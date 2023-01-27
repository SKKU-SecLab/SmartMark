pragma solidity 0.8.9;

interface IPool {

  struct Deposit {
    uint256 tokenAmount;
    uint256 weight;
    uint64 lockedFrom;
    uint64 lockedUntil;
    bool isYield;
  }

  function rewardToken() external view returns (address);


  function poolToken() external view returns (address);


  function isFlashPool() external view returns (bool);


  function weight() external view returns (uint32);


  function lastYieldDistribution() external view returns (uint64);


  function yieldRewardsPerWeight() external view returns (uint256);


  function usersLockingWeight() external view returns (uint256);


  function pendingYieldRewards(address _user) external view returns (uint256);


  function balanceOf(address _user) external view returns (uint256);


  function getDeposit(address _user, uint256 _depositId) external view returns (Deposit memory);


  function getDepositsLength(address _user) external view returns (uint256);


  function stake(uint256 _amount, uint64 _lockedUntil) external;


  function unstake(uint256 _depositId, uint256 _amount) external;


  function sync() external;


  function processRewards() external;


  function setWeight(uint32 _weight) external;

}// MIT

pragma solidity 0.8.9;


interface ICorePool is IPool {

  function poolTokenReserve() external view returns (uint256);


  function stakeAsPool(address _staker, uint256 _amount) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;


abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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
pragma solidity ^0.8.9;

abstract contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    address msgSender = msg.sender;
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}// MIT
pragma solidity 0.8.9;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender)
    external
    view
    returns (uint256);


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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT
pragma solidity ^0.8.9;



contract zStakePoolFactory is OwnableUpgradeable, PausableUpgradeable {

  address public rewardToken;

  address public rewardVault;

  struct PoolData {
    address poolToken;
    address poolAddress;
    uint32 weight;
    bool isFlashPool;
  }

  uint256 internal rewardTokensPerBlock;

  uint32 public totalWeight;

  mapping(address => address) public pools;

  mapping(address => bool) public poolExists;

  event PoolRegistered(
    address indexed _by,
    address indexed poolToken,
    address indexed poolAddress,
    uint64 weight,
    bool isFlashPool
  );

  event WeightUpdated(address indexed _by, address indexed poolAddress, uint32 weight);

  event WildRatioUpdated(address indexed _by, uint256 newIlvPerBlock);

  function initialize(
    address _rewardToken,
    address _rewardsVault,
    uint192 _rewardTokensPerBlock
  ) public initializer {

    __Ownable_init();

    require(_rewardTokensPerBlock > 0, "WILD/block not set");

    rewardToken = _rewardToken;
    rewardVault = _rewardsVault;
    rewardTokensPerBlock = _rewardTokensPerBlock;
  }

  function initializeImplementation() public initializer {

    __Ownable_init();
    _pause();
  }

  function getPoolAddress(address poolToken) external view returns (address) {

    return pools[poolToken];
  }

  function getPoolData(address _poolToken) public view returns (PoolData memory) {

    address poolAddr = pools[_poolToken];

    require(poolAddr != address(0), "pool not found");

    address poolToken = IPool(poolAddr).poolToken();
    bool isFlashPool = IPool(poolAddr).isFlashPool();
    uint32 weight = IPool(poolAddr).weight();

    return
      PoolData({
        poolToken: poolToken,
        poolAddress: poolAddr,
        weight: weight,
        isFlashPool: isFlashPool
      });
  }

  function registerPool(address poolAddr) public onlyOwner {

    require(!paused(), "contract is paused");
    address poolToken = IPool(poolAddr).poolToken();
    bool isFlashPool = IPool(poolAddr).isFlashPool();
    uint32 weight = IPool(poolAddr).weight();

    require(pools[poolToken] == address(0), "this pool is already registered");

    pools[poolToken] = poolAddr;
    poolExists[poolAddr] = true;
    totalWeight += weight;

    emit PoolRegistered(msg.sender, poolToken, poolAddr, weight, isFlashPool);
  }

  function transferRewardYield(address _to, uint256 _amount) external {

    require(!paused(), "contract is paused");
    require(poolExists[msg.sender], "access denied");

    IERC20(rewardToken).transferFrom(rewardVault, _to, _amount);
  }

  function changePoolWeight(address poolAddr, uint32 weight) external {

    require(!paused(), "contract is paused");
    require(msg.sender == owner() || poolExists[msg.sender]);

    totalWeight = totalWeight + weight - IPool(poolAddr).weight();

    IPool(poolAddr).setWeight(weight);

    emit WeightUpdated(msg.sender, poolAddr, weight);
  }

  function changeRewardTokensPerBlock(uint256 perBlock) external {

    require(!paused(), "contract is paused");
    require(rewardTokensPerBlock != perBlock, "No change");
    rewardTokensPerBlock = perBlock;
  }

  function blockNumber() public view virtual returns (uint256) {

    return block.number;
  }

  function getRewardTokensPerBlock() public view returns (uint256) {

    return rewardTokensPerBlock;
  }
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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
pragma solidity ^0.8.9;


library SafeERC20 {

  using AddressUpgradeable for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {

    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transfer.selector, to, value)
    );
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {

    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
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
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, value)
    );
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    uint256 newAllowance = token.allowance(address(this), spender) - value;
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {


    bytes memory returndata = address(token).functionCall(
      data,
      "SafeERC20: low-level call failed"
    );
    if (returndata.length > 0) {
      require(
        abi.decode(returndata, (bool)),
        "SafeERC20: ERC20 operation did not succeed"
      );
    }
  }
}// MIT
pragma solidity ^0.8.9;



abstract contract zStakePoolBase is
  IPool,
  ReentrancyGuardUpgradeable,
  OwnableUpgradeable,
  PausableUpgradeable
{
  struct User {
    uint256 tokenAmount;
    uint256 totalWeight;
    uint256 subYieldRewards;
    Deposit[] deposits;
  }

  function isFlashPool() external view virtual override returns (bool) {
    return false;
  }

  address public override rewardToken;

  mapping(address => User) public users;

  zStakePoolFactory public factory;

  address public override poolToken;

  uint32 public override weight;

  uint64 public override lastYieldDistribution;

  uint256 public override yieldRewardsPerWeight;

  uint256 public override usersLockingWeight;

  uint256 public rewardLockPeriod;

  uint256 internal constant WEIGHT_MULTIPLIER = 1e6;

  uint256 internal constant YEAR_STAKE_WEIGHT_MULTIPLIER = 2 * WEIGHT_MULTIPLIER;

  uint256 internal constant REWARD_PER_WEIGHT_MULTIPLIER = 1e12;

  event Staked(address indexed _by, address indexed _from, uint256 amount);

  event StakeLockUpdated(
    address indexed _by,
    uint256 depositId,
    uint64 lockedFrom,
    uint64 lockedUntil
  );

  event Unstaked(address indexed _by, address indexed _to, uint256 amount);

  event Synchronized(
    address indexed _by,
    uint256 yieldRewardsPerWeight,
    uint64 lastYieldDistribution
  );

  event YieldClaimed(address indexed _by, address indexed _to, uint256 amount);

  event PoolWeightUpdated(address indexed _by, uint32 _fromVal, uint32 _toVal);

  function __zStakePoolBase__init(
    address _rewardToken,
    zStakePoolFactory _factory,
    address _poolToken,
    uint64 _initBlock,
    uint32 _weight
  ) public initializer {
    __Ownable_init();

    require(address(_factory) != address(0), "factory address not set");
    require(_poolToken != address(0), "pool token address not set");
    require(_initBlock > 0, "init block not set");
    require(_weight > 0, "pool weight not set");

    factory = _factory;
    poolToken = _poolToken;
    weight = _weight;
    rewardToken = _rewardToken;

    lastYieldDistribution = _initBlock;
    rewardLockPeriod = 365 days;
  }

  function pendingYieldRewards(address _staker) external view override returns (uint256) {
    uint256 newYieldRewardsPerWeight;

    if (blockNumber() > lastYieldDistribution && usersLockingWeight != 0) {
      uint256 multiplier = blockNumber() - lastYieldDistribution;
      uint256 rewards = (multiplier * weight * factory.getRewardTokensPerBlock()) /
        factory.totalWeight();

      newYieldRewardsPerWeight =
        rewardToWeight(rewards, usersLockingWeight) +
        yieldRewardsPerWeight;
    } else {
      newYieldRewardsPerWeight = yieldRewardsPerWeight;
    }

    User memory user = users[_staker];
    uint256 pending = weightToReward(user.totalWeight, newYieldRewardsPerWeight) -
      user.subYieldRewards;

    return pending;
  }

  function balanceOf(address _user) external view override returns (uint256) {
    return users[_user].tokenAmount;
  }

  function getDeposit(address _user, uint256 _depositId)
    external
    view
    override
    returns (Deposit memory)
  {
    return users[_user].deposits[_depositId];
  }

  function getDepositsLength(address _user) external view override returns (uint256) {
    return users[_user].deposits.length;
  }

  function stake(uint256 _amount, uint64 _lockUntil) external override {
    require(!paused(), "contract is paused");
    _stake(msg.sender, _amount, _lockUntil, false);
  }

  function unstake(uint256 _depositId, uint256 _amount) external override {
    require(!paused(), "contract is paused");
    _unstake(msg.sender, _depositId, _amount);
  }

  function updateStakeLock(uint256 depositId, uint64 lockedUntil) external {
    require(!paused(), "contract is paused");
    _sync();
    _processRewards(msg.sender, false);

    _updateStakeLock(msg.sender, depositId, lockedUntil);

    User storage user = users[msg.sender];
    user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);
  }

  function sync() external override {
    require(!paused(), "contract is paused");
    _sync();
  }

  function processRewards() external virtual override {
    require(!paused(), "contract is paused");
    _processRewards(msg.sender, true);
  }

  function setWeight(uint32 _weight) external override {
    require(!paused(), "contract is paused");
    require(msg.sender == address(factory), "access denied");

    emit PoolWeightUpdated(msg.sender, weight, _weight);

    weight = _weight;
  }

  function _pendingYieldRewards(address _staker) internal view returns (uint256 pending) {
    User memory user = users[_staker];

    return weightToReward(user.totalWeight, yieldRewardsPerWeight) - user.subYieldRewards;
  }

  function _stake(
    address _staker,
    uint256 _amount,
    uint64 _lockUntil,
    bool _isYield
  ) internal virtual {
    require(_amount > 0, "zero amount");
    require(
      _lockUntil == 0 || (_lockUntil > now256() && _lockUntil - now256() <= 365 days),
      "invalid lock interval"
    );

    _sync();

    User storage user = users[_staker];
    if (user.tokenAmount > 0) {
      _processRewards(_staker, false);
    }


    uint256 previousBalance = IERC20(poolToken).balanceOf(address(this));
    transferPoolTokenFrom(address(msg.sender), address(this), _amount);
    uint256 newBalance = IERC20(poolToken).balanceOf(address(this));
    uint256 addedAmount = newBalance - previousBalance;

    uint64 lockFrom = _lockUntil > 0 ? uint64(now256()) : 0;
    uint64 lockUntil = _lockUntil;

    uint256 stakeWeight = (((lockUntil - lockFrom) * WEIGHT_MULTIPLIER) /
      365 days +
      WEIGHT_MULTIPLIER) * addedAmount;

    assert(stakeWeight > 0);

    Deposit memory deposit = Deposit({
      tokenAmount: addedAmount,
      weight: stakeWeight,
      lockedFrom: lockFrom,
      lockedUntil: lockUntil,
      isYield: _isYield
    });
    user.deposits.push(deposit);

    user.tokenAmount += addedAmount;
    user.totalWeight += stakeWeight;
    user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

    usersLockingWeight += stakeWeight;

    emit Staked(msg.sender, _staker, _amount);
  }

  function changeRewardLockPeriod(uint256 _rewardLockPeriod) external onlyOwner {
    require(rewardLockPeriod != _rewardLockPeriod, "same rewardLockPeriod");
    require(_rewardLockPeriod <= 365 days, "too long lock period");
    rewardLockPeriod = _rewardLockPeriod;
  }

  function _unstake(
    address _staker,
    uint256 _depositId,
    uint256 _amount
  ) internal virtual {
    require(_amount > 0, "zero amount");

    User storage user = users[_staker];
    Deposit storage stakeDeposit = user.deposits[_depositId];
    bool isYield = stakeDeposit.isYield;

    require(stakeDeposit.tokenAmount >= _amount, "amount exceeds stake");

    _sync();
    _processRewards(_staker, false);

    uint256 previousWeight = stakeDeposit.weight;
    uint256 newWeight = (((stakeDeposit.lockedUntil - stakeDeposit.lockedFrom) *
      WEIGHT_MULTIPLIER) /
      365 days +
      WEIGHT_MULTIPLIER) * (stakeDeposit.tokenAmount - _amount);

    if (stakeDeposit.tokenAmount - _amount == 0) {
      delete user.deposits[_depositId];
    } else {
      stakeDeposit.tokenAmount -= _amount;
      stakeDeposit.weight = newWeight;
    }

    user.tokenAmount -= _amount;
    user.totalWeight = user.totalWeight - previousWeight + newWeight;
    user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

    usersLockingWeight = usersLockingWeight - previousWeight + newWeight;

    if (isYield) {

      factory.transferRewardYield(msg.sender, _amount);
    } else {
      transferPoolToken(msg.sender, _amount);
    }

    emit Unstaked(msg.sender, _staker, _amount);
  }

  function _sync() internal virtual {
    if (blockNumber() <= lastYieldDistribution) {
      return;
    }
    if (usersLockingWeight == 0) {
      lastYieldDistribution = uint64(blockNumber());
      return;
    }

    uint256 currentBlock = blockNumber();
    uint256 blocksPassed = currentBlock - lastYieldDistribution;
    uint256 rewardPerBlock = factory.getRewardTokensPerBlock();

    uint256 rewardAmount = (blocksPassed * rewardPerBlock * weight) / factory.totalWeight();

    yieldRewardsPerWeight += rewardToWeight(rewardAmount, usersLockingWeight);
    lastYieldDistribution = uint64(currentBlock);

    emit Synchronized(msg.sender, yieldRewardsPerWeight, lastYieldDistribution);
  }

  function _processRewards(address _staker, bool _withUpdate)
    internal
    virtual
    returns (uint256 pendingYield)
  {
    if (_withUpdate) {
      _sync();
    }

    pendingYield = _pendingYieldRewards(_staker);

    if (pendingYield == 0) return 0;

    User storage user = users[_staker];

    if (poolToken == rewardToken) {
      uint256 depositWeight = pendingYield * YEAR_STAKE_WEIGHT_MULTIPLIER;

      Deposit memory newDeposit = Deposit({
        tokenAmount: pendingYield,
        lockedFrom: uint64(now256()),
        lockedUntil: uint64(now256() + rewardLockPeriod), // staking yield for 1 year
        weight: depositWeight,
        isYield: true
      });
      user.deposits.push(newDeposit);

      user.tokenAmount += pendingYield;
      user.totalWeight += depositWeight;

      usersLockingWeight += depositWeight;
    } else {
      address rewardPool = factory.getPoolAddress(rewardToken);
      ICorePool(rewardPool).stakeAsPool(_staker, pendingYield);
    }

    if (_withUpdate) {
      user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);
    }

    emit YieldClaimed(msg.sender, _staker, pendingYield);
  }

  function _updateStakeLock(
    address _staker,
    uint256 _depositId,
    uint64 _lockedUntil
  ) internal {
    require(_lockedUntil > now256(), "lock should be in the future");

    User storage user = users[_staker];
    Deposit storage stakeDeposit = user.deposits[_depositId];

    require(_lockedUntil > stakeDeposit.lockedUntil, "invalid new lock");

    if (stakeDeposit.lockedFrom == 0) {
      require(_lockedUntil - now256() <= 365 days, "max lock period is 365 days");
      stakeDeposit.lockedFrom = uint64(now256());
    } else {
      require(_lockedUntil - stakeDeposit.lockedFrom <= 365 days, "max lock period is 365 days");
    }

    stakeDeposit.lockedUntil = _lockedUntil;
    uint256 newWeight = (((stakeDeposit.lockedUntil - stakeDeposit.lockedFrom) *
      WEIGHT_MULTIPLIER) /
      365 days +
      WEIGHT_MULTIPLIER) * stakeDeposit.tokenAmount;

    uint256 previousWeight = stakeDeposit.weight;
    stakeDeposit.weight = newWeight;

    user.totalWeight = user.totalWeight - previousWeight + newWeight;
    usersLockingWeight = usersLockingWeight - previousWeight + newWeight;

    emit StakeLockUpdated(_staker, _depositId, stakeDeposit.lockedFrom, _lockedUntil);
  }

  function weightToReward(uint256 _weight, uint256 rewardPerWeight) public pure returns (uint256) {
    return (_weight * rewardPerWeight) / REWARD_PER_WEIGHT_MULTIPLIER;
  }

  function rewardToWeight(uint256 reward, uint256 rewardPerWeight) public pure returns (uint256) {
    return (reward * REWARD_PER_WEIGHT_MULTIPLIER) / rewardPerWeight;
  }

  function blockNumber() public view virtual returns (uint256) {
    return block.number;
  }

  function now256() public view virtual returns (uint256) {
    return block.timestamp;
  }

  function setPauseStatus(bool toPause) public onlyOwner {
    if (toPause) {
      require(!paused(), "Pausable: paused");
      _pause();
    } else {
      require(paused(), "Pausable: not paused");
      _unpause();
    }
  }

  function transferPoolToken(address _to, uint256 _value) internal nonReentrant {
    SafeERC20.safeTransfer(IERC20(poolToken), _to, _value);
  }

  function transferPoolTokenFrom(
    address _from,
    address _to,
    uint256 _value
  ) internal nonReentrant {
    SafeERC20.safeTransferFrom(IERC20(poolToken), _from, _to, _value);
  }
}// MIT

pragma solidity ^0.8.9;


contract zStakeCorePool is zStakePoolBase {

  bool public constant override isFlashPool = false;

  uint256 public poolTokenReserve;

  function initialize(
    address _rewardToken,
    zStakePoolFactory _factory,
    address _poolToken,
    uint64 _initBlock,
    uint32 _weight
  ) initializer public {

    __zStakePoolBase__init(_rewardToken, _factory, _poolToken, _initBlock, _weight);
  }

  function initializeImplementation() public initializer {

    __Ownable_init();
    _pause();
  }

  function processRewards() external override {

    require(!paused(), "contract is paused");
    _processRewards(msg.sender, true);
  }

  function stakeAsPool(address _staker, uint256 _amount) external {

    require(!paused(), "contract is paused");
    require(factory.poolExists(msg.sender), "access denied");
    _sync();
    User storage user = users[_staker];
    if (user.tokenAmount > 0) {
      _processRewards(_staker, false);
    }
    uint256 depositWeight = _amount * YEAR_STAKE_WEIGHT_MULTIPLIER;
    Deposit memory newDeposit = Deposit({
      tokenAmount: _amount,
      lockedFrom: uint64(now256()),
      lockedUntil: uint64(now256() + rewardLockPeriod),
      weight: depositWeight,
      isYield: true
    });
    user.tokenAmount += _amount;
    user.totalWeight += depositWeight;
    user.deposits.push(newDeposit);

    usersLockingWeight += depositWeight;

    user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

    poolTokenReserve += _amount;
  }

  function _stake(
    address _staker,
    uint256 _amount,
    uint64 _lockedUntil,
    bool _isYield
  ) internal override {

    super._stake(_staker, _amount, _lockedUntil, _isYield);

    poolTokenReserve += _amount;
  }

  function _unstake(
    address _staker,
    uint256 _depositId,
    uint256 _amount
  ) internal override {

    User storage user = users[_staker];
    Deposit memory stakeDeposit = user.deposits[_depositId];
    require(
      stakeDeposit.lockedFrom == 0 || now256() > stakeDeposit.lockedUntil,
      "deposit not yet unlocked"
    );
    poolTokenReserve -= _amount;
    super._unstake(_staker, _depositId, _amount);
  }

  function _processRewards(address _staker, bool _withUpdate)
    internal
    override
    returns (uint256 pendingYield)
  {

    pendingYield = super._processRewards(_staker, _withUpdate);

    if (poolToken == rewardToken) {
      poolTokenReserve += pendingYield;
    }
  }
}