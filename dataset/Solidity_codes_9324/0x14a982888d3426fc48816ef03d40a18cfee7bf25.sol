pragma solidity ^0.5.1;


contract IERC223 {

    uint public _totalSupply;
    
    function balanceOf(address who) public view returns (uint);

        
    function transfer(address to, uint value) public returns (bool success);

        
    function transfer(address to, uint value, bytes memory data) public returns (bool success);

     
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}pragma solidity ^0.5.1;

 
contract IERC223Recipient { 

    function tokenFallback(address _from, uint _value, bytes memory _data) public;

}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }
}pragma solidity ^0.5.1;


contract ERC223Token is IERC223 {

    using SafeMath for uint;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    mapping(address => uint) balances; // List of user balances.

    function transfer(address _to, uint _value, bytes memory _data) public returns (bool success){

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(Address.isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function transfer(address _to, uint _value) public returns (bool success){

        bytes memory empty = hex"00000000";
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(Address.isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
        return true;
    }


    function balanceOf(address _owner) public view returns (uint balance) {

        return balances[_owner];
    }
}pragma solidity ^0.5.1;


contract ERC223Burnable is ERC223Token {

    function burn(uint256 _amount) public {

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        _totalSupply = _totalSupply.sub(_amount);
        
        bytes memory empty = hex"00000000";
        emit Transfer(msg.sender, address(0), _amount, empty);
    }
}pragma solidity ^0.5.1;




contract ERC223Detailed is IERC223 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}pragma solidity ^0.5.1;


contract Links is ERC223Detailed, ERC223Burnable {


	constructor () public ERC223Detailed("Smart Links", "LINX", 18) {
		uint256 initialAmount = 20000000000 * (10**uint256(18));
		balances[msg.sender] = balances[msg.sender].add(initialAmount);
		_totalSupply = _totalSupply.add(initialAmount);
		bytes memory empty = hex"00000000";
		emit Transfer(address(0), msg.sender, initialAmount, empty);
	}
}