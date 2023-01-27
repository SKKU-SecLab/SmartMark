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
}pragma solidity ^0.4.24;

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
}pragma solidity ^0.4.24;


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
}pragma solidity ^0.4.24;

library Roles {

  struct Role {
    mapping (address => bool) bearer;
  }

  function add(Role storage role, address account) internal {

    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  function remove(Role storage role, address account) internal {

    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {

    require(account != address(0));
    return role.bearer[account];
  }
}pragma solidity ^0.4.24;


contract PauserRole {

  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {

    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {

    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {

    _addPauser(account);
  }

  function renouncePauser() public {

    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {

    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {

    pausers.remove(account);
    emit PauserRemoved(account);
  }
}pragma solidity ^0.4.24;


contract Pausable is PauserRole {

  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  function paused() public view returns(bool) {

    return _paused;
  }

  modifier whenNotPaused() {

    require(!_paused);
    _;
  }

  modifier whenPaused() {

    require(_paused);
    _;
  }

  function pause() public onlyPauser whenNotPaused {

    _paused = true;
    emit Paused(msg.sender);
  }

  function unpause() public onlyPauser whenPaused {

    _paused = false;
    emit Unpaused(msg.sender);
  }
}pragma solidity ^0.4.24;


contract ERC20Pausable is ERC20, Pausable {


  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {

    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {

    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {

    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {

    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {

    return super.decreaseAllowance(spender, subtractedValue);
  }
}pragma solidity ^0.4.24;

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
}pragma solidity ^0.4.24;


contract ERC20PreMint is ERC20, ERC20Pausable {


    bool private _minted;

    constructor() internal {
        _minted = false;
        pause();
    }

    function minted() public view returns(bool) {

        return _minted;
    }

    modifier whenNotMinted() {

        require(!_minted);
        _;
    }

    function mint(address account, uint256 value) public onlyPauser whenNotMinted {

        _mint(account, value);
    }

    function unpause() public onlyPauser whenPaused {

        _minted = true;
        super.unpause();
    }
}pragma solidity ^0.4.24;


contract BalanceCopier is Ownable {

    ERC20Pausable public oldToken;
    ERC20PreMint public newToken;

    mapping (address => bool) internal copied;
    mapping (address => bool) public excluded;

    constructor(ERC20Pausable _oldToken, ERC20PreMint _newToken, address[] _exclude) public {
        oldToken = _oldToken;
        newToken = _newToken;

        excluded[address(_oldToken)] = true;

        for (uint i=0; i < _exclude.length; i++) {
            excluded[_exclude[i]] = true;
        }
    }

    modifier whenBothPaused() {

        require(oldToken.paused(), "Old ERC20 contract is not paused");
        require(!newToken.minted(), "New ERC20 token is already pre-minted");
        _;
    }

    function copy(address _holder) external whenBothPaused {

        require(!excluded[_holder], 'Address is excluded');
        require(!copied[_holder], 'Already copied balance of this holder');

        uint256 balance = oldToken.balanceOf(_holder);
        require(balance > 0, 'Zero balance');

        _mint(_holder, balance);
    }

    function copyAll(address[] _holders) external whenBothPaused {

        uint length = _holders.length;

        for (uint i=0; i < length; i++) if (!copied[_holders[i]] && !excluded[_holders[i]]) {
            address holder = _holders[i];
            uint256 balance = oldToken.balanceOf(holder);

            if (balance != 0) {
                _mint(holder, balance);
            }
        }
    }

    function done() external onlyOwner {

        newToken.unpause();
        newToken.renouncePauser();
    }

    function _mint(address _holder, uint256 _balance) internal {

        newToken.mint(_holder, _balance);
        copied[_holder] = true;
    }
}