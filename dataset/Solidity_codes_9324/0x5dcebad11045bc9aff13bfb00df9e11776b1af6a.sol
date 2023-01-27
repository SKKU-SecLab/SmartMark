pragma solidity ^0.6.0;
contract Owned {

    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {

        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}// "UNLICENSED "
pragma solidity ^0.6.0;
 
library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function ceil(uint a, uint m) internal pure returns (uint r) {

    return (a + m - 1) / m * m;
  }
}// "UNLICENSED "
pragma solidity ^0.6.0;
abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function approve(address spender, uint256 tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}pragma solidity ^0.6.0;




contract Token is ERC20Interface, Owned {

    using SafeMath for uint256;
    string public symbol = "ZDEX";
    string public  name = "Zeedex";
    uint256 public decimals = 18;
    uint256 _totalSupply = 10 * 1000000 * 10 ** (decimals); 
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    constructor() public {
        owner = msg.sender;
        balances[address(owner)] = totalSupply();
        
        emit Transfer(address(0),address(owner), totalSupply());
    }
    
    
    function totalSupply() public override view returns (uint256){

       return _totalSupply; 
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {

        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens) public override returns (bool success) {

        require(address(to) != address(0));
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
            
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
    function approve(address spender, uint256 tokens) public override returns (bool success){

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success){

        require(tokens <= allowed[from][msg.sender]); //check allowance
        require(balances[from] >= tokens);
            
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {

        return allowed[tokenOwner][spender];
    }
    
    function burnTokens(uint256 _amount) public {

        _burn(_amount, msg.sender);
    }

    function _burn(uint256 _amount, address _account) internal {

        require(balances[_account] >= _amount, "insufficient account balance");
        _totalSupply = _totalSupply.sub(_amount);
        balances[address(_account)] = balances[address(_account)].sub(_amount);
        emit Transfer(address(_account), address(0), _amount);
    }
}pragma solidity ^0.6.0;


contract ZeedexSale is Owned {

    
    Token token;
    enum State {_OPEN, _CLOSE, _UNLOCKED}
    
    State saleState = State._CLOSE;
    
    mapping(address => uint256) public tokenAllocation;
    mapping(uint256 => address) public users;
    uint256 totalUsers;
    uint256 public totalTokens;
    
    event TokensAllocated(uint256 tokens, address purchaser);
    event TokensUnlocked();
    
    constructor(address payable _owner, address _tokenAddress) public{
        owner = _owner; 
        token = Token(_tokenAddress);
    }
    
    function startSale() external onlyOwner{

        require(token.balanceOf(address(this)) > 0, "tokens: Insufficient token balance of the contract");
        require(saleState == State._CLOSE, "sale state: The sale is open already");
        
        totalTokens = token.balanceOf(address(this));
        saleState = State._OPEN; // open sale but tokens are locked
    }
    
    function endSale() external onlyOwner{

        require(saleState == State._OPEN, "sale state: Sale is closed already");
        
        saleState = State._CLOSE;
        
        if(totalTokens > 0){
            token.transfer(owner, totalTokens);
            totalTokens = 0;
        }
        
        owner.transfer(address(this).balance); // send all collected funds to the owner
    }
    
    function unlockTokens() external onlyOwner{

        require(saleState == State._CLOSE, "sale state: Sale is open");
        saleState = State._UNLOCKED;
        sendTokens();
        emit TokensUnlocked();
    }
    
    
    function sendTokens() internal{

        for(uint256 i = 1; i<= totalUsers; i++){
            address _to = users[i];
            token.transfer(_to, tokenAllocation[_to]); // transfer tokens to the users
            tokenAllocation[_to] = 0;
        }
        
    }
    
    fallback() external payable{
        purchase();
    }
    
    receive() external payable{
        purchase();
    }
    
    function purchase() internal {

        require(saleState == State._OPEN, "sale state: Sale is not open");
        require(msg.value >= 0.5 ether && msg.value <= 20 ether, "investment: Purchase amount is not within limits");
        require(totalTokens >= calculateTokens(), "tokens: Insufficient token balance of the contract, try with lower amount");
        tokenAllocation[msg.sender] += calculateTokens();
        totalTokens -= calculateTokens();
        totalUsers++;
        users[totalUsers] = msg.sender;
        emit TokensAllocated(calculateTokens(), msg.sender);
    }
    function calculateTokens() internal returns(uint256 _tokens){

        
        return msg.value * (4000); 
    }
}