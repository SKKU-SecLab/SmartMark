pragma solidity ^0.7.1;

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
}// MIT
pragma solidity ^0.7.1;

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
pragma solidity ^0.7.1;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}// MIT
pragma solidity ^0.7.1;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity >=0.4.24 <0.8.0;

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
}// MIT
pragma solidity ^0.7.1;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT
pragma solidity ^0.7.1;

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.1;

contract LockUpPool is Initializable, OwnableUpgradeSafe {

  using Address for address;
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint8 public PENALTY_RATE;
  uint8 public PLATFORM_FEE_RATE;
  uint24 public SECONDS_IN_MONTH;

  bool public emergencyMode;

  struct LockUp {
    uint8 durationInMonths;
    uint256 unlockedAt; // NOTE: Potential block time manipulation by miners
    uint256 amount;
    uint256 effectiveAmount; // amount * durationBoost
    uint256 exitedAt;
  }

  struct UserLockUp {
    uint256 total;
    uint256 effectiveTotal;
    uint256 accTotal; // info
    uint256 bonusClaimed; // info
    uint256 bonusDebt;
    uint40 lockedUpCount; // accumulative lock-up count (= length of lockUps)
    LockUp[] lockUps;
  }

  struct TokenStats {
    uint256 maxLockUpLimit;
    uint256 totalLockUp;
    uint256 effectiveTotalLockUp; // sum(amount * durationBoost)
    uint256 accBonusPerShare; // Others' Penalty = My Bonus
    uint256 totalPenalty; // info
    uint256 accTotalLockUp; // info
    uint40 accLockUpCount; // info
    uint40 activeLockUpCount; // info
    uint40 unlockedCount; // info
    uint40 brokenCount; // info
  }

  mapping (address => TokenStats) public tokenStats;

  address[] public pools;

  mapping (address => mapping (address => UserLockUp)) public userLockUps;

  address public fundAddress;

  event LockedUp(address indexed token, address indexed account, uint256 amount, uint256 totalLockUp, uint256 durationInMonths, uint256 timestamp);
  event Exited(address indexed token, address indexed account, uint256 amount, uint256 refundAmount, uint256 penalty, uint256 fee, uint256 remainingTotal, uint256 durationInMonths, uint256 timestamp);
  event BonusClaimed(address indexed token, address indexed account, uint256 amount, uint256 timestamp);


  function initialize() public initializer {

    OwnableUpgradeSafe.__Ownable_init();

    PENALTY_RATE = 10;
    PLATFORM_FEE_RATE = 3;
    SECONDS_IN_MONTH = 2592000; // TODO: Uncomment it on production

    fundAddress = address(0x82CA6d313BffE56E9096b16633dfD414148D66b1);  // TODO: Uncomment it on production
  }

  modifier _checkPoolExists(address tokenAddress) {

    require(tokenStats[tokenAddress].maxLockUpLimit > 0, 'POOL_NOT_FOUND');
    _;
  }

  modifier _checkEmergencyMode() {

    require(!emergencyMode, 'NOT_ALLOWED_IN_EMERGENCY');
    _;
  }

  function addLockUpPool(address tokenAddress, uint256 maxLockUpLimit) public onlyOwner {

    require(tokenAddress.isContract(), 'INVALID_TOKEN');
    require(tokenStats[tokenAddress].maxLockUpLimit == 0, 'POOL_ALREADY_EXISTS');
    require(maxLockUpLimit > 0, 'INVALID_LIMIT');

    pools.push(tokenAddress);
    tokenStats[tokenAddress].maxLockUpLimit = maxLockUpLimit;
  }

  function updateMaxLimit(address tokenAddress, uint256 maxLockUpLimit) external onlyOwner _checkPoolExists(tokenAddress) {

    tokenStats[tokenAddress].maxLockUpLimit = maxLockUpLimit;
  }

  function setEmergencyMode(bool mode) external onlyOwner {

    emergencyMode = mode;
  }

  function _durationBoost(uint256 durationInMonths) private pure returns (uint256) {

    uint256 durationBoost = durationInMonths.div(3);
    if (durationBoost > 40) {
      durationBoost = 40; // Max 10 years
    }
    return durationBoost;
  }

  function doLockUp(address tokenAddress, uint256 amount, uint8 durationInMonths) public virtual _checkPoolExists(tokenAddress) _checkEmergencyMode {

    require(amount > 0, 'INVALID_AMOUNT');
    require(durationInMonths >= 3 && durationInMonths <= 120, 'INVALID_DURATION');

    IERC20 token = IERC20(tokenAddress);

    UserLockUp storage userLockUp = userLockUps[tokenAddress][msg.sender];
    TokenStats storage tokenStat = tokenStats[tokenAddress];

    if (tokenStat.maxLockUpLimit < userLockUp.total + amount) {
      revert('MAX_LIMIT_EXCEEDED');
    }

    token.safeTransferFrom(msg.sender, address(this), amount);

    claimBonus(tokenAddress);

    uint256 effectiveAmount = amount.mul(_durationBoost(durationInMonths));
    userLockUp.lockUps.push(
      LockUp(
        durationInMonths,
        block.timestamp.add(durationInMonths * SECONDS_IN_MONTH), // unlockedAt
        amount,
        effectiveAmount,
        0 // exitedAt
      )
    );

    userLockUp.total = userLockUp.total.add(amount);
    userLockUp.accTotal = userLockUp.accTotal.add(amount);
    userLockUp.effectiveTotal = userLockUp.effectiveTotal.add(effectiveAmount);
    userLockUp.lockedUpCount = userLockUp.lockedUpCount + 1;

    tokenStat.totalLockUp = tokenStat.totalLockUp.add(amount);
    tokenStat.accTotalLockUp = tokenStat.accTotalLockUp.add(amount);
    tokenStat.accLockUpCount = tokenStat.accLockUpCount + 1;
    tokenStat.activeLockUpCount = tokenStat.activeLockUpCount + 1;
    tokenStat.effectiveTotalLockUp = tokenStat.effectiveTotalLockUp.add(effectiveAmount);

    _updateBonusDebt(tokenAddress, msg.sender);

    emit LockedUp(tokenAddress, msg.sender, amount, tokenStat.totalLockUp, durationInMonths, block.timestamp);
  }

  function _updateBonusDebt(address tokenAddress, address account) private {

    userLockUps[tokenAddress][account].bonusDebt = tokenStats[tokenAddress].accBonusPerShare
      .mul(userLockUps[tokenAddress][account].effectiveTotal).div(1e18);
  }

  function exit(address tokenAddress, uint256 lockUpId, bool force) public virtual _checkPoolExists(tokenAddress) _checkEmergencyMode {

    UserLockUp storage userLockUp = userLockUps[tokenAddress][msg.sender];
    LockUp storage lockUp = userLockUp.lockUps[lockUpId];

    require(lockUp.exitedAt == 0, 'ALREADY_EXITED');
    require(force || block.timestamp >= lockUp.unlockedAt, 'MUST_BE_FORCED');

    claimBonus(tokenAddress);

    uint256 penalty = 0;
    uint256 fee = 0;

    if (force && block.timestamp < lockUp.unlockedAt) {
      penalty = lockUp.amount.mul(PENALTY_RATE).div(100);
      fee = lockUp.amount.mul(PLATFORM_FEE_RATE).div(100);
    } else if (force) {
      revert('MUST_NOT_BE_FORCED');
    }

    uint256 refundAmount = lockUp.amount.sub(penalty).sub(fee);

    lockUp.exitedAt = block.timestamp;

    TokenStats storage tokenStat = tokenStats[tokenAddress];
    tokenStat.totalLockUp = tokenStat.totalLockUp.sub(lockUp.amount);
    tokenStat.effectiveTotalLockUp = tokenStat.effectiveTotalLockUp.sub(lockUp.effectiveAmount);
    tokenStat.totalPenalty = tokenStat.totalPenalty.add(penalty);

    tokenStat.activeLockUpCount = tokenStat.activeLockUpCount - 1;
    if (penalty > 0) {
      tokenStat.brokenCount = tokenStat.brokenCount + 1;
    } else {
      tokenStat.unlockedCount = tokenStat.unlockedCount + 1;
    }

    userLockUp.total = userLockUp.total.sub(lockUp.amount);
    userLockUp.effectiveTotal = userLockUp.effectiveTotal.sub(lockUp.effectiveAmount);
    _updateBonusDebt(tokenAddress, msg.sender);

    if (penalty > 0 && tokenStat.effectiveTotalLockUp > 0) {
      tokenStat.accBonusPerShare = tokenStat.accBonusPerShare.add(penalty.mul(1e18).div(tokenStat.effectiveTotalLockUp));
    }

    IERC20 token = IERC20(tokenAddress);
    token.safeTransfer(msg.sender, refundAmount);
    if (fee > 0) {
      token.safeTransfer(fundAddress, fee); // Platform fee converted to HUNT and burned
    }
    emit Exited(tokenAddress, msg.sender, lockUp.amount, refundAmount, penalty, fee, userLockUp.total, lockUp.durationInMonths, block.timestamp);
  }

  function earnedBonus(address tokenAddress) public view returns (uint256) {

    TokenStats storage tokenStat = tokenStats[tokenAddress];
    UserLockUp storage userLockUp = userLockUps[tokenAddress][msg.sender];


    return userLockUp.effectiveTotal
      .mul(tokenStat.accBonusPerShare).div(1e18)
      .sub(userLockUp.bonusDebt); // The accumulated amount before I join the pool
  }

  function claimBonus(address tokenAddress) public _checkPoolExists(tokenAddress) _checkEmergencyMode {

    uint256 amount = earnedBonus(tokenAddress);

    if (amount == 0) {
      return;
    }

    UserLockUp storage userLockUp = userLockUps[tokenAddress][msg.sender];

    userLockUp.bonusClaimed = userLockUp.bonusClaimed.add(amount);
    _updateBonusDebt(tokenAddress, msg.sender);

    IERC20(tokenAddress).safeTransfer(msg.sender, amount);

    emit BonusClaimed(tokenAddress, msg.sender, amount, block.timestamp);
  }


  function poolCount() external view returns(uint256) {

    return pools.length;
  }

  function getLockUp(address tokenAddress, address account, uint256 lockUpId) external view returns (uint8, uint256, uint256, uint256, uint256) {

    LockUp storage lockUp = userLockUps[tokenAddress][account].lockUps[lockUpId];

    return (
      lockUp.durationInMonths,
      lockUp.unlockedAt,
      lockUp.amount,
      lockUp.effectiveAmount,
      lockUp.exitedAt
    );
  }

  function lockedUpAt(address tokenAddress, address account, uint256 lockUpId) external view returns (uint256) {

    LockUp storage lockUp = userLockUps[tokenAddress][account].lockUps[lockUpId];

    return lockUp.unlockedAt.sub(lockUp.durationInMonths * SECONDS_IN_MONTH);
  }

  function setFundAddress(address _fundAddress) external onlyOwner {

    fundAddress = _fundAddress;
  }

  uint256[50] private ______gap;
}// MIT
pragma solidity ^0.7.1;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT
pragma solidity ^0.7.1;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT
pragma solidity ^0.7.1;


abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}// MIT
pragma solidity ^0.7.1;


contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {



        _name = name;
        _symbol = symbol;
        _decimals = 18;

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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    uint256[44] private __gap;
}// MIT
pragma solidity ^0.7.1;


abstract contract ERC20BurnableUpgradeSafe is Initializable, ContextUpgradeSafe, ERC20UpgradeSafe {
    using SafeMath for uint256;

    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {


    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    uint256[50] private __gap;
}// MIT
pragma solidity ^0.7.1;


contract PausableUpgradeSafe is Initializable, ContextUpgradeSafe {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;


    function __Pausable_init() internal initializer {

        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {



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

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}// MIT
pragma solidity ^0.7.1;


abstract contract ERC20PausableUpgradeSafe is Initializable, ERC20UpgradeSafe, PausableUpgradeSafe {
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {


    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    uint256[50] private __gap;
}// MIT
pragma solidity ^0.7.1;


contract ERC20PresetMinterPauserUpgradeSafe is Initializable, ContextUpgradeSafe, AccessControlUpgradeSafe, ERC20BurnableUpgradeSafe, ERC20PausableUpgradeSafe {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");


    function initialize(string memory name, string memory symbol) public {

        __ERC20PresetMinterPauser_init(name, symbol);
    }

    function __ERC20PresetMinterPauser_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __AccessControl_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20Burnable_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
        __ERC20PresetMinterPauser_init_unchained();
    }

    function __ERC20PresetMinterPauser_init_unchained() internal initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function mint(address to, uint256 amount) public {

        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

    function pause() public {

        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    function unpause() public {

        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20UpgradeSafe, ERC20PausableUpgradeSafe) {

        super._beforeTokenTransfer(from, to, amount);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.7.1;

contract WRNRewardPool is LockUpPool {

  using SafeMath for uint256;
  using SafeERC20 for ERC20PresetMinterPauserUpgradeSafe;

  ERC20PresetMinterPauserUpgradeSafe public WRNToken; // WRN Reward Token

  uint256 public REWARD_START_BLOCK;
  uint256 public REWARD_END_BLOCK;
  uint256 public REWARD_EARLY_BONUS_END_BLOCK;
  uint256 public REWARD_PER_BLOCK;
  uint8 public REWARD_EARLY_BONUS_BOOST;

  uint16 public totalMultiplier;
  struct WRNStats {
    uint8 multiplier; // For WRN token distribution
    uint256 accWRNPerShare;
    uint256 lastRewardBlock;
  }

  struct UserWRNReward {
    uint256 claimed;
    uint256 debt;
  }

  mapping (address => WRNStats) public wrnStats;

  mapping (address => mapping (address => UserWRNReward)) public userWRNRewards;

  event PoolAdded(address indexed tokenAddress, uint8 multiplier, uint256 timestamp);
  event WRNMinted(address indexed tokenAddress, uint256 amount, uint256 timestamp);
  event WRNClaimed(address indexed tokenAddress, address indexed account, uint256 amount, uint256 timestamp);

  function initialize(address WRNAddress, uint256 rewardStartBlock, uint256 rewardBlocks, uint256 bonusBlocks) public initializer {

    require(bonusBlocks <= rewardBlocks, 'INVALID_PARAM');

    LockUpPool.initialize();

    WRNToken = ERC20PresetMinterPauserUpgradeSafe(WRNAddress);

    REWARD_START_BLOCK = rewardStartBlock;
    REWARD_PER_BLOCK = 1e17; // 0.1 WRN
    REWARD_END_BLOCK = REWARD_START_BLOCK.add(rewardBlocks); // 8.8M blocks (appx 3 years and 7 months)

    REWARD_EARLY_BONUS_END_BLOCK = REWARD_START_BLOCK.add(bonusBlocks);
    REWARD_EARLY_BONUS_BOOST = 5;
  }


  function addLockUpRewardPool(address tokenAddress, uint8 multiplier, uint256 maxLockUpLimit, bool shouldUpdate) external onlyOwner {

    require(multiplier >= 0, 'INVALID_MULTIPLIER');

    if(shouldUpdate) {
      updateAllPools();
    }

    addLockUpPool(tokenAddress, maxLockUpLimit);

    wrnStats[tokenAddress].multiplier = multiplier;
    totalMultiplier = totalMultiplier + multiplier;

    emit PoolAdded(tokenAddress, multiplier, block.timestamp);
  }

  function updatePoolMultiplier(address tokenAddress, uint8 multiplier, bool shouldUpdate) external onlyOwner {

    require(multiplier >= 0, 'INVALID_MULTIPLIER');

    if(shouldUpdate) {
      updateAllPools();
    } else if (wrnStats[tokenAddress].multiplier > multiplier) {

      revert('UPDATE_ALL_REQUIRED');
    }

    totalMultiplier = totalMultiplier - wrnStats[tokenAddress].multiplier + multiplier;
    wrnStats[tokenAddress].multiplier = multiplier;
  }

  function _updateDebt(address tokenAddress, address account) private {

    userWRNRewards[tokenAddress][account].debt = wrnStats[tokenAddress].accWRNPerShare
      .mul(userLockUps[tokenAddress][account].effectiveTotal).div(1e18);
  }

  function doLockUp(address tokenAddress, uint256 amount, uint8 durationInMonths) public override {

    claimWRN(tokenAddress);

    super.doLockUp(tokenAddress, amount, durationInMonths);

    _updateDebt(tokenAddress, msg.sender);
  }

  function exit(address tokenAddress, uint256 lockUpIndex, bool force) public override {

    claimWRN(tokenAddress);

    super.exit(tokenAddress, lockUpIndex, force);

    _updateDebt(tokenAddress, msg.sender);
  }

  function _getWRNPerBlock(uint256 from, uint256 to) private view returns (uint256) {

    if (to < REWARD_START_BLOCK || from > REWARD_END_BLOCK) { // Reward not started or finished
      return 0;
    }
    if (from < REWARD_START_BLOCK) {
      from = REWARD_START_BLOCK;
    }
    if (to > REWARD_END_BLOCK) {
      to = REWARD_END_BLOCK;
    }

    if (to <= REWARD_EARLY_BONUS_END_BLOCK) { // Bonus period
      return to.sub(from).mul(REWARD_EARLY_BONUS_BOOST).mul(REWARD_PER_BLOCK);
    } else if (from <= REWARD_EARLY_BONUS_END_BLOCK && to > REWARD_EARLY_BONUS_END_BLOCK) { // Partial bonus period
      return REWARD_EARLY_BONUS_END_BLOCK.sub(from).mul(REWARD_EARLY_BONUS_BOOST).mul(REWARD_PER_BLOCK).add(
        to.sub(REWARD_EARLY_BONUS_END_BLOCK).mul(REWARD_PER_BLOCK)
      );
    } else { // After bonus period (from > REWARD_EARLY_BONUS_END_BLOCK)
      return to.sub(from).mul(REWARD_PER_BLOCK);
    }
  }

  function updateAllPools() public {

    uint256 length = pools.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(pools[pid]);
    }
  }

  function updatePool(address tokenAddress) public _checkPoolExists(tokenAddress) {

    WRNStats storage wrnStat = wrnStats[tokenAddress];
    if (block.number <= wrnStat.lastRewardBlock) {
      return;
    }

    TokenStats storage tokenStat = tokenStats[tokenAddress];
    uint256 wrnToMint = _getAccWRNTillNow(tokenAddress);

    if (wrnStat.lastRewardBlock != 0 && tokenStat.effectiveTotalLockUp > 0 && wrnToMint > 0) {
      WRNToken.mint(fundAddress, wrnToMint.div(9)); // 10% dev pool (120,000 / (1,080,000 + 120,000) = 10%)
      WRNToken.mint(address(this), wrnToMint);
      wrnStat.accWRNPerShare = wrnStat.accWRNPerShare.add(
        wrnToMint.mul(1e18).div(tokenStat.effectiveTotalLockUp)
      );

      emit WRNMinted(tokenAddress, wrnToMint, block.timestamp);
    }

    wrnStat.lastRewardBlock = block.number;
  }

  function _getAccWRNTillNow(address tokenAddress) private view returns (uint256) {

    WRNStats storage wrnStat = wrnStats[tokenAddress];

    return _getWRNPerBlock(wrnStat.lastRewardBlock, block.number)
      .mul(wrnStat.multiplier)
      .div(totalMultiplier);
  }

  function pendingWRN(address tokenAddress) public view returns (uint256) {

    TokenStats storage tokenStat = tokenStats[tokenAddress];
    WRNStats storage wrnStat = wrnStats[tokenAddress];
    UserWRNReward storage userWRNReward = userWRNRewards[tokenAddress][msg.sender];

    uint256 accWRNPerShare = wrnStat.accWRNPerShare;
    if (block.number > wrnStat.lastRewardBlock && tokenStat.effectiveTotalLockUp != 0) {
      uint256 accWRNTillNow = _getAccWRNTillNow(tokenAddress);
      accWRNPerShare = accWRNPerShare.add(
        accWRNTillNow.mul(1e18).div(tokenStat.effectiveTotalLockUp)
      );
    }

    return userLockUps[tokenAddress][msg.sender].effectiveTotal
      .mul(accWRNPerShare)
      .div(1e18)
      .sub(userWRNReward.debt);
  }

  function claimWRN(address tokenAddress) public {

    updatePool(tokenAddress);

    uint256 amount = pendingWRN(tokenAddress);
    if (amount == 0) {
      return;
    }

    UserWRNReward storage userWRNReward = userWRNRewards[tokenAddress][msg.sender];

    userWRNReward.claimed = userWRNReward.claimed.add(amount);
    _updateDebt(tokenAddress, msg.sender);

    WRNToken.safeTransfer(msg.sender, amount);

    emit WRNClaimed(tokenAddress, msg.sender, amount, block.timestamp);
  }

  function claimWRNandBonus(address tokenAddress) external {

    claimWRN(tokenAddress);
    claimBonus(tokenAddress);
  }

  uint256[50] private ______gap;
}