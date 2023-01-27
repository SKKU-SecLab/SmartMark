
pragma solidity ^0.4.20;

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

contract ERC20 {

    function totalSupply() public constant returns (uint256 _totalSupply);

 
    function balanceOf(address _owner) public constant returns (uint256 balance);

 
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    function approve(address _spender, uint256 _value) public returns (bool success);


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

  
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC223 is ERC20{

    function transfer(address _to, uint _value, bytes _data) public returns (bool success);

    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint _value, bytes indexed _data);
}

contract ContractReceiver {  

    function tokenFallback(address _from, uint _value, bytes _data) external;

}

contract Ownable {

    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {

        _owner = msg.sender;
        OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {

        return _owner;
    }   
    
    modifier onlyOwner() {

        require(_owner == msg.sender);
        _;
    }
    
    function renounceOwnership() public onlyOwner {

        OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {

        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {

        return block.timestamp;
    }

    function lock(uint256 time) public onlyOwner {

        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public {

        require(_previousOwner == msg.sender);
        require(block.timestamp > _lockTime );
        OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract BasicToken is Ownable, ERC223 {

    using SafeMath for uint256;
    
    uint256 public constant decimals = 18;
    string public constant symbol = "DFIAT";
    string public constant name = "DeFiato";
    uint256 public totalSupply = 250000000 * 10**18;

    address public admin;

    bool public tradable = false;

    mapping(address => uint256) balances;
    
    mapping(address => mapping (address => uint256)) allowed;

    modifier isTradable(){

        require(tradable == true || msg.sender == admin || msg.sender == owner());
        _;
    }

    function totalSupply()
    public 
    constant 
    returns (uint256) {

        return totalSupply;
    }
        
    function balanceOf(address _addr) 
    public
    constant 
    returns (uint256) {

        return balances[_addr];
    }
    
    
    function isContract(address _addr) 
    private 
    view 
    returns (bool is_contract) {

        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length>0);
    }
 
    function transfer(address _to, uint _value) 
    public 
    isTradable
    returns (bool success) {

        require(_to != 0x0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transfer(
        address _to, 
        uint _value, 
        bytes _data) 
    public
    isTradable 
    returns (bool success) {

        require(_to != 0x0);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        Transfer(msg.sender, _to, _value);
        if(isContract(_to)) {
            ContractReceiver receiver = ContractReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
        }
        
        return true;
    }
    
    function transfer(
        address _to, 
        uint _value, 
        bytes _data, 
        string _custom_fallback) 
    public 
    isTradable
    returns (bool success) {

        require(_to != 0x0);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        Transfer(msg.sender, _to, _value);

        if(isContract(_to)) {
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
        }
        return true;
    }
         
    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
    public
    isTradable
    returns (bool success) {

        require(_to != 0x0);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _amount) 
    public
    returns (bool success) {

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    function allowance(address _owner, address _spender) 
    public
    constant 
    returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }
    
    function updateAdmin(address _admin) 
    public 
    onlyOwner{

        admin = _admin;
    }
    
    function turnOnTradable() 
    public onlyOwner {

        tradable = true;
    }
}

contract DEFIATO is BasicToken {


    function DEFIATO() public {

        balances[msg.sender] = totalSupply;
        Transfer(0x0, msg.sender, totalSupply);
    }

    function()
    public
    payable {
        
    }

    function withdraw() onlyOwner 
    public 
    returns (bool) {

        return owner().send(this.balance);
    }

    function transferAnyERC20Token(address tokenAddress, uint256 amount) public returns (bool success) {

        return ERC20(tokenAddress).transfer(owner(), amount);
    }
}