
pragma solidity ^0.4.24;


library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);
        c = a / b;
    }
}


contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}


contract Owned {

    address public owner;
    address public newOwner;
    address public manger;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        manger =msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }
    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}




contract BIOPLUS_X_RAY_Token is ERC20Interface, Owned {

    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    constructor() public {
        symbol = "BPX";
        name = "BIOPLUS X-RAY ";
        decimals = 18;
        _totalSupply = 1000000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


    function totalSupply() public view returns (uint) {

        return _totalSupply.sub(balances[address(0)]);
    }


    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];
    }


    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    function () public payable {
        revert();
    }


    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
   
}

contract BPX_ctrl{

    
    using SafeMath for uint;
    
    constructor(address ERC20_From , address space_address)public {
        manager = msg.sender;
        Safe_space = space_address;
        ERC_20_From = ERC20_From;
    }
   
    address public ERC_20_From;
    address public manager;
    address public Safe_space;
    uint public price;
    uint public count;
    
    mapping(address => address)public verification;
    mapping(uint=>address)public investor_number;
    mapping(address=>uint)public amount;
   
    BIOPLUS_X_RAY_Token BPX_ERC20 = BIOPLUS_X_RAY_Token(0xd5cEC1599196cfF44c8277517Cd01936Bc8d7f00);
    
    
    function exchange()public payable{

        require(msg.value !=0);
        
        manager.transfer(msg.value.mul(1).div(100));
        Safe_space.transfer(msg.value.mul(99).div(100));
        
        if(verification[msg.sender] == address(0)){
            verification[msg.sender] = msg.sender;
            investor_number[count] = msg.sender;
            count=count.add(1);
        }
        
        amount[msg.sender]= amount[msg.sender].add(msg.value);
        BPX_ERC20.transferFrom(ERC_20_From,msg.sender,msg.value.mul(price));
        
    }
    
    function project_fail(uint start , uint end)public {

        require(msg.sender == manager);
        
        for(uint i=start ; i<=end ; i++){
            investor_number[i].transfer(amount[investor_number[i]].mul(8).div(10));
        }
        
        Safe_transe();
        
    }
    
    function Safe_transe()private {

        require(manager == msg.sender);
        manager.transfer(address(this).balance);
    }
    
    function pay_back()public payable{

        require(manager == msg.sender);
    }
    
    
    function token_price(uint _price)public {

        require(msg.sender == manager);
        price = _price;
        
    }
    
    
   
}