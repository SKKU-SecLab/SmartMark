
pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {

    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

}

contract FreedomCoin is Ownable {

    
    using SafeMath for uint256;

    string public constant symbol = "FDC";
    string public constant name = "Freedom Coin";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 100000000000000000000000000;
    uint256 public rate = 5000000000000000000;
    
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() public{
      balances[owner] = totalSupply;
    }
    
    function () public payable {
        create(msg.sender);
    }

    function create(address beneficiary) public payable {

        require(beneficiary != address(0));
        
        uint256 weiAmount = msg.value; // Calculate tokens to sell
        uint256 tokens = weiAmount.mul(10**18).div(rate);

        require(tokens <= balances[owner]);
        
        if(weiAmount > 0){
            balances[beneficiary] += tokens;
            balances[owner] -= tokens;
        }
    }
    
    function back_giving(uint256 tokens) public {

        uint256 amount = tokens.mul(rate).div(10**18);
        balances[owner] += tokens;
        balances[msg.sender] -= tokens;
        (msg.sender).transfer(amount);
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];
    }
    
    function balanceMaxSupply() public constant returns (uint256 balance) {

        return balances[owner];
    }
    
    function balanceEth(address _owner) public constant returns (uint256 balance) {

        return _owner.balance;
    }
    
    function collect(uint256 amount) onlyOwner public{

        msg.sender.transfer(amount);
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {

        require(_to != address(0));
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0));
        balances[newOwner] = balances[owner];
        balances[owner] = 0;
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }

}