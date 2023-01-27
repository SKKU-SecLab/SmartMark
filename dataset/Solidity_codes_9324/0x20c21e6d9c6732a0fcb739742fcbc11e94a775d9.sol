
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


interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
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

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
    uint256[49] private __gap;
}// GPL-3.0

pragma solidity =0.8.6;

interface IDistro {

    event Claim(address indexed grantee, uint256 amount);
    event Allocate(
        address indexed distributor,
        address indexed grantee,
        uint256 amount
    );
    event Assign(
        address indexed admin,
        address indexed distributor,
        uint256 amount
    );
    event ChangeAddress(address indexed oldAddress, address indexed newAddress);

    event StartTimeChanged(uint256 newStartTime, uint256 newCliffTime);

    function totalTokens() external view returns (uint256);


    function setStartTime(uint256 newStartTime) external;


    function assign(address distributor, uint256 amount) external;


    function claim() external;


    function allocate(
        address recipient,
        uint256 amount,
        bool claim
    ) external;


    function allocateMany(address[] memory recipients, uint256[] memory amounts)
        external;


    function sendGIVbacks(address[] memory recipients, uint256[] memory amounts)
        external;


    function changeAddress(address newAddress) external;


    function getTimestamp() external view returns (uint256);


    function globallyClaimableAt(uint256 timestamp)
        external
        view
        returns (uint256);


    function claimableAt(address recipient, uint256 timestamp)
        external
        view
        returns (uint256);


    function claimableNow(address recipient) external view returns (uint256);


    function cancelAllocation(address prevRecipient, address newRecipient)
        external;

}// GPL-3.0
pragma solidity =0.8.6;


contract TokenDistro is
    Initializable,
    IDistro,
    AccessControlEnumerableUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant DISTRIBUTOR_ROLE =
        0xfbd454f36a7e1a388bd6fc3ab10d434aa4578f811acbbcf33afb1c697486313c;

    struct accountStatus {
        uint256 allocatedTokens;
        uint256 claimed;
    }

    mapping(address => accountStatus) public balances; // Mapping with all accounts that have received an allocation

    uint256 public override totalTokens; // total tokens to be distribute
    uint256 public startTime; // Instant of time in which distribution begins
    uint256 public cliffTime; // Instant of time in which tokens will begin to be released
    uint256 public duration;
    uint256 public initialAmount; // Initial amount that will be available from startTime
    uint256 public lockedAmount; // Amount that will be released over time from cliffTime

    IERC20Upgradeable public token; // Token to be distribute
    bool public cancelable; // Variable that allows the ADMIN_ROLE to cancel an allocation

    event GivBackPaid(address distributor);

    event DurationChanged(uint256 newDuration);

    modifier onlyDistributor() {

        require(
            hasRole(DISTRIBUTOR_ROLE, msg.sender),
            "TokenDistro::onlyDistributor: ONLY_DISTRIBUTOR_ROLE"
        );

        require(
            balances[msg.sender].claimed == 0,
            "TokenDistro::onlyDistributor: DISTRIBUTOR_CANNOT_CLAIM"
        );
        _;
    }

    function initialize(
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _cliffPeriod,
        uint256 _duration,
        uint256 _initialPercentage,
        IERC20Upgradeable _token,
        bool _cancelable
    ) public initializer {

        require(
            _duration >= _cliffPeriod,
            "TokenDistro::constructor: DURATION_LESS_THAN_CLIFF"
        );
        require(
            _initialPercentage <= 10000,
            "TokenDistro::constructor: INITIALPERCENTAGE_GREATER_THAN_100"
        );
        __AccessControlEnumerable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        uint256 _initialAmount = (_totalTokens * _initialPercentage) / 10000;

        token = _token;
        duration = _duration;
        startTime = _startTime;
        totalTokens = _totalTokens;
        initialAmount = _initialAmount;
        cliffTime = _startTime + _cliffPeriod;
        lockedAmount = _totalTokens - _initialAmount;
        balances[address(this)].allocatedTokens = _totalTokens;
        cancelable = _cancelable;
    }

    function setStartTime(uint256 newStartTime) external override {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "TokenDistro::setStartTime: ONLY_ADMIN_ROLE"
        );
        require(
            startTime > getTimestamp() && newStartTime > getTimestamp(),
            "TokenDistro::setStartTime: IF_HAS_NOT_STARTED_YET"
        );

        uint256 _cliffPeriod = cliffTime - startTime;
        startTime = newStartTime;
        cliffTime = newStartTime + _cliffPeriod;

        emit StartTimeChanged(startTime, cliffTime);
    }

    function assign(address distributor, uint256 amount) external override {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "TokenDistro::assign: ONLY_ADMIN_ROLE"
        );
        require(
            hasRole(DISTRIBUTOR_ROLE, distributor),
            "TokenDistro::assign: ONLY_TO_DISTRIBUTOR_ROLE"
        );

        balances[address(this)].allocatedTokens =
            balances[address(this)].allocatedTokens -
            amount;
        balances[distributor].allocatedTokens =
            balances[distributor].allocatedTokens +
            amount;

        emit Assign(msg.sender, distributor, amount);
    }

    function claimTo(address account) external {

        _claim(account);
    }

    function claim() external override {

        _claim(msg.sender);
    }

    function _allocate(
        address recipient,
        uint256 amount,
        bool claim
    ) internal {

        require(
            !hasRole(DISTRIBUTOR_ROLE, recipient),
            "TokenDistro::allocate: DISTRIBUTOR_NOT_VALID_RECIPIENT"
        );

        balances[msg.sender].allocatedTokens =
            balances[msg.sender].allocatedTokens -
            amount;

        balances[recipient].allocatedTokens =
            balances[recipient].allocatedTokens +
            amount;

        if (claim && claimableNow(recipient) > 0) {
            _claim(recipient);
        }

        emit Allocate(msg.sender, recipient, amount);
    }

    function allocate(
        address recipient,
        uint256 amount,
        bool claim
    ) external override onlyDistributor {

        _allocate(recipient, amount, claim);
    }

    function _allocateMany(
        address[] memory recipients,
        uint256[] memory amounts
    ) internal onlyDistributor {

        require(
            recipients.length == amounts.length,
            "TokenDistro::allocateMany: INPUT_LENGTH_NOT_MATCH"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            _allocate(recipients[i], amounts[i], false);
        }
    }

    function allocateMany(address[] memory recipients, uint256[] memory amounts)
        external
        override
    {

        _allocateMany(recipients, amounts);
    }

    function sendGIVbacks(address[] memory recipients, uint256[] memory amounts)
        external
        override
    {

        _allocateMany(recipients, amounts);
        emit GivBackPaid(msg.sender);
    }

    function changeAddress(address newAddress) external override {

        require(
            balances[newAddress].allocatedTokens == 0 &&
                balances[newAddress].claimed == 0,
            "TokenDistro::changeAddress: ADDRESS_ALREADY_IN_USE"
        );

        require(
            !hasRole(DISTRIBUTOR_ROLE, msg.sender) &&
                !hasRole(DISTRIBUTOR_ROLE, newAddress),
            "TokenDistro::changeAddress: DISTRIBUTOR_ROLE_NOT_A_VALID_ADDRESS"
        );

        balances[newAddress].allocatedTokens = balances[msg.sender]
            .allocatedTokens;
        balances[msg.sender].allocatedTokens = 0;

        balances[newAddress].claimed = balances[msg.sender].claimed;
        balances[msg.sender].claimed = 0;

        emit ChangeAddress(msg.sender, newAddress);
    }

    function getTimestamp() public view virtual override returns (uint256) {

        return block.timestamp;
    }

    function globallyClaimableAt(uint256 timestamp)
        public
        view
        override
        returns (uint256)
    {

        if (timestamp < startTime) return 0;
        if (timestamp < cliffTime) return initialAmount;
        if (timestamp > startTime + duration) return totalTokens;

        uint256 deltaTime = timestamp - startTime;
        return initialAmount + (deltaTime * lockedAmount) / duration;
    }

    function claimableAt(address recipient, uint256 timestamp)
        public
        view
        override
        returns (uint256)
    {

        require(
            !hasRole(DISTRIBUTOR_ROLE, recipient),
            "TokenDistro::claimableAt: DISTRIBUTOR_ROLE_CANNOT_CLAIM"
        );
        require(
            timestamp >= getTimestamp(),
            "TokenDistro::claimableAt: NOT_VALID_PAST_TIMESTAMP"
        );
        uint256 unlockedAmount = (globallyClaimableAt(timestamp) *
            balances[recipient].allocatedTokens) / totalTokens;

        return unlockedAmount - balances[recipient].claimed;
    }

    function claimableNow(address recipient)
        public
        view
        override
        returns (uint256)
    {

        return claimableAt(recipient, getTimestamp());
    }

    function cancelAllocation(address prevRecipient, address newRecipient)
        external
        override
    {

        require(cancelable, "TokenDistro::cancelAllocation: NOT_CANCELABLE");

        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "TokenDistro::cancelAllocation: ONLY_ADMIN_ROLE"
        );

        require(
            balances[newRecipient].allocatedTokens == 0 &&
                balances[newRecipient].claimed == 0,
            "TokenDistro::cancelAllocation: ADDRESS_ALREADY_IN_USE"
        );

        require(
            !hasRole(DISTRIBUTOR_ROLE, prevRecipient) &&
                !hasRole(DISTRIBUTOR_ROLE, newRecipient),
            "TokenDistro::cancelAllocation: DISTRIBUTOR_ROLE_NOT_A_VALID_ADDRESS"
        );

        balances[newRecipient].allocatedTokens = balances[prevRecipient]
            .allocatedTokens;
        balances[prevRecipient].allocatedTokens = 0;

        balances[newRecipient].claimed = balances[prevRecipient].claimed;
        balances[prevRecipient].claimed = 0;

        emit ChangeAddress(prevRecipient, newRecipient);
    }

    function _claim(address recipient) private {

        uint256 remainingToClaim = claimableNow(recipient);

        require(
            remainingToClaim > 0,
            "TokenDistro::claim: NOT_ENOUGTH_TOKENS_TO_CLAIM"
        );

        balances[recipient].claimed =
            balances[recipient].claimed +
            remainingToClaim;

        token.safeTransfer(recipient, remainingToClaim);

        emit Claim(recipient, remainingToClaim);
    }

    function setDuration(uint256 newDuration) public {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "TokenDistro::setDuration: ONLY_ADMIN_ROLE"
        );

        require(
            startTime > getTimestamp(),
            "TokenDistro::setDuration: IF_HAS_NOT_STARTED_YET"
        );

        duration = newDuration;

        emit DurationChanged(newDuration);
    }
}