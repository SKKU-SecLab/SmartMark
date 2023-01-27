
pragma solidity ^0.4.24;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


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

pragma solidity ^0.4.24;

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

pragma solidity ^0.4.24;




library SafeERC20 {


  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {

    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {

    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {

    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {

    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {

    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

pragma solidity ^0.4.24;




contract ERC20 is IERC20 {

  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  function totalSupply() public view returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];
  }

  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {

    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool) {

    _transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {

    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {

    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {

    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _transfer(address from, address to, uint256 value) internal {

    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  function _mint(address account, uint256 value) internal {

    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  function _burn(address account, uint256 value) internal {

    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  function _burnFrom(address account, uint256 value) internal {

    require(value <= _allowed[account][msg.sender]);

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

pragma solidity ^0.4.24;

contract Ownable {

  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
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

  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

pragma solidity ^0.4.21;






contract RKRToken is ERC20, Ownable {

    using SafeMath for uint256;
    
    string public constant name = "RKRToken";
    string public constant symbol = "RKR";
    uint8 public constant decimals = 18;
    uint256 public constant UNLOCKED_SUPPLY = 36e6 * 1e18;
    uint256 public constant TEAM_SUPPLY = 10e6 * 1e18;
    uint256 public constant ADVISOR_SUPPLY = 10e6 * 1e18;
    uint256 public constant RESERVED_SUPPLY = 44e6 * 1e18;
    bool public ADVISOR_SUPPLY_INITIALIZED;
    bool public TEAM_SUPPLY_INITIALIZED;
    bool public RESERVED_SUPPLY_INITIALIZED;

    constructor() public {
        _mint(msg.sender, UNLOCKED_SUPPLY);
        ADVISOR_SUPPLY_INITIALIZED = false;
        TEAM_SUPPLY_INITIALIZED = false;
        RESERVED_SUPPLY_INITIALIZED = false;
    }

    function initializeAdvisorVault(address advisorVault) public onlyOwner {

        require(ADVISOR_SUPPLY_INITIALIZED == false);
        ADVISOR_SUPPLY_INITIALIZED = true;
        _mint(advisorVault, ADVISOR_SUPPLY);
    }

    function initializeTeamVault(address teamVault) public onlyOwner {

        require(TEAM_SUPPLY_INITIALIZED == false);
        TEAM_SUPPLY_INITIALIZED = true;
        _mint(teamVault, TEAM_SUPPLY);
    }

    function initializeReservedVault(address reservedVault) public onlyOwner {

        require(RESERVED_SUPPLY_INITIALIZED == false);
        RESERVED_SUPPLY_INITIALIZED = true;
        _mint(reservedVault, RESERVED_SUPPLY);
    }

}




pragma solidity ^0.4.21;






contract TeamVault {

    using SafeMath for uint256;
    using SafeERC20 for RKRToken;

    mapping(address => uint256) public team_amounts_unreleased;
    mapping(address => uint256) public team_amounts_released;

    RKRToken public token;
    uint256 public start;
    uint256 public offset = 360 days;
    uint256 public released;
    constructor(
        address _token
    )
        public
    {
        token = RKRToken(_token);
        start = block.timestamp;
        team_amounts_unreleased[address(0x365c571424a3Fe44799179d38bc38979f35ec7Bc)] = 1.5e6 * 1e18;
        team_amounts_unreleased[address(0x97F52761320F55d7a6b6030a211948de616FDc10)] = 1.5e6 * 1e18;
        team_amounts_unreleased[address(0x22676C0d8Fa7242C5AFbA6d66060ef4A9113Fa41)] = 1.5e6 * 1e18;
        team_amounts_unreleased[address(0xe105679D4Ad6FB5B50252e532c2D265281486C05)] = 5.5e6 * 1e18;
    }

    function release() public {

        release(msg.sender);
    }

    function release(address receiver) public {

        require(block.timestamp > start.add(offset));
        uint256 unreleased = availableAmount(receiver);
        require(unreleased > 0);
        team_amounts_released[receiver] = unreleased;
        token.safeTransfer(receiver, unreleased);
    }

    function availableAmount(address receiver) public view returns (uint256) {

        uint256 vestedAmount = team_amounts_unreleased[receiver];
        uint256 releasedAmount = team_amounts_released[receiver];
        return vestedAmount.sub(releasedAmount);
    }

    
}