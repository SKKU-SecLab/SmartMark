pragma solidity >=0.6.6;

library SafeMathDEOR {

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

  function log_2(uint256 x) internal pure returns (uint256) {

    uint256 idx = 1;
    uint256 res = 0;
    while (x > idx) {
      idx = idx << 1;
      res = add(res, 1);
    }
    return res;
  }
}pragma solidity >=0.6.6;

contract Ownable {

    address public owner;
    address public devAddr = address(0x7e9f1f3F25515F0421D44d23cC98f76bdA1db2D1);
    address public treasury = address(0x92126534bc8448de051FD9Cb8c54C31b82525669);

    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner, address newDev) public onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
        if (newDev != address(0)) {
            devAddr = newDev;
        }
    }

}// pragma solidity >=0.4.21 <0.6.0;
pragma solidity >=0.6.6;

interface IDEOR {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
}pragma solidity >=0.6.6;


contract DEOR is IDEOR, Ownable {


    using SafeMathDEOR for uint256;

    mapping(address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowed;

    string private _name = "DEOR";
    string private _symbol = "DEOR";
    uint256 private _decimals = 10;
    uint256 private _totalSupply;
    uint256 private _maxSupply = 100000000 * (10**_decimals);
    bool public mintingFinished = false;
	uint256 public startTime = 1488294000;

    constructor() public {}

    receive () external payable {
        revert();
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint256) {

        return _decimals;
    }

    function totalSupply() public view virtual override(IDEOR) returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address _owner) external view override(IDEOR) returns (uint256) {

        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value) external override(IDEOR) returns (bool) {

        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override(IDEOR) returns (bool) {

        uint256 _allowance = _allowed[_from][msg.sender];

        _allowed[_from][msg.sender] = _allowance.sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        _balances[_from] = _balances[_from].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external override(IDEOR) returns (bool) {

        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override(IDEOR) returns (uint256) {

        return _allowed[_owner][_spender];
    }


    modifier canMint() {

        require(!mintingFinished);
        _;
    }

    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {

        uint256 amount = _maxSupply.sub(_totalSupply);
        if (amount > _amount) {
            amount = _amount;
        }
        else {
            mintingFinished = true;
            emit MintFinished();
        }
        _totalSupply = _totalSupply.add(amount);
        _balances[_to] = _balances[_to].add(amount);
        emit Mint(_to, _amount);
        return true;
    }

    function finishMinting() public onlyOwner returns (bool) {

        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}