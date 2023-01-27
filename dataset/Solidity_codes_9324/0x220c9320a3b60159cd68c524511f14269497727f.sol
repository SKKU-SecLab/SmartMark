pragma solidity 0.6.12;

contract RolesManagerConsts {

    bytes32 public constant OWNER_ROLE = keccak256("");

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant CONFIGURATOR_ROLE = keccak256("CONFIGURATOR_ROLE");
}//AGPL-3.0-only
pragma solidity 0.6.12;

contract PlatformSettingsConsts {

    bytes32 public constant FEE = "Fee";

    bytes32 public constant BONUS_MULTIPLIER = "BonusMultiplier";

    bytes32 public constant ALLOW_ONLY_EOA = "AllowOnlyEOA";

    bytes32 public constant RATE_TOKEN_PAUSED = "RATETokenPaused";
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}//AGPL-3.0-only
pragma solidity 0.6.12;

library SettingsLib {

    struct Setting {
        uint256 value;
        uint256 min;
        uint256 max;
        bool exists;
    }

    function create(
        Setting storage self,
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

    function requireNotExists(Setting storage self) internal view {

        require(!self.exists, "SETTING_ALREADY_EXISTS");
    }

    function requireExists(Setting storage self) internal view {

        require(self.exists, "SETTING_NOT_EXISTS");
    }

    function update(Setting storage self, uint256 newValue) internal returns (uint256 oldValue) {

        requireExists(self);
        require(self.value != newValue, "NEW_VALUE_REQUIRED");
        require(newValue >= self.min, "NEW_VALUE_MUST_BE_GT_MIN_VALUE");
        require(newValue <= self.max, "NEW_VALUE_MUST_BE_LT_MAX_VALUE");
        oldValue = self.value;
        self.value = newValue;
    }

    function remove(Setting storage self) internal {

        requireExists(self);
        self.value = 0;
        self.min = 0;
        self.max = 0;
        self.exists = false;
    }
}//AGPL-3.0-only
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


interface IPlatformSettings {

    event PlatformPaused(address indexed pauser);

    event PlatformUnpaused(address indexed unpauser);

    event PlatformSettingCreated(
        bytes32 indexed name,
        address indexed creator,
        uint256 value,
        uint256 minValue,
        uint256 maxValue
    );

    event PlatformSettingRemoved(bytes32 indexed name, address indexed remover, uint256 value);

    event PlatformSettingUpdated(
        bytes32 indexed name,
        address indexed remover,
        uint256 oldValue,
        uint256 newValue
    );

    function createSetting(
        bytes32 name,
        uint256 value,
        uint256 min,
        uint256 max
    ) external;


    function removeSetting(bytes32 name) external;


    function getSetting(bytes32 name) external view returns (SettingsLib.Setting memory);


    function getSettingValue(bytes32 name) external view returns (uint256);


    function hasSetting(bytes32 name) external view returns (bool);


    function rolesManager() external view returns (address);


    function isPaused() external view returns (bool);


    function requireIsPaused() external view;


    function requireIsNotPaused() external view;


    function consts() external view returns (address);


    function pause() external;


    function unpause() external;

}//AGPL-3.0-only
pragma solidity 0.6.12;

interface IRolesManager {

    event MaxMultiItemsUpdated(address indexed updater, uint8 oldValue, uint8 newValue);

    function setMaxMultiItems(uint8 newMaxMultiItems) external;


    function multiGrantRole(bytes32 role, address[] calldata accounts) external;


    function multiRevokeRole(bytes32 role, address[] calldata accounts) external;


    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;


    function consts() external view returns (address);


    function maxMultiItems() external view returns (uint8);


    function requireHasRole(bytes32 role, address account) external view;


    function requireHasRole(
        bytes32 role,
        address account,
        string calldata message
    ) external view;

}//AGPL-3.0-only
pragma solidity 0.6.12;




abstract contract Base {
    using Address for address;



    address public settings;


    modifier whenPlatformIsPaused() {
        require(_settings().isPaused(), "PLATFORM_ISNT_PAUSED");
        _;
    }

    modifier whenPlatformIsNotPaused() {
        require(!_settings().isPaused(), "PLATFORM_IS_PAUSED");
        _;
    }

    modifier onlyOwner(address account) {
        _requireHasRole(
            RolesManagerConsts(_rolesManager().consts()).OWNER_ROLE(),
            account,
            "SENDER_ISNT_OWNER"
        );
        _;
    }

    modifier onlyMinter(address account) {
        _requireHasRole(
            RolesManagerConsts(_rolesManager().consts()).MINTER_ROLE(),
            account,
            "SENDER_ISNT_MINTER"
        );
        _;
    }

    modifier onlyConfigurator(address account) {
        _requireHasRole(
            RolesManagerConsts(_rolesManager().consts()).CONFIGURATOR_ROLE(),
            account,
            "SENDER_ISNT_CONFIGURATOR"
        );
        _;
    }

    modifier onlyPauser(address account) {
        _requireHasRole(
            RolesManagerConsts(_rolesManager().consts()).PAUSER_ROLE(),
            account,
            "SENDER_ISNT_PAUSER"
        );
        _;
    }


    constructor(address settingsAddress) internal {
        require(settingsAddress.isContract(), "SETTINGS_MUST_BE_CONTRACT");
        settings = settingsAddress;
    }

    function setSettings(address newSettings) external onlyOwner(msg.sender) {
        require(newSettings.isContract(), "SETTINGS_MUST_BE_CONTRACT");
        require(newSettings != settings, "SETTINGS_MUST_BE_NEW");
        address oldSettings = settings;
        settings = newSettings;
        emit PlatformSettingsUpdated(oldSettings, newSettings);
    }


    function _settings() internal view returns (IPlatformSettings) {
        return IPlatformSettings(settings);
    }

    function _settingsConsts() internal view returns (PlatformSettingsConsts) {
        return PlatformSettingsConsts(_settings().consts());
    }

    function _rolesManager() internal view returns (IRolesManager) {
        return IRolesManager(IPlatformSettings(settings).rolesManager());
    }

    function _requireHasRole(
        bytes32 role,
        address account,
        string memory message
    ) internal view {
        IRolesManager rolesManager = _rolesManager();
        rolesManager.requireHasRole(role, account, message);
    }

    function _getPlatformSettingsValue(bytes32 name) internal view returns (uint256) {
        return _settings().getSettingValue(name);
    }


    event PlatformSettingsUpdated(address indexed oldSettings, address indexed newSettings);
}//AGPL-3.0-only
pragma solidity 0.6.12;

interface ITokenValuator {

    function valuate(
        address token,
        address user,
        uint256 pid,
        uint256 amountOrId
    ) external view returns (uint256);


    function isConfigured(address token) external view returns (bool);


    function requireIsConfigured(address token) external view;


    function hasValuation(
        address token,
        address user,
        uint256 pid,
        uint256 amountOrId
    ) external view returns (bool);


    function requireHasValuation(
        address token,
        address user,
        uint256 pid,
        uint256 amountOrId
    ) external view;

}//AGPL-3.0-only
pragma solidity 0.6.12;



contract OnlyTokenValuator is ITokenValuator, Base {

    mapping(address => bool) public asFungibleToken;

    mapping(address => uint256) public valuations;

    constructor(address settingsAddress) public Base(settingsAddress) {}

    function setAsFungibleToken(address[] calldata tokens, bool asFungible)
        external
        onlyConfigurator(msg.sender)
    {

        require(tokens.length > 0, "TOKENS_REQUIRED");
        for (uint256 indexAt = 0; indexAt < tokens.length; indexAt++) {
            asFungibleToken[tokens[indexAt]] = asFungible;
        }
        emit TokensAsFungibleSet(tokens, asFungible);
    }

    function setValuations(address[] calldata tokens, uint256 valuation)
        external
        onlyConfigurator(msg.sender)
    {

        require(tokens.length > 0, "TOKENS_REQUIRED");
        for (uint256 indexAt = 0; indexAt < tokens.length; indexAt++) {
            valuations[tokens[indexAt]] = valuation;
        }
        emit NewValuationsSet(tokens, valuation);
    }


    function isConfigured(address token) external view override returns (bool) {

        return _isConfigured(token);
    }

    function requireIsConfigured(address token) external view override {

        require(_isConfigured(token), "TOKEN_ISNT_CONFIGURED");
    }

    function isFungibleToken(address token) external view returns (bool) {

        return asFungibleToken[token];
    }

    function hasValuation(
        address token,
        address,
        uint256,
        uint256
    ) external view override returns (bool) {

        return valuations[token] > 0;
    }

    function requireHasValuation(
        address token,
        address,
        uint256,
        uint256
    ) external view override {

        require(valuations[token] > 0, "TOKEN_HASNT_VALUATION");
    }

    function valuate(
        address token,
        address,
        uint256,
        uint256 amountOrId
    ) external view override returns (uint256) {

        return asFungibleToken[token] ? amountOrId : valuations[token];
    }


    function _isConfigured(address token) internal view returns (bool) {

        return asFungibleToken[token] || valuations[token] > 0;
    }


    event NewValuationsSet(address[] tokens, uint256 valuation);

    event TokensAsFungibleSet(address[] tokens, bool value);
}