
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// GPL-3.0
pragma solidity =0.8.11;
pragma experimental ABIEncoderV2;


contract BadgerRegistry {

  using EnumerableSet for EnumerableSet.AddressSet;

  enum VaultStatus {
    deprecated,
    experimental,
    guarded,
    open
  }

  uint256 public constant VAULT_STATUS_LENGTH = 4;

  struct VaultInfo {
    address vault;
    string version;
    VaultStatus status;
    string metadata;
  }

  struct VaultMetadata {
    address vault;
    string metadata;
  }

  struct VaultData {
    string version;
    VaultStatus status;
    VaultMetadata[] list;
  }

  address public governance;
  address public developer; //@notice an address with some powers to make things easier in development
  address public strategistGuild;

  mapping(address => mapping(string => EnumerableSet.AddressSet)) private vaults;

  mapping(address => mapping(address => VaultInfo)) public vaultInfoByAuthorAndVault;

  mapping(string => address) public addresses;
  mapping(address => string) public keyByAddress;

  mapping(string => mapping(VaultStatus => EnumerableSet.AddressSet)) private productionVaults;

  mapping(address => VaultInfo) public productionVaultInfoByVault;

  string[] public keys; //@notice, you don't have a guarantee of the key being there, it's just a utility
  string[] public versions; //@notice, you don't have a guarantee of the key being there, it's just a utility

  event NewVault(address author, string version, string metadata, address vault);
  event RemoveVault(address author, string version, string metadata, address vault);
  event PromoteVault(address author, string version, string metadata, address vault, VaultStatus status);
  event DemoteVault(address author, string version, string metadata, address vault, VaultStatus status);
  event PurgeVault(address author, string version, string metadata, address vault, VaultStatus status);

  event Set(string key, address at);
  event AddKey(string key);
  event DeleteKey(string key);
  event AddVersion(string version);

  function initialize(address newGovernance, address newStrategistGuild) public {

    require(governance == address(0));
    governance = newGovernance;
    strategistGuild = newStrategistGuild;
    developer = address(0);

    versions.push("v1"); //For v1
    versions.push("v1.5"); //For v1.5
    versions.push("v2"); //For v2
  }

  function setGovernance(address _newGov) public {

    require(msg.sender == governance, "!gov");
    governance = _newGov;
  }

  function setDeveloper(address newDev) public {

    require(msg.sender == governance || msg.sender == developer, "!gov");
    developer = newDev;
  }

  function setStrategistGuild(address newStrategistGuild) public {

    require(msg.sender == governance, "!gov");
    strategistGuild = newStrategistGuild;
  }

  function addVersions(string memory version) public {

    require(msg.sender == governance, "!gov");
    versions.push(version);

    emit AddVersion(version);
  }

  function add(
    address vault,
    string memory version,
    string memory metadata
  ) public {

    verifyMetadata(metadata);
    VaultInfo memory existedVaultInfo = vaultInfoByAuthorAndVault[msg.sender][vault];
    if (existedVaultInfo.vault != address(0)) {
      require(
        vault == existedVaultInfo.vault &&
          keccak256(bytes(version)) == keccak256(bytes(existedVaultInfo.version)) &&
          keccak256(bytes(metadata)) == keccak256(bytes(existedVaultInfo.metadata)),
        "BadgerRegistry: vault info changed. Please remove before add changed vault info"
      );
      return;
    }

    vaultInfoByAuthorAndVault[msg.sender][vault] = VaultInfo({
      vault: vault,
      version: version,
      status: VaultStatus(1),
      metadata: metadata
    });

    vaults[msg.sender][version].add(vault);
    emit NewVault(msg.sender, version, metadata, vault);
  }

  function remove(address vault) public {

    VaultInfo memory existedVaultInfo = vaultInfoByAuthorAndVault[msg.sender][vault];
    if (existedVaultInfo.vault == address(0)) {
      return;
    }
    delete vaultInfoByAuthorAndVault[msg.sender][vault];
    bool removedFromVersionSet = vaults[msg.sender][existedVaultInfo.version].remove(vault);
    if (removedFromVersionSet) {
      emit RemoveVault(msg.sender, existedVaultInfo.version, existedVaultInfo.metadata, vault);
    }
  }

  function promote(
    address vault,
    string memory version,
    string memory metadata,
    VaultStatus status
  ) public {

    require(msg.sender == governance || msg.sender == strategistGuild || msg.sender == developer, "!auth");
    verifyMetadata(metadata);

    VaultStatus actualStatus = status;
    if (msg.sender == developer) {
      actualStatus = VaultStatus.experimental;
    }

    VaultInfo memory existedVaultInfo = productionVaultInfoByVault[vault];
    if (existedVaultInfo.vault != address(0)) {
      require(
        vault == existedVaultInfo.vault && keccak256(bytes(version)) == keccak256(bytes(existedVaultInfo.version)),
        "BadgerRegistry: vault info changed. Please demote before promote changed vault info"
      );
      productionVaultInfoByVault[vault].status = actualStatus;
    } else {
      productionVaultInfoByVault[vault] = VaultInfo({
        vault: vault,
        version: version,
        status: actualStatus,
        metadata: metadata
      });
    }
    require(uint256(actualStatus) >= uint256(existedVaultInfo.status), "BadgerRegistry: Vault is not being promoted");

    bool addedToVersionStatusSet = productionVaults[version][actualStatus].add(vault);
    if (addedToVersionStatusSet) {
      if (uint256(actualStatus) > 0) {
        for (uint256 status_ = uint256(actualStatus); status_ > 0; --status_) {
          productionVaults[version][VaultStatus(status_ - 1)].remove(vault);
        }
      }

      emit PromoteVault(msg.sender, version, metadata, vault, actualStatus);
    }
  }

  function demote(address vault, VaultStatus status) public {

    require(msg.sender == governance || msg.sender == strategistGuild || msg.sender == developer, "!auth");

    VaultStatus actualStatus = status;

    VaultInfo memory existedVaultInfo = productionVaultInfoByVault[vault];
    require(existedVaultInfo.vault != address(0), "BadgerRegistry: Vault does not exist");
    require(uint256(actualStatus) < uint256(existedVaultInfo.status), "BadgerRegistry: Vault is not being demoted");

    productionVaults[existedVaultInfo.version][existedVaultInfo.status].remove(vault);
    productionVaultInfoByVault[vault].status = status;
    emit DemoteVault(msg.sender, existedVaultInfo.version, existedVaultInfo.metadata, vault, status);
    productionVaults[existedVaultInfo.version][status].add(vault);
  }

  function purge(address vault) public {

    require(msg.sender == governance || msg.sender == strategistGuild, "!auth");

    VaultInfo memory existedVaultInfo = productionVaultInfoByVault[vault];
    require(existedVaultInfo.vault != address(0), "BadgerRegistry: Vault does not exist");

    bool removedFromVersionStatusSet = productionVaults[existedVaultInfo.version][existedVaultInfo.status].remove(
      vault
    );
    bool deletedFromVaultInfoByVault = productionVaultInfoByVault[vault].vault != address(0);
    if (removedFromVersionStatusSet || deletedFromVaultInfoByVault) {
      delete productionVaultInfoByVault[vault];
      emit PurgeVault(msg.sender, existedVaultInfo.version, existedVaultInfo.metadata, vault, existedVaultInfo.status);
    }
  }

  function updateMetadata(address vault, string memory metadata) public {

    require(msg.sender == governance || msg.sender == strategistGuild, "!auth");
    verifyMetadata(metadata);

    require(productionVaultInfoByVault[vault].vault != address(0), "BadgerRegistry: Vault does not exist");

    productionVaultInfoByVault[vault].metadata = metadata;
  }


  function set(string memory key, address at) public {

    require(msg.sender == governance, "!gov");
    _addKey(key);
    addresses[key] = at;
    keyByAddress[at] = key;
    emit Set(key, at);
  }

  function deleteKey(string memory key) external {

    require(msg.sender == governance, "!gov");
    _deleteKey(key);
  }

  function _deleteKey(string memory key) private {

    address at = addresses[key];
    delete keyByAddress[at];

    for (uint256 x = 0; x < keys.length; x++) {
      if (keccak256(bytes(key)) == keccak256(bytes(keys[x]))) {
        delete addresses[key];
        keys[x] = keys[keys.length - 1];
        keys.pop();
        emit DeleteKey(key);
        return;
      }
    }
  }

  function deleteKeys(string[] memory _keys) external {

    require(msg.sender == governance, "!gov");

    uint256 length = _keys.length;
    for (uint256 x = 0; x < length; ++x) {
      _deleteKey(_keys[x]);
    }
  }

  function get(string memory key) public view returns (address) {

    return addresses[key];
  }

  function keysCount() public view returns (uint256) {

    return keys.length;
  }

  function _addKey(string memory key) internal {

    for (uint256 x = 0; x < keys.length; x++) {
      if (keccak256(bytes(key)) == keccak256(bytes(keys[x]))) {
        return;
      }
    }

    keys.push(key);

    emit AddKey(key);
  }

  function getVaults(string memory version, address author) public view returns (VaultInfo[] memory) {

    uint256 length = vaults[author][version].length();

    VaultInfo[] memory list = new VaultInfo[](length);
    for (uint256 i = 0; i < length; i++) {
      list[i] = vaultInfoByAuthorAndVault[author][vaults[author][version].at(i)];
    }
    return list;
  }

  function getFilteredProductionVaults(string memory version, VaultStatus status)
    public
    view
    returns (VaultInfo[] memory)
  {

    uint256 length = productionVaults[version][status].length();

    VaultInfo[] memory list = new VaultInfo[](length);
    for (uint256 i = 0; i < length; i++) {
      list[i] = productionVaultInfoByVault[productionVaults[version][status].at(i)];
    }
    return list;
  }

  function getProductionVaults() public view returns (VaultData[] memory) {

    uint256 versionsCount = versions.length;

    VaultData[] memory data = new VaultData[](versionsCount * VAULT_STATUS_LENGTH);

    for (uint256 x = 0; x < versionsCount; x++) {
      for (uint256 y = 0; y < VAULT_STATUS_LENGTH; y++) {
        uint256 length = productionVaults[versions[x]][VaultStatus(y)].length();
        VaultMetadata[] memory list = new VaultMetadata[](length);
        for (uint256 z = 0; z < length; z++) {
          VaultInfo storage vaultInfo = productionVaultInfoByVault[productionVaults[versions[x]][VaultStatus(y)].at(z)];
          list[z] = VaultMetadata({vault: vaultInfo.vault, metadata: vaultInfo.metadata});
        }
        data[x * VAULT_STATUS_LENGTH + y] = VaultData({version: versions[x], status: VaultStatus(y), list: list});
      }
    }

    return data;
  }

  function verifyMetadata(string memory metadata) private pure {

    bytes memory metadataBytes = bytes(metadata);
    uint256 nameIndex;
    uint256 protocolIndex;
    uint256 behaviorIndex;
    for (uint256 i = 0; i < metadataBytes.length; i++) {
      if (metadataBytes[i] == 0x3d) {
        if (nameIndex == 0) {
          nameIndex = i;
        } else if (protocolIndex == 0) {
          protocolIndex = i;
        } else if (behaviorIndex == 0) {
          behaviorIndex = i;
          break;
        }
      }
    }
    require(nameIndex > 0, "BadgerRegistry: Invalid Name");
    require(protocolIndex > 0, "BadgerRegistry: Invalid Protocol");
    require(behaviorIndex > 0, "BadgerRegistry: Invalid Behavior");
    require(keccak256(getSlice(metadataBytes, 0, nameIndex - 1)) == keccak256("name"), "BadgerRegistry: Invalid Name");
    require(
      keccak256(getSlice(metadataBytes, protocolIndex - 8, protocolIndex - 1)) == keccak256("protocol"),
      "BadgerRegistry: Invalid Protocol"
    );
    require(
      keccak256(getSlice(metadataBytes, behaviorIndex - 8, behaviorIndex - 1)) == keccak256("behavior"),
      "BadgerRegistry: Invalid Behavior"
    );
  }

  function getSlice(
    bytes memory text,
    uint256 begin,
    uint256 end
  ) private pure returns (bytes memory) {

    bytes memory a = new bytes(end - begin + 1);
    for (uint256 i = begin; i <= end; i++) {
      a[i - begin] = text[i];
    }
    return a;
  }
}