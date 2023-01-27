
pragma solidity ^0.8.0;

interface IACLRegistry {

  event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  function hasRole(bytes32 role, address account) external view returns (bool);


  function hasPermission(bytes32 permission, address account) external view returns (bool);


  function getRoleAdmin(bytes32 role) external view returns (bytes32);


  function grantRole(bytes32 role, address account) external;


  function revokeRole(bytes32 role, address account) external;


  function renounceRole(bytes32 role, address account) external;


  function setRoleAdmin(bytes32 role, bytes32 adminRole) external;


  function grantPermission(bytes32 permission, address account) external;


  function revokePermission(bytes32 permission) external;


  function requireApprovedContractOrEOA(address account) external view;


  function requireRole(bytes32 role, address account) external view;


  function requirePermission(bytes32 permission, address account) external view;


  function isRoleAdmin(bytes32 role, address account) external view;

}// GPL-3.0

pragma solidity ^0.8.0;

interface IContractRegistry {

  function getContract(bytes32 _name) external view returns (address);

}// GPL-3.0

pragma solidity ^0.8.0;


contract ContractRegistry is IContractRegistry {

  struct Contract {
    address contractAddress;
    bytes32 version;
  }


  IACLRegistry public aclRegistry;

  mapping(bytes32 => Contract) public contracts;
  bytes32[] public contractNames;


  event ContractAdded(bytes32 _name, address _address, bytes32 _version);
  event ContractUpdated(bytes32 _name, address _address, bytes32 _version);
  event ContractDeleted(bytes32 _name);


  constructor(IACLRegistry _aclRegistry) {
    aclRegistry = _aclRegistry;
    contracts[keccak256("ACLRegistry")] = Contract({contractAddress: address(_aclRegistry), version: keccak256("1")});
    contractNames.push(keccak256("ACLRegistry"));
  }


  function getContractNames() external view returns (bytes32[] memory) {

    return contractNames;
  }

  function getContract(bytes32 _name) external view override returns (address) {

    return contracts[_name].contractAddress;
  }


  function addContract(
    bytes32 _name,
    address _address,
    bytes32 _version
  ) external {

    aclRegistry.requireRole(keccak256("DAO"), msg.sender);
    require(contracts[_name].contractAddress == address(0), "contract already exists");
    contracts[_name] = Contract({contractAddress: _address, version: _version});
    contractNames.push(_name);
    emit ContractAdded(_name, _address, _version);
  }

  function updateContract(
    bytes32 _name,
    address _newAddress,
    bytes32 _version
  ) external {

    aclRegistry.requireRole(keccak256("DAO"), msg.sender);
    require(contracts[_name].contractAddress != address(0), "contract doesnt exist");
    contracts[_name] = Contract({contractAddress: _newAddress, version: _version});
    emit ContractUpdated(_name, _newAddress, _version);
  }

  function deleteContract(bytes32 _name, uint256 _contractIndex) external {

    aclRegistry.requireRole(keccak256("DAO"), msg.sender);
    require(contracts[_name].contractAddress != address(0), "contract doesnt exist");
    require(contractNames[_contractIndex] == _name, "this is not the contract you are looking for");
    delete contracts[_name];
    delete contractNames[_contractIndex];
    emit ContractDeleted(_name);
  }
}