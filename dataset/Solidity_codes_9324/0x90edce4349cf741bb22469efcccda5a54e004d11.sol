


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity >=0.6.8;



interface OMGInterface {

  function totalSupply() external view returns (uint);

  function balanceOf(address tokenOwner) external view returns (uint balance);

  function allowance(address tokenOwner, address spender) external view returns (uint remaining);

  function transfer(address to, uint tokens) external;

  function approve(address spender, uint tokens) external;

  function transferFrom(address from, address to, uint tokens) external;


  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract WOMG is IERC20 {

    using SafeMath for uint256;

    uint256 constant private MAX_UINT256 = type(uint256).max;
    string constant public name = "Wrapped OMG Network";
    string constant public symbol = "WOMG";
    uint8 constant public decimals = 18;

    event  Deposit(address indexed _tokenHolder, uint256 _amount);
    event  Withdrawal(address indexed _tokenHolder, uint _amount);

    mapping (address => uint256) override public balanceOf;
    mapping (address => mapping (address => uint256)) override public allowance;

    OMGInterface public omg;

    constructor (address _omg) public {
        omg = OMGInterface(_omg);
    }

    function deposit(uint256 _amount) public {

        omg.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public {

        require(balanceOf[msg.sender] >= _amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        omg.transfer(msg.sender, _amount);
        emit Withdrawal(msg.sender, _amount);
    }

    function totalSupply() public override view returns (uint256) {

        return omg.balanceOf(address(this));
    }

    function approve(address _spender, uint256 _amount) public override returns (bool) {

        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _to, uint256 _amount) public override returns (bool) {

        return transferFrom(msg.sender, _to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public override returns (bool)
    {

        require(balanceOf[_from] >= _amount);

        if (_from != msg.sender && allowance[_from][msg.sender] < MAX_UINT256) {
            require(allowance[_from][msg.sender] >= _amount);
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_amount);
        }

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        emit Transfer(_from, _to, _amount);

        return true;
    }
}