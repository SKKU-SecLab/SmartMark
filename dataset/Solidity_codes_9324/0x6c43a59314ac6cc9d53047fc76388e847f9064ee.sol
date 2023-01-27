
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
}//MIT
pragma solidity ^0.8.0;


abstract contract AccessLevel is AccessControlUpgradeable {
    
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    
    function __AccessLevel_init(address owner) initializer public {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library StorageSlotUpgradeable {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
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
pragma solidity ^0.8.0;


contract StakePIF is UUPSUpgradeable, AccessLevel,ReentrancyGuardUpgradeable {

    
    using SafeERC20Upgradeable for IERC20Upgradeable;
    
    IERC20Upgradeable public stakingToken;
    IERC20Upgradeable public rewardToken;
 
    event Unstake(uint256 stakeId, address unstaker);
    event Stake(uint256 stakeId, address staker);
    event SetStakingEnabled(bool stakingEnabled, address sender);
    event SetMaxLoss(uint maxLoss, address sender);   
    event SetMaxStakingWeeks(uint maxStakingWeeks, address sender);   
    event SetRewardRate(uint rewardRate, address sender);   
    event SetMinClaimPeriod(uint rewardRate, address sender);
    event SetCommunityAddress(address communityAddress, address sender);

    struct StakingInfo{
        address owner;
        uint id;
        uint timeToUnlock;
        uint stakingTime;
        uint tokensStaked;
        uint tokensStakedWithBonus;
    }

    address public communityAddress;
    bool public stakingEnabled;
    uint private constant DIVISOR = 1e11;
    uint private constant DECIMAL = 1e18;
    uint private constant WEEK_PER_YEAR = 52;
    uint public maxLoss;
    uint public maxStakingWeeks;
    uint public rewardRate; 
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;
    uint public minClaimPeriod;
    uint public uniqueAddressesStaked;
    uint public totalTokensStaked;
    uint public totalRewardsClaimed;

    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;
    mapping(address => mapping(uint => StakingInfo)) public stakingInfoForAddress;
    mapping(address => uint) public tokensStakedByAddress;
    mapping(address => uint) public tokensStakedWithBonusByAddress;
    mapping(address => uint) public totalRewardsClaimedByAddress;

    uint public totalTokensStakedWithBonusTokens;
    mapping(address => uint) public balances;
    mapping(address => uint) public lastClaimedTimestamp;
    mapping(address => uint) public stakingNonce;


    function _authorizeUpgrade(address) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}


    

    function initialize(address tokenAddress_, address rewardToken_, address owner_, address communityAddress_, uint minClaimPeriod_, uint rewardRate_, uint maxLoss_, uint maxStakingWeeks_) initializer external {

        require(tokenAddress_ != address(0),"INVALID_TOKEN_ADDRESS");
        require(rewardToken_ != address(0),"INVALID_TOKEN_ADDRESS");
        require(owner_ != address(0),"INVALID_OWNER_ADDRESS");
        require(communityAddress_ != address(0),"INVALID_COMMUNITY_ADDRESS");
        require(minClaimPeriod_ > 0,"INVALID_MIN_CLAIM_PERIOD");
        require(rewardRate_ > 0,"INVALID_REWARD_RATE");
        require(maxLoss_ > 0,"INVALID_MAX_LOSS");
        require(maxLoss_ < DIVISOR, "INVALID_MAX_LOSS");
        require(maxStakingWeeks_ > 0,"INVALID_MAX_STAKING_WEEKS");

        __AccessLevel_init(owner_);
        __ReentrancyGuard_init();
        stakingToken = IERC20Upgradeable(tokenAddress_);
        rewardToken = IERC20Upgradeable(rewardToken_);
        stakingEnabled = true;
        communityAddress = communityAddress_;
        minClaimPeriod = minClaimPeriod_;
        rewardRate = rewardRate_;
        maxLoss = maxLoss_;
        maxStakingWeeks = maxStakingWeeks_;
    }

    function rewardPerToken() public view returns (uint) {

        if (totalTokensStakedWithBonusTokens == 0) {
            return 0;
        }

        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * DECIMAL) / totalTokensStakedWithBonusTokens);
    }

    function earned(address account_) public view returns (uint) {

        return
            ((balances[account_] *
                (rewardPerToken() - userRewardPerTokenPaid[account_])) / DECIMAL) +
            rewards[account_];
    }

    modifier updateReward(address account_) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account_] = earned(account_);
        userRewardPerTokenPaid[account_] = rewardPerTokenStored;
        _;
    }

    function stake(uint amount_, uint lockWeek_) external nonReentrant() updateReward(msg.sender) {

        require(stakingEnabled , "STAKING_DISABLED");
        require(amount_ > 0, "CANNOT_STAKE_0");
        require(lockWeek_ <= maxStakingWeeks, "LOCK_TIME_ERROR");

        if(stakingNonce[msg.sender] == 0){
            uniqueAddressesStaked++;
        }

        stakingNonce[msg.sender]++;
        uint bonusTokenWeightage = DIVISOR + DIVISOR * lockWeek_ / WEEK_PER_YEAR;
        if (lockWeek_ > WEEK_PER_YEAR) {
            bonusTokenWeightage += DIVISOR * (lockWeek_ - WEEK_PER_YEAR) / WEEK_PER_YEAR;
        }
        uint tokensWithBonus = amount_ * bonusTokenWeightage / DIVISOR;

        totalTokensStaked += amount_;
        totalTokensStakedWithBonusTokens += tokensWithBonus;
        balances[msg.sender] += tokensWithBonus;
        tokensStakedByAddress[msg.sender] += amount_;
        tokensStakedWithBonusByAddress[msg.sender] += tokensWithBonus;
        lastClaimedTimestamp[msg.sender] = block.timestamp;

        StakingInfo storage data = stakingInfoForAddress[msg.sender][stakingNonce[msg.sender]];
        data.owner = msg.sender;
        data.stakingTime = block.timestamp;
        data.tokensStaked = amount_;
        data.timeToUnlock = block.timestamp + lockWeek_ * 604800;
        data.tokensStakedWithBonus = tokensWithBonus;
        data.id = stakingNonce[msg.sender];

        emit Stake(stakingNonce[msg.sender], msg.sender);
       
        stakingToken.safeTransferFrom(msg.sender, address(this), amount_);
    
    }

    function unstake(uint stakeId_) external nonReentrant() updateReward(msg.sender) {

        getRewardInternal();
        StakingInfo storage info = stakingInfoForAddress[msg.sender][stakeId_];
        require(stakeId_ > 0 && info.id == stakeId_,"INVALID_STAKE_ID");
        
        totalTokensStaked -= info.tokensStaked;
        totalTokensStakedWithBonusTokens -= info.tokensStakedWithBonus;
        balances[msg.sender] -= info.tokensStakedWithBonus;
        tokensStakedByAddress[msg.sender] -= info.tokensStaked;
        tokensStakedWithBonusByAddress[msg.sender] -= info.tokensStakedWithBonus;

        if (balances[msg.sender] == 0) {
            userRewardPerTokenPaid[msg.sender] = 0;
        }

        uint tokensLost = 0;
        uint tokensTotal = info.tokensStaked;
        
        if(info.timeToUnlock > block.timestamp) {
            uint maxTime = info.timeToUnlock - info.stakingTime;
            uint lossPercentage = maxLoss - (block.timestamp - info.stakingTime) * maxLoss / maxTime;
            tokensLost = lossPercentage * info.tokensStaked / DIVISOR;
            stakingToken.safeTransfer(communityAddress, tokensLost);
           
        }

        delete stakingInfoForAddress[msg.sender][stakeId_];
        emit Unstake(stakeId_, msg.sender);

        stakingToken.safeTransfer(msg.sender, tokensTotal - tokensLost);
        
    }

    function getReward() external nonReentrant() updateReward(msg.sender) {

        require(lastClaimedTimestamp[msg.sender] + minClaimPeriod <= block.timestamp,
         "CANNOT_CLAIM_REWARDS_YET");
        getRewardInternal();
    }

    function getRewardInternal() internal {

        lastClaimedTimestamp[msg.sender] = block.timestamp;
        uint reward = rewards[msg.sender];
        require(stakingToken.balanceOf(address(this)) >= reward ,"BALANCE_NOT_ENOUGH");

        rewards[msg.sender] = 0;
        totalRewardsClaimed += reward;
        totalRewardsClaimedByAddress[msg.sender] += reward;
        rewardToken.safeTransfer(msg.sender, reward);
    }

    function setStakingEnabled(bool stakingEnabled_) external onlyRole(OPERATOR_ROLE) {

        stakingEnabled = stakingEnabled_;

        emit SetStakingEnabled(stakingEnabled_,msg.sender);
    }

    function setMaxLoss(uint maxLoss_) external onlyRole(OPERATOR_ROLE) {

        require(maxLoss_ > 0,"INVALID_MAX_LOSS");
        require(maxLoss_ < DIVISOR, "INVALID_MAX_LOSS");
        maxLoss = maxLoss_;

        emit SetMaxLoss(maxLoss_,msg.sender);
    }

    function setMaxStakingWeeks(uint maxStakingWeeks_) external onlyRole(OPERATOR_ROLE) {

        require(maxStakingWeeks_ > 0,"INVALID_MAX_LOSS");
        maxStakingWeeks = maxStakingWeeks_;

        emit SetMaxStakingWeeks(maxStakingWeeks_,msg.sender);
    }

    function setRewardRate(uint rewardRate_) external onlyRole(OPERATOR_ROLE) {

        require(rewardRate_ > 0, "INVALID_REWARD_RATE");
        rewardRate = rewardRate_;

        emit SetRewardRate(rewardRate_,msg.sender);
    }

    function setMinClaimPeriod(uint minClaimPeriod_) external onlyRole(OPERATOR_ROLE) {

        require(minClaimPeriod_ > 0,"INVALID_MIN_CLAIM_PERIOD");
        minClaimPeriod = minClaimPeriod_;

        emit SetMinClaimPeriod(minClaimPeriod_,msg.sender);
    }

    function setCommunityAddress_(address communityAddress_) external onlyRole(OPERATOR_ROLE) {

        communityAddress = communityAddress_;

        emit SetCommunityAddress(communityAddress,msg.sender);
    }

    function getAllAddressStakes(address userAddress_) public view returns(StakingInfo[] memory)
    {

        StakingInfo[] memory stakings = new StakingInfo[](stakingNonce[userAddress_]);
        for (uint i = 0; i < stakingNonce[userAddress_]; i++) {
            StakingInfo memory staking = stakingInfoForAddress[userAddress_][i+1];
            if(staking.tokensStaked > 0){
                stakings[i] = staking;
            }
        }
        return stakings;
    }
}