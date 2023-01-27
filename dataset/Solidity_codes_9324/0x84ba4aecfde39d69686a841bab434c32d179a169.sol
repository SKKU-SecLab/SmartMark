
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

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
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

    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view virtual returns(uint256) {
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

interface IERC20Permit {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    constructor(string memory name, string memory version) internal {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = _getChainId();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view virtual returns (bytes32) {
        if (_getChainId() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }
}// MIT

pragma solidity >=0.6.5 <0.8.0;


abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;

    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) internal EIP712(name, "1") {
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _nonces[owner].current(),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
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
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
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
pragma solidity 0.7.6;
pragma abicoder v2;


interface ITimelockConfig {

    struct Config {
        bytes32 id;
        uint256 value;
    }

    struct PendingRequest {
        bytes32 id;
        uint256 value;
        uint256 timestamp;
    }


    event ChangeRequested(bytes32 configID, uint256 value);
    event ChangeConfirmed(bytes32 configID, uint256 value);
    event ChangeCanceled(bytes32 configID, uint256 value);


    function confirmChange(bytes32 configID) external;


    function requestChange(bytes32 configID, uint256 value) external;

    function cancelChange(bytes32 configID) external;


    function calculateConfigID(string memory name) external pure returns (bytes32 configID);


    function getConfig(bytes32 configID) external view returns (Config memory config);

    function isConfig(bytes32 configID) external view returns (bool status);

    function getConfigCount() external view returns (uint256 count);

    function getConfigByIndex(uint256 index) external view returns (Config memory config);

    function getPending(bytes32 configID)
        external
        view
        returns (PendingRequest memory pendingRequest);

    function isPending(bytes32 configID) external view returns (bool status);

    function getPendingCount() external view returns (uint256 count);

    function getPendingByIndex(uint256 index)
        external
        view
        returns (PendingRequest memory pendingRequest);
}

contract TimelockConfig is ITimelockConfig {
    using EnumerableSet for EnumerableSet.Bytes32Set;


    bytes32 public constant ADMIN_CONFIG_ID = keccak256("Admin");
    bytes32 public constant TIMELOCK_CONFIG_ID = keccak256("Timelock");


    struct InternalPending {
        uint256 value;
        uint256 timestamp;
    }

    mapping(bytes32 => uint256) _config;
    EnumerableSet.Bytes32Set _configSet;

    mapping(bytes32 => InternalPending) _pending;
    EnumerableSet.Bytes32Set _pendingSet;


    modifier onlyAdmin() {
        require(msg.sender == address(_config[ADMIN_CONFIG_ID]), "only admin");
        _;
    }


    constructor(address admin, uint256 timelock) {
        _setRawConfig(ADMIN_CONFIG_ID, uint256(admin));
        _setRawConfig(TIMELOCK_CONFIG_ID, timelock);
    }


    function confirmChange(bytes32 configID) external override onlyAdmin {
        require(isPending(configID), "No pending configID found");

        require(
            block.timestamp >= _pending[configID].timestamp + _config[TIMELOCK_CONFIG_ID],
            "too early"
        );

        uint256 value = _pending[configID].value;

        _configSet.add(configID);
        _config[configID] = value;

        _pendingSet.remove(configID);
        delete _pending[configID];

        emit ChangeConfirmed(configID, value);
    }


    function requestChange(bytes32 configID, uint256 value) external override onlyAdmin {
        require(_pendingSet.add(configID), "request already exists");

        _pending[configID] = InternalPending(value, block.timestamp);

        emit ChangeRequested(configID, value);
    }

    function cancelChange(bytes32 configID) external override onlyAdmin {
        require(_pendingSet.remove(configID), "no pending request");

        uint256 value = _pending[configID].value;

        delete _pending[configID];

        emit ChangeCanceled(configID, value);
    }


    function _setRawConfig(bytes32 configID, uint256 value) internal {
        _configSet.add(configID);
        _config[configID] = value;

        emit ChangeRequested(configID, value);
        emit ChangeConfirmed(configID, value);
    }


    function calculateConfigID(string memory name) public pure override returns (bytes32 configID) {
        return keccak256(abi.encodePacked(name));
    }


    function isConfig(bytes32 configID) public view override returns (bool status) {
        return _configSet.contains(configID);
    }

    function getConfigCount() public view override returns (uint256 count) {
        return _configSet.length();
    }

    function getConfigByIndex(uint256 index)
        public
        view
        override
        returns (ITimelockConfig.Config memory config)
    {
        bytes32 configID = _configSet.at(index);
        return ITimelockConfig.Config(configID, _config[configID]);
    }

    function getConfig(bytes32 configID)
        public
        view
        override
        returns (ITimelockConfig.Config memory config)
    {
        require(_configSet.contains(configID), "not config");
        return ITimelockConfig.Config(configID, _config[configID]);
    }

    function isPending(bytes32 configID) public view override returns (bool status) {
        return _pendingSet.contains(configID);
    }

    function getPendingCount() public view override returns (uint256 count) {
        return _pendingSet.length();
    }

    function getPendingByIndex(uint256 index)
        public
        view
        override
        returns (ITimelockConfig.PendingRequest memory pendingRequest)
    {
        bytes32 configID = _pendingSet.at(index);
        return
            ITimelockConfig.PendingRequest(
                configID,
                _pending[configID].value,
                _pending[configID].timestamp
            );
    }

    function getPending(bytes32 configID)
        public
        view
        override
        returns (ITimelockConfig.PendingRequest memory pendingRequest)
    {
        require(_pendingSet.contains(configID), "not pending");
        return
            ITimelockConfig.PendingRequest(
                configID,
                _pending[configID].value,
                _pending[configID].timestamp
            );
    }
}// MIT
pragma solidity 0.7.6;
// pragma experimental SMTChecker;


interface IMethodToken {

    event Advanced(uint256 epoch, uint256 supplyMinted);


    function advance() external;


    function getAdmin() external view returns (address admin);

    function getTreasurer() external view returns (address treasurer);

    function getDistributor() external view returns (address distributor);

    function getTimelock() external view returns (uint256 timelock);

    function getInflation() external view returns (uint256 inflation);

    function getEpochDuration() external view returns (uint256 epochDuration);
}

contract MethodToken is
    IMethodToken,
    ERC20("Method", "MTHD"),
    ERC20Burnable,
    ERC20Snapshot,
    ERC20Permit("Method"),
    TimelockConfig
{

    bytes32 public constant INFLATION_CONFIG_ID = keccak256("Inflation");
    bytes32 public constant EPOCH_DURATION_CONFIG_ID = keccak256("EpochDuration");
    bytes32 public constant DISTRIBUTOR_CONFIG_ID = keccak256("Distributor");
    bytes32 public constant TREASURER_CONFIG_ID = keccak256("Treasurer");


    uint256 private _epoch;
    uint256 private _previousEpochTimestamp;


    constructor(
        address admin,
        address distributor,
        address treasurer,
        uint256 inflation,
        uint256 epochDuration,
        uint256 timelock,
        uint256 supply,
        uint256 epochStart
    ) TimelockConfig(admin, timelock) {
        TimelockConfig._setRawConfig(DISTRIBUTOR_CONFIG_ID, uint256(distributor));
        TimelockConfig._setRawConfig(TREASURER_CONFIG_ID, uint256(treasurer));
        TimelockConfig._setRawConfig(INFLATION_CONFIG_ID, inflation);
        TimelockConfig._setRawConfig(EPOCH_DURATION_CONFIG_ID, epochDuration);

        _previousEpochTimestamp = epochStart;

        ERC20._mint(treasurer, supply);
    }


    function advance() external override {
        require(
            block.timestamp >= _previousEpochTimestamp + getEpochDuration(),
            "not ready to advance"
        );
        _epoch++;
        _previousEpochTimestamp = block.timestamp;
        ERC20Snapshot._snapshot();
        uint256 supplyMinted = getInflation();

        ERC20._mint(getTreasurer(), supplyMinted/2);
        ERC20._mint(getDistributor(), supplyMinted/2);
        
        emit Advanced(_epoch, supplyMinted);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Snapshot) {
        ERC20Snapshot._beforeTokenTransfer(from, to, amount);
    }

    function getEpoch() public view returns (uint256 epoch) {
        return _epoch;
    }

    function getAdmin() public view override returns (address admin) {
        return address(TimelockConfig.getConfig(TimelockConfig.ADMIN_CONFIG_ID).value);
    }

    function getTreasurer() public view override returns (address treasurer) {
        return address(TimelockConfig.getConfig(TREASURER_CONFIG_ID).value);
    }

    function getDistributor() public view override returns (address distributor) {
        return address(TimelockConfig.getConfig(DISTRIBUTOR_CONFIG_ID).value);
    }

    function getTimelock() public view override returns (uint256 timelock) {
        return TimelockConfig.getConfig(TimelockConfig.TIMELOCK_CONFIG_ID).value;
    }

    function getInflation() public view override returns (uint256 inflation) {
        return TimelockConfig.getConfig(INFLATION_CONFIG_ID).value;
    }

    function getEpochDuration() public view override returns (uint256 epochDuration) {
        return TimelockConfig.getConfig(EPOCH_DURATION_CONFIG_ID).value;
    }
}