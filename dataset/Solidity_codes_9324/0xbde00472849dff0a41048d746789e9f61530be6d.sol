
pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
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
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

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


abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
}//Unlicense
pragma solidity ^0.8.4;


interface IPollyModule {


  struct ModuleInfo {
    string name;
    address implementation;
    bool clone;
  }

  function init(address for_) external;

  function didInit() external view returns(bool);

  function getModuleInfo() external returns(IPollyModule.ModuleInfo memory module_);

  function setString(string memory key_, string memory value_) external;

  function setUint(string memory key_, uint value_) external;

  function setAddress(string memory key_, address value_) external;

  function setBytes(string memory key_, bytes memory value_) external;

  function getString(string memory key_) external view returns(string memory);

  function getUint(string memory key_) external view returns(uint);

  function getAddress(string memory key_) external view returns(address);

  function getBytes(string memory key_) external view returns(bytes memory);


}


contract PollyModule is AccessControl {


  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bool private _did_init = false;
  mapping(string => string) private _keyStoreStrings;
  mapping(string => uint) private _keyStoreUints;
  mapping(string => bytes) private _keyStoreBytes;
  mapping(string => address) private _keyStoreAddresses;

  constructor(){
    init(msg.sender);
  }

  function init(address for_) public virtual {

    require(!_did_init, 'CAN_NOT_INIT');
    _did_init = true;
    _grantRole(DEFAULT_ADMIN_ROLE, for_);
    _grantRole(MANAGER_ROLE, for_);
  }

  function didInit() public view returns(bool){

    return _did_init;
  }

  function setString(string memory key_, string memory value_) public onlyRole(DEFAULT_ADMIN_ROLE) {

    _keyStoreStrings[key_] = value_;
  }
  function setUint(string memory key_, uint value_) public onlyRole(DEFAULT_ADMIN_ROLE) {

    _keyStoreUints[key_] = value_;
  }
  function setAddress(string memory key_, address value_) public onlyRole(DEFAULT_ADMIN_ROLE) {

    _keyStoreAddresses[key_] = value_;
  }
  function setBytes(string memory key_, bytes memory value_) public onlyRole(DEFAULT_ADMIN_ROLE) {

    _keyStoreBytes[key_] = value_;
  }
  function getString(string memory key_) public view returns(string memory) {

    return _keyStoreStrings[key_];
  }
  function getUint(string memory key_) public view returns(uint) {

    return _keyStoreUints[key_];
  }
  function getAddress(string memory key_) public view returns(address) {

    return _keyStoreAddresses[key_];
  }
  function getBytes(string memory key_) public view returns(bytes memory) {

    return _keyStoreBytes[key_];
  }

}/*

       -*%%+++*#+:              .+     --
        [email protected]*     *@*           -#@-  .=#%
        %@.      @@:          [email protected]*    :@:
       [email protected]*       @@.          [email protected]    #*  :=     --
       #@.      [email protected]#  +*+#:    @=    [email protected]: *=%*    *@
      [email protected]*      :@#.-%-  [email protected]   +%    [email protected]*.+  [email protected]    =#
      *@.    .+%= =%.   [email protected] :@-    *@     [email protected]:   *-
     :@#---===-  [email protected]    #@  %%    :@-     [email protected]  .#
     #@:        [email protected]*    [email protected]+ [email protected]:    ##      [email protected]  #.
    :@%         *@.    *% [email protected]+    :@.      [email protected] =:
    #@-         @*    [email protected] +%  =. %+ .=    [email protected]::=
   :@#          @=   [email protected] [email protected]==  [email protected]+-     [email protected]*
   *@-          #*  *#.  #@*.  :@@+       [email protected]+
.:=++=:.         ===:    +:    :=.        +=
                                         +-
                                       =+.
                                  +*-=+.

v1

*/

pragma solidity ^0.8.4;


interface IPolly {



  struct ModuleBase {
    string name;
    uint version;
    address implementation;
  }

  struct ModuleInstance {
    string name;
    uint version;
    address location;
  }

  struct Config {
    string name;
    address owner;
    ModuleInstance[] modules;
  }


  function updateModule(string memory name_, address implementation_) external;

  function getModule(string memory name_, uint version_) external view returns(IPolly.ModuleBase memory);

  function moduleExists(string memory name_, uint version_) external view returns(bool exists_);

  function useModule(uint config_id_, IPolly.ModuleInstance memory mod_) external;

  function useModules(uint config_id_, IPolly.ModuleInstance[] memory mods_) external;

  function createConfig(string memory name_, IPolly.ModuleInstance[] memory mod_) external;

  function getConfigsForOwner(address owner_, uint page_) external view returns(uint[] memory);

  function getConfig(uint config_id_) external view returns(IPolly.Config memory);

  function isConfigOwner(uint config_id_, address check_) external view returns(bool);

  function transferConfig(uint config_id_, address to_) external;



}


contract Polly is Ownable {




    mapping(string => mapping(uint => address)) private _modules;
    mapping(string => uint) private _module_versions;

    uint private _config_id;
    mapping(uint => IPolly.Config) private _configs;
    mapping(uint => address) private _config_owners;
    mapping(address => uint) private _owner_configs;
    mapping(address => uint[]) private _configs_for_owner;






    event moduleUpdated(
      string indexed name, uint version, address implementation
    );

    event configCreated(
      uint id, string name, address indexed by
    );

    event configUpdated(
      uint indexed id, string indexed module_name, uint indexed module_version
    );

    event configTransferred(
      uint indexed id, address indexed from, address indexed to
    );



    modifier onlyConfigOwner(uint config_id_) {

      require(isConfigOwner(config_id_, msg.sender), 'NOT_CONFIG_OWNER');
      _;
    }

    modifier onlyValidModules(IPolly.ModuleInstance[] memory mods_) {

      for(uint i = 0; i < mods_.length; i++){
        require(moduleExists(mods_[i].name, mods_[i].version), string(abi.encodePacked('MODULE_DOES_NOT_EXIST: ', mods_[i].name)));
      }
      _;
    }



    function updateModule(string memory name_, address implementation_) public onlyOwner {


      uint version_ = _module_versions[name_]+1;

      IPolly.ModuleBase memory module_ = IPolly.ModuleBase(
        name_, version_, implementation_
      );

      _modules[module_.name][module_.version] = module_.implementation;
      _module_versions[module_.name] = module_.version;

      emit moduleUpdated(module_.name, module_.version, module_.implementation);

    }


    function getModule(string memory name_, uint version_) public view returns(IPolly.ModuleBase memory){


      if(version_ < 1)
        version_ = _module_versions[name_];

      return IPolly.ModuleBase(name_, version_, _modules[name_][version_]);

    }

    function moduleExists(string memory name_, uint version_) public view returns(bool exists_){

      if(_modules[name_][version_] != address(0))
        exists_ = true;
      return exists_;
    }


    function _cloneAndAttachModule(uint config_id_, string memory name_, uint version_) private {


      address implementation_ = _modules[name_][version_];

      IPollyModule module_ = IPollyModule(Clones.clone(implementation_));
      module_.init(msg.sender);

      _attachModule(config_id_, name_, version_, address(module_));

    }

    function _attachModule(uint config_id_, string memory name_, uint version_, address location_) private {

      _configs[config_id_].modules.push(IPolly.ModuleInstance(name_, version_, location_));
      emit configUpdated(config_id_, name_, version_);
    }

    function _useModule(uint config_id_, IPolly.ModuleInstance memory mod_) private {


      IPolly.ModuleBase memory base_ = getModule(mod_.name, mod_.version);
      IPollyModule.ModuleInfo memory base_info_ = IPollyModule(_modules[mod_.name][mod_.version]).getModuleInfo();

      if(mod_.location == address(0x00)){
        if(base_info_.clone)
          _cloneAndAttachModule(config_id_, base_.name, base_.version);
        else
          _attachModule(config_id_, base_.name, base_.version, base_.implementation);
      }
      else {
        _attachModule(config_id_, mod_.name, mod_.version, mod_.location);
      }

    }

    function useModule(uint config_id_, IPolly.ModuleInstance memory mod_) public onlyConfigOwner(config_id_) {


      require(moduleExists(mod_.name, mod_.version), string(abi.encodePacked('MODULE_DOES_NOT_EXIST: ', mod_.name)));

      _useModule(config_id_, mod_);

    }

    function useModules(uint config_id_, IPolly.ModuleInstance[] memory mods_) public onlyConfigOwner(config_id_) onlyValidModules(mods_) {


      for(uint256 i = 0; i < mods_.length; i++) {
        _useModule(config_id_, mods_[i]);
      }

    }




    function createConfig(string memory name_, IPolly.ModuleInstance[] memory mod_) public returns(uint) {


      _config_id++;
      _configs[_config_id].name = name_;
      _configs[_config_id].owner = msg.sender;
      _configs_for_owner[msg.sender].push(_config_id);

      useModules(_config_id, mod_);

      emit configCreated(_config_id, name_, msg.sender);

      return _config_id;

    }

    function getConfigsForOwner(address owner_, uint limit_, uint page_) public view returns(uint[] memory){


      if(limit_ < 1 && page_ < 1){
        return _configs_for_owner[owner_];
      }

      uint[] memory configs_ = new uint[](limit_);
      uint i = 0;
      uint index;
      uint offset = (page_-1)*limit_;
      while(i < limit_ && i < _configs_for_owner[owner_].length){
        index = i+(offset);
        if(_configs_for_owner[owner_].length > index){
          configs_[i] = _configs_for_owner[owner_][index];
        }
        i++;
      }

      return configs_;

    }

    function getConfig(uint config_id_) public view returns(IPolly.Config memory){

      return _configs[config_id_];
    }

    function isConfigOwner(uint config_id_, address check_) public view returns(bool){

      IPolly.Config memory config_ = getConfig(config_id_);
      return (config_.owner == check_);
    }

    function transferConfig(uint config_id_, address to_) public onlyConfigOwner(config_id_) {


      _configs[config_id_].owner = to_;

      uint[] memory configs_ = getConfigsForOwner(msg.sender, 0, 0);
      uint[] memory new_configs_ = new uint[](configs_.length -1);
      uint ii = 0;
      for (uint i = 0; i < configs_.length; i++) {
        if(configs_[i] == config_id_){
          _configs_for_owner[to_].push(config_id_);
        }
        else {
          new_configs_[ii] = config_id_;
          ii++;
        }
      }

      _configs_for_owner[msg.sender] = new_configs_;

      emit configTransferred(config_id_, msg.sender, to_);

    }


}