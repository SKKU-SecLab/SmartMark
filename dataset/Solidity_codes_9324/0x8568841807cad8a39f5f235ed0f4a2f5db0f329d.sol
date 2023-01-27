pragma solidity ^0.8.0;


interface IGameDB {

    function createPlayer(
        string calldata name,
        uint16 yearOfBirth,
        uint8 monthOfBirth,
        uint8 dayOfBirth
    ) external returns (uint32);


    function getPlayer(uint32 playerId)
        external
        view
        returns (
            string memory name,
            uint16 yearOfBirth,
            uint8 monthOfBirth,
            uint8 dayOfBirth
        );


    function createClub(
        string calldata name,
        string calldata country,
        string calldata city,
        uint16 yearFounded
    ) external returns (uint16);


    function getClub(uint16 clubId)
        external
        view
        returns (
            string memory name,
            string memory country,
            string memory city,
            uint16 yearFounded
        );


    function playerExists(uint32 playerId) external view returns (bool);

    function clubExists(uint16 clubId) external view returns (bool);

    function setMinter (address minter) external returns (bool);
}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlUpgradeable {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                StringsUpgradeable.toHexString(uint160(account), 20),
                " is missing role ",
                StringsUpgradeable.toHexString(uint256(role), 32)
            )));
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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


interface IAccessControlEnumerableUpgradeable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}

abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping (bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
    uint256[49] private __gap;
}//UNLICENSED
pragma solidity ^0.8.0;


contract GameDB is IGameDB, AccessControlEnumerableUpgradeable {


	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Player {
        string name;
        uint16 yearOfBirth;
        uint8 monthOfBirth;
        uint8 dayOfBirth;
    }

    struct Club {
        string name;
        string country;
        string city;
        uint16 yearFounded;
    }

    event PlayerAdded(
        uint32 indexed playerId,
        string playerName,
        uint16 yearOfBirth,
        uint8 monthOfBirth,
        uint8 dayOfBirth
    );

    event ClubAdded(
        uint16 indexed clubId,
        string name,
        string country,
        string city,
        uint16 yearFounded
    );

    mapping(uint256 => uint32) public playerIds;

    mapping(uint256 => uint16) public clubIds;

    Club[] public clubs;

    Player[] public players;

    function init() public initializer  {      

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function createPlayer(
        string calldata name,
        uint16 yearOfBirth,
        uint8 monthOfBirth,
        uint8 dayOfBirth
    ) external override returns (uint32) {

    	require(hasRole(MINTER_ROLE, _msgSender()), "GameDB: must have minter role to mint");

        require(
            monthOfBirth >= 1 &&
                monthOfBirth <= 12 &&
                dayOfBirth >= 1 &&
                dayOfBirth <= 31,
            "GameDB: Invalid birth date"
        );

        require(players.length < 4294967295, "GameDB: Too many players");

        uint256 playerHash = uint256(
            keccak256(
                abi.encodePacked(name, yearOfBirth, monthOfBirth, dayOfBirth)
            )
        );

        require(playerIds[playerHash] == 0, "GameDB: Player already exists");

        Player memory player = Player({
            name: name,
            dayOfBirth: dayOfBirth,
            monthOfBirth: monthOfBirth,
            yearOfBirth: yearOfBirth
        });

        players.push(player);
        uint32 playerId = uint32(players.length);
        playerIds[playerHash] = playerId;

        emit PlayerAdded(playerId, name, yearOfBirth, monthOfBirth, dayOfBirth);

        return playerId;
    }
 
    function createClub(
        string calldata name,
        string calldata country,
        string calldata city,
        uint16 yearFounded
    ) external override  returns (uint16) {

    	require(hasRole(MINTER_ROLE, _msgSender()), "GameDB: must have minter role to mint");
        require(bytes(country).length > 0, "GameDB: Country is required");
        require(clubs.length < 65535, "GameDB: Too many clubs");

        uint256 clubHash = uint256(
            keccak256(abi.encodePacked(name, country, city, yearFounded))
        );

        require(clubIds[clubHash] == 0, "GameDB: Club already exists");

        Club memory club = Club({
            name: name,
            country: country,
            city: city,
            yearFounded: yearFounded
        });

        clubs.push(club);
        uint16 clubId = uint16(clubs.length);
        clubIds[clubHash] = clubId;

        emit ClubAdded(clubId, name, country, city, yearFounded);

        return clubId;
    }
 
    function getPlayer(uint32 playerId)
        external
        override
        view
        returns (
            string memory name,
            uint16 yearOfBirth,
            uint8 monthOfBirth,
            uint8 dayOfBirth
        )
    {

        require(playerId <= players.length, "GameDB: playerId out of range");
        Player storage p = players[playerId - 1];
        name = p.name;
        yearOfBirth = p.yearOfBirth;
        monthOfBirth = p.monthOfBirth;
        dayOfBirth = p.dayOfBirth;
    }
 
    function getClub(uint16 clubId)
        external
        override
        view
        returns (
            string memory name,
            string memory country,
            string memory city,
            uint16 yearFounded
        )
    {

        require(clubId <= clubs.length, "GameDB: clubId out of range");
        Club storage c = clubs[clubId - 1];
        name = c.name;
        country = c.country;
        city = c.city;
        yearFounded = c.yearFounded;
    }
  
    function playerExists(uint32 playerId) external override view returns(bool) {

        require(playerId <= players.length, "GameDB: playerId out of range");
        Player storage player = players[playerId-1];
        return player.yearOfBirth > 0;
    }
 
    function clubExists(uint16 clubId) external override view returns (bool) {

        return clubId <= clubs.length;
    }

    function setMinter (address minter) external override returns (bool) {
    	require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "GameDB: must have Admin role to set minter");
    	_setupRole (MINTER_ROLE, minter);
    	return true;
    }
}