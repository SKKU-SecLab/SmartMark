pragma solidity ^0.8.4;

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

}// agpl-3.0
pragma solidity ^0.8.4;

abstract contract VersionedInitializable {
  uint256 private constant BLOCK_REVISION = type(uint256).max;
  uint256 private constant IMPL_REVISION = BLOCK_REVISION - 1;

  uint256 private lastInitializedRevision = IMPL_REVISION;

  uint256 private lastInitializingRevision = 0;

  function _unsafeResetVersionedInitializers() internal {
    require(isConstructor(), 'only for constructor');

    if (lastInitializedRevision == IMPL_REVISION) {
      lastInitializedRevision = 0;
    } else {
      require(lastInitializedRevision == 0, 'can only be called before initializer(s)');
    }
  }

  modifier initializer(uint256 localRevision) {
    (uint256 topRevision, bool initializing, bool skip) = _preInitializer(localRevision);

    if (!skip) {
      lastInitializingRevision = localRevision;
      _;
      lastInitializedRevision = localRevision;
    }

    if (!initializing) {
      lastInitializedRevision = topRevision;
      lastInitializingRevision = 0;
    }
  }

  modifier initializerRunAlways(uint256 localRevision) {
    (uint256 topRevision, bool initializing, bool skip) = _preInitializer(localRevision);

    if (!skip) {
      lastInitializingRevision = localRevision;
    }
    _;
    if (!skip) {
      lastInitializedRevision = localRevision;
    }

    if (!initializing) {
      lastInitializedRevision = topRevision;
      lastInitializingRevision = 0;
    }
  }

  function _preInitializer(uint256 localRevision)
    private
    returns (
      uint256 topRevision,
      bool initializing,
      bool skip
    )
  {
    topRevision = getRevision();
    require(topRevision < IMPL_REVISION, 'invalid contract revision');

    require(localRevision > 0, 'incorrect initializer revision');
    require(localRevision <= topRevision, 'inconsistent contract revision');

    if (lastInitializedRevision < IMPL_REVISION) {
      initializing = lastInitializingRevision > 0 && lastInitializedRevision < topRevision;
      require(initializing || isConstructor() || topRevision > lastInitializedRevision, 'already initialized');
    } else {
      require(lastInitializedRevision == IMPL_REVISION && isConstructor(), 'initializer blocked');

      lastInitializedRevision = 0;
      topRevision = BLOCK_REVISION;

      initializing = lastInitializingRevision > 0;
    }

    if (initializing) {
      require(lastInitializingRevision > localRevision, 'incorrect order of initializers');
    }

    if (localRevision <= lastInitializedRevision) {
      if (initializing) {
        lastInitializingRevision = 1;
      }
      return (topRevision, initializing, true);
    }
    return (topRevision, initializing, false);
  }

  function isRevisionInitialized(uint256 localRevision) internal view returns (bool) {
    return lastInitializedRevision >= localRevision;
  }

  function REVISION() public pure returns (uint256) {
    return getRevision();
  }

  function getRevision() internal pure virtual returns (uint256);

  function isConstructor() private view returns (bool) {
    uint256 cs;
    assembly {
      cs := extcodesize(address())
    }
    return cs == 0;
  }

  uint256[4] private ______gap;
}// agpl-3.0
pragma solidity ^0.8.4;

interface IRemoteAccessBitmask {

  function queryAccessControlMask(address addr, uint256 filterMask) external view returns (uint256);

}// agpl-3.0
pragma solidity ^0.8.4;

interface IProxy {

  function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;

}// agpl-3.0
pragma solidity ^0.8.4;


interface IAccessController is IRemoteAccessBitmask {

  function getAddress(uint256 id) external view returns (address);


  function createProxy(
    address admin,
    address impl,
    bytes calldata params
  ) external returns (IProxy);

}// agpl-3.0
pragma solidity ^0.8.4;


interface IMarketAccessController is IAccessController {

  function getMarketId() external view returns (string memory);


  function getLendingPool() external view returns (address);


  function getPriceOracle() external view returns (address);


  function getLendingRateOracle() external view returns (address);

}// agpl-3.0
pragma solidity ^0.8.4;

interface IDerivedToken {

  function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// agpl-3.0
pragma solidity ^0.8.4;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);


  function getScaleIndex() external view returns (uint256);

}// agpl-3.0
pragma solidity ^0.8.4;


interface IPoolToken is IDerivedToken {

  function POOL() external view returns (address);


  function updatePool() external;

}// agpl-3.0
pragma solidity ^0.8.4;


interface IDepositToken is IERC20, IPoolToken, IScaledBalanceToken {

  event Mint(address indexed account, uint256 value, uint256 index);

  function mint(
    address user,
    uint256 amount,
    uint256 index,
    bool repayOverdraft
  ) external returns (bool);


  event Burn(address indexed account, address indexed target, uint256 value, uint256 index);

  event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);

  function burn(
    address user,
    address receiverOfUnderlying,
    uint256 amount,
    uint256 index
  ) external;


  function mintToTreasury(uint256 amount, uint256 index) external;


  function transferOnLiquidation(
    address from,
    address to,
    uint256 value,
    uint256 index,
    bool transferUnderlying
  ) external returns (bool);


  function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);


  function collateralBalanceOf(address) external view returns (uint256);


  event OverdraftApplied(address indexed account, uint256 value, uint256 index);

  event OverdraftCovered(address indexed provider, address indexed recipient, uint256 overdraft, uint256 index);

  event SubBalanceProvided(address indexed provider, address indexed recipient, uint256 amount, uint256 index);
  event SubBalanceReturned(address indexed provider, address indexed recipient, uint256 amount, uint256 index);
  event SubBalanceLocked(address indexed provider, uint256 amount, uint256 index);
  event SubBalanceUnlocked(address indexed provider, uint256 amount, uint256 index);

  function updateTreasury() external;


  function addSubBalanceOperator(address addr) external;


  function addStakeOperator(address addr) external;


  function removeSubBalanceOperator(address addr) external;


  function provideSubBalance(
    address provider,
    address recipient,
    uint256 scaledAmount
  ) external;


  function returnSubBalance(
    address provider,
    address recipient,
    uint256 scaledAmount,
    bool preferOverdraft
  ) external returns (uint256 coveredOverdraft);


  function lockSubBalance(address provider, uint256 scaledAmount) external;


  function unlockSubBalance(
    address provider,
    uint256 scaledAmount,
    address transferTo
  ) external;


  function replaceSubBalance(
    address prevProvider,
    address recipient,
    uint256 prevScaledAmount,
    address newProvider,
    uint256 newScaledAmount
  ) external returns (uint256 coveredOverdraftByPrevProvider);


  function transferLockedBalance(
    address from,
    address to,
    uint256 scaledAmount
  ) external;

}// agpl-3.0
pragma solidity ^0.8.4;

library Errors {

  string public constant VL_INVALID_AMOUNT = '1'; // Amount must be greater than 0
  string public constant VL_NO_ACTIVE_RESERVE = '2'; // Action requires an active reserve
  string public constant VL_RESERVE_FROZEN = '3'; // Action cannot be performed because the reserve is frozen
  string public constant VL_UNKNOWN_RESERVE = '4'; // Action requires an active reserve
  string public constant VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE = '5'; // User cannot withdraw more than the available balance (above min limit)
  string public constant VL_TRANSFER_NOT_ALLOWED = '6'; // Transfer cannot be allowed.
  string public constant VL_BORROWING_NOT_ENABLED = '7'; // Borrowing is not enabled
  string public constant VL_INVALID_INTEREST_RATE_MODE_SELECTED = '8'; // Invalid interest rate mode selected
  string public constant VL_COLLATERAL_BALANCE_IS_0 = '9'; // The collateral balance is 0
  string public constant VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD = '10'; // Health factor is lesser than the liquidation threshold
  string public constant VL_COLLATERAL_CANNOT_COVER_NEW_BORROW = '11'; // There is not enough collateral to cover a new borrow
  string public constant VL_STABLE_BORROWING_NOT_ENABLED = '12'; // stable borrowing not enabled
  string public constant VL_COLLATERAL_SAME_AS_BORROWING_CURRENCY = '13'; // collateral is (mostly) the same currency that is being borrowed
  string public constant VL_AMOUNT_BIGGER_THAN_MAX_LOAN_SIZE_STABLE = '14'; // The requested amount is exceeds max size of a stable loan
  string public constant VL_NO_DEBT_OF_SELECTED_TYPE = '15'; // to repay a debt, user needs to specify a correct debt type (variable or stable)
  string public constant VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF = '16'; // To repay on behalf of an user an explicit amount to repay is needed
  string public constant VL_NO_STABLE_RATE_LOAN_IN_RESERVE = '17'; // User does not have a stable rate loan in progress on this reserve
  string public constant VL_NO_VARIABLE_RATE_LOAN_IN_RESERVE = '18'; // User does not have a variable rate loan in progress on this reserve
  string public constant VL_UNDERLYING_BALANCE_NOT_GREATER_THAN_0 = '19'; // The collateral balance needs to be greater than 0
  string public constant VL_DEPOSIT_ALREADY_IN_USE = '20'; // User deposit is already being used as collateral
  string public constant VL_RESERVE_MUST_BE_COLLATERAL = '21'; // This reserve must be enabled as collateral
  string public constant LP_INTEREST_RATE_REBALANCE_CONDITIONS_NOT_MET = '22'; // Interest rate rebalance conditions were not met
  string public constant AT_OVERDRAFT_DISABLED = '23'; // User doesn't accept allocation of overdraft
  string public constant VL_INVALID_SUB_BALANCE_ARGS = '24';
  string public constant AT_INVALID_SLASH_DESTINATION = '25';

  string public constant LP_CALLER_NOT_LENDING_POOL_CONFIGURATOR = '27'; // The caller of the function is not the lending pool configurator

  string public constant LENDING_POOL_REQUIRED = '28'; // The caller of this function must be a lending pool
  string public constant CALLER_NOT_LENDING_POOL = '29'; // The caller of this function must be a lending pool
  string public constant AT_SUB_BALANCE_RESTIRCTED_FUNCTION = '30'; // The caller of this function must be a lending pool or a sub-balance operator

  string public constant RL_RESERVE_ALREADY_INITIALIZED = '32'; // Reserve has already been initialized
  string public constant CALLER_NOT_POOL_ADMIN = '33'; // The caller must be the pool admin
  string public constant LPC_RESERVE_LIQUIDITY_NOT_0 = '34'; // The liquidity of the reserve needs to be 0

  string public constant LPAPR_PROVIDER_NOT_REGISTERED = '41'; // Provider is not registered
  string public constant LPCM_HEALTH_FACTOR_NOT_BELOW_THRESHOLD = '42'; // Health factor is not below the threshold
  string public constant LPCM_COLLATERAL_CANNOT_BE_LIQUIDATED = '43'; // The collateral chosen cannot be liquidated
  string public constant LPCM_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER = '44'; // User did not borrow the specified currency
  string public constant LPCM_NOT_ENOUGH_LIQUIDITY_TO_LIQUIDATE = '45'; // There isn't enough liquidity available to liquidate

  string public constant MATH_MULTIPLICATION_OVERFLOW = '48';
  string public constant MATH_ADDITION_OVERFLOW = '49';
  string public constant MATH_DIVISION_BY_ZERO = '50';
  string public constant RL_LIQUIDITY_INDEX_OVERFLOW = '51'; //  Liquidity index overflows uint128
  string public constant RL_VARIABLE_BORROW_INDEX_OVERFLOW = '52'; //  Variable borrow index overflows uint128
  string public constant RL_LIQUIDITY_RATE_OVERFLOW = '53'; //  Liquidity rate overflows uint128
  string public constant RL_VARIABLE_BORROW_RATE_OVERFLOW = '54'; //  Variable borrow rate overflows uint128
  string public constant RL_STABLE_BORROW_RATE_OVERFLOW = '55'; //  Stable borrow rate overflows uint128
  string public constant CT_INVALID_MINT_AMOUNT = '56'; //invalid amount to mint
  string public constant CALLER_NOT_STAKE_ADMIN = '57';
  string public constant CT_INVALID_BURN_AMOUNT = '58'; //invalid amount to burn
  string public constant BORROW_ALLOWANCE_NOT_ENOUGH = '59'; // User borrows on behalf, but allowance are too small
  string public constant CALLER_NOT_LIQUIDITY_CONTROLLER = '60';
  string public constant CALLER_NOT_REF_ADMIN = '61';
  string public constant VL_INSUFFICIENT_REWARD_AVAILABLE = '62';
  string public constant LP_CALLER_MUST_BE_DEPOSIT_TOKEN = '63';
  string public constant LP_IS_PAUSED = '64'; // Pool is paused
  string public constant LP_NO_MORE_RESERVES_ALLOWED = '65';
  string public constant LP_INVALID_FLASH_LOAN_EXECUTOR_RETURN = '66';
  string public constant RC_INVALID_LTV = '67';
  string public constant RC_INVALID_LIQ_THRESHOLD = '68';
  string public constant RC_INVALID_LIQ_BONUS = '69';
  string public constant RC_INVALID_DECIMALS = '70';
  string public constant RC_INVALID_RESERVE_FACTOR = '71';
  string public constant LPAPR_INVALID_ADDRESSES_PROVIDER_ID = '72';
  string public constant VL_INCONSISTENT_FLASHLOAN_PARAMS = '73';
  string public constant VL_TREASURY_REQUIRED = '74';
  string public constant LPC_INVALID_CONFIGURATION = '75'; // Invalid risk parameters for the reserve
  string public constant CALLER_NOT_EMERGENCY_ADMIN = '76'; // The caller must be the emergency admin
  string public constant UL_INVALID_INDEX = '77';
  string public constant VL_CONTRACT_REQUIRED = '78';
  string public constant SDT_STABLE_DEBT_OVERFLOW = '79';
  string public constant SDT_BURN_EXCEEDS_BALANCE = '80';
  string public constant CALLER_NOT_REWARD_CONFIG_ADMIN = '81'; // The caller of this function must be a reward admin
  string public constant LP_INVALID_PERCENTAGE = '82'; // Percentage can't be more than 100%
  string public constant LP_IS_NOT_TRUSTED_FLASHLOAN = '83';
  string public constant CALLER_NOT_SWEEP_ADMIN = '84';
  string public constant LP_TOO_MANY_NESTED_CALLS = '85';
  string public constant LP_RESTRICTED_FEATURE = '86';
  string public constant LP_TOO_MANY_FLASHLOAN_CALLS = '87';
  string public constant RW_BASELINE_EXCEEDED = '88';
  string public constant CALLER_NOT_REWARD_RATE_ADMIN = '89';
  string public constant CALLER_NOT_REWARD_CONTROLLER = '90';
  string public constant RW_REWARD_PAUSED = '91';
  string public constant CALLER_NOT_TEAM_MANAGER = '92';
  string public constant STK_REDEEM_PAUSED = '93';
  string public constant STK_INSUFFICIENT_COOLDOWN = '94';
  string public constant STK_UNSTAKE_WINDOW_FINISHED = '95';
  string public constant STK_INVALID_BALANCE_ON_COOLDOWN = '96';
  string public constant STK_EXCESSIVE_SLASH_PCT = '97';
  string public constant STK_WRONG_COOLDOWN_OR_UNSTAKE = '98';
  string public constant STK_PAUSED = '99';

  string public constant TXT_OWNABLE_CALLER_NOT_OWNER = 'Ownable: caller is not the owner';
  string public constant TXT_CALLER_NOT_PROXY_OWNER = 'ProxyOwner: caller is not the owner';
  string public constant TXT_ACCESS_RESTRICTED = 'RESTRICTED';
}// agpl-3.0
pragma solidity ^0.8.4;


library AccessHelper {

  function getAcl(IRemoteAccessBitmask remote, address subject) internal view returns (uint256) {

    return remote.queryAccessControlMask(subject, ~uint256(0));
  }

  function queryAcl(
    IRemoteAccessBitmask remote,
    address subject,
    uint256 filterMask
  ) internal view returns (uint256) {

    return remote.queryAccessControlMask(subject, filterMask);
  }

  function hasAnyOf(
    IRemoteAccessBitmask remote,
    address subject,
    uint256 flags
  ) internal view returns (bool) {

    uint256 found = queryAcl(remote, subject, flags);
    return found & flags != 0;
  }

  function hasAny(IRemoteAccessBitmask remote, address subject) internal view returns (bool) {

    return remote.queryAccessControlMask(subject, 0) != 0;
  }

  function hasNone(IRemoteAccessBitmask remote, address subject) internal view returns (bool) {

    return remote.queryAccessControlMask(subject, 0) == 0;
  }

  function requireAnyOf(
    IRemoteAccessBitmask remote,
    address subject,
    uint256 flags,
    string memory text
  ) internal view {

    require(hasAnyOf(remote, subject, flags), text);
  }
}// agpl-3.0
pragma solidity ^0.8.4;

library AccessFlags {

  uint256 public constant EMERGENCY_ADMIN = 1 << 0;
  uint256 public constant POOL_ADMIN = 1 << 1;
  uint256 public constant TREASURY_ADMIN = 1 << 2;
  uint256 public constant REWARD_CONFIG_ADMIN = 1 << 3;
  uint256 public constant REWARD_RATE_ADMIN = 1 << 4;
  uint256 public constant STAKE_ADMIN = 1 << 5;
  uint256 public constant REFERRAL_ADMIN = 1 << 6;
  uint256 public constant LENDING_RATE_ADMIN = 1 << 7;
  uint256 public constant SWEEP_ADMIN = 1 << 8;
  uint256 public constant ORACLE_ADMIN = 1 << 9;

  uint256 public constant ROLES = (uint256(1) << 16) - 1;

  uint256 public constant SINGLETONS = ((uint256(1) << 64) - 1) & ~ROLES;

  uint256 public constant LENDING_POOL = 1 << 16;
  uint256 public constant LENDING_POOL_CONFIGURATOR = 1 << 17;
  uint256 public constant LIQUIDITY_CONTROLLER = 1 << 18;
  uint256 public constant TREASURY = 1 << 19;
  uint256 public constant REWARD_TOKEN = 1 << 20;
  uint256 public constant REWARD_STAKE_TOKEN = 1 << 21;
  uint256 public constant REWARD_CONTROLLER = 1 << 22;
  uint256 public constant REWARD_CONFIGURATOR = 1 << 23;
  uint256 public constant STAKE_CONFIGURATOR = 1 << 24;
  uint256 public constant REFERRAL_REGISTRY = 1 << 25;

  uint256 public constant PROXIES = ((uint256(1) << 26) - 1) & ~ROLES;

  uint256 public constant WETH_GATEWAY = 1 << 27;
  uint256 public constant DATA_HELPER = 1 << 28;
  uint256 public constant PRICE_ORACLE = 1 << 29;
  uint256 public constant LENDING_RATE_ORACLE = 1 << 30;


  uint256 public constant TRUSTED_FLASHLOAN = 1 << 66;
}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract MarketAccessBitmaskMin {
  using AccessHelper for IMarketAccessController;
  IMarketAccessController internal _remoteAcl;

  constructor(IMarketAccessController remoteAcl) {
    _remoteAcl = remoteAcl;
  }

  function _getRemoteAcl(address addr) internal view returns (uint256) {
    return _remoteAcl.getAcl(addr);
  }

  function hasRemoteAcl() internal view returns (bool) {
    return _remoteAcl != IMarketAccessController(address(0));
  }

  function acl_hasAnyOf(address subject, uint256 flags) internal view returns (bool) {
    return _remoteAcl.hasAnyOf(subject, flags);
  }

  modifier aclHas(uint256 flags) virtual {
    _remoteAcl.requireAnyOf(msg.sender, flags, Errors.TXT_ACCESS_RESTRICTED);
    _;
  }

  modifier aclAnyOf(uint256 flags) {
    _remoteAcl.requireAnyOf(msg.sender, flags, Errors.TXT_ACCESS_RESTRICTED);
    _;
  }

  modifier onlyPoolAdmin() {
    _remoteAcl.requireAnyOf(msg.sender, AccessFlags.POOL_ADMIN, Errors.CALLER_NOT_POOL_ADMIN);
    _;
  }

  modifier onlyRewardAdmin() {
    _remoteAcl.requireAnyOf(msg.sender, AccessFlags.REWARD_CONFIG_ADMIN, Errors.CALLER_NOT_REWARD_CONFIG_ADMIN);
    _;
  }

  modifier onlyRewardConfiguratorOrAdmin() {
    _remoteAcl.requireAnyOf(
      msg.sender,
      AccessFlags.REWARD_CONFIG_ADMIN | AccessFlags.REWARD_CONFIGURATOR,
      Errors.CALLER_NOT_REWARD_CONFIG_ADMIN
    );
    _;
  }
}

abstract contract MarketAccessBitmask is MarketAccessBitmaskMin {
  using AccessHelper for IMarketAccessController;

  constructor(IMarketAccessController remoteAcl) MarketAccessBitmaskMin(remoteAcl) {}

  modifier onlyEmergencyAdmin() {
    _remoteAcl.requireAnyOf(msg.sender, AccessFlags.EMERGENCY_ADMIN, Errors.CALLER_NOT_EMERGENCY_ADMIN);
    _;
  }

  function _onlySweepAdmin() internal view virtual {
    _remoteAcl.requireAnyOf(msg.sender, AccessFlags.SWEEP_ADMIN, Errors.CALLER_NOT_SWEEP_ADMIN);
  }

  modifier onlySweepAdmin() {
    _onlySweepAdmin();
    _;
  }
}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract ProxyAdminBase {
  function _getProxyImplementation(IProxy proxy) internal view returns (address) {
    (bool success, bytes memory returndata) = address(proxy).staticcall(hex'5c60da1b');
    require(success);
    return abi.decode(returndata, (address));
  }
}// agpl-3.0
pragma solidity ^0.8.4;


contract ProxyAdmin is ProxyAdminBase {

  address private immutable _owner;

  constructor() {
    _owner = msg.sender;
  }

  function owner() public view returns (address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(_owner == msg.sender, Errors.TXT_CALLER_NOT_PROXY_OWNER);
    _;
  }

  function getProxyImplementation(IProxy proxy) public view virtual returns (address) {

    return _getProxyImplementation(proxy);
  }

  function upgradeAndCall(
    IProxy proxy,
    address implementation,
    bytes memory data
  ) public payable virtual onlyOwner {

    proxy.upgradeToAndCall{value: msg.value}(implementation, data);
  }
}// agpl-3.0
pragma solidity ^0.8.4;

interface IUnderlyingStrategy {

  function getUnderlying(address asset) external view returns (address);


  function delegatedWithdrawUnderlying(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);

}// agpl-3.0
pragma solidity ^0.8.4;


struct StakeTokenConfig {
  IMarketAccessController stakeController;
  IERC20 stakedToken;
  IUnderlyingStrategy strategy;
  uint32 cooldownPeriod;
  uint32 unstakePeriod;
  uint16 maxSlashable;
  uint8 stakedTokenDecimals;
}// agpl-3.0
pragma solidity ^0.8.4;


interface IStakeConfigurator {

  struct InitStakeTokenData {
    address stakeTokenImpl;
    address stakedToken;
    address strategy;
    string stkTokenName;
    string stkTokenSymbol;
    uint32 cooldownPeriod;
    uint32 unstakePeriod;
    uint16 maxSlashable;
    uint8 stkTokenDecimals;
    bool depositStake;
  }

  struct UpdateStakeTokenData {
    address token;
    address stakeTokenImpl;
    string stkTokenName;
    string stkTokenSymbol;
  }

  struct StakeTokenData {
    address token;
    string stkTokenName;
    string stkTokenSymbol;
    StakeTokenConfig config;
  }

  event StakeTokenInitialized(address indexed token, InitStakeTokenData data);

  event StakeTokenUpgraded(address indexed token, UpdateStakeTokenData data);

  event StakeTokenAdded(address indexed token, address indexed underlying);

  event StakeTokenRemoved(address indexed token, address indexed underlying);

  function list() external view returns (address[] memory tokens);


  function listAll() external view returns (address[] memory tokens, uint256 genCount);


  function dataOf(address stakeToken) external view returns (StakeTokenData memory data);


  function stakeTokenOf(address underlying) external view returns (address);


  function setCooldownForAll(uint32 cooldownPeriod, uint32 unstakePeriod) external;

}// agpl-3.0
pragma solidity ^0.8.4;


interface IInitializableStakeToken {

  event Initialized(StakeTokenConfig params, string tokenName, string tokenSymbol);

  function initializeStakeToken(
    StakeTokenConfig calldata params,
    string calldata name,
    string calldata symbol
  ) external;


  function initializedStakeTokenWith()
    external
    view
    returns (
      StakeTokenConfig memory params,
      string memory name,
      string memory symbol
    );

}// agpl-3.0
pragma solidity ^0.8.4;

interface IEmergencyAccess {

  function setPaused(bool paused) external;


  function isPaused() external view returns (bool);


  event EmergencyPaused(address indexed by, bool paused);
}// agpl-3.0
pragma solidity ^0.8.4;


interface IManagedStakeToken is IEmergencyAccess {

  event Slashed(address to, uint256 amount, uint256 totalBeforeSlash);

  event MaxSlashUpdated(uint16 maxSlash);
  event CooldownUpdated(uint32 cooldownPeriod, uint32 unstakePeriod);

  event RedeemableUpdated(bool redeemable);

  function setRedeemable(bool redeemable) external;


  function setMaxSlashablePercentage(uint16 percentage) external;


  function setCooldown(uint32 cooldownPeriod, uint32 unstakePeriod) external;


  function slashUnderlying(
    address destination,
    uint256 minAmount,
    uint256 maxAmount
  ) external returns (uint256 amount, bool erc20Transfer);

}// agpl-3.0
pragma solidity ^0.8.4;


contract StakeConfigurator is MarketAccessBitmask, VersionedInitializable, IStakeConfigurator {

  uint256 private constant CONFIGURATOR_REVISION = 3;

  mapping(uint256 => address) private _entries;
  uint256 private _entryCount;
  mapping(address => uint256) private _underlyings;

  ProxyAdmin private _proxies;
  uint256 private _legacyCount;

  constructor() MarketAccessBitmask(IMarketAccessController(address(0))) {}

  function getRevision() internal pure virtual override returns (uint256) {

    return CONFIGURATOR_REVISION;
  }

  function initialize(address addressesProvider) external initializer(CONFIGURATOR_REVISION) {

    _remoteAcl = IMarketAccessController(addressesProvider);
    if (address(_proxies) == address(0)) {
      _proxies = new ProxyAdmin();
      _legacyCount = _entryCount;
    }
  }

  function getProxyAdmin() public view returns (address) {

    return address(_proxies);
  }

  function list() public view override returns (address[] memory tokens) {

    return _list(_legacyCount);
  }

  function listAll() public view override returns (address[] memory tokens, uint256 genCount) {

    return (_list(0), _legacyCount);
  }

  function _list(uint256 base) internal view returns (address[] memory tokens) {

    if (_entryCount <= base) {
      return tokens;
    }
    tokens = new address[](_entryCount - base);
    base++;
    for (uint256 i = 0; i < tokens.length; i++) {
      tokens[i] = _entries[i + base];
    }
    return tokens;
  }

  function stakeTokenOf(address underlying) public view override returns (address) {

    uint256 i = _underlyings[underlying];
    if (i == 0) {
      return address(0);
    }
    return _entries[i];
  }

  function dataOf(address stakeToken) public view override returns (StakeTokenData memory data) {

    (data.config, data.stkTokenName, data.stkTokenSymbol) = IInitializableStakeToken(stakeToken)
      .initializedStakeTokenWith();
    data.token = stakeToken;

    return data;
  }

  function addStakeToken(address token) public aclHas(AccessFlags.STAKE_ADMIN) {

    require(token != address(0), 'unknown token');
    _addStakeToken(token, IDerivedToken(token).UNDERLYING_ASSET_ADDRESS());
  }

  function removeStakeTokenByUnderlying(address underlying) public aclHas(AccessFlags.STAKE_ADMIN) returns (bool) {

    require(underlying != address(0), 'unknown underlying');
    return _removeStakeToken(_underlyings[underlying], underlying);
  }

  function removeStakeToken(uint256 index) public aclHas(AccessFlags.STAKE_ADMIN) returns (bool) {

    return _removeStakeToken(index + 1, address(0));
  }

  function removeUnderlyings(address[] calldata underlyings) public aclHas(AccessFlags.STAKE_ADMIN) {

    for (uint256 i = underlyings.length; i > 0; ) {
      i--;
      _underlyings[underlyings[i]] = 0;
    }
  }

  function _removeStakeToken(uint256 i, address underlying) private returns (bool) {

    if (i == 0 || _entries[i] == address(0)) {
      return false;
    }

    emit StakeTokenRemoved(_entries[i], underlying);

    delete (_entries[i]);
    if (underlying == address(0)) {
      delete (_underlyings[underlying]);
    }
    return true;
  }

  function _addStakeToken(address token, address underlying) private {

    require(token != address(0), 'unknown token');
    require(underlying != address(0), 'unknown underlying');
    require(stakeTokenOf(underlying) == address(0), 'ambiguous underlying');

    _entryCount++;
    _entries[_entryCount] = token;
    _underlyings[underlying] = _entryCount;

    emit StakeTokenAdded(token, underlying);
  }

  function batchInitStakeTokens(InitStakeTokenData[] memory input) public aclHas(AccessFlags.STAKE_ADMIN) {

    for (uint256 i = 0; i < input.length; i++) {
      initStakeToken(input[i]);
    }
  }

  function initStakeToken(InitStakeTokenData memory input) private returns (address token) {

    StakeTokenConfig memory config = StakeTokenConfig(
      _remoteAcl,
      IERC20(input.stakedToken),
      IUnderlyingStrategy(input.strategy),
      input.cooldownPeriod,
      input.unstakePeriod,
      input.maxSlashable,
      input.stkTokenDecimals
    );

    bytes memory params = abi.encodeWithSelector(
      IInitializableStakeToken.initializeStakeToken.selector,
      config,
      input.stkTokenName,
      input.stkTokenSymbol
    );

    token = address(_remoteAcl.createProxy(address(_proxies), input.stakeTokenImpl, params));
    if (input.depositStake) {
      IDepositToken(input.stakedToken).addStakeOperator(token);
    }

    emit StakeTokenInitialized(token, input);

    _addStakeToken(token, input.stakedToken);

    return token;
  }

  function implementationOf(address token) external view returns (address) {

    return _proxies.getProxyImplementation(IProxy(token));
  }

  function updateStakeToken(UpdateStakeTokenData calldata input) external aclHas(AccessFlags.STAKE_ADMIN) {

    StakeTokenData memory data = dataOf(input.token);

    bytes memory params = abi.encodeWithSelector(
      IInitializableStakeToken.initializeStakeToken.selector,
      data.config,
      input.stkTokenName,
      input.stkTokenSymbol
    );

    _proxies.upgradeAndCall(IProxy(input.token), input.stakeTokenImpl, params);

    emit StakeTokenUpgraded(input.token, input);
  }

  function setCooldownForAll(uint32 cooldownPeriod, uint32 unstakePeriod)
    external
    override
    aclHas(AccessFlags.STAKE_ADMIN)
  {

    for (uint256 i = 1; i <= _entryCount; i++) {
      IManagedStakeToken(_entries[i]).setCooldown(cooldownPeriod, unstakePeriod);
    }
  }
}