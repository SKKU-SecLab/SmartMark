
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract PlaceHolder {

    
}


abstract contract Proxy {
  fallback () virtual payable external {
    _fallback();
  }
  
  receive () virtual payable external {
    _fallback();
  }

  function _implementation() virtual internal view returns (address);

  function _delegate(address implementation) internal {
    assembly {
      calldatacopy(0, 0, calldatasize())

      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      returndatacopy(0, 0, returndatasize())

      switch result
      case 0 { revert(0, returndatasize()) }
      default { return(0, returndatasize()) }
    }
  }

  function _willFallback() virtual internal {
      
  }

  function _fallback() internal {
    if(OpenZeppelinUpgradesAddress.isContract(msg.sender) && msg.data.length == 0)         // for receive ETH only from other contract
        return;
    _willFallback();
    _delegate(_implementation());
  }
}

abstract contract BaseUpgradeabilityProxy is Proxy {
  event Upgraded(address indexed implementation);

  bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  function _implementation() virtual override internal view returns (address impl) {
    bytes32 slot = _IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  function _setImplementation(address newImplementation) internal {
    require(newImplementation == address(0) || OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = _IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}


contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {

  event AdminChanged(address previousAdmin, address newAdmin);


  bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  modifier ifAdmin() {

    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  function admin() external ifAdmin returns (address) {

    return _admin();
  }

  function implementation() external ifAdmin returns (address) {

    return _implementation();
  }

  function changeAdmin(address newAdmin) external ifAdmin {

    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  function upgradeTo(address newImplementation) external ifAdmin {

    _upgradeTo(newImplementation);
  }

  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {

    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = _ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  function _setAdmin(address newAdmin) internal {

    bytes32 slot = _ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  function _willFallback() virtual override internal {

    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
  }
}

interface IAdminUpgradeabilityProxyView {

  function admin() external view returns (address);

  function implementation() external view returns (address);

}


abstract contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
  constructor(address _logic, bytes memory _data) public payable {
    assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
  
}


contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {

  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
    _setAdmin(_admin);
  }
  
  function _willFallback() override(Proxy, BaseAdminUpgradeabilityProxy) internal {

    super._willFallback();
  }
}


contract __BaseAdminUpgradeabilityProxy__ is BaseUpgradeabilityProxy {

  event AdminChanged(address previousAdmin, address newAdmin);


  bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  modifier ifAdmin() {

    require (msg.sender == _admin(), "only admin");
      _;
  }

  function __admin__() external view returns (address) {

    return _admin();
  }

  function __implementation__() external view returns (address) {

    return _implementation();
  }

  function __changeAdmin__(address newAdmin) external ifAdmin {

    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  function __upgradeTo__(address newImplementation) external ifAdmin {

    _upgradeTo(newImplementation);
  }

  function __upgradeToAndCall__(address newImplementation, bytes calldata data) payable external ifAdmin {

    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = _ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  function _setAdmin(address newAdmin) internal {

    bytes32 slot = _ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

}


contract __AdminUpgradeabilityProxy__ is __BaseAdminUpgradeabilityProxy__, UpgradeabilityProxy {

  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
    _setAdmin(_admin);
  }
  
}  

contract __AdminUpgradeabilityProxy0__ is __BaseAdminUpgradeabilityProxy__, UpgradeabilityProxy {

  constructor() UpgradeabilityProxy(address(0), "") public {
    assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
    _setAdmin(msg.sender);
  }
}


abstract contract InitializableUpgradeabilityProxy is BaseUpgradeabilityProxy {
  function initialize(address _logic, bytes memory _data) public payable {
    require(_implementation() == address(0));
    assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}


contract InitializableAdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, InitializableUpgradeabilityProxy {

  function initialize(address _logic, address _admin, bytes memory _data) public payable {

    require(_implementation() == address(0));
    InitializableUpgradeabilityProxy.initialize(_logic, _data);
    assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
    _setAdmin(_admin);
  }
  
  function _willFallback() override(Proxy, BaseAdminUpgradeabilityProxy) internal {

    super._willFallback();
  }

}


interface IBeacon {

    function governor() external view returns (address);

    function __admin__() external view returns (address);

    function implementation() external view returns (address);

    function implementations(bytes32 shard) external view returns (address);

}


contract BeaconProxy is Proxy {

    
  bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;
  bytes32 internal constant _SHARD_SLOT  = 0xaaae0bca7ee6d7a0887fc381d821ed8229b96ca9503d8457f880ab5f52323504;      // bytes32(uint256(keccak256("eip1967.proxy.shard")) - 1)

  function _shard() virtual internal view returns (bytes32 shard_) {

    bytes32 slot = _SHARD_SLOT;
    assembly {  shard_ := sload(slot)  }
  }
  
  function _setShard(bytes32 shard_) internal {

    bytes32 slot = _SHARD_SLOT;
    assembly {  sstore(slot, shard_)  }
  }

  function _setBeacon(address newBeacon) internal {

    require(newBeacon == address(0) || OpenZeppelinUpgradesAddress.isContract(newBeacon), "Cannot set a beacon to a non-contract address");

    bytes32 slot = _BEACON_SLOT;

    assembly {
      sstore(slot, newBeacon)
    }
  }

  function _beacon() internal view returns (address beacon_) {

    bytes32 slot = _BEACON_SLOT;
    assembly {
      beacon_ := sload(slot)
    }
  }
  
  function _implementation() virtual override internal view returns (address) {

    address beacon_ = _beacon();
    bytes32 shard_ = _shard();
    if(OpenZeppelinUpgradesAddress.isContract(beacon_))
        if(shard_ != 0x0)
            return IBeacon(beacon_).implementations(shard_);
        else
            return IBeacon(beacon_).implementation();
    else
        return address(0);
  }

}


contract InitializableBeaconProxy is BeaconProxy {

  function __InitializableBeaconProxy_init(address beacon, bytes32 shard, bytes memory data) external payable {

    address beacon_ = _beacon();
    require(beacon_ == address(0) || msg.sender == beacon_ || msg.sender == IBeacon(beacon_).governor() || msg.sender == IBeacon(beacon_).__admin__());
    assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
    assert(_SHARD_SLOT  == bytes32(uint256(keccak256("eip1967.proxy.shard")) - 1));
    _setBeacon(beacon);
    _setShard(shard);
    if(data.length > 0) {
      (bool success,) = _implementation().delegatecall(data);
      require(success);
    }
  }  
}


contract __InitializableAdminUpgradeabilityBeaconProxy__ is __BaseAdminUpgradeabilityProxy__, BeaconProxy {

  function __InitializableAdminUpgradeabilityBeaconProxy_init__(address logic, address admin, address beacon, bytes32 shard, bytes memory data) public payable {

    assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
    assert(_ADMIN_SLOT          == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
    assert(_BEACON_SLOT         == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
    assert(_SHARD_SLOT          == bytes32(uint256(keccak256("eip1967.proxy.shard")) - 1));
    address admin_ = _admin();
    require(admin_ == address(0) || msg.sender == admin_);
    _setAdmin(admin);
    _setImplementation(logic);
    _setBeacon(beacon);
    _setShard(shard);
    if(data.length > 0) {
      (bool success,) = _implementation().delegatecall(data);
      require(success);
    }
  }
  
  function _implementation() virtual override(BaseUpgradeabilityProxy, BeaconProxy) internal view returns (address impl) {

    impl = BeaconProxy._implementation();
    if(impl == address(0))
        impl = BaseUpgradeabilityProxy._implementation();
  }
}

contract __AdminUpgradeabilityBeaconProxy__ is __InitializableAdminUpgradeabilityBeaconProxy__ {

  constructor(address logic, address admin, address beacon, bytes32 shard, bytes memory data) public payable {
    __InitializableAdminUpgradeabilityBeaconProxy_init__(logic, admin, beacon, shard, data);
  }
}

contract __AdminUpgradeabilityBeaconProxy0__ is __InitializableAdminUpgradeabilityBeaconProxy__ {

  constructor() public {
    __InitializableAdminUpgradeabilityBeaconProxy_init__(address(0), msg.sender, address(0), 0, "");
  }
}


library Clones {


    function isClone(address target, address query) internal view returns (bool result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(ptr, 0xa), targetBytes)
            mstore(add(ptr, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(ptr, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(ptr), mload(other)),
                eq(mload(add(ptr, 0xd)), mload(add(other, 0xd)))
            )
        }
    }

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
}


library Config {

  bytes32 internal constant CONFIG_SLOT        = 0x54c601f62ced84cb3960726428d8409adc363a3fa5c7abf6dba0c198dcc43c14;     // bytes32(uint256(keccak256("eip1967.proxy.config")) - 1));

  function config() internal pure returns (mapping (bytes32 => uint) storage map) {

    assembly {  map_slot := CONFIG_SLOT   }
  }

  function configA() internal pure returns (mapping (bytes32 => address) storage map) {

    assembly {  map_slot := CONFIG_SLOT   }
  }

  function get(bytes32 key) internal view returns (uint) {

    return config()[key];
  }

  function get(bytes32 key, uint index) internal view returns (uint) {

    return config()[bytes32(uint(key) ^ index)];
  }

  function get(bytes32 key, address addr) internal view returns (uint) {

    return config()[bytes32(uint(key) ^ uint(addr))];
  }

  function getA(bytes32 key) internal view returns (address) {

    return configA()[key];
  }

  function getA(bytes32 key, uint index) internal view returns (address) {

    return configA()[bytes32(uint(key) ^ index)];
  }

  function getA(bytes32 key, address addr) internal view returns (address) {

    return configA()[bytes32(uint(key) ^ uint(addr))];
  }

  function set(bytes32 key, uint value) internal {

    config()[key] = value;
  }

  function set(bytes32 key, uint index, uint value) internal {

    config()[bytes32(uint(key) ^ index)] = value;
  }

  function set(bytes32 key, address addr, uint value) internal {

    config()[bytes32(uint(key) ^ uint(addr))] = value;
  }

  function setA(bytes32 key, address value) internal {

    configA()[key] = value;
  }

  function setA(bytes32 key, uint index, address value) internal {

    configA()[bytes32(uint(key) ^ index)] = value;
  }

  function setA(bytes32 key, address addr, address value) internal {

    configA()[bytes32(uint(key) ^ uint(addr))] = value;
  }

  bytes32 internal constant _ADMIN_SLOT_ = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  function admin() internal view returns (address adm) {

    bytes32 slot = _ADMIN_SLOT_;
    assembly {
      adm := sload(slot)
    }
  }
    
}

contract Setable {

  bytes32 internal constant _governor_  = "governor";

  constructor() public {
    Config.setA(_governor_, msg.sender);
  }

  function _governance() internal view {

    require(msg.sender == Config.getA(_governor_) || msg.sender == Config.admin());
  }
  
  modifier governance() virtual {

    _governance();
    _;
  }
}

contract Sets is Setable {

  struct KeyValue {
    bytes32 key;
    uint    value;
  }

  function sets_(KeyValue[] calldata s) external governance {

    for(uint i=0; i<s.length; i++)
      Config.set(s[i].key, s[i].value);
  }

  function gets(bytes32[] calldata keys) external view returns (uint[] memory values){

    values = new uint[](keys.length);
    for(uint i=0; i<keys.length; i++)
      values[i] = Config.get(keys[i]);
  }
}

library IDelegateStaticCall {

  function delegatestaticcall(address ex, bytes memory data) external view returns (bool, bytes memory) {

    return ex.staticcall(data);
  }
  function delegatestaticcall(bytes memory data) external view returns (bool, bytes memory) {

    return address(this).staticcall(data);
  }
}

library DelegateStaticCall {

  function delegatestaticcall(address ex, bytes memory data) external returns (bool, bytes memory) {

    return ex.delegatecall(data);
  }
}

contract Extend {

  bytes32 internal constant _extend_        = "extend";
  string  internal constant ERROR_FALLBACK  = "eip1967.proxy.error.fallback";



  function _getExtend(bytes4 sig) virtual internal view returns (address) {

    return Config.getA(_extend_, uint32(sig));
  }
  
  function _setExtend(bytes4 sig, address ex) virtual internal {

    Config.setA(_extend_, uint32(sig), ex);
  }
}

contract Extendable is Sets, Extend {


  modifier viewExtend virtual {

    _viewExtend();
    _;
  }

  modifier extend virtual {

    _extend();
    _;
  }

  function _viewExtend() virtual internal view {

    address ex = _getExtend(0xffffffff);
    if(ex == address(0))
      ex = _getExtend(msg.sig);
    if(OpenZeppelinUpgradesAddress.isContract(ex)) {
      (bool success, bytes memory r) = IDelegateStaticCall.delegatestaticcall(ex, msg.data);
      if(success)
        assembly {  return(add(r, 32), returndatasize())  }
      else
        assembly {  revert(add(r, 32), returndatasize())  }
    } else if(ex == 0x000000000000000000000000000000000000dEaD)
      revert("obsolete");
  }
  
  function _extend() virtual internal {

    address ex = _getExtend(0xffffffff);
    if(ex == address(0))
      ex = _getExtend(msg.sig);
    return _extend(ex);
  }

  function _extend0() virtual internal {

    address ex = address(0);
    address ex1 = _getExtend(0xffffffff);
    if(ex1 == address(0))
      ex = _getExtend(msg.sig);
    if(ex == address(0)) {
      ex = _getExtend(0);
      if(ex == address(0)) {
        ex = ex1;
        require(ex != address(0), ERROR_FALLBACK);
      }
    }
    return _extend(ex);
  }

  function _extend(address ex) internal {

    if(OpenZeppelinUpgradesAddress.isContract(ex)) {
      (bool success, bytes memory r) = ex.delegatecall(msg.data);
      if(success)
        assembly {  return(add(r, 32), returndatasize())  }
      else
        assembly {  revert(add(r, 32), returndatasize())  }
    } else if(ex == 0x000000000000000000000000000000000000dEaD)
      revert("obsolete");
  }

  struct SigEx {
    bytes4  sig;
    address ex;
  }
  
  function setExtends_(SigEx[] memory s) external governance {

    for(uint i=0; i<s.length; i++)
      _setExtend(s[i].sig, s[i].ex);
  }

  fallback () virtual payable external {
    _extend0();
  }
  
  receive () virtual payable external {
    if(OpenZeppelinUpgradesAddress.isContract(msg.sender) && msg.data.length == 0 && gasleft() <= 2300)         // for receive ETH only from other contract
        return;
    _extend0();
  }
}

contract Extended is Setable, Extend {

  function _callback(bytes memory data) internal returns(bytes memory rdata) {

    bytes4 sig = abi.decode(data, (bytes4));
    address ex = _getExtend(sig);
    if(ex != address(0))
      _setExtend(sig, address(0));
    address ex1 = _getExtend(0xffffffff);
    if(ex1 != address(0))
      _setExtend(0xffffffff, address(0));
    bool success;
    (success, rdata) = address(this).delegatecall(data);
    if(!success)
      assembly {  revert(add(data, 32), returndatasize()) }
    if(ex != address(0))
      _setExtend(sig, ex);
    if(ex1 != address(0))
      _setExtend(0xffffffff, ex1);
  }

  fallback () virtual payable external {
     revert(ERROR_FALLBACK);
  }

  receive () virtual payable external {
    if(OpenZeppelinUpgradesAddress.isContract(msg.sender) && msg.data.length == 0)         // for receive ETH only from other contract
      return;
    revert(ERROR_FALLBACK);
  }
}


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


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
}

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function sqrt(uint256 x) internal pure returns (uint256) {

        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
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

    function sub0(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a - b : 0;
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

    function div0(uint256 a, uint256 b) internal pure returns (uint256) {

        return b == 0 ? 0 : a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library OpenZeppelinUpgradesAddress {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20UpgradeSafe is ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    uint256 internal _cap;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {

        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function __ERC20Capped_init(string memory name, string memory symbol, uint256 cap) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20Capped_init_unchained(cap);
    }

    function __ERC20Capped_init_unchained(uint256 cap) internal initializer {

        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    function cap() virtual public view returns (uint256) {

        return _cap;
    }

    function name() virtual public view returns (string memory) {

        return _name;
    }

    function symbol() virtual public view returns (string memory) {

        return _symbol;
    }

    function decimals() virtual public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public virtual override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) virtual override public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        if(sender != _msgSender() && _allowances[sender][_msgSender()] != uint(-1))
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        if (_cap > 0) { // When Capped
            require(_totalSupply.add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
		
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    uint256[43] private __gap;
}


contract ERC20Permit is ERC20UpgradeSafe {		// ERC2612

    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public DOMAIN_SEPARATOR;
    mapping (address => uint) public nonces;
    
    function __ERC20Permit_init_unchained() internal initializer {

        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(_name)), keccak256(bytes("1")), _chainId(), address(this)));
    }
    
    function _chainId() internal pure returns (uint id) {

        assembly { id := chainid() }
    }
    
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) virtual external {

      return _permit(owner, spender, value, deadline, v, r, s);
    }
    function _permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) virtual internal {

        require(deadline >= block.timestamp, "permit EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "permit INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }

    uint256[48] private __gap;
}


library $M {

    function msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    function chainId() internal pure returns (uint id) {

        assembly { id := chainid() }
    }
}


struct ERC20Stru {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    uint256 totalSupply;

    string name;
    string symbol;
    uint8 decimals;

    uint256 cap;

    bytes32 DOMAIN_SEPARATOR;
    mapping (address => uint) nonces;
}

library ERC20Lib {

    using SafeMath for uint256;

    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    
    function ERC20_init(ERC20Stru storage $, string memory name, string memory symbol) internal {

        ERC20_init_unchained($, name, symbol);
    }
    
    function ERC20_init_unchained(ERC20Stru storage $, string memory name, string memory symbol) internal {

        $.name = name;
        $.symbol = symbol;
        $.decimals = 18;
    }
    
    function ERC20Capped_init(ERC20Stru storage $, string memory name, string memory symbol, uint256 cap) internal {

        ERC20_init_unchained($, name, symbol);
        ERC20Capped_init_unchained($, cap);
    }
    
    function ERC20Capped_init_unchained(ERC20Stru storage $, uint256 cap) internal {

        require(cap > 0, "ERC20Capped: cap is 0");
        $.cap = cap;
    }
    
    function ERC20Permit_init(ERC20Stru storage $, string memory name, string memory symbol, uint256 cap) internal {

        ERC20_init_unchained($, name, symbol);
        ERC20Capped_init_unchained($, cap);
        ERC20Permit_init_unchained($);
    }
    
    function ERC20Permit_init_unchained(ERC20Stru storage $) internal {

        $.DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes($.name)), keccak256(bytes("1")), $M.chainId(), address(this)));
    }
    
    function setupDecimals(ERC20Stru storage $, uint8 decimals) internal {

        $.decimals = decimals;
    }

    function transfer(ERC20Stru storage $, address recipient, uint256 amount) internal returns (bool) {

        transfer($, $M.msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(ERC20Stru storage $, address owner, address spender) internal view returns (uint256) {

        return $.allowances[owner][spender];
    }
    
    function approve(ERC20Stru storage $, address spender, uint256 amount) internal returns (bool) {

        approve($, $M.msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(ERC20Stru storage $, address sender, address recipient, uint256 amount) internal returns (bool) {

        transfer($, sender, recipient, amount);
        if(sender != $M.msgSender() && $.allowances[sender][$M.msgSender()] != uint(-1))
            approve($, sender, $M.msgSender(), $.allowances[sender][$M.msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function increaseAllowance(ERC20Stru storage $, address spender, uint256 addedValue) internal returns (bool) {

        approve($, $M.msgSender(), spender, $.allowances[$M.msgSender()][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(ERC20Stru storage $, address spender, uint256 subtractedValue) internal returns (bool) {

        approve($, $M.msgSender(), spender, $.allowances[$M.msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function transfer(ERC20Stru storage $, address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        $.balances[sender] = $.balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        $.balances[recipient] = $.balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function mint(ERC20Stru storage $, address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        if ($.cap > 0) { // When Capped
            require($.totalSupply.add(amount) <= $.cap, "ERC20Capped: cap exceeded");
        }
		

        $.totalSupply = $.totalSupply.add(amount);
        $.balances[account] = $.balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(ERC20Stru storage $, address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");


        $.balances[account] = $.balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        $.totalSupply = $.totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function approve(ERC20Stru storage $, address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        $.allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function permit(ERC20Stru storage $, address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) internal {

        require(deadline >= block.timestamp, "permit EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                $.DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, $.nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "permit INVALID_SIGNATURE");
        approve($, owner, spender, value);
    }


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeApprove_(IERC20 token, address spender, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract Governable is Initializable {

    address public governor;

    event GovernorshipTransferred(address indexed previousGovernor, address indexed newGovernor);

    function __Governable_init_unchained(address governor_) virtual internal initializer {

        governor = governor_;
        emit GovernorshipTransferred(address(0), governor);
    }

    modifier governance() virtual {

        require(msg.sender == governor || msg.sender == Config.admin());
        _;
    }

    function renounceGovernorship_() public governance {

        emit GovernorshipTransferred(governor, address(0));
        governor = address(0);
    }

    function transferGovernorship_(address newGovernor) public governance {

        _transferGovernorship(newGovernor);
    }

    function _transferGovernorship(address newGovernor) internal {

        require(newGovernor != address(0));
        emit GovernorshipTransferred(governor, newGovernor);
        governor = newGovernor;
    }
}


contract Configurable is Governable {

    mapping (bytes32 => uint) internal config;
    
    function getConfig(bytes32 key) public view returns (uint) {

        return config[key];
    }
    function getConfigI(bytes32 key, uint index) public view returns (uint) {

        return config[bytes32(uint(key) ^ index)];
    }
    function getConfigA(bytes32 key, address addr) public view returns (uint) {

        return config[bytes32(uint(key) ^ uint(addr))];
    }

    function _setConfig(bytes32 key, uint value) internal {

        if(config[key] != value)
            config[key] = value;
    }
    function _setConfig(bytes32 key, uint index, uint value) internal {

        _setConfig(bytes32(uint(key) ^ index), value);
    }
    function _setConfig(bytes32 key, address addr, uint value) internal {

        _setConfig(bytes32(uint(key) ^ uint(addr)), value);
    }

    function setConfig_(bytes32 key, uint value) external governance {

        _setConfig(key, value);
    }
    function setConfigI_(bytes32 key, uint index, uint value) external governance {

        _setConfig(bytes32(uint(key) ^ index), value);
    }
    function setConfigA_(bytes32 key, address addr, uint value) public governance {

        _setConfig(bytes32(uint(key) ^ uint(addr)), value);
    }
}


contract Rescue is Governable, Setable {

    using SafeERC20 for IERC20;

    modifier governance() override(Governable, Setable) {

        require(msg.sender == governor || msg.sender == Config.admin() || msg.sender == Config.getA(_governor_));
        _;
    }

    function rescue(address payable _dst, uint _amt) external governance {

        _dst.transfer(Math.min(_amt, address(this).balance));
    }

    function rescueTokens(address _token, address _dst, uint _amt) external governance {

        uint balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(_dst, Math.min(_amt, balance));
    }
}

pragma solidity ^0.6.0;


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}


contract ERC165UpgradeSafe is Initializable, IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;


    function __ERC165_init() internal initializer {

        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {



        _registerInterface(_INTERFACE_ID_ERC165);

    }


    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[49] private __gap;
}


library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}


library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}


library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}


contract ERC721UpgradeSafe is Initializable, ContextUpgradeSafe, ERC165UpgradeSafe, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string internal _name;

    string internal _symbol;

    mapping(uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;


    function __ERC721_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name, symbol);
    }

    function __ERC721_init_unchained(string memory name, string memory symbol) internal initializer {



        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);

    }


    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }


    uint256[41] private __gap;
}

pragma solidity 0.6.12;

library Account {

    enum Status {Normal, Liquid, Vapor}
    struct Info {
        address owner; // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }
    struct Storage {
        mapping(uint256 => Types.Par) balances; // Mapping from marketId to principal
        Status status;
    }
}


library Actions {

    enum ActionType {
        Deposit, // supply tokens
        Withdraw, // borrow tokens
        Transfer, // transfer balance between accounts
        Buy, // buy an amount of some token (publicly)
        Sell, // sell an amount of some token (publicly)
        Trade, // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize, // use excess tokens to zero-out a completely negative account
        Call // send arbitrary data to an address
    }

    enum AccountLayout {OnePrimary, TwoPrimary, PrimaryAndSecondary}

    enum MarketLayout {ZeroMarkets, OneMarket, TwoMarkets}

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct DepositArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address from;
    }

    struct WithdrawArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address to;
    }

    struct TransferArgs {
        Types.AssetAmount amount;
        Account.Info accountOne;
        Account.Info accountTwo;
        uint256 market;
    }

    struct BuyArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 makerMarket;
        uint256 takerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    struct SellArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 takerMarket;
        uint256 makerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    struct TradeArgs {
        Types.AssetAmount amount;
        Account.Info takerAccount;
        Account.Info makerAccount;
        uint256 inputMarket;
        uint256 outputMarket;
        address autoTrader;
        bytes tradeData;
    }

    struct LiquidateArgs {
        Types.AssetAmount amount;
        Account.Info solidAccount;
        Account.Info liquidAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    struct VaporizeArgs {
        Types.AssetAmount amount;
        Account.Info solidAccount;
        Account.Info vaporAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    struct CallArgs {
        Account.Info account;
        address callee;
        bytes data;
    }
}


library Decimal {

    struct D256 {
        uint256 value;
    }
}


library Interest {

    struct Rate {
        uint256 value;
    }

    struct Index {
        uint96 borrow;
        uint96 supply;
        uint32 lastUpdate;
    }
}


library Monetary {

    struct Price {
        uint256 value;
    }
    struct Value {
        uint256 value;
    }
}


library Storage {

    struct Market {
        address token;
        Types.TotalPar totalPar;
        Interest.Index index;
        address priceOracle;
        address interestSetter;
        Decimal.D256 marginPremium;
        Decimal.D256 spreadPremium;
        bool isClosing;
    }

    struct RiskParams {
        Decimal.D256 marginRatio;
        Decimal.D256 liquidationSpread;
        Decimal.D256 earningsRate;
        Monetary.Value minBorrowedValue;
    }

    struct RiskLimits {
        uint64 marginRatioMax;
        uint64 liquidationSpreadMax;
        uint64 earningsRateMax;
        uint64 marginPremiumMax;
        uint64 spreadPremiumMax;
        uint128 minBorrowedValueMax;
    }

    struct State {
        uint256 numMarkets;
        mapping(uint256 => Market) markets;
        mapping(address => mapping(uint256 => Account.Storage)) accounts;
        mapping(address => mapping(address => bool)) operators;
        mapping(address => bool) globalOperators;
        RiskParams riskParams;
        RiskLimits riskLimits;
    }
}


library Types {

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    struct Par {
        bool sign; // true if positive
        uint128 value;
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }
}


abstract contract ISoloMargin { //
    struct OperatorArg {
        address operator;
        bool trusted;
    }

    function ownerSetSpreadPremium(
        uint256 marketId,
        Decimal.D256 memory spreadPremium
    ) public virtual;

    function getIsGlobalOperator(address operator) public virtual view returns (bool);

    function getMarketTokenAddress(uint256 marketId)
        public
        virtual
        view
        returns (address);

    function ownerSetInterestSetter(uint256 marketId, address interestSetter)
        public virtual;

    function getAccountValues(Account.Info memory account)
        public
        virtual
        view
        returns (Monetary.Value memory, Monetary.Value memory);

    function getMarketPriceOracle(uint256 marketId)
        public
        virtual
        view
        returns (address);

    function getMarketInterestSetter(uint256 marketId)
        public
        virtual
        view
        returns (address);

    function getMarketSpreadPremium(uint256 marketId)
        public
        virtual
        view
        returns (Decimal.D256 memory);

    function getNumMarkets() public virtual view returns (uint256);

    function ownerWithdrawUnsupportedTokens(address token, address recipient)
        public virtual
        returns (uint256);

    function ownerSetMinBorrowedValue(Monetary.Value memory minBorrowedValue)
        public virtual;

    function ownerSetLiquidationSpread(Decimal.D256 memory spread) public virtual;

    function ownerSetEarningsRate(Decimal.D256 memory earningsRate) public virtual;

    function getIsLocalOperator(address owner, address operator)
        public
        virtual
        view
        returns (bool);

    function getAccountPar(Account.Info memory account, uint256 marketId)
        public
        virtual
        view
        returns (Types.Par memory);

    function ownerSetMarginPremium(
        uint256 marketId,
        Decimal.D256 memory marginPremium
    ) public virtual;

    function getMarginRatio() public virtual view returns (Decimal.D256 memory);

    function getMarketCurrentIndex(uint256 marketId)
        public
        virtual
        view
        returns (Interest.Index memory);

    function getMarketIsClosing(uint256 marketId) public virtual view returns (bool);

    function getRiskParams() public virtual view returns (Storage.RiskParams memory);

    function getAccountBalances(Account.Info memory account)
        public
        virtual
        view
        returns (address[] memory, Types.Par[] memory, Types.Wei[] memory);

    function renounceOwnership() public virtual;

    function getMinBorrowedValue() public virtual view returns (Monetary.Value memory);

    function setOperators(OperatorArg[] memory args) public virtual;

    function getMarketPrice(uint256 marketId) public virtual view returns (address);

    function owner() public virtual view returns (address);

    function isOwner() public virtual view returns (bool);

    function ownerWithdrawExcessTokens(uint256 marketId, address recipient)
        public virtual
        returns (uint256);

    function ownerAddMarket(
        address token,
        address priceOracle,
        address interestSetter,
        Decimal.D256 memory marginPremium,
        Decimal.D256 memory spreadPremium
    ) public virtual;

    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    ) public virtual;

    function getMarketWithInfo(uint256 marketId)
        public
        virtual
        view
        returns (
            Storage.Market memory,
            Interest.Index memory,
            Monetary.Price memory,
            Interest.Rate memory
        );

    function ownerSetMarginRatio(Decimal.D256 memory ratio) public virtual;

    function getLiquidationSpread() public virtual view returns (Decimal.D256 memory);

    function getAccountWei(Account.Info memory account, uint256 marketId)
        public
        virtual
        view
        returns (Types.Wei memory);

    function getMarketTotalPar(uint256 marketId)
        public
        virtual
        view
        returns (Types.TotalPar memory);

    function getLiquidationSpreadForPair(
        uint256 heldMarketId,
        uint256 owedMarketId
    ) public virtual view returns (Decimal.D256 memory);

    function getNumExcessTokens(uint256 marketId)
        public
        virtual
        view
        returns (Types.Wei memory);

    function getMarketCachedIndex(uint256 marketId)
        public
        virtual
        view
        returns (Interest.Index memory);

    function getAccountStatus(Account.Info memory account)
        public
        virtual
        view
        returns (uint8);

    function getEarningsRate() public virtual view returns (Decimal.D256 memory);

    function ownerSetPriceOracle(uint256 marketId, address priceOracle) public virtual;

    function getRiskLimits() public virtual view returns (Storage.RiskLimits memory);

    function getMarket(uint256 marketId)
        public
        virtual
        view
        returns (Storage.Market memory);

    function ownerSetIsClosing(uint256 marketId, bool isClosing) public virtual;

    function ownerSetGlobalOperator(address operator, bool approved) public virtual;

    function transferOwnership(address newOwner) public virtual;

    function getAdjustedAccountValues(Account.Info memory account)
        public
        virtual
        view
        returns (Monetary.Value memory, Monetary.Value memory);

    function getMarketMarginPremium(uint256 marketId)
        public
        virtual
        view
        returns (Decimal.D256 memory);

    function getMarketInterestRate(uint256 marketId)
        public
        virtual
        view
        returns (Interest.Rate memory);
}

pragma solidity 0.6.12;



interface ICallee {



    function callFunction(
        address sender,
        Account.Info memory accountInfo,
        bytes memory data
    )
        external;

}

contract DydxFlashloanBase {



    function _getMarketIdFromTokenAddress(address _solo, address token)
        internal
        view
        returns (uint256)
    {

        ISoloMargin solo = ISoloMargin(_solo);

        uint256 numMarkets = solo.getNumMarkets();

        address curToken;
        for (uint256 i = 0; i < numMarkets; i++) {
            curToken = solo.getMarketTokenAddress(i);

            if (curToken == token) {
                return i;
            }
        }

        revert("No marketId found for provided token");
    }

    function _getRepaymentAmountInternal(uint256 amount)
        internal
        pure
        returns (uint256)
    {

        return amount + 2;
    }

    function _getAccountInfo() internal view returns (Account.Info memory) {

        return Account.Info({owner: address(this), number: 1});
    }

    function _getWithdrawAction(uint marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Withdraw,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }

    function _getCallAction(bytes memory data)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Call,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: 0
                }),
                primaryMarketId: 0,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: data
            });
    }

    function _getDepositAction(uint marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Deposit,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: true,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }
}
pragma solidity ^0.6.0;

interface IWETHGateway {

  function depositETH(address onBehalfOf, uint16 referralCode) external payable;


  function withdrawETH(uint256 amount, address to) external;


  function borrowETH(
    uint256 amount,
    address nftAsset,
    uint256 nftTokenId,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function batchBorrowETH(
    uint256[] calldata amounts,
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function repayETH(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
  ) external payable returns (uint256, bool);


  function batchRepayETH(
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    uint256[] calldata amounts
  ) external payable returns (uint256[] memory, bool[] memory);


  function auctionETH(
    address nftAsset,
    uint256 nftTokenId,
    address onBehalfOf
  ) external payable;


  function redeemETH(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount,
    uint256 bidFine
  ) external payable returns (uint256);


  function liquidateETH(address nftAsset, uint256 nftTokenId) external payable returns (uint256);

}// MIT

pragma solidity ^0.6.0;


contract Constants {


    bytes32 internal constant _GemSwap_         = "GemSwap";
    bytes32 internal constant _gem_converter_   = "gem_converter";

    address internal constant _dYdX_SoloMargin_ = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address internal constant _WETH_            = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address internal constant _BEND_            = 0x0d02755a5700414B26FF040e1dE35D337DF56218;
    address internal constant _bendWETHGateway_ = 0x3B968D2D299B895A5Fcf3BBa7A64ad0F566e6F88;
    address internal constant _bendDebtWETH_    = 0x87ddE3A3f4b629E389ce5894c9A1F34A7eeC5648;
    address internal constant _bendLendPool_    = 0x70b97A0da65C15dfb0FFA02aEE6FA36e507C2762;
    address internal constant _bendLendPoolLoan_= 0x5f6ac80CdB9E87f3Cfa6a90E5140B9a16A361d5C;
    address internal constant _bendIncentives_  = 0x26FC1f11E612366d3367fc0cbFfF9e819da91C8d;   // BendProtocolIncentivesController

    address internal constant _NPics_           = 0xA2f78200746F73662ea8b5b721fDA86CB0880F15;
    address internal constant _BeaconProxyNBP_  = 0x70643f0DFbA856071D335678dF7ED332FFd6e3be;
    bytes32 internal constant _SHARD_NEO_       = 0;
    bytes32 internal constant _SHARD_NBP_       = bytes32(uint(1));

    bytes4 internal constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
}

contract NEO is ERC721UpgradeSafe, Constants {      // NFT Everlasting Options

    
    address payable public beacon;
    address public nft;

    function __NEO_init(address nft_) external initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        (string memory name, string memory symbol) = spellNameAndSymbol(nft_);
        __ERC721_init_unchained(name, symbol);
        __NEO_init_unchained(nft_);
    }

    function __NEO_init_unchained(address nft_) internal initializer {

        beacon = _msgSender();
        nft = nft_;
    }

    function spellNameAndSymbol(address nft_) public view returns (string memory name, string memory symbol) {

        name = string(abi.encodePacked("NPics.xyz NFT Everlasting Options ", IERC721Metadata(nft_).symbol()));
        symbol = string(abi.encodePacked("neo", IERC721Metadata(nft_).symbol()));
    }

    function setNameAndSymbol(string memory name, string memory symbol) external {

        require(_msgSender() == NPics(beacon).governor() || _msgSender() == __AdminUpgradeabilityProxy__(beacon).__admin__());
        _name = name;
        _symbol = symbol;
    }

    modifier onlyBeacon {

        require(_msgSender() == beacon, 'Only Beacon');
        _;
    }
    
    function transfer_(address sender, address recipient, uint tokenId) external onlyBeacon {

        _transfer(sender, recipient, tokenId);
    }
    
    function mint_(address to, uint tokenId) external onlyBeacon {

        _mint(to, tokenId);
        _setTokenURI(tokenId, IERC721Metadata(nft).tokenURI(tokenId));
    }
    
    function burn_(uint tokenId) external onlyBeacon {

        _burn(tokenId);
    }

    uint[48] private ______gap;
}

contract NBP is DydxFlashloanBase, ICallee, IERC721Receiver, ReentrancyGuardUpgradeSafe, ContextUpgradeSafe, Constants {      // NFT Backed Position

    using SafeMath for uint;
    
    address payable public beacon;
    address public nft;
    uint public tokenId;

    function __NBP_init(address nft_, uint tokenId_) external initializer {

        __ReentrancyGuard_init_unchained();
        __Context_init_unchained();
        __NBP_init_unchained(nft_, tokenId_);
    }

    function __NBP_init_unchained(address nft_, uint tokenId_) internal initializer {

        beacon = _msgSender();
        nft = nft_;
        tokenId = tokenId_;
    }

    modifier onlyBeacon {

        require(_msgSender() == beacon, 'Only Beacon');
        _;
    }
    
    function withdraw_(address to) external onlyBeacon {

        IERC721(nft).safeTransferFrom(address(this), to, tokenId);
    }

    function claimRewardsTo_(address to) external onlyBeacon returns(uint amt) {

        address[] memory assets = new address[](1);
        assets[0] = _bendDebtWETH_;
        amt = IBendIncentives(_bendIncentives_).claimRewards(assets, uint(-1));
        IERC20(_BEND_).transfer(to, amt);
    }

    function downPayWithETH(TradeDetails[] memory tradeDetails, uint loanAmt) public payable onlyBeacon {

        address _solo = _dYdX_SoloMargin_;
        address _token = _WETH_;
        uint marketId = _getMarketIdFromTokenAddress(_solo, _token);

        uint _amount = IERC20(_token).balanceOf(_solo);
        uint repayAmount = _amount.add(2);   //_getRepaymentAmountInternal(_amount);
        IERC20(_token).approve(_solo, repayAmount);

        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, _amount);
        operations[1] = _getCallAction(
            abi.encode(tradeDetails, loanAmt)
        );
        operations[2] = _getDepositAction(marketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        ISoloMargin(_solo).operate(accountInfos, operations);


        if(address(this).balance > 0)
            _msgSender().transfer(address(this).balance);
    }

    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) override external {

        require(_msgSender() == _dYdX_SoloMargin_ && sender == address(this) && account.owner == address(this) && account.number == 1, "callFunction param check fail");
        (TradeDetails[] memory tradeDetails, uint loanAmt) = abi.decode(data, (TradeDetails[], uint));
        uint balOfLoanedToken = IERC20(_WETH_).balanceOf(address(this));
        WETH9(_WETH_).withdraw(balOfLoanedToken);
        require(address(this).balance >= tradeDetails[0].value, "Insufficient downPay+flashLoan to batchBuyWithETH");

        require(IERC721(nft).ownerOf(tokenId) != address(this), "nbp owned the nft already");
        IGemSwap(NPics(beacon).getConfig(_GemSwap_)).batchBuyWithETH{value: address(this).balance}(tradeDetails);
        require(IERC721(nft).ownerOf(tokenId) == address(this), "nbp not owned the nft yet");

        IERC721(nft).approve(_bendWETHGateway_, tokenId);
        IDebtToken(_bendDebtWETH_).approveDelegation(_bendWETHGateway_, uint(-1));
        IWETHGateway(_bendWETHGateway_).borrowETH(loanAmt, nft, tokenId, address(this), 0);

        require(address(this).balance >= balOfLoanedToken.add(2), "Insufficient balance to repay flashLoan");
        WETH9(_WETH_).deposit{value: balOfLoanedToken.add(2)}();
    }

    function onERC721Received(address operator, address from, uint tokenId_, bytes calldata data) override external returns (bytes4) {

        operator;
        from;
        data;

        if(tokenId_ == tokenId)
            return this.onERC721Received.selector;
        else
            return 0;
    }

    receive () external payable {

    }

    uint[47] private ______gap;
}

contract NPics is Configurable, ReentrancyGuardUpgradeSafe, ContextUpgradeSafe, Constants {

    using SafeMath for uint;
    using Address for address;

    function implementation() public view returns(address) {  return implementations[0];  }

    mapping (bytes32 => address) public implementations;

    mapping (address => address) public neos;     // uft => neo
    address[] public neoA;
    function neoN() external view returns (uint) {  return neoA.length;  }

    
    mapping(address => mapping(uint => address payable)) public nbps;     // uft => tokenId => nbp
    address[] public nbpA;
    function nbpN() external view returns (uint) {  return nbpA.length;  }

    
    function __NPics_init(address governor, address implNEO, address implNBP) public initializer {

        __Governable_init_unchained(governor);
        __ReentrancyGuard_init_unchained();
        __Context_init_unchained();
        __NPics_init_unchained(implNEO, implNBP);
    }

    function __NPics_init_unchained(address implNEO, address implNBP) internal initializer {

        upgradeImplementationTo(implNEO, implNBP);
        config[_GemSwap_]               = uint(0x83C8F28c26bF6aaca652Df1DbBE0e1b56F8baBa2);
        config[_gem_converter_]         = uint(0x97Fb625482464eb51E8F65291515de1F68526337);
    }
    
    function upgradeImplementationTo(address implNEO, address implNBP) public governance {

        implementations[_SHARD_NEO_]    = implNEO;
        implementations[_SHARD_NBP_]    = implNBP;
    }
    
    function createNEO(address nft) public returns (address neo) {

        require(nft.isContract(), 'nft should isContract');
        require(IERC165(nft).supportsInterface(_INTERFACE_ID_ERC721), 'nft should supportsInterface(_INTERFACE_ID_ERC721)');

        require(neos[nft] == address(0), 'the NEO exist already');

        bytes memory bytecode = type(BeaconProxyNEO).creationCode;

        bytes32 salt = keccak256(abi.encodePacked(nft));
        assembly {
            neo := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        NEO(neo).__NEO_init(nft);

        neos[nft] = neo;
        neoA.push(neo);
        emit CreateNEO(_msgSender(), nft, neo, neoA.length);
    }
    event CreateNEO(address indexed creator, address indexed nft, address indexed neo, uint count);

    function createNBP(address nft, uint tokenId) public returns (address payable nbp) {

        require(nft.isContract(), 'nft should isContract');
        require(IERC165(nft).supportsInterface(_INTERFACE_ID_ERC721), 'nft should supportsInterface(_INTERFACE_ID_ERC721)');

        require(nbps[nft][tokenId] == address(0), 'the NBP exist already');

        bytes32 salt = keccak256(abi.encodePacked(nft, tokenId));
        nbp = payable(Clones.cloneDeterministic(_BeaconProxyNBP_, salt));
        NBP(nbp).__NBP_init(nft, tokenId);

        nbps[nft][tokenId] = nbp;
        nbpA.push(nbp);
        emit CreateNBP(_msgSender(), nft, tokenId, nbp, nbpA.length);
    }
    event CreateNBP(address indexed creator, address indexed nft, uint indexed tokenId, address nbp, uint count);

    function availableBorrowsInETH(address nft) public view returns(uint r) {

        (, , r, , , ,) = ILendPool(_bendLendPool_).getNftCollateralData(nft, _WETH_);
    }

    function downPayWithETH(address nft, uint tokenId, TradeDetails[] memory tradeDetails, uint loanAmt) public payable nonReentrant {

        require(tradeDetails.length == 1, "tradeDetails.length != 1");
        require(loanAmt <= availableBorrowsInETH(nft), "Too much borrowETH");
        uint value = address(this).balance;
        require(value.add(loanAmt) >= tradeDetails[0].value.add(2), "Insufficient down payment");

        address payable nbp = nbps[nft][tokenId];
        if(nbp == address(0))
            nbp = createNBP(nft, tokenId);
        NBP(nbp).downPayWithETH{value: value}(tradeDetails, loanAmt);

        address neo = neos[nft];
        if(neo == address(0))
            neo = createNEO(nft);
        NEO(neo).mint_(_msgSender(), tokenId);

        emit DownPayWithETH(_msgSender(), nft, tokenId, value.sub(address(this).balance), loanAmt);

        if(address(this).balance > 0)
            _msgSender().transfer(address(this).balance);
    }
    event DownPayWithETH(address indexed sender, address indexed nft, uint indexed tokenId, uint value, uint loanAmt);

    function downPayBatchBuyWithETH(address nft, uint tokenId, bytes calldata data, uint loanAmt) external payable {

        bytes4 sig = data[0] |  bytes4(data[1]) >> 8 | bytes4(data[2]) >> 16  | bytes4(data[3]) >> 24;
        require(sig == IGemSwap.batchBuyWithETH.selector, "not batchBuyWithETH.selector");
        TradeDetails[] memory tradeDetails = abi.decode(data[4:], (TradeDetails[]));
        downPayWithETH(nft, tokenId, tradeDetails, loanAmt);
    }

    function downPayBatchBuyWithERC20s(address nft, uint tokenId, bytes calldata data, uint loanAmt) external payable {

        bytes4 sig = data[0] |  bytes4(data[1]) >> 8 | bytes4(data[2]) >> 16  | bytes4(data[3]) >> 24;
        require(sig == IGemSwap.batchBuyWithERC20s.selector, "not batchBuyWithErc20s.selector");
        (ERC20Details memory erc20Details,
        TradeDetails[] memory tradeDetails,
        ConverstionDetails[] memory converstionDetails,
        address[] memory dustTokens) = abi.decode(data[4:], (ERC20Details, TradeDetails[], ConverstionDetails[], address[]));

        for (uint256 i = 0; i < erc20Details.tokenAddrs.length; i++) {
            (bool success, ) = erc20Details.tokenAddrs[i].call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), erc20Details.amounts[i]));
            success;
        }

        _conversionHelper(converstionDetails);

        downPayWithETH(nft, tokenId, tradeDetails, loanAmt);

        _returnDust(dustTokens);
    }

    function _conversionHelper(ConverstionDetails[] memory _converstionDetails) internal {

        for (uint256 i = 0; i < _converstionDetails.length; i++) {
            (bool success, ) = address(config[_gem_converter_]).delegatecall(_converstionDetails[i].conversionData);
            _checkCallResult(success);
        }
    }

    function _returnDust(address[] memory _tokens) internal {

        assembly {
            if gt(selfbalance(), 0) {
                let callStatus := call(
                    gas(),
                    caller(),
                    selfbalance(),
                    0,
                    0,
                    0,
                    0
                )
            }
        }
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (IERC20(_tokens[i]).balanceOf(address(this)) > 0) {
                (bool success, ) = _tokens[i].call(abi.encodeWithSelector(0xa9059cbb, msg.sender, IERC20(_tokens[i]).balanceOf(address(this))));
                success;
            }
        }
    }

    function _checkCallResult(bool _success) internal pure {

        if (!_success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    function getLoanReserveBorrowAmount(address nftAsset, uint nftTokenId) public view returns(address reserveAsset, uint repayDebtAmount) {

        uint loanId = ILendPoolLoan(_bendLendPoolLoan_).getCollateralLoanId(nftAsset, nftTokenId);
        if(loanId == 0)
            return (address(0), 0);
        return ILendPoolLoan(_bendLendPoolLoan_).getLoanReserveBorrowAmount(loanId);
    }

    function getDebtWEthOf(address user) external view returns(uint amt) {

        for(uint i=0; i<neoA.length; i++) {
            NEO neo = NEO(neoA[i]);
            address nft = neo.nft();
            for(uint j=0; j<neo.balanceOf(user); j++) {
                (address reserveAsset, uint repayDebtAmount) = getLoanReserveBorrowAmount(nft, neo.tokenOfOwnerByIndex(user, j));
                if(reserveAsset == _WETH_)
                    amt = amt.add(repayDebtAmount);
            }
        }
    }
    
    function repayETH(address nftAsset, uint nftTokenId, uint amount) external payable nonReentrant returns(uint repayAmount, bool repayAll) {

        if(amount > 0)
            (repayAmount, repayAll) = IWETHGateway(_bendWETHGateway_).repayETH{value: msg.value}(nftAsset, nftTokenId, amount);
        if(amount == 0 || repayAll) {
            NEO neo = NEO(neos[nftAsset]);
            require(address(neo) != address(0) && address(neo).isContract(), "INVALID neo");
            address user = neo.ownerOf(nftTokenId);
            NBP nbp = NBP(nbps[nftAsset][nftTokenId]);
            uint rwd = nbp.claimRewardsTo_(user);
            emit RewardsClaimed(user, rwd);
            nbp.withdraw_(user);
            neo.burn_(nftTokenId);
        }
        if(address(this).balance > 0)
            _msgSender().transfer(address(this).balance);
        emit RepayETH(_msgSender(), nftAsset, nftTokenId, repayAmount, repayAll);
    }
    event RepayETH(address indexed sender, address indexed nftAsset, uint indexed nftTokenId, uint repayAmount, bool repayAll);

    function batchRepayETH(address[] calldata nftAssets, uint256[] calldata nftTokenIds, uint256[] calldata amounts) external payable nonReentrant returns(uint256[] memory repayAmounts, bool[] memory repayAlls) {

        (repayAmounts, repayAlls) = IWETHGateway(_bendWETHGateway_).batchRepayETH{value: msg.value}(nftAssets, nftTokenIds, amounts);
        for(uint i=0; i<repayAmounts.length; i++) {
            if(repayAlls[i]) {
                NEO neo = NEO(neos[nftAssets[i]]);
                require(address(neo) != address(0) && address(neo).isContract(), "INVALID neo");
                address user = neo.ownerOf(nftTokenIds[i]);
                NBP nbp = NBP(nbps[nftAssets[i]][nftTokenIds[i]]);
                uint rwd = nbp.claimRewardsTo_(user);
                emit RewardsClaimed(user, rwd);
                nbp.withdraw_(user);
                neo.burn_(nftTokenIds[i]);
            }
            emit RepayETH(_msgSender(), nftAssets[i], nftTokenIds[i], repayAmounts[i], repayAlls[i]);
        }
        if(address(this).balance > 0)
            _msgSender().transfer(address(this).balance);
    }

    function getRewardsBalance(address user) external view returns(uint amt) {

        address[] memory assets = new address[](1);
        assets[0] = _bendDebtWETH_;
        for(uint i=0; i<neoA.length; i++) {
            NEO neo = NEO(neoA[i]);
            address nft = neo.nft();
            for(uint j=0; j<neo.balanceOf(user); j++) {
                address nbp = nbps[nft][neo.tokenOfOwnerByIndex(user, j)];
                amt = amt.add(IBendIncentives(_bendIncentives_).getRewardsBalance(assets, nbp));
            }
        }
    }

    function claimRewards() external returns(uint amt) {

        address user = _msgSender();
        for(uint i=0; i<neoA.length; i++) {
            NEO neo = NEO(neoA[i]);
            address nft = neo.nft();
            for(uint j=0; j<neo.balanceOf(user); j++) {
                address payable nbp = nbps[nft][neo.tokenOfOwnerByIndex(user, j)];
                amt = amt.add(NBP(nbp).claimRewardsTo_(user));
            }
        }
        emit RewardsClaimed(user, amt);
    }
    event RewardsClaimed(address indexed user, uint amount);

    receive () external payable {
        
    }

    uint[45] private ______gap;
}


contract BeaconProxyNEO is Proxy, Constants {

    function _implementation() virtual override internal view returns (address) {

        return IBeacon(_NPics_).implementations(_SHARD_NEO_);
  }
}

contract BeaconProxyNBP is Proxy, Constants {

    function _implementation() virtual override internal view returns (address) {

        return IBeacon(_NPics_).implementations(_SHARD_NBP_);
  }
}


interface WETH9 {

    function deposit() external payable;

    function withdraw(uint wad) external;

}

struct TradeDetails {
    uint marketId;
    uint value;
    bytes tradeData;
}

struct ERC20Details {
    address[] tokenAddrs;
    uint256[] amounts;
}

struct ConverstionDetails {
    bytes conversionData;
}

interface IGemSwap {

    function batchBuyWithETH(TradeDetails[] memory tradeDetails) payable external;

    function batchBuyWithERC20s(
        ERC20Details memory erc20Details,
        TradeDetails[] memory tradeDetails,
        ConverstionDetails[] memory converstionDetails,
        address[] memory dustTokens
    ) payable external;

}

interface IDebtToken {

    function approveDelegation(address delegatee, uint amount) external;

}

interface ILendPool {

  function getNftCollateralData(address nftAsset, address reserveAsset) external view returns (
      uint256 totalCollateralInETH,
      uint256 totalCollateralInReserve,
      uint256 availableBorrowsInETH,
      uint256 availableBorrowsInReserve,
      uint256 ltv,
      uint256 liquidationThreshold,
      uint256 liquidationBonus
    );

}

interface ILendPoolLoan {

    function getCollateralLoanId(address nftAsset, uint nftTokenId) external view returns(uint);

    function getLoanReserveBorrowAmount(uint loanId) external view returns(address, uint);

}

interface IBendIncentives {

    function getRewardsBalance(address[] calldata assets, address user) external view returns(uint);

    function claimRewards(address[] calldata assets, uint amount) external returns(uint);

}
