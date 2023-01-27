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

}// MIT
pragma solidity ^0.8.4;


library Address {

  function isContract(address account) internal view returns (bool) {


    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  bytes32 private constant accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

  function isExternallyOwned(address account) internal view returns (bool) {

    bytes32 codehash;
    uint256 size;
    assembly {
      codehash := extcodehash(account)
      size := extcodesize(account)
    }
    return codehash == accountHash && size == 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {

    require(address(this).balance >= amount, 'Address: insufficient balance');

    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {

    return functionCall(target, data, 'Address: low-level call failed');
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

    return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {

    require(address(this).balance >= value, 'Address: insufficient balance for call');
    require(isContract(target), 'Address: call to non-contract');

    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

    return functionStaticCall(target, data, 'Address: low-level static call failed');
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {

    require(isContract(target), 'Address: static call to non-contract');

    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

    return functionDelegateCall(target, data, 'Address: low-level delegate call failed');
  }

  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {

    require(isContract(target), 'Address: delegate call to non-contract');

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
pragma solidity ^0.8.4;


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

    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}// agpl-3.0
pragma solidity ^0.8.4;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);


  function getScaleIndex() external view returns (uint256);

}// agpl-3.0
pragma solidity ^0.8.4;

interface IDerivedToken {

  function UNDERLYING_ASSET_ADDRESS() external view returns (address);

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

interface IBalanceHook {

  function handleBalanceUpdate(
    address token,
    address holder,
    uint256 oldBalance,
    uint256 newBalance,
    uint256 providerSupply
  ) external;


  function handleScaledBalanceUpdate(
    address token,
    address holder,
    uint256 oldBalance,
    uint256 newBalance,
    uint256 providerSupply,
    uint256 scaleRay
  ) external;


  function isScaledBalanceUpdateNeeded() external view returns (bool);

}// agpl-3.0
pragma solidity ^0.8.4;


interface IStableDebtToken is IPoolToken {

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
  ) external returns (bool);


  function burn(address user, uint256 amount) external;


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

}// agpl-3.0
pragma solidity ^0.8.4;


interface IVariableDebtToken is IPoolToken, IScaledBalanceToken {

  event Mint(address indexed from, address indexed onBehalfOf, uint256 value, uint256 index);

  function mint(
    address user,
    address onBehalfOf,
    uint256 amount,
    uint256 index
  ) external returns (bool);


  event Burn(address indexed user, uint256 amount, uint256 index);

  function burn(
    address user,
    uint256 amount,
    uint256 index
  ) external;

}// agpl-3.0
pragma solidity ^0.8.4;

enum SourceType {
  AggregatorOrStatic,
  UniswapV2Pair
}

interface IPriceOracleEvents {

  event AssetPriceUpdated(address asset, uint256 price, uint256 timestamp);
  event EthPriceUpdated(uint256 price, uint256 timestamp);
  event DerivedAssetSourceUpdated(
    address indexed asset,
    uint256 index,
    address indexed underlyingSource,
    uint256 underlyingPrice,
    uint256 timestamp,
    SourceType sourceType
  );
}

interface IPriceOracleGetter is IPriceOracleEvents {

  function getAssetPrice(address asset) external view returns (uint256);

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


interface ILendingPoolEvents {

  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 indexed referral
  );

  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint256 indexed referral
  );

  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  event Swap(address indexed reserve, address indexed user, uint256 rateMode);

  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint256 referral
  );

  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveDeposit
  );

  event ReserveDataUpdated(
    address indexed underlying,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  event LendingPoolExtensionUpdated(address extension);

  event DisabledFeaturesUpdated(uint16 disabledFeatures);

  event FlashLoanPremiumUpdated(uint16 premium);
}// agpl-3.0
pragma solidity ^0.8.4;


interface ILendingPool is ILendingPoolEvents {

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint256 referral
  ) external;


  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);


  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint256 referral,
    address onBehalfOf
  ) external;


  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);


  function swapBorrowRateMode(address asset, uint256 rateMode) external;


  function rebalanceStableBorrowRate(address asset, address user) external;


  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;


  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveDeposit
  ) external;


  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint256 referral
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


  function getReservesList() external view returns (address[] memory);


  function getAddressesProvider() external view returns (address);


  function getFlashloanPremiumPct() external view returns (uint16);

}// agpl-3.0
pragma solidity ^0.8.4;

interface ILendingPoolAaveCompatible {

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referral
  ) external;


  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referral,
    address onBehalfOf
  ) external;


  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referral
  ) external;

}// agpl-3.0
pragma solidity ^0.8.4;


interface ILendingPoolExtension {

  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveDepositToken
  ) external;


  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint256 referral
  ) external;


  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint256 referral,
    address onBehalfOf
  ) external;


  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referral,
    address onBehalfOf
  ) external;


  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referral
  ) external;

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


library WadRayMath {

  uint256 internal constant WAD = 1e18;
  uint256 internal constant halfWAD = WAD / 2;

  uint256 internal constant RAY = 1e27;
  uint256 internal constant halfRAY = RAY / 2;

  uint256 internal constant WAD_RAY_RATIO = 1e9;

  function ray() internal pure returns (uint256) {

    return RAY;
  }

  function wad() internal pure returns (uint256) {

    return WAD;
  }

  function halfRay() internal pure returns (uint256) {

    return halfRAY;
  }

  function halfWad() internal pure returns (uint256) {

    return halfWAD;
  }

  function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }
    require(a <= (type(uint256).max - halfWAD) / b, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (a * b + halfWAD) / WAD;
  }

  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, Errors.MATH_DIVISION_BY_ZERO);
    uint256 halfB = b / 2;

    require(a <= (type(uint256).max - halfB) / WAD, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (a * WAD + halfB) / b;
  }

  function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }

    require(a <= (type(uint256).max - halfRAY) / b, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (a * b + halfRAY) / RAY;
  }

  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, Errors.MATH_DIVISION_BY_ZERO);
    uint256 halfB = b / 2;

    require(a <= (type(uint256).max - halfB) / RAY, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (a * RAY + halfB) / b;
  }

  function rayToWad(uint256 a) internal pure returns (uint256) {

    uint256 halfRatio = WAD_RAY_RATIO / 2;
    uint256 result = halfRatio + a;

    require(result >= halfRatio, Errors.MATH_ADDITION_OVERFLOW);

    return result / WAD_RAY_RATIO;
  }

  function wadToRay(uint256 a) internal pure returns (uint256) {

    uint256 result = a * WAD_RAY_RATIO;

    require(result / WAD_RAY_RATIO == a, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return result;
  }
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

interface IPriceOracleProvider {

  function getPriceOracle() external view returns (address);


  function getLendingRateOracle() external view returns (address);

}// agpl-3.0
pragma solidity ^0.8.4;


interface IPoolAddressProvider is IPriceOracleProvider {

  function getLendingPool() external view returns (address);

}// agpl-3.0
pragma solidity ^0.8.4;


interface IFlashLoanAddressProvider is IPoolAddressProvider {}// agpl-3.0

pragma solidity ^0.8.4;


interface IFlashLoanReceiver {

  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external returns (bool);


  function ADDRESS_PROVIDER() external view returns (IFlashLoanAddressProvider);


  function LENDING_POOL() external view returns (ILendingPool);

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

interface IReserveStrategy {

  function isDelegatedReserve() external view returns (bool);

}// agpl-3.0
pragma solidity ^0.8.4;


interface IReserveRateStrategy is IReserveStrategy {

  function baseVariableBorrowRate() external view returns (uint256);


  function getMaxVariableBorrowRate() external view returns (uint256);


  function calculateInterestRates(
    address reserve,
    address depositToken,
    uint256 liquidityAdded,
    uint256 liquidityTaken,
    uint256 totalStableDebt,
    uint256 totalVariableDebt,
    uint256 averageStableBorrowRate,
    uint256 reserveFactor
  )
    external
    view
    returns (
      uint256 liquidityRate,
      uint256 stableBorrowRate,
      uint256 variableBorrowRate
    );

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


interface IReserveDelegatedStrategy is IReserveStrategy, IUnderlyingStrategy {

  struct DelegatedState {
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 liquidityRate;
    uint128 variableBorrowRate;
    uint128 stableBorrowRate;
    uint40 lastUpdateTimestamp;
  }

  function getDelegatedState(address underlyingToken, uint40 lastUpdateTimestamp)
    external
    returns (DelegatedState memory);


  function getDelegatedDepositIndex(address underlyingToken) external view returns (uint256 liquidityIndex);


  function getStrategyName() external view returns (string memory);

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


library InterestMath {

  using WadRayMath for uint256;

  uint256 internal constant SECONDS_PER_YEAR = 365 days;
  uint256 internal constant MILLIS_PER_YEAR = SECONDS_PER_YEAR * 1000;

  function calculateLinearInterest(uint256 rate, uint40 lastUpdateTimestamp) internal view returns (uint256) {

    return WadRayMath.RAY + (rate * (block.timestamp - lastUpdateTimestamp)) / SECONDS_PER_YEAR;
  }

  function calculateCompoundedInterest(
    uint256 rate,
    uint40 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {

    uint256 exp = currentTimestamp - lastUpdateTimestamp;

    if (exp == 0) {
      return WadRayMath.ray();
    }

    uint256 expMinusOne = exp - 1;
    uint256 expMinusTwo = exp > 2 ? exp - 2 : 0;

    uint256 ratePerSecond = rate / SECONDS_PER_YEAR;

    uint256 basePowerTwo = ratePerSecond.rayMul(ratePerSecond);
    uint256 basePowerThree = basePowerTwo.rayMul(ratePerSecond);

    uint256 secondTerm = (exp * expMinusOne * basePowerTwo) / 2;
    uint256 thirdTerm = (exp * expMinusOne * expMinusTwo * basePowerThree) / 6;

    return WadRayMath.RAY + exp * ratePerSecond + secondTerm + thirdTerm;
  }

  function calculateCompoundedInterest(uint256 rate, uint40 lastUpdateTimestamp) internal view returns (uint256) {

    return calculateCompoundedInterest(rate, lastUpdateTimestamp, block.timestamp);
  }
}// agpl-3.0
pragma solidity ^0.8.4;


library ReserveLogic {

  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using SafeERC20 for IERC20;

  uint256 private constant externalPastLimit = 10 minutes;

  event ReserveDataUpdated(
    address indexed asset,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  using ReserveLogic for DataTypes.ReserveData;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  function getNormalizedIncome(DataTypes.ReserveData storage reserve, address asset) internal view returns (uint256) {

    uint40 timestamp = reserve.lastUpdateTimestamp;

    if (timestamp == uint40(block.timestamp)) {
      return reserve.liquidityIndex;
    }

    if (reserve.configuration.isExternalStrategy()) {
      return IReserveDelegatedStrategy(reserve.strategy).getDelegatedDepositIndex(asset);
    }

    return InterestMath.calculateLinearInterest(reserve.currentLiquidityRate, timestamp).rayMul(reserve.liquidityIndex);
  }

  function getNormalizedDebt(DataTypes.ReserveData storage reserve) internal view returns (uint256) {

    uint40 timestamp = reserve.lastUpdateTimestamp;

    if (timestamp == uint40(block.timestamp) || reserve.configuration.isExternalStrategy()) {
      return reserve.variableBorrowIndex;
    }

    uint256 cumulated = InterestMath.calculateCompoundedInterest(reserve.currentVariableBorrowRate, timestamp).rayMul(
      reserve.variableBorrowIndex
    );

    return cumulated;
  }

  function updateStateForDeposit(DataTypes.ReserveData storage reserve, address asset) internal returns (uint256) {

    if (reserve.configuration.isExternalStrategy()) {
      return _updateExternalIndexes(reserve, asset);
    }
    return _updateState(reserve);
  }

  function updateState(DataTypes.ReserveData storage reserve, address asset) internal {

    if (reserve.configuration.isExternalStrategy()) {
      if (reserve.lastUpdateTimestamp < uint40(block.timestamp)) {
        _updateExternalIndexes(reserve, asset);
      }
    } else {
      _updateState(reserve);
    }
  }

  function _updateState(DataTypes.ReserveData storage reserve) private returns (uint256) {

    uint256 scaledVariableDebt = IVariableDebtToken(reserve.variableDebtTokenAddress).scaledTotalSupply();
    uint256 previousVariableBorrowIndex = reserve.variableBorrowIndex;
    uint256 previousLiquidityIndex = reserve.liquidityIndex;
    uint40 lastUpdatedTimestamp = reserve.lastUpdateTimestamp;

    (uint256 newLiquidityIndex, uint256 newVariableBorrowIndex) = _updateIndexes(
      reserve,
      scaledVariableDebt,
      previousLiquidityIndex,
      previousVariableBorrowIndex,
      lastUpdatedTimestamp
    );

    _mintToTreasury(
      reserve,
      scaledVariableDebt,
      previousVariableBorrowIndex,
      newLiquidityIndex,
      newVariableBorrowIndex,
      lastUpdatedTimestamp
    );

    return newLiquidityIndex;
  }

  function cumulateToLiquidityIndex(
    DataTypes.ReserveData storage reserve,
    uint256 totalLiquidity,
    uint256 amount
  ) internal {

    uint256 result = WadRayMath.RAY + amount.wadToRay().wadDiv(totalLiquidity);

    result = result.rayMul(reserve.liquidityIndex);
    require(result <= type(uint128).max, Errors.RL_LIQUIDITY_INDEX_OVERFLOW);

    reserve.liquidityIndex = uint128(result);
  }

  function init(DataTypes.ReserveData storage reserve, DataTypes.InitReserveData calldata data) internal {

    require(reserve.depositTokenAddress == address(0), Errors.RL_RESERVE_ALREADY_INITIALIZED);

    reserve.liquidityIndex = uint128(WadRayMath.RAY);
    reserve.variableBorrowIndex = uint128(WadRayMath.RAY);
    reserve.depositTokenAddress = data.depositTokenAddress;
    reserve.stableDebtTokenAddress = data.stableDebtAddress;
    reserve.variableDebtTokenAddress = data.variableDebtAddress;
    reserve.strategy = data.strategy;
    {
      DataTypes.ReserveConfigurationMap memory cfg = reserve.configuration;
      cfg.setExternalStrategy(data.externalStrategy);
      reserve.configuration = cfg;
    }
  }

  struct UpdateInterestRatesLocalVars {
    uint256 availableLiquidity;
    uint256 totalStableDebt;
    uint256 newLiquidityRate;
    uint256 newStableRate;
    uint256 newVariableRate;
    uint256 avgStableRate;
    uint256 totalVariableDebt;
  }

  function updateInterestRates(
    DataTypes.ReserveData storage reserve,
    address reserveAddress,
    address depositToken,
    uint256 liquidityAdded,
    uint256 liquidityTaken
  ) internal {

    if (!reserve.configuration.isExternalStrategy()) {
      _updateInterestRates(reserve, reserveAddress, depositToken, liquidityAdded, liquidityTaken);
    }
  }

  function _updateInterestRates(
    DataTypes.ReserveData storage reserve,
    address reserveAddress,
    address depositToken,
    uint256 liquidityAdded,
    uint256 liquidityTaken
  ) private {

    UpdateInterestRatesLocalVars memory vars;

    (vars.totalStableDebt, vars.avgStableRate) = IStableDebtToken(reserve.stableDebtTokenAddress)
      .getTotalSupplyAndAvgRate();

    vars.totalVariableDebt = IVariableDebtToken(reserve.variableDebtTokenAddress).scaledTotalSupply().rayMul(
      reserve.variableBorrowIndex
    );

    (vars.newLiquidityRate, vars.newStableRate, vars.newVariableRate) = IReserveRateStrategy(reserve.strategy)
      .calculateInterestRates(
        reserveAddress,
        depositToken,
        liquidityAdded,
        liquidityTaken,
        vars.totalStableDebt,
        vars.totalVariableDebt,
        vars.avgStableRate,
        reserve.configuration.getReserveFactor()
      );
    require(vars.newLiquidityRate <= type(uint128).max, Errors.RL_LIQUIDITY_RATE_OVERFLOW);
    require(vars.newStableRate <= type(uint128).max, Errors.RL_STABLE_BORROW_RATE_OVERFLOW);
    require(vars.newVariableRate <= type(uint128).max, Errors.RL_VARIABLE_BORROW_RATE_OVERFLOW);

    reserve.currentLiquidityRate = uint128(vars.newLiquidityRate);
    reserve.currentStableBorrowRate = uint128(vars.newStableRate);
    reserve.currentVariableBorrowRate = uint128(vars.newVariableRate);

    emit ReserveDataUpdated(
      reserveAddress,
      vars.newLiquidityRate,
      vars.newStableRate,
      vars.newVariableRate,
      reserve.liquidityIndex,
      reserve.variableBorrowIndex
    );
  }

  struct MintToTreasuryLocalVars {
    uint256 currentStableDebt;
    uint256 principalStableDebt;
    uint256 previousStableDebt;
    uint256 currentVariableDebt;
    uint256 previousVariableDebt;
    uint256 avgStableRate;
    uint256 cumulatedStableInterest;
    uint256 totalDebtAccrued;
    uint256 amountToMint;
    uint256 reserveFactor;
    uint40 stableSupplyUpdatedTimestamp;
  }

  function _mintToTreasury(
    DataTypes.ReserveData storage reserve,
    uint256 scaledVariableDebt,
    uint256 previousVariableBorrowIndex,
    uint256 newLiquidityIndex,
    uint256 newVariableBorrowIndex,
    uint40 timestamp
  ) private {

    MintToTreasuryLocalVars memory vars;

    vars.reserveFactor = reserve.configuration.getReserveFactor();

    if (vars.reserveFactor == 0) {
      return;
    }

    (
      vars.principalStableDebt,
      vars.currentStableDebt,
      vars.avgStableRate,
      vars.stableSupplyUpdatedTimestamp
    ) = IStableDebtToken(reserve.stableDebtTokenAddress).getSupplyData();

    vars.previousVariableDebt = scaledVariableDebt.rayMul(previousVariableBorrowIndex);

    vars.currentVariableDebt = scaledVariableDebt.rayMul(newVariableBorrowIndex);

    vars.cumulatedStableInterest = InterestMath.calculateCompoundedInterest(
      vars.avgStableRate,
      vars.stableSupplyUpdatedTimestamp,
      timestamp
    );

    vars.previousStableDebt = vars.principalStableDebt.rayMul(vars.cumulatedStableInterest);

    vars.totalDebtAccrued =
      (vars.currentVariableDebt + vars.currentStableDebt) -
      (vars.previousVariableDebt + vars.previousStableDebt);

    vars.amountToMint = vars.totalDebtAccrued.percentMul(vars.reserveFactor);

    if (vars.amountToMint != 0) {
      IDepositToken(reserve.depositTokenAddress).mintToTreasury(vars.amountToMint, newLiquidityIndex);
    }
  }

  function _updateIndexes(
    DataTypes.ReserveData storage reserve,
    uint256 scaledVariableDebt,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex,
    uint40 timestamp
  ) private returns (uint256, uint256) {

    uint256 currentLiquidityRate = reserve.currentLiquidityRate;

    uint256 newLiquidityIndex = liquidityIndex;
    uint256 newVariableBorrowIndex = variableBorrowIndex;

    if (currentLiquidityRate > 0) {
      uint256 cumulatedLiquidityInterest = InterestMath.calculateLinearInterest(currentLiquidityRate, timestamp);
      newLiquidityIndex = cumulatedLiquidityInterest.rayMul(liquidityIndex);
      require(newLiquidityIndex <= type(uint128).max, Errors.RL_LIQUIDITY_INDEX_OVERFLOW);

      reserve.liquidityIndex = uint128(newLiquidityIndex);

      if (scaledVariableDebt != 0) {
        uint256 cumulatedVariableBorrowInterest = InterestMath.calculateCompoundedInterest(
          reserve.currentVariableBorrowRate,
          timestamp
        );
        newVariableBorrowIndex = cumulatedVariableBorrowInterest.rayMul(variableBorrowIndex);
        require(newVariableBorrowIndex <= type(uint128).max, Errors.RL_VARIABLE_BORROW_INDEX_OVERFLOW);
        reserve.variableBorrowIndex = uint128(newVariableBorrowIndex);
      }
    }

    reserve.lastUpdateTimestamp = uint40(block.timestamp);
    return (newLiquidityIndex, newVariableBorrowIndex);
  }

  function _updateExternalIndexes(DataTypes.ReserveData storage reserve, address asset) private returns (uint256) {

    IReserveDelegatedStrategy.DelegatedState memory state = IReserveDelegatedStrategy(reserve.strategy)
      .getDelegatedState(asset, reserve.lastUpdateTimestamp);
    require(state.lastUpdateTimestamp <= block.timestamp);

    if (state.lastUpdateTimestamp == reserve.lastUpdateTimestamp) {
      if (state.liquidityIndex == reserve.liquidityIndex) {
        return state.liquidityIndex;
      }
    } else {
      require(state.lastUpdateTimestamp > reserve.lastUpdateTimestamp);
      reserve.lastUpdateTimestamp = state.lastUpdateTimestamp;
    }

    reserve.variableBorrowIndex = state.variableBorrowIndex;
    reserve.currentLiquidityRate = state.liquidityRate;
    reserve.currentVariableBorrowRate = state.variableBorrowRate;
    reserve.currentStableBorrowRate = state.stableBorrowRate;
    reserve.liquidityIndex = state.liquidityIndex;

    return state.liquidityIndex;
  }

}// agpl-3.0
pragma solidity ^0.8.4;


library UserConfiguration {

  uint256 private constant ANY_BORROWING_MASK = 0x5555555555555555555555555555555555555555555555555555555555555555;
  uint256 private constant BORROW_BIT_MASK = 1;
  uint256 private constant COLLATERAL_BIT_MASK = 2;
  uint256 internal constant ANY_MASK = BORROW_BIT_MASK | COLLATERAL_BIT_MASK;
  uint256 internal constant SHIFT_STEP = 2;

  function setBorrowing(DataTypes.UserConfigurationMap storage self, uint256 reserveIndex) internal {

    self.data |= BORROW_BIT_MASK << (reserveIndex << 1);
  }

  function unsetBorrowing(DataTypes.UserConfigurationMap storage self, uint256 reserveIndex) internal {

    self.data &= ~(BORROW_BIT_MASK << (reserveIndex << 1));
  }

  function setUsingAsCollateral(DataTypes.UserConfigurationMap storage self, uint256 reserveIndex) internal {

    self.data |= COLLATERAL_BIT_MASK << (reserveIndex << 1);
  }

  function unsetUsingAsCollateral(DataTypes.UserConfigurationMap storage self, uint256 reserveIndex) internal {

    self.data &= ~(COLLATERAL_BIT_MASK << (reserveIndex << 1));
  }

  function isBorrowing(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex) internal pure returns (bool) {

    return (self.data >> (reserveIndex << 1)) & BORROW_BIT_MASK != 0;
  }

  function isUsingAsCollateral(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex)
    internal
    pure
    returns (bool)
  {

    return (self.data >> (reserveIndex << 1)) & COLLATERAL_BIT_MASK != 0;
  }

  function isBorrowingAny(DataTypes.UserConfigurationMap memory self) internal pure returns (bool) {

    return self.data & ANY_BORROWING_MASK != 0;
  }

  function isEmpty(DataTypes.UserConfigurationMap memory self) internal pure returns (bool) {

    return self.data == 0;
  }
}// agpl-3.0
pragma solidity ^0.8.4;


library GenericLogic {

  using ReserveLogic for DataTypes.ReserveData;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 public constant HEALTH_FACTOR_LIQUIDATION_THRESHOLD = 1 ether;

  struct BalanceDecreaseAllowedLocalVars {
    uint256 decimals;
    uint256 liquidationThreshold;
    uint256 totalCollateralInETH;
    uint256 totalDebtInETH;
    uint256 avgLiquidationThreshold;
    uint256 amountToDecreaseInETH;
    uint256 collateralBalanceAfterDecrease;
    uint256 liquidationThresholdAfterDecrease;
    uint256 healthFactorAfterDecrease;
    bool reserveUsageAsCollateralEnabled;
  }

  function balanceDecreaseAllowed(
    address asset,
    address user,
    uint256 amount,
    mapping(address => DataTypes.ReserveData) storage reservesData,
    DataTypes.UserConfigurationMap memory userConfig,
    mapping(uint256 => address) storage reserves,
    address oracle
  ) internal view returns (bool) {

    if (!userConfig.isBorrowingAny() || !userConfig.isUsingAsCollateral(reservesData[asset].id)) {
      return true;
    }

    BalanceDecreaseAllowedLocalVars memory vars;

    (, vars.liquidationThreshold, , vars.decimals, ) = reservesData[asset].configuration.getParams();

    if (vars.liquidationThreshold == 0) {
      return true;
    }

    (vars.totalCollateralInETH, vars.totalDebtInETH, , vars.avgLiquidationThreshold, ) = calculateUserAccountData(
      user,
      reservesData,
      userConfig,
      reserves,
      oracle
    );

    if (vars.totalDebtInETH == 0) {
      return true;
    }

    vars.amountToDecreaseInETH = (IPriceOracleGetter(oracle).getAssetPrice(asset) * amount) / (10**vars.decimals);
    vars.collateralBalanceAfterDecrease = vars.totalCollateralInETH - vars.amountToDecreaseInETH;

    if (vars.collateralBalanceAfterDecrease == 0) {
      return false;
    }

    vars.liquidationThresholdAfterDecrease =
      ((vars.totalCollateralInETH * vars.avgLiquidationThreshold) -
        (vars.amountToDecreaseInETH * vars.liquidationThreshold)) /
      vars.collateralBalanceAfterDecrease;

    uint256 healthFactorAfterDecrease = calculateHealthFactorFromBalances(
      vars.collateralBalanceAfterDecrease,
      vars.totalDebtInETH,
      vars.liquidationThresholdAfterDecrease
    );

    return healthFactorAfterDecrease >= GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD;
  }

  struct CalculateUserAccountDataVars {
    uint256 i;
    uint256 reserveUnitPrice;
    uint256 tokenUnit;
    uint256 compoundedLiquidityBalance;
    uint256 compoundedBorrowBalance;
    uint256 decimals;
    uint256 ltv;
    uint256 liquidationThreshold;
    uint256 healthFactor;
    uint256 totalCollateralInETH;
    uint256 totalDebtInETH;
    uint256 avgLtv;
    uint256 avgLiquidationThreshold;
    uint256 reservesLength;
    bool healthFactorBelowThreshold;
    address currentReserveAddress;
    bool usageAsCollateralEnabled;
    bool userUsesReserveAsCollateral;
  }

  function calculateUserAccountData(
    address user,
    mapping(address => DataTypes.ReserveData) storage reservesData,
    DataTypes.UserConfigurationMap memory userConfig,
    mapping(uint256 => address) storage reserves,
    address oracle
  )
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

    if (userConfig.isEmpty()) {
      return (0, 0, 0, 0, ~uint256(0));
    }

    CalculateUserAccountDataVars memory vars;
    for (
      uint256 scanData = userConfig.data;
      scanData > 0;
      (vars.i, scanData) = (vars.i + 1, scanData >> UserConfiguration.SHIFT_STEP)
    ) {
      if (scanData & UserConfiguration.ANY_MASK == 0) {
        continue;
      }

      vars.currentReserveAddress = reserves[vars.i];
      DataTypes.ReserveData storage currentReserve = reservesData[vars.currentReserveAddress];

      (vars.ltv, vars.liquidationThreshold, , vars.decimals, ) = currentReserve.configuration.getParams();

      vars.tokenUnit = 10**vars.decimals;
      vars.reserveUnitPrice = IPriceOracleGetter(oracle).getAssetPrice(vars.currentReserveAddress);

      if (vars.liquidationThreshold != 0 && userConfig.isUsingAsCollateral(vars.i)) {
        vars.compoundedLiquidityBalance = IDepositToken(currentReserve.depositTokenAddress).collateralBalanceOf(user);

        uint256 liquidityBalanceETH = (vars.reserveUnitPrice * vars.compoundedLiquidityBalance) / vars.tokenUnit;

        vars.totalCollateralInETH += liquidityBalanceETH;
        vars.avgLtv += liquidityBalanceETH * vars.ltv;
        vars.avgLiquidationThreshold += liquidityBalanceETH * vars.liquidationThreshold;
      }

      if (userConfig.isBorrowing(vars.i)) {
        vars.compoundedBorrowBalance =
          IERC20(currentReserve.stableDebtTokenAddress).balanceOf(user) +
          IERC20(currentReserve.variableDebtTokenAddress).balanceOf(user);

        vars.totalDebtInETH += (vars.reserveUnitPrice * vars.compoundedBorrowBalance) / vars.tokenUnit;
      }
    }

    if (vars.totalCollateralInETH > 0) {
      vars.avgLtv /= vars.totalCollateralInETH;
      vars.avgLiquidationThreshold /= vars.totalCollateralInETH;
    } else {
      (vars.avgLtv, vars.avgLiquidationThreshold) = (0, 0);
    }

    vars.healthFactor = calculateHealthFactorFromBalances(
      vars.totalCollateralInETH,
      vars.totalDebtInETH,
      vars.avgLiquidationThreshold
    );
    return (
      vars.totalCollateralInETH,
      vars.totalDebtInETH,
      vars.avgLtv,
      vars.avgLiquidationThreshold,
      vars.healthFactor
    );
  }

  function calculateHealthFactorFromBalances(
    uint256 totalCollateralInETH,
    uint256 totalDebtInETH,
    uint256 liquidationThreshold
  ) internal pure returns (uint256) {

    if (totalDebtInETH == 0) return ~uint256(0);

    return (totalCollateralInETH.percentMul(liquidationThreshold)).wadDiv(totalDebtInETH);
  }


  function calculateAvailableBorrowsETH(
    uint256 totalCollateralInETH,
    uint256 totalDebtInETH,
    uint256 ltv
  ) internal pure returns (uint256) {

    uint256 availableBorrowsETH = totalCollateralInETH.percentMul(ltv);

    if (availableBorrowsETH < totalDebtInETH) {
      return 0;
    }

    availableBorrowsETH = availableBorrowsETH - totalDebtInETH;
    return availableBorrowsETH;
  }
}// agpl-3.0
pragma solidity ^0.8.4;


library Helpers {

  function getUserCurrentDebt(address user, DataTypes.ReserveData storage reserve)
    internal
    view
    returns (uint256, uint256)
  {

    return (
      IERC20(reserve.stableDebtTokenAddress).balanceOf(user),
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }

  function getUserCurrentDebtMemory(address user, DataTypes.ReserveData memory reserve)
    internal
    view
    returns (uint256, uint256)
  {

    return (
      IERC20(reserve.stableDebtTokenAddress).balanceOf(user),
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }
}// agpl-3.0
pragma solidity ^0.8.4;


library ValidationLogic {

  using ReserveLogic for DataTypes.ReserveData;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using SafeERC20 for IERC20;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 public constant REBALANCE_UP_LIQUIDITY_RATE_THRESHOLD = 4000;
  uint256 public constant REBALANCE_UP_USAGE_RATIO_THRESHOLD = 0.95 * 1e27; //usage ratio of 95%

  function validateDeposit(DataTypes.ReserveData storage reserve, uint256 amount) internal view {

    (bool isActive, bool isFrozen, , ) = reserve.configuration.getFlags();

    require(amount != 0, Errors.VL_INVALID_AMOUNT);
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!isFrozen, Errors.VL_RESERVE_FROZEN);
  }

  function validateWithdraw(
    address reserveAddress,
    uint256 amount,
    uint256 userBalance,
    mapping(address => DataTypes.ReserveData) storage reservesData,
    DataTypes.UserConfigurationMap storage userConfig,
    mapping(uint256 => address) storage reserves,
    address oracle
  ) internal view {

    require(amount != 0, Errors.VL_INVALID_AMOUNT);
    require(amount <= userBalance, Errors.VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE);
    (bool isActive, , , ) = reservesData[reserveAddress].configuration.getFlags();
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);

    require(
      GenericLogic.balanceDecreaseAllowed(
        reserveAddress,
        msg.sender,
        amount,
        reservesData,
        userConfig,
        reserves,
        oracle
      ),
      Errors.VL_TRANSFER_NOT_ALLOWED
    );
  }

  struct ValidateBorrowLocalVars {
    uint256 currentLtv;
    uint256 currentLiquidationThreshold;
    uint256 amountOfCollateralNeededETH;
    uint256 userCollateralBalanceETH;
    uint256 userBorrowBalanceETH;
    uint256 availableLiquidity;
    uint256 healthFactor;
    bool isActive;
    bool isFrozen;
    bool borrowingEnabled;
    bool stableRateBorrowingEnabled;
  }


  function validateBorrow(
    address asset,
    DataTypes.ReserveData storage reserve,
    address userAddress,
    uint256 amount,
    uint256 amountInETH,
    uint256 interestRateMode,
    uint256 maxStableLoanPercent,
    mapping(address => DataTypes.ReserveData) storage reservesData,
    DataTypes.UserConfigurationMap storage userConfig,
    mapping(uint256 => address) storage reserves,
    address oracle
  ) internal view {

    ValidateBorrowLocalVars memory vars;

    (vars.isActive, vars.isFrozen, vars.borrowingEnabled, vars.stableRateBorrowingEnabled) = reserve
      .configuration
      .getFlags();

    require(vars.isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!vars.isFrozen, Errors.VL_RESERVE_FROZEN);
    require(amount != 0, Errors.VL_INVALID_AMOUNT);

    require(vars.borrowingEnabled, Errors.VL_BORROWING_NOT_ENABLED);

    require(
      uint256(DataTypes.InterestRateMode.VARIABLE) == interestRateMode ||
        uint256(DataTypes.InterestRateMode.STABLE) == interestRateMode,
      Errors.VL_INVALID_INTEREST_RATE_MODE_SELECTED
    );

    (
      vars.userCollateralBalanceETH,
      vars.userBorrowBalanceETH,
      vars.currentLtv,
      vars.currentLiquidationThreshold,
      vars.healthFactor
    ) = GenericLogic.calculateUserAccountData(userAddress, reservesData, userConfig, reserves, oracle);

    require(vars.userCollateralBalanceETH > 0, Errors.VL_COLLATERAL_BALANCE_IS_0);

    require(
      vars.healthFactor > GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      Errors.VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD
    );

    vars.amountOfCollateralNeededETH = (vars.userBorrowBalanceETH + amountInETH).percentDiv(vars.currentLtv); //LTV is calculated in percentage

    require(
      vars.amountOfCollateralNeededETH <= vars.userCollateralBalanceETH,
      Errors.VL_COLLATERAL_CANNOT_COVER_NEW_BORROW
    );


    if (interestRateMode == uint256(DataTypes.InterestRateMode.STABLE)) {

      require(vars.stableRateBorrowingEnabled, Errors.VL_STABLE_BORROWING_NOT_ENABLED);

      require(
        !userConfig.isUsingAsCollateral(reserve.id) ||
          reserve.configuration.getLtv() == 0 ||
          amount > IDepositToken(reserve.depositTokenAddress).collateralBalanceOf(userAddress),
        Errors.VL_COLLATERAL_SAME_AS_BORROWING_CURRENCY
      );

      vars.availableLiquidity = IERC20(asset).balanceOf(reserve.depositTokenAddress);

      uint256 maxLoanSizeStable = vars.availableLiquidity.percentMul(maxStableLoanPercent);

      require(amount <= maxLoanSizeStable, Errors.VL_AMOUNT_BIGGER_THAN_MAX_LOAN_SIZE_STABLE);
    }
  }

  function validateRepay(
    DataTypes.ReserveData storage reserve,
    uint256 amountSent,
    DataTypes.InterestRateMode rateMode,
    address onBehalfOf,
    uint256 stableDebt,
    uint256 variableDebt
  ) internal view {

    bool isActive = reserve.configuration.getActive();

    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);

    require(amountSent > 0, Errors.VL_INVALID_AMOUNT);

    require(
      (stableDebt > 0 && DataTypes.InterestRateMode(rateMode) == DataTypes.InterestRateMode.STABLE) ||
        (variableDebt > 0 && DataTypes.InterestRateMode(rateMode) == DataTypes.InterestRateMode.VARIABLE),
      Errors.VL_NO_DEBT_OF_SELECTED_TYPE
    );

    require(amountSent != ~uint256(0) || msg.sender == onBehalfOf, Errors.VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF);
  }

  function validateSwapRateMode(
    DataTypes.ReserveData storage reserve,
    DataTypes.UserConfigurationMap storage userConfig,
    uint256 stableDebt,
    uint256 variableDebt,
    DataTypes.InterestRateMode currentRateMode
  ) internal view {

    (bool isActive, bool isFrozen, , bool stableRateEnabled) = reserve.configuration.getFlags();

    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!isFrozen, Errors.VL_RESERVE_FROZEN);

    if (currentRateMode == DataTypes.InterestRateMode.STABLE) {
      require(stableDebt > 0, Errors.VL_NO_STABLE_RATE_LOAN_IN_RESERVE);
    } else if (currentRateMode == DataTypes.InterestRateMode.VARIABLE) {
      require(variableDebt > 0, Errors.VL_NO_VARIABLE_RATE_LOAN_IN_RESERVE);
      require(stableRateEnabled, Errors.VL_STABLE_BORROWING_NOT_ENABLED);

      require(
        !userConfig.isUsingAsCollateral(reserve.id) ||
          reserve.configuration.getLtv() == 0 ||
          (stableDebt + variableDebt) > IDepositToken(reserve.depositTokenAddress).collateralBalanceOf(msg.sender),
        Errors.VL_COLLATERAL_SAME_AS_BORROWING_CURRENCY
      );
    } else {
      revert(Errors.VL_INVALID_INTEREST_RATE_MODE_SELECTED);
    }
  }

  function validateRebalanceStableBorrowRate(
    DataTypes.ReserveData storage reserve,
    address reserveAddress,
    IERC20 stableDebtToken,
    address depositTokenAddress
  ) internal view {

    (bool isActive, , , ) = reserve.configuration.getFlags();

    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);

    uint256 usageRatio = stableDebtToken.totalSupply() + IERC20(reserve.variableDebtTokenAddress).totalSupply(); /* totalDebt */
    if (usageRatio != 0) {
      uint256 availableLiquidity = IERC20(reserveAddress).balanceOf(depositTokenAddress);
      usageRatio = usageRatio.wadToRay().wadDiv(
        availableLiquidity +
          usageRatio
      );
    }


    uint256 currentLiquidityRate = reserve.currentLiquidityRate;
    uint256 maxVariableBorrowRate = IReserveRateStrategy(reserve.strategy).getMaxVariableBorrowRate();

    require(
      usageRatio >= REBALANCE_UP_USAGE_RATIO_THRESHOLD &&
        currentLiquidityRate <= maxVariableBorrowRate.percentMul(REBALANCE_UP_LIQUIDITY_RATE_THRESHOLD),
      Errors.LP_INTEREST_RATE_REBALANCE_CONDITIONS_NOT_MET
    );
  }

  function validateSetUseReserveAsCollateral(
    DataTypes.ReserveData storage reserve,
    address reserveAddress,
    bool useAsCollateral,
    mapping(address => DataTypes.ReserveData) storage reservesData,
    DataTypes.UserConfigurationMap storage userConfig,
    mapping(uint256 => address) storage reserves,
    address oracle
  ) internal view {

    uint256 underlyingBalance = IDepositToken(reserve.depositTokenAddress).collateralBalanceOf(msg.sender);

    require(underlyingBalance > 0, Errors.VL_UNDERLYING_BALANCE_NOT_GREATER_THAN_0);

    if (!useAsCollateral) {
      require(!reserve.configuration.isExternalStrategy(), Errors.VL_RESERVE_MUST_BE_COLLATERAL);

      require(
        GenericLogic.balanceDecreaseAllowed(
          reserveAddress,
          msg.sender,
          underlyingBalance,
          reservesData,
          userConfig,
          reserves,
          oracle
        ),
        Errors.VL_DEPOSIT_ALREADY_IN_USE
      );
    } else {
      require(reserve.configuration.getLtv() > 0, Errors.VL_RESERVE_MUST_BE_COLLATERAL);
    }
  }

  function validateFlashloan(address[] memory assets, uint256[] memory amounts) internal pure {

    require(assets.length == amounts.length, Errors.VL_INCONSISTENT_FLASHLOAN_PARAMS);
  }

  function validateLiquidationCall(
    DataTypes.ReserveData storage collateralReserve,
    DataTypes.ReserveData storage principalReserve,
    DataTypes.UserConfigurationMap storage userConfig,
    uint256 userHealthFactor,
    uint256 userStableDebt,
    uint256 userVariableDebt
  ) internal view {

    require(
      collateralReserve.configuration.getActive() && principalReserve.configuration.getActive(),
      Errors.VL_NO_ACTIVE_RESERVE
    );

    require(
      userHealthFactor < GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      Errors.LPCM_HEALTH_FACTOR_NOT_BELOW_THRESHOLD
    );

    require(
      collateralReserve.configuration.getLiquidationThreshold() > 0 &&
        userConfig.isUsingAsCollateral(collateralReserve.id),
      Errors.LPCM_COLLATERAL_CANNOT_BE_LIQUIDATED
    );

    require(userStableDebt != 0 || userVariableDebt != 0, Errors.LPCM_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER);
  }

  function validateTransfer(
    address asset,
    address from,
    mapping(address => DataTypes.ReserveData) storage reservesData,
    DataTypes.UserConfigurationMap storage userConfig,
    mapping(uint256 => address) storage reserves,
    address oracle
  ) internal view {

    if (!userConfig.isBorrowingAny() || !userConfig.isUsingAsCollateral(reservesData[asset].id)) {
      return;
    }

    (, , , , uint256 healthFactor) = GenericLogic.calculateUserAccountData(
      from,
      reservesData,
      userConfig,
      reserves,
      oracle
    );

    require(healthFactor >= GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD, Errors.VL_TRANSFER_NOT_ALLOWED);
  }
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


abstract contract LendingPoolStorage is VersionedInitializable {
  IMarketAccessController internal _addressesProvider;
  address internal _extension;

  mapping(address => DataTypes.ReserveData) internal _reserves;
  mapping(address => DataTypes.UserConfigurationMap) internal _usersConfig;

  mapping(uint256 => address) internal _reservesList;

  uint16 internal _maxStableRateBorrowSizePct;

  uint16 internal _flashLoanPremiumPct;

  uint16 internal constant FEATURE_LIQUIDATION = 1 << 0;
  uint16 internal constant FEATURE_FLASHLOAN = 1 << 1;
  uint16 internal constant FEATURE_FLASHLOAN_DEPOSIT = 1 << 2;
  uint16 internal constant FEATURE_FLASHLOAN_WITHDRAW = 1 << 3;
  uint16 internal constant FEATURE_FLASHLOAN_BORROW = 1 << 4;
  uint16 internal constant FEATURE_FLASHLOAN_REPAY = 1 << 5;
  uint16 internal _disabledFeatures;

  uint8 internal _reservesCount;

  uint8 internal constant _maxNumberOfReserves = 128;

  uint8 internal _flashloanCalls;
  uint8 internal _nestedCalls;

  bool internal _paused;

  mapping(address => address[]) internal _indirectUnderlying;
}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract LendingPoolBase is IEmergencyAccess, LendingPoolStorage {
  using AccessHelper for IMarketAccessController;

  function _whenNotPaused() private view {
    require(!_paused, Errors.LP_IS_PAUSED);
  }

  modifier whenNotPaused() {
    _whenNotPaused();
    _;
  }

  function _onlyLendingPoolConfigurator() private view {
    _addressesProvider.requireAnyOf(
      msg.sender,
      AccessFlags.LENDING_POOL_CONFIGURATOR,
      Errors.LP_CALLER_NOT_LENDING_POOL_CONFIGURATOR
    );
  }

  modifier onlyLendingPoolConfigurator() {
    _onlyLendingPoolConfigurator();
    _;
  }

  function _onlyConfiguratorOrAdmin() private view {
    _addressesProvider.requireAnyOf(
      msg.sender,
      AccessFlags.POOL_ADMIN | AccessFlags.LENDING_POOL_CONFIGURATOR,
      Errors.CALLER_NOT_POOL_ADMIN
    );
  }

  modifier onlyConfiguratorOrAdmin() {
    _onlyConfiguratorOrAdmin();
    _;
  }

  function _notNestedCall() private view {
    require(_nestedCalls == 0, Errors.LP_TOO_MANY_NESTED_CALLS);
  }

  modifier noReentry() {
    _notNestedCall();
    _nestedCalls++;
    _;
    _nestedCalls--;
  }

  function _noReentryOrFlashloan() private view {
    _notNestedCall();
    require(_flashloanCalls == 0, Errors.LP_TOO_MANY_FLASHLOAN_CALLS);
  }

  modifier noReentryOrFlashloan() {
    _noReentryOrFlashloan();
    _nestedCalls++;
    _;
    _nestedCalls--;
  }

  function _noReentryOrFlashloanFeature(uint16 featureFlag) private view {
    _notNestedCall();
    require(featureFlag & _disabledFeatures == 0 || _flashloanCalls == 0, Errors.LP_TOO_MANY_FLASHLOAN_CALLS);
  }

  modifier noReentryOrFlashloanFeature(uint16 featureFlag) {
    _noReentryOrFlashloanFeature(featureFlag);
    _nestedCalls++;
    _;
    _nestedCalls--;
  }

  function _onlyEmergencyAdmin() internal view {
    _addressesProvider.requireAnyOf(msg.sender, AccessFlags.EMERGENCY_ADMIN, Errors.CALLER_NOT_EMERGENCY_ADMIN);
  }

  function setPaused(bool val) external override {
    _onlyEmergencyAdmin();
    _paused = val;
    emit EmergencyPaused(msg.sender, val);
  }

  function isPaused() external view override returns (bool) {
    return _paused;
  }
}// agpl-3.0
pragma solidity ^0.8.4;


contract LendingPoolExtension is LendingPoolBase, ILendingPoolExtension, ILendingPoolEvents, IManagedLendingPool {

  using SafeERC20 for IERC20;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using ReserveLogic for DataTypes.ReserveData;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;
  using AccessHelper for IMarketAccessController;

  uint256 internal constant LIQUIDATION_CLOSE_FACTOR_PERCENT = 5000;

  struct LiquidationCallLocalVars {
    uint256 userCollateralBalance;
    uint256 userStableDebt;
    uint256 userVariableDebt;
    uint256 maxLiquidatableDebt;
    uint256 actualDebtToLiquidate;
    uint256 liquidationRatio;
    uint256 maxAmountCollateralToLiquidate;
    uint256 userStableRate;
    uint256 maxCollateralToLiquidate;
    uint256 debtAmountNeeded;
    uint256 healthFactor;
    IDepositToken collateralDepositToken;
    bool isCollateralEnabled;
    DataTypes.InterestRateMode borrowRateMode;
  }

  function getRevision() internal pure override returns (uint256) {

    revert('IMPOSSIBLE');
  }

  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveDeposit
  ) external override whenNotPaused {

    require(_disabledFeatures & FEATURE_LIQUIDATION == 0, Errors.LP_RESTRICTED_FEATURE);

    DataTypes.ReserveData storage collateralReserve = _reserves[collateralAsset];
    DataTypes.ReserveData storage debtReserve = _reserves[debtAsset];
    DataTypes.UserConfigurationMap storage userConfig = _usersConfig[user];

    LiquidationCallLocalVars memory vars;

    (, , , , vars.healthFactor) = GenericLogic.calculateUserAccountData(
      user,
      _reserves,
      userConfig,
      _reservesList,
      _addressesProvider.getPriceOracle()
    );

    (vars.userStableDebt, vars.userVariableDebt) = Helpers.getUserCurrentDebt(user, debtReserve);

    ValidationLogic.validateLiquidationCall(
      collateralReserve,
      debtReserve,
      userConfig,
      vars.healthFactor,
      vars.userStableDebt,
      vars.userVariableDebt
    );

    vars.collateralDepositToken = IDepositToken(collateralReserve.depositTokenAddress);

    vars.userCollateralBalance = vars.collateralDepositToken.collateralBalanceOf(user);

    vars.maxLiquidatableDebt = (vars.userStableDebt + vars.userVariableDebt).percentMul(
      LIQUIDATION_CLOSE_FACTOR_PERCENT
    );

    vars.actualDebtToLiquidate = debtToCover > vars.maxLiquidatableDebt ? vars.maxLiquidatableDebt : debtToCover;

    (vars.maxCollateralToLiquidate, vars.debtAmountNeeded) = _calculateAvailableCollateralToLiquidate(
      collateralReserve,
      debtReserve,
      collateralAsset,
      debtAsset,
      vars.actualDebtToLiquidate,
      vars.userCollateralBalance
    );


    if (vars.debtAmountNeeded < vars.actualDebtToLiquidate) {
      vars.actualDebtToLiquidate = vars.debtAmountNeeded;
    }

    if (!receiveDeposit) {
      uint256 currentAvailableCollateral = IERC20(collateralAsset).balanceOf(address(vars.collateralDepositToken));
      require(
        currentAvailableCollateral >= vars.maxCollateralToLiquidate,
        Errors.LPCM_NOT_ENOUGH_LIQUIDITY_TO_LIQUIDATE
      );
    }

    debtReserve.updateState(debtAsset);

    if (vars.userVariableDebt >= vars.actualDebtToLiquidate) {
      IVariableDebtToken(debtReserve.variableDebtTokenAddress).burn(
        user,
        vars.actualDebtToLiquidate,
        debtReserve.variableBorrowIndex
      );
    } else {
      if (vars.userVariableDebt > 0) {
        IVariableDebtToken(debtReserve.variableDebtTokenAddress).burn(
          user,
          vars.userVariableDebt,
          debtReserve.variableBorrowIndex
        );
      }
      IStableDebtToken(debtReserve.stableDebtTokenAddress).burn(
        user,
        vars.actualDebtToLiquidate - vars.userVariableDebt
      );
    }

    debtReserve.updateInterestRates(debtAsset, debtReserve.depositTokenAddress, vars.actualDebtToLiquidate, 0);

    if (receiveDeposit) {
      uint256 liquidityIndex = collateralReserve.getNormalizedIncome(collateralAsset);

      if (
        vars.collateralDepositToken.transferOnLiquidation(
          user,
          msg.sender,
          vars.maxCollateralToLiquidate,
          liquidityIndex,
          false
        )
      ) {
        DataTypes.UserConfigurationMap storage liquidatorConfig = _usersConfig[msg.sender];
        liquidatorConfig.setUsingAsCollateral(collateralReserve.id);
        emit ReserveUsedAsCollateralEnabled(collateralAsset, msg.sender);
      }
    } else {
      uint256 liquidityIndex = collateralReserve.updateStateForDeposit(collateralAsset);
      collateralReserve.updateInterestRates(
        collateralAsset,
        address(vars.collateralDepositToken),
        0,
        vars.maxCollateralToLiquidate
      );

      vars.collateralDepositToken.transferOnLiquidation(
        user,
        msg.sender,
        vars.maxCollateralToLiquidate,
        liquidityIndex,
        true
      );
    }

    if (vars.maxCollateralToLiquidate == vars.userCollateralBalance) {
      userConfig.unsetUsingAsCollateral(collateralReserve.id);
      emit ReserveUsedAsCollateralDisabled(collateralAsset, user);
    }

    IERC20(debtAsset).safeTransferFrom(msg.sender, debtReserve.depositTokenAddress, vars.actualDebtToLiquidate);

    emit LiquidationCall(
      collateralAsset,
      debtAsset,
      user,
      vars.actualDebtToLiquidate,
      vars.maxCollateralToLiquidate,
      msg.sender,
      receiveDeposit
    );
  }

  struct AvailableCollateralToLiquidateLocalVars {
    uint256 userCompoundedBorrowBalance;
    uint256 liquidationBonus;
    uint256 collateralPrice;
    uint256 debtAssetPrice;
    uint256 maxAmountCollateralToLiquidate;
    uint256 debtAssetDecimals;
    uint256 collateralDecimals;
  }

  function _calculateAvailableCollateralToLiquidate(
    DataTypes.ReserveData storage collateralReserve,
    DataTypes.ReserveData storage debtReserve,
    address collateralAsset,
    address debtAsset,
    uint256 debtToCover,
    uint256 userCollateralBalance
  ) private view returns (uint256, uint256) {

    uint256 collateralAmount = 0;
    uint256 debtAmountNeeded = 0;
    IPriceOracleGetter oracle = IPriceOracleGetter(_addressesProvider.getPriceOracle());

    AvailableCollateralToLiquidateLocalVars memory vars;

    vars.collateralPrice = oracle.getAssetPrice(collateralAsset);
    vars.debtAssetPrice = oracle.getAssetPrice(debtAsset);

    (, , vars.liquidationBonus, vars.collateralDecimals, ) = collateralReserve.configuration.getParams();
    vars.debtAssetDecimals = debtReserve.configuration.getDecimals();

    vars.maxAmountCollateralToLiquidate =
      (vars.debtAssetPrice * debtToCover * (10**vars.collateralDecimals)).percentMul(vars.liquidationBonus) /
      (vars.collateralPrice * (10**vars.debtAssetDecimals));

    if (vars.maxAmountCollateralToLiquidate > userCollateralBalance) {
      collateralAmount = userCollateralBalance;
      debtAmountNeeded = ((vars.collateralPrice * collateralAmount * (10**vars.debtAssetDecimals)) /
        (vars.debtAssetPrice * (10**vars.collateralDecimals))).percentDiv(vars.liquidationBonus);
    } else {
      collateralAmount = vars.maxAmountCollateralToLiquidate;
      debtAmountNeeded = debtToCover;
    }
    return (collateralAmount, debtAmountNeeded);
  }

  function _checkUntrustedFlashloan() private view {

    require(_disabledFeatures & FEATURE_FLASHLOAN == 0, Errors.LP_RESTRICTED_FEATURE);
    require(_flashloanCalls == 0, Errors.LP_TOO_MANY_FLASHLOAN_CALLS);
    require(_nestedCalls == 0, Errors.LP_TOO_MANY_NESTED_CALLS);
  }

  function flashLoan(
    address receiver,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint256 referral
  ) external override whenNotPaused {

    _checkUntrustedFlashloan();
    _flashLoan(receiver, assets, amounts, modes, onBehalfOf, params, referral, _flashLoanPremiumPct);
  }

  function flashLoan(
    address receiver,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referral
  ) external override whenNotPaused {

    _checkUntrustedFlashloan();
    _flashLoan(receiver, assets, amounts, modes, onBehalfOf, params, referral, _flashLoanPremiumPct);
  }

  function trustedFlashLoan(
    address receiver,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint256 referral
  ) external override {

    _addressesProvider.requireAnyOf(
      msg.sender,
      AccessFlags.TRUSTED_FLASHLOAN | AccessFlags.LIQUIDITY_CONTROLLER,
      Errors.LP_IS_NOT_TRUSTED_FLASHLOAN
    );
    require(_flashloanCalls < type(uint8).max, Errors.LP_TOO_MANY_FLASHLOAN_CALLS);

    _flashLoan(receiver, assets, amounts, modes, onBehalfOf, params, referral, 0);
  }

  struct FlashLoanLocalVars {
    IFlashLoanReceiver receiver;
    address currentAsset;
    address currentDepositToken;
    uint256 currentAmount;
    uint256 currentPremium;
    uint256 currentAmountPlusPremium;
    uint256[] premiums;
    uint256 referral;
    address onBehalfOf;
    uint16 premium;
    uint8 i;
  }

  function _flashLoan(
    address receiver,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint256 referral,
    uint16 flPremium
  ) private {

    require(Address.isContract(receiver), Errors.VL_CONTRACT_REQUIRED);
    _flashloanCalls++;
    {
      FlashLoanLocalVars memory vars;
      ValidationLogic.validateFlashloan(assets, amounts);

      (vars.receiver, vars.referral, vars.onBehalfOf, vars.premium) = (
        IFlashLoanReceiver(receiver),
        referral,
        onBehalfOf,
        flPremium
      );

      vars.premiums = _flashLoanPre(address(vars.receiver), assets, amounts, vars.premium);

      require(
        vars.receiver.executeOperation(assets, amounts, vars.premiums, msg.sender, params),
        Errors.LP_INVALID_FLASH_LOAN_EXECUTOR_RETURN
      );

      _flashLoanPost(vars, assets, amounts, modes, vars.premiums);
    }
    _flashloanCalls--;
  }

  function _flashLoanPre(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint16 flashLoanPremium
  ) private returns (uint256[] memory premiums) {

    premiums = new uint256[](assets.length);

    for (uint256 i = 0; i < assets.length; i++) {
      premiums[i] = amounts[i].percentMul(flashLoanPremium);
      IDepositToken(_reserves[assets[i]].depositTokenAddress).transferUnderlyingTo(receiverAddress, amounts[i]);
    }

    return premiums;
  }

  function _flashLoanPost(
    FlashLoanLocalVars memory vars,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    uint256[] memory premiums
  ) private {

    for (vars.i = 0; vars.i < assets.length; vars.i++) {
      vars.currentAsset = assets[vars.i];
      vars.currentAmount = amounts[vars.i];
      vars.currentPremium = premiums[vars.i];
      vars.currentDepositToken = _reserves[vars.currentAsset].depositTokenAddress;
      vars.currentAmountPlusPremium = vars.currentAmount + vars.currentPremium;

      if (DataTypes.InterestRateMode(modes[vars.i]) == DataTypes.InterestRateMode.NONE) {
        _flashLoanRetrieve(vars);
      } else {
        _executeBorrow(
          ExecuteBorrowParams(
            vars.currentAsset,
            msg.sender,
            vars.onBehalfOf,
            vars.currentAmount,
            modes[vars.i],
            vars.currentDepositToken,
            vars.referral,
            false
          )
        );
      }
      emit FlashLoan(
        address(vars.receiver),
        msg.sender,
        vars.currentAsset,
        vars.currentAmount,
        vars.currentPremium,
        vars.referral
      );
    }
  }

  function _flashLoanRetrieve(FlashLoanLocalVars memory vars) private {

    _reserves[vars.currentAsset].updateState(vars.currentAsset);
    _reserves[vars.currentAsset].cumulateToLiquidityIndex(
      IERC20(vars.currentDepositToken).totalSupply(),
      vars.currentPremium
    );
    _reserves[vars.currentAsset].updateInterestRates(
      vars.currentAsset,
      vars.currentDepositToken,
      vars.currentAmountPlusPremium,
      0
    );

    IERC20(vars.currentAsset).safeTransferFrom(
      address(vars.receiver),
      vars.currentDepositToken,
      vars.currentAmountPlusPremium
    );
  }

  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint256 referral,
    address onBehalfOf
  ) external override whenNotPaused noReentryOrFlashloanFeature(FEATURE_FLASHLOAN_BORROW) {

    _executeBorrow(
      ExecuteBorrowParams(
        asset,
        msg.sender,
        onBehalfOf,
        amount,
        interestRateMode,
        _reserves[asset].depositTokenAddress,
        referral,
        true
      )
    );
  }

  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referral,
    address onBehalfOf
  ) external override whenNotPaused noReentryOrFlashloanFeature(FEATURE_FLASHLOAN_BORROW) {

    _executeBorrow(
      ExecuteBorrowParams(
        asset,
        msg.sender,
        onBehalfOf,
        amount,
        interestRateMode,
        _reserves[asset].depositTokenAddress,
        referral,
        true
      )
    );
  }

  struct ExecuteBorrowParams {
    address asset;
    address user;
    address onBehalfOf;
    uint256 amount;
    uint256 interestRateMode;
    address depositToken;
    uint256 referral;
    bool releaseUnderlying;
  }

  struct ExecuteBorrowVars {
    address oracle;
    uint256 amountInETH;
  }

  function _executeBorrow(ExecuteBorrowParams memory vars) private {

    DataTypes.ReserveData storage reserve = _reserves[vars.asset];
    DataTypes.UserConfigurationMap storage userConfig = _usersConfig[vars.onBehalfOf];

    ExecuteBorrowVars memory v;

    v.oracle = _addressesProvider.getPriceOracle();
    v.amountInETH =
      (IPriceOracleGetter(v.oracle).getAssetPrice(vars.asset) * vars.amount) /
      (10**reserve.configuration.getDecimals());

    ValidationLogic.validateBorrow(
      vars.asset,
      reserve,
      vars.onBehalfOf,
      vars.amount,
      v.amountInETH,
      vars.interestRateMode,
      _maxStableRateBorrowSizePct,
      _reserves,
      userConfig,
      _reservesList,
      v.oracle
    );

    reserve.updateState(vars.asset);

    uint256 currentStableRate = 0;

    bool isFirstBorrowing = false;
    if (DataTypes.InterestRateMode(vars.interestRateMode) == DataTypes.InterestRateMode.STABLE) {
      currentStableRate = reserve.currentStableBorrowRate;

      isFirstBorrowing = IStableDebtToken(reserve.stableDebtTokenAddress).mint(
        vars.user,
        vars.onBehalfOf,
        vars.amount,
        currentStableRate
      );
    } else {
      isFirstBorrowing = IVariableDebtToken(reserve.variableDebtTokenAddress).mint(
        vars.user,
        vars.onBehalfOf,
        vars.amount,
        reserve.variableBorrowIndex
      );
    }

    if (isFirstBorrowing) {
      userConfig.setBorrowing(reserve.id);
    }

    reserve.updateInterestRates(vars.asset, vars.depositToken, 0, vars.releaseUnderlying ? vars.amount : 0);
    if (vars.releaseUnderlying) {
      IDepositToken(vars.depositToken).transferUnderlyingTo(vars.user, vars.amount);
    }

    emit Borrow(
      vars.asset,
      vars.user,
      vars.onBehalfOf,
      vars.amount,
      vars.interestRateMode,
      DataTypes.InterestRateMode(vars.interestRateMode) == DataTypes.InterestRateMode.STABLE
        ? currentStableRate
        : reserve.currentVariableBorrowRate,
      vars.referral
    );
  }

  function setReserveStrategy(
    address asset,
    address strategy,
    bool isExternal
  ) external override onlyLendingPoolConfigurator {

    _checkReserve(asset);
    require(isExternal = IReserveStrategy(strategy).isDelegatedReserve());
    if (_reserves[asset].strategy != address(0)) {
      require(isExternal == _reserves[asset].configuration.isExternalStrategy());
    } else {
      DataTypes.ReserveConfigurationMap memory cfg = _reserves[asset].configuration;
      cfg.setExternalStrategy(isExternal);
      _reserves[asset].configuration = cfg;
    }
    _reserves[asset].strategy = strategy;
  }

  function _checkReserve(address asset) private view {

    require(_reserves[asset].depositTokenAddress != address(0), Errors.VL_UNKNOWN_RESERVE);
  }

  function setConfiguration(address asset, uint256 configuration) external override onlyLendingPoolConfigurator {

    _checkReserve(asset);
    _reserves[asset].configuration.data = configuration;
  }

  function setFlashLoanPremium(uint16 premium) external onlyConfiguratorOrAdmin {

    require(premium <= PercentageMath.ONE && premium > 0, Errors.LP_INVALID_PERCENTAGE);
    _flashLoanPremiumPct = premium;
    emit FlashLoanPremiumUpdated(premium);
  }

  function _addReserveToList(address asset) internal {

    uint256 reservesCount = _reservesCount;
    require(reservesCount < _maxNumberOfReserves, Errors.LP_NO_MORE_RESERVES_ALLOWED);

    bool reserveAlreadyAdded = _reserves[asset].id != 0 || _reservesList[0] == asset;

    if (!reserveAlreadyAdded) {
      _reserves[asset].id = uint8(reservesCount);
      _reservesList[reservesCount] = asset;

      _reservesCount = uint8(reservesCount) + 1;
    }
  }

  function setDisabledFeatures(uint16 disabledFeatures) external override onlyConfiguratorOrAdmin {

    _disabledFeatures = disabledFeatures;
    emit DisabledFeaturesUpdated(disabledFeatures);
  }

  function getDisabledFeatures() external view override returns (uint16 disabledFeatures) {

    return _disabledFeatures;
  }

  function initReserve(DataTypes.InitReserveData calldata data) external override onlyLendingPoolConfigurator {

    require(Address.isContract(data.asset), Errors.VL_CONTRACT_REQUIRED);
    _reserves[data.asset].init(data);
    _addReserveToList(data.asset);

    if (data.externalStrategy) {
      address underlying = IReserveDelegatedStrategy(data.strategy).getUnderlying(data.asset);
      require(underlying != address(0));
      if (underlying != data.asset) {
        _indirectUnderlying[underlying].push(data.asset);
      }
    }
  }

  function getLendingPoolExtension() external view override returns (address) {

    return _extension;
  }

  function setLendingPoolExtension(address extension) external override onlyConfiguratorOrAdmin {

    require(Address.isContract(extension), Errors.VL_CONTRACT_REQUIRED);
    _extension = extension;
    emit LendingPoolExtensionUpdated(extension);
  }
}