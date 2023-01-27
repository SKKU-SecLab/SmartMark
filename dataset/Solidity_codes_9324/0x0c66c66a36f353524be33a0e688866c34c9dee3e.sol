
pragma solidity ^0.8.0;

interface IERC20 {

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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value < 2**96, "SafeCast: value doesn\'t fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }
}// MIT

pragma solidity ^0.8.0;


interface ICreatureRewards is IERC165Upgradeable {

    event EnergyUpdated(address indexed user, bool increase, uint energy, uint timestamp);
    event StakedTransfer(address indexed from, address to, uint indexed tokenId, uint energy);

    event RewardsSet(uint32 start, uint32 end, uint256 rate);
    event RewardsPerEnergyUpdated(uint256 accumulated);
    event UserRewardsUpdated(address user, uint256 userRewards, uint256 paidRewardPerEnergy);
    event RewardClaimed(address receiver, uint256 claimed);

    function stakedEnergy(address user) external view returns(uint);

    function getRewardRate() external view returns(uint);

    function checkUserRewards(address user) external view returns(uint);

    function version() external view returns(string memory);


    function alertStaked(address user, uint tokenId, bool staked, uint energy) external;

    function alertBoost(address user, uint tokenId, bool boost, uint energy) external;

    function alertStakedTransfer(address from, address to, uint tokenId, uint energy) external;

    function claim(address to) external;

}// MIT
pragma solidity ^0.8.2;


contract CreatureRewards is Initializable, ContextUpgradeable, ERC165Upgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {

    using SafeCast for uint;
    
    event EnergyUpdated(address indexed user, bool increase, uint energy, uint timestamp);
    event StakedTransfer(address indexed from, address to, uint indexed tokenId, uint energy);

    event RewardsSet(uint32 start, uint32 end, uint256 rate);
    event RewardsUpdated(uint32 start, uint32 end, uint256 rate);
    event RewardsPerEnergyUpdated(uint256 accumulated);
    event UserRewardsUpdated(address user, uint256 userRewards, uint256 paidRewardPerEnergy);
    event RewardClaimed(address receiver, uint256 claimed);

    struct RewardsPeriod {
        uint32 start;
        uint32 end;
    }

    struct RewardsPerEnergy {
        uint32 totalEnergy;
        uint96 accumulated;
        uint32 lastUpdated;
        uint96 rate;
    }

    struct UserRewards {
        uint32 stakedEnergy;
        uint96 accumulated;
        uint96 checkpoint;
    }

    RewardsPeriod public rewardsPeriod;
    RewardsPerEnergy public rewardsPerEnergy;     
    mapping (address => UserRewards) public rewards;
    bytes32 private constant NFT_ROLE = keccak256("NFT_ROLE");
    bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
    address public LFG_TOKEN;


    function initialize() public virtual initializer {

        __Context_init();
        __ERC165_init();
        __AccessControl_init();
        __ReentrancyGuard_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OWNER_ROLE, _msgSender());
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, AccessControlUpgradeable) returns (bool) {

        return interfaceId == type(ICreatureRewards).interfaceId || super.supportsInterface(interfaceId);
    }

    function setRewardToken(address token) external virtual onlyRole(OWNER_ROLE) {

        require(token != address(0), "addr 0");
        require(LFG_TOKEN == address(0), "Can only set once");
        LFG_TOKEN = token;
    }

    function setRewards(uint32 start, uint32 end, uint96 rate) external virtual onlyRole(OWNER_ROLE) {

        require(start <= end, "Incorrect input");
        require(rate > 0.03 ether && rate < 30 ether, "Rate incorrect");
        require(LFG_TOKEN != address(0), "Rewards token not set");
        require(block.timestamp.toUint32() < rewardsPeriod.start || block.timestamp.toUint32() > rewardsPeriod.end, "Rewards already set");

        rewardsPeriod.start = start;
        rewardsPeriod.end = end;

        rewardsPerEnergy.lastUpdated = start;
        rewardsPerEnergy.rate = rate;

        emit RewardsSet(start, end, rate);
    }

    function updateRewards(uint96 rate) external virtual onlyRole(OWNER_ROLE) {

        require(rate > 0.03 ether && rate < 30 ether, "Rate incorrect");
        require(block.timestamp.toUint32() > rewardsPeriod.start && block.timestamp.toUint32() < rewardsPeriod.end, "Rewards not active");
        rewardsPerEnergy.rate = rate;

        emit RewardsUpdated(rewardsPeriod.start, rewardsPeriod.end, rate);
    }


    function alertStaked(address user, uint, bool staked, uint energy) external virtual onlyRole(NFT_ROLE) {

        _updateRewardsPerEnergy(energy.toUint32(), staked);
        _updateUserRewards(user, energy.toUint32(), staked);
    }

    function alertBoost(address user, uint, bool boost, uint energy) external virtual onlyRole(NFT_ROLE) {

        _updateRewardsPerEnergy(energy.toUint32(), boost);
        _updateUserRewards(user, energy.toUint32(), boost);
    }

    function alertStakedTransfer(address from, address to, uint tokenId, uint energy) external virtual onlyRole(NFT_ROLE) {

        emit StakedTransfer(from, to, tokenId, energy);
    }


    function claim(address to) virtual external
    {

        _updateRewardsPerEnergy(0, false);
        uint claiming = _updateUserRewards(_msgSender(), 0, false);
        rewards[_msgSender()].accumulated = 0; // A Claimed event implies the rewards were set to zero
        TransferHelper.safeTransfer(LFG_TOKEN, to, claiming);
        emit RewardClaimed(to, claiming);
    }


    function stakedEnergy(address user) external virtual view returns(uint) {

        return rewards[user].stakedEnergy;
    }

    function getRewardRate() external virtual view returns(uint) {

        return rewardsPerEnergy.rate;
    }

    function checkUserRewards(address user) external virtual view returns(uint) {

        RewardsPerEnergy memory rewardsPerEnergy_ = rewardsPerEnergy;
        RewardsPeriod memory rewardsPeriod_ = rewardsPeriod;
        UserRewards memory userRewards_ = rewards[user];

        uint32 end = earliest(block.timestamp.toUint32(), rewardsPeriod_.end);
        uint256 unaccountedTime = end - rewardsPerEnergy_.lastUpdated; // Cast to uint256 to avoid overflows later on
        if (unaccountedTime != 0) {

            if (rewardsPerEnergy_.totalEnergy != 0) {
                rewardsPerEnergy_.accumulated = (rewardsPerEnergy_.accumulated + unaccountedTime * rewardsPerEnergy_.rate / rewardsPerEnergy_.totalEnergy).toUint96();
            }
            rewardsPerEnergy_.lastUpdated = end;
        }
        userRewards_.accumulated = userRewards_.accumulated + userRewards_.stakedEnergy * (rewardsPerEnergy_.accumulated - userRewards_.checkpoint);
        userRewards_.checkpoint = rewardsPerEnergy_.accumulated;
        return userRewards_.accumulated;
    }

    function version() external virtual view returns(string memory) {

        return "1.0.0";
    }


    function earliest(uint32 x, uint32 y) internal pure returns (uint32 z) {

        z = (x < y) ? x : y;
    }

    function _updateRewardsPerEnergy(uint32 energy, bool increase) internal virtual {

        RewardsPerEnergy memory rewardsPerEnergy_ = rewardsPerEnergy;
        RewardsPeriod memory rewardsPeriod_ = rewardsPeriod;

        if (block.timestamp.toUint32() >= rewardsPeriod_.start) {

            uint32 end = earliest(block.timestamp.toUint32(), rewardsPeriod_.end);
            uint256 unaccountedTime = end - rewardsPerEnergy_.lastUpdated; // Cast to uint256 to avoid overflows later on
            if (unaccountedTime != 0) {

                if (rewardsPerEnergy_.totalEnergy != 0) {
                    rewardsPerEnergy_.accumulated = (rewardsPerEnergy_.accumulated + unaccountedTime * rewardsPerEnergy_.rate / rewardsPerEnergy_.totalEnergy).toUint96();
                }
                rewardsPerEnergy_.lastUpdated = end;
            }
        }
        if (increase) {
            rewardsPerEnergy_.totalEnergy += energy;
        }
        else {
            rewardsPerEnergy_.totalEnergy -= energy;
        }
        rewardsPerEnergy = rewardsPerEnergy_;
        emit RewardsPerEnergyUpdated(rewardsPerEnergy_.accumulated);
    }

    function _updateUserRewards(address user, uint32 energy, bool increase) internal virtual returns (uint96) {

        UserRewards memory userRewards_ = rewards[user];
        RewardsPerEnergy memory rewardsPerEnergy_ = rewardsPerEnergy;
        
        userRewards_.accumulated = userRewards_.accumulated + userRewards_.stakedEnergy * (rewardsPerEnergy_.accumulated - userRewards_.checkpoint);
        userRewards_.checkpoint = rewardsPerEnergy_.accumulated;

        if (increase) {
            userRewards_.stakedEnergy += energy;
        }
        else {
            userRewards_.stakedEnergy -= energy;
        }
        rewards[user] = userRewards_;
        emit EnergyUpdated(user, increase, energy, block.timestamp);
        emit UserRewardsUpdated(user, userRewards_.accumulated, userRewards_.checkpoint);

        return userRewards_.accumulated;
    }

}


library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }
    
    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {

        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
        }
    }
}