

pragma solidity ^0.7.4;



contract SafeMath {

    function safeAdd(uint a, uint b) internal pure returns (uint c) {

        c = a + b;
        require(c >= a);
    }
    
    function safeSub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);
        c = a - b;
    }
    
    function safeMul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;
        require(a == 0 || c / a == b);
    }
    
    function safeDiv(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);
        c = a / b;
    }
}


abstract contract ERC20 {
    function totalSupply() virtual external view returns (uint);
    function balanceOf(address tokenOwner) virtual external view returns (uint balance);
    function allowance(address tokenOwner, address spender) virtual external view returns (uint remaining);
    function transfer(address to, uint tokens) virtual external returns (bool success);
    function approve(address spender, uint tokens) virtual external returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


abstract contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) virtual external;
}

abstract contract TransferAndCallFallBack {
    function receiveTransfer(address from, uint tokens, bytes memory data) virtual public returns (bool success); 
}


contract Owned {

    address public owner;
    address public newOwner; 

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor(address ownerAddress) {
        owner = ownerAddress;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        newOwner = _newOwner;
    }

    function acceptOwnership() public virtual {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


    contract EASYCOIN is ERC20, Owned, SafeMath {

    string constant public symbol = "EASY";
    string constant public name = "EASY COIN";
    uint8 constant public decimals = 18;
    uint constant private _totalSupply = 1000000000 * 10 ** 18;
    uint private _exchangeRate;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    event ChangeExchangeRate(uint newRate);

    constructor(address ownerAddress) Owned (ownerAddress) {
        balances[ownerAddress] = _totalSupply;
        _exchangeRate = 100;
        emit Transfer(address(0), ownerAddress, _totalSupply);
    }


    function totalSupply() override external view returns (uint) {

        return _totalSupply  - balances[address(0)];
    }


    function balanceOf(address tokenOwner) override external view returns (uint balance) {

        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) override external returns (bool success) {

        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint tokens) override external returns (bool success) {

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) override external returns (bool success) {

        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) override external view returns (uint remaining) {

        return allowed[tokenOwner][spender];
    }


    function exchangeRate() external view returns (uint rate) {

        return _exchangeRate;
    }


    function approveAndCall(address spender, uint tokens, bytes memory data) external returns (bool success) {

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    function transferAndCall(address to, uint tokens, bytes memory data) public returns (bool success) {

        require (tokens <= balances[msg.sender] );
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        require (TransferAndCallFallBack(to).receiveTransfer(msg.sender, tokens, data));
        
        emit Transfer(msg.sender, to, tokens);
        return true;    
    }


    function buyTokens() public payable returns (bool success) {

        require (msg.value > 0, "ETH amount should be greater than zero");
        
        uint tokenAmount = _exchangeRate * msg.value; 
        balances[owner] = safeSub(balances[owner], tokenAmount);
        balances[msg.sender] = safeAdd(balances[msg.sender], tokenAmount);
        emit Transfer(owner, msg.sender, tokenAmount);
        return true;
    }


    function buyTokensAndTransfer(address to, bytes memory data) external payable returns (bool success) {

        require (buyTokens());
        uint tokenAmount = _exchangeRate * msg.value ;
        require (transferAndCall (to, tokenAmount, data));
        return true;
    }
    

    function transferAnyERC20Token(address tokenAddress, uint tokens) external onlyOwner returns (bool success) {

        return ERC20(tokenAddress).transfer(owner, tokens);
    }


    function changeExchangeRate(uint newExchangeRate) external onlyOwner {

        require (newExchangeRate > 0, "Exchange rate should be greater than zero");
        _exchangeRate = newExchangeRate; 
        emit ChangeExchangeRate(newExchangeRate);
    }

  
    function transferFunds(address to, uint amount) external onlyOwner returns (bool success) {

        require (amount <= address(this).balance, "Not enough funds");
        address(uint160(to)).transfer(amount);
        return true;
    }
    
    function acceptOwnership() public override {

        balances[newOwner] = balances[owner];
        balances[owner] = 0;
        emit Transfer(owner, newOwner, balances[newOwner]);
        super.acceptOwnership();
    }
}