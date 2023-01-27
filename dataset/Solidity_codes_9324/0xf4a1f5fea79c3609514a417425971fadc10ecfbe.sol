pragma solidity 0.6.12;

interface IPermissionManager {

  event RoleSet(address indexed user, uint256 indexed role, address indexed whiteLister, bool set);
  event PermissionsAdminSet(address indexed user, bool set);

  function addPermissionAdmins(address[] calldata admins) external;


  function removePermissionAdmins(address[] calldata admins) external;


  function addPermissions(uint256[] calldata roles, address[] calldata users) external;


  function removePermissions(uint256[] calldata roles, address[] calldata users) external;


  function getUserPermissions(address user) external view returns (uint256[] memory, uint256);


  function isInRole(address user, uint256 role) external view returns (bool);


  function isPermissionsAdmin(address user) external view returns (bool);


  function isInAllRoles(address user, uint256[] calldata roles) external view returns (bool);


  function isInAnyRole(address user, uint256[] calldata roles) external view returns (bool);


  function getUserPermissionAdmin(address user) external view returns (address);


  function isUserPermissionAdminValid(address user) external view returns (bool);

}// MIT
pragma solidity 0.6.12;

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}// MIT

pragma solidity ^0.6.0;


contract Ownable is Context {

  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  function renounceOwnership() public virtual onlyOwner {

    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {

    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}pragma solidity 0.6.12;


contract PermissionManager is IPermissionManager, Ownable {

  struct UserData {
    uint256 permissions;
    address permissionAdmin;
  }

  mapping(address => UserData) _users;
  mapping(address => uint256) _permissionsAdmins;

  uint256 public constant MAX_NUM_OF_ROLES = 256;

  modifier onlyPermissionAdmins(address user) {

    require(_permissionsAdmins[user] > 0, 'CALLER_NOT_PERMISSIONS_ADMIN');
    _;
  }

  function addPermissionAdmins(address[] calldata admins) external override onlyOwner {

    for (uint256 i = 0; i < admins.length; i++) {
      _permissionsAdmins[admins[i]] = 1;

      emit PermissionsAdminSet(admins[i], true);
    }
  }

  function removePermissionAdmins(address[] calldata admins) external override onlyOwner {

    for (uint256 i = 0; i < admins.length; i++) {
      _permissionsAdmins[admins[i]] = 0;

      emit PermissionsAdminSet(admins[i], false);
    }
  }

  function addPermissions(uint256[] calldata roles, address[] calldata users)
    external
    override
    onlyPermissionAdmins(msg.sender)
  {

    require(roles.length == users.length, 'INCONSISTENT_ARRAYS_LENGTH');

    for (uint256 i = 0; i < users.length; i++) {
      uint256 role = roles[i];
      address user = users[i];

      require(role < MAX_NUM_OF_ROLES, 'INVALID_ROLE');

      uint256 permissions = _users[user].permissions;
      address permissionAdmin = _users[user].permissionAdmin;

      require(
        (permissions != 0 && permissionAdmin == msg.sender) ||
          _users[user].permissionAdmin == address(0),
        'INVALID_PERMISSIONADMIN'
      );

      if (permissions == 0) {
        _users[user].permissionAdmin = msg.sender;
      }

      _users[user].permissions = permissions | (1 << role);

      emit RoleSet(user, role, msg.sender, true);
    }
  }

  function removePermissions(uint256[] calldata roles, address[] calldata users)
    external
    override
    onlyPermissionAdmins(msg.sender)
  {

    require(roles.length == users.length, 'INCONSISTENT_ARRAYS_LENGTH');

    for (uint256 i = 0; i < users.length; i++) {
      uint256 role = roles[i];
      address user = users[i];

      require(role < MAX_NUM_OF_ROLES, 'INVALID_ROLE');

      uint256 permissions = _users[user].permissions;
      address permissionAdmin = _users[user].permissionAdmin;

      require(
        (permissions != 0 && permissionAdmin == msg.sender) ||
          _users[user].permissionAdmin == address(0),
        'INVALID_PERMISSIONADMIN'
      );

      _users[user].permissions = permissions & ~(1 << role);

      if (_users[user].permissions == 0) {
        _users[user].permissionAdmin = address(0);
      }

      emit RoleSet(user, role, msg.sender, false);
    }
  }

  function getUserPermissions(address user)
    external
    view
    override
    returns (uint256[] memory, uint256)
  {

    uint256[] memory roles = new uint256[](256);
    uint256 rolesCount = 0;
    uint256 userPermissions = _users[user].permissions;

    for (uint256 i = 0; i < 256; i++) {
      if ((userPermissions >> i) & 1 > 0) {
        roles[rolesCount] = i;
        rolesCount++;
      }
    }

    return (roles, rolesCount);
  }

  function isInRole(address user, uint256 role) external view override returns (bool) {

    return (_users[user].permissions >> role) & 1 > 0;
  }

  function isInAllRoles(address user, uint256[] calldata roles)
    external
    view
    override
    returns (bool)
  {

    for (uint256 i = 0; i < roles.length; i++) {
      if ((_users[user].permissions >> roles[i]) & 1 == 0) {
        return false;
      }
    }
    return true;
  }

  function isInAnyRole(address user, uint256[] calldata roles)
    external
    view
    override
    returns (bool)
  {

    for (uint256 i = 0; i < roles.length; i++) {
      if ((_users[user].permissions >> roles[i]) & 1 > 0) {
        return true;
      }
    }
    return false;
  }

  function isPermissionsAdmin(address admin) public view override returns (bool) {

    return _permissionsAdmins[admin] > 0;
  }

  function getUserPermissionAdmin(address user) external view override returns (address) {

    return _users[user].permissionAdmin;
  }

  function isUserPermissionAdminValid(address user) external view override returns (bool) {

    return _permissionsAdmins[_users[user].permissionAdmin] > 0;
  }
}