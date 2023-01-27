
pragma solidity ^0.8.11;




interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface ICurveFactoryethpool {

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external payable returns (uint256);

}/// @title  IERC20Metadata
interface IERC20Metadata {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

interface IWETH9 is IERC20, IERC20Metadata {

  function deposit() external payable;


  function withdraw(uint256 amount) external;

}
interface IAlchemistV2Actions {

    function approveMint(address spender, uint256 amount) external;


    function approveWithdraw(
        address spender,
        address yieldToken,
        uint256 shares
    ) external;


    function poke(address owner) external;


    function deposit(
        address yieldToken,
        uint256 amount,
        address recipient
    ) external returns (uint256 sharesIssued);


    function depositUnderlying(
        address yieldToken,
        uint256 amount,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 sharesIssued);


    function withdraw(
        address yieldToken,
        uint256 shares,
        address recipient
    ) external returns (uint256 amountWithdrawn);


    function withdrawFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient
    ) external returns (uint256 amountWithdrawn);


    function withdrawUnderlying(
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 amountWithdrawn);


    function withdrawUnderlyingFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 amountWithdrawn);


    function mint(uint256 amount, address recipient) external;


    function mintFrom(
        address owner,
        uint256 amount,
        address recipient
    ) external;


    function burn(uint256 amount, address recipient) external returns (uint256 amountBurned);


    function repay(
        address underlyingToken,
        uint256 amount,
        address recipient
    ) external returns (uint256 amountRepaid);


    function liquidate(
        address yieldToken,
        uint256 shares,
        uint256 minimumAmountOut
    ) external returns (uint256 sharesLiquidated);


    function donate(address yieldToken, uint256 amount) external;


    function harvest(address yieldToken, uint256 minimumAmountOut) external;

}
interface IAlchemistV2AdminActions {

    struct InitializationParams {
        address admin;
        address debtToken;
        address transmuter;
        uint256 minimumCollateralization;
        uint256 protocolFee;
        address protocolFeeReceiver;
        uint256 mintingLimitMinimum;
        uint256 mintingLimitMaximum;
        uint256 mintingLimitBlocks;
        address whitelist;
    }

    struct UnderlyingTokenConfig {
        uint256 repayLimitMinimum;
        uint256 repayLimitMaximum;
        uint256 repayLimitBlocks;
        uint256 liquidationLimitMinimum;
        uint256 liquidationLimitMaximum;
        uint256 liquidationLimitBlocks;
    }

    struct YieldTokenConfig {
        address adapter;
        uint256 maximumLoss;
        uint256 maximumExpectedValue;
        uint256 creditUnlockBlocks;
    }

    function initialize(InitializationParams memory params) external;


    function setPendingAdmin(address value) external;


    function acceptAdmin() external;


    function setSentinel(address sentinel, bool flag) external;


    function setKeeper(address keeper, bool flag) external;


    function addUnderlyingToken(
        address underlyingToken,
        UnderlyingTokenConfig calldata config
    ) external;


    function addYieldToken(address yieldToken, YieldTokenConfig calldata config)
        external;


    function setUnderlyingTokenEnabled(address underlyingToken, bool enabled)
        external;


    function setYieldTokenEnabled(address yieldToken, bool enabled) external;


    function configureRepayLimit(
        address underlyingToken,
        uint256 maximum,
        uint256 blocks
    ) external;


    function configureLiquidationLimit(
        address underlyingToken,
        uint256 maximum,
        uint256 blocks
    ) external;


    function setTransmuter(address value) external;


    function setMinimumCollateralization(uint256 value) external;


    function setProtocolFee(uint256 value) external;


    function setProtocolFeeReceiver(address value) external;


    function configureMintingLimit(uint256 maximum, uint256 blocks) external;


    function configureCreditUnlockRate(address yieldToken, uint256 blocks) external;


    function setTokenAdapter(address yieldToken, address adapter) external;


    function setMaximumExpectedValue(address yieldToken, uint256 value)
        external;


    function setMaximumLoss(address yieldToken, uint256 value) external;


    function snap(address yieldToken) external;

}
interface IAlchemistV2Errors {

    error UnsupportedToken(address token);

    error TokenDisabled(address token);

    error Undercollateralized();

    error ExpectedValueExceeded(address yieldToken, uint256 expectedValue, uint256 maximumExpectedValue);

    error LossExceeded(address yieldToken, uint256 loss, uint256 maximumLoss);

    error MintingLimitExceeded(uint256 amount, uint256 available);

    error RepayLimitExceeded(address underlyingToken, uint256 amount, uint256 available);

    error LiquidationLimitExceeded(address underlyingToken, uint256 amount, uint256 available);

    error SlippageExceeded(uint256 amount, uint256 minimumAmountOut);
}
interface IAlchemistV2Immutables {

    function version() external view returns (string memory);


    function debtToken() external view returns (address);

}
interface IAlchemistV2Events {

    event PendingAdminUpdated(address pendingAdmin);

    event AdminUpdated(address admin);

    event SentinelSet(address sentinel, bool flag);

    event KeeperSet(address sentinel, bool flag);

    event AddUnderlyingToken(address indexed underlyingToken);

    event AddYieldToken(address indexed yieldToken);

    event UnderlyingTokenEnabled(address indexed underlyingToken, bool enabled);

    event YieldTokenEnabled(address indexed yieldToken, bool enabled);

    event RepayLimitUpdated(address indexed underlyingToken, uint256 maximum, uint256 blocks);

    event LiquidationLimitUpdated(address indexed underlyingToken, uint256 maximum, uint256 blocks);

    event TransmuterUpdated(address transmuter);

    event MinimumCollateralizationUpdated(uint256 minimumCollateralization);

    event ProtocolFeeUpdated(uint256 protocolFee);
    
    event ProtocolFeeReceiverUpdated(address protocolFeeReceiver);

    event MintingLimitUpdated(uint256 maximum, uint256 blocks);

    event CreditUnlockRateUpdated(address yieldToken, uint256 blocks);

    event TokenAdapterUpdated(address yieldToken, address tokenAdapter);

    event MaximumExpectedValueUpdated(address indexed yieldToken, uint256 maximumExpectedValue);

    event MaximumLossUpdated(address indexed yieldToken, uint256 maximumLoss);

    event Snap(address indexed yieldToken, uint256 expectedValue);

    event ApproveMint(address indexed owner, address indexed spender, uint256 amount);

    event ApproveWithdraw(address indexed owner, address indexed spender, address indexed yieldToken, uint256 amount);

    event Deposit(address indexed sender, address indexed yieldToken, uint256 amount, address recipient);

    event Withdraw(address indexed owner, address indexed yieldToken, uint256 shares, address recipient);

    event Mint(address indexed owner, uint256 amount, address recipient);

    event Burn(address indexed sender, uint256 amount, address recipient);

    event Repay(address indexed sender, address indexed underlyingToken, uint256 amount, address recipient);

    event Liquidate(address indexed owner, address indexed yieldToken, address indexed underlyingToken, uint256 shares);

    event Donate(address indexed sender, address indexed yieldToken, uint256 amount);

    event Harvest(address indexed yieldToken, uint256 minimumAmountOut, uint256 totalHarvested);
}
interface IAlchemistV2State {

    struct UnderlyingTokenParams {
        uint8 decimals;
        uint256 conversionFactor;
        bool enabled;
    }

    struct YieldTokenParams {
        uint8 decimals;
        address underlyingToken;
        address adapter;
        uint256 maximumLoss;
        uint256 maximumExpectedValue;
        uint256 creditUnlockRate;
        uint256 activeBalance;
        uint256 harvestableBalance;
        uint256 totalShares;
        uint256 expectedValue;
        uint256 pendingCredit;
        uint256 distributedCredit;
        uint256 lastDistributionBlock;
        uint256 accruedWeight;
        bool enabled;
    }

    function admin() external view returns (address admin);


    function pendingAdmin() external view returns (address pendingAdmin);


    function sentinels(address sentinel) external view returns (bool isSentinel);


    function keepers(address keeper) external view returns (bool isKeeper);


    function transmuter() external view returns (address transmuter);


    function minimumCollateralization() external view returns (uint256 minimumCollateralization);


    function protocolFee() external view returns (uint256 protocolFee);


    function protocolFeeReceiver() external view returns (address protocolFeeReceiver);


    function whitelist() external view returns (address whitelist);

    
    function getUnderlyingTokensPerShare(address yieldToken) external view returns (uint256 rate);


    function getYieldTokensPerShare(address yieldToken) external view returns (uint256 rate);


    function getSupportedUnderlyingTokens() external view returns (address[] memory tokens);


    function getSupportedYieldTokens() external view returns (address[] memory tokens);


    function isSupportedUnderlyingToken(address underlyingToken) external view returns (bool isSupported);


    function isSupportedYieldToken(address yieldToken) external view returns (bool isSupported);


    function accounts(address owner) external view returns (int256 debt, address[] memory depositedTokens);


    function positions(address owner, address yieldToken)
        external view
        returns (
            uint256 shares,
            uint256 lastAccruedWeight
        );


    function mintAllowance(address owner, address spender) external view returns (uint256 allowance);


    function withdrawAllowance(address owner, address spender, address yieldToken) external view returns (uint256 allowance);


    function getUnderlyingTokenParameters(address underlyingToken)
        external view
        returns (UnderlyingTokenParams memory params);


    function getYieldTokenParameters(address yieldToken)
        external view
        returns (YieldTokenParams memory params);


    function getMintLimitInfo()
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );


    function getRepayLimitInfo(address underlyingToken)
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );


    function getLiquidationLimitInfo(address underlyingToken)
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );

}

interface IAlchemistV2 is
    IAlchemistV2Actions,
    IAlchemistV2AdminActions,
    IAlchemistV2Errors,
    IAlchemistV2Immutables,
    IAlchemistV2Events,
    IAlchemistV2State
{ }/**

 * @title IFlashLoanReceiver interface
 * @notice Interface for the Aave fee IFlashLoanReceiver.
 * @author Aave
 * @dev implement this interface to develop a flashloan-compatible flashLoanReceiver contract
 **/
interface IAaveFlashLoanReceiver {

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool);

}library DataTypes {
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
}

interface IAaveLendingPool {


    function FLASHLOAN_PREMIUM_TOTAL() external view returns (uint256);


    function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;


    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);


    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;


}/// @title  Whitelist
interface IWhitelist {

  event AccountAdded(address account);

  event AccountRemoved(address account);

  event WhitelistDisabled();

  function getAddresses() external view returns (address[] memory addresses);


  function disabled() external view returns (bool);


  function add(address caller) external;


  function remove(address caller) external;


  function disable() external;


  function isWhitelisted(address account) external view returns (bool);

}
abstract contract AutoleverageBase is IAaveFlashLoanReceiver {

    IWhitelist constant whitelist = IWhitelist(0xA3dfCcbad1333DC69997Da28C961FF8B2879e653);
    IAaveLendingPool constant flashLender = IAaveLendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    struct Details {
        address pool;
        int128 poolInputIndex;
        int128 poolOutputIndex;
        address alchemist;
        address yieldToken;
        address recipient;
        uint256 targetDebt;
    }

    error Unauthorized(address sender);

    error IllegalArgument(string reason);
    
    error UnsupportedYieldToken(address yieldToken);

    error MintFailure();

    error InexactTokens(uint256 currentBalance, uint256 repayAmount);

    function _transferTokensToSelf(address underlyingToken, uint256 collateralInitial) internal virtual;

    function _maybeConvertCurveOutput(uint256 amountOut) internal virtual;

    function _curveSwap(address poolAddress, address debtToken, int128 i, int128 j, uint256 minAmountOut) internal virtual returns (uint256 amountOut);

    function approve(address token, address spender) internal {
        IERC20(token).approve(spender, type(uint256).max);
    }

    function autoleverage(
        address pool,
        int128 poolInputIndex,
        int128 poolOutputIndex,
        address alchemist,
        address yieldToken,
        uint256 collateralInitial,
        uint256 collateralTotal,
        uint256 targetDebt
    ) external payable {
        if (!(tx.origin == msg.sender || whitelist.isWhitelisted(msg.sender))) revert Unauthorized(msg.sender);

        address underlyingToken = IAlchemistV2(alchemist).getYieldTokenParameters(yieldToken).underlyingToken;
        if (underlyingToken == address(0)) revert UnsupportedYieldToken(yieldToken);

        _transferTokensToSelf(underlyingToken, collateralInitial);

        address[] memory assets = new address[](1);
        assets[0] = underlyingToken;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = collateralTotal - collateralInitial;
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        bytes memory params = abi.encode(Details({
            pool: pool,
            poolInputIndex: poolInputIndex,
            poolOutputIndex: poolOutputIndex,
            alchemist: alchemist,
            yieldToken: yieldToken,
            recipient: msg.sender,
            targetDebt: targetDebt
        }));

        flashLender.flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(0), // onBehalfOf, not used here
            params, // params, passed to callback func to decode as struct
            0 // referralCode
        );
    }

    function executeOperation(
        address[] calldata assets,
        uint[] calldata amounts,
        uint[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        if (msg.sender != address(flashLender)) revert Unauthorized(msg.sender);
        if (initiator != address(this)) revert IllegalArgument("flashloan initiator must be self");
        Details memory details = abi.decode(params, (Details));
        uint256 repayAmount = amounts[0] + premiums[0];

        uint256 collateralBalance = IERC20(assets[0]).balanceOf(address(this));

        approve(assets[0], details.alchemist);
        IAlchemistV2(details.alchemist).depositUnderlying(details.yieldToken, collateralBalance, details.recipient, 0);

        try IAlchemistV2(details.alchemist).mintFrom(details.recipient, details.targetDebt, address(this)) {

        } catch {
            revert MintFailure();
        }

        {
            address debtToken = IAlchemistV2(details.alchemist).debtToken();
            uint256 amountOut = _curveSwap(
                details.pool, 
                debtToken, 
                details.poolInputIndex, 
                details.poolOutputIndex, 
                repayAmount
            );

            _maybeConvertCurveOutput(amountOut);


            uint256 excessCollateral = amountOut - repayAmount;
            if (excessCollateral > 0) {
                IAlchemistV2(details.alchemist).depositUnderlying(details.yieldToken, excessCollateral, details.recipient, 0);
            }
        }

        approve(assets[0], address(flashLender));
        uint256 balance = IERC20(assets[0]).balanceOf(address(this));
        if (balance != repayAmount) {
            revert InexactTokens(balance, repayAmount);
        }

        return true;
    }

}
contract AutoleverageCurveFactoryethpool is AutoleverageBase {


    address public constant wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    receive() external payable {}

    function _transferTokensToSelf(address underlyingToken, uint256 collateralInitial) internal override {

        if (msg.value > 0) {
            if (msg.value != collateralInitial) revert IllegalArgument("msg.value doesn't match collateralInitial");
            IWETH9(wethAddress).deposit{value: msg.value}();
        } else {
            IERC20(underlyingToken).transferFrom(msg.sender, address(this), collateralInitial);
        }
    }

    function _maybeConvertCurveOutput(uint256 amountOut) internal override {

        IWETH9(wethAddress).deposit{value: amountOut}();
    }

    function _curveSwap(address poolAddress, address debtToken, int128 i, int128 j, uint256 minAmountOut) internal override returns (uint256 amountOut) {

        uint256 debtTokenBalance = IERC20(debtToken).balanceOf(address(this));
        approve(debtToken, poolAddress);
        return ICurveFactoryethpool(poolAddress).exchange(
            i,
            j,
            debtTokenBalance,
            minAmountOut
        );
    }

}