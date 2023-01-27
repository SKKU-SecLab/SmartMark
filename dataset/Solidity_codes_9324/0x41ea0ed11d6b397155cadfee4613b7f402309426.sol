
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
}//MIT
pragma solidity 0.8.9;


interface ILPStakingRewards {

    function isSupported(address lpToken) external returns (bool);


    function getUserEngagedPool(address user) external view returns (address[] memory);


    function getPoolList() external view returns (address[] memory);


    function rewardsRate() external view returns (uint256);


    function setRewardsRate(uint256 newRewardsRate) external;


    function stakeOf(address addr, address lpToken) external view returns (uint256);


    function rewardOf(address user, address lpToken) external view returns (uint256);


    function totalRewardOf(address user) external view returns (uint256);


    function totalClaimableRewardOf(address user) external view returns (uint256);


    function stake(address lpToken, uint256 amount) external;


    function claimReward(address onBehalfOf, address lpToken) external;


    function claimReward(address lpToken) external;


    function claimAllReward(address onBehalfOf) external;


    function claimAllReward() external;


    function withdraw(address lpToken, uint256 amount) external;


    function exit(address lpToken) external;


    function rewardsPerToken(address lpToken) external view returns (uint256);


    function rewardRatePerTokenStaked(address lpToken) external view returns (uint256);


    function startRewards(address lpToken, uint256 rewardDuration) external;


    function startRewardsToBlock(address lpToken, uint256 _rewardsEndBlock) external;


    function endRewards(address lpToken) external;


    function isLocked(address lpToken) external view returns (bool);


    function setTimeLock(address lpToken, uint256 lockDuration) external;


    function setTimeLockEndBlock(address lpToken, uint256 lockEndBlock) external;


    function setTimeLockForAllLPTokens(uint256 lockDuration) external;


    function setTimeLockEndBlockForAllLPTokens(uint256 lockEndBlock) external;


    function earlyUnlock(address lpToken) external;


    function getLockEndBlock(address lpToken) external view returns (uint256);


    function addLP(address lpToken, uint256 allocPoint) external;


    function setLP(address lpToken, uint256 allocPoint) external;


    function sweepERC20Token(address token, address to) external;


    function flurryStakingRewards() external returns (IFlurryStakingRewards);

}//MIT
pragma solidity 0.8.9;


interface IRhoTokenRewards {

    function isSupported(address rhoToken) external returns (bool);


    function getRhoTokenList() external view returns (address[] memory);


    function rewardsRate() external view returns (uint256);


    function setRewardsRate(uint256 newRewardsRate) external;


    function rewardOf(address user, address rhoToken) external view returns (uint256);


    function totalRewardOf(address user) external view returns (uint256);


    function totalClaimableRewardOf(address user) external view returns (uint256);


    function rewardsPerToken(address rhoToken) external view returns (uint256);


    function rewardRatePerRhoToken(address rhoToken) external view returns (uint256);


    function startRewards(address rhoToken, uint256 rewardDuration) external;


    function startRewardsToBlock(address rhoToken, uint256 _rewardsEndBlock) external;


    function endRewards(address rhoToken) external;


    function updateReward(address user, address rhoToken) external;


    function claimReward(address onBehalfOf, address rhoToken) external;


    function claimReward(address rhoToken) external;


    function claimAllReward(address onBehalfOf) external;


    function claimAllReward() external;


    function isLocked(address rhoToken) external view returns (bool);


    function setTimeLock(address rhoToken, uint256 lockDuration) external;


    function setTimeLockEndBlock(address rhoToken, uint256 lockEndBlock) external;


    function setTimeLockForAllRho(uint256 lockDuration) external;


    function setTimeLockEndBlockForAllRho(uint256 lockEndBlock) external;


    function earlyUnlock(address rhoToken) external;


    function getLockEndBlock(address rhoToken) external view returns (uint256);


    function addRhoToken(address rhoToken, uint256 allocPoint) external;


    function setRhoToken(address rhoToken, uint256 allocPoint) external;


    function sweepERC20Token(address token, address to) external;


    function flurryStakingRewards() external returns (IFlurryStakingRewards);

}//MIT
pragma solidity 0.8.9;


interface IFlurryStakingRewards {

    function totalRewardsPool() external view returns (uint256);


    function totalStakes() external view returns (uint256);


    function stakeOf(address user) external view returns (uint256);


    function rewardOf(address user) external view returns (uint256);


    function claimableRewardOf(address user) external view returns (uint256);


    function totalRewardOf(address user) external view returns (uint256);


    function totalClaimableRewardOf(address user) external view returns (uint256);


    function rewardsRate() external view returns (uint256);


    function rewardsPerToken() external view returns (uint256);


    function rewardRatePerTokenStaked() external view returns (uint256);


    function stake(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function claimReward() external;


    function claimAllRewards() external;


    function grantFlurry(address addr, uint256 amount) external returns (uint256);


    function exit() external;


    function setRewardsRate(uint256 newRewardsRate) external;


    function startRewards(uint256 rewardsDuration) external;


    function startRewardsToBlock(uint256 _rewardsEndBlock) external;


    function endRewards() external;


    function isLocked() external view returns (bool);


    function setTimeLock(uint256 lockDuration) external;


    function earlyUnlock() external;


    function setTimeLockEndBlock(uint256 _lockEndBlock) external;


    function sweepERC20Token(address token, address to) external;


    function setRhoTokenRewardContract(address rhoTokenRewardAddr) external;


    function setLPRewardsContract(address lpRewardsAddr) external;


    function lpStakingRewards() external returns (ILPStakingRewards);


    function rhoTokenRewards() external returns (IRhoTokenRewards);

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}//MIT
pragma solidity 0.8.9;



abstract contract BaseRewards is AccessControlEnumerableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event RewardPaid(address indexed user, uint256 reward);
    event NotEnoughBalance(address indexed user, uint256 withdrawalAmount);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant SWEEPER_ROLE = keccak256("SWEEPER_ROLE");

    function __initialize() internal {
        AccessControlEnumerableUpgradeable.__AccessControlEnumerable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function getTokenOne(address token) internal view returns (uint256) {
        return 10**IERC20MetadataUpgradeable(token).decimals();
    }

    function _earned(
        uint256 _tokenBalance,
        uint256 _netRewardPerToken,
        uint256 _tokenOne,
        uint256 accumulatedReward
    ) internal pure returns (uint256) {
        return ((_tokenBalance * _netRewardPerToken) / _tokenOne) + accumulatedReward;
    }

    function _lastBlockApplicable(uint256 _rewardsEndBlock) internal view returns (uint256) {
        return MathUpgradeable.min(block.number, _rewardsEndBlock);
    }

    function rewardRatePerTokenInternal(
        uint256 rewardRate,
        uint256 tokenOne,
        uint256 allocPoint,
        uint256 totalToken,
        uint256 totalAllocPoint
    ) internal pure returns (uint256) {
        return (rewardRate * tokenOne * allocPoint) / (totalToken * totalAllocPoint);
    }

    function rewardPerTokenInternal(
        uint256 accruedRewardsPerToken,
        uint256 blockDelta,
        uint256 rewardRatePerToken
    ) internal pure returns (uint256) {
        return accruedRewardsPerToken + blockDelta * rewardRatePerToken;
    }

    function _sweepERC20Token(address token, address to) internal notZeroTokenAddr(token) {
        IERC20Upgradeable tokenToSweep = IERC20Upgradeable(token);
        tokenToSweep.safeTransfer(to, tokenToSweep.balanceOf(address(this)));
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    modifier notZeroAddr(address addr) {
        require(addr != address(0), "address is zero");
        _;
    }

    modifier notZeroTokenAddr(address addr) {
        require(addr != address(0), "token address is zero");
        _;
    }

    modifier isValidDuration(uint256 rewardDuration) {
        require(rewardDuration > 0, "Reward duration cannot be zero");
        _;
    }
}// MIT
pragma solidity 0.8.9;



contract FlurryStakingRewards is IFlurryStakingRewards, BaseRewards {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    event FlurryRewardsRateChanged(uint256 blockNumber, uint256 rewardsRate);
    event RewardsEndUpdated(uint256 blockNumber, uint256 rewardsEndBlock);
    event Staked(address indexed user, uint256 blockNumber, uint256 amount);
    event Withdrawn(address indexed user, uint256 blockNumber, uint256 amount);
    event StakeBalanceUpdate(address indexed user, uint256 blockNumber, uint256 amount);
    event TotalStakesChanged(uint256 totalStakes);

    bytes32 public constant LP_TOKEN_REWARDS_ROLE = keccak256("LP_TOKEN_REWARDS_ROLE");
    bytes32 public constant RHO_TOKEN_REWARDS_ROLE = keccak256("RHO_TOKEN_REWARDS_ROLE");

    uint256 public override rewardsRate;

    uint256 public lockEndBlock;

    uint256 public lastUpdateBlock;

    uint256 public rewardsPerTokenStored;

    uint256 public rewardsEndBlock;

    IERC20Upgradeable public flurryToken;
    uint256 public override totalStakes;
    uint256 public flurryTokenOne;

    struct UserInfo {
        uint256 stake;
        uint256 rewardPerTokenPaid;
        uint256 reward;
    }
    mapping(address => UserInfo) public userInfo;

    ILPStakingRewards public override lpStakingRewards;
    IRhoTokenRewards public override rhoTokenRewards;

    function initialize(address flurryTokenAddr) external initializer notZeroAddr(flurryTokenAddr) {

        BaseRewards.__initialize();
        flurryToken = IERC20Upgradeable(flurryTokenAddr);
        flurryTokenOne = getTokenOne(flurryTokenAddr);
    }

    function totalRewardsPool() external view override returns (uint256) {

        return _totalRewardsPool();
    }

    function _totalRewardsPool() internal view returns (uint256) {

        return flurryToken.balanceOf(address(this)) - totalStakes;
    }

    function stakeOf(address user) external view override notZeroAddr(user) returns (uint256) {

        return userInfo[user].stake;
    }

    function rewardOf(address user) external view override notZeroAddr(user) returns (uint256) {

        return _earned(user);
    }

    function claimableRewardOf(address user) external view override notZeroAddr(user) returns (uint256) {

        return block.number >= lockEndBlock ? _earned(user) : 0;
    }

    function lastBlockApplicable() internal view returns (uint256) {

        return _lastBlockApplicable(rewardsEndBlock);
    }

    function rewardsPerToken() public view override returns (uint256) {

        if (totalStakes == 0) return rewardsPerTokenStored;
        return
            rewardPerTokenInternal(
                rewardsPerTokenStored,
                lastBlockApplicable() - lastUpdateBlock,
                rewardRatePerTokenInternal(rewardsRate, flurryTokenOne, 1, totalStakes, 1)
            );
    }

    function rewardRatePerTokenStaked() external view override returns (uint256) {

        if (totalStakes == 0) return type(uint256).max;
        if (block.number > rewardsEndBlock) return 0;
        return rewardRatePerTokenInternal(rewardsRate, flurryTokenOne, 1, totalStakes, 1);
    }

    function updateRewardInternal() internal {

        rewardsPerTokenStored = rewardsPerToken();
        lastUpdateBlock = lastBlockApplicable();
    }

    function updateReward(address addr) internal {

        updateRewardInternal();
        if (addr != address(0)) {
            userInfo[addr].reward = _earned(addr);
            userInfo[addr].rewardPerTokenPaid = rewardsPerTokenStored;
        }
    }

    function _earned(address addr) internal view returns (uint256) {

        return
            super._earned(
                userInfo[addr].stake,
                rewardsPerToken() - userInfo[addr].rewardPerTokenPaid,
                flurryTokenOne,
                userInfo[addr].reward
            );
    }

    function setRewardsRate(uint256 newRewardsRate) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {

        updateRewardInternal();
        rewardsRate = newRewardsRate;
        emit FlurryRewardsRateChanged(block.number, rewardsRate);
    }

    function startRewards(uint256 rewardsDuration)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
        isValidDuration(rewardsDuration)
    {

        require(block.number > rewardsEndBlock, "Previous rewards period must complete before starting a new one");
        updateRewardInternal();
        lastUpdateBlock = block.number;
        rewardsEndBlock = block.number + rewardsDuration;
        emit RewardsEndUpdated(block.number, rewardsEndBlock);
    }

    function startRewardsToBlock(uint256 _rewardsEndBlock)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {

        require(block.number > rewardsEndBlock, "Previous rewards period must complete before starting a new one");
        require(_rewardsEndBlock > block.number, "rewardsEndBlock must be greater than the current block number");
        updateRewardInternal();
        lastUpdateBlock = block.number;
        rewardsEndBlock = _rewardsEndBlock;
        emit RewardsEndUpdated(block.number, rewardsEndBlock);
    }

    function endRewards() external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {

        if (rewardsEndBlock > block.number) {
            rewardsEndBlock = block.number;
            emit RewardsEndUpdated(block.number, rewardsEndBlock);
        }
    }

    function isLocked() external view override returns (bool) {

        return block.number <= lockEndBlock;
    }

    function setTimeLock(uint256 lockDuration) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {

        lockEndBlock = block.number + lockDuration;
    }

    function earlyUnlock() external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {

        lockEndBlock = block.number;
    }

    function setTimeLockEndBlock(uint256 _lockEndBlock) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {

        require(_lockEndBlock >= block.number);
        lockEndBlock = _lockEndBlock;
    }

    function stake(uint256 amount) external override whenNotPaused nonReentrant {

        address user = _msgSender();
        require(amount > 0, "Cannot stake 0 tokens");
        require(flurryToken.balanceOf(user) >= amount, "Not Enough balance to stake");
        updateReward(user);
        userInfo[user].stake += amount;
        totalStakes += amount;
        emit Staked(user, block.number, amount);
        emit StakeBalanceUpdate(user, block.number, userInfo[user].stake);
        emit TotalStakesChanged(totalStakes);
        flurryToken.safeTransferFrom(user, address(this), amount);
    }

    function withdraw(uint256 amount) external override whenNotPaused nonReentrant {

        _withdrawUser(_msgSender(), amount);
    }

    function _withdrawUser(address user, uint256 amount) internal {

        require(amount > 0, "Cannot withdraw 0 amount");
        require(userInfo[user].stake >= amount, "Exceeds staked amount");
        updateReward(user);
        userInfo[user].stake -= amount;
        totalStakes -= amount;
        emit Withdrawn(user, block.number, amount);
        emit StakeBalanceUpdate(user, block.number, userInfo[user].stake);
        emit TotalStakesChanged(totalStakes);
        flurryToken.safeTransfer(user, amount);
    }

    function exit() external override whenNotPaused nonReentrant {

        _withdrawUser(_msgSender(), userInfo[_msgSender()].stake);
    }

    function claimRewardInternal(address user) internal {

        if (block.number > lockEndBlock) {
            updateReward(user);
            if (userInfo[user].reward > 0) {
                userInfo[user].reward = grantFlurryInternal(user, userInfo[user].reward);
            }
        }
    }

    function claimReward() external override whenNotPaused nonReentrant {

        require(this.claimableRewardOf(_msgSender()) > 0, "nothing to claim");
        claimRewardInternal(_msgSender());
    }

    function claimAllRewards() external override whenNotPaused nonReentrant {

        require(this.totalClaimableRewardOf(_msgSender()) > 0, "nothing to claim");
        if (address(lpStakingRewards) != address(0)) lpStakingRewards.claimAllReward(_msgSender());
        if (address(rhoTokenRewards) != address(0)) rhoTokenRewards.claimAllReward(_msgSender());
        claimRewardInternal(_msgSender());
    }

    function grantFlurry(address addr, uint256 amount) external override onlyLPOrRhoTokenRewards returns (uint256) {

        return grantFlurryInternal(addr, amount);
    }

    function grantFlurryInternal(address addr, uint256 amount) internal notZeroAddr(addr) returns (uint256) {

        if (amount <= _totalRewardsPool()) {
            flurryToken.safeTransfer(addr, amount);
            emit RewardPaid(addr, amount);
            return 0;
        }
        emit NotEnoughBalance(addr, amount);
        return amount;
    }

    function isStakeholder(address addr) external view notZeroAddr(addr) returns (bool) {

        return userInfo[addr].stake > 0;
    }

    function sweepERC20Token(address token, address to) external override onlyRole(SWEEPER_ROLE) {

        require(token != address(flurryToken), "!safe");
        _sweepERC20Token(token, to);
    }

    function totalRewardOf(address user) external view override notZeroAddr(user) returns (uint256) {

        uint256 otherRewards;

        if (address(lpStakingRewards) != address(0)) otherRewards += lpStakingRewards.totalRewardOf(user);
        if (address(rhoTokenRewards) != address(0)) otherRewards += rhoTokenRewards.totalRewardOf(user);
        return otherRewards + this.rewardOf(user);
    }

    function totalClaimableRewardOf(address user) external view override notZeroAddr(user) returns (uint256) {

        uint256 otherRewards;

        if (address(lpStakingRewards) != address(0)) otherRewards += lpStakingRewards.totalClaimableRewardOf(user);
        if (address(rhoTokenRewards) != address(0)) otherRewards += rhoTokenRewards.totalClaimableRewardOf(user);
        return otherRewards + this.claimableRewardOf(user);
    }

    function setRhoTokenRewardContract(address _rhoTokenRewardAddr)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        notZeroAddr(_rhoTokenRewardAddr)
        whenNotPaused
    {

        rhoTokenRewards = IRhoTokenRewards(_rhoTokenRewardAddr);
    }

    function setLPRewardsContract(address lpRewardsAddr)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        notZeroAddr(lpRewardsAddr)
        whenNotPaused
    {

        lpStakingRewards = ILPStakingRewards(lpRewardsAddr);
    }

    modifier onlyLPOrRhoTokenRewards() {

        require(
            hasRole(LP_TOKEN_REWARDS_ROLE, _msgSender()) || hasRole(RHO_TOKEN_REWARDS_ROLE, _msgSender()),
            string(
                abi.encodePacked(
                    "AccessControl: account ",
                    StringsUpgradeable.toHexString(uint160(_msgSender()), 20),
                    " is missing role ",
                    StringsUpgradeable.toHexString(uint256(LP_TOKEN_REWARDS_ROLE), 32),
                    " or role ",
                    StringsUpgradeable.toHexString(uint256(RHO_TOKEN_REWARDS_ROLE), 32)
                )
            )
        );
        _;
    }
}