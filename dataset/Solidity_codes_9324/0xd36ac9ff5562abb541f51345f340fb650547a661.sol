pragma solidity >=0.8.4 <0.9.0;

library FullMath {

  function mulDiv(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {

    unchecked {
      uint256 prod0; // Least significant 256 bits of the product
      uint256 prod1; // Most significant 256 bits of the product
      assembly {
        let mm := mulmod(a, b, not(0))
        prod0 := mul(a, b)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
      }

      if (prod1 == 0) {
        require(denominator > 0);
        assembly {
          result := div(prod0, denominator)
        }
        return result;
      }

      require(denominator > prod1);


      uint256 remainder;
      assembly {
        remainder := mulmod(a, b, denominator)
      }
      assembly {
        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
      }

      uint256 twos = (~denominator + 1) & denominator;
      assembly {
        denominator := div(denominator, twos)
      }

      assembly {
        prod0 := div(prod0, twos)
      }
      assembly {
        twos := add(div(sub(0, twos), twos), 1)
      }
      prod0 |= prod1 * twos;

      uint256 inv = (3 * denominator) ^ 2;
      inv *= 2 - denominator * inv; // inverse mod 2**8
      inv *= 2 - denominator * inv; // inverse mod 2**16
      inv *= 2 - denominator * inv; // inverse mod 2**32
      inv *= 2 - denominator * inv; // inverse mod 2**64
      inv *= 2 - denominator * inv; // inverse mod 2**128
      inv *= 2 - denominator * inv; // inverse mod 2**256

      result = prod0 * inv;
      return result;
    }
  }

  function mulDivRoundingUp(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {

    unchecked {
      result = mulDiv(a, b, denominator);
      if (mulmod(a, b, denominator) > 0) {
        require(result < type(uint256).max);
        result++;
      }
    }
  }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


library TickMath {

  int24 internal constant MIN_TICK = -887272;
  int24 internal constant MAX_TICK = -MIN_TICK;

  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

  function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {

    uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
    require(absTick <= uint256(int256(MAX_TICK)), 'T');

    uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
    if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
    if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
    if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
    if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
    if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
    if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
    if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
    if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
    if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
    if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
    if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
    if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
    if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
    if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
    if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
    if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
    if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
    if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
    if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

    if (tick > 0) ratio = type(uint256).max / ratio;

    sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
  }

  function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {

    require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
    uint256 ratio = uint256(sqrtPriceX96) << 32;

    uint256 r = ratio;
    uint256 msb = 0;

    assembly {
      let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(5, gt(r, 0xFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(4, gt(r, 0xFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(3, gt(r, 0xFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(2, gt(r, 0xF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(1, gt(r, 0x3))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := gt(r, 0x1)
      msb := or(msb, f)
    }

    if (msb >= 128) r = ratio >> (msb - 127);
    else r = ratio << (127 - msb);

    int256 log_2 = (int256(msb) - 128) << 64;

    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(63, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(62, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(61, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(60, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(59, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(58, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(57, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(56, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(55, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(54, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(53, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(52, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(51, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(50, f))
    }

    int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

    int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
    int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

    tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IKeep3rJobFundableCredits {


  event TokenCreditAddition(address indexed _job, address indexed _token, address indexed _provider, uint256 _amount);

  event TokenCreditWithdrawal(address indexed _job, address indexed _token, address indexed _receiver, uint256 _amount);


  error TokenUnallowed();

  error JobTokenCreditsLocked();

  error InsufficientJobTokenCredits();


  function jobTokenCreditsAddedAt(address _job, address _token) external view returns (uint256 _timestamp);



  function addTokenCreditsToJob(
    address _job,
    address _token,
    uint256 _amount
  ) external;


  function withdrawTokenCreditsFromJob(
    address _job,
    address _token,
    uint256 _amount,
    address _receiver
  ) external;

}

interface IKeep3rJobFundableLiquidity {


  event LiquidityApproval(address _liquidity);

  event LiquidityRevocation(address _liquidity);

  event LiquidityAddition(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _amount);

  event LiquidityWithdrawal(address indexed _job, address indexed _liquidity, address indexed _receiver, uint256 _amount);

  event LiquidityCreditsReward(address indexed _job, uint256 _rewardedAt, uint256 _currentCredits, uint256 _periodCredits);

  event LiquidityCreditsForced(address indexed _job, uint256 _rewardedAt, uint256 _currentCredits);


  error LiquidityPairApproved();

  error LiquidityPairUnexistent();

  error LiquidityPairUnapproved();

  error JobLiquidityUnexistent();

  error JobLiquidityInsufficient();

  error JobLiquidityLessThanMin();


  struct TickCache {
    int56 current; // Tracks the current tick
    int56 difference; // Stores the difference between the current tick and the last tick
    uint256 period; // Stores the period at which the last observation was made
  }


  function approvedLiquidities() external view returns (address[] memory _list);


  function liquidityAmount(address _job, address _liquidity) external view returns (uint256 _amount);


  function rewardedAt(address _job) external view returns (uint256 _timestamp);


  function workedAt(address _job) external view returns (uint256 _timestamp);



  function jobLiquidityCredits(address _job) external view returns (uint256 _amount);


  function jobPeriodCredits(address _job) external view returns (uint256 _amount);


  function totalJobCredits(address _job) external view returns (uint256 _amount);


  function quoteLiquidity(address _liquidity, uint256 _amount) external view returns (uint256 _periodCredits);


  function observeLiquidity(address _liquidity) external view returns (TickCache memory _tickCache);


  function forceLiquidityCreditsToJob(address _job, uint256 _amount) external;


  function approveLiquidity(address _liquidity) external;


  function revokeLiquidity(address _liquidity) external;


  function addLiquidityToJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;


  function unbondLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;


  function withdrawLiquidityFromJob(
    address _job,
    address _liquidity,
    address _receiver
  ) external;

}

interface IKeep3rJobManager {


  event JobAddition(address indexed _job, address indexed _jobOwner);


  error JobAlreadyAdded();

  error AlreadyAKeeper();


  function addJob(address _job) external;

}

interface IKeep3rJobWorkable {


  event KeeperValidation(uint256 _gasLeft);

  event KeeperWork(address indexed _credit, address indexed _job, address indexed _keeper, uint256 _payment, uint256 _gasLeft);


  error JobUnapproved();

  error InsufficientFunds();


  function isKeeper(address _keeper) external returns (bool _isKeeper);


  function isBondedKeeper(
    address _keeper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool _isBondedKeeper);


  function worked(address _keeper) external;


  function bondedPayment(address _keeper, uint256 _payment) external;


  function directTokenPayment(
    address _token,
    address _keeper,
    uint256 _amount
  ) external;

}

interface IKeep3rJobOwnership {


  event JobOwnershipChange(address indexed _job, address indexed _owner, address indexed _pendingOwner);

  event JobOwnershipAssent(address indexed _job, address indexed _previousOwner, address indexed _newOwner);


  error OnlyJobOwner();

  error OnlyPendingJobOwner();


  function jobOwner(address _job) external view returns (address _owner);


  function jobPendingOwner(address _job) external view returns (address _pendingOwner);



  function changeJobOwnership(address _job, address _newOwner) external;


  function acceptJobOwnership(address _job) external;

}

interface IKeep3rJobMigration {


  event JobMigrationRequested(address indexed _fromJob, address _toJob);

  event JobMigrationSuccessful(address _fromJob, address indexed _toJob);


  error JobMigrationImpossible();

  error JobMigrationUnavailable();

  error JobMigrationLocked();


  function pendingJobMigrations(address _fromJob) external view returns (address _toJob);



  function migrateJob(address _fromJob, address _toJob) external;


  function acceptJobMigration(address _fromJob, address _toJob) external;

}

interface IKeep3rJobDisputable is IKeep3rJobFundableCredits, IKeep3rJobFundableLiquidity {


  event JobSlashToken(address indexed _job, address _token, address indexed _slasher, uint256 _amount);

  event JobSlashLiquidity(address indexed _job, address _liquidity, address indexed _slasher, uint256 _amount);


  error JobTokenUnexistent();

  error JobTokenInsufficient();


  function slashTokenFromJob(
    address _job,
    address _token,
    uint256 _amount
  ) external;


  function slashLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;

}

interface IKeep3rJobs is IKeep3rJobOwnership, IKeep3rJobDisputable, IKeep3rJobMigration, IKeep3rJobManager, IKeep3rJobWorkable {


}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IKeep3rKeeperFundable {


  event Activation(address indexed _keeper, address indexed _bond, uint256 _amount);

  event Withdrawal(address indexed _keeper, address indexed _bond, uint256 _amount);


  error AlreadyAJob();


  function bond(address _bonding, uint256 _amount) external;


  function unbond(address _bonding, uint256 _amount) external;


  function activate(address _bonding) external;


  function withdraw(address _bonding) external;

}

interface IKeep3rKeeperDisputable {


  event KeeperSlash(address indexed _keeper, address indexed _slasher, uint256 _amount);

  event KeeperRevoke(address indexed _keeper, address indexed _slasher);


  function slash(
    address _keeper,
    address _bonded,
    uint256 _bondAmount,
    uint256 _unbondAmount
  ) external;


  function revoke(address _keeper) external;

}


interface IKeep3rKeepers is IKeep3rKeeperDisputable {


}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IKeep3rAccountance {


  event Bonding(address indexed _keeper, address indexed _bonding, uint256 _amount);

  event Unbonding(address indexed _keeperOrJob, address indexed _unbonding, uint256 _amount);


  function workCompleted(address _keeper) external view returns (uint256 _workCompleted);


  function firstSeen(address _keeper) external view returns (uint256 timestamp);


  function disputes(address _keeperOrJob) external view returns (bool _disputed);


  function bonds(address _keeper, address _bond) external view returns (uint256 _bonds);


  function jobTokenCredits(address _job, address _token) external view returns (uint256 _amount);


  function pendingBonds(address _keeper, address _bonding) external view returns (uint256 _pendingBonds);


  function canActivateAfter(address _keeper, address _bonding) external view returns (uint256 _timestamp);


  function canWithdrawAfter(address _keeper, address _bonding) external view returns (uint256 _timestamp);


  function pendingUnbonds(address _keeper, address _bonding) external view returns (uint256 _pendingUnbonds);


  function hasBonded(address _keeper) external view returns (bool _hasBonded);



  function jobs() external view returns (address[] memory _jobList);


  function keepers() external view returns (address[] memory _keeperList);



  error JobUnavailable();

  error JobDisputed();
}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IKeep3rRoles {


  event SlasherAdded(address _slasher);

  event SlasherRemoved(address _slasher);

  event DisputerAdded(address _disputer);

  event DisputerRemoved(address _disputer);


  function slashers(address _slasher) external view returns (bool _isSlasher);


  function disputers(address _disputer) external view returns (bool _isDisputer);



  error SlasherExistent();

  error SlasherUnexistent();

  error DisputerExistent();

  error DisputerUnexistent();

  error OnlySlasher();

  error OnlyDisputer();


  function addSlasher(address _slasher) external;


  function removeSlasher(address _slasher) external;


  function addDisputer(address _disputer) external;


  function removeDisputer(address _disputer) external;

}// MIT

pragma solidity >=0.8.4 <0.9.0;

interface IBaseErrors {

  error ZeroAddress();
}// MIT
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rParameters is IBaseErrors {


  event Keep3rHelperChange(address _keep3rHelper);

  event Keep3rV1Change(address _keep3rV1);

  event Keep3rV1ProxyChange(address _keep3rV1Proxy);

  event Kp3rWethPoolChange(address _kp3rWethPool);

  event BondTimeChange(uint256 _bondTime);

  event LiquidityMinimumChange(uint256 _liquidityMinimum);

  event UnbondTimeChange(uint256 _unbondTime);

  event RewardPeriodTimeChange(uint256 _rewardPeriodTime);

  event InflationPeriodChange(uint256 _inflationPeriod);

  event FeeChange(uint256 _fee);


  function keep3rHelper() external view returns (address _keep3rHelper);


  function keep3rV1() external view returns (address _keep3rV1);


  function keep3rV1Proxy() external view returns (address _keep3rV1Proxy);


  function kp3rWethPool() external view returns (address _kp3rWethPool);


  function bondTime() external view returns (uint256 _days);


  function unbondTime() external view returns (uint256 _days);


  function liquidityMinimum() external view returns (uint256 _amount);


  function rewardPeriodTime() external view returns (uint256 _days);


  function inflationPeriod() external view returns (uint256 _period);


  function fee() external view returns (uint256 _amount);



  error MinRewardPeriod();

  error Disputed();

  error BondsUnexistent();

  error BondsLocked();

  error UnbondsUnexistent();

  error UnbondsLocked();


  function setKeep3rHelper(address _keep3rHelper) external;


  function setKeep3rV1(address _keep3rV1) external;


  function setKeep3rV1Proxy(address _keep3rV1Proxy) external;


  function setKp3rWethPool(address _kp3rWethPool) external;


  function setBondTime(uint256 _bond) external;


  function setUnbondTime(uint256 _unbond) external;


  function setLiquidityMinimum(uint256 _liquidityMinimum) external;


  function setRewardPeriodTime(uint256 _rewardPeriodTime) external;


  function setInflationPeriod(uint256 _inflationPeriod) external;


  function setFee(uint256 _fee) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3r is IKeep3rJobs, IKeep3rKeepers, IKeep3rAccountance, IKeep3rRoles, IKeep3rParameters {


}// MIT
pragma solidity >=0.8.4 <0.9.0;


interface IKeep3rHelper {


  error LiquidityPairInvalid();


  function quote(uint256 _eth) external view returns (uint256 _amountOut);


  function bonds(address _keeper) external view returns (uint256 _amountBonded);


  function getRewardAmountFor(address _keeper, uint256 _gasUsed) external view returns (uint256 _kp3r);


  function getRewardBoostFor(uint256 _bonds) external view returns (uint256 _rewardBoost);


  function getRewardAmount(uint256 _gasUsed) external view returns (uint256 _amount);


  function getPoolTokens(address _pool) external view returns (address _token0, address _token1);


  function isKP3RToken0(address _pool) external view returns (bool _isKP3RToken0);


  function observe(address _pool, uint32[] memory _secondsAgo)
    external
    view
    returns (
      int56 _tickCumulative1,
      int56 _tickCumulative2,
      bool _success
    );


  function getPaymentParams(uint256 _bonds)
    external
    view
    returns (
      uint256 _boost,
      uint256 _oneEthQuote,
      uint256 _extra
    );


  function getKP3RsAtTick(
    uint256 _liquidityAmount,
    int56 _tickDifference,
    uint256 _timeInterval
  ) external pure returns (uint256 _kp3rAmount);


  function getQuoteAtTick(
    uint128 _baseAmount,
    int56 _tickDifference,
    uint256 _timeInterval
  ) external pure returns (uint256 _quoteAmount);

}// MIT

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
pragma solidity >=0.8.4 <0.9.0;


interface IKeep3rV1 is IERC20, IERC20Metadata {

  struct Checkpoint {
    uint32 fromBlock;
    uint256 votes;
  }

  event DelegateChanged(address indexed _delegator, address indexed _fromDelegate, address indexed _toDelegate);
  event DelegateVotesChanged(address indexed _delegate, uint256 _previousBalance, uint256 _newBalance);
  event SubmitJob(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _block, uint256 _credit);
  event ApplyCredit(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _block, uint256 _credit);
  event RemoveJob(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _block, uint256 _credit);
  event UnbondJob(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _block, uint256 _credit);
  event JobAdded(address indexed _job, uint256 _block, address _governance);
  event JobRemoved(address indexed _job, uint256 _block, address _governance);
  event KeeperWorked(address indexed _credit, address indexed _job, address indexed _keeper, uint256 _block, uint256 _amount);
  event KeeperBonding(address indexed _keeper, uint256 _block, uint256 _active, uint256 _bond);
  event KeeperBonded(address indexed _keeper, uint256 _block, uint256 _activated, uint256 _bond);
  event KeeperUnbonding(address indexed _keeper, uint256 _block, uint256 _deactive, uint256 _bond);
  event KeeperUnbound(address indexed _keeper, uint256 _block, uint256 _deactivated, uint256 _bond);
  event KeeperSlashed(address indexed _keeper, address indexed _slasher, uint256 _block, uint256 _slash);
  event KeeperDispute(address indexed _keeper, uint256 _block);
  event KeeperResolved(address indexed _keeper, uint256 _block);
  event TokenCreditAddition(address indexed _credit, address indexed _job, address indexed _creditor, uint256 _block, uint256 _amount);

  function KPRH() external returns (address);


  function delegates(address _delegator) external view returns (address);


  function checkpoints(address _account, uint32 _checkpoint) external view returns (Checkpoint memory);


  function numCheckpoints(address _account) external view returns (uint32);


  function DOMAIN_TYPEHASH() external returns (bytes32);


  function DOMAINSEPARATOR() external returns (bytes32);


  function DELEGATION_TYPEHASH() external returns (bytes32);


  function PERMIT_TYPEHASH() external returns (bytes32);


  function nonces(address _user) external view returns (uint256);


  function BOND() external returns (uint256);


  function UNBOND() external returns (uint256);


  function LIQUIDITYBOND() external returns (uint256);


  function FEE() external returns (uint256);


  function BASE() external returns (uint256);


  function ETH() external returns (address);


  function bondings(address _user, address _bonding) external view returns (uint256);


  function canWithdrawAfter(address _user, address _bonding) external view returns (uint256);


  function pendingUnbonds(address _keeper, address _bonding) external view returns (uint256);


  function pendingbonds(address _keeper, address _bonding) external view returns (uint256);


  function bonds(address _keeper, address _bonding) external view returns (uint256);


  function votes(address _delegator) external view returns (uint256);


  function firstSeen(address _keeper) external view returns (uint256);


  function disputes(address _keeper) external view returns (bool);


  function lastJob(address _keeper) external view returns (uint256);


  function workCompleted(address _keeper) external view returns (uint256);


  function jobs(address _job) external view returns (bool);


  function credits(address _job, address _credit) external view returns (uint256);


  function liquidityProvided(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);


  function liquidityUnbonding(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);


  function liquidityAmountsUnbonding(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);


  function jobProposalDelay(address _job) external view returns (uint256);


  function liquidityApplied(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);


  function liquidityAmount(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);


  function keepers(address _keeper) external view returns (bool);


  function blacklist(address _keeper) external view returns (bool);


  function keeperList(uint256 _index) external view returns (address);


  function jobList(uint256 _index) external view returns (address);


  function governance() external returns (address);


  function pendingGovernance() external returns (address);


  function liquidityAccepted(address _liquidity) external view returns (bool);


  function liquidityPairs(uint256 _index) external view returns (address);


  function getCurrentVotes(address _account) external view returns (uint256);


  function addCreditETH(address _job) external payable;


  function addCredit(
    address _credit,
    address _job,
    uint256 _amount
  ) external;


  function addVotes(address _voter, uint256 _amount) external;


  function removeVotes(address _voter, uint256 _amount) external;


  function addKPRCredit(address _job, uint256 _amount) external;


  function approveLiquidity(address _liquidity) external;


  function revokeLiquidity(address _liquidity) external;


  function pairs() external view returns (address[] memory);


  function addLiquidityToJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;


  function applyCreditToJob(
    address _provider,
    address _liquidity,
    address _job
  ) external;


  function unbondLiquidityFromJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;


  function removeLiquidityFromJob(address _liquidity, address _job) external;


  function mint(uint256 _amount) external;


  function burn(uint256 _amount) external;


  function worked(address _keeper) external;


  function receipt(
    address _credit,
    address _keeper,
    uint256 _amount
  ) external;


  function receiptETH(address _keeper, uint256 _amount) external;


  function addJob(address _job) external;


  function getJobs() external view returns (address[] memory);


  function removeJob(address _job) external;


  function setKeep3rHelper(address _keep3rHelper) external;


  function setGovernance(address _governance) external;


  function acceptGovernance() external;


  function isKeeper(address _keeper) external returns (bool);


  function isMinKeeper(
    address _keeper,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool);


  function isBondedKeeper(
    address _keeper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool);


  function bond(address _bonding, uint256 _amount) external;


  function getKeepers() external view returns (address[] memory);


  function activate(address _bonding) external;


  function unbond(address _bonding, uint256 _amount) external;


  function slash(
    address _bonded,
    address _keeper,
    uint256 _amount
  ) external;


  function withdraw(address _bonding) external;


  function dispute(address _keeper) external;


  function revoke(address _keeper) external;


  function resolve(address _keeper) external;


  function permit(
    address _owner,
    address _spender,
    uint256 _amount,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IKeep3rHelperParameters {


  struct Kp3rWethPool {
    address poolAddress;
    bool isKP3RToken0;
  }


  error InvalidKp3rPool();


  event Kp3rWethPoolChange(address _address, bool _isKP3RToken0);

  event MinBoostChange(uint256 _minBoost);

  event MaxBoostChange(uint256 _maxBoost);

  event TargetBondChange(uint256 _targetBond);

  event Keep3rV2Change(address _keep3rV2);

  event WorkExtraGasChange(uint256 _workExtraGas);

  event QuoteTwapTimeChange(uint32 _quoteTwapTime);


  function KP3R() external view returns (address _kp3r);


  function BOOST_BASE() external view returns (uint256 _base);


  function kp3rWethPool() external view returns (address poolAddress, bool isKP3RToken0);


  function minBoost() external view returns (uint256 _multiplier);


  function maxBoost() external view returns (uint256 _multiplier);


  function targetBond() external view returns (uint256 _target);


  function workExtraGas() external view returns (uint256 _workExtraGas);


  function quoteTwapTime() external view returns (uint32 _quoteTwapTime);


  function keep3rV2() external view returns (address _keep3rV2);



  function setKp3rWethPool(address _poolAddress) external;


  function setMinBoost(uint256 _minBoost) external;


  function setMaxBoost(uint256 _maxBoost) external;


  function setTargetBond(uint256 _targetBond) external;


  function setKeep3rV2(address _keep3rV2) external;


  function setWorkExtraGas(uint256 _workExtraGas) external;


  function setQuoteTwapTime(uint32 _quoteTwapTime) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IGovernable {


  event GovernanceSet(address _governance);

  event GovernanceProposal(address _pendingGovernance);


  error OnlyGovernance();

  error OnlyPendingGovernance();

  error NoGovernanceZeroAddress();


  function governance() external view returns (address _governance);


  function pendingGovernance() external view returns (address _pendingGovernance);



  function setGovernance(address _governance) external;


  function acceptGovernance() external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Governable is IGovernable {
  address public override governance;

  address public override pendingGovernance;

  constructor(address _governance) {
    if (_governance == address(0)) revert NoGovernanceZeroAddress();
    governance = _governance;
  }

  function setGovernance(address _governance) external override onlyGovernance {
    pendingGovernance = _governance;
    emit GovernanceProposal(_governance);
  }

  function acceptGovernance() external override onlyPendingGovernance {
    governance = pendingGovernance;
    delete pendingGovernance;
    emit GovernanceSet(governance);
  }

  modifier onlyGovernance {
    if (msg.sender != governance) revert OnlyGovernance();
    _;
  }

  modifier onlyPendingGovernance {
    if (msg.sender != pendingGovernance) revert OnlyPendingGovernance();
    _;
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
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolState {

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees() external view returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolDerivedState {

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);


    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolActions {

    function initialize(uint160 sqrtPriceX96) external;


    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);


    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);


    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);


    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);


    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;


    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolEvents {

    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


}// MIT
pragma solidity >=0.8.7 <0.9.0;



contract Keep3rHelperParameters is IKeep3rHelperParameters, Governable {

  address public constant override KP3R = 0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44;

  uint256 public constant override BOOST_BASE = 10_000;

  uint256 public override minBoost = 11_000;

  uint256 public override maxBoost = 12_000;

  uint256 public override targetBond = 200 ether;

  uint256 public override workExtraGas = 50_000;

  uint32 public override quoteTwapTime = 10 minutes;

  address public override keep3rV2;

  IKeep3rHelperParameters.Kp3rWethPool public override kp3rWethPool;

  constructor(address _keep3rV2, address _governance) Governable(_governance) {
    keep3rV2 = _keep3rV2;
    _setKp3rWethPool(0x11B7a6bc0259ed6Cf9DB8F499988F9eCc7167bf5);
  }

  function setKp3rWethPool(address _poolAddress) external override onlyGovernance {

    _setKp3rWethPool(_poolAddress);
    emit Kp3rWethPoolChange(kp3rWethPool.poolAddress, kp3rWethPool.isKP3RToken0);
  }

  function setMinBoost(uint256 _minBoost) external override onlyGovernance {

    minBoost = _minBoost;
    emit MinBoostChange(minBoost);
  }

  function setMaxBoost(uint256 _maxBoost) external override onlyGovernance {

    maxBoost = _maxBoost;
    emit MaxBoostChange(maxBoost);
  }

  function setTargetBond(uint256 _targetBond) external override onlyGovernance {

    targetBond = _targetBond;
    emit TargetBondChange(targetBond);
  }

  function setKeep3rV2(address _keep3rV2) external override onlyGovernance {

    keep3rV2 = _keep3rV2;
    emit Keep3rV2Change(keep3rV2);
  }

  function setWorkExtraGas(uint256 _workExtraGas) external override onlyGovernance {

    workExtraGas = _workExtraGas;
    emit WorkExtraGasChange(workExtraGas);
  }

  function setQuoteTwapTime(uint32 _quoteTwapTime) external override onlyGovernance {

    quoteTwapTime = _quoteTwapTime;
    emit QuoteTwapTimeChange(quoteTwapTime);
  }

  function _setKp3rWethPool(address _poolAddress) internal {

    bool _isKP3RToken0 = IUniswapV3Pool(_poolAddress).token0() == KP3R;
    bool _isKP3RToken1 = IUniswapV3Pool(_poolAddress).token1() == KP3R;

    if (!_isKP3RToken0 && !_isKP3RToken1) revert InvalidKp3rPool();

    kp3rWethPool = Kp3rWethPool(_poolAddress, _isKP3RToken0);
  }
}// MIT


pragma solidity >=0.8.7 <0.9.0;



contract Keep3rHelper is IKeep3rHelper, Keep3rHelperParameters {

  constructor(address _keep3rV2, address _governance) Keep3rHelperParameters(_keep3rV2, _governance) {}

  function quote(uint256 _eth) public view override returns (uint256 _amountOut) {

    uint32[] memory _secondsAgos = new uint32[](2);
    _secondsAgos[1] = quoteTwapTime;

    (int56[] memory _tickCumulatives, ) = IUniswapV3Pool(kp3rWethPool.poolAddress).observe(_secondsAgos);
    int56 _difference = _tickCumulatives[0] - _tickCumulatives[1];
    _amountOut = getQuoteAtTick(uint128(_eth), kp3rWethPool.isKP3RToken0 ? _difference : -_difference, quoteTwapTime);
  }

  function bonds(address _keeper) public view override returns (uint256 _amountBonded) {

    return IKeep3r(keep3rV2).bonds(_keeper, KP3R);
  }

  function getRewardAmountFor(address _keeper, uint256 _gasUsed) public view override returns (uint256 _kp3r) {

    uint256 _boost = getRewardBoostFor(bonds(_keeper));
    _kp3r = quote((_gasUsed * _boost) / BOOST_BASE);
  }

  function getRewardAmount(uint256 _gasUsed) external view override returns (uint256 _amount) {

    return getRewardAmountFor(tx.origin, _gasUsed);
  }

  function getRewardBoostFor(uint256 _bonds) public view override returns (uint256 _rewardBoost) {

    _bonds = Math.min(_bonds, targetBond);
    uint256 _cap = Math.max(minBoost, minBoost + ((maxBoost - minBoost) * _bonds) / targetBond);
    _rewardBoost = _cap * _getBasefee();
  }

  function getPoolTokens(address _pool) public view override returns (address _token0, address _token1) {

    return (IUniswapV3Pool(_pool).token0(), IUniswapV3Pool(_pool).token1());
  }

  function isKP3RToken0(address _pool) public view override returns (bool _isKP3RToken0) {

    address _token0;
    address _token1;
    (_token0, _token1) = getPoolTokens(_pool);
    if (_token0 == KP3R) {
      return true;
    } else if (_token1 != KP3R) {
      revert LiquidityPairInvalid();
    }
  }

  function observe(address _pool, uint32[] memory _secondsAgo)
    public
    view
    override
    returns (
      int56 _tickCumulative1,
      int56 _tickCumulative2,
      bool _success
    )
  {

    try IUniswapV3Pool(_pool).observe(_secondsAgo) returns (int56[] memory _uniswapResponse, uint160[] memory) {
      _tickCumulative1 = _uniswapResponse[0];
      if (_uniswapResponse.length > 1) {
        _tickCumulative2 = _uniswapResponse[1];
      }
      _success = true;
    } catch (bytes memory) {}
  }

  function getPaymentParams(uint256 _bonds)
    external
    view
    override
    returns (
      uint256 _boost,
      uint256 _oneEthQuote,
      uint256 _extra
    )
  {
    _oneEthQuote = quote(1 ether);
    _boost = getRewardBoostFor(_bonds);
    _extra = workExtraGas;
  }

  function getKP3RsAtTick(
    uint256 _liquidityAmount,
    int56 _tickDifference,
    uint256 _timeInterval
  ) public pure override returns (uint256 _kp3rAmount) {
    uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(int24(_tickDifference / int256(_timeInterval)));
    _kp3rAmount = FullMath.mulDiv(1 << 96, _liquidityAmount, sqrtRatioX96);
  }

  function getQuoteAtTick(
    uint128 _baseAmount,
    int56 _tickDifference,
    uint256 _timeInterval
  ) public pure override returns (uint256 _quoteAmount) {
    uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(int24(_tickDifference / int256(_timeInterval)));

    if (sqrtRatioX96 <= type(uint128).max) {
      uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
      _quoteAmount = FullMath.mulDiv(1 << 192, _baseAmount, ratioX192);
    } else {
      uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
      _quoteAmount = FullMath.mulDiv(1 << 128, _baseAmount, ratioX128);
    }
  }

  function _getBasefee() internal view virtual returns (uint256 _baseFee) {
    return block.basefee;
  }
}