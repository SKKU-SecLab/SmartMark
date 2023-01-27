
pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

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

library StorageSlot {

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


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            Address.functionDelegateCall(newImplementation, data);
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
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
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
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}// MIT

pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


contract ProxyAdmin is Ownable {

    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(
        TransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) public payable virtual onlyOwner {

        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
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

interface IFarming{

    function userInfo(uint16 poolId, address user) external view returns(uint256 amount, uint256 pendingReward, uint256 totalRewarded, uint256 rewardDebt);

    function poolInfo(uint256 poolId) external view returns(address lpToken, uint64 allocPoint, uint64 startBlock, uint64 endBlock, uint64 lastRewardBlock, uint256 accTokenPerShare, uint256 totalDeposited);

    function depositTo(uint16 _pid, uint256 _amount, address _beneficiary) external;

    function deposit(uint16 _pid, uint256 _amount) external;

    function withdraw(uint16 _pid, uint256 _amount) external;

    function claimReward(uint16 _pid) external;

    function exit(uint16 _pid) external;

    function emergencyWithdraw(uint16 _pid) external;

    function getContractData() external view returns (uint256, uint256, uint64);

    function getPoolLength() external view returns (uint256);

    function getPool(uint16 _index) external view returns (address, uint256, uint64, uint64, uint64, uint256, uint256);

    function getUserInfo(uint16 _pid, address _user) external view returns (uint256, uint256, uint256);


}// MIT
pragma solidity ^0.8.0;




contract Farming is Initializable, AccessControlUpgradeable, PausableUpgradeable {




    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided. [amount]=lpToken
        uint256 pendingReward;  // how many tokens user was rewarded with, pending to withdraw. [pendingReward]=rewardToken
        uint256 totalRewarded;  // total amount of tokens rewarded to user [totalRewarded]=rewardToken
        uint256 rewardDebt;     // Reward debt. See explanation below. [rewardDebt]=rewardToken
    }

    struct PoolInfo {
        IERC20Upgradeable lpToken;  // Address of LP token contract. 
        uint64 allocPoint;          // How many allocation points assigned to this pool. Tokens to distribute per block.[allocPoint] = allocationPoint
        uint64 startBlock;          // farming start block. [startBlock]=block
        uint64 endBlock;            // farming endBlock. [endBlock]=block
        uint64 lastRewardBlock;     // Last block number that Tokens distribution occurs. [lastRewardBlock]=block
        uint256 accTokenPerShare;   // Accumulated Tokens per share, times 1e12. See below. [accTokenPerShare]=rewardToken/lpToken
        uint256 totalDeposited;     //total tokens deposited in address of a pool. [totalDeposited]=lpToken
    }

    IERC20Upgradeable public rewardToken;
    uint256 public tokensFarmedPerBlock; //[tokensFarmedPerBlock]=rewardToken/block
    PoolInfo[] public poolInfo;
    mapping (uint16 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0; //[totalAllocPoint]=allocationPoint
    uint64 public noRewardClaimsUntil; //[noRewardClaimsUntil]=timestamp

    event PoolAdded(uint256 indexed pid);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amountLiquidity);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amountLiquidity);
    event RewardClaimed(address indexed user, uint256 indexed pid, uint256 amountRewarded);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amountLiquidity);

    function initialize(
        address _admin,
        address _rewardToken,
        uint256 _tokensPerBlock,
        uint64 _noRewardClaimsUntil
    ) public initializer {

        __AccessControl_init();
        __Pausable_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(MANAGER_ROLE, _admin);

        rewardToken = IERC20Upgradeable(_rewardToken);
        tokensFarmedPerBlock = _tokensPerBlock;
        require (_noRewardClaimsUntil > block.timestamp, "Incorrect _noRewardClaimsUntil");
        noRewardClaimsUntil = _noRewardClaimsUntil;
    }

    function version() public pure returns (uint32){

        return uint32(1001000);
    }

    modifier onlyManager() {

        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not the Manager");
        _;
    }

    modifier onlyAdmin() {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not the Admin");
        _;
    }


    function setTokenPerBlock(uint256 _tokensFarmedPerBlock) public onlyManager {

        tokensFarmedPerBlock = _tokensFarmedPerBlock;
        massUpdatePools();
    }

    function setNoRewardClaimsUntil(uint64 _noRewardClaimsUntil) public onlyManager {

        require (_noRewardClaimsUntil > block.timestamp, "Incorrect _noRewardClaimsUntil");
        noRewardClaimsUntil = _noRewardClaimsUntil;
    }

    function addPool(uint64 _allocPoint, address _lpTokenAddress, uint64 _startBlock, uint64 _endBlock, bool _withUpdate) public onlyManager {

        require (block.number < _endBlock, "Incorrect endblock number");
        IERC20Upgradeable _lpToken = IERC20Upgradeable(_lpTokenAddress);
        if (_withUpdate) {
            massUpdatePools();
        }
        uint64 lastRewardBlock = block.number > _startBlock ? uint64(block.number) : _startBlock;
        totalAllocPoint += _allocPoint;
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            startBlock: _startBlock,
            endBlock: _endBlock,
            lastRewardBlock: lastRewardBlock,
            accTokenPerShare: 0,
            totalDeposited: 0
        }));

        emit PoolAdded(poolInfo.length-1);
    }

    function updatePoolData(uint16 _pid, uint64 _allocPoint, uint64 _startBlock, uint64 _endBlock, bool _withUpdate) public onlyManager {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if(_startBlock > 0){
            poolInfo[_pid].startBlock = _startBlock;
        }
        if(_endBlock > 0){
            require (block.number < _endBlock, "Incorrect endblock number");
            poolInfo[_pid].endBlock = _endBlock;
        }
        if(_withUpdate){

        }
    }


    function withdrawRewardTokens(address _to, uint256 _amount) public onlyAdmin {

        rewardToken.safeTransfer(_to, _amount);
    }

    function pause() onlyAdmin public {

        super._pause();
    }
   
    function unpause() onlyAdmin public {

        super._unpause();
    }


    function massUpdatePools() public whenNotPaused {

        _massUpdatePools();
    }

    function updatePool(uint256 _pid) public whenNotPaused {

        _updatePool(_pid);
    }

    function deposit(uint16 _pid, uint256 _amount) public whenNotPaused {

        depositTo(_pid, _amount, msg.sender);
    }

    function depositTo(uint16 _pid, uint256 _amount, address _beneficiary) public whenNotPaused {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_beneficiary];
        updatePool(_pid);
        if (user.amount > 0) {
            user.pendingReward += user.amount * pool.accTokenPerShare / 1e12 - user.rewardDebt;
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount += _amount;
            pool.totalDeposited += _amount;
        }
        user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;
        emit Deposit(_beneficiary, _pid, _amount);
    }

    function withdraw(uint16 _pid, uint256 _amount) public whenNotPaused {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        user.pendingReward += user.amount * pool.accTokenPerShare / 1e12 - user.rewardDebt;
        if(_amount > 0) {
            user.amount -= _amount;
            pool.totalDeposited -= _amount;
            pool.lpToken.safeTransfer(msg.sender, _amount);
            emit Withdraw(msg.sender, _pid, _amount);
        }
        user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;   
    }

    function claimReward(uint16 _pid) public whenNotPaused {

        require(block.timestamp >= noRewardClaimsUntil, "Claiming reward is not available yet");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        user.pendingReward += user.amount * pool.accTokenPerShare / 1e12 - user.rewardDebt;
        user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;
        if(user.pendingReward > 0){
            user.totalRewarded += user.pendingReward;
            uint256 pending = user.pendingReward;
            user.pendingReward = 0;
            _safeTokenTransfer(msg.sender, pending);
            emit RewardClaimed(msg.sender, _pid, pending);
        }     
    }

    function exit(uint16 _pid) public whenNotPaused {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        user.pendingReward += user.amount * pool.accTokenPerShare / 1e12 - user.rewardDebt;
        if(user.amount > 0) {
            uint256 amountLiquidity = user.amount;
            pool.totalDeposited -= amountLiquidity;
            user.amount = 0;
            pool.lpToken.safeTransfer(msg.sender, amountLiquidity);
            emit Withdraw(msg.sender, _pid, amountLiquidity);
        }
        if(user.pendingReward > 0){
            require(block.timestamp >= noRewardClaimsUntil, "Claiming reward is not available yet");
            user.totalRewarded += user.pendingReward;
            uint256 pending = user.pendingReward;
            user.pendingReward = 0;
            _safeTokenTransfer(msg.sender,pending);
            emit RewardClaimed(msg.sender, _pid, pending);
        }    
        user.rewardDebt = 0;   
    }

    function emergencyWithdraw(uint16 _pid) public whenNotPaused {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        pool.totalDeposited -= amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function claimAndStake(uint16 _pid) public {

        require(address(rewardToken) == address(poolInfo[_pid].lpToken), "Not allowed to this pool");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        user.pendingReward += user.amount * pool.accTokenPerShare / 1e12 - user.rewardDebt;
        if(user.pendingReward > 0) {
            user.totalRewarded += user.pendingReward;
            user.amount += user.pendingReward;
            user.pendingReward = 0;
            user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;
        }
        
    }


    function getContractData() external view returns (uint256, uint256, uint64){

        return (tokensFarmedPerBlock, totalAllocPoint, noRewardClaimsUntil);
    }

    function getPoolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function getPool(uint16 _index) external view returns (address, uint256, uint64, uint64, uint64, uint256, uint256) {

        require (_index < poolInfo.length, "index incorrect");
        PoolInfo memory pool = poolInfo[_index];
        return (address(pool.lpToken), pool.allocPoint, pool.startBlock, pool.endBlock, pool.lastRewardBlock, pool.accTokenPerShare, pool.totalDeposited);
    }

    function getMultiplier(uint256 _pid, uint256 _from, uint256 _to) public view returns (uint256) {

        require (_from <= _to, "incorrect from/to sequence");
        if (poolInfo[_pid].startBlock == 0 || _to <= poolInfo[_pid].startBlock || _from >= poolInfo[_pid].endBlock) {
            return 0;
        }

        uint256 lastBlock = _to <= poolInfo[_pid].endBlock ? _to : poolInfo[_pid].endBlock;
        uint256 firstBlock = _from >= poolInfo[_pid].startBlock ? _from : poolInfo[_pid].startBlock;
        return lastBlock - firstBlock;
    }

    function getUserInfo(uint16 _pid, address _user) external view returns (uint256, uint256, uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.number > pool.lastRewardBlock && pool.totalDeposited != 0) {
            uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.number);
            uint256 amountRewardedPerPool = totalAllocPoint > 0 ? (multiplier * tokensFarmedPerBlock * pool.allocPoint / totalAllocPoint) : 0;
            accTokenPerShare += amountRewardedPerPool * 1e12 / pool.totalDeposited;
        }
        return (user.amount, user.totalRewarded, user.pendingReward + user.amount * accTokenPerShare / 1e12 - user.rewardDebt);
    }


    function _safeTokenTransfer(address _to, uint256 _amount) internal {

        uint256 tokenBal = rewardToken.balanceOf(address(this));
        if (_amount > tokenBal) {
            rewardToken.transfer(_to, tokenBal);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }

    function _massUpdatePools() internal {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    function _updatePool(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.totalDeposited == 0) {
            pool.lastRewardBlock = uint64(block.number);
            return;
        }
        uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.number);
        uint256 amountRewardedPerPool = totalAllocPoint > 0 ? (multiplier * tokensFarmedPerBlock * pool.allocPoint / totalAllocPoint) : 0;
        pool.accTokenPerShare += amountRewardedPerPool * 1e12 / pool.totalDeposited;
        pool.lastRewardBlock = uint64(block.number);
    }
}