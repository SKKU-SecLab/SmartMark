
pragma solidity ^0.4.23;

library StringUtils {


  function contains(string source, string query) internal pure returns (bool) {

    return indexOf(source, query) != -1;
  }

  function indexOf(string source, string query) internal pure returns (int256) {

    return indexOf(source, query, 0);
  }

  function indexOf(string source, string query, uint256 fromIndex) internal pure returns (int256) {

    bytes memory sourceBytes = bytes(source);

    bytes memory queryBytes = bytes(query);

    if(queryBytes.length == 0) {
      return 0;
    }

    if(sourceBytes.length < queryBytes.length) {
      return -1;
    }

    for(uint256 i = fromIndex; i < sourceBytes.length - queryBytes.length; i++) {
      uint256 j = 0;
      while(j < queryBytes.length && queryBytes[j] == sourceBytes[j + i]) {
        j++;
      }
      if(j == queryBytes.length) {
        return int256(i);
      }
    }

    return -1;
  }

}

contract AccessControl {

  uint256 private constant ROLE_ROLE_MANAGER = 0x10000000;

  uint256 private constant ROLE_FEATURE_MANAGER = 0x20000000;

  uint256 private constant FULL_PRIVILEGES_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  uint256 public features;

  mapping(address => uint256) public userRoles;

  event FeaturesUpdated(address indexed _by, uint256 _requested, uint256 _actual);

  event RoleUpdated(address indexed _by, address indexed _to, uint256 _role);

  constructor() public {
    userRoles[msg.sender] = FULL_PRIVILEGES_MASK;
  }

  function updateFeatures(uint256 mask) public {

    address caller = msg.sender;
    uint256 p = userRoles[caller];

    require(__hasRole(p, ROLE_FEATURE_MANAGER));

    features |= p & mask;
    features &= FULL_PRIVILEGES_MASK ^ (p & (FULL_PRIVILEGES_MASK ^ mask));

    emit FeaturesUpdated(caller, mask, features);
  }

  function addOperator(address operator, uint256 role) public {

    address manager = msg.sender;

    uint256 permissions = userRoles[manager];

    require(userRoles[operator] == 0);

    require(__hasRole(permissions, ROLE_ROLE_MANAGER));

    uint256 r = role & permissions;

    require(r != 0);

    userRoles[operator] = r;

    emit RoleUpdated(manager, operator, userRoles[operator]);
  }

  function removeOperator(address operator) public {

    address manager = msg.sender;

    require(userRoles[operator] != 0);

    require(operator != manager);

    require(__hasRole(userRoles[manager], ROLE_ROLE_MANAGER | userRoles[operator]));

    delete userRoles[operator];

    emit RoleUpdated(manager, operator, 0);
  }

  function addRole(address operator, uint256 role) public {

    address manager = msg.sender;

    uint256 permissions = userRoles[manager];

    require(userRoles[operator] != 0);

    require(__hasRole(permissions, ROLE_ROLE_MANAGER));

    uint256 r = role & permissions;

    require(r != 0);

    userRoles[operator] |= r;

    emit RoleUpdated(manager, operator, userRoles[operator]);
  }

  function removeRole(address operator, uint256 role) public {

    address manager = msg.sender;

    uint256 permissions = userRoles[manager];


    require(__hasRole(permissions, ROLE_ROLE_MANAGER));

    uint256 r = role & permissions;

    require(r != 0);

    userRoles[operator] &= FULL_PRIVILEGES_MASK ^ r;

    emit RoleUpdated(manager, operator, userRoles[operator]);
  }

  function __isFeatureEnabled(uint256 featureRequired) internal constant returns(bool) {

    return __hasRole(features, featureRequired);
  }

  function __isSenderInRole(uint256 roleRequired) internal constant returns(bool) {

    uint256 userRole = userRoles[msg.sender];

    return __hasRole(userRole, roleRequired);
  }

  function __hasRole(uint256 userRole, uint256 roleRequired) internal pure returns(bool) {

    return userRole & roleRequired == roleRequired;
  }
}

contract DeedStamp is AccessControl {

  using StringUtils for string;

  uint32 private constant ROLE_DEED_REGISTRANT = 0x00000001;

  mapping(uint256 => uint256) private documentRegistry;

  mapping(uint256 => string[]) private addressRegistry;

  string[] public knownPropertyAddresses;

  event DeedRegistered(string propertyAddress, string document);

  function registerDeed(string propertyAddress, string document) public {

    require(__isSenderInRole(ROLE_DEED_REGISTRANT));

    uint256 documentHash = uint256(keccak256(document));

    require(documentRegistry[documentHash] == 0);

    require(document.contains(propertyAddress));

    documentRegistry[documentHash] = now;

    uint256 propertyAddressHash = uint256(keccak256(propertyAddress));

    if(addressRegistry[propertyAddressHash].length == 0) {
      knownPropertyAddresses.push(propertyAddress);
    }

    addressRegistry[propertyAddressHash].push(document);

    emit DeedRegistered(propertyAddress, document);
  }

  function verifyDeed(string document) public constant returns (bool) {

    uint256 documentHash = uint256(keccak256(document));

    return documentRegistry[documentHash] > 0;
  }

  function getDeedTimestamp(string document) public constant returns (uint256) {

    uint256 documentHash = uint256(keccak256(document));

    uint256 timestamp = documentRegistry[documentHash];

    require(timestamp > 0);

    return timestamp;
  }

  function getNumberOfDeedsByAddress(string propertyAddress) public constant returns (uint256) {

    uint256 propertyAddressHash = uint256(keccak256(propertyAddress));

    return addressRegistry[propertyAddressHash].length;
  }

  function getDeedByAddress(string propertyAddress, uint256 i) public constant returns (string) {

    uint256 propertyAddressHash = uint256(keccak256(propertyAddress));

    return addressRegistry[propertyAddressHash][i];
  }

  function getLastDeedByAddress(string propertyAddress) public constant returns (string) {

    uint256 propertyAddressHash = uint256(keccak256(propertyAddress));

    return addressRegistry[propertyAddressHash][addressRegistry[propertyAddressHash].length - 1];
  }
  function getDeedTimestampByAddress(string propertyAddress, uint256 i) public constant returns (uint256) {

    string memory deed = getDeedByAddress(propertyAddress, i);

    return getDeedTimestamp(deed);
  }

  function getLastDeedTimestampByAddress(string propertyAddress) public constant returns (uint256) {

    uint256 propertyAddressHash = uint256(keccak256(propertyAddress));

    string memory deed = addressRegistry[propertyAddressHash][addressRegistry[propertyAddressHash].length - 1];

    return getDeedTimestamp(deed);
  }

  function lastKnownPropertyAddress() public constant returns (string) {

    return knownPropertyAddresses[knownPropertyAddresses.length - 1];
  }

  function getNumberOfKnownPropertyAddresses() public constant returns (uint256) {

    return knownPropertyAddresses.length;
  }

}