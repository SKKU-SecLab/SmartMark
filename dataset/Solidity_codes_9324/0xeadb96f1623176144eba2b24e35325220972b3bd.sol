
pragma solidity ^0.7.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.7.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity 0.7.6;


abstract contract PermissionAdmin {
    address public admin;
    address public pendingAdmin;

    event AdminClaimed(address newAdmin, address previousAdmin);

    event TransferAdminPending(address pendingAdmin);

    constructor(address _admin) {
        require(_admin != address(0), "admin 0");
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "new admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    function claimAdmin() public {
        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }
}// MIT
pragma solidity 0.7.6;

interface IEpochUtils {

  function epochPeriodInSeconds() external view returns (uint256);


  function firstEpochStartTime() external view returns (uint256);


  function getCurrentEpochNumber() external view returns (uint256);


  function getEpochNumber(uint256 timestamp) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.7.6;
pragma abicoder v2;



interface IKyberStaking is IEpochUtils {

  event Delegated(
    address indexed staker,
    address indexed representative,
    uint256 indexed epoch,
    bool isDelegated
  );
  event Deposited(uint256 curEpoch, address indexed staker, uint256 amount);
  event Withdraw(uint256 indexed curEpoch, address indexed staker, uint256 amount);

  function initAndReturnStakerDataForCurrentEpoch(address staker)
    external
    returns (
      uint256 stake,
      uint256 delegatedStake,
      address representative
    );


  function deposit(uint256 amount) external;


  function delegate(address dAddr) external;


  function withdraw(uint256 amount) external;


  function getStakerData(address staker, uint256 epoch)
    external
    view
    returns (
      uint256 stake,
      uint256 delegatedStake,
      address representative
    );


  function getLatestStakerData(address staker)
    external
    view
    returns (
      uint256 stake,
      uint256 delegatedStake,
      address representative
    );


  function getStakerRawData(address staker, uint256 epoch)
    external
    view
    returns (
      uint256 stake,
      uint256 delegatedStake,
      address representative
    );


  function kncToken() external view returns (IERC20);

}// agpl-3.0
pragma solidity 0.7.6;

interface IWithdrawHandler {

  function handleWithdrawal(address staker, uint256 reduceAmount) external;

}// MIT
pragma solidity 0.7.6;



contract EpochUtils is IEpochUtils {

  using SafeMath for uint256;

  uint256 public immutable override epochPeriodInSeconds;
  uint256 public immutable override firstEpochStartTime;

  constructor(uint256 _epochPeriod, uint256 _startTime) {
    require(_epochPeriod > 0, 'ctor: epoch period is 0');

    epochPeriodInSeconds = _epochPeriod;
    firstEpochStartTime = _startTime;
  }

  function getCurrentEpochNumber() public override view returns (uint256) {

    return getEpochNumber(block.timestamp);
  }

  function getEpochNumber(uint256 currentTime) public override view returns (uint256) {

    if (currentTime < firstEpochStartTime || epochPeriodInSeconds == 0) {
      return 0;
    }
    return ((currentTime.sub(firstEpochStartTime)).div(epochPeriodInSeconds)).add(1);
  }
}// MIT
pragma solidity 0.7.6;



contract KyberStaking is IKyberStaking, EpochUtils, ReentrancyGuard, PermissionAdmin {

  using Math for uint256;
  using SafeMath for uint256;
  struct StakerData {
    uint128 stake;
    uint128 delegatedStake;
    address representative;
    bool hasInited;
  }

  IERC20 public immutable override kncToken;

  IWithdrawHandler public withdrawHandler;
  mapping(uint256 => mapping(address => StakerData)) internal stakerPerEpochData;
  mapping(address => StakerData) internal stakerLatestData;

  event WithdrawDataUpdateFailed(uint256 curEpoch, address staker, uint256 amount);

  event UpdateWithdrawHandler(IWithdrawHandler withdrawHandler);

  constructor(
    address _admin,
    IERC20 _kncToken,
    uint256 _epochPeriod,
    uint256 _startTime
  ) PermissionAdmin(_admin) EpochUtils(_epochPeriod, _startTime) {
    require(_startTime >= block.timestamp, 'ctor: start in the past');

    require(_kncToken != IERC20(0), 'ctor: kncToken 0');
    kncToken = _kncToken;
  }

  function updateWithdrawHandler(IWithdrawHandler _withdrawHandler) external onlyAdmin {

    withdrawHandler = _withdrawHandler;

    emit UpdateWithdrawHandler(_withdrawHandler);
  }

  function delegate(address newRepresentative) external override {

    require(newRepresentative != address(0), 'delegate: representative 0');
    address staker = msg.sender;
    uint256 curEpoch = getCurrentEpochNumber();

    initDataIfNeeded(staker, curEpoch);

    address curRepresentative = stakerPerEpochData[curEpoch + 1][staker].representative;
    if (newRepresentative == curRepresentative) {
      return;
    }

    uint256 updatedStake = stakerPerEpochData[curEpoch + 1][staker].stake;

    if (curRepresentative != staker) {
      initDataIfNeeded(curRepresentative, curEpoch);
      decreaseDelegatedStake(stakerPerEpochData[curEpoch + 1][curRepresentative], updatedStake);
      decreaseDelegatedStake(stakerLatestData[curRepresentative], updatedStake);

      emit Delegated(staker, curRepresentative, curEpoch, false);
    }

    stakerLatestData[staker].representative = newRepresentative;
    stakerPerEpochData[curEpoch + 1][staker].representative = newRepresentative;

    if (newRepresentative != staker) {
      initDataIfNeeded(newRepresentative, curEpoch);
      increaseDelegatedStake(stakerPerEpochData[curEpoch + 1][newRepresentative], updatedStake);
      increaseDelegatedStake(stakerLatestData[newRepresentative], updatedStake);

      emit Delegated(staker, newRepresentative, curEpoch, true);
    }
  }

  function deposit(uint256 amount) external override {

    require(amount > 0, 'deposit: amount is 0');

    uint256 curEpoch = getCurrentEpochNumber();
    address staker = msg.sender;

    require(kncToken.transferFrom(staker, address(this), amount), 'deposit: can not get token');

    initDataIfNeeded(staker, curEpoch);
    increaseStake(stakerPerEpochData[curEpoch + 1][staker], amount);
    increaseStake(stakerLatestData[staker], amount);

    address representative = stakerPerEpochData[curEpoch + 1][staker].representative;
    if (representative != staker) {
      initDataIfNeeded(representative, curEpoch);
      increaseDelegatedStake(stakerPerEpochData[curEpoch + 1][representative], amount);
      increaseDelegatedStake(stakerLatestData[representative], amount);
    }

    emit Deposited(curEpoch, staker, amount);
  }

  function withdraw(uint256 amount) external override nonReentrant {

    require(amount > 0, 'withdraw: amount is 0');

    uint256 curEpoch = getCurrentEpochNumber();
    address staker = msg.sender;

    require(
      stakerLatestData[staker].stake >= amount,
      'withdraw: latest amount staked < withdrawal amount'
    );

    initDataIfNeeded(staker, curEpoch);
    decreaseStake(stakerLatestData[staker], amount);

    (bool success, ) = address(this).call(
      abi.encodeWithSelector(KyberStaking.handleWithdrawal.selector, staker, amount, curEpoch)
    );
    if (!success) {
      emit WithdrawDataUpdateFailed(curEpoch, staker, amount);
    }

    require(kncToken.transfer(staker, amount), 'withdraw: can not transfer knc');
    emit Withdraw(curEpoch, staker, amount);
  }

  function initAndReturnStakerDataForCurrentEpoch(address staker)
    external
    override
    nonReentrant
    returns (
      uint256 stake,
      uint256 delegatedStake,
      address representative
    )
  {

    uint256 curEpoch = getCurrentEpochNumber();
    initDataIfNeeded(staker, curEpoch);

    StakerData memory stakerData = stakerPerEpochData[curEpoch][staker];
    stake = stakerData.stake;
    delegatedStake = stakerData.delegatedStake;
    representative = stakerData.representative;
  }

  function getStakerRawData(address staker, uint256 epoch)
    external
    override
    view
    returns (
      uint256 stake,
      uint256 delegatedStake,
      address representative
    )
  {

    StakerData memory stakerData = stakerPerEpochData[epoch][staker];
    stake = stakerData.stake;
    delegatedStake = stakerData.delegatedStake;
    representative = stakerData.representative;
  }

  function getStake(address staker, uint256 epoch) external view returns (uint256) {

    uint256 curEpoch = getCurrentEpochNumber();
    if (epoch > curEpoch + 1) {
      return 0;
    }
    uint256 i = epoch;
    while (true) {
      if (stakerPerEpochData[i][staker].hasInited) {
        return stakerPerEpochData[i][staker].stake;
      }
      if (i == 0) {
        break;
      }
      i--;
    }
    return 0;
  }

  function getDelegatedStake(address staker, uint256 epoch) external view returns (uint256) {

    uint256 curEpoch = getCurrentEpochNumber();
    if (epoch > curEpoch + 1) {
      return 0;
    }
    uint256 i = epoch;
    while (true) {
      if (stakerPerEpochData[i][staker].hasInited) {
        return stakerPerEpochData[i][staker].delegatedStake;
      }
      if (i == 0) {
        break;
      }
      i--;
    }
    return 0;
  }

  function getRepresentative(address staker, uint256 epoch) external view returns (address) {

    uint256 curEpoch = getCurrentEpochNumber();
    if (epoch > curEpoch + 1) {
      return address(0);
    }
    uint256 i = epoch;
    while (true) {
      if (stakerPerEpochData[i][staker].hasInited) {
        return stakerPerEpochData[i][staker].representative;
      }
      if (i == 0) {
        break;
      }
      i--;
    }
    return staker;
  }

  function getStakerData(address staker, uint256 epoch)
    external
    override
    view
    returns (
      uint256 stake,
      uint256 delegatedStake,
      address representative
    )
  {

    stake = 0;
    delegatedStake = 0;
    representative = address(0);

    uint256 curEpoch = getCurrentEpochNumber();
    if (epoch > curEpoch + 1) {
      return (stake, delegatedStake, representative);
    }
    uint256 i = epoch;
    while (true) {
      if (stakerPerEpochData[i][staker].hasInited) {
        stake = stakerPerEpochData[i][staker].stake;
        delegatedStake = stakerPerEpochData[i][staker].delegatedStake;
        representative = stakerPerEpochData[i][staker].representative;
        return (stake, delegatedStake, representative);
      }
      if (i == 0) {
        break;
      }
      i--;
    }
    representative = staker;
  }

  function getLatestRepresentative(address staker) external view returns (address) {

    return
      stakerLatestData[staker].representative == address(0)
        ? staker
        : stakerLatestData[staker].representative;
  }

  function getLatestDelegatedStake(address staker) external view returns (uint256) {

    return stakerLatestData[staker].delegatedStake;
  }

  function getLatestStakeBalance(address staker) external view returns (uint256) {

    return stakerLatestData[staker].stake;
  }

  function getLatestStakerData(address staker)
    external
    override
    view
    returns (
      uint256 stake,
      uint256 delegatedStake,
      address representative
    )
  {

    stake = stakerLatestData[staker].stake;
    delegatedStake = stakerLatestData[staker].delegatedStake;
    representative = stakerLatestData[staker].representative == address(0)
      ? staker
      : stakerLatestData[staker].representative;
  }

  function handleWithdrawal(
    address staker,
    uint256 amount,
    uint256 curEpoch
  ) external {

    require(msg.sender == address(this), 'only staking contract');
    decreaseStake(stakerPerEpochData[curEpoch + 1][staker], amount);
    address representative = stakerPerEpochData[curEpoch + 1][staker].representative;
    if (representative != staker) {
      initDataIfNeeded(representative, curEpoch);
      decreaseDelegatedStake(stakerPerEpochData[curEpoch + 1][representative], amount);
      decreaseDelegatedStake(stakerLatestData[representative], amount);
    }

    representative = stakerPerEpochData[curEpoch][staker].representative;
    uint256 curStake = stakerPerEpochData[curEpoch][staker].stake;
    uint256 lStakeBal = stakerLatestData[staker].stake;
    uint256 newStake = curStake.min(lStakeBal);
    uint256 reduceAmount = curStake.sub(newStake); // newStake is always <= curStake

    if (reduceAmount > 0) {
      if (representative != staker) {
        initDataIfNeeded(representative, curEpoch);
        decreaseDelegatedStake(stakerPerEpochData[curEpoch][representative], reduceAmount);
      }
      stakerPerEpochData[curEpoch][staker].stake = SafeCast.toUint128(newStake);
      if (withdrawHandler != IWithdrawHandler(0)) {
        (bool success, ) = address(withdrawHandler).call(
          abi.encodeWithSelector(
            IWithdrawHandler.handleWithdrawal.selector,
            representative,
            reduceAmount
          )
        );
        if (!success) {
          emit WithdrawDataUpdateFailed(curEpoch, staker, amount);
        }
      }
    }
  }

  function initDataIfNeeded(address staker, uint256 epoch) internal {

    address representative = stakerLatestData[staker].representative;
    if (representative == address(0)) {
      stakerLatestData[staker].representative = staker;
      representative = staker;
    }

    uint128 lStakeBal = stakerLatestData[staker].stake;
    uint128 ldStake = stakerLatestData[staker].delegatedStake;

    if (!stakerPerEpochData[epoch][staker].hasInited) {
      stakerPerEpochData[epoch][staker] = StakerData({
        stake: lStakeBal,
        delegatedStake: ldStake,
        representative: representative,
        hasInited: true
      });
    }

    if (!stakerPerEpochData[epoch + 1][staker].hasInited) {
      stakerPerEpochData[epoch + 1][staker] = StakerData({
        stake: lStakeBal,
        delegatedStake: ldStake,
        representative: representative,
        hasInited: true
      });
    }
  }

  function decreaseDelegatedStake(StakerData storage stakeData, uint256 amount) internal {

    stakeData.delegatedStake = SafeCast.toUint128(uint256(stakeData.delegatedStake).sub(amount));
  }

  function increaseDelegatedStake(StakerData storage stakeData, uint256 amount) internal {

    stakeData.delegatedStake = SafeCast.toUint128(uint256(stakeData.delegatedStake).add(amount));
  }

  function increaseStake(StakerData storage stakeData, uint256 amount) internal {

    stakeData.stake = SafeCast.toUint128(uint256(stakeData.stake).add(amount));
  }

  function decreaseStake(StakerData storage stakeData, uint256 amount) internal {

    stakeData.stake = SafeCast.toUint128(uint256(stakeData.stake).sub(amount));
  }
}