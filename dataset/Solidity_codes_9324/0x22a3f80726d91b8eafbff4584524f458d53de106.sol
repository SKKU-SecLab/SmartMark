
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
}// MIT

pragma solidity ^0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
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
pragma abicoder v2;


abstract contract PoolFarmable is Initializable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;

    struct FarmPool {
        bool opened;
        int256 minTier;
        uint256 maxTotalDepositAmount;
        uint256 maxUserDepositAmount;
        uint256 minDepositDuration; // in seconds
        uint256 maxDepositDuration; // in seconds
        uint256 interestNumerator; // interest per seconds
        uint256 interestDenominator; // interest per seconds
    }

    FarmPool[] private _pools;

    event FarmPoolAdd(uint256 poolIndex, FarmPool pool);

    event FarmPoolUpdate(uint256 poolIndex, FarmPool pool);

    modifier checkFarmPool(FarmPool calldata pool) {
        require(
            pool.maxUserDepositAmount <= pool.maxTotalDepositAmount,
            "PoolFarmable: maxUserDepositAmount must be less than or equal to maxTotalDepositAmount"
        );

        require(
            pool.minDepositDuration <= pool.maxDepositDuration,
            "PoolFarmable: minDepositDuration must be less than or equal to maxDepositDuration"
        );

        require(
            pool.interestNumerator > 0,
            "PoolFarmable: interestNumerator must be greater than 0"
        );

        require(
            pool.interestDenominator > 0,
            "PoolFarmable: interestDenominator must be greater than 0"
        );

        require(
            pool.interestNumerator <= pool.interestDenominator,
            "PoolFarmable: interestNumerator must be less than or equal to interestDenominator"
        );

        _;
    }

    modifier checkFarmPoolIndex(uint256 poolIndex) {
        require(poolIndex < _pools.length, "PoolFarmable: Invalid poolIndex");
        _;
    }

    function __PoolFarmable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __PoolFarmable_init_unchained();
    }

    function __PoolFarmable_init_unchained() internal onlyInitializing {}

    function getFarmPool(uint256 poolIndex)
        public
        view
        checkFarmPoolIndex(poolIndex)
        returns (FarmPool memory)
    {
        return _pools[poolIndex];
    }

    function farmPoolsLength() public view returns (uint256) {
        return _pools.length;
    }

    function addFarmPool(FarmPool calldata pool)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        checkFarmPool(pool)
    {
        _pools.push(pool);

        emit FarmPoolAdd(_pools.length - 1, _pools[_pools.length - 1]);
    }

    function updateFarmPool(uint256 poolIndex, FarmPool calldata pool)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        checkFarmPoolIndex(poolIndex)
        checkFarmPool(pool)
    {
        FarmPool storage editedPool = _pools[poolIndex];

        editedPool.opened = pool.opened;
        editedPool.minTier = pool.minTier;
        editedPool.maxTotalDepositAmount = pool.maxTotalDepositAmount;
        editedPool.maxUserDepositAmount = pool.maxUserDepositAmount;
        editedPool.minDepositDuration = pool.minDepositDuration;
        editedPool.maxDepositDuration = pool.maxDepositDuration;
        editedPool.interestNumerator = pool.interestNumerator;
        editedPool.interestDenominator = pool.interestDenominator;

        emit FarmPoolUpdate(poolIndex, editedPool);
    }

    uint256[50] private __gap;
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

interface ITierable {

    function tierOf(address account) external returns (int256);

}// UNLICENSED

pragma solidity ^0.8.0;


abstract contract PoolFarmDepositable is
    Initializable,
    AccessControlUpgradeable,
    PoolFarmable,
    Depositable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    struct UserFarmPoolDeposit {
        uint256 amount; // amount deposited in the pool
        uint256 date; // date of the deposit
    }

    mapping(address => mapping(uint256 => UserFarmPoolDeposit[]))
        private _poolDeposits;

    mapping(uint256 => uint256) private _poolTotalDeposits;

    ITierable public tier;

    address public interestWallet;

    event FarmPoolDeposit(
        address indexed from,
        address indexed to,
        uint256 indexed poolIndex,
        uint256 depositIndex,
        uint256 amount
    );

    event FarmPoolWithdraw(
        address indexed from,
        address indexed to,
        uint256 indexed poolIndex,
        uint256 depositIndex,
        uint256 amount,
        uint256 interest
    );

    function __PoolFarmDepositable_init(
        IERC20Upgradeable _depositToken,
        ITierable _tier,
        address _interestWallet
    ) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __PoolFarmable_init_unchained();
        __Depositable_init_unchained(_depositToken);
        __PoolFarmDepositable_init_unchained(_tier, _interestWallet);
    }

    function __PoolFarmDepositable_init_unchained(
        ITierable _tier,
        address _interestWallet
    ) internal onlyInitializing {
        tier = _tier;
        interestWallet = _interestWallet;
    }

    function farmPoolDepositOf(address account, uint256 poolIndex)
        public
        view
        checkFarmPoolIndex(poolIndex)
        returns (UserFarmPoolDeposit memory)
    {
        uint256 depositIndex = 0;

        require(
            _poolDeposits[account][poolIndex].length > depositIndex,
            "PoolFarmDepositable: Deposit in this pool not found"
        );

        return _poolDeposits[account][poolIndex][depositIndex];
    }

    function farmPoolInterestOf(address account, uint256 poolIndex)
        public
        view
        returns (uint256)
    {
        FarmPool memory pool = getFarmPool(poolIndex);
        UserFarmPoolDeposit memory deposit = farmPoolDepositOf(
            account,
            poolIndex
        );

        uint256 depositDuration = MathUpgradeable.min(
            block.timestamp.sub(deposit.date),
            pool.maxDepositDuration
        );

        uint256 interest = deposit
            .amount
            .mul(depositDuration)
            .mul(pool.interestNumerator)
            .div(pool.interestDenominator);
        return interest;
    }

    function farmPoolTotalDepositOfPool(uint256 poolIndex)
        public
        view
        checkFarmPoolIndex(poolIndex)
        returns (uint256)
    {
        return _poolTotalDeposits[poolIndex];
    }

    function _deposit(
        address from,
        address to,
        uint256 amount,
        uint256 poolIndex
    ) internal virtual checkFarmPoolIndex(poolIndex) returns (uint256) {
        FarmPool memory pool = getFarmPool(poolIndex);

        require(pool.opened, "PoolFarmDepositable: Pool is closed");

        require(
            amount <= pool.maxUserDepositAmount,
            "PoolFarmDepositable: Amount to deposit is more than the pool max deposit per user"
        );

        int256 userTier = tier.tierOf(to);
        require(
            userTier >= pool.minTier,
            "PoolFarmDepositable: Tier of the to address is less than required by the pool"
        );

        uint256 transferredAmount = Depositable._deposit(from, to, amount);

        if (_poolDeposits[to][poolIndex].length > 0) {
            uint256 depositIndex = 0;

            UserFarmPoolDeposit storage deposit = _poolDeposits[to][poolIndex][
                depositIndex
            ];

            require(
                deposit.amount == 0,
                "PoolFarmDepositable: Already deposited in this pool"
            );

            deposit.amount = deposit.amount.add(transferredAmount);
            deposit.date = block.timestamp;
        } else {
            _poolDeposits[to][poolIndex].push(
                UserFarmPoolDeposit({
                    amount: transferredAmount,
                    date: block.timestamp
                })
            );
        }

        _poolTotalDeposits[poolIndex] = _poolTotalDeposits[poolIndex].add(
            transferredAmount
        );

        require(
            _poolTotalDeposits[poolIndex] <= pool.maxTotalDepositAmount,
            "PoolFarmDepositable: Pool max total deposit amount surpassed with this deposit"
        );

        emit FarmPoolDeposit(
            from,
            to,
            poolIndex,
            _poolDeposits[to][poolIndex].length - 1,
            transferredAmount
        );

        return transferredAmount;
    }

    function _withdraw(
        address from,
        address to,
        uint256 amount,
        uint256 poolIndex
    ) internal virtual checkFarmPoolIndex(poolIndex) returns (uint256) {
        FarmPool memory pool = getFarmPool(poolIndex);

        uint256 depositIndex = 0;

        require(
            _poolDeposits[to][poolIndex].length > depositIndex,
            "PoolFarmDepositable: Deposit in this pool not found"
        );

        UserFarmPoolDeposit storage deposit = _poolDeposits[to][poolIndex][
            depositIndex
        ];

        uint256 depositDuration = block.timestamp.sub(deposit.date);
        require(
            depositDuration >= pool.minDepositDuration,
            "PoolFarmDepositable: Deposit duration is less than pool min deposit duration"
        );

        require(
            amount <= deposit.amount,
            "PoolFarmDepositable: Amount to withdraw is more than the deposited amount"
        );

        uint256 interest = farmPoolInterestOf(from, poolIndex);

        uint256 withdrawAmount = Depositable._withdraw(to, amount);

        depositToken.safeTransferFrom(interestWallet, to, interest);

        deposit.amount = deposit.amount.sub(withdrawAmount);

        _poolTotalDeposits[poolIndex] = _poolTotalDeposits[poolIndex].sub(
            withdrawAmount
        );

        emit FarmPoolWithdraw(
            from,
            to,
            poolIndex,
            depositIndex,
            withdrawAmount,
            interest
        );

        return withdrawAmount;
    }

    function updateInterestWallet(address _interestWallet)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        interestWallet = _interestWallet;
    }

    uint256[50] private __gap;
}// UNLICENSED

pragma solidity ^0.8.0;


contract Farm is Initializable, Suspendable, PoolFarmDepositable {

    function initialize(
        IERC20Upgradeable _depositToken,
        ITierable _tier,
        address _interestWallet,
        address _pauser
    ) external initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        __Suspendable_init_unchained(_pauser);
        __PoolFarmable_init_unchained();
        __Depositable_init_unchained(_depositToken);
        __PoolFarmDepositable_init_unchained(_tier, _interestWallet);
        __Farm_init_unchained();
    }

    function __Farm_init_unchained() internal onlyInitializing {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function deposit(uint256 amount, uint256 poolIndex) external whenNotPaused {

        PoolFarmDepositable._deposit(
            _msgSender(),
            _msgSender(),
            amount,
            poolIndex
        );
    }

    function withdraw(uint256 amount, uint256 poolIndex)
        external
        whenNotPaused
    {

        PoolFarmDepositable._withdraw(
            _msgSender(),
            _msgSender(),
            amount,
            poolIndex
        );
    }

    uint256[50] private __gap;
}