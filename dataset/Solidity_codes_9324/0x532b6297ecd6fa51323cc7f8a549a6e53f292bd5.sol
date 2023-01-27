
pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;


abstract contract Poolable is Initializable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;

    struct Pool {
        uint256 lockDuration; // locked timespan
        bool opened; // flag indicating if the pool is open
    }

    mapping(uint256 => Pool) private _pools;
    uint256 public poolsLength;

    event PoolAdded(uint256 poolIndex, Pool pool);

    event PoolUpdated(uint256 poolIndex, Pool pool);

    modifier whenPoolOpened(uint256 poolIndex) {
        require(poolIndex < poolsLength, "Poolable: Invalid poolIndex");
        require(_pools[poolIndex].opened, "Poolable: Pool is closed");
        _;
    }

    modifier whenUnlocked(uint256 poolIndex, uint256 depositDate) {
        require(poolIndex < poolsLength, "Poolable: Invalid poolIndex");
        require(
            depositDate < block.timestamp,
            "Poolable: Invalid deposit date"
        );
        require(
            block.timestamp - depositDate >= _pools[poolIndex].lockDuration,
            "Poolable: Not unlocked"
        );
        _;
    }

    function __Poolable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Poolable_init_unchained();
    }

    function __Poolable_init_unchained() internal onlyInitializing {}

    function getPool(uint256 poolIndex) public view returns (Pool memory) {
        require(poolIndex < poolsLength, "Poolable: Invalid poolIndex");
        return _pools[poolIndex];
    }

    function addPool(Pool calldata pool) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 poolIndex = poolsLength;

        _pools[poolIndex] = Pool({
            lockDuration: pool.lockDuration,
            opened: pool.opened
        });
        poolsLength = poolsLength + 1;

        emit PoolAdded(poolIndex, _pools[poolIndex]);
    }

    function updatePool(uint256 poolIndex, Pool calldata pool)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(poolIndex < poolsLength, "Poolable: Invalid poolIndex");
        Pool storage editedPool = _pools[poolIndex];

        editedPool.lockDuration = pool.lockDuration;
        editedPool.opened = pool.opened;

        emit PoolUpdated(poolIndex, editedPool);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract Depositable is Initializable, AccessControlUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private _deposits;

    IERC20Upgradeable public depositToken;

    uint256 public totalDeposit;

    event Deposit(address indexed from, address indexed to, uint256 amount);

    event Withdraw(address indexed to, uint256 amount);

    event DepositTokenChange(address indexed token);

    function __Depositable_init(IERC20Upgradeable _depositToken)
        internal
        onlyInitializing
    {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Depositable_init_unchained(_depositToken);
    }

    function __Depositable_init_unchained(IERC20Upgradeable _depositToken)
        internal
        onlyInitializing
    {
        depositToken = _depositToken;
    }

    function _deposit(
        address from,
        address to,
        uint256 amount
    ) internal virtual returns (uint256) {
        uint256 balance = depositToken.balanceOf(address(this));
        depositToken.safeTransferFrom(from, address(this), amount);
        uint256 newBalance = depositToken.balanceOf(address(this));

        amount = newBalance.sub(balance);

        _deposits[to] = _deposits[to].add(amount);
        totalDeposit = totalDeposit.add(amount);
        emit Deposit(from, to, amount);

        return amount;
    }

    function _withdraw(address to, uint256 amount)
        internal
        virtual
        returns (uint256)
    {
        require(amount <= _deposits[to], "Depositable: amount too high");

        _deposits[to] = _deposits[to].sub(amount);
        totalDeposit = totalDeposit.sub(amount);
        depositToken.safeTransfer(to, amount);

        emit Withdraw(to, amount);
        return amount;
    }

    function depositOf(address _address) public view virtual returns (uint256) {
        return _deposits[_address];
    }

    function changeDepositToken(IERC20Upgradeable _depositToken)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(totalDeposit == 0, "Depositable: total deposit != 0");
        depositToken = _depositToken;

        emit DepositTokenChange(address(_depositToken));
    }

    uint256[50] private __gap;
}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract PoolDepositable is
    Initializable,
    AccessControlUpgradeable,
    Poolable,
    Depositable
{
    using SafeMathUpgradeable for uint256;

    struct UserPoolDeposit {
        uint256 poolIndex; // index of the pool
        uint256 amount; // amount deposited in the pool
        uint256 depositDate; // date of last deposit
    }

    struct BatchDeposit {
        address to; // destination address
        uint256 amount; // amount deposited
        uint256 poolIndex; // index of the pool
    }

    mapping(address => UserPoolDeposit[]) private _poolDeposits;

    event PoolDeposit(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 poolIndex
    );

    event PoolWithdraw(address indexed to, uint256 amount, uint256 poolIndex);

    function __PoolDepositable_init(IERC20Upgradeable _depositToken)
        internal
        onlyInitializing
    {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Poolable_init_unchained();
        __Depositable_init_unchained(_depositToken);
        __PoolDepositable_init_unchained();
    }

    function __PoolDepositable_init_unchained() internal onlyInitializing {}

    function _indexOfPoolDeposit(address account, uint256 poolIndex)
        private
        view
        returns (int256)
    {
        for (uint256 i = 0; i < _poolDeposits[account].length; i++) {
            if (_poolDeposits[account][i].poolIndex == poolIndex) {
                return int256(i);
            }
        }
        return -1;
    }

    function poolDepositsOf(address account)
        public
        view
        returns (UserPoolDeposit[] memory)
    {
        return _poolDeposits[account];
    }

    function poolDepositOf(address account, uint256 poolIndex)
        external
        view
        returns (UserPoolDeposit memory poolDeposit)
    {
        int256 depositIndex = _indexOfPoolDeposit(account, poolIndex);
        if (depositIndex > -1) {
            poolDeposit = _poolDeposits[account][uint256(depositIndex)];
        }
    }

    function _deposit(
        address,
        address,
        uint256
    ) internal pure virtual override returns (uint256) {
        revert("PoolDepositable: Must deposit with poolIndex");
    }

    function _withdraw(address, uint256)
        internal
        pure
        virtual
        override
        returns (uint256)
    {
        revert("PoolDepositable: Must withdraw with poolIndex");
    }

    function _deposit(
        address from,
        address to,
        uint256 amount,
        uint256 poolIndex
    ) internal virtual whenPoolOpened(poolIndex) returns (uint256) {
        uint256 depositAmount = Depositable._deposit(from, to, amount);

        int256 depositIndex = _indexOfPoolDeposit(to, poolIndex);
        if (depositIndex > -1) {
            UserPoolDeposit storage pool = _poolDeposits[to][
                uint256(depositIndex)
            ];
            pool.amount = pool.amount.add(depositAmount);
            pool.depositDate = block.timestamp; // update date to last deposit
        } else {
            _poolDeposits[to].push(
                UserPoolDeposit({
                    poolIndex: poolIndex,
                    amount: depositAmount,
                    depositDate: block.timestamp
                })
            );
        }

        emit PoolDeposit(from, to, amount, poolIndex);
        return depositAmount;
    }

    function _withdrawPoolDeposit(
        address to,
        uint256 amount,
        UserPoolDeposit storage poolDeposit
    )
        private
        whenUnlocked(poolDeposit.poolIndex, poolDeposit.depositDate)
        returns (uint256)
    {
        require(
            poolDeposit.amount >= amount,
            "PoolDepositable: Pool deposit less than amount"
        );
        require(poolDeposit.amount > 0, "PoolDepositable: No deposit in pool");

        uint256 withdrawAmount = Depositable._withdraw(to, amount);
        poolDeposit.amount = poolDeposit.amount.sub(withdrawAmount);

        emit PoolWithdraw(to, amount, poolDeposit.poolIndex);
        return withdrawAmount;
    }

    function _withdraw(
        address to,
        uint256 amount,
        uint256 poolIndex
    ) internal virtual returns (uint256) {
        int256 depositIndex = _indexOfPoolDeposit(to, poolIndex);
        require(depositIndex > -1, "PoolDepositable: Not deposited");
        return
            _withdrawPoolDeposit(
                to,
                amount,
                _poolDeposits[to][uint256(depositIndex)]
            );
    }

    function batchDeposits(address from, BatchDeposit[] memory deposits)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < deposits.length; i++) {
            _deposit(
                from,
                deposits[i].to,
                deposits[i].amount,
                deposits[i].poolIndex
            );
        }
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// UNLICENSED

pragma solidity ^0.8.0;

interface ITierable {

    function tierOf(address account) external returns (int256);

}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract Tierable is
    Initializable,
    AccessControlUpgradeable,
    Depositable,
    ITierable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256[] private _tiersMinAmount;
    EnumerableSet.AddressSet private _whitelist;

    event TiersMinAmountChange(uint256[] amounts);

    event AddToWhitelist(address account);

    event RemoveFromWhitelist(address account);

    function __Tierable_init(
        IERC20Upgradeable _depositToken,
        uint256[] memory tiersMinAmount
    ) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Depositable_init_unchained(_depositToken);
        __Tierable_init_unchained(tiersMinAmount);
    }

    function __Tierable_init_unchained(uint256[] memory tiersMinAmount)
        internal
        onlyInitializing
    {
        _tiersMinAmount = tiersMinAmount;
    }

    function tierOf(address account) public view override returns (int256) {
        uint256 max = _tiersMinAmount.length;

        if (_whitelist.contains(account)) {
            return int256(max) - 1;
        }

        uint256 balance = depositOf(account);
        for (uint256 i = 0; i < max; i++) {
            if (balance < _tiersMinAmount[i]) return int256(i) - 1;
        }
        return int256(max) - 1;
    }

    function changeTiersMinAmount(uint256[] memory tiersMinAmount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _tiersMinAmount = tiersMinAmount;
        emit TiersMinAmountChange(_tiersMinAmount);
    }

    function getTiersMinAmount() external view returns (uint256[] memory) {
        return _tiersMinAmount;
    }

    function addToWhitelist(address[] memory accounts)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            bool result = _whitelist.add(accounts[i]);
            if (result) emit AddToWhitelist(accounts[i]);
        }
    }

    function removeFromWhitelist(address[] memory accounts)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            bool result = _whitelist.remove(accounts[i]);
            if (result) emit RemoveFromWhitelist(accounts[i]);
        }
    }

    function getWhitelist()
        external
        view
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (address[] memory)
    {
        return _whitelist.values();
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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
}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract Suspendable is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    function __Suspendable_init(address _pauser) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        __Suspendable_init_unchained(_pauser);
    }

    function __Suspendable_init_unchained(address _pauser)
        internal
        onlyInitializing
    {
        _setupRole(PAUSER_ROLE, _pauser);
    }

    function suspended() public view virtual returns (bool) {
        return paused();
    }

    function suspend() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function resume() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    uint256[50] private __gap;
}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract PoolVestingable is Initializable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;

    struct VestingPool {
        uint256[] timestamps; // Timestamp at which the associated ratio is available.
        uint256[] ratiosPerHundredThousand; // Ratio of initial amount to be available at the associated timestamp in / 100,000 (100% = 100,000, 1% = 1,000)
    }

    VestingPool[] private _pools;

    event VestingPoolAdded(uint256 poolIndex, VestingPool pool);

    event VestingPoolUpdated(uint256 poolIndex, VestingPool pool);

    modifier checkVestingPool(VestingPool calldata pool) {
        require(
            pool.timestamps.length == pool.ratiosPerHundredThousand.length,
            "PoolVestingable: Number of timestamps is not equal to number of ratios"
        );

        for (uint256 i = 1; i < pool.timestamps.length; i++) {
            require(
                pool.timestamps[i - 1] < pool.timestamps[i],
                "PoolVestingable: Timestamps be asc ordered"
            );
        }

        uint256 totalRatio = 0;
        for (uint256 i = 0; i < pool.ratiosPerHundredThousand.length; i++) {
            totalRatio = totalRatio.add(pool.ratiosPerHundredThousand[i]);
        }
        require(
            totalRatio == 100000,
            "PoolVestingable: Sum of ratios per thousand must be equal to 100,000"
        );

        _;
    }

    function __PoolVestingable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __PoolVestingable_init_unchained();
    }

    function __PoolVestingable_init_unchained() internal onlyInitializing {}

    function getVestingPool(uint256 poolIndex)
        public
        view
        returns (VestingPool memory)
    {
        require(
            poolIndex < _pools.length,
            "PoolVestingable: Invalid poolIndex"
        );
        return _pools[poolIndex];
    }

    function vestingPoolsLength() public view returns (uint256) {
        return _pools.length;
    }

    function addVestingPool(VestingPool calldata pool)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        checkVestingPool(pool)
    {
        _pools.push(
            VestingPool({
                timestamps: pool.timestamps,
                ratiosPerHundredThousand: pool.ratiosPerHundredThousand
            })
        );

        emit VestingPoolAdded(_pools.length - 1, _pools[_pools.length - 1]);
    }

    function updateVestingPool(uint256 poolIndex, VestingPool calldata pool)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        checkVestingPool(pool)
    {
        require(
            poolIndex < _pools.length,
            "PoolVestingable: Invalid poolIndex"
        );
        VestingPool storage editedPool = _pools[poolIndex];

        editedPool.timestamps = pool.timestamps;
        editedPool.ratiosPerHundredThousand = pool.ratiosPerHundredThousand;

        emit VestingPoolUpdated(poolIndex, editedPool);
    }

    uint256[50] private __gap;
}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract PoolVestingDepositable is
    Initializable,
    PoolVestingable,
    Depositable
{
    using SafeMathUpgradeable for uint256;

    struct UserVestingPoolDeposit {
        uint256 initialAmount; // initial amount deposited in the pool
        uint256 withdrawnAmount; // amount already withdrawn from the pool
    }

    mapping(address => mapping(uint256 => UserVestingPoolDeposit))
        private _poolDeposits;

    event VestingPoolDeposit(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 poolIndex
    );

    event VestingPoolWithdraw(
        address indexed to,
        uint256 amount,
        uint256 poolIndex
    );

    event VestingPoolTransfer(
        address indexed account,
        uint256 amount,
        uint256 fromPoolIndex,
        uint256 toPoolIndex
    );

    function __PoolVestingDepositable_init(IERC20Upgradeable _depositToken)
        internal
        onlyInitializing
    {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __PoolVestingable_init_unchained();
        __Depositable_init_unchained(_depositToken);
        __PoolVestingDepositable_init_unchained();
    }

    function __PoolVestingDepositable_init_unchained()
        internal
        onlyInitializing
    {}

    function _vestedAmountOf(address account, uint256 poolIndex)
        private
        view
        returns (uint256 vestedAmount)
    {
        VestingPool memory pool = getVestingPool(poolIndex);
        for (uint256 i = 0; i < pool.timestamps.length; i++) {
            if (block.timestamp >= pool.timestamps[i]) {
                uint256 scheduleAmount = _poolDeposits[account][poolIndex]
                    .initialAmount
                    .mul(pool.ratiosPerHundredThousand[i])
                    .div(100000);
                vestedAmount = vestedAmount.add(scheduleAmount);
            }
        }
    }

    function _withdrawableAmountOf(address account, uint256 poolIndex)
        private
        view
        returns (uint256)
    {
        require(
            poolIndex < vestingPoolsLength(),
            "PoolVestingDepositable: Invalid poolIndex"
        );
        return
            _vestedAmountOf(account, poolIndex).sub(
                _poolDeposits[account][poolIndex].withdrawnAmount
            );
    }

    function vestingPoolDepositOf(address account, uint256 poolIndex)
        external
        view
        returns (UserVestingPoolDeposit memory)
    {
        require(
            poolIndex < vestingPoolsLength(),
            "PoolVestingDepositable: Invalid poolIndex"
        );
        return _poolDeposits[account][poolIndex];
    }

    function vestingPoolVestedAmountOf(address account, uint256 poolIndex)
        external
        view
        returns (uint256)
    {
        return _vestedAmountOf(account, poolIndex);
    }

    function vestingPoolWithdrawableAmountOf(address account, uint256 poolIndex)
        external
        view
        returns (uint256)
    {
        return _withdrawableAmountOf(account, poolIndex);
    }

    function _deposit(
        address,
        address,
        uint256
    ) internal pure virtual override returns (uint256) {
        revert("PoolVestingDepositable: Must deposit with poolIndex");
    }

    function _withdraw(address, uint256)
        internal
        pure
        virtual
        override
        returns (uint256)
    {
        revert("PoolVestingDepositable: Must withdraw with poolIndex");
    }

    function _savePoolDeposit(
        address from,
        address to,
        uint256 amount,
        uint256 poolIndex
    ) private {
        require(
            poolIndex < vestingPoolsLength(),
            "PoolVestingDepositable: Invalid poolIndex"
        );
        UserVestingPoolDeposit storage poolDeposit = _poolDeposits[to][
            poolIndex
        ];
        poolDeposit.initialAmount = poolDeposit.initialAmount.add(amount);
        emit VestingPoolDeposit(from, to, amount, poolIndex);
    }

    function _batchDeposits(
        address from,
        address[] memory to,
        uint256[] memory amounts,
        uint256 poolIndex
    ) internal virtual returns (uint256) {
        require(
            to.length == amounts.length,
            "PoolVestingDepositable: arrays to and amounts have different length"
        );

        uint256 totalTransferredAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            uint256 transferredAmount = Depositable._deposit(
                from,
                to[i],
                amounts[i]
            );
            _savePoolDeposit(from, to[i], transferredAmount, poolIndex);
            totalTransferredAmount = totalTransferredAmount.add(
                transferredAmount
            );
        }

        return totalTransferredAmount;
    }

    function _withdraw(
        address to,
        uint256 amount,
        uint256 poolIndex
    ) internal virtual returns (uint256) {
        require(
            poolIndex < vestingPoolsLength(),
            "PoolVestingDepositable: Invalid poolIndex"
        );
        UserVestingPoolDeposit storage poolDeposit = _poolDeposits[to][
            poolIndex
        ];
        uint256 withdrawableAmount = _withdrawableAmountOf(to, poolIndex);

        require(
            withdrawableAmount >= amount,
            "PoolVestingDepositable: Withdrawable amount less than amount to withdraw"
        );
        require(
            withdrawableAmount > 0,
            "PoolVestingDepositable: No withdrawable amount to withdraw"
        );

        uint256 withdrawAmount = Depositable._withdraw(to, amount);
        poolDeposit.withdrawnAmount = poolDeposit.withdrawnAmount.add(
            withdrawAmount
        );

        emit VestingPoolWithdraw(to, amount, poolIndex);
        return withdrawAmount;
    }

    function _transferVestingPoolDeposit(
        address account,
        uint256 amount,
        uint256 fromPoolIndex,
        uint256 toPoolIndex
    ) internal {
        require(
            fromPoolIndex < vestingPoolsLength(),
            "PoolVestingDepositable: Invalid fromPoolIndex"
        );
        require(
            toPoolIndex < vestingPoolsLength(),
            "PoolVestingDepositable: Invalid toPoolIndex"
        );

        UserVestingPoolDeposit storage poolDepositFrom = _poolDeposits[account][
            fromPoolIndex
        ];
        UserVestingPoolDeposit storage poolDepositTo = _poolDeposits[account][
            toPoolIndex
        ];

        require(
            poolDepositTo.withdrawnAmount == 0,
            "PoolVestingDepositable: Cannot transfer amount if withdrawnAmount is not equal to 0"
        );

        poolDepositTo.initialAmount = poolDepositTo.initialAmount.add(amount);
        poolDepositFrom.initialAmount = poolDepositFrom.initialAmount.sub(
            amount
        );

        emit VestingPoolTransfer(account, amount, fromPoolIndex, toPoolIndex);
    }

    uint256[50] private __gap;
}// UNLICENSED

pragma solidity ^0.8.0;


contract LockedLBToken is
    Initializable,
    PoolDepositable,
    Tierable,
    Suspendable,
    PoolVestingDepositable
{

    function initialize(
        IERC20Upgradeable _depositToken,
        uint256[] memory tiersMinAmount,
        address _pauser
    ) external initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Poolable_init_unchained();
        __Depositable_init_unchained(_depositToken);
        __PoolDepositable_init_unchained();
        __Tierable_init_unchained(tiersMinAmount);
        __Pausable_init_unchained();
        __Suspendable_init_unchained(_pauser);
        __PoolVestingable_init_unchained();
        __PoolVestingDepositable_init_unchained();
        __LockedLBToken_init_unchained();
    }

    function __LockedLBToken_init_unchained() internal onlyInitializing {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function _deposit(
        address,
        address,
        uint256
    )
        internal
        pure
        override(PoolDepositable, Depositable, PoolVestingDepositable)
        returns (uint256)
    {

        revert("LockedLBToken: Must deposit with poolIndex");
    }

    function _withdraw(address, uint256)
        internal
        pure
        override(PoolDepositable, Depositable, PoolVestingDepositable)
        returns (uint256)
    {

        revert("LockedLBToken: Must withdraw with poolIndex");
    }

    function _withdraw(
        address,
        uint256,
        uint256
    )
        internal
        pure
        override(PoolDepositable, PoolVestingDepositable)
        returns (uint256)
    {

        revert("LockedLBToken: Must withdraw with on a specific pool type");
    }

    function deposit(uint256 amount, uint256 poolIndex) external whenNotPaused {

        PoolDepositable._deposit(_msgSender(), _msgSender(), amount, poolIndex);
    }

    function withdraw(uint256 amount, uint256 poolIndex)
        external
        whenNotPaused
    {

        PoolDepositable._withdraw(_msgSender(), amount, poolIndex);
    }

    function vestingBatchDeposits(
        address from,
        address[] memory to,
        uint256[] memory amounts,
        uint256 poolIndex
    ) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {

        PoolVestingDepositable._batchDeposits(from, to, amounts, poolIndex);
    }

    function vestingWithdraw(uint256 amount, uint256 poolIndex)
        external
        whenNotPaused
    {

        PoolVestingDepositable._withdraw(_msgSender(), amount, poolIndex);
    }

    function transferVestingPoolDeposits(
        address[] calldata accounts,
        uint256[] calldata amounts,
        uint256 fromPoolIndex,
        uint256 toPoolIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(
            accounts.length == amounts.length,
            "LockedLBToken: account and amounts length are not equal"
        );
        for (uint256 i = 0; i < accounts.length; i++) {
            PoolVestingDepositable._transferVestingPoolDeposit(
                accounts[i],
                amounts[i],
                fromPoolIndex,
                toPoolIndex
            );
        }
    }

    uint256[50] private __gap;
}