
 
pragma solidity 0.5.11;

interface IERC20 {

    function transfer(address to, uint256 tokens) external returns (bool);

    
    function approve(address spender, uint256 tokens) external returns (bool);

    
    function transferFrom(address from, address to, uint256 tokens) external returns (bool);


    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function allowance(address account, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ERC20 is IERC20 {

    using SafeMath for uint256;		                            /// Attach SafeMath functions with uint256 to mitigate integer overflow

    string public constant name = "TokenHook";                  /// Token name
    string public constant symbol = "THK";                      /// Token symbol
    uint8 public constant decimals = 18;                        /// Divisible to 18 decimal places
    address payable private owner;                              /// Token owner
    uint256 public exchangeRate = 100;                          /// 100 tokens per 1ETH, default exchange rate
    uint256 private initialSupply = 200e6;                      /// Controls economy of the token by limiting initial supply to 200M
    bool private locked;                                        /// Mutex variable to mitigate re-entrancy attack
    bool private paused;                                        /// Boolean variable to support Fail-Safe mode

    mapping(address => mapping (address => uint256)) private allowances;	/// Allowed token to transfer by spenders
    mapping(address => mapping (address => uint256)) private transferred;	/// Transferred tokens by spenders
    mapping(address => uint256) public balances;                            /// Balance of token holders

    constructor(uint256 supply) public {
        owner = msg.sender;                                                 /// Owner of the token
        initialSupply = (supply != 0) ? supply :                            /// Initialize token supply
                        initialSupply.mul(10 ** uint256(decimals));         /// With 18 zero
        balances[owner] = initialSupply;                                    /// Owner gets all initial tokens
        emit Transfer(address(0), owner, initialSupply);                    /// Logs transferred tokens to the owner
    }
    
    function() external payable{
        emit Received(msg.sender, msg.value);                               /// Logs received ETH
    }
    
    function transfer(address to, uint256 tokens) external notPaused validAddress(to) noReentrancy returns (bool success) {

        require(balances[msg.sender] >= tokens, "Not enough balance");          /// Checks the sender's balance
        require(balances[to].add(tokens) >= balances[to], "Overflow error");    /// Checks overflows
        balances[msg.sender] = balances[msg.sender].sub(tokens);                /// Subtracts from the sender
        balances[to] = balances[to].add(tokens);                                /// Adds to the recipient
        emit Transfer(msg.sender, to, tokens);                                  /// Logs transferred tokens
        return true;
    }
 
    function transferFrom(address from, address to, uint256 tokens) external notPaused validAddress(to) noReentrancy returns (bool success) {

        require(balances[from] >= tokens, "Not enough tokens");                     /// Checks the sender's balance
        require(tokens <= (                                                         /// Prevent token transfer more than allowed
                           (allowances[from][msg.sender] > transferred[from][msg.sender]) ? 
                            allowances[from][msg.sender].sub(transferred[from][msg.sender]) : 0)
                            , "Transfer more than allowed");                               
        balances[from] = balances[from].sub(tokens);                                /// Decreases balance of approver
        balances[to] = balances[to].add(tokens);                                    /// Increases balance of spender
        transferred[from][msg.sender] = transferred[from][msg.sender].add(tokens);  /// Tracks transferred tokens
        emit Transfer(from, to, tokens);                                            /// Logs transferred tokens
        return true;
    }

    function approve(address spender, uint256 tokens) external notPaused validAddress(spender) noReentrancy returns (bool success) {

        require(spender != msg.sender, "Approver is spender");                      /// Spender cannot approve himself
        require(balances[msg.sender] >= tokens, "Not enough balance");              /// Checks the approver's balance
        allowances[msg.sender][spender] = tokens;                                   /// Sets allowance of the spender
        emit Approval(msg.sender, spender, tokens);                                 /// Logs approved tokens
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedTokens) external notPaused validAddress(spender) noReentrancy returns (bool success) {

        require(balances[msg.sender] >= addedTokens, "Not enough token");                       /// Checks the approver's balance
        allowances[msg.sender][spender] = allowances[msg.sender][spender].add(addedTokens);     /// Adds allowance of the spender
        emit Approval(msg.sender, spender, addedTokens);                                        /// Logs approved tokens
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedTokens) external notPaused validAddress(spender) noReentrancy returns (bool success) {

        require(allowances[msg.sender][spender] >= subtractedTokens, "Not enough token");       /// Checks the spenders's allowance
        allowances[msg.sender][spender] = allowances[msg.sender][spender].sub(subtractedTokens);/// Adds allowance of the spender
        emit Approval(msg.sender, spender, subtractedTokens);                                   /// Logs approved tokens
        return true;
    }
    
    function sell(uint256 tokens) external notPaused noReentrancy returns(bool success)
    {

        require(tokens > 0, "No token to sell");                                /// Selling zero token is not allowed
        require(balances[msg.sender] >= tokens, "Not enough token");            /// Checks the seller's balance
        uint256 _wei = tokens.div(exchangeRate);                                /// Calculates equivalent of tokens in Wei
        require(address(this).balance >= _wei, "Not enough wei");               /// Checks the contract's ETH balance
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);                /// Decreases tokens of seller
        balances[owner] = balances[owner].add(tokens);                          /// Increases tokens of owner
        
        emit Sell(msg.sender, tokens, address(this), _wei, owner);              /// Logs sell event
        (success, ) = msg.sender.call.value(_wei)("");                          /// Transfers Wei to the seller
        require(success, "Ether transfer failed");                              /// Checks successful transfer
    }
    
    function buy() external payable notPaused noReentrancy returns(bool success){

        require(msg.sender != owner, "Called by the Owner");                /// The owner cannot be seller/buyer
        uint256 _tokens = msg.value.mul(exchangeRate);                      /// Calculates token equivalents
        require(balances[owner] >= _tokens, "Not enough tokens");           /// Checks owner's balance

        balances[msg.sender] = balances[msg.sender].add(_tokens);           /// Increases token balance of buyer
        balances[owner] = balances[owner].sub(_tokens);                     /// Decreases token balance of owner
        emit Buy(msg.sender, msg.value, owner, _tokens);                    /// Logs Buy event
        return true;
    }
    
    function withdraw(uint256 amount) external onlyOwner returns(bool success){

        require(address(this).balance >= amount, "Not enough fund");        /// Checks the contract's ETH balance

        emit Withdrawal(msg.sender, address(this), amount);                 /// Logs withdrawal event
        (success, ) = msg.sender.call.value(amount)("");                    /// Transfers amount (EIP-1884 compatible)
        require(success, "Ether transfer failed");                          /// Checks successful transfer
    }
    
    
    function mint(uint256 newTokens) external onlyOwner {

        initialSupply = initialSupply.add(newTokens);               /// Increases token supply
        balances[owner] = balances[owner].add(newTokens);           /// Increases balance of the owner
        emit Mint(msg.sender, newTokens);                           /// Logs Mint event
    }

    function burn(uint256 tokens) external onlyOwner {

        require(balances[owner] >= tokens, "Not enough tokens");    /// Checks owner's balance
        balances[owner] = balances[owner].sub(tokens);              /// Decreases balance of the owner
        initialSupply = initialSupply.sub(tokens);                  /// Decreases token supply
        emit Burn(msg.sender, tokens);                              /// Logs Burn event
    }
    
    function setExchangeRate(uint256 newRate) external onlyOwner returns(bool success)
    {

        uint256 _currentRate = exchangeRate;
        exchangeRate = newRate;                             /// Sets new exchange rate
        emit Change(_currentRate, exchangeRate);            /// Logs Change event
        return true;
    }
    
    function changeOwner(address payable newOwner) external onlyOwner validAddress(newOwner) {

        address _current = owner;
        owner = newOwner;
        emit ChangeOwner(_current, owner);
    }
    
    function pause() external onlyOwner {

        paused = true;                  
        emit Pause(msg.sender, paused);
    }
    
    function unpause() external onlyOwner {

        paused = false;
        emit Pause(msg.sender, paused);
    }

    function totalSupply() external view returns (uint256 tokens) {

        return initialSupply;                       /// Total supply of the token.
    }
    
    function balanceOf(address tokenHolder) external view returns (uint256 tokens) {

        return balances[tokenHolder];               /// Balance of token holder.
    }
    
    function allowance(address tokenHolder, address spender) external view notPaused returns (uint256 tokens) {

        uint256 _transferred = transferred[tokenHolder][spender];       /// Already transferred tokens by `spender`.
        return allowances[tokenHolder][spender].sub(_transferred);      /// Remained tokens to transfer by `spender`.
    }
    
    function transfers(address tokenHolder, address spender) external view notPaused returns (uint256 tokens) {

        return transferred[tokenHolder][spender];    /// Transfers by `spender` (approved by `tokenHolder`).
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    modifier validAddress(address addr){

        require(addr != address(0x0), "Zero address");
        require(addr != address(this), "Contract address");
        _;
    }
    
    modifier noReentrancy() 
    {

        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
    modifier notPaused() 
    {

        require(!paused, "Fail-Safe mode");
        _;
    }
    
    event Buy(address indexed _buyer, uint256 _wei, address indexed _owner, uint256 _tokens);
    event Sell(address indexed _seller, uint256 _tokens, address indexed _contract, uint256 _wei, address indexed _owner);
    event Received(address indexed _sender, uint256 _wei);
    event Withdrawal(address indexed _by, address indexed _contract, uint256 _wei);
    event Change(uint256 _current, uint256 _new);
    event ChangeOwner(address indexed _current, address indexed _new);
    event Pause(address indexed _owner, bool _state);
    event Mint(address indexed _owner, uint256 _tokens);
    event Burn(address indexed _owner, uint256 _tokens);
}