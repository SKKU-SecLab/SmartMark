pragma solidity ^0.4.24;


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
pragma solidity >=0.4.21 <0.6.0;


contract Ownable {

    address _owner;

    modifier onlyOwner() {

        require(isOwner(msg.sender), "OwnerRole: caller does not have the Owner role");
        _;
    }

    function isOwner(address account) public view returns (bool) {

        return account == _owner;
    }
}
pragma solidity >=0.4.21 <0.6.0;


contract TokenStorage  is Ownable{

    using SafeMath for uint256;


    address internal _registryContract;

    constructor() public {
        _owner = msg.sender;
        _totalSupply = 1000000000 * 10 ** 18;
        _balances[_owner] = _totalSupply;
    }

    function setProxyContractAndVersionOneDeligatee(address registryContract) onlyOwner public{

        require(registryContract != address(0), "InvalidAddress: invalid address passed for proxy contract");
        _registryContract = registryContract;
    }

    function getRegistryContract() view public returns(address){

        return _registryContract;
    }


    modifier onlyAllowedAccess() {

        require(msg.sender == _registryContract, "AccessDenied: This address is not allowed to access the storage");
        _;
    }

    mapping (address => mapping (address => uint256)) internal _allowances;

    function setAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyAllowedAccess {

        _allowances[_tokenHolder][_spender] = _value;
    }

    function getAllowance(address _tokenHolder, address _spender) public view onlyAllowedAccess returns(uint256){

        return _allowances[_tokenHolder][_spender];
    }


    mapping (address => uint256) internal _balances;
    function addBalance(address _addr, uint256 _value) public onlyAllowedAccess {

        _balances[_addr] = _balances[_addr].add(_value);
    }

    function subBalance(address _addr, uint256 _value) public onlyAllowedAccess {

        _balances[_addr] = _balances[_addr].sub(_value);
    }

    function setBalance(address _addr, uint256 _value) public onlyAllowedAccess {

        _balances[_addr] = _value;
    }

    function getBalance(address _addr) public view onlyAllowedAccess returns(uint256){

        return _balances[_addr];
    }

    uint256 internal _totalSupply = 0;

    function addTotalSupply(uint256 _value) public onlyAllowedAccess {

        _totalSupply = _totalSupply.add(_value);
    }

    function subTotalSupply(uint256 _value) public onlyAllowedAccess {

        _totalSupply = _totalSupply.sub(_value);
    }

    function setTotalSupply(uint256 _value) public onlyAllowedAccess {

        _totalSupply = _value;
    }

    function getTotalSupply() public view onlyAllowedAccess returns(uint256) {

        return(_totalSupply);
    }


    mapping(address => bytes32[]) internal lockReason;

    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    mapping(address => mapping(bytes32 => lockToken)) internal locked;


    function getLockedTokenAmount(address _of, bytes32 _reason) public view onlyAllowedAccess returns (uint256 amount){

        if (!locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }

    function getLockedTokensAtTime(address _of, bytes32 _reason, uint256 _time) public view onlyAllowedAccess returns(uint256 amount){

        if (locked[_of][_reason].validity > _time)
            amount = locked[_of][_reason].amount;
    }

    function getTotalLockedTokens(address _of) public view onlyAllowedAccess returns(uint256 amount){

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(getLockedTokenAmount(_of, lockReason[_of][i]));
        }
    }

    function extendTokenLock(address _of, bytes32 _reason, uint256 _time) public onlyAllowedAccess returns(uint256 amount, uint256 validity){


        locked[_of][_reason].validity = locked[_of][_reason].validity.add(_time);
        amount = locked[_of][_reason].amount;
        validity = locked[_of][_reason].validity;
    }

    function increaseLockAmount(address _of, bytes32 _reason, uint256 _amount) public onlyAllowedAccess returns(uint256 amount, uint256 validity){

        locked[_of][_reason].amount = locked[_of][_reason].amount.add(_amount);
        amount = locked[_of][_reason].amount;
        validity = locked[_of][_reason].validity;
    }

    function getUnlockable(address _of, bytes32 _reason) public view onlyAllowedAccess returns(uint256 amount){

        if (locked[_of][_reason].validity <= now && !locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }

    function addLockedToken(address _of, bytes32 _reason, uint256 _amount, uint256 _validity) public onlyAllowedAccess {

        locked[_of][_reason] = lockToken(_amount, _validity, false);
    }

    function addLockReason(address _of, bytes32 _reason) public onlyAllowedAccess {

        lockReason[_of].push(_reason);
    }

    function getNumberOfLockReasons(address _of) public view onlyAllowedAccess returns(uint256 number){

        number = lockReason[_of].length;
    }

    function getLockReason(address _of, uint256 _i) public view onlyAllowedAccess returns(bytes32 reason){

        reason = lockReason[_of][_i];
    }

    function setClaimed(address _of, bytes32 _reason) public onlyAllowedAccess{

        locked[_of][_reason].claimed = true;
    }

    function caller(address _of) public view  onlyAllowedAccess returns(uint){

        return getTotalLockedTokens(_of);
    }
}pragma solidity ^0.4.24;


library AddressUtils {


    function isContract(address _addr) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }

}
pragma solidity ^0.4.24;


contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity ^0.4.24;



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
pragma solidity >=0.4.21 <0.6.0;


contract Token_V0 is ERC20, Ownable{

    using SafeMath for uint256;

    string public constant name = 'RoboAi Coin R2R';
    string public constant symbol = 'R2R';
    uint8 public constant decimals = 18;

    event Lock(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    event Unlock(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );

    string internal constant ALREADY_LOCKED = "Tokens already locked";
    string internal constant NOT_LOCKED = "No tokens locked";
    string internal constant AMOUNT_ZERO = "Amount can not be 0";

    event Mint(address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    TokenStorage dataStore;
    address dataStoreAddress;

    constructor(address storeAddress) public {
        dataStore = TokenStorage(storeAddress);
        dataStoreAddress = storeAddress;
    }



    function totalSupply() public view returns(uint256) {

        return(dataStore.getTotalSupply());
    }

    function balanceOf(address account) public view returns (uint256) {

        return dataStore.getBalance(account);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return dataStore.getAllowance(owner, spender);
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        require(dataStore.getAllowance(sender, msg.sender) >= amount, "AllowanceError: The spender does not hve the required allowance to spend token holder's tokens");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, dataStore.getAllowance(sender, msg.sender).sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(dataStore.getBalance(sender) >= amount, "Insufficient Funds");

        dataStore.subBalance(sender, amount);
        dataStore.addBalance(recipient, amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        dataStore.setAllowance(owner, spender, value);
        emit Approval(owner, spender, value);
    }

    function mintToken(address recipient, uint256 value) public onlyOwner{

        dataStore.addTotalSupply(value);
        dataStore.addBalance(recipient, value);
        emit Mint(recipient, value);
    }

    function burnToken(uint256 value) public{

        address sender = msg.sender;
        dataStore.subBalance(sender, value);
        dataStore.subTotalSupply(value);
        emit Burn(msg.sender, value);
    }


    function lock(bytes32 _reason, uint256 _amount, uint256 _time)
    public
    returns (bool)
    {

        uint256 validUntil = block.timestamp.add(_time);

        uint256 tokensAlreadyLocked = dataStore.getLockedTokenAmount(msg.sender, _reason);

        require(tokensAlreadyLocked == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        dataStore.addLockReason(msg.sender, _reason);

        _transfer(msg.sender, dataStore, _amount);

        dataStore.addLockedToken(msg.sender, _reason, _amount, validUntil);

        emit Lock(msg.sender, _reason, _amount, validUntil);
        return true;
    }


    function transferWithLock(address _to, bytes32 _reason, uint256 _amount, uint256 _time)
    public
    returns (bool)
    {

        uint256 validUntil = block.timestamp.add(_time);

        uint256 tokensAlreadyLocked = dataStore.getLockedTokenAmount(_to, _reason);

        require(tokensAlreadyLocked == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);
        require(_to != address(0), "ERC20: transfer to the zero address");

        dataStore.addLockReason(_to, _reason);

        _transfer(msg.sender, dataStore, _amount);

        dataStore.addLockedToken(_to, _reason, _amount, validUntil);

        emit Lock(_to, _reason, _amount, validUntil);
        return true;
    }


    function tokensLocked(address _of, bytes32 _reason)
    public
    view
    returns (uint256 amount)
    {

        return dataStore.getLockedTokenAmount(_of, _reason);
    }


    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
    public
    view
    returns (uint256 amount)
    {

        amount = dataStore.getLockedTokensAtTime(_of, _reason, _time);
    }


    function totalBalanceOf(address _of)
    public
    view
    returns (uint256 amount)
    {

        amount = balanceOf(_of);
        amount = amount + dataStore.getTotalLockedTokens(_of);
    }


    function extendLock(bytes32 _reason, uint256 _time)
    public
    returns (bool)
    {

        uint256 tokensAlreadyLocked = dataStore.getLockedTokenAmount(msg.sender, _reason);
        require(tokensAlreadyLocked > 0, NOT_LOCKED);

        (uint256 amount, uint256 validity) = dataStore.extendTokenLock(msg.sender, _reason, _time);

        emit Lock(msg.sender, _reason, amount, validity);
        return true;
    }


    function increaseLockAmount(bytes32 _reason, uint256 _amount)
    public
    returns (bool)
    {

        uint256 tokensAlreadyLocked = dataStore.getLockedTokenAmount(msg.sender, _reason);
        require(tokensAlreadyLocked > 0, NOT_LOCKED);
        _transfer(msg.sender, dataStore, _amount);
        (uint256 amount, uint256 validity) = dataStore.increaseLockAmount(msg.sender, _reason, _amount);

        emit Lock(msg.sender, _reason, amount, validity);
        return true;
    }


    function tokensUnlockable(address _of, bytes32 _reason)
    public
    view
    returns (uint256 amount)
    {

        return dataStore.getUnlockable(_of, _reason);
    }


    function unlock(address _of)
    public
    returns (uint256 unlockableTokens)
    {

        uint256 lockedTokens;
        uint256 numLockReasons = dataStore.getNumberOfLockReasons(_of);
        for (uint256 i = 0; i < numLockReasons; i++) {
            bytes32 reason = dataStore.getLockReason(_of, i);
            lockedTokens = tokensUnlockable(_of, reason);
            if (lockedTokens > 0) {
                unlockableTokens += lockedTokens;
                dataStore.setClaimed(_of, reason);
                emit Unlock(_of, reason, lockedTokens);
            }
        }

        if (unlockableTokens > 0)
            _transfer(dataStore, _of, unlockableTokens);
    }


    function getUnlockableTokens(address _of)
    public
    view
    returns (uint256 unlockableTokens)
    {

        uint256 numLockReasons = dataStore.getNumberOfLockReasons(_of);
        for (uint256 i = 0; i < numLockReasons; i++) {
            bytes32 reason = dataStore.getLockReason(_of, i);
            unlockableTokens = unlockableTokens + tokensUnlockable(_of, reason);
        }
    }
}pragma solidity >=0.4.21 <0.6.0;


contract Token_V1 is Token_V0{


    mapping(string => uint) fundDistribution;

    constructor(address storeAddress)
    Token_V0(storeAddress)
    public {
        fundDistribution['development'] = 22;
        fundDistribution['business'] = 34;
        fundDistribution['marketing'] = 11;
        fundDistribution['legal'] = 11;
        fundDistribution['future'] = 22;
    }

    function getFundDistributionPercentage(string  allocatee) public view returns(uint percentage){

        percentage = fundDistribution[allocatee];
    }
}
