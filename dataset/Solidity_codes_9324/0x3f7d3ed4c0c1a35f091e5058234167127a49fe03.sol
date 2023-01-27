

pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity >=0.4.24 <0.7.0;


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


pragma solidity ^0.6.0;



contract ERC165UpgradeSafe is Initializable, IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;


    function __ERC165_init() internal initializer {

        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {



        _registerInterface(_INTERFACE_ID_ERC165);

    }


    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[49] private __gap;
}


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


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}


pragma solidity ^0.6.0;


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


pragma solidity ^0.6.2;

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
}


pragma solidity ^0.6.0;






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
}


pragma solidity ^0.6.2;

library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}




pragma solidity ^0.6.0;



interface IConsumable is IERC165, IERC20 {

  struct ConsumableAmount {
    IConsumable consumable;
    uint256 amount;
  }



  function myBalance() external view returns (uint256);


  function myAllowance(address owner) external view returns (uint256);



}





pragma solidity ^0.6.0;



interface IConsumableConsumer {

  function consumablesRequired() external view returns (IConsumable[] memory);


  function isRequired(IConsumable consumable) external view returns (bool);


  function amountRequired(IConsumable consumable) external view returns (uint256);

}





pragma solidity ^0.6.0;



interface IConsumableProvider {

  function consumablesProvided() external view returns (IConsumable[] memory);


  function isProvided(IConsumable consumable) external view returns (bool);


  function amountProvided(IConsumable consumable) external view returns (uint256);

}





pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;




interface IActivity is IERC165, IConsumableConsumer, IConsumableProvider {

  event Executed(address indexed player);

  function executed(address player) external view returns (uint256);


  function totalExecuted() external view returns (uint256);


  function execute(address[] calldata helpers) external;

}





pragma solidity ^0.6.0;



library ActivityInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant ACTIVITY_INTERFACE_ID = 0x00f62528;

  function supportsActivityInterface(IActivity activity) internal view returns (bool) {

    return address(activity).supportsInterface(ACTIVITY_INTERFACE_ID);
  }
}





pragma solidity ^0.6.0;



library ConsumableInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant CONSUMABLE_INTERFACE_ID = 0x0d6673db;

  function supportsConsumableInterface(IConsumable account) internal view returns (bool) {

    return address(account).supportsInterface(CONSUMABLE_INTERFACE_ID);
  }
}





pragma solidity ^0.6.0;


interface IConvertibleConsumable is IConsumable {

  function exchangeToken() external view returns (IERC20);


  function asymmetricalExchangeRate() external view returns (bool);


  function intrinsicValueExchangeRate() external view returns (uint256);


  function purchasePriceExchangeRate() external view returns (uint256);


  function amountExchangeTokenAvailable() external view returns (uint256);


  function mintByExchange(uint256 consumableAmount) external;


  function amountExchangeTokenNeeded(uint256 consumableAmount) external view returns (uint256);


  function burnByExchange(uint256 consumableAmount) external;


  function amountExchangeTokenProvided(uint256 consumableAmount) external view returns (uint256);

}





pragma solidity ^0.6.0;



library ConvertibleConsumableInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant CONVERTIBLE_CONSUMABLE_INTERFACE_ID = 0x1574139e;

  function supportsConvertibleConsumableInterface(IConvertibleConsumable consumable) internal view returns (bool) {

    return address(consumable).supportsInterface(CONVERTIBLE_CONSUMABLE_INTERFACE_ID);
  }

  function calcConvertibleConsumableInterfaceId(IConvertibleConsumable consumable) internal pure returns (bytes4) {

    return
      consumable.exchangeToken.selector ^
      consumable.asymmetricalExchangeRate.selector ^
      consumable.intrinsicValueExchangeRate.selector ^
      consumable.purchasePriceExchangeRate.selector ^
      consumable.amountExchangeTokenAvailable.selector ^
      consumable.mintByExchange.selector ^
      consumable.amountExchangeTokenNeeded.selector ^
      consumable.burnByExchange.selector ^
      consumable.amountExchangeTokenProvided.selector;
  }
}


pragma solidity ^0.6.0;

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
}


pragma solidity ^0.6.0;





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
}





pragma solidity ^0.6.0;

interface IRoleDelegate {

  function isInRole(bytes32 role, address account) external view returns (bool);

}





pragma solidity ^0.6.0;



library RoleDelegateInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant ROLE_DELEGATE_INTERFACE_ID = 0x7cef57ea;

  function supportsRoleDelegateInterface(IRoleDelegate roleDelegate) internal view returns (bool) {

    return address(roleDelegate).supportsInterface(ROLE_DELEGATE_INTERFACE_ID);
  }
}





pragma solidity ^0.6.0;

library RoleSupport {

  bytes32 public constant SUPER_ADMIN_ROLE = 0x00;
  bytes32 public constant MINTER_ROLE = keccak256('Minter');
  bytes32 public constant ADMIN_ROLE = keccak256('Admin');
  bytes32 public constant TRANSFER_AGENT_ROLE = keccak256('Transfer');
}





pragma solidity ^0.6.0;






contract DelegatingRoles is Initializable, ContextUpgradeSafe {

  using EnumerableSet for EnumerableSet.AddressSet;
  using RoleDelegateInterfaceSupport for IRoleDelegate;

  EnumerableSet.AddressSet private _roleDelegates;

  function isRoleDelegate(IRoleDelegate roleDelegate) public view returns (bool) {

    return _roleDelegates.contains(address(roleDelegate));
  }

  function _addRoleDelegate(IRoleDelegate roleDelegate) internal {

    require(address(roleDelegate) != address(0), 'Role delegate cannot be zero address');
    require(roleDelegate.supportsRoleDelegateInterface(), 'Role delegate must implement interface');

    _roleDelegates.add(address(roleDelegate));
    emit RoleDelegateAdded(roleDelegate);
  }

  function _removeRoleDelegate(IRoleDelegate roleDelegate) internal {

    _roleDelegates.remove(address(roleDelegate));
    emit RoleDelegateRemoved(roleDelegate);
  }

  function _hasRole(bytes32 role, address account) internal virtual view returns (bool) {

    uint256 roleDelegateLength = _roleDelegates.length();
    for (uint256 roleDelegateIndex = 0; roleDelegateIndex < roleDelegateLength; roleDelegateIndex++) {
      IRoleDelegate roleDelegate = IRoleDelegate(_roleDelegates.at(roleDelegateIndex));
      if (roleDelegate.isInRole(role, account)) {
        return true;
      }
    }

    return false;
  }

  modifier onlyAdmin() {

    require(isAdmin(_msgSender()), 'Caller does not have the Admin role');
    _;
  }

  function isAdmin(address account) public view returns (bool) {

    return _hasRole(RoleSupport.ADMIN_ROLE, account);
  }

  modifier onlyMinter() {

    require(isMinter(_msgSender()), 'Caller does not have the Minter role');
    _;
  }

  function isMinter(address account) public view returns (bool) {

    return _hasRole(RoleSupport.MINTER_ROLE, account);
  }

  modifier onlyTransferAgent() {

    require(isTransferAgent(_msgSender()), 'Caller does not have the Transfer Agent role');
    _;
  }

  function isTransferAgent(address account) public view returns (bool) {

    return _hasRole(RoleSupport.TRANSFER_AGENT_ROLE, account);
  }

  event RoleDelegateAdded(IRoleDelegate indexed roleDelegate);

  event RoleDelegateRemoved(IRoleDelegate indexed roleDelegate);

  uint256[50] private ______gap;
}





pragma solidity ^0.6.0;





contract Roles is IRoleDelegate, Initializable, ContextUpgradeSafe, AccessControlUpgradeSafe, DelegatingRoles {

  function _initializeRoles(IRoleDelegate roleDelegate) public initializer {

    if (address(roleDelegate) != address(0)) {
      _addRoleDelegate(roleDelegate);
    } else {
      _addSuperAdmin(_msgSender());
    }
  }

  function isInRole(bytes32 role, address account) external override view returns (bool) {

    return _hasRole(role, account);
  }

  function _hasRole(bytes32 role, address account) internal override view returns (bool) {

    if (hasRole(role, account)) {
      return true;
    }

    return super._hasRole(role, account);
  }

  modifier onlySuperAdmin() {

    require(isSuperAdmin(_msgSender()), 'Caller does not have the SuperAdmin role');
    _;
  }

  function isSuperAdmin(address account) public view returns (bool) {

    return _hasRole(RoleSupport.SUPER_ADMIN_ROLE, account);
  }

  function addSuperAdmin(address account) public virtual onlySuperAdmin {

    _addSuperAdmin(account);
  }

  function _addSuperAdmin(address account) internal {

    _setupRole(RoleSupport.SUPER_ADMIN_ROLE, account);
  }

  function renounceSuperAdmin() public virtual {

    renounceRole(RoleSupport.SUPER_ADMIN_ROLE, _msgSender());
  }

  function revokeSuperAdmin(address account) public virtual {

    revokeRole(RoleSupport.SUPER_ADMIN_ROLE, account);
  }

  function addAdmin(address account) public virtual onlySuperAdmin {

    _addAdmin(account);
  }

  function _addAdmin(address account) internal {

    _setupRole(RoleSupport.ADMIN_ROLE, account);
  }

  function renounceAdmin() public virtual {

    renounceRole(RoleSupport.ADMIN_ROLE, _msgSender());
  }

  function revokeAdmin(address account) public virtual {

    revokeRole(RoleSupport.ADMIN_ROLE, account);
  }

  function addMinter(address account) public virtual onlySuperAdmin {

    _addMinter(account);
  }

  function _addMinter(address account) internal {

    _setupRole(RoleSupport.MINTER_ROLE, account);
  }

  function renounceMinter() public virtual {

    renounceRole(RoleSupport.MINTER_ROLE, _msgSender());
  }

  function revokeMinter(address account) public virtual {

    revokeRole(RoleSupport.MINTER_ROLE, account);
  }

  function addTransferAgent(address account) public virtual onlySuperAdmin {

    _addTransferAgent(account);
  }

  function _addTransferAgent(address account) internal {

    _setupRole(RoleSupport.TRANSFER_AGENT_ROLE, account);
  }

  function renounceTransferAgent() public virtual {

    renounceRole(RoleSupport.TRANSFER_AGENT_ROLE, _msgSender());
  }

  function revokeTransferAgent(address account) public virtual {

    revokeRole(RoleSupport.TRANSFER_AGENT_ROLE, account);
  }

  uint256[50] private ______gap;
}





pragma solidity ^0.6.0;



interface ISkill is IERC165 {

  event Acquired(address indexed player, uint256 level);

  function myCurrentLevel() external view returns (uint256);


  function currentLevel(address player) external view returns (uint256);


  function acquireNext(address[] calldata helpers) external returns (bool);

}





pragma solidity ^0.6.0;



library SkillInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant SKILL_INTERFACE_ID = 0xa87617d1;

  function supportsSkillInterface(ISkill skill) internal view returns (bool) {

    return address(skill).supportsInterface(SKILL_INTERFACE_ID);
  }
}


pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}





pragma solidity ^0.6.0;




interface IArtifact is IERC165, IERC721, IConsumableProvider {

  struct Item {
    IArtifact artifact;
    uint256 itemId;
  }

  event Used(address indexed player, address indexed action, uint256 indexed itemId);

  function initialUses() external view returns (uint256);


  function usesLeft(uint256 itemId) external view returns (uint256);


  function totalUsesLeft() external view returns (uint256);


  function useItem(uint256 itemId, address action) external;

}





pragma solidity ^0.6.0;







interface IPlayer is IERC165 {

  function execute(
    IActivity activity,
    IArtifact.Item[] calldata useItems,
    IConsumable.ConsumableAmount[] calldata amountsToProvide,
    IConsumable.ConsumableAmount[] calldata amountsToConsume
  ) external;


  function acquireNext(
    ISkill skill,
    IArtifact.Item[] calldata useItems,
    IConsumable.ConsumableAmount[] calldata amountsToProvide
  ) external;

}





pragma solidity ^0.6.0;



library PlayerInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant PLAYER_INTERFACE_ID = 0x9c833abb;

  function supportsPlayerInterface(IPlayer player) internal view returns (bool) {

    return address(player).supportsInterface(PLAYER_INTERFACE_ID);
  }
}





pragma solidity ^0.6.0;

interface IDisableable {

  event Disabled();

  event Enabled();

  function disabled() external view returns (bool);


  function enabled() external view returns (bool);


  modifier onlyEnabled() virtual {

    require(!this.disabled(), 'Contract is disabled');
    _;
  }

  function disable() external;


  function enable() external;

}





pragma solidity ^0.6.0;


abstract contract Disableable is IDisableable {
  bool private _disabled;

  function disabled() external override view returns (bool) {
    return _disabled;
  }

  function enabled() external override view returns (bool) {
    return !_disabled;
  }

  function _disable() internal {
    if (_disabled) {
      return;
    }

    _disabled = true;
    emit Disabled();
  }

  function _enable() internal {
    if (!_disabled) {
      return;
    }

    _disabled = false;
    emit Enabled();
  }

  uint256[50] private ______gap;
}





pragma solidity ^0.6.0;


library TransferringInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant TRANSFERRING_INTERFACE_ID = 0x6fafa3a8;

  function supportsTransferInterface(address account) internal view returns (bool) {

    return account.supportsInterface(TRANSFERRING_INTERFACE_ID);
  }
}


pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}





pragma solidity ^0.6.0;





interface ITransferring is IERC165, IERC721Receiver {

  function transferToken(
    IERC20 token,
    uint256 amount,
    address recipient
  ) external;


  function transferItem(
    IERC721 artifact,
    uint256 itemId,
    address recipient
  ) external;

}





pragma solidity ^0.6.0;






library TransferLogic {

  using ConvertibleConsumableInterfaceSupport for IConvertibleConsumable;

  function transferToken(
    address, /*account*/
    IERC20 token,
    uint256 amount,
    address recipient
  ) internal {

    token.transfer(recipient, amount);
  }

  function transferTokenWithExchange(
    address account,
    IERC20 token,
    uint256 amount,
    address recipient
  ) internal {

    uint256 myBalance = token.balanceOf(account);
    if (myBalance < amount && IConvertibleConsumable(address(token)).supportsConvertibleConsumableInterface()) {
      IConvertibleConsumable convertibleConsumable = IConvertibleConsumable(address(token));

      uint256 amountConsumableNeeded = amount - myBalance; // safe since we checked < above
      uint256 amountExchangeToken = convertibleConsumable.amountExchangeTokenNeeded(amountConsumableNeeded);

      ERC20UpgradeSafe exchange = ERC20UpgradeSafe(address(convertibleConsumable.exchangeToken()));
      exchange.increaseAllowance(address(token), amountExchangeToken);
    }

    token.transfer(recipient, amount);
  }

  function transferItem(
    address account,
    IERC721 artifact,
    uint256 itemId,
    address recipient
  ) internal {

    artifact.safeTransferFrom(account, recipient, itemId);
  }

  function onERC721Received(
    address, /*operator*/
    address, /*from*/
    uint256, /*tokenId*/
    bytes memory /*data*/
  ) internal pure returns (bytes4) {

    return IERC721Receiver.onERC721Received.selector;
  }
}





pragma solidity ^0.6.0;



library ArtifactInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant ARTIFACT_INTERFACE_ID = 0xd3abf7f1;

  function supportsArtifactInterface(IArtifact artifact) internal view returns (bool) {

    return address(artifact).supportsInterface(ARTIFACT_INTERFACE_ID);
  }
}





pragma solidity ^0.6.0;



library ItemUserLogic {

  using ArtifactInterfaceSupport for IArtifact;

  function useItems(address action, IArtifact.Item[] memory itemsToUse) internal {

    for (uint256 itemIndex = 0; itemIndex < itemsToUse.length; itemIndex++) {
      IArtifact.Item memory item = itemsToUse[itemIndex];
      IArtifact artifact = item.artifact;
      require(artifact.supportsArtifactInterface(), 'ItemUser: item address must support IArtifact');
      artifact.useItem(item.itemId, action);
    }
  }
}





pragma solidity ^0.6.0;




















contract Player is Initializable, ITransferring, IPlayer, ContextUpgradeSafe, ERC165UpgradeSafe, Disableable, Roles {

  using ActivityInterfaceSupport for IActivity;
  using ConsumableInterfaceSupport for IConsumable;
  using ConvertibleConsumableInterfaceSupport for IConvertibleConsumable;
  using PlayerInterfaceSupport for IPlayer;
  using SkillInterfaceSupport for ISkill;
  using TransferLogic for address;
  using ItemUserLogic for address;

  function initializePlayer(IRoleDelegate roleDelegate) public initializer {

    __ERC165_init();
    _registerInterface(PlayerInterfaceSupport.PLAYER_INTERFACE_ID);
    _registerInterface(RoleDelegateInterfaceSupport.ROLE_DELEGATE_INTERFACE_ID);
    _registerInterface(TransferringInterfaceSupport.TRANSFERRING_INTERFACE_ID);

    if (address(roleDelegate) != address(0)) {
      _addRoleDelegate(roleDelegate);
    } else {
      _addSuperAdmin(_msgSender());
      _addAdmin(_msgSender());
      _addTransferAgent(_msgSender());
    }
  }

  function execute(
    IActivity activity,
    IArtifact.Item[] calldata useItems,
    IConsumable.ConsumableAmount[] calldata amountsToProvide,
    IConsumable.ConsumableAmount[] calldata amountsToConsume
  ) external override onlyEnabled onlyAdmin {

    require(activity.supportsActivityInterface(), 'Player: activity address must support IActivity');

    address(activity).useItems(useItems);

    _provideConsumables(address(activity), amountsToProvide);

    address[] memory helpers = new address[](useItems.length);
    for (uint256 itemIndex = 0; itemIndex < useItems.length; itemIndex++) {
      helpers[itemIndex] = address(useItems[itemIndex].artifact);
    }

    activity.execute(helpers);

    _consumeConsumables(address(activity), amountsToConsume);
  }

  function acquireNext(
    ISkill skill,
    IArtifact.Item[] calldata useItems,
    IConsumable.ConsumableAmount[] calldata amountsToProvide
  ) external override onlyEnabled onlyAdmin {

    require(skill.supportsSkillInterface(), 'Player: skill address must support ISkill');

    address(skill).useItems(useItems);

    _provideConsumables(address(skill), amountsToProvide);

    address[] memory helpers = new address[](useItems.length);
    for (uint256 itemIndex = 0; itemIndex < useItems.length; itemIndex++) {
      helpers[itemIndex] = address(useItems[itemIndex].artifact);
    }

    skill.acquireNext(helpers);
  }

  function _provideConsumables(address consumer, IConsumable.ConsumableAmount[] memory amountsToProvide) internal {

    for (uint256 consumableIndex = 0; consumableIndex < amountsToProvide.length; consumableIndex++) {
      IConsumable.ConsumableAmount memory amountToProvide = amountsToProvide[consumableIndex];
      IConsumable consumable = IConsumable(amountToProvide.consumable);
      require(consumable.supportsConsumableInterface(), 'Player: Consumable must support interface when providing');

      ERC20UpgradeSafe token = ERC20UpgradeSafe(address(consumable));
      bool success = token.increaseAllowance(consumer, amountToProvide.amount);
      require(success, 'Provider: Consumable failed to transfer');
    }
  }

  function _consumeConsumables(address provider, IConsumable.ConsumableAmount[] memory amountsToConsume) internal {

    for (uint256 consumableIndex = 0; consumableIndex < amountsToConsume.length; consumableIndex++) {
      IConsumable.ConsumableAmount memory amountToConsume = amountsToConsume[consumableIndex];
      IConsumable consumable = IConsumable(amountToConsume.consumable);
      require(consumable.supportsConsumableInterface(), 'Player: Consumable must support interface when consuming');

      bool success = consumable.transferFrom(provider, address(this), amountToConsume.amount);
      require(success, 'Consumer: Consumable failed to transfer');
    }
  }

  function transferToken(
    IERC20 token,
    uint256 amount,
    address recipient
  ) external override onlyTransferAgent onlyEnabled {

    address(this).transferTokenWithExchange(token, amount, recipient);
  }

  function transferItem(
    IERC721 artifact,
    uint256 itemId,
    address recipient
  ) external override onlyTransferAgent onlyEnabled {

    address(this).transferItem(artifact, itemId, recipient);
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external virtual override returns (bytes4) {

    return TransferLogic.onERC721Received(operator, from, tokenId, data);
  }

  function disable() external override onlyAdmin {

    _disable();
  }

  function enable() external override onlyAdmin {

    _enable();
  }

  uint256[50] private ______gap;
}