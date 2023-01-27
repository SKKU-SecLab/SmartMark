
pragma solidity ^0.5.0;

library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;
        
		return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}



contract Ownable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() internal view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract NeuroToken is Ownable {

    using SafeMath for uint256;
    
    mapping (address => uint256) private balances;
    
    mapping (address => mapping(address => uint256)) private allowed;
    
    string public constant name = "NeuroToken";
    string public constant symbol = "NRT";
    uint8 public constant decimal = 18;
    
    uint256 public totalSupply;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _from, address indexed _to, uint256 _value);
    
    function mint(address _to, uint256 _value) onlyOwner public {

        require(_to != address(0), "ERC20: mint to the zero address");
        
        balances[_to] = balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        
        emit Transfer(address(0), _to, _value);
    }
    
    function balanceOf(address _owner) public view returns(uint256) {

        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public {

        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public {

        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        
        emit Transfer(_from, _to, _value);
        emit Approval(_from, _to, _value);
    }
    
    function allowance(address _owner, address _spender) public view returns(uint256) {

        return allowed[_owner][_spender];
    }
    
    function approve(address _spender, uint256 _value) public {

        require(msg.sender != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve from the zero address");
        
        allowed[msg.sender][_spender] = _value; 
        
        emit Approval(msg.sender, _spender, _value);
    }
}