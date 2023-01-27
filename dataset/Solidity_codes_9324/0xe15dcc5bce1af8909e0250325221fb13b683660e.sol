


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.5.0;

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



pragma solidity ^0.5.0;

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



pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}



pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}



pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



pragma solidity ^0.5.0;



contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}



pragma solidity ^0.5.0;



contract Pausable is Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}



pragma solidity ^0.5.0;



contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {

        return super.decreaseAllowance(spender, subtractedValue);
    }
}



pragma solidity >=0.4.21 <0.6.0;




contract ERC20Source is ERC20, ERC20Detailed, ERC20Pausable {

  address[] private _taxpayers;

  constructor
    (string memory name, string memory symbol, uint supply, address[] memory taxpayers)
    public
    ERC20Detailed(name, symbol, uint8(18))
  {
    for (uint i = 0; i < taxpayers.length; i++) {
      _mint(taxpayers[i], supply);
    }

    _taxpayers = taxpayers;
  }

  function taxpayers () external view returns (address[] memory) {
    return _taxpayers;
  }
}



pragma solidity >=0.4.21 <0.6.0;




contract ERC20HardFork is ERC20, ERC20Detailed {

  bool private _airdropped;

  ERC20Source private _source;

  constructor
    (string memory name, string memory symbol, address source)
    public
    ERC20Detailed(name, symbol, uint8(18))
  {
    _source = ERC20Source(source);
    uint supply = _source.totalSupply();
    require(supply > 0, 'ERC20HardFork: source token has no supply');
    _mint(address(this), supply);
  }

  function airdrop () external {
    require(!_airdropped, 'ERC20HardFork: airdrop may only be executed once');
    address[] memory taxpayers = _source.taxpayers();

    for (uint i = 0; i < taxpayers.length; i++) {
      address taxpayer = taxpayers[i];
      _transfer(address(this), taxpayer, _source.balanceOf(taxpayer));
      taxpayer.call.gas(0)("AN AIRDROP HAS TAKEN PLACE FOLLOWING A HARD FORK; REVIEW YOUR TAX OBLIGATIONS AT https://www.irs.gov/pub/irs-drop/rr-19-24.pdf");
    }

    _airdropped = true;
  }
}



pragma solidity >=0.4.21 <0.6.0;



contract EthereumTaxDodgeball {

  struct Offer {
    address seller;
    uint value;
    uint volume;
  }

  mapping (address => Offer) _offers;

  address private _owner;
  uint private _optOutFee;
  mapping (address => bool) private _optOuts;

  event Deployment(address token);
  event HardFork(address token);
  event LiquidityAdded(address token, uint costBasis, uint volume);
  event Airdrop(address token);

  constructor (uint optOutFee) public {
    _owner = msg.sender;
    _optOutFee = optOutFee;
  }

  function deployToken (string calldata name, string calldata symbol, uint supplyPerTaxpayer, address[] calldata taxpayers) external {
    for (uint i = 0; i < taxpayers.length; i++) {
      require(!_optOuts[taxpayers[i]], 'EthereumTaxDodgeball: taxpayer has opted out');
    }
    ERC20Source token = new ERC20Source(name, symbol, supplyPerTaxpayer, taxpayers);
    emit Deployment(address(token));
  }

  function hardFork (string calldata name, string calldata symbol, address sourceToken) external returns (address) {
    ERC20HardFork hardForkToken = new ERC20HardFork(name, symbol, sourceToken);
    ERC20Source(sourceToken).pause();
    emit HardFork(address(hardForkToken));
  }

  function addLiquidity (address hardForkToken, uint volume) external payable {
    require(msg.value > 0, 'EthereumTaxDodgeball: value must be non-zero');
    require(_offers[hardForkToken].seller == address(0), 'EthereumTaxDodgeball: hard fork token must not have liquidity');
    _offers[hardForkToken] = Offer(msg.sender, msg.value, volume);
    emit LiquidityAdded(hardForkToken, msg.value, volume);
  }

  function airdrop (address hardForkToken) external {
    require(_offers[hardForkToken].seller != address(0), 'EthereumTaxDodgeball: hard fork token must have liquidity');
    ERC20HardFork(hardForkToken).airdrop();
    emit Airdrop(hardForkToken);
  }

  function removeLiquidity (address hardForkToken) external {
    Offer storage offer = _offers[hardForkToken];
    require(offer.seller == msg.sender, 'EthereumTaxDodgeball: sender must be offer owner');
    uint value = offer.value;

    delete _offers[hardForkToken];
    msg.sender.call.value(value)("");
  }

  function takeLiquidity (address hardForkToken) external {
    Offer storage offer = _offers[hardForkToken];
    require(offer.seller != address(0), 'EthereumTaxDodgeball: offer must exist');
    ERC20HardFork token = ERC20HardFork(hardForkToken);
    require(token.allowance(msg.sender, address(this)) >= offer.volume, 'EthereumTaxDodgeball: taxpayer must grant sufficient token allowance to contract');
    token.transferFrom(msg.sender, offer.seller, offer.volume);
    uint value = offer.value;

    delete _offers[hardForkToken];
    msg.sender.call.value(value)("");
  }

  function optOut () external payable {
    require(msg.value >= _optOutFee, 'EthereumTaxDodgeball: taxpayer must pay opt-out fee');
    require(!_optOuts[msg.sender], 'EthereumTaxDodgeball: taxpayer has already opted out');
    _optOuts[msg.sender] = true;
    _owner.call.value(msg.value)("");
  }

  function isOptedOut (address taxpayer) external view returns (bool) {
    return _optOuts[taxpayer];
  }

  function getOptOutFee () external view returns (uint) {
    return _optOutFee;
  }

  function setOptOutFee (uint fee) external {
    require(msg.sender == _owner, 'EthereumTaxDodgeball: sender must be owner');
    _optOutFee = fee;
  }

  function setOwner (address owner) external {
    require(msg.sender == _owner, 'EthereumTaxDodgeball: sender must be owner');
    _owner = owner;
  }
}



pragma solidity >=0.4.21 <0.6.0;

contract Migrations {

  address public owner;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {

    if (msg.sender == owner) _;
  }

  function setCompleted(uint completed) public restricted {

    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {

    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}