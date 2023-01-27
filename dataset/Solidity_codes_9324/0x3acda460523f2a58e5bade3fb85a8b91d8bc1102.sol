

pragma solidity 0.5.10;

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

interface TRC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract ERC20 is Context, TRC20 {

    using SafeMath for uint256;

    address admin;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply = 500000000 * (10 ** 8);

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

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint amountRec = amount;
        uint amountBurn = 0;

        if(sender != admin && recipient != admin){   //this is for the initial Pool Liquidity
            amountBurn = amount.mul(5).div(100);
            amountRec = amount.sub(amountBurn);
        }
        
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amountRec);
        _totalSupply = _totalSupply.sub(amountBurn);

        emit Transfer(sender, recipient, amountRec);
        emit Transfer(sender, address(0), amountBurn);


    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) external {

        require(_balances[msg.sender] >= amount, "ERC20: not enough balance!");

        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
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
        uint256 dividends,
        uint256 payout,
        uint256 penalty,
        uint256 stakeReturn
    );

    event ShareRateChange(
        uint40 indexed stakeId,
        uint256 timestamp,
        uint256 newShareRate
    );

    address payable internal LIQUIDITY_ADDR;

    uint8 internal LAST_FLUSHED_DAY = 1;

    string public constant name = "LUUV.LIFE";
    string public constant symbol = "LUUV";
    uint8 public constant decimals = 8;

    uint256 private constant SUNS_PER_E2X = 10 ** uint256(decimals); // 1e8

    
    uint256 internal LAUNCH_TIME = 1605916800;

    uint256 internal constant PRE_CLAIM_DAYS = 1;
    uint256 internal constant CLAIM_STARTING_AMOUNT = 5000000 * (10 ** 8);
    uint256 internal constant CLAIM_LOWEST_AMOUNT = 100000 * (10 ** 8);
    uint256 internal constant CLAIM_PHASE_START_DAY = PRE_CLAIM_DAYS;

    uint256 internal constant XF_LOBBY_DAY_WORDS = ((1 + (50 * 7)) + 255) >> 8;

    uint256 internal constant MIN_STAKE_DAYS = 1;

    uint256 internal constant MAX_STAKE_DAYS = 365;

    uint256 internal constant EARLY_PENALTY_MIN_DAYS = 90;

    uint256 private constant LATE_PENALTY_GRACE_WEEKS = 2;
    uint256 internal constant LATE_PENALTY_GRACE_DAYS = LATE_PENALTY_GRACE_WEEKS * 7;

    uint256 private constant LATE_PENALTY_SCALE_WEEKS = 100;
    uint256 internal constant LATE_PENALTY_SCALE_DAYS = LATE_PENALTY_SCALE_WEEKS * 7;

    uint256 private constant LPB_BONUS_PERCENT = 20;
    uint256 private constant LPB_BONUS_MAX_PERCENT = 200;
    uint256 internal constant LPB = 364 * 100 / LPB_BONUS_PERCENT;
    uint256 internal constant LPB_MAX_DAYS = LPB * LPB_BONUS_MAX_PERCENT / 100;

    uint256 private constant BPB_BONUS_PERCENT = 10;
    uint256 private constant BPB_MAX_E2X = 7 * 1e6;
    uint256 internal constant BPB_MAX_SUNS = BPB_MAX_E2X * SUNS_PER_E2X;
    uint256 internal constant BPB = BPB_MAX_SUNS * 100 / BPB_BONUS_PERCENT;

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
        uint72 lockedSunsTotal;
        uint72 nextStakeSharesTotal;
        uint40 shareRate;
        uint72 stakePenaltyTotal;
        uint16 dailyDataCount;
        uint72 stakeSharesTotal;
        uint40 latestStakeId;
    }

    GlobalsStore public globals;

    struct DailyDataStore {
        uint72 dayPayoutTotal;
        uint256 dayDividends;
        uint72 dayStakeSharesTotal;
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
        uint72 stakedSuns;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
    }

    mapping(address => StakeStore[]) public stakeLists;

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
    mapping(uint256 => mapping(address => XfLobbyQueueStore)) public xfLobbyMembers;

    function dailyDataUpdate(uint256 beforeDay)
        external
    {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        require(g._currentDay > CLAIM_PHASE_START_DAY, "LUUV: Too early");

        if (beforeDay != 0) {
            require(beforeDay <= g._currentDay, "LUUV: beforeDay cannot be in the future");

            _dailyDataUpdate(g, beforeDay, false);
        } else {
            _dailyDataUpdate(g, g._currentDay, false);
        }

        _globalsSync(g, gSnapshot);
    }

    function dailyDataRange(uint256 beginDay, uint256 endDay)
        external
        view
        returns (uint256[] memory _dayStakeSharesTotal, uint256[] memory _dayPayoutTotal, uint256[] memory _dayDividends)
    {

        require(beginDay < endDay && endDay <= globals.dailyDataCount, "LUUV: range invalid");

        _dayStakeSharesTotal = new uint256[](endDay - beginDay);
        _dayPayoutTotal = new uint256[](endDay - beginDay);
        _dayDividends = new uint256[](endDay - beginDay);

        uint256 src = beginDay;
        uint256 dst = 0;
        do {
            _dayStakeSharesTotal[dst] = uint256(dailyData[src].dayStakeSharesTotal);
            _dayPayoutTotal[dst++] = uint256(dailyData[src].dayPayoutTotal);
            _dayDividends[dst++] = dailyData[src].dayDividends;
        } while (++src < endDay);

        return (_dayStakeSharesTotal, _dayPayoutTotal, _dayDividends);
    }


    function globalInfo()
        external
        view
        returns (uint256[10] memory)
    {


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

    function allocatedSupply()
        external
        view
        returns (uint256)
    {

        return totalSupply() + globals.lockedSunsTotal;
    }

    function currentDay()
        external
        view
        returns (uint256)
    {

        return _currentDay();
    }

    function _currentDay()
        internal
        view
        returns (uint256)
    {

        if (block.timestamp < LAUNCH_TIME){
             return 0;
        }else{
             return (block.timestamp - LAUNCH_TIME) / 1 days; 
        }
    }

    function _dailyDataUpdateAuto(GlobalsCache memory g)
        internal
    {

        _dailyDataUpdate(g, g._currentDay, true);
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

    function _globalsCacheSnapshot(GlobalsCache memory g, GlobalsCache memory gSnapshot)
        internal
        pure
    {

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

        if (g._lockedSunsTotal != gSnapshot._lockedSunsTotal
            || g._nextStakeSharesTotal != gSnapshot._nextStakeSharesTotal
            || g._shareRate != gSnapshot._shareRate
            || g._stakePenaltyTotal != gSnapshot._stakePenaltyTotal) {
            globals.lockedSunsTotal = uint72(g._lockedSunsTotal);
            globals.nextStakeSharesTotal = uint72(g._nextStakeSharesTotal);
            globals.shareRate = uint40(g._shareRate);
            globals.stakePenaltyTotal = uint72(g._stakePenaltyTotal);
        }
        if (g._dailyDataCount != gSnapshot._dailyDataCount
            || g._stakeSharesTotal != gSnapshot._stakeSharesTotal
            || g._latestStakeId != gSnapshot._latestStakeId) {
            globals.dailyDataCount = uint16(g._dailyDataCount);
            globals.stakeSharesTotal = uint72(g._stakeSharesTotal);
            globals.latestStakeId = g._latestStakeId;
        }
    }

    function _stakeLoad(StakeStore storage stRef, uint40 stakeIdParam, StakeCache memory st)
        internal
        view
    {

        require(stakeIdParam == stRef.stakeId, "LUUV: stakeIdParam not in stake");

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
        stRef.stakedSuns = uint72(st._stakedSuns);
        stRef.stakeShares = uint72(st._stakeShares);
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
    )
        internal
    {

        stakeListRef.push(
            StakeStore(
                newStakeId,
                uint72(newStakedSuns),
                uint72(newStakeShares),
                uint16(newLockedDay),
                uint16(newStakedDays),
                uint16(0) // unlockedDay
            )
        );
    }

    function _stakeRemove(StakeStore[] storage stakeListRef, uint256 stakeIndex)
        internal
    {

        uint256 lastIndex = stakeListRef.length - 1;

        if (stakeIndex != lastIndex) {
            stakeListRef[stakeIndex] = stakeListRef[lastIndex];
        }

        stakeListRef.pop();
    }

    function _estimatePayoutRewardsDay(GlobalsCache memory g, uint256 stakeSharesParam, uint256 day)
        internal
        view
        returns (uint256 payout)
    {

        GlobalsCache memory gTmp;
        _globalsCacheSnapshot(g, gTmp);

        DailyRoundState memory rs;
        rs._allocSupplyCached = totalSupply() + g._lockedSunsTotal;

        _dailyRoundCalc(gTmp, rs, day);

        gTmp._stakeSharesTotal += stakeSharesParam;

        payout = rs._payoutTotal * stakeSharesParam / gTmp._stakeSharesTotal;

        return payout;
    }

    function _dailyRoundCalc(GlobalsCache memory g, DailyRoundState memory rs, uint256 day)
        private
        view
    {

        
        rs._payoutTotal = (rs._allocSupplyCached * 50000 / 68854153);
       

        if (g._stakePenaltyTotal != 0) {
            rs._payoutTotal += g._stakePenaltyTotal;
            g._stakePenaltyTotal = 0;
        }
    }

    function _dailyRoundCalcAndStore(GlobalsCache memory g, DailyRoundState memory rs, uint256 day)
        private
    {

        _dailyRoundCalc(g, rs, day);

        dailyData[day].dayPayoutTotal = uint72(rs._payoutTotal);
        dailyData[day].dayDividends = xfLobby[day];
        dailyData[day].dayStakeSharesTotal = uint72(g._stakeSharesTotal);
    }

    function _dailyDataUpdate(GlobalsCache memory g, uint256 beforeDay, bool isAutoUpdate)
        private
    {

        if (g._dailyDataCount >= beforeDay) {
            return;
        }

        DailyRoundState memory rs;
        rs._allocSupplyCached = totalSupply() + g._lockedSunsTotal;

        uint256 day = g._dailyDataCount;

        _dailyRoundCalcAndStore(g, rs, day);

        if (g._nextStakeSharesTotal != 0) {
            g._stakeSharesTotal += g._nextStakeSharesTotal;
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

    function stakeStart(uint256 newStakedSuns, uint256 newStakedDays)
        external
    {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        require(newStakedDays >= MIN_STAKE_DAYS, "LUUV: newStakedDays lower than minimum");

        _dailyDataUpdateAuto(g);

        _stakeStart(g, newStakedSuns, newStakedDays);

        _burn(msg.sender, newStakedSuns);

        _globalsSync(g, gSnapshot);
    }

    function stakeGoodAccounting(address stakerAddr, uint256 stakeIndex, uint40 stakeIdParam)
        external
    {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        require(stakeLists[stakerAddr].length != 0, "LUUV: Empty stake list");
        require(stakeIndex < stakeLists[stakerAddr].length, "LUUV: stakeIndex invalid");

        StakeStore storage stRef = stakeLists[stakerAddr][stakeIndex];

        StakeCache memory st;
        _stakeLoad(stRef, stakeIdParam, st);

        require(g._currentDay >= st._lockedDay + st._stakedDays, "LUUV: Stake not fully served");

        require(st._unlockedDay == 0, "LUUV: Stake already unlocked");

        _dailyDataUpdateAuto(g);

        _stakeUnlock(g, st);

        (, uint256 payout, uint256 dividends, uint256 penalty, uint256 cappedPenalty) = _stakePerformance(
            g,
            st,
            st._stakedDays
        );

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
            g._stakePenaltyTotal += cappedPenalty;
        }

        _stakeUpdate(stRef, st);

        _globalsSync(g, gSnapshot);
    }

    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam)
        external
    {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        StakeStore[] storage stakeListRef = stakeLists[msg.sender];

        require(stakeListRef.length != 0, "LUUV: Empty stake list");
        require(stakeIndex < stakeListRef.length, "LUUV: stakeIndex invalid");

        StakeCache memory st;
        _stakeLoad(stakeListRef[stakeIndex], stakeIdParam, st);

        _dailyDataUpdateAuto(g);

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

                servedDays = g._currentDay - st._lockedDay;
                if (servedDays > st._stakedDays) {
                    servedDays = st._stakedDays;
                }
            }

            (stakeReturn, payout, dividends, penalty, cappedPenalty) = _stakePerformance(g, st, servedDays);

            msg.sender.transfer(dividends);
        } else {
            g._nextStakeSharesTotal -= st._stakeShares;

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
            dividends,
            payout, 
            penalty,
            stakeReturn
        );

        if (cappedPenalty != 0 && !prevUnlocked) {
            g._stakePenaltyTotal += cappedPenalty;
        }

        if (stakeReturn != 0) {
            _mint(msg.sender, stakeReturn);

            _shareRateUpdate(g, st, stakeReturn);

        }
        g._lockedSunsTotal -= st._stakedSuns;

        _stakeRemove(stakeListRef, stakeIndex);

        _globalsSync(g, gSnapshot);
    }

    function stakeCount(address stakerAddr)
        external
        view
        returns (uint256)
    {

        return stakeLists[stakerAddr].length;
    }

    function _stakeStart(
        GlobalsCache memory g,
        uint256 newStakedSuns,
        uint256 newStakedDays
    )
        internal
    {

        require(newStakedDays <= MAX_STAKE_DAYS, "LUUV: newStakedDays higher than maximum");

        uint256 bonusSuns = _stakeStartBonusSuns(newStakedSuns, newStakedDays);
        uint256 newStakeShares = (newStakedSuns + bonusSuns) * SHARE_RATE_SCALE / g._shareRate;

        require(newStakeShares != 0, "LUUV: newStakedSuns must be at least minimum shareRate");

        uint256 newLockedDay = g._currentDay + 1;

        uint40 newStakeId = ++g._latestStakeId;
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

        g._nextStakeSharesTotal += newStakeShares;

        g._lockedSunsTotal += newStakedSuns;
    }

    function _calcPayoutRewards(
        GlobalsCache memory g,
        uint256 stakeSharesParam,
        uint256 beginDay,
        uint256 endDay
    )
        private
        view
        returns (uint256 payout)
    {

        uint256 counter;

        for (uint256 day = beginDay; day < endDay; day++) {
            uint256 dayPayout;

            dayPayout = dailyData[day].dayPayoutTotal * stakeSharesParam
                / dailyData[day].dayStakeSharesTotal;

            if (counter < 4) {
                counter++;
            } 
            else {
                dayPayout = (dailyData[day].dayPayoutTotal * stakeSharesParam
                / dailyData[day].dayStakeSharesTotal) * BONUS_DAY_SCALE;
                counter = 0;
            }

            payout += dayPayout;
        }

        return payout;
    }

    function _calcPayoutDividendsReward(
        GlobalsCache memory g,
        uint256 stakeSharesParam,
        uint256 beginDay,
        uint256 endDay
    )
        private
        view
        returns (uint256 payout)
    {


        for (uint256 day = beginDay; day < endDay; day++) {
            uint256 dayPayout;

            dayPayout += ((dailyData[day].dayDividends * 0) / 100) * stakeSharesParam
            / dailyData[day].dayStakeSharesTotal;

            payout += dayPayout;
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
            cappedExtraDays = newStakedDays <= LPB_MAX_DAYS ? newStakedDays - 1 : LPB_MAX_DAYS;
        }

        uint256 cappedStakedSuns = newStakedSuns <= BPB_MAX_SUNS
            ? newStakedSuns
            : BPB_MAX_SUNS;

        bonusSuns = cappedExtraDays * BPB + cappedStakedSuns * LPB;
        bonusSuns = newStakedSuns * bonusSuns / (LPB * BPB);

        return bonusSuns;
    }

    function _stakeUnlock(GlobalsCache memory g, StakeCache memory st)
        private
        pure
    {

        g._stakeSharesTotal -= st._stakeShares;
        st._unlockedDay = g._currentDay;
    }

    function _stakePerformance(GlobalsCache memory g, StakeCache memory st, uint256 servedDays)
        private
        view
        returns (uint256 stakeReturn, uint256 payout, uint256 dividends, uint256 penalty, uint256 cappedPenalty)
    {

        if (servedDays < st._stakedDays) {
            (payout, penalty) = _calcPayoutAndEarlyPenalty(
                g,
                st._lockedDay,
                st._stakedDays,
                servedDays,
                st._stakeShares
            );
            stakeReturn = st._stakedSuns + payout;

            dividends = _calcPayoutDividendsReward(
                g,
                st._stakeShares,
                st._lockedDay,
                st._lockedDay + servedDays
            );
        } else {
            payout = _calcPayoutRewards(
                g,
                st._stakeShares,
                st._lockedDay,
                st._lockedDay + servedDays
            );

            dividends = _calcPayoutDividendsReward(
                g,
                st._stakeShares,
                st._lockedDay,
                st._lockedDay + servedDays
            );

            stakeReturn = st._stakedSuns + payout;

            penalty = _calcLatePenalty(st._lockedDay, st._stakedDays, st._unlockedDay, stakeReturn);
        }
        if (penalty != 0) {
            if (penalty > stakeReturn) {
                cappedPenalty = stakeReturn;
                stakeReturn = 0;
            } else {
                cappedPenalty = penalty;
                stakeReturn -= cappedPenalty;
            }
        }
        return (stakeReturn, payout, dividends, penalty, cappedPenalty);
    }

    function _calcPayoutAndEarlyPenalty(
        GlobalsCache memory g,
        uint256 lockedDayParam,
        uint256 stakedDaysParam,
        uint256 servedDays,
        uint256 stakeSharesParam
    )
        private
        view
        returns (uint256 payout, uint256 penalty)
    {

        uint256 servedEndDay = lockedDayParam + servedDays;

        uint256 penaltyDays = (stakedDaysParam + 1) / 2;
        if (penaltyDays < EARLY_PENALTY_MIN_DAYS) {
            penaltyDays = EARLY_PENALTY_MIN_DAYS;
        }

        if (servedDays == 0) {
            uint256 expected = _estimatePayoutRewardsDay(g, stakeSharesParam, lockedDayParam);
            penalty = expected * penaltyDays;
            return (payout, penalty); // Actual payout was 0
        }

        if (penaltyDays < servedDays) {
            uint256 penaltyEndDay = lockedDayParam + penaltyDays;
            penalty = _calcPayoutRewards(g, stakeSharesParam, lockedDayParam, penaltyEndDay);

            uint256 delta = _calcPayoutRewards(g, stakeSharesParam, penaltyEndDay, servedEndDay);
            payout = penalty + delta;
            return (payout, penalty);
        }

        payout = _calcPayoutRewards(g, stakeSharesParam, lockedDayParam, servedEndDay);

        if (penaltyDays == servedDays) {
            penalty = payout;
        } else {
            penalty = payout * penaltyDays / servedDays;
        }
        return (payout, penalty);
    }

    function _calcLatePenalty(
        uint256 lockedDayParam,
        uint256 stakedDaysParam,
        uint256 unlockedDayParam,
        uint256 rawStakeReturn
    )
        private
        pure
        returns (uint256)
    {

        uint256 maxUnlockedDay = lockedDayParam + stakedDaysParam + LATE_PENALTY_GRACE_DAYS;
        if (unlockedDayParam <= maxUnlockedDay) {
            return 0;
        }

        return rawStakeReturn * (unlockedDayParam - maxUnlockedDay) / LATE_PENALTY_SCALE_DAYS;

        	    }
    function _shareRateUpdate(GlobalsCache memory g, StakeCache memory st, uint256 stakeReturn)
        private
    {

        if (stakeReturn > st._stakedSuns) {
            uint256 bonusSuns = _stakeStartBonusSuns(stakeReturn, st._stakedDays);
            uint256 newShareRate = (stakeReturn + bonusSuns) * SHARE_RATE_SCALE / st._stakeShares;
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

    function xfLobbyEnter(address referrerAddr)
        external
        payable
    {

        uint256 enterDay = _currentDay();

        uint256 rawAmount = msg.value;
        require(rawAmount != 0, "LUUV: Amount required");

        XfLobbyQueueStore storage qRef = xfLobbyMembers[enterDay][msg.sender];

        uint256 entryIndex = qRef.tailIndex++;

        qRef.entries[entryIndex] = XfLobbyEntryStore(uint96(rawAmount), referrerAddr);

        xfLobby[enterDay] += rawAmount;

        emit XfLobbyEnter(
            block.timestamp, 
            enterDay, 
            entryIndex, 
            rawAmount
        );
    }

    function xfLobbyExit(uint256 enterDay, uint256 count)
        external
    {

        require(enterDay < _currentDay(), "LUUV: Round is not complete");

        XfLobbyQueueStore storage qRef = xfLobbyMembers[enterDay][msg.sender];

        uint256 headIndex = qRef.headIndex;
        uint256 endIndex;

        if (count != 0) {
            require(count <= qRef.tailIndex - headIndex, "LUUV: count invalid");
            endIndex = headIndex + count;
        } else {
            endIndex = qRef.tailIndex;
            require(headIndex < endIndex, "LUUV: count invalid");
        }

        uint256 waasLobby = _waasLobby(enterDay);
        uint256 _xfLobby = xfLobby[enterDay];
        uint256 totalXfAmount = 0;

        do {
            uint256 rawAmount = qRef.entries[headIndex].rawAmount;
            address referrerAddr = qRef.entries[headIndex].referrerAddr;

            delete qRef.entries[headIndex];

            uint256 xfAmount = waasLobby * rawAmount / _xfLobby;

            if (referrerAddr == address(0) || referrerAddr == msg.sender) {
                _emitXfLobbyExit(enterDay, headIndex, xfAmount, referrerAddr);
            } else {
                uint256 referralBonusSuns = xfAmount / 20;

                xfAmount += referralBonusSuns;

                uint256 referrerBonusSuns = xfAmount / 10;

                _emitXfLobbyExit(enterDay, headIndex, xfAmount, referrerAddr);
                _mint(referrerAddr, referrerBonusSuns);
            }

            totalXfAmount += xfAmount;
        } while (++headIndex < endIndex);

        qRef.headIndex = uint40(headIndex);

        if (totalXfAmount != 0) {
            _mint(msg.sender, totalXfAmount);
        }
    }

    function xfLobbyRange(uint256 beginDay, uint256 endDay)
        external
        view
        returns (uint256[] memory list)
    {

        require(
            beginDay < endDay && endDay <= _currentDay(),
            "LUUV: invalid range"
        );

        list = new uint256[](endDay - beginDay);

        uint256 src = beginDay;
        uint256 dst = 0;
        do {
            list[dst++] = uint256(xfLobby[src++]);
        } while (src < endDay);

        return list;
    }

    function xfFlush()
        external
    {

        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);
        
        require(address(this).balance != 0, "LUUV: No value");

        require(LAST_FLUSHED_DAY < _currentDay(), "LUUV: Invalid day");

        _dailyDataUpdateAuto(g);

      
        LIQUIDITY_ADDR.transfer(address(this).balance);

        LAST_FLUSHED_DAY++;

        _globalsSync(g, gSnapshot);
    }

    function xfLobbyEntry(address memberAddr, uint256 enterDay, uint256 entryIndex)
        external
        view
        returns (uint256 rawAmount, address referrerAddr)
    {

        XfLobbyEntryStore storage entry = xfLobbyMembers[enterDay][memberAddr].entries[entryIndex];

        require(entry.rawAmount != 0, "LUUV: Param invalid");

        return (entry.rawAmount, entry.referrerAddr);
    }

    function xfLobbyPendingDays(address memberAddr)
        external
        view
        returns (uint256[XF_LOBBY_DAY_WORDS] memory words)
    {

        uint256 day = _currentDay() + 1;

        while (day-- != 0) {
            if (xfLobbyMembers[day][memberAddr].tailIndex > xfLobbyMembers[day][memberAddr].headIndex) {
                words[day >> 8] |= 1 << (day & 255);
            }
        }

        return words;
    }
    
    function _waasLobby(uint256 enterDay)
        private
        returns (uint256 waasLobby)
    {

        if (enterDay > 0 && enterDay <= 365) {                                     
            waasLobby = CLAIM_STARTING_AMOUNT - ((enterDay - 1) * 1342465753424);
        } else {
            waasLobby = CLAIM_LOWEST_AMOUNT;
        }

        return waasLobby;
    }

    function _emitXfLobbyExit(
        uint256 enterDay,
        uint256 entryIndex,
        uint256 xfAmount,
        address referrerAddr
    )
        private
    {

        emit XfLobbyExit(
            block.timestamp, 
            enterDay,
            entryIndex,
            xfAmount,
            referrerAddr
        );
    }
}

contract LUUV is TransformableToken {

    constructor()
        public
    {
        admin = msg.sender;
        globals.shareRate = uint40(1 * SHARE_RATE_SCALE);
        LIQUIDITY_ADDR = msg.sender;
    }

    function() external payable {}
}