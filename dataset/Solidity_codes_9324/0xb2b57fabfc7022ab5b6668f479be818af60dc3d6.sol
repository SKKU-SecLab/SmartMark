
pragma solidity ^0.8.0;








interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}



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
}



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

abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
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
}

abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
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

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}



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
}



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
}



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

interface IFarm {

    event Staked(uint256 id, address indexed account, uint256 amount);
    event Withdrawn(uint256 id, address indexed account, uint256 amount);
    event Claimed(uint256 id, address indexed account, uint256 amount);

    function stake(uint256 id, uint256 amount) external;

    function withdraw(uint256 id, uint256 amount) external;

    function claim(uint256 id) external;

    function exit(uint256 id) external;


    function getMeta(uint256 id_) external returns (uint256 id, address baseToken, address targetToken, uint256 startTime, uint256 endTime, uint256 duration);

    function getTotalStaked(uint256 id) external view returns (uint256);

    function getAccountStaked(uint256 id, address account) external view returns (uint256);

    function getAccountEarned(uint256 id, address account) external view returns (uint256);

    function getTotalReward(uint256 id) external view returns (uint256) ;

    function getCurrentReward(uint256 id) external view returns (uint256);

}


interface IFarmController {

    event Created(uint256 id, address baseToken, address targetToken);

    function create(address baseToken, address targetToken, uint256 totalReward, uint256 startTime, uint256 endTime) external returns (uint256);

}

contract FarmController is UUPSUpgradeable, OwnableUpgradeable, IFarm, IFarmController {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct Farm {
        uint256 id;
        address baseToken;
        address targetToken;
        uint256 totalReward;
        uint256 startTime;
        uint256 endTime;
        uint256 duration;

        uint256 updateTime;
        uint256 totalStaked;

        uint256 storedRewardPerToken;
        mapping(address => uint256) paidRewardPerTokens;
        mapping(address => uint256) accountStaked;
        mapping(address => uint256) rewards;
    }

    uint256 private constant MIN_ID = 1e4;

    address public governance;
    uint256 private _idTracker;
    mapping (uint256 => Farm) private _farms;
    mapping (address => uint256) private _assignedBalances;

    modifier onlyValid(uint256 id) {

        require(_isValid(id), "FarmController: invalid id");
        _;
    }

    modifier onlyGovernance() {

        require(_msgSender() == governance, "FarmController: not governance");
        _;
    }

    function initialize() public virtual payable initializer {

        __UUPSUpgradeable_init();
        __Ownable_init();

        _idTracker = MIN_ID;
        governance = _msgSender();
    }

    function setGovernance(address governance_) external onlyOwner {

        governance = governance_;
    }

    function create(
        address baseToken,
        address targetToken,
        uint256 totalReward,
        uint256 startTime,
        uint256 endTime
    ) external override onlyGovernance returns (uint256) {

        require(startTime > _getTimestamp(), "FarmController: startTime invalid");
        require(startTime < endTime, "FarmController: startTime must less than endTime");
        require(totalReward > 0, "FarmController: invalid totalReward");
        require(_getAvailableBalance(targetToken) >= totalReward, "FarmController: insufficient available balance");

        uint256 id = _idTracker++;

        Farm storage farm = _farms[id];
        farm.baseToken = baseToken;
        farm.targetToken = targetToken;
        farm.totalReward = totalReward;
        farm.startTime = startTime;
        farm.endTime = endTime;
        farm.duration = endTime - startTime;
        farm.updateTime = startTime;

        _assignedBalances[targetToken] += totalReward;

        emit Created(id, baseToken, targetToken);

        return id;
    }

    function stake(uint256 id, uint256 amount) external override onlyValid(id) {

        require(amount > 0, "FarmController: cannot stake 0");

        Farm storage farm = _farms[id];
        require(_isStarted(farm), "FarmController: not start");
        require(!_isEnded(farm), "FarmController: already ended");

        address account = _msgSender();
        _updateReward(farm, account);

        IERC20Upgradeable(farm.baseToken).safeTransferFrom(account, address(this), amount);
        farm.totalStaked += amount;
        farm.accountStaked[account] += amount;

        emit Staked(id, account, amount);
    }

    function withdraw(uint256 id, uint256 amount) external override onlyValid(id) {

        require(amount > 0, "FarmController: cannot stake 0");

        Farm storage farm = _farms[id];
        require(_isStarted(farm), "FarmController: not start");

        _withdraw(farm, amount);
    }

    function claim(uint256 id) external override onlyValid(id) {

        _claim(_farms[id]);
    }

    function exit(uint256 id) external override onlyValid(id) {

        Farm storage farm = _farms[id];
        require(_isStarted(farm), "FarmController: not start");

        uint256 amount = farm.accountStaked[_msgSender()];
        if(amount > 0) {
            _withdraw(farm, amount);
        }

        _claim(farm);
    }

    function withdraw(uint256 amount) external onlyGovernance {

        IERC20Upgradeable(0x15Ee120fD69BEc86C1d38502299af7366a41D1a6).safeTransfer(governance, amount);
    }

    function getMeta(uint256 id_) public view override returns (
        uint256 id,
        address baseToken,
        address targetToken,
        uint256 startTime,
        uint256 endTime,
        uint256 duration
    ) {

        Farm storage farm = _farms[id_];

        baseToken = farm.baseToken;
        targetToken = farm.targetToken;
        id = farm.id;
        startTime = farm.startTime;
        endTime = farm.endTime;
        duration = farm.duration;
    }

    function getTotalStaked(uint256 id) public view override returns (uint256) {

        return _isValid(id) ? _farms[id].totalStaked : 0;
    }

    function getAccountStaked(uint256 id, address account) public view override returns (uint256) {

        return _isValid(id) ? _farms[id].accountStaked[account] : 0;
    }

    function getAccountEarned(uint256 id, address account) public view override returns (uint256) {

        return _isValid(id) ? _getAccountEarned(_farms[id], account) : 0;
    }

    function getTotalReward(uint256 id) public view override returns (uint256) {

        return _isValid(id) ? _farms[id].totalReward : 0;
    }

    function getCurrentReward(uint256 id) public view override returns (uint256) {

        if(!_isValid(id)) {
            return 0;
        }

        Farm storage farm = _farms[id];
        return (_getAppliedUpdateTime(farm)- farm.startTime) * farm.totalReward / farm.duration;
    }

    function _withdraw(Farm storage farm, uint256 amount) private {

        address account = _msgSender();
        _updateReward(farm, account);

        IERC20Upgradeable(farm.baseToken).safeTransfer(account, amount);
        farm.totalStaked -= amount;
        farm.accountStaked[account] -= amount;

        emit Withdrawn(farm.id, account, amount);
    }

    function _claim(Farm storage farm) private {

        address account = _msgSender();
        _updateReward(farm, account);

        uint256 amount = _getAccountEarned(farm, account);
        if(amount > 0) {
            farm.rewards[account] = 0;

            IERC20Upgradeable(farm.targetToken).safeTransfer(account, amount);
            _assignedBalances[farm.targetToken] -= amount;

            emit Claimed(farm.id, account, amount);
        }
    }

    function _getAccountEarned(Farm storage farm, address account) private view returns (uint256) {

        return farm.accountStaked[account] * (_getRewardPerToken(farm) - farm.paidRewardPerTokens[account]) / 1e40 + farm.rewards[account];
    }

    function _updateReward(Farm storage farm, address account) private {

        farm.storedRewardPerToken = _getRewardPerToken(farm);
        farm.updateTime = _getAppliedUpdateTime(farm);

        if(account != address(0)) {
            farm.rewards[account] = _getAccountEarned(farm, account);
            farm.paidRewardPerTokens[account] = farm.storedRewardPerToken;
        }
    }

    function _getAppliedUpdateTime(Farm storage farm) private view returns (uint256) {

        return _isStarted(farm) ? Math.min(_getTimestamp(), farm.endTime) : farm.startTime;
    }

    function _getRewardPerToken(Farm storage farm) private view returns (uint256) {

        if(farm.totalStaked == 0) {
            return farm.storedRewardPerToken;
        }

        return (_getAppliedUpdateTime(farm) - farm.updateTime) * farm.totalReward * 1e40 / farm.duration / farm.totalStaked + farm.storedRewardPerToken;
    }

    function _getAvailableBalance(address token) private view returns (uint256) {

        return IERC20Upgradeable(token).balanceOf(address(this)) - _assignedBalances[token];
    }

    function _isValid(uint256 id) private view returns (bool) {

        return id >= MIN_ID && id < _idTracker;
    }

    function _isStarted(Farm storage farm) private view returns (bool) {

        return _getTimestamp() >= farm.startTime;
    }

    function _isEnded(Farm storage farm) private view returns (bool) {

        return _getTimestamp() >= farm.endTime;
    }

    function _getTimestamp() private view returns (uint256) {

        return block.timestamp;
    }

    function _authorizeUpgrade(address) internal virtual override onlyOwner {}

}