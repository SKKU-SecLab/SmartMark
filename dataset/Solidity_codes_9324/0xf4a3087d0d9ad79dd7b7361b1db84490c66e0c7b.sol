
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
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}/// Unlicensed
pragma solidity 0.8.9;

library ConstantsAF {

    string public constant MINT_BEFORE_START = "Sale not started";
    string public constant INCORRECT_AMOUNT = "Incorrect amount sent";
    string public constant PURCHACE_TOO_MANY = "Quantity was greater than 20";
    string public constant NO_CHARACTERS = "No characters are available";
    string public constant INVALID_CHARACTER = "Non-existent character";
    string public constant MAIN_SALE_ENDED = "Main sale has ended";

    bytes32 public constant ROLE_MANAGER_ROLE = keccak256("ROLE_MANAGER_ROLE");

    bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");

    bytes32 public constant CONTRACT_ROLE = keccak256("CONTRACT_ROLE");
}/// Unlicensed

pragma solidity 0.8.9;

abstract contract AFRoles is AccessControlEnumerable {
    modifier onlyEditor() {
        require(
            hasRole(ConstantsAF.EDITOR_ROLE, msg.sender),
            "Caller is not an editor"
        );
        _;
    }

    modifier onlyContract() {
        require(
            hasRole(ConstantsAF.CONTRACT_ROLE, msg.sender),
            "Caller is not a contract"
        );
        _;
    }

    function setRole(bytes32 role, address user) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(ConstantsAF.ROLE_MANAGER_ROLE, msg.sender),
            "Caller is not admin nor role manager"
        );

        _setupRole(role, user);
    }
}/// Unlicensed
pragma solidity 0.8.9;

interface IAFCharacter {

    function takeRandomCharacter(uint256 randomNumber, uint256 totalRemaining) external returns (uint256);


    function getCharacterSupply(uint256 characterID)
        external
        view
        returns (uint256);

}/// Unlicensed

pragma solidity 0.8.9;



contract AFCharacter is AFRoles, IAFCharacter {

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    string public constant name = "AFCharacter";

    bytes32 private constant ARTIST = "Todd Wahnish";
    bytes32 private constant SERIES = "Season 1/Genesis";
    bytes32 private constant COLLECTION = "Adult Fantasy";

    uint256[] public availableCharacters = [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25
    ];

    struct Character {
        string name; /// The character name
        Rarities rarity; /// The rarity of the character
        uint256 scarcity; /// The total number tokens that can be minted of this character
        uint256 supply; /// The total number of times this character has been minted
        bytes32 artist; /// The name of the artist
        bytes32 series; // The name of the series
        bytes32 collection; // The name of the collection
    }

    enum Rarities {
        RARE1,
        RARE2,
        SUPERRARE1,
        SUPERRARE2,
        EPIC1,
        EPIC2,
        LEGENDARY1,
        LEGENDARY2,
        MYTHIC1,
        MYTHIC2
    }

    mapping(uint256 => Character) public allCharactersEver;

    function makeCharacters(
        string[] memory names,
        int8[] memory rarities,
        uint256[] memory scarcities
    ) external onlyEditor {

        for (uint256 index = 0; index < names.length; index++) {
            Character storage char = allCharactersEver[index + 1];
            char.name = names[index];
            char.rarity = Rarities(rarities[index]);
            char.scarcity = scarcities[index];
            char.supply = 0;
            char.artist = ARTIST;
            char.collection = COLLECTION;
            char.series = SERIES;
        }
    }

    function takeRandomCharacter(uint256 randomNumber, uint256 totalRemaining)
        external
        onlyContract
        returns (uint256)
    {

        uint256 arrayCount = availableCharacters.length;
        require(arrayCount > 0, ConstantsAF.NO_CHARACTERS);

        uint256 shorterRandomNumber = randomNumber % totalRemaining;
        uint256 characterID = 0;
        for (uint256 index = 0; index < arrayCount; index++) {
            uint256 currentCharacterID = availableCharacters[index];
            uint256 numberOfMintsLeft = allCharactersEver[currentCharacterID]
                .scarcity - allCharactersEver[currentCharacterID].supply;
            if (shorterRandomNumber < numberOfMintsLeft) {
                characterID = currentCharacterID;
                break;
            } else {
                shorterRandomNumber -= numberOfMintsLeft;
            }
        }
        require(
            bytes(allCharactersEver[characterID].name).length != 0,
            ConstantsAF.INVALID_CHARACTER
        );

        incrementCharacterSupply(characterID);
        delete arrayCount;
        delete shorterRandomNumber;
        return characterID;
    }

    function getCharacter(uint256 characterID)
        external
        view
        returns (Character memory)
    {

        return allCharactersEver[characterID];
    }

    function getCharacterSupply(uint256 characterID)
        external
        view
        returns (uint256)
    {

        return allCharactersEver[characterID].supply;
    }

    function incrementCharacterSupply(uint256 characterID) private {

        allCharactersEver[characterID].supply += 1;

        if (
            allCharactersEver[characterID].supply ==
            allCharactersEver[characterID].scarcity
        ) {
            removeCharacterFromAvailableCharacters(characterID);
        }
    }

    function removeCharacterFromAvailableCharacters(uint256 characterID)
        private
    {

        uint256 arrayCount = availableCharacters.length;
        uint256 index = 0;
        for (index; index < arrayCount; index++) {
            if (availableCharacters[index] == characterID) {
                break;
            }
        }
        availableCharacters[index] = availableCharacters[
            availableCharacters.length - 1
        ];
        availableCharacters.pop();
        delete arrayCount;
        delete index;
    }
}