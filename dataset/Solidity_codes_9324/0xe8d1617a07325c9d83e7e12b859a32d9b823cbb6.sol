pragma solidity 0.4.24;


contract ERC20 {

    function totalSupply() public view returns (uint256);


    function balanceOf(address _who) public view returns (uint256);


    function allowance(address _owner, address _spender)
    public view returns (uint256);


    function transfer(address _to, uint256 _value) public returns (bool);


    function approve(address _spender, uint256 _value)
    public returns (bool);


    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


library SafeMath {


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


contract StandardToken is ERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowed;

    uint256 private totalSupply_;

    function totalSupply() public view returns (uint256) {

        return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {

        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {

        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns (bool)
    {

        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns (bool)
    {

        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function _mint(address _account, uint256 _amount) internal {

        require(_account != 0);
        totalSupply_ = totalSupply_.add(_amount);
        balances[_account] = balances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal {

        require(_account != 0);
        require(_amount <= balances[_account]);

        totalSupply_ = totalSupply_.sub(_amount);
        balances[_account] = balances[_account].sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }

    function _burnFrom(address _account, uint256 _amount) internal {

        require(_amount <= allowed[_account][msg.sender]);

        allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);
        _burn(_account, _amount);
    }
}


contract BurnableToken is StandardToken {


    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        _burn(msg.sender, _value);
    }

    function burnFrom(address _from, uint256 _value) public {

        _burnFrom(_from, _value);
    }

    function _burn(address _who, uint256 _value) internal {

        super._burn(_who, _value);
        emit Burn(_who, _value);
    }
}


contract Ownable {

    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


contract HasNoEther is Ownable {


    constructor() public payable {
        require(msg.value == 0);
    }

    function() external {
    }

    function reclaimEther() external onlyOwner {

        owner.transfer(address(this).balance);
    }
}


library SafeERC20 {

    function safeTransfer(
        ERC20 _token,
        address _to,
        uint256 _value
    )
    internal
    {

        require(_token.transfer(_to, _value));
    }

    function safeTransferFrom(
        ERC20 _token,
        address _from,
        address _to,
        uint256 _value
    )
    internal
    {

        require(_token.transferFrom(_from, _to, _value));
    }

    function safeApprove(
        ERC20 _token,
        address _spender,
        uint256 _value
    )
    internal
    {

        require(_token.approve(_spender, _value));
    }
}


contract CanReclaimToken is Ownable {

    using SafeERC20 for ERC20;

    function reclaimToken(ERC20 _token) external onlyOwner {

        uint256 balance = _token.balanceOf(this);
        _token.safeTransfer(owner, balance);
    }

}


contract HasNoTokens is CanReclaimToken {


    function tokenFallback(
        address _from,
        uint256 _value,
        bytes _data
    )
    external
    pure
    {

        _from;
        _value;
        _data;
        revert();
    }

}


contract HasNoContracts is Ownable {


    function reclaimContract(address _contractAddr) external onlyOwner {

        Ownable contractInst = Ownable(_contractAddr);
        contractInst.transferOwnership(owner);
    }
}


contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {

}


contract ClarityToken is StandardToken, BurnableToken, NoOwner {

    string public constant name = "Clarity Token"; // solium-disable-line uppercase
    string public constant symbol = "CLRTY"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase

    uint256 public constant INITIAL_SUPPLY = 240000000 * (10 ** uint256(decimals));

    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}pragma solidity 0.4.24;


contract UserPaymentAccount {


    ClarityToken clarityToken;
    address controller;
    address paymentTarget;
    bool isLockedTransactions;
    bool isLockedReplenish;

    mapping(string => uint256) balances;
    mapping(address => bool) public isOwner;
    mapping(address => bool) public isOperator;

    constructor(address _controller, address _clarityToken, address _paymentTarget, address _owner) public {
        clarityToken = ClarityToken(_clarityToken);
        controller = _controller;
        isOwner[_owner] = true;
        paymentTarget = _paymentTarget;
    }

    modifier notNull(address _address) {

        require(_address != 0);
        _;
    }

    function balanceOf(string _userId) public view returns (uint256 _balance) {

        _balance = balances[_userId];
    }

    function replenish(string _toUserId, uint256 _amount) public returns (bool) {

        require(!isLockedReplenish);
        require(clarityToken.transferFrom(msg.sender, address(this), _amount));
        balances[_toUserId] += _amount;
        return true;
    }

    function move(string _fromUserId, string _toUserId, uint256 _amount) public returns (bool) {

        require((msg.sender == controller && !isLockedTransactions) || isOwner[msg.sender]);
        return _move(_fromUserId, _toUserId, _amount);
    }

    function _move(string _fromUserId, string _toUserId, uint256 _amount) internal returns (bool) {

        require(balances[_fromUserId] >= _amount);
        balances[_fromUserId] -= _amount;
        balances[_toUserId] += _amount;
        return true;
    }

    function pay(string _fromUserId, uint256 _amount) public returns (bool) {

        require((msg.sender == controller && !isLockedTransactions) || isOwner[msg.sender]);
        require(balances[_fromUserId] >= _amount);
        require(clarityToken.transfer(paymentTarget, _amount));
        balances[_fromUserId] -= _amount;
        return true;
    }

    function takeAllTokens() public returns (bool) {

        require(isOwner[msg.sender]);
        require(clarityToken.transfer(paymentTarget, clarityToken.balanceOf(address(this))));
        isLockedReplenish = true;
        isLockedTransactions = true;
        return true;
    }

    function addOwner(address _owner) public notNull(_owner) returns (bool) {

        require(isOwner[msg.sender]);
        isOwner[_owner] = true;
        return true;
    }

    function removeOwner(address _owner) public notNull(_owner) returns (bool) {

        require(msg.sender != _owner && isOwner[msg.sender]);
        isOwner[_owner] = false;
        return true;
    }

    function lockTransactions() public returns (bool) {

        require(isOwner[msg.sender] || isOperator[msg.sender]);
        isLockedTransactions = true;
        return true;
    }

    function unlockTransactions() public returns (bool) {

        require(isOwner[msg.sender] || isOperator[msg.sender]);
        isLockedTransactions = false;
        return true;
    }

    function lockReplenish() public returns (bool) {

        require(isOwner[msg.sender]);
        isLockedReplenish = true;
        return true;
    }

    function unlockReplenish() public returns (bool) {

        require(isOwner[msg.sender]);
        isLockedReplenish = false;
        return true;
    }

    function addOperator(address _operator) public notNull(_operator) returns (bool) {

        require(isOwner[msg.sender]);
        isOperator[_operator] = true;
        return true;
    }

    function removeOperator(address _operator) public notNull(_operator) returns (bool) {

        require(isOwner[msg.sender]);
        isOperator[_operator] = false;
        return true;
    }

    function setController(address _controller) public notNull(_controller) returns (bool) {

        require(isOwner[msg.sender]);
        controller = _controller;
        return true;
    }

    function setPaymentTarget(address _paymentTarget) public notNull(_paymentTarget) returns (bool) {

        require(isOwner[msg.sender]);
        paymentTarget = _paymentTarget;
        return true;
    }

}
