
pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity 0.7.6;

library Roles
{

  struct Role
  {
    mapping(address => bool) bearer;
  }

  function add(Role storage role, address account) internal
  {

    require(!has(role, account), "has role");
    role.bearer[account] = true;
  }

  function remove(Role storage role, address account) internal
  {

    require(has(role, account), "!has role");
    role.bearer[account] = false;
  }

  function has(Role storage role, address account) internal view returns (bool)
  {

    require(account != address(0), "Roles: 0 addy");

    return role.bearer[account];
  }
}// MIT
pragma solidity 0.7.6;



contract DiscounterRole
{

  using Roles for Roles.Role;

  Roles.Role private _discounters;

  event DiscounterAdded(address indexed account);
  event DiscounterRemoved(address indexed account);

  modifier onlyDiscounter()
  {

    require(isDiscounter(msg.sender), "!discounter");
    _;
  }

  constructor()
  {
    _discounters.add(msg.sender);

    emit DiscounterAdded(msg.sender);
  }

  function isDiscounter(address account) public view returns (bool)
  {

    return _discounters.has(account);
  }

  function addDiscounter(address account) public onlyDiscounter
  {

    _discounters.add(account);

    emit DiscounterAdded(account);
  }

  function renounceDiscounter() public
  {

    _discounters.remove(msg.sender);

    emit DiscounterRemoved(msg.sender);
  }
}// MIT
pragma solidity 0.7.6;


interface IYLD
{

  function renounceMinter() external;


  function mint(address account, uint256 amount) external returns (bool);

}// MIT
pragma solidity 0.7.6;




interface IDiscountManager
{

  event Enroll(address indexed account, uint256 amount);
  event Exit(address indexed account);


  function isDiscounted(address account) external view returns (bool);


  function updateUnlockTime(address lender, address borrower, uint256 duration) external;

}


contract DiscountManager is IDiscountManager, DiscounterRole, ReentrancyGuard
{

  using SafeMath for uint256;


  address private immutable _YLD;

  uint256 private _requiredAmount = 50 * 1e18; // 50 YLD
  bool private _discountsActivated = true;

  mapping(address => uint256) private _balanceOf;
  mapping(address => uint256) private _unlockTimeOf;


  constructor()
  {
    _YLD = address(0xDcB01cc464238396E213a6fDd933E36796eAfF9f);
  }

  function requiredAmount () public view returns (uint256)
  {
    return _requiredAmount;
  }

  function discountsActivated () public view returns (bool)
  {
    return _discountsActivated;
  }

  function balanceOf (address account) public view returns (uint256)
  {
    return _balanceOf[account];
  }

  function unlockTimeOf (address account) public view returns (uint256)
  {
    return _unlockTimeOf[account];
  }

  function isDiscounted(address account) public view override returns (bool)
  {

    return _discountsActivated ? _balanceOf[account] >= _requiredAmount : false;
  }


  function enroll() external nonReentrant
  {

    require(_discountsActivated, "Discounts off");
    require(!isDiscounted(msg.sender), "In");

    require(IERC20(_YLD).transferFrom(msg.sender, address(this), _requiredAmount));

    _balanceOf[msg.sender] = _requiredAmount;
    _unlockTimeOf[msg.sender] = block.timestamp.add(4 weeks);

    emit Enroll(msg.sender, _requiredAmount);
  }

  function exit() external nonReentrant
  {

    require(_balanceOf[msg.sender] >= _requiredAmount, "!in");
    require(block.timestamp > _unlockTimeOf[msg.sender], "Discounting");

    require(IERC20(_YLD).transfer(msg.sender, _balanceOf[msg.sender]));

    _balanceOf[msg.sender] = 0;
    _unlockTimeOf[msg.sender] = 0;

    emit Exit(msg.sender);
  }


  function updateUnlockTime(address lender, address borrower, uint256 duration) external override onlyDiscounter
  {

    uint256 lenderUnlockTime = _unlockTimeOf[lender];
    uint256 borrowerUnlockTime = _unlockTimeOf[borrower];

    if (isDiscounted(lender))
    {
      _unlockTimeOf[lender] = (block.timestamp >= lenderUnlockTime || lenderUnlockTime.sub(block.timestamp) < duration) ? lenderUnlockTime.add(duration.add(4 weeks)) : lenderUnlockTime;
    }
    else if (isDiscounted(borrower))
    {
      _unlockTimeOf[borrower] = (block.timestamp >= borrowerUnlockTime || borrowerUnlockTime.sub(block.timestamp) < duration) ? borrowerUnlockTime.add(duration.add(4 weeks)) : borrowerUnlockTime;
    }
  }

  function activateDiscounts() external onlyDiscounter
  {

    require(!_discountsActivated, "Activated");

    _discountsActivated = true;
  }

  function deactivateDiscounts() external onlyDiscounter
  {

    require(_discountsActivated, "Deactivated");

    _discountsActivated = false;
  }

  function setRequiredAmount(uint256 newAmount) external onlyDiscounter
  {

    require(newAmount > (0.75 * 1e18) && newAmount < type(uint256).max, "Invalid val");

    _requiredAmount = newAmount;
  }
}