



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.8.0;

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}


pragma solidity ^0.8.0;

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}


pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}


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
}


pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}


pragma solidity ^0.8.0;

interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}


pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.8.0;

library StringsUpgradeable {

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
}


pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.8.0;

abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {}

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.8.0;

abstract contract AccessControlUpgradeable is
    Initializable,
    ContextUpgradeable,
    IAccessControlUpgradeable,
    ERC165Upgradeable
{
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {}

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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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

    uint256[49] private __gap;
}


pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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
}


pragma solidity ^0.8.0;

abstract contract AccessControlEnumerableUpgradeable is
    Initializable,
    IAccessControlEnumerableUpgradeable,
    AccessControlUpgradeable
{
    function __AccessControlEnumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal initializer {}

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account)
        public
        virtual
        override(AccessControlUpgradeable, IAccessControlUpgradeable)
    {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account)
        public
        virtual
        override(AccessControlUpgradeable, IAccessControlUpgradeable)
    {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account)
        public
        virtual
        override(AccessControlUpgradeable, IAccessControlUpgradeable)
    {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }

    uint256[49] private __gap;
}


pragma solidity ^0.8.0;

abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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

    uint256[49] private __gap;
}


pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}


pragma solidity 0.8.9;
pragma abicoder v2;

uint8 constant STATUS_CREATED = 0;
uint8 constant STATUS_FINALIZED = 1;

struct Race {
    uint256 id;
    uint256 createBlock;
    uint256 startBlock;
    uint256 maxLevel;
    uint16 version;
    uint8 status;
}

struct RaceInfo {
    Race race;
    uint256[] racers;
}

struct RacerPosition {
    uint256 racer;
    uint256 position;
}

interface IBoneyard {

    function token() external view returns (IERC721Enumerable);


    function raceData(uint256 raceId) external view returns (RaceInfo memory);


    function raceResults(uint256 raceId) external view returns (RacerPosition[] memory);


    function levelOf(uint256 tokenId) external view returns (uint256);


    function xpOf(uint256 tokenId) external view returns (uint256);


    function joinBoneyard(uint256 tokenId) external;


    function joinBoneyardMulti(uint256[] calldata tokenIds) external;


    function leaveBoneyard(uint256 tokenId) external;


    function leaveBoneyardMulti(uint256[] calldata tokenIds) external;


    function createRace(uint256 tokenId, uint256 maxLevel) external returns (uint256);


    function joinRace(uint256 raceId, uint256 tokenId) external;


    function finalizeRace(uint256 raceId) external;


    function calcRacePositions(uint256 raceId, uint256 blocks) external view returns (RacerPosition[] memory);


    function isRaceValid(uint256 raceId) external view returns (bool);


    function isRacePending(uint256 raceId) external view returns (bool);


    function isRaceLive(uint256 raceId) external view returns (bool);


    function isRaceFinished(uint256 raceId) external view returns (bool);


    function isRaceFinalizable(uint256 raceId) external view returns (bool);


    function isRaceFinalized(uint256 raceId) external view returns (bool);


    function isRaceExpired(uint256 raceId) external view returns (bool);


    function isParticipating(uint256 tokenId) external view returns (bool);

}


pragma solidity 0.8.9;

error NotInitialized();
error AccessDenied();
error InvalidAddress();
error InvalidRace();
error InvalidArgument();
error AlreadyExists();
error TooManyRacers();
error LevelTooHigh();
error AlreadyRacing();
error NotRacing();

contract Boneyard is
    IBoneyard,
    Initializable,
    AccessControlEnumerableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint8 public constant VERSION = 1;

    uint8 public constant MAX_RACERS = 7;

    uint16 public constant PENDING_BLOCKS = 600;

    uint8 public constant RACING_BLOCKS = 60;

    uint8 public constant MAX_FINALIZATION_BLOCKS = 255 - RACING_BLOCKS + 1;

    uint256 public constant MAX_DISTANCE_PER_BLOCK = 20;

    uint8 public constant DISTANCE_BONUS = 1;

    uint8 public constant LEVELS_PER_BONUS_POINT = 1;

    uint256 public constant XP_PER_LEVEL = 1000;

    uint256 public constant XP_BASE_GAIN = 50;

    uint256 public constant LEVEL_DIFF_XP_BONUS = 25;

    IERC721Enumerable private immutable _token;

    uint256 internal _nextRaceId;

    mapping(uint256 => Race) private _races;

    mapping(uint256 => EnumerableSetUpgradeable.UintSet) private _racers;

    mapping(uint256 => address) internal _owners;

    mapping(uint256 => uint256) internal _racing;

    mapping(uint256 => uint256) internal _xp;

    mapping(uint256 => RacerPosition[]) private _results;

    uint256[50 - 7] private __gap;

    event BoneyardJoined(address indexed racer, uint256 indexed racerTokenId);

    event BoneyardLeft(address indexed racer, uint256 indexed racerTokenId);

    event RaceCreated(
        uint256 indexed raceId,
        address indexed host,
        uint256 indexed hostTokenId,
        uint256 createBlock,
        uint256 maxLevel
    );

    event RaceJoined(uint256 indexed raceId, address indexed racer, uint256 indexed racerTokenId);

    event RaceFinalized(uint256 indexed raceId, uint256 indexed winnerTokenId);

    modifier whenInitialized() {

        _verifyInitialized();

        _;
    }

    modifier onlyAdmin() {

        _hasRole(ADMIN_ROLE, msg.sender);

        _;
    }

    modifier onlyRacer(uint256 tokenId) {

        _verifyRacer(tokenId);

        _;
    }

    modifier whenRacing(uint256 tokenId) {

        _verifyParticipation(tokenId, true);

        _;
    }

    modifier whenNotRacing(uint256 tokenId) {

        _verifyParticipation(tokenId, false);

        _;
    }

    constructor(IERC721Enumerable initToken) {
        if (address(initToken) == address(0)) {
            revert InvalidAddress();
        }

        _token = initToken;
    }

    function initialize() external initializer {

        __Boneyard_init();
    }


    function __Boneyard_init() internal initializer {

        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        __Boneyard_init_unchained();
    }

    function __Boneyard_init_unchained() internal initializer {

        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, msg.sender);

        _nextRaceId = 1;
    }


    function token() external view returns (IERC721Enumerable) {

        return _token;
    }

    function raceData(uint256 raceId) external view returns (RaceInfo memory) {

        return RaceInfo({ race: _races[raceId], racers: _racers[raceId].values() });
    }

    function raceResults(uint256 raceId) external view returns (RacerPosition[] memory) {

        return _results[raceId];
    }

    function levelOf(uint256 tokenId) external view returns (uint256) {

        return _levelOf(tokenId);
    }

    function xpOf(uint256 tokenId) external view returns (uint256) {

        return _xp[tokenId];
    }

    function joinBoneyard(uint256 tokenId) external whenInitialized whenNotPaused {

        _joinBoneyard(msg.sender, tokenId);
    }

    function joinBoneyardMulti(uint256[] calldata tokenIds) external whenInitialized whenNotPaused {

        uint256 length = tokenIds.length;

        unchecked {
            for (uint256 i = 0; i < length; ++i) {
                _joinBoneyard(msg.sender, tokenIds[i]);
            }
        }
    }

    function leaveBoneyard(uint256 tokenId) external whenNotRacing(tokenId) {

        _leaveBoneyard(msg.sender, tokenId);
    }

    function leaveBoneyardMulti(uint256[] calldata tokenIds) external {

        uint256 length = tokenIds.length;

        unchecked {
            for (uint256 i = 0; i < length; ++i) {
                uint256 tokenId = tokenIds[i];

                _verifyParticipation(tokenId, false);
                _leaveBoneyard(msg.sender, tokenId);
            }
        }
    }

    function createRace(uint256 tokenId, uint256 maxLevel)
        external
        virtual
        nonReentrant
        whenNotRacing(tokenId)
        whenNotPaused
        returns (uint256)
    {

        if (_levelOf(tokenId) > maxLevel) {
            revert LevelTooHigh();
        }

        uint256 raceId = _nextRaceId;
        unchecked {
            ++_nextRaceId;
        }

        Race memory race = Race({
            id: raceId,
            version: VERSION,
            createBlock: block.number,
            startBlock: block.number + PENDING_BLOCKS - 1,
            maxLevel: maxLevel,
            status: STATUS_CREATED
        });

        _races[raceId] = race;

        _racers[raceId].add(tokenId);
        _racing[tokenId] = raceId;

        emit RaceCreated({
            raceId: raceId,
            host: msg.sender,
            hostTokenId: tokenId,
            createBlock: block.number,
            maxLevel: maxLevel
        });

        return raceId;
    }

    function joinRace(uint256 raceId, uint256 tokenId) external nonReentrant whenNotPaused whenNotRacing(tokenId) {

        Race memory race = _races[raceId];

        if (!_isRacePending(race)) {
            revert InvalidRace();
        }

        if (_levelOf(tokenId) > race.maxLevel) {
            revert LevelTooHigh();
        }

        EnumerableSetUpgradeable.UintSet storage racers = _racers[raceId];
        uint256 newRacersCount = racers.length() + 1;
        unchecked {
            if (newRacersCount > MAX_RACERS) {
                revert TooManyRacers();
            }

            if (newRacersCount == MAX_RACERS) {
                _races[raceId].startBlock = block.number;
            }
        }

        if (!racers.add(tokenId)) {
            revert AlreadyExists();
        }

        _racing[tokenId] = raceId;

        emit RaceJoined({ raceId: raceId, racer: msg.sender, racerTokenId: tokenId });
    }

    function finalizeRace(uint256 raceId) external nonReentrant whenNotPaused {

        Race memory race = _races[raceId];

        if (!_isRaceFinalizable(race)) {
            revert InvalidRace();
        }

        uint256[] memory positions = _calcRacePositions(race, RACING_BLOCKS);

        uint256[] memory racers = _racers[race.id].values();
        assert(positions.length == racers.length);
        uint256[] memory levels = new uint256[](racers.length);
        unchecked {
            for (uint256 i = 0; i < racers.length; ++i) {
                levels[i] = _levelOf(racers[i]);
            }
        }

        uint256[] memory indexes = new uint256[](racers.length);
        _sortWithIndexes(positions, indexes);

        unchecked {
            for (uint256 i = 1; i < positions.length; ++i) {
                uint256 position = positions[i];
                uint256 winnerIndex = indexes[i];
                uint256 winnerRacerId = racers[winnerIndex];

                uint256 gain = 0;
                for (uint256 j = 0; j < i; ++j) {
                    if (position == positions[j]) {
                        continue;
                    }

                    uint256 loserIndex = indexes[j];
                    uint256 winnerLevel = levels[winnerIndex];
                    uint256 loserLevel = levels[loserIndex];

                    gain +=
                        XP_BASE_GAIN +
                        (loserLevel > winnerLevel ? (loserLevel - winnerLevel) * LEVEL_DIFF_XP_BONUS : 0);
                }

                _xp[winnerRacerId] += gain;
            }
        }

        for (uint256 i = 0; i < racers.length; ++i) {
            delete _racing[racers[i]];
        }

        _races[raceId].status = STATUS_FINALIZED;

        RacerPosition[] storage racePositions = _results[raceId];
        unchecked {
            for (uint256 i = 0; i < positions.length; ++i) {
                racePositions.push(RacerPosition({ racer: racers[indexes[i]], position: positions[i] }));
            }
        }

        emit RaceFinalized({ raceId: raceId, winnerTokenId: racers[indexes[indexes.length - 1]] });
    }

    function calcRacePositions(uint256 raceId, uint256 blocks) external view returns (RacerPosition[] memory) {

        Race memory race = _races[raceId];

        if (!_isRaceValid(race)) {
            revert InvalidRace();
        }

        if (blocks == 0) {
            revert InvalidArgument();
        }

        uint256[] memory positions = _calcRacePositions(race, blocks);
        uint256[] memory racers = _racers[race.id].values();
        assert(positions.length == racers.length);

        RacerPosition[] memory racerPositions = new RacerPosition[](racers.length);
        unchecked {
            for (uint256 i = 0; i < racerPositions.length; ++i) {
                racerPositions[i] = RacerPosition({ racer: racers[i], position: positions[i] });
            }
        }

        return racerPositions;
    }

    function isRaceValid(uint256 raceId) external view returns (bool) {

        return _isRaceValid(_races[raceId]);
    }

    function isRacePending(uint256 raceId) external view returns (bool) {

        return _isRacePending(_races[raceId]);
    }

    function isRaceLive(uint256 raceId) external view returns (bool) {

        Race memory race = _races[raceId];
        return _isRaceLive(race) && !_isRaceExpired(race);
    }

    function isRaceFinished(uint256 raceId) external view returns (bool) {

        return _isRaceFinished(_races[raceId]);
    }

    function isRaceFinalizable(uint256 raceId) external view returns (bool) {

        return _isRaceFinalizable(_races[raceId]);
    }

    function isRaceFinalized(uint256 raceId) external view returns (bool) {

        return _isRaceStatusFinalized(_races[raceId]);
    }

    function isRaceExpired(uint256 raceId) external view returns (bool) {

        return _isRaceExpired(_races[raceId]);
    }

    function isParticipating(uint256 tokenId) external view returns (bool) {

        return _isParticipating(tokenId);
    }

    function pause() external onlyAdmin {

        _pause();
    }

    function unpause() external onlyAdmin {

        _unpause();
    }

    function _joinBoneyard(address racer, uint256 tokenId) private {

        _lockRacer(racer, tokenId);

        emit BoneyardJoined({ racer: racer, racerTokenId: tokenId });
    }

    function _leaveBoneyard(address racer, uint256 tokenId) private {

        _unlockRacer(tokenId);

        emit BoneyardLeft({ racer: racer, racerTokenId: tokenId });
    }

    function _calcRacePositions(Race memory race, uint256 blocks) private view returns (uint256[] memory) {

        uint256[] memory racers = _racers[race.id].values();

        uint256[] memory levelBonuses = new uint256[](racers.length);
        unchecked {
            for (uint256 i = 0; i < racers.length; ++i) {
                levelBonuses[i] = DISTANCE_BONUS * (((_levelOf(racers[i]) - 1) / LEVELS_PER_BONUS_POINT) + 1);
            }
        }

        uint256[] memory positions = new uint256[](racers.length);
        bytes32 digest = bytes32(0);

        unchecked {
            uint256 fromBlock = race.startBlock;
            uint256 toBlock = fromBlock + Math.min(RACING_BLOCKS, blocks) - 1;

            for (uint256 blockNumber = fromBlock; blockNumber <= toBlock; ++blockNumber) {
                digest = keccak256(abi.encodePacked(digest, _blockhash(blockNumber)));

                for (uint256 i = 0; i < racers.length; ++i) {
                    uint256 rand = uint256(keccak256(abi.encodePacked(digest, i)));

                    positions[i] += (rand % (MAX_DISTANCE_PER_BLOCK + 1)) + levelBonuses[i];
                }
            }
        }

        return positions;
    }

    function _isRaceValid(Race memory race) private pure returns (bool) {

        return race.id != 0;
    }

    function _isRacePending(Race memory race) private view returns (bool) {

        if (!_isRaceValid(race)) {
            return false;
        }

        return block.number < race.startBlock;
    }

    function _isRaceLive(Race memory race) private view returns (bool) {

        if (!_isRaceValid(race)) {
            return false;
        }

        unchecked {
            uint256 currentBlock = block.number;
            uint256 finishBlock = race.startBlock + RACING_BLOCKS - 1;

            return race.startBlock <= currentBlock && currentBlock <= finishBlock;
        }
    }

    function _isRaceFinished(Race memory race) private view returns (bool) {

        if (!_isRaceValid(race)) {
            return false;
        }

        unchecked {
            uint256 finishBlock = race.startBlock + RACING_BLOCKS - 1;

            return finishBlock < block.number;
        }
    }

    function _isRaceFinalizable(Race memory race) private view returns (bool) {

        if (_isRaceStatusFinalized(race) || !_isRaceFinished(race) || _isRaceExpired(race)) {
            return false;
        }

        unchecked {
            uint256 finishBlock = race.startBlock + RACING_BLOCKS - 1;

            return finishBlock < block.number;
        }
    }

    function _isRaceTimeExpired(Race memory race) private view returns (bool) {

        unchecked {
            uint256 finishBlock = race.startBlock + RACING_BLOCKS - 1;

            return block.number > finishBlock + MAX_FINALIZATION_BLOCKS - 1;
        }
    }

    function _isRaceStatusFinalized(Race memory race) private pure returns (bool) {

        return race.status == STATUS_FINALIZED;
    }

    function _isRaceExpired(Race memory race) private view returns (bool) {

        if (!_isRaceValid(race) || _isRaceStatusFinalized(race)) {
            return true;
        }

        if (_isRacePending(race)) {
            return false;
        }

        if (_isRaceTimeExpired(race)) {
            return true;
        }

        uint256 racersCount = _racers[race.id].length();

        return race.startBlock <= block.number && racersCount == 1;
    }

    function _isParticipating(uint256 tokenId) private view returns (bool) {

        uint256 raceId = _racing[tokenId];
        return raceId != 0 && !_isRaceExpired(_races[raceId]);
    }

    function _sortWithIndexes(uint256[] memory list, uint256[] memory indexes) internal pure {

        unchecked {
            uint256 length = list.length;
            for (uint256 i = 0; i < length; i++) {
                indexes[i] = i;
            }

            for (uint256 i = 1; i < length; i++) {
                uint256 key = list[i];
                uint256 j = i - 1;
                while ((int256(j) >= 0) && (list[j] > key)) {
                    list[j + 1] = list[j];
                    indexes[j + 1] = indexes[j];

                    j--;
                }

                list[j + 1] = key;
                indexes[j + 1] = i;
            }
        }
    }

    function _levelOf(uint256 tokenId) private view returns (uint256) {

        unchecked {
            return _xp[tokenId] / XP_PER_LEVEL + 1;
        }
    }

    function _lockRacer(address owner, uint256 tokenId) private {

        _owners[tokenId] = owner;

        _token.transferFrom(owner, address(this), tokenId);
    }

    function _unlockRacer(uint256 tokenId) private {

        address owner = _owners[tokenId];
        delete _owners[tokenId];

        _token.transferFrom(address(this), owner, tokenId);
    }

    function _hasRole(bytes32 role, address account) private view {

        if (!hasRole(role, account)) {
            revert AccessDenied();
        }
    }

    function _verifyRacer(uint256 tokenId) private view {

        if (_owners[tokenId] != msg.sender) {
            revert AccessDenied();
        }
    }

    function _verifyParticipation(uint256 tokenId, bool participating) private view {

        _verifyRacer(tokenId);

        if (_isParticipating(tokenId) != participating) {
            if (participating) {
                revert NotRacing();
            } else {
                revert AlreadyRacing();
            }
        }
    }

    function _isInitialized() private view returns (bool) {

        return _nextRaceId != 0;
    }

    function _verifyInitialized() private view {

        if (!_isInitialized()) {
            revert NotInitialized();
        }
    }

    function _blockhash(uint256 blockNumber) internal view virtual returns (bytes32) {

        return blockhash(blockNumber);
    }
}