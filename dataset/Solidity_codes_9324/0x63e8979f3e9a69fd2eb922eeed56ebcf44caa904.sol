
pragma solidity ^0.5.16;

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

contract ERC20 {

	using SafeMath for uint256;
	uint public totalSupply;
	
	string public name;
	uint8 public decimals;
	string public symbol;
	string public version;
	
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint)) allowed;

	modifier onlyPayloadSize(uint size) {

		assert(msg.data.length == size + 4);
		_;
	} 

	function balanceOf(address _owner) public view returns (uint balance) {

		return balances[_owner];
	}

	function transfer(address _to, uint _value) public onlyPayloadSize(2*32) returns (bool success) {

	    address owner = msg.sender;
	    require(balances[owner] >= _value && _value > 0);
	    balances[owner] = balances[owner].sub(_value);
	    balances[_to] = balances[_to].add(_value);
	    emit Transfer(owner, _to, _value);
	    return true;
    }

	function transferFrom(address _from, address _to, uint _value) public returns (bool success) {

	    address owner = msg.sender;
	    require(balances[_from] >= _value && allowed[_from][owner] >= _value && _value > 0);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][owner] = allowed[_from][owner].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint remaining) {

        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint _value) external returns (bool) {

    	address owner = msg.sender;
        allowed[owner][_spender] = _value;
        emit Approval(owner, _spender, _value);
        return true;
    }

	event Transfer(
		address indexed _from,
		address indexed _to,
		uint _value
		);
		
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint _value
		);
}

contract OakTreasureChest is ERC20 {

	constructor() public {
		totalSupply = 123000000000000000000;
		name = "OakTreasureChest";
		decimals = 18;
		symbol = "OAK-CHEST";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}