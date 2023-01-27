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
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity 0.5.17;


contract Ownable
{

  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  modifier onlyOwner()
  {

    require(isOwner(), "!owner");
    _;
  }

  constructor () internal
  {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), msg.sender);
  }

  function owner() public view returns (address)
  {

    return _owner;
  }

  function isOwner() public view returns (bool)
  {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner
  {

    emit OwnershipTransferred(_owner, address(0));

    _owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner
  {

    require(_newOwner != address(0), "0 addy");

    emit OwnershipTransferred(_owner, _newOwner);

    _owner = _newOwner;
  }
}pragma solidity 0.5.17;


contract IStaking
{

  event Staked(address indexed user, uint amount, uint total, bytes data);
  event Unstaked(address indexed user, uint amount, uint total, bytes data);

  function stake(uint amount, bytes calldata data) external;


  function stakeFor(address user, uint amount, bytes calldata data) external;


  function unstake(uint amount, bytes calldata data) external;


  function totalStakedFor(address addr) public view returns (uint);


  function totalStaked() public view returns (uint);


  function token() external view returns (address);


  function supportsHistory() external pure returns (bool)
  {

    return false;
  }
}pragma solidity 0.5.17;




contract TokenPool is Ownable
{

  IERC20 public token;


  constructor(IERC20 _token) public
  {
    token = _token;
  }

  function balance() public view returns (uint)
  {

    return token.balanceOf(address(this));
  }

  function transfer(address _to, uint _value) external onlyOwner returns (bool)
  {

    return token.transfer(_to, _value);
  }
}pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;




contract TokenGeyser is IStaking, Ownable
{

  using SafeMath for uint;


  struct Stake
  {
    uint stakingShares;
    uint timestampSec;
  }

  struct UserTotals
  {
    uint stakingShares;
    uint stakingShareSeconds;
    uint lastAccountingTimestampSec;
  }

  struct UnlockSchedule
  {
    uint initialLockedShares;
    uint unlockedShares;
    uint lastUnlockTimestampSec;
    uint endAtSec;
    uint durationSec;
  }


  TokenPool private _lockedPool;
  TokenPool private _unlockedPool;
  TokenPool private _stakingPool;

  UnlockSchedule[] public unlockSchedules;


  uint public startBonus = 0;
  uint public bonusPeriodSec = 0;
  uint public constant BONUS_DECIMALS = 2;


  uint public totalLockedShares = 0;
  uint public totalStakingShares = 0;
  uint private _maxUnlockSchedules = 0;
  uint private _initialSharesPerToken = 0;
  uint private _totalStakingShareSeconds = 0;
  uint private _lastAccountingTimestampSec = now;


  mapping(address => Stake[]) private _userStakes;

  mapping(address => UserTotals) private _userTotals;

  mapping(address => uint) public initStakeTimestamps;


  event Staked(address indexed user, uint amount, uint total, bytes data);
  event Unstaked(address indexed user, uint amount, uint total, bytes data);

  event TokensClaimed(address indexed user, uint amount);
  event TokensLocked(uint amount, uint durationSec, uint total);
  event TokensUnlocked(uint amount, uint remainingLocked);


  constructor(IERC20 stakingToken, IERC20 distributionToken, uint maxUnlockSchedules, uint startBonus_, uint bonusPeriodSec_, uint initialSharesPerToken) public
  {
    require(startBonus_ <= 10 ** BONUS_DECIMALS, "TokenGeyser: start bonus too high");
    require(bonusPeriodSec_ != 0, "TokenGeyser: bonus period is 0");
    require(initialSharesPerToken > 0, "TokenGeyser: initialSharesPerToken is 0");

    _stakingPool = new TokenPool(stakingToken);
    _lockedPool = new TokenPool(distributionToken);
    _unlockedPool = new TokenPool(distributionToken);

    startBonus = startBonus_;
    bonusPeriodSec = bonusPeriodSec_;
    _maxUnlockSchedules = maxUnlockSchedules;
    _initialSharesPerToken = initialSharesPerToken;
  }


  function unlockScheduleShares(uint s) private returns (uint)
  {

    UnlockSchedule storage schedule = unlockSchedules[s];

    if (schedule.unlockedShares >= schedule.initialLockedShares)
    {
      return 0;
    }

    uint sharesToUnlock = 0;

    if (now >= schedule.endAtSec)
    {
      sharesToUnlock = (schedule.initialLockedShares.sub(schedule.unlockedShares));
      schedule.lastUnlockTimestampSec = schedule.endAtSec;
    }
    else
    {
      sharesToUnlock = now.sub(schedule.lastUnlockTimestampSec).mul(schedule.initialLockedShares).div(schedule.durationSec);

      schedule.lastUnlockTimestampSec = now;
    }

    schedule.unlockedShares = schedule.unlockedShares.add(sharesToUnlock);

    return sharesToUnlock;
  }

  function unlockTokens() public returns (uint)
  {

    uint unlockedTokens = 0;
    uint lockedTokens = totalLocked();

    if (totalLockedShares == 0)
    {
      unlockedTokens = lockedTokens;
    }
    else
    {
      uint unlockedShares = 0;

      for (uint s = 0; s < unlockSchedules.length; s++)
      {
        unlockedShares = unlockedShares.add(unlockScheduleShares(s));
      }

      unlockedTokens = unlockedShares.mul(lockedTokens).div(totalLockedShares);
      totalLockedShares = totalLockedShares.sub(unlockedShares);
    }

    if (unlockedTokens > 0)
    {
      require(_lockedPool.transfer(address(_unlockedPool), unlockedTokens), "TokenGeyser: tx out of locked pool failed");

      emit TokensUnlocked(unlockedTokens, totalLocked());
    }

    return unlockedTokens;
  }

  function updateAccounting() public returns (uint, uint, uint, uint, uint, uint)
  {

    unlockTokens();


    uint newStakingShareSeconds = now.sub(_lastAccountingTimestampSec).mul(totalStakingShares);

    _totalStakingShareSeconds = _totalStakingShareSeconds.add(newStakingShareSeconds);
    _lastAccountingTimestampSec = now;


    UserTotals storage totals = _userTotals[msg.sender];

    uint newUserStakingShareSeconds = now.sub(totals.lastAccountingTimestampSec).mul(totals.stakingShares);

    totals.stakingShareSeconds = totals.stakingShareSeconds.add(newUserStakingShareSeconds);
    totals.lastAccountingTimestampSec = now;

    uint totalUserRewards = (_totalStakingShareSeconds > 0) ? totalUnlocked().mul(totals.stakingShareSeconds).div(_totalStakingShareSeconds) : 0;

    return (totalLocked(), totalUnlocked(), totals.stakingShareSeconds, _totalStakingShareSeconds, totalUserRewards, now);
  }

  function lockTokens(uint amount, uint durationSec) external onlyOwner
  {

    require(unlockSchedules.length < _maxUnlockSchedules, "TokenGeyser: reached max unlock schedules");

    updateAccounting();

    UnlockSchedule memory schedule;

    uint lockedTokens = totalLocked();
    uint mintedLockedShares = (lockedTokens > 0) ? totalLockedShares.mul(amount).div(lockedTokens) : amount.mul(_initialSharesPerToken);


    schedule.initialLockedShares = mintedLockedShares;
    schedule.lastUnlockTimestampSec = now;
    schedule.endAtSec = now.add(durationSec);
    schedule.durationSec = durationSec;
    unlockSchedules.push(schedule);

    totalLockedShares = totalLockedShares.add(mintedLockedShares);

    require(_lockedPool.token().transferFrom(msg.sender, address(_lockedPool), amount), "TokenGeyser: transfer into locked pool failed");

    emit TokensLocked(amount, durationSec, totalLocked());
  }


  function stake(uint amount, bytes calldata data) external
  {

    _stakeFor(msg.sender, msg.sender, amount);
  }

  function stakeFor(address user, uint amount, bytes calldata data) external onlyOwner
  {

    _stakeFor(msg.sender, user, amount);
  }

  function _stakeFor(address staker, address beneficiary, uint amount) private
  {

    require(amount > 0, "TokenGeyser: stake amt is 0");
    require(beneficiary != address(0), "TokenGeyser: beneficiary is 0 addr");
    require(totalStakingShares == 0 || totalStaked() > 0, "TokenGeyser: Invalid state. Staking shares exist, but no staking tokens do");


    if (initStakeTimestamps[beneficiary] == 0)
    {
      initStakeTimestamps[beneficiary] = now;
    }


    uint mintedStakingShares = (totalStakingShares > 0) ? totalStakingShares.mul(amount).div(totalStaked()) : amount.mul(_initialSharesPerToken);


    require(mintedStakingShares > 0, "TokenGeyser: Stake too small");

    updateAccounting();


    UserTotals storage totals = _userTotals[beneficiary];

    totals.stakingShares = totals.stakingShares.add(mintedStakingShares);
    totals.lastAccountingTimestampSec = now;


    Stake memory newStake = Stake(mintedStakingShares, now);

    _userStakes[beneficiary].push(newStake);
    totalStakingShares = totalStakingShares.add(mintedStakingShares);

    require(_stakingPool.token().transferFrom(staker, address(_stakingPool), amount), "TokenGeyser: tx into staking pool failed");

    emit Staked(beneficiary, amount, totalStakedFor(beneficiary), "");
  }


  function computeNewReward(uint currentRewardTokens, uint stakingShareSeconds, uint stakeTimeSec) private view returns (uint)
  {

    uint newRewardTokens = totalUnlocked().mul(stakingShareSeconds).div(_totalStakingShareSeconds);

    if (stakeTimeSec >= bonusPeriodSec)
    {
      return currentRewardTokens.add(newRewardTokens);
    }

    uint oneHundredPct = 10 ** BONUS_DECIMALS;
    uint bonusedReward = startBonus.add(oneHundredPct.sub(startBonus).mul(stakeTimeSec).div(bonusPeriodSec)).mul(newRewardTokens).div(oneHundredPct);

    return currentRewardTokens.add(bonusedReward);
  }

  function unstake(uint amount, bytes calldata data) external
  {

    _unstake(amount);
  }

  function unstakeQuery(uint amount) public returns (uint)
  {

    return _unstake(amount);
  }

  function _unstake(uint amount) private returns (uint)
  {

    uint initStakeTimestamp = initStakeTimestamps[msg.sender];

    require(now > initStakeTimestamp.add(10 days), "TokenGeyser: in cooldown");

    updateAccounting();

    require(amount > 0, "TokenGeyser: unstake amt is 0");
    require(totalStakedFor(msg.sender) >= amount, "TokenGeyser: unstake amt > total user stakes");

    uint stakingSharesToBurn = totalStakingShares.mul(amount).div(totalStaked());

    require(stakingSharesToBurn > 0, "TokenGeyser: unstake too small");


    UserTotals storage totals = _userTotals[msg.sender];
    Stake[] storage accountStakes = _userStakes[msg.sender];

    uint rewardAmount = 0;
    uint stakingShareSecondsToBurn = 0;
    uint sharesLeftToBurn = stakingSharesToBurn;

    while (sharesLeftToBurn > 0)
    {
      Stake storage lastStake = accountStakes[accountStakes.length - 1];
      uint stakeTimeSec = now.sub(lastStake.timestampSec);
      uint newStakingShareSecondsToBurn = 0;

      if (lastStake.stakingShares <= sharesLeftToBurn)
      {
        newStakingShareSecondsToBurn = lastStake.stakingShares.mul(stakeTimeSec);
        rewardAmount = computeNewReward(rewardAmount, newStakingShareSecondsToBurn, stakeTimeSec);
        stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(newStakingShareSecondsToBurn);
        sharesLeftToBurn = sharesLeftToBurn.sub(lastStake.stakingShares);
        accountStakes.length--;
      }
      else
      {
        newStakingShareSecondsToBurn = sharesLeftToBurn.mul(stakeTimeSec);
        rewardAmount = computeNewReward(rewardAmount, newStakingShareSecondsToBurn, stakeTimeSec);
        stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(newStakingShareSecondsToBurn);
        lastStake.stakingShares = lastStake.stakingShares.sub(sharesLeftToBurn);
        sharesLeftToBurn = 0;
      }
    }

    totals.stakingShareSeconds = totals.stakingShareSeconds.sub(stakingShareSecondsToBurn);
    totals.stakingShares = totals.stakingShares.sub(stakingSharesToBurn);


    _totalStakingShareSeconds = _totalStakingShareSeconds.sub(stakingShareSecondsToBurn);
    totalStakingShares = totalStakingShares.sub(stakingSharesToBurn);


    uint unstakeFee = amount.mul(100).div(10000);

    if (now >= initStakeTimestamp.add(45 days))
    {
      unstakeFee = amount.mul(75).div(10000);
    }

    require(_stakingPool.transfer(owner(), unstakeFee), "TokenGeyser: err tx'ing fee");

    require(_stakingPool.transfer(msg.sender, amount.sub(unstakeFee)), "TokenGeyser: tx out of staking pool failed");
    require(_unlockedPool.transfer(msg.sender, rewardAmount), "TokenGeyser: tx out of unlocked pool failed");

    emit Unstaked(msg.sender, amount, totalStakedFor(msg.sender), "");
    emit TokensClaimed(msg.sender, rewardAmount);

    require(totalStakingShares == 0 || totalStaked() > 0, "TokenGeyser: Err unstaking. Staking shares exist, but no staking tokens do");

    return rewardAmount;
  }


  function totalStakedFor(address addr) public view returns (uint)
  {

    return totalStakingShares > 0 ? totalStaked().mul(_userTotals[addr].stakingShares).div(totalStakingShares) : 0;
  }

  function totalStaked() public view returns (uint)
  {

    return _stakingPool.balance();
  }

  function totalLocked() public view returns (uint)
  {

    return _lockedPool.balance();
  }

  function totalUnlocked() public view returns (uint)
  {

    return _unlockedPool.balance();
  }

  function unlockScheduleCount() public view returns (uint)
  {

    return unlockSchedules.length;
  }



  function getUserStakes(address addr) public view returns (Stake[] memory)
  {

    Stake[] memory userStakes = _userStakes[addr];

    return userStakes;
  }

  function getUserTotals(address addr) public view returns (UserTotals memory)
  {

    UserTotals memory userTotals = _userTotals[addr];

    return userTotals;
  }

  function getTotalStakingShareSeconds() public view returns (uint256)
  {

    return _totalStakingShareSeconds;
  }

  function getLastAccountingTimestamp() public view returns (uint256)
  {

    return _lastAccountingTimestampSec;
  }

  function getDistributionToken() public view returns (IERC20)
  {

    assert(_unlockedPool.token() == _lockedPool.token());

    return _unlockedPool.token();
  }

  function getStakingToken() public view returns (IERC20)
  {

    return _stakingPool.token();
  }

  function token() external view returns (address)
  {

    return address(getStakingToken());
  }
}