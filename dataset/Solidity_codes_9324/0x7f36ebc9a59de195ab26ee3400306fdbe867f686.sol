

pragma solidity ^ 0.7.0;


abstract contract ERC20 {
    function totalSupply() public view virtual returns(uint256);
    function balanceOf(address _who) public view virtual returns(uint256);
    function allowance(address _owner, address _spender) public view virtual returns(uint256);
    function transfer(address _to, uint256 _value) public virtual returns(bool);
    function approve(address _spender, uint256 _value) public virtual returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {

        if(_a == 0)
        {
            return 0;
        }    

        uint256 c = _a * _b;
        require(c / _a == _b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {

        uint256 c = _a / _b;
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {

        require(_b <= _a, "SafeMath: subtraction overflow");
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {

        uint256 c = _a + _b;
        require(c >= _a, "SafeMath: addition overflow");

        return c;
    }
}


contract Ownable {

    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


contract Blacklisted is Ownable {

    mapping(address => bool) public blacklist;

    event SetBlacklist(address indexed _address, bool _bool);

    modifier notInBlacklist(address _address) {

        require(blacklist[_address] == false, "Blacklisted: address is in blakclist");
        _;
    }

    function setBlacklist(address _address, bool _bool) public onlyOwner {

        require(_address != address(0), "Blacklisted: address is the zero address");

        blacklist[_address] = _bool;
        emit SetBlacklist(_address, _bool);
    }

    function setBlacklistBulk(address[] calldata _addresses, bool _bool) public onlyOwner {

        require(_addresses.length != 0, "Blacklisted: the length of addresses is zero");

        for (uint256 i = 0; i < _addresses.length; i++)
        {
            setBlacklist(_addresses[i], _bool);
        }
    }
}

contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused, "Pausable: the contract is paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "Pausable, the contract is not paused");
        _;
    }

    function pause() public onlyOwner whenNotPaused {

        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {

        paused = false;
        emit Unpause();
    }
}


contract StandardToken is ERC20, Pausable, Blacklisted {

    using SafeMath for uint256;

        mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 totalSupply_;

    function totalSupply() public view override returns(uint256) {

        return totalSupply_;
    }

    function balanceOf(address _owner) public view override returns(uint256) {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view override returns(uint256) {

        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) whenNotPaused notInBlacklist(msg.sender) notInBlacklist(_to) public override returns(bool) {

        require(_to != address(0), "ERC20: transfer to the zero address");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused notInBlacklist(msg.sender) notInBlacklist(_from) notInBlacklist(_to) public override returns(bool) {

        require(_to != address(0), "ERC20: transfer to the zero address");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) whenNotPaused public override returns(bool) {

        require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function increaseApproval(address _spender, uint256 _addedValue) whenNotPaused public returns(bool) {

        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) whenNotPaused public returns(bool) {

        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}


contract BurnableToken is StandardToken {

    using SafeMath for uint256;

        event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) whenNotPaused public {

        _burn(msg.sender, _value);
    }

    function burnFrom(address _from, uint256 _value) whenNotPaused public {


        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _burn(_from, _value);
    }

    function _burn(address _who, uint256 _value) internal {


        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);

        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
}


contract MintableToken is StandardToken {

    using SafeMath for uint256;

        event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {

        require(!mintingFinished, "ERC20: mint is finished");
        _;
    }

    function _mint(address _to, uint256 _value) internal {

        require(_to != address(0), "ERC20: mint to the zero address");

        totalSupply_ = totalSupply_.add(_value);
        balances[_to] = balances[_to].add(_value);

        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
    }

    function mint(address _to, uint256 _value) onlyOwner canMint public returns(bool) {

        _mint(_to, _value);

        return true;
    }

    function finishMinting() onlyOwner canMint public returns(bool) {

        mintingFinished = true;
        MintFinished();
        return true;
    }
}



contract BixinTestToken is BurnableToken, MintableToken {

    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initalSupply, address _owner)  {
        require(_owner != address(0), "Main: contract owner is the zero address");
        require(_decimals != 0, "Main: decimals is zero");

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = _owner;

        _mint(_owner, _initalSupply * (10 ** uint256(decimals)));
    }
}