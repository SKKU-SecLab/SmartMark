
pragma solidity ^0.8.0;

interface IAccessControl {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

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
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

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


library SafeMath {

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

pragma solidity ^0.8.13;

interface IStaking {

    event Staked(string tokenName, address indexed staker, uint256 timestamp, uint256 amount);
    event UnStaked(string tokenName, address indexed staker, uint256 timestamp, uint256 amount);

    struct Stake {
        uint256 time; // Time for precise calculations
        uint256 amount; // New amount on every new (un)stake
    }
}// MIT

pragma solidity ^0.8.13;


uint256 constant DAYS_PER_WEEK = 7;
uint256 constant HOURS_PER_DAY = 24;
uint256 constant MINUTES_PER_HOUR = 60;
uint256 constant SECONDS_PER_MINUTE = 60;
uint256 constant SECONDS_PER_HOUR = 3600;
uint256 constant SECONDS_PER_DAY = 86400;
uint256 constant SECONDS_PER_WEEK = 604800;// MIT

pragma solidity ^0.8.13;

contract Util {

    error InvalidInput(string errMsg);
    error ContractError(string errMsg);

    string constant ALREADY_INITIALIZED = "The contract has already been initialized";
    string constant INVALID_MULTISIG = "Invalid Multisig contract";
    string constant INVALID_DAO = "Invalid DAO contract";
    string constant INVALID_CONTROLLER = "Invalid Controller contract";
    string constant INVALID_STAKING_LOGIC = "Invalid Staking Logic contract";
    string constant INVALID_STAKING_STORAGE = "Invalid Staking Storage contract";
    string constant INVALID_CONVERTER_LOGIC = "Invalid Converter Logic contract";
    string constant INVALID_ENERGY_STORAGE = "Invalid Energy Storage contract";
    string constant INVALID_LBA_ENERGY_STORAGE = "Invalid LBA Energy Storage contract";
    string constant INVALID_ASTO_CONTRACT = "Invalid ASTO contract";
    string constant INVALID_LP_CONTRACT = "Invalid LP contract";
    string constant INVALID_LBA_CONTRACT = "Invalid LBA contract";
    string constant WRONG_ADDRESS = "Wrong or missed wallet address";
    string constant WRONG_AMOUNT = "Wrong or missed amount";
    string constant WRONG_PERIOD_ID = "Wrong periodId";
    string constant WRONG_TOKEN = "Token not allowed for staking";
    string constant INSUFFICIENT_BALANCE = "Insufficient token balance";
    string constant INSUFFICIENT_STAKED_AMOUNT = "Requested amount is greater than a stake";
    string constant NO_STAKES = "No stakes yet";

    function _isContract(address addr) internal view returns (bool) {

        return addr.code.length > 0;
    }
}// MIT

pragma solidity ^0.8.13;



bytes32 constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");
bytes32 constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");
bytes32 constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
bytes32 constant DAO_ROLE = keccak256("DAO_ROLE");
bytes32 constant CONSUMER_ROLE = keccak256("CONSUMER_ROLE");

string constant MISSING_ROLE = "Missing required role";

contract PermissionControl is AccessControlEnumerable {

    error AccessDenied(string errMsg);

    modifier eitherRole(bytes32[2] memory roles) {

        if (!hasRole(roles[0], _msgSender()) && !hasRole(roles[1], _msgSender())) {
            revert AccessDenied(MISSING_ROLE);
        }
        _;
    }

    function _clearRole(bytes32 role) internal {

        uint256 count = getRoleMemberCount(role);
        for (uint256 i = count; i > 0; i--) {
            _revokeRole(role, getRoleMember(role, i - 1));
        }
    }

    function addConsumer(address addr) public eitherRole([CONTROLLER_ROLE, MULTISIG_ROLE]) {

        _grantRole(CONSUMER_ROLE, addr);
    }

    function removeConsumer(address addr) public eitherRole([CONTROLLER_ROLE, MULTISIG_ROLE]) {

        _revokeRole(CONSUMER_ROLE, addr);
    }

    function addManager(address addr) public eitherRole([CONTROLLER_ROLE, MULTISIG_ROLE]) {

        _grantRole(MANAGER_ROLE, addr);
    }

    function removeManager(address addr) public eitherRole([CONTROLLER_ROLE, MULTISIG_ROLE]) {

        _revokeRole(MANAGER_ROLE, addr);
    }
}// MIT

pragma solidity ^0.8.13;



contract StakingStorage is IStaking, PermissionControl, Util, Pausable {

    bool private _initialized = false;

    mapping(address => uint256) public stakeIds;
    mapping(address => mapping(uint256 => Stake)) public stakeHistory;

    constructor(address controller) {
        if (!_isContract(controller)) revert InvalidInput(INVALID_CONTROLLER);
        _grantRole(CONTROLLER_ROLE, controller);
    }


    function updateHistory(address addr, uint256 amount) external onlyRole(CONSUMER_ROLE) returns (uint256) {

        if (address(addr) == address(0)) revert InvalidInput(WRONG_ADDRESS);

        uint128 time = uint128(currentTime());
        Stake memory newStake = Stake(time, amount);
        uint256 userStakeId = ++stakeIds[addr]; // ++i cheaper than i++, so, stakeHistory[addr] starts from 1
        stakeHistory[addr][userStakeId] = newStake;
        return userStakeId;
    }


    function getHistory(address addr, uint256 endTime) external view returns (Stake[] memory) {

        uint256 totalStakes = stakeIds[addr];

        Stake[] memory stakes = new Stake[](totalStakes); // suboptimal - it could be larger than needed, when endTime is lesser than current time

        for (uint256 i = 1; i < totalStakes + 1; i++) {
            Stake memory stake = stakeHistory[addr][i];
            if (stake.time <= endTime) stakes[i - 1] = stake;
            else {
                Stake[] memory res = new Stake[](i - 1);
                for (uint256 j = 0; j < res.length; j++) res[j] = stakes[j];
                return res;
            }
        }
        return stakes;
    }

    function getStake(address addr, uint256 id) external view returns (Stake memory) {

        return stakeHistory[addr][id];
    }

    function getUserLastStakeId(address addr) external view returns (uint256) {

        return stakeIds[addr];
    }

    function currentTime() public view virtual returns (uint256) {

        return block.timestamp;
    }


    function init(address stakingLogic) external onlyRole(CONTROLLER_ROLE) {

        if (!_initialized) {
            _grantRole(CONSUMER_ROLE, stakingLogic);
            _initialized = true;
        }
    }

    function setController(address newController) external onlyRole(CONTROLLER_ROLE) {

        _clearRole(CONTROLLER_ROLE);
        _grantRole(CONTROLLER_ROLE, newController);
    }
}// MIT

pragma solidity ^0.8.13;




contract Staking is IStaking, Util, PermissionControl, Pausable {

    using SafeERC20 for IERC20;

    bool private _initialized = false;

    uint256 public constant ASTO_TOKEN_ID = 0;
    uint256 public constant LP_TOKEN_ID = 1;

    mapping(uint256 => IERC20) private _token;
    mapping(uint256 => string) private _tokenName;
    mapping(uint256 => StakingStorage) private _storage;
    mapping(uint256 => uint256) public totalStakedAmount;

    constructor(address controller) {
        if (!_isContract(controller)) revert InvalidInput(INVALID_CONTROLLER);
        _grantRole(CONTROLLER_ROLE, controller);
        _pause();
    }


    function withdraw(
        uint256 tokenId,
        address recipient,
        uint256 amount
    ) external onlyRole(DAO_ROLE) {

        if (!_isContract(address(_token[tokenId]))) revert InvalidInput(WRONG_TOKEN);
        if (address(recipient) == address(0)) revert InvalidInput(WRONG_ADDRESS);
        if (_token[tokenId].balanceOf(address(this)) < amount) revert InvalidInput(INSUFFICIENT_BALANCE);

        _token[tokenId].safeTransfer(recipient, amount);
    }


    function init(
        address dao,
        IERC20 astoToken,
        address astoStorage,
        IERC20 lpToken,
        address lpStorage,
        uint256 totalStakedAsto,
        uint256 totalStakedLp
    ) external onlyRole(CONTROLLER_ROLE) {

        if (!_initialized) {
            _token[0] = astoToken;
            _storage[0] = StakingStorage(astoStorage);
            _tokenName[0] = "ASTO";

            _token[1] = lpToken;
            _storage[1] = StakingStorage(lpStorage);
            _tokenName[1] = "ASTO/USDC Uniswap V2 LP";

            _clearRole(DAO_ROLE);
            _grantRole(DAO_ROLE, dao);

            totalStakedAmount[ASTO_TOKEN_ID] = totalStakedAsto;
            totalStakedAmount[LP_TOKEN_ID] = totalStakedLp;

            _initialized = true;
        }
    }

    function setDao(address newDao) external onlyRole(CONTROLLER_ROLE) {

        _clearRole(DAO_ROLE);
        _grantRole(DAO_ROLE, newDao);
    }

    function setController(address newController) external onlyRole(CONTROLLER_ROLE) {

        _clearRole(CONTROLLER_ROLE);
        _grantRole(CONTROLLER_ROLE, newController);
    }

    function pause() external onlyRole(CONTROLLER_ROLE) {

        _pause();
    }

    function unpause() external onlyRole(CONTROLLER_ROLE) {

        _unpause();
    }


    function stake(uint256 tokenId, uint256 amount) external whenNotPaused {

        if (tokenId > 1) revert InvalidInput(WRONG_TOKEN);
        if (amount == 0) revert InvalidInput(WRONG_AMOUNT);
        address user = msg.sender;
        uint256 tokenBalance = _token[tokenId].balanceOf(user);
        if (amount > tokenBalance) revert InvalidInput(INSUFFICIENT_BALANCE);

        _token[tokenId].safeTransferFrom(user, address(this), amount);

        uint256 lastStakeId = _storage[tokenId].getUserLastStakeId(user);
        uint256 stakeBalance = (_storage[tokenId].getStake(user, lastStakeId)).amount;
        uint256 newAmount = stakeBalance + amount;
        _storage[tokenId].updateHistory(user, newAmount);
        totalStakedAmount[tokenId] += amount;

        emit Staked(_tokenName[tokenId], user, block.timestamp, amount);
    }

    function unstake(uint256 tokenId, uint256 amount) external whenNotPaused {

        if (!_isContract(address(_token[tokenId]))) revert InvalidInput(WRONG_TOKEN);
        if (amount == 0) revert InvalidInput(WRONG_AMOUNT);

        address user = msg.sender;
        uint256 id = _storage[tokenId].getUserLastStakeId(user);
        if (id == 0) revert InvalidInput(NO_STAKES);
        uint256 userBalance = (_storage[tokenId].getStake(user, id)).amount;
        if (amount > userBalance) revert InvalidInput(INSUFFICIENT_BALANCE);

        uint256 newAmount = userBalance - amount;
        _storage[tokenId].updateHistory(user, newAmount);
        totalStakedAmount[tokenId] -= amount;

        _token[tokenId].safeTransfer(user, amount);

        emit UnStaked(_tokenName[tokenId], user, block.timestamp, amount);
    }

    function getTotalValueLocked(uint256 tokenId) external view returns (uint256) {

        return totalStakedAmount[tokenId];
    }


    function getStorageAddress(uint256 tokenId) external view returns (address) {

        return address(_storage[tokenId]);
    }

    function getTokenAddress(uint256 tokenId) external view returns (address) {

        return address(_token[tokenId]);
    }

    function getHistory(
        uint256 tokenId,
        address addr,
        uint256 endTime
    ) external view returns (Stake[] memory) {

        return _storage[tokenId].getHistory(addr, endTime);
    }
}// MIT

pragma solidity ^0.8.13;


contract EnergyStorage is Util, PermissionControl {

    bool private _initialized = false;
    mapping(address => uint256) public consumedAmount;

    constructor(address controller) {
        if (!_isContract(controller)) revert ContractError(INVALID_CONTROLLER);
        _grantRole(CONTROLLER_ROLE, controller);
    }

    function increaseConsumedAmount(address addr, uint256 amount) external onlyRole(CONSUMER_ROLE) {

        if (address(addr) == address(0)) revert InvalidInput(WRONG_ADDRESS);
        consumedAmount[addr] += amount;
    }


    function init(address converterLogic) external onlyRole(CONTROLLER_ROLE) {

        if (!_initialized) {
            if (!_isContract(converterLogic)) revert ContractError(INVALID_CONVERTER_LOGIC);

            _grantRole(CONSUMER_ROLE, converterLogic);
            _initialized = true;
        }
    }

    function setController(address newController) external onlyRole(CONTROLLER_ROLE) {

        _clearRole(CONTROLLER_ROLE);
        _grantRole(CONTROLLER_ROLE, newController);
    }
}// MIT

pragma solidity ^0.8.13;

interface IConverter {

    struct Period {
        uint128 startTime;
        uint128 endTime;
        uint128 astoMultiplier;
        uint128 lpMultiplier;
        uint128 lbaLPMultiplier;
    }
}// MIT

pragma solidity ^0.8.13;

interface ILiquidityBootstrapAuction {

    function claimableLPAmount(address) external view returns (uint256);


    function lpTokenReleaseTime() external view returns (uint256);

}// MIT

pragma solidity ^0.8.13;


contract Converter is IConverter, IStaking, Util, PermissionControl, Pausable {

    using SafeMath for uint256;

    bool private _initialized = false;

    uint256 public periodIdCounter = 0;
    mapping(uint256 => Period) public periods;

    Staking public stakingLogic_;
    ILiquidityBootstrapAuction public lba_;
    EnergyStorage public energyStorage_;
    EnergyStorage public lbaEnergyStorage_;

    uint256 public constant ASTO_TOKEN_ID = 0;
    uint256 public constant LP_TOKEN_ID = 1;

    uint256 private _lbaEnergyStartTime;

    event EnergyUsed(address addr, uint256 amount);
    event LBAEnergyUsed(address addr, uint256 amount);
    event PeriodAdded(uint256 time, uint256 periodId, Period period);
    event PeriodUpdated(uint256 time, uint256 periodId, Period period);

    constructor(
        address controller,
        address lba,
        Period[] memory _periods,
        uint256 lbaEnergyStartTime
    ) {
        if (!_isContract(controller)) revert ContractError(INVALID_CONTROLLER);
        if (!_isContract(lba)) revert ContractError(INVALID_LBA_CONTRACT);
        lba_ = ILiquidityBootstrapAuction(lba);
        _grantRole(CONTROLLER_ROLE, controller);
        _addPeriods(_periods);
        _lbaEnergyStartTime = lbaEnergyStartTime;
        _pause();
    }


    function getConsumedEnergy(address addr) public view returns (uint256) {

        if (address(addr) == address(0)) revert InvalidInput(WRONG_ADDRESS);
        return energyStorage_.consumedAmount(addr);
    }

    function getConsumedLBAEnergy(address addr) public view returns (uint256) {

        if (address(addr) == address(0)) revert InvalidInput(WRONG_ADDRESS);
        return lbaEnergyStorage_.consumedAmount(addr);
    }

    function calculateEnergy(address addr, uint256 periodId) public view returns (uint256) {

        if (address(addr) == address(0)) revert InvalidInput(WRONG_ADDRESS);
        if (periodId == 0 || periodId > periodIdCounter) revert ContractError(WRONG_PERIOD_ID);

        Period memory period = getPeriod(periodId);

        Stake[] memory astoHistory = stakingLogic_.getHistory(ASTO_TOKEN_ID, addr, period.endTime);
        Stake[] memory lpHistory = stakingLogic_.getHistory(LP_TOKEN_ID, addr, period.endTime);

        uint256 astoEnergyAmount = _calculateEnergyForToken(astoHistory, period.astoMultiplier);
        uint256 lpEnergyAmount = _calculateEnergyForToken(lpHistory, period.lpMultiplier);

        return (astoEnergyAmount + lpEnergyAmount);
    }

    function _calculateEnergyForToken(Stake[] memory history, uint256 multiplier) internal view returns (uint256) {

        uint256 total = 0;
        for (uint256 i = history.length; i > 0; i--) {
            if (currentTime() < history[i - 1].time) continue;

            uint256 elapsedTime = i == history.length
                ? currentTime().sub(history[i - 1].time)
                : history[i].time.sub(history[i - 1].time);

            total = total.add(elapsedTime.mul(history[i - 1].amount).mul(multiplier));
        }
        return total.div(SECONDS_PER_DAY);
    }

    function calculateAvailableLBAEnergy(address addr, uint256 periodId) public view returns (uint256) {

        if (address(addr) == address(0)) revert InvalidInput(WRONG_ADDRESS);
        if (periodId == 0 || periodId > periodIdCounter) revert ContractError(WRONG_PERIOD_ID);

        Period memory period = getPeriod(periodId);

        uint256 lbaEnergyStartTime = getLBAEnergyStartTime();
        if (currentTime() < lbaEnergyStartTime) return 0;

        uint256 elapsedTime = currentTime() - lbaEnergyStartTime;
        uint256 lbaLPAmount = lba_.claimableLPAmount(addr);

        return elapsedTime.mul(lbaLPAmount).mul(period.lbaLPMultiplier).div(SECONDS_PER_DAY);
    }

    function getEnergy(address addr, uint256 periodId) public view returns (uint256) {

        return calculateEnergy(addr, periodId) - getConsumedEnergy(addr) + getRemainingLBAEnergy(addr, periodId);
    }

    function getRemainingLBAEnergy(address addr, uint256 periodId) public view returns (uint256) {

        uint256 availableEnergy = calculateAvailableLBAEnergy(addr, periodId);
        uint256 consumedEnergy = getConsumedLBAEnergy(addr);
        if (availableEnergy > 0 && availableEnergy > consumedEnergy) return availableEnergy - consumedEnergy;
        return 0;
    }

    function useEnergy(
        address addr,
        uint256 periodId,
        uint256 amount
    ) external whenNotPaused onlyRole(CONSUMER_ROLE) {

        if (address(addr) == address(0)) revert InvalidInput(WRONG_ADDRESS);
        if (periodId == 0 || periodId > periodIdCounter) revert ContractError(WRONG_PERIOD_ID);
        if (amount > getEnergy(addr, periodId)) revert InvalidInput(WRONG_AMOUNT);

        uint256 remainingLBAEnergy = getRemainingLBAEnergy(addr, periodId);
        uint256 lbaEnergyToSpend = Math.min(amount, remainingLBAEnergy);

        if (lbaEnergyToSpend > 0) {
            lbaEnergyStorage_.increaseConsumedAmount(addr, lbaEnergyToSpend);
            emit LBAEnergyUsed(addr, lbaEnergyToSpend);
        }

        uint256 energyToSpend = amount - lbaEnergyToSpend;
        if (energyToSpend > 0) {
            energyStorage_.increaseConsumedAmount(addr, energyToSpend);
            emit EnergyUsed(addr, energyToSpend);
        }
    }


    function getPeriod(uint256 periodId) public view returns (Period memory) {

        if (periodId == 0 || periodId > periodIdCounter) revert InvalidInput(WRONG_PERIOD_ID);
        return periods[periodId];
    }

    function getCurrentPeriod() external view returns (Period memory) {

        return periods[getCurrentPeriodId()];
    }

    function getCurrentPeriodId() public view returns (uint256) {

        for (uint256 index = 1; index <= periodIdCounter; index++) {
            Period memory p = periods[index];
            if (currentTime() >= uint256(p.startTime) && currentTime() < uint256(p.endTime)) {
                return index;
            }
        }
        return 0;
    }

    function currentTime() public view virtual returns (uint256) {

        return block.timestamp;
    }

    function getLBAEnergyStartTime() public view returns (uint256) {

        return _lbaEnergyStartTime > 0 ? _lbaEnergyStartTime : lba_.lpTokenReleaseTime();
    }


    function addPeriods(Period[] memory _periods) external onlyRole(MANAGER_ROLE) {

        _addPeriods(_periods);
    }

    function addPeriod(Period memory period) external onlyRole(MANAGER_ROLE) {

        _addPeriod(period);
    }

    function updatePeriod(uint256 periodId, Period memory period) external onlyRole(MANAGER_ROLE) {

        _updatePeriod(periodId, period);
    }

    function _addPeriods(Period[] memory _periods) internal {

        for (uint256 i = 0; i < _periods.length; i++) {
            _addPeriod(_periods[i]);
        }
    }

    function _addPeriod(Period memory period) internal {

        periods[++periodIdCounter] = period;
        emit PeriodAdded(currentTime(), periodIdCounter, period);
    }

    function _updatePeriod(uint256 periodId, Period memory period) internal {

        if (periodId == 0 || periodId > periodIdCounter) revert ContractError(WRONG_PERIOD_ID);
        periods[periodId] = period;
        emit PeriodUpdated(currentTime(), periodId, period);
    }


    function init(
        address dao,
        address multisig,
        address energyStorage,
        address lbaEnergyStorage,
        address stakingLogic
    ) external onlyRole(CONTROLLER_ROLE) {

        if (!_initialized) {
            if (!_isContract(energyStorage)) revert ContractError(INVALID_ENERGY_STORAGE);
            if (!_isContract(lbaEnergyStorage)) revert ContractError(INVALID_LBA_ENERGY_STORAGE);
            if (!_isContract(stakingLogic)) revert ContractError(INVALID_STAKING_LOGIC);

            stakingLogic_ = Staking(stakingLogic);
            energyStorage_ = EnergyStorage(energyStorage);
            lbaEnergyStorage_ = EnergyStorage(lbaEnergyStorage);

            _grantRole(DAO_ROLE, dao);
            _grantRole(MULTISIG_ROLE, multisig);
            _grantRole(MANAGER_ROLE, multisig);

            _initialized = true;
        }
    }

    function setDao(address newDao) external onlyRole(CONTROLLER_ROLE) {

        _clearRole(DAO_ROLE);
        _grantRole(DAO_ROLE, newDao);
    }

    function setMultisig(address newMultisig, address dao) external onlyRole(CONTROLLER_ROLE) {

        _clearRole(MULTISIG_ROLE);
        _grantRole(MULTISIG_ROLE, newMultisig);
        _grantRole(MULTISIG_ROLE, dao);
    }

    function setController(address newController) external onlyRole(CONTROLLER_ROLE) {

        _clearRole(CONTROLLER_ROLE);
        _grantRole(CONTROLLER_ROLE, newController);
    }

    function pause() external onlyRole(CONTROLLER_ROLE) {

        _pause();
    }

    function unpause() external onlyRole(CONTROLLER_ROLE) {

        _unpause();
    }
}// MIT

pragma solidity ^0.8.13;


contract Controller is Util, PermissionControl {

    Staking private _stakingLogic;
    StakingStorage private _astoStorage;
    StakingStorage private _lpStorage;
    Converter private _converterLogic;
    EnergyStorage private _energyStorage;
    EnergyStorage private _lbaEnergyStorage;
    IERC20 private _astoToken;
    IERC20 private _lpToken;
    address private _dao;
    address private _multisig;

    bool private _initialized;

    uint256 public constant ASTO_TOKEN_ID = 0;
    uint256 public constant LP_TOKEN_ID = 1;

    event ContractUpgraded(uint256 timestamp, string contractName, address oldAddress, address newAddress);

    constructor(address multisig) {
        if (!_isContract(multisig)) revert InvalidInput(INVALID_MULTISIG);
        _grantRole(MULTISIG_ROLE, multisig);
        _grantRole(DAO_ROLE, multisig);
        _multisig = multisig;
    }

    function init(
        address dao,
        address astoToken,
        address astoStorage,
        address lpToken,
        address lpStorage,
        address stakingLogic,
        address converterLogic,
        address energyStorage,
        address lbaEnergyStorage
    ) external onlyRole(MULTISIG_ROLE) {

        if (!_initialized) {
            if (!_isContract(dao)) revert InvalidInput(INVALID_DAO);
            if (!_isContract(astoToken)) revert InvalidInput(INVALID_ASTO_CONTRACT);
            if (!_isContract(astoStorage)) revert InvalidInput(INVALID_STAKING_STORAGE);
            if (!_isContract(lpToken)) revert InvalidInput(INVALID_LP_CONTRACT);
            if (!_isContract(lpStorage)) revert InvalidInput(INVALID_STAKING_STORAGE);
            if (!_isContract(stakingLogic)) revert InvalidInput(INVALID_STAKING_LOGIC);
            if (!_isContract(converterLogic)) revert InvalidInput(INVALID_CONVERTER_LOGIC);
            if (!_isContract(energyStorage)) revert InvalidInput(INVALID_ENERGY_STORAGE);
            if (!_isContract(lbaEnergyStorage)) revert InvalidInput(INVALID_ENERGY_STORAGE);
            _clearRole(DAO_ROLE);
            _grantRole(DAO_ROLE, dao);

            _dao = dao;
            _astoToken = IERC20(astoToken);
            _astoStorage = StakingStorage(astoStorage);
            _lpToken = IERC20(lpToken);
            _lpStorage = StakingStorage(lpStorage);
            _stakingLogic = Staking(stakingLogic);
            _converterLogic = Converter(converterLogic);
            _energyStorage = EnergyStorage(energyStorage);
            _lbaEnergyStorage = EnergyStorage(lbaEnergyStorage);

            _upgradeContracts(
                astoToken,
                astoStorage,
                lpToken,
                lpStorage,
                stakingLogic,
                converterLogic,
                energyStorage,
                lbaEnergyStorage
            );
            _initialized = true;
        }
    }


    function _upgradeContracts(
        address astoToken,
        address astoStorage,
        address lpToken,
        address lpStorage,
        address stakingLogic,
        address converterLogic,
        address energyStorage,
        address lbaEnergyStorage
    ) internal {

        if (_isContract(astoToken)) _setAstoToken(astoToken);
        if (_isContract(astoStorage)) _setAstoStorage(astoStorage);
        if (_isContract(lpToken)) _setLpToken(lpToken);
        if (_isContract(lpStorage)) _setLpStorage(lpStorage);
        if (_isContract(stakingLogic)) _setStakingLogic(stakingLogic);
        if (_isContract(energyStorage)) _setEnergyStorage(energyStorage);
        if (_isContract(lbaEnergyStorage)) _setLBAEnergyStorage(lbaEnergyStorage);
        if (_isContract(converterLogic)) _setConverterLogic(converterLogic);
        _setController(address(this));
    }

    function _setDao(address dao) internal {

        _dao = dao;
        _clearRole(DAO_ROLE);
        _grantRole(DAO_ROLE, dao);
        _grantRole(MULTISIG_ROLE, dao);
        _stakingLogic.setDao(dao);
        _converterLogic.setDao(dao);
    }

    function _setMultisig(address multisig) internal {

        _multisig = multisig;
        _clearRole(MULTISIG_ROLE);
        _grantRole(MULTISIG_ROLE, multisig);
        _grantRole(MULTISIG_ROLE, _dao);
        _converterLogic.setMultisig(multisig, _dao);
    }

    function _setController(address newContract) internal {

        _stakingLogic.setController(newContract);
        _astoStorage.setController(newContract);
        _lpStorage.setController(newContract);
        _converterLogic.setController(newContract);
        _energyStorage.setController(newContract);
        _lbaEnergyStorage.setController(newContract);
        emit ContractUpgraded(block.timestamp, "Controller", address(this), newContract);
    }

    function _setStakingLogic(address newContract) internal {

        if (_isContract(address(_stakingLogic))) {
            _astoStorage.removeConsumer(address(_stakingLogic));
            _lpStorage.removeConsumer(address(_stakingLogic));
        }

        uint256 lockedAsto = _stakingLogic.totalStakedAmount(ASTO_TOKEN_ID);
        uint256 lockedLp = _stakingLogic.totalStakedAmount(LP_TOKEN_ID);

        _stakingLogic = Staking(newContract);
        _stakingLogic.init(
            address(_dao),
            IERC20(_astoToken),
            address(_astoStorage),
            IERC20(_lpToken),
            address(_lpStorage),
            lockedAsto,
            lockedLp
        );
        _astoStorage.addConsumer(newContract);
        _lpStorage.addConsumer(newContract);
        emit ContractUpgraded(block.timestamp, "Staking Logic", address(this), newContract);
    }

    function _setAstoToken(address newContract) internal {

        _astoToken = IERC20(newContract);
        emit ContractUpgraded(block.timestamp, "ASTO Token", address(this), newContract);
    }

    function _setAstoStorage(address newContract) internal {

        _astoStorage = StakingStorage(newContract);
        _astoStorage.init(address(_stakingLogic));
        emit ContractUpgraded(block.timestamp, "ASTO Staking Storage", address(this), newContract);
    }

    function _setLpToken(address newContract) internal {

        _lpToken = IERC20(newContract);
        emit ContractUpgraded(block.timestamp, "LP Token", address(this), newContract);
    }

    function _setLpStorage(address newContract) internal {

        _lpStorage = StakingStorage(newContract);
        _lpStorage.init(address(_stakingLogic));
        emit ContractUpgraded(block.timestamp, "LP Staking Storage", address(this), newContract);
    }

    function _setConverterLogic(address newContract) internal {

        if (_isContract(address(_converterLogic))) {
            _lbaEnergyStorage.removeConsumer(address(_converterLogic));
            _energyStorage.removeConsumer(address(_converterLogic));
        }

        _converterLogic = Converter(newContract);
        _converterLogic.init(
            address(_dao),
            address(_multisig),
            address(_energyStorage),
            address(_lbaEnergyStorage),
            address(_stakingLogic)
        );
        _lbaEnergyStorage.addConsumer(newContract);
        _energyStorage.addConsumer(newContract);
        emit ContractUpgraded(block.timestamp, "Converter Logic", address(this), newContract);
    }

    function _setEnergyStorage(address newContract) internal {

        _energyStorage = EnergyStorage(newContract);
        _energyStorage.init(address(_converterLogic));
        emit ContractUpgraded(block.timestamp, "Energy Storage", address(this), newContract);
    }

    function _setLBAEnergyStorage(address newContract) internal {

        _lbaEnergyStorage = EnergyStorage(newContract);
        _lbaEnergyStorage.init(address(_converterLogic));
        emit ContractUpgraded(block.timestamp, "LBA Energy Storage", address(this), newContract);
    }


    function upgradeContracts(
        address astoToken,
        address astoStorage,
        address lpToken,
        address lpStorage,
        address stakingLogic,
        address converterLogic,
        address energyStorage,
        address lbaEnergyStorage
    ) external onlyRole(DAO_ROLE) {

        _upgradeContracts(
            astoToken,
            astoStorage,
            lpToken,
            lpStorage,
            stakingLogic,
            converterLogic,
            energyStorage,
            lbaEnergyStorage
        );
    }

    function setDao(address dao) external onlyRole(DAO_ROLE) {

        _setDao(dao);
    }

    function setMultisig(address multisig) external onlyRole(DAO_ROLE) {

        _setMultisig(multisig);
    }

    function setController(address newContract) external onlyRole(DAO_ROLE) {

        _setController(newContract);
    }

    function setStakingLogic(address newContract) external onlyRole(DAO_ROLE) {

        _setStakingLogic(newContract);
    }

    function setAstoStorage(address newContract) external onlyRole(DAO_ROLE) {

        _setAstoStorage(newContract);
    }

    function setLpStorage(address newContract) external onlyRole(DAO_ROLE) {

        _setLpStorage(newContract);
    }

    function setConverterLogic(address newContract) external onlyRole(DAO_ROLE) {

        _setConverterLogic(newContract);
    }

    function setEnergyStorage(address newContract) external onlyRole(DAO_ROLE) {

        _setEnergyStorage(newContract);
    }

    function setLBAEnergyStorage(address newContract) external onlyRole(DAO_ROLE) {

        _setLBAEnergyStorage(newContract);
    }

    function pause() external onlyRole(MULTISIG_ROLE) {

        if (!_stakingLogic.paused()) {
            _stakingLogic.pause();
        }

        if (!_converterLogic.paused()) {
            _converterLogic.pause();
        }
    }

    function unpause() external onlyRole(MULTISIG_ROLE) {

        if (_stakingLogic.paused()) {
            _stakingLogic.unpause();
        }

        if (_converterLogic.paused()) {
            _converterLogic.unpause();
        }
    }


    function getController() external view returns (address) {

        return address(this);
    }

    function getDao() external view returns (address) {

        return _dao;
    }

    function getMultisig() external view returns (address) {

        return _multisig;
    }

    function getStakingLogic() external view returns (address) {

        return address(_stakingLogic);
    }

    function getAstoStorage() external view returns (address) {

        return address(_astoStorage);
    }

    function getLpStorage() external view returns (address) {

        return address(_lpStorage);
    }

    function getConverterLogic() external view returns (address) {

        return address(_converterLogic);
    }

    function getEnergyStorage() external view returns (address) {

        return address(_energyStorage);
    }

    function getLBAEnergyStorage() external view returns (address) {

        return address(_lbaEnergyStorage);
    }
}