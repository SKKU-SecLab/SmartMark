

pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;





contract ERC20 is Context, IERC20, Ownable {

    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 99999900 * (10**8);

    constructor() public {
        _balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract GlobalsAndUtility is ERC20 {

    event XfLobbyEnter(
        uint256 timestamp,
        uint256 enterDay,
        uint256 indexed entryIndex,
        uint256 indexed rawAmount
    );
    event XfLobbyExit(
        uint256 timestamp,
        uint256 enterDay,
        uint256 indexed entryIndex,
        uint256 indexed xfAmount,
        address indexed referrerAddr
    );
    event DailyDataUpdate(
        address indexed updaterAddr,
        uint256 timestamp,
        uint256 beginDay,
        uint256 endDay
    );
    event StakeStart(
        uint40 indexed stakeId,
        address indexed stakerAddr,
        uint256 stakedSuns,
        uint256 stakeShares,
        uint256 stakedDays
    );
    event StakeGoodAccounting(
        uint40 indexed stakeId,
        address indexed stakerAddr,
        address indexed senderAddr,
        uint256 stakedSuns,
        uint256 stakeShares,
        uint256 payout,
        uint256 penalty
    );
    event StakeEnd(
        uint40 indexed stakeId,
        uint40 prevUnlocked,
        address indexed stakerAddr,
        uint256 lockedDay,
        uint256 servedDays,
        uint256 stakedSuns,
        uint256 stakeShares,
        uint256 payout,
        uint256 penalty,
        uint256 stakeReturn
    );
    event ShareRateChange(
        uint40 indexed stakeId,
        uint256 timestamp,
        uint256 newShareRate
    );
    uint256 public ROUND_TIME;
    uint256 public LOTERY_ENTRY_TIME;
    address public defaultReferrerAddr;
    address payable public flushAddr;
    uint256 internal firstAuction = uint256(-1);
    uint256 internal LAST_FLUSHED_DAY = 0;
    string public constant name = "Jackpot Ethereum";
    string public constant symbol = "JETH";
    uint8 public constant decimals = 8;
    uint256 public LAUNCH_TIME; // = 1606046700;
    uint256 public dayNumberBegin; // = 2;
    uint256 internal constant CLAIM_STARTING_AMOUNT =
        2500000 * (10**uint256(decimals));
    uint256 internal constant CLAIM_LOWEST_AMOUNT =
        1000000 * (10**uint256(decimals));
    uint256 internal constant XF_LOBBY_DAY_WORDS = ((1 + (50 * 7)) + 255) >> 8;
    uint256 internal constant MIN_STAKE_DAYS = 1;
    uint256 internal constant MAX_STAKE_DAYS = 180; // Approx 0.5 years
    uint256 internal constant EARLY_PENALTY_MIN_DAYS = 90;
    uint256 internal constant LATE_PENALTY_GRACE_DAYS = 2 * 7;
    uint256 internal constant LATE_PENALTY_SCALE_DAYS = 100 * 7;
    uint256 internal constant LPB = (18 * 100) / 20; /* LPB_BONUS_PERCENT */
    uint256 internal constant LPB_MAX_DAYS = (LPB * 200) / 100; /* LPB_BONUS_MAX_PERCENT */
    uint256 internal constant BPB_MAX_SUNS =
        7 *
            1e6 * /* BPB_MAX_JACKPOT */
            (10**uint256(decimals));
    uint256 internal constant BPB = (BPB_MAX_SUNS * 100) / 10; /* BPB_BONUS_PERCENT */
    uint256 internal constant SHARE_RATE_SCALE = 1e5;
    uint256 internal constant SHARE_RATE_UINT_SIZE = 40;
    uint256 internal constant SHARE_RATE_MAX = (1 << SHARE_RATE_UINT_SIZE) - 1;
    uint8 internal constant BONUS_DAY_SCALE = 2;
    struct GlobalsCache {
        uint256 _lockedSunsTotal;
        uint256 _nextStakeSharesTotal;
        uint256 _shareRate;
        uint256 _stakePenaltyTotal;
        uint256 _dailyDataCount;
        uint256 _stakeSharesTotal;
        uint40 _latestStakeId;
        uint256 _currentDay;
    }
    struct GlobalsStore {
        uint256 lockedSunsTotal;
        uint256 nextStakeSharesTotal;
        uint40 shareRate;
        uint256 stakePenaltyTotal;
        uint16 dailyDataCount;
        uint256 stakeSharesTotal;
        uint40 latestStakeId;
    }
    GlobalsStore public globals;
    struct DailyDataStore {
        uint256 dayPayoutTotal;
        uint256 dayDividends;
        uint256 dayStakeSharesTotal;
    }
    mapping(uint256 => DailyDataStore) public dailyData;
    struct StakeCache {
        uint40 _stakeId;
        uint256 _stakedSuns;
        uint256 _stakeShares;
        uint256 _lockedDay;
        uint256 _stakedDays;
        uint256 _unlockedDay;
    }
    struct StakeStore {
        uint40 stakeId;
        uint256 stakedSuns;
        uint256 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
    }
    struct UnstakeStore {
        uint40 stakeId;
        uint256 stakedSuns;
        uint256 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
        uint256 unstakePayout;
        uint256 unstakeDividends;
    }
    mapping(address => StakeStore[]) public stakeLists;
    mapping(address => UnstakeStore[]) public endedStakeLists;
    struct DailyRoundState {
        uint256 _allocSupplyCached;
        uint256 _payoutTotal;
    }
    struct XfLobbyEntryStore {
        uint96 rawAmount;
        address referrerAddr;
    }
    struct XfLobbyQueueStore {
        uint40 headIndex;
        uint40 tailIndex;
        mapping(uint256 => XfLobbyEntryStore) entries;
    }
    mapping(uint256 => uint256) public xfLobby;
    mapping(uint256 => mapping(address => XfLobbyQueueStore))
        public xfLobbyMembers;
    mapping(address => uint256) public fromReferrs;
    mapping(uint256 => mapping(address => uint256))
        public jackpotReceivedAuction;

    event loteryLobbyEnter(
        uint256 timestamp,
        uint256 enterDay,
        uint256 indexed rawAmount
    );
    event loteryLobbyExit(
        uint256 timestamp,
        uint256 enterDay,
        uint256 indexed rawAmount
    );
    event loteryWin(uint256 day, uint256 amount, address who);
    struct LoteryStore {
        uint256 change;
        uint256 chanceCount;
    }
    struct LoteryCount {
        address who;
        uint256 chanceCount;
    }
    struct winLoteryStat {
        address payable who;
        uint256 totalAmount;
        uint256 restAmount;
    }
    uint256 public lastEndedLoteryDay = 0;
    uint256 public lastEndedLoteryDayWithWinner = 0;
    uint256 public loteryDayWaitingForWinner = 0;
    uint256 public loteryDayWaitingForWinnerNew = 0;
    mapping(uint256 => winLoteryStat) public winners;
    mapping(uint256 => uint256) public dayChanceCount;
    mapping(uint256 => mapping(address => LoteryStore)) public loteryLobby;
    mapping(uint256 => LoteryCount[]) public loteryCount;

    function dailyDataUpdate(uint256 beforeDay) external {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);
        require(g._currentDay > 1, "JACKPOT: Too early"); /* CLAIM_PHASE_START_DAY */
        if (beforeDay != 0) {
            require(
                beforeDay <= g._currentDay,
                "JACKPOT: beforeDay cannot be in the future"
            );
            _dailyDataUpdate(g, beforeDay);
        } else {
            _dailyDataUpdate(g, g._currentDay);
        }
        _globalsSync(g, gSnapshot);
    }

    function globalInfo() external view returns (uint256[10] memory) {

        return [
            globals.lockedSunsTotal,
            globals.nextStakeSharesTotal,
            globals.shareRate,
            globals.stakePenaltyTotal,
            globals.dailyDataCount,
            globals.stakeSharesTotal,
            globals.latestStakeId,
            block.timestamp,
            totalSupply(),
            xfLobby[_currentDay()]
        ];
    }

    function allocatedSupply() external view returns (uint256) {

        return totalSupply().add(globals.lockedSunsTotal);
    }

    function currentDay() external view returns (uint256) {

        return _currentDay();
    }

    function _currentDay() internal view returns (uint256) {

        return block.timestamp.sub(LAUNCH_TIME).div(ROUND_TIME);
    }

    function _dailyDataUpdateAuto(GlobalsCache memory g) internal {

        _dailyDataUpdate(g, g._currentDay);
    }

    function _globalsLoad(GlobalsCache memory g, GlobalsCache memory gSnapshot)
        internal
        view
    {

        g._lockedSunsTotal = globals.lockedSunsTotal;
        g._nextStakeSharesTotal = globals.nextStakeSharesTotal;
        g._shareRate = globals.shareRate;
        g._stakePenaltyTotal = globals.stakePenaltyTotal;
        g._dailyDataCount = globals.dailyDataCount;
        g._stakeSharesTotal = globals.stakeSharesTotal;
        g._latestStakeId = globals.latestStakeId;
        g._currentDay = _currentDay();
        _globalsCacheSnapshot(g, gSnapshot);
    }

    function _globalsCacheSnapshot(
        GlobalsCache memory g,
        GlobalsCache memory gSnapshot
    ) internal pure {

        gSnapshot._lockedSunsTotal = g._lockedSunsTotal;
        gSnapshot._nextStakeSharesTotal = g._nextStakeSharesTotal;
        gSnapshot._shareRate = g._shareRate;
        gSnapshot._stakePenaltyTotal = g._stakePenaltyTotal;
        gSnapshot._dailyDataCount = g._dailyDataCount;
        gSnapshot._stakeSharesTotal = g._stakeSharesTotal;
        gSnapshot._latestStakeId = g._latestStakeId;
    }

    function _globalsSync(GlobalsCache memory g, GlobalsCache memory gSnapshot)
        internal
    {

        if (
            g._lockedSunsTotal != gSnapshot._lockedSunsTotal ||
            g._nextStakeSharesTotal != gSnapshot._nextStakeSharesTotal ||
            g._shareRate != gSnapshot._shareRate ||
            g._stakePenaltyTotal != gSnapshot._stakePenaltyTotal
        ) {
            globals.lockedSunsTotal = g._lockedSunsTotal;
            globals.nextStakeSharesTotal = g._nextStakeSharesTotal;
            globals.shareRate = uint40(g._shareRate);
            globals.stakePenaltyTotal = g._stakePenaltyTotal;
        }
        if (
            g._dailyDataCount != gSnapshot._dailyDataCount ||
            g._stakeSharesTotal != gSnapshot._stakeSharesTotal ||
            g._latestStakeId != gSnapshot._latestStakeId
        ) {
            globals.dailyDataCount = uint16(g._dailyDataCount);
            globals.stakeSharesTotal = g._stakeSharesTotal;
            globals.latestStakeId = g._latestStakeId;
        }
    }

    function _stakeLoad(
        StakeStore storage stRef,
        uint40 stakeIdParam,
        StakeCache memory st
    ) internal view {

        require(
            stakeIdParam == stRef.stakeId,
            "JACKPOT: stakeIdParam not in stake"
        );
        st._stakeId = stRef.stakeId;
        st._stakedSuns = stRef.stakedSuns;
        st._stakeShares = stRef.stakeShares;
        st._lockedDay = stRef.lockedDay;
        st._stakedDays = stRef.stakedDays;
        st._unlockedDay = stRef.unlockedDay;
    }

    function _stakeUpdate(StakeStore storage stRef, StakeCache memory st)
        internal
    {

        stRef.stakeId = st._stakeId;
        stRef.stakedSuns = st._stakedSuns;
        stRef.stakeShares = st._stakeShares;
        stRef.lockedDay = uint16(st._lockedDay);
        stRef.stakedDays = uint16(st._stakedDays);
        stRef.unlockedDay = uint16(st._unlockedDay);
    }

    function _stakeAdd(
        StakeStore[] storage stakeListRef,
        uint40 newStakeId,
        uint256 newStakedSuns,
        uint256 newStakeShares,
        uint256 newLockedDay,
        uint256 newStakedDays
    ) internal {

        stakeListRef.push(
            StakeStore(
                newStakeId,
                newStakedSuns,
                newStakeShares,
                uint16(newLockedDay),
                uint16(newStakedDays),
                uint16(0) // unlockedDay
            )
        );
    }

    function _stakeRemove(StakeStore[] storage stakeListRef, uint256 stakeIndex)
        internal
    {

        uint256 lastIndex = stakeListRef.length.sub(1);
        if (stakeIndex != lastIndex) {
            stakeListRef[stakeIndex] = stakeListRef[lastIndex];
        }
        stakeListRef.pop();
    }

    function _estimatePayoutRewardsDay(
        GlobalsCache memory g,
        uint256 stakeSharesParam
    ) internal view returns (uint256 payout) {

        GlobalsCache memory gJpt;
        _globalsCacheSnapshot(g, gJpt);
        DailyRoundState memory rs;
        rs._allocSupplyCached = totalSupply().add(g._lockedSunsTotal);
        _dailyRoundCalc(gJpt, rs);
        gJpt._stakeSharesTotal = gJpt._stakeSharesTotal.add(stakeSharesParam);
        payout = rs._payoutTotal.mul(stakeSharesParam).div(gJpt._stakeSharesTotal);
        return payout;
    }

    function _dailyRoundCalc(GlobalsCache memory g, DailyRoundState memory rs)
        private
        pure
    {

        rs._payoutTotal = rs._allocSupplyCached.mul(342345).div(685188967);
        if (g._stakePenaltyTotal != 0) {
            rs._payoutTotal = rs._payoutTotal.add(g._stakePenaltyTotal);
            g._stakePenaltyTotal = 0;
        }
    }

    function _dailyRoundCalcAndStore(
        GlobalsCache memory g,
        DailyRoundState memory rs,
        uint256 day
    ) private {

        _dailyRoundCalc(g, rs);
        dailyData[day].dayPayoutTotal = rs._payoutTotal;
        dailyData[day].dayDividends = xfLobby[day];
        dailyData[day].dayStakeSharesTotal = g._stakeSharesTotal;
    }

    function _dailyDataUpdate(GlobalsCache memory g, uint256 beforeDay)
        private
    {

        if (g._dailyDataCount >= beforeDay) {
            return;
        }
        DailyRoundState memory rs;
        rs._allocSupplyCached = totalSupply().add(g._lockedSunsTotal);
        uint256 day = g._dailyDataCount;
        _dailyRoundCalcAndStore(g, rs, day);
        if (g._nextStakeSharesTotal != 0) {
            g._stakeSharesTotal = g._stakeSharesTotal.add(g._nextStakeSharesTotal);
            g._nextStakeSharesTotal = 0;
        }
        while (++day < beforeDay) {
            _dailyRoundCalcAndStore(g, rs, day);
        }
        emit DailyDataUpdate(
            msg.sender,
            block.timestamp,
            g._dailyDataCount,
            day
        );
        g._dailyDataCount = day;
    }
}

contract StakeableToken is GlobalsAndUtility {

    modifier onlyAfterNDays(uint256 daysShift) {

        require(now >= LAUNCH_TIME, "JACKPOT: Too early");
        require(
            firstAuction != uint256(-1),
            "JACKPOT: Must be at least one auction"
        );
        require(
            _currentDay() >= firstAuction.add(daysShift),
            "JACKPOT: Too early"
        );
        _;
    }

    function stakeStart(uint256 newStakedSuns, uint256 newStakedDays)
        external
        onlyAfterNDays(1)
    {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);
        if (g._currentDay >= 1) endLoteryDay(g._currentDay.sub(1));
        require(
            newStakedDays >= MIN_STAKE_DAYS,
            "JACKPOT: newStakedDays lower than minimum"
        );
        _dailyDataUpdateAuto(g);
        _stakeStart(g, newStakedSuns, newStakedDays);
        _burn(msg.sender, newStakedSuns);
        _globalsSync(g, gSnapshot);
    }

    function stakeGoodAccounting(
        address stakerAddr,
        uint256 stakeIndex,
        uint40 stakeIdParam
    ) external {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);
        if (g._currentDay >= 1) endLoteryDay(g._currentDay.sub(1));
        require(
            stakeLists[stakerAddr].length != 0,
            "JACKPOT: Empty stake list"
        );
        require(
            stakeIndex < stakeLists[stakerAddr].length,
            "JACKPOT: stakeIndex invalid"
        );
        StakeStore storage stRef = stakeLists[stakerAddr][stakeIndex];
        StakeCache memory st;
        _stakeLoad(stRef, stakeIdParam, st);
        require(
            g._currentDay >= st._lockedDay.add(st._stakedDays),
            "JACKPOT: Stake not fully served"
        );
        require(st._unlockedDay == 0, "JACKPOT: Stake already unlocked");
        _dailyDataUpdateAuto(g);
        _stakeUnlock(g, st);
        (, uint256 payout, , uint256 penalty, uint256 cappedPenalty) =
            _stakePerformance(g, st, st._stakedDays);
        emit StakeGoodAccounting(
            stakeIdParam,
            stakerAddr,
            msg.sender,
            st._stakedSuns,
            st._stakeShares,
            payout,
            penalty
        );
        if (cappedPenalty != 0) {
            g._stakePenaltyTotal = g._stakePenaltyTotal.add(cappedPenalty);
        }
        _stakeUpdate(stRef, st);
        _globalsSync(g, gSnapshot);
    }

    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);
        StakeStore[] storage stakeListRef = stakeLists[msg.sender];
        require(stakeListRef.length != 0, "JACKPOT: Empty stake list");
        require(
            stakeIndex < stakeListRef.length,
            "JACKPOT: stakeIndex invalid"
        );
        StakeCache memory st;
        _stakeLoad(stakeListRef[stakeIndex], stakeIdParam, st);
        _dailyDataUpdateAuto(g);
        _globalsSync(g, gSnapshot);
        uint256 servedDays = 0;
        bool prevUnlocked = (st._unlockedDay != 0);
        uint256 stakeReturn;
        uint256 payout = 0;
        uint256 dividends = 0;
        uint256 penalty = 0;
        uint256 cappedPenalty = 0;
        if (g._currentDay >= st._lockedDay) {
            if (prevUnlocked) {
                servedDays = st._stakedDays;
            } else {
                _stakeUnlock(g, st);
                servedDays = g._currentDay.sub(st._lockedDay);
                if (servedDays > st._stakedDays) {
                    servedDays = st._stakedDays;
                }
            }
            (
                stakeReturn,
                payout,
                dividends,
                penalty,
                cappedPenalty
            ) = _stakePerformance(g, st, servedDays);
            msg.sender.transfer(dividends);
        } else {
            g._nextStakeSharesTotal = g._nextStakeSharesTotal.sub(st._stakeShares);
            stakeReturn = st._stakedSuns;
        }
        emit StakeEnd(
            stakeIdParam,
            prevUnlocked ? 1 : 0,
            msg.sender,
            st._lockedDay,
            servedDays,
            st._stakedSuns,
            st._stakeShares,
            payout,
            penalty,
            stakeReturn
        );
        if (cappedPenalty != 0 && !prevUnlocked) {
            g._stakePenaltyTotal = g._stakePenaltyTotal.add(cappedPenalty);
        }
        if (stakeReturn != 0) {
            _mint(msg.sender, stakeReturn);
            _shareRateUpdate(g, st, stakeReturn);
        }
        g._lockedSunsTotal = g._lockedSunsTotal.sub(st._stakedSuns);
        stakeListRef[stakeIndex].unlockedDay = uint16(
            g._currentDay.mod(uint256(uint16(-1)))
        );
        UnstakeStore memory endedInfo;
        endedInfo.stakeId = stakeListRef[stakeIndex].stakeId;
        endedInfo.stakedSuns = stakeListRef[stakeIndex].stakedSuns;
        endedInfo.stakeShares = stakeListRef[stakeIndex].stakeShares;
        endedInfo.lockedDay = stakeListRef[stakeIndex].lockedDay;
        endedInfo.stakedDays = stakeListRef[stakeIndex].stakedDays;
        endedInfo.unlockedDay = stakeListRef[stakeIndex].unlockedDay;
        endedInfo.unstakePayout = stakeReturn;
        endedInfo.unstakeDividends = dividends;
        endedStakeLists[_msgSender()].push(endedInfo);
        _stakeRemove(stakeListRef, stakeIndex);
        _globalsSync(g, gSnapshot);
    }

    uint256 private undestributedLotery = 0;

    function endLoteryDay(uint256 endDay) public onlyAfterNDays(0) {

        uint256 currDay = _currentDay();
        if (currDay == 0) return;
        if (endDay >= currDay) endDay = currDay.sub(1);
        if (
            endDay == currDay.sub(1) &&
            now % ROUND_TIME <= LOTERY_ENTRY_TIME &&
            endDay > 0
        ) endDay = endDay.sub(1);
        else if (
            endDay == currDay.sub(1) &&
            now % ROUND_TIME <= LOTERY_ENTRY_TIME &&
            endDay == 0
        ) return;
        while (lastEndedLoteryDay <= endDay) {
            uint256 ChanceCount = dayChanceCount[lastEndedLoteryDay];
            if (ChanceCount == 0) {
                undestributedLotery = undestributedLotery.add(xfLobby[lastEndedLoteryDay].mul(25).div(1000));
                lastEndedLoteryDay = lastEndedLoteryDay.add(1);
                continue;
            }
            uint256 randomInt = _random(ChanceCount);
            uint256 count = 0;
            uint256 ind = 0;
            while (count < randomInt) {
                uint256 newChanceCount =
                    loteryCount[lastEndedLoteryDay][ind].chanceCount;
                if (count.add(newChanceCount) >= randomInt) break;
                count = count.add(newChanceCount);
                ind = ind.add(1);
            }
            uint256 amount = xfLobby[lastEndedLoteryDay].mul(25).div(1000);
            if (undestributedLotery > 0) {
                amount = amount.add(undestributedLotery);
                undestributedLotery = 0;
            }
            winners[lastEndedLoteryDay] = winLoteryStat(
                address(uint160(loteryCount[lastEndedLoteryDay][ind].who)),
                amount,
                amount
            );
            lastEndedLoteryDayWithWinner = lastEndedLoteryDay;
            emit loteryWin(
                lastEndedLoteryDay,
                amount,
                winners[lastEndedLoteryDay].who
            );
            lastEndedLoteryDay = lastEndedLoteryDay.add(1);
        }
    }

    function loteryCountLen(uint256 day) external view returns (uint256) {

        return loteryCount[day].length;
    }

    function withdrawLotery(uint256 day) public {

        if (winners[day].restAmount != 0) {
            winners[day].who.transfer(winners[day].restAmount);
            winners[day].restAmount = 0;
        }
    }

    uint256 private nonce = 0;

    function _random(uint256 limit) private returns (uint256) {

        uint256 randomnumber =
            uint256(
                keccak256(
                    abi.encodePacked(
                        now,
                        msg.sender,
                        nonce,
                        blockhash(block.number),
                        block.number,
                        block.coinbase,
                        block.difficulty
                    )
                )
            ) % limit;
        nonce = nonce.add(1);
        return randomnumber;
    }

    function endedStakeCount(address stakerAddr)
        external
        view
        returns (uint256)
    {

        return endedStakeLists[stakerAddr].length;
    }

    function stakeCount(address stakerAddr) external view returns (uint256) {

        return stakeLists[stakerAddr].length;
    }

    function _stakeStart(
        GlobalsCache memory g,
        uint256 newStakedSuns,
        uint256 newStakedDays
    ) internal {

        require(
            newStakedDays <= MAX_STAKE_DAYS,
            "JACKPOT: newStakedDays higher than maximum"
        );
        uint256 bonusSuns = _stakeStartBonusSuns(newStakedSuns, newStakedDays);
        uint256 newStakeShares = newStakedSuns.add(bonusSuns).mul(SHARE_RATE_SCALE).div(g._shareRate);
        require(
            newStakeShares != 0,
            "JACKPOT: newStakedSuns must be at least minimum shareRate"
        );
        uint256 newLockedDay = g._currentDay.add(1);
        g._latestStakeId = uint40(uint256(g._latestStakeId).add(1));
        uint40 newStakeId = g._latestStakeId;
        _stakeAdd(
            stakeLists[msg.sender],
            newStakeId,
            newStakedSuns,
            newStakeShares,
            newLockedDay,
            newStakedDays
        );
        emit StakeStart(
            newStakeId,
            msg.sender,
            newStakedSuns,
            newStakeShares,
            newStakedDays
        );
        g._nextStakeSharesTotal = g._nextStakeSharesTotal.add(newStakeShares);
        g._lockedSunsTotal = g._lockedSunsTotal.add(newStakedSuns);
    }

    function calcPayoutRewards(
        uint256 stakeSharesParam,
        uint256 beginDay,
        uint256 endDay
    ) public view returns (uint256 payout) {

        uint256 currDay = _currentDay();
        require(beginDay <= currDay, "JACKPOT: Wrong argument for beginDay");
        require(
            endDay <= currDay && beginDay <= endDay,
            "JACKPOT: Wrong argument for endDay"
        );
        require(globals.latestStakeId != 0, "JACKPOT: latestStakeId error.");
        if (beginDay == endDay) return 0;
        uint256 counter;
        uint256 day = beginDay;
        while (day < endDay && day < globals.dailyDataCount) {
            uint256 dayPayout;
            dayPayout =
                dailyData[day].dayPayoutTotal.mul(stakeSharesParam).div(dailyData[day].dayStakeSharesTotal);
            if (counter < 4) {
                counter = counter.add(1);
            }
            else {
                dayPayout =
                    dailyData[day].dayPayoutTotal.mul(stakeSharesParam).div(dailyData[day].dayStakeSharesTotal).mul(BONUS_DAY_SCALE);
                counter = 0;
            }
            payout = payout.add(dayPayout);
            day = day.add(1);
        }
        uint256 dayStakeSharesTotal =
            dailyData[uint256(globals.dailyDataCount).sub(1)].dayStakeSharesTotal;
        if (dayStakeSharesTotal == 0) dayStakeSharesTotal = stakeSharesParam;
        uint256 dayPayoutTotal =
            dailyData[uint256(globals.dailyDataCount).sub(1)].dayPayoutTotal;
        while (day < endDay) {
            uint256 dayPayout;
            dayPayout =
                dayPayoutTotal.mul(stakeSharesParam).div(dayStakeSharesTotal);
            if (counter < 4) {
                counter = counter.add(1);
            }
            else {
                dayPayout =
                    dayPayoutTotal.mul(stakeSharesParam).div(dayStakeSharesTotal).mul(BONUS_DAY_SCALE);
                counter = 0;
            }
            payout = payout.add(dayPayout);
            day = day.add(1);
        }
        return payout;
    }

    function calcPayoutRewardsBonusDays(
        uint256 stakeSharesParam,
        uint256 beginDay,
        uint256 endDay
    ) external view returns (uint256 payout) {

        uint256 currDay = _currentDay();
        require(beginDay <= currDay, "JACKPOT: Wrong argument for beginDay");
        require(
            endDay <= currDay && beginDay <= endDay,
            "JACKPOT: Wrong argument for endDay"
        );
        require(globals.latestStakeId != 0, "JACKPOT: latestStakeId error.");
        if (beginDay == endDay) return 0;
        uint256 day = beginDay.add(5);
        while (day < endDay && day < globals.dailyDataCount) {
            payout = payout.add(dailyData[day].dayPayoutTotal.mul(stakeSharesParam).div(dailyData[day].dayStakeSharesTotal));
            day = day.add(5);
        }
        uint256 dayStakeSharesTotal =
            dailyData[uint256(globals.dailyDataCount).sub(1)].dayStakeSharesTotal;
        if (dayStakeSharesTotal == 0) dayStakeSharesTotal = stakeSharesParam;
        uint256 dayPayoutTotal =
            dailyData[uint256(globals.dailyDataCount).sub(1)].dayPayoutTotal;
        while (day < endDay) {
            payout = payout.add(dayPayoutTotal.mul(stakeSharesParam).div(dayStakeSharesTotal));
            day = day.add(5);
        }
        return payout;
    }

    function calcPayoutDividendsReward(
        uint256 stakeSharesParam,
        uint256 beginDay,
        uint256 endDay
    ) public view returns (uint256 payout) {

        uint256 currDay = _currentDay();
        require(beginDay <= currDay, "JACKPOT: Wrong argument for beginDay");
        require(
            endDay <= currDay && beginDay <= endDay,
            "JACKPOT: Wrong argument for endDay"
        );
        require(globals.latestStakeId != 0, "JACKPOT: latestStakeId error.");
        if (beginDay == endDay) return 0;
        uint256 day = beginDay;
        while (day < endDay && day < globals.dailyDataCount) {
            uint256 dayPayout;
            dayPayout = dayPayout.add(dailyData[day].dayDividends.mul(90).div(100).mul(stakeSharesParam).div(dailyData[day].dayStakeSharesTotal));
            payout = payout.add(dayPayout);
            day = day.add(1);
        }
        uint256 dayStakeSharesTotal =
            dailyData[uint256(globals.dailyDataCount).sub(1)].dayStakeSharesTotal;
        if (dayStakeSharesTotal == 0) dayStakeSharesTotal = stakeSharesParam;
        while (day < endDay) {
            uint256 dayPayout;
            dayPayout = dayPayout.add(xfLobby[day].mul(90).div(100).mul(stakeSharesParam).div(dayStakeSharesTotal));
            payout = payout.add(dayPayout);
            day = day.add(1);
        }
        return payout;
    }

    function _stakeStartBonusSuns(uint256 newStakedSuns, uint256 newStakedDays)
        private
        pure
        returns (uint256 bonusSuns)
    {

        uint256 cappedExtraDays = 0;
        if (newStakedDays > 1) {
            cappedExtraDays = newStakedDays.sub(1) <= LPB_MAX_DAYS
                ? newStakedDays.sub(1)
                : LPB_MAX_DAYS;
        }
        uint256 cappedStakedSuns =
            newStakedSuns <= BPB_MAX_SUNS ? newStakedSuns : BPB_MAX_SUNS;
        bonusSuns = cappedExtraDays.mul(BPB).add(cappedStakedSuns.mul(LPB));
        bonusSuns = newStakedSuns.mul(bonusSuns).div(LPB.mul(BPB));
        return bonusSuns;
    }

    function _stakeUnlock(GlobalsCache memory g, StakeCache memory st)
        private
        pure
    {

        g._stakeSharesTotal = g._stakeSharesTotal.sub(st._stakeShares);
        st._unlockedDay = g._currentDay;
    }

    function _stakePerformance(
        GlobalsCache memory g,
        StakeCache memory st,
        uint256 servedDays
    )
        private
        view
        returns (
            uint256 stakeReturn,
            uint256 payout,
            uint256 dividends,
            uint256 penalty,
            uint256 cappedPenalty
        )
    {

        if (servedDays < st._stakedDays) {
            (payout, penalty) = _calcPayoutAndEarlyPenalty(
                g,
                st._lockedDay,
                st._stakedDays,
                servedDays,
                st._stakeShares
            );
            stakeReturn = st._stakedSuns.add(payout);
            dividends = calcPayoutDividendsReward(
                st._stakeShares,
                st._lockedDay,
                st._lockedDay.add(servedDays)
            );
        } else {
            payout = calcPayoutRewards(
                st._stakeShares,
                st._lockedDay,
                st._lockedDay.add(servedDays)
            );
            dividends = calcPayoutDividendsReward(
                st._stakeShares,
                st._lockedDay,
                st._lockedDay.add(servedDays)
            );
            stakeReturn = st._stakedSuns.add(payout);
            penalty = _calcLatePenalty(
                st._lockedDay,
                st._stakedDays,
                st._unlockedDay,
                stakeReturn
            );
        }
        if (penalty != 0) {
            if (penalty > stakeReturn) {
                cappedPenalty = stakeReturn;
                stakeReturn = 0;
            } else {
                cappedPenalty = penalty;
                stakeReturn = stakeReturn.sub(cappedPenalty);
            }
        }
        return (stakeReturn, payout, dividends, penalty, cappedPenalty);
    }

    function getUnstakeParams(
        address user,
        uint256 stakeIndex,
        uint40 stakeIdParam
    )
        external
        view
        returns (
            uint256 stakeReturn,
            uint256 payout,
            uint256 dividends,
            uint256 penalty,
            uint256 cappedPenalty
        )
    {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);
        StakeStore[] storage stakeListRef = stakeLists[user];
        require(stakeListRef.length != 0, "JACKPOT: Empty stake list");
        require(
            stakeIndex < stakeListRef.length,
            "JACKPOT: stakeIndex invalid"
        );
        StakeCache memory st;
        _stakeLoad(stakeListRef[stakeIndex], stakeIdParam, st);
        uint256 servedDays = 0;
        bool prevUnlocked = (st._unlockedDay != 0);
        if (g._currentDay >= st._lockedDay) {
            if (prevUnlocked) {
                servedDays = st._stakedDays;
            } else {
                _stakeUnlock(g, st);
                servedDays = g._currentDay.sub(st._lockedDay);
                if (servedDays > st._stakedDays) {
                    servedDays = st._stakedDays;
                }
            }
            (
                stakeReturn,
                payout,
                dividends,
                penalty,
                cappedPenalty
            ) = _stakePerformance(g, st, servedDays);
        } else {
            stakeReturn = st._stakedSuns;
        }
        return (stakeReturn, payout, dividends, penalty, cappedPenalty);
    }

    function _calcPayoutAndEarlyPenalty(
        GlobalsCache memory g,
        uint256 lockedDayParam,
        uint256 stakedDaysParam,
        uint256 servedDays,
        uint256 stakeSharesParam
    ) private view returns (uint256 payout, uint256 penalty) {

        uint256 servedEndDay = lockedDayParam.add(servedDays);
        uint256 penaltyDays = stakedDaysParam.add(1).div(2);
        if (penaltyDays < EARLY_PENALTY_MIN_DAYS) {
            penaltyDays = EARLY_PENALTY_MIN_DAYS;
        }
        if (servedDays == 0) {
            uint256 expected = _estimatePayoutRewardsDay(g, stakeSharesParam);
            penalty = expected.mul(penaltyDays);
            return (payout, penalty); // Actual payout was 0
        }
        if (penaltyDays < servedDays) {
            uint256 penaltyEndDay = lockedDayParam.add(penaltyDays);
            penalty = calcPayoutRewards(
                stakeSharesParam,
                lockedDayParam,
                penaltyEndDay
            );
            uint256 delta =
                calcPayoutRewards(
                    stakeSharesParam,
                    penaltyEndDay,
                    servedEndDay
                );
            payout = penalty.add(delta);
            return (payout, penalty);
        }
        payout = calcPayoutRewards(
            stakeSharesParam,
            lockedDayParam,
            servedEndDay
        );
        if (penaltyDays == servedDays) {
            penalty = payout;
        } else {
            penalty = payout.mul(penaltyDays).div(servedDays);
        }
        return (payout, penalty);
    }

    function _calcLatePenalty(
        uint256 lockedDayParam,
        uint256 stakedDaysParam,
        uint256 unlockedDayParam,
        uint256 rawStakeReturn
    ) private pure returns (uint256) {

        uint256 maxUnlockedDay =
            lockedDayParam.add(stakedDaysParam).add(LATE_PENALTY_GRACE_DAYS);
        if (unlockedDayParam <= maxUnlockedDay) {
            return 0;
        }
        return rawStakeReturn.mul(unlockedDayParam.sub(maxUnlockedDay)).div(LATE_PENALTY_SCALE_DAYS);
    }

    function _shareRateUpdate(
        GlobalsCache memory g,
        StakeCache memory st,
        uint256 stakeReturn
    ) private {

        if (stakeReturn > st._stakedSuns) {
            uint256 bonusSuns =
                _stakeStartBonusSuns(stakeReturn, st._stakedDays);
            uint256 newShareRate =
                stakeReturn.add(bonusSuns).mul(SHARE_RATE_SCALE).div(st._stakeShares);
            if (newShareRate > SHARE_RATE_MAX) {
                newShareRate = SHARE_RATE_MAX;
            }
            if (newShareRate > g._shareRate) {
                g._shareRate = newShareRate;
                emit ShareRateChange(
                    st._stakeId,
                    block.timestamp,
                    newShareRate
                );
            }
        }
    }
}

contract TransformableToken is StakeableToken {

    function xfLobbyEnter(address referrerAddr) external payable {

        require(now >= LAUNCH_TIME, "JACKPOT: Too early");
        uint256 enterDay = _currentDay();
        require(enterDay < 365, "JACKPOT: Auction only first 365 days");
        if (firstAuction == uint256(-1)) firstAuction = enterDay;
        if (enterDay >= 1) endLoteryDay(enterDay.sub(1));
        uint256 rawAmount = msg.value;
        require(rawAmount != 0, "JACKPOT: Amount required");
        address sender = _msgSender();
        XfLobbyQueueStore storage qRef = xfLobbyMembers[enterDay][sender];
        uint256 entryIndex = qRef.tailIndex++;
        qRef.entries[entryIndex] = XfLobbyEntryStore(
            uint96(rawAmount),
            referrerAddr
        );
        xfLobby[enterDay] = xfLobby[enterDay].add(rawAmount);
        uint256 dayNumberNow = whatDayIsItToday(enterDay);
        bool is_good = block.timestamp.sub(LAUNCH_TIME) % ROUND_TIME <= LOTERY_ENTRY_TIME;
        if (
            is_good &&
            dayNumberNow % 2 == 1 &&
            loteryLobby[enterDay][sender].chanceCount == 0
        ) {
            loteryLobby[enterDay][sender].change = 0;
            loteryLobby[enterDay][sender].chanceCount = 1;
            dayChanceCount[enterDay] = dayChanceCount[enterDay].add(1);
            loteryCount[enterDay].push(LoteryCount(sender, 1));

            _updateLoteryDayWaitingForWinner(enterDay);

            emit loteryLobbyEnter(block.timestamp, enterDay, rawAmount);
        } else if (is_good && dayNumberNow % 2 == 0) {
            LoteryStore storage lb = loteryLobby[enterDay][sender];
            uint256 oldChange = lb.change;
            lb.change = oldChange.add(rawAmount) % 1 ether;
            uint256 newEth = oldChange.add(rawAmount).div(1 ether);
            if (newEth > 0) {
                lb.chanceCount = lb.chanceCount.add(newEth);
                dayChanceCount[enterDay] = dayChanceCount[enterDay].add(newEth);
                loteryCount[enterDay].push(LoteryCount(sender, newEth));

                _updateLoteryDayWaitingForWinner(enterDay);

                emit loteryLobbyEnter(block.timestamp, enterDay, rawAmount);
            }
        }
        emit XfLobbyEnter(block.timestamp, enterDay, entryIndex, rawAmount);
    }

    function _updateLoteryDayWaitingForWinner(uint256 enterDay) private {

        if (dayChanceCount[loteryDayWaitingForWinner] == 0) {
            loteryDayWaitingForWinner = enterDay;
            loteryDayWaitingForWinnerNew = enterDay;
        } else if (loteryDayWaitingForWinnerNew < enterDay) {
            loteryDayWaitingForWinner = loteryDayWaitingForWinnerNew;
            loteryDayWaitingForWinnerNew = enterDay;
        }
    }

    function whatDayIsItToday(uint256 day) public view returns (uint256) {

        return dayNumberBegin.add(day) % 7;
    }

    function xfLobbyExit(uint256 enterDay, uint256 count) external {

        uint256 currDay = _currentDay();
        require(enterDay < currDay, "JACKPOT: Round is not complete");
        if (currDay >= 1) endLoteryDay(currDay.sub(1));
        XfLobbyQueueStore storage qRef = xfLobbyMembers[enterDay][msg.sender];
        uint256 headIndex = qRef.headIndex;
        uint256 endIndex;
        if (count != 0) {
            require(
                count <= uint256(qRef.tailIndex).sub(headIndex),
                "JACKPOT: count invalid"
            );
            endIndex = headIndex.add(count);
        } else {
            endIndex = qRef.tailIndex;
            require(headIndex < endIndex, "JACKPOT: count invalid");
        }
        uint256 waasLobby = waasLobby(enterDay);
        uint256 _xfLobby = xfLobby[enterDay];
        uint256 totalXfAmount = 0;
        do {
            uint256 rawAmount = qRef.entries[headIndex].rawAmount;
            address referrerAddr = qRef.entries[headIndex].referrerAddr;
            uint256 xfAmount = waasLobby.mul(rawAmount).div(_xfLobby);
            if (
                (referrerAddr == address(0) || referrerAddr == msg.sender) &&
                defaultReferrerAddr == address(0)
            ) {
                _emitXfLobbyExit(enterDay, headIndex, xfAmount, referrerAddr);
            } else {
                if (referrerAddr == address(0) || referrerAddr == msg.sender) {
                    uint256 referrerBonusSuns = xfAmount.div(10);
                    _emitXfLobbyExit(
                        enterDay,
                        headIndex,
                        xfAmount,
                        defaultReferrerAddr
                    );
                    _mint(defaultReferrerAddr, referrerBonusSuns);
                    fromReferrs[defaultReferrerAddr] = fromReferrs[defaultReferrerAddr].add(referrerBonusSuns);
                } else {
                    xfAmount = xfAmount.add(xfAmount.div(10));
                    uint256 referrerBonusSuns = xfAmount.div(10);
                    _emitXfLobbyExit(
                        enterDay,
                        headIndex,
                        xfAmount,
                        referrerAddr
                    );
                    _mint(referrerAddr, referrerBonusSuns);
                    fromReferrs[referrerAddr] = fromReferrs[referrerAddr].add(referrerBonusSuns);
                }
            }
            totalXfAmount = totalXfAmount.add(xfAmount);
        } while (++headIndex < endIndex);
        qRef.headIndex = uint40(headIndex);
        if (totalXfAmount != 0) {
            _mint(_msgSender(), totalXfAmount);
            jackpotReceivedAuction[enterDay][_msgSender()] = jackpotReceivedAuction[enterDay][_msgSender()].add(totalXfAmount);
        }
    }

    function xfFlush() external onlyOwner {

        if (LAST_FLUSHED_DAY < firstAuction.add(2))
            LAST_FLUSHED_DAY = firstAuction.add(2);
        require(address(this).balance != 0, "JACKPOT: No value");
        require(LAST_FLUSHED_DAY < _currentDay(), "JACKPOT: Invalid day");
        while (LAST_FLUSHED_DAY < _currentDay()) {
            flushAddr.transfer(xfLobby[LAST_FLUSHED_DAY].mul(75).div(1000));
            LAST_FLUSHED_DAY = LAST_FLUSHED_DAY.add(1);
        }
    }

    function xfLobbyEntry(
        address memberAddr,
        uint256 enterDay,
        uint256 entryIndex
    ) external view returns (uint256 rawAmount, address referrerAddr) {

        XfLobbyEntryStore storage entry =
            xfLobbyMembers[enterDay][memberAddr].entries[entryIndex];
        require(entry.rawAmount != 0, "JACKPOT: Param invalid");
        return (entry.rawAmount, entry.referrerAddr);
    }

    function waasLobby(uint256 enterDay)
        public
        pure
        returns (uint256 _waasLobby)
    {

        if (enterDay >= 0 && enterDay <= 365) {
            _waasLobby = CLAIM_STARTING_AMOUNT.sub(enterDay.mul(410958904109));
        } else {
            _waasLobby = CLAIM_LOWEST_AMOUNT;
        }
        return _waasLobby;
    }

    function _emitXfLobbyExit(
        uint256 enterDay,
        uint256 entryIndex,
        uint256 xfAmount,
        address referrerAddr
    ) private {

        emit XfLobbyExit(
            block.timestamp,
            enterDay,
            entryIndex,
            xfAmount,
            referrerAddr
        );
    }
}

contract Jackpot is TransformableToken {

    constructor(
        uint256 _LAUNCH_TIME,
        uint256 _dayNumberBegin,
        uint256 _ROUND_TIME,
        uint256 _LOTERY_ENTRY_TIME
    ) public {
        require(_dayNumberBegin > 0 && _dayNumberBegin < 7);
        LAUNCH_TIME = _LAUNCH_TIME;
        dayNumberBegin = _dayNumberBegin;
        ROUND_TIME = _ROUND_TIME;
        LOTERY_ENTRY_TIME = _LOTERY_ENTRY_TIME;
        globals.shareRate = uint40(SHARE_RATE_SCALE);
        uint256 currDay;
        if (block.timestamp < _LAUNCH_TIME)
            currDay = 0;
        else
            currDay = _currentDay();
        lastEndedLoteryDay = currDay;
        globals.dailyDataCount = uint16(currDay);
        lastEndedLoteryDayWithWinner = currDay;
        loteryDayWaitingForWinner = currDay;
        loteryDayWaitingForWinnerNew = currDay;
    }

    function() external payable {}

    function setDefaultReferrerAddr(address _defaultReferrerAddr)
        external
        onlyOwner
    {

        defaultReferrerAddr = _defaultReferrerAddr;
    }

    function setFlushAddr(address payable _flushAddr) external onlyOwner {

        flushAddr = _flushAddr;
    }

    function getDayUnixTime(uint256 day) external view returns (uint256) {

        return LAUNCH_TIME.add(day.mul(ROUND_TIME));
    }

    function getFirstAuction() external view returns (bool, uint256) {

        if (firstAuction == uint256(-1)) return (false, 0);
        else return (true, firstAuction);
    }

    bool private isFirstTwoDaysWithdrawed = false;

    function ownerClaimFirstTwoDays() external onlyOwner onlyAfterNDays(2) {

        require(
            isFirstTwoDaysWithdrawed == false,
            "JACKPOT: Already withdrawed"
        );

        flushAddr.transfer(xfLobby[firstAuction].add(xfLobby[firstAuction.add(1)]));

        isFirstTwoDaysWithdrawed = true;
    }
}