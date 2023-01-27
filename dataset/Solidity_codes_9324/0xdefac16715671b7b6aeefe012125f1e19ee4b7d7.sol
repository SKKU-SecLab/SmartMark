pragma solidity ^0.6.10;

contract Pausable {

    struct PauseState {
        bool paused;
        bool pausedByAttorney;
    }

    PauseState private pauseState;

    event Paused(address account, bool attorney);
    event Unpaused(address account);

    constructor() internal {
        pauseState = PauseState(false, false);
    }

    modifier whenNotPaused() {

        require(!pauseState.paused);
        _;
    }

    modifier whenPaused() {

        require(pauseState.paused);
        _;
    }

    function paused() public view returns (bool) {

        return pauseState.paused;
    }

    function pausedByAttorney() public view returns (bool) {

        return pauseState.paused && pauseState.pausedByAttorney;
    }

    function _pause(bool attorney) internal {

        pauseState.paused = true;
        pauseState.pausedByAttorney = attorney;
        emit Paused(msg.sender, attorney);
    }

    function _unpause() internal {

        pauseState.paused = false;
        pauseState.pausedByAttorney = false;
        emit Unpaused(msg.sender);
    }
}
pragma solidity >=0.4.25;

contract ErrorCodes {


    bytes2 constant ERROR_RESERVED = 0xe100;
    bytes2 constant ERROR_RESERVED2 = 0xe200;
    bytes2 constant ERROR_MATH = 0xe101;
    bytes2 constant ERROR_FROZEN = 0xe102;
    bytes2 constant ERROR_INVALID_ADDRESS = 0xe103;
    bytes2 constant ERROR_ZERO_VALUE = 0xe104;
    bytes2 constant ERROR_INSUFFICIENT_BALANCE = 0xe105;
    bytes2 constant ERROR_WRONG_TIME = 0xe106;
    bytes2 constant ERROR_EMPTY_ARRAY = 0xe107;
    bytes2 constant ERROR_LENGTH_MISMATCH = 0xe108;
    bytes2 constant ERROR_UNAUTHORIZED = 0xe109;
    bytes2 constant ERROR_DISALLOWED_STATE = 0xe10a;
    bytes2 constant ERROR_TOO_HIGH = 0xe10b;
    bytes2 constant ERROR_ERC721_CHECK = 0xe10c;
    bytes2 constant ERROR_PAUSED = 0xe10d;
    bytes2 constant ERROR_NOT_PAUSED = 0xe10e;
    bytes2 constant ERROR_ALREADY_EXISTS = 0xe10f;

    bytes2 constant ERROR_OWNER_MISMATCH = 0xe110;
    bytes2 constant ERROR_LOCKED = 0xe111;
    bytes2 constant ERROR_TOKEN_LOCKED = 0xe112;
    bytes2 constant ERROR_ATTORNEY_PAUSE = 0xe113;
    bytes2 constant ERROR_VALUE_MISMATCH = 0xe114;
    bytes2 constant ERROR_TRANSFER_FAIL = 0xe115;
    bytes2 constant ERROR_INDEX_RANGE = 0xe116;
    bytes2 constant ERROR_PAYMENT = 0xe117;

    function expect(bool pass, bytes2 code) internal pure {

        if (!pass) {
            assembly {
                mstore(0x40, code)
                revert(0x40, 0x02)
            }
        }
    }
}
pragma solidity >=0.6.10;

library Groups {

    struct MemberMap {
        mapping(address => bool) members;
    }

    struct GroupMap {
        mapping(uint8 => MemberMap) groups;
    }

    function add(
        GroupMap storage map,
        uint8 groupId,
        address account
    ) internal {

        MemberMap storage group = map.groups[groupId];
        require(account != address(0));
        require(!groupContains(group, account));

        group.members[account] = true;
    }

    function remove(
        GroupMap storage map,
        uint8 groupId,
        address account
    ) internal {

        MemberMap storage group = map.groups[groupId];
        require(account != address(0));
        require(groupContains(group, account));

        group.members[account] = false;
    }

    function contains(
        GroupMap storage map,
        uint8 groupId,
        address account
    ) internal view returns (bool) {

        MemberMap storage group = map.groups[groupId];
        return groupContains(group, account);
    }

    function groupContains(MemberMap storage group, address account) internal view returns (bool) {

        require(account != address(0));
        return group.members[account];
    }
}
pragma solidity ^0.6.10;


contract TokenGroups is Pausable, ErrorCodes {

    uint8 public constant ADMIN = 1;
    uint8 public constant ATTORNEY = 2;
    uint8 public constant BUNDLER = 3;
    uint8 public constant WHITELIST = 4;
    uint8 public constant FROZEN = 5;
    uint8 public constant BW_ADMIN = 6;
    uint8 public constant SWAPPER = 7;
    uint8 public constant DELEGATE = 8;
    uint8 public constant AUTOMATOR = 11;

    using Groups for Groups.GroupMap;

    Groups.GroupMap groups;

    event AddedToGroup(uint8 indexed groupId, address indexed account);
    event RemovedFromGroup(uint8 indexed groupId, address indexed account);

    event BwAddedAttorney(address indexed account);
    event BwRemovedAttorney(address indexed account);
    event BwRemovedAdmin(address indexed account);

    modifier onlyAdminOrAttorney() {

        expect(isAdmin(msg.sender) || isAttorney(msg.sender), ERROR_UNAUTHORIZED);
        _;
    }


    function _addAttorney(address account) internal {

        _add(ATTORNEY, account);
    }

    function addAttorney(address account) public whenNotPaused onlyAdminOrAttorney {

        _add(ATTORNEY, account);
    }

    function bwAddAttorney(address account) public onlyBwAdmin {

        _add(ATTORNEY, account);
        emit BwAddedAttorney(account);
    }

    function removeAttorney(address account) public whenNotPaused onlyAdminOrAttorney {

        _remove(ATTORNEY, account);
    }

    function bwRemoveAttorney(address account) public onlyBwAdmin {

        _remove(ATTORNEY, account);
        emit BwRemovedAttorney(account);
    }

    function isAttorney(address account) public view returns (bool) {

        return _contains(ATTORNEY, account);
    }


    function _addAdmin(address account) internal {

        _add(ADMIN, account);
    }

    function addAdmin(address account) public whenNotPaused onlyAdminOrAttorney {

        _addAdmin(account);
    }

    function removeAdmin(address account) public whenNotPaused onlyAdminOrAttorney {

        _remove(ADMIN, account);
    }

    function bwRemoveAdmin(address account) public onlyBwAdmin {

        _remove(ADMIN, account);
        emit BwRemovedAdmin(account);
    }

    function isAdmin(address account) public view returns (bool) {

        return _contains(ADMIN, account);
    }


    function addBundler(address account) public onlyAdminOrAttorney {

        _add(BUNDLER, account);
    }

    function removeBundler(address account) public onlyAdminOrAttorney {

        _remove(BUNDLER, account);
    }

    function isBundler(address account) public view returns (bool) {

        return _contains(BUNDLER, account);
    }

    modifier onlyBundler() {

        expect(isBundler(msg.sender), ERROR_UNAUTHORIZED);
        _;
    }


    function addSwapper(address account) public onlyAdminOrAttorney {

        _addSwapper(account);
    }

    function _addSwapper(address account) internal {

        _add(SWAPPER, account);
    }

    function removeSwapper(address account) public onlyAdminOrAttorney {

        _remove(SWAPPER, account);
    }

    function isSwapper(address account) public view returns (bool) {

        return _contains(SWAPPER, account);
    }

    modifier onlySwapper() {

        expect(isSwapper(msg.sender), ERROR_UNAUTHORIZED);
        _;
    }


    function addToWhitelist(address account) public onlyAdminOrAttorney {

        _add(WHITELIST, account);
    }

    function removeFromWhitelist(address account) public onlyAdminOrAttorney {

        _remove(WHITELIST, account);
    }

    function isWhitelisted(address account) public view returns (bool) {

        return _contains(WHITELIST, account);
    }


    function _addBwAdmin(address account) internal {

        _add(BW_ADMIN, account);
    }

    function addBwAdmin(address account) public onlyBwAdmin {

        _addBwAdmin(account);
    }

    function renounceBwAdmin() public {

        _remove(BW_ADMIN, msg.sender);
    }

    function isBwAdmin(address account) public view returns (bool) {

        return _contains(BW_ADMIN, account);
    }

    modifier onlyBwAdmin() {

        expect(isBwAdmin(msg.sender), ERROR_UNAUTHORIZED);
        _;
    }


    function _freeze(address account) internal {

        _add(FROZEN, account);
    }

    function freeze(address account) public onlyAdminOrAttorney {

        _freeze(account);
    }

    function _unfreeze(address account) internal {

        _remove(FROZEN, account);
    }

    function unfreeze(address account) public onlyAdminOrAttorney {

        _unfreeze(account);
    }

    function multiFreeze(address[] calldata account) public onlyAdminOrAttorney {

        expect(account.length > 0, ERROR_EMPTY_ARRAY);

        for (uint256 i = 0; i < account.length; i++) {
            _freeze(account[i]);
        }
    }

    function multiUnfreeze(address[] calldata account) public onlyAdminOrAttorney {

        expect(account.length > 0, ERROR_EMPTY_ARRAY);

        for (uint256 i = 0; i < account.length; i++) {
            _unfreeze(account[i]);
        }
    }

    function isFrozen(address account) public view returns (bool) {

        return _contains(FROZEN, account);
    }

    modifier isNotFrozen() {

        expect(!isFrozen(msg.sender), ERROR_FROZEN);
        _;
    }


    function addDelegate(address account) public onlyAdminOrAttorney {

        _add(DELEGATE, account);
    }

    function removeDelegate(address account) public onlyAdminOrAttorney {

        _remove(DELEGATE, account);
    }

    function isDelegate(address account) public view returns (bool) {

        return _contains(DELEGATE, account);
    }


    function addAutomator(address account) public onlyAdminOrAttorney {

        _add(AUTOMATOR, account);
    }

    function removeAutomator(address account) public onlyAdminOrAttorney {

        _remove(AUTOMATOR, account);
    }

    function isAutomator(address account) public view returns (bool) {

        return _contains(AUTOMATOR, account);
    }


    function _add(uint8 groupId, address account) internal {

        groups.add(groupId, account);
        emit AddedToGroup(groupId, account);
    }

    function _remove(uint8 groupId, address account) internal {

        groups.remove(groupId, account);
        emit RemovedFromGroup(groupId, account);
    }

    function _contains(uint8 groupId, address account) internal view returns (bool) {

        return groups.contains(groupId, account);
    }
}
pragma solidity ^0.6.10;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}
pragma solidity ^0.6.10;


contract Voting {

    using SafeMath for uint256;

    struct Suggestion {
        uint256 votes;
        bool created;
        address creator;
        string text;
    }

    mapping(uint256 => mapping(address => uint256)) private voted;

    mapping(uint256 => Suggestion) internal suggestions;

    uint256 public suggestionCount;

    bool public oneVotePerAccount = true;

    event SuggestionCreated(uint256 suggestionId, string text);
    event Votes(
        address voter,
        uint256 indexed suggestionId,
        uint256 votes,
        uint256 totalVotes,
        string comment
    );

    function getVotes(uint256 suggestionId) public view returns (uint256) {

        return suggestions[suggestionId].votes;
    }

    function getAllVotes() public view returns (uint256[] memory) {

        uint256[] memory votes = new uint256[](suggestionCount);

        for (uint256 i = 0; i < suggestionCount; i++) {
            votes[i] = suggestions[i].votes;
        }

        return votes;
    }

    function getSuggestionText(uint256 suggestionId) public view returns (string memory) {

        return suggestions[suggestionId].text;
    }

    function hasVoted(address account, uint256 suggestionId) public view returns (bool) {

        return voted[suggestionId][account] > 0;
    }

    function getAccountVotes(address account, uint256 suggestionId) public view returns (uint256) {

        return voted[suggestionId][account];
    }

    function getSuggestionCreator(uint256 suggestionId) public view returns (address) {

        return suggestions[suggestionId].creator;
    }

    function getAllSuggestionCreators() public view returns (address[] memory) {

        address[] memory creators = new address[](suggestionCount);

        for (uint256 i = 0; i < suggestionCount; i++) {
            creators[i] = suggestions[i].creator;
        }

        return creators;
    }

    function _createSuggestion(string memory text) internal {

        uint256 suggestionId = suggestionCount++;

        suggestions[suggestionId] = Suggestion(0, true, msg.sender, text);

        emit SuggestionCreated(suggestionId, text);
    }

    function _vote(
        address account,
        uint256 suggestionId,
        uint256 votes,
        string memory comment
    ) internal returns (uint256) {

        if (oneVotePerAccount) {
            require(!hasVoted(account, suggestionId));
            require(votes == 1);
        }
        Suggestion storage sugg = suggestions[suggestionId];
        require(sugg.created);

        voted[suggestionId][account] = voted[suggestionId][account].add(votes);
        sugg.votes = sugg.votes.add(votes);

        emit Votes(account, suggestionId, votes, sugg.votes, comment);

        return sugg.votes;
    }
}
pragma solidity >=0.6.10;

interface Erc20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.6.10;

library BlockwellQuill {

    struct Data {
        mapping(address => bytes) data;
    }

    function set(
        Data storage data,
        address account,
        bytes memory value
    ) internal {

        require(account != address(0));
        data.data[account] = value;
    }

    function get(Data storage data, address account) internal view returns (bytes memory) {

        require(account != address(0));
        return data.data[account];
    }

    function setString(
        Data storage data,
        address account,
        string memory value
    ) internal {

        data.data[address(account)] = bytes(value);
    }

    function getString(Data storage data, address account) internal view returns (string memory) {

        return string(data.data[address(account)]);
    }

    function setUint256(
        Data storage data,
        address account,
        uint256 value
    ) internal {

        data.data[address(account)] = abi.encodePacked(value);
    }

    function getUint256(Data storage data, address account) internal view returns (uint256) {

        uint256 ret;
        bytes memory source = data.data[address(account)];
        assembly {
            ret := mload(add(source, 32))
        }
        return ret;
    }

    function setAddress(
        Data storage data,
        address account,
        address value
    ) internal {

        data.data[address(account)] = abi.encodePacked(value);
    }

    function getAddress(Data storage data, address account) internal view returns (address) {

        address ret;
        bytes memory source = data.data[address(account)];
        assembly {
            ret := mload(add(source, 20))
        }
        return ret;
    }
}
pragma solidity >=0.4.25;

contract Type {

    uint256 constant PRIME = 1;

    uint256 public bwtype;
    uint256 public bwver;
}
pragma solidity ^0.6.10;


contract PrimeToken is Erc20, TokenGroups, Type, Voting {

    using SafeMath for uint256;
    using BlockwellQuill for BlockwellQuill.Data;

    struct Lock {
        uint256 value;
        uint64 expiration;
        uint32 periodLength;
        uint16 periods;
        bool staking;
    }

    mapping(address => uint256) internal balances;

    mapping(address => uint256) internal stakes;

    mapping(address => mapping(address => uint256)) private allowed;

    mapping(address => Lock[]) locks;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public unlockTime;
    uint256 public transferLockTime;
    string public attorneyEmail;

    uint256 internal totalTokenSupply;

    uint256 public swapNonce;

    bool public suggestionsRestricted = false;
    bool public requireBalanceForVote = false;
    bool public requireBalanceForCreateSuggestion = false;
    uint256 public voteCost;

    uint256 public unstakingDelay = 1 hours;

    BlockwellQuill.Data bwQuill1;

    event SetNewUnlockTime(uint256 unlockTime);
    event MultiTransferPrevented(address indexed from, address indexed to, uint256 value);

    event Locked(
        address indexed owner,
        uint256 value,
        uint64 expiration,
        uint32 periodLength,
        uint16 periodCount
    );
    event Unlocked(address indexed owner, uint256 value, uint16 periodsLeft);

    event SwapToChain(
        string toChain,
        address indexed from,
        address indexed to,
        bytes32 indexed swapId,
        uint256 value
    );
    event SwapFromChain(
        string fromChain,
        address indexed from,
        address indexed to,
        bytes32 indexed swapId,
        uint256 value
    );

    event BwQuillSet(address indexed account, string value);

    event Payment(address indexed from, address indexed to, uint256 value, uint256 order);

    event Stake(address indexed account, uint256 value);
    event Unstake(address indexed account, uint256 value);
    event StakeReward(address indexed account, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) public {
        require(_totalSupply > 0);

        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        totalTokenSupply = _totalSupply;

        init(msg.sender);
        bwtype = PRIME;
        bwver = 62;
    }

    function init(address sender) internal virtual {

        _addBwAdmin(sender);
        _addAdmin(sender);

        balances[sender] = totalTokenSupply;
        emit Transfer(address(0), sender, totalTokenSupply);
    }

    modifier whenUnlocked() {

        expect(
            now > unlockTime || isAdmin(msg.sender) || isAttorney(msg.sender) || isWhitelisted(msg.sender),
            ERROR_TOKEN_LOCKED
        );
        _;
    }

    function setBwQuill(address account, string memory value) public onlyAdminOrAttorney {

        bwQuill1.setString(account, value);
        emit BwQuillSet(account, value);
    }

    function getBwQuill(address account) public view returns (string memory) {

        return bwQuill1.getString(account);
    }

    function configureVoting(
        bool restrictSuggestions,
        bool balanceForVote,
        bool balanceForCreateSuggestion,
        uint256 cost,
        bool oneVote
    ) public onlyAdminOrAttorney {

        suggestionsRestricted = restrictSuggestions;
        requireBalanceForVote = balanceForVote;
        requireBalanceForCreateSuggestion = balanceForCreateSuggestion;
        voteCost = cost;
        oneVotePerAccount = oneVote;
    }

    function setAttorneyEmail(string memory email) public onlyAdminOrAttorney {

        attorneyEmail = email;
    }

    function pause() public whenNotPaused {

        bool attorney = isAttorney(msg.sender);
        expect(attorney || isAdmin(msg.sender), ERROR_UNAUTHORIZED);

        _pause(attorney);
    }

    function unpause() public whenPaused {

        if (!isAttorney(msg.sender)) {
            expect(isAdmin(msg.sender), ERROR_UNAUTHORIZED);
            expect(!pausedByAttorney(), ERROR_ATTORNEY_PAUSE);
        }
        _unpause();
    }

    function setUnlockTime(uint256 timestamp) public onlyAdminOrAttorney {

        unlockTime = timestamp;
        emit SetNewUnlockTime(unlockTime);
    }

    function totalSupply() public view override returns (uint256) {

        return totalTokenSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public override whenNotPaused whenUnlocked returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function multiTransfer(address[] calldata to, uint256[] calldata value)
        public
        whenNotPaused
        onlyBundler
        returns (bool)
    {

        expect(to.length > 0, ERROR_EMPTY_ARRAY);
        expect(value.length == to.length, ERROR_LENGTH_MISMATCH);

        for (uint256 i = 0; i < to.length; i++) {
            if (!isFrozen(to[i])) {
                _transfer(msg.sender, to[i], value[i]);
            } else {
                emit MultiTransferPrevented(msg.sender, to[i], value[i]);
            }
        }

        return true;
    }

    function approve(address spender, uint256 value)
        public
        override
        isNotFrozen
        whenNotPaused
        whenUnlocked
        returns (bool)
    {

        expect(spender != address(0), ERROR_INVALID_ADDRESS);

        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override whenNotPaused whenUnlocked returns (bool) {

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function multiTransferFrom(
        address from,
        address[] calldata to,
        uint256[] calldata value
    ) public whenNotPaused onlyBundler returns (bool) {

        expect(to.length > 0, ERROR_EMPTY_ARRAY);
        expect(value.length == to.length, ERROR_LENGTH_MISMATCH);

        for (uint256 i = 0; i < to.length; i++) {
            if (!isFrozen(to[i])) {
                allowed[from][msg.sender] = allowed[from][msg.sender].sub(value[i]);
                _transfer(from, to[i], value[i]);
            } else {
                emit MultiTransferPrevented(from, to[i], value[i]);
            }
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        isNotFrozen
        whenNotPaused
        whenUnlocked
        returns (bool)
    {

        expect(spender != address(0), ERROR_INVALID_ADDRESS);

        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        isNotFrozen
        whenNotPaused
        whenUnlocked
        returns (bool)
    {

        expect(spender != address(0), ERROR_INVALID_ADDRESS);

        allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function locksOf(address account) public view returns (uint256[] memory) {

        Lock[] storage userLocks = locks[account];

        uint256[] memory lockArray = new uint256[](userLocks.length * 4);

        for (uint256 i = 0; i < userLocks.length; i++) {
            uint256 pos = 4 * i;
            lockArray[pos] = userLocks[i].value;
            lockArray[pos + 1] = userLocks[i].expiration;
            lockArray[pos + 2] = userLocks[i].periodLength;
            lockArray[pos + 3] = userLocks[i].periods;
        }

        return lockArray;
    }

    function unlock() public returns (bool) {

        return _unlock(msg.sender);
    }

    function _unlock(address account) internal returns (bool) {

        Lock[] storage list = locks[account];
        if (list.length == 0) {
            return true;
        }

        for (uint256 i = 0; i < list.length; ) {
            Lock storage lock = list[i];
            if (lock.expiration < block.timestamp) {
                if (lock.periods < 2) {
                    emit Unlocked(account, lock.value, 0);

                    if (i < list.length - 1) {
                        list[i] = list[list.length - 1];
                    }
                    list.pop();
                } else {
                    uint256 value;
                    uint256 diff = block.timestamp.sub(lock.expiration);
                    uint16 periodsPassed = 1 + uint16(diff.div(lock.periodLength));
                    if (periodsPassed >= lock.periods) {
                        periodsPassed = lock.periods;
                        value = lock.value;
                        emit Unlocked(account, value, 0);
                        if (i < list.length - 1) {
                            list[i] = list[list.length - 1];
                        }
                        list.pop();
                    } else {
                        value = lock.value.div(lock.periods) * periodsPassed;

                        lock.periods -= periodsPassed;
                        lock.value = lock.value.sub(value);
                        lock.expiration =
                            lock.expiration +
                            uint32(uint256(lock.periodLength).mul(periodsPassed));
                        emit Unlocked(account, value, lock.periods);
                        i++;
                    }
                }
            } else {
                i++;
            }
        }

        return true;
    }

    function unlockedBalanceOf(address account) public view returns (uint256) {

        return balances[account].sub(totalLocked(account));
    }

    function availableBalanceOf(address account) external view returns (uint256) {

        return balances[account].sub(totalLocked(account)).add(totalUnlockable(account));
    }

    function transferAndLock(
        address to,
        uint256 value,
        uint32 lockTime,
        uint32 periodLength,
        uint16 periods
    ) public returns (bool) {

        uint64 expires = uint64(block.timestamp.add(lockTime));
        Lock memory newLock = Lock(value, expires, periodLength, periods, false);
        locks[to].push(newLock);

        transfer(to, value);
        emit Locked(to, value, expires, periodLength, periods);

        return true;
    }

    function multiTransferAndLock(
        address[] calldata to,
        uint256[] calldata value,
        uint32 lockTime,
        uint32 periodLength,
        uint16 periods
    ) public whenNotPaused onlyBundler returns (bool) {

        expect(to.length > 0, ERROR_EMPTY_ARRAY);
        expect(value.length == to.length, ERROR_LENGTH_MISMATCH);

        for (uint256 i = 0; i < to.length; i++) {
            if (!isFrozen(to[i])) {
                transferAndLock(to[i], value[i], lockTime, periodLength, periods);
            } else {
                emit MultiTransferPrevented(msg.sender, to[i], value[i]);
            }
        }

        return true;
    }

    function totalLocked(address account) public view returns (uint256) {

        uint256 total = 0;
        for (uint256 i = 0; i < locks[account].length; i++) {
            total = total.add(locks[account][i].value);
        }

        return total;
    }

    function totalUnlockable(address account) public view returns (uint256) {

        Lock[] storage userLocks = locks[account];
        uint256 total = 0;
        for (uint256 i = 0; i < userLocks.length; i++) {
            Lock storage lock = userLocks[i];
            if (lock.expiration < block.timestamp) {
                if (lock.periods < 2) {
                    total = total.add(lock.value);
                } else {
                    uint256 value;
                    uint256 diff = block.timestamp.sub(lock.expiration);
                    uint16 periodsPassed = 1 + uint16(diff.div(lock.periodLength));
                    if (periodsPassed > lock.periods) {
                        periodsPassed = lock.periods;
                        value = lock.value;
                    } else {
                        value = lock.value.div(lock.periods) * periodsPassed;
                    }

                    total = total.add(value);
                }
            }
        }

        return total;
    }

    function withdrawTokens() public whenNotPaused {

        expect(isAdmin(msg.sender), ERROR_UNAUTHORIZED);
        _transfer(address(this), msg.sender, balanceOf(address(this)));
    }

    function getSwapNonce() internal returns (uint256) {

        return ++swapNonce;
    }

    function swapToChain(
        string memory chain,
        address to,
        uint256 value
    ) public whenNotPaused whenUnlocked {

        bytes32 swapId = keccak256(
            abi.encodePacked(getSwapNonce(), msg.sender, to, address(this), chain, value)
        );

        _transfer(msg.sender, address(this), value);
        emit SwapToChain(chain, msg.sender, to, swapId, value);
    }

    function swapFromChain(
        string memory fromChain,
        address from,
        address to,
        bytes32 swapId,
        uint256 value
    ) public whenNotPaused onlySwapper {

        _transfer(address(this), to, value);

        emit SwapFromChain(fromChain, from, to, swapId, value);
    }

    function createSuggestion(string memory text) public {

        if (suggestionsRestricted) {
            expect(isAdmin(msg.sender) || isDelegate(msg.sender), ERROR_UNAUTHORIZED);
        } else if (requireBalanceForCreateSuggestion) {
            expect(balanceOf(msg.sender) > 0, ERROR_INSUFFICIENT_BALANCE);
        }
        _createSuggestion(text);
    }

    function vote(uint256 suggestionId, string memory comment) public {

        if (requireBalanceForVote) {
            expect(balanceOf(msg.sender) > 0, ERROR_INSUFFICIENT_BALANCE);
        }

        if (voteCost > 0) {
            _transfer(msg.sender, address(this), voteCost);
        }

        _vote(msg.sender, suggestionId, 1, comment);
    }

    function multiVote(
        uint256 suggestionId,
        uint256 votes,
        string memory comment
    ) public {

        expect(!oneVotePerAccount, ERROR_DISALLOWED_STATE);

        if (requireBalanceForVote) {
            expect(balanceOf(msg.sender) > 0, ERROR_INSUFFICIENT_BALANCE);
        }

        if (voteCost > 0) {
            _transfer(msg.sender, address(this), voteCost.mul(votes));
        }

        _vote(msg.sender, suggestionId, votes, comment);
    }

    function payment(
        address to,
        uint256 value,
        uint256 order
    ) public whenNotPaused whenUnlocked returns (bool) {

        _transfer(msg.sender, to, value);

        emit Payment(msg.sender, to, value, order);
        return true;
    }

    function stake(uint256 value) public whenNotPaused whenUnlocked returns (bool) {

        expect(!isFrozen(msg.sender), ERROR_FROZEN);

        _unlock(msg.sender);
        expect(value <= unlockedBalanceOf(msg.sender), ERROR_INSUFFICIENT_BALANCE);

        balances[msg.sender] = balances[msg.sender].sub(value);
        stakes[msg.sender] = stakes[msg.sender].add(value);

        emit Transfer(msg.sender, address(0), value);
        emit Stake(msg.sender, value);

        return true;
    }

    function stakeOf(address account) public view returns (uint256) {

        return stakes[account];
    }

    function unstake(uint256 value) public whenNotPaused whenUnlocked returns (bool) {

        expect(!isFrozen(msg.sender), ERROR_FROZEN);

        stakes[msg.sender] = stakes[msg.sender].sub(value);
        balances[msg.sender] = balances[msg.sender].add(value);

        if (unstakingDelay > 0) {
            uint64 expires = uint64(block.timestamp.add(unstakingDelay));
            Lock memory newLock = Lock(value, expires, 0, 0, true);
            locks[msg.sender].push(newLock);
            emit Locked(msg.sender, value, expires, 0, 0);
        }

        emit Unstake(msg.sender, value);
        emit Transfer(address(0), msg.sender, value);

        return true;
    }

    function configureStaking(uint256 unstakeDelay) public onlyAdminOrAttorney {

        unstakingDelay = unstakeDelay;
    }

    function stakeReward(address[] calldata to, uint256[] calldata value)
        public
        whenNotPaused
        returns (bool)
    {

        expect(isAutomator(msg.sender), ERROR_UNAUTHORIZED);
        expect(value.length == to.length, ERROR_LENGTH_MISMATCH);

        for (uint256 i = 0; i < to.length; i++) {
            address account = to[i];
            uint256 val = value[i];
            if (!isFrozen(account)) {
                stakes[account] = stakes[account].add(val);
                balances[msg.sender] = balances[msg.sender].sub(val);

                emit StakeReward(account, val);
                emit Transfer(msg.sender, address(0), val);
            }
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {

        expect(to != address(0), ERROR_INVALID_ADDRESS);
        expect(!isFrozen(from), ERROR_FROZEN);
        expect(!isFrozen(to), ERROR_FROZEN);

        _unlock(from);

        expect(value <= unlockedBalanceOf(from), ERROR_INSUFFICIENT_BALANCE);

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
    }
}

pragma solidity ^0.6.10;


contract PrimeDeployable is PrimeToken {

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply,
        address owner,
        address bwAdmin,
        address feeAccount,
        uint256 feePercentageTenths,
        address attorney,
        string memory _attorneyEmail
    ) public PrimeToken(_name, _symbol, _decimals, _totalSupply) {
        _addBwAdmin(bwAdmin);
        _addAdmin(owner);
        if (attorney != address(0x0)) {
            _addAttorney(attorney);
        }
        attorneyEmail = _attorneyEmail;

        if (feePercentageTenths > 0) {
            uint256 fee = totalTokenSupply.mul(feePercentageTenths).div(1000);
            balances[owner] = totalTokenSupply.sub(fee);
            emit Transfer(address(0), owner, balances[owner]);

            balances[feeAccount] = fee;
            emit Transfer(address(0), feeAccount, fee);
        } else {
            balances[owner] = totalTokenSupply;
            emit Transfer(address(0), owner, totalTokenSupply);
        }
    }

    function init(address) internal override {

    }
}

pragma solidity ^0.6.10;

contract NoContract {


}
