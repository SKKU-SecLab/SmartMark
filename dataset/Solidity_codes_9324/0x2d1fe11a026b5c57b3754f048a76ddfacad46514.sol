
pragma solidity ^0.4.24;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }


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

        require(b > 0); // Solidity only automatically asserts when dividing by 0
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

library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a)
        internal
        pure
        returns (int256)
    {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

contract GeneralToken {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    address private _owner;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 8;

    bool public rebasePaused;
    bool public tokenPaused;

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private _initalSupply;

    uint256 private _totalGons;

    uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 1

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    mapping (address => mapping (address => uint256)) private _allowedFragments;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event LogRebase(uint256 totalSupply);
    event LogRebasePaused(bool paused);
    event LogTokenPaused(bool paused);

    modifier whenRebaseNotPaused() {

        require(!rebasePaused);
        _;
    }

    modifier whenTokenNotPaused() {

        require(!tokenPaused);
        _;
    }

    modifier validRecipient(address to) {

        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function owner() public view returns(address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns(bool) {

        return msg.sender == _owner;
    }

    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        _owner = msg.sender;

        _name = tokenName;
        _symbol = tokenSymbol;

        _initalSupply = initialSupply * 10 ** uint256(_decimals);
        _totalGons = MAX_UINT256 - (MAX_UINT256 % _initalSupply);

        rebasePaused = false;
        tokenPaused = false;

        _totalSupply = _initalSupply;
        _gonBalances[_owner] = _totalGons;
        _gonsPerFragment = _totalGons.div(_totalSupply);

        emit Transfer(address(0x0), _owner, _totalSupply);
    }

    function rebase(uint256 supplyDelta)
        external
        onlyOwner
        whenRebaseNotPaused
        returns (uint256)
    {

        if (supplyDelta == 0) {
            emit LogRebase(_totalSupply);
            return _totalSupply;
        }

        _totalSupply = supplyDelta * 10 ** uint256(_decimals);

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = _totalGons.div(_totalSupply);

        emit LogRebase(_totalSupply);
        return _totalSupply;
    }

    function setRebasePaused(bool paused)
        external
        onlyOwner
    {

        rebasePaused = paused;
        emit LogRebasePaused(paused);
    }

    function setTokenPaused(bool paused)
        external
        onlyOwner
    {

        tokenPaused = paused;
        emit LogTokenPaused(paused);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(address who)
        public
        view
        returns (uint256)
    {

        return _gonBalances[who].div(_gonsPerFragment);
    }

    function name() public view returns(string) {

        return _name;
    }

    function symbol() public view returns(string) {

        return _symbol;
    }

    function decimals() public view returns(uint8) {

        return _decimals;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {


        uint256 gonValue = _value.mul(_gonsPerFragment);
        require(_gonBalances[_from] >= gonValue);
        require(_gonBalances[_to].add(gonValue) >= _gonBalances[_to]);

        uint256 previousBalances = _gonBalances[_from].add(_gonBalances[_to]);
        _gonBalances[_from] = _gonBalances[_from].sub(gonValue);
        _gonBalances[_to] = _gonBalances[_to].add(gonValue);

        emit Transfer(_from, _to, _value);
        assert(_gonBalances[_from].add(_gonBalances[_to]) == previousBalances);
    }

    function transfer(address _to, uint256 _value) public validRecipient(_to) whenTokenNotPaused returns (bool) {

        _transfer(msg.sender, _to, _value);
        return true;
    }

    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {

        return _allowedFragments[owner_][spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public validRecipient(_to) whenTokenNotPaused returns (bool) {

        require(_value <= _allowedFragments[_from][msg.sender]);     // Check allowance

        _allowedFragments[_from][msg.sender] = _allowedFragments[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public whenTokenNotPaused returns (bool) {

        require(_spender != address(0));

        _allowedFragments[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        whenTokenNotPaused
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        whenTokenNotPaused
        returns (bool)
    {

        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        whenTokenNotPaused
        returns (bool) {

        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
}