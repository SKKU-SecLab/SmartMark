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

struct PoolTokenConfig {
  address pool;
  address treasury;
  address underlyingAsset;
  uint8 underlyingDecimals;
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

interface ERC20Events {

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
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


interface IERC20WithPermit is IERC20 {

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract ERC20PermitBase is IERC20WithPermit {
  bytes32 public DOMAIN_SEPARATOR;
  bytes public constant EIP712_REVISION = bytes('1');
  bytes32 internal constant EIP712_DOMAIN =
    keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)');
  bytes32 public constant PERMIT_TYPEHASH =
    keccak256('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)');

  mapping(address => uint256) public _nonces;

  constructor() {
    _initializeDomainSeparator();
  }

  function nonces(address addr) external view returns (uint256) {
    return _nonces[addr];
  }

  function _initializeDomainSeparator() internal {
    uint256 chainId;

    assembly {
      chainId := chainid()
    }

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(EIP712_DOMAIN, keccak256(_getPermitDomainName()), keccak256(EIP712_REVISION), chainId, address(this))
    );
  }


  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {
    require(owner != address(0), 'INVALID_OWNER');
    require(block.timestamp <= deadline, 'INVALID_EXPIRATION');
    uint256 currentValidNonce = _nonces[owner];
    bytes32 digest = keccak256(
      abi.encodePacked(
        '\x19\x01',
        DOMAIN_SEPARATOR,
        keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, currentValidNonce, deadline))
      )
    );

    require(owner == ecrecover(digest, v, r, s), 'INVALID_SIGNATURE');
    _nonces[owner] = currentValidNonce + 1;
    _approveByPermit(owner, spender, value);
  }

  function _approveByPermit(
    address owner,
    address spender,
    uint256 value
  ) internal virtual;

  function _getPermitDomainName() internal view virtual returns (bytes memory);
}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract ERC20AllowanceBase is IERC20 {
  mapping(address => mapping(address => uint256)) private _allowances;

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _decAllowance(msg.sender, spender, subtractedValue, 'ERC20: decreased allowance below zero');
    return true;
  }

  function useAllowance(address owner, uint256 subtractedValue) public virtual returns (bool) {
    _decAllowance(owner, msg.sender, subtractedValue, 'ERC20: decreased allowance below zero');
    return true;
  }

  function _decAllowance(
    address owner,
    address spender,
    uint256 subtractedValue,
    string memory errMsg
  ) private {
    uint256 limit = _allowances[owner][spender];
    require(limit >= subtractedValue, errMsg);
    unchecked {
      _approve(owner, spender, limit - subtractedValue);
    }
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal {
    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  event Approval(address indexed owner, address indexed spender, uint256 value);

  function _approveTransferFrom(address owner, uint256 amount) internal virtual {
    _decAllowance(owner, msg.sender, amount, 'ERC20: transfer amount exceeds allowance');
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


enum AllocationMode {
  Push,
  SetPull,
  SetPullSpecial
}

interface IRewardController {

  function allocatedByPool(
    address holder,
    uint256 allocated,
    uint32 since,
    AllocationMode mode
  ) external;


  function isRateAdmin(address) external view returns (bool);


  function isConfigAdmin(address) external view returns (bool);


  function getAccessController() external view returns (IMarketAccessController);

}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract CalcLinearRewardBalances {
  struct RewardBalance {
    uint192 rewardBase;
    uint32 custom;
    uint32 claimedAt;
  }
  mapping(address => RewardBalance) private _balances;
  mapping(address => uint256) private _accumRates;

  uint224 private _rate;
  uint32 private _rateUpdatedAt;

  function setLinearRate(uint256 rate) internal {
    setLinearRateAt(rate, getCurrentTick());
  }

  function setLinearRateAt(uint256 rate, uint32 at) internal {
    if (_rate == rate) {
      return;
    }
    require(rate <= type(uint224).max);

    uint32 prevTick = _rateUpdatedAt;
    if (at != prevTick) {
      uint224 prevRate = _rate;
      internalMarkRateUpdate(at);
      _rate = uint224(rate);
      internalRateUpdated(prevRate, prevTick, at);
    }
  }

  function doSyncRateAt(uint32 at) internal {
    uint32 prevTick = _rateUpdatedAt;
    if (at != prevTick) {
      internalMarkRateUpdate(at);
      internalRateUpdated(_rate, prevTick, at);
    }
  }

  function getCurrentTick() internal view virtual returns (uint32);

  function internalRateUpdated(
    uint256 lastRate,
    uint32 lastAt,
    uint32 at
  ) internal virtual;

  function internalMarkRateUpdate(uint32 currentTick) internal {
    require(currentTick >= _rateUpdatedAt, 'retroactive update');
    _rateUpdatedAt = currentTick;
  }

  function getLinearRate() internal view returns (uint256) {
    return _rate;
  }

  function getRateAndUpdatedAt() internal view returns (uint256, uint32) {
    return (_rate, _rateUpdatedAt);
  }

  function internalCalcRateAndReward(
    RewardBalance memory entry,
    uint256 lastAccumRate,
    uint32 currentTick
  )
    internal
    view
    virtual
    returns (
      uint256 rate,
      uint256 allocated,
      uint32 since
    );

  function getRewardEntry(address holder) internal view returns (RewardBalance memory) {
    return _balances[holder];
  }

  function internalSetRewardEntryCustom(address holder, uint32 custom) internal {
    _balances[holder].custom = custom;
  }

  function doIncrementRewardBalance(address holder, uint256 amount)
    internal
    returns (
      uint256,
      uint32,
      AllocationMode
    )
  {
    RewardBalance memory entry = _balances[holder];
    amount += entry.rewardBase;
    require(amount <= type(uint192).max, 'balance is too high');
    return _doUpdateRewardBalance(holder, entry, uint192(amount));
  }

  function doDecrementRewardBalance(
    address holder,
    uint256 amount,
    uint256 minBalance
  )
    internal
    returns (
      uint256,
      uint32,
      AllocationMode
    )
  {
    RewardBalance memory entry = _balances[holder];
    require(entry.rewardBase >= minBalance + amount, 'amount exceeds balance');
    unchecked {
      amount = entry.rewardBase - amount;
    }
    return _doUpdateRewardBalance(holder, entry, uint192(amount));
  }

  function doUpdateRewardBalance(address holder, uint256 newBalance)
    internal
    returns (
      uint256 allocated,
      uint32 since,
      AllocationMode mode
    )
  {
    require(newBalance <= type(uint192).max, 'balance is too high');
    return _doUpdateRewardBalance(holder, _balances[holder], uint192(newBalance));
  }

  function _doUpdateRewardBalance(
    address holder,
    RewardBalance memory entry,
    uint192 newBalance
  )
    private
    returns (
      uint256,
      uint32,
      AllocationMode mode
    )
  {
    if (entry.claimedAt == 0) {
      mode = AllocationMode.SetPull;
    } else {
      mode = AllocationMode.Push;
    }

    uint32 currentTick = getCurrentTick();
    (uint256 adjRate, uint256 allocated, uint32 since) = internalCalcRateAndReward(
      entry,
      _accumRates[holder],
      currentTick
    );

    _accumRates[holder] = adjRate;
    _balances[holder] = RewardBalance(newBalance, entry.custom, currentTick);
    return (allocated, since, mode);
  }

  function doRemoveRewardBalance(address holder) internal returns (uint256 rewardBase) {
    rewardBase = _balances[holder].rewardBase;
    if (rewardBase == 0 && _balances[holder].claimedAt == 0) {
      return 0;
    }
    delete (_balances[holder]);
    return rewardBase;
  }

  function doGetReward(address holder)
    internal
    returns (
      uint256,
      uint32,
      bool
    )
  {
    return doGetRewardAt(holder, getCurrentTick());
  }

  function doGetRewardAt(address holder, uint32 currentTick)
    internal
    returns (
      uint256,
      uint32,
      bool
    )
  {
    RewardBalance memory balance = _balances[holder];
    if (balance.rewardBase == 0) {
      return (0, 0, false);
    }

    (uint256 adjRate, uint256 allocated, uint32 since) = internalCalcRateAndReward(
      balance,
      _accumRates[holder],
      currentTick
    );

    _accumRates[holder] = adjRate;
    _balances[holder].claimedAt = currentTick;
    return (allocated, since, true);
  }

  function doCalcReward(address holder) internal view returns (uint256, uint32) {
    return doCalcRewardAt(holder, getCurrentTick());
  }

  function doCalcRewardAt(address holder, uint32 currentTick) internal view returns (uint256, uint32) {
    if (_balances[holder].rewardBase == 0) {
      return (0, 0);
    }

    (, uint256 allocated, uint32 since) = internalCalcRateAndReward(
      _balances[holder],
      _accumRates[holder],
      currentTick
    );
    return (allocated, since);
  }
}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract CalcLinearWeightedReward is CalcLinearRewardBalances {
  uint256 private _accumRate;
  uint256 private _totalSupply;

  uint256 private constant _maxWeightBase = 1e36;

  function internalGetTotalSupply() internal view returns (uint256) {
    return _totalSupply;
  }

  function internalRateUpdated(
    uint256 lastRate,
    uint32 lastAt,
    uint32 at
  ) internal override {
    if (_totalSupply == 0) {
      return;
    }

    if (at != lastAt) {
      lastRate *= _maxWeightBase / _totalSupply;
      _accumRate += lastRate * (at - lastAt);
    }
  }

  function doUpdateTotalSupply(uint256 newSupply) internal returns (bool) {
    if (newSupply == _totalSupply) {
      return false;
    }
    return internalSetTotalSupply(newSupply, getCurrentTick());
  }

  function doIncrementTotalSupply(uint256 amount) internal {
    doUpdateTotalSupply(_totalSupply + amount);
  }

  function doDecrementTotalSupply(uint256 amount) internal {
    doUpdateTotalSupply(_totalSupply - amount);
  }

  function internalSetTotalSupply(uint256 totalSupply, uint32 at) internal returns (bool rateUpdated) {
    (uint256 lastRate, uint32 lastAt) = getRateAndUpdatedAt();
    internalMarkRateUpdate(at);

    if (lastRate > 0) {
      internalRateUpdated(lastRate, lastAt, at);
      rateUpdated = lastAt != at;
    }

    _totalSupply = totalSupply;
    return rateUpdated;
  }

  function internalGetLastAccumRate() internal view returns (uint256) {
    return _accumRate;
  }

  function internalCalcRateAndReward(
    RewardBalance memory entry,
    uint256 lastAccumRate,
    uint32 at
  )
    internal
    view
    virtual
    override
    returns (
      uint256 adjRate,
      uint256 allocated,
      uint32 /* since */
    )
  {
    adjRate = _accumRate;

    if (_totalSupply > 0) {
      (uint256 rate, uint32 updatedAt) = getRateAndUpdatedAt();

      rate *= _maxWeightBase / _totalSupply;
      adjRate += rate * (at - updatedAt);
    }

    if (adjRate == lastAccumRate || entry.rewardBase == 0) {
      return (adjRate, 0, entry.claimedAt);
    }

    allocated = (uint256(entry.rewardBase) * (adjRate - lastAccumRate)) / _maxWeightBase;
    return (adjRate, allocated, entry.claimedAt);
  }
}// agpl-3.0
pragma solidity ^0.8.4;

interface IEmergencyAccess {

  function setPaused(bool paused) external;


  function isPaused() external view returns (bool);


  event EmergencyPaused(address indexed by, bool paused);
}// agpl-3.0
pragma solidity ^0.8.4;


interface IManagedRewardPool is IEmergencyAccess {

  function updateBaseline(uint256) external returns (bool hasBaseline, uint256 appliedRate);


  function setBaselinePercentage(uint16) external;


  function getBaselinePercentage() external view returns (uint16);


  function getRate() external view returns (uint256);


  function getPoolName() external view returns (string memory);


  function claimRewardFor(address holder)
    external
    returns (
      uint256 amount,
      uint32 since,
      bool keepPull
    );


  function claimRewardWithLimitFor(
    address holder,
    uint256 baseAmount,
    uint256 limit,
    uint16 minPct
  )
    external
    returns (
      uint256 amount,
      uint32 since,
      bool keepPull,
      uint256 newLimit
    );


  function calcRewardFor(address holder, uint32 at)
    external
    view
    returns (
      uint256 amount,
      uint256 extra,
      uint32 since
    );


  function addRewardProvider(address provider, address token) external;


  function removeRewardProvider(address provider) external;


  function getRewardController() external view returns (address);


  function attachedToRewardController() external returns (uint256 allocateReward);


  function detachedFromRewardController() external returns (uint256 deallocateReward);


  event RateUpdated(uint256 rate);
  event BaselinePercentageUpdated(uint16);
  event ProviderAdded(address provider, address token);
  event ProviderRemoved(address provider);
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


abstract contract ControlledRewardPool is IManagedRewardPool {
  using PercentageMath for uint256;

  IRewardController private _controller;

  uint16 private _baselinePercentage;
  bool private _paused;

  constructor(
    IRewardController controller,
    uint256 initialRate,
    uint16 baselinePercentage
  ) {
    _initialize(controller, initialRate, baselinePercentage, '');
  }

  function _initialize(
    IRewardController controller,
    uint256 initialRate,
    uint16 baselinePercentage,
    string memory poolName
  ) internal virtual {
    poolName;
    _controller = controller;

    if (baselinePercentage > 0) {
      _setBaselinePercentage(baselinePercentage);
    }

    if (initialRate > 0) {
      _setRate(initialRate);
    }
  }

  function getPoolName() public view virtual override returns (string memory) {
    return '';
  }

  function updateBaseline(uint256 baseline)
    external
    virtual
    override
    onlyController
    returns (bool hasBaseline, uint256 appliedRate)
  {
    if (_baselinePercentage == 0) {
      return (false, internalGetRate());
    }
    appliedRate = baseline.percentMul(_baselinePercentage);
    _setRate(appliedRate);
    return (true, appliedRate);
  }

  function setBaselinePercentage(uint16 factor) external override onlyController {
    _setBaselinePercentage(factor);
  }

  function getBaselinePercentage() public view override returns (uint16) {
    return _baselinePercentage;
  }

  function _mustHaveController() private view {
    require(address(_controller) != address(0), 'controller is required');
  }

  function _setBaselinePercentage(uint16 factor) internal virtual {
    _mustHaveController();
    require(factor <= PercentageMath.ONE, 'illegal value');
    _baselinePercentage = factor;
    emit BaselinePercentageUpdated(factor);
  }

  function _setRate(uint256 rate) internal {
    _mustHaveController();
    internalSetRate(rate);
    emit RateUpdated(rate);
  }

  function getRate() external view override returns (uint256) {
    return internalGetRate();
  }

  function internalGetRate() internal view virtual returns (uint256);

  function internalSetRate(uint256 rate) internal virtual;

  function setPaused(bool paused) public override onlyEmergencyAdmin {
    if (_paused != paused) {
      _paused = paused;
      internalPause(paused);
    }
    emit EmergencyPaused(msg.sender, paused);
  }

  function isPaused() public view override returns (bool) {
    return _paused;
  }

  function internalPause(bool paused) internal virtual {}

  function getRewardController() public view override returns (address) {
    return address(_controller);
  }

  function claimRewardFor(address holder)
    external
    override
    onlyController
    returns (
      uint256,
      uint32,
      bool
    )
  {
    return internalGetReward(holder);
  }

  function claimRewardWithLimitFor(
    address holder,
    uint256 baseAmount,
    uint256 limit,
    uint16 minPct
  )
    external
    override
    onlyController
    returns (
      uint256 amount,
      uint32 since,
      bool keepPull,
      uint256 newLimit
    )
  {
    return internalGetRewardWithLimit(holder, baseAmount, limit, minPct);
  }

  function calcRewardFor(address holder, uint32 at)
    external
    view
    virtual
    override
    returns (
      uint256 amount,
      uint256,
      uint32 since
    )
  {
    require(at >= uint32(block.timestamp));
    (amount, since) = internalCalcReward(holder, at);
    return (amount, 0, since);
  }

  function internalAllocateReward(
    address holder,
    uint256 allocated,
    uint32 since,
    AllocationMode mode
  ) internal {
    _controller.allocatedByPool(holder, allocated, since, mode);
  }

  function internalGetRewardWithLimit(
    address holder,
    uint256 baseAmount,
    uint256 limit,
    uint16 minBoostPct
  )
    internal
    virtual
    returns (
      uint256 amount,
      uint32 since,
      bool keepPull,
      uint256
    )
  {
    (amount, since, keepPull) = internalGetReward(holder);
    amount += baseAmount;
    if (minBoostPct > 0) {
      limit += PercentageMath.percentMul(amount, minBoostPct);
    }
    return (amount, since, keepPull, limit);
  }

  function internalGetReward(address holder)
    internal
    virtual
    returns (
      uint256,
      uint32,
      bool
    );

  function internalCalcReward(address holder, uint32 at) internal view virtual returns (uint256, uint32);

  function attachedToRewardController() external override onlyController returns (uint256) {
    internalAttachedToRewardController();
    return internalGetPreAllocatedLimit();
  }

  function detachedFromRewardController() external override onlyController returns (uint256) {
    return internalGetPreAllocatedLimit();
  }

  function internalGetPreAllocatedLimit() internal virtual returns (uint256) {
    return 0;
  }

  function internalAttachedToRewardController() internal virtual {}

  function _isController(address addr) internal view virtual returns (bool) {
    return address(_controller) == addr;
  }

  function getAccessController() internal view virtual returns (IMarketAccessController) {
    return _controller.getAccessController();
  }

  function _onlyController() private view {
    require(_isController(msg.sender), Errors.CALLER_NOT_REWARD_CONTROLLER);
  }

  modifier onlyController() {
    _onlyController();
    _;
  }

  function _isConfigAdmin(address addr) internal view returns (bool) {
    return address(_controller) != address(0) && _controller.isConfigAdmin(addr);
  }

  function _onlyConfigAdmin() private view {
    require(_isConfigAdmin(msg.sender), Errors.CALLER_NOT_REWARD_CONFIG_ADMIN);
  }

  modifier onlyConfigAdmin() {
    _onlyConfigAdmin();
    _;
  }

  function _isRateAdmin(address addr) internal view returns (bool) {
    return address(_controller) != address(0) && _controller.isRateAdmin(addr);
  }

  function _onlyRateAdmin() private view {
    require(_isRateAdmin(msg.sender), Errors.CALLER_NOT_REWARD_RATE_ADMIN);
  }

  modifier onlyRateAdmin() {
    _onlyRateAdmin();
    _;
  }

  function _onlyEmergencyAdmin() private view {
    AccessHelper.requireAnyOf(
      getAccessController(),
      msg.sender,
      AccessFlags.EMERGENCY_ADMIN,
      Errors.CALLER_NOT_EMERGENCY_ADMIN
    );
  }

  modifier onlyEmergencyAdmin() {
    _onlyEmergencyAdmin();
    _;
  }

  function _notPaused() private view {
    require(!_paused, Errors.RW_REWARD_PAUSED);
  }

  modifier notPaused() {
    _notPaused();
    _;
  }

  modifier notPausedCustom(string memory err) {
    require(!_paused, err);
    _;
  }
}// agpl-3.0
pragma solidity ^0.8.4;


interface IInitializableRewardPool {

  struct InitRewardPoolData {
    IRewardController controller;
    string poolName;
    uint16 baselinePercentage;
  }

  function initializeRewardPool(InitRewardPoolData calldata) external;


  function initializedRewardPoolWith() external view returns (InitRewardPoolData memory);

}// agpl-3.0
pragma solidity ^0.8.4;

interface IERC20Details {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);

}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract ERC20DetailsBase is IERC20Details {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  function _initializeERC20(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) internal {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
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

interface IRewardedToken {

  function setIncentivesController(address) external;


  function getIncentivesController() external view returns (address);


  function rewardedBalanceOf(address) external view returns (uint256);

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


abstract contract PoolTokenBase is
  IERC20,
  IPoolToken,
  IInitializablePoolToken,
  IRewardedToken,
  ERC20DetailsBase,
  MarketAccessBitmaskMin
{
  using AccessHelper for IMarketAccessController;

  event Transfer(address indexed from, address indexed to, uint256 value);

  ILendingPoolForTokens internal _pool;
  address internal _underlyingAsset;

  constructor(address pool_, address underlyingAsset_)
    MarketAccessBitmaskMin(
      pool_ != address(0) ? ILendingPoolForTokens(pool_).getAccessController() : IMarketAccessController(address(0))
    )
  {
    _pool = ILendingPoolForTokens(pool_);
    _underlyingAsset = underlyingAsset_;
  }

  function _initializePoolToken(PoolTokenConfig memory config, bytes calldata params) internal virtual {
    params;
    _pool = ILendingPoolForTokens(config.pool);
    _underlyingAsset = config.underlyingAsset;
    _remoteAcl = ILendingPoolForTokens(config.pool).getAccessController();
  }

  function _onlyLendingPool() private view {
    require(msg.sender == address(_pool), Errors.CALLER_NOT_LENDING_POOL);
  }

  modifier onlyLendingPool() {
    _onlyLendingPool();
    _;
  }

  function _onlyLendingPoolConfiguratorOrAdmin() private view {
    _remoteAcl.requireAnyOf(
      msg.sender,
      AccessFlags.POOL_ADMIN | AccessFlags.LENDING_POOL_CONFIGURATOR,
      Errors.CALLER_NOT_POOL_ADMIN
    );
  }

  modifier onlyLendingPoolConfiguratorOrAdmin() {
    _onlyLendingPoolConfiguratorOrAdmin();
    _;
  }

  function updatePool() external override onlyLendingPoolConfiguratorOrAdmin {
    address pool = _remoteAcl.getLendingPool();
    require(pool != address(0), Errors.LENDING_POOL_REQUIRED);
    _pool = ILendingPoolForTokens(pool);
  }

  function UNDERLYING_ASSET_ADDRESS() public view override returns (address) {
    return _underlyingAsset;
  }

  function POOL() public view override returns (address) {
    return address(_pool);
  }

  function setIncentivesController(address hook) external override onlyRewardConfiguratorOrAdmin {
    internalSetIncentivesController(hook);
  }

  function internalBalanceOf(address account) internal view virtual returns (uint256);

  function internalBalanceAndFlagsOf(address account) internal view virtual returns (uint256, uint32);

  function internalSetFlagsOf(address account, uint32 flags) internal virtual;

  function internalSetIncentivesController(address hook) internal virtual;

  function totalSupply() public view virtual override returns (uint256) {
    return internalTotalSupply();
  }

  function internalTotalSupply() internal view virtual returns (uint256);

  function _mintBalance(
    address account,
    uint256 amount,
    uint256 scale
  ) internal {
    require(account != address(0), 'ERC20: mint to the zero address');
    _beforeTokenTransfer(address(0), account, amount);
    internalUpdateTotalSupply(internalTotalSupply() + amount);
    internalIncrementBalance(account, amount, scale);
  }

  function _burnBalance(
    address account,
    uint256 amount,
    uint256 minLimit,
    uint256 scale
  ) internal {
    require(account != address(0), 'ERC20: burn from the zero address');
    _beforeTokenTransfer(account, address(0), amount);
    internalUpdateTotalSupply(internalTotalSupply() - amount);
    internalDecrementBalance(account, amount, minLimit, scale);
  }

  function _transferBalance(
    address sender,
    address recipient,
    uint256 amount,
    uint256 senderMinLimit,
    uint256 scale
  ) internal {
    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');

    _beforeTokenTransfer(sender, recipient, amount);
    if (sender != recipient) {
      internalDecrementBalance(sender, amount, senderMinLimit, scale);
      internalIncrementBalance(recipient, amount, scale);
    }
  }

  function _incrementBalanceWithTotal(
    address account,
    uint256 amount,
    uint256 scale,
    uint256 total
  ) internal {
    internalUpdateTotalSupply(total);
    internalIncrementBalance(account, amount, scale);
  }

  function _decrementBalanceWithTotal(
    address account,
    uint256 amount,
    uint256 scale,
    uint256 total
  ) internal {
    internalUpdateTotalSupply(total);
    internalDecrementBalance(account, amount, 0, scale);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

  function internalIncrementBalance(
    address account,
    uint256 amount,
    uint256 scale
  ) internal virtual;

  function internalDecrementBalance(
    address account,
    uint256 amount,
    uint256 senderMinLimit,
    uint256 scale
  ) internal virtual;

  function internalUpdateTotalSupply(uint256 newTotal) internal virtual;
}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract RewardedTokenBase is
  PoolTokenBase,
  CalcLinearWeightedReward,
  ControlledRewardPool,
  IInitializableRewardPool
{
  constructor() ControlledRewardPool(IRewardController(address(0)), 0, 0) {}

  function internalTotalSupply() internal view override returns (uint256) {
    return super.internalGetTotalSupply();
  }

  function internalBalanceOf(address account) internal view override returns (uint256) {
    return super.getRewardEntry(account).rewardBase;
  }

  function internalBalanceAndFlagsOf(address account) internal view override returns (uint256, uint32) {
    RewardBalance memory balance = super.getRewardEntry(account);
    return (balance.rewardBase, balance.custom);
  }

  function internalSetFlagsOf(address account, uint32 flags) internal override {
    super.internalSetRewardEntryCustom(account, flags);
  }

  function internalSetIncentivesController(address) internal override {
    _mutable();
    _notSupported();
  }

  function _notSupported() private pure {
    revert('UNSUPPORTED');
  }

  function _mutable() private {}

  function addRewardProvider(address, address) external view override onlyConfigAdmin {
    _notSupported();
  }

  function removeRewardProvider(address provider) external override onlyConfigAdmin {}

  function internalGetRate() internal view override returns (uint256) {
    return super.getLinearRate();
  }

  function internalSetRate(uint256 rate) internal override {
    super.setLinearRate(rate);
  }

  function getIncentivesController() public view override returns (address) {
    return address(this);
  }

  function getCurrentTick() internal view override returns (uint32) {
    return uint32(block.timestamp);
  }

  function internalGetReward(address holder)
    internal
    override
    returns (
      uint256,
      uint32,
      bool
    )
  {
    return doGetReward(holder);
  }

  function internalCalcReward(address holder, uint32 at) internal view override returns (uint256, uint32) {
    return doCalcRewardAt(holder, at);
  }

  function getAccessController() internal view override returns (IMarketAccessController) {
    return _remoteAcl;
  }

  function internalAllocatedReward(
    address account,
    uint256 allocated,
    uint32 since,
    AllocationMode mode
  ) internal {
    if (allocated == 0) {
      if (mode == AllocationMode.Push || getRewardController() == address(0)) {
        return;
      }
    }
    super.internalAllocateReward(account, allocated, since, mode);
  }

  function internalIncrementBalance(
    address account,
    uint256 amount,
    uint256
  ) internal override {
    (uint256 allocated, uint32 since, AllocationMode mode) = doIncrementRewardBalance(account, amount);
    internalAllocatedReward(account, allocated, since, mode);
  }

  function internalDecrementBalance(
    address account,
    uint256 amount,
    uint256 minBalance,
    uint256
  ) internal override {
    (uint256 allocated, uint32 since, AllocationMode mode) = doDecrementRewardBalance(account, amount, minBalance);
    internalAllocatedReward(account, allocated, since, mode);
  }

  function internalUpdateTotalSupply(uint256 newSupply) internal override {
    doUpdateTotalSupply(newSupply);
  }

  function getPoolName() public view virtual override returns (string memory) {
    return super.symbol();
  }

  function initializeRewardPool(InitRewardPoolData calldata config) external override onlyRewardConfiguratorOrAdmin {
    require(address(config.controller) != address(0));
    require(address(getRewardController()) == address(0));
    _initialize(IRewardController(config.controller), 0, config.baselinePercentage, config.poolName);
  }

  function initializedRewardPoolWith() external view override returns (InitRewardPoolData memory) {
    return InitRewardPoolData(IRewardController(getRewardController()), getPoolName(), getBaselinePercentage());
  }
}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract SubBalanceBase is IDepositToken, RewardedTokenBase {
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using SafeERC20 for IERC20;

  uint32 private constant FLAG_OUT_BALANCE = 1 << 0;
  uint32 private constant FLAG_ALLOW_OVERDRAFT = 1 << 1;
  uint32 private constant FLAG_IN_BALANCE = 1 << 2;

  struct InBalance {
    uint128 allowance;
    uint128 overdraft;
  }

  struct OutBalance {
    uint128 outBalance;
  }

  uint8 internal constant ACCESS_SUB_BALANCE = uint8(1) << 0;
  uint8 internal constant ACCESS_LOCK_BALANCE = uint8(1) << 1;
  uint8 internal constant ACCESS_TRANSFER = uint8(1) << 2;

  mapping(address => uint8) private _subBalanceOperators;
  mapping(address => OutBalance) private _outBalances;
  mapping(address => InBalance) private _inBalances;
  uint256 private _totalOverdraft;
  uint16 private _overdraftTolerancePct = PercentageMath.HALF_ONE;

  function internalSetOverdraftTolerancePct(uint16 overdraftTolerancePct) internal {
    require(overdraftTolerancePct <= PercentageMath.ONE);
    _overdraftTolerancePct = overdraftTolerancePct;
  }

  function _addSubBalanceOperator(address addr, uint8 accessMode) internal {
    require(addr != address(0), 'address is required');
    _subBalanceOperators[addr] |= accessMode;
  }

  function _removeSubBalanceOperator(address addr) internal {
    delete (_subBalanceOperators[addr]);
  }

  function getSubBalanceOperatorAccess(address addr) internal view virtual returns (uint8) {
    return _subBalanceOperators[addr];
  }

  function getScaleIndex() public view virtual override returns (uint256);

  function _onlySubBalanceOperator(uint8 requiredMode) private view returns (uint8 accessMode) {
    accessMode = getSubBalanceOperatorAccess(msg.sender);
    require(accessMode & requiredMode != 0, Errors.AT_SUB_BALANCE_RESTIRCTED_FUNCTION);
    return accessMode;
  }

  modifier onlySubBalanceOperator() {
    _onlySubBalanceOperator(ACCESS_SUB_BALANCE);
    _;
  }

  function provideSubBalance(
    address provider,
    address recipient,
    uint256 scaledAmount
  ) external override onlySubBalanceOperator {
    require(recipient != address(0), Errors.VL_INVALID_SUB_BALANCE_ARGS);
    _checkSubBalanceArgs(provider, recipient, scaledAmount);

    _incrementOutBalance(provider, scaledAmount);
    _incrementInBalance(recipient, scaledAmount);

    uint256 index = getScaleIndex();
    emit SubBalanceProvided(provider, recipient, scaledAmount.rayMul(index), index);
  }

  function lockSubBalance(address provider, uint256 scaledAmount) external override {
    _onlySubBalanceOperator(ACCESS_LOCK_BALANCE);
    _checkSubBalanceArgs(provider, address(0), scaledAmount);

    _incrementOutBalance(provider, scaledAmount);

    uint256 index = getScaleIndex();
    emit SubBalanceLocked(provider, scaledAmount.rayMul(index), index);
  }

  function _incrementOutBalance(address provider, uint256 scaledAmount) private {
    _incrementOutBalanceNoCheck(provider, scaledAmount);
    _ensureHealthFactor(provider);
  }

  function _incrementOutBalanceNoCheck(address provider, uint256 scaledAmount) private {
    (uint256 balance, uint32 flags) = internalBalanceAndFlagsOf(provider);
    uint256 outBalance = scaledAmount + _outBalances[provider].outBalance;

    require(outBalance <= balance, Errors.VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE);
    require(outBalance <= type(uint128).max, 'balance is too high');

    _outBalances[provider].outBalance = uint128(outBalance);

    if (flags & FLAG_OUT_BALANCE == 0) {
      internalSetFlagsOf(provider, flags | FLAG_OUT_BALANCE);
    }

    _ensureHealthFactor(provider);
  }

  function _ensureHealthFactor(address provider) internal virtual;

  function _decrementOutBalance(
    address provider,
    uint256 scaledAmount,
    uint256 coveredOverdraft,
    uint256 index
  ) private returns (uint256) {
    uint256 outBalance = uint256(_outBalances[provider].outBalance) - scaledAmount;

    if (coveredOverdraft > 0) {
      _burnBalance(provider, coveredOverdraft, outBalance, index);
    }
    _outBalances[provider].outBalance = uint128(outBalance);

    if (outBalance == 0) {
      (, uint32 flags) = internalBalanceAndFlagsOf(provider);
      internalSetFlagsOf(provider, flags & ~FLAG_OUT_BALANCE);
    }
    return outBalance;
  }

  function _incrementInBalance(address recipient, uint256 scaledAmount) private {
    (, uint32 flags) = internalBalanceAndFlagsOf(recipient);
    require(flags & FLAG_ALLOW_OVERDRAFT != 0, Errors.AT_OVERDRAFT_DISABLED);
    scaledAmount += _inBalances[recipient].allowance;

    require(scaledAmount <= type(uint128).max, 'balance is too high');
    _inBalances[recipient].allowance = uint128(scaledAmount);

    if (flags & FLAG_IN_BALANCE == 0) {
      internalSetFlagsOf(recipient, flags | FLAG_IN_BALANCE);
    }
  }

  function _decrementInBalance(
    address recipient,
    uint256 scaledAmount,
    bool preferOverdraft
  ) private returns (uint256 overdraft) {
    InBalance memory inBalance = _inBalances[recipient];

    if (
      inBalance.overdraft > 0 &&
      (scaledAmount > inBalance.allowance ||
        (preferOverdraft && inBalance.overdraft >= scaledAmount.percentMul(_overdraftTolerancePct)))
    ) {
      if (inBalance.overdraft > scaledAmount) {
        overdraft = uint128(scaledAmount);
        unchecked {
          inBalance.overdraft -= uint128(scaledAmount);
        }
      } else {
        overdraft = inBalance.overdraft;
        inBalance.overdraft = 0;
      }
      _totalOverdraft -= overdraft;
    }
    inBalance.allowance = uint128(uint256(inBalance.allowance) - (scaledAmount - overdraft));

    _inBalances[recipient] = inBalance;
    if (inBalance.allowance == 0) {
      (, uint32 flags) = internalBalanceAndFlagsOf(recipient);
      internalSetFlagsOf(recipient, flags & ~FLAG_IN_BALANCE);
    }
  }

  function _checkSubBalanceArgs(
    address provider,
    address recipient,
    uint256 scaledAmount
  ) private pure {
    require(scaledAmount > 0, Errors.VL_INVALID_SUB_BALANCE_ARGS);
    require(provider != address(0) && provider != recipient, Errors.VL_INVALID_SUB_BALANCE_ARGS);
  }

  function replaceSubBalance(
    address prevProvider,
    address recipient,
    uint256 prevScaledAmount,
    address newProvider,
    uint256 newScaledAmount
  ) external override onlySubBalanceOperator returns (uint256) {
    require(recipient != address(0), Errors.VL_INVALID_SUB_BALANCE_ARGS);
    _checkSubBalanceArgs(prevProvider, recipient, prevScaledAmount);

    if (prevProvider != newProvider) {
      _checkSubBalanceArgs(newProvider, recipient, newScaledAmount);
      _incrementOutBalance(newProvider, newScaledAmount);
    } else if (prevScaledAmount == newScaledAmount) {
      return 0;
    }

    uint256 overdraft;
    uint256 delta;
    uint256 compensation;
    if (prevScaledAmount > newScaledAmount) {
      unchecked {
        delta = prevScaledAmount - newScaledAmount;
      }
      overdraft = _decrementInBalance(recipient, delta, true);
      if (delta > overdraft) {
        unchecked {
          compensation = delta - overdraft;
        }
      }
    } else if (prevScaledAmount < newScaledAmount) {
      unchecked {
        delta = newScaledAmount - prevScaledAmount;
      }
      _incrementInBalance(recipient, delta);
    }

    uint256 index = getScaleIndex();
    emit SubBalanceReturned(prevProvider, recipient, prevScaledAmount.rayMul(index), index);

    uint256 outBalance;
    if (prevProvider != newProvider) {
      outBalance = _decrementOutBalance(prevProvider, prevScaledAmount, overdraft, index);
    } else if (prevScaledAmount > newScaledAmount) {
      outBalance = _decrementOutBalance(prevProvider, delta, overdraft, index);
    } else {
      _incrementOutBalance(newProvider, delta);
    }

    if (overdraft > 0) {
      emit OverdraftCovered(prevProvider, recipient, uint256(overdraft).rayMul(index), index);
    }
    emit SubBalanceProvided(newProvider, recipient, newScaledAmount.rayMul(index), index);

    if (compensation > 0) {
      _transferScaled(prevProvider, recipient, compensation, outBalance, index);
    }

    return overdraft;
  }

  function returnSubBalance(
    address provider,
    address recipient,
    uint256 scaledAmount,
    bool preferOverdraft
  ) external override onlySubBalanceOperator returns (uint256) {
    require(recipient != address(0), Errors.VL_INVALID_SUB_BALANCE_ARGS);
    _checkSubBalanceArgs(provider, recipient, scaledAmount);

    uint256 overdraft = _decrementInBalance(recipient, scaledAmount, preferOverdraft);
    _ensureHealthFactor(recipient);

    uint256 index = getScaleIndex();
    _decrementOutBalance(provider, scaledAmount, overdraft, index);
    if (overdraft > 0) {
      emit OverdraftCovered(provider, recipient, uint256(overdraft).rayMul(index), index);
    }

    emit SubBalanceReturned(provider, recipient, scaledAmount.rayMul(index), index);
    return overdraft;
  }

  function unlockSubBalance(
    address provider,
    uint256 scaledAmount,
    address transferTo
  ) external override {
    uint8 accessMode = _onlySubBalanceOperator(ACCESS_LOCK_BALANCE);

    _checkSubBalanceArgs(provider, address(0), scaledAmount);

    uint256 index = getScaleIndex();
    uint256 outBalance = _decrementOutBalance(provider, scaledAmount, 0, index);

    emit SubBalanceUnlocked(provider, scaledAmount.rayMul(index), index);

    if (transferTo != address(0) && transferTo != provider) {
      require(accessMode & ACCESS_TRANSFER != 0, Errors.AT_SUB_BALANCE_RESTIRCTED_FUNCTION);
      _transferScaled(provider, transferTo, scaledAmount, outBalance, index);
    }
  }

  function transferLockedBalance(
    address from,
    address to,
    uint256 scaledAmount
  ) external override {
    _onlySubBalanceOperator(ACCESS_LOCK_BALANCE | ACCESS_SUB_BALANCE);
    require(from != address(0) || to != address(0), Errors.VL_INVALID_SUB_BALANCE_ARGS);
    if (scaledAmount == 0) {
      return;
    }

    uint256 index = getScaleIndex();
    uint256 amount = scaledAmount.rayMul(index);

    _decrementOutBalance(from, scaledAmount, 0, index);
    emit SubBalanceUnlocked(from, amount, index);

    _transferScaled(from, to, scaledAmount, 0, index);

    _incrementOutBalanceNoCheck(to, scaledAmount);
    emit SubBalanceLocked(to, amount, index);
  }

  function _mintToSubBalance(
    address user,
    uint256 amountScaled,
    bool repayOverdraft
  ) internal returns (bool) {
    require(amountScaled != 0, Errors.CT_INVALID_MINT_AMOUNT);

    (uint256 firstBalance, uint32 flags) = internalBalanceAndFlagsOf(user);
    if (repayOverdraft && flags & FLAG_IN_BALANCE != 0) {
      InBalance memory inBalance = _inBalances[user];

      if (inBalance.overdraft > 0) {
        unchecked {
          if (inBalance.overdraft >= amountScaled) {
            inBalance.overdraft -= uint128(amountScaled);
            _inBalances[user] = inBalance;
            return firstBalance == 0;
          }
          amountScaled -= inBalance.overdraft;
        }
        inBalance.overdraft = 0;
        _inBalances[user] = inBalance;
      }
    }
    return firstBalance == 0;
  }

  function _liquidateWithSubBalance(
    address user,
    address receiver,
    uint256 scaledAmount,
    uint256 index,
    bool transferUnderlying
  ) internal returns (bool firstBalance, uint256 outBalance) {
    firstBalance = internalBalanceOf(receiver) == 0;
    (uint256 scaledBalanceFrom, uint32 flags) = internalBalanceAndFlagsOf(user);

    if (flags & FLAG_OUT_BALANCE != 0) {
      outBalance = _outBalances[user].outBalance;
    }

    if (flags & FLAG_IN_BALANCE != 0 && scaledAmount + outBalance > scaledBalanceFrom) {

      uint256 requiredAmount;
      unchecked {
        requiredAmount = scaledAmount + outBalance - scaledBalanceFrom;
      }

      InBalance memory inBalance = _inBalances[user];
      if (inBalance.allowance > requiredAmount) {
        unchecked {
          inBalance.allowance -= uint128(requiredAmount);
        }
        inBalance.overdraft += uint128(requiredAmount);
      } else {
        inBalance.overdraft += inBalance.allowance;
        requiredAmount = inBalance.allowance;
        inBalance.allowance = 0;
      }

      scaledAmount -= requiredAmount;
      if (!transferUnderlying) {

        _mintBalance(receiver, requiredAmount, index);
        _totalOverdraft += requiredAmount;

        emit OverdraftApplied(user, requiredAmount.rayMul(index), index);
      }
    }
  }

  function getMinBalance(address user) internal view returns (uint256) {
    return _outBalances[user].outBalance;
  }

  function getMinBalance(address user, uint256 flags) internal view returns (uint256) {
    return flags & FLAG_OUT_BALANCE != 0 ? _outBalances[user].outBalance : 0;
  }

  function scaledBalanceOf(address user) public view override returns (uint256) {
    (uint256 userBalance, uint32 flags) = internalBalanceAndFlagsOf(user);
    if (userBalance == 0) {
      return 0;
    }
    if (flags & FLAG_OUT_BALANCE == 0) {
      return userBalance;
    }

    return userBalance - _outBalances[user].outBalance;
  }

  function scaledTotalSupply() public view override returns (uint256) {
    return super.totalSupply() - _totalOverdraft;
  }

  function collateralBalanceOf(address user) public view override returns (uint256) {
    (uint256 userBalance, uint32 flags) = internalBalanceAndFlagsOf(user);
    if (flags & FLAG_OUT_BALANCE != 0) {
      userBalance -= _outBalances[user].outBalance;
    }
    if (flags & FLAG_IN_BALANCE != 0) {
      userBalance += _inBalances[user].allowance;
    }
    if (userBalance == 0) {
      return 0;
    }
    return userBalance.rayMul(getScaleIndex());
  }

  function _transferScaled(
    address from,
    address to,
    uint256 scaledAmount,
    uint256 outBalance,
    uint256 index
  ) internal virtual;
}// agpl-3.0
pragma solidity ^0.8.4;


abstract contract DepositTokenBase is SubBalanceBase, ERC20PermitBase, ERC20AllowanceBase {
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using SafeERC20 for IERC20;
  using AccessHelper for IMarketAccessController;

  address internal _treasury;

  constructor(address treasury_) {
    _treasury = treasury_;
  }

  function _initializePoolToken(PoolTokenConfig memory config, bytes calldata params) internal virtual override {
    require(config.treasury != address(0), Errors.VL_TREASURY_REQUIRED);
    super._initializeDomainSeparator();
    super._initializePoolToken(config, params);
    internalSetOverdraftTolerancePct(PercentageMath.HALF_ONE);
    _treasury = config.treasury;
  }

  function getTreasury() external view returns (address) {
    return _treasury;
  }

  function updateTreasury() external override onlyLendingPoolConfiguratorOrAdmin {
    address treasury = _remoteAcl.getAddress(AccessFlags.TREASURY);
    require(treasury != address(0), Errors.VL_TREASURY_REQUIRED);
    _treasury = treasury;
  }

  function setOverdraftTolerancePct(uint16 overdraftTolerancePct) external onlyLendingPoolConfiguratorOrAdmin {
    internalSetOverdraftTolerancePct(overdraftTolerancePct);
  }

  function addSubBalanceOperator(address addr) external override onlyLendingPoolConfiguratorOrAdmin {
    _addSubBalanceOperator(addr, ACCESS_SUB_BALANCE);
  }

  function addStakeOperator(address addr) external override {
    _remoteAcl.requireAnyOf(
      msg.sender,
      AccessFlags.POOL_ADMIN |
        AccessFlags.LENDING_POOL_CONFIGURATOR |
        AccessFlags.STAKE_CONFIGURATOR |
        AccessFlags.STAKE_ADMIN,
      Errors.CALLER_NOT_POOL_ADMIN
    );

    _addSubBalanceOperator(addr, ACCESS_LOCK_BALANCE | ACCESS_TRANSFER);
  }

  function removeSubBalanceOperator(address addr) external override onlyLendingPoolConfiguratorOrAdmin {
    _removeSubBalanceOperator(addr);
  }

  function getSubBalanceOperatorAccess(address addr) internal view override returns (uint8) {
    if (addr == address(_pool)) {
      return ~uint8(0);
    }
    return super.getSubBalanceOperatorAccess(addr);
  }

  function getScaleIndex() public view override returns (uint256) {
    return _pool.getReserveNormalizedIncome(_underlyingAsset);
  }

  function mint(
    address user,
    uint256 amount,
    uint256 index,
    bool repayOverdraft
  ) external override onlyLendingPool returns (bool firstBalance) {
    uint256 amountScaled = amount.rayDiv(index);
    require(amountScaled != 0, Errors.CT_INVALID_MINT_AMOUNT);

    firstBalance = _mintToSubBalance(user, amountScaled, repayOverdraft);

    _mintBalance(user, amountScaled, index);
    emit Transfer(address(0), user, amount);
    emit Mint(user, amount, index);

    return firstBalance;
  }

  function mintToTreasury(uint256 amount, uint256 index) external override onlyLendingPool {
    if (amount == 0) {
      return;
    }

    address treasury = _treasury;

    _mintBalance(treasury, amount.rayDiv(index), index);

    emit Transfer(address(0), treasury, amount);
    emit Mint(treasury, amount, index);
  }

  function burn(
    address user,
    address receiverOfUnderlying,
    uint256 amount,
    uint256 index
  ) external override onlyLendingPool {
    uint256 amountScaled = amount.rayDiv(index);
    require(amountScaled != 0, Errors.CT_INVALID_BURN_AMOUNT);
    _burnBalance(user, amountScaled, getMinBalance(user), index);

    IERC20(_underlyingAsset).safeTransfer(receiverOfUnderlying, amount);

    emit Transfer(user, address(0), amount);
    emit Burn(user, receiverOfUnderlying, amount, index);
  }

  function transferOnLiquidation(
    address user,
    address receiver,
    uint256 amount,
    uint256 index,
    bool transferUnderlying
  ) external override onlyLendingPool returns (bool) {
    uint256 scaledAmount = amount.rayDiv(index);
    if (scaledAmount == 0) {
      return false;
    }

    (bool firstBalance, uint256 outBalance) = _liquidateWithSubBalance(
      user,
      receiver,
      scaledAmount,
      index,
      transferUnderlying
    );

    if (transferUnderlying) {
      _burnBalance(user, scaledAmount, outBalance, index);
      IERC20(_underlyingAsset).safeTransfer(receiver, amount);

      emit Transfer(user, address(0), amount);
      emit Burn(user, receiver, amount, index);
      return false;
    }

    super._transferBalance(user, receiver, scaledAmount, outBalance, index);

    emit Transfer(user, receiver, amount);
    emit BalanceTransfer(user, receiver, amount, index);
    return firstBalance;
  }

  function balanceOf(address user) public view override returns (uint256) {
    uint256 scaledBalance = scaledBalanceOf(user);
    if (scaledBalance == 0) {
      return 0;
    }
    return scaledBalanceOf(user).rayMul(getScaleIndex());
  }

  function rewardedBalanceOf(address user) external view override returns (uint256) {
    return internalBalanceOf(user).rayMul(getScaleIndex());
  }

  function getScaledUserBalanceAndSupply(address user) external view override returns (uint256, uint256) {
    return (scaledBalanceOf(user), scaledTotalSupply());
  }

  function totalSupply() public view override returns (uint256) {
    uint256 currentSupplyScaled = scaledTotalSupply();
    if (currentSupplyScaled == 0) {
      return 0;
    }
    return currentSupplyScaled.rayMul(getScaleIndex());
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(msg.sender, recipient, amount, getScaleIndex());
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount, getScaleIndex());
    _approveTransferFrom(sender, amount);
    return true;
  }

  function transferUnderlyingTo(address target, uint256 amount) external override onlyLendingPool returns (uint256) {
    IERC20(_underlyingAsset).safeTransfer(target, amount);
    return amount;
  }

  function _transfer(
    address from,
    address to,
    uint256 amount,
    uint256 index
  ) private {
    uint256 scaledAmount = amount.rayDiv(index);
    (uint256 scaledBalanceBeforeFrom, uint256 flags) = internalBalanceAndFlagsOf(from);

    _transferAndFinalize(from, to, scaledAmount, getMinBalance(from, flags), index, scaledBalanceBeforeFrom);

    emit Transfer(from, to, amount);
    emit BalanceTransfer(from, to, amount, index);
  }

  function _transferScaled(
    address from,
    address to,
    uint256 scaledAmount,
    uint256 minBalance,
    uint256 index
  ) internal override {
    _transferAndFinalize(from, to, scaledAmount, minBalance, index, internalBalanceOf(from));

    uint256 amount = scaledAmount.rayMul(index);
    emit Transfer(from, to, amount);
    emit BalanceTransfer(from, to, amount, index);
  }

  function _transferAndFinalize(
    address from,
    address to,
    uint256 scaledAmount,
    uint256 minBalance,
    uint256 index,
    uint256 scaledBalanceBeforeFrom
  ) private {
    uint256 scaledBalanceBeforeTo = internalBalanceOf(to);
    super._transferBalance(from, to, scaledAmount, minBalance, index);

    _pool.finalizeTransfer(
      _underlyingAsset,
      from,
      to,
      scaledAmount > 0 && scaledBalanceBeforeFrom == scaledAmount,
      scaledAmount > 0 && scaledBalanceBeforeTo == 0
    );
  }

  function _ensureHealthFactor(address holder) internal override {
    _pool.finalizeTransfer(_underlyingAsset, holder, holder, false, false);
  }

  function _approveByPermit(
    address owner,
    address spender,
    uint256 amount
  ) internal override {
    _approve(owner, spender, amount);
  }

  function _getPermitDomainName() internal view override returns (bytes memory) {
    return bytes(super.name());
  }

  function internalPause(bool paused) internal override {
    super.internalPause(paused);
    _pool.setReservePaused(_underlyingAsset, paused);
  }
}// agpl-3.0
pragma solidity ^0.8.4;


contract DepositToken is DepositTokenBase, VersionedInitializable {

  uint256 private constant TOKEN_REVISION = 0x1;

  constructor() PoolTokenBase(address(0), address(0)) DepositTokenBase(address(0)) ERC20DetailsBase('', '', 0) {}

  function getRevision() internal pure virtual override returns (uint256) {

    return TOKEN_REVISION;
  }

  function initialize(
    PoolTokenConfig calldata config,
    string calldata name,
    string calldata symbol,
    bytes calldata params
  ) external override initializerRunAlways(TOKEN_REVISION) {

    if (isRevisionInitialized(TOKEN_REVISION)) {
      _initializeERC20(name, symbol, super.decimals());
    } else {
      _initializeERC20(name, symbol, config.underlyingDecimals);
      _initializePoolToken(config, params);
    }

    emit Initialized(
      config.underlyingAsset,
      address(config.pool),
      address(config.treasury),
      super.name(),
      super.symbol(),
      super.decimals(),
      params
    );
  }
}