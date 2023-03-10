
pragma solidity ^0.4.24;

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
    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

interface tokenRecipient { function receiveApproval(address from, uint256 value, address token, bytes extraData) external; }


contract TokenERC20 {

    using SafeMath for uint256;

    uint256 public totalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address _owner) view public returns(uint256) {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender) view public returns(uint256) {

        return allowed[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint _value) internal {

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer( _from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns(bool) {

        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool) {

        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
        return false;
    }

    function burn(uint256 _value) public returns(bool) {

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns(bool) {

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_from, _value);
        return true;
    }

    function transferMultiple(address[] _to, uint256[] _value) external returns(bool) {

        require(_to.length == _value.length);
        uint256 i = 0;
        while (i < _to.length) {
           _transfer(msg.sender, _to[i], _value[i]);
           i += 1;
        }
        return true;
    }
}

contract EventSponsorshipToken is TokenERC20 {

    using SafeMath for uint256;

    string public constant name = "EventSponsorshipToken";
    string public constant symbol = "EST";
    uint8 public constant decimals = 18;

    constructor(address _wallet, uint256 _totalSupply) public {
        totalSupply = _totalSupply;
        balances[_wallet] = _totalSupply;
    }

}

contract ESTVault is Ownable {

    using SafeMath for uint256;

    struct vault {
        uint256 amount;
        uint256 unlockTime;
        bool claimed;
    }

    mapping(address => vault[]) public vaults;

    EventSponsorshipToken EST = EventSponsorshipToken(0xD427c628C5f72852965fADAf1231b618c0C82395);

    event Lock(address to, uint256 value, uint256 time);
    event Revoke(address to, uint256 index);
    event Redeem(address to, uint256 index);

    function lock(address to, uint256 value, uint256 time) external {

        _lock(to, value, time);
    }

    function lockMultiple(address[] to, uint256[] value, uint256[] time) external {

        require(to.length == value.length && to.length == time.length);
        for(uint256 i = 0 ; i < to.length ; i++)
            _lock(to[i], value[i], time[i]);
    }

    function revoke(address to, uint256 index) public onlyOwner {

        vault storage v = vaults[to][index];
        require(now >= v.unlockTime);
        require(!v.claimed);
        v.claimed = true;
        require(EST.transfer(msg.sender, v.amount));
        emit Revoke(to, index);
    }

    function _lock(address to, uint256 value, uint256 time) internal {

        require(EST.transferFrom(msg.sender, address(this), value));
        vault memory v;
        v.amount = value;
        v.unlockTime = time;
        vaults[to].push(v);
        emit Lock(to, value, time);
    }

    function redeem(uint256 index) external {

        vault storage v = vaults[msg.sender][index];
        require(now >= v.unlockTime);
        require(!v.claimed);
        v.claimed = true;
        require(EST.transfer(msg.sender, v.amount));
        emit Redeem(msg.sender, index);
    }

}