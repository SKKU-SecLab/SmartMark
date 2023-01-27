
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

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
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
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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

}//MIT
pragma solidity ^0.8.0;


interface IUninterestedUnicorns is IERC721 {

    function mint(uint256 _quantity) external payable;


    function getPrice(uint256 _quantity) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function lockTokens(uint8[] memory tokenId) external;


    function unlockTokens(uint8[] memory tokenId) external;

}//MIT
pragma solidity ^0.8.0;


interface ICandyToken is IERC20 {

    function updateRewardOnMint(address _user, uint256 _amount) external;


    function updateReward(address _from, address _to) external;


    function getReward(address _to) external;


    function burn(address _from, uint256 _amount) external;


    function mint(address to, uint256 amount) external;


    function getTotalClaimable(address _user) external view returns (uint256);

}//MIT
pragma solidity ^0.8.0;



contract UniQuest is
    AccessControlUpgradeable,
    ERC721HolderUpgradeable,
    ReentrancyGuardUpgradeable
{

    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Quest {
        address questOwner;
        uint256 questLevel;
        uint256 questStart;
        uint256 questEnd;
        uint256 lastClaim;
        uint256 clanMultiplier;
        uint256 rareMultiplier;
        uint256 lengthMultiplier;
        uint256[] unicornIds;
        QuestState questState;
    }

    struct ClanCounter {
        uint8 airCount;
        uint8 earthCount;
        uint8 fireCount;
        uint8 waterCount;
        uint8 darkCount;
        uint8 pureCount;
    }

    enum Clans {
        AIR,
        EARTH,
        FIRE,
        WATER,
        DARK,
        PURE
    }

    enum QuestState {
        IN_PROGRESS,
        ENDED
    }

    IUninterestedUnicorns public UU;
    ICandyToken public UCD;

    uint256 public baseReward;
    uint256 public baseRoboReward;
    uint256 public baseGoldenReward;
    uint256 private timescale;

    uint256[] public clanMultipliers;
    uint256[] public rareMultipliers;
    uint256[] public lengthMultipliers;
    uint256[] public questLengths;
    bytes public clans;

    mapping(uint256 => Quest) public quests;
    mapping(address => uint256[]) public userQuests; // Maps user address to questIds
    mapping(uint256 => uint256) public onQuest; // Maps tokenId to QuestId (0 = not questing)
    mapping(uint256 => uint256) clanCounter;

    mapping(uint256 => bool) private isRoboUni;
    mapping(uint256 => bool) private isGoldenUni;
    mapping(uint256 => uint256) private HODLLastClaim;

    CountersUpgradeable.Counter private _questId;
    bool private initialized;

    uint256[50] private ______gap;

    event QuestStarted(
        address indexed user,
        uint256 questId,
        uint256[] unicornIds,
        uint256 questLevel,
        uint256 questStart,
        uint256 questEnd
    );
    event QuestEnded(address indexed user, uint256 questId, uint256 endDate);
    event RewardClaimed(
        address indexed user,
        uint256 amount,
        uint256 claimTime
    );

    event QuestUpgraded(
        address indexed user,
        uint256 questId,
        uint256 questLevel
    );

    modifier onlyAdmin() {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "UninterestedUnicorns: OnlyAdmin"
        );
        _;
    }

    function __UniQuest_init(
        address uu,
        uint256 _baseReward,
        uint256 _baseRoboReward,
        uint256 _baseGoldenReward,
        address deployer,
        address treasury
    ) public initializer {

        require(!initialized, "Contract instance has already been initialized");
        __AccessControl_init();
        __ReentrancyGuard_init();
        __ERC721Holder_init();

        _setupRole(DEFAULT_ADMIN_ROLE, deployer); // To revoke access after functions are set
        grantRole(DEFAULT_ADMIN_ROLE, treasury);
        baseReward = _baseReward;
        baseRoboReward = _baseRoboReward;
        baseGoldenReward = _baseGoldenReward;
        UU = IUninterestedUnicorns(uu);
        clanMultipliers = [10000, 10000, 10200, 10400, 10600, 11000];
        rareMultipliers = [10000, 10200, 10400, 10600, 10800, 11000];
        lengthMultipliers = [10000, 10500, 11000];
        questLengths = [30 days, 90 days, 180 days];
        timescale = 1 days;

        initialized = true;
    }


    function startQuest(uint256[] memory unicornIds, uint256 questLevel)
        public
    {

        require(
            areOwned(unicornIds),
            "UniQuest: One or More Unicorns are not owned by you!"
        );

        require(questLevel <= 2, "UniQuest: Invalid Quest Level!");
        require(unicornIds.length <= 5, "UniQuest: Maximum of 5 U_U only!");
        require(unicornIds.length > 0, "UniQuest: At least 1 U_U required!");

        _questId.increment();
        _lockTokens(unicornIds);

        for (uint256 i = 0; i < unicornIds.length; i++) {
            onQuest[unicornIds[i]] = _questId.current();
        }

        uint256 _clanMultiplier;
        uint256 _rareMultiplier;

        (_clanMultiplier, _rareMultiplier) = calculateMultipliers(unicornIds);

        Quest memory _quest = Quest(
            msg.sender, // address questOwner
            questLevel, // uint256 questLevel;
            block.timestamp, // uint256 questStart;
            block.timestamp.add(questLengths[questLevel]), // uint256 questEnd;
            block.timestamp, // uint256 lastClaim;
            _clanMultiplier, // uint256 clanMultiplier;
            _rareMultiplier, // uint256 rareMultiplier;
            lengthMultipliers[questLevel], // uint256 lengthMultiplier;
            unicornIds, // uint256[] unicornIds;
            QuestState.IN_PROGRESS // QuestState questState;
        );

        quests[_questId.current()] = _quest;
        userQuests[msg.sender].push(_questId.current());

        emit QuestStarted(
            msg.sender,
            _questId.current(),
            unicornIds,
            questLevel,
            block.timestamp,
            block.timestamp.add(questLengths[questLevel])
        );
    }

    function upgradeQuest(uint256 questId, uint256 questLevel) public {

        Quest storage quest = quests[questId];
        require(
            quest.questOwner == msg.sender,
            "UniQuest: Quest not owned by you!"
        );

        require(questLevel <= 2, "UniQuest: Invalid Quest Level!");
        require(
            questLevel > quest.questLevel,
            "UniQuest: Invalid Quest Level!"
        );

        quest.questLevel = questLevel;
        quest.questEnd = block.timestamp + questLengths[questLevel];
        quest.lengthMultiplier = lengthMultipliers[questLevel];
    }

    function claimRewards(uint256 questId) public nonReentrant {

        Quest storage quest = quests[questId];
        address questOwner = quest.questOwner;
        require(
            msg.sender == questOwner,
            "UniQuest: Only quest owner can claim candy"
        );
        require(
            quest.questState == QuestState.IN_PROGRESS,
            "UniQuest: Quest has already ended!"
        );
        uint256 rewards = calculateRewards(questId);
        UCD.mint(questOwner, rewards);
        quest.lastClaim = block.timestamp;
        emit RewardClaimed(msg.sender, rewards, block.timestamp);
    }

    function claimAllRewards() public nonReentrant {

        uint256[] memory questIds = getUserQuests(msg.sender);
        uint256 totalRewards = 0;
        Quest storage quest;

        for (uint256 i = 0; i < questIds.length; i++) {
            totalRewards = totalRewards.add(calculateRewards(questIds[i]));
            quest = quests[questIds[i]];
            quest.lastClaim = block.timestamp;
        }
        UCD.mint(msg.sender, totalRewards);
    }

    function claimHODLRewards(uint256[] memory tokenIds) public nonReentrant {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                UU.ownerOf(tokenIds[i]) == msg.sender,
                "UniQuest: Not Owner of token"
            );
        }

        uint256 totalRewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalRewards += calculateHODLReward(tokenIds[i]);
            HODLLastClaim[tokenIds[i]] = block.timestamp;
        }

        UCD.mint(msg.sender, totalRewards);
    }

    function endQuest(uint256 questId) public {

        require(
            msg.sender == quests[questId].questOwner,
            "UniQuest: Not the owner of quest"
        );
        require(
            isQuestEndable(questId),
            "UniQuest: Unicorns are still questing!"
        );
        require(
            quests[questId].questState == QuestState.IN_PROGRESS,
            "UniQuest: Quest already Ended"
        );

        claimRewards(questId);

        _unlockTokens(quests[questId].unicornIds);

        quests[questId].questState = QuestState.ENDED;

        emit QuestEnded(msg.sender, questId, block.timestamp);
    }


    function isQuestEndable(uint256 questId) public view returns (bool) {

        return block.timestamp > quests[questId].questEnd;
    }

    function getClanMultiplier(uint256 clanCount)
        public
        view
        returns (uint256)
    {

        return clanMultipliers[clanCount];
    }

    function getRareMultiplier(uint256 rareCount)
        public
        view
        returns (uint256)
    {

        return rareMultipliers[rareCount];
    }

    function getLengthMultiplier(uint256 questLevel)
        public
        view
        returns (uint256)
    {

        return lengthMultipliers[questLevel];
    }

    function calculateMultipliers(uint256[] memory _tokenIds)
        internal
        view
        returns (uint256 _clanMultiplier, uint256 _rareMultiplier)
    {

        uint8[6] memory _clanCounter = [0, 0, 0, 0, 0, 0];
        uint8 maxCount = 0;
        uint8 maxIndex;
        uint256 rareCount = 0;

        for (uint8 i = 0; i < _tokenIds.length; i++) {
            _clanCounter[getClan(_tokenIds[i]) - 1] += 1;
        }

        for (uint8 i = 0; i < _clanCounter.length; i++) {
            if (_clanCounter[i] > maxCount) {
                maxCount = _clanCounter[i];
                maxIndex = i;
            }
        }

        if (maxIndex < 4) {
            maxCount += _clanCounter[5];
        }

        _clanMultiplier = getClanMultiplier(maxCount);

        rareCount = rareCount.add(_clanCounter[4]).add(_clanCounter[5]);
        _rareMultiplier = getRareMultiplier(rareCount);
    }

    function calculateHODLRewards(uint256[] memory tokenIds)
        public
        view
        returns (uint256 HODLRewards)
    {

        HODLRewards = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (isGoldenUni[tokenIds[i]]) {
                HODLRewards = HODLRewards.add(
                    baseGoldenReward.mul(calcGoldenDuration(tokenIds[i])).div(
                        timescale
                    )
                );
            } else if (isRoboUni[tokenIds[i]]) {
                HODLRewards = HODLRewards.add(
                    baseRoboReward.mul(calcRoboDuration(tokenIds[i])).div(
                        timescale
                    )
                );
            }
        }
    }

    function calculateHODLReward(uint256 tokenId)
        public
        view
        returns (uint256 HODLRewards)
    {

        if (isGoldenUni[tokenId]) {
            HODLRewards = baseGoldenReward.mul(calcGoldenDuration(tokenId)).div(
                    timescale
                );
        } else if (isRoboUni[tokenId]) {
            HODLRewards = baseRoboReward.mul(calcRoboDuration(tokenId)).div(
                timescale
            );
        }
    }

    function calcGoldenDuration(uint256 tokenId)
        private
        view
        returns (uint256)
    {

        return block.timestamp.sub(HODLLastClaim[tokenId]);
    }

    function calcRoboDuration(uint256 tokenId) private view returns (uint256) {

        return block.timestamp.sub(HODLLastClaim[tokenId]);
    }

    function calculateRewards(uint256 questId)
        public
        view
        returns (uint256 rewardAmount)
    {

        Quest memory quest = quests[questId];
        rewardAmount = baseReward
            .mul(block.timestamp.sub(quest.lastClaim))
            .mul(quest.unicornIds.length)
            .mul(quest.clanMultiplier)
            .mul(quest.rareMultiplier)
            .mul(quest.lengthMultiplier)
            .div(timescale)
            .div(1000000000000);
    }

    function areAvailiable(uint256[] memory tokenIds)
        public
        view
        returns (bool out)
    {

        out = true;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (onQuest[tokenIds[i]] > 0) {
                out = false;
            }
        }
    }

    function areOwned(uint256[] memory tokenIds)
        public
        view
        returns (bool out)
    {

        out = true;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (UU.ownerOf(tokenIds[i]) != msg.sender) {
                out = false;
            }
        }
    }

    function getUserQuests(address user)
        public
        view
        returns (uint256[] memory)
    {

        return userQuests[user];
    }

    function getQuest(uint256 questId) public view returns (Quest memory) {

        return quests[questId];
    }

    function isQuestOver(uint256 questId) public view returns (bool) {

        Quest memory quest = quests[questId];
        return block.timestamp > quest.questEnd;
    }

    function getClan(uint256 tokenId) public view returns (uint8) {

        return uint8(clans[tokenId - 1]);
    }


    function setBaseReward(uint256 _amount) public onlyAdmin {

        baseReward = _amount;
    }

    function setRoboReward(uint256 _amount) public onlyAdmin {

        baseRoboReward = _amount;
    }

    function setGoldenReward(uint256 _amount) public onlyAdmin {

        baseGoldenReward = _amount;
    }

    function setRoboIds(uint256[] memory _roboTokenIds) public onlyAdmin {

        for (uint256 i = 0; i < _roboTokenIds.length; i++) {
            isRoboUni[_roboTokenIds[i]] = true;
            HODLLastClaim[_roboTokenIds[i]] = block.timestamp;
        }
    }

    function setGoldenIds(uint256[] memory _goldenTokenIds) public onlyAdmin {

        for (uint256 i = 0; i < _goldenTokenIds.length; i++) {
            isGoldenUni[_goldenTokenIds[i]] = true;
            HODLLastClaim[_goldenTokenIds[i]] = block.timestamp;
        }
    }

    function updateClans(bytes calldata _clans) public onlyAdmin {

        clans = _clans;
    }

    function setUniCandy(address uniCandy) public onlyAdmin {

        UCD = ICandyToken(uniCandy);
    }

    function setTimeScale(uint256 _newTimescale) public onlyAdmin {

        timescale = _newTimescale;
    }

    function transferQuestOwnership(uint256 questId, address newOwner)
        public
        onlyAdmin
    {

        Quest storage quest = quests[questId];
        quest.questOwner = newOwner;
    }

    function setQuestLengths(uint256[] memory _newQuestLengths)
        public
        onlyAdmin
    {

        questLengths = _newQuestLengths;
    }

    function _lockTokens(uint256[] memory tokenIds) private {

        for (uint256 i; i < tokenIds.length; i++) {
            UU.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }
    }

    function _unlockTokens(uint256[] memory tokenIds) private {

        for (uint256 i; i < tokenIds.length; i++) {
            UU.safeTransferFrom(address(this), msg.sender, tokenIds[i]);
            HODLLastClaim[tokenIds[i]] = block.timestamp;
        }
    }
}