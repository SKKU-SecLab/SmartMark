pragma solidity ^0.5.11;

library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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
}pragma solidity ^0.5.11;


contract AccountFrozenBalances {

    using SafeMath for uint256;

    mapping (address => uint256) private frozen_balances;

    function _frozen_add(address _account, uint256 _amount) internal returns (bool) {

        frozen_balances[_account] = frozen_balances[_account].add(_amount);
        return true;
    }

    function _frozen_sub(address _account, uint256 _amount) internal returns (bool) {

        frozen_balances[_account] = frozen_balances[_account].sub(_amount);
        return true;
    }

    function _frozen_balanceOf(address _account) internal view returns (uint256) {

        return frozen_balances[_account];
    }
}pragma solidity ^0.5.11;

contract Ownable {

    address private _owner;
    address public pendingOwner;

    modifier onlyOwner() {

        require(msg.sender == _owner, "caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(_owner, pendingOwner);
        _owner = pendingOwner;
        pendingOwner = address(0);
    }
}pragma solidity ^0.5.11;

contract Mintable {

    mapping (address => bool) private _minters;
    address private _minteradmin;
    address public pendingMinterAdmin;


    modifier onlyMinterAdmin() {

        require (msg.sender == _minteradmin, "caller not a minter admin");
        _;
    }

    modifier onlyMinter() {

        require (_minters[msg.sender] == true, "can't perform mint");
        _;
    }

    modifier onlyPendingMinterAdmin() {

        require(msg.sender == pendingMinterAdmin);
        _;
    }

    event MinterTransferred(address indexed previousMinter, address indexed newMinter);

    constructor () internal {
        _minteradmin = msg.sender;
        _minters[msg.sender] = true;
    }

    function minteradmin() public view returns (address) {

        return _minteradmin;
    }

    function addToMinters(address account) public onlyMinterAdmin {

        _minters[account] = true;
    }

    function removeFromMinters(address account) public onlyMinterAdmin {

        _minters[account] = false;
    }

    function transferMinterAdmin(address newMinter) public onlyMinterAdmin {

        pendingMinterAdmin = newMinter;
    }

    function claimMinterAdmin() public onlyPendingMinterAdmin {

        emit MinterTransferred(_minteradmin, pendingMinterAdmin);
        _minteradmin = pendingMinterAdmin;
        pendingMinterAdmin = address(0);
    }
}pragma solidity ^0.5.11;


library Rules {

    
    using SafeMath for uint256;

    struct Rule {               
        uint256 intervalFreezeBlock;        
        uint256 percent;                   
        bool    initRule;     
        uint256 maxAmount;
        uint256 remainAmount;              
    }

    function setRule(Rule storage rule, uint256 _intervalFreezeBlock, uint256 _percent, uint256 _maxAmount) internal {

        require(_intervalFreezeBlock > 0);
        require(_percent > 0);
        rule.intervalFreezeBlock = _intervalFreezeBlock;
        rule.percent = _percent;
        rule.initRule = true;
        rule.maxAmount = _maxAmount;
        rule.remainAmount = _maxAmount;
    }

    function freezeAmount(Rule storage rule, uint256 baseAmount, uint256 startFrozenBlock, uint256 lastFreezeBlock, uint256 currentBlock) internal view returns(uint256) {

        require(startFrozenBlock <= lastFreezeBlock, "startFrozenBlockmust be greater than or equal to lastFreezeBlock");
        if(currentBlock < lastFreezeBlock){
            return 0;
        }
        require(currentBlock >= lastFreezeBlock);
        require(baseAmount > 0, "baseAmount cant not be 0");
        require(rule.percent > 0);
        uint256 actualFactor =  currentBlock.sub(startFrozenBlock).div(rule.intervalFreezeBlock);
        uint256 alreadyFactor = lastFreezeBlock.sub(startFrozenBlock).div(rule.intervalFreezeBlock);
        require(actualFactor >= alreadyFactor, "invalid factor");
        uint256 factor = actualFactor - alreadyFactor;
        return baseAmount.mul(rule.percent).mul(factor).div(100);
    }
}pragma solidity ^0.5.11;

contract TokenRecipient {

    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public;

}pragma solidity ^0.5.11;

contract IERC20Token {



    function balanceOf(address _owner) public view returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);


    function approve(address _spender, uint256 _value) public returns (bool success);


    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

}pragma solidity ^0.5.11;


contract DSGToken is AccountFrozenBalances, Ownable, Mintable {

    using SafeMath for uint256;
    using Rules for Rules.Rule;

    uint256 constant public maxCallFrequency = 100;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupplyLimit;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    enum RoleType { Invalid, FUNDER, TEAM, ADVISORS, PARTNERSHIP, COMMUNITY, SEED, PRIVATE, AIRDROP}

    struct FreezeData {
        bool initialzed;
        uint256 frozenAmount;       // fronzen amount
        uint256 startBlock;         // freeze block for start.
        uint256 lastFreezeBlock;
    }

    mapping (address => RoleType) private _roles;
    mapping (uint256 => Rules.Rule) private _rules;
    mapping (address => FreezeData) private _freeze_datas;
    uint256 public monthIntervalBlock = 172800;    // 172800 (30d*24h*60m*60s/15s)
    uint256 public yearIntervalBlock = 2102400;    // 2102400 (365d*24h*60m*60s/15s)
    uint256 public sixMonthIntervalBlock = 1036800; // six month block: 1036800 (6m*30d*24h*60m*60s/15s)

    bool public seedPause = true;
    uint256 public seedMeltStartBlock = 0;       

    bool public ruleReady;

    uint256 private _totalUpgraded;    

    modifier onlyReady(){

        require(ruleReady, "ruleReady is false");
        _;
    }            

    modifier canClaim() {

        require(uint256(_roles[msg.sender]) != uint256(RoleType.Invalid), "Invalid user role");
        require(_freeze_datas[msg.sender].initialzed);
        if(_roles[msg.sender] == RoleType.SEED){
            require(!seedPause, "Seed is not time to unlock yet");
        }
        _;
    }

    modifier canMint(uint256 _amount) {

        require((_totalSupply + _amount) <= totalSupplyLimit, "Mint: Exceed the maximum circulation");
        _;
    }

    modifier roleCanMint(uint256 _role, uint256 _amount) {

        require(_rules[_role].initRule, "role not exists or not initialzed");
        if(_role == uint256(RoleType.AIRDROP)) {
            _role = uint256(RoleType.COMMUNITY);
        }
        require(_amount <= _rules[_role].remainAmount, "RoleMint: Exceed the maximum circulation");
        _;
        _rules[_role].remainAmount = _rules[_role].remainAmount.sub(_amount);
    }

    modifier canBatchMint(uint256[] memory _amounts) {

        uint256 mintAmount = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            mintAmount = mintAmount.add(_amounts[i]);
        }
        require((_totalSupply + mintAmount) <= totalSupplyLimit, "BatchMint: Exceed the maximum circulation");
        _;
    }

    modifier roleCanBatchMint(uint256 _role, uint256[] memory _amounts) {

        if(_role == uint256(RoleType.AIRDROP)) {
            _role = uint256(RoleType.COMMUNITY);
        }
        uint256 mintAmount = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            mintAmount = mintAmount.add(_amounts[i]);
        }
        require(mintAmount <= _rules[_role].remainAmount, "RoleBatchMint: Exceed the maximum circulation");
        _;
        _rules[_role].remainAmount = _rules[_role].remainAmount.sub(mintAmount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Freeze(address indexed from, uint256 amount);
    event Melt(address indexed from, uint256 amount);
    event MintFrozen(address indexed to, uint256 amount);
    event Claim(address indexed from, uint256 amount);

    event Withdrawal(address indexed src, uint wad);
    event FrozenTransfer(address indexed from, address indexed to, uint256 value);

    event Upgrade(address indexed from, uint256 _value);

    constructor (string memory _name, string memory _symbol) public {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupplyLimit = 1024 * 1024 * 1024 * 10 ** uint256(decimals);
    }

    function readyRule() onlyMinter public {

        require(!ruleReady, "only init once");
        ruleReady = true;
        _rules[uint256(RoleType.FUNDER)].setRule(yearIntervalBlock, 10, 7546257537 * 10 ** (uint256(decimals)-2));   // 107803679.1 * 70%
        _rules[uint256(RoleType.TEAM)].setRule(monthIntervalBlock, 2, 560858304356 * 10 ** (uint256(decimals)-4));      // 57230439.22 * 98%
        _rules[uint256(RoleType.ADVISORS)].setRule(monthIntervalBlock, 2, 13153337344 * 10 ** (uint256(decimals)-3)); // 13421772.8 * 98%
        _rules[uint256(RoleType.PARTNERSHIP)].setRule(monthIntervalBlock, 20, 4563402752 * 10 ** (uint256(decimals)-2)); // 45634027.52 (sixmonth after ido) 
        _rules[uint256(RoleType.COMMUNITY)].setRule(monthIntervalBlock, 20, 3489660928*10**(uint256(decimals)-2)); // 34896609.28 (sixmonth after ido) 
        _rules[uint256(RoleType.SEED)].setRule(monthIntervalBlock, 10, 3575560274*10** (uint256(decimals)-2));   // 35755602.74
        _rules[uint256(RoleType.PRIVATE)].setRule(monthIntervalBlock, 10, 536870912*10**(uint256(decimals)-1)); // 53687091.2
    }

    function roleType(address account) public view returns (uint256) {

        return uint256(_roles[account]);
    }

    function startBlock(address account) public view returns (uint256) {

        return _freeze_datas[account].startBlock;
    }

    function lastestFreezeBlock(address account) public view returns (uint256) {

        return _freeze_datas[account].lastFreezeBlock;
    }

    function queryFreezeAmount(address account) public view returns(uint256) {

        uint256 lastFreezeBlock = _freeze_datas[account].lastFreezeBlock;
        uint256 startFreezeBlock = _freeze_datas[account].startBlock;
        if(uint256(_roles[account]) == uint256(RoleType.SEED) || uint256(_roles[account]) == uint256(RoleType.PRIVATE)) {
            if(seedPause){
                return 0;
            }
            if(seedMeltStartBlock != 0 && seedMeltStartBlock > lastFreezeBlock) {
                lastFreezeBlock = seedMeltStartBlock;
            }
            startFreezeBlock = seedMeltStartBlock;
        }
        if(_roles[account] == RoleType.Invalid){
            return 0;
        }
        uint256 amount = _rules[uint256(_roles[account])].freezeAmount(_freeze_datas[account].frozenAmount , startFreezeBlock, lastFreezeBlock, block.number);
        uint256 balance = _frozen_balanceOf(account);
        if(amount > balance) {
            amount = balance;
        }
        return amount;
    }

    function totalSupply() public view returns (uint256) {

        return totalSupplyLimit;
    }

    function currentTotalSupply() public view returns(uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account].add(_frozen_balanceOf(account));
    }

    function roleRemainAmount(uint256 _role) public view returns(uint256) {

        return _rules[_role].remainAmount;
    }

    function frozenBalanceOf(address account) public view returns (uint256) {

        return _frozen_balanceOf(account);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        require(recipient != address(this), "can't transfer tokens to the contract address");

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferBatch(address[] memory recipients, uint256[] memory amounts) public returns (bool) {

        require(recipients.length > 0, "transferBatch: recipient should be to at least one address");
        require(recipients.length == amounts.length, "transferBatch: recipients and amounts must be equal");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
        return true;
    }

    function allowance(address _owner, address spender) public view returns (uint256) {

        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool) {

        TokenRecipient spender = TokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        require(recipient != address(this), "can't transfer tokens to the contract address");

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function transferFrozenToken(address to, uint256 amount) public returns (bool) {

        _transferFrozen(msg.sender, to, amount);
        return true;
    }

    function transferBatchFrozenTokens(address[] calldata accounts, uint256[] calldata amounts) external returns (bool) {

        require(accounts.length > 0, "transferBatchFrozenTokens: transfer should be to at least one address");
        require(accounts.length == amounts.length, "transferBatchFrozenTokens: recipients.length != amounts.length");
        for (uint256 i = 0; i < accounts.length; i++) {
            _transferFrozen(msg.sender, accounts[i], amounts[i]);
        }
        return true;
    }

    function meltTokens(address account, uint256 amount) public onlyMinter returns (bool) {

        _melt(account, amount);
        emit Transfer(address(this), account, amount);
        return true;
    }
    
    function meltBatchTokens(address[] calldata accounts, uint256[] calldata amounts) external onlyMinter returns (bool) {

        require(accounts.length > 0, "meltBatchTokens: transfer should be to at least one address");
        require(accounts.length == amounts.length, "meltBatchTokens: accounts.length != amounts.length");
        for (uint256 i = 0; i < accounts.length; i++) {
            _melt(accounts[i], amounts[i]);
            emit Transfer(address(this), accounts[i], amounts[i]);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function mint(address account, uint256 amount) public onlyMinter canMint(amount) returns (bool) {

        _mint(account, amount);
        return true;
    }

    function burn(uint256 amount) public {

        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }

    function mintBatchToken(address[] calldata accounts, uint256[] calldata amounts) external onlyMinter canBatchMint(amounts) returns (bool) {

        require(accounts.length > 0, "mintBatchToken: transfer should be to at least one address");
        require(accounts.length == amounts.length, "mintBatchToken: recipients.length != amounts.length");
        for (uint256 i = 0; i < accounts.length; i++) {
            _mint(accounts[i], amounts[i]);
        }

        return true;
    }

    function mintFrozenTokens(address account, uint256 amount) public onlyMinter canMint(amount) returns (bool) {

        _mintfrozen(account, amount);
        return true;
    }

    function mintBatchFrozenTokens(address[] calldata accounts, uint256[] calldata amounts) external onlyMinter canBatchMint(amounts) returns (bool) {

        require(accounts.length > 0, "mintBatchFrozenTokens: transfer should be to at least one address");
        require(accounts.length == amounts.length, "mintBatchFrozenTokens: recipients.length != amounts.length");
        for (uint256 i = 0; i < accounts.length; i++) {
            _mintfrozen(accounts[i], amounts[i]);
        }

        return true;
    }

    function mintFrozenTokensForRole(address account, uint256 amount, RoleType _role) public onlyMinter onlyReady canMint(amount) roleCanMint(uint256(_role), amount) returns (bool) {

        _mintFrozenTokensForRole(account, amount, _role);
        return true;
    }

    function mintBatchFrozenTokensForRole(address[] memory accounts, uint256[] memory amounts, RoleType _role) public onlyMinter onlyReady canBatchMint(amounts)  roleCanBatchMint(uint256(_role), amounts) returns (bool) {

        require(accounts.length > 0, "transfer should be to at least one address");
        require(accounts.length == amounts.length, "recipients.length != amounts.length");
        for (uint256 i = 0; i < accounts.length; i++) {
            _mintFrozenTokensForRole(accounts[i], amounts[i], _role);
        }
        return true;
    }

    function upgrade(uint256 amount) public {

        require(amount != 0, "DSGT: upgradable amount should be more than 0");
        address holder = msg.sender;

        _burn(holder, amount);

        _totalUpgraded = _totalUpgraded.add(amount);

        emit Upgrade(holder, amount);
    }

    function totalUpgraded() public view returns (uint256) {

        return _totalUpgraded;
    }

    function withdraw(address _token, address payable _recipient) public onlyOwner {

        if (_token == address(0x0)) {
            require(_recipient != address(0x0));
            _recipient.transfer(address(this).balance);
            emit Withdrawal(_recipient, address(this).balance);
            return;
        }

        IERC20Token token = IERC20Token(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(_recipient, balance);
        emit Withdrawal(_recipient, balance);
    }

    function isContract(address _addr) view internal returns (bool) {

        if (_addr == address(0x0)) return false;
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }

    function claimTokens() public canClaim returns (bool) {

        uint256 lastFreezeBlock = _freeze_datas[msg.sender].lastFreezeBlock;
        uint256 startFreezeBlock = _freeze_datas[msg.sender].startBlock;
        if(uint256(_roles[msg.sender]) == uint256(RoleType.SEED) || uint256(_roles[msg.sender]) == uint256(RoleType.PRIVATE) ) {
            require(!seedPause, "seed pause is true, can't to claim");
            if(seedMeltStartBlock != 0 && seedMeltStartBlock > lastFreezeBlock) {
                lastFreezeBlock = seedMeltStartBlock;
            }
            startFreezeBlock = seedMeltStartBlock;
        }
        uint256 amount = _rules[uint256(_roles[msg.sender])].freezeAmount(_freeze_datas[msg.sender].frozenAmount, startFreezeBlock, lastFreezeBlock, block.number);
        require(amount > 0, "Melt amount must be greater than 0");
        if(amount > _frozen_balanceOf(msg.sender)) {
            amount = _frozen_balanceOf(msg.sender);
        }
        _melt(msg.sender, amount); 

        _freeze_datas[msg.sender].lastFreezeBlock = block.number;

        emit Claim(msg.sender, amount);
        return true;
    }

    function startSeedPause() onlyOwner public {

        seedPause = false;
        seedMeltStartBlock = block.number;
    }

    function _mintFrozenTokensForRole(address account, uint256 amount, RoleType _role) internal returns (bool) {

        require(!_freeze_datas[account].initialzed, "specified account already initialzed");
        _roles[account] = _role;
        uint256 startBn = block.number;
        if(_role == RoleType.PARTNERSHIP || _role == RoleType.COMMUNITY){
            startBn = startBn + sixMonthIntervalBlock;
        }
        _freeze_datas[account] = FreezeData(true, amount, startBn, startBn);
        _mintfrozen(account, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _transferFrozen(address sender, address to, uint256 amount) internal {

        require(to != address(0), "ERC20-Frozen: transfer from the zero address");
        require(amount != 0, "ERC20-Frozen: transfer amount is zero");
        require(uint256(_roles[sender]) == uint256(RoleType.COMMUNITY), "ERC20-Frozen: msg.sender is not belong to community");
        require(_frozen_balanceOf(sender) >= amount, "frozen amount should greater than amount");
        _frozen_sub(sender, amount);
        _frozen_add(to, amount);

        emit FrozenTransfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");
        require(account != address(this), "ERC20: mint to the contract address");
        require(amount > 0, "ERC20: mint amount should be > 0");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(this), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(this), value);
    }

    function _approve(address _owner, address spender, uint256 value) internal {

        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }

    function _freeze(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: freeze from the zero address");
        require(amount > 0, "ERC20: freeze from the address: amount should be > 0");

        _balances[account] = _balances[account].sub(amount);
        _frozen_add(account, amount);

        emit Freeze(account, amount);
    }

    function _mintfrozen(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint frozen to the zero address");
        require(account != address(this), "ERC20: mint frozen to the contract address");
        require(amount > 0, "ERC20: mint frozen amount should be > 0");

        _totalSupply = _totalSupply.add(amount);

        emit Transfer(address(this), account, amount);

        _frozen_add(account, amount);

        emit MintFrozen(account, amount);
    }

    function _melt(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: melt from the zero address");
        require(amount > 0, "ERC20: melt from the address: value should be > 0");
        require(_frozen_balanceOf(account) >= amount, "ERC20: melt from the address: balance < amount");

        _frozen_sub(account, amount);
        _balances[account] = _balances[account].add(amount);

        emit Melt(account, amount);
    }

    function _burnFrozen(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: frozen burn from the zero address");

        _totalSupply = _totalSupply.sub(amount);
        _frozen_sub(account, amount);

        emit Transfer(account, address(this), amount);
    }
}pragma solidity ^0.5.11;

contract Burnable {

    bool private _burnallow;
    address private _burner;
    address public pendingBurner;

    modifier whenBurn() {

        require(_burnallow, "burnable: can't burn");
        _;
    }

    modifier onlyBurner() {

        require(msg.sender == _burner, "caller is not a burner");
        _;
    }

    modifier onlyPendingBurner() {

        require(msg.sender == pendingBurner);
        _;
    }

    event BurnerTransferred(address indexed previousBurner, address indexed newBurner);

    constructor () internal {
        _burnallow = true;
        _burner = msg.sender;
    }

    function burnallow() public view returns (bool) {

        return _burnallow;
    }

    function burner() public view returns (address) {

        return _burner;
    }

    function burnTrigger() public onlyBurner {

        _burnallow = !_burnallow;
    }

    function transferWhitelistAdmin(address newBurner) public onlyBurner {

        pendingBurner = newBurner;
    }

    function claimBurner() public onlyPendingBurner {

        emit BurnerTransferred(_burner, pendingBurner);
        _burner = pendingBurner;
        pendingBurner = address(0);
    }
}pragma solidity ^0.5.11;


contract Meltable {

    mapping (address => bool) private _melters;
    address private _melteradmin;
    address public pendingMelterAdmin;

    modifier onlyMelterAdmin() {

        require (msg.sender == _melteradmin, "caller not a melter admin");
        _;
    }

    modifier onlyMelter() {

        require (_melters[msg.sender] == true, "can't perform melt");
        _;
    }

    modifier onlyPendingMelterAdmin() {

        require(msg.sender == pendingMelterAdmin);
        _;
    }

    event MelterTransferred(address indexed previousMelter, address indexed newMelter);

    constructor () internal {
        _melteradmin = msg.sender;
        _melters[msg.sender] = true;
    }

    function melteradmin() public view returns (address) {

        return _melteradmin;
    }

    function addToMelters(address account) public onlyMelterAdmin {

        _melters[account] = true;
    }

    function removeFromMelters(address account) public onlyMelterAdmin {

        _melters[account] = false;
    }

    function transferMelterAdmin(address newMelter) public onlyMelterAdmin {

        pendingMelterAdmin = newMelter;
    }

    function claimMelterAdmin() public onlyPendingMelterAdmin {

        emit MelterTransferred(_melteradmin, pendingMelterAdmin);
        _melteradmin = pendingMelterAdmin;
        pendingMelterAdmin = address(0);
    }
}pragma solidity ^0.5.11;

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