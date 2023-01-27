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

library Address {

  function isContract(address account) internal view returns (bool) {

    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  function sendValue(address payable recipient, uint256 amount) internal {

    require(address(this).balance >= amount, 'Address: insufficient balance');

    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
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

    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {

    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {

    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length != 0) {
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}// agpl-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

library DistributionTypes {

  struct AssetConfigInput {
    uint104 emissionPerSecond;
    uint256 totalStaked;
    address underlyingAsset;
  }

  struct UserStakeInput {
    address underlyingAsset;
    uint256 stakedByUser;
    uint256 totalStaked;
  }

  struct AssetConfigInputForYield {
    uint256 totalStaked;
    address underlyingAsset;
  }
}// agpl-3.0
pragma solidity ^0.8.0;

abstract contract VersionedInitializable {
  uint256 private lastInitializedRevision;

  bool private initializing;

  modifier initializer() {
    uint256 revision = getRevision();
    require(
      initializing || isConstructor() || revision > lastInitializedRevision,
      'Contract instance has already been initialized'
    );

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      lastInitializedRevision = revision;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function getRevision() internal pure virtual returns (uint256);

  function isConstructor() private view returns (bool) {
    uint256 cs;
    assembly {
      cs := extcodesize(address())
    }
    return cs == 0;
  }

  uint256[50] private ______gap;
}// agpl-3.0
pragma solidity ^0.8.0;


interface ISturdyDistributionManager {

  event AssetConfigUpdated(address indexed asset, uint256 emission);
  event AssetIndexUpdated(address indexed asset, uint256 index);
  event UserIndexUpdated(address indexed user, address indexed asset, uint256 index);
  event DistributionEndUpdated(uint256 newDistributionEnd);

  function setDistributionEnd(uint256 distributionEnd) external payable;


  function getDistributionEnd() external view returns (uint256);


  function DISTRIBUTION_END() external view returns (uint256);


  function getUserAssetData(address user, address asset) external view returns (uint256);


  function getAssetData(address asset)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );

}// agpl-3.0
pragma solidity ^0.8.0;


contract DistributionManager is ISturdyDistributionManager {

  struct AssetData {
    uint104 emissionPerSecond;
    uint104 index;
    uint40 lastUpdateTimestamp;
    mapping(address => uint256) users;
  }

  address public immutable EMISSION_MANAGER;

  uint8 internal constant _PRECISION = 18;

  mapping(address => AssetData) public assets;

  uint256 internal _distributionEnd;

  modifier onlyEmissionManager() {

    require(msg.sender == EMISSION_MANAGER, 'ONLY_EMISSION_MANAGER');
    _;
  }

  constructor(address emissionManager) {
    EMISSION_MANAGER = emissionManager;
  }

  function setDistributionEnd(uint256 distributionEnd)
    external
    payable
    override
    onlyEmissionManager
  {

    _distributionEnd = distributionEnd;
    emit DistributionEndUpdated(distributionEnd);
  }

  function getDistributionEnd() external view override returns (uint256) {

    return _distributionEnd;
  }

  function DISTRIBUTION_END() external view virtual override returns (uint256) {

    return _distributionEnd;
  }

  function getUserAssetData(address user, address asset)
    public
    view
    virtual
    override
    returns (uint256)
  {

    return assets[asset].users[user];
  }

  function getAssetData(address asset)
    public
    view
    virtual
    override
    returns (
      uint256,
      uint256,
      uint256
    )
  {

    return (
      assets[asset].index,
      assets[asset].emissionPerSecond,
      assets[asset].lastUpdateTimestamp
    );
  }

  function _configureAssets(DistributionTypes.AssetConfigInput[] memory assetsConfigInput)
    internal
  {

    uint256 length = assetsConfigInput.length;
    for (uint256 i; i < length; ++i) {
      AssetData storage assetConfig = assets[assetsConfigInput[i].underlyingAsset];

      _updateAssetStateInternal(
        assetsConfigInput[i].underlyingAsset,
        assetConfig,
        assetsConfigInput[i].totalStaked
      );

      assetConfig.emissionPerSecond = assetsConfigInput[i].emissionPerSecond;

      emit AssetConfigUpdated(
        assetsConfigInput[i].underlyingAsset,
        assetsConfigInput[i].emissionPerSecond
      );
    }
  }

  function _updateAssetStateInternal(
    address asset,
    AssetData storage assetConfig,
    uint256 totalStaked
  ) internal returns (uint256) {

    uint256 oldIndex = assetConfig.index;
    uint256 emissionPerSecond = assetConfig.emissionPerSecond;
    uint128 lastUpdateTimestamp = assetConfig.lastUpdateTimestamp;

    if (block.timestamp == lastUpdateTimestamp) {
      return oldIndex;
    }

    uint256 newIndex = _getAssetIndex(
      oldIndex,
      emissionPerSecond,
      lastUpdateTimestamp,
      totalStaked
    );

    if (newIndex == oldIndex) {
      assetConfig.lastUpdateTimestamp = uint40(block.timestamp);
    } else {
      require(uint104(newIndex) == newIndex, 'Index overflow');
      assetConfig.index = uint104(newIndex);
      assetConfig.lastUpdateTimestamp = uint40(block.timestamp);
      emit AssetIndexUpdated(asset, newIndex);
    }

    return newIndex;
  }

  function _updateUserAssetInternal(
    address user,
    address asset,
    uint256 stakedByUser,
    uint256 totalStaked
  ) internal returns (uint256) {

    AssetData storage assetData = assets[asset];
    uint256 userIndex = assetData.users[user];
    uint256 accruedRewards;

    uint256 newIndex = _updateAssetStateInternal(asset, assetData, totalStaked);

    if (userIndex == newIndex) return accruedRewards;

    if (stakedByUser != 0) {
      accruedRewards = _getRewards(stakedByUser, newIndex, userIndex);
    }

    assetData.users[user] = newIndex;
    emit UserIndexUpdated(user, asset, newIndex);

    return accruedRewards;
  }

  function _claimRewards(address user, DistributionTypes.UserStakeInput[] memory stakes)
    internal
    returns (uint256)
  {

    uint256 accruedRewards;
    uint256 length = stakes.length;
    for (uint256 i; i < length; ++i) {
      accruedRewards =
        accruedRewards +
        _updateUserAssetInternal(
          user,
          stakes[i].underlyingAsset,
          stakes[i].stakedByUser,
          stakes[i].totalStaked
        );
    }

    return accruedRewards;
  }

  function _getUnclaimedRewards(address user, DistributionTypes.UserStakeInput[] memory stakes)
    internal
    view
    returns (uint256)
  {

    uint256 accruedRewards;
    uint256 length = stakes.length;
    for (uint256 i; i < length; ++i) {
      AssetData storage assetConfig = assets[stakes[i].underlyingAsset];
      uint256 assetIndex = _getAssetIndex(
        assetConfig.index,
        assetConfig.emissionPerSecond,
        assetConfig.lastUpdateTimestamp,
        stakes[i].totalStaked
      );

      accruedRewards =
        accruedRewards +
        _getRewards(stakes[i].stakedByUser, assetIndex, assetConfig.users[user]);
    }
    return accruedRewards;
  }

  function _getRewards(
    uint256 principalUserBalance,
    uint256 reserveIndex,
    uint256 userIndex
  ) internal pure returns (uint256) {

    return (principalUserBalance * (reserveIndex - userIndex)) / 10**uint256(_PRECISION);
  }

  function _getAssetIndex(
    uint256 currentIndex,
    uint256 emissionPerSecond,
    uint128 lastUpdateTimestamp,
    uint256 totalBalance
  ) internal view returns (uint256) {

    uint256 distributionEnd = _distributionEnd;
    if (
      emissionPerSecond == 0 ||
      totalBalance == 0 ||
      lastUpdateTimestamp == block.timestamp ||
      lastUpdateTimestamp >= distributionEnd
    ) {
      return currentIndex;
    }

    uint256 currentTimestamp = block.timestamp > distributionEnd
      ? distributionEnd
      : block.timestamp;
    uint256 timeDelta = currentTimestamp - lastUpdateTimestamp;
    return
      ((emissionPerSecond * timeDelta * (10**uint256(_PRECISION))) / totalBalance) + currentIndex;
  }
}// agpl-3.0
pragma solidity ^0.8.0;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);

}// agpl-3.0
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
  string internal constant CLAIMER_UNAUTHORIZED = '102'; // 'The claimer is not authorized'
  string internal constant YD_INVALID_CONFIGURATION = '103'; // 'The yield distribution's invalid configuration'
  string internal constant CALLER_NOT_EMISSION_MANAGER = '104'; // 'The caller must be emission manager'
  string internal constant CALLER_NOT_INCENTIVE_CONTROLLER = '105'; // 'The caller must be incentive controller'
  string internal constant YD_VR_ASSET_ALREADY_IN_USE = '106'; // Vault is already registered
  string internal constant YD_VR_INVALID_VAULT = '107'; // Invalid vault is used for an asset
  string internal constant YD_VR_INVALID_REWARDS_AMOUNT = '108'; // Rewards amount should be bigger than before
  string internal constant YD_VR_REWARD_TOKEN_NOT_VALID = '109'; // The reward token must be same with configured address
  string internal constant YD_VR_ASSET_NOT_REGISTERED = '110';
  string internal constant YD_VR_CALLER_NOT_VAULT = '111'; // The caller must be same with configured vault address

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



library PercentageMath {

  uint256 constant PERCENTAGE_FACTOR = 1e4; //percentage plus two decimals
  uint256 constant HALF_PERCENT = PERCENTAGE_FACTOR / 2;

  function percentMul(uint256 value, uint256 percentage) internal pure returns (uint256) {

    if (value == 0 || percentage == 0) {
      return 0;
    }

    return (value * percentage + HALF_PERCENT) / PERCENTAGE_FACTOR;
  }

  function percentDiv(uint256 value, uint256 percentage) internal pure returns (uint256) {

    uint256 halfPercentage = percentage / 2;

    return (value * PERCENTAGE_FACTOR + halfPercentage) / percentage;
  }
}// agpl-3.0
pragma solidity ^0.8.0;


interface IERC20Detailed is IERC20 {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);

}// agpl-3.0
pragma solidity ^0.8.0;



abstract contract GeneralVault is VersionedInitializable {
  using PercentageMath for uint256;

  event ProcessYield(address indexed collateralAsset, uint256 yieldAmount);
  event DepositCollateral(address indexed collateralAsset, address indexed from, uint256 amount);
  event WithdrawCollateral(address indexed collateralAsset, address indexed to, uint256 amount);
  event SetTreasuryInfo(address indexed treasuryAddress, uint256 fee);

  modifier onlyAdmin() {
    require(_addressesProvider.getPoolAdmin() == msg.sender, Errors.CALLER_NOT_POOL_ADMIN);
    _;
  }

  modifier onlyYieldProcessor() {
    require(
      _addressesProvider.getAddress('YIELD_PROCESSOR') == msg.sender,
      Errors.CALLER_NOT_YIELD_PROCESSOR
    );
    _;
  }

  struct AssetYield {
    address asset;
    uint256 amount;
  }

  ILendingPoolAddressesProvider internal _addressesProvider;

  uint256 internal _vaultFee;
  address internal _treasuryAddress;

  uint256 private constant VAULT_REVISION = 0x1;
  address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  function initialize(ILendingPoolAddressesProvider _provider) external initializer {
    _addressesProvider = _provider;
  }

  function getRevision() internal pure override returns (uint256) {
    return VAULT_REVISION;
  }

  function depositCollateral(address _asset, uint256 _amount) external payable virtual {
    if (_asset != address(0)) {
      require(msg.value == 0, Errors.VT_COLLATERAL_DEPOSIT_INVALID);
    } else {
      require(msg.value == _amount, Errors.VT_COLLATERAL_DEPOSIT_REQUIRE_ETH);
    }
    (address _stAsset, uint256 _stAssetAmount) = _depositToYieldPool(_asset, _amount);

    ILendingPool(_addressesProvider.getLendingPool()).deposit(
      _stAsset,
      _stAssetAmount,
      msg.sender,
      0
    );

    emit DepositCollateral(_asset, msg.sender, _amount);
  }

  function withdrawCollateral(
    address _asset,
    uint256 _amount,
    uint256 _slippage,
    address _to
  ) external virtual {
    (address _stAsset, uint256 _stAssetAmount) = _getWithdrawalAmount(_asset, _amount);

    uint256 _amountToWithdraw = ILendingPool(_addressesProvider.getLendingPool()).withdrawFrom(
      _stAsset,
      _stAssetAmount,
      msg.sender,
      address(this)
    );

    uint256 withdrawAmount = _withdrawFromYieldPool(_asset, _amountToWithdraw, _to);

    if (_amount == type(uint256).max) {
      uint256 decimal;
      if (_asset == address(0)) {
        decimal = 18;
      } else {
        decimal = IERC20Detailed(_asset).decimals();
      }

      _amount = (_amountToWithdraw * this.pricePerShare()) / 10**decimal;
    }
    require(
      withdrawAmount >= _amount.percentMul(PercentageMath.PERCENTAGE_FACTOR - _slippage),
      Errors.VT_WITHDRAW_AMOUNT_MISMATCH
    );

    emit WithdrawCollateral(_asset, _to, _amount);
  }

  function withdrawOnLiquidation(address, uint256 _amount) external virtual returns (uint256) {
    return _amount;
  }

  function processYield() external virtual;

  function pricePerShare() external view virtual returns (uint256);

  function setTreasuryInfo(address _treasury, uint256 _fee) external payable onlyAdmin {
    require(_treasury != address(0), Errors.VT_TREASURY_INVALID);
    require(_fee <= 30_00, Errors.VT_FEE_TOO_BIG);
    _treasuryAddress = _treasury;
    _vaultFee = _fee;

    emit SetTreasuryInfo(_treasury, _fee);
  }

  function _getYield(address _stAsset) internal returns (uint256) {
    uint256 yieldStAsset = _getYieldAmount(_stAsset);
    require(yieldStAsset != 0, Errors.VT_PROCESS_YIELD_INVALID);

    ILendingPool(_addressesProvider.getLendingPool()).getYield(_stAsset, yieldStAsset);
    return yieldStAsset;
  }

  function _getYieldAmount(address _stAsset) internal view returns (uint256) {
    (uint256 stAssetBalance, uint256 aTokenBalance) = ILendingPool(
      _addressesProvider.getLendingPool()
    ).getTotalBalanceOfAssetPair(_stAsset);

    if (stAssetBalance > aTokenBalance) return stAssetBalance - aTokenBalance;

    return 0;
  }

  function _depositToYieldPool(address _asset, uint256 _amount)
    internal
    virtual
    returns (address, uint256);

  function _withdrawFromYieldPool(
    address _asset,
    uint256 _amount,
    address _to
  ) internal virtual returns (uint256);

  function _getWithdrawalAmount(address _asset, uint256 _amount)
    internal
    view
    virtual
    returns (address, uint256);
}// agpl-3.0
pragma solidity ^0.8.0;



abstract contract IncentiveVault is GeneralVault {
  using SafeERC20 for IERC20;

  event SetIncentiveRatio(uint256 ratio);

  function getIncentiveToken() public view virtual returns (address);

  function getCurrentTotalIncentiveAmount() external view virtual returns (uint256);

  function getIncentiveRatio() external view virtual returns (uint256);

  function setIncentiveRatio(uint256 _ratio) external virtual;

  function _getAToken() internal view virtual returns (address);

  function _clearRewards() internal virtual;

  function _sendIncentive(uint256 amount) internal {
    address asset = _getAToken();
    address incentiveToken = getIncentiveToken();

    address yieldDistributor = _addressesProvider.getAddress('VR_YIELD_DISTRIBUTOR');
    IERC20(incentiveToken).safeTransfer(yieldDistributor, amount);

    VariableYieldDistribution(yieldDistributor).receivedRewards(asset, incentiveToken, amount);
  }
}// agpl-3.0
pragma solidity ^0.8.0;


contract VariableYieldDistribution is VersionedInitializable {

  using SafeERC20 for IERC20;

  uint256 private constant REVISION = 1;
  uint8 private constant PRECISION = 27;
  address public immutable EMISSION_MANAGER;

  ILendingPoolAddressesProvider internal _addressProvider;

  mapping(address => AssetData) public assets;

  event AssetRegistered(address indexed asset, address indexed yieldAddress);
  event AssetIndexUpdated(address indexed asset, uint256 index, uint256 rewardsAmount);
  event UserIndexUpdated(
    address indexed user,
    address indexed asset,
    uint256 index,
    uint256 unclaimedRewardsAmount
  );
  event RewardsReceived(address indexed asset, address indexed rewardToken, uint256 receivedAmount);
  event RewardsAccrued(address indexed user, address indexed asset, uint256 amount);
  event RewardsClaimed(
    address indexed asset,
    address indexed user,
    address indexed to,
    uint256 amount
  );

  modifier onlyEmissionManager() {

    require(msg.sender == EMISSION_MANAGER, Errors.CALLER_NOT_EMISSION_MANAGER);
    _;
  }

  modifier onlyIncentiveController() {

    require(
      msg.sender == _addressProvider.getIncentiveController(),
      Errors.CALLER_NOT_INCENTIVE_CONTROLLER
    );
    _;
  }

  constructor(address emissionManager) {
    EMISSION_MANAGER = emissionManager;
  }

  function initialize(ILendingPoolAddressesProvider _provider) external initializer {

    _addressProvider = _provider;
  }

  function registerAsset(address asset, address yieldAddress) external payable onlyEmissionManager {

    AssetData storage assetData = assets[asset];
    address rewardToken = IncentiveVault(yieldAddress).getIncentiveToken();

    require(assetData.yieldAddress == address(0), Errors.YD_VR_ASSET_ALREADY_IN_USE);
    require(rewardToken != address(0), Errors.YD_VR_INVALID_VAULT);

    uint256 totalStaked = IScaledBalanceToken(asset).scaledTotalSupply();
    assetData.yieldAddress = yieldAddress;
    assetData.rewardToken = rewardToken;

    (uint256 lastAvailableRewards, uint256 increasedRewards) = _getAvailableRewardsAmount(
      assetData
    );

    _updateAssetStateInternal(
      asset,
      assetData,
      totalStaked,
      lastAvailableRewards,
      increasedRewards
    );

    emit AssetRegistered(asset, yieldAddress);
  }

  function receivedRewards(
    address asset,
    address rewardToken,
    uint256 amount
  ) external {

    AssetData storage assetData = assets[asset];
    address _rewardToken = assetData.rewardToken;
    address _yieldAddress = assetData.yieldAddress;
    uint256 lastAvailableRewards = assetData.lastAvailableRewards;

    require(msg.sender == _yieldAddress, Errors.YD_VR_CALLER_NOT_VAULT);
    require(_rewardToken != address(0), Errors.YD_VR_ASSET_NOT_REGISTERED);
    require(rewardToken == _rewardToken, Errors.YD_VR_REWARD_TOKEN_NOT_VALID);
    require(amount >= lastAvailableRewards, Errors.YD_VR_INVALID_REWARDS_AMOUNT);

    uint256 increasedRewards = amount - lastAvailableRewards;
    uint256 totalStaked = IScaledBalanceToken(asset).scaledTotalSupply();

    _updateAssetStateInternal(asset, assetData, totalStaked, 0, increasedRewards);

    emit RewardsReceived(asset, rewardToken, amount);
  }

  function handleAction(
    address user,
    address asset,
    uint256 totalSupply,
    uint256 userBalance
  ) external payable onlyIncentiveController {

    uint256 accruedRewards = _updateUserAssetInternal(user, asset, userBalance, totalSupply);
    if (accruedRewards != 0) {
      emit RewardsAccrued(user, asset, accruedRewards);
    }
  }

  function getRewardsBalance(address[] calldata assets, address user)
    external
    view
    returns (AggregatedRewardsData[] memory)
  {

    uint256 length = assets.length;
    AggregatedRewardsData[] memory rewards = new AggregatedRewardsData[](length);

    for (uint256 i; i < length; ++i) {
      (uint256 stakedByUser, uint256 totalStaked) = IScaledBalanceToken(assets[i])
        .getScaledUserBalanceAndSupply(user);
      rewards[i].asset = assets[i];
      (rewards[i].rewardToken, rewards[i].balance) = _getUnclaimedRewards(
        user,
        assets[i],
        stakedByUser,
        totalStaked
      );
    }

    return rewards;
  }

  function claimRewards(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256) {

    require(to != address(0), 'INVALID_TO_ADDRESS');
    return _claimRewards(asset, amount, msg.sender, to);
  }

  function getUserAssetData(address user, address asset) public view returns (uint256, uint256) {

    UserData storage userData = assets[asset].users[user];
    return (userData.index, userData.unclaimedRewards);
  }

  function getAssetData(address asset)
    public
    view
    returns (
      uint256,
      address,
      address,
      uint256
    )
  {

    return (
      assets[asset].index,
      assets[asset].yieldAddress,
      assets[asset].rewardToken,
      assets[asset].lastAvailableRewards
    );
  }

  function getRevision() internal pure override returns (uint256) {

    return REVISION;
  }

  function _claimRewards(
    address asset,
    uint256 amount,
    address user,
    address to
  ) internal returns (uint256) {

    if (amount == 0) {
      return 0;
    }

    AssetData storage assetData = assets[asset];
    UserData storage userData = assetData.users[user];
    address rewardToken = assetData.rewardToken;

    (uint256 stakedByUser, uint256 totalStaked) = IScaledBalanceToken(asset)
      .getScaledUserBalanceAndSupply(user);

    _updateUserAssetInternal(user, asset, stakedByUser, totalStaked);

    uint256 unclaimedRewards = userData.unclaimedRewards;
    if (unclaimedRewards == 0) {
      return 0;
    }

    uint256 amountToClaim = amount > unclaimedRewards ? unclaimedRewards : amount;

    IERC20 stakeToken = IERC20(rewardToken);
    if (stakeToken.balanceOf(address(this)) >= amountToClaim) {
      stakeToken.safeTransfer(to, amountToClaim);
      userData.unclaimedRewards = unclaimedRewards - amountToClaim;
      emit RewardsClaimed(asset, user, to, amountToClaim);
    }

    return amountToClaim;
  }

  function _updateAssetStateInternal(
    address asset,
    AssetData storage assetData,
    uint256 totalStaked,
    uint256 lastAvailableRewards,
    uint256 increasedRewards
  ) internal returns (uint256) {

    uint256 oldIndex = assetData.index;
    uint256 oldAvailableRewards = assetData.lastAvailableRewards;

    uint256 newIndex = _getAssetIndex(oldIndex, increasedRewards, totalStaked);

    if (newIndex != oldIndex || lastAvailableRewards != oldAvailableRewards) {
      assetData.index = newIndex;
      assetData.lastAvailableRewards = lastAvailableRewards;
      emit AssetIndexUpdated(asset, newIndex, lastAvailableRewards);
    }

    return newIndex;
  }

  function _updateUserAssetInternal(
    address user,
    address asset,
    uint256 stakedByUser,
    uint256 totalStaked
  ) internal returns (uint256) {

    AssetData storage assetData = assets[asset];
    UserData storage userData = assetData.users[user];
    uint256 userIndex = userData.index;
    uint256 unclaimedRewards = userData.unclaimedRewards;
    uint256 accruedRewards;

    (uint256 lastAvailableRewards, uint256 increasedRewards) = _getAvailableRewardsAmount(
      assetData
    );
    uint256 newIndex = _updateAssetStateInternal(
      asset,
      assetData,
      totalStaked,
      lastAvailableRewards,
      increasedRewards
    );

    if (userIndex == newIndex) return accruedRewards;

    if (stakedByUser != 0) {
      accruedRewards = _getRewards(stakedByUser, newIndex, userIndex);
      unclaimedRewards += accruedRewards;
    }

    userData.index = newIndex;
    userData.unclaimedRewards = unclaimedRewards;
    emit UserIndexUpdated(user, asset, newIndex, unclaimedRewards);

    return accruedRewards;
  }

  function _getUnclaimedRewards(
    address user,
    address asset,
    uint256 stakedByUser,
    uint256 totalStaked
  ) internal view returns (address rewardToken, uint256 unclaimedRewards) {

    AssetData storage assetData = assets[asset];
    rewardToken = assetData.rewardToken;
    uint256 oldIndex = assetData.index;
    (, uint256 increasedRewards) = _getAvailableRewardsAmount(assetData);

    UserData storage userData = assetData.users[user];
    uint256 userIndex = userData.index;
    unclaimedRewards = userData.unclaimedRewards;

    uint256 assetIndex = _getAssetIndex(oldIndex, increasedRewards, totalStaked);

    if (stakedByUser != 0) {
      unclaimedRewards += _getRewards(stakedByUser, assetIndex, userIndex);
    }
  }

  function _getRewards(
    uint256 principalUserBalance,
    uint256 reserveIndex,
    uint256 userIndex
  ) internal pure returns (uint256) {

    return (principalUserBalance * (reserveIndex - userIndex)) / 10**uint256(PRECISION);
  }

  function _getAssetIndex(
    uint256 currentIndex,
    uint256 increasedRewards,
    uint256 totalBalance
  ) internal pure returns (uint256) {

    if (increasedRewards == 0 || totalBalance == 0) {
      return currentIndex;
    }

    return (increasedRewards * (10**uint256(PRECISION))) / totalBalance + currentIndex;
  }

  function _getAvailableRewardsAmount(AssetData storage assetData)
    internal
    view
    returns (uint256 lastAvailableRewards, uint256 increasedRewards)
  {

    address vault = assetData.yieldAddress;
    uint256 oldAmount = assetData.lastAvailableRewards;
    lastAvailableRewards = IncentiveVault(vault).getCurrentTotalIncentiveAmount();
    require(lastAvailableRewards >= oldAmount, Errors.YD_VR_INVALID_REWARDS_AMOUNT);
    increasedRewards = lastAvailableRewards - oldAmount;
  }
}// agpl-3.0
pragma solidity ^0.8.0;

struct UserData {
  uint256 index;
  uint256 unclaimedRewards;
}

struct AssetData {
  uint256 index;
  uint256 lastAvailableRewards;
  address rewardToken; // The address of reward token
  address yieldAddress; // The address of vault
  mapping(address => UserData) users;
}

struct AggregatedRewardsData {
  address asset;
  address rewardToken;
  uint256 balance;
}

interface IVariableYieldDistribution {

  function claimRewards(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);


  function getRewardsBalance(address[] calldata assets, address user)
    external
    view
    returns (AggregatedRewardsData[] memory);

}