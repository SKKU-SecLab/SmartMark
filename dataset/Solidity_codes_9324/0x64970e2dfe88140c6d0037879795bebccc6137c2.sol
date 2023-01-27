
pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract PauserRole is Initializable, Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {

        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}

contract Pausable is Initializable, Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function initialize(address sender) public initializer {

        PauserRole.initialize(sender);

        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[50] private ______gap;
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library AddressLib {

    address public constant ADDRESS_EMPTY = address(0x0);

    function isEmpty(address self) internal pure returns (bool) {

        return self == ADDRESS_EMPTY;
    }

    function isEqualTo(address self, address other) internal pure returns (bool) {

        return self == other;
    }

    function isNotEqualTo(address self, address other) internal pure returns (bool) {

        return self != other;
    }

    function isNotEmpty(address self) internal pure returns (bool) {

        return self != ADDRESS_EMPTY;
    }

    function requireNotEmpty(address self, string memory message) internal pure {

        require(isNotEmpty(self), message);
    }

    function requireEmpty(address self, string memory message) internal pure {

        require(isEmpty(self), message);
    }

    function requireEqualTo(address self, address other, string memory message)
        internal
        pure
    {

        require(isEqualTo(self, other), message);
    }

    function requireNotEqualTo(address self, address other, string memory message)
        internal
        pure
    {

        require(isNotEqualTo(self, other), message);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library AssetSettingsLib {

    using SafeMath for uint256;
    using AddressLib for address;
    using Address for address;

    struct AssetSettings {
        address cTokenAddress;
        uint256 maxLoanAmount;
    }

    function initialize(
        AssetSettings storage self,
        address cTokenAddress,
        uint256 maxLoanAmount
    ) internal {

        require(maxLoanAmount > 0, "INIT_MAX_AMOUNT_REQUIRED");
        require(
            cTokenAddress.isEmpty() || cTokenAddress.isContract(),
            "CTOKEN_MUST_BE_CONTRACT_OR_EMPTY"
        );
        self.cTokenAddress = cTokenAddress;
        self.maxLoanAmount = maxLoanAmount;
    }

    function requireNotExists(AssetSettings storage self) internal view {

        require(exists(self) == false, "ASSET_SETTINGS_ALREADY_EXISTS");
    }

    function requireExists(AssetSettings storage self) internal view {

        require(exists(self) == true, "ASSET_SETTINGS_NOT_EXISTS");
    }

    function exists(AssetSettings storage self) internal view returns (bool) {

        return self.maxLoanAmount > 0;
    }

    function exceedsMaxLoanAmount(AssetSettings storage self, uint256 amount)
        internal
        view
        returns (bool)
    {

        return amount > self.maxLoanAmount;
    }

    function updateCTokenAddress(AssetSettings storage self, address newCTokenAddress)
        internal
    {

        requireExists(self);
        require(self.cTokenAddress != newCTokenAddress, "NEW_CTOKEN_ADDRESS_REQUIRED");
        self.cTokenAddress = newCTokenAddress;
    }

    function updateMaxLoanAmount(AssetSettings storage self, uint256 newMaxLoanAmount)
        internal
    {

        requireExists(self);
        require(self.maxLoanAmount != newMaxLoanAmount, "NEW_MAX_LOAN_AMOUNT_REQUIRED");
        require(newMaxLoanAmount > 0, "MAX_LOAN_AMOUNT_NOT_ZERO");
        self.maxLoanAmount = newMaxLoanAmount;
    }
}

library PlatformSettingsLib {

    struct PlatformSetting {
        uint256 value;
        uint256 min;
        uint256 max;
        bool exists;
    }

    function initialize(
        PlatformSetting storage self,
        uint256 value,
        uint256 min,
        uint256 max
    ) internal {

        requireNotExists(self);
        require(value >= min, "VALUE_MUST_BE_GT_MIN_VALUE");
        require(value <= max, "VALUE_MUST_BE_LT_MAX_VALUE");
        self.value = value;
        self.min = min;
        self.max = max;
        self.exists = true;
    }

    function requireNotExists(PlatformSetting storage self) internal view {

        require(self.exists == false, "PLATFORM_SETTING_ALREADY_EXISTS");
    }

    function requireExists(PlatformSetting storage self) internal view {

        require(self.exists == true, "PLATFORM_SETTING_NOT_EXISTS");
    }

    function update(PlatformSetting storage self, uint256 newValue)
        internal
        returns (uint256 oldValue)
    {

        requireExists(self);
        require(self.value != newValue, "NEW_VALUE_REQUIRED");
        require(newValue >= self.min, "NEW_VALUE_MUST_BE_GT_MIN_VALUE");
        require(newValue <= self.max, "NEW_VALUE_MUST_BE_LT_MAX_VALUE");
        oldValue = self.value;
        self.value = newValue;
    }

    function remove(PlatformSetting storage self) internal {

        requireExists(self);
        self.value = 0;
        self.min = 0;
        self.max = 0;
        self.exists = false;
    }
}

library AddressArrayLib {

    function add(address[] storage self, address newItem)
        internal
        returns (address[] memory)
    {

        require(newItem != address(0x0), "EMPTY_ADDRESS_NOT_ALLOWED");
        self.push(newItem);
        return self;
    }

    function removeAt(address[] storage self, uint256 index)
        internal
        returns (address[] memory)
    {

        if (index >= self.length) return self;

        if (index == self.length - 1) {
            delete self[self.length - 1];
            self.length--;
            return self;
        }

        address temp = self[self.length - 1];
        self[self.length - 1] = self[index];
        self[index] = temp;

        delete self[self.length - 1];
        self.length--;

        return self;
    }

    function getIndex(address[] storage self, address item)
        internal
        view
        returns (bool found, uint256 indexAt)
    {

        found = false;
        for (indexAt = 0; indexAt < self.length; indexAt++) {
            found = self[indexAt] == item;
            if (found) {
                return (found, indexAt);
            }
        }
        return (found, indexAt);
    }

    function remove(address[] storage self, address item)
        internal
        returns (address[] memory)
    {

        (bool found, uint256 indexAt) = getIndex(self, item);
        if (!found) return self;

        return removeAt(self, indexAt);
    }
}

interface SettingsInterface {

    event PlatformSettingCreated(
        bytes32 indexed settingName,
        address indexed sender,
        uint256 value,
        uint256 minValue,
        uint256 maxValue
    );

    event PlatformSettingRemoved(
        bytes32 indexed settingName,
        uint256 lastValue,
        address indexed sender
    );

    event PlatformSettingUpdated(
        bytes32 indexed settingName,
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );

    event LendingPoolPaused(address indexed account, address indexed lendingPoolAddress);

    event LendingPoolUnpaused(
        address indexed account,
        address indexed lendingPoolAddress
    );

    event AssetSettingsCreated(
        address indexed sender,
        address indexed assetAddress,
        address cTokenAddress,
        uint256 maxLoanAmount
    );

    event AssetSettingsRemoved(address indexed sender, address indexed assetAddress);

    event AssetSettingsAddressUpdated(
        bytes32 indexed assetSettingName,
        address indexed sender,
        address indexed assetAddress,
        address oldValue,
        address newValue
    );

    event AssetSettingsUintUpdated(
        bytes32 indexed assetSettingName,
        address indexed sender,
        address indexed assetAddress,
        uint256 oldValue,
        uint256 newValue
    );

    function createPlatformSetting(
        bytes32 settingName,
        uint256 value,
        uint256 minValue,
        uint256 maxValue
    ) external;


    function updatePlatformSetting(bytes32 settingName, uint256 newValue) external;


    function removePlatformSetting(bytes32 settingName) external;


    function getPlatformSetting(bytes32 settingName)
        external
        view
        returns (PlatformSettingsLib.PlatformSetting memory);


    function getPlatformSettingValue(bytes32 settingName) external view returns (uint256);


    function hasPlatformSetting(bytes32 settingName) external view returns (bool);


    function isPaused() external view returns (bool);


    function lendingPoolPaused(address lendingPoolAddress) external view returns (bool);


    function pauseLendingPool(address lendingPoolAddress) external;


    function unpauseLendingPool(address lendingPoolAddress) external;


    function createAssetSettings(
        address assetAddress,
        address cTokenAddress,
        uint256 maxLoanAmount
    ) external;


    function removeAssetSettings(address assetAddress) external;


    function updateMaxLoanAmount(address assetAddress, uint256 newMaxLoanAmount) external;


    function updateCTokenAddress(address assetAddress, address newCTokenAddress) external;


    function getAssets() external view returns (address[] memory);


    function getAssetSettings(address assetAddress)
        external
        view
        returns (AssetSettingsLib.AssetSettings memory);


    function exceedsMaxLoanAmount(address assetAddress, uint256 amount)
        external
        view
        returns (bool);


    function hasPauserRole(address account) external view returns (bool);

}

contract Settings is Pausable, SettingsInterface {

    using AddressLib for address;
    using Address for address;
    using AssetSettingsLib for AssetSettingsLib.AssetSettings;
    using AddressArrayLib for address[];
    using PlatformSettingsLib for PlatformSettingsLib.PlatformSetting;

    bytes32 public constant MAX_LOAN_AMOUNT_ASSET_SETTING = "MaxLoanAmount";
    bytes32 public constant CTOKEN_ADDRESS_ASSET_SETTING = "CTokenAddress";


    mapping(address => bool) public lendingPoolPaused;

    mapping(address => AssetSettingsLib.AssetSettings) public assetSettings;

    address[] public assets;

    mapping(bytes32 => PlatformSettingsLib.PlatformSetting) public platformSettings;




    function createPlatformSetting(
        bytes32 settingName,
        uint256 value,
        uint256 minValue,
        uint256 maxValue
    ) external onlyPauser() {

        require(settingName != "", "SETTING_NAME_MUST_BE_PROVIDED");
        platformSettings[settingName].initialize(value, minValue, maxValue);

        emit PlatformSettingCreated(settingName, msg.sender, value, minValue, maxValue);
    }

    function updatePlatformSetting(bytes32 settingName, uint256 newValue)
        external
        onlyPauser()
    {

        uint256 oldValue = platformSettings[settingName].update(newValue);

        emit PlatformSettingUpdated(settingName, msg.sender, oldValue, newValue);
    }

    function removePlatformSetting(bytes32 settingName) external onlyPauser() {

        uint256 oldValue = platformSettings[settingName].value;
        platformSettings[settingName].remove();

        emit PlatformSettingRemoved(settingName, oldValue, msg.sender);
    }

    function getPlatformSetting(bytes32 settingName)
        external
        view
        returns (PlatformSettingsLib.PlatformSetting memory)
    {

        return _getPlatformSetting(settingName);
    }

    function getPlatformSettingValue(bytes32 settingName)
        external
        view
        returns (uint256)
    {

        return _getPlatformSetting(settingName).value;
    }

    function hasPlatformSetting(bytes32 settingName) external view returns (bool) {

        return _getPlatformSetting(settingName).exists;
    }

    function pauseLendingPool(address lendingPoolAddress)
        external
        onlyPauser()
        whenNotPaused()
    {

        lendingPoolAddress.requireNotEmpty("LENDING_POOL_IS_REQUIRED");
        require(!lendingPoolPaused[lendingPoolAddress], "LENDING_POOL_ALREADY_PAUSED");

        lendingPoolPaused[lendingPoolAddress] = true;

        emit LendingPoolPaused(msg.sender, lendingPoolAddress);
    }

    function unpauseLendingPool(address lendingPoolAddress)
        external
        onlyPauser()
        whenNotPaused()
    {

        lendingPoolAddress.requireNotEmpty("LENDING_POOL_IS_REQUIRED");
        require(lendingPoolPaused[lendingPoolAddress], "LENDING_POOL_IS_NOT_PAUSED");

        lendingPoolPaused[lendingPoolAddress] = false;

        emit LendingPoolUnpaused(msg.sender, lendingPoolAddress);
    }

    function isPaused() external view returns (bool) {

        return paused();
    }

    function createAssetSettings(
        address assetAddress,
        address cTokenAddress,
        uint256 maxLoanAmount
    ) external onlyPauser() whenNotPaused() {

        require(assetAddress.isContract(), "ASSET_ADDRESS_MUST_BE_CONTRACT");

        assetSettings[assetAddress].requireNotExists();

        assetSettings[assetAddress].initialize(cTokenAddress, maxLoanAmount);

        assets.add(assetAddress);

        emit AssetSettingsCreated(msg.sender, assetAddress, cTokenAddress, maxLoanAmount);
    }

    function removeAssetSettings(address assetAddress)
        external
        onlyPauser()
        whenNotPaused()
    {

        assetAddress.requireNotEmpty("ASSET_ADDRESS_IS_REQUIRED");
        assetSettings[assetAddress].requireExists();

        delete assetSettings[assetAddress];
        assets.remove(assetAddress);

        emit AssetSettingsRemoved(msg.sender, assetAddress);
    }

    function updateMaxLoanAmount(address assetAddress, uint256 newMaxLoanAmount)
        external
        onlyPauser()
        whenNotPaused()
    {

        uint256 oldMaxLoanAmount = assetSettings[assetAddress].maxLoanAmount;

        assetSettings[assetAddress].updateMaxLoanAmount(newMaxLoanAmount);

        emit AssetSettingsUintUpdated(
            MAX_LOAN_AMOUNT_ASSET_SETTING,
            msg.sender,
            assetAddress,
            oldMaxLoanAmount,
            newMaxLoanAmount
        );
    }

    function updateCTokenAddress(address assetAddress, address newCTokenAddress)
        external
        onlyPauser()
        whenNotPaused()
    {

        address oldCTokenAddress = assetSettings[assetAddress].cTokenAddress;

        assetSettings[assetAddress].updateCTokenAddress(newCTokenAddress);

        emit AssetSettingsAddressUpdated(
            CTOKEN_ADDRESS_ASSET_SETTING,
            msg.sender,
            assetAddress,
            oldCTokenAddress,
            newCTokenAddress
        );
    }

    function exceedsMaxLoanAmount(address assetAddress, uint256 amount)
        external
        view
        returns (bool)
    {

        return assetSettings[assetAddress].exceedsMaxLoanAmount(amount);
    }

    function getAssets() external view returns (address[] memory) {

        return assets;
    }

    function getAssetSettings(address assetAddress)
        external
        view
        returns (AssetSettingsLib.AssetSettings memory)
    {

        return assetSettings[assetAddress];
    }

    function hasPauserRole(address account) external view returns (bool) {

        return isPauser(account);
    }


    function _getPlatformSetting(bytes32 settingName)
        internal
        view
        returns (PlatformSettingsLib.PlatformSetting memory)
    {

        return platformSettings[settingName];
    }

}