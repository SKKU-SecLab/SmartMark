


pragma solidity 0.8.6;

library Address {

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}


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
}

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
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

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
}

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
}

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
}

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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
}

interface IAccessControlUpgradeable {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

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

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
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
}

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
}

interface IClusterToken {

    function assemble(uint256 clusterAmount, bool coverDhvWithEth) external payable returns (uint256);


    function disassemble(uint256 indexAmount, bool coverDhvWithEth) external;


    function withdrawToAccumulation(uint256 _clusterAmount) external;


    function refundFromAccumulation(uint256 _clusterAmount) external;


    function returnDebtFromAccumulation(uint256[] calldata _amounts, uint256 _clusterAmount) external;


    function optimizeProportion(uint256[] memory updatedShares) external returns (uint256[] memory debt);


    function getUnderlyingInCluster() external view returns (uint256[] calldata);


    function getUnderlyings() external view returns (address[] calldata);


    function getUnderlyingBalance(address _underlying) external view returns (uint256);


    function getUnderlyingsAmountsFromClusterAmount(uint256 _clusterAmount) external view returns (uint256[] calldata);


    function clusterTokenLock() external view returns (uint256);


    function clusterLock(address _token) external view returns (uint256);


    function controllerChange(address) external;


    function assembleByAdapter(uint256 _clusterAmount) external;


    function disassembleByAdapter(uint256 _clusterAmount) external;

}


interface IStakingDHV {

    function dhvToken() external view returns (address);


    function lastRewardBlock() external view returns (uint256);


    function accDhvPerShare() external view returns (uint256);


    function dhvPerBlock() external view returns (uint256);


    function userInfo(address) external view returns (uint256, uint256);


    function onPause() external view returns (bool);


    function clusterRate(address) external view returns (uint256);


    function totalLockedDhvByUser(address) external view returns (uint256);


    function lockedDhvForClusterByUser(address, address) external view returns (uint256);


    function setDHVToken(IERC20 _dhvTokenAddress) external;


    function setOnPause(bool _paused) external;


    function setDhvPerBlock(uint256 _dhvPerBlock) external;


    function pendingDhv(address _user) external view returns (uint256);


    function updateRewards() external;


    function deposit(uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    function adminWithdrawDhv(uint256 _amount) external;


    function setClusterRate(address _cluster, uint256 _rate) external;


    function coverCluster(
        address _cluster,
        address _user,
        uint256 _amount,
        uint256 _pid
    ) external;


    function releaseCluster(
        address _cluster,
        address _user,
        uint256 _amount,
        uint256 _pid
    ) external;


    function releaseClusterTotal(
        address _cluster,
        address _user,
        uint256 _pid
    ) external;


    function claimRewards() external;

}

contract StakingPools is AccessControlUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20 for IERC20;


    struct UserInfo {
        uint256 amount; // How many ASSET tokensens the user has provided.
        uint256[] rewardsDebts; // Order like in AssetInfo rewardsTokens
    }
    struct PoolInfo {
        address assetToken; // Address of LP token contract.
        uint256 lastRewardBlock; // Last block number that DHVs distribution occurs.
        uint256[] accumulatedPerShare; // Accumulated token per share, times token decimals. See below.
        address[] rewardsTokens; // Must be constant.
        uint256[] rewardsPerBlock; // Tokens to distribute per block.
        uint256[] accuracy; // Tokens accuracy.
        uint256 poolSupply; // Total amount of deposits by users.
        bool paused;
    }


    mapping(uint256 => PoolInfo) public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 indexed poolId, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed poolId, uint256 amount);
    event ClaimRewards(address indexed user, uint256 indexed poolId, address[] tokens, uint256[] amounts);


    modifier hasPool(uint256 _pid) {

        require(poolExist(_pid), "Pool not exist");
        _;
    }

    modifier poolRunning(uint256 _pid) {

        require(!poolInfo[_pid].paused, "Pool on pause");
        _;
    }


    function initialize() public virtual initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        __ReentrancyGuard_init();
    }

    function addPool(
        uint256 _pid,
        address _assetAddress,
        address[] calldata _rewardsTokens,
        uint256[] calldata _rewardsPerBlock
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(!poolExist(_pid), "Pool exist");
        require(_assetAddress != address(0), "Wrong asset address");
        require(_rewardsTokens.length == _rewardsPerBlock.length, "Wrong rewards tokens");

        poolInfo[_pid] = PoolInfo({
            assetToken: _assetAddress,
            lastRewardBlock: block.number,
            accumulatedPerShare: new uint256[](_rewardsTokens.length),
            rewardsTokens: _rewardsTokens,
            accuracy: new uint256[](_rewardsTokens.length),
            rewardsPerBlock: _rewardsPerBlock,
            poolSupply: 0,
            paused: false
        });
        for (uint256 i = 0; i < _rewardsTokens.length; i++) {
            poolInfo[_pid].accuracy[i] = 10**IERC20Metadata(_rewardsTokens[i]).decimals();
        }
    }

    function updatePoolSettings(
        uint256 _pid,
        uint256[] calldata _rewardsPerBlock,
        bool _withUpdate
    ) external onlyRole(DEFAULT_ADMIN_ROLE) hasPool(_pid) {

        if (_withUpdate) {
            updatePool(_pid);
        }

        require(poolInfo[_pid].rewardsTokens.length == _rewardsPerBlock.length, "Wrong rewards tokens");
        poolInfo[_pid].rewardsPerBlock = _rewardsPerBlock;
    }

    function setOnPause(uint256 _pid, bool _paused) external hasPool(_pid) onlyRole(DEFAULT_ADMIN_ROLE) {

        poolInfo[_pid].paused = _paused;
    }


    function updatePool(uint256 _pid) public hasPool(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.poolSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blocks = block.number - pool.lastRewardBlock;
        for (uint256 i = 0; i < pool.rewardsTokens.length; i++) {
            uint256 unaccountedReward = pool.rewardsPerBlock[i] * blocks;
            pool.accumulatedPerShare[i] = pool.accumulatedPerShare[i] + (unaccountedReward * pool.accuracy[i]) / pool.poolSupply;
        }
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public virtual nonReentrant hasPool(_pid) poolRunning(_pid) {

        updatePool(_pid);
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        if (user.rewardsDebts.length == 0 && pool.rewardsTokens.length > 0) {
            user.rewardsDebts = new uint256[](pool.rewardsTokens.length);
        }

        uint256 poolAmountBefore = user.amount;
        user.amount += _amount;

        for (uint256 i = 0; i < pool.rewardsTokens.length; i++) {
            _updateUserInfo(pool, user, i, poolAmountBefore);
        }
        poolInfo[_pid].poolSupply += _amount;

        IERC20(pool.assetToken).safeTransferFrom(_msgSender(), address(this), _amount);

        emit Deposit(_msgSender(), _pid, _amount);
    }

    function depositFor(uint256 _pid, uint256 _amount, address _user) public virtual nonReentrant hasPool(_pid) poolRunning(_pid) {

        updatePool(_pid);
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        if (user.rewardsDebts.length == 0 && pool.rewardsTokens.length > 0) {
            user.rewardsDebts = new uint256[](pool.rewardsTokens.length);
        }

        uint256 poolAmountBefore = user.amount;
        user.amount += _amount;

        for (uint256 i = 0; i < pool.rewardsTokens.length; i++) {
            _updateUserInfo(pool, user, i, poolAmountBefore);
        }
        poolInfo[_pid].poolSupply += _amount;

        IERC20(pool.assetToken).safeTransferFrom(_msgSender(), address(this), _amount);

        emit Deposit(_user, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public virtual nonReentrant poolRunning(_pid) hasPool(_pid) {

        updatePool(_pid);
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        require(user.amount > 0 && user.amount >= _amount, "withdraw: wrong amount");
        uint256 poolAmountBefore = user.amount;
        user.amount -= _amount;

        for (uint256 i = 0; i < pool.rewardsTokens.length; i++) {
            _updateUserInfo(pool, user, i, poolAmountBefore);
        }
        poolInfo[_pid].poolSupply -= _amount;
        IERC20(pool.assetToken).safeTransfer(_msgSender(), _amount);
        emit Withdraw(_msgSender(), _pid, _amount);
    }

    function claimRewards(uint256 _pid) external nonReentrant poolRunning(_pid) {

        _claimRewards(_pid, _msgSender());
    }

    function _updateUserInfo(
        PoolInfo memory pool,
        UserInfo storage user,
        uint256 _tokenNum,
        uint256 _amount
    ) internal returns (uint256 pending) {

        uint256 accumulatedPerShare = pool.accumulatedPerShare[_tokenNum];

        if (_amount > 0) {
            pending = (_amount * accumulatedPerShare) / pool.accuracy[_tokenNum] - user.rewardsDebts[_tokenNum];
            if (pending > 0) {
                IERC20(pool.rewardsTokens[_tokenNum]).safeTransfer(_msgSender(), pending);
            }
        }
        user.rewardsDebts[_tokenNum] = (user.amount * accumulatedPerShare) / pool.accuracy[_tokenNum];
    }


    function pendingRewards(uint256 _pid, address _user) external view hasPool(_pid) returns (uint256[] memory amounts) {

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        amounts = new uint256[](pool.rewardsTokens.length);
        for (uint256 i = 0; i < pool.rewardsTokens.length; i++) {
            uint256 accumulatedPerShare = pool.accumulatedPerShare[i];
            if (block.number > pool.lastRewardBlock && pool.poolSupply != 0) {
                uint256 blocks = block.number - pool.lastRewardBlock;
                uint256 unaccountedReward = pool.rewardsPerBlock[i] * blocks;
                accumulatedPerShare = accumulatedPerShare + (unaccountedReward * pool.accuracy[i]) / pool.poolSupply;
            }
            uint256 rewardsDebts = 0;
            if (user.rewardsDebts.length > 0) {
                rewardsDebts = user.rewardsDebts[i];
            }
            amounts[i] = (user.amount * accumulatedPerShare) / pool.accuracy[i] - rewardsDebts;
        }
    }

    function poolExist(uint256 _pid) public view returns (bool) {

        return poolInfo[_pid].assetToken != address(0);
    }

    function userPoolAmount(uint256 _pid, address _user) external view returns (uint256) {

        return userInfo[_pid][_user].amount;
    }


    function _claimRewards(uint256 _pid, address _user) internal {

        updatePool(_pid);
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256[] memory amounts = new uint256[](pool.rewardsTokens.length);
        for (uint256 i = 0; i < pool.rewardsTokens.length; i++) {
            amounts[i] = _updateUserInfo(pool, user, i, user.amount);
        }
        emit ClaimRewards(_user, _pid, pool.rewardsTokens, amounts);
    }
}

contract StakingDHV is StakingPools {

    using SafeERC20 for IERC20;

    bytes32 public constant CLUSTER_LOCK_ROLE = keccak256("CLUSTER_LOCK_ROLE");

    address public dhvToken;
    uint256 public constant CLUSTER_RATE_ACCURACY = 1e12;
    mapping(address => uint256) public clusterRate;
    mapping(address => uint256) public totalLockedDhvByUser;
    mapping(address => mapping(address => uint256)) public lockedDhvForClusterByUser;

    modifier hasDHV(uint256 _pid) {

        require(dhvToken != address(0), "Unknown address for DHV");
        require(poolInfo[_pid].assetToken == address(dhvToken), "Wrong pool id");
        _;
    }
    modifier hasCluster(address _cluster) {

        require(clusterRate[_cluster] > 0, "Rate is zero");
        _;
    }

    function initialize() public override initializer {

        StakingPools.initialize();
    }


    function setDHVToken(address _dhvTokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {

        dhvToken = _dhvTokenAddress;
    }

    function setClusterRate(address _cluster, uint256 _rate) external onlyRole(DEFAULT_ADMIN_ROLE) {

        clusterRate[_cluster] = _rate;
    }


    function coverCluster(
        address _cluster,
        address _user,
        uint256 _amount,
        uint256 _pid
    ) external hasDHV(_pid) hasCluster(_cluster) onlyRole(CLUSTER_LOCK_ROLE) {

        uint256 amountInDhv = (_amount * CLUSTER_RATE_ACCURACY) / clusterRate[_cluster];
        require(amountInDhv > 0, "wrong amount or too small amount");
        require(userInfo[_pid][_user].amount - totalLockedDhvByUser[_user] >= amountInDhv, "Insufficiently DHV");

        lockedDhvForClusterByUser[_cluster][_user] += amountInDhv;
        totalLockedDhvByUser[_user] += amountInDhv;
    }

    function releaseCluster(
        address _cluster,
        address _user,
        uint256 _amount,
        uint256 _pid
    ) external hasDHV(_pid) hasCluster(_cluster) onlyRole(CLUSTER_LOCK_ROLE) {

        require(_amount > 0, "amount is zero");
        uint256 amountInDhv = (_amount * CLUSTER_RATE_ACCURACY) / clusterRate[_cluster];

        if (amountInDhv > lockedDhvForClusterByUser[_cluster][_user]) {
            amountInDhv = lockedDhvForClusterByUser[_cluster][_user];
        }

        lockedDhvForClusterByUser[_cluster][_user] -= amountInDhv;
        totalLockedDhvByUser[_user] -= amountInDhv;
    }

    function releaseClusterTotal(
        address _cluster,
        address _user,
        uint256 _pid
    ) external hasDHV(_pid) hasCluster(_cluster) onlyRole(CLUSTER_LOCK_ROLE) {

        totalLockedDhvByUser[_user] -= lockedDhvForClusterByUser[_cluster][_user];
        lockedDhvForClusterByUser[_cluster][_user] = 0;
    }
}