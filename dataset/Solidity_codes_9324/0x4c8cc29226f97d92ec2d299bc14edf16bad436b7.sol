
pragma solidity 0.5.12;

interface IKToken {

    function underlying() external view returns (address);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address recipient, uint256 amount) external returns (bool);

    function burnFrom(address sender, uint256 amount) external;

    function addMinter(address sender) external;

    function renounceMinter() external;

}

interface ILiquidityPool {

    function () external payable;
    function kToken(address _token) external view returns (IKToken);

    function register(IKToken _kToken) external;

    function renounceOperator() external;

    function deposit(address _token, uint256 _amount) external payable returns (uint256);

    function withdraw(address payable _to, IKToken _kToken, uint256 _kTokenAmount) external;

    function borrowableBalance(address _token) external view returns (uint256);

    function underlyingBalance(address _token, address _owner) external view returns (uint256);

}

interface ILender {

    function () external payable;
    function borrow(address _token, uint256 _amount, bytes calldata _data) external;

}

interface IBorrowerProxy {

    function lend(address _caller, bytes calldata _data) external payable;

}

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract ERC20 is Initializable, Context, IERC20 {

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

    uint256[50] private ______gap;
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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

contract KRoles is Initializable {

    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;
    address[] public operators;

    function initialize(address _operator) public initializer {

        _addOperator(_operator);
    }

    modifier onlyOperator() {

        require(isOperator(msg.sender), "OperatorRole: caller does not have the Operator role");
        _;
    }

    function isOperator(address account) public view returns (bool) {

        return _operators.has(account);
    }

    function addOperator(address account) public onlyOperator {

        _addOperator(account);
    }

    function renounceOperator() public {

        _removeOperator(msg.sender);
    }

    function _addOperator(address account) internal {

        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {

        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}

contract CanReclaimTokens is KRoles {

    using SafeERC20 for ERC20;

    mapping(address => bool) private recoverableTokensBlacklist;

    function initialize(address _nextOwner) public initializer {

        KRoles.initialize(_nextOwner);
    }

    function blacklistRecoverableToken(address _token) public onlyOperator {

        recoverableTokensBlacklist[_token] = true;
    }

    function recoverTokens(address _token) external onlyOperator {

        require(
            !recoverableTokensBlacklist[_token],
            "CanReclaimTokens: token is not recoverable"
        );

        if (_token == address(0x0)) {
           (bool success,) = msg.sender.call.value(address(this).balance)("");
            require(success, "Transfer Failed");
        } else {
            ERC20(_token).safeTransfer(
                msg.sender,
                ERC20(_token).balanceOf(address(this))
            );
        }
    }
}

contract ReentrancyGuard is Initializable {

    uint256 private _guardCounter;

    function initialize() public initializer {

        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}

contract PauserRole is Initializable, Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {

        if (!isPauser(sender)) {
            _addPauser(sender);
        }
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

    uint256[50] private ______gap;
}

contract Pausable is Initializable, Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function initialize(address sender) public initializer {

        PauserRole.initialize(sender);

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

    uint256[50] private ______gap;
}

contract Proxy {

  function () payable external {
    _fallback();
  }

  function _implementation() internal view returns (address);


  function _delegate(address implementation) internal {

    assembly {
      calldatacopy(0, 0, calldatasize)

      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      returndatacopy(0, 0, returndatasize)

      switch result
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  function _willFallback() internal {

  }

  function _fallback() internal {

    _willFallback();
    _delegate(_implementation());
  }
}

library OpenZeppelinUpgradesAddress {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract BaseUpgradeabilityProxy is Proxy {

  event Upgraded(address indexed implementation);

  bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  function _implementation() internal view returns (address impl) {

    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  function _upgradeTo(address newImplementation) internal {

    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  function _setImplementation(address newImplementation) internal {

    require(OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}

contract UpgradeabilityProxy is BaseUpgradeabilityProxy {

  constructor(address _logic, bytes memory _data) public payable {
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}

contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {

  event AdminChanged(address previousAdmin, address newAdmin);


  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  modifier ifAdmin() {

    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  function admin() external ifAdmin returns (address) {

    return _admin();
  }

  function implementation() external ifAdmin returns (address) {

    return _implementation();
  }

  function changeAdmin(address newAdmin) external ifAdmin {

    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  function upgradeTo(address newImplementation) external ifAdmin {

    _upgradeTo(newImplementation);
  }

  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {

    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  function _setAdmin(address newAdmin) internal {

    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  function _willFallback() internal {

    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}

contract InitializableUpgradeabilityProxy is BaseUpgradeabilityProxy {

  function initialize(address _logic, bytes memory _data) public payable {

    require(_implementation() == address(0));
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}

contract InitializableAdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, InitializableUpgradeabilityProxy {

  function initialize(address _logic, address _admin, bytes memory _data) public payable {

    require(_implementation() == address(0));
    InitializableUpgradeabilityProxy.initialize(_logic, _data);
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(_admin);
  }
}

contract LiquidityPoolV2 is ILiquidityPool, CanReclaimTokens, ReentrancyGuard, Pausable {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    mapping (address=>IKToken) public kTokens;
    address[] public registeredTokens;
    mapping (address=>bool) public registeredKTokens;
    string public VERSION;
    IBorrowerProxy borrower;

    uint256 public depositFeeInBips;
    uint256 public poolFeeInBips;
    uint256 public FEE_BASE = 10000;

    address public ETHEREUM = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address payable feePool;

    event Deposited(address indexed _depositor, address indexed _token, uint256 _amount, uint256 _mintAmount);
    event Withdrew(address indexed _reciever, address indexed _withdrawer, address indexed _token, uint256 _amount, uint256 _burnAmount);
    event Borrowed(address indexed _borrower, address indexed _token, uint256 _amount, uint256 _fee);
    event EtherReceived(address indexed _from, uint256 _amount);

    function () external payable {
        emit EtherReceived(_msgSender(), msg.value);
    }

    function initialize(string memory _VERSION, address _borrower) public initializer {

        require(_borrower != address(0), "LiquidityPoolV2: borrower proxy cannot be 0x0");
        CanReclaimTokens.initialize(msg.sender);
        Pausable.initialize(msg.sender);
        ReentrancyGuard.initialize();
        Pausable.initialize(msg.sender);

        VERSION = _VERSION;
        borrower = IBorrowerProxy(_borrower);
    }

    function updateDepositFee(uint256 _depositFeeInBips) external onlyOperator {

        require(_depositFeeInBips >= 0 && _depositFeeInBips <= FEE_BASE, "LiquidityPoolV1: fee should be between 0 and FEE_BASE");
        depositFeeInBips = _depositFeeInBips;
    }

    function updatePoolFee(uint256 _poolFeeInBips) external onlyOperator {

        require(_poolFeeInBips >= 0 && _poolFeeInBips <= FEE_BASE, "LiquidityPoolV1: fee should be between 0 and FEE_BASE");
        poolFeeInBips = _poolFeeInBips;
    }

    function updateFeePool(address payable _newFeePool) external onlyOperator {

        require(_newFeePool != address(0), "LiquidityPoolV2: feepool cannot be 0x0");
        feePool = _newFeePool;        
    }

    function register(IKToken _kToken) external onlyOperator {

        require(address(kTokens[_kToken.underlying()]) == address(0x0), "Underlying asset should not have been registered");
        require(!registeredKTokens[address(_kToken)], "kToken should not have been registered");

        kTokens[_kToken.underlying()] = _kToken;
        registeredKTokens[address(_kToken)] = true;
        registeredTokens.push(address(_kToken.underlying()));
        blacklistRecoverableToken(_kToken.underlying());
    }

    function deposit(address _token, uint256 _amount) external payable nonReentrant whenNotPaused returns (uint256) {

        IKToken kToken = kTokens[_token];
        require(address(kToken) != address(0x0), "Token is not registered");
        require(_amount > 0, "Deposit amount should be greater than 0");
        if (_token != ETHEREUM) {
            require(msg.value == 0, "LiquidityPoolV2: Should not allow ETH deposits during ERC20 token deposits");
            ERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        } else {
            require(_amount == msg.value, "Incorrect eth amount");
        }

        uint256 mintAmount = calculateMintAmount(kToken, _token, _amount);
        kToken.mint(msg.sender, mintAmount);
        emit Deposited(msg.sender, _token, _amount, mintAmount);

        return mintAmount;
    }

    function withdraw(address payable _to, IKToken _kToken, uint256 _kTokenAmount) external nonReentrant whenNotPaused {

        require(registeredKTokens[address(_kToken)], "kToken is not registered");
        require(_kTokenAmount > 0, "Withdraw amount should be greater than 0");
        address token = _kToken.underlying();
        uint256 amount = calculateWithdrawAmount(_kToken, token, _kTokenAmount);
        _kToken.burnFrom(msg.sender, _kTokenAmount);
        if (token != ETHEREUM) {
            ERC20(token).safeTransfer(_to, amount);
        } else {
            (bool success,) = _to.call.value(amount)("");
            require(success, "Transfer Failed");
        }
        emit Withdrew(_to, msg.sender, token, amount, _kTokenAmount);
    }

    function borrow(address _token, uint256 _amount, bytes calldata _data) external nonReentrant whenNotPaused {

        require(address(kTokens[_token]) != address(0x0), "Token is not registered");
        uint256 initialBalance = borrowableBalance(_token);
        if (_token != ETHEREUM) {
            ERC20(_token).safeTransfer(msg.sender, _amount);
        } else {
            (bool success,) = msg.sender.call.value(_amount)("");
            require(success, "LiquidityPoolV1: failed to send funds to the borrower");
        }
        borrower.lend(msg.sender, _data);
        uint256 finalBalance = borrowableBalance(_token);
        require(finalBalance >= initialBalance, "Borrower failed to return the borrowed funds");

        uint256 fee = finalBalance.sub(initialBalance);
        uint256 poolFee = calculateFee(poolFeeInBips, fee);
        emit Borrowed(msg.sender, _token, _amount, fee.sub(poolFee));
        if (_token != ETHEREUM) {
            ERC20(_token).safeTransfer(feePool, poolFee);
        } else {
            (bool success,) = feePool.call.value(poolFee)("");
            require(success, "LiquidityPoolV1: failed to send funds to the fee pool");
        }
    }

    function borrowableBalance(address _token) public view returns (uint256) {

        if (_token == ETHEREUM) {
            return address(this).balance;
        }
        return ERC20(_token).balanceOf(address(this));
    }

    function underlyingBalance(address _token, address _owner) public view returns (uint256) {

        uint256 kBalance = kTokens[_token].balanceOf(_owner);
        uint256 kSupply = kTokens[_token].totalSupply();
        if (kBalance == 0) {
            return 0;
        }
        return borrowableBalance(_token).mul(kBalance).div(kSupply);
    }

    function migrate(ILiquidityPool _newLP) public onlyOperator {

        for (uint256 i = 0; i < registeredTokens.length; i++) {
            address token = registeredTokens[i];
            kTokens[token].addMinter(address(_newLP));
            kTokens[token].renounceMinter();
            _newLP.register(kTokens[token]);
            if (token != ETHEREUM) {
                ERC20(token).safeTransfer(address(_newLP), borrowableBalance(token));
            } else {
                (bool success,) = address(_newLP).call.value(borrowableBalance(token))("");
                require(success, "Transfer Failed");
            }
        }
        _newLP.renounceOperator();
    }

    function kToken(address _token) external view returns (IKToken) {

        return kTokens[_token];
    }

    function calculateWithdrawAmount(IKToken _kToken, address _token, uint256 _kTokenAmount) internal view returns (uint256) {

        uint256 kTokenSupply = _kToken.totalSupply();
        require(kTokenSupply != 0, "No KTokens to be burnt");
        uint256 initialBalance = borrowableBalance(_token);
        return _kTokenAmount.mul(initialBalance).div(_kToken.totalSupply());
    }

    function calculateMintAmount(IKToken _kToken, address _token, uint256 _depositAmount) internal view returns (uint256) {

        uint256 initialBalance = borrowableBalance(_token).sub(_depositAmount);
        uint256 kTokenSupply = _kToken.totalSupply();
        if (kTokenSupply == 0) {
            return _depositAmount;
        }

        return (applyFee(depositFeeInBips, _depositAmount).mul(kTokenSupply))
            .div(initialBalance.add(
                calculateFee(depositFeeInBips, _depositAmount)
            ));
    }

    function applyFee(uint256 _feeInBips, uint256 _amount) internal view returns (uint256) {

        return _amount.mul(FEE_BASE.sub(_feeInBips)).div(FEE_BASE); 
    }

    function calculateFee(uint256 _feeInBips, uint256 _amount) internal view returns (uint256) {

        return _amount.mul(_feeInBips).div(FEE_BASE); 
    }
}