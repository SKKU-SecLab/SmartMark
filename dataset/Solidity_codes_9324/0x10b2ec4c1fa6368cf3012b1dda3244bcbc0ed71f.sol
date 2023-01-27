
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


interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

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
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
}// MIT

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
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// AGPL-3.0-or-later
pragma solidity ^0.8.0;

interface IManifestNFTManager {

  event VaultSet(address indexed prevVault, address indexed newVault);
  event DropWhitelisted(address indexed drop, uint256[] ids);
  event DropBlacklisted(address indexed drop);
  event Burned(address indexed user, address drop, uint256 id, uint256 amount, address vault);

  struct Drop {
    address drop;
    uint256[] ids;
  }

  struct UserDrop {
    address drop;
    uint256[] ids;
    uint256[] amounts;
    string[] uris;
  }

  struct Burn {
    address drop;
    uint256 id;
    uint256 amount;
  }

  function setVault(address _vault) external;

  function togglePause() external;

  function whitelistDrop(address _drop, uint256[] calldata _ids) external;

  function blacklistDrop(uint256 _idx) external;


  function burn(address _drop, uint256 _id, uint256 _amount) external;


  function getUserDrops(address _user) external view returns (UserDrop[] memory);

  function checkDrop(address _drop, uint256 _id) external view returns (bool);

  function checkBurn(address _user, address _drop, uint256 _id) external view returns (uint256);

}// AGPL-3.0-or-later
pragma solidity ^0.8.0;



contract ManifestNFTManager is IManifestNFTManager, AccessControlEnumerable, Pausable, ReentrancyGuard {

  bytes32 public constant TEAM_ROLE = keccak256("TEAM_ROLE");
  bytes32 public constant VAULT_ROLE = keccak256("VAULT_ROLE");

  address public vault;
  Drop[] public drops;
  mapping(address => Burn[]) public burns;

  constructor(address _vault) {
    require(_vault != address(0), "ManifestNFTManager: vault address must not be 0");

    vault = _vault;

    _grantRole(DEFAULT_ADMIN_ROLE, _vault);
    _grantRole(TEAM_ROLE, _vault);
    _grantRole(VAULT_ROLE, _vault);
  }

  function setVault(address _vault) external override onlyRole(VAULT_ROLE) {

    require(_vault != address(0), "ManifestNFTManager: vault address must not be 0");

    address oldVault = vault;
    vault = _vault;

    _grantRole(DEFAULT_ADMIN_ROLE, _vault);
    _grantRole(TEAM_ROLE, _vault);
    _grantRole(VAULT_ROLE, _vault);
    _revokeRole(DEFAULT_ADMIN_ROLE, oldVault);
    _revokeRole(TEAM_ROLE, oldVault);
    _revokeRole(VAULT_ROLE, oldVault);

    emit VaultSet(oldVault, _vault);
  }

  function togglePause() external override onlyRole(TEAM_ROLE) {

    if (paused()) {
      _unpause();
    } else {
      _pause();
    }
  }

  function whitelistDrop(address _drop, uint256[] calldata _ids) external override onlyRole(TEAM_ROLE) {

    require(_drop != address(0), "ManifestNFTManager: drop address must not be 0");

    drops.push(Drop(_drop, _ids));

    emit DropWhitelisted(_drop, _ids);
  }

  function blacklistDrop(uint256 _idx) external override onlyRole(TEAM_ROLE) {

    require(_idx < drops.length, "ManifestNFTManager: index must be less than size of drops array");

    Drop memory drop = drops[_idx];

    drops[_idx] = drops[drops.length - 1];
    drops.pop();

    emit DropBlacklisted(drop.drop);
  }

  function burn(address _drop, uint256 _id, uint256 _amount) external override whenNotPaused nonReentrant {

    require(checkDrop(_drop, _id), "ManifestNFTManager: drop and/or ID not found");
    require(_amount > 0, "ManifestNFTManager: amount must be greater than 0");

    IERC1155MetadataURI dropNFT = IERC1155MetadataURI(_drop);
    dropNFT.safeTransferFrom(msg.sender, vault, _id, _amount, "");

    burns[msg.sender].push(Burn(_drop, _id, _amount));
    emit Burned(msg.sender, _drop, _id, _amount, vault);
  }

  function getUserDrops(address _user) public view override returns (UserDrop[] memory) {

    require(_user != address(0), "ManifestNFTManager: user address must not be 0");

    UserDrop[] memory userDrops = new UserDrop[](drops.length);

    for (uint256 i = 0; i < drops.length; i++) {
      userDrops[i].drop = drops[i].drop;
      userDrops[i].ids = drops[i].ids;
      userDrops[i].uris = new string[](drops[i].ids.length);

      address[] memory accounts = new address[](drops[i].ids.length);
      for (uint256 j = 0; j < accounts.length; j++) {
        accounts[j] = _user;
      }

      IERC1155MetadataURI dropNFT = IERC1155MetadataURI(drops[i].drop);
      userDrops[i].amounts = dropNFT.balanceOfBatch(accounts, drops[i].ids);

      for (uint256 j = 0; j < drops[i].ids.length; j++) {
        userDrops[i].uris[j] = dropNFT.uri(drops[i].ids[j]);
      }
    }

    return userDrops;
  }

  function checkDrop(address _drop, uint256 _id) public override view returns (bool) {

    require(_drop != address(0), "ManifestNFTManager: drop address must not be 0");

    for (uint256 i = 0; i < drops.length; i++) {
      if (drops[i].drop != _drop) {
        continue;
      }

      for (uint256 j = 0; j < drops[i].ids.length; j++) {
        if (drops[i].ids[j] == _id) {
          return true;
        }
      }
    }

    return false;
  }

  function checkBurn(address _user, address _drop, uint256 _id) public override view returns (uint256) {

    require(_user != address(0), "ManifestNFTManager: user address must not be 0");
    require(_drop != address(0), "ManifestNFTManager: drop address must not be 0");

    Burn[] memory userBurns = burns[_user];
    if (userBurns.length == 0) {
      return 0;
    }

    for (uint256 i = 0; i < userBurns.length; i++) {
      if (userBurns[i].drop == _drop && userBurns[i].id == _id) {
        return userBurns[i].amount;
      }
    }

    return 0;
  }
}