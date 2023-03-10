
pragma solidity 0.4.24;


contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

}


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract StandardToken is ERC20 {

    using SafeMath for uint256;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balanceOf;
    mapping (address => mapping (address => uint256)) internal _allowance;

    modifier onlyValidAddress(address addr) {

        require(addr != address(0), "Address cannot be zero");
        _;
    }

    modifier onlySufficientBalance(address from, uint256 value) {

        require(value <= _balanceOf[from], "Insufficient balance");
        _;
    }

    modifier onlySufficientAllowance(address owner, address spender, uint256 value) {

        require(value <= _allowance[owner][spender], "Insufficient allowance");
        _;
    }

    function transfer(address to, uint256 value)
        public
        onlyValidAddress(to)
        onlySufficientBalance(msg.sender, value)
        returns (bool)
    {

        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(value);
        _balanceOf[to] = _balanceOf[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        public
        onlyValidAddress(to)
        onlySufficientBalance(from, value)
        onlySufficientAllowance(from, msg.sender, value)
        returns (bool)
    {

        _balanceOf[from] = _balanceOf[from].sub(value);
        _balanceOf[to] = _balanceOf[to].add(value);
        _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value)
        public
        onlyValidAddress(spender)
        returns (bool)
    {

        _allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        onlyValidAddress(spender)
        returns (bool)
    {

        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        onlyValidAddress(spender)
        onlySufficientAllowance(msg.sender, spender, subtractedValue)
        returns (bool)
    {

        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);

        return true;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balanceOf[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowance[owner][spender];
    }
}


contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner, "Can only be called by the owner");
        _;
    }

    modifier onlyValidAddress(address addr) {

        require(addr != address(0), "Address cannot be zero");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
        onlyValidAddress(newOwner)
    {

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;
    }
}


contract MintableToken is StandardToken, Ownable {

    bool public mintingFinished;
    uint256 public cap;

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    modifier onlyMinting() {

        require(!mintingFinished, "Minting is already finished");
        _;
    }

    modifier onlyNotExceedingCap(uint256 amount) {

        require(_totalSupply.add(amount) <= cap, "Total supply must not exceed cap");
        _;
    }

    constructor(uint256 _cap) public {
        cap = _cap;
    }

    function mint(address to, uint256 amount)
        public
        onlyOwner
        onlyMinting
        onlyValidAddress(to)
        onlyNotExceedingCap(amount)
        returns (bool)
    {

        mintImpl(to, amount);

        return true;
    }

    function mintMany(address[] addresses, uint256[] amounts)
        public
        onlyOwner
        onlyMinting
        onlyNotExceedingCap(sum(amounts))
        returns (bool)
    {

        require(
            addresses.length == amounts.length,
            "Addresses array must be the same size as amounts array"
        );

        for (uint256 i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "Address cannot be zero");
            mintImpl(addresses[i], amounts[i]);
        }

        return true;
    }

    function finishMinting()
        public
        onlyOwner
        onlyMinting
        returns (bool)
    {

        mintingFinished = true;

        emit MintFinished();

        return true;
    }

    function mintImpl(address to, uint256 amount) private {

        _totalSupply = _totalSupply.add(amount);
        _balanceOf[to] = _balanceOf[to].add(amount);

        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    function sum(uint256[] arr) private pure returns (uint256) {

        uint256 aggr = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            aggr = aggr.add(arr[i]);
        }
        return aggr;
    }
}


contract PhotochainToken is MintableToken {

    string public name = "PhotochainToken";
    string public symbol = "PHT";
    uint256 public decimals = 18;
    uint256 public cap = 120 * 10**6 * 10**decimals;

    constructor() public MintableToken(cap) {}
}