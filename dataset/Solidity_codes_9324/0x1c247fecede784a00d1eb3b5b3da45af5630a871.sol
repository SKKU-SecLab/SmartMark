
pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {


    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract PussyRocket is IERC20 {

   
    string public constant name         = 'PussyRocket';
    string public constant symbol       = 'PROCK';
    uint8 public constant decimals      = 18;
    
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    address public tokenOwner;
    address public crowdsale;
    
    uint256 public totalSupply_                     = 69e27; // 69B tokens
    uint256 public constant unlockTime              = 1640008800; //After this date, tokens are no longer locked
    uint256 public limitCrowdsale                   = 58e27;    // 84% of token goes for sale
    uint256 public tokensDistributedCrowdsale       = 0;    // The amount of tokens already sold to the ICO buyers
    bool public remainingTokenBurnt                 = false;  


    modifier onlyOwner {

    require(msg.sender == tokenOwner);
    _;
    }
    
    modifier onlyCrowdsale {

    require(msg.sender == crowdsale);
    _;
    }
    
    modifier afterCrowdsale {

    require(block.timestamp > unlockTime || msg.sender == crowdsale);
    _;
    }
    
    constructor() public {
        tokenOwner = msg.sender;
        balances[msg.sender] = totalSupply_ - limitCrowdsale;
            emit Transfer(address(0), msg.sender, totalSupply_ - limitCrowdsale);
    }

    function totalSupply() public override view returns (uint256) {

        return totalSupply_;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public afterCrowdsale override returns (bool) {

        require(recipient != address(0));
        require(amount <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public afterCrowdsale override returns (bool) {

        require(recipient != address(0));
        require(amount <= balances[sender]);
        require(amount <= allowed[sender][msg.sender]);

        balances[sender] = balances[sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public afterCrowdsale override returns (bool) {

        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address account,address spender) public override view returns (uint256) {

        return allowed[account][spender];
    }

    function increaseApproval(address spender, uint256 amount) public afterCrowdsale returns (bool) {

        allowed[msg.sender][spender] = (allowed[msg.sender][spender] + amount);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseApproval(address spender, uint256 amount) public afterCrowdsale returns (bool) {

        uint256 oldValue = allowed[msg.sender][spender];
        if (amount >= oldValue) {
          allowed[msg.sender][spender] = 0;
        } else {
          allowed[msg.sender][spender] = oldValue - amount;
        }
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
   
   
    function setCrowdsale(address _crowdsale) external onlyOwner {

        require(_crowdsale != address(0));
        crowdsale = _crowdsale;
    }
    
    function distribute(address buyer, uint tokens) external onlyCrowdsale {

        require(buyer != address(0));
        require(tokens > 0);

        require(tokensDistributedCrowdsale < limitCrowdsale);
        require(tokensDistributedCrowdsale + tokens <= limitCrowdsale);

        tokensDistributedCrowdsale = tokensDistributedCrowdsale + tokens;
        balances[buyer] = balances[buyer] + tokens;
        emit Transfer(address(0), buyer, tokens);
      }
   
   function airdrop(address recipient, uint amount) external onlyOwner returns (bool){

        require(block.timestamp < unlockTime);
        require(recipient != address(0));
        require(amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
      }
   
    function burn() external onlyCrowdsale {

        uint256 remainingICOToken = limitCrowdsale - tokensDistributedCrowdsale;
        if(remainingICOToken > 0 && !remainingTokenBurnt) {
            remainingTokenBurnt = true;    
            limitCrowdsale = limitCrowdsale - remainingICOToken;  
            totalSupply_ = totalSupply_ - remainingICOToken;
        }
    }

    function emergencyExtract() external onlyOwner {

        payable(tokenOwner).transfer(address(this).balance);
    }
}



pragma solidity >=0.8.0 <0.9.0;


contract Crowdsale {

   
    PussyRocket public constant token = PussyRocket(0x263CE9eA0dC46c9A12F3F624396eEe896c270b60);
   
    uint256 public constant icoEndTime      = 1640008800;
    uint256 public constant fundingGoal     = 58e27;
   
    address public contractOwner;
    uint256 public tokensRaised;
    uint256 public etherRaised;
   
    bool public icoCompleted = false;

    modifier whenIcoCompleted {

        require(icoCompleted);
        _;
    }

    modifier onlyOwner {

        require(msg.sender == contractOwner);
        _;
    }

    constructor() public {
        contractOwner = msg.sender;
    }
    
    
    receive() external payable { 
        purchaseTokens(msg.value);
        
    }
    
    function time() public view returns (uint256) {

        return block.timestamp;
    }

    function purchaseTokens(uint256 etherUsedWei) public payable {

    assert(1 ether == 1e18);
        require(!icoCompleted);
        require(block.timestamp < icoEndTime);
    
        uint256 tokensToReiceive;
        
        
        if(tokensRaised < 14.5e27) { // Each tier is 25% of total funding goal
            tokensToReiceive = 45e6 * etherUsedWei; // 80% discount
        } else if(tokensRaised <  29e27) {
            tokensToReiceive = 22.5e6 * etherUsedWei; // 60% discount
        } else if(tokensRaised < 43.5e27) {
            tokensToReiceive = 15e6 * etherUsedWei; // 40% discount
        } else{
            tokensToReiceive = 11.25e6 * etherUsedWei; // 20% discount
        }
    
        token.distribute(msg.sender, tokensToReiceive);
        tokensRaised += tokensToReiceive;
        etherRaised += etherUsedWei;
        
        if(tokensRaised >= fundingGoal) {
            icoCompleted = true;
        }
       
    }
   
    function finalizeCrowdsale() public onlyOwner {

        require(!icoCompleted);
        require(icoEndTime < block.timestamp);
        token.burn();
        icoCompleted = true;
    }
    
    function extractEther() public onlyOwner {

        payable(contractOwner).transfer(address(this).balance);
    }
}


