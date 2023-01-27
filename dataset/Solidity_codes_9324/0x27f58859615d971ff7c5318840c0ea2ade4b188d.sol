
pragma solidity 0.5.7;

contract ERC20 {

  function totalSupply()public view returns (uint256 total_Supply);

  function balanceOf(address who)public view returns (uint256);

  function transfer(address to, uint256 value)public returns (bool success);

  function transferFrom(address from, address to, uint256 value)public returns (bool success);

  function approve(address spender, uint256 value)public returns (bool success);

  function allowance(address owner, address spender)public view returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity 0.5.7;



contract UzNEX is ERC20 {

    using SafeMath for uint256;
    string private constant _name = "UzNEX Coin";
    string private constant _symbol = "UNB";
    uint8 private constant _decimals = 18;

    uint256 private _totalsupply = 8000000000 * (10 ** uint256(_decimals));
    address private _owner;


    struct Lock {
        uint256 time;
        uint256 amount;
    }

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;
    mapping (address => Lock) private locks;


    event Burn(address indexed from, uint256 amount);

    modifier onlyOwner() {

        require(msg.sender == _owner, "Only owner is allowed");
        _;
    }

    constructor() public
    {
        balances[msg.sender] = _totalsupply;
        _owner = msg.sender;

    }

    function name() public pure returns (string memory) {

        return _name;
    }

    function symbol() public pure returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return _decimals;
    }


    function owner() public view returns (address) {

        return _owner;
    }

    function lockStatus(address _of) public view returns (uint256,uint256,uint256) {

        return (block.timestamp, locks[_of].time, locks[_of].amount);
    }

    function totalSupply() public view returns (uint256) {

        return _totalsupply;
    }

    function balanceOf(address _of) public view returns (uint256) {

        return balances[_of];
    }

    function lockToken(address _of, uint256 _amount, uint256 _time) public onlyOwner  {

        locks[_of].time = _time;
        locks[_of].amount = _amount;
    }

    function unlockToken(address _of) public onlyOwner  {

        locks[_of].time = block.timestamp;
        locks[_of].amount = 0;
    }


    function approve(address _spender, uint256 _amount) public  returns (bool)  {

        require(_spender != address(0), "Address can not be 0x0");
        require(balances[msg.sender] >= _amount, "Balance does not have enough tokens");
        require(balances[msg.sender] - locks[msg.sender].amount >= _amount || block.timestamp >= locks[msg.sender].time,"Sender address is locked");
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _from, address _spender) public view returns (uint256) {

        return allowed[_from][_spender];
    }

    function transfer(address _to, uint256 _amount) public  returns (bool) {

        require(_to != address(0), "Receiver can not be 0x0");
        require(balances[msg.sender] >= _amount, "Balance does not have enough tokens");
        require(balances[msg.sender] - locks[msg.sender].amount >= _amount || block.timestamp >= locks[msg.sender].time,"Sender address is locked");
        balances[msg.sender] = (balances[msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount ) public  returns (bool)  {

        require(_to != address(0), "Receiver can not be 0x0");
        require(balances[_from] >= _amount, "Source's balance is not enough");
        require(allowed[_from][msg.sender] >= _amount, "Allowance is not enough");
        require(balances[_from] - locks[_from].amount >= _amount || block.timestamp >= locks[_from].time,"Sender address is locked");
        balances[_from] = (balances[_from]).sub(_amount);
        allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function burn(uint256 _value) public onlyOwner returns (bool) {

        require(balances[msg.sender] >= _value,"Balance does not have enough tokens");
        balances[msg.sender] = (balances[msg.sender]).sub(_value);
        _totalsupply = _totalsupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }
}
