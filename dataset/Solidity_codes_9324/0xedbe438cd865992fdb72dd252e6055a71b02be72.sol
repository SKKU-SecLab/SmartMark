

pragma solidity >0.5.4;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Reputation is Ownable {


    uint8 public decimals = 18;             //Number of decimals of the smallest unit
    event Mint(address indexed _to, uint256 _amount);
    event Burn(address indexed _from, uint256 _amount);

    struct Checkpoint {

        uint128 fromBlock;

        uint128 value;
    }

    mapping (address => Checkpoint[]) balances;

    Checkpoint[] totalSupplyHistory;

    constructor(
    ) public
    {
    }

    function totalSupply() public view returns (uint256) {

        return totalSupplyAt(block.number);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);
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

    function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {

        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            return 0;
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

    function mint(address _user, uint256 _amount) public onlyOwner returns (bool) {

        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint256 previousBalanceTo = balanceOf(_user);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
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
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value) internal {

        require(uint128(_value) == _value); //check value is in the 128 bits bounderies
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

contract ERC20Burnable is ERC20 {

    function burn(uint256 value) public {

        _burn(msg.sender, value);
    }

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);
    }
}

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

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

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

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}

contract PauserRole {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {

        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract Pausable is PauserRole {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused);
        _;
    }

    modifier whenPaused() {

        require(_paused);
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract GlobalConstraintInterface {


    enum CallPhase { Pre, Post, PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);

    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);

    function when() public returns(CallPhase);

}

interface ControllerInterface {


    function mintReputation(uint256 _amount, address _to, address _avatar)
    external
    returns(bool);


    function burnReputation(uint256 _amount, address _from, address _avatar)
    external
    returns(bool);


    function mintTokens(uint256 _amount, address _beneficiary, address _avatar)
    external
    returns(bool);


    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions, address _avatar)
    external
    returns(bool);


    function unregisterScheme(address _scheme, address _avatar)
    external
    returns(bool);


    function unregisterSelf(address _avatar) external returns(bool);


    function addGlobalConstraint(address _globalConstraint, bytes32 _params, address _avatar)
    external returns(bool);


    function removeGlobalConstraint (address _globalConstraint, address _avatar)
    external  returns(bool);

    function upgradeController(address _newController, Avatar _avatar)
    external returns(bool);


    function genericCall(address _contract, bytes calldata _data, Avatar _avatar, uint256 _value)
    external
    returns(bool, bytes memory);


    function sendEther(uint256 _amountInWei, address payable _to, Avatar _avatar)
    external returns(bool);


    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value, Avatar _avatar)
    external
    returns(bool);


    function externalTokenTransferFrom(
    IERC20 _externalToken,
    address _from,
    address _to,
    uint256 _value,
    Avatar _avatar)
    external
    returns(bool);


    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value, Avatar _avatar)
    external
    returns(bool);


    function metaData(string calldata _metaData, Avatar _avatar) external returns(bool);


    function getNativeReputation(address _avatar)
    external
    view
    returns(address);


    function isSchemeRegistered( address _scheme, address _avatar) external view returns(bool);


    function getSchemeParameters(address _scheme, address _avatar) external view returns(bytes32);


    function getGlobalConstraintParameters(address _globalConstraint, address _avatar) external view returns(bytes32);


    function getSchemePermissions(address _scheme, address _avatar) external view returns(bytes4);


    function globalConstraintsCount(address _avatar) external view returns(uint, uint);


    function isGlobalConstraintRegistered(address _globalConstraint, address _avatar) external view returns(bool);

}

contract SchemeGuard is Ownable {

    Avatar avatar;
    ControllerInterface internal controller = ControllerInterface(0);

    constructor(Avatar _avatar) public {
        avatar = _avatar;

        if (avatar != Avatar(0)) {
            controller = ControllerInterface(avatar.owner());
        }
    }

    modifier onlyAvatar() {

        require(address(avatar) == msg.sender, "only Avatar can call this method");
        _;
    }

    modifier onlyRegistered() {

        require(isRegistered(), "Scheme is not registered");
        _;
    }

    modifier onlyNotRegistered() {

        require(!isRegistered(), "Scheme is registered");
        _;
    }

    modifier onlyRegisteredCaller() {

        require(isRegistered(msg.sender), "Calling scheme is not registered");
        _;
    }

    function setAvatar(Avatar _avatar) public onlyOwner {

        avatar = _avatar;
        controller = ControllerInterface(avatar.owner());
    }

    function isRegistered() public view returns (bool) {

        return isRegistered(address(this));
    }

    function isRegistered(address scheme) public view returns (bool) {

        require(avatar != Avatar(0), "Avatar is not set");

        if (!(controller.isSchemeRegistered(scheme, address(avatar)))) {
            return false;
        }
        return true;
    }
}

contract IdentityAdminRole is Ownable {

    using Roles for Roles.Role;

    event IdentityAdminAdded(address indexed account);
    event IdentityAdminRemoved(address indexed account);

    Roles.Role private IdentityAdmins;

    constructor() internal {
        _addIdentityAdmin(msg.sender);
    }

    modifier onlyIdentityAdmin() {

        require(isIdentityAdmin(msg.sender), "not IdentityAdmin");
        _;
    }

    function isIdentityAdmin(address account) public view returns (bool) {

        return IdentityAdmins.has(account);
    }

    function addIdentityAdmin(address account) public onlyOwner returns (bool) {

        _addIdentityAdmin(account);
        return true;
    }

    function removeIdentityAdmin(address account) public onlyOwner returns (bool) {

        _removeIdentityAdmin(account);
        return true;
    }

    function renounceIdentityAdmin() public {

        _removeIdentityAdmin(msg.sender);
    }

    function _addIdentityAdmin(address account) internal {

        IdentityAdmins.add(account);
        emit IdentityAdminAdded(account);
    }

    function _removeIdentityAdmin(address account) internal {

        IdentityAdmins.remove(account);
        emit IdentityAdminRemoved(account);
    }
}

contract Identity is IdentityAdminRole, SchemeGuard, Pausable {

    using Roles for Roles.Role;
    using SafeMath for uint256;

    Roles.Role private blacklist;
    Roles.Role private whitelist;
    Roles.Role private contracts;

    uint256 public whitelistedCount = 0;
    uint256 public whitelistedContracts = 0;
    uint256 public authenticationPeriod = 14;

    mapping(address => uint256) public dateAuthenticated;
    mapping(address => uint256) public dateAdded;

    mapping(address => string) public addrToDID;
    mapping(bytes32 => address) public didHashToAddress;

    event BlacklistAdded(address indexed account);
    event BlacklistRemoved(address indexed account);

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    event ContractAdded(address indexed account);
    event ContractRemoved(address indexed account);

    constructor() public SchemeGuard(Avatar(0)) {}

    function setAuthenticationPeriod(uint256 period) public onlyOwner whenNotPaused {

        authenticationPeriod = period;
    }

    function authenticate(address account)
        public
        onlyRegistered
        onlyIdentityAdmin
        whenNotPaused
    {

        dateAuthenticated[account] = now;
    }

    function addWhitelisted(address account)
        public
        onlyRegistered
        onlyIdentityAdmin
        whenNotPaused
    {

        _addWhitelisted(account);
    }

    function addWhitelistedWithDID(address account, string memory did)
        public
        onlyRegistered
        onlyIdentityAdmin
        whenNotPaused
    {

        _addWhitelistedWithDID(account, did);
    }

    function removeWhitelisted(address account)
        public
        onlyRegistered
        onlyIdentityAdmin
        whenNotPaused
    {

        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public whenNotPaused {

        _removeWhitelisted(msg.sender);
    }

    function isWhitelisted(address account) public view returns (bool) {

        uint256 daysSinceAuthentication = (now.sub(dateAuthenticated[account])) / 1 days;
        return
            (daysSinceAuthentication <= authenticationPeriod) && whitelist.has(account);
    }

    function lastAuthenticated(address account) public view returns (uint256) {

        return dateAuthenticated[account];
    }





    function addBlacklisted(address account)
        public
        onlyRegistered
        onlyIdentityAdmin
        whenNotPaused
    {

        blacklist.add(account);
        emit BlacklistAdded(account);
    }

    function removeBlacklisted(address account)
        public
        onlyRegistered
        onlyIdentityAdmin
        whenNotPaused
    {

        blacklist.remove(account);
        emit BlacklistRemoved(account);
    }

    function addContract(address account)
        public
        onlyRegistered
        onlyIdentityAdmin
        whenNotPaused
    {

        require(isContract(account), "Given address is not a contract");
        contracts.add(account);
        _addWhitelisted(account);

        emit ContractAdded(account);
    }

    function removeContract(address account)
        public
        onlyRegistered
        onlyIdentityAdmin
        whenNotPaused
    {

        contracts.remove(account);
        _removeWhitelisted(account);

        emit ContractRemoved(account);
    }

    function isDAOContract(address account) public view returns (bool) {

        return contracts.has(account);
    }

    function _addWhitelisted(address account) internal {

        whitelist.add(account);

        whitelistedCount += 1;
        dateAdded[account] = now;
        dateAuthenticated[account] = now;

        if (isContract(account)) {
            whitelistedContracts += 1;
        }

        emit WhitelistedAdded(account);
    }

    function _addWhitelistedWithDID(address account, string memory did) internal {

        bytes32 pHash = keccak256(bytes(did));
        require(didHashToAddress[pHash] == address(0), "DID already registered");

        addrToDID[account] = did;
        didHashToAddress[pHash] = account;

        _addWhitelisted(account);
    }

    function _removeWhitelisted(address account) internal {

        whitelist.remove(account);

        whitelistedCount -= 1;
        delete dateAuthenticated[account];

        if (isContract(account)) {
            whitelistedContracts -= 1;
        }

        string memory did = addrToDID[account];
        bytes32 pHash = keccak256(bytes(did));

        delete dateAuthenticated[account];
        delete addrToDID[account];
        delete didHashToAddress[pHash];

        emit WhitelistedRemoved(account);
    }

    function isBlacklisted(address account) public view returns (bool) {

        return blacklist.has(account);
    }

    function isContract(address _addr) internal view returns (bool) {

        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}

contract IdentityGuard is Ownable {

    Identity public identity;

    constructor(Identity _identity) public {
        require(_identity != Identity(0), "Supplied identity is null");
        identity = _identity;
    }

    modifier onlyNotBlacklisted() {

        require(!identity.isBlacklisted(msg.sender), "Caller is blacklisted");
        _;
    }

    modifier requireNotBlacklisted(address _account) {

        require(!identity.isBlacklisted(_account), "Receiver is blacklisted");
        _;
    }

    modifier onlyWhitelisted() {

        require(identity.isWhitelisted(msg.sender), "is not whitelisted");
        _;
    }

    modifier requireWhitelisted(address _account) {

        require(identity.isWhitelisted(_account), "is not whitelisted");
        _;
    }

    modifier onlyDAOContract() {

        require(identity.isDAOContract(msg.sender), "is not whitelisted contract");
        _;
    }

    modifier requireDAOContract(address _contract) {

        require(identity.isDAOContract(_contract), "is not whitelisted contract");
        _;
    }

    modifier onlyAddedBefore(uint256 date) {

        require(
            identity.lastAuthenticated(msg.sender) <= date,
            "Was not added within period"
        );
        _;
    }

    modifier onlyIdentityAdmin() {

        require(identity.isIdentityAdmin(msg.sender), "not IdentityAdmin");
        _;
    }

    function setIdentity(Identity _identity) public onlyOwner {

        require(_identity.isRegistered(), "Identity is not registered");
        identity = _identity;
    }
}

contract AbstractFees is SchemeGuard {

    constructor() public SchemeGuard(Avatar(0)) {}

    function getTxFees(
        uint256 _value,
        address _sender,
        address _recipient
    ) public view returns (uint256, bool);

}

contract FeeFormula is AbstractFees {

    using SafeMath for uint256;

    uint256 public percentage;
    bool public constant senderPays = false;

    constructor(uint256 _percentage) public {
        require(_percentage < 100, "Percentage should be <100");
        percentage = _percentage;
    }

    function getTxFees(
        uint256 _value,
        address _sender,
        address _recipient
    ) public view returns (uint256, bool) {

        return (_value.mul(percentage).div(100), senderPays);
    }
}

contract FormulaHolder is Ownable {

    AbstractFees public formula;

    constructor(AbstractFees _formula) public {
        require(_formula != AbstractFees(0), "Supplied formula is null");
        formula = _formula;
    }

    function setFormula(AbstractFees _formula) public onlyOwner {

        _formula.isRegistered();
        formula = _formula;
    }
}

interface ERC677 {

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function transferAndCall(
        address,
        uint256,
        bytes calldata
    ) external returns (bool);

}

interface ERC677Receiver {

    function onTokenTransfer(
        address _from,
        uint256 _value,
        bytes calldata _data
    ) external returns (bool);

}

contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(spender, subtractedValue);
    }
}

contract ERC677Token is ERC677, DAOToken, ERC20Pausable {

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _cap
    ) public DAOToken(_name, _symbol, _cap) {}

    function _transferAndCall(
        address _to,
        uint256 _value,
        bytes memory _data
    ) internal whenNotPaused returns (bool) {

        bool res = super.transfer(_to, _value);
        emit Transfer(msg.sender, _to, _value, _data);

        if (isContract(_to)) {
            require(contractFallback(_to, _value, _data), "Contract fallback failed");
        }
        return res;
    }

    function contractFallback(
        address _to,
        uint256 _value,
        bytes memory _data
    ) private returns (bool) {

        ERC677Receiver receiver = ERC677Receiver(_to);
        require(
            receiver.onTokenTransfer(msg.sender, _value, _data),
            "Contract Fallback failed"
        );
        return true;
    }


    function isContract(address _addr) internal view returns (bool) {

        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}

contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract ERC677BridgeToken is ERC677Token, MinterRole {

    address public bridgeContract;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _cap
    ) public ERC677Token(_name, _symbol, _cap) {}

    function setBridgeContract(address _bridgeContract) public onlyMinter {

        require(
            _bridgeContract != address(0) && isContract(_bridgeContract),
            "Invalid bridge contract"
        );
        bridgeContract = _bridgeContract;
    }
}

contract GoodDollar is ERC677BridgeToken, IdentityGuard, FormulaHolder {

    address feeRecipient;

    uint256 public constant decimals = 2;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _cap,
        AbstractFees _formula,
        Identity _identity,
        address _feeRecipient
    )
        public
        ERC677BridgeToken(_name, _symbol, _cap)
        IdentityGuard(_identity)
        FormulaHolder(_formula)
    {
        feeRecipient = _feeRecipient;
    }

    function transfer(address to, uint256 value) public returns (bool) {

        uint256 bruttoValue = processFees(msg.sender, to, value);
        return super.transfer(to, bruttoValue);
    }

    function approve(address spender, uint256 value) public returns (bool) {

        return super.approve(spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {

        uint256 bruttoValue = processFees(from, to, value);
        return super.transferFrom(from, to, bruttoValue);
    }

    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool) {

        uint256 bruttoValue = processFees(msg.sender, to, value);
        return super._transferAndCall(to, bruttoValue, data);
    }

    function mint(address to, uint256 value)
        public
        onlyMinter
        requireNotBlacklisted(to)
        returns (bool)
    {

        if (cap > 0) {
            require(totalSupply().add(value) <= cap, "Cannot increase supply beyond cap");
        }
        super._mint(to, value);
        return true;
    }

    function burn(uint256 value) public onlyNotBlacklisted {

        super.burn(value);
    }

    function burnFrom(address from, uint256 value)
        public
        onlyNotBlacklisted
        requireNotBlacklisted(from)
    {

        super.burnFrom(from, value);
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {

        return super.decreaseAllowance(spender, subtractedValue);
    }

    function getFees(uint256 value) public view returns (uint256, bool) {

        return formula.getTxFees(value, address(0), address(0));
    }

    function getFees(
        uint256 value,
        address sender,
        address recipient
    ) public view returns (uint256, bool) {

        return formula.getTxFees(value, sender, recipient);
    }

    function setFeeRecipient(address _feeRecipient) public onlyOwner {

        feeRecipient = _feeRecipient;
    }

    function processFees(
        address account,
        address recipient,
        uint256 value
    ) internal returns (uint256) {

        (uint256 txFees, bool senderPays) = getFees(value, account, recipient);
        if (txFees > 0 && !identity.isDAOContract(msg.sender)) {
            require(
                senderPays == false || value.add(txFees) <= balanceOf(account),
                "Not enough balance to pay TX fee"
            );
            if (account == msg.sender) {
                super.transfer(feeRecipient, txFees);
            } else {
                super.transferFrom(account, feeRecipient, txFees);
            }

            return senderPays ? value : value.sub(txFees);
        }
        return value;
    }
}

contract DSMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x >= y ? x : y;
    }
    function imin(int256 x, int256 y) internal pure returns (int256 z) {

        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) internal pure returns (int256 z) {

        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract BancorFormula {

    using SafeMath for uint256;

    uint16 public version = 6;

    uint256 private constant ONE = 1;
    uint32 private constant MAX_RATIO = 1000000;
    uint8 private constant MIN_PRECISION = 32;
    uint8 private constant MAX_PRECISION = 127;

    uint256 private constant FIXED_1 = 0x080000000000000000000000000000000;
    uint256 private constant FIXED_2 = 0x100000000000000000000000000000000;
    uint256 private constant MAX_NUM = 0x200000000000000000000000000000000;

    uint256 private constant LN2_NUMERATOR = 0x3f80fe03f80fe03f80fe03f80fe03f8;
    uint256 private constant LN2_DENOMINATOR = 0x5b9de1d10bf4103d647b0955897ba80;

    uint256 private constant OPT_LOG_MAX_VAL = 0x15bf0a8b1457695355fb8ac404e7a79e3;
    uint256 private constant OPT_EXP_MAX_VAL = 0x800000000000000000000000000000000;

    uint256[128] private maxExpArray;

    constructor() public {
        maxExpArray[32] = 0x1c35fedd14ffffffffffffffffffffffff;
        maxExpArray[33] = 0x1b0ce43b323fffffffffffffffffffffff;
        maxExpArray[34] = 0x19f0028ec1ffffffffffffffffffffffff;
        maxExpArray[35] = 0x18ded91f0e7fffffffffffffffffffffff;
        maxExpArray[36] = 0x17d8ec7f0417ffffffffffffffffffffff;
        maxExpArray[37] = 0x16ddc6556cdbffffffffffffffffffffff;
        maxExpArray[38] = 0x15ecf52776a1ffffffffffffffffffffff;
        maxExpArray[39] = 0x15060c256cb2ffffffffffffffffffffff;
        maxExpArray[40] = 0x1428a2f98d72ffffffffffffffffffffff;
        maxExpArray[41] = 0x13545598e5c23fffffffffffffffffffff;
        maxExpArray[42] = 0x1288c4161ce1dfffffffffffffffffffff;
        maxExpArray[43] = 0x11c592761c666fffffffffffffffffffff;
        maxExpArray[44] = 0x110a688680a757ffffffffffffffffffff;
        maxExpArray[45] = 0x1056f1b5bedf77ffffffffffffffffffff;
        maxExpArray[46] = 0x0faadceceeff8bffffffffffffffffffff;
        maxExpArray[47] = 0x0f05dc6b27edadffffffffffffffffffff;
        maxExpArray[48] = 0x0e67a5a25da4107fffffffffffffffffff;
        maxExpArray[49] = 0x0dcff115b14eedffffffffffffffffffff;
        maxExpArray[50] = 0x0d3e7a392431239fffffffffffffffffff;
        maxExpArray[51] = 0x0cb2ff529eb71e4fffffffffffffffffff;
        maxExpArray[52] = 0x0c2d415c3db974afffffffffffffffffff;
        maxExpArray[53] = 0x0bad03e7d883f69bffffffffffffffffff;
        maxExpArray[54] = 0x0b320d03b2c343d5ffffffffffffffffff;
        maxExpArray[55] = 0x0abc25204e02828dffffffffffffffffff;
        maxExpArray[56] = 0x0a4b16f74ee4bb207fffffffffffffffff;
        maxExpArray[57] = 0x09deaf736ac1f569ffffffffffffffffff;
        maxExpArray[58] = 0x0976bd9952c7aa957fffffffffffffffff;
        maxExpArray[59] = 0x09131271922eaa606fffffffffffffffff;
        maxExpArray[60] = 0x08b380f3558668c46fffffffffffffffff;
        maxExpArray[61] = 0x0857ddf0117efa215bffffffffffffffff;
        maxExpArray[62] = 0x07ffffffffffffffffffffffffffffffff;
        maxExpArray[63] = 0x07abbf6f6abb9d087fffffffffffffffff;
        maxExpArray[64] = 0x075af62cbac95f7dfa7fffffffffffffff;
        maxExpArray[65] = 0x070d7fb7452e187ac13fffffffffffffff;
        maxExpArray[66] = 0x06c3390ecc8af379295fffffffffffffff;
        maxExpArray[67] = 0x067c00a3b07ffc01fd6fffffffffffffff;
        maxExpArray[68] = 0x0637b647c39cbb9d3d27ffffffffffffff;
        maxExpArray[69] = 0x05f63b1fc104dbd39587ffffffffffffff;
        maxExpArray[70] = 0x05b771955b36e12f7235ffffffffffffff;
        maxExpArray[71] = 0x057b3d49dda84556d6f6ffffffffffffff;
        maxExpArray[72] = 0x054183095b2c8ececf30ffffffffffffff;
        maxExpArray[73] = 0x050a28be635ca2b888f77fffffffffffff;
        maxExpArray[74] = 0x04d5156639708c9db33c3fffffffffffff;
        maxExpArray[75] = 0x04a23105873875bd52dfdfffffffffffff;
        maxExpArray[76] = 0x0471649d87199aa990756fffffffffffff;
        maxExpArray[77] = 0x04429a21a029d4c1457cfbffffffffffff;
        maxExpArray[78] = 0x0415bc6d6fb7dd71af2cb3ffffffffffff;
        maxExpArray[79] = 0x03eab73b3bbfe282243ce1ffffffffffff;
        maxExpArray[80] = 0x03c1771ac9fb6b4c18e229ffffffffffff;
        maxExpArray[81] = 0x0399e96897690418f785257fffffffffff;
        maxExpArray[82] = 0x0373fc456c53bb779bf0ea9fffffffffff;
        maxExpArray[83] = 0x034f9e8e490c48e67e6ab8bfffffffffff;
        maxExpArray[84] = 0x032cbfd4a7adc790560b3337ffffffffff;
        maxExpArray[85] = 0x030b50570f6e5d2acca94613ffffffffff;
        maxExpArray[86] = 0x02eb40f9f620fda6b56c2861ffffffffff;
        maxExpArray[87] = 0x02cc8340ecb0d0f520a6af58ffffffffff;
        maxExpArray[88] = 0x02af09481380a0a35cf1ba02ffffffffff;
        maxExpArray[89] = 0x0292c5bdd3b92ec810287b1b3fffffffff;
        maxExpArray[90] = 0x0277abdcdab07d5a77ac6d6b9fffffffff;
        maxExpArray[91] = 0x025daf6654b1eaa55fd64df5efffffffff;
        maxExpArray[92] = 0x0244c49c648baa98192dce88b7ffffffff;
        maxExpArray[93] = 0x022ce03cd5619a311b2471268bffffffff;
        maxExpArray[94] = 0x0215f77c045fbe885654a44a0fffffffff;
        maxExpArray[95] = 0x01ffffffffffffffffffffffffffffffff;
        maxExpArray[96] = 0x01eaefdbdaaee7421fc4d3ede5ffffffff;
        maxExpArray[97] = 0x01d6bd8b2eb257df7e8ca57b09bfffffff;
        maxExpArray[98] = 0x01c35fedd14b861eb0443f7f133fffffff;
        maxExpArray[99] = 0x01b0ce43b322bcde4a56e8ada5afffffff;
        maxExpArray[100] = 0x019f0028ec1fff007f5a195a39dfffffff;
        maxExpArray[101] = 0x018ded91f0e72ee74f49b15ba527ffffff;
        maxExpArray[102] = 0x017d8ec7f04136f4e5615fd41a63ffffff;
        maxExpArray[103] = 0x016ddc6556cdb84bdc8d12d22e6fffffff;
        maxExpArray[104] = 0x015ecf52776a1155b5bd8395814f7fffff;
        maxExpArray[105] = 0x015060c256cb23b3b3cc3754cf40ffffff;
        maxExpArray[106] = 0x01428a2f98d728ae223ddab715be3fffff;
        maxExpArray[107] = 0x013545598e5c23276ccf0ede68034fffff;
        maxExpArray[108] = 0x01288c4161ce1d6f54b7f61081194fffff;
        maxExpArray[109] = 0x011c592761c666aa641d5a01a40f17ffff;
        maxExpArray[110] = 0x0110a688680a7530515f3e6e6cfdcdffff;
        maxExpArray[111] = 0x01056f1b5bedf75c6bcb2ce8aed428ffff;
        maxExpArray[112] = 0x00faadceceeff8a0890f3875f008277fff;
        maxExpArray[113] = 0x00f05dc6b27edad306388a600f6ba0bfff;
        maxExpArray[114] = 0x00e67a5a25da41063de1495d5b18cdbfff;
        maxExpArray[115] = 0x00dcff115b14eedde6fc3aa5353f2e4fff;
        maxExpArray[116] = 0x00d3e7a3924312399f9aae2e0f868f8fff;
        maxExpArray[117] = 0x00cb2ff529eb71e41582cccd5a1ee26fff;
        maxExpArray[118] = 0x00c2d415c3db974ab32a51840c0b67edff;
        maxExpArray[119] = 0x00bad03e7d883f69ad5b0a186184e06bff;
        maxExpArray[120] = 0x00b320d03b2c343d4829abd6075f0cc5ff;
        maxExpArray[121] = 0x00abc25204e02828d73c6e80bcdb1a95bf;
        maxExpArray[122] = 0x00a4b16f74ee4bb2040a1ec6c15fbbf2df;
        maxExpArray[123] = 0x009deaf736ac1f569deb1b5ae3f36c130f;
        maxExpArray[124] = 0x00976bd9952c7aa957f5937d790ef65037;
        maxExpArray[125] = 0x009131271922eaa6064b73a22d0bd4f2bf;
        maxExpArray[126] = 0x008b380f3558668c46c91c49a2f8e967b9;
        maxExpArray[127] = 0x00857ddf0117efa215952912839f6473e6;
    }

    function calculatePurchaseReturn(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _depositAmount
    ) public view returns (uint256) {

        require(
            _supply > 0 &&
                _reserveBalance > 0 &&
                _reserveRatio > 0 &&
                _reserveRatio <= MAX_RATIO
        );

        if (_depositAmount == 0) return 0;

        if (_reserveRatio == MAX_RATIO)
            return _supply.mul(_depositAmount) / _reserveBalance;

        uint256 result;
        uint8 precision;
        uint256 baseN = _depositAmount.add(_reserveBalance);
        (result, precision) = power(baseN, _reserveBalance, _reserveRatio, MAX_RATIO);
        uint256 temp = _supply.mul(result) >> precision;
        return temp - _supply;
    }

    function calculateSaleReturn(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _sellAmount
    ) public view returns (uint256) {

        require(
            _supply > 0 &&
                _reserveBalance > 0 &&
                _reserveRatio > 0 &&
                _reserveRatio <= MAX_RATIO &&
                _sellAmount <= _supply
        );

        if (_sellAmount == 0) return 0;

        if (_sellAmount == _supply) return _reserveBalance;

        if (_reserveRatio == MAX_RATIO) return _reserveBalance.mul(_sellAmount) / _supply;

        uint256 result;
        uint8 precision;
        uint256 baseD = _supply - _sellAmount;
        (result, precision) = power(_supply, baseD, MAX_RATIO, _reserveRatio);
        uint256 temp1 = _reserveBalance.mul(result);
        uint256 temp2 = _reserveBalance << precision;
        return (temp1 - temp2) / result;
    }

    function calculateCrossReserveReturn(
        uint256 _fromReserveBalance,
        uint32 _fromReserveRatio,
        uint256 _toReserveBalance,
        uint32 _toReserveRatio,
        uint256 _amount
    ) public view returns (uint256) {

        require(
            _fromReserveBalance > 0 &&
                _fromReserveRatio > 0 &&
                _fromReserveRatio <= MAX_RATIO &&
                _toReserveBalance > 0 &&
                _toReserveRatio > 0 &&
                _toReserveRatio <= MAX_RATIO
        );

        if (_fromReserveRatio == _toReserveRatio)
            return _toReserveBalance.mul(_amount) / _fromReserveBalance.add(_amount);

        uint256 result;
        uint8 precision;
        uint256 baseN = _fromReserveBalance.add(_amount);
        (result, precision) = power(
            baseN,
            _fromReserveBalance,
            _fromReserveRatio,
            _toReserveRatio
        );
        uint256 temp1 = _toReserveBalance.mul(result);
        uint256 temp2 = _toReserveBalance << precision;
        return (temp1 - temp2) / result;
    }

    function calculateFundCost(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _totalRatio,
        uint256 _amount
    ) public view returns (uint256) {

        require(
            _supply > 0 &&
                _reserveBalance > 0 &&
                _totalRatio > 1 &&
                _totalRatio <= MAX_RATIO * 2
        );

        if (_amount == 0) return 0;

        if (_totalRatio == MAX_RATIO)
            return (_amount.mul(_reserveBalance) - 1) / _supply + 1;

        uint256 result;
        uint8 precision;
        uint256 baseN = _supply.add(_amount);
        (result, precision) = power(baseN, _supply, MAX_RATIO, _totalRatio);
        uint256 temp = ((_reserveBalance.mul(result) - 1) >> precision) + 1;
        return temp - _reserveBalance;
    }

    function calculateLiquidateReturn(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _totalRatio,
        uint256 _amount
    ) public view returns (uint256) {

        require(
            _supply > 0 &&
                _reserveBalance > 0 &&
                _totalRatio > 1 &&
                _totalRatio <= MAX_RATIO * 2 &&
                _amount <= _supply
        );

        if (_amount == 0) return 0;

        if (_amount == _supply) return _reserveBalance;

        if (_totalRatio == MAX_RATIO) return _amount.mul(_reserveBalance) / _supply;

        uint256 result;
        uint8 precision;
        uint256 baseD = _supply - _amount;
        (result, precision) = power(_supply, baseD, MAX_RATIO, _totalRatio);
        uint256 temp1 = _reserveBalance.mul(result);
        uint256 temp2 = _reserveBalance << precision;
        return (temp1 - temp2) / result;
    }

    function power(
        uint256 _baseN,
        uint256 _baseD,
        uint32 _expN,
        uint32 _expD
    ) internal view returns (uint256, uint8) {

        require(_baseN < MAX_NUM);

        uint256 baseLog;
        uint256 base = (_baseN * FIXED_1) / _baseD;
        if (base < OPT_LOG_MAX_VAL) {
            baseLog = optimalLog(base);
        } else {
            baseLog = generalLog(base);
        }

        uint256 baseLogTimesExp = (baseLog * _expN) / _expD;
        if (baseLogTimesExp < OPT_EXP_MAX_VAL) {
            return (optimalExp(baseLogTimesExp), MAX_PRECISION);
        } else {
            uint8 precision = findPositionInMaxExpArray(baseLogTimesExp);
            return (
                generalExp(baseLogTimesExp >> (MAX_PRECISION - precision), precision),
                precision
            );
        }
    }

    function generalLog(uint256 x) internal pure returns (uint256) {

        uint256 res = 0;

        if (x >= FIXED_2) {
            uint8 count = floorLog2(x / FIXED_1);
            x >>= count; // now x < 2
            res = count * FIXED_1;
        }

        if (x > FIXED_1) {
            for (uint8 i = MAX_PRECISION; i > 0; --i) {
                x = (x * x) / FIXED_1; // now 1 < x < 4
                if (x >= FIXED_2) {
                    x >>= 1; // now 1 < x < 2
                    res += ONE << (i - 1);
                }
            }
        }

        return (res * LN2_NUMERATOR) / LN2_DENOMINATOR;
    }

    function floorLog2(uint256 _n) internal pure returns (uint8) {

        uint8 res = 0;

        if (_n < 256) {
            while (_n > 1) {
                _n >>= 1;
                res += 1;
            }
        } else {
            for (uint8 s = 128; s > 0; s >>= 1) {
                if (_n >= (ONE << s)) {
                    _n >>= s;
                    res |= s;
                }
            }
        }

        return res;
    }

    function findPositionInMaxExpArray(uint256 _x) internal view returns (uint8) {

        uint8 lo = MIN_PRECISION;
        uint8 hi = MAX_PRECISION;

        while (lo + 1 < hi) {
            uint8 mid = (lo + hi) / 2;
            if (maxExpArray[mid] >= _x) lo = mid;
            else hi = mid;
        }

        if (maxExpArray[hi] >= _x) return hi;
        if (maxExpArray[lo] >= _x) return lo;

        require(false);
        return 0;
    }

    function generalExp(uint256 _x, uint8 _precision) internal pure returns (uint256) {

        uint256 xi = _x;
        uint256 res = 0;

        xi = (xi * _x) >> _precision;
        res += xi * 0x3442c4e6074a82f1797f72ac0000000; // add x^02 * (33! / 02!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x116b96f757c380fb287fd0e40000000; // add x^03 * (33! / 03!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x045ae5bdd5f0e03eca1ff4390000000; // add x^04 * (33! / 04!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00defabf91302cd95b9ffda50000000; // add x^05 * (33! / 05!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x002529ca9832b22439efff9b8000000; // add x^06 * (33! / 06!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00054f1cf12bd04e516b6da88000000; // add x^07 * (33! / 07!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000a9e39e257a09ca2d6db51000000; // add x^08 * (33! / 08!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000012e066e7b839fa050c309000000; // add x^09 * (33! / 09!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000001e33d7d926c329a1ad1a800000; // add x^10 * (33! / 10!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000002bee513bdb4a6b19b5f800000; // add x^11 * (33! / 11!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000003a9316fa79b88eccf2a00000; // add x^12 * (33! / 12!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000048177ebe1fa812375200000; // add x^13 * (33! / 13!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000005263fe90242dcbacf00000; // add x^14 * (33! / 14!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000057e22099c030d94100000; // add x^15 * (33! / 15!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000057e22099c030d9410000; // add x^16 * (33! / 16!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000052b6b54569976310000; // add x^17 * (33! / 17!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000004985f67696bf748000; // add x^18 * (33! / 18!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000003dea12ea99e498000; // add x^19 * (33! / 19!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000031880f2214b6e000; // add x^20 * (33! / 20!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000025bcff56eb36000; // add x^21 * (33! / 21!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000001b722e10ab1000; // add x^22 * (33! / 22!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000001317c70077000; // add x^23 * (33! / 23!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000cba84aafa00; // add x^24 * (33! / 24!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000082573a0a00; // add x^25 * (33! / 25!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000005035ad900; // add x^26 * (33! / 26!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000002f881b00; // add x^27 * (33! / 27!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000000000001b29340; // add x^28 * (33! / 28!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000efc40; // add x^29 * (33! / 29!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000000000000007fe0; // add x^30 * (33! / 30!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000000000000000420; // add x^31 * (33! / 31!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000000000000000021; // add x^32 * (33! / 32!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000000000000000001; // add x^33 * (33! / 33!)

        return res / 0x688589cc0e9505e2f2fee5580000000 + _x + (ONE << _precision); // divide by 33! and then add x^1 / 1! + x^0 / 0!
    }

    function optimalLog(uint256 x) internal pure returns (uint256) {

        uint256 res = 0;

        uint256 y;
        uint256 z;
        uint256 w;

        if (x >= 0xd3094c70f034de4b96ff7d5b6f99fcd8) {
            res += 0x40000000000000000000000000000000;
            x = (x * FIXED_1) / 0xd3094c70f034de4b96ff7d5b6f99fcd8;
        } // add 1 / 2^1
        if (x >= 0xa45af1e1f40c333b3de1db4dd55f29a7) {
            res += 0x20000000000000000000000000000000;
            x = (x * FIXED_1) / 0xa45af1e1f40c333b3de1db4dd55f29a7;
        } // add 1 / 2^2
        if (x >= 0x910b022db7ae67ce76b441c27035c6a1) {
            res += 0x10000000000000000000000000000000;
            x = (x * FIXED_1) / 0x910b022db7ae67ce76b441c27035c6a1;
        } // add 1 / 2^3
        if (x >= 0x88415abbe9a76bead8d00cf112e4d4a8) {
            res += 0x08000000000000000000000000000000;
            x = (x * FIXED_1) / 0x88415abbe9a76bead8d00cf112e4d4a8;
        } // add 1 / 2^4
        if (x >= 0x84102b00893f64c705e841d5d4064bd3) {
            res += 0x04000000000000000000000000000000;
            x = (x * FIXED_1) / 0x84102b00893f64c705e841d5d4064bd3;
        } // add 1 / 2^5
        if (x >= 0x8204055aaef1c8bd5c3259f4822735a2) {
            res += 0x02000000000000000000000000000000;
            x = (x * FIXED_1) / 0x8204055aaef1c8bd5c3259f4822735a2;
        } // add 1 / 2^6
        if (x >= 0x810100ab00222d861931c15e39b44e99) {
            res += 0x01000000000000000000000000000000;
            x = (x * FIXED_1) / 0x810100ab00222d861931c15e39b44e99;
        } // add 1 / 2^7
        if (x >= 0x808040155aabbbe9451521693554f733) {
            res += 0x00800000000000000000000000000000;
            x = (x * FIXED_1) / 0x808040155aabbbe9451521693554f733;
        } // add 1 / 2^8

        z = y = x - FIXED_1;
        w = (y * y) / FIXED_1;
        res +=
            (z * (0x100000000000000000000000000000000 - y)) /
            0x100000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^01 / 01 - y^02 / 02
        res +=
            (z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y)) /
            0x200000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^03 / 03 - y^04 / 04
        res +=
            (z * (0x099999999999999999999999999999999 - y)) /
            0x300000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^05 / 05 - y^06 / 06
        res +=
            (z * (0x092492492492492492492492492492492 - y)) /
            0x400000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^07 / 07 - y^08 / 08
        res +=
            (z * (0x08e38e38e38e38e38e38e38e38e38e38e - y)) /
            0x500000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^09 / 09 - y^10 / 10
        res +=
            (z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b - y)) /
            0x600000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^11 / 11 - y^12 / 12
        res +=
            (z * (0x089d89d89d89d89d89d89d89d89d89d89 - y)) /
            0x700000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^13 / 13 - y^14 / 14
        res +=
            (z * (0x088888888888888888888888888888888 - y)) /
            0x800000000000000000000000000000000; // add y^15 / 15 - y^16 / 16

        return res;
    }

    function optimalExp(uint256 x) internal pure returns (uint256) {

        uint256 res = 0;

        uint256 y;
        uint256 z;

        z = y = x % 0x10000000000000000000000000000000; // get the input modulo 2^(-3)
        z = (z * y) / FIXED_1;
        res += z * 0x10e1b3be415a0000; // add y^02 * (20! / 02!)
        z = (z * y) / FIXED_1;
        res += z * 0x05a0913f6b1e0000; // add y^03 * (20! / 03!)
        z = (z * y) / FIXED_1;
        res += z * 0x0168244fdac78000; // add y^04 * (20! / 04!)
        z = (z * y) / FIXED_1;
        res += z * 0x004807432bc18000; // add y^05 * (20! / 05!)
        z = (z * y) / FIXED_1;
        res += z * 0x000c0135dca04000; // add y^06 * (20! / 06!)
        z = (z * y) / FIXED_1;
        res += z * 0x0001b707b1cdc000; // add y^07 * (20! / 07!)
        z = (z * y) / FIXED_1;
        res += z * 0x000036e0f639b800; // add y^08 * (20! / 08!)
        z = (z * y) / FIXED_1;
        res += z * 0x00000618fee9f800; // add y^09 * (20! / 09!)
        z = (z * y) / FIXED_1;
        res += z * 0x0000009c197dcc00; // add y^10 * (20! / 10!)
        z = (z * y) / FIXED_1;
        res += z * 0x0000000e30dce400; // add y^11 * (20! / 11!)
        z = (z * y) / FIXED_1;
        res += z * 0x000000012ebd1300; // add y^12 * (20! / 12!)
        z = (z * y) / FIXED_1;
        res += z * 0x0000000017499f00; // add y^13 * (20! / 13!)
        z = (z * y) / FIXED_1;
        res += z * 0x0000000001a9d480; // add y^14 * (20! / 14!)
        z = (z * y) / FIXED_1;
        res += z * 0x00000000001c6380; // add y^15 * (20! / 15!)
        z = (z * y) / FIXED_1;
        res += z * 0x000000000001c638; // add y^16 * (20! / 16!)
        z = (z * y) / FIXED_1;
        res += z * 0x0000000000001ab8; // add y^17 * (20! / 17!)
        z = (z * y) / FIXED_1;
        res += z * 0x000000000000017c; // add y^18 * (20! / 18!)
        z = (z * y) / FIXED_1;
        res += z * 0x0000000000000014; // add y^19 * (20! / 19!)
        z = (z * y) / FIXED_1;
        res += z * 0x0000000000000001; // add y^20 * (20! / 20!)
        res = res / 0x21c3677c82b40000 + y + FIXED_1; // divide by 20! and then add y^1 / 1! + y^0 / 0!

        if ((x & 0x010000000000000000000000000000000) != 0)
            res =
                (res * 0x1c3d6a24ed82218787d624d3e5eba95f9) /
                0x18ebef9eac820ae8682b9793ac6d1e776; // multiply by e^2^(-3)
        if ((x & 0x020000000000000000000000000000000) != 0)
            res =
                (res * 0x18ebef9eac820ae8682b9793ac6d1e778) /
                0x1368b2fc6f9609fe7aceb46aa619baed4; // multiply by e^2^(-2)
        if ((x & 0x040000000000000000000000000000000) != 0)
            res =
                (res * 0x1368b2fc6f9609fe7aceb46aa619baed5) /
                0x0bc5ab1b16779be3575bd8f0520a9f21f; // multiply by e^2^(-1)
        if ((x & 0x080000000000000000000000000000000) != 0)
            res =
                (res * 0x0bc5ab1b16779be3575bd8f0520a9f21e) /
                0x0454aaa8efe072e7f6ddbab84b40a55c9; // multiply by e^2^(+0)
        if ((x & 0x100000000000000000000000000000000) != 0)
            res =
                (res * 0x0454aaa8efe072e7f6ddbab84b40a55c5) /
                0x00960aadc109e7a3bf4578099615711ea; // multiply by e^2^(+1)
        if ((x & 0x200000000000000000000000000000000) != 0)
            res =
                (res * 0x00960aadc109e7a3bf4578099615711d7) /
                0x0002bf84208204f5977f9a8cf01fdce3d; // multiply by e^2^(+2)
        if ((x & 0x400000000000000000000000000000000) != 0)
            res =
                (res * 0x0002bf84208204f5977f9a8cf01fdc307) /
                0x0000003c6ab775dd0b95b4cbee7e65d11; // multiply by e^2^(+3)

        return res;
    }

    function calculateCrossConnectorReturn(
        uint256 _fromConnectorBalance,
        uint32 _fromConnectorWeight,
        uint256 _toConnectorBalance,
        uint32 _toConnectorWeight,
        uint256 _amount
    ) public view returns (uint256) {

        return
            calculateCrossReserveReturn(
                _fromConnectorBalance,
                _fromConnectorWeight,
                _toConnectorBalance,
                _toConnectorWeight,
                _amount
            );
    }
}

contract GoodMarketMaker is BancorFormula, DSMath, SchemeGuard {

    using SafeMath for uint256;

    BancorFormula bancor;

    struct ReserveToken {
        uint256 reserveSupply;
        uint32 reserveRatio;
        uint256 gdSupply;
    }

    mapping(address => ReserveToken) public reserveTokens;

    event BalancesUpdated(
        address indexed caller,
        address indexed reserveToken,
        uint256 amount,
        uint256 returnAmount,
        uint256 totalSupply,
        uint256 reserveBalance
    );

    event ReserveRatioUpdated(address indexed caller, uint256 nom, uint256 denom);

    event InterestMinted(
        address indexed caller,
        address indexed reserveToken,
        uint256 addInterest,
        uint256 oldSupply,
        uint256 mint
    );

    event UBIExpansionMinted(
        address indexed caller,
        address indexed reserveToken,
        uint256 oldReserveRatio,
        uint256 oldSupply,
        uint256 mint
    );

    uint256 public reserveRatioDailyExpansion;

    constructor(
        Avatar _avatar,
        uint256 _nom,
        uint256 _denom
    ) public SchemeGuard(_avatar) {
        reserveRatioDailyExpansion = rdiv(_nom, _denom);
    }

    modifier onlyActiveToken(ERC20 _token) {

        ReserveToken storage rtoken = reserveTokens[address(_token)];
        require(rtoken.gdSupply > 0, "Reserve token not initialized");
        _;
    }

    function setReserveRatioDailyExpansion(uint256 _nom, uint256 _denom)
        public
        onlyAvatar
    {

        require(_denom > 0, "denominator must be above 0");
        reserveRatioDailyExpansion = rdiv(_nom, _denom);
        emit ReserveRatioUpdated(msg.sender, _nom, _denom);
    }


    function initializeToken(
        ERC20 _token,
        uint256 _gdSupply,
        uint256 _tokenSupply,
        uint32 _reserveRatio
    ) public onlyOwner {

        reserveTokens[address(_token)] = ReserveToken({
            gdSupply: _gdSupply,
            reserveSupply: _tokenSupply,
            reserveRatio: _reserveRatio
        });
    }

    function calculateNewReserveRatio(ERC20 _token)
        public
        view
        onlyActiveToken(_token)
        returns (uint32)
    {

        ReserveToken memory reserveToken = reserveTokens[address(_token)];
        uint32 ratio = reserveToken.reserveRatio;
        if (ratio == 0) {
            ratio = 1e6;
        }
        return
            uint32(
                rmul(
                    uint256(ratio).mul(1e21), // expand to e27 precision
                    reserveRatioDailyExpansion
                )
                    .div(1e21) // return to e6 precision
            );
    }

    function expandReserveRatio(ERC20 _token)
        public
        onlyOwner
        onlyActiveToken(_token)
        returns (uint32)
    {

        ReserveToken storage reserveToken = reserveTokens[address(_token)];
        uint32 ratio = reserveToken.reserveRatio;
        if (ratio == 0) {
            ratio = 1e6;
        }
        reserveToken.reserveRatio = calculateNewReserveRatio(_token);
        return reserveToken.reserveRatio;
    }

    function buyReturn(ERC20 _token, uint256 _tokenAmount)
        public
        view
        onlyActiveToken(_token)
        returns (uint256)
    {

        ReserveToken memory rtoken = reserveTokens[address(_token)];
        return
            calculatePurchaseReturn(
                rtoken.gdSupply,
                rtoken.reserveSupply,
                rtoken.reserveRatio,
                _tokenAmount
            );
    }

    function sellReturn(ERC20 _token, uint256 _gdAmount)
        public
        view
        onlyActiveToken(_token)
        returns (uint256)
    {

        ReserveToken memory rtoken = reserveTokens[address(_token)];
        return
            calculateSaleReturn(
                rtoken.gdSupply,
                rtoken.reserveSupply,
                rtoken.reserveRatio,
                _gdAmount
            );
    }

    function buy(ERC20 _token, uint256 _tokenAmount)
        public
        onlyOwner
        onlyActiveToken(_token)
        returns (uint256)
    {

        uint256 gdReturn = buyReturn(_token, _tokenAmount);
        ReserveToken storage rtoken = reserveTokens[address(_token)];
        rtoken.gdSupply = rtoken.gdSupply.add(gdReturn);
        rtoken.reserveSupply = rtoken.reserveSupply.add(_tokenAmount);
        emit BalancesUpdated(
            msg.sender,
            address(_token),
            _tokenAmount,
            gdReturn,
            rtoken.gdSupply,
            rtoken.reserveSupply
        );
        return gdReturn;
    }

    function sell(ERC20 _token, uint256 _gdAmount)
        public
        onlyOwner
        onlyActiveToken(_token)
        returns (uint256)
    {

        ReserveToken storage rtoken = reserveTokens[address(_token)];
        require(rtoken.gdSupply > _gdAmount, "GD amount is higher than the total supply");
        uint256 tokenReturn = sellReturn(_token, _gdAmount);
        rtoken.gdSupply = rtoken.gdSupply.sub(_gdAmount);
        rtoken.reserveSupply = rtoken.reserveSupply.sub(tokenReturn);
        emit BalancesUpdated(
            msg.sender,
            address(_token),
            _gdAmount,
            tokenReturn,
            rtoken.gdSupply,
            rtoken.reserveSupply
        );
        return tokenReturn;
    }

    function sellWithContribution(
        ERC20 _token,
        uint256 _gdAmount,
        uint256 _contributionGdAmount
    ) public onlyOwner onlyActiveToken(_token) returns (uint256) {

        require(
            _gdAmount >= _contributionGdAmount,
            "GD amount is lower than the contribution amount"
        );
        ReserveToken storage rtoken = reserveTokens[address(_token)];
        require(rtoken.gdSupply > _gdAmount, "GD amount is higher than the total supply");

        uint256 amountAfterContribution = _gdAmount.sub(_contributionGdAmount);

        uint256 tokenReturn = sellReturn(_token, amountAfterContribution);
        rtoken.gdSupply = rtoken.gdSupply.sub(_gdAmount);
        rtoken.reserveSupply = rtoken.reserveSupply.sub(tokenReturn);
        emit BalancesUpdated(
            msg.sender,
            address(_token),
            _contributionGdAmount,
            tokenReturn,
            rtoken.gdSupply,
            rtoken.reserveSupply
        );
        return tokenReturn;
    }

    function currentPrice(ERC20 _token)
        public
        view
        onlyActiveToken(_token)
        returns (uint256)
    {

        ReserveToken memory rtoken = reserveTokens[address(_token)];
        GoodDollar gooddollar = GoodDollar(address(avatar.nativeToken()));
        return
            calculateSaleReturn(
                rtoken.gdSupply,
                rtoken.reserveSupply,
                rtoken.reserveRatio,
                (10**uint256(gooddollar.decimals()))
            );
    }

    function calculateMintInterest(ERC20 _token, uint256 _addTokenSupply)
        public
        view
        onlyActiveToken(_token)
        returns (uint256)
    {

        GoodDollar gooddollar = GoodDollar(address(avatar.nativeToken()));
        uint256 decimalsDiff = uint256(27).sub(uint256(gooddollar.decimals()));
        return rdiv(_addTokenSupply, currentPrice(_token)).div(10**decimalsDiff);
    }

    function mintInterest(ERC20 _token, uint256 _addTokenSupply)
        public
        onlyOwner
        returns (uint256)
    {

        if (_addTokenSupply == 0) {
            return 0;
        }
        uint256 toMint = calculateMintInterest(_token, _addTokenSupply);
        ReserveToken storage reserveToken = reserveTokens[address(_token)];
        uint256 gdSupply = reserveToken.gdSupply;
        uint256 reserveBalance = reserveToken.reserveSupply;
        reserveToken.gdSupply = gdSupply.add(toMint);
        reserveToken.reserveSupply = reserveBalance.add(_addTokenSupply);
        emit InterestMinted(
            msg.sender,
            address(_token),
            _addTokenSupply,
            gdSupply,
            toMint
        );
        return toMint;
    }

    function calculateMintExpansion(ERC20 _token)
        public
        view
        onlyActiveToken(_token)
        returns (uint256)
    {

        ReserveToken memory reserveToken = reserveTokens[address(_token)];
        uint32 newReserveRatio = calculateNewReserveRatio(_token); // new reserve ratio
        uint256 reserveDecimalsDiff = uint256(
            uint256(27).sub(ERC20Detailed(address(_token)).decimals())
        ); // //result is in RAY precision
        uint256 denom = rmul(
            uint256(newReserveRatio).mul(1e21),
            currentPrice(_token).mul(10**reserveDecimalsDiff)
        ); // (newreserveratio * currentprice) in RAY precision
        GoodDollar gooddollar = GoodDollar(address(avatar.nativeToken()));
        uint256 gdDecimalsDiff = uint256(27).sub(uint256(gooddollar.decimals()));
        uint256 toMint = rdiv(
            reserveToken.reserveSupply.mul(10**reserveDecimalsDiff), // reservebalance in RAY precision
            denom
        )
            .div(10**gdDecimalsDiff); // return to gd precision
        return toMint.sub(reserveToken.gdSupply);
    }

    function mintExpansion(ERC20 _token) public onlyOwner returns (uint256) {

        uint256 toMint = calculateMintExpansion(_token);
        ReserveToken storage reserveToken = reserveTokens[address(_token)];
        uint256 gdSupply = reserveToken.gdSupply;
        uint256 ratio = reserveToken.reserveRatio;
        reserveToken.gdSupply = gdSupply.add(toMint);
        expandReserveRatio(_token);
        emit UBIExpansionMinted(msg.sender, address(_token), ratio, gdSupply, toMint);
        return toMint;
    }
}