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


abstract contract Keep3rJobOwnership is IKeep3rJobOwnership {
  mapping(address => address) public override jobOwner;

  mapping(address => address) public override jobPendingOwner;

  function changeJobOwnership(address _job, address _newOwner) external override onlyJobOwner(_job) {
    jobPendingOwner[_job] = _newOwner;
    emit JobOwnershipChange(_job, jobOwner[_job], _newOwner);
  }

  function acceptJobOwnership(address _job) external override onlyPendingJobOwner(_job) {
    address _previousOwner = jobOwner[_job];

    jobOwner[_job] = jobPendingOwner[_job];
    delete jobPendingOwner[_job];

    emit JobOwnershipAssent(msg.sender, _job, _previousOwner);
  }

  modifier onlyJobOwner(address _job) {
    if (msg.sender != jobOwner[_job]) revert OnlyJobOwner();
    _;
  }

  modifier onlyPendingJobOwner(address _job) {
    if (msg.sender != jobPendingOwner[_job]) revert OnlyPendingJobOwner();
    _;
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


abstract contract Keep3rAccountance is IKeep3rAccountance {
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet internal _keepers;

  mapping(address => uint256) public override workCompleted;

  mapping(address => uint256) public override firstSeen;

  mapping(address => bool) public override disputes;

  mapping(address => mapping(address => uint256)) public override bonds;

  mapping(address => mapping(address => uint256)) public override jobTokenCredits;

  mapping(address => uint256) internal _jobLiquidityCredits;

  mapping(address => uint256) internal _jobPeriodCredits;

  mapping(address => EnumerableSet.AddressSet) internal _jobTokens;

  mapping(address => EnumerableSet.AddressSet) internal _jobLiquidities;

  mapping(address => address) internal _liquidityPool;

  mapping(address => bool) internal _isKP3RToken0;

  mapping(address => mapping(address => uint256)) public override pendingBonds;

  mapping(address => mapping(address => uint256)) public override canActivateAfter;

  mapping(address => mapping(address => uint256)) public override canWithdrawAfter;

  mapping(address => mapping(address => uint256)) public override pendingUnbonds;

  mapping(address => bool) public override hasBonded;

  EnumerableSet.AddressSet internal _jobs;

  function jobs() external view override returns (address[] memory _list) {
    _list = _jobs.values();
  }

  function keepers() external view override returns (address[] memory _list) {
    _list = _keepers.values();
  }
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
pragma solidity >=0.8.4 <0.9.0;


contract Keep3rRoles is IKeep3rRoles, Governable {

  mapping(address => bool) public override slashers;

  mapping(address => bool) public override disputers;

  constructor(address _governance) Governable(_governance) {}

  function addSlasher(address _slasher) external override onlyGovernance {

    if (slashers[_slasher]) revert SlasherExistent();
    slashers[_slasher] = true;
    emit SlasherAdded(_slasher);
  }

  function removeSlasher(address _slasher) external override onlyGovernance {

    if (!slashers[_slasher]) revert SlasherUnexistent();
    delete slashers[_slasher];
    emit SlasherRemoved(_slasher);
  }

  function addDisputer(address _disputer) external override onlyGovernance {

    if (disputers[_disputer]) revert DisputerExistent();
    disputers[_disputer] = true;
    emit DisputerAdded(_disputer);
  }

  function removeDisputer(address _disputer) external override onlyGovernance {

    if (!disputers[_disputer]) revert DisputerUnexistent();
    delete disputers[_disputer];
    emit DisputerRemoved(_disputer);
  }

  modifier onlySlasher {

    if (!slashers[msg.sender]) revert OnlySlasher();
    _;
  }

  modifier onlyDisputer {

    if (!disputers[msg.sender]) revert OnlyDisputer();
    _;
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Keep3rParameters is IKeep3rParameters, Keep3rAccountance, Keep3rRoles {
  address public override keep3rV1;

  address public override keep3rV1Proxy;

  address public override keep3rHelper;

  address public override kp3rWethPool;

  uint256 public override bondTime = 3 days;

  uint256 public override unbondTime = 14 days;

  uint256 public override liquidityMinimum = 3 ether;

  uint256 public override rewardPeriodTime = 5 days;

  uint256 public override inflationPeriod = 34 days;

  uint256 public override fee = 30;

  uint256 internal constant _BASE = 10_000;

  uint256 internal constant _MIN_REWARD_PERIOD_TIME = 1 days;

  constructor(
    address _keep3rHelper,
    address _keep3rV1,
    address _keep3rV1Proxy,
    address _kp3rWethPool
  ) {
    keep3rHelper = _keep3rHelper;
    keep3rV1 = _keep3rV1;
    keep3rV1Proxy = _keep3rV1Proxy;
    kp3rWethPool = _kp3rWethPool;
    _liquidityPool[kp3rWethPool] = kp3rWethPool;
    _isKP3RToken0[_kp3rWethPool] = IKeep3rHelper(keep3rHelper).isKP3RToken0(kp3rWethPool);
  }

  function setKeep3rHelper(address _keep3rHelper) external override onlyGovernance {
    if (_keep3rHelper == address(0)) revert ZeroAddress();
    keep3rHelper = _keep3rHelper;
    emit Keep3rHelperChange(_keep3rHelper);
  }

  function setKeep3rV1(address _keep3rV1) external override onlyGovernance {
    if (_keep3rV1 == address(0)) revert ZeroAddress();
    keep3rV1 = _keep3rV1;
    emit Keep3rV1Change(_keep3rV1);
  }

  function setKeep3rV1Proxy(address _keep3rV1Proxy) external override onlyGovernance {
    if (_keep3rV1Proxy == address(0)) revert ZeroAddress();
    keep3rV1Proxy = _keep3rV1Proxy;
    emit Keep3rV1ProxyChange(_keep3rV1Proxy);
  }

  function setKp3rWethPool(address _kp3rWethPool) external override onlyGovernance {
    if (_kp3rWethPool == address(0)) revert ZeroAddress();
    kp3rWethPool = _kp3rWethPool;
    _liquidityPool[kp3rWethPool] = kp3rWethPool;
    _isKP3RToken0[_kp3rWethPool] = IKeep3rHelper(keep3rHelper).isKP3RToken0(_kp3rWethPool);
    emit Kp3rWethPoolChange(_kp3rWethPool);
  }

  function setBondTime(uint256 _bondTime) external override onlyGovernance {
    bondTime = _bondTime;
    emit BondTimeChange(_bondTime);
  }

  function setUnbondTime(uint256 _unbondTime) external override onlyGovernance {
    unbondTime = _unbondTime;
    emit UnbondTimeChange(_unbondTime);
  }

  function setLiquidityMinimum(uint256 _liquidityMinimum) external override onlyGovernance {
    liquidityMinimum = _liquidityMinimum;
    emit LiquidityMinimumChange(_liquidityMinimum);
  }

  function setRewardPeriodTime(uint256 _rewardPeriodTime) external override onlyGovernance {
    if (_rewardPeriodTime < _MIN_REWARD_PERIOD_TIME) revert MinRewardPeriod();
    rewardPeriodTime = _rewardPeriodTime;
    emit RewardPeriodTimeChange(_rewardPeriodTime);
  }

  function setInflationPeriod(uint256 _inflationPeriod) external override onlyGovernance {
    inflationPeriod = _inflationPeriod;
    emit InflationPeriodChange(_inflationPeriod);
  }

  function setFee(uint256 _fee) external override onlyGovernance {
    fee = _fee;
    emit FeeChange(_fee);
  }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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
pragma solidity >=0.8.4 <0.9.0;



abstract contract Keep3rJobFundableCredits is IKeep3rJobFundableCredits, ReentrancyGuard, Keep3rJobOwnership, Keep3rParameters {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  uint256 internal constant _WITHDRAW_TOKENS_COOLDOWN = 1 minutes;

  mapping(address => mapping(address => uint256)) public override jobTokenCreditsAddedAt;

  function addTokenCreditsToJob(
    address _job,
    address _token,
    uint256 _amount
  ) external override nonReentrant {
    if (!_jobs.contains(_job)) revert JobUnavailable();
    if (_token == keep3rV1) revert TokenUnallowed();
    uint256 _before = IERC20(_token).balanceOf(address(this));
    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
    uint256 _received = IERC20(_token).balanceOf(address(this)) - _before;
    uint256 _tokenFee = (_received * fee) / _BASE;
    jobTokenCredits[_job][_token] += _received - _tokenFee;
    jobTokenCreditsAddedAt[_job][_token] = block.timestamp;
    IERC20(_token).safeTransfer(governance, _tokenFee);
    _jobTokens[_job].add(_token);

    emit TokenCreditAddition(_job, _token, msg.sender, _received);
  }

  function withdrawTokenCreditsFromJob(
    address _job,
    address _token,
    uint256 _amount,
    address _receiver
  ) external override nonReentrant onlyJobOwner(_job) {
    if (block.timestamp <= jobTokenCreditsAddedAt[_job][_token] + _WITHDRAW_TOKENS_COOLDOWN) revert JobTokenCreditsLocked();
    if (jobTokenCredits[_job][_token] < _amount) revert InsufficientJobTokenCredits();
    if (disputes[_job]) revert JobDisputed();

    jobTokenCredits[_job][_token] -= _amount;
    IERC20(_token).safeTransfer(_receiver, _amount);

    if (jobTokenCredits[_job][_token] == 0) {
      _jobTokens[_job].remove(_token);
    }

    emit TokenCreditWithdrawal(_job, _token, _receiver, _amount);
  }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT
pragma solidity >=0.8.4 <0.9.0;


interface IPairManager is IERC20Metadata {

  function factory() external view returns (address _factory);


  function pool() external view returns (address _pool);


  function token0() external view returns (address _token0);


  function token1() external view returns (address _token1);

}// MIT
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
}// MIT
pragma solidity >=0.8.4 <0.9.0;




abstract contract Keep3rJobFundableLiquidity is IKeep3rJobFundableLiquidity, ReentrancyGuard, Keep3rJobOwnership, Keep3rParameters {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  EnumerableSet.AddressSet internal _approvedLiquidities;

  mapping(address => mapping(address => uint256)) public override liquidityAmount;

  mapping(address => uint256) public override rewardedAt;

  mapping(address => uint256) public override workedAt;

  mapping(address => TickCache) internal _tick;


  function approvedLiquidities() external view override returns (address[] memory _list) {
    _list = _approvedLiquidities.values();
  }

  function jobPeriodCredits(address _job) public view override returns (uint256 _periodCredits) {
    for (uint256 i; i < _jobLiquidities[_job].length(); i++) {
      address _liquidity = _jobLiquidities[_job].at(i);
      if (_approvedLiquidities.contains(_liquidity)) {
        TickCache memory _tickCache = observeLiquidity(_liquidity);
        if (_tickCache.period != 0) {
          int56 _tickDifference = _isKP3RToken0[_liquidity] ? _tickCache.difference : -_tickCache.difference;
          _periodCredits += _getReward(
            IKeep3rHelper(keep3rHelper).getKP3RsAtTick(liquidityAmount[_job][_liquidity], _tickDifference, rewardPeriodTime)
          );
        }
      }
    }
  }

  function jobLiquidityCredits(address _job) public view override returns (uint256 _liquidityCredits) {
    uint256 _periodCredits = jobPeriodCredits(_job);

    if ((block.timestamp - rewardedAt[_job]) < rewardPeriodTime) {
      _liquidityCredits = _periodCredits > 0
        ? (_jobLiquidityCredits[_job] * _periodCredits) / _jobPeriodCredits[_job] // If the job has period credits, return remaining job credits updated to new twap
        : _jobLiquidityCredits[_job]; // If not, return remaining credits, forced credits should not be updated
    } else {
      _liquidityCredits = _periodCredits;
    }
  }

  function totalJobCredits(address _job) external view override returns (uint256 _credits) {
    uint256 _periodCredits = jobPeriodCredits(_job);
    uint256 _cooldown = block.timestamp;

    if ((rewardedAt[_job] > _period(block.timestamp - rewardPeriodTime))) {
      if ((block.timestamp - rewardedAt[_job]) >= rewardPeriodTime) {
        _cooldown -= (rewardedAt[_job] + rewardPeriodTime);
      } else {
        _cooldown -= rewardedAt[_job];
      }
    } else {
      _cooldown -= _period(block.timestamp);
    }
    _credits = jobLiquidityCredits(_job) + _phase(_cooldown, _periodCredits);
  }

  function quoteLiquidity(address _liquidity, uint256 _amount) external view override returns (uint256 _periodCredits) {
    if (_approvedLiquidities.contains(_liquidity)) {
      TickCache memory _tickCache = observeLiquidity(_liquidity);
      if (_tickCache.period != 0) {
        int56 _tickDifference = _isKP3RToken0[_liquidity] ? _tickCache.difference : -_tickCache.difference;
        return _getReward(IKeep3rHelper(keep3rHelper).getKP3RsAtTick(_amount, _tickDifference, rewardPeriodTime));
      }
    }
  }

  function observeLiquidity(address _liquidity) public view override returns (TickCache memory _tickCache) {
    if (_tick[_liquidity].period == _period(block.timestamp)) {
      _tickCache = _tick[_liquidity];
    } else {
      bool success;
      uint256 lastPeriod = _period(block.timestamp - rewardPeriodTime);

      if (_tick[_liquidity].period == lastPeriod) {
        uint32[] memory _secondsAgo = new uint32[](1);
        int56 previousTick = _tick[_liquidity].current;

        _secondsAgo[0] = uint32(block.timestamp - _period(block.timestamp));

        (_tickCache.current, , success) = IKeep3rHelper(keep3rHelper).observe(_liquidityPool[_liquidity], _secondsAgo);

        _tickCache.difference = _tickCache.current - previousTick;
      } else if (_tick[_liquidity].period < lastPeriod) {
        uint32[] memory _secondsAgo = new uint32[](2);

        _secondsAgo[0] = uint32(block.timestamp - _period(block.timestamp));
        _secondsAgo[1] = uint32(block.timestamp - _period(block.timestamp) + rewardPeriodTime);

        int56 _tickCumulative2;
        (_tickCache.current, _tickCumulative2, success) = IKeep3rHelper(keep3rHelper).observe(_liquidityPool[_liquidity], _secondsAgo);

        _tickCache.difference = _tickCache.current - _tickCumulative2;
      }
      if (success) {
        _tickCache.period = _period(block.timestamp);
      } else {
        delete _tickCache.period;
      }
    }
  }


  function forceLiquidityCreditsToJob(address _job, uint256 _amount) external override onlyGovernance {
    if (!_jobs.contains(_job)) revert JobUnavailable();
    _settleJobAccountance(_job);
    _jobLiquidityCredits[_job] += _amount;
    emit LiquidityCreditsForced(_job, rewardedAt[_job], _jobLiquidityCredits[_job]);
  }

  function approveLiquidity(address _liquidity) external override onlyGovernance {
    if (!_approvedLiquidities.add(_liquidity)) revert LiquidityPairApproved();
    _liquidityPool[_liquidity] = IPairManager(_liquidity).pool();
    _isKP3RToken0[_liquidity] = IKeep3rHelper(keep3rHelper).isKP3RToken0(_liquidityPool[_liquidity]);
    _tick[_liquidity] = observeLiquidity(_liquidity);
    emit LiquidityApproval(_liquidity);
  }

  function revokeLiquidity(address _liquidity) external override onlyGovernance {
    if (!_approvedLiquidities.remove(_liquidity)) revert LiquidityPairUnexistent();
    emit LiquidityRevocation(_liquidity);
  }

  function addLiquidityToJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external override nonReentrant {
    if (!_approvedLiquidities.contains(_liquidity)) revert LiquidityPairUnapproved();
    if (!_jobs.contains(_job)) revert JobUnavailable();

    _jobLiquidities[_job].add(_liquidity);

    _settleJobAccountance(_job);

    if (_quoteLiquidity(liquidityAmount[_job][_liquidity] + _amount, _liquidity) < liquidityMinimum) revert JobLiquidityLessThanMin();

    emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);

    IERC20(_liquidity).safeTransferFrom(msg.sender, address(this), _amount);
    liquidityAmount[_job][_liquidity] += _amount;
    _jobPeriodCredits[_job] += _getReward(_quoteLiquidity(_amount, _liquidity));
    emit LiquidityAddition(_job, _liquidity, msg.sender, _amount);
  }

  function unbondLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external override onlyJobOwner(_job) {
    canWithdrawAfter[_job][_liquidity] = block.timestamp + unbondTime;
    pendingUnbonds[_job][_liquidity] += _amount;
    _unbondLiquidityFromJob(_job, _liquidity, _amount);

    uint256 _remainingLiquidity = liquidityAmount[_job][_liquidity];
    if (_remainingLiquidity > 0 && _quoteLiquidity(_remainingLiquidity, _liquidity) < liquidityMinimum) revert JobLiquidityLessThanMin();

    emit Unbonding(_job, _liquidity, _amount);
  }

  function withdrawLiquidityFromJob(
    address _job,
    address _liquidity,
    address _receiver
  ) external override onlyJobOwner(_job) {
    if (_receiver == address(0)) revert ZeroAddress();
    if (pendingUnbonds[_job][_liquidity] == 0) revert UnbondsUnexistent();
    if (canWithdrawAfter[_job][_liquidity] >= block.timestamp) revert UnbondsLocked();
    if (disputes[_job]) revert Disputed();

    uint256 _amount = pendingUnbonds[_job][_liquidity];

    delete pendingUnbonds[_job][_liquidity];
    delete canWithdrawAfter[_job][_liquidity];

    IERC20(_liquidity).safeTransfer(_receiver, _amount);
    emit LiquidityWithdrawal(_job, _liquidity, _receiver, _amount);
  }


  function _updateJobCreditsIfNeeded(address _job) internal returns (bool _rewarded) {
    if (rewardedAt[_job] < _period(block.timestamp)) {
      if (rewardedAt[_job] <= _period(block.timestamp - rewardPeriodTime)) {
        _updateJobPeriod(_job);
        _jobLiquidityCredits[_job] = _jobPeriodCredits[_job];
        rewardedAt[_job] = _period(block.timestamp);
        _rewarded = true;
      } else if ((block.timestamp - rewardedAt[_job]) >= rewardPeriodTime) {
        _updateJobPeriod(_job);
        _jobLiquidityCredits[_job] = _jobPeriodCredits[_job];
        rewardedAt[_job] += rewardPeriodTime;
        _rewarded = true;
      } else if (workedAt[_job] < _period(block.timestamp)) {
        uint256 previousPeriodCredits = _jobPeriodCredits[_job];
        _updateJobPeriod(_job);
        _jobLiquidityCredits[_job] = (_jobLiquidityCredits[_job] * _jobPeriodCredits[_job]) / previousPeriodCredits;
      }
    }
  }

  function _rewardJobCredits(address _job) internal {
    _jobLiquidityCredits[_job] += _phase(block.timestamp - rewardedAt[_job], _jobPeriodCredits[_job]);
    rewardedAt[_job] = block.timestamp;
  }

  function _updateJobPeriod(address _job) internal {
    _jobPeriodCredits[_job] = _calculateJobPeriodCredits(_job);
  }

  function _calculateJobPeriodCredits(address _job) internal returns (uint256 _periodCredits) {
    if (_tick[kp3rWethPool].period != _period(block.timestamp)) {
      _tick[kp3rWethPool] = observeLiquidity(kp3rWethPool);
    }

    for (uint256 i; i < _jobLiquidities[_job].length(); i++) {
      address _liquidity = _jobLiquidities[_job].at(i);
      if (_approvedLiquidities.contains(_liquidity)) {
        if (_tick[_liquidity].period != _period(block.timestamp)) {
          _tick[_liquidity] = observeLiquidity(_liquidity);
        }
        _periodCredits += _getReward(_quoteLiquidity(liquidityAmount[_job][_liquidity], _liquidity));
      }
    }
  }

  function _unbondLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) internal nonReentrant {
    if (!_jobLiquidities[_job].contains(_liquidity)) revert JobLiquidityUnexistent();
    if (liquidityAmount[_job][_liquidity] < _amount) revert JobLiquidityInsufficient();

    _updateJobPeriod(_job);
    uint256 _periodCreditsToRemove = _getReward(_quoteLiquidity(_amount, _liquidity));

    if (_jobPeriodCredits[_job] > 0) {
      _jobLiquidityCredits[_job] -= (_jobLiquidityCredits[_job] * _periodCreditsToRemove) / _jobPeriodCredits[_job];
      _jobPeriodCredits[_job] -= _periodCreditsToRemove;
    }

    liquidityAmount[_job][_liquidity] -= _amount;
    if (liquidityAmount[_job][_liquidity] == 0) {
      _jobLiquidities[_job].remove(_liquidity);
    }
  }

  function _phase(uint256 _timePassed, uint256 _multiplier) internal view returns (uint256 _result) {
    if (_timePassed < rewardPeriodTime) {
      _result = (_timePassed * _multiplier) / rewardPeriodTime;
    } else _result = _multiplier;
  }

  function _period(uint256 _timestamp) internal view returns (uint256 _periodTimestamp) {
    return _timestamp - (_timestamp % rewardPeriodTime);
  }

  function _getReward(uint256 _baseAmount) internal view returns (uint256 _credits) {
    return FullMath.mulDiv(_baseAmount, rewardPeriodTime, inflationPeriod);
  }

  function _quoteLiquidity(uint256 _amount, address _liquidity) internal view returns (uint256 _quote) {
    if (_tick[_liquidity].period != 0) {
      int56 _tickDifference = _isKP3RToken0[_liquidity] ? _tick[_liquidity].difference : -_tick[_liquidity].difference;
      _quote = IKeep3rHelper(keep3rHelper).getKP3RsAtTick(_amount, _tickDifference, rewardPeriodTime);
    }
  }

  function _settleJobAccountance(address _job) internal virtual {
    _updateJobCreditsIfNeeded(_job);
    _rewardJobCredits(_job);
    _jobLiquidityCredits[_job] = Math.min(_jobLiquidityCredits[_job], _jobPeriodCredits[_job]);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IKeep3rDisputable {

  event Dispute(address indexed _jobOrKeeper, address indexed _disputer);

  event Resolve(address indexed _jobOrKeeper, address indexed _resolver);

  error AlreadyDisputed();

  error NotDisputed();

  function dispute(address _jobOrKeeper) external;


  function resolve(address _jobOrKeeper) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Keep3rDisputable is IKeep3rDisputable, Keep3rAccountance, Keep3rRoles {
  function dispute(address _jobOrKeeper) external override onlyDisputer {
    if (disputes[_jobOrKeeper]) revert AlreadyDisputed();
    disputes[_jobOrKeeper] = true;
    emit Dispute(_jobOrKeeper, msg.sender);
  }

  function resolve(address _jobOrKeeper) external override onlyDisputer {
    if (!disputes[_jobOrKeeper]) revert NotDisputed();
    disputes[_jobOrKeeper] = false;
    emit Resolve(_jobOrKeeper, msg.sender);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Keep3rJobDisputable is IKeep3rJobDisputable, Keep3rDisputable, Keep3rJobFundableCredits, Keep3rJobFundableLiquidity {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  function slashTokenFromJob(
    address _job,
    address _token,
    uint256 _amount
  ) external override onlySlasher {
    if (!disputes[_job]) revert NotDisputed();
    if (!_jobTokens[_job].contains(_token)) revert JobTokenUnexistent();
    if (jobTokenCredits[_job][_token] < _amount) revert JobTokenInsufficient();

    try IERC20(_token).transfer(governance, _amount) {} catch {}
    jobTokenCredits[_job][_token] -= _amount;
    if (jobTokenCredits[_job][_token] == 0) {
      _jobTokens[_job].remove(_token);
    }

    emit JobSlashToken(_job, _token, msg.sender, _amount);
  }

  function slashLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external override onlySlasher {
    if (!disputes[_job]) revert NotDisputed();

    _unbondLiquidityFromJob(_job, _liquidity, _amount);
    try IERC20(_liquidity).transfer(governance, _amount) {} catch {}
    emit JobSlashLiquidity(_job, _liquidity, msg.sender, _amount);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Keep3rJobMigration is IKeep3rJobMigration, Keep3rJobFundableCredits, Keep3rJobFundableLiquidity {
  using EnumerableSet for EnumerableSet.AddressSet;

  uint256 internal constant _MIGRATION_COOLDOWN = 1 minutes;

  mapping(address => address) public override pendingJobMigrations;
  mapping(address => mapping(address => uint256)) internal _migrationCreatedAt;

  function migrateJob(address _fromJob, address _toJob) external override onlyJobOwner(_fromJob) {
    if (_fromJob == _toJob) revert JobMigrationImpossible();

    pendingJobMigrations[_fromJob] = _toJob;
    _migrationCreatedAt[_fromJob][_toJob] = block.timestamp;

    emit JobMigrationRequested(_fromJob, _toJob);
  }

  function acceptJobMigration(address _fromJob, address _toJob) external override onlyJobOwner(_toJob) {
    if (disputes[_fromJob] || disputes[_toJob]) revert JobDisputed();
    if (pendingJobMigrations[_fromJob] != _toJob) revert JobMigrationUnavailable();
    if (block.timestamp < _migrationCreatedAt[_fromJob][_toJob] + _MIGRATION_COOLDOWN) revert JobMigrationLocked();

    _settleJobAccountance(_fromJob);
    _settleJobAccountance(_toJob);

    while (_jobTokens[_fromJob].length() > 0) {
      address _tokenToMigrate = _jobTokens[_fromJob].at(0);
      jobTokenCredits[_toJob][_tokenToMigrate] += jobTokenCredits[_fromJob][_tokenToMigrate];
      delete jobTokenCredits[_fromJob][_tokenToMigrate];
      _jobTokens[_fromJob].remove(_tokenToMigrate);
      _jobTokens[_toJob].add(_tokenToMigrate);
    }

    while (_jobLiquidities[_fromJob].length() > 0) {
      address _liquidity = _jobLiquidities[_fromJob].at(0);

      liquidityAmount[_toJob][_liquidity] += liquidityAmount[_fromJob][_liquidity];
      delete liquidityAmount[_fromJob][_liquidity];

      _jobLiquidities[_toJob].add(_liquidity);
      _jobLiquidities[_fromJob].remove(_liquidity);
    }

    _jobPeriodCredits[_toJob] += _jobPeriodCredits[_fromJob];
    delete _jobPeriodCredits[_fromJob];

    _jobLiquidityCredits[_toJob] += _jobLiquidityCredits[_fromJob];
    delete _jobLiquidityCredits[_fromJob];

    delete rewardedAt[_fromJob];
    _jobs.remove(_fromJob);

    delete jobOwner[_fromJob];
    delete jobPendingOwner[_fromJob];
    delete _migrationCreatedAt[_fromJob][_toJob];
    delete pendingJobMigrations[_fromJob];

    emit JobMigrationSuccessful(_fromJob, _toJob);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;



abstract contract Keep3rJobWorkable is IKeep3rJobWorkable, Keep3rJobMigration {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  uint256 internal _initialGas;

  function isKeeper(address _keeper) external override returns (bool _isKeeper) {
    _initialGas = _getGasLeft();
    if (_keepers.contains(_keeper)) {
      emit KeeperValidation(_initialGas);
      return true;
    }
  }

  function isBondedKeeper(
    address _keeper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) public override returns (bool _isBondedKeeper) {
    _initialGas = _getGasLeft();
    if (
      _keepers.contains(_keeper) &&
      bonds[_keeper][_bond] >= _minBond &&
      workCompleted[_keeper] >= _earned &&
      block.timestamp - firstSeen[_keeper] >= _age
    ) {
      emit KeeperValidation(_initialGas);
      return true;
    }
  }

  function worked(address _keeper) external override {
    address _job = msg.sender;
    if (disputes[_job]) revert JobDisputed();
    if (!_jobs.contains(_job)) revert JobUnapproved();

    if (_updateJobCreditsIfNeeded(_job)) {
      emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);
    }

    (uint256 _boost, uint256 _oneEthQuote, uint256 _extraGas) = IKeep3rHelper(keep3rHelper).getPaymentParams(bonds[_keeper][keep3rV1]);

    uint256 _gasLeft = _getGasLeft();
    uint256 _payment = _calculatePayment(_gasLeft, _extraGas, _oneEthQuote, _boost);

    if (_payment > _jobLiquidityCredits[_job]) {
      _rewardJobCredits(_job);
      emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);

      _gasLeft = _getGasLeft();
      _payment = _calculatePayment(_gasLeft, _extraGas, _oneEthQuote, _boost);
    }

    _bondedPayment(_job, _keeper, _payment);
    emit KeeperWork(keep3rV1, _job, _keeper, _payment, _gasLeft);
  }

  function bondedPayment(address _keeper, uint256 _payment) public override {
    address _job = msg.sender;

    if (disputes[_job]) revert JobDisputed();
    if (!_jobs.contains(_job)) revert JobUnapproved();

    if (_updateJobCreditsIfNeeded(_job)) {
      emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);
    }

    if (_payment > _jobLiquidityCredits[_job]) {
      _rewardJobCredits(_job);
      emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);
    }

    _bondedPayment(_job, _keeper, _payment);
    emit KeeperWork(keep3rV1, _job, _keeper, _payment, _getGasLeft());
  }

  function directTokenPayment(
    address _token,
    address _keeper,
    uint256 _amount
  ) external override {
    address _job = msg.sender;

    if (disputes[_job]) revert JobDisputed();
    if (disputes[_keeper]) revert Disputed();
    if (!_jobs.contains(_job)) revert JobUnapproved();
    if (jobTokenCredits[_job][_token] < _amount) revert InsufficientFunds();
    jobTokenCredits[_job][_token] -= _amount;
    IERC20(_token).safeTransfer(_keeper, _amount);
    emit KeeperWork(_token, _job, _keeper, _amount, _getGasLeft());
  }

  function _bondedPayment(
    address _job,
    address _keeper,
    uint256 _payment
  ) internal {
    if (_payment > _jobLiquidityCredits[_job]) revert InsufficientFunds();

    workedAt[_job] = block.timestamp;
    _jobLiquidityCredits[_job] -= _payment;
    bonds[_keeper][keep3rV1] += _payment;
    workCompleted[_keeper] += _payment;
  }

  function _calculatePayment(
    uint256 _gasLeft,
    uint256 _extraGas,
    uint256 _oneEthQuote,
    uint256 _boost
  ) internal view returns (uint256 _payment) {
    uint256 _accountedGas = _initialGas - _gasLeft + _extraGas;
    _payment = (((_accountedGas * _boost) / _BASE) * _oneEthQuote) / 1 ether;
  }

  function _getGasLeft() internal view returns (uint256 _gasLeft) {
    _gasLeft = (gasleft() * 64) / 63;
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Keep3rJobManager is IKeep3rJobManager, Keep3rJobOwnership, Keep3rRoles, Keep3rParameters {
  using EnumerableSet for EnumerableSet.AddressSet;

  function addJob(address _job) external override {
    if (_jobs.contains(_job)) revert JobAlreadyAdded();
    if (hasBonded[_job]) revert AlreadyAKeeper();
    _jobs.add(_job);
    jobOwner[_job] = msg.sender;
    emit JobAddition(msg.sender, _job);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Keep3rJobs is Keep3rJobDisputable, Keep3rJobManager, Keep3rJobWorkable {}// MIT
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


interface IKeep3rV1Proxy is IGovernable {

  struct Recipient {
    address recipient;
    uint256 caps;
  }

  function keep3rV1() external view returns (address);


  function minter() external view returns (address);


  function next(address) external view returns (uint256);


  function caps(address) external view returns (uint256);


  function recipients() external view returns (address[] memory);


  function recipientsCaps() external view returns (Recipient[] memory);


  error Cooldown();
  error NoDrawableAmount();
  error ZeroAddress();
  error OnlyMinter();

  function addRecipient(address recipient, uint256 amount) external;


  function removeRecipient(address recipient) external;


  function draw() external returns (uint256 _amount);


  function setKeep3rV1(address _keep3rV1) external;


  function setMinter(address _minter) external;


  function mint(uint256 _amount) external;


  function mint(address _account, uint256 _amount) external;


  function setKeep3rV1Governance(address _governance) external;


  function acceptKeep3rV1Governance() external;


  function dispute(address _keeper) external;


  function slash(
    address _bonded,
    address _keeper,
    uint256 _amount
  ) external;


  function revoke(address _keeper) external;


  function resolve(address _keeper) external;


  function addJob(address _job) external;


  function removeJob(address _job) external;


  function addKPRCredit(address _job, uint256 _amount) external;


  function approveLiquidity(address _liquidity) external;


  function revokeLiquidity(address _liquidity) external;


  function setKeep3rHelper(address _keep3rHelper) external;


  function addVotes(address _voter, uint256 _amount) external;


  function removeVotes(address _voter, uint256 _amount) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;




abstract contract Keep3rKeeperFundable is IKeep3rKeeperFundable, ReentrancyGuard, Keep3rParameters {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  function bond(address _bonding, uint256 _amount) external override nonReentrant {
    if (disputes[msg.sender]) revert Disputed();
    if (_jobs.contains(msg.sender)) revert AlreadyAJob();
    canActivateAfter[msg.sender][_bonding] = block.timestamp + bondTime;

    uint256 _before = IERC20(_bonding).balanceOf(address(this));
    IERC20(_bonding).safeTransferFrom(msg.sender, address(this), _amount);
    _amount = IERC20(_bonding).balanceOf(address(this)) - _before;

    hasBonded[msg.sender] = true;
    pendingBonds[msg.sender][_bonding] += _amount;

    emit Bonding(msg.sender, _bonding, _amount);
  }

  function activate(address _bonding) external override {
    if (disputes[msg.sender]) revert Disputed();
    if (canActivateAfter[msg.sender][_bonding] == 0) revert BondsUnexistent();
    if (canActivateAfter[msg.sender][_bonding] >= block.timestamp) revert BondsLocked();

    delete canActivateAfter[msg.sender][_bonding];

    uint256 _amount = _activate(msg.sender, _bonding);
    emit Activation(msg.sender, _bonding, _amount);
  }

  function unbond(address _bonding, uint256 _amount) external override {
    canWithdrawAfter[msg.sender][_bonding] = block.timestamp + unbondTime;
    bonds[msg.sender][_bonding] -= _amount;
    pendingUnbonds[msg.sender][_bonding] += _amount;

    emit Unbonding(msg.sender, _bonding, _amount);
  }

  function withdraw(address _bonding) external override nonReentrant {
    if (pendingUnbonds[msg.sender][_bonding] == 0) revert UnbondsUnexistent();
    if (canWithdrawAfter[msg.sender][_bonding] >= block.timestamp) revert UnbondsLocked();
    if (disputes[msg.sender]) revert Disputed();

    uint256 _amount = pendingUnbonds[msg.sender][_bonding];

    if (_bonding == keep3rV1) {
      IKeep3rV1Proxy(keep3rV1Proxy).mint(_amount);
    }

    delete pendingUnbonds[msg.sender][_bonding];
    delete canWithdrawAfter[msg.sender][_bonding];

    IERC20(_bonding).safeTransfer(msg.sender, _amount);

    emit Withdrawal(msg.sender, _bonding, _amount);
  }

  function _activate(address _keeper, address _bonding) internal returns (uint256 _amount) {
    if (firstSeen[_keeper] == 0) {
      firstSeen[_keeper] = block.timestamp;
    }
    _keepers.add(_keeper);
    _amount = pendingBonds[_keeper][_bonding];
    delete pendingBonds[_keeper][_bonding];

    bonds[_keeper][_bonding] += _amount;
    if (_bonding == keep3rV1) {
      IKeep3rV1(keep3rV1).burn(_amount);
    }
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Keep3rKeeperDisputable is IKeep3rKeeperDisputable, Keep3rDisputable, Keep3rKeeperFundable {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  function slash(
    address _keeper,
    address _bonded,
    uint256 _bondAmount,
    uint256 _unbondAmount
  ) public override onlySlasher {
    if (!disputes[_keeper]) revert NotDisputed();
    _slash(_keeper, _bonded, _bondAmount, _unbondAmount);
    emit KeeperSlash(_keeper, msg.sender, _bondAmount + _unbondAmount);
  }

  function revoke(address _keeper) external override onlySlasher {
    if (!disputes[_keeper]) revert NotDisputed();
    _keepers.remove(_keeper);
    _slash(_keeper, keep3rV1, bonds[_keeper][keep3rV1], pendingUnbonds[_keeper][keep3rV1]);
    emit KeeperRevoke(_keeper, msg.sender);
  }

  function _slash(
    address _keeper,
    address _bonded,
    uint256 _bondAmount,
    uint256 _unbondAmount
  ) internal {
    if (_bonded != keep3rV1) {
      try IERC20(_bonded).transfer(governance, _bondAmount + _unbondAmount) returns (bool) {} catch (bytes memory) {}
    }
    bonds[_keeper][_bonded] -= _bondAmount;
    pendingUnbonds[_keeper][_bonded] -= _unbondAmount;
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Keep3rKeepers is Keep3rKeeperDisputable {}// MIT

pragma solidity >=0.8.4 <0.9.0;


interface IDustCollector is IBaseErrors {

  event DustSent(address _token, uint256 _amount, address _to);

  function sendDust(
    address _token,
    uint256 _amount,
    address _to
  ) external;

}// MIT

pragma solidity >=0.8.4 <0.9.0;


abstract contract DustCollector is IDustCollector, Governable {
  using SafeERC20 for IERC20;

  address internal constant _ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  function sendDust(
    address _token,
    uint256 _amount,
    address _to
  ) external override onlyGovernance {
    if (_to == address(0)) revert ZeroAddress();
    if (_token == _ETH_ADDRESS) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_token, _amount, _to);
  }
}// MIT


pragma solidity >=0.8.4 <0.9.0;


contract Keep3r is DustCollector, Keep3rJobs, Keep3rKeepers {

  constructor(
    address _governance,
    address _keep3rHelper,
    address _keep3rV1,
    address _keep3rV1Proxy,
    address _kp3rWethPool
  ) Keep3rParameters(_keep3rHelper, _keep3rV1, _keep3rV1Proxy, _kp3rWethPool) Keep3rRoles(_governance) DustCollector() {}
}