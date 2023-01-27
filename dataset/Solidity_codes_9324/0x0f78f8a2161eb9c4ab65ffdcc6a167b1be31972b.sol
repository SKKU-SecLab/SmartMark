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

interface IProxy {

  function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;

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

interface IRemoteAccessBitmask {

  function queryAccessControlMask(address addr, uint256 filterMask) external view returns (uint256);

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

interface IEmergencyAccessGroup {

  function setPausedFor(address subject, bool paused) external;


  function isPausedFor(address subject) external view returns (bool);


  function listEmergencyGroup() external view returns (address[] memory);

}// agpl-3.0
pragma solidity ^0.8.4;


interface ILendingPoolConfigurator {

  struct InitReserveInput {
    address depositTokenImpl;
    address stableDebtTokenImpl;
    address variableDebtTokenImpl;
    uint8 underlyingAssetDecimals;
    bool externalStrategy;
    address strategy;
    address underlyingAsset;
    string depositTokenName;
    string depositTokenSymbol;
    string variableDebtTokenName;
    string variableDebtTokenSymbol;
    string stableDebtTokenName;
    string stableDebtTokenSymbol;
    bytes params;
  }

  struct UpdatePoolTokenInput {
    address asset;
    string name;
    string symbol;
    address implementation;
    bytes params;
  }

  struct ConfigureReserveInput {
    address asset;
    uint256 baseLTV;
    uint256 liquidationThreshold;
    uint256 liquidationBonus;
    uint256 reserveFactor;
    bool borrowingEnabled;
    bool stableBorrowingEnabled;
  }

  event ReserveInitialized(
    address indexed asset,
    address indexed depositToken,
    address stableDebtToken,
    address variableDebtToken,
    address strategy,
    bool externalStrategy
  );

  event BorrowingEnabledOnReserve(address indexed asset, bool stableRateEnabled);
  event BorrowingDisabledOnReserve(address indexed asset);

  event CollateralConfigurationChanged(
    address indexed asset,
    uint256 ltv,
    uint256 liquidationThreshold,
    uint256 liquidationBonus
  );

  event StableRateEnabledOnReserve(address indexed asset);
  event StableRateDisabledOnReserve(address indexed asset);

  event ReserveActivated(address indexed asset);
  event ReserveDeactivated(address indexed asset);

  event ReserveFrozen(address indexed asset);
  event ReserveUnfrozen(address indexed asset);

  event ReserveFactorChanged(address indexed asset, uint256 factor);
  event ReserveStrategyChanged(address indexed asset, address strategy, bool isExternal);

  event DepositTokenUpgraded(address indexed asset, address indexed proxy, address indexed implementation);

  event StableDebtTokenUpgraded(address indexed asset, address indexed proxy, address indexed implementation);

  event VariableDebtTokenUpgraded(address indexed asset, address indexed proxy, address indexed implementation);

  function getFlashloanAdapters(string[] calldata names) external view returns (address[] memory adapters);

}// agpl-3.0
pragma solidity ^0.8.4;

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address depositTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address strategy;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}

  struct InitReserveData {
    address asset;
    address depositTokenAddress;
    address stableDebtAddress;
    address variableDebtAddress;
    address strategy;
    bool externalStrategy;
  }
}// agpl-3.0
pragma solidity ^0.8.4;

interface IEmergencyAccess {

  function setPaused(bool paused) external;


  function isPaused() external view returns (bool);


  event EmergencyPaused(address indexed by, bool paused);
}// agpl-3.0
pragma solidity ^0.8.4;


interface IManagedLendingPool is IEmergencyAccess {

  function initReserve(DataTypes.InitReserveData calldata data) external;


  function setReserveStrategy(
    address reserve,
    address strategy,
    bool isExternal
  ) external;


  function setConfiguration(address reserve, uint256 configuration) external;


  function getLendingPoolExtension() external view returns (address);


  function setLendingPoolExtension(address) external;


  function trustedFlashLoan(
    address receiver,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint256 referral
  ) external;


  function setDisabledFeatures(uint16) external;


  function getDisabledFeatures() external view returns (uint16);

}// agpl-3.0
pragma solidity ^0.8.4;


interface ILendingPoolForTokens {

  function finalizeTransfer(
    address asset,
    address from,
    address to,
    bool lastBalanceFrom,
    bool firstBalanceTo
  ) external;


  function getAccessController() external view returns (IMarketAccessController);


  function getReserveNormalizedIncome(address asset) external view returns (uint256);


  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


  function getConfiguration(address asset) external view returns (DataTypes.ReserveConfigurationMap memory);


  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


  function getReservesList() external view returns (address[] memory);


  function setReservePaused(address asset, bool paused) external;

}// agpl-3.0
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


library PercentageMath {

  uint16 public constant BP = 1; // basis point
  uint16 public constant PCT = 100 * BP; // basis points per percentage point
  uint16 public constant ONE = 100 * PCT; // basis points per 1 (100%)
  uint16 public constant HALF_ONE = ONE / 2;
  uint256 public constant PERCENTAGE_FACTOR = ONE; //percentage plus two decimals

  function percentMul(uint256 value, uint256 factor) internal pure returns (uint256) {

    if (value == 0 || factor == 0) {
      return 0;
    }

    require(value <= (type(uint256).max - HALF_ONE) / factor, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (value * factor + HALF_ONE) / ONE;
  }

  function percentDiv(uint256 value, uint256 factor) internal pure returns (uint256) {

    require(factor != 0, Errors.MATH_DIVISION_BY_ZERO);
    uint256 halfFactor = factor >> 1;

    require(value <= (type(uint256).max - halfFactor) / ONE, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (value * ONE + halfFactor) / factor;
  }

  function percentOf(uint256 value, uint256 base) internal pure returns (uint256) {

    require(base != 0, Errors.MATH_DIVISION_BY_ZERO);
    if (value == 0) {
      return 0;
    }

    require(value <= (type(uint256).max - HALF_ONE) / ONE, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (value * ONE + (base >> 1)) / base;
  }
}// agpl-3.0
pragma solidity ^0.8.4;


library ReserveConfiguration {

  uint256 private constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
  uint256 private constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
  uint256 private constant LIQUIDATION_BONUS_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
  uint256 private constant DECIMALS_MASK =              0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFF; // prettier-ignore
  uint256 private constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
  uint256 private constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore
  uint256 private constant BORROWING_MASK =             0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF; // prettier-ignore
  uint256 private constant STABLE_BORROWING_MASK =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFF; // prettier-ignore
  uint256 private constant RESERVE_FACTOR_MASK =        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFF; // prettier-ignore
  uint256 private constant STRATEGY_TYPE_MASK =         0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFF; // prettier-ignore

  uint256 private constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
  uint256 private constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
  uint256 private constant RESERVE_DECIMALS_START_BIT_POSITION = 48;
  uint256 private constant RESERVE_FACTOR_START_BIT_POSITION = 64;

  uint256 private constant MAX_VALID_LTV = 65535;
  uint256 private constant MAX_VALID_LIQUIDATION_THRESHOLD = 65535;
  uint256 private constant MAX_VALID_LIQUIDATION_BONUS = 65535;
  uint256 private constant MAX_VALID_DECIMALS = 255;
  uint256 private constant MAX_VALID_RESERVE_FACTOR = 65535;

  function setLtv(DataTypes.ReserveConfigurationMap memory self, uint256 ltv) internal pure {

    require(ltv <= MAX_VALID_LTV, Errors.RC_INVALID_LTV);

    self.data = (self.data & LTV_MASK) | ltv;
  }

  function getLtv(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return self.data & ~LTV_MASK;
  }

  function setLiquidationThreshold(DataTypes.ReserveConfigurationMap memory self, uint256 threshold) internal pure {

    require(threshold <= MAX_VALID_LIQUIDATION_THRESHOLD, Errors.RC_INVALID_LIQ_THRESHOLD);

    self.data = (self.data & LIQUIDATION_THRESHOLD_MASK) | (threshold << LIQUIDATION_THRESHOLD_START_BIT_POSITION);
  }

  function getLiquidationThreshold(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION;
  }

  function setLiquidationBonus(DataTypes.ReserveConfigurationMap memory self, uint256 bonus) internal pure {

    require(bonus <= MAX_VALID_LIQUIDATION_BONUS, Errors.RC_INVALID_LIQ_BONUS);

    self.data = (self.data & LIQUIDATION_BONUS_MASK) | (bonus << LIQUIDATION_BONUS_START_BIT_POSITION);
  }

  function getLiquidationBonus(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION;
  }

  function setDecimals(DataTypes.ReserveConfigurationMap memory self, uint256 decimals) internal pure {

    require(decimals <= MAX_VALID_DECIMALS, Errors.RC_INVALID_DECIMALS);

    self.data = (self.data & DECIMALS_MASK) | (decimals << RESERVE_DECIMALS_START_BIT_POSITION);
  }

  function getDecimals(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION;
  }

  function getDecimalsMemory(DataTypes.ReserveConfigurationMap memory self) internal pure returns (uint8) {

    return uint8((self.data & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION);
  }

  function _setFlag(
    DataTypes.ReserveConfigurationMap memory self,
    uint256 mask,
    bool value
  ) internal pure {

    if (value) {
      self.data |= ~mask;
    } else {
      self.data &= mask;
    }
  }

  function setActive(DataTypes.ReserveConfigurationMap memory self, bool active) internal pure {

    _setFlag(self, ACTIVE_MASK, active);
  }

  function getActive(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~ACTIVE_MASK) != 0;
  }

  function setFrozen(DataTypes.ReserveConfigurationMap memory self, bool frozen) internal pure {

    _setFlag(self, FROZEN_MASK, frozen);
  }

  function getFrozen(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~FROZEN_MASK) != 0;
  }

  function getFrozenMemory(DataTypes.ReserveConfigurationMap memory self) internal pure returns (bool) {

    return (self.data & ~FROZEN_MASK) != 0;
  }

  function setBorrowingEnabled(DataTypes.ReserveConfigurationMap memory self, bool enabled) internal pure {

    _setFlag(self, BORROWING_MASK, enabled);
  }

  function getBorrowingEnabled(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~BORROWING_MASK) != 0;
  }

  function setStableRateBorrowingEnabled(DataTypes.ReserveConfigurationMap memory self, bool enabled) internal pure {

    _setFlag(self, STABLE_BORROWING_MASK, enabled);
  }

  function getStableRateBorrowingEnabled(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~STABLE_BORROWING_MASK) != 0;
  }

  function setReserveFactor(DataTypes.ReserveConfigurationMap memory self, uint256 reserveFactor) internal pure {

    require(reserveFactor <= MAX_VALID_RESERVE_FACTOR, Errors.RC_INVALID_RESERVE_FACTOR);

    self.data = (self.data & RESERVE_FACTOR_MASK) | (reserveFactor << RESERVE_FACTOR_START_BIT_POSITION);
  }

  function getReserveFactor(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION;
  }

  function getFlags(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (
      bool,
      bool,
      bool,
      bool
    )
  {

    return _getFlags(self.data);
  }

  function getFlagsMemory(DataTypes.ReserveConfigurationMap memory self)
    internal
    pure
    returns (
      bool active,
      bool frozen,
      bool borrowEnable,
      bool stableBorrowEnable
    )
  {

    return _getFlags(self.data);
  }

  function _getFlags(uint256 data)
    private
    pure
    returns (
      bool,
      bool,
      bool,
      bool
    )
  {

    return (
      (data & ~ACTIVE_MASK) != 0,
      (data & ~FROZEN_MASK) != 0,
      (data & ~BORROWING_MASK) != 0,
      (data & ~STABLE_BORROWING_MASK) != 0
    );
  }

  function getParams(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    return _getParams(self.data);
  }

  function getParamsMemory(DataTypes.ReserveConfigurationMap memory self)
    internal
    pure
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    return _getParams(self.data);
  }

  function _getParams(uint256 dataLocal)
    private
    pure
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    return (
      dataLocal & ~LTV_MASK,
      (dataLocal & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (dataLocal & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION,
      (dataLocal & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION,
      (dataLocal & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION
    );
  }

  function isExternalStrategyMemory(DataTypes.ReserveConfigurationMap memory self) internal pure returns (bool) {

    return (self.data & ~STRATEGY_TYPE_MASK) != 0;
  }

  function isExternalStrategy(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~STRATEGY_TYPE_MASK) != 0;
  }

  function setExternalStrategy(DataTypes.ReserveConfigurationMap memory self, bool isExternal) internal pure {

    _setFlag(self, STRATEGY_TYPE_MASK, isExternal);
  }
}// agpl-3.0
pragma solidity ^0.8.4;

struct PoolTokenConfig {
  address pool;
  address treasury;
  address underlyingAsset;
  uint8 underlyingDecimals;
}// agpl-3.0
pragma solidity ^0.8.4;


interface IInitializablePoolToken {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address treasury,
    string tokenName,
    string tokenSymbol,
    uint8 tokenDecimals,
    bytes params
  );

  function initialize(
    PoolTokenConfig calldata config,
    string calldata tokenName,
    string calldata tokenSymbol,
    bytes calldata params
  ) external;

}// agpl-3.0
pragma solidity ^0.8.4;


contract LendingPoolConfigurator is
  ProxyAdminBase,
  VersionedInitializable,
  MarketAccessBitmask(IMarketAccessController(address(0))),
  ILendingPoolConfigurator,
  IEmergencyAccessGroup
{

  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  ICombinedPool internal pool;
  mapping(string => address) private _namedAdapters;

  uint256 private constant CONFIGURATOR_REVISION = 0x1;

  function getRevision() internal pure virtual override returns (uint256) {

    return CONFIGURATOR_REVISION;
  }

  function initialize(IMarketAccessController provider) public initializer(CONFIGURATOR_REVISION) {

    _remoteAcl = provider;
    pool = ICombinedPool(provider.getLendingPool());
  }

  function batchInitReserve(InitReserveInput[] calldata input) external onlyPoolAdmin {

    address treasury = _remoteAcl.getAddress(AccessFlags.TREASURY);
    for (uint256 i = 0; i < input.length; i++) {
      _initReserve(input[i], treasury);
    }
  }

  function _initPoolToken(address impl, bytes memory initParams) internal returns (address) {

    return address(_remoteAcl.createProxy(address(this), impl, initParams));
  }

  function _initReserve(InitReserveInput calldata input, address treasury) internal {

    PoolTokenConfig memory config = PoolTokenConfig({
      pool: address(pool),
      treasury: treasury,
      underlyingAsset: input.underlyingAsset,
      underlyingDecimals: input.underlyingAssetDecimals
    });

    address depositTokenProxyAddress = _initPoolToken(
      input.depositTokenImpl,
      abi.encodeWithSelector(
        IInitializablePoolToken.initialize.selector,
        config,
        input.depositTokenName,
        input.depositTokenSymbol,
        input.params
      )
    );

    address variableDebtTokenProxyAddress = input.externalStrategy || input.variableDebtTokenImpl == address(0)
      ? address(0)
      : _initPoolToken(
        input.variableDebtTokenImpl,
        abi.encodeWithSelector(
          IInitializablePoolToken.initialize.selector,
          config,
          input.variableDebtTokenName,
          input.variableDebtTokenSymbol,
          input.params
        )
      );

    address stableDebtTokenProxyAddress = input.externalStrategy || input.stableDebtTokenImpl == address(0)
      ? address(0)
      : _initPoolToken(
        input.stableDebtTokenImpl,
        abi.encodeWithSelector(
          IInitializablePoolToken.initialize.selector,
          config,
          input.stableDebtTokenName,
          input.stableDebtTokenSymbol,
          input.params
        )
      );

    pool.initReserve(
      DataTypes.InitReserveData(
        input.underlyingAsset,
        depositTokenProxyAddress,
        stableDebtTokenProxyAddress,
        variableDebtTokenProxyAddress,
        input.strategy,
        input.externalStrategy
      )
    );

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(input.underlyingAsset);

    currentConfig.setDecimals(input.underlyingAssetDecimals);

    currentConfig.setActive(true);
    currentConfig.setFrozen(false);

    pool.setConfiguration(input.underlyingAsset, currentConfig.data);

    emit ReserveInitialized(
      input.underlyingAsset,
      depositTokenProxyAddress,
      stableDebtTokenProxyAddress,
      variableDebtTokenProxyAddress,
      input.strategy,
      input.externalStrategy
    );
  }

  function updateDepositToken(UpdatePoolTokenInput calldata input) external onlyPoolAdmin {

    address token = pool.getReserveData(input.asset).depositTokenAddress;

    _updatePoolToken(input, token);
    emit DepositTokenUpgraded(input.asset, token, input.implementation);
  }

  function updateStableDebtToken(UpdatePoolTokenInput calldata input) external onlyPoolAdmin {

    address token = pool.getReserveData(input.asset).stableDebtTokenAddress;

    _updatePoolToken(input, token);
    emit StableDebtTokenUpgraded(input.asset, token, input.implementation);
  }

  function updateVariableDebtToken(UpdatePoolTokenInput calldata input) external onlyPoolAdmin {

    address token = pool.getReserveData(input.asset).variableDebtTokenAddress;

    _updatePoolToken(input, token);
    emit VariableDebtTokenUpgraded(input.asset, token, input.implementation);
  }

  function _updatePoolToken(UpdatePoolTokenInput calldata input, address token) private {

    (, , , uint256 decimals, ) = pool.getConfiguration(input.asset).getParamsMemory();
    address treasury = _remoteAcl.getAddress(AccessFlags.TREASURY);

    PoolTokenConfig memory config = PoolTokenConfig({
      pool: address(pool),
      treasury: treasury,
      underlyingAsset: input.asset,
      underlyingDecimals: uint8(decimals)
    });

    bytes memory encodedCall = abi.encodeWithSelector(
      IInitializablePoolToken.initialize.selector,
      config,
      input.name,
      input.symbol,
      input.params
    );

    IProxy(token).upgradeToAndCall(input.implementation, encodedCall);
  }

  function implementationOf(address token) external view returns (address) {

    return _getProxyImplementation(IProxy(token));
  }

  function enableBorrowingOnReserve(address asset, bool stableBorrowRateEnabled) public onlyPoolAdmin {

    DataTypes.ReserveData memory reserve = pool.getReserveData(asset);
    require(reserve.variableDebtTokenAddress != address(0), Errors.LPC_INVALID_CONFIGURATION);
    require(
      !stableBorrowRateEnabled || (reserve.stableDebtTokenAddress != address(0)),
      Errors.LPC_INVALID_CONFIGURATION
    );

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);

    currentConfig.setBorrowingEnabled(true);
    currentConfig.setStableRateBorrowingEnabled(stableBorrowRateEnabled);

    pool.setConfiguration(asset, currentConfig.data);

    emit BorrowingEnabledOnReserve(asset, stableBorrowRateEnabled);
  }

  function disableBorrowingOnReserve(address asset) public onlyPoolAdmin {

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);

    currentConfig.setBorrowingEnabled(false);

    pool.setConfiguration(asset, currentConfig.data);
    emit BorrowingDisabledOnReserve(asset);
  }

  function configureReserveAsCollateral(
    address asset,
    uint256 ltv,
    uint256 liquidationThreshold,
    uint256 liquidationBonus
  ) public onlyPoolAdmin {

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);

    require(ltv <= liquidationThreshold, Errors.LPC_INVALID_CONFIGURATION);

    if (liquidationThreshold != 0) {
      require(liquidationBonus > PercentageMath.ONE, Errors.LPC_INVALID_CONFIGURATION);

      require(
        liquidationThreshold.percentMul(liquidationBonus) <= PercentageMath.ONE,
        Errors.LPC_INVALID_CONFIGURATION
      );
    } else {
      require(liquidationBonus == 0, Errors.LPC_INVALID_CONFIGURATION);
      _checkNoLiquidity(asset);
    }

    currentConfig.setLtv(ltv);
    currentConfig.setLiquidationThreshold(liquidationThreshold);
    currentConfig.setLiquidationBonus(liquidationBonus);

    pool.setConfiguration(asset, currentConfig.data);

    emit CollateralConfigurationChanged(asset, ltv, liquidationThreshold, liquidationBonus);
  }

  function enableReserveStableRate(address asset) external onlyPoolAdmin {

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);
    currentConfig.setStableRateBorrowingEnabled(true);
    pool.setConfiguration(asset, currentConfig.data);

    emit StableRateEnabledOnReserve(asset);
  }

  function disableReserveStableRate(address asset) external onlyPoolAdmin {

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);
    currentConfig.setStableRateBorrowingEnabled(false);
    pool.setConfiguration(asset, currentConfig.data);

    emit StableRateDisabledOnReserve(asset);
  }

  function activateReserve(address asset) external onlyPoolAdmin {

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);
    currentConfig.setActive(true);
    pool.setConfiguration(asset, currentConfig.data);

    emit ReserveActivated(asset);
  }

  function deactivateReserve(address asset) external onlyPoolAdmin {

    _checkNoLiquidity(asset);

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);
    currentConfig.setActive(false);
    pool.setConfiguration(asset, currentConfig.data);

    emit ReserveDeactivated(asset);
  }

  function freezeReserve(address asset) external onlyPoolAdmin {

    _setReserveFrozen(asset, true);
  }

  function unfreezeReserve(address asset) external onlyPoolAdmin {

    _setReserveFrozen(asset, false);
  }

  function setPausedFor(address asset, bool val) external override onlyEmergencyAdmin {

    _setReserveFrozen(asset, val);
  }

  function isPausedFor(address asset) external view override returns (bool) {

    return pool.getConfiguration(asset).getFrozenMemory();
  }

  function listEmergencyGroup() external view override returns (address[] memory) {

    return pool.getReservesList();
  }

  function _setReserveFrozen(address asset, bool val) private {

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);
    currentConfig.setFrozen(val);
    pool.setConfiguration(asset, currentConfig.data);

    if (val) {
      emit ReserveFrozen(asset);
    } else {
      emit ReserveUnfrozen(asset);
    }
  }

  function setReserveFactor(address asset, uint256 reserveFactor) public onlyPoolAdmin {

    DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);

    currentConfig.setReserveFactor(reserveFactor);

    pool.setConfiguration(asset, currentConfig.data);

    emit ReserveFactorChanged(asset, reserveFactor);
  }

  function setReserveStrategy(
    address asset,
    address strategy,
    bool isExternal
  ) external onlyPoolAdmin {

    require(strategy != address(0) || isExternal);
    pool.setReserveStrategy(asset, strategy, isExternal);
    emit ReserveStrategyChanged(asset, strategy, isExternal);
  }

  function _checkNoLiquidity(address asset) internal view {

    DataTypes.ReserveData memory reserveData = pool.getReserveData(asset);

    uint256 availableLiquidity = IERC20(asset).balanceOf(reserveData.depositTokenAddress);

    require(availableLiquidity == 0 && reserveData.currentLiquidityRate == 0, Errors.LPC_RESERVE_LIQUIDITY_NOT_0);
  }

  function configureReserves(ConfigureReserveInput[] calldata inputParams) external onlyPoolAdmin {

    for (uint256 i = 0; i < inputParams.length; i++) {
      configureReserveAsCollateral(
        inputParams[i].asset,
        inputParams[i].baseLTV,
        inputParams[i].liquidationThreshold,
        inputParams[i].liquidationBonus
      );

      if (inputParams[i].borrowingEnabled) {
        enableBorrowingOnReserve(inputParams[i].asset, inputParams[i].stableBorrowingEnabled);
      } else {
        disableBorrowingOnReserve(inputParams[i].asset);
      }
      setReserveFactor(inputParams[i].asset, inputParams[i].reserveFactor);
    }
  }

  function getFlashloanAdapters(string[] calldata names) external view override returns (address[] memory adapters) {

    adapters = new address[](names.length);
    for (uint256 i = 0; i < names.length; i++) {
      adapters[i] = _namedAdapters[names[i]];
    }
    return adapters;
  }

  function setFlashloanAdapters(string[] calldata names, address[] calldata adapters) external onlyPoolAdmin {

    require(names.length == adapters.length);

    for (uint256 i = 0; i < names.length; i++) {
      _namedAdapters[names[i]] = adapters[i];
    }
  }
}

interface ICombinedPool is ILendingPoolForTokens, IManagedLendingPool {}
