pragma solidity 0.6.12;

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
pragma solidity 0.6.12;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    return mod(a, b, 'SafeMath: modulo by zero');
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b != 0, errorMessage);
    return a % b;
  }
}// agpl-3.0
pragma solidity 0.6.12;

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

pragma solidity 0.6.12;


library SafeERC20 {

  using SafeMath for uint256;
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
pragma solidity 0.6.12;

interface ILendingPoolAddressesProvider {

  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);


  function setMarketId(string calldata marketId) external;


  function setAddress(bytes32 id, address newAddress) external;


  function setAddressAsProxy(bytes32 id, address impl) external;


  function getAddress(bytes32 id) external view returns (address);


  function getLendingPool() external view returns (address);


  function setLendingPoolImpl(address pool) external;


  function getLendingPoolConfigurator() external view returns (address);


  function setLendingPoolConfiguratorImpl(address configurator) external;


  function getLendingPoolCollateralManager() external view returns (address);


  function setLendingPoolCollateralManager(address manager) external;


  function getPoolAdmin() external view returns (address);


  function setPoolAdmin(address admin) external;


  function getEmergencyAdmin() external view returns (address);


  function setEmergencyAdmin(address admin) external;


  function getPriceOracle() external view returns (address);


  function setPriceOracle(address priceOracle) external;


  function getLendingRateOracle() external view returns (address);


  function setLendingRateOracle(address lendingRateOracle) external;

}// agpl-3.0
pragma solidity 0.6.12;

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
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}// agpl-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


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


  function withdraw(
    address asset,
    uint256 amount,
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


  function swapBorrowRateMode(address asset, uint256 rateMode) external;


  function rebalanceStableBorrowRate(address asset, address user) external;


  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;


  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;


  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
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
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;


  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;


  function setConfiguration(address reserve, uint256 configuration) external;


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


  function setPause(bool val) external;


  function paused() external view returns (bool);

}// agpl-3.0
pragma solidity 0.6.12;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);

}// agpl-3.0
pragma solidity 0.6.12;


interface IAToken is IERC20, IScaledBalanceToken {

  event Mint(address indexed from, uint256 value, uint256 index);

  function mint(
    address user,
    uint256 amount,
    uint256 index
  ) external returns (bool);


  event Burn(address indexed from, address indexed target, uint256 value, uint256 index);

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
    uint256 value
  ) external;


  function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);

}// agpl-3.0
pragma solidity 0.6.12;

library Errors {

  string public constant CALLER_NOT_POOL_ADMIN = '33'; // 'The caller must be the pool admin'
  string public constant BORROW_ALLOWANCE_NOT_ENOUGH = '59'; // User borrows on behalf, but allowance are too small

  string public constant VL_INVALID_AMOUNT = '1'; // 'Amount must be greater than 0'
  string public constant VL_NO_ACTIVE_RESERVE = '2'; // 'Action requires an active reserve'
  string public constant VL_RESERVE_FROZEN = '3'; // 'Action cannot be performed because the reserve is frozen'
  string public constant VL_CURRENT_AVAILABLE_LIQUIDITY_NOT_ENOUGH = '4'; // 'The current liquidity is not enough'
  string public constant VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE = '5'; // 'User cannot withdraw more than the available balance'
  string public constant VL_TRANSFER_NOT_ALLOWED = '6'; // 'Transfer cannot be allowed.'
  string public constant VL_BORROWING_NOT_ENABLED = '7'; // 'Borrowing is not enabled'
  string public constant VL_INVALID_INTEREST_RATE_MODE_SELECTED = '8'; // 'Invalid interest rate mode selected'
  string public constant VL_COLLATERAL_BALANCE_IS_0 = '9'; // 'The collateral balance is 0'
  string public constant VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD = '10'; // 'Health factor is lesser than the liquidation threshold'
  string public constant VL_COLLATERAL_CANNOT_COVER_NEW_BORROW = '11'; // 'There is not enough collateral to cover a new borrow'
  string public constant VL_STABLE_BORROWING_NOT_ENABLED = '12'; // stable borrowing not enabled
  string public constant VL_COLLATERAL_SAME_AS_BORROWING_CURRENCY = '13'; // collateral is (mostly) the same currency that is being borrowed
  string public constant VL_AMOUNT_BIGGER_THAN_MAX_LOAN_SIZE_STABLE = '14'; // 'The requested amount is greater than the max loan size in stable rate mode
  string public constant VL_NO_DEBT_OF_SELECTED_TYPE = '15'; // 'for repayment of stable debt, the user needs to have stable debt, otherwise, he needs to have variable debt'
  string public constant VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF = '16'; // 'To repay on behalf of an user an explicit amount to repay is needed'
  string public constant VL_NO_STABLE_RATE_LOAN_IN_RESERVE = '17'; // 'User does not have a stable rate loan in progress on this reserve'
  string public constant VL_NO_VARIABLE_RATE_LOAN_IN_RESERVE = '18'; // 'User does not have a variable rate loan in progress on this reserve'
  string public constant VL_UNDERLYING_BALANCE_NOT_GREATER_THAN_0 = '19'; // 'The underlying balance needs to be greater than 0'
  string public constant VL_DEPOSIT_ALREADY_IN_USE = '20'; // 'User deposit is already being used as collateral'
  string public constant LP_NOT_ENOUGH_STABLE_BORROW_BALANCE = '21'; // 'User does not have any stable rate loan for this reserve'
  string public constant LP_INTEREST_RATE_REBALANCE_CONDITIONS_NOT_MET = '22'; // 'Interest rate rebalance conditions were not met'
  string public constant LP_LIQUIDATION_CALL_FAILED = '23'; // 'Liquidation call failed'
  string public constant LP_NOT_ENOUGH_LIQUIDITY_TO_BORROW = '24'; // 'There is not enough liquidity available to borrow'
  string public constant LP_REQUESTED_AMOUNT_TOO_SMALL = '25'; // 'The requested amount is too small for a FlashLoan.'
  string public constant LP_INCONSISTENT_PROTOCOL_ACTUAL_BALANCE = '26'; // 'The actual balance of the protocol is inconsistent'
  string public constant LP_CALLER_NOT_LENDING_POOL_CONFIGURATOR = '27'; // 'The caller of the function is not the lending pool configurator'
  string public constant LP_INCONSISTENT_FLASHLOAN_PARAMS = '28';
  string public constant CT_CALLER_MUST_BE_LENDING_POOL = '29'; // 'The caller of this function must be a lending pool'
  string public constant CT_CANNOT_GIVE_ALLOWANCE_TO_HIMSELF = '30'; // 'User cannot give allowance to himself'
  string public constant CT_TRANSFER_AMOUNT_NOT_GT_0 = '31'; // 'Transferred amount needs to be greater than zero'
  string public constant RL_RESERVE_ALREADY_INITIALIZED = '32'; // 'Reserve has already been initialized'
  string public constant LPC_RESERVE_LIQUIDITY_NOT_0 = '34'; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_ATOKEN_POOL_ADDRESS = '35'; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_STABLE_DEBT_TOKEN_POOL_ADDRESS = '36'; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_VARIABLE_DEBT_TOKEN_POOL_ADDRESS = '37'; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_STABLE_DEBT_TOKEN_UNDERLYING_ADDRESS = '38'; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_VARIABLE_DEBT_TOKEN_UNDERLYING_ADDRESS = '39'; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_ADDRESSES_PROVIDER_ID = '40'; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_CONFIGURATION = '75'; // 'Invalid risk parameters for the reserve'
  string public constant LPC_CALLER_NOT_EMERGENCY_ADMIN = '76'; // 'The caller must be the emergency admin'
  string public constant LPAPR_PROVIDER_NOT_REGISTERED = '41'; // 'Provider is not registered'
  string public constant LPCM_HEALTH_FACTOR_NOT_BELOW_THRESHOLD = '42'; // 'Health factor is not below the threshold'
  string public constant LPCM_COLLATERAL_CANNOT_BE_LIQUIDATED = '43'; // 'The collateral chosen cannot be liquidated'
  string public constant LPCM_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER = '44'; // 'User did not borrow the specified currency'
  string public constant LPCM_NOT_ENOUGH_LIQUIDITY_TO_LIQUIDATE = '45'; // "There isn't enough liquidity available to liquidate"
  string public constant LPCM_NO_ERRORS = '46'; // 'No errors'
  string public constant LP_INVALID_FLASHLOAN_MODE = '47'; //Invalid flashloan mode selected
  string public constant MATH_MULTIPLICATION_OVERFLOW = '48';
  string public constant MATH_ADDITION_OVERFLOW = '49';
  string public constant MATH_DIVISION_BY_ZERO = '50';
  string public constant RL_LIQUIDITY_INDEX_OVERFLOW = '51'; //  Liquidity index overflows uint128
  string public constant RL_VARIABLE_BORROW_INDEX_OVERFLOW = '52'; //  Variable borrow index overflows uint128
  string public constant RL_LIQUIDITY_RATE_OVERFLOW = '53'; //  Liquidity rate overflows uint128
  string public constant RL_VARIABLE_BORROW_RATE_OVERFLOW = '54'; //  Variable borrow rate overflows uint128
  string public constant RL_STABLE_BORROW_RATE_OVERFLOW = '55'; //  Stable borrow rate overflows uint128
  string public constant CT_INVALID_MINT_AMOUNT = '56'; //invalid amount to mint
  string public constant LP_FAILED_REPAY_WITH_COLLATERAL = '57';
  string public constant CT_INVALID_BURN_AMOUNT = '58'; //invalid amount to burn
  string public constant LP_FAILED_COLLATERAL_SWAP = '60';
  string public constant LP_INVALID_EQUAL_ASSETS_TO_SWAP = '61';
  string public constant LP_REENTRANCY_NOT_ALLOWED = '62';
  string public constant LP_CALLER_MUST_BE_AN_ATOKEN = '63';
  string public constant LP_IS_PAUSED = '64'; // 'Pool is paused'
  string public constant LP_NO_MORE_RESERVES_ALLOWED = '65';
  string public constant LP_INVALID_FLASH_LOAN_EXECUTOR_RETURN = '66';
  string public constant RC_INVALID_LTV = '67';
  string public constant RC_INVALID_LIQ_THRESHOLD = '68';
  string public constant RC_INVALID_LIQ_BONUS = '69';
  string public constant RC_INVALID_DECIMALS = '70';
  string public constant RC_INVALID_RESERVE_FACTOR = '71';
  string public constant LPAPR_INVALID_ADDRESSES_PROVIDER_ID = '72';
  string public constant VL_INCONSISTENT_FLASHLOAN_PARAMS = '73';
  string public constant LP_INCONSISTENT_PARAMS_LENGTH = '74';
  string public constant UL_INVALID_INDEX = '77';
  string public constant LP_NOT_CONTRACT = '78';
  string public constant SDT_STABLE_DEBT_OVERFLOW = '79';
  string public constant SDT_BURN_EXCEEDS_BALANCE = '80';

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
pragma solidity 0.6.12;



library WadRayMath {

  uint256 internal constant WAY = 1e9;
  uint256 internal constant halfWAY = WAY / 2;

  uint256 internal constant WAD = 1e18;
  uint256 internal constant halfWAD = WAD / 2;

  uint256 internal constant RAY = 1e27;
  uint256 internal constant halfRAY = RAY / 2;

  uint256 internal constant WAD_RAY_RATIO = 1e9;

  uint256 internal constant WAY_WAD_RATIO = 1e9;

  uint256 internal constant WAY_RAY_RATIO = 1e18;

  function ray() internal pure returns (uint256) {

    return RAY;
  }


  function wad() internal pure returns (uint256) {

    return WAD;
  }


  function way() internal pure returns (uint256) {

    return WAD;
  }

  function halfRay() internal pure returns (uint256) {

    return halfRAY;
  }

  function halfWad() internal pure returns (uint256) {

    return halfWAD;
  }

  function halfWay() internal pure returns (uint256) {

    return halfWAY;
  }

  function wayMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }

    require(a <= (type(uint256).max - halfWAY) / b, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (a * b + halfWAY) / WAY;
  }

  function wayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, Errors.MATH_DIVISION_BY_ZERO);
    uint256 halfB = b / 2;

    require(a <= (type(uint256).max - halfB) / WAY, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (a * WAY + halfB) / b;
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

  function rayToWay(uint256 a) internal pure returns (uint256) {

    uint256 halfRatio = WAY_RAY_RATIO / 2;
    uint256 result = halfRatio + a;
    require(result >= halfRatio, Errors.MATH_ADDITION_OVERFLOW);

    return result / WAY_RAY_RATIO;
  }

  function wayToRay(uint256 a) internal pure returns (uint256) {

    uint256 result = a * WAY_RAY_RATIO;
    require(result / WAY_RAY_RATIO == a, Errors.MATH_MULTIPLICATION_OVERFLOW);
    return result;
  }

  function wadToWay(uint256 a) internal pure returns (uint256) {

    uint256 halfRatio = WAY_WAD_RATIO / 2;
    uint256 result = halfRatio + a;
    require(result >= halfRatio, Errors.MATH_ADDITION_OVERFLOW);

    return result / WAY_WAD_RATIO;
  }

  function wayToWad(uint256 a) internal pure returns (uint256) {

    uint256 result = a * WAY_WAD_RATIO;
    require(result / WAY_WAD_RATIO == a, Errors.MATH_MULTIPLICATION_OVERFLOW);
    return result;
  }

}// agpl-3.0
pragma solidity 0.6.12;

abstract contract VersionedInitializable {
  uint256 private lastInitializedRevision = 0;

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
}// MIT
pragma solidity 0.6.12;

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}// agpl-3.0
pragma solidity 0.6.12;


interface IERC20Detailed is IERC20 {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);

}// agpl-3.0
pragma solidity 0.6.12;

interface IAaveIncentivesController {

  function handleAction(
    address user,
    uint256 userBalance,
    uint256 totalSupply
  ) external;

}// agpl-3.0
pragma solidity 0.6.12;


contract IncentivizedERC20 is Context, IERC20, IERC20Detailed {

  using SafeMath for uint256;

  IAaveIncentivesController internal immutable _incentivesController;

  mapping(address => uint256) internal _balances;

  mapping(address => mapping(address => uint256)) private _allowances;
  uint256 internal _totalSupply;
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(
    string memory name,
    string memory symbol,
    uint8 decimals,
    address incentivesController
  ) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
    _incentivesController = IAaveIncentivesController(incentivesController);
  }

  function name() public view override returns (string memory) {

    return _name;
  }

  function symbol() public view override returns (string memory) {

    return _symbol;
  }

  function decimals() public view override returns (uint8) {

    return _decimals;
  }

  function totalSupply() public view virtual override returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {

    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

    _transfer(_msgSender(), recipient, amount);
    emit Transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {

    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {

    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {

    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(amount, 'ERC20: transfer amount exceeds allowance')
    );
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {

    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(
        subtractedValue,
        'ERC20: decreased allowance below zero'
      )
    );
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {

    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');

    _beforeTokenTransfer(sender, recipient, amount);

    uint256 oldSenderBalance = _balances[sender];
    _balances[sender] = oldSenderBalance.sub(amount, 'ERC20: transfer amount exceeds balance');
    uint256 oldRecipientBalance = _balances[recipient];
    _balances[recipient] = _balances[recipient].add(amount);

    if (address(_incentivesController) != address(0)) {
      uint256 currentTotalSupply = _totalSupply;
      _incentivesController.handleAction(sender, currentTotalSupply, oldSenderBalance);
      if (sender != recipient) {
        _incentivesController.handleAction(recipient, currentTotalSupply, oldRecipientBalance);
      }
    }
  }

  function _mint(address account, uint256 amount) internal virtual {

    require(account != address(0), 'ERC20: mint to the zero address');

    _beforeTokenTransfer(address(0), account, amount);

    uint256 oldTotalSupply = _totalSupply;
    _totalSupply = oldTotalSupply.add(amount);

    uint256 oldAccountBalance = _balances[account];
    _balances[account] = oldAccountBalance.add(amount);

    if (address(_incentivesController) != address(0)) {
      _incentivesController.handleAction(account, oldTotalSupply, oldAccountBalance);
    }
  }

  function _burn(address account, uint256 amount) internal virtual {

    require(account != address(0), 'ERC20: burn from the zero address');

    _beforeTokenTransfer(account, address(0), amount);

    uint256 oldTotalSupply = _totalSupply;
    _totalSupply = oldTotalSupply.sub(amount);

    uint256 oldAccountBalance = _balances[account];
    _balances[account] = oldAccountBalance.sub(amount, 'ERC20: burn amount exceeds balance');

    if (address(_incentivesController) != address(0)) {
      _incentivesController.handleAction(account, oldTotalSupply, oldAccountBalance);
    }
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {

    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _setName(string memory newName) internal {

    _name = newName;
  }

  function _setSymbol(string memory newSymbol) internal {

    _symbol = newSymbol;
  }

  function _setDecimals(uint8 newDecimals) internal {

    _decimals = newDecimals;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

}// MIT
pragma solidity 0.6.12;

library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}// agpl-3.0
pragma solidity 0.6.12;

library UInt256Lib {
    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    function toInt256Safe(uint256 a) internal pure returns (int256) {
        require(a <= MAX_INT256);
        return int256(a);
    }
}// agpl-3.0
pragma solidity 0.6.12;


interface IAMPLDebtToken {
  function getAMPLBorrowData() external view returns (uint256, int256);
}

contract AAmplToken is VersionedInitializable, IncentivizedERC20, IAToken {
  using WadRayMath for uint256;
  using SafeERC20 for IERC20;
  using UInt256Lib for uint256;
  using SignedSafeMath for int256;

  bytes public constant EIP712_REVISION = bytes('1');
  bytes32 internal constant EIP712_DOMAIN =
    keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)');
  bytes32 public constant PERMIT_TYPEHASH =
    keccak256('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)');

  uint256 public constant ATOKEN_REVISION = 0x1;
  address public immutable UNDERLYING_ASSET_ADDRESS;
  address public immutable RESERVE_TREASURY_ADDRESS;
  ILendingPool public immutable POOL;

  mapping(address => uint256) public _nonces;

  bytes32 public DOMAIN_SEPARATOR;

  address public STABLE_DEBT_TOKEN_ADDRESS;
  address public VARIABLE_DEBT_TOKEN_ADDRESS;

  uint256 private constant GONS_TOTAL_SUPPLY = uint256(type(int128).max);

  int256 private _totalGonsDeposited;

  struct ExtData {
    uint256 totalAMPLSupply;
    uint256 totalPrincipalBorrowed;
    int256 totalGonsBorrowed;
  }

  modifier onlyLendingPool {
    require(_msgSender() == address(POOL), Errors.CT_CALLER_MUST_BE_LENDING_POOL);
    _;
  }

  constructor(
    ILendingPool pool,
    address underlyingAssetAddress,
    address reserveTreasuryAddress,
    string memory tokenName,
    string memory tokenSymbol,
    address incentivesController
  ) public IncentivizedERC20(tokenName, tokenSymbol, 18, incentivesController) {
    POOL = pool;
    UNDERLYING_ASSET_ADDRESS = underlyingAssetAddress;
    RESERVE_TREASURY_ADDRESS = reserveTreasuryAddress;
  }

  function getRevision() internal pure virtual override returns (uint256) {
    return ATOKEN_REVISION;
  }

  function initialize(
    uint8 underlyingAssetDecimals,
    string calldata tokenName,
    string calldata tokenSymbol
  ) external virtual initializer {
    uint256 chainId;

    assembly {
      chainId := chainid()
    }

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        EIP712_DOMAIN,
        keccak256(bytes(tokenName)),
        keccak256(EIP712_REVISION),
        chainId,
        address(this)
      )
    );

    _setName(tokenName);
    _setSymbol(tokenSymbol);
    _setDecimals(underlyingAssetDecimals);
  }

  function initializeDebtTokens () external {
    require(STABLE_DEBT_TOKEN_ADDRESS == address(0) && VARIABLE_DEBT_TOKEN_ADDRESS == address(0));

    DataTypes.ReserveData memory reserveData = ILendingPool(POOL).getReserveData(UNDERLYING_ASSET_ADDRESS);
    STABLE_DEBT_TOKEN_ADDRESS = reserveData.stableDebtTokenAddress;
    VARIABLE_DEBT_TOKEN_ADDRESS = reserveData.variableDebtTokenAddress;
  }

  function burn(
    address user,
    address receiverOfUnderlying,
    uint256 amount,
    uint256 index
  ) external override onlyLendingPool {
    uint256 amountScaled = amount.rayDiv(index);
    require(amountScaled != 0, Errors.CT_INVALID_BURN_AMOUNT);

    ExtData memory e = _fetchExtData();
    _burnScaled(user, amountScaled, e);
    _totalGonsDeposited = _totalGonsDeposited.sub(
      _amplToGons(e.totalAMPLSupply, amountScaled).toInt256Safe()
    );

    IERC20(UNDERLYING_ASSET_ADDRESS).safeTransfer(receiverOfUnderlying, amount);

    emit Transfer(user, address(0), amount);
    emit Burn(user, receiverOfUnderlying, amount, index);
  }

  function mint(
    address user,
    uint256 amount,
    uint256 index
  ) external override onlyLendingPool returns (bool) {
    uint256 previousBalanceInternal = super.balanceOf(user);

    uint256 amountScaled = amount.rayDiv(index);
    require(amountScaled != 0, Errors.CT_INVALID_MINT_AMOUNT);

    ExtData memory e = _fetchExtData();
    _mintScaled(user, amountScaled, e);
    _totalGonsDeposited = _totalGonsDeposited.add(
      _amplToGons(e.totalAMPLSupply, amountScaled).toInt256Safe()
    );

    emit Transfer(address(0), user, amount);
    emit Mint(user, amount, index);

    return previousBalanceInternal == 0;
  }

  function mintToTreasury(uint256 amount, uint256 index) external override onlyLendingPool {
    if (amount == 0) {
      return;
    }

    uint256 amountScaled = amount.rayDiv(index);

    ExtData memory e = _fetchExtData();
    _mintScaled(RESERVE_TREASURY_ADDRESS, amountScaled, e);
    _totalGonsDeposited = _totalGonsDeposited.add(
      _amplToGons(e.totalAMPLSupply, amountScaled).toInt256Safe()
    );

    emit Transfer(address(0), RESERVE_TREASURY_ADDRESS, amount);
    emit Mint(RESERVE_TREASURY_ADDRESS, amount, index);
  }

  function transferOnLiquidation(
    address from,
    address to,
    uint256 value
  ) external override onlyLendingPool {
    _transfer(from, to, value, false);

    emit Transfer(from, to, value);
  }

  function transferUnderlyingTo(address target, uint256 amount)
    external
    override
    onlyLendingPool
    returns (uint256)
  {
    IERC20(UNDERLYING_ASSET_ADDRESS).safeTransfer(target, amount);
    return amount;
  }

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {
    require(owner != address(0), 'INVALID_OWNER');
    require(block.timestamp <= deadline, 'INVALID_EXPIRATION');
    uint256 currentValidNonce = _nonces[owner];
    bytes32 digest =
      keccak256(
        abi.encodePacked(
          '\x19\x01',
          DOMAIN_SEPARATOR,
          keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, currentValidNonce, deadline))
        )
      );
    require(owner == ecrecover(digest, v, r, s), 'INVALID_SIGNATURE');
    _nonces[owner] = currentValidNonce.add(1);
    _approve(owner, spender, value);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount,
    bool validate
  ) internal {
    uint256 index = POOL.getReserveNormalizedIncome(UNDERLYING_ASSET_ADDRESS);
    uint256 amountScaled = amount.rayDiv(index);

    ExtData memory e = _fetchExtData();
    uint256 totalSupplyInternal = super.totalSupply();

    uint256 scaledTotalSupply = _scaledTotalSupply(e, _totalGonsDeposited);
    uint256 fromBalanceScaled = _scaledBalanceOf(super.balanceOf(from), totalSupplyInternal, scaledTotalSupply);
    uint256 toBalanceScaled = _scaledBalanceOf(super.balanceOf(to), totalSupplyInternal, scaledTotalSupply);

    uint256 fromBalanceBefore = fromBalanceScaled.rayMul(index);
    uint256 toBalanceBefore = toBalanceScaled.rayMul(index);

    _transferScaled(from, to, amountScaled, e);

    if (validate) {
      POOL.finalizeTransfer(
        UNDERLYING_ASSET_ADDRESS,
        from,
        to,
        amount,
        fromBalanceBefore,
        toBalanceBefore
      );
    }

    emit BalanceTransfer(from, to, amount, index);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    _transfer(from, to, amount, true);
  }


  function scaledTotalSupply() public view virtual override returns (uint256) {
    return _scaledTotalSupply(_fetchExtData(), _totalGonsDeposited);
  }

  function scaledBalanceOf(address user) external view override returns (uint256) {
    return _scaledBalanceOf(
      super.balanceOf(user), super.totalSupply(),
      _scaledTotalSupply(_fetchExtData(), _totalGonsDeposited)
    );
  }

  function getScaledUserBalanceAndSupply(address user)
    external
    view
    override
    returns (uint256, uint256)
  {
    uint256 scaledTotalSupply = _scaledTotalSupply(_fetchExtData(), _totalGonsDeposited);
    return (
      _scaledBalanceOf(super.balanceOf(user), super.totalSupply(), scaledTotalSupply),
      scaledTotalSupply
    );
  }

  function totalSupply() public view override(IncentivizedERC20, IERC20) returns (uint256) {
    uint256 currentSupplyScaled = _scaledTotalSupply(_fetchExtData(), _totalGonsDeposited);

    if (currentSupplyScaled == 0) {
      return 0;
    }

    return currentSupplyScaled.rayMul(POOL.getReserveNormalizedIncome(UNDERLYING_ASSET_ADDRESS));
  }

  function balanceOf(address user)
    public
    view
    override(IncentivizedERC20, IERC20)
    returns (uint256)
  {
    uint256 userBalanceScaled = _scaledBalanceOf(
      super.balanceOf(user), super.totalSupply(),
      _scaledTotalSupply(_fetchExtData(), _totalGonsDeposited)
    );
    return userBalanceScaled.rayMul(POOL.getReserveNormalizedIncome(UNDERLYING_ASSET_ADDRESS));
  }



  function _transferScaled(address from, address to, uint256 transferAmountScaled, ExtData memory e) private returns (uint256) {
    uint256 totalSupplyInternal = super.totalSupply();
    uint256 scaledTotalSupply = _scaledTotalSupply(e, _totalGonsDeposited);
    uint256 transferAmountInternal = transferAmountScaled.mul(totalSupplyInternal).div(scaledTotalSupply);
    super._transfer(from, to, transferAmountInternal);
  }

  function _mintScaled(address user, uint256 mintAmountScaled, ExtData memory e) private {
    uint256 totalSupplyInternalBefore = super.totalSupply();
    uint256 userBalanceInternalBefore = super.balanceOf(user);

    if(totalSupplyInternalBefore == 0) {
      uint256 mintAmountInternal = _amplToGons(e.totalAMPLSupply, mintAmountScaled);
      _mint(user, mintAmountInternal);
      return;
    }

    uint256 scaledTotalSupplyBefore = _scaledTotalSupply(e, _totalGonsDeposited);

    uint256 userBalanceScaledBefore = _scaledBalanceOf(userBalanceInternalBefore, totalSupplyInternalBefore, scaledTotalSupplyBefore);
    uint256 otherBalanceScaledBefore = scaledTotalSupplyBefore.sub(userBalanceScaledBefore);

    uint256 scaledTotalSupplyAfter = scaledTotalSupplyBefore.add(mintAmountScaled);
    uint256 userBalanceScaledAfter = userBalanceScaledBefore.add(mintAmountScaled);
    uint256 mintAmountInternal = 0;

    if(otherBalanceScaledBefore == 0) {
      uint256 mintAmountInternal = mintAmountScaled.mul(totalSupplyInternalBefore).div(scaledTotalSupplyBefore);
      _mint(user, mintAmountInternal);
      return;
    }

    mintAmountInternal = totalSupplyInternalBefore
      .mul(userBalanceScaledAfter)
      .sub(scaledTotalSupplyAfter.mul(userBalanceInternalBefore))
      .div(otherBalanceScaledBefore);

    _mint(user, mintAmountInternal);
  }

  function _burnScaled(address user, uint256 burnAmountScaled, ExtData memory e) private {
    uint256 totalSupplyInternalBefore = super.totalSupply();
    uint256 userBalanceInternalBefore = super.balanceOf(user);

    uint256 scaledTotalSupplyBefore = _scaledTotalSupply(e, _totalGonsDeposited);
    uint256 userBalanceScaledBefore = _scaledBalanceOf(userBalanceInternalBefore, totalSupplyInternalBefore, scaledTotalSupplyBefore);
    uint256 otherBalanceScaledBefore = scaledTotalSupplyBefore.sub(userBalanceScaledBefore);

    uint256 scaledTotalSupplyAfter = scaledTotalSupplyBefore.sub(burnAmountScaled);
    uint256 userBalanceScaledAfter = userBalanceScaledBefore.sub(burnAmountScaled);
    uint256 burnAmountInternal = 0;

    if(otherBalanceScaledBefore == 0) {
      uint256 burnAmountInternal = burnAmountScaled.mul(totalSupplyInternalBefore).div(scaledTotalSupplyBefore);
      _burn(user, burnAmountInternal);
      return;
    }

    burnAmountInternal = scaledTotalSupplyAfter
      .mul(userBalanceInternalBefore)
      .sub(totalSupplyInternalBefore.mul(userBalanceScaledAfter))
      .div(otherBalanceScaledBefore);
    _burn(user, burnAmountInternal);
  }

  function _scaledBalanceOf(uint256 balanceInternal, uint256 totalSupplyInternal, uint256 scaledTotalSupply) private pure returns (uint256) {
    if (balanceInternal == 0 || scaledTotalSupply == 0) {
      return 0;
    }
    return balanceInternal.wayMul(scaledTotalSupply).wayDiv(totalSupplyInternal);
  }

  function _scaledTotalSupply(ExtData memory e, int256 totalGonsDeposited) private pure returns (uint256) {
    return _gonsToAMPL(e.totalAMPLSupply, uint256(totalGonsDeposited.sub(e.totalGonsBorrowed)))
      .add(e.totalPrincipalBorrowed);
  }

  function _gonsToAMPL(uint256 totalAMPLSupply, uint256 gonValue) private pure returns (uint256) {
    return gonValue.wayMul(totalAMPLSupply).wayDiv(GONS_TOTAL_SUPPLY);
  }

  function _amplToGons(uint256 totalAMPLSupply, uint256 amplValue) private pure returns (uint256) {
    return amplValue.mul(GONS_TOTAL_SUPPLY).div(totalAMPLSupply);
  }

  function _fetchExtData() internal view returns (ExtData memory) {
    ExtData memory _extContractData;
    _extContractData.totalAMPLSupply = IERC20(UNDERLYING_ASSET_ADDRESS).totalSupply();

    uint256 stablePrincipal;
    int256 stablePrincipalScaled;
    (stablePrincipal, stablePrincipalScaled) = IAMPLDebtToken(STABLE_DEBT_TOKEN_ADDRESS).getAMPLBorrowData();

    uint256 variablePrincipal;
    int256 variablePrincipalScaled;
    (variablePrincipal, variablePrincipalScaled) = IAMPLDebtToken(VARIABLE_DEBT_TOKEN_ADDRESS).getAMPLBorrowData();

    _extContractData.totalPrincipalBorrowed = stablePrincipal.add(variablePrincipal);
    _extContractData.totalGonsBorrowed = stablePrincipalScaled.add(variablePrincipalScaled);

    return _extContractData;
  }
}