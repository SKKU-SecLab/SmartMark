
pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

interface IAccessControlEnumerable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}

library RoleBasedAccessControlLib {

    using EnumerableSet for EnumerableSet.AddressSet;

    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    struct RoleBasedAccessControlStorage {
        mapping (bytes32 => RoleData) _roles;
        mapping (bytes32 => EnumerableSet.AddressSet) _roleMembers;
    }

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {

        return interfaceId == type(IAccessControl).interfaceId
            || interfaceId == type(IAccessControlEnumerable).interfaceId;
    }

    function _hasRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) internal view returns (bool) {

        return s._roles[role].members[account];
    }

    function hasRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external view returns (bool) {

        return _hasRole(s, role, account);
    }

    function _getRoleAdmin(RoleBasedAccessControlStorage storage s, bytes32 role) internal view returns (bytes32) {

        return s._roles[role].adminRole;
    }

    function getRoleAdmin(RoleBasedAccessControlStorage storage s, bytes32 role) external view returns (bytes32) {

        return _getRoleAdmin(s, role);
    }

    function grantRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external {

        require(_hasRole(s, _getRoleAdmin(s, role), msg.sender), "AccessControl: must be admin");

        _grantRole(s, role, account);
    }

    function revokeRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external {

        require(_hasRole(s, _getRoleAdmin(s, role), msg.sender), "AccessControl: must be admin");

        _revokeRole(s, role, account);
    }

    function renounceRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external {

        require(account == msg.sender, "Can only renounce role for self");

        _revokeRole(s, role, account);
    }

    function _setupRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external {

        _grantRole(s, role, account);
    }

    function _setRoleAdmin(RoleBasedAccessControlStorage storage s, bytes32 role, bytes32 adminRole) internal {

        emit RoleAdminChanged(role, _getRoleAdmin(s, role), adminRole);
        s._roles[role].adminRole = adminRole;
    }

    function _grantRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) private {

        if (!_hasRole(s, role, account)) {
            s._roles[role].members[account] = true;
            s._roleMembers[role].add(account);
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) private {

        require(role != DEFAULT_ADMIN_ROLE || account != msg.sender, "Cannot revoke own admin role");
        if (_hasRole(s, role, account)) {
            s._roles[role].members[account] = false;
            s._roleMembers[role].remove(account);
            emit RoleRevoked(role, account, msg.sender);
        }
    }


    function getRoleMember(RoleBasedAccessControlStorage storage s, bytes32 role, uint256 index) external view returns (address) {

        return s._roleMembers[role].at(index);
    }

    function getRoleMemberCount(RoleBasedAccessControlStorage storage s, bytes32 role) external view returns (uint256) {

        return s._roleMembers[role].length();
    }


}