


pragma solidity ^0.8.4;







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
}





interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}



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
}







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
}











library AddressUpgradeable {
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

abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
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

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
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
}


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}







interface IERC1822ProxiableUpgradeable {
    function proxiableUUID() external view returns (bytes32);
}






interface IBeaconUpgradeable {
    function implementation() external view returns (address);
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


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
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

    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
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


abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;

    uint256[50] private __gap;
}

contract VoteLockerCurve is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for ERC20;

    event LockupCreated(
        address indexed provider,
        int128 amount,
        uint256 end,
        uint256 ts
    );
    event LockupUpdated(
        address indexed provider,
        int128 oldAmount,
        uint256 oldEnd,
        int128 amount,
        uint256 end,
        uint256 ts
    );
    event Withdraw(address indexed provider, uint256 value, uint256 ts);

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private constant WEEK = 7 days;
    uint256 public constant MAX_LOCK_TIME = 4 * 365 * 86400; // 4 years


    mapping(address => Checkpoint[]) private _userCheckpoints;
    mapping(address => uint256) public userEpoch;

    Checkpoint[] private _globalCheckpoints;
    uint256 public globalEpoch;

    mapping(address => Lockup) public lockups;

    mapping(uint256 => int128) public slopeChanges;

    ERC20 stakingToken;

    struct Checkpoint {
        int128 bias;
        int128 slope;
        uint256 ts;
        uint256 blk;
    }

    struct Lockup {
        int128 amount;
        uint256 end;
    }

    constructor() initializer {}

    function initialize(address _stakingToken) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();

        stakingToken = ERC20(_stakingToken);

        _name = string(
            bytes.concat(bytes("Vote Locked"), " ", bytes(stakingToken.name()))
        );
        _symbol = string(
            bytes.concat(bytes("vl"), bytes(stakingToken.symbol()))
        );
        _decimals = stakingToken.decimals();

        _globalCheckpoints.push(
            Checkpoint({
                bias: 0,
                slope: 0,
                ts: block.timestamp,
                blk: block.number
            })
        );
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function balanceOf(address _account) public view returns (uint256) {
        uint256 currentUserEpoch = userEpoch[_account];
        if (currentUserEpoch == 0) {
            return 0;
        }
        Checkpoint memory lastCheckpoint = _userCheckpoints[_account][
            currentUserEpoch
        ];
        lastCheckpoint.bias -= (lastCheckpoint.slope *
            SafeCast.toInt128(int256(block.timestamp - lastCheckpoint.ts)));
        return SafeCast.toUint256(max(lastCheckpoint.bias, 0));
    }

    function totalSupply() public view returns (uint256) {
        if (_globalCheckpoints.length == 0) {
            return 0;
        }
        Checkpoint memory lastCheckpoint = _globalCheckpoints[globalEpoch];
        return _supplyAt(lastCheckpoint, block.timestamp);
    }

    function checkpoints(address _account, uint32 _pos)
        public
        view
        virtual
        returns (Checkpoint memory)
    {
        return _userCheckpoints[_account][_pos];
    }

    function numCheckpoints(address _account)
        public
        view
        virtual
        returns (uint256)
    {
        return _userCheckpoints[_account].length;
    }

    function getLastCheckpoint(address _account)
        public
        view
        returns (Checkpoint memory)
    {
        return
            _userCheckpoints[_account][_userCheckpoints[_account].length - 1];
    }

    function globalCheckpoints(uint32 pos)
        public
        view
        returns (Checkpoint memory)
    {
        return _globalCheckpoints[pos];
    }

    function numGlobalCheckpoints() public view returns (uint256) {
        return _globalCheckpoints.length;
    }

    function getLastGlobalCheckpoint() public view returns (Checkpoint memory) {
        return _globalCheckpoints[_globalCheckpoints.length - 1];
    }

    function getVotes(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    function getLockup(address _account) public view returns (Lockup memory) {
        return lockups[_account];
    }

    function delegates(address _account)
        public
        view
        virtual
        returns (address)
    {}

    function delegate(address delegatee) public virtual {
        revert("Delegation is not supported");
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 end,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        revert("Delegation by signature is not supported");
    }

    function lockup(uint256 _amount, uint256 _end) public virtual {
        _end = _floorToWeek(_end);

        Lockup memory oldLockup = lockups[msg.sender];

        require(
            _end > block.timestamp,
            "End must be greater than the current block timestamp"
        );
        if (oldLockup.end > 0 && _end < oldLockup.end) {
            revert("End must be greater than or equal to the current end");
        }
        require(
            _end - block.timestamp <= MAX_LOCK_TIME,
            "End must be before maximum lockup time"
        );
        int128 amount = SafeCast.toInt128(int256(_amount));
        require(
            amount >= oldLockup.amount,
            "Amount must be greater than or equal to current amount"
        );

        uint256 amountDelta = SafeCast.toUint256(amount - oldLockup.amount);

        Lockup memory newLockup = Lockup({amount: amount, end: _end});

        lockups[msg.sender] = newLockup;

        if (amountDelta > 0) {
            stakingToken.safeTransferFrom(
                msg.sender,
                address(this),
                amountDelta
            );
        }

        if (oldLockup.end > 0) {
            emit LockupUpdated(
                msg.sender,
                oldLockup.amount,
                oldLockup.end,
                newLockup.amount,
                newLockup.end,
                block.timestamp
            );
        } else {
            emit LockupCreated(
                msg.sender,
                newLockup.amount,
                newLockup.end,
                block.timestamp
            );
        }

        _writeUserCheckpoint(msg.sender, oldLockup, newLockup);
    }

    function withdraw() public {
        Lockup memory oldLockup = Lockup({
            end: lockups[msg.sender].end,
            amount: lockups[msg.sender].amount
        });
        require(
            block.timestamp >= oldLockup.end,
            "Lockup must be expired"
        );

        require(oldLockup.amount > 0, "Lockup has no tokens");

        Lockup memory newLockup = Lockup({end: 0, amount: 0});
        lockups[msg.sender] = newLockup;

        uint256 amount = SafeCast.toUint256(oldLockup.amount);

        stakingToken.safeTransfer(msg.sender, amount);

        _writeUserCheckpoint(msg.sender, oldLockup, newLockup);

        emit Withdraw(msg.sender, amount, block.timestamp);
    }

    function checkpoint() external {
        _writeGlobalCheckpoint(0, 0);
    }

    function _writeUserCheckpoint(
        address _account,
        Lockup memory _oldLockup,
        Lockup memory _newLockup
    ) private {
        Checkpoint memory oldCheckpoint;
        Checkpoint memory newCheckpoint;

        int128 oldSlopeDelta = 0;
        int128 newSlopeDelta = 0;

        if (_oldLockup.end > block.timestamp && _oldLockup.amount > 0) {
            oldCheckpoint.slope =
                _oldLockup.amount /
                SafeCast.toInt128(int256(MAX_LOCK_TIME));
            oldCheckpoint.bias =
                oldCheckpoint.slope *
                SafeCast.toInt128(int256(_oldLockup.end - block.timestamp));
        }
        if (_newLockup.end > block.timestamp && _newLockup.amount > 0) {
            newCheckpoint.slope =
                _newLockup.amount /
                SafeCast.toInt128(int256(MAX_LOCK_TIME));
            newCheckpoint.bias =
                newCheckpoint.slope *
                SafeCast.toInt128(int256(_newLockup.end - block.timestamp));
        }

        uint256 userCurrentEpoch = userEpoch[_account];
        if (userCurrentEpoch == 0) {
            _userCheckpoints[_account].push(oldCheckpoint);
        }

        newCheckpoint.ts = block.timestamp;
        newCheckpoint.blk = block.number;
        userEpoch[_account] = userCurrentEpoch + 1;
        _userCheckpoints[_account].push(newCheckpoint);

        oldSlopeDelta = slopeChanges[_oldLockup.end];
        if (_newLockup.end != 0) {
            if (_newLockup.end == _oldLockup.end) {
                newSlopeDelta = oldSlopeDelta;
            } else {
                newSlopeDelta = slopeChanges[_newLockup.end];
            }
        }

        _writeGlobalCheckpoint(
            newCheckpoint.slope - oldCheckpoint.slope,
            newCheckpoint.bias - oldCheckpoint.bias
        );


        if (_oldLockup.end > block.timestamp) {
            oldSlopeDelta = oldSlopeDelta + oldCheckpoint.slope;
            if (_newLockup.end == _oldLockup.end) {
                oldSlopeDelta = oldSlopeDelta - newCheckpoint.slope;
            }
            slopeChanges[_oldLockup.end] = oldSlopeDelta;
        }
        if (_newLockup.end > block.timestamp) {
            if (_newLockup.end > _oldLockup.end) {
                newSlopeDelta = newSlopeDelta - newCheckpoint.slope;
                slopeChanges[_newLockup.end] = newSlopeDelta;
            }
        }
    }

    function _writeGlobalCheckpoint(int128 userSlopeDelta, int128 userBiasDelta)
        private
    {
        Checkpoint memory lastCheckpoint;
        if (globalEpoch > 0) {
            lastCheckpoint = _globalCheckpoints[globalEpoch];
        } else {
            lastCheckpoint = Checkpoint({
                bias: 0,
                slope: 0,
                ts: block.timestamp,
                blk: block.number
            });
        }

        Checkpoint memory initialLastCheckpoint = Checkpoint({
            bias: 0,
            slope: 0,
            ts: lastCheckpoint.ts,
            blk: lastCheckpoint.blk
        });

        uint256 blockSlope = 0; // dblock/dt
        if (block.timestamp > lastCheckpoint.ts) {
            blockSlope =
                ((block.number - lastCheckpoint.blk) * 1e18) /
                (block.timestamp - lastCheckpoint.ts);
        }

        uint256 lastCheckpointTimestamp = lastCheckpoint.ts;
        uint256 iterativeTime = _floorToWeek(lastCheckpointTimestamp);

        for (uint256 i = 0; i < 255; i++) {
            iterativeTime = iterativeTime + WEEK;

            int128 slopeDelta = 0;
            if (iterativeTime > block.timestamp) {
                iterativeTime = block.timestamp;
            } else {
                slopeDelta = slopeChanges[iterativeTime];
            }

            int128 biasDelta = lastCheckpoint.slope *
                SafeCast.toInt128(
                    int256((iterativeTime - lastCheckpointTimestamp))
                );

            lastCheckpoint.bias = max(lastCheckpoint.bias - biasDelta, 0);
            lastCheckpoint.slope = max(lastCheckpoint.slope + slopeDelta, 0);
            lastCheckpoint.ts = iterativeTime;
            lastCheckpointTimestamp = iterativeTime;
            lastCheckpoint.blk =
                initialLastCheckpoint.blk +
                ((blockSlope * (iterativeTime - initialLastCheckpoint.ts)) /
                    1e18); // Scale back down

            globalEpoch += 1;

            if (iterativeTime == block.timestamp) {
                lastCheckpoint.blk = block.number;
                lastCheckpoint.slope = max(
                    lastCheckpoint.slope + userSlopeDelta,
                    0
                );
                lastCheckpoint.bias = max(
                    lastCheckpoint.bias + userBiasDelta,
                    0
                );
                _globalCheckpoints.push(lastCheckpoint);
                break;
            } else {
                _globalCheckpoints.push(lastCheckpoint);
            }
        }
    }

    function _findEpoch(
        Checkpoint[] memory _checkpoints,
        uint256 _block,
        uint256 _maxEpoch
    ) internal view returns (uint256) {
        uint256 minEpoch = 0;
        uint256 maxEpoch = _maxEpoch;
        for (uint256 i = 0; i < 128; i++) {
            if (minEpoch >= maxEpoch) break;
            uint256 mid = (minEpoch + maxEpoch + 1) / 2;
            if (_checkpoints[mid].blk <= _block) {
                minEpoch = mid;
            } else {
                maxEpoch = mid - 1;
            }
        }
        return minEpoch;
    }

    function getPastVotes(address _account, uint256 _blockNumber)
        public
        view
        returns (uint256)
    {
        return balanceOfAt(_account, _blockNumber);
    }

    function balanceOfAt(address _account, uint256 _blockNumber)
        public
        view
        returns (uint256)
    {
        require(_blockNumber <= block.number, "Block number is in the future");

        uint256 recentUserEpoch = _findEpoch(
            _userCheckpoints[_account],
            _blockNumber,
            userEpoch[_account] // Max epoch
        );
        if (recentUserEpoch == 0) {
            return 0;
        }
        Checkpoint memory userPoint = _userCheckpoints[_account][
            recentUserEpoch
        ];

        uint256 recentGlobalEpoch = _findEpoch(
            _globalCheckpoints,
            _blockNumber,
            globalEpoch // Max epoch
        );
        Checkpoint memory checkpoint0 = _globalCheckpoints[recentGlobalEpoch];

        uint256 dBlock = 0;
        uint256 dTime = 0;
        if (recentGlobalEpoch < globalEpoch) {
            Checkpoint memory checkpoint1 = _globalCheckpoints[
                recentGlobalEpoch + 1
            ];
            dBlock = checkpoint1.blk - checkpoint0.blk;
            dTime = checkpoint1.ts - checkpoint0.ts;
        } else {
            dBlock = block.number - checkpoint0.blk;
            dTime = block.timestamp - checkpoint0.ts;
        }

        uint256 blockTime = checkpoint0.ts;
        if (dBlock != 0) {
            blockTime += (dTime * (_blockNumber - checkpoint0.blk)) / dBlock;
        }

        userPoint.bias -= (userPoint.slope *
            SafeCast.toInt128(int256(blockTime - userPoint.ts)));
        if (userPoint.bias >= 0) {
            return SafeCast.toUint256(userPoint.bias);
        } else {
            return 0;
        }
    }

    function getPastTotalSupply(uint256 _blockNumber)
        public
        view
        returns (uint256)
    {
        return totalSupplyAt(_blockNumber);
    }

    function totalSupplyAt(uint256 _blockNumber) public view returns (uint256) {
        require(_blockNumber <= block.number, "Block number is in the future");

        uint256 recentGlobalEpoch = _findEpoch(
            _globalCheckpoints,
            _blockNumber,
            globalEpoch
        );

        Checkpoint memory checkpoint0 = _globalCheckpoints[recentGlobalEpoch];

        if (checkpoint0.blk > _blockNumber) {
            return 0;
        }

        uint256 dTime = 0;
        if (recentGlobalEpoch < globalEpoch) {
            Checkpoint memory checkpoint1 = _globalCheckpoints[
                recentGlobalEpoch + 1
            ];
            if (checkpoint0.blk != checkpoint1.blk) {
                dTime =
                    ((_blockNumber - checkpoint0.blk) *
                        (checkpoint1.ts - checkpoint0.ts)) /
                    (checkpoint1.blk - checkpoint0.blk);
            }
        } else if (checkpoint0.blk != block.number) {
            dTime =
                ((_blockNumber - checkpoint0.blk) *
                    (block.timestamp - checkpoint0.ts)) /
                (block.number - checkpoint0.blk);
        }

        return _supplyAt(checkpoint0, checkpoint0.ts + dTime);
    }

    function _supplyAt(Checkpoint memory _checkpoint, uint256 _time)
        internal
        view
        returns (uint256)
    {
        Checkpoint memory lastCheckpoint = _checkpoint;

        uint256 iterativeTime = _floorToWeek(lastCheckpoint.ts);
        for (uint256 i = 0; i < 255; i++) {
            iterativeTime = iterativeTime + WEEK;
            int128 dSlope = 0;
            if (iterativeTime > _time) {
                iterativeTime = _time;
            }
            else {
                dSlope = slopeChanges[iterativeTime];
            }

            lastCheckpoint.bias =
                lastCheckpoint.bias -
                (lastCheckpoint.slope *
                    SafeCast.toInt128(
                        int256(iterativeTime - lastCheckpoint.ts)
                    ));

            if (iterativeTime == _time) {
                break;
            }

            lastCheckpoint.slope = lastCheckpoint.slope + dSlope;
            lastCheckpoint.ts = iterativeTime;
        }

        return SafeCast.toUint256(max(lastCheckpoint.bias, 0));
    }

    function _floorToWeek(uint256 _t) internal pure returns (uint256) {
        return (_t / WEEK) * WEEK;
    }

    function max(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a >= _b ? _a : _b;
    }

    function max(int128 _a, int128 _b) internal pure returns (int128) {
        return _a >= _b ? _a : _b;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}