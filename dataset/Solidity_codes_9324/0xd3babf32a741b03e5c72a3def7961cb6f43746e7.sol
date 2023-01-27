
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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
}// MIT
pragma solidity ^0.8.0;

interface IConfetti {

    function approve(address spender, uint256 amount) external returns (bool);


    function burnFrom(address account, uint256 amount) external;


    function mint(address recipient, uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;

interface IParty {

    function getDamage(address user) external view returns (uint32);


    function getUserHero(address user) external view returns (uint256);

}// MIT
pragma solidity ^0.8.0;

interface IRpSeeder {

    function getBatch() external view returns (uint256);


    function getReqByBatch(uint256 batch) external view returns (bytes32);


    function getNextAvailableBatch() external view returns (uint256);


    function getRandomness(bytes32 key) external view returns (uint256);


    function executeRequestMulti() external;

}// MIT
pragma solidity ^0.8.0;



contract RaffleParty is Context, Pausable, AccessControlEnumerable {

    using Strings for uint256;

    IConfetti public immutable _confetti;
    IParty public immutable _party;
    IRpSeeder public immutable _rpSeeder;

    Raffle[] public _raffles;

    string private _baseRaffleURI;

    bytes32 public constant RAFFLE_CREATOR_ROLE =
        keccak256("RAFFLE_CREATOR_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event RaffleCreated(uint256 indexed raffleId, address indexed creator);

    struct Raffle {
        uint128 cost;
        uint32 endingSeedRound;
        uint32 winnerCount;
        uint32 maxEntries;
        uint32 totalTicketsBought;
        mapping(address => uint32) ticketsBought;
        address[] participants;
    }

    constructor(
        address confetti,
        address party,
        address rpSeeder,
        address admin,
        string memory baseRaffleURI
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);

        _setupRole(RAFFLE_CREATOR_ROLE, admin);
        _setupRole(PAUSER_ROLE, admin);

        _party = IParty(party);
        _confetti = IConfetti(confetti);
        _rpSeeder = IRpSeeder(rpSeeder);
        _baseRaffleURI = baseRaffleURI;
    }

    function createRaffle(
        uint32 endingSeedRound,
        uint128 cost,
        uint32 maxEntries,
        uint32 winnerCount
    )
        public
        whenNotPaused
    {

        require(getSeed(endingSeedRound) == 0, "Raffle finished");
        require(
            endingSeedRound > _rpSeeder.getBatch() ||
                _rpSeeder.getNextAvailableBatch() > (block.timestamp + 60),
            "Not enough time before next seed"
        );

        Raffle storage newRaffle = _raffles.push();
        newRaffle.maxEntries = maxEntries == 0 ? type(uint32).max : maxEntries;
        newRaffle.cost = cost;
        newRaffle.endingSeedRound = endingSeedRound;
        newRaffle.winnerCount = winnerCount;

        emit RaffleCreated(_raffles.length - 1, _msgSender());
    }

    function setRaffleEndingSeed(uint256 raffleId, uint32 endingSeedRound)
        public
        whenNotPaused
    {

        require(getSeed(endingSeedRound) == 0, "Raffle finished");
        require(
            endingSeedRound > _rpSeeder.getBatch() ||
                _rpSeeder.getNextAvailableBatch() > (block.timestamp + 60),
            "Not enough time before next seed"
        );

        getRaffleSafe(raffleId).endingSeedRound = endingSeedRound;
    }

    function buyTickets(uint256 raffleId, uint32 count) public whenNotPaused {

        require(count > 0, "Need to buy at least 1 ticket");
        Raffle storage raffle = getRaffleSafe(raffleId);
        require(getSeed(raffle.endingSeedRound) == 0, "Raffle finished");
        require(
            raffle.endingSeedRound > _rpSeeder.getBatch() ||
                _rpSeeder.getNextAvailableBatch() > (block.timestamp + 60),
            "Not enough time before next seed"
        );
        require(_party.getUserHero(_msgSender()) != 0, "No hero staked");

        uint32 ticketsLeft = raffle.maxEntries - raffle.totalTicketsBought;
        require(ticketsLeft > 0, "Sold out");
        uint32 ticketCount = count > ticketsLeft ? ticketsLeft : count;

        uint256 cost = ticketCount * raffle.cost;
        if (cost > 0) {
            _confetti.burnFrom(_msgSender(), cost);
        }
        if (raffle.ticketsBought[_msgSender()] == 0) {
            raffle.participants.push(_msgSender());
        }
        unchecked {
            raffle.ticketsBought[_msgSender()] += ticketCount;
            raffle.totalTicketsBought += ticketCount;
        }
    }

    function raffleWinners(uint256 raffleId)
        public
        view
        returns (address[] memory)
    {

        Raffle storage raffle = getRaffleSafe(raffleId);
        uint256 seed = getSeed(raffle.endingSeedRound);
        require(seed != 0, "Raffle not finished");

        address[] memory tickets = new address[](raffle.totalTicketsBought);
        uint256 ticketsAssigned = 0;
        unchecked {
            for (uint256 i = 0; i < raffle.participants.length; i++) {
                address participant = raffle.participants[i];

                uint256 ticketsBought = raffle.ticketsBought[participant];
                for (uint256 j = 0; j < ticketsBought; j++) {
                    tickets[ticketsAssigned + j] = participant;
                }
                ticketsAssigned += ticketsBought;
            }
        }

        return shuffledAddresses(tickets, seed);
    }

    function setBaseRaffleURI(string memory uri) external {

        _baseRaffleURI = uri;
    }

    function raffleURI(uint256 raffleId) external view returns (string memory) {

        getRaffleSafe(raffleId);

        return
            bytes(_baseRaffleURI).length > 0
                ? string(abi.encodePacked(_baseRaffleURI, raffleId.toString()))
                : "";
    }

    function pause() external onlyRole(PAUSER_ROLE) whenNotPaused {

        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) whenPaused {

        _unpause();
    }


    function getRaffleSafe(uint256 raffleId)
        private
        view
        returns (Raffle storage)
    {

        require(raffleId < _raffles.length, "Raffle doesn't exist");
        return _raffles[raffleId];
    }

    function getRaffleCount() public view returns (uint256) {

        return _raffles.length;
    }

    function getRaffleParticipants(uint256 raffleId)
        public
        view
        returns (address[] memory)
    {

        return getRaffleSafe(raffleId).participants;
    }

    function getRaffleParticipantsPaged(
        uint256 raffleId,
        uint32 skipPages,
        uint32 pageSize
    ) public view returns (address[] memory) {

        address[] memory participants = getRaffleSafe(raffleId).participants;

        if (pageSize == 0) {
            return participants;
        } else {
            uint256 start = Math.min(skipPages * pageSize, participants.length);
            uint256 end = Math.min(start + pageSize, participants.length);
            address[] memory returned = new address[](end - start);
            unchecked {
                for (uint256 i = 0; i < returned.length; i++) {
                    returned[i] = participants[start + i];
                }
            }
            return returned;
        }
    }

    function getRaffleView(uint256 raffleId)
        public
        view
        returns (
            uint128 cost,
            uint32 endingSeedRound,
            uint32 maxEntries,
            uint32 winnerCount,
            uint32 totalTicketsBought
        )
    {

        Raffle storage raffle = getRaffleSafe(raffleId);
        return (
            raffle.cost,
            raffle.endingSeedRound,
            raffle.maxEntries,
            raffle.winnerCount,
            raffle.totalTicketsBought
        );
    }

    function getUserTicketsBought(uint256 raffleId, address user)
        public
        view
        returns (uint256)
    {

        return getRaffleSafe(raffleId).ticketsBought[user];
    }


    function getSeed(uint256 roundNum) public view returns (uint256) {

        bytes32 reqId = _rpSeeder.getReqByBatch(roundNum);
        return _rpSeeder.getRandomness(reqId);
    }

    function shuffledAddresses(address[] memory addresses, uint256 seed)
        public
        pure
        returns (address[] memory)
    {

        address[] memory shuffled = addresses;

        uint256 pick;
        for (uint256 i = 0; i < addresses.length - 1; i++) {
            pick =
                uint256(keccak256(abi.encodePacked(i, addresses[i], seed))) %
                (addresses.length - i);

            (shuffled[i], shuffled[i + pick]) = (
                shuffled[i + pick],
                shuffled[i]
            );
        }

        return shuffled;
    }
}