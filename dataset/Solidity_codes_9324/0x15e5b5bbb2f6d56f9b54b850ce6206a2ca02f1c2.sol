pragma solidity ^0.5.8;

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
}pragma solidity ^0.5.8;

contract Ownable
{

    string constant public ERROR_NO_HAVE_PERMISSION = 'Reason: No have permission.';
    string constant public ERROR_IS_STOPPED         = 'Reason: Is stopped.';
    string constant public ERROR_ADDRESS_NOT_VALID  = 'Reason: Address is not valid.';

    bool private stopped;
    address private _owner;
    address[] public _allowed;

    event Stopped();
    event Started();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Allowed(address indexed _address);
    event RemoveAllowed(address indexed _address);

    constructor () internal
    {
        stopped = false;
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address)
    {

        return _owner;
    }

    modifier onlyOwner()
    {

        require(isOwner(), ERROR_NO_HAVE_PERMISSION);
        _;
    }

    modifier onlyAllowed()
    {

        require(isAllowed() || isOwner(), ERROR_NO_HAVE_PERMISSION);
        _;
    }

    modifier onlyWhenNotStopped()
    {

        require(!isStopped(), ERROR_IS_STOPPED);
        _;
    }

    function isOwner() public view returns (bool)
    {

        return msg.sender == _owner;
    }

    function isAllowed() public view returns (bool)
    {

        uint256 length = _allowed.length;

        for(uint256 i=0; i<length; i++)
        {
            if(_allowed[i] == msg.sender)
            {
                return true;
            }
        }

        return false;
    }

    function transferOwnership(address newOwner) external onlyOwner
    {

        _transferOwnership(newOwner);
    }

    function allow(address _target) external onlyOwner returns (bool)
    {

        uint256 length = _allowed.length;

        for(uint256 i=0; i<length; i++)
        {
            if(_allowed[i] == _target)
            {
                return true;
            }
        }

        _allowed.push(_target);

        emit Allowed(_target);

        return true;
    }

    function removeAllowed(address _target) external onlyOwner returns (bool)
    {

        uint256 length = _allowed.length;

        for(uint256 i=0; i<length; i++)
        {
            if(_allowed[i] == _target)
            {
                if(i < length - 1)
                {
                    _allowed[i] = _allowed[length-1];
                    delete _allowed[length-1];
                }
                else
                {
                    delete _allowed[i];
                }

                _allowed.length--;

                emit RemoveAllowed(_target);

                return true;
            }
        }

        return true;
    }

    function isStopped() public view returns (bool)
    {

        if(isOwner() || isAllowed())
        {
            return false;
        }
        else
        {
            return stopped;
        }
    }

    function stop() public onlyOwner
    {

        _stop();
    }

    function start() public onlyOwner
    {

        _start();
    }

    function _transferOwnership(address newOwner) internal
    {

        require(newOwner != address(0), ERROR_ADDRESS_NOT_VALID);
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function _stop() internal
    {

        emit Stopped();
        stopped = true;
    }

    function _start() internal
    {

        emit Started();
        stopped = false;
    }
}pragma solidity ^0.5.8;


contract BaseToken is Ownable
{

    using SafeMath for uint256;

    string constant public ERROR_APPROVED_BALANCE_NOT_ENOUGH = 'Reason: Approved balance is not enough.';
    string constant public ERROR_BALANCE_NOT_ENOUGH          = 'Reason: Balance is not enough.';
    string constant public ERROR_LOCKED                      = 'Reason: Locked';
    string constant public ERROR_ADDRESS_NOT_VALID           = 'Reason: Address is not valid.';
    string constant public ERROR_ADDRESS_IS_SAME             = 'Reason: Address is same.';
    string constant public ERROR_VALUE_NOT_VALID             = 'Reason: Value must be greater than 0.';
    string constant public ERROR_NO_LOCKUP                   = 'Reason: There is no lockup.';
    string constant public ERROR_DATE_TIME_NOT_VALID         = 'Reason: Datetime must grater or equals than zero.';

    uint256 constant public E18                  = 1000000000000000000;
    uint256 constant public decimals             = 18;
    uint256 public totalSupply;

    struct Lock {
        uint256 amount;
        uint256 expiresAt;
    }

    mapping (address => uint256) public balances;
    mapping (address => mapping ( address => uint256 )) public approvals;
    mapping (address => Lock[]) public lockup;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Locked(address _who, uint256 _amount, uint256 _time);
    event Unlocked(address _who);
    event Burn(address indexed from, uint256 indexed value);

    constructor() public
    {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _who) view public returns (uint256)
    {

        return balances[_who];
    }

    function lockedBalanceOf(address _who) view public returns (uint256)
    {

        require(_who != address(0), ERROR_ADDRESS_NOT_VALID);

        uint256 lockedBalance = 0;
        if(lockup[_who].length > 0)
        {
            Lock[] storage locks = lockup[_who];

            uint256 length = locks.length;
            for (uint i = 0; i < length; i++)
            {
                if (now < locks[i].expiresAt)
                {
                    lockedBalance = lockedBalance.add(locks[i].amount);
                }
            }
        }

        return lockedBalance;
    }

    function allowance(address _owner, address _spender) view external returns (uint256)
    {

        return approvals[_owner][_spender];
    }

    function isLocked(address _who, uint256 _value) view public returns(bool)
    {

        uint256 lockedBalance = lockedBalanceOf(_who);
        uint256 balance = balanceOf(_who);

        if(lockedBalance <= 0)
        {
            return false;
        }
        else
        {
            return !(balance > lockedBalance && balance.sub(lockedBalance) >= _value);
        }
    }

    function transfer(address _to, uint256 _value) external onlyWhenNotStopped returns (bool)
    {

        require(_to != address(0));
        require(balances[msg.sender] >= _value, ERROR_BALANCE_NOT_ENOUGH);
        require(!isLocked(msg.sender, _value), ERROR_LOCKED);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external onlyWhenNotStopped returns (bool)
    {

        require(_from != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_to != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_value > 0, ERROR_VALUE_NOT_VALID);
        require(balances[_from] >= _value, ERROR_BALANCE_NOT_ENOUGH);
        require(approvals[_from][msg.sender] >= _value, ERROR_APPROVED_BALANCE_NOT_ENOUGH);
        require(!isLocked(_from, _value), ERROR_LOCKED);

        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferWithLock(address _to, uint256 _value, uint256 _time) onlyOwner external returns (bool)
    {

        require(balances[msg.sender] >= _value, ERROR_BALANCE_NOT_ENOUGH);

        lock(_to, _value, _time);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external onlyWhenNotStopped returns (bool)
    {

        require(_spender != address(0), ERROR_VALUE_NOT_VALID);
        require(balances[msg.sender] >= _value, ERROR_BALANCE_NOT_ENOUGH);
        require(msg.sender != _spender, ERROR_ADDRESS_IS_SAME);

        approvals[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function lock(address _who, uint256 _value, uint256 _dateTime) onlyOwner public
    {

        require(_who != address (0), ERROR_VALUE_NOT_VALID);
        require(_value > 0, ERROR_VALUE_NOT_VALID);

        lockup[_who].push(Lock(_value, _dateTime));
        emit Locked(_who, _value, _dateTime);
    }

    function unlock(address _who) onlyOwner external
    {

        require(lockup[_who].length > 0, ERROR_NO_LOCKUP);
        delete lockup[_who];
        emit Unlocked(_who);
    }

    function burn(uint256 _value) external
    {

        require(balances[msg.sender] >= _value, ERROR_BALANCE_NOT_ENOUGH);
        require(_value > 0, ERROR_VALUE_NOT_VALID);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        totalSupply = totalSupply.sub(_value);

        emit Burn(msg.sender, _value);
    }

    function close() onlyOwner public
    {

        selfdestruct(msg.sender);
    }
}pragma solidity ^0.5.8;


contract Nest is BaseToken
{

    using SafeMath for uint256;

    string constant public ERROR_NOT_MANDATED = 'Reason: Not mandated.';

    string constant public name    = 'NEST';
    string constant public symbol  = 'EGG';
    string constant public version = '1.0.0';

    mapping (address => bool) public mandates;

    event TransferByMandate(address indexed from, address indexed to, uint256 value);
    event ReferralDrop(address indexed from, address indexed to1, uint256 value1, address indexed to2, uint256 value2);
    event UpdatedMandate(address indexed from, bool mandate);

    constructor() public
    {
        totalSupply = 3000000000 * E18;
        balances[msg.sender] = totalSupply;
    }

    function transferByMandate(address _from, address _to, uint256 _value, address _sale, uint256 _fee) external onlyWhenNotStopped onlyOwner returns (bool)
    {

        require(_from != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_sale != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_value > 0, ERROR_VALUE_NOT_VALID);
        require(balances[_from] >= _value + _fee, ERROR_BALANCE_NOT_ENOUGH);
        require(mandates[_from], ERROR_NOT_MANDATED);
        require(!isLocked(_from, _value), ERROR_LOCKED);

        balances[_from] = balances[_from].sub(_value + _fee);
        balances[_to]  = balances[_to].add(_value);

        if(_fee > 0)
        {
            balances[_sale] = balances[_sale].add(_fee);
        }

        emit TransferByMandate(_from, _to, _value);
        return true;
    }

    function referralDrop(address _to1, uint256 _value1, address _to2, uint256 _value2, address _sale, uint256 _fee) external onlyWhenNotStopped returns (bool)
    {

        require(_to1 != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_to2 != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_sale != address(0), ERROR_ADDRESS_NOT_VALID);
        require(balances[msg.sender] >= _value1 + _value2 + _fee);
        require(!isLocked(msg.sender, _value1 + _value2 + _fee), ERROR_LOCKED);

        balances[msg.sender] = balances[msg.sender].sub(_value1 + _value2 + _fee);

        if(_value1 > 0)
        {
            balances[_to1] = balances[_to1].add(_value1);
        }

        if(_value2 > 0)
        {
            balances[_to2] = balances[_to2].add(_value2);
        }

        if(_fee > 0)
        {
            balances[_sale] = balances[_sale].add(_fee);
        }

        emit ReferralDrop(msg.sender, _to1, _value1, _to2, _value2);
        return true;
    }

    function updateMandate(bool _value) external onlyWhenNotStopped returns (bool)
    {

        mandates[msg.sender] = _value;
        emit UpdatedMandate(msg.sender, _value);
        return true;
    }
}