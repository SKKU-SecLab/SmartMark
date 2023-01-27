
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

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

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT
pragma solidity ^0.8.0;


interface IConfetti is IERC20 {

    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;

library Stats {

    struct HeroStats {
        uint8 dmgMultiplier;
        uint8 partySize;
        uint8 enhancement;
    }

    struct FighterStats {
        uint32 dmg;
        uint8 enhancement;
    }

    struct EquipmentStats {
        uint32 dmg;
        uint8 dmgMultiplier;
        uint8 slot;
    }
}// MIT
pragma solidity ^0.8.0;


interface IParty {

    event Equipped(address indexed user, uint8 item, uint8 slot, uint256 id);

    event Unequipped(address indexed user, uint8 item, uint8 slot, uint256 id);

    event DamageUpdated(address indexed user, uint32 damageCurr);

    struct PartyData {
        uint256 hero;
        mapping(uint256 => uint256) fighters;
    }

    struct Action {
        ActionType action;
        uint256 id;
        uint8 slot;
    }

    enum Property {
        HERO,
        FIGHTER
    }

    enum ActionType {
        UNEQUIP,
        EQUIP
    }

    function act(
        Action[] calldata heroActions,
        Action[] calldata fighterActions
    ) external;


    function equip(
        Property item,
        uint256 id,
        uint8 slot
    ) external;


    function unequip(Property item, uint8 slot) external;


    function enhance(
        Property item,
        uint8 slot,
        uint256 burnTokenId
    ) external;


    function getUserHero(address user) external view returns (uint256);


    function getUserFighters(address user)
        external
        view
        returns (uint256[] memory);


    function getDamage(address user) external view returns (uint32);

}// MIT
pragma solidity ^0.8.0;

interface IRaid {

    struct Round {
        uint16 boss;
        uint32 roll;
        uint32 startBlock;
        uint32 finalBlock;
    }

    struct Raider {
        uint32 dpb;
        uint32 startedAt;
        uint32 startBlock;
        uint32 startRound;
        uint32 startSnapshot;
        uint256 pendingRewards;
    }

    struct Boss {
        uint32 weight;
        uint32 blockHealth;
        uint128 multiplier;
    }

    struct Snapshot {
        uint32 initialBlock;
        uint32 initialRound;
        uint32 finalBlock;
        uint32 finalRound;
        uint256 attackDealt;
    }

    struct RaidData {
        uint16 boss;
        uint32 roundId;
        uint32 health;
        uint32 maxHealth;
        uint256 seed;
    }

    function updateDamage(address user, uint32 _dpb) external;

}// MIT
pragma solidity ^0.8.0;

library Randomness {

    struct SeedData {
        uint256 batch;
        bytes32 randomnessId;
    }
}// MIT
pragma solidity ^0.8.0;


interface ISeeder {

    event Requested(address indexed origin, uint256 indexed identifier);

    event Seeded(bytes32 identifier, uint256 randomness);

    function getIdReferenceCount(
        bytes32 randomnessId,
        address origin,
        uint256 startIdx
    ) external view returns (uint256);


    function getIdentifiers(
        bytes32 randomnessId,
        address origin,
        uint256 startIdx,
        uint256 count
    ) external view returns (uint256[] memory);


    function requestSeed(uint256 identifier) external;


    function getSeed(address origin, uint256 identifier)
        external
        view
        returns (uint256);


    function getSeedSafe(address origin, uint256 identifier)
        external
        view
        returns (uint256);


    function executeRequestMulti() external;


    function isSeeded(address origin, uint256 identifier)
        external
        view
        returns (bool);


    function setFee(uint256 fee) external;


    function getFee() external view returns (uint256);


    function getData(address origin, uint256 identifier)
        external
        view
        returns (Randomness.SeedData memory);

}// MIT
pragma solidity 0.8.13;




error RaidHalted();

error RaidStarted();

error RaidNotStarted();

error RaidNotSeeded();

error MissingBosses();

error InvalidState();

error InvalidWeightTotal();

error InvalidBoss(uint32 bossId, uint32 amount);

error InvalidCaller(address caller, address expected);

error SnapshotTooRecent(uint64 currentTime, uint64 earliestTime);

contract Raid is IRaid, Initializable, AccessControlUpgradeable {

    bool public started;
    bool public halted;
    bool public bossesCreated;

    uint32 private roundId;
    uint32 public weightTotal;
    uint64 public lastSnapshotTime;
    uint64 private constant PRECISION = 1e18;

    uint256 public seed;
    uint256 public seedId;

    IParty public party;
    ISeeder public seeder;
    IConfetti public confetti;

    Boss[] public bosses;
    Snapshot[] public snapshots;

    mapping(uint32 => Round) public rounds;
    mapping(address => Raider) public raiders;

    event HaltUpdated(bool isHalted);

    modifier notHalted() {

        if (halted) revert RaidHalted();
        _;
    }

    modifier raidActive() {

        if (!started) revert RaidNotStarted();
        _;
    }

    modifier partyCaller() {

        address partyAddress = address(party);
        if (msg.sender != partyAddress)
            revert InvalidCaller({caller: msg.sender, expected: partyAddress});
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        IParty _party,
        ISeeder _seeder,
        IConfetti _confetti
    ) external initializer {

        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, admin);

        party = _party;
        seeder = _seeder;
        confetti = _confetti;
    }

    function setParty(IParty _party) external onlyRole(DEFAULT_ADMIN_ROLE) {

        party = _party;
    }

    function setSeeder(ISeeder _seeder) external onlyRole(DEFAULT_ADMIN_ROLE) {

        seeder = _seeder;
    }

    function setHalted(bool _halted) external onlyRole(DEFAULT_ADMIN_ROLE) {

        halted = _halted;

        emit HaltUpdated(_halted);
    }

    function updateSeed() external onlyRole(DEFAULT_ADMIN_ROLE) {

        if (started) {
            _syncRounds(uint32(block.number));
        }

        seed = seeder.getSeedSafe(address(this), seedId);
    }

    function requestSeed() external onlyRole(DEFAULT_ADMIN_ROLE) {

        seedId += 1;
        seeder.requestSeed(seedId);
    }

    function createBosses(Boss[] calldata _bosses)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        delete bosses;
        delete weightTotal;

        for (uint256 i; i < _bosses.length; i++) {
            Boss calldata boss = _bosses[i];
            weightTotal += boss.weight;
            bosses.push(boss);
        }

        bossesCreated = true;
    }

    function updateBoss(uint32 id, Boss calldata boss)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        if (!(bosses.length > id)) {
            revert InvalidBoss({bossId: id, amount: uint32(bosses.length)});
        }

        if (started) {
            _syncRounds(uint32(block.number));
        }

        weightTotal -= bosses[id].weight;
        weightTotal += boss.weight;
        bosses[id] = boss;

        if (weightTotal == 0) revert InvalidWeightTotal();
    }

    function appendBoss(Boss calldata boss)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        if (started) {
            _syncRounds(uint32(block.number));
        }

        weightTotal += boss.weight;
        bosses.push(boss);
    }

    function manualSync() external {

        _syncRounds(uint32(block.number));
    }

    function start() external onlyRole(DEFAULT_ADMIN_ROLE) {

        if (started) revert RaidStarted();
        if (!bossesCreated) revert MissingBosses();
        if (weightTotal == 0) revert InvalidWeightTotal();
        if (seedId == 0) revert RaidNotSeeded();

        seed = seeder.getSeedSafe(address(this), seedId);
        rounds[roundId] = _rollRound(seed, uint32(block.number));

        started = true;
        lastSnapshotTime = uint64(block.timestamp);
    }

    function commitSnapshot() external raidActive {

        if (lastSnapshotTime + 23 hours > block.timestamp) {
            revert SnapshotTooRecent({
                currentTime: uint64(block.timestamp),
                earliestTime: lastSnapshotTime + 23 hours
            });
        }

        _syncRounds(uint32(block.number));

        Snapshot memory snapshot = _createSnapshot();
        snapshots.push(snapshot);

        lastSnapshotTime = uint64(block.timestamp);
    }

    function getRaidData() external view returns (RaidData memory data) {

        uint256 _seed = seed;
        uint32 _roundId = roundId;
        Round memory round = rounds[_roundId];
        while (block.number > round.finalBlock) {
            _roundId += 1;
            _seed = _rollSeed(_seed);
            round = _rollRound(_seed, round.finalBlock + 1);
        }

        data.boss = round.boss;
        data.roundId = _roundId;
        data.health = uint32(round.finalBlock - block.number);
        data.maxHealth = bosses[round.boss].blockHealth;
        data.seed = _seed;
    }

    function getPendingRewards(address user) external view returns (uint256) {

        Raider memory raider = raiders[user];
        (, uint256 rewards) = _fetchRewards(raider);
        return rewards + raider.pendingRewards;
    }

    function updateDamage(address user, uint32 _dpb)
        external
        notHalted
        raidActive
        partyCaller
    {

        Raider storage raider = raiders[user];
        uint32 blockNumber = uint32(block.number);

        if (raider.startedAt > 0) {
            (uint32 _roundId, uint256 rewards) = _fetchRewards(raider);
            raider.startRound = _roundId;
            raider.pendingRewards += rewards;
        } else {
            raider.startedAt = blockNumber;
            raider.startRound = _lazyFetchRoundId();
        }

        raider.dpb = _dpb;
        raider.startBlock = blockNumber;
        raider.startSnapshot = uint32(snapshots.length + 1);
    }

    function claimRewards(address user) external notHalted {

        Raider storage raider = raiders[user];

        (uint32 _roundId, uint256 rewards) = _fetchRewards(raider);
        rewards += raider.pendingRewards;

        raider.startRound = _roundId;
        raider.pendingRewards = 0;
        raider.startBlock = uint32(block.number);
        raider.startSnapshot = uint32(snapshots.length + 1);

        if (rewards > 0) {
            confetti.mint(user, rewards);
        }
    }

    function fixInternalState(address user) external {

        uint32 _roundId = roundId;
        uint256 _seed = seed;
        Round memory round = rounds[_roundId];
        Raider storage raider = raiders[user];

        unchecked {
            if (raider.startBlock > round.finalBlock) {
                while (raider.startBlock > round.finalBlock) {
                    _roundId += 1;
                    _seed = _rollSeed(_seed);
                    round = _rollRound(_seed, round.finalBlock + 1);
                }
            } else if (raider.startBlock < round.startBlock) {
                while (raider.startBlock < round.startBlock) {
                    _roundId -= 1;
                    round = rounds[_roundId];
                }
            }
        }

        raider.startRound = _roundId;
    }


    function _rollSeed(uint256 oldSeed) internal pure returns (uint256 rolled) {

        assembly {
            mstore(0x00, oldSeed)
            rolled := keccak256(0x00, 0x20)
        }
    }

    function _rollRound(uint256 _seed, uint32 startBlock)
        internal
        view
        returns (Round memory round)
    {

        unchecked {
            uint32 roll = uint32(_seed % weightTotal);
            uint256 weight = 0;
            uint32 _bossWeight;

            for (uint16 bossId; bossId < bosses.length; bossId++) {
                _bossWeight = bosses[bossId].weight;

                if (roll <= weight + _bossWeight) {
                    round.boss = bossId;
                    round.roll = roll;
                    round.startBlock = startBlock;
                    round.finalBlock = startBlock + bosses[bossId].blockHealth;

                    return round;
                }

                weight += _bossWeight;
            }
        }
    }

    function _syncRounds(uint32 maxBlock) internal {

        unchecked {
            Round memory round = rounds[roundId];

            while (maxBlock > round.finalBlock) {
                roundId += 1;
                seed = _rollSeed(seed);
                round = _rollRound(seed, round.finalBlock + 1);
                rounds[roundId] = round;
            }
        }
    }

    function _createSnapshot()
        internal
        view
        returns (Snapshot memory snapshot)
    {

        uint32 _roundId;

        if (snapshots.length > 0) {
            _roundId = snapshots[snapshots.length - 1].finalRound + 1;
        }

        snapshot.initialRound = _roundId;
        snapshot.initialBlock = rounds[_roundId].startBlock;

        while (_roundId < roundId) {
            Round memory round = rounds[_roundId];
            Boss memory boss = bosses[round.boss];

            snapshot.attackDealt +=
                uint256(boss.blockHealth) *
                uint256(boss.multiplier);

            _roundId += 1;
        }

        snapshot.finalRound = _roundId - 1;
        snapshot.finalBlock = rounds[_roundId - 1].finalBlock;
    }

    function _fetchRewards(Raider memory raider)
        internal
        view
        returns (uint32 _roundId, uint256 rewards)
    {

        if (raider.dpb > 0) {
            if (snapshots.length > raider.startSnapshot) {
                (_roundId, rewards) = _fetchNewRewardsWithSnapshot(raider);
                return (_roundId, rewards);
            } else {
                (_roundId, rewards) = _fetchNewRewards(raider);
                return (_roundId, rewards);
            }
        }

        return (_lazyFetchRoundId(), 0);
    }

    function _fetchNewRewards(Raider memory raider)
        internal
        view
        returns (uint32 _roundId, uint256 rewards)
    {

        unchecked {
            Boss memory boss;
            Round memory round;

            uint256 _seed = seed;

            if (raider.startRound <= roundId) {
                _roundId = raider.startRound;
                for (_roundId; _roundId <= roundId; _roundId++) {
                    round = rounds[_roundId];
                    boss = bosses[round.boss];
                    rewards += _rewardCalculation(
                        raider,
                        round,
                        boss.multiplier
                    );
                }
                _roundId -= 1;
            } else {
                _roundId = roundId;
                round = rounds[_roundId];
            }

            while (block.number > round.finalBlock) {
                _roundId += 1;
                _seed = _rollSeed(_seed);
                round = _rollRound(_seed, round.finalBlock + 1);
                boss = bosses[round.boss];

                if (_roundId >= raider.startRound) {
                    rewards += _rewardCalculation(
                        raider,
                        round,
                        boss.multiplier
                    );
                }
            }
        }
    }

    function _fetchNewRewardsWithSnapshot(Raider memory raider)
        internal
        view
        returns (uint32 _roundId, uint256 rewards)
    {

        unchecked {
            Boss memory boss;
            Round memory round;

            _roundId = raider.startRound;
            uint256 _snapshotId = raider.startSnapshot;
            uint32 _lastRound = snapshots[_snapshotId].initialRound;

            for (_roundId; _roundId < _lastRound; _roundId++) {
                round = rounds[_roundId];
                boss = bosses[round.boss];
                rewards += _rewardCalculation(raider, round, boss.multiplier);
            }

            for (_snapshotId; _snapshotId < snapshots.length; _snapshotId++) {
                rewards += snapshots[_snapshotId].attackDealt * raider.dpb;
                _roundId = snapshots[_snapshotId].finalRound;
            }

            round = rounds[_roundId];

            while (_roundId < roundId) {
                _roundId += 1;
                round = rounds[_roundId];
                boss = bosses[round.boss];
                rewards += _rewardCalculation(raider, round, boss.multiplier);
            }

            uint256 _seed = seed;
            while (block.number > round.finalBlock) {
                _roundId += 1;
                _seed = _rollSeed(_seed);
                round = _rollRound(_seed, round.finalBlock + 1);
                boss = bosses[round.boss];
                rewards += _rewardCalculation(raider, round, boss.multiplier);
            }
        }
    }

    function _lazyFetchRoundId() internal view returns (uint32 _roundId) {

        unchecked {
            _roundId = roundId;
            Round memory round = rounds[_roundId];
            uint256 _seed = seed;
            while (block.number > round.finalBlock) {
                _roundId += 1;
                _seed = _rollSeed(_seed);
                round = _rollRound(_seed, round.finalBlock + 1);
            }
        }
    }

    function _rewardCalculation(
        Raider memory raider,
        Round memory round,
        uint256 bossMultiplier
    ) internal view returns (uint256 reward) {

        if (raider.startBlock > round.finalBlock) revert InvalidState();

        unchecked {
            uint256 blocksDefeated;

            if (
                round.startBlock >= raider.startBlock &&
                block.number >= round.finalBlock
            ) {
                blocksDefeated = round.finalBlock - round.startBlock;
            } else if (
                raider.startBlock > round.startBlock &&
                block.number >= round.finalBlock
            ) {
                blocksDefeated = round.finalBlock - raider.startBlock;
            } else if (
                round.finalBlock > raider.startBlock &&
                round.startBlock >= raider.startBlock
            ) {
                blocksDefeated = block.number - round.startBlock;
            } else if (
                raider.startBlock > round.startBlock &&
                round.finalBlock > block.number
            ) {
                blocksDefeated = block.number - raider.startBlock;
            }


            assembly {
                reward := div(
                    mul(
                        mul(
                            mul(1000000000000000000, blocksDefeated),
                            bossMultiplier
                        ),
                        and(
                            mload(raider),
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                        )
                    ),
                    1000000000000000000
                )
            }
        }
    }
}