
pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


library Arrays {

    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Snapshot is ERC20 {

    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
      super._beforeTokenTransfer(from, to, amount);

      if (from == address(0)) {
        _updateAccountSnapshot(to);
        _updateTotalSupplySnapshot();
      } else if (to == address(0)) {
        _updateAccountSnapshot(from);
        _updateTotalSupplySnapshot();
      } else {
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);
      }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _currentSnapshotId.current(), "ERC20Snapshot: nonexistent id");


        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
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

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
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
}// UNLICENSED
pragma solidity ^0.7.4;


contract ScalingFundsToken is ERC20Snapshot, AccessControl {
  bool public areInvestorTransfersDisabled;
  bool public isCapTableLocked;
  bool public isTokenLaunched;
  bool public isTokenDead;

  bytes32 public constant SCALINGFUNDS_AGENT = keccak256("SCALINGFUNDS_AGENT");
  bytes32 public constant TRANSFER_AGENT = keccak256("TRANSFER_AGENT");
  bytes32 public constant ALLOWLISTED_INVESTOR =
    keccak256("ALLOWLISTED_INVESTOR");

  ScalingFundsToken internal _previousContract;


  event InvestorTransfersDisabled(address indexed caller);

  event InvestorTransfersEnabled(address indexed caller);

  event CapTableLocked(address indexed caller);

  event CapTableUnlocked(address indexed caller);

  event TokenLaunched(address indexed caller);

  event TokenKilled(address indexed caller, string reason);

  event ForcedTransfer(
    address indexed from,
    address indexed to,
    uint256 amount,
    string reason
  );

  event PreviousContractLinked(address indexed previousContractAddress);


  modifier whenInvestorTransfersAreEnabled() {
    require(!areInvestorTransfersDisabled, "Investor Transfers are disabled");
    _;
  }

  modifier whenCapTableIsUnlocked() {
    require(!isCapTableLocked, "CapTable is locked");
    _;
  }

  modifier onlyBeforeLaunch() {
    require(!isTokenLaunched, "Token is already launched");
    _;
  }

  modifier onlyAfterLaunch() {
    require(isTokenLaunched, "Token is not yet launched");
    _;
  }

  modifier whenTokenIsActive() {
    require(!isTokenDead, "Token is dead");
    _;
  }

  modifier onlyScalingFundsAgent {
    require(
      super.hasRole(SCALINGFUNDS_AGENT, msg.sender),
      "Caller does not have SCALINGFUNDS_AGENT role"
    );
    _;
  }

  modifier isNotScalingFundsAgent(address account) {
    require(
      !super.hasRole(SCALINGFUNDS_AGENT, account),
      "account cannot have SCALINGFUNDS_AGENT role"
    );
    _;
  }

  modifier onlyTransferAgent {
    require(
      super.hasRole(TRANSFER_AGENT, msg.sender),
      "Caller does not have TRANSFER_AGENT role"
    );
    _;
  }

  modifier isNotTransferAgent(address account) {
    require(
      !super.hasRole(TRANSFER_AGENT, account),
      "account cannot have TRANSFER_AGENT role"
    );
    _;
  }

  modifier onlyTransferAgentOrScalingFundsAgent {
    require(
      super.hasRole(TRANSFER_AGENT, msg.sender) ||
        super.hasRole(SCALINGFUNDS_AGENT, msg.sender),
      "Caller does not have TRANSFER_AGENT or SCALINGFUNDS_AGENT role"
    );
    _;
  }

  modifier isAllowlistedInvestor(address account) {
    require(
      super.hasRole(ALLOWLISTED_INVESTOR, account),
      "account does not have ALLOWLISTED_INVESTOR role"
    );
    _;
  }

  modifier isNotAllowlistedInvestor(address account) {
    require(
      !super.hasRole(ALLOWLISTED_INVESTOR, account),
      "account cannot have ALLOWLISTED_INVESTOR role"
    );
    _;
  }


  constructor(
    string memory name,
    string memory symbol,
    address transferAgent,
    address scalingFundsAgent
  ) ERC20(name, symbol) {
    areInvestorTransfersDisabled = true;
    isCapTableLocked = false;
    isTokenDead = false;
    isTokenLaunched = false;

    super._setupRole(TRANSFER_AGENT, transferAgent);
    super._setupRole(SCALINGFUNDS_AGENT, scalingFundsAgent);

    super._setRoleAdmin(SCALINGFUNDS_AGENT, SCALINGFUNDS_AGENT);
    super._setRoleAdmin(TRANSFER_AGENT, TRANSFER_AGENT);
    super._setRoleAdmin(ALLOWLISTED_INVESTOR, TRANSFER_AGENT);
  }


  function disableInvestorTransfers()
    external
    onlyTransferAgent
    whenTokenIsActive
    onlyAfterLaunch
    whenInvestorTransfersAreEnabled
  {
    areInvestorTransfersDisabled = true;
    emit InvestorTransfersDisabled(msg.sender);
  }

  function enableInvestorTransfers()
    external
    onlyTransferAgent
    whenTokenIsActive
    onlyAfterLaunch
  {
    require(areInvestorTransfersDisabled, "Investor Transfers are enabled");
    areInvestorTransfersDisabled = false;
    emit InvestorTransfersEnabled(msg.sender);
  }

  function lockCapTable()
    external
    onlyTransferAgent
    whenTokenIsActive
    onlyAfterLaunch
    whenCapTableIsUnlocked
  {
    isCapTableLocked = true;
    emit CapTableLocked(msg.sender);
  }

  function unlockCapTable()
    external
    onlyTransferAgent
    whenTokenIsActive
    onlyAfterLaunch
  {
    require(isCapTableLocked, "CapTable is already unlocked");
    isCapTableLocked = false;
    emit CapTableUnlocked(msg.sender);
  }

  function launchToken()
    external
    onlyScalingFundsAgent
    whenTokenIsActive
    onlyBeforeLaunch
  {
    isTokenLaunched = true;
    emit TokenLaunched(msg.sender);
  }

  function killToken(string calldata reason)
    external
    onlyScalingFundsAgent
    whenTokenIsActive
  {
    bytes memory reasonAsBytes = bytes(reason);
    require(reasonAsBytes.length > 0, "reason string is empty");
    isTokenDead = true;
    emit TokenKilled(msg.sender, reason);
  }

  function takeSnapshot() external onlyScalingFundsAgent returns (uint256) {
    return super._snapshot();
  }


  function mint(address to, uint256 amount)
    public
    onlyAfterLaunch
    onlyTransferAgent
    isAllowlistedInvestor(to)
    returns (bool)
  {
    super._mint(to, amount);
    return true;
  }

  function burn(address account, uint256 amount)
    public
    onlyAfterLaunch
    onlyTransferAgent
    returns (bool)
  {
    super._burn(account, amount);
    return true;
  }

  function batchMint(address[] calldata accounts, uint256[] calldata amounts)
    external
    onlyAfterLaunch
    onlyTransferAgent
    returns (bool)
  {
    require(
      (accounts.length == amounts.length),
      "accounts and amounts do not have the same length"
    );
    for (uint256 i = 0; i < accounts.length; i++) {
      mint(accounts[i], amounts[i]);
    }
    return true;
  }

  function transfer(address to, uint256 amount)
    public
    override
    whenInvestorTransfersAreEnabled
    isAllowlistedInvestor(msg.sender)
    isAllowlistedInvestor(to)
    returns (bool)
  {
    return super.transfer(to, amount);
  }

  function forceTransfer(
    address from,
    address to,
    uint256 amount,
    string memory reason
  )
    external
    onlyAfterLaunch
    onlyTransferAgent
    isAllowlistedInvestor(from)
    isAllowlistedInvestor(to)
    returns (bool)
  {
    bytes memory reasonAsBytes = bytes(reason);
    require(reasonAsBytes.length > 0, "reason string is empty");
    super._transfer(from, to, amount);
    emit ForcedTransfer(from, to, amount, reason);
    return true;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override whenTokenIsActive whenCapTableIsUnlocked {
    super._beforeTokenTransfer(from, to, amount);
  }


  function addInvestorToAllowlist(address account)
    public
    onlyTransferAgent
    isNotTransferAgent(account)
    isNotScalingFundsAgent(account)
    returns (bool)
  {
    require(account != address(0), "Zero address cannot be allowlisted");
    super.grantRole(ALLOWLISTED_INVESTOR, account);
    return true;
  }

  function removeInvestorFromAllowlist(address account)
    public
    onlyTransferAgent
    returns (bool)
  {
    super.revokeRole(ALLOWLISTED_INVESTOR, account);
    return true;
  }

  function batchAddInvestorsToAllowlist(address[] calldata accounts)
    public
    onlyTransferAgent
    returns (bool)
  {
    for (uint256 i = 0; i < accounts.length; i++) {
      addInvestorToAllowlist(accounts[i]);
    }
    return true;
  }

  function batchRemoveInvestorsFromAllowlist(address[] calldata accounts)
    public
    onlyTransferAgent
    returns (bool)
  {
    for (uint256 i = 0; i < accounts.length; i++) {
      removeInvestorFromAllowlist(accounts[i]);
    }
    return true;
  }

  function getAllAllowlistedInvestors()
    external
    view
    onlyTransferAgentOrScalingFundsAgent
    returns (address[] memory)
  {
    uint256 investorCount = super.getRoleMemberCount(ALLOWLISTED_INVESTOR);
    address[] memory allowlistedInvestors = new address[](investorCount);
    for (uint256 i = 0; i < investorCount; i++) {
      address _investor = super.getRoleMember(ALLOWLISTED_INVESTOR, i);
      allowlistedInvestors[i] = _investor;
    }
    return allowlistedInvestors;
  }

  function addTransferAgent(address account)
    external
    onlyTransferAgent
    isNotAllowlistedInvestor(account)
    isNotScalingFundsAgent(account)
  {
    require(account != address(0), "Transfer agent cannot be zero address");
    super.grantRole(TRANSFER_AGENT, account);
  }

  function removeTransferAgent(address account) external onlyTransferAgent {
    super.revokeRole(TRANSFER_AGENT, account);
  }

  function getAllTransferAgents()
    external
    view
    onlyTransferAgentOrScalingFundsAgent
    returns (address[] memory)
  {
    uint256 transferAgentCount = super.getRoleMemberCount(TRANSFER_AGENT);
    address[] memory transferAgents = new address[](transferAgentCount);
    for (uint256 i = 0; i < transferAgentCount; i++) {
      address _transferAgent = super.getRoleMember(TRANSFER_AGENT, i);
      transferAgents[i] = _transferAgent;
    }
    return transferAgents;
  }

  function addScalingFundsAgent(address account)
    external
    onlyScalingFundsAgent
    isNotAllowlistedInvestor(account)
    isNotTransferAgent(account)
  {
    require(
      (account != address(0)),
      "ScalingFunds agent cannot be zero address"
    );
    super.grantRole(SCALINGFUNDS_AGENT, account);
  }

  function removeScalingFundsAgent(address account)
    external
    onlyScalingFundsAgent
  {
    super.revokeRole(SCALINGFUNDS_AGENT, account);
  }

  function getAllScalingFundsAgents()
    external
    view
    onlyScalingFundsAgent
    returns (address[] memory)
  {
    uint256 scalingfundAgentCount =
      super.getRoleMemberCount(SCALINGFUNDS_AGENT);
    address[] memory scalingfundAgents = new address[](scalingfundAgentCount);
    for (uint256 i = 0; i < scalingfundAgentCount; i++) {
      address _scalingFundsAgent = super.getRoleMember(SCALINGFUNDS_AGENT, i);
      scalingfundAgents[i] = _scalingFundsAgent;
    }
    return scalingfundAgents;
  }


  function linkPreviousContract(address _previousContractAddress)
    external
    onlyScalingFundsAgent
    onlyBeforeLaunch
  {
    require(
      address(_previousContract) == address(0),
      "_previousContract can only be linked once"
    );

    require(
      Address.isContract(_previousContractAddress),
      "_previousContractAddress must be a contract"
    );

    _previousContract = ScalingFundsToken(_previousContractAddress);

    emit PreviousContractLinked(_previousContractAddress);
  }

  function previousContractAddress() external view returns (address) {
    return address(_previousContract);
  }

  function migrateTransferAgents(address[] calldata transferAgents)
    external
    onlyScalingFundsAgent
    onlyBeforeLaunch
  {
    for (uint256 i = 0; i < transferAgents.length; i++) {
      super._setupRole(TRANSFER_AGENT, transferAgents[i]);
    }
  }

  function migrateAllowlistedInvestors(address[] calldata investors)
    external
    onlyScalingFundsAgent
    onlyBeforeLaunch
  {
    for (uint256 i = 0; i < investors.length; i++) {
      super._setupRole(ALLOWLISTED_INVESTOR, investors[i]);
    }
  }

  function migrateScalingFundsAgents(address[] calldata scalingFundsAgents)
    external
    onlyScalingFundsAgent
    onlyBeforeLaunch
  {
    for (uint256 i = 0; i < scalingFundsAgents.length; i++) {
      super._setupRole(SCALINGFUNDS_AGENT, scalingFundsAgents[i]);
    }
  }

  function migrateBalancesFromSnapshot(
    address[] calldata investors,
    uint256 snapshotId
  ) external onlyScalingFundsAgent onlyBeforeLaunch {
    for (uint256 i = 0; i < investors.length; i++) {
      address investor = investors[i];
      uint256 balance = super.balanceOf(investor);
      uint256 snapshotBalance =
        _previousContract.balanceOfAt(investor, snapshotId);
      if (balance > 0) {
        super._burn(investor, balance);
      }
      super._mint(investor, snapshotBalance);
    }
  }

  function migrateBalances(
    address[] calldata investors,
    uint256[] calldata balances
  ) external onlyScalingFundsAgent onlyBeforeLaunch returns (bool) {
    require(
      (investors.length == balances.length),
      "investors and balances do not have the same length"
    );
    for (uint256 i = 0; i < balances.length; i++) {
      address investor = investors[i];
      uint256 newBalance = balances[i];
      uint256 currentBalance = super.balanceOf(investor);
      if (currentBalance > 0) {
        super._burn(investor, currentBalance);
      }
      super._mint(investor, newBalance);
    }
    return true;
  }


  function transferFrom(
    address,
    address,
    uint256
  ) public pure override returns (bool) {
    revert("Operation Not Supported");
  }

  function approve(address, uint256) public pure override returns (bool) {
    revert("Operation Not Supported");
  }

  function allowance(address, address) public pure override returns (uint256) {
    revert("Operation Not Supported");
  }

  function increaseAllowance(address, uint256)
    public
    pure
    override
    returns (bool)
  {
    revert("Operation Not Supported");
  }

  function decreaseAllowance(address, uint256)
    public
    pure
    override
    returns (bool)
  {
    revert("Operation Not Supported");
  }

  function renounceRole(bytes32, address) public pure override {
    revert("Operation Not Supported");
  }

  function grantRole(bytes32, address) public pure override {
    revert("Operation Not Supported");
  }
}