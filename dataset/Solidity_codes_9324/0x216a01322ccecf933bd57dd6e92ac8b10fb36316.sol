pragma solidity ^0.8.0;

interface ILendingPoolAddressesProvider {

  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event IncentiveControllerUpdated(address indexed newAddress);
  event IncentiveTokenUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);


  function setMarketId(string calldata marketId) external payable;


  function setAddress(bytes32 id, address newAddress) external payable;


  function setAddressAsProxy(bytes32 id, address impl) external payable;


  function getAddress(bytes32 id) external view returns (address);


  function getLendingPool() external view returns (address);


  function setLendingPoolImpl(address pool) external payable;


  function getIncentiveController() external view returns (address);


  function setIncentiveControllerImpl(address incentiveController) external payable;


  function getIncentiveToken() external view returns (address);


  function setIncentiveTokenImpl(address incentiveToken) external payable;


  function getLendingPoolConfigurator() external view returns (address);


  function setLendingPoolConfiguratorImpl(address configurator) external payable;


  function getLendingPoolCollateralManager() external view returns (address);


  function setLendingPoolCollateralManager(address manager) external payable;


  function getPoolAdmin() external view returns (address);


  function setPoolAdmin(address admin) external payable;


  function getEmergencyAdmin() external view returns (address);


  function setEmergencyAdmin(address admin) external payable;


  function getPriceOracle() external view returns (address);


  function setPriceOracle(address priceOracle) external payable;


  function getLendingRateOracle() external view returns (address);


  function setLendingRateOracle(address lendingRateOracle) external payable;

}// agpl-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface ISturdyIncentivesController {

  event RewardsAccrued(address indexed user, uint256 amount);

  event RewardsClaimed(address indexed user, address indexed to, uint256 amount);

  event RewardsClaimed(
    address indexed user,
    address indexed to,
    address indexed claimer,
    uint256 amount
  );

  event ClaimerSet(address indexed user, address indexed claimer);

  function getAssetData(address asset)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );


  function setClaimer(address user, address claimer) external payable;


  function getClaimer(address user) external view returns (address);


  function configureAssets(address[] calldata assets, uint256[] calldata emissionsPerSecond)
    external
    payable;


  function handleAction(
    address asset,
    uint256 userBalance,
    uint256 totalSupply
  ) external;


  function getRewardsBalance(address[] calldata assets, address user)
    external
    view
    returns (uint256);


  function claimRewards(
    address[] calldata assets,
    uint256 amount,
    address to
  ) external returns (uint256);


  function claimRewardsOnBehalf(
    address[] calldata assets,
    uint256 amount,
    address user,
    address to
  ) external returns (uint256);


  function getUserUnclaimedRewards(address user) external view returns (uint256);


  function getUserAssetData(address user, address asset) external view returns (uint256);


  function REWARD_TOKEN() external view returns (address);


  function PRECISION() external view returns (uint8);


  function DISTRIBUTION_END() external view returns (uint256);

}// agpl-3.0
pragma solidity ^0.8.0;


interface IUiIncentiveDataProvider {

  struct AggregatedReserveIncentiveData {
    address underlyingAsset;
    IncentiveData aIncentiveData;
    IncentiveData vIncentiveData;
    IncentiveData sIncentiveData;
  }

  struct IncentiveData {
    uint256 emissionPerSecond;
    uint256 incentivesLastUpdateTimestamp;
    uint256 tokenIncentivesIndex;
    uint256 emissionEndTimestamp;
    address tokenAddress;
    address rewardTokenAddress;
    address incentiveControllerAddress;
    uint8 rewardTokenDecimals;
    uint8 precision;
  }

  struct UserReserveIncentiveData {
    address underlyingAsset;
    UserIncentiveData aTokenIncentivesUserData;
    UserIncentiveData vTokenIncentivesUserData;
    UserIncentiveData sTokenIncentivesUserData;
  }

  struct UserIncentiveData {
    uint256 tokenincentivesUserIndex;
    uint256 userUnclaimedRewards;
    address tokenAddress;
    address rewardTokenAddress;
    address incentiveControllerAddress;
    uint8 rewardTokenDecimals;
  }

  function getReservesIncentivesData(ILendingPoolAddressesProvider provider)
    external
    view
    returns (AggregatedReserveIncentiveData[] memory);


  function getUserReservesIncentivesData(ILendingPoolAddressesProvider provider, address user)
    external
    view
    returns (UserReserveIncentiveData[] memory);


  function getFullReservesIncentiveData(ILendingPoolAddressesProvider provider, address user)
    external
    view
    returns (AggregatedReserveIncentiveData[] memory, UserReserveIncentiveData[] memory);

}// agpl-3.0
pragma solidity ^0.8.0;

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    address yieldAddress;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {
    NONE,
    STABLE,
    VARIABLE
  }
}// agpl-3.0
pragma solidity ^0.8.0;


interface ILendingPool {

  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  event Paused();

  event Unpaused();

  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function depositYield(address asset, uint256 amount) external;


  function getYield(address asset, uint256 amount) external;


  function getTotalBalanceOfAssetPair(address asset) external view returns (uint256, uint256);


  function getBorrowingAssetAndVolumes()
    external
    view
    returns (
      uint256,
      uint256[] memory,
      address[] memory,
      uint256
    );


  function registerVault(address _vaultAddress) external payable;


  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);


  function withdrawFrom(
    address asset,
    uint256 amount,
    address from,
    address to
  ) external returns (uint256);


  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;


  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);


  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;


  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;


  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );


  function initReserve(
    address reserve,
    address yieldAddress,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external payable;


  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external
    payable;


  function setConfiguration(address reserve, uint256 configuration) external payable;


  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);


  function getUserConfiguration(address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);


  function getReserveNormalizedIncome(address asset) external view returns (uint256);


  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;


  function getReservesList() external view returns (address[] memory);


  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);


  function setPause(bool val) external payable;


  function paused() external view returns (bool);

}// agpl-3.0
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
}// agpl-3.0
pragma solidity ^0.8.0;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);

}// agpl-3.0
pragma solidity ^0.8.0;


interface IInitializableAToken {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address treasury,
    address incentivesController,
    uint8 aTokenDecimals,
    string aTokenName,
    string aTokenSymbol,
    bytes params
  );

  function initialize(
    ILendingPool pool,
    address treasury,
    address underlyingAsset,
    ISturdyIncentivesController incentivesController,
    uint8 aTokenDecimals,
    string calldata aTokenName,
    string calldata aTokenSymbol,
    bytes calldata params
  ) external;

}// agpl-3.0
pragma solidity ^0.8.0;


interface IAToken is IERC20, IScaledBalanceToken, IInitializableAToken {

  event Mint(address indexed from, uint256 value, uint256 index);

  function mint(
    address user,
    uint256 amount,
    uint256 index
  ) external payable returns (bool);


  event Burn(address indexed from, address indexed target, uint256 value, uint256 index);

  event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);

  function burn(
    address user,
    address receiverOfUnderlying,
    uint256 amount,
    uint256 index
  ) external payable;


  function mintToTreasury(uint256 amount, uint256 index) external payable;


  function transferOnLiquidation(
    address from,
    address to,
    uint256 value
  ) external payable;


  function transferUnderlyingTo(address user, uint256 amount) external payable returns (uint256);


  function handleRepayment(address user, uint256 amount) external;


  function getIncentivesController() external view returns (ISturdyIncentivesController);


  function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// agpl-3.0
pragma solidity ^0.8.0;


interface IInitializableDebtToken {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address incentivesController,
    uint8 debtTokenDecimals,
    string debtTokenName,
    string debtTokenSymbol,
    bytes params
  );

  function initialize(
    ILendingPool pool,
    address underlyingAsset,
    ISturdyIncentivesController incentivesController,
    uint8 debtTokenDecimals,
    string memory debtTokenName,
    string memory debtTokenSymbol,
    bytes calldata params
  ) external;

}// agpl-3.0
pragma solidity ^0.8.0;


interface IVariableDebtToken is IScaledBalanceToken, IInitializableDebtToken {

  event Mint(address indexed from, address indexed onBehalfOf, uint256 value, uint256 index);

  function mint(
    address user,
    address onBehalfOf,
    uint256 amount,
    uint256 index
  ) external payable returns (bool);


  event Burn(address indexed user, uint256 amount, uint256 index);

  function burn(
    address user,
    uint256 amount,
    uint256 index
  ) external payable;


  function getIncentivesController() external view returns (ISturdyIncentivesController);

}// agpl-3.0
pragma solidity ^0.8.0;



interface IStableDebtToken is IInitializableDebtToken {

  event Mint(
    address indexed user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 currentBalance,
    uint256 balanceIncrease,
    uint256 newRate,
    uint256 avgStableRate,
    uint256 newTotalSupply
  );

  event Burn(
    address indexed user,
    uint256 amount,
    uint256 currentBalance,
    uint256 balanceIncrease,
    uint256 avgStableRate,
    uint256 newTotalSupply
  );

  function mint(
    address user,
    address onBehalfOf,
    uint256 amount,
    uint256 rate
  ) external payable returns (bool);


  function burn(address user, uint256 amount) external payable;


  function getAverageStableRate() external view returns (uint256);


  function getUserStableRate(address user) external view returns (uint256);


  function getUserLastUpdated(address user) external view returns (uint40);


  function getSupplyData()
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint40
    );


  function getTotalSupplyLastUpdated() external view returns (uint40);


  function getTotalSupplyAndAvgRate() external view returns (uint256, uint256);


  function principalBalanceOf(address user) external view returns (uint256);


  function getIncentivesController() external view returns (ISturdyIncentivesController);

}// agpl-3.0
pragma solidity ^0.8.0;

library Errors {

  string internal constant CALLER_NOT_POOL_ADMIN = '33'; // 'The caller must be the pool admin'
  string internal constant BORROW_ALLOWANCE_NOT_ENOUGH = '59'; // User borrows on behalf, but allowance are too small

  string internal constant VL_INVALID_AMOUNT = '1'; // 'Amount must be greater than 0'
  string internal constant VL_NO_ACTIVE_RESERVE = '2'; // 'Action requires an active reserve'
  string internal constant VL_RESERVE_FROZEN = '3'; // 'Action cannot be performed because the reserve is frozen'
  string internal constant VL_CURRENT_AVAILABLE_LIQUIDITY_NOT_ENOUGH = '4'; // 'The current liquidity is not enough'
  string internal constant VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE = '5'; // 'User cannot withdraw more than the available balance'
  string internal constant VL_TRANSFER_NOT_ALLOWED = '6'; // 'Transfer cannot be allowed.'
  string internal constant VL_BORROWING_NOT_ENABLED = '7'; // 'Borrowing is not enabled'
  string internal constant VL_INVALID_INTEREST_RATE_MODE_SELECTED = '8'; // 'Invalid interest rate mode selected'
  string internal constant VL_COLLATERAL_BALANCE_IS_0 = '9'; // 'The collateral balance is 0'
  string internal constant VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD = '10'; // 'Health factor is lesser than the liquidation threshold'
  string internal constant VL_COLLATERAL_CANNOT_COVER_NEW_BORROW = '11'; // 'There is not enough collateral to cover a new borrow'
  string internal constant VL_STABLE_BORROWING_NOT_ENABLED = '12'; // stable borrowing not enabled
  string internal constant VL_COLLATERAL_SAME_AS_BORROWING_CURRENCY = '13'; // collateral is (mostly) the same currency that is being borrowed
  string internal constant VL_AMOUNT_BIGGER_THAN_MAX_LOAN_SIZE_STABLE = '14'; // 'The requested amount is greater than the max loan size in stable rate mode
  string internal constant VL_NO_DEBT_OF_SELECTED_TYPE = '15'; // 'for repayment of stable debt, the user needs to have stable debt, otherwise, he needs to have variable debt'
  string internal constant VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF = '16'; // 'To repay on behalf of an user an explicit amount to repay is needed'
  string internal constant VL_NO_STABLE_RATE_LOAN_IN_RESERVE = '17'; // 'User does not have a stable rate loan in progress on this reserve'
  string internal constant VL_NO_VARIABLE_RATE_LOAN_IN_RESERVE = '18'; // 'User does not have a variable rate loan in progress on this reserve'
  string internal constant VL_UNDERLYING_BALANCE_NOT_GREATER_THAN_0 = '19'; // 'The underlying balance needs to be greater than 0'
  string internal constant VL_DEPOSIT_ALREADY_IN_USE = '20'; // 'User deposit is already being used as collateral'
  string internal constant LP_NOT_ENOUGH_STABLE_BORROW_BALANCE = '21'; // 'User does not have any stable rate loan for this reserve'
  string internal constant LP_INTEREST_RATE_REBALANCE_CONDITIONS_NOT_MET = '22'; // 'Interest rate rebalance conditions were not met'
  string internal constant LP_LIQUIDATION_CALL_FAILED = '23'; // 'Liquidation call failed'
  string internal constant LP_NOT_ENOUGH_LIQUIDITY_TO_BORROW = '24'; // 'There is not enough liquidity available to borrow'
  string internal constant LP_REQUESTED_AMOUNT_TOO_SMALL = '25'; // 'The requested amount is too small for a FlashLoan.'
  string internal constant LP_INCONSISTENT_PROTOCOL_ACTUAL_BALANCE = '26'; // 'The actual balance of the protocol is inconsistent'
  string internal constant LP_CALLER_NOT_LENDING_POOL_CONFIGURATOR = '27'; // 'The caller of the function is not the lending pool configurator'
  string internal constant LP_INCONSISTENT_FLASHLOAN_PARAMS = '28';
  string internal constant CT_CALLER_MUST_BE_LENDING_POOL = '29'; // 'The caller of this function must be a lending pool'
  string internal constant CT_CANNOT_GIVE_ALLOWANCE_TO_HIMSELF = '30'; // 'User cannot give allowance to himself'
  string internal constant CT_TRANSFER_AMOUNT_NOT_GT_0 = '31'; // 'Transferred amount needs to be greater than zero'
  string internal constant RL_RESERVE_ALREADY_INITIALIZED = '32'; // 'Reserve has already been initialized'
  string internal constant LPC_RESERVE_LIQUIDITY_NOT_0 = '34'; // 'The liquidity of the reserve needs to be 0'
  string internal constant LPC_INVALID_ATOKEN_POOL_ADDRESS = '35'; // 'The liquidity of the reserve needs to be 0'
  string internal constant LPC_INVALID_STABLE_DEBT_TOKEN_POOL_ADDRESS = '36'; // 'The liquidity of the reserve needs to be 0'
  string internal constant LPC_INVALID_VARIABLE_DEBT_TOKEN_POOL_ADDRESS = '37'; // 'The liquidity of the reserve needs to be 0'
  string internal constant LPC_INVALID_STABLE_DEBT_TOKEN_UNDERLYING_ADDRESS = '38'; // 'The liquidity of the reserve needs to be 0'
  string internal constant LPC_INVALID_VARIABLE_DEBT_TOKEN_UNDERLYING_ADDRESS = '39'; // 'The liquidity of the reserve needs to be 0'
  string internal constant LPC_INVALID_ADDRESSES_PROVIDER_ID = '40'; // 'The liquidity of the reserve needs to be 0'
  string internal constant LPC_INVALID_CONFIGURATION = '75'; // 'Invalid risk parameters for the reserve'
  string internal constant LPC_CALLER_NOT_EMERGENCY_ADMIN = '76'; // 'The caller must be the emergency admin'
  string internal constant LPAPR_PROVIDER_NOT_REGISTERED = '41'; // 'Provider is not registered'
  string internal constant LPCM_HEALTH_FACTOR_NOT_BELOW_THRESHOLD = '42'; // 'Health factor is not below the threshold'
  string internal constant LPCM_COLLATERAL_CANNOT_BE_LIQUIDATED = '43'; // 'The collateral chosen cannot be liquidated'
  string internal constant LPCM_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER = '44'; // 'User did not borrow the specified currency'
  string internal constant LPCM_NOT_ENOUGH_LIQUIDITY_TO_LIQUIDATE = '45'; // "There isn't enough liquidity available to liquidate"
  string internal constant LPCM_NO_ERRORS = '46'; // 'No errors'
  string internal constant LP_INVALID_FLASHLOAN_MODE = '47'; //Invalid flashloan mode selected
  string internal constant MATH_MULTIPLICATION_OVERFLOW = '48';
  string internal constant MATH_ADDITION_OVERFLOW = '49';
  string internal constant MATH_DIVISION_BY_ZERO = '50';
  string internal constant RL_LIQUIDITY_INDEX_OVERFLOW = '51'; //  Liquidity index overflows uint128
  string internal constant RL_VARIABLE_BORROW_INDEX_OVERFLOW = '52'; //  Variable borrow index overflows uint128
  string internal constant RL_LIQUIDITY_RATE_OVERFLOW = '53'; //  Liquidity rate overflows uint128
  string internal constant RL_VARIABLE_BORROW_RATE_OVERFLOW = '54'; //  Variable borrow rate overflows uint128
  string internal constant RL_STABLE_BORROW_RATE_OVERFLOW = '55'; //  Stable borrow rate overflows uint128
  string internal constant CT_INVALID_MINT_AMOUNT = '56'; //invalid amount to mint
  string internal constant LP_FAILED_REPAY_WITH_COLLATERAL = '57';
  string internal constant CT_INVALID_BURN_AMOUNT = '58'; //invalid amount to burn
  string internal constant LP_FAILED_COLLATERAL_SWAP = '60';
  string internal constant LP_INVALID_EQUAL_ASSETS_TO_SWAP = '61';
  string internal constant LP_REENTRANCY_NOT_ALLOWED = '62';
  string internal constant LP_CALLER_MUST_BE_AN_ATOKEN = '63';
  string internal constant LP_IS_PAUSED = '64'; // 'Pool is paused'
  string internal constant LP_NO_MORE_RESERVES_ALLOWED = '65';
  string internal constant LP_INVALID_FLASH_LOAN_EXECUTOR_RETURN = '66';
  string internal constant RC_INVALID_LTV = '67';
  string internal constant RC_INVALID_LIQ_THRESHOLD = '68';
  string internal constant RC_INVALID_LIQ_BONUS = '69';
  string internal constant RC_INVALID_DECIMALS = '70';
  string internal constant RC_INVALID_RESERVE_FACTOR = '71';
  string internal constant LPAPR_INVALID_ADDRESSES_PROVIDER_ID = '72';
  string internal constant VL_INCONSISTENT_FLASHLOAN_PARAMS = '73';
  string internal constant LP_INCONSISTENT_PARAMS_LENGTH = '74';
  string internal constant UL_INVALID_INDEX = '77';
  string internal constant LP_NOT_CONTRACT = '78';
  string internal constant SDT_STABLE_DEBT_OVERFLOW = '79';
  string internal constant SDT_BURN_EXCEEDS_BALANCE = '80';
  string internal constant VT_COLLATERAL_DEPOSIT_REQUIRE_ETH = '81'; //Only accept ETH for collateral deposit
  string internal constant VT_COLLATERAL_DEPOSIT_INVALID = '82'; //Collateral deposit failed
  string internal constant VT_LIQUIDITY_DEPOSIT_INVALID = '83'; //Only accept USDC, USDT, DAI for liquidity deposit
  string internal constant VT_COLLATERAL_WITHDRAW_INVALID = '84'; //Collateral withdraw failed
  string internal constant VT_COLLATERAL_WITHDRAW_INVALID_AMOUNT = '85'; //Collateral withdraw has not enough amount
  string internal constant VT_CONVERT_ASSET_BY_CURVE_INVALID = '86'; //Convert asset by curve invalid
  string internal constant VT_PROCESS_YIELD_INVALID = '87'; //Processing yield is invalid
  string internal constant VT_TREASURY_INVALID = '88'; //Treasury is invalid
  string internal constant LP_ATOKEN_INIT_INVALID = '89'; //aToken invalid init
  string internal constant VT_FEE_TOO_BIG = '90'; //Fee is too big
  string internal constant VT_COLLATERAL_DEPOSIT_VAULT_UNAVAILABLE = '91';
  string internal constant LP_LIQUIDATION_CONVERT_FAILED = '92';
  string internal constant VT_DEPLOY_FAILED = '93'; // Vault deploy failed
  string internal constant VT_INVALID_CONFIGURATION = '94'; // Invalid vault configuration
  string internal constant VL_OVERFLOW_MAX_RESERVE_CAPACITY = '95'; // overflow max capacity of reserve
  string internal constant VT_WITHDRAW_AMOUNT_MISMATCH = '96'; // not performed withdraw 100%
  string internal constant VT_SWAP_MISMATCH_RETURNED_AMOUNT = '97'; //Returned amount is not enough
  string internal constant CALLER_NOT_YIELD_PROCESSOR = '98'; // 'The caller must be the pool admin'
  string internal constant VT_EXTRA_REWARDS_INDEX_INVALID = '99'; // Invalid extraRewards index
  string internal constant VT_SWAP_PATH_LENGTH_INVALID = '100'; // Invalid token or fee length
  string internal constant VT_SWAP_PATH_TOKEN_INVALID = '101'; // Invalid token information

  enum CollateralManagerErrors {
    NO_ERROR,
    NO_COLLATERAL_AVAILABLE,
    COLLATERAL_CANNOT_BE_LIQUIDATED,
    CURRRENCY_NOT_BORROWED,
    HEALTH_FACTOR_ABOVE_THRESHOLD,
    NOT_ENOUGH_LIQUIDITY,
    NO_ACTIVE_RESERVE,
    HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD,
    INVALID_EQUAL_ASSETS_TO_SWAP,
    FROZEN_RESERVE
  }
}// agpl-3.0
pragma solidity ^0.8.0;


library UserConfiguration {

  uint256 internal constant BORROWING_MASK =
    0x5555555555555555555555555555555555555555555555555555555555555555;

  function setBorrowing(
    DataTypes.UserConfigurationMap storage self,
    uint256 reserveIndex,
    bool borrowing
  ) internal {

    require(reserveIndex < 128, Errors.UL_INVALID_INDEX);
    self.data =
      (self.data & ~(1 << (reserveIndex * 2))) |
      (uint256(borrowing ? 1 : 0) << (reserveIndex * 2));
  }

  function setUsingAsCollateral(
    DataTypes.UserConfigurationMap storage self,
    uint256 reserveIndex,
    bool usingAsCollateral
  ) internal {

    require(reserveIndex < 128, Errors.UL_INVALID_INDEX);
    self.data =
      (self.data & ~(1 << (reserveIndex * 2 + 1))) |
      (uint256(usingAsCollateral ? 1 : 0) << (reserveIndex * 2 + 1));
  }

  function isUsingAsCollateralOrBorrowing(
    DataTypes.UserConfigurationMap memory self,
    uint256 reserveIndex
  ) internal pure returns (bool) {

    require(reserveIndex < 128, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 2)) & 3 > 0;
  }

  function isBorrowing(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex)
    internal
    pure
    returns (bool)
  {

    require(reserveIndex < 128, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 2)) & 1 > 0;
  }

  function isUsingAsCollateral(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex)
    internal
    pure
    returns (bool)
  {

    require(reserveIndex < 128, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 2 + 1)) & 1 > 0;
  }

  function isBorrowingAny(DataTypes.UserConfigurationMap memory self) internal pure returns (bool) {

    return self.data & BORROWING_MASK > 0;
  }

  function isEmpty(DataTypes.UserConfigurationMap memory self) internal pure returns (bool) {

    return self.data == 0;
  }
}// agpl-3.0
pragma solidity ^0.8.0;


interface IERC20Detailed is IERC20 {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);

}// agpl-3.0
pragma solidity ^0.8.0;


contract UiIncentiveDataProvider is IUiIncentiveDataProvider {

  using UserConfiguration for DataTypes.UserConfigurationMap;

  constructor() {}

  function getFullReservesIncentiveData(ILendingPoolAddressesProvider provider, address user)
    external
    view
    override
    returns (AggregatedReserveIncentiveData[] memory, UserReserveIncentiveData[] memory)
  {

    return (_getReservesIncentivesData(provider), _getUserReservesIncentivesData(provider, user));
  }

  function getReservesIncentivesData(ILendingPoolAddressesProvider provider)
    external
    view
    override
    returns (AggregatedReserveIncentiveData[] memory)
  {

    return _getReservesIncentivesData(provider);
  }

  function _getReservesIncentivesData(ILendingPoolAddressesProvider provider)
    private
    view
    returns (AggregatedReserveIncentiveData[] memory)
  {

    ILendingPool lendingPool = ILendingPool(provider.getLendingPool());
    address[] memory reserves = lendingPool.getReservesList();
    uint256 length = reserves.length;
    AggregatedReserveIncentiveData[]
      memory reservesIncentiveData = new AggregatedReserveIncentiveData[](length);

    for (uint256 i; i < length; ++i) {
      AggregatedReserveIncentiveData memory reserveIncentiveData = reservesIncentiveData[i];
      reserveIncentiveData.underlyingAsset = reserves[i];

      DataTypes.ReserveData memory baseData = lendingPool.getReserveData(reserves[i]);

      try IStableDebtToken(baseData.aTokenAddress).getIncentivesController() returns (
        ISturdyIncentivesController aTokenIncentiveController
      ) {
        if (address(aTokenIncentiveController) != address(0)) {
          address aRewardToken = aTokenIncentiveController.REWARD_TOKEN();

          try aTokenIncentiveController.getAssetData(baseData.aTokenAddress) returns (
            uint256 aTokenIncentivesIndex,
            uint256 aEmissionPerSecond,
            uint256 aIncentivesLastUpdateTimestamp
          ) {
            reserveIncentiveData.aIncentiveData = IncentiveData(
              aEmissionPerSecond,
              aIncentivesLastUpdateTimestamp,
              aTokenIncentivesIndex,
              aTokenIncentiveController.DISTRIBUTION_END(),
              baseData.aTokenAddress,
              aRewardToken,
              address(aTokenIncentiveController),
              IERC20Detailed(aRewardToken).decimals(),
              aTokenIncentiveController.PRECISION()
            );
          } catch (
            bytes memory /*lowLevelData*/
          ) {
          }
        }
      } catch (
        bytes memory /*lowLevelData*/
      ) {
      }

      try IStableDebtToken(baseData.stableDebtTokenAddress).getIncentivesController() returns (
        ISturdyIncentivesController sTokenIncentiveController
      ) {
        if (address(sTokenIncentiveController) != address(0)) {
          address sRewardToken = sTokenIncentiveController.REWARD_TOKEN();
          try sTokenIncentiveController.getAssetData(baseData.stableDebtTokenAddress) returns (
            uint256 sTokenIncentivesIndex,
            uint256 sEmissionPerSecond,
            uint256 sIncentivesLastUpdateTimestamp
          ) {
            reserveIncentiveData.sIncentiveData = IncentiveData(
              sEmissionPerSecond,
              sIncentivesLastUpdateTimestamp,
              sTokenIncentivesIndex,
              sTokenIncentiveController.DISTRIBUTION_END(),
              baseData.stableDebtTokenAddress,
              sRewardToken,
              address(sTokenIncentiveController),
              IERC20Detailed(sRewardToken).decimals(),
              sTokenIncentiveController.PRECISION()
            );
          } catch (
            bytes memory /*lowLevelData*/
          ) {
          }
        }
      } catch (
        bytes memory /*lowLevelData*/
      ) {
      }

      try IStableDebtToken(baseData.variableDebtTokenAddress).getIncentivesController() returns (
        ISturdyIncentivesController vTokenIncentiveController
      ) {
        if (address(vTokenIncentiveController) != address(0)) {
          address vRewardToken = vTokenIncentiveController.REWARD_TOKEN();

          try vTokenIncentiveController.getAssetData(baseData.variableDebtTokenAddress) returns (
            uint256 vTokenIncentivesIndex,
            uint256 vEmissionPerSecond,
            uint256 vIncentivesLastUpdateTimestamp
          ) {
            reserveIncentiveData.vIncentiveData = IncentiveData(
              vEmissionPerSecond,
              vIncentivesLastUpdateTimestamp,
              vTokenIncentivesIndex,
              vTokenIncentiveController.DISTRIBUTION_END(),
              baseData.variableDebtTokenAddress,
              vRewardToken,
              address(vTokenIncentiveController),
              IERC20Detailed(vRewardToken).decimals(),
              vTokenIncentiveController.PRECISION()
            );
          } catch (
            bytes memory /*lowLevelData*/
          ) {
          }
        }
      } catch (
        bytes memory /*lowLevelData*/
      ) {
      }
    }
    return (reservesIncentiveData);
  }

  function getUserReservesIncentivesData(ILendingPoolAddressesProvider provider, address user)
    external
    view
    override
    returns (UserReserveIncentiveData[] memory)
  {

    return _getUserReservesIncentivesData(provider, user);
  }

  function _getUserReservesIncentivesData(ILendingPoolAddressesProvider provider, address user)
    private
    view
    returns (UserReserveIncentiveData[] memory)
  {

    ILendingPool lendingPool = ILendingPool(provider.getLendingPool());
    address[] memory reserves = lendingPool.getReservesList();
    uint256 length = reserves.length;

    UserReserveIncentiveData[] memory userReservesIncentivesData = new UserReserveIncentiveData[](
      user != address(0) ? length : 0
    );

    for (uint256 i; i < length; ++i) {
      DataTypes.ReserveData memory baseData = lendingPool.getReserveData(reserves[i]);

      userReservesIncentivesData[i].underlyingAsset = reserves[i];

      IUiIncentiveDataProvider.UserIncentiveData memory aUserIncentiveData;

      try IAToken(baseData.aTokenAddress).getIncentivesController() returns (
        ISturdyIncentivesController aTokenIncentiveController
      ) {
        if (address(aTokenIncentiveController) != address(0)) {
          address aRewardToken = aTokenIncentiveController.REWARD_TOKEN();
          aUserIncentiveData.tokenincentivesUserIndex = aTokenIncentiveController.getUserAssetData(
            user,
            baseData.aTokenAddress
          );
          aUserIncentiveData.userUnclaimedRewards = aTokenIncentiveController
            .getUserUnclaimedRewards(user);
          aUserIncentiveData.tokenAddress = baseData.aTokenAddress;
          aUserIncentiveData.rewardTokenAddress = aRewardToken;
          aUserIncentiveData.incentiveControllerAddress = address(aTokenIncentiveController);
          aUserIncentiveData.rewardTokenDecimals = IERC20Detailed(aRewardToken).decimals();
        }
      } catch (
        bytes memory /*lowLevelData*/
      ) {}

      userReservesIncentivesData[i].aTokenIncentivesUserData = aUserIncentiveData;

      UserIncentiveData memory vUserIncentiveData;

      try IVariableDebtToken(baseData.variableDebtTokenAddress).getIncentivesController() returns (
        ISturdyIncentivesController vTokenIncentiveController
      ) {
        if (address(vTokenIncentiveController) != address(0)) {
          address vRewardToken = vTokenIncentiveController.REWARD_TOKEN();
          vUserIncentiveData.tokenincentivesUserIndex = vTokenIncentiveController.getUserAssetData(
            user,
            baseData.variableDebtTokenAddress
          );
          vUserIncentiveData.userUnclaimedRewards = vTokenIncentiveController
            .getUserUnclaimedRewards(user);
          vUserIncentiveData.tokenAddress = baseData.variableDebtTokenAddress;
          vUserIncentiveData.rewardTokenAddress = vRewardToken;
          vUserIncentiveData.incentiveControllerAddress = address(vTokenIncentiveController);
          vUserIncentiveData.rewardTokenDecimals = IERC20Detailed(vRewardToken).decimals();
        }
      } catch (
        bytes memory /*lowLevelData*/
      ) {}

      userReservesIncentivesData[i].vTokenIncentivesUserData = vUserIncentiveData;

      UserIncentiveData memory sUserIncentiveData;

      try IStableDebtToken(baseData.stableDebtTokenAddress).getIncentivesController() returns (
        ISturdyIncentivesController sTokenIncentiveController
      ) {
        if (address(sTokenIncentiveController) != address(0)) {
          address sRewardToken = sTokenIncentiveController.REWARD_TOKEN();
          sUserIncentiveData.tokenincentivesUserIndex = sTokenIncentiveController.getUserAssetData(
            user,
            baseData.stableDebtTokenAddress
          );
          sUserIncentiveData.userUnclaimedRewards = sTokenIncentiveController
            .getUserUnclaimedRewards(user);
          sUserIncentiveData.tokenAddress = baseData.stableDebtTokenAddress;
          sUserIncentiveData.rewardTokenAddress = sRewardToken;
          sUserIncentiveData.incentiveControllerAddress = address(sTokenIncentiveController);
          sUserIncentiveData.rewardTokenDecimals = IERC20Detailed(sRewardToken).decimals();
        }
      } catch (
        bytes memory /*lowLevelData*/
      ) {}

      userReservesIncentivesData[i].sTokenIncentivesUserData = sUserIncentiveData;
    }

    return (userReservesIncentivesData);
  }
}