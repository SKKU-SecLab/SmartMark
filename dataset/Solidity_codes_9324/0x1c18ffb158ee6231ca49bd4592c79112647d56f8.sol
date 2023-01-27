
pragma solidity >=0.4.23 <0.6.0;
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

        assert(b > 0);
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

contract Token {



    function balanceOf(address _owner) public view returns (uint balance);


    function transfer(address _to, uint _value) public returns (bool success);


    function transferFrom(address _from, address _to, uint _value) public returns (bool success);


    function approve(address _spender, uint _value) public returns (bool success);


    function allowance(address _owner, address _spender) public view returns (uint remaining);


    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract RegularToken is Token {


    using SafeMath for uint256;

    function transfer(address _to, uint _value) public returns (bool) {

        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {

        require(_to != address(0));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint) {

        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool) {

        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint) {

        return allowed[_owner][_spender];
    }

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint public totalSupply;
}

contract UnboundedRegularToken is RegularToken {


    uint constant MAX_UINT = 2 ** 256 - 1;

    function transferFrom(address _from, address _to, uint _value)
    public
    returns (bool)
    {

        require(_to != address(0));
        uint allowance = allowed[_from][msg.sender];

        require(balances[_from] >= _value);
        require(allowance >= _value);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        if (allowance < MAX_UINT) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }
}

contract ETPlanToken is UnboundedRegularToken {


    uint8 constant public decimals = 18;
    string constant public name = "ETPlanToken";
    string constant public symbol = "ELS";

    constructor() public {
        totalSupply = 33 * 10 ** 25;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
}