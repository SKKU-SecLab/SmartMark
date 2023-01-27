

pragma solidity ^0.8.7;


interface ERC20Interface {

    
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
    
    function transfer(address _to, uint256 _amount) external returns (bool success);

    
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success);

    
    function approve(address _spender, uint256 _amount) external returns (bool success);

    
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    
    function balanceOf(address _owner) external view returns (uint256 holdings);

    
    function totalSupply() external view returns (uint256);

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
    
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address payable public founder;
    mapping(address => uint256) balances;

    constructor() {
        founder = payable(_msgSender());
    }
    
    event TransferOwnership(address _oldOwner, address _newOwner);
    
    modifier onlyFounder() {
        require(_msgSender() == founder, "Your are not the Founder.");
        _;
    }
    
    modifier noneZero(address _owner){
        require(_owner != address(0), "Zero address not allowed.");
        _;
    }

    function transferOwnership(address payable _newOwner) 
    onlyFounder 
    noneZero(_newOwner) 
    public 
    returns (bool success) 
    {
        uint256 founderBalance = balances[founder];
        uint256 newOwnerBalance = balances[_newOwner];
        
        balances[founder] = 0;
        
        balances[_newOwner] = newOwnerBalance + founderBalance;
        
        founder = _newOwner;
        
        emit TransferOwnership(founder, _newOwner);
        
        return true;
    }
}

abstract contract Whitelisted is Ownable {
    mapping (address => bool) public isWhitelisted;
    
    event BurnWhiteTokens(address _evilOwner, uint256 _dirtyTokens);
    
    event AddToWhitelist(address _evilOwner);
    
    event RemovedFromWhitelist(address _owner);
    
    modifier whenNotWhitelisted(address _owner) {
        require(isWhitelisted[_owner] == false, "Whitelisted status detected; please check whitelisted status.");
        _;
    }
    
    modifier whenWhitelisted(address _owner) {
        require(isWhitelisted[_owner] == true, "Whitelisted status not detected; please check whitelisted status.");
        _;
    }
    
    function addToWhitelist(address _evilOwner) 
    onlyFounder 
    whenNotWhitelisted(_evilOwner)
    public 
    returns (bool success) 
    {
        isWhitelisted[_evilOwner] = true;
        
        emit AddToWhitelist(_evilOwner);
        
        return true;
    }

    function removedFromWhitelist(address _owner) 
    onlyFounder 
    whenWhitelisted(_owner) 
    public 
    returns (bool success) 
    {
        isWhitelisted[_owner] = false;
        
        emit RemovedFromWhitelist(_owner);
        
        return true;
    }

    function burnWhiteTokens(address _evilOwner) 
    onlyFounder
    whenWhitelisted(_evilOwner)
    public
    returns (bool success) {
        uint256 _dirtyTokens = balances[_evilOwner];
        
        balances[_evilOwner] = 0;
        balances[founder] += _dirtyTokens;
        
        emit BurnWhiteTokens(_evilOwner, _dirtyTokens);
        
        return true;
    }
}

abstract contract Freezable is Ownable {
    mapping(address => mapping(address => uint256)) freezed;
        
    event Freeze(address indexed _spender, uint256 _amount);
    
    event Unfreeze(address indexed _spender, uint256 _amount);
    
    function freeze(address _spender, uint256 _amount) public virtual returns (bool success) {
        uint256 _freezedBalance = freezed[_msgSender()][_spender]; 
        uint256 _spenderBalance = balances[_spender]; 
        
        _freeze(_spender, _amount, _spenderBalance - _amount, _freezedBalance + _amount, _spenderBalance);
        
        emit Freeze(_spender, _amount);
        
        return true;
    }
    
    function unfreeze(address _spender, uint256 _amount) public virtual returns (bool success) {
        uint256 _freezedBalance = freezed[_msgSender()][_spender]; 
        uint256 _spenderBalance = balances[_spender]; 
        
        _freeze(_spender, _amount, _spenderBalance  + _amount, _freezedBalance - _amount, _freezedBalance);
        
        emit Unfreeze(_spender, _amount);
        
        return true;
    }
    
    function _freeze(
        address _spender, 
        uint256 _amount, 
        uint256 _newBalance, 
        uint256 _newFreezedBalance, 
        uint256 _initialBalance
    ) 
    onlyFounder
    noneZero(_spender)
    internal 
    virtual 
    {
        require(_initialBalance >= _amount, "Balance too low!");
        
        require(_amount > 0, "The value is less than zero!");
        
        balances[_spender] = _newBalance;
        
        freezed[_msgSender()][_spender] = _newFreezedBalance;
    }
    
    function freezedBalanceOf(address _spender) public view returns (uint256 locked) {
        return freezed[_msgSender()][_spender];
    }
}

abstract contract Pausable is Ownable {
    bool public paused = false;
    
    event Pause();
    
    event Unpause();

    modifier whenNotPaused() {
        require(paused == false, "All transactions have been paused.");
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }
    
    function pause() public onlyFounder whenNotPaused returns (bool success) {
        paused = true;
        
        emit Pause();
        
        return true;
    }
    
    function unpause() public  onlyFounder whenPaused returns (bool success) {
        paused = false;
        
        emit Unpause();
        
        return true;
    }
}

contract Bozy is  ERC20Interface, Context, Ownable, Whitelisted, Freezable, Pausable {

    uint8 public decimals; // Number of decimals
    string public name;    // Token name
    string public symbol;  // Token symbol
    uint256 public tokenPrice;
    uint256 public override totalSupply;
    mapping(address => mapping(address => uint256)) allowed;
    
    constructor() {
        name              = "Bozindo.com Currency";
        decimals          = 18;
        symbol            = "BOZY";
        totalSupply       = 30000000000; // 30 Billion
        balances[founder] = totalSupply * (10 ** decimals); // 30000000000E18
        tokenPrice        = 0.00001 ether; 
    }
    
    event Mint(address indexed _from, address indexed _to, uint256 _amount);
    
    event Burn(address indexed _from, address indexed _to, uint256 _amount);
    
    function changeTokenName(string memory _newName) 
    onlyFounder 
    noneZero(_msgSender()) 
    public 
    returns (bool success) 
    {

        
        name = _newName;
        
        return true;
    }
    
    function changeTokenSymbol(string memory _newSymbol) 
    onlyFounder 
    noneZero(_msgSender()) 
    public 
    returns (bool success) 
    {

        
        symbol = _newSymbol;
        
        return true;
    }
    
    function changeTokenPrice(uint256 _newPrice) 
    onlyFounder 
    noneZero(_msgSender()) 
    public 
    returns (bool success) 
    {

        
        tokenPrice = _newPrice;
        
        return true;
    }
    
    function transfer(address _to, uint256 _amount) public virtual override returns (bool success) {

        _transfer(_msgSender(), _to, _amount);
        
        return true;
    }
    
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _amount
    ) public virtual override returns (bool success) {

        _transfer(_from, _to, _amount);
        
        uint256 currentAllowance = allowed[_from][_msgSender()];
        
        _approve(_from, _msgSender(), currentAllowance - _amount, currentAllowance); 

        return true;
    }

    function approve(address _spender, uint256 _amount) public virtual override returns (bool success) {

        _approve(_msgSender(), _spender, _amount, balances[_msgSender()]);
        
        return true;
    }
    
    function disapprove(address _spender) public virtual returns (bool success) {

        _approve(_msgSender(), _spender, 0, 0);
        
        return true;
    }
    
    function increaseAllowance(address _spender, uint256 _amount) public virtual returns (bool success) {

        uint256 currentAllowance = allowed[_msgSender()][_spender];
        
        _approve(_msgSender(), _spender, currentAllowance + _amount, balances[_msgSender()]);
        
        return true;
    }
    
    function decreaseAllowance(address _spender, uint256 _amount) public virtual returns (bool success) {

        uint256 currentAllowance = allowed[_msgSender()][_spender];
        
        _approve(_msgSender(), _spender, currentAllowance - _amount, currentAllowance);

        return true;
    }  
    
    function _transfer( address _from, address _to, uint256 _amount)
    noneZero(_from)
    noneZero(_to)
    whenNotWhitelisted(_from)
    whenNotWhitelisted(_to)
    whenNotPaused
    internal 
    virtual 
    {

        uint256 senderBalance = balances[_from];
        
        require(senderBalance >= _amount, "The transfer amount exceeds balance.");
        
        balances[_to] += _amount;
        balances[_from] -= _amount;
        
        emit Transfer(_from, _to, _amount);
    }
    
    function _approve( address _owner, address _spender, uint256 _amount, uint256 _initialBalance)
    noneZero(_spender)
    noneZero(_owner)
    internal 
    virtual 
    {

        require(_initialBalance >= _amount, "Not enough balance.");
        
        require(_amount >= 0, "The value is less than or zero!");
        
        allowed[_owner][_spender] = _amount;
        
        emit Approval(_owner, _spender, _amount);
    }
    function mint(address _owner, uint256 _amount) 
    onlyFounder
    noneZero(_owner)
    public 
    virtual 
    returns (bool success) 
    {

        totalSupply += _amount;
        balances[_owner] += ( _amount * (10 ** decimals) );
        
        emit Mint(address(0), _owner, _amount);
        
        return true;
    }
    
    function burn(address _owner, uint256 _amount) 
    onlyFounder
    noneZero(_owner)
    public
    virtual
    returns (bool success)
    {

        uint256 accountBalance = balances[_owner];
        
        require(accountBalance >= _amount, "Burn amount exceeds balance");
        
        balances[_owner] -= ( _amount * (10 ** decimals) );
        totalSupply -= _amount;

        emit Burn(address(0), _owner, _amount);
        
        return true;
    }
        
    function balanceOf(address _owner) public view override returns (uint256 holdings) {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view virtual override returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }
    
}

contract BozyICO is Bozy {

    mapping(address => uint256) public contributions;
    address payable public deposit;
    address public admin;
    uint256 public raisedAmount;
    uint256 public icoTokenSold;
    uint256 public hardCap         = 6000 ether;
    uint256 public goal            = 2000 ether;
    uint256 public saleStart       = block.timestamp + 30 days;
    uint256 public saleEnd         = saleStart + 100 days;
    uint256 public TokenTransferStart = saleEnd + 10 days;
    uint256 public maxContribution = 10 ether;
    uint256 public minContribution = 0.001 ether;
    bool public emergencyMode      = false;

    enum State {beforeStart, running, afterEnd, halted}
    State icoState;
    
    event Contribute(address _contributor, uint256 _amount, uint256 _tokens);
    
    constructor(address payable _deposit) {
        deposit  = _deposit;
        admin    = _msgSender();
        icoState = State.beforeStart;
    }
    
    receive() payable external {
        contribute();
    }
    
    function haltICO() public onlyFounder {

        icoState = State.halted;
    }
    
    function resumeICO() public onlyFounder {

        icoState = State.running;
    }
    
    function changeDepositAddress(address payable _newDeposit) public onlyFounder {

        deposit = _newDeposit;
    }
    
    function contribute() payable public noneZero(_msgSender()) returns (bool success) {

        icoState = getICOState();   
         
        require(icoState == State.running, "ICO is not running. Check ICO state.");
        require(_msgValue() >= minContribution && _msgValue() <= maxContribution, "Contribution out of range.");
        require(raisedAmount <= hardCap, "HardCap has been reached.");
        
        raisedAmount += _msgValue();
        
        uint256 _tokens = (_msgValue() / tokenPrice) * (10 ** decimals);
        uint256 _depositBalance = contributions[deposit];
        
        icoTokenSold += _tokens;
        
        contributions[_msgSender()] += _msgValue();
        contributions[deposit] = _depositBalance + _msgValue();
        balances[_msgSender()] += _tokens;
        balances[founder] -= _tokens;
        
        payable(deposit).transfer(_msgValue());
        
        emit Contribute(_msgSender(), _msgValue(), _tokens);
        
        return true;
    }
    
    function transfer(address _to, uint256 _tokens) public override returns (bool success) {

        require(block.timestamp > saleStart, "ICO is not running.");
        require(block.timestamp > TokenTransferStart, "Transfer starts after ICO has ended.");
        
        Bozy.transfer(_to, _tokens);
        
        return true;
    }
    
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _tokens
    ) public override returns (bool success) {

        require(block.timestamp > saleStart, "ICO is not running.");
        require(block.timestamp > TokenTransferStart, "Transfer starts after ICO has ended.");
        
        Bozy.transferFrom(_from, _to, _tokens);
        
        return true;
    }
    
    function getICOState() public view returns(State) {

        if(icoState == State.halted) {
            return State.halted;      // returns 3
        } else 
        if(block.timestamp < saleStart) {
            return State.beforeStart; // returns 0
        } else if(block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.running;     // returns 1
        } else {
            return State.afterEnd;    // returns 2
        }
    }
}