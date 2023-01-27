
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}//MIT
pragma solidity ^0.8.0;


interface IERC20Burnable is IERC20 {

    function burn(uint256 amount) external;

}//MIT
pragma solidity 0.8.4;


abstract contract GlobalsAndUtility {
    event DailyDataUpdate(
        address indexed updaterAddr,
        uint40 timestamp,
        uint16 beginDay,
        uint16 endDay,
        bool isAutoUpdate
    );

    event StakeStart(
        address indexed stakerAddr,
        uint40 indexed stakeId,
        uint40 timestamp,
        uint128 stakedAmount,
        uint128 stakeShares,
        uint16 stakedDays
    );

    event StakeGoodAccounting(        
        address indexed stakerAddr,
        uint40 indexed stakeId,
        address indexed senderAddr,
        uint40 timestamp,
        uint128 stakedAmount,
        uint128 stakeShares,
        uint128 payout,
        uint128 penalty
    );

    event StakeEnd(
        address indexed stakerAddr,
        uint40 indexed stakeId,
        uint40 timestamp,
        uint128 stakedAmount,
        uint128 stakeShares,
        uint128 payout,
        uint128 penalty,
        uint16 servedDays,
        bool prevUnlocked
    );

    event ShareRateChange(
        uint40 indexed stakeId,
        uint40 timestamp,
        uint40 shareRate
    );

    event RewardsFund(
        uint128 amountPerDay,
        uint16 daysCount,
        uint16 shiftInDays
    );

    IERC20Burnable public stakingToken;
    uint40 public launchTime;
    address public originAddr;

    uint256 internal constant ACC_REWARD_MULTIPLIER = 1e36;
    uint256 internal constant TOKEN_DECIMALS = 18;

    uint256 internal constant HARD_LOCK_DAYS = 15;
    uint256 internal constant MIN_STAKE_DAYS = 30;
    uint256 internal constant MAX_STAKE_DAYS = 1095;
    uint256 internal constant EARLY_PENALTY_MIN_DAYS = 30;
    uint256 internal constant LATE_PENALTY_GRACE_DAYS = 30;
    uint256 internal constant LATE_PENALTY_SCALE_DAYS = 100;

    uint256 private constant LPB_BONUS_PERCENT = 600;
    uint256 private constant LPB_BONUS_MAX_PERCENT = 1800;
    uint256 internal constant LPB = 364 * 100 / LPB_BONUS_PERCENT;
    uint256 internal constant LPB_MAX_DAYS = LPB * LPB_BONUS_MAX_PERCENT / 100;

    uint256 private constant BPB_BONUS_PERCENT = 50;
    uint256 internal constant BPB_MAX = 1e6 * 10 ** TOKEN_DECIMALS;
    uint256 internal constant BPB = BPB_MAX * 100 / BPB_BONUS_PERCENT;
    uint256 internal constant BPB_FROM_AMOUNT = 50000 * 10 ** TOKEN_DECIMALS;

    uint256 internal constant SHARE_RATE_SCALE = 1e5;

    uint256 internal constant SHARE_RATE_UINT_SIZE = 40;
    uint256 internal constant SHARE_RATE_MAX = (1 << SHARE_RATE_UINT_SIZE) - 1;

    struct GlobalsCache {
        uint256 _lockedStakeTotal;
        uint256 _nextStakeSharesTotal;

        uint256 _stakePenaltyTotal;
        uint256 _stakeSharesTotal;

        uint40 _latestStakeId;
        uint256 _shareRate;
        uint256 _dailyDataCount;

        uint256 _currentDay;
    }

    struct GlobalsStore {
        uint128 lockedStakeTotal;
        uint128 nextStakeSharesTotal;

        uint128 stakePenaltyTotal;
        uint128 stakeSharesTotal;

        uint40 latestStakeId;
        uint40 shareRate;
        uint16 dailyDataCount;
    }

    GlobalsStore public globals;

    struct DailyDataStore {
        uint128 dayPayoutTotal;
        uint128 sharesToBeRemoved;
        uint256 accRewardPerShare;
    }

    mapping(uint256 => DailyDataStore) public dailyData;

    struct StakeCache {
        uint256 _stakedAmount;
        uint256 _stakeShares;
        uint40 _stakeId;
        uint256 _lockedDay;
        uint256 _stakedDays;
        uint256 _unlockedDay;
    }

    struct StakeStore {
        uint128 stakedAmount;
        uint128 stakeShares;
        uint40 stakeId;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
    }

    mapping(address => StakeStore[]) public stakeLists;

    struct DailyRoundState {
        uint256 _payoutTotal;
        uint256 _accRewardPerShare;
    }

    function dailyDataUpdate(uint256 beforeDay)
        external
    {
        GlobalsCache memory g;
        _globalsLoad(g);

        if (beforeDay != 0) {
            require(beforeDay <= g._currentDay, "STAKING: beforeDay cannot be in the future");

            _dailyDataUpdate(g, beforeDay, false);
        } else {
            _dailyDataUpdate(g, g._currentDay, false);
        }

        _globalsSync(g);
    }

    function dailyDataRange(uint256 beginDay, uint256 endDay)
        external
        view
        returns (uint256[] memory listDayAccRewardPerShare, uint256[] memory listDayPayoutTotal)
    {
        require(beginDay < endDay, "STAKING: range invalid");

        listDayAccRewardPerShare = new uint256[](endDay - beginDay);
        listDayPayoutTotal = new uint256[](endDay - beginDay);

        uint256 src = beginDay;
        uint256 dst = 0;
        do {
            listDayAccRewardPerShare[dst] = dailyData[src].accRewardPerShare;
            listDayPayoutTotal[dst++] = dailyData[src].dayPayoutTotal;
        } while (++src < endDay);
    }

    function globalInfo()
        external
        view
        returns (GlobalsCache memory)
    {
        GlobalsCache memory g;
        _globalsLoad(g);

        return g;
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
        return (block.timestamp - launchTime) / 1 days;
    }

    function _dailyDataUpdateAuto(GlobalsCache memory g)
        internal
    {
        _dailyDataUpdate(g, g._currentDay, true);
    }

    function _globalsLoad(GlobalsCache memory g)
        internal
        view
    {
        g._lockedStakeTotal = globals.lockedStakeTotal;
        g._nextStakeSharesTotal = globals.nextStakeSharesTotal;

        g._stakeSharesTotal = globals.stakeSharesTotal;
        g._stakePenaltyTotal = globals.stakePenaltyTotal;

        g._latestStakeId = globals.latestStakeId;
        g._shareRate = globals.shareRate;
        g._dailyDataCount = globals.dailyDataCount;
        
        g._currentDay = _currentDay();
    }

    function _globalsSync(GlobalsCache memory g)
        internal
    {
        globals.lockedStakeTotal = uint128(g._lockedStakeTotal);
        globals.nextStakeSharesTotal = uint128(g._nextStakeSharesTotal);

        globals.stakeSharesTotal = uint128(g._stakeSharesTotal);
        globals.stakePenaltyTotal = uint128(g._stakePenaltyTotal);

        globals.latestStakeId = g._latestStakeId;
        globals.shareRate = uint40(g._shareRate);
        globals.dailyDataCount = uint16(g._dailyDataCount);
    }

    function _stakeLoad(StakeStore storage stRef, uint40 stakeIdParam, StakeCache memory st)
        internal
        view
    {
        require(stakeIdParam == stRef.stakeId, "STAKING: stakeIdParam not in stake");

        st._stakedAmount = stRef.stakedAmount;
        st._stakeShares = stRef.stakeShares;
        st._stakeId = stRef.stakeId;
        st._lockedDay = stRef.lockedDay;
        st._stakedDays = stRef.stakedDays;
        st._unlockedDay = stRef.unlockedDay;
    }

    function _stakeUpdate(StakeStore storage stRef, StakeCache memory st)
        internal
    {
        stRef.stakedAmount = uint128(st._stakedAmount);
        stRef.stakeShares = uint128(st._stakeShares);
        stRef.stakeId = st._stakeId;
        stRef.lockedDay = uint16(st._lockedDay);
        stRef.stakedDays = uint16(st._stakedDays);
        stRef.unlockedDay = uint16(st._unlockedDay);
    }

    function _stakeAdd(
        StakeStore[] storage stakeListRef,
        uint40 newStakeId,
        uint256 newstakedAmount,
        uint256 newStakeShares,
        uint256 newLockedDay,
        uint256 newStakedDays
    )
        internal
    {
        stakeListRef.push(
            StakeStore(
                uint128(newstakedAmount),
                uint128(newStakeShares),
                newStakeId,
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

    function _dailyRoundCalc(GlobalsCache memory g, DailyRoundState memory rs, uint256 day)
        private
        view
    {
        rs._payoutTotal = dailyData[day].dayPayoutTotal;
        rs._accRewardPerShare = day == 0 ? 0 : dailyData[day - 1].accRewardPerShare;

        if (g._stakePenaltyTotal != 0) {
            rs._payoutTotal += g._stakePenaltyTotal;
            g._stakePenaltyTotal = 0;
        }

        if (g._stakeSharesTotal > 0) {
            rs._accRewardPerShare += rs._payoutTotal * ACC_REWARD_MULTIPLIER / g._stakeSharesTotal;
        }
    }

    function _dailyRoundCalcAndStore(GlobalsCache memory g, DailyRoundState memory rs, uint256 day)
        private
    {
        g._stakeSharesTotal -= dailyData[day].sharesToBeRemoved;

        _dailyRoundCalc(g, rs, day);

        dailyData[day].accRewardPerShare = rs._accRewardPerShare;

        if (g._stakeSharesTotal > 0) {
            dailyData[day].dayPayoutTotal = uint128(rs._payoutTotal);
        } else {
            dailyData[day + 1].dayPayoutTotal += uint128(rs._payoutTotal);
        }
    }

    function _dailyDataUpdate(GlobalsCache memory g, uint256 beforeDay, bool isAutoUpdate)
        private
    {
        if (g._dailyDataCount >= beforeDay) {
            return;
        }

        DailyRoundState memory rs;

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
            uint40(block.timestamp),
            uint16(g._dailyDataCount),
            uint16(day),
            isAutoUpdate
        );

        g._dailyDataCount = day;
    }
}//MIT
pragma solidity 0.8.4;


contract Staking is GlobalsAndUtility {

    using SafeERC20 for IERC20Burnable;

    constructor(
        IERC20Burnable _stakingToken, // MUST BE BURNABLE
        uint40 _launchTime,
        address _originAddr
    )
    {
        require(IERC20Metadata(address(_stakingToken)).decimals() == TOKEN_DECIMALS, "STAKING: incompatible token decimals");
        require(_launchTime >= block.timestamp, "STAKING: launch must be in future");
        require(_originAddr != address(0), "STAKING: origin address is 0");

        stakingToken = _stakingToken;
        launchTime = _launchTime;
        originAddr = _originAddr;

        globals.shareRate = uint40(1 * SHARE_RATE_SCALE);
    }

    function stakeStart(uint256 newStakedAmount, uint256 newStakedDays)
        external
    {

        GlobalsCache memory g;
        _globalsLoad(g);

        require(newStakedDays >= MIN_STAKE_DAYS, "STAKING: newStakedDays lower than minimum");
        require(newStakedDays <= MAX_STAKE_DAYS, "STAKING: newStakedDays higher than maximum");

        _dailyDataUpdateAuto(g);

        _stakeStart(g, newStakedAmount, newStakedDays);

        stakingToken.safeTransferFrom(msg.sender, address(this), newStakedAmount);

        _globalsSync(g);
    }

    function stakeGoodAccounting(address stakerAddr, uint256 stakeIndex, uint40 stakeIdParam)
        external
    {

        GlobalsCache memory g;
        _globalsLoad(g);

        require(stakeLists[stakerAddr].length != 0, "STAKING: Empty stake list");
        require(stakeIndex < stakeLists[stakerAddr].length, "STAKING: stakeIndex invalid");

        StakeStore storage stRef = stakeLists[stakerAddr][stakeIndex];

        StakeCache memory st;
        _stakeLoad(stRef, stakeIdParam, st);

        require(g._currentDay >= st._lockedDay + st._stakedDays, "STAKING: Stake not fully served");

        require(st._unlockedDay == 0, "STAKING: Stake already unlocked");

        _dailyDataUpdateAuto(g);

        _stakeUnlock(g, st);

        (, uint256 payout, uint256 penalty, uint256 cappedPenalty) = _stakePerformance(
            st,
            st._stakedDays
        );

        emit StakeGoodAccounting(
            stakerAddr,
            stakeIdParam,
            msg.sender,
            uint40(block.timestamp),
            uint128(st._stakedAmount),
            uint128(st._stakeShares),
            uint128(payout),
            uint128(penalty)
        );

        if (cappedPenalty != 0) {
            _splitPenaltyProceeds(g, cappedPenalty);
        }

        _stakeUpdate(stRef, st);

        _globalsSync(g);
    }

    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam)
        external
        returns (uint256 stakeReturn, uint256 payout, uint256 penalty, uint256 cappedPenalty)
    {

        GlobalsCache memory g;
        _globalsLoad(g);

        StakeStore[] storage stakeListRef = stakeLists[msg.sender];

        require(stakeListRef.length != 0, "STAKING: Empty stake list");
        require(stakeIndex < stakeListRef.length, "STAKING: stakeIndex invalid");

        StakeCache memory st;
        _stakeLoad(stakeListRef[stakeIndex], stakeIdParam, st);

        _dailyDataUpdateAuto(g);

        require(g._currentDay >= st._lockedDay + HARD_LOCK_DAYS, "STAKING: hard lock period");

        uint256 servedDays = 0;
        bool prevUnlocked = (st._unlockedDay != 0);

        if (prevUnlocked) {
            servedDays = st._stakedDays;
        } else {
            _stakeUnlock(g, st);

            servedDays = g._currentDay - st._lockedDay;
            if (servedDays > st._stakedDays) {
                servedDays = st._stakedDays;
            }
        }

        (stakeReturn, payout, penalty, cappedPenalty) = _stakePerformance(st, servedDays);

        emit StakeEnd(
            msg.sender,
            stakeIdParam,
            uint40(block.timestamp),
            uint128(st._stakedAmount),
            uint128(st._stakeShares),
            uint128(payout),
            uint128(penalty),
            uint16(servedDays),
            prevUnlocked
        );

        if (cappedPenalty != 0 && !prevUnlocked) {
            _splitPenaltyProceeds(g, cappedPenalty);
        }

        if (stakeReturn != 0) {
            stakingToken.safeTransfer(msg.sender, stakeReturn);

            _shareRateUpdate(g, st, stakeReturn);
        }
        g._lockedStakeTotal -= st._stakedAmount;

        _stakeRemove(stakeListRef, stakeIndex);

        _globalsSync(g);

        return (
            stakeReturn,
            payout,
            penalty,
            cappedPenalty
        );
    }
 
    function fundRewards(
        uint128 amountPerDay,
        uint16 daysCount,
        uint16 shiftInDays
    )
        external
    {

        require(daysCount <= 365, "STAKING: too many days");

        stakingToken.safeTransferFrom(msg.sender, address(this), amountPerDay * daysCount);

        uint256 currentDay = _currentDay() + 1;
        uint256 fromDay = currentDay + shiftInDays;

        for (uint256 day = fromDay; day < fromDay + daysCount; day++) {
            dailyData[day].dayPayoutTotal += amountPerDay;
        }

        emit RewardsFund(amountPerDay, daysCount, shiftInDays);
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
        uint256 newStakedAmount,
        uint256 newStakedDays
    )
        internal
    {

        uint256 bonusShares = stakeStartBonusShares(newStakedAmount, newStakedDays);
        uint256 newStakeShares = (newStakedAmount + bonusShares) * SHARE_RATE_SCALE / g._shareRate;

        require(newStakeShares != 0, "STAKING: newStakedAmount must be at least minimum shareRate");

        uint256 newLockedDay = g._currentDay + 1;

        uint40 newStakeId = ++g._latestStakeId;
        _stakeAdd(
            stakeLists[msg.sender],
            newStakeId,
            newStakedAmount,
            newStakeShares,
            newLockedDay,
            newStakedDays
        );

        emit StakeStart(
            msg.sender,
            newStakeId,
            uint40(block.timestamp),
            uint128(newStakedAmount),
            uint128(newStakeShares),
            uint16(newStakedDays)
        );

        g._nextStakeSharesTotal += newStakeShares;

        g._lockedStakeTotal += newStakedAmount;

        dailyData[newLockedDay + newStakedDays].sharesToBeRemoved += uint128(newStakeShares);
    }

    function getStakeStatus(
        address staker, 
        uint256 stakeIndex, 
        uint40 stakeIdParam
    ) 
        external
        view
        returns (uint256 stakeReturn, uint256 payout, uint256 penalty, uint256 cappedPenalty)
    {

        GlobalsCache memory g;
        _globalsLoad(g);

        StakeStore[] storage stakeListRef = stakeLists[staker];

        require(stakeListRef.length != 0, "STAKING: Empty stake list");
        require(stakeIndex < stakeListRef.length, "STAKING: stakeIndex invalid");

        StakeCache memory st;
        _stakeLoad(stakeListRef[stakeIndex], stakeIdParam, st);

        require(g._currentDay >= st._lockedDay + HARD_LOCK_DAYS, "STAKING: hard lock period");

        uint256 servedDays = 0;
        bool prevUnlocked = (st._unlockedDay != 0);

        if (prevUnlocked) {
            servedDays = st._stakedDays;
        } else {
            st._unlockedDay = g._currentDay;

            servedDays = g._currentDay - st._lockedDay;
            if (servedDays > st._stakedDays) {
                servedDays = st._stakedDays;
            }
        }

        (stakeReturn, payout, penalty, cappedPenalty) = _stakePerformance(st, servedDays);
    }

    function _calcPayoutRewards(
        uint256 stakeSharesParam,
        uint256 beginDay,
        uint256 endDay
    )
        private
        view
        returns (uint256 payout)
    {

        uint256 accRewardPerShare = dailyData[endDay - 1].accRewardPerShare - dailyData[beginDay - 1].accRewardPerShare;
        payout = stakeSharesParam * accRewardPerShare / ACC_REWARD_MULTIPLIER;
        return payout;
    }

    function stakeStartBonusShares(uint256 newStakedAmount, uint256 newStakedDays)
        public
        pure
        returns (uint256 bonusShares)
    {

        uint256 cappedExtraDays = 0;

        if (newStakedDays > 1) {
            cappedExtraDays = newStakedDays <= LPB_MAX_DAYS ? newStakedDays - 1 : LPB_MAX_DAYS;
        }

        uint256 cappedStakedAmount = newStakedAmount >= BPB_FROM_AMOUNT ? newStakedAmount - BPB_FROM_AMOUNT : 0;
        if (cappedStakedAmount > BPB_MAX) {
            cappedStakedAmount = BPB_MAX;
        }

        bonusShares = cappedExtraDays * BPB + cappedStakedAmount * LPB;
        bonusShares = newStakedAmount * bonusShares / (LPB * BPB);

        return bonusShares;
    }

    function _stakeUnlock(GlobalsCache memory g, StakeCache memory st)
        private
    {

        st._unlockedDay = g._currentDay;

        uint256 endDay = st._lockedDay + st._stakedDays;
        
        if (g._currentDay <= endDay) {
            dailyData[endDay].sharesToBeRemoved -= uint128(st._stakeShares);
            g._stakeSharesTotal -= st._stakeShares;
        }
    }

    function _stakePerformance(StakeCache memory st, uint256 servedDays)
        private
        view
        returns (uint256 stakeReturn, uint256 payout, uint256 penalty, uint256 cappedPenalty)
    {

        if (servedDays < st._stakedDays) {
            (payout, penalty) = _calcPayoutAndEarlyPenalty(
                st._lockedDay,
                st._stakedDays,
                servedDays,
                st._stakeShares
            );
            stakeReturn = st._stakedAmount + payout;
        } else {
            payout = _calcPayoutRewards(
                st._stakeShares,
                st._lockedDay,
                st._lockedDay + servedDays
            );
            stakeReturn = st._stakedAmount + payout;

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
        return (stakeReturn, payout, penalty, cappedPenalty);
    }

    function _calcPayoutAndEarlyPenalty(
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

        if (penaltyDays < servedDays) {
            uint256 penaltyEndDay = lockedDayParam + penaltyDays;
            penalty = _calcPayoutRewards(stakeSharesParam, lockedDayParam, penaltyEndDay);

            uint256 delta = _calcPayoutRewards(stakeSharesParam, penaltyEndDay, servedEndDay);
            payout = penalty + delta;
            return (payout, penalty);
        }

        payout = _calcPayoutRewards(stakeSharesParam, lockedDayParam, servedEndDay);

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

    function _splitPenaltyProceeds(GlobalsCache memory g, uint256 penalty)
        private
    {

        uint256 splitPenalty = penalty / 2;

        if (splitPenalty != 0) {
            uint256 originPenalty = splitPenalty * 3 / 5;
            stakingToken.safeTransfer(originAddr, originPenalty);

            stakingToken.burn(splitPenalty - originPenalty);
        }

        splitPenalty = penalty - splitPenalty;
        g._stakePenaltyTotal += splitPenalty;
    }

    function _shareRateUpdate(GlobalsCache memory g, StakeCache memory st, uint256 stakeReturn)
        private
    {

        if (stakeReturn > st._stakedAmount) {
            uint256 bonusShares = stakeStartBonusShares(stakeReturn, st._stakedDays);
            uint256 newShareRate = (stakeReturn + bonusShares) * SHARE_RATE_SCALE / st._stakeShares;

            if (newShareRate > SHARE_RATE_MAX) {
                newShareRate = SHARE_RATE_MAX;
            }

            if (newShareRate > g._shareRate) {
                g._shareRate = newShareRate;

                emit ShareRateChange(
                    st._stakeId,
                    uint40(block.timestamp),
                    uint40(newShareRate)
                );
            }
        }
    }
}