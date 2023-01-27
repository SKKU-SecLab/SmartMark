

pragma solidity 0.5.17;


contract GenesisProtocolInterface {

    function setParameters(
        uint[11] calldata _params, //use array here due to stack too deep issue.
        address _voteOnBehalf
    )
    external
    returns(bytes32);

}


pragma solidity 0.5.17;

interface IntVoteInterface {

    modifier votable(bytes32 _proposalId) {revert("proposal is not votable"); _;}


    event NewProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _numOfChoices,
        address _proposer,
        bytes32 _paramsHash
    );

    event ExecuteProposal(bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _decision,
        uint256 _totalReputation
    );

    event VoteProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        address indexed _voter,
        uint256 _vote,
        uint256 _reputation
    );

    event CancelProposal(bytes32 indexed _proposalId, address indexed _organization );
    event CancelVoting(bytes32 indexed _proposalId, address indexed _organization, address indexed _voter);

    function propose(
        uint256 _numOfChoices,
        bytes32 _proposalParameters,
        address _proposer,
        address _organization
        ) external returns(bytes32);


    function vote(
        bytes32 _proposalId,
        uint256 _vote,
        uint256 _rep,
        address _voter
    )
    external
    returns(bool);


    function cancelVote(bytes32 _proposalId) external;


    function getNumberOfChoices(bytes32 _proposalId) external view returns(uint256);


    function isVotable(bytes32 _proposalId) external view returns(bool);


    function voteStatus(bytes32 _proposalId, uint256 _choice) external view returns(uint256);


    function isAbstainAllow() external pure returns(bool);


    function getAllowedRangeOfChoices() external pure returns(uint256 min, uint256 max);

}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.5.17;


interface VotingMachineCallbacksInterface {

    function mintReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId) external returns(bool);

    function burnReputation(uint256 _amount, address _owner, bytes32 _proposalId) external returns(bool);


    function stakingTokenTransfer(IERC20 _stakingToken, address _beneficiary, uint256 _amount, bytes32 _proposalId)
    external
    returns(bool);


    function getTotalReputationSupply(bytes32 _proposalId) external view returns(uint256);

    function reputationOf(address _owner, bytes32 _proposalId) external view returns(uint256);

    function balanceOfStakingToken(IERC20 _stakingToken, bytes32 _proposalId) external view returns(uint256);

}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.17;



contract Reputation is Ownable {


    uint8 public decimals = 18;             //Number of decimals of the smallest unit
    event Mint(address indexed _to, uint256 _amount);
    event Burn(address indexed _from, uint256 _amount);

    struct Checkpoint {

        uint128 fromBlock;

        uint128 value;
    }

    mapping (address => Checkpoint[]) private balances;

    Checkpoint[] private totalSupplyHistory;

    function mint(address _user, uint256 _amount) public onlyOwner returns (bool) {

        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply, "total supply overflow"); // Check for overflow
        uint256 previousBalanceTo = balanceOf(_user);
        require(previousBalanceTo + _amount >= previousBalanceTo, "balace overflow"); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_user], previousBalanceTo + _amount);
        emit Mint(_user, _amount);
        return true;
    }

    function burn(address _user, uint256 _amount) public onlyOwner returns (bool) {

        uint256 curTotalSupply = totalSupply();
        uint256 amountBurned = _amount;
        uint256 previousBalanceFrom = balanceOf(_user);
        if (previousBalanceFrom < amountBurned) {
            amountBurned = previousBalanceFrom;
        }
        updateValueAtNow(totalSupplyHistory, curTotalSupply - amountBurned);
        updateValueAtNow(balances[_user], previousBalanceFrom - amountBurned);
        emit Burn(_user, amountBurned);
        return true;
    }

    function totalSupply() public view returns (uint256) {

        return totalSupplyAt(block.number);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);
    }

    function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {

        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            return 0;
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

    function balanceOfAt(address _owner, uint256 _blockNumber)
    public view returns (uint256)
    {

        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            return 0;
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    function getValueAt(Checkpoint[] storage checkpoints, uint256 _block) internal view returns (uint256) {

        if (checkpoints.length == 0) {
            return 0;
        }

        if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }
        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

        uint256 min = 0;
        uint256 max = checkpoints.length-1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value) internal {

        require(uint128(_value) == _value, "reputation overflow"); //check value is in the 128 bits bounderies
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;



contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }
}


pragma solidity 0.5.17;






contract DAOToken is ERC20, ERC20Burnable, Ownable {


    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public cap;

    constructor(string memory _name, string memory _symbol, uint256 _cap)
    public {
        name = _name;
        symbol = _symbol;
        cap = _cap;
    }

    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {

        if (cap > 0)
            require(totalSupply().add(_amount) <= cap);
        _mint(_to, _amount);
        return true;
    }
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity 0.5.17;



library SafeERC20 {

    using Address for address;

    bytes4 constant private TRANSFER_SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 constant private TRANSFERFROM_SELECTOR = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
    bytes4 constant private APPROVE_SELECTOR = bytes4(keccak256(bytes("approve(address,uint256)")));

    function safeTransfer(address _erc20Addr, address _to, uint256 _value) internal {


        require(_erc20Addr.isContract());

        (bool success, bytes memory returnValue) =
        _erc20Addr.call(abi.encodeWithSelector(TRANSFER_SELECTOR, _to, _value));
        require(success);
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }

    function safeTransferFrom(address _erc20Addr, address _from, address _to, uint256 _value) internal {


        require(_erc20Addr.isContract());

        (bool success, bytes memory returnValue) =
        _erc20Addr.call(abi.encodeWithSelector(TRANSFERFROM_SELECTOR, _from, _to, _value));
        require(success);
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }

    function safeApprove(address _erc20Addr, address _spender, uint256 _value) internal {


        require(_erc20Addr.isContract());

        require((_value == 0) || (IERC20(_erc20Addr).allowance(address(this), _spender) == 0));

        (bool success, bytes memory returnValue) =
        _erc20Addr.call(abi.encodeWithSelector(APPROVE_SELECTOR, _spender, _value));
        require(success);
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }
}


pragma solidity 0.5.17;







contract Avatar is Ownable {

    using SafeERC20 for address;

    string public orgName;
    DAOToken public nativeToken;
    Reputation public nativeReputation;

    event GenericCall(address indexed _contract, bytes _data, uint _value, bool _success);
    event SendEther(uint256 _amountInWei, address indexed _to);
    event ExternalTokenTransfer(address indexed _externalToken, address indexed _to, uint256 _value);
    event ExternalTokenTransferFrom(address indexed _externalToken, address _from, address _to, uint256 _value);
    event ExternalTokenApproval(address indexed _externalToken, address _spender, uint256 _value);
    event ReceiveEther(address indexed _sender, uint256 _value);
    event MetaData(string _metaData);

    constructor(string memory _orgName, DAOToken _nativeToken, Reputation _nativeReputation) public {
        orgName = _orgName;
        nativeToken = _nativeToken;
        nativeReputation = _nativeReputation;
    }

    function() external payable {
        emit ReceiveEther(msg.sender, msg.value);
    }

    function genericCall(address _contract, bytes memory _data, uint256 _value)
    public
    onlyOwner
    returns(bool success, bytes memory returnValue) {

        (success, returnValue) = _contract.call.value(_value)(_data);
        emit GenericCall(_contract, _data, _value, success);
    }

    function sendEther(uint256 _amountInWei, address payable _to) public onlyOwner returns(bool) {

        _to.transfer(_amountInWei);
        emit SendEther(_amountInWei, _to);
        return true;
    }

    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value)
    public onlyOwner returns(bool)
    {

        address(_externalToken).safeTransfer(_to, _value);
        emit ExternalTokenTransfer(address(_externalToken), _to, _value);
        return true;
    }

    function externalTokenTransferFrom(
        IERC20 _externalToken,
        address _from,
        address _to,
        uint256 _value
    )
    public onlyOwner returns(bool)
    {

        address(_externalToken).safeTransferFrom(_from, _to, _value);
        emit ExternalTokenTransferFrom(address(_externalToken), _from, _to, _value);
        return true;
    }

    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value)
    public onlyOwner returns(bool)
    {

        address(_externalToken).safeApprove(_spender, _value);
        emit ExternalTokenApproval(address(_externalToken), _spender, _value);
        return true;
    }

    function metaData(string memory _metaData) public onlyOwner returns(bool) {

        emit MetaData(_metaData);
        return true;
    }


}


pragma solidity 0.5.17;


contract UniversalSchemeInterface {


    function getParametersFromController(Avatar _avatar) internal view returns(bytes32);

    
}


pragma solidity 0.5.17;


contract GlobalConstraintInterface {


    enum CallPhase { Pre, Post, PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);

    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);

    function when() public returns(CallPhase);

}


pragma solidity 0.5.17;



contract Controller {


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
        uint256 index;    //index at globalConstraints
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
    event UpgradeController(address indexed _oldController, address _newController);

    event AddGlobalConstraint(
        address indexed _globalConstraint,
        bytes32 _params,
        GlobalConstraintInterface.CallPhase _when);

    event RemoveGlobalConstraint(address indexed _globalConstraint, uint256 _index, bool _isPre);

    constructor( Avatar _avatar) public {
        avatar = _avatar;
        nativeToken = avatar.nativeToken();
        nativeReputation = avatar.nativeReputation();
        schemes[msg.sender] = Scheme({paramsHash: bytes32(0), permissions: bytes4(0x0000001F)});
        emit RegisterScheme (msg.sender, msg.sender);
    }

    function() external {
        revert();
    }

    modifier onlyRegisteredScheme() {

        require(schemes[msg.sender].permissions&bytes4(0x00000001) == bytes4(0x00000001));
        _;
    }

    modifier onlyRegisteringSchemes() {

        require(schemes[msg.sender].permissions&bytes4(0x00000002) == bytes4(0x00000002));
        _;
    }

    modifier onlyGlobalConstraintsScheme() {

        require(schemes[msg.sender].permissions&bytes4(0x00000004) == bytes4(0x00000004));
        _;
    }

    modifier onlyUpgradingScheme() {

        require(schemes[msg.sender].permissions&bytes4(0x00000008) == bytes4(0x00000008));
        _;
    }

    modifier onlyGenericCallScheme() {

        require(schemes[msg.sender].permissions&bytes4(0x00000010) == bytes4(0x00000010));
        _;
    }

    modifier onlyMetaDataScheme() {

        require(schemes[msg.sender].permissions&bytes4(0x00000010) == bytes4(0x00000010));
        _;
    }

    modifier onlySubjectToConstraint(bytes32 func) {

        uint256 idx;
        for (idx = 0; idx < globalConstraintsPre.length; idx++) {
            require(
            (GlobalConstraintInterface(globalConstraintsPre[idx].gcAddress))
            .pre(msg.sender, globalConstraintsPre[idx].params, func));
        }
        _;
        for (idx = 0; idx < globalConstraintsPost.length; idx++) {
            require(
            (GlobalConstraintInterface(globalConstraintsPost[idx].gcAddress))
            .post(msg.sender, globalConstraintsPost[idx].params, func));
        }
    }

    modifier isAvatarValid(address _avatar) {

        require(_avatar == address(avatar));
        _;
    }

    function mintReputation(uint256 _amount, address _to, address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("mintReputation")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit MintReputation(msg.sender, _to, _amount);
        return nativeReputation.mint(_to, _amount);
    }

    function burnReputation(uint256 _amount, address _from, address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("burnReputation")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit BurnReputation(msg.sender, _from, _amount);
        return nativeReputation.burn(_from, _amount);
    }

    function mintTokens(uint256 _amount, address _beneficiary, address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("mintTokens")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit MintTokens(msg.sender, _beneficiary, _amount);
        return nativeToken.mint(_beneficiary, _amount);
    }

    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions, address _avatar)
    external
    onlyRegisteringSchemes
    onlySubjectToConstraint("registerScheme")
    isAvatarValid(_avatar)
    returns(bool)
    {


        Scheme memory scheme = schemes[_scheme];


        require(bytes4(0x0000001f)&(_permissions^scheme.permissions)&(~schemes[msg.sender].permissions) == bytes4(0));

        require(bytes4(0x0000001f)&(scheme.permissions&(~schemes[msg.sender].permissions)) == bytes4(0));

        schemes[_scheme].paramsHash = _paramsHash;
        schemes[_scheme].permissions = _permissions|bytes4(0x00000001);
        emit RegisterScheme(msg.sender, _scheme);
        return true;
    }

    function unregisterScheme( address _scheme, address _avatar)
    external
    onlyRegisteringSchemes
    onlySubjectToConstraint("unregisterScheme")
    isAvatarValid(_avatar)
    returns(bool)
    {

        if (_isSchemeRegistered(_scheme) == false) {
            return false;
        }
        require(bytes4(0x0000001f)&(schemes[_scheme].permissions&(~schemes[msg.sender].permissions)) == bytes4(0));

        emit UnregisterScheme(msg.sender, _scheme);
        delete schemes[_scheme];
        return true;
    }

    function unregisterSelf(address _avatar) external isAvatarValid(_avatar) returns(bool) {

        if (_isSchemeRegistered(msg.sender) == false) {
            return false;
        }
        delete schemes[msg.sender];
        emit UnregisterScheme(msg.sender, msg.sender);
        return true;
    }

    function addGlobalConstraint(address _globalConstraint, bytes32 _params, address _avatar)
    external
    onlyGlobalConstraintsScheme
    isAvatarValid(_avatar)
    returns(bool)
    {

        GlobalConstraintInterface.CallPhase when = GlobalConstraintInterface(_globalConstraint).when();
        if ((when == GlobalConstraintInterface.CallPhase.Pre)||
            (when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            if (!globalConstraintsRegisterPre[_globalConstraint].isRegistered) {
                globalConstraintsPre.push(GlobalConstraint(_globalConstraint, _params));
                globalConstraintsRegisterPre[_globalConstraint] =
                GlobalConstraintRegister(true, globalConstraintsPre.length-1);
            }else {
                globalConstraintsPre[globalConstraintsRegisterPre[_globalConstraint].index].params = _params;
            }
        }
        if ((when == GlobalConstraintInterface.CallPhase.Post)||
            (when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            if (!globalConstraintsRegisterPost[_globalConstraint].isRegistered) {
                globalConstraintsPost.push(GlobalConstraint(_globalConstraint, _params));
                globalConstraintsRegisterPost[_globalConstraint] =
                GlobalConstraintRegister(true, globalConstraintsPost.length-1);
            }else {
                globalConstraintsPost[globalConstraintsRegisterPost[_globalConstraint].index].params = _params;
            }
        }
        emit AddGlobalConstraint(_globalConstraint, _params, when);
        return true;
    }

    function removeGlobalConstraint (address _globalConstraint, address _avatar)
    external
    onlyGlobalConstraintsScheme
    isAvatarValid(_avatar)
    returns(bool)
    {
        GlobalConstraintRegister memory globalConstraintRegister;
        GlobalConstraint memory globalConstraint;
        GlobalConstraintInterface.CallPhase when = GlobalConstraintInterface(_globalConstraint).when();
        bool retVal = false;

        if ((when == GlobalConstraintInterface.CallPhase.Pre)||
            (when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
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
        if ((when == GlobalConstraintInterface.CallPhase.Post)||
            (when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
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
            emit RemoveGlobalConstraint(
            _globalConstraint,
            globalConstraintRegister.index,
            when == GlobalConstraintInterface.CallPhase.Pre
            );
        }
        return retVal;
    }

    function upgradeController(address _newController, Avatar _avatar)
    external
    onlyUpgradingScheme
    isAvatarValid(address(_avatar))
    returns(bool)
    {

        require(newController == address(0));   // so the upgrade could be done once for a contract.
        require(_newController != address(0));
        newController = _newController;
        avatar.transferOwnership(_newController);
        require(avatar.owner() == _newController);
        if (nativeToken.owner() == address(this)) {
            nativeToken.transferOwnership(_newController);
            require(nativeToken.owner() == _newController);
        }
        if (nativeReputation.owner() == address(this)) {
            nativeReputation.transferOwnership(_newController);
            require(nativeReputation.owner() == _newController);
        }
        emit UpgradeController(address(this), newController);
        return true;
    }

    function genericCall(address _contract, bytes calldata _data, Avatar _avatar, uint256 _value)
    external
    onlyGenericCallScheme
    onlySubjectToConstraint("genericCall")
    isAvatarValid(address(_avatar))
    returns (bool, bytes memory)
    {

        return avatar.genericCall(_contract, _data, _value);
    }

    function sendEther(uint256 _amountInWei, address payable _to, Avatar _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("sendEther")
    isAvatarValid(address(_avatar))
    returns(bool)
    {

        return avatar.sendEther(_amountInWei, _to);
    }

    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value, Avatar _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenTransfer")
    isAvatarValid(address(_avatar))
    returns(bool)
    {

        return avatar.externalTokenTransfer(_externalToken, _to, _value);
    }

    function externalTokenTransferFrom(
    IERC20 _externalToken,
    address _from,
    address _to,
    uint256 _value,
    Avatar _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenTransferFrom")
    isAvatarValid(address(_avatar))
    returns(bool)
    {

        return avatar.externalTokenTransferFrom(_externalToken, _from, _to, _value);
    }

    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value, Avatar _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenIncreaseApproval")
    isAvatarValid(address(_avatar))
    returns(bool)
    {

        return avatar.externalTokenApproval(_externalToken, _spender, _value);
    }

    function metaData(string calldata _metaData, Avatar _avatar)
        external
        onlyMetaDataScheme
        isAvatarValid(address(_avatar))
        returns(bool)
        {

        return avatar.metaData(_metaData);
    }

    function getNativeReputation(address _avatar) external isAvatarValid(_avatar) view returns(address) {

        return address(nativeReputation);
    }

    function isSchemeRegistered(address _scheme, address _avatar) external isAvatarValid(_avatar) view returns(bool) {

        return _isSchemeRegistered(_scheme);
    }

    function getSchemeParameters(address _scheme, address _avatar)
    external
    isAvatarValid(_avatar)
    view
    returns(bytes32)
    {

        return schemes[_scheme].paramsHash;
    }

    function getSchemePermissions(address _scheme, address _avatar)
    external
    isAvatarValid(_avatar)
    view
    returns(bytes4)
    {

        return schemes[_scheme].permissions;
    }

    function getGlobalConstraintParameters(address _globalConstraint, address) external view returns(bytes32) {


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
        returns(uint, uint)
        {

        return (globalConstraintsPre.length, globalConstraintsPost.length);
    }

    function isGlobalConstraintRegistered(address _globalConstraint, address _avatar)
        external
        isAvatarValid(_avatar)
        view
        returns(bool)
        {

        return (globalConstraintsRegisterPre[_globalConstraint].isRegistered ||
                globalConstraintsRegisterPost[_globalConstraint].isRegistered);
    }

    function _isSchemeRegistered(address _scheme) private view returns(bool) {

        return (schemes[_scheme].permissions&bytes4(0x00000001) != bytes4(0));
    }
}


pragma solidity 0.5.17;





contract UniversalScheme is UniversalSchemeInterface {

    function getParametersFromController(Avatar _avatar) internal view returns(bytes32) {

        require(Controller(_avatar.owner()).isSchemeRegistered(address(this), address(_avatar)),
        "scheme is not registered");
        return Controller(_avatar.owner()).getSchemeParameters(address(this), address(_avatar));
    }
}


pragma solidity 0.5.17;

interface ProposalExecuteInterface {

    function executeProposal(bytes32 _proposalId, int _decision) external returns(bool);

}


pragma solidity 0.5.17;





contract VotingMachineCallbacks is VotingMachineCallbacksInterface {


    struct ProposalInfo {
        uint256 blockNumber; // the proposal's block number
        Avatar avatar; // the proposal's avatar
    }

    modifier onlyVotingMachine(bytes32 _proposalId) {

        require(proposalsInfo[msg.sender][_proposalId].avatar != Avatar(address(0)), "only VotingMachine");
        _;
    }

    modifier onlyRegisteredScheme(bytes32 _proposalId) {

        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        require(Controller(avatar.owner()).isSchemeRegistered(address(this), address(avatar)),
            "scheme is not registered"
        );
        _;
    }

    mapping(address => mapping(bytes32 => ProposalInfo)) public proposalsInfo;

    function mintReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {

        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return Controller(avatar.owner()).mintReputation(_amount, _beneficiary, address(avatar));
    }

    function burnReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {

        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return Controller(avatar.owner()).burnReputation(_amount, _beneficiary, address(avatar));
    }

    function stakingTokenTransfer(
        IERC20 _stakingToken,
        address _beneficiary,
        uint256 _amount,
        bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {

        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return Controller(avatar.owner()).externalTokenTransfer(_stakingToken, _beneficiary, _amount, avatar);
    }

    function balanceOfStakingToken(IERC20 _stakingToken, bytes32 _proposalId) external view returns(uint256) {

        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        if (proposalsInfo[msg.sender][_proposalId].avatar == Avatar(0)) {
            return 0;
        }
        return _stakingToken.balanceOf(address(avatar));
    }

    function getTotalReputationSupply(bytes32 _proposalId)
    external
    view
    onlyRegisteredScheme(_proposalId)
    returns(uint256) {

        ProposalInfo memory proposal = proposalsInfo[msg.sender][_proposalId];
        if (proposal.avatar == Avatar(0)) {
            return 0;
        }
        return proposal.avatar.nativeReputation().totalSupplyAt(proposal.blockNumber);
    }

    function reputationOf(address _owner, bytes32 _proposalId)
    external
    view
    onlyRegisteredScheme(_proposalId)
    returns(uint256) {

        ProposalInfo memory proposal = proposalsInfo[msg.sender][_proposalId];
        if (proposal.avatar == Avatar(0)) {
            return 0;
        }
        return proposal.avatar.nativeReputation().balanceOfAt(_owner, proposal.blockNumber);
    }
}


pragma solidity 0.5.17;






contract ContributionRewardExt is VotingMachineCallbacks, ProposalExecuteInterface {

    using SafeMath for uint;
    using SafeERC20 for address;

    event NewContributionProposal(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _intVoteInterface,
        string _descriptionHash,
        int256 _reputationChange,
        uint[3]  _rewards,
        IERC20 _externalToken,
        address _beneficiary,
        address _proposer
    );

    event ProposalExecuted(address indexed _avatar, bytes32 indexed _proposalId, int256 _param);

    event RedeemReputation(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        int256 _amount);

    event RedeemEther(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

    event RedeemNativeToken(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

    event RedeemExternalToken(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

    struct ContributionProposal {
        uint256 nativeTokenReward; // Reward asked in the native token of the organization.
        int256 reputationChange; // Organization reputation reward requested.
        uint256 ethReward;
        IERC20 externalToken;
        uint256 externalTokenReward;
        address payable beneficiary;
        uint256 nativeTokenRewardLeft;
        uint256 reputationChangeLeft;
        uint256 ethRewardLeft;
        uint256 externalTokenRewardLeft;
        bool acceptedByVotingMachine;
    }

    modifier onlyRewarder() {

        require(msg.sender == rewarder, "msg.sender is not authorized");
        _;
    }

    mapping(bytes32=>ContributionProposal) public organizationProposals;

    IntVoteInterface public votingMachine;
    bytes32 public voteParams;
    Avatar public avatar;
    address public rewarder;

    function() external payable {
    }

    function initialize(
        Avatar _avatar,
        IntVoteInterface _votingMachine,
        bytes32 _voteParams,
        address _rewarder
    )
    external
    {

        require(avatar == Avatar(0), "can be called only one time");
        require(_avatar != Avatar(0), "avatar cannot be zero");
        require(_votingMachine != IntVoteInterface(0), "votingMachine cannot be zero");
        avatar = _avatar;
        votingMachine = _votingMachine;
        voteParams = _voteParams;
        rewarder = _rewarder;
    }

    function executeProposal(bytes32 _proposalId, int256 _decision)
    external
    onlyVotingMachine(_proposalId)
    returns(bool) {

        require(organizationProposals[_proposalId].acceptedByVotingMachine == false);
        require(organizationProposals[_proposalId].beneficiary != address(0));
        if (_decision == 1) {
            organizationProposals[_proposalId].acceptedByVotingMachine = true;
        }
        emit ProposalExecuted(address(avatar), _proposalId, _decision);
        return true;
    }

    function proposeContributionReward(
        string memory _descriptionHash,
        int256 _reputationChange,
        uint[3] memory _rewards,
        IERC20 _externalToken,
        address payable _beneficiary,
        address _proposer
    )
    public
    returns(bytes32 proposalId)
    {

        address proposer = _proposer;
        if (proposer == address(0)) {
            proposer = msg.sender;
        }
        proposalId = votingMachine.propose(2, voteParams, proposer, address(avatar));
        address payable beneficiary = _beneficiary;
        if (beneficiary == address(0)) {
            beneficiary = msg.sender;
        }
        if (beneficiary == address(this)) {
            require(_reputationChange >= 0, "negative rep change not allowed for this case");
        }

        ContributionProposal memory proposal = ContributionProposal({
            nativeTokenReward: _rewards[0],
            reputationChange: _reputationChange,
            ethReward: _rewards[1],
            externalToken: _externalToken,
            externalTokenReward: _rewards[2],
            beneficiary: beneficiary,
            nativeTokenRewardLeft: 0,
            reputationChangeLeft: 0,
            ethRewardLeft: 0,
            externalTokenRewardLeft: 0,
            acceptedByVotingMachine: false
        });
        organizationProposals[proposalId] = proposal;

        emit NewContributionProposal(
            address(avatar),
            proposalId,
            address(votingMachine),
            _descriptionHash,
            _reputationChange,
            _rewards,
            _externalToken,
            beneficiary,
            proposer
        );

        proposalsInfo[address(votingMachine)][proposalId] = ProposalInfo({
            blockNumber:block.number,
            avatar:avatar
        });
    }

    function redeemReputation(bytes32 _proposalId) public returns(int256 reputation) {

        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");

        if (proposal.beneficiary == address(this)) {
            if (proposal.reputationChangeLeft == 0) {//for now only mint(not burn) rep allowed from ext contract.
                proposal.reputationChangeLeft = uint256(proposal.reputationChange);
                proposal.reputationChange = 0;
            }
        } else {
            reputation = proposal.reputationChange;
            proposal.reputationChange = 0;

            if (reputation > 0) {
                require(
                Controller(
                avatar.owner()).mintReputation(uint(reputation), proposal.beneficiary, address(avatar)));
            } else if (reputation < 0) {
                require(
                Controller(
                avatar.owner()).burnReputation(uint(reputation*(-1)), proposal.beneficiary, address(avatar)));
            }
            if (reputation != 0) {
                emit RedeemReputation(address(avatar), _proposalId, proposal.beneficiary, reputation);
            }
        }
    }

    function redeemNativeToken(bytes32 _proposalId) public returns(uint256 amount) {


        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");

        if (proposal.beneficiary == address(this)) {
            if (proposal.nativeTokenRewardLeft == 0) {
                proposal.nativeTokenRewardLeft = proposal.nativeTokenReward;
            }
        }
        amount = proposal.nativeTokenReward;
        proposal.nativeTokenReward = 0;
        if (amount > 0) {
            require(Controller(avatar.owner()).mintTokens(amount, proposal.beneficiary, address(avatar)));
            emit RedeemNativeToken(address(avatar), _proposalId, proposal.beneficiary, amount);
        }
    }

    function redeemEther(bytes32 _proposalId) public returns(uint256 amount) {

        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");

        if (proposal.beneficiary == address(this)) {
            if (proposal.ethRewardLeft == 0) {
                proposal.ethRewardLeft = proposal.ethReward;
            }
        }
        amount = proposal.ethReward;
        proposal.ethReward = 0;
        if (amount > 0) {
            require(Controller(avatar.owner()).sendEther(amount, proposal.beneficiary, avatar));
            emit RedeemEther(address(avatar), _proposalId, proposal.beneficiary, amount);
        }
    }

    function redeemExternalToken(bytes32 _proposalId) public returns(uint256 amount) {

        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");


        if (proposal.beneficiary == address(this)) {
            if (proposal.externalTokenRewardLeft == 0) {
                proposal.externalTokenRewardLeft = proposal.externalTokenReward;
            }
        }

        if (proposal.externalToken != IERC20(0) && proposal.externalTokenReward > 0) {
            amount = proposal.externalTokenReward;
            proposal.externalTokenReward = 0;
            require(
            Controller(
            avatar.owner())
            .externalTokenTransfer(proposal.externalToken, proposal.beneficiary, amount, avatar));
            emit RedeemExternalToken(address(avatar), _proposalId, proposal.beneficiary, amount);
        }
    }

    function redeemReputationByRewarder(bytes32 _proposalId, address _beneficiary, uint256 _reputation)
    public
    onlyRewarder
    {

        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");
        proposal.reputationChangeLeft =
        proposal.reputationChangeLeft.sub(_reputation,
        "cannot redeem more reputation than allocated for this proposal or no redeemReputation was called");
        require(
        Controller(
        avatar.owner()).mintReputation(_reputation, _beneficiary, address(avatar)));
        if (_reputation != 0) {
            emit RedeemReputation(address(avatar), _proposalId, _beneficiary, int256(_reputation));
        }
    }

    function redeemNativeTokenByRewarder(bytes32 _proposalId, address _beneficiary, uint256 _amount)
    public
    onlyRewarder
    {

        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");
        proposal.nativeTokenRewardLeft =
        proposal.nativeTokenRewardLeft.sub(_amount,
        "cannot redeem more tokens than allocated for this proposal or no redeemNativeToken was called");

        if (_amount > 0) {
            address(avatar.nativeToken()).safeTransfer(_beneficiary, _amount);
            emit RedeemNativeToken(address(avatar), _proposalId, _beneficiary, _amount);
        }
    }

    function redeemEtherByRewarder(bytes32 _proposalId, address payable _beneficiary, uint256 _amount)
    public
    onlyRewarder
    {

        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");
        proposal.ethRewardLeft = proposal.ethRewardLeft.sub(_amount,
        "cannot redeem more Ether than allocated for this proposal or no redeemEther was called");

        if (_amount > 0) {
            _beneficiary.transfer(_amount);
            emit RedeemEther(address(avatar), _proposalId, _beneficiary, _amount);
        }
    }

    function redeemExternalTokenByRewarder(bytes32 _proposalId, address _beneficiary, uint256 _amount)
    public
    onlyRewarder {

        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");
        proposal.externalTokenRewardLeft =
        proposal.externalTokenRewardLeft.sub(_amount,
        "cannot redeem more tokens than allocated for this proposal or no redeemExternalToken was called");

        if (proposal.externalToken != IERC20(0)) {
            if (_amount > 0) {
                address(proposal.externalToken).safeTransfer(_beneficiary, _amount);
                emit RedeemExternalToken(address(avatar), _proposalId, _beneficiary, _amount);
            }
        }
    }

    function redeem(bytes32 _proposalId, bool[4] memory _whatToRedeem)
    public
    returns(int256 reputationReward, uint256 nativeTokenReward, uint256 etherReward, uint256 externalTokenReward)
    {


        if (_whatToRedeem[0]) {
            reputationReward = redeemReputation(_proposalId);
        }

        if (_whatToRedeem[1]) {
            nativeTokenReward = redeemNativeToken(_proposalId);
        }

        if (_whatToRedeem[2]) {
            etherReward = redeemEther(_proposalId);
        }

        if (_whatToRedeem[3]) {
            externalTokenReward = redeemExternalToken(_proposalId);
        }
    }

    function getProposalEthReward(bytes32 _proposalId) public view returns (uint256) {

        return organizationProposals[_proposalId].ethReward;
    }

    function getProposalExternalTokenReward(bytes32 _proposalId) public view returns (uint256) {

        return organizationProposals[_proposalId].externalTokenReward;
    }

    function getProposalExternalToken(bytes32 _proposalId) public view returns (address) {

        return address(organizationProposals[_proposalId].externalToken);
    }

    function getProposalReputationReward(bytes32 _proposalId) public view returns (int256) {

        return organizationProposals[_proposalId].reputationChange;
    }

    function getProposalNativeTokenReward(bytes32 _proposalId) public view returns (uint256) {

        return organizationProposals[_proposalId].nativeTokenReward;
    }

    function getProposalAcceptedByVotingMachine(bytes32 _proposalId) public view returns (bool) {

        return organizationProposals[_proposalId].acceptedByVotingMachine;
    }

}


pragma solidity 0.5.17;



contract Competition {

    using SafeMath for uint256;

    event NewCompetitionProposal(
        bytes32 indexed _proposalId,
        uint256 _numberOfWinners,
        uint256[] _rewardSplit,
        uint256 _startTime,
        uint256 _votingStartTime,
        uint256 _suggestionsEndTime,
        uint256 _endTime,
        uint256 _maxNumberOfVotesPerVoter,
        address payable _contributionRewardExt, //address of the contract to redeem from.
        address _admin
    );

    event Redeem(
        bytes32 indexed _proposalId,
        uint256 indexed _suggestionId,
        uint256 _rewardPercentage
    );

    event NewSuggestion(
        bytes32 indexed _proposalId,
        uint256 indexed _suggestionId,
        string _descriptionHash,
        address payable indexed _beneficiary
    );

    event NewVote(
        bytes32 indexed _proposalId,
        uint256 indexed _suggestionId,
        address indexed _voter,
        uint256 _reputation
    );

    event SnapshotBlock(
        bytes32 indexed _proposalId,
        uint256 _snapshotBlock
    );

    struct Proposal {
        uint256 numberOfWinners;
        uint256[] rewardSplit;
        uint256 startTime;
        uint256 votingStartTime;
        uint256 suggestionsEndTime;
        uint256 endTime;
        uint256 maxNumberOfVotesPerVoter;
        address payable contributionRewardExt;
        uint256 snapshotBlock;
        uint256 reputationReward;
        uint256 ethReward;
        uint256 nativeTokenReward;
        uint256 externalTokenReward;
        uint256[] topSuggestions;
        address admin;
        mapping(uint256=>uint256) suggestionsPerVote;
        mapping(address=>uint256) votesPerVoter;
    }

    struct Suggestion {
        uint256 totalVotes;
        bytes32 proposalId;
        address payable beneficiary;
        mapping(address=>uint256) votes;
    }

    mapping(bytes32=>Proposal) public proposals;
    mapping(uint256=>Suggestion) public suggestions;
    uint256 public suggestionsCounter;
    address payable public contributionRewardExt; //address of the contract to redeem from.
    uint256 constant public REDEMPTION_PERIOD = 7776000; //90 days
    uint256 constant public MAX_NUMBER_OF_WINNERS = 100;

    function initialize(address payable _contributionRewardExt) external {

        require(contributionRewardExt == address(0), "can be called only one time");
        require(_contributionRewardExt != address(0), "contributionRewardExt cannot be zero");
        contributionRewardExt = _contributionRewardExt;
    }

    function proposeCompetition(
            string calldata _descriptionHash,
            int256 _reputationChange,
            uint[3] calldata _rewards,
            IERC20 _externalToken,
            uint256[] calldata _rewardSplit,
            uint256[5] calldata _competitionParams,
            bool _proposerIsAdmin
    )
    external
    returns(bytes32 proposalId) {

        uint256 numberOfWinners = _rewardSplit.length;
        uint256 startTime = _competitionParams[0];
        if (startTime == 0) {
            startTime = now;
        }
        require(startTime >= now, "startTime should be greater than proposing time");
        require(numberOfWinners <= MAX_NUMBER_OF_WINNERS, "number of winners greater than max allowed");
        require(_competitionParams[1] < _competitionParams[2], "voting start time greater than end time");
        require(_competitionParams[1] >= startTime, "voting start time smaller than start time");
        require(_competitionParams[3] > 0, "maxNumberOfVotesPerVoter should be greater than 0");
        require(_competitionParams[4] <= _competitionParams[2],
        "suggestionsEndTime should be earlier than proposal end time");
        require(_competitionParams[4] > startTime, "suggestionsEndTime should be later than proposal start time");
        if (_rewards[2] > 0) {
            require(_externalToken != ERC20(0), "extenal token cannot be zero");
        }
        require(_reputationChange >= 0, "negative reputation change is not allowed for a competition");
        uint256 totalRewardSplit;
        for (uint256 i = 0; i < numberOfWinners; i++) {
            totalRewardSplit = totalRewardSplit.add(_rewardSplit[i]);
        }
        require(totalRewardSplit == 100, "total rewards split is not 100%");
        proposalId = ContributionRewardExt(contributionRewardExt).proposeContributionReward(
                _descriptionHash, _reputationChange, _rewards, _externalToken, contributionRewardExt, msg.sender);
        proposals[proposalId].numberOfWinners = numberOfWinners;
        proposals[proposalId].rewardSplit = _rewardSplit;
        proposals[proposalId].startTime = startTime;
        proposals[proposalId].votingStartTime = _competitionParams[1];
        proposals[proposalId].endTime = _competitionParams[2];
        proposals[proposalId].maxNumberOfVotesPerVoter = _competitionParams[3];
        proposals[proposalId].suggestionsEndTime = _competitionParams[4];
        proposals[proposalId].reputationReward = uint256(_reputationChange);
        proposals[proposalId].nativeTokenReward = _rewards[0];
        proposals[proposalId].ethReward = _rewards[1];
        proposals[proposalId].externalTokenReward = _rewards[2];
        proposals[proposalId].snapshotBlock = 0;
        if (_proposerIsAdmin) {
            proposals[proposalId].admin = msg.sender;
        }
        emit NewCompetitionProposal(
            proposalId,
            numberOfWinners,
            proposals[proposalId].rewardSplit,
            startTime,
            proposals[proposalId].votingStartTime,
            proposals[proposalId].suggestionsEndTime,
            proposals[proposalId].endTime,
            proposals[proposalId].maxNumberOfVotesPerVoter,
            contributionRewardExt,
            proposals[proposalId].admin
        );
    }

    function suggest(
            bytes32 _proposalId,
            string calldata _descriptionHash,
            address payable _beneficiary
    )
    external
    returns(uint256)
    {

        if (proposals[_proposalId].admin != address(0)) {
            require(proposals[_proposalId].admin == msg.sender, "only admin can suggest");
        }
        require(proposals[_proposalId].startTime <= now, "competition not started yet");
        require(proposals[_proposalId].suggestionsEndTime > now, "suggestions submission time is over");
        suggestionsCounter = suggestionsCounter.add(1);
        suggestions[suggestionsCounter].proposalId = _proposalId;
        address payable beneficiary;
        if (_beneficiary == address(0)) {
            beneficiary = msg.sender;
        } else {
            beneficiary = _beneficiary;
        }
        suggestions[suggestionsCounter].beneficiary = beneficiary;
        emit NewSuggestion(_proposalId, suggestionsCounter, _descriptionHash, beneficiary);
        return suggestionsCounter;
    }

    function vote(uint256 _suggestionId)
    external
    returns(bool)
    {

        bytes32 proposalId = suggestions[_suggestionId].proposalId;
        require(proposalId != bytes32(0), "suggestion does not exist");
        setSnapshotBlock(proposalId);
        Avatar avatar = ContributionRewardExt(contributionRewardExt).avatar();
        uint256 reputation = avatar.nativeReputation().balanceOfAt(msg.sender, proposals[proposalId].snapshotBlock);
        require(reputation > 0, "voter had no reputation when snapshot was taken");
        Proposal storage proposal = proposals[proposalId];
        require(proposal.endTime > now, "competition ended");
        Suggestion storage suggestion = suggestions[_suggestionId];
        require(suggestion.votes[msg.sender] == 0, "already voted on this suggestion");
        require(proposal.votesPerVoter[msg.sender] < proposal.maxNumberOfVotesPerVoter,
        "exceed number of votes allowed");
        proposal.votesPerVoter[msg.sender] = proposal.votesPerVoter[msg.sender].add(1);
        if (suggestion.totalVotes > 0) {
            proposal.suggestionsPerVote[suggestion.totalVotes] =
            proposal.suggestionsPerVote[suggestion.totalVotes].sub(1);
        }
        suggestion.totalVotes = suggestion.totalVotes.add(reputation);
        proposal.suggestionsPerVote[suggestion.totalVotes] = proposal.suggestionsPerVote[suggestion.totalVotes].add(1);
        suggestion.votes[msg.sender] = reputation;
        refreshTopSuggestions(proposalId, _suggestionId);
        emit NewVote(proposalId, _suggestionId, msg.sender, reputation);
        return true;
    }

    function setSnapshotBlock(bytes32 _proposalId) public {

        require(proposals[_proposalId].votingStartTime < now, "voting period not started yet");
        require(proposals[_proposalId].maxNumberOfVotesPerVoter > 0, "proposal does not exist");
        if (proposals[_proposalId].snapshotBlock == 0) {
            proposals[_proposalId].snapshotBlock = block.number;
            emit SnapshotBlock(_proposalId, block.number);
        }
    }

    function sendLeftOverFunds(bytes32 _proposalId) public {

        require(proposals[_proposalId].endTime.add(REDEMPTION_PERIOD) < now, "redemption period is still on");
        require(proposals[_proposalId].maxNumberOfVotesPerVoter > 0, "proposal does not exist");
        require(_proposalId != bytes32(0), "proposalId is zero");

        (, , , , , ,
        uint256 nativeTokenRewardLeft, ,
        uint256 ethRewardLeft,
        uint256 externalTokenRewardLeft,)
        = ContributionRewardExt(contributionRewardExt).organizationProposals(_proposalId);

        Avatar avatar = ContributionRewardExt(contributionRewardExt).avatar();

        ContributionRewardExt(contributionRewardExt).redeemExternalTokenByRewarder(
        _proposalId, address(avatar), externalTokenRewardLeft);

        ContributionRewardExt(contributionRewardExt).redeemEtherByRewarder(
        _proposalId, address(avatar), ethRewardLeft);

        ContributionRewardExt(contributionRewardExt).redeemNativeTokenByRewarder(
        _proposalId, address(avatar), nativeTokenRewardLeft);
    }

    function redeem(uint256 _suggestionId) public {

        bytes32 proposalId = suggestions[_suggestionId].proposalId;
        require(proposalId != bytes32(0), "proposalId is zero");
        Proposal storage proposal = proposals[proposalId];
        require(_suggestionId > 0, "suggestionId is zero");
        require(proposal.endTime < now, "competition is still on");
        require(proposal.endTime.add(REDEMPTION_PERIOD) > now, "redemption period is over");
        require(proposal.maxNumberOfVotesPerVoter > 0, "proposal does not exist");
        require(suggestions[_suggestionId].beneficiary != address(0),
        "suggestion was already redeemed");
        address payable beneficiary = suggestions[_suggestionId].beneficiary;
        uint256 orderIndex = getOrderedIndexOfSuggestion(_suggestionId);
        require(orderIndex < proposal.topSuggestions.length, "suggestion is not in winners list");
        suggestions[_suggestionId].beneficiary = address(0);
        uint256 rewardPercentage = 0;
        uint256 numberOfTieSuggestions = proposal.suggestionsPerVote[suggestions[_suggestionId].totalVotes];
        uint256 j;
        for (j = orderIndex; j < (orderIndex+numberOfTieSuggestions) && j < proposal.numberOfWinners; j++) {
            rewardPercentage = rewardPercentage.add(proposal.rewardSplit[j]);
        }
        rewardPercentage = rewardPercentage.div(numberOfTieSuggestions);
        uint256 rewardPercentageLeft = 0;
        if (proposal.topSuggestions.length < proposal.numberOfWinners) {
            for (j = proposal.topSuggestions.length; j < proposal.numberOfWinners; j++) {
                rewardPercentageLeft = rewardPercentageLeft.add(proposal.rewardSplit[j]);
            }
            rewardPercentage =
            rewardPercentage.add(rewardPercentageLeft.div(proposal.topSuggestions.length));
        }
        uint256 amount;
        amount = proposal.externalTokenReward.mul(rewardPercentage).div(100);
        ContributionRewardExt(contributionRewardExt).redeemExternalTokenByRewarder(
        proposalId, beneficiary, amount);

        amount = proposal.reputationReward.mul(rewardPercentage).div(100);
        ContributionRewardExt(contributionRewardExt).redeemReputationByRewarder(
        proposalId, beneficiary, amount);

        amount = proposal.ethReward.mul(rewardPercentage).div(100);
        ContributionRewardExt(contributionRewardExt).redeemEtherByRewarder(
        proposalId, beneficiary, amount);

        amount = proposal.nativeTokenReward.mul(rewardPercentage).div(100);
        ContributionRewardExt(contributionRewardExt).redeemNativeTokenByRewarder(
        proposalId, beneficiary, amount);
        emit Redeem(proposalId, _suggestionId, rewardPercentage);
    }

    function getOrderedIndexOfSuggestion(uint256 _suggestionId)
    public
    view
    returns(uint256 index) {

        bytes32 proposalId = suggestions[_suggestionId].proposalId;
        require(proposalId != bytes32(0), "suggestion does not exist");
        uint256[] memory topSuggestions = proposals[proposalId].topSuggestions;
        for (uint256 i = 0; i < topSuggestions.length; i++) {
            if (suggestions[topSuggestions[i]].totalVotes > suggestions[_suggestionId].totalVotes) {
                index++;
            }
        }
    }

    function refreshTopSuggestions(bytes32 _proposalId, uint256 _suggestionId) private {

        uint256[] storage topSuggestions = proposals[_proposalId].topSuggestions;
        uint256 topSuggestionsLength = topSuggestions.length;
        uint256 i;
        if (topSuggestionsLength < proposals[_proposalId].numberOfWinners) {
            for (i = 0; i < topSuggestionsLength; i++) {
                if (topSuggestions[i] == _suggestionId) {
                    return;
                }
            }
            topSuggestions.push(_suggestionId);
        } else {
            uint256 smallest = 0;
            for (i = 0; i < proposals[_proposalId].numberOfWinners; i++) {
                if (suggestions[topSuggestions[i]].totalVotes <
                    suggestions[topSuggestions[smallest]].totalVotes) {
                    smallest = i;
                } else if (topSuggestions[i] == _suggestionId) {
                    return;
                }
            }

            if (suggestions[topSuggestions[smallest]].totalVotes < suggestions[_suggestionId].totalVotes) {
                topSuggestions[smallest] = _suggestionId;
            }
        }
    }

}


pragma solidity 0.5.17;




contract CompetitionFactory {

    uint8 public constant CUSTOM = 0;
    uint8 public constant FAST = 1;
    uint8 public constant NORMAL = 2;
    uint8 public constant SLOW = 3;

    event NewCompetition(address competition, address contributionRewardExt);

    function createCompetition(
        Avatar _avatar,
        IntVoteInterface _votingMachine,
        uint8 _voteParamsType,
        uint256[11] memory _votingParams,
        address _voteOnBehalf
    ) public returns(address, address) {

        require(_voteParamsType < 4, "Vote params type specified does not exist");
        ContributionRewardExt contributionRewardExt = new ContributionRewardExt();
        Competition competition = new Competition();
        competition.initialize(address(contributionRewardExt));
        
        uint256[11] memory voteParams;
        if (_voteParamsType == CUSTOM) {
            voteParams = _votingParams;
        } else {
            voteParams = getDefaultVoteParams(_voteParamsType);
        }

        bytes32 voteParamsHash = GenesisProtocolInterface(address(_votingMachine))
                                    .setParameters(voteParams, _voteOnBehalf);

        contributionRewardExt.initialize(
            _avatar, _votingMachine, voteParamsHash, address(competition)
        );

        emit NewCompetition(address(competition), address(contributionRewardExt));
        return (address(competition), address(contributionRewardExt));
    }

    function getDefaultVoteParams(uint8 _voteParamsType) private pure returns(uint256[11] memory voteParams) {

        if (_voteParamsType == FAST) {
            voteParams = [
                uint256(50),
                uint256(604800),
                uint256(129600),
                uint256(43200),
                uint256(1200),
                uint256(86400),
                uint256(10000000000000000000),
                uint256(1),
                uint256(50000000000000000000),
                uint256(10),
                uint256(0)
            ];
        } else if (_voteParamsType == NORMAL) {
            voteParams = [
                uint256(50),
                uint256(2592000),
                uint256(345600),
                uint256(86400),
                uint256(1200),
                uint256(172800),
                uint256(50000000000000000000),
                uint256(4),
                uint256(150000000000000000000),
                uint256(10),
                uint256(0)
            ];
        } else if (_voteParamsType == SLOW) {
            voteParams = [
                uint256(50),
                uint256(5184000),
                uint256(691200),
                uint256(172800),
                uint256(1500),
                uint256(345600),
                uint256(200000000000000000000),
                uint256(4),
                uint256(500000000000000000000),
                uint256(10),
                uint256(0)
            ];
        }
    }
}