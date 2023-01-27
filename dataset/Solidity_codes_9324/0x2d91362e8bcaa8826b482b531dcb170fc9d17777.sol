
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


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface IPermissions is IAccessControl {


    function createRole(bytes32 role, bytes32 adminRole) external;


    function grantMinter(address minter) external;


    function grantBurner(address burner) external;


    function grantPCVController(address pcvController) external;


    function grantGovernor(address governor) external;


    function grantGuardian(address guardian) external;


    function revokeMinter(address minter) external;


    function revokeBurner(address burner) external;


    function revokePCVController(address pcvController) external;


    function revokeGovernor(address governor) external;


    function revokeGuardian(address guardian) external;



    function revokeOverride(bytes32 role, address account) external;



    function isBurner(address _address) external view returns (bool);


    function isMinter(address _address) external view returns (bool);


    function isGovernor(address _address) external view returns (bool);


    function isGuardian(address _address) external view returns (bool);


    function isPCVController(address _address) external view returns (bool);


    function GUARDIAN_ROLE() external view returns (bytes32);


    function GOVERN_ROLE() external view returns (bytes32);


    function BURNER_ROLE() external view returns (bytes32);


    function MINTER_ROLE() external view returns (bytes32);


    function PCV_CONTROLLER_ROLE() external view returns (bytes32);


}// MIT

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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface IFei is IERC20 {


    event Minting(
        address indexed _to,
        address indexed _minter,
        uint256 _amount
    );

    event Burning(
        address indexed _to,
        address indexed _burner,
        uint256 _amount
    );

    event IncentiveContractUpdate(
        address indexed _incentivized,
        address indexed _incentiveContract
    );


    function burn(uint256 amount) external;


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;



    function burnFrom(address account, uint256 amount) external;



    function mint(address account, uint256 amount) external;



    function setIncentiveContract(address account, address incentive) external;



    function incentiveContract(address account) external view returns (address);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface ICore is IPermissions {


    event FeiUpdate(address indexed _fei);
    event TribeUpdate(address indexed _tribe);
    event GenesisGroupUpdate(address indexed _genesisGroup);
    event TribeAllocation(address indexed _to, uint256 _amount);
    event GenesisPeriodComplete(uint256 _timestamp);


    function init() external;



    function setFei(address token) external;


    function setTribe(address token) external;


    function allocateTribe(address to, uint256 amount) external;



    function fei() external view returns (IFei);


    function tribe() external view returns (IERC20);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface ICoreRef {


    event CoreUpdate(address indexed oldCore, address indexed newCore);

    event ContractAdminRoleUpdate(bytes32 indexed oldContractAdminRole, bytes32 indexed newContractAdminRole);


    function setCore(address newCore) external;


    function setContractAdminRole(bytes32 newContractAdminRole) external;



    function pause() external;


    function unpause() external;



    function core() external view returns (ICore);


    function fei() external view returns (IFei);


    function tribe() external view returns (IERC20);


    function feiBalance() external view returns (uint256);


    function tribeBalance() external view returns (uint256);


    function CONTRACT_ADMIN_ROLE() external view returns (bytes32);


    function isContractAdmin(address admin) external view returns (bool);

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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


abstract contract CoreRef is ICoreRef, Pausable {
    ICore private _core;

    bytes32 public override CONTRACT_ADMIN_ROLE;

    bool private _initialized;

    constructor(address coreAddress) {
        _initialize(coreAddress);
    }

    function _initialize(address coreAddress) internal {
        require(!_initialized, "CoreRef: already initialized");
        _initialized = true;

        _core = ICore(coreAddress);
        _setContractAdminRole(_core.GOVERN_ROLE());
    }

    modifier ifMinterSelf() {
        if (_core.isMinter(address(this))) {
            _;
        }
    }

    modifier onlyMinter() {
        require(_core.isMinter(msg.sender), "CoreRef: Caller is not a minter");
        _;
    }

    modifier onlyBurner() {
        require(_core.isBurner(msg.sender), "CoreRef: Caller is not a burner");
        _;
    }

    modifier onlyPCVController() {
        require(
            _core.isPCVController(msg.sender),
            "CoreRef: Caller is not a PCV controller"
        );
        _;
    }

    modifier onlyGovernorOrAdmin() {
        require(
            _core.isGovernor(msg.sender) ||
            isContractAdmin(msg.sender),
            "CoreRef: Caller is not a governor or contract admin"
        );
        _;
    }

    modifier onlyGovernor() {
        require(
            _core.isGovernor(msg.sender),
            "CoreRef: Caller is not a governor"
        );
        _;
    }

    modifier onlyGuardianOrGovernor() {
        require(
            _core.isGovernor(msg.sender) || 
            _core.isGuardian(msg.sender),
            "CoreRef: Caller is not a guardian or governor"
        );
        _;
    }

    modifier onlyFei() {
        require(msg.sender == address(fei()), "CoreRef: Caller is not FEI");
        _;
    }

    function setCore(address newCore) external override onlyGovernor {
        require(newCore != address(0), "CoreRef: zero address");
        address oldCore = address(_core);
        _core = ICore(newCore);
        emit CoreUpdate(oldCore, newCore);
    }

    function setContractAdminRole(bytes32 newContractAdminRole) external override onlyGovernor {
        _setContractAdminRole(newContractAdminRole);
    }

    function isContractAdmin(address _admin) public view override returns (bool) {
        return _core.hasRole(CONTRACT_ADMIN_ROLE, _admin);
    }

    function pause() public override onlyGuardianOrGovernor {
        _pause();
    }

    function unpause() public override onlyGuardianOrGovernor {
        _unpause();
    }

    function core() public view override returns (ICore) {
        return _core;
    }

    function fei() public view override returns (IFei) {
        return _core.fei();
    }

    function tribe() public view override returns (IERC20) {
        return _core.tribe();
    }

    function feiBalance() public view override returns (uint256) {
        return fei().balanceOf(address(this));
    }

    function tribeBalance() public view override returns (uint256) {
        return tribe().balanceOf(address(this));
    }

    function _burnFeiHeld() internal {
        fei().burn(feiBalance());
    }

    function _mintFei(uint256 amount) internal {
        fei().mint(address(this), amount);
    }

    function _setContractAdminRole(bytes32 newContractAdminRole) internal {
        bytes32 oldContractAdminRole = CONTRACT_ADMIN_ROLE;
        CONTRACT_ADMIN_ROLE = newContractAdminRole;
        emit ContractAdminRoleUpdate(oldContractAdminRole, newContractAdminRole);
    }
}// MIT

pragma solidity ^0.8.0;


interface IRewarder {

    function onSushiReward(uint256 pid, address user, address recipient, uint256 sushiAmount, uint256 newLpAmount) external;

    function pendingTokens(uint256 pid, address user, uint256 sushiAmount) external view returns (IERC20[] memory, uint256[] memory);

}// MIT

pragma solidity ^0.8.0;

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

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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



contract TribalChief is CoreRef, ReentrancyGuard, Initializable {

    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    using SafeCast for int256;

    struct UserInfo {
        int256 rewardDebt;
        uint256 virtualAmount;
    }

    struct DepositInfo {
        uint256 amount;
        uint128 unlockBlock;
        uint128 multiplier;
    }

    struct PoolInfo {
        uint256 virtualTotalSupply;
        uint256 accTribePerShare;
        uint128 lastRewardBlock;
        uint120 allocPoint;
        bool unlocked;
    }

    mapping (uint256 => mapping (uint128 => uint128)) public rewardMultipliers;

    struct RewardData {
        uint128 lockLength;
        uint128 rewardMultiplier;
    }

    IERC20 public TRIBE;
    PoolInfo[] public poolInfo;
    IERC20[] public stakedToken;
    IRewarder[] public rewarder;
    
    mapping (uint256 => mapping(address => UserInfo)) public userInfo;
    mapping (uint256 => mapping (address => DepositInfo[])) public depositInfo;
    uint256 public totalAllocPoint;



    uint256 private tribalChiefTribePerBlock;
    uint256 private ACC_TRIBE_PRECISION;
    uint256 public SCALE_FACTOR;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 indexed depositID);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, IERC20 indexed stakedToken, IRewarder indexed rewarder);
    event LogSetPool(uint256 indexed pid, uint256 allocPoint, IRewarder indexed rewarder, bool overwrite);
    event LogPoolMultiplier(uint256 indexed pid, uint128 indexed lockLength, uint256 indexed multiplier);
    event LogUpdatePool(uint256 indexed pid, uint128 indexed lastRewardBlock, uint256 lpSupply, uint256 accTribePerShare);
    event TribeWithdraw(uint256 amount);
    event NewTribePerBlock(uint256 indexed amount);
    event PoolLocked(bool indexed locked, uint256 indexed pid);

    constructor(address coreAddress) CoreRef(coreAddress) {}

    function initialize(address _core, IERC20 _tribe) external initializer {        

        CoreRef._initialize(_core);    
        
        TRIBE = _tribe;
        _setContractAdminRole(keccak256("TRIBAL_CHIEF_ADMIN_ROLE"));

        tribalChiefTribePerBlock = 75e18;
        ACC_TRIBE_PRECISION = 1e23;
        SCALE_FACTOR = 1e4;
    }

    function updateBlockReward(uint256 newBlockReward) external onlyGovernorOrAdmin {

        if (isContractAdmin(msg.sender)) {
            require(newBlockReward < tribalChiefTribePerBlock, "TribalChief: admin can only lower reward rate");
        }

        tribalChiefTribePerBlock = newBlockReward;
        emit NewTribePerBlock(newBlockReward);
    }

    function lockPool(uint256 _pid) external onlyGovernorOrAdmin {

        PoolInfo storage pool = poolInfo[_pid];
        pool.unlocked = false;

        emit PoolLocked(true, _pid);
    }

    function unlockPool(uint256 _pid) external onlyGovernorOrAdmin {

        PoolInfo storage pool = poolInfo[_pid];
        pool.unlocked = true;

        emit PoolLocked(false, _pid);
    }

    function governorAddPoolMultiplier(
        uint256 _pid,
        uint64 lockLength,
        uint64 newRewardsMultiplier
    ) external onlyGovernorOrAdmin {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 currentMultiplier = rewardMultipliers[_pid][lockLength];
        if (newRewardsMultiplier > currentMultiplier) {
            pool.unlocked = true;
            emit PoolLocked(false, _pid);
        }
        rewardMultipliers[_pid][lockLength] = newRewardsMultiplier;

        emit LogPoolMultiplier(_pid, lockLength, newRewardsMultiplier);
    }

    function governorWithdrawTribe(uint256 amount) external onlyGovernor {

        TRIBE.safeTransfer(address(core()), amount);
        emit TribeWithdraw(amount);
    }

    function numPools() public view returns (uint256) {

        return poolInfo.length;
    }

    function openUserDeposits(uint256 pid, address user) public view returns (uint256) {

        return depositInfo[pid][user].length;
    }

    function getTotalStakedInPool(uint256 pid, address user) public view returns (uint256) {

        uint256 amount = 0;
        for (uint256 i = 0; i < depositInfo[pid][user].length; i++) {
            DepositInfo storage poolDeposit = depositInfo[pid][user][i];
            amount += poolDeposit.amount;
        }

        return amount;
    }


    function add(
        uint120 allocPoint,
        IERC20 _stakedToken,
        IRewarder _rewarder,
        RewardData[] calldata rewardData
    ) external onlyGovernorOrAdmin {

        require(allocPoint > 0, "pool must have allocation points to be created");
        uint128 lastRewardBlock = block.number.toUint128();
        totalAllocPoint += allocPoint;
        stakedToken.push(_stakedToken);
        rewarder.push(_rewarder);

        uint256 pid = poolInfo.length;

        require(rewardData.length != 0, "must specify rewards");
        for (uint256 i = 0; i < rewardData.length; i++) {
            if (rewardData[i].lockLength == 0) {
                require(rewardData[i].rewardMultiplier == SCALE_FACTOR, "invalid multiplier for 0 lock length");
            } else {
                require(rewardData[i].rewardMultiplier >= SCALE_FACTOR, "invalid multiplier, must be above scale factor");
            }

            rewardMultipliers[pid][rewardData[i].lockLength] = rewardData[i].rewardMultiplier;
            emit LogPoolMultiplier(
                pid,
                rewardData[i].lockLength,
                rewardData[i].rewardMultiplier
            );
        }

        poolInfo.push(PoolInfo({
            allocPoint: allocPoint,
            virtualTotalSupply: 0, // virtual total supply starts at 0 as there is 0 initial supply
            lastRewardBlock: lastRewardBlock,
            accTribePerShare: 0,
            unlocked: false
        }));
        emit LogPoolAddition(pid, allocPoint, _stakedToken, _rewarder);
    }

    function set(uint256 _pid, uint120 _allocPoint, IRewarder _rewarder, bool overwrite) public onlyGovernorOrAdmin {

        updatePool(_pid);
        totalAllocPoint = (totalAllocPoint - poolInfo[_pid].allocPoint) + _allocPoint;
        require(totalAllocPoint > 0, "total allocation points cannot be 0");

        poolInfo[_pid].allocPoint = _allocPoint;
        if (overwrite) {
            rewarder[_pid] = _rewarder;
        }

        emit LogSetPool(_pid, _allocPoint, overwrite ? _rewarder : rewarder[_pid], overwrite);
    }

    function resetRewards(uint256 _pid) public onlyGuardianOrGovernor {

        updatePool(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        totalAllocPoint = (totalAllocPoint - pool.allocPoint);
        pool.allocPoint = 0;
        
        pool.unlocked = true;

        rewarder[_pid] = IRewarder(address(0));

        emit PoolLocked(false, _pid);
        emit LogSetPool(_pid, 0, IRewarder(address(0)), false);
    }

    function pendingRewards(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accTribePerShare = pool.accTribePerShare;

        if (block.number > pool.lastRewardBlock && pool.virtualTotalSupply != 0) {
            uint256 blocks = block.number - pool.lastRewardBlock;
            uint256 tribeReward = (blocks * tribePerBlock() * pool.allocPoint) / totalAllocPoint;
            accTribePerShare = accTribePerShare + ((tribeReward * ACC_TRIBE_PRECISION) / pool.virtualTotalSupply);
        }

        return (((user.virtualAmount * accTribePerShare) / ACC_TRIBE_PRECISION).toInt256() - user.rewardDebt).toUint256();
    }

    function massUpdatePools(uint256[] calldata pids) external {

        uint256 len = pids.length;
        for (uint256 i = 0; i < len; ++i) {
            updatePool(pids[i]);
        }
    }

    function tribePerBlock() public view returns (uint256) {

        return tribalChiefTribePerBlock;
    }

    function updatePool(uint256 pid) public {

        PoolInfo storage pool = poolInfo[pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 virtualSupply = pool.virtualTotalSupply;
            if (virtualSupply > 0 && totalAllocPoint != 0) {
                uint256 blocks = block.number - pool.lastRewardBlock;
                uint256 tribeReward = (blocks * tribePerBlock() * pool.allocPoint) / totalAllocPoint;
                pool.accTribePerShare = pool.accTribePerShare + ((tribeReward * ACC_TRIBE_PRECISION) / virtualSupply);
            }
            pool.lastRewardBlock = block.number.toUint128();
            emit LogUpdatePool(pid, pool.lastRewardBlock, virtualSupply, pool.accTribePerShare);
        }
    }

    function deposit(uint256 pid, uint256 amount, uint64 lockLength) public nonReentrant whenNotPaused {

        updatePool(pid);
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage userPoolData = userInfo[pid][msg.sender];
        DepositInfo memory poolDeposit;

        uint128 multiplier = rewardMultipliers[pid][lockLength];
        require(multiplier >= SCALE_FACTOR, "invalid lock length");

        poolDeposit.amount = amount;
        poolDeposit.unlockBlock = (lockLength + block.number).toUint128();
        poolDeposit.multiplier = multiplier;

        uint256 virtualAmountDelta = (amount * multiplier) / SCALE_FACTOR;
        userPoolData.virtualAmount += virtualAmountDelta;
        userPoolData.rewardDebt += ((virtualAmountDelta * pool.accTribePerShare) / ACC_TRIBE_PRECISION).toInt256();

        pool.virtualTotalSupply += virtualAmountDelta;

        depositInfo[pid][msg.sender].push(poolDeposit);

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onSushiReward(pid, msg.sender, msg.sender, 0, userPoolData.virtualAmount);
        }

        stakedToken[pid].safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, pid, amount, depositInfo[pid][msg.sender].length - 1);
    }

    function withdrawAllAndHarvest(uint256 pid, address to) external nonReentrant {

        updatePool(pid);
        _harvest(pid, to);

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 unlockedTotalAmount = 0;
        uint256 virtualLiquidityDelta = 0;

        uint256 processedDeposits = 0;
        for (uint256 i = 0; i < depositInfo[pid][msg.sender].length; i++) {
            DepositInfo storage poolDeposit = depositInfo[pid][msg.sender][i];
            if (poolDeposit.unlockBlock > block.number && pool.unlocked == false) {
                continue;
            }

            processedDeposits++;

            unlockedTotalAmount += poolDeposit.amount;
            virtualLiquidityDelta += (poolDeposit.amount * poolDeposit.multiplier) / SCALE_FACTOR;

            poolDeposit.unlockBlock = 0;
            poolDeposit.multiplier = 0;
            poolDeposit.amount = 0;
        }

        if (processedDeposits == depositInfo[pid][msg.sender].length) {
            delete depositInfo[pid][msg.sender];
            delete userInfo[pid][msg.sender];
        } else {
            user.virtualAmount -= virtualLiquidityDelta;
            user.rewardDebt = (user.virtualAmount * pool.accTribePerShare / ACC_TRIBE_PRECISION).toInt256();
        }

        pool.virtualTotalSupply -= virtualLiquidityDelta;

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onSushiReward(pid, msg.sender, to, 0, user.virtualAmount);
        }

        if (unlockedTotalAmount != 0) {
            stakedToken[pid].safeTransfer(to, unlockedTotalAmount);
        }

        emit Withdraw(msg.sender, pid, unlockedTotalAmount, to);
    }

    function withdrawFromDeposit(
        uint256 pid,
        uint256 amount,
        address to,
        uint256 index
    ) public nonReentrant {

        require(depositInfo[pid][msg.sender].length > index, "invalid index");
        updatePool(pid);
        PoolInfo storage pool = poolInfo[pid];
        DepositInfo storage poolDeposit = depositInfo[pid][msg.sender][index];
        UserInfo storage user = userInfo[pid][msg.sender];

        require(poolDeposit.unlockBlock <= block.number || pool.unlocked == true, "tokens locked");

        uint256 virtualAmountDelta = ( amount * poolDeposit.multiplier ) / SCALE_FACTOR;

        poolDeposit.amount -= amount;
        user.rewardDebt = user.rewardDebt - ((virtualAmountDelta * pool.accTribePerShare) / ACC_TRIBE_PRECISION).toInt256();
        user.virtualAmount -= virtualAmountDelta;
        pool.virtualTotalSupply -= virtualAmountDelta;

        stakedToken[pid].safeTransfer(to, amount);

        emit Withdraw(msg.sender, pid, amount, to);
    }

    function _harvest(uint256 pid, address to) private {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        int256 accumulatedTribe = ( (user.virtualAmount * pool.accTribePerShare ) / ACC_TRIBE_PRECISION ).toInt256();

        assert(accumulatedTribe >= 0 && accumulatedTribe - user.rewardDebt >= 0);

        uint256 pendingTribe = (accumulatedTribe - user.rewardDebt).toUint256();

        assert(pendingTribe.toInt256() >= 0);

        user.rewardDebt = accumulatedTribe;

        if (pendingTribe != 0) {
            TRIBE.safeTransfer(to, pendingTribe);
        }

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onSushiReward( pid, msg.sender, to, pendingTribe, user.virtualAmount);
        }

        emit Harvest(msg.sender, pid, pendingTribe);
    }

    function harvest(uint256 pid, address to) public nonReentrant {

        updatePool(pid);
        _harvest(pid, to);
    }


    function emergencyWithdraw(uint256 pid, address to) public nonReentrant {

        updatePool(pid);
        PoolInfo storage pool = poolInfo[pid];

        uint256 totalUnlocked = 0;
        uint256 virtualLiquidityDelta = 0;
        for (uint256 i = 0; i < depositInfo[pid][msg.sender].length; i++) {
            DepositInfo storage poolDeposit = depositInfo[pid][msg.sender][i];

            require(poolDeposit.unlockBlock <= block.number || pool.unlocked == true, "tokens locked");

            totalUnlocked += poolDeposit.amount;

            virtualLiquidityDelta += (poolDeposit.amount * poolDeposit.multiplier) / SCALE_FACTOR;
        }

        pool.virtualTotalSupply -= virtualLiquidityDelta;

        delete depositInfo[pid][msg.sender];
        delete userInfo[pid][msg.sender];

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onSushiReward(pid, msg.sender, to, 0, 0);
        }

        stakedToken[pid].safeTransfer(to, totalUnlocked);
        emit EmergencyWithdraw(msg.sender, pid, totalUnlocked, to);
    }
}