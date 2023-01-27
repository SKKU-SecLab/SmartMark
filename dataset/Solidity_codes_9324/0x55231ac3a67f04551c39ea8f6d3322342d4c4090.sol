
pragma solidity 0.7.5;

interface ITransferHook {

    function onTransfer(
        address from,
        address to,
        uint256 amount
    ) external;

}// agpl-3.0

pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

library DistributionTypes {

    struct AssetConfigInput {
        uint128 emissionPerSecond;
        uint256 totalStaked;
        address underlyingAsset;
    }

    struct UserStakeInput {
        address underlyingAsset;
        uint256 stakedByUser;
        uint256 totalStaked;
    }
}// agpl-3.0

pragma solidity 0.7.5;


interface IStakingRewards {

    function configureAssets(DistributionTypes.AssetConfigInput[] calldata assetsConfigInput)
        external;

}// MIT

pragma solidity ^0.7.0;

library SafeMathUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity ^0.7.0;

library EnumerableSetUpgradeable {


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

pragma solidity ^0.7.0;

library AddressUpgradeable {

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

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.7.0;

abstract contract ContextUpgradeable is Initializable {
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

pragma solidity ^0.7.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
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
    uint256[49] private __gap;
}// agpl-3.0

pragma solidity 0.7.5;



contract StakingRewards is Initializable, IStakingRewards, AccessControlUpgradeable {

    bytes32 public constant EMISSION_MANAGER_ROLE = keccak256('EMISSION_MANAGER');
    using SafeMathUpgradeable for uint256;

    struct AssetData {
        uint128 emissionPerSecond;
        uint128 lastUpdateTimestamp;
        uint256 index;
        mapping(address => uint256) users;
    }

    uint256 public DISTRIBUTION_END;

    uint8 constant public PRECISION = 18;

    mapping(address => AssetData) public assets;

    event AssetConfigUpdated(address indexed asset, uint256 emission);
    event AssetIndexUpdated(address indexed asset, uint256 index);
    event UserIndexUpdated(address indexed user, address indexed asset, uint256 index);

    function __StakingRewards_init(address emissionManager, uint256 distributionDuration)
        public
        initializer
    {

        __AccessControl_init_unchained();
        DISTRIBUTION_END = block.timestamp.add(distributionDuration);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(EMISSION_MANAGER_ROLE, emissionManager);
    }

    function configureAssets(DistributionTypes.AssetConfigInput[] calldata assetsConfigInput)
        external
        override
    {

        require(hasRole(EMISSION_MANAGER_ROLE, msg.sender), 'ONLY_EMISSION_MANAGER');

        for (uint256 i = 0; i < assetsConfigInput.length; i++) {
            AssetData storage assetConfig = assets[assetsConfigInput[i].underlyingAsset];

            _updateAssetStateInternal(
                assetsConfigInput[i].underlyingAsset,
                assetConfig,
                assetsConfigInput[i].totalStaked
            );

            assetConfig.emissionPerSecond = assetsConfigInput[i].emissionPerSecond;

            emit AssetConfigUpdated(
                assetsConfigInput[i].underlyingAsset,
                assetsConfigInput[i].emissionPerSecond
            );
        }
    }

    function _updateAssetStateInternal(
        address underlyingAsset,
        AssetData storage assetConfig,
        uint256 totalStaked
    ) internal returns (uint256) {

        uint256 oldIndex = assetConfig.index;
        uint128 lastUpdateTimestamp = assetConfig.lastUpdateTimestamp;

        if (block.timestamp == lastUpdateTimestamp) {
            return oldIndex;
        }

        uint256 newIndex =
            _getAssetIndex(
                oldIndex,
                assetConfig.emissionPerSecond,
                lastUpdateTimestamp,
                totalStaked
            );

        if (newIndex != oldIndex) {
            assetConfig.index = newIndex;
            emit AssetIndexUpdated(underlyingAsset, newIndex);
        }

        assetConfig.lastUpdateTimestamp = uint128(block.timestamp);

        return newIndex;
    }

    function _updateUserAssetInternal(
        address user,
        address asset,
        uint256 stakedByUser,
        uint256 totalStaked
    ) internal returns (uint256) {

        AssetData storage assetData = assets[asset];
        uint256 userIndex = assetData.users[user];
        uint256 accruedRewards = 0;

        uint256 newIndex = _updateAssetStateInternal(asset, assetData, totalStaked);

        if (userIndex != newIndex) {
            if (stakedByUser != 0) {
                accruedRewards = _getRewards(stakedByUser, newIndex, userIndex);
            }

            assetData.users[user] = newIndex;
            emit UserIndexUpdated(user, asset, newIndex);
        }

        return accruedRewards;
    }

    function _claimRewards(address payable user, DistributionTypes.UserStakeInput[] memory stakes)
        internal
        returns (uint256)
    {

        uint256 accruedRewards = 0;

        for (uint256 i = 0; i < stakes.length; i++) {
            accruedRewards = accruedRewards.add(
                _updateUserAssetInternal(
                    user,
                    stakes[i].underlyingAsset,
                    stakes[i].stakedByUser,
                    stakes[i].totalStaked
                )
            );
        }

        return accruedRewards;
    }

    function _getUnclaimedRewards(address user, DistributionTypes.UserStakeInput[] memory stakes)
        internal
        view
        returns (uint256)
    {

        uint256 accruedRewards = 0;

        for (uint256 i = 0; i < stakes.length; i++) {
            AssetData storage assetConfig = assets[stakes[i].underlyingAsset];
            uint256 assetIndex =
                _getAssetIndex(
                    assetConfig.index,
                    assetConfig.emissionPerSecond,
                    assetConfig.lastUpdateTimestamp,
                    stakes[i].totalStaked
                );

            accruedRewards = accruedRewards.add(
                _getRewards(stakes[i].stakedByUser, assetIndex, assetConfig.users[user])
            );
        }
        return accruedRewards;
    }

    function _getRewards(
        uint256 principalUserBalance,
        uint256 reserveIndex,
        uint256 userIndex
    ) internal view returns (uint256) {

        return principalUserBalance.mul(reserveIndex.sub(userIndex)).div(10**uint256(PRECISION));
    }

    function _getAssetIndex(
        uint256 currentIndex,
        uint256 emissionPerSecond,
        uint128 lastUpdateTimestamp,
        uint256 totalBalance
    ) internal view returns (uint256) {

        if (
            emissionPerSecond == 0 ||
            totalBalance == 0 ||
            lastUpdateTimestamp == block.timestamp ||
            lastUpdateTimestamp >= DISTRIBUTION_END
        ) {
            return currentIndex;
        }

        uint256 currentTimestamp =
            block.timestamp > DISTRIBUTION_END ? DISTRIBUTION_END : block.timestamp;
        uint256 timeDelta = currentTimestamp.sub(lastUpdateTimestamp);
        return
            emissionPerSecond.mul(timeDelta).mul(10**uint256(PRECISION)).div(totalBalance).add(
                currentIndex
            );
    }

    function getUserAssetData(address user, address asset) public view returns (uint256) {

        return assets[asset].users[user];
    }
}// agpl-3.0

pragma solidity 0.7.5;

interface IStakedEthix {

    function stake(address to, uint256 amount) external;


    function redeem(address to, uint256 amount) external;


    function cooldown() external;


    function claimRewards(address payable to, uint256 amount) external;

}// gpl-3.0

pragma solidity 0.7.5;

interface IReserve {

    event Transfer(address indexed to, uint256 amount);
    event RescueFunds(address token, address indexed to, uint256 amount);

    function balance() external view returns (uint256);


    function transfer(address payable _to, uint256 _value) external returns (bool);


    function rescueFunds(
        address _tokenToRescue,
        address _to,
        uint256 _amount
    ) external;

}// MIT

pragma solidity ^0.7.0;

library MathUpgradeable {

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

pragma solidity ^0.7.0;


library ArraysUpgradeable {

    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);

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

pragma solidity ^0.7.0;


library CountersUpgradeable {

    using SafeMathUpgradeable for uint256;

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

pragma solidity ^0.7.0;

interface IERC20Upgradeable {

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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

    uint256[44] private __gap;
}// MIT

pragma solidity ^0.7.0;


abstract contract ERC20SnapshotUpgradeable is Initializable, ERC20Upgradeable {
    function __ERC20Snapshot_init() internal initializer {
        __Context_init_unchained();
        __ERC20Snapshot_init_unchained();
    }

    function __ERC20Snapshot_init_unchained() internal initializer {
    }

    using SafeMathUpgradeable for uint256;
    using ArraysUpgradeable for uint256[];
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    CountersUpgradeable.Counter private _currentSnapshotId;

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
    uint256[46] private __gap;
}// agpl-3.0
pragma solidity 0.7.5;



contract EthixERC20Snapshot is ERC20SnapshotUpgradeable {


    function __EthixERC20Snapshot_init(string memory name_, string memory symbol_)
        public
        initializer
    {

        __ERC20Snapshot_init();
        __ERC20_init(name_, symbol_);
    }

    ITransferHook public _ethixGovernance;

    function _setEthixGovernance(ITransferHook ethixGovernance) internal virtual {

        _ethixGovernance = ethixGovernance;
    }

}// MIT

pragma solidity ^0.7.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// agpl-3.0

pragma solidity 0.7.5;






contract StakedToken is Initializable, IStakedEthix, EthixERC20Snapshot, StakingRewards {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    IERC20Upgradeable public STAKED_TOKEN;
    uint256 public COOLDOWN_SECONDS;

    uint256 public UNSTAKE_WINDOW;

    IReserve public REWARDS_VAULT;

    mapping(address => uint256) public stakerRewardsToClaim;
    mapping(address => uint256) public stakersCooldowns;

    event Staked(address indexed from, address indexed onBehalfOf, uint256 amount);
    event Redeem(address indexed from, address indexed to, uint256 amount);

    event RewardsAccrued(address user, uint256 amount);
    event RewardsClaimed(address indexed from, address indexed to, uint256 amount);

    event Cooldown(address indexed user);

    function __StakedToken_init(
        string memory name,
        string memory symbol,
        uint8 decimals,
        ITransferHook ethixGovernance,
        IERC20Upgradeable stakedToken,
        uint256 cooldownSeconds,
        uint256 unstakeWindow,
        IReserve rewardsVault,
        address emissionManager,
        uint128 distributionDuration
    ) internal initializer {

        __EthixERC20Snapshot_init(name, symbol);
        _setupDecimals(decimals);
        _setEthixGovernance(ethixGovernance);
        __StakingRewards_init(emissionManager, distributionDuration);
        STAKED_TOKEN = stakedToken;
        COOLDOWN_SECONDS = cooldownSeconds;
        UNSTAKE_WINDOW = unstakeWindow;
        REWARDS_VAULT = rewardsVault;
    }

    function stake(address onBehalfOf, uint256 amount) external override {

        require(amount != 0, 'INVALID_ZERO_AMOUNT');
        uint256 balanceOfUser = balanceOf(onBehalfOf);

        uint256 accruedRewards =
            _updateUserAssetInternal(onBehalfOf, address(this), balanceOfUser, totalSupply());
        if (accruedRewards != 0) {
            emit RewardsAccrued(onBehalfOf, accruedRewards);
            stakerRewardsToClaim[onBehalfOf] = stakerRewardsToClaim[onBehalfOf].add(accruedRewards);
        }

        stakersCooldowns[onBehalfOf] = getNextCooldownTimestamp(
            0,
            amount,
            onBehalfOf,
            balanceOfUser
        );

        _mint(onBehalfOf, amount);
        IERC20Upgradeable(STAKED_TOKEN).safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, onBehalfOf, amount);
    }

    function redeem(address to, uint256 amount) external override {

        require(amount != 0, 'INVALID_ZERO_AMOUNT');
        uint256 cooldownStartTimestamp = stakersCooldowns[msg.sender];
        require(
            block.timestamp > cooldownStartTimestamp.add(COOLDOWN_SECONDS),
            'INSUFFICIENT_COOLDOWN'
        );
        require(
            block.timestamp.sub(cooldownStartTimestamp.add(COOLDOWN_SECONDS)) <= UNSTAKE_WINDOW,
            'UNSTAKE_WINDOW_FINISHED'
        );
        uint256 balanceOfMessageSender = balanceOf(msg.sender);

        uint256 amountToRedeem =
            (amount > balanceOfMessageSender) ? balanceOfMessageSender : amount;

        _updateCurrentUnclaimedRewards(msg.sender, balanceOfMessageSender, true);

        _burn(msg.sender, amountToRedeem);

        if (balanceOfMessageSender.sub(amountToRedeem) == 0) {
            stakersCooldowns[msg.sender] = 0;
        }

        IERC20Upgradeable(STAKED_TOKEN).safeTransfer(to, amountToRedeem);

        emit Redeem(msg.sender, to, amountToRedeem);
    }

    function cooldown() external override {

        require(balanceOf(msg.sender) != 0, 'INVALID_BALANCE_ON_COOLDOWN');
        stakersCooldowns[msg.sender] = block.timestamp;

        emit Cooldown(msg.sender);
    }

    function claimRewards(address payable to, uint256 amount) external override {

        uint256 newTotalRewards =
            _updateCurrentUnclaimedRewards(msg.sender, balanceOf(msg.sender), false);
        uint256 amountToClaim = (amount == type(uint256).max) ? newTotalRewards : amount;

        stakerRewardsToClaim[msg.sender] = newTotalRewards.sub(amountToClaim, 'INVALID_AMOUNT');

        require(REWARDS_VAULT.transfer(to, amountToClaim), 'ERROR_TRANSFER_FROM_VAULT');

        emit RewardsClaimed(msg.sender, to, amountToClaim);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        uint256 balanceOfFrom = balanceOf(from);
        _updateCurrentUnclaimedRewards(from, balanceOfFrom, true);

        if (from != to) {
            uint256 balanceOfTo = balanceOf(to);
            _updateCurrentUnclaimedRewards(to, balanceOfTo, true);

            uint256 previousSenderCooldown = stakersCooldowns[from];
            stakersCooldowns[to] = getNextCooldownTimestamp(
                previousSenderCooldown,
                amount,
                to,
                balanceOfTo
            );
            if (balanceOfFrom == amount && previousSenderCooldown != 0) {
                stakersCooldowns[from] = 0;
            }
        }

        super._transfer(from, to, amount);
    }

    function _updateCurrentUnclaimedRewards(
        address user,
        uint256 userBalance,
        bool updateStorage
    ) internal returns (uint256) {

        uint256 accruedRewards =
            _updateUserAssetInternal(user, address(this), userBalance, totalSupply());
        uint256 unclaimedRewards = stakerRewardsToClaim[user].add(accruedRewards);

        if (accruedRewards != 0) {
            if (updateStorage) {
                stakerRewardsToClaim[user] = unclaimedRewards;
            }
            emit RewardsAccrued(user, accruedRewards);
        }

        return unclaimedRewards;
    }

    function getNextCooldownTimestamp(
        uint256 _fromCooldownTimestamp,
        uint256 _amountToReceive,
        address _toAddress,
        uint256 _toBalance
    ) public returns (uint256) {

        uint256 toCooldownTimestamp = stakersCooldowns[_toAddress];
        if (toCooldownTimestamp == 0) {
            return 0;
        }

        uint256 minimalValidCooldownTimestamp =
            block.timestamp.sub(COOLDOWN_SECONDS).sub(UNSTAKE_WINDOW);

        if (minimalValidCooldownTimestamp > toCooldownTimestamp) {
            toCooldownTimestamp = 0;
        } else {
            uint256 fromCooldownTimestamp =
                (minimalValidCooldownTimestamp > _fromCooldownTimestamp)
                    ? block.timestamp
                    : _fromCooldownTimestamp;

            if (fromCooldownTimestamp < toCooldownTimestamp) {
                return toCooldownTimestamp;
            } else {
                toCooldownTimestamp = (
                    _amountToReceive.mul(fromCooldownTimestamp).add(
                        _toBalance.mul(toCooldownTimestamp)
                    )
                )
                    .div(_amountToReceive.add(_toBalance));
            }
        }
        stakersCooldowns[_toAddress] = toCooldownTimestamp;

        return toCooldownTimestamp;
    }

    function getTotalRewardsBalance(address staker) external view returns (uint256) {

        DistributionTypes.UserStakeInput[] memory userStakeInputs =
            new DistributionTypes.UserStakeInput[](1);
        userStakeInputs[0] = DistributionTypes.UserStakeInput({
            underlyingAsset: address(this),
            stakedByUser: balanceOf(staker),
            totalStaked: totalSupply()
        });
        return stakerRewardsToClaim[staker].add(_getUnclaimedRewards(staker, userStakeInputs));
    }
}// gpl-3.0

pragma solidity 0.7.5;


contract StakedETHIX is StakedToken {

    function initialize(
        IERC20Upgradeable stakedToken,
        ITransferHook ethixGovernance,
        uint256 cooldownSeconds,
        uint256 unstakeWindow,
        IReserve rewardsVault,
        address emissionManager,
        uint128 distributionDuration
    ) public initializer {

        __StakedToken_init(
            'Staked ETHIX',
            'stkETHIX',
            18,
            ethixGovernance,
            stakedToken,
            cooldownSeconds,
            unstakeWindow,
            rewardsVault,
            emissionManager,
            distributionDuration
        );
    }
}