
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
}// BUSL-1.1

pragma solidity ^0.8.14;

function settingToPath(bytes32 setting) pure returns (bytes32[] memory) {
  bytes32[] memory path = new bytes32[](1);
  path[0] = setting;
  return path;
}

function hashPath(bytes32[] memory path) pure returns (bytes32) {
  return keccak256(abi.encode(path));
}

struct Setting {
  bytes32[] path;

  uint64 releaseTime;

  bytes value;
}// BUSL-1.1

pragma solidity ^0.8.14;

interface SettingValidatorV1 {

  function isValidUnlockedSetting(bytes32[] calldata path, uint64 releaseTime, bytes calldata value) external view returns (bool);

}// BUSL-1.1
pragma solidity ^0.8.14;



contract OracleAuthorityV1 is Ownable {

  
  SettingValidatorV1 public settingValidator;

  Setting[] private changeHistory;

  bytes32 constant AUTHORITY = "authority";
  bytes32 constant SETTING_VALIDATOR = "settingValidator";

  event SettingConfigured(bytes32 indexed path0, bytes32 indexed pathIdx, bytes32[] path, uint64 releaseTime, bytes value);

  event PendingSettingCancelled(bytes32 indexed path0, bytes32 indexed pathIdx, Setting setting);

  constructor(Setting[] memory genesisSettings) {
    addSetting(Setting(settingToPath(AUTHORITY), 0, abi.encode(block.chainid, address(this))));

    for(uint i = 0; i < genesisSettings.length; i++) {
      require(genesisSettings[i].releaseTime == 0, "400");
      addSetting(genesisSettings[i]);
    }

    require(address(settingValidator) != address(0), "400: settings");
  }

  function changeCount() external view returns (uint256) {

    return changeHistory.length;
  }

  function getChange(uint256 idx) external view returns (Setting memory) {

    return changeHistory[idx];
  }

  function planChanges(Setting[] calldata settings) external onlyOwner {

    for(uint256 i = changeHistory.length-1; i >= 0; i--) {
      if(changeHistory[i].releaseTime <= block.timestamp) {
        break;
      }
      emit PendingSettingCancelled(changeHistory[i].path[0], hashPath(changeHistory[i].path), changeHistory[i]);
      changeHistory.pop();
    }

    uint256 lastTime;
    for(uint i = 0; i < settings.length; i++) {
      require(
        settings[i].releaseTime > block.timestamp
        && (lastTime > 0 ? settings[i].releaseTime >= lastTime : true)
        && (settingValidator.isValidUnlockedSetting(settings[i].path, settings[i].releaseTime, settings[i].value) == true)
        , "400");

      addSetting(settings[i]);

      lastTime = settings[i].releaseTime;
    }
  }

  function addSetting(Setting memory setting) private {

    if(setting.path[0] == SETTING_VALIDATOR) {
      (address addr) = abi.decode(setting.value, (address));
      require(addr != address(0), "400");
      settingValidator = SettingValidatorV1(addr); // SettingValidator ignores the history concept
    }

    changeHistory.push(setting);
    emit SettingConfigured(setting.path[0], hashPath(setting.path), setting.path, setting.releaseTime, setting.value);
  }

  receive() external payable {
    revert('unsupported');
  }

  fallback() external payable {
    revert('unsupported');
  }
}