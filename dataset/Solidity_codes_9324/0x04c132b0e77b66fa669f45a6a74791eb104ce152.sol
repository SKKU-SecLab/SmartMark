pragma solidity 0.8.10;

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
}// AGPL-3.0
pragma solidity 0.8.10;

abstract contract VersionedInitializable {
    uint256 private lastInitializedRevision = 0;

    bool private initializing;

    modifier initializer() {
        uint256 revision = getRevision();
        require(
            initializing ||
                isConstructor() ||
                revision > lastInitializedRevision,
            "Contract instance has already been initialized"
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
}// BUSL-1.1
pragma solidity 0.8.10;

library WadRayMath {

    uint256 internal constant WAD = 1e18;
    uint256 internal constant HALF_WAD = 0.5e18;

    uint256 internal constant RAY = 1e27;
    uint256 internal constant HALF_RAY = 0.5e27;

    uint256 internal constant WAD_RAY_RATIO = 1e9;

    function wadMul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        assembly {
            if iszero(
                or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_WAD), b))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, b), HALF_WAD), WAD)
        }
    }

    function wadDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        assembly {
            if or(
                iszero(b),
                iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), WAD))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, WAD), div(b, 2)), b)
        }
    }

    function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        assembly {
            if iszero(
                or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_RAY), b))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, b), HALF_RAY), RAY)
        }
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        assembly {
            if or(
                iszero(b),
                iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), RAY))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, RAY), div(b, 2)), b)
        }
    }

    function rayToWad(uint256 a) internal pure returns (uint256 b) {

        assembly {
            b := div(a, WAD_RAY_RATIO)
            let remainder := mod(a, WAD_RAY_RATIO)
            if iszero(lt(remainder, div(WAD_RAY_RATIO, 2))) {
                b := add(b, 1)
            }
        }
    }

    function wadToRay(uint256 a) internal pure returns (uint256 b) {

        assembly {
            b := mul(a, WAD_RAY_RATIO)

            if iszero(eq(div(b, WAD_RAY_RATIO), a)) {
                revert(0, 0)
            }
        }
    }
}// BUSL-1.1
pragma solidity 0.8.10;


library MathUtils {

    using WadRayMath for uint256;

    uint256 internal constant SECONDS_PER_YEAR = 365 days;

    function calculateLinearInterest(uint256 rate, uint40 lastUpdateTimestamp)
        internal
        view
        returns (uint256)
    {

        uint256 result = rate *
            (block.timestamp - uint256(lastUpdateTimestamp));
        unchecked {
            result = result / SECONDS_PER_YEAR;
        }

        return WadRayMath.RAY + result;
    }

    function calculateCompoundedInterest(
        uint256 rate,
        uint40 lastUpdateTimestamp,
        uint256 currentTimestamp
    ) internal pure returns (uint256) {

        uint256 exp = currentTimestamp - uint256(lastUpdateTimestamp);

        if (exp == 0) {
            return WadRayMath.RAY;
        }

        uint256 expMinusOne;
        uint256 expMinusTwo;
        uint256 basePowerTwo;
        uint256 basePowerThree;
        unchecked {
            expMinusOne = exp - 1;

            expMinusTwo = exp > 2 ? exp - 2 : 0;

            basePowerTwo =
                rate.rayMul(rate) /
                (SECONDS_PER_YEAR * SECONDS_PER_YEAR);
            basePowerThree = basePowerTwo.rayMul(rate) / SECONDS_PER_YEAR;
        }

        uint256 secondTerm = exp * expMinusOne * basePowerTwo;
        unchecked {
            secondTerm /= 2;
        }
        uint256 thirdTerm = exp * expMinusOne * expMinusTwo * basePowerThree;
        unchecked {
            thirdTerm /= 6;
        }

        return
            WadRayMath.RAY +
            (rate * exp) /
            SECONDS_PER_YEAR +
            secondTerm +
            thirdTerm;
    }

    function calculateCompoundedInterest(
        uint256 rate,
        uint40 lastUpdateTimestamp
    ) internal view returns (uint256) {

        return
            calculateCompoundedInterest(
                rate,
                lastUpdateTimestamp,
                block.timestamp
            );
    }
}// BUSL-1.1
pragma solidity 0.8.10;

library Errors {

    string public constant CALLER_NOT_POOL_ADMIN = "1"; // 'The caller of the function is not a pool admin'
    string public constant CALLER_NOT_EMERGENCY_ADMIN = "2"; // 'The caller of the function is not an emergency admin'
    string public constant CALLER_NOT_POOL_OR_EMERGENCY_ADMIN = "3"; // 'The caller of the function is not a pool or emergency admin'
    string public constant CALLER_NOT_RISK_OR_POOL_ADMIN = "4"; // 'The caller of the function is not a risk or pool admin'
    string public constant CALLER_NOT_ASSET_LISTING_OR_POOL_ADMIN = "5"; // 'The caller of the function is not an asset listing or pool admin'
    string public constant CALLER_NOT_BRIDGE = "6"; // 'The caller of the function is not a bridge'
    string public constant ADDRESSES_PROVIDER_NOT_REGISTERED = "7"; // 'Pool addresses provider is not registered'
    string public constant INVALID_ADDRESSES_PROVIDER_ID = "8"; // 'Invalid id for the pool addresses provider'
    string public constant NOT_CONTRACT = "9"; // 'Address is not a contract'
    string public constant CALLER_NOT_POOL_CONFIGURATOR = "10"; // 'The caller of the function is not the pool configurator'
    string public constant CALLER_NOT_XTOKEN = "11"; // 'The caller of the function is not an OToken'
    string public constant INVALID_ADDRESSES_PROVIDER = "12"; // 'The address of the pool addresses provider is invalid'
    string public constant INVALID_FLASHLOAN_EXECUTOR_RETURN = "13"; // 'Invalid return value of the flashloan executor function'
    string public constant RESERVE_ALREADY_ADDED = "14"; // 'Reserve has already been added to reserve list'
    string public constant NO_MORE_RESERVES_ALLOWED = "15"; // 'Maximum amount of reserves in the pool reached'
    string public constant EMODE_CATEGORY_RESERVED = "16"; // 'Zero eMode category is reserved for volatile heterogeneous assets'
    string public constant INVALID_EMODE_CATEGORY_ASSIGNMENT = "17"; // 'Invalid eMode category assignment to asset'
    string public constant RESERVE_LIQUIDITY_NOT_ZERO = "18"; // 'The liquidity of the reserve needs to be 0'
    string public constant FLASHLOAN_PREMIUM_INVALID = "19"; // 'Invalid flashloan premium'
    string public constant INVALID_RESERVE_PARAMS = "20"; // 'Invalid risk parameters for the reserve'
    string public constant INVALID_EMODE_CATEGORY_PARAMS = "21"; // 'Invalid risk parameters for the eMode category'
    string public constant BRIDGE_PROTOCOL_FEE_INVALID = "22"; // 'Invalid bridge protocol fee'
    string public constant CALLER_MUST_BE_POOL = "23"; // 'The caller of this function must be a pool'
    string public constant INVALID_MINT_AMOUNT = "24"; // 'Invalid amount to mint'
    string public constant INVALID_BURN_AMOUNT = "25"; // 'Invalid amount to burn'
    string public constant INVALID_AMOUNT = "26"; // 'Amount must be greater than 0'
    string public constant RESERVE_INACTIVE = "27"; // 'Action requires an active reserve'
    string public constant RESERVE_FROZEN = "28"; // 'Action cannot be performed because the reserve is frozen'
    string public constant RESERVE_PAUSED = "29"; // 'Action cannot be performed because the reserve is paused'
    string public constant BORROWING_NOT_ENABLED = "30"; // 'Borrowing is not enabled'
    string public constant STABLE_BORROWING_NOT_ENABLED = "31"; // 'Stable borrowing is not enabled'
    string public constant NOT_ENOUGH_AVAILABLE_USER_BALANCE = "32"; // 'User cannot withdraw more than the available balance'
    string public constant INVALID_INTEREST_RATE_MODE_SELECTED = "33"; // 'Invalid interest rate mode selected'
    string public constant COLLATERAL_BALANCE_IS_ZERO = "34"; // 'The collateral balance is 0'
    string public constant HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD =
        "35"; // 'Health factor is lesser than the liquidation threshold'
    string public constant COLLATERAL_CANNOT_COVER_NEW_BORROW = "36"; // 'There is not enough collateral to cover a new borrow'
    string public constant COLLATERAL_SAME_AS_BORROWING_CURRENCY = "37"; // 'Collateral is (mostly) the same currency that is being borrowed'
    string public constant AMOUNT_BIGGER_THAN_MAX_LOAN_SIZE_STABLE = "38"; // 'The requested amount is greater than the max loan size in stable rate mode'
    string public constant NO_DEBT_OF_SELECTED_TYPE = "39"; // 'For repayment of a specific type of debt, the user needs to have debt that type'
    string public constant NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF = "40"; // 'To repay on behalf of a user an explicit amount to repay is needed'
    string public constant NO_OUTSTANDING_STABLE_DEBT = "41"; // 'User does not have outstanding stable rate debt on this reserve'
    string public constant NO_OUTSTANDING_VARIABLE_DEBT = "42"; // 'User does not have outstanding variable rate debt on this reserve'
    string public constant UNDERLYING_BALANCE_ZERO = "43"; // 'The underlying balance needs to be greater than 0'
    string public constant INTEREST_RATE_REBALANCE_CONDITIONS_NOT_MET = "44"; // 'Interest rate rebalance conditions were not met'
    string public constant HEALTH_FACTOR_NOT_BELOW_THRESHOLD = "45"; // 'Health factor is not below the threshold'
    string public constant COLLATERAL_CANNOT_BE_LIQUIDATED = "46"; // 'The collateral chosen cannot be liquidated'
    string public constant SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER = "47"; // 'User did not borrow the specified currency'
    string public constant SAME_BLOCK_BORROW_REPAY = "48"; // 'Borrow and repay in same block is not allowed'
    string public constant INCONSISTENT_FLASHLOAN_PARAMS = "49"; // 'Inconsistent flashloan parameters'
    string public constant BORROW_CAP_EXCEEDED = "50"; // 'Borrow cap is exceeded'
    string public constant SUPPLY_CAP_EXCEEDED = "51"; // 'Supply cap is exceeded'
    string public constant UNBACKED_MINT_CAP_EXCEEDED = "52"; // 'Unbacked mint cap is exceeded'
    string public constant DEBT_CEILING_EXCEEDED = "53"; // 'Debt ceiling is exceeded'
    string public constant XTOKEN_SUPPLY_NOT_ZERO = "54"; // 'OToken supply is not zero'
    string public constant STABLE_DEBT_NOT_ZERO = "55"; // 'Stable debt supply is not zero'
    string public constant VARIABLE_DEBT_SUPPLY_NOT_ZERO = "56"; // 'Variable debt supply is not zero'
    string public constant LTV_VALIDATION_FAILED = "57"; // 'Ltv validation failed'
    string public constant INCONSISTENT_EMODE_CATEGORY = "58"; // 'Inconsistent eMode category'
    string public constant PRICE_ORACLE_SENTINEL_CHECK_FAILED = "59"; // 'Price oracle sentinel validation failed'
    string public constant ASSET_NOT_BORROWABLE_IN_ISOLATION = "60"; // 'Asset is not borrowable in isolation mode'
    string public constant RESERVE_ALREADY_INITIALIZED = "61"; // 'Reserve has already been initialized'
    string public constant USER_IN_ISOLATION_MODE = "62"; // 'User is in isolation mode'
    string public constant INVALID_LTV = "63"; // 'Invalid ltv parameter for the reserve'
    string public constant INVALID_LIQ_THRESHOLD = "64"; // 'Invalid liquidity threshold parameter for the reserve'
    string public constant INVALID_LIQ_BONUS = "65"; // 'Invalid liquidity bonus parameter for the reserve'
    string public constant INVALID_DECIMALS = "66"; // 'Invalid decimals parameter of the underlying asset of the reserve'
    string public constant INVALID_RESERVE_FACTOR = "67"; // 'Invalid reserve factor parameter for the reserve'
    string public constant INVALID_BORROW_CAP = "68"; // 'Invalid borrow cap for the reserve'
    string public constant INVALID_SUPPLY_CAP = "69"; // 'Invalid supply cap for the reserve'
    string public constant INVALID_LIQUIDATION_PROTOCOL_FEE = "70"; // 'Invalid liquidation protocol fee for the reserve'
    string public constant INVALID_EMODE_CATEGORY = "71"; // 'Invalid eMode category for the reserve'
    string public constant INVALID_UNBACKED_MINT_CAP = "72"; // 'Invalid unbacked mint cap for the reserve'
    string public constant INVALID_DEBT_CEILING = "73"; // 'Invalid debt ceiling for the reserve
    string public constant INVALID_RESERVE_INDEX = "74"; // 'Invalid reserve index'
    string public constant ACL_ADMIN_CANNOT_BE_ZERO = "75"; // 'ACL admin cannot be set to the zero address'
    string public constant INCONSISTENT_PARAMS_LENGTH = "76"; // 'Array parameters that should be equal length are not'
    string public constant ZERO_ADDRESS_NOT_VALID = "77"; // 'Zero address not valid'
    string public constant INVALID_EXPIRATION = "78"; // 'Invalid expiration'
    string public constant INVALID_SIGNATURE = "79"; // 'Invalid signature'
    string public constant OPERATION_NOT_SUPPORTED = "80"; // 'Operation not supported'
    string public constant DEBT_CEILING_NOT_ZERO = "81"; // 'Debt ceiling is not zero'
    string public constant ASSET_NOT_LISTED = "82"; // 'Asset is not listed'
    string public constant INVALID_OPTIMAL_USAGE_RATIO = "83"; // 'Invalid optimal usage ratio'
    string public constant INVALID_OPTIMAL_STABLE_TO_TOTAL_DEBT_RATIO = "84"; // 'Invalid optimal stable to total debt ratio'
    string public constant UNDERLYING_CANNOT_BE_RESCUED = "85"; // 'The underlying asset cannot be rescued'
    string public constant ADDRESSES_PROVIDER_ALREADY_ADDED = "86"; // 'Reserve has already been added to reserve list'
    string public constant POOL_ADDRESSES_DO_NOT_MATCH = "87"; // 'The token implementation pool address and the pool address provided by the initializing pool do not match'
    string public constant STABLE_BORROWING_ENABLED = "88"; // 'Stable borrowing is enabled'
    string public constant SILOED_BORROWING_VIOLATION = "89"; // 'User is trying to borrow multiple assets including a siloed one'
    string public constant RESERVE_DEBT_NOT_ZERO = "90"; // the total debt of the reserve needs to be 0
    string public constant NOT_THE_OWNER = "91"; // user is not the owner of a given asset
    string public constant LIQUIDATION_AMOUNT_NOT_ENOUGH = "92";
    string public constant INVALID_ASSET_TYPE = "93"; // invalid asset type for action.
    string public constant INVALID_FLASH_CLAIM_RECEIVER = "94"; // invalid flash claim receiver.
    string public constant ERC721_HEALTH_FACTOR_NOT_BELOW_THRESHOLD = "95"; // 'ERC721 Health factor is not below the threshold. Can only liquidate ERC20'
    string public constant UNDERLYING_ASSET_CAN_NOT_BE_TRANSFERRED = "96"; //underlying asset can not be transferred.
    string public constant TOKEN_TRANSFERRED_CAN_NOT_BE_SELF_ADDRESS = "97"; //token transferred can not be self address.
    string public constant INVALID_AIRDROP_CONTRACT_ADDRESS = "98"; //invalid airdrop contract address.
    string public constant INVALID_AIRDROP_PARAMETERS = "99"; //invalid airdrop parameters.
    string public constant CALL_AIRDROP_METHOD_FAILED = "100"; //call airdrop method failed.
}// AGPL-3.0
pragma solidity 0.8.10;

interface IRewardController {

    event RewardsAccrued(address indexed user, uint256 amount);

    event RewardsClaimed(
        address indexed user,
        address indexed to,
        uint256 amount
    );

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


    function assets(address asset)
        external
        view
        returns (
            uint128,
            uint128,
            uint256
        );


    function setClaimer(address user, address claimer) external;


    function getClaimer(address user) external view returns (address);


    function configureAssets(
        address[] calldata assets,
        uint256[] calldata emissionsPerSecond
    ) external;


    function handleAction(
        address asset,
        uint256 totalSupply,
        uint256 userBalance
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


    function getUserUnclaimedRewards(address user)
        external
        view
        returns (uint256);


    function getUserAssetData(address user, address asset)
        external
        view
        returns (uint256);


    function REWARD_TOKEN() external view returns (address);


    function PRECISION() external view returns (uint8);


    function DISTRIBUTION_END() external view returns (uint256);

}// AGPL-3.0
pragma solidity 0.8.10;

interface IPoolAddressesProvider {

    event MarketIdSet(string indexed oldMarketId, string indexed newMarketId);

    event PoolUpdated(address indexed oldAddress, address indexed newAddress);

    event PoolConfiguratorUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event PriceOracleUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event ACLManagerUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event ACLAdminUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event PriceOracleSentinelUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event PoolDataProviderUpdated(
        address indexed oldAddress,
        address indexed newAddress
    );

    event ProxyCreated(
        bytes32 indexed id,
        address indexed proxyAddress,
        address indexed implementationAddress
    );

    event AddressSet(
        bytes32 indexed id,
        address indexed oldAddress,
        address indexed newAddress
    );

    event AddressSetAsProxy(
        bytes32 indexed id,
        address indexed proxyAddress,
        address oldImplementationAddress,
        address indexed newImplementationAddress
    );

    function getMarketId() external view returns (string memory);


    function setMarketId(string calldata newMarketId) external;


    function getAddress(bytes32 id) external view returns (address);


    function setAddressAsProxy(bytes32 id, address newImplementationAddress)
        external;


    function setAddress(bytes32 id, address newAddress) external;


    function getPool() external view returns (address);


    function setPoolImpl(address newPoolImpl) external;


    function getPoolConfigurator() external view returns (address);


    function setPoolConfiguratorImpl(address newPoolConfiguratorImpl) external;


    function getPriceOracle() external view returns (address);


    function setPriceOracle(address newPriceOracle) external;


    function getACLManager() external view returns (address);


    function setACLManager(address newAclManager) external;


    function getACLAdmin() external view returns (address);


    function setACLAdmin(address newAclAdmin) external;


    function getPriceOracleSentinel() external view returns (address);


    function setPriceOracleSentinel(address newPriceOracleSentinel) external;


    function getPoolDataProvider() external view returns (address);


    function setPoolDataProvider(address newDataProvider) external;

}// BUSL-1.1
pragma solidity 0.8.10;

library DataTypes {

    enum AssetType {
        ERC20,
        ERC721,
        ERC1155
    }

    struct ReserveData {
        ReserveConfigurationMap configuration;
        uint128 liquidityIndex;
        uint128 currentLiquidityRate;
        uint128 variableBorrowIndex;
        uint128 currentVariableBorrowRate;
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
        uint16 id;
        AssetType assetType;
        address xTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        address interestRateStrategyAddress;
        uint128 accruedToTreasury;
    }

    struct ReserveConfigurationMap {

        uint256 data;
    }

    struct UserConfigurationMap {
        uint256 data;
    }

    struct ERC721SupplyParams {
        uint256 tokenId;
        bool useAsCollateral;
    }

    enum InterestRateMode {
        NONE,
        STABLE,
        VARIABLE
    }

    struct ReserveCache {
        AssetType assetType;
        uint256 currScaledVariableDebt;
        uint256 nextScaledVariableDebt;
        uint256 currPrincipalStableDebt;
        uint256 currAvgStableBorrowRate;
        uint256 currTotalStableDebt;
        uint256 nextAvgStableBorrowRate;
        uint256 nextTotalStableDebt;
        uint256 currLiquidityIndex;
        uint256 nextLiquidityIndex;
        uint256 currVariableBorrowIndex;
        uint256 nextVariableBorrowIndex;
        uint256 currLiquidityRate;
        uint256 currVariableBorrowRate;
        uint256 reserveFactor;
        ReserveConfigurationMap reserveConfiguration;
        address xTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        uint40 reserveLastUpdateTimestamp;
        uint40 stableDebtLastUpdateTimestamp;
    }



    struct ExecuteLiquidationCallParams {
        uint256 reservesCount;
        uint256 liquidationAmount;
        uint256 collateralTokenId;
        address collateralAsset;
        address liquidationAsset;
        address user;
        bool receiveXToken;
        address priceOracle;
        address priceOracleSentinel;
    }

    struct ExecuteSupplyParams {
        address asset;
        uint256 amount;
        address onBehalfOf;
        uint16 referralCode;
    }

    struct ExecuteSupplyERC721Params {
        address asset;
        DataTypes.ERC721SupplyParams[] tokenData;
        address onBehalfOf;
        uint16 referralCode;
    }

    struct ExecuteBorrowParams {
        address asset;
        address user;
        address onBehalfOf;
        uint256 amount;
        InterestRateMode interestRateMode;
        uint16 referralCode;
        bool releaseUnderlying;
        uint256 maxStableRateBorrowSizePercent;
        uint256 reservesCount;
        address oracle;
        address priceOracleSentinel;
    }

    struct ExecuteRepayParams {
        address asset;
        uint256 amount;
        InterestRateMode interestRateMode;
        address onBehalfOf;
        bool useOTokens;
    }

    struct ExecuteWithdrawParams {
        address asset;
        uint256 amount;
        address to;
        uint256 reservesCount;
        address oracle;
    }

    struct ExecuteWithdrawERC721Params {
        address asset;
        uint256[] tokenIds;
        address to;
        uint256 reservesCount;
        address oracle;
    }

    struct FinalizeTransferParams {
        address asset;
        address from;
        address to;
        bool usedAsCollateral;
        uint256 value;
        uint256 balanceFromBefore;
        uint256 balanceToBefore;
        uint256 reservesCount;
        address oracle;
    }

    struct CalculateUserAccountDataParams {
        UserConfigurationMap userConfig;
        uint256 reservesCount;
        address user;
        address oracle;
    }

    struct ValidateBorrowParams {
        ReserveCache reserveCache;
        UserConfigurationMap userConfig;
        address asset;
        address userAddress;
        uint256 amount;
        InterestRateMode interestRateMode;
        uint256 maxStableLoanPercent;
        uint256 reservesCount;
        address oracle;
        address priceOracleSentinel;
        AssetType assetType;
    }

    struct ValidateLiquidationCallParams {
        ReserveCache debtReserveCache;
        uint256 totalDebt;
        uint256 healthFactor;
        address priceOracleSentinel;
        AssetType assetType;
    }

    struct ValidateERC721LiquidationCallParams {
        ReserveCache debtReserveCache;
        uint256 totalDebt;
        uint256 healthFactor;
        uint256 tokenId;
        uint256 collateralDiscountedPrice;
        uint256 liquidationAmount;
        address priceOracleSentinel;
        address xTokenAddress;
        AssetType assetType;
    }

    struct CalculateInterestRatesParams {
        uint256 liquidityAdded;
        uint256 liquidityTaken;
        uint256 totalStableDebt;
        uint256 totalVariableDebt;
        uint256 averageStableBorrowRate;
        uint256 reserveFactor;
        address reserve;
        address xToken;
    }

    struct InitReserveParams {
        address asset;
        AssetType assetType;
        address xTokenAddress;
        address stableDebtAddress;
        address variableDebtAddress;
        address interestRateStrategyAddress;
        uint16 reservesCount;
        uint16 maxNumberReserves;
    }

    struct ExecuteFlashClaimParams {
        address receiverAddress;
        address nftAsset;
        uint256[] nftTokenIds;
        bytes params;
    }
}// AGPL-3.0
pragma solidity 0.8.10;


interface IPool {

    event Supply(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 indexed referralCode
    );

    event SupplyERC721(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        DataTypes.ERC721SupplyParams[] tokenData,
        uint16 indexed referralCode
    );

    event Withdraw(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256 amount
    );

    event WithdrawERC721(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256[] tokenIds
    );

    event Borrow(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        DataTypes.InterestRateMode interestRateMode,
        uint256 borrowRate,
        uint16 indexed referralCode
    );

    event Repay(
        address indexed reserve,
        address indexed user,
        address indexed repayer,
        uint256 amount,
        bool useOTokens
    );

    event SwapBorrowRateMode(
        address indexed reserve,
        address indexed user,
        DataTypes.InterestRateMode interestRateMode
    );

    event ReserveUsedAsCollateralEnabled(
        address indexed reserve,
        address indexed user
    );

    event ReserveUsedAsCollateralDisabled(
        address indexed reserve,
        address indexed user
    );

    event RebalanceStableBorrowRate(
        address indexed reserve,
        address indexed user
    );

    event LiquidationCall(
        address indexed collateralAsset,
        address indexed debtAsset,
        address indexed user,
        uint256 debtToCover,
        uint256 liquidatedCollateralAmount,
        address liquidator,
        bool receiveOToken
    );

    event ReserveDataUpdated(
        address indexed reserve,
        uint256 liquidityRate,
        uint256 stableBorrowRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );

    event MintedToTreasury(address indexed reserve, uint256 amountMinted);

    event FlashClaim(
        address indexed target,
        address indexed initiator,
        address indexed nftAsset,
        uint256 tokenId
    );

    function flashClaim(
        address receiverAddress,
        address nftAsset,
        uint256[] calldata nftTokenIds,
        bytes calldata params
    ) external;


    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function supplyERC721(
        address asset,
        DataTypes.ERC721SupplyParams[] calldata tokenData,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function supplyWithPermit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external;


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);


    function withdrawERC721(
        address asset,
        uint256[] calldata tokenIds,
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
        uint256 interestRateMode,
        address onBehalfOf
    ) external returns (uint256);


    function repayWithPermit(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external returns (uint256);


    function repayWithOTokens(
        address asset,
        uint256 amount,
        uint256 interestRateMode
    ) external returns (uint256);


    function swapBorrowRateMode(address asset, uint256 interestRateMode)
        external;


    function rebalanceStableBorrowRate(address asset, address user) external;


    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral)
        external;


    function setUserUseERC721AsCollateral(
        address asset,
        uint256 tokenId,
        bool useAsCollateral
    ) external virtual;


    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveOToken
    ) external;


    function liquidationERC721(
        address collateralAsset,
        address liquidationAsset,
        address user,
        uint256 collateralTokenId,
        uint256 liquidationAmount,
        bool receiveNToken
    ) external;


    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor,
            uint256 erc721HealthFactor
        );


    function initReserve(
        address asset,
        DataTypes.AssetType assetType,
        address xTokenAddress,
        address stableDebtAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress
    ) external;


    function dropReserve(address asset) external;


    function setReserveInterestRateStrategyAddress(
        address asset,
        address rateStrategyAddress
    ) external;


    function setConfiguration(
        address asset,
        DataTypes.ReserveConfigurationMap calldata configuration
    ) external;


    function getConfiguration(address asset)
        external
        view
        returns (DataTypes.ReserveConfigurationMap memory);


    function getUserConfiguration(address user)
        external
        view
        returns (DataTypes.UserConfigurationMap memory);


    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256);


    function getReserveNormalizedVariableDebt(address asset)
        external
        view
        returns (uint256);


    function getReserveData(address asset)
        external
        view
        returns (DataTypes.ReserveData memory);


    function finalizeTransfer(
        address asset,
        address from,
        address to,
        bool usedAsCollateral,
        uint256 amount,
        uint256 balanceFromBefore,
        uint256 balanceToBefore
    ) external;


    function getReservesList() external view returns (address[] memory);


    function getReserveAddressById(uint16 id) external view returns (address);


    function ADDRESSES_PROVIDER()
        external
        view
        returns (IPoolAddressesProvider);


    function MAX_STABLE_RATE_BORROW_SIZE_PERCENT()
        external
        view
        returns (uint256);


    function MAX_NUMBER_RESERVES() external view returns (uint16);


    function mintToTreasury(address[] calldata assets) external;


    function rescueTokens(
        address token,
        address to,
        uint256 amount
    ) external;

}// AGPL-3.0
pragma solidity 0.8.10;


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
        IPool pool,
        address underlyingAsset,
        IRewardController incentivesController,
        uint8 debtTokenDecimals,
        string memory debtTokenName,
        string memory debtTokenSymbol,
        bytes calldata params
    ) external;

}// AGPL-3.0
pragma solidity 0.8.10;


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
        address indexed from,
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
    )
        external
        returns (
            bool,
            uint256,
            uint256
        );


    function burn(address from, uint256 amount)
        external
        returns (uint256, uint256);


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


    function getTotalSupplyAndAvgRate()
        external
        view
        returns (uint256, uint256);


    function principalBalanceOf(address user) external view returns (uint256);


    function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// agpl-3.0
pragma solidity 0.8.10;

abstract contract EIP712Base {
    bytes public constant EIP712_REVISION = bytes("1");
    bytes32 internal constant EIP712_DOMAIN =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    mapping(address => uint256) internal _nonces;

    bytes32 internal _domainSeparator;
    uint256 internal immutable _chainId;

    constructor() {
        _chainId = block.chainid;
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        if (block.chainid == _chainId) {
            return _domainSeparator;
        }
        return _calculateDomainSeparator();
    }

    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    function _calculateDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN,
                    keccak256(bytes(_EIP712BaseId())),
                    keccak256(EIP712_REVISION),
                    block.chainid,
                    address(this)
                )
            );
    }

    function _EIP712BaseId() internal view virtual returns (string memory);
}// MIT
pragma solidity 0.8.10;

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}// AGPL-3.0
pragma solidity 0.8.10;

interface ICreditDelegationToken {

    event BorrowAllowanceDelegated(
        address indexed fromUser,
        address indexed toUser,
        address indexed asset,
        uint256 amount
    );

    function approveDelegation(address delegatee, uint256 amount) external;


    function borrowAllowance(address fromUser, address toUser)
        external
        view
        returns (uint256);


    function delegationWithSig(
        address delegator,
        address delegatee,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// BUSL-1.1
pragma solidity 0.8.10;


abstract contract DebtTokenBase is
    VersionedInitializable,
    EIP712Base,
    Context,
    ICreditDelegationToken
{
    mapping(address => mapping(address => uint256)) internal _borrowAllowances;

    bytes32 public constant DELEGATION_WITH_SIG_TYPEHASH =
        keccak256(
            "DelegationWithSig(address delegatee,uint256 value,uint256 nonce,uint256 deadline)"
        );

    address internal _underlyingAsset;

    constructor() EIP712Base() {
    }

    function approveDelegation(address delegatee, uint256 amount)
        external
        override
    {
        _approveDelegation(_msgSender(), delegatee, amount);
    }

    function delegationWithSig(
        address delegator,
        address delegatee,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(delegator != address(0), Errors.ZERO_ADDRESS_NOT_VALID);
        require(block.timestamp <= deadline, Errors.INVALID_EXPIRATION);
        uint256 currentValidNonce = _nonces[delegator];
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        DELEGATION_WITH_SIG_TYPEHASH,
                        delegatee,
                        value,
                        currentValidNonce,
                        deadline
                    )
                )
            )
        );
        require(
            delegator == ecrecover(digest, v, r, s),
            Errors.INVALID_SIGNATURE
        );
        _nonces[delegator] = currentValidNonce + 1;
        _approveDelegation(delegator, delegatee, value);
    }

    function borrowAllowance(address fromUser, address toUser)
        external
        view
        override
        returns (uint256)
    {
        return _borrowAllowances[fromUser][toUser];
    }

    function _approveDelegation(
        address delegator,
        address delegatee,
        uint256 amount
    ) internal {
        _borrowAllowances[delegator][delegatee] = amount;
        emit BorrowAllowanceDelegated(
            delegator,
            delegatee,
            _underlyingAsset,
            amount
        );
    }

    function _decreaseBorrowAllowance(
        address delegator,
        address delegatee,
        uint256 amount
    ) internal {
        uint256 newAllowance = _borrowAllowances[delegator][delegatee] - amount;

        _borrowAllowances[delegator][delegatee] = newAllowance;

        emit BorrowAllowanceDelegated(
            delegator,
            delegatee,
            _underlyingAsset,
            newAllowance
        );
    }
}// agpl-3.0
pragma solidity 0.8.10;


interface IERC20Detailed is IERC20 {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);

}// MIT
pragma solidity 0.8.10;

library SafeCast {

  function toUint224(uint256 value) internal pure returns (uint224) {

    require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
    return uint224(value);
  }

  function toUint128(uint256 value) internal pure returns (uint128) {

    require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
    return uint128(value);
  }

  function toUint96(uint256 value) internal pure returns (uint96) {

    require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
    return uint96(value);
  }

  function toUint64(uint256 value) internal pure returns (uint64) {

    require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
    return uint64(value);
  }

  function toUint32(uint256 value) internal pure returns (uint32) {

    require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
    return uint32(value);
  }

  function toUint16(uint256 value) internal pure returns (uint16) {

    require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
    return uint16(value);
  }

  function toUint8(uint256 value) internal pure returns (uint8) {

    require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
    return uint8(value);
  }

  function toUint256(int256 value) internal pure returns (uint256) {

    require(value >= 0, 'SafeCast: value must be positive');
    return uint256(value);
  }

  function toInt128(int256 value) internal pure returns (int128) {

    require(
      value >= type(int128).min && value <= type(int128).max,
      "SafeCast: value doesn't fit in 128 bits"
    );
    return int128(value);
  }

  function toInt64(int256 value) internal pure returns (int64) {

    require(
      value >= type(int64).min && value <= type(int64).max,
      "SafeCast: value doesn't fit in 64 bits"
    );
    return int64(value);
  }

  function toInt32(int256 value) internal pure returns (int32) {

    require(
      value >= type(int32).min && value <= type(int32).max,
      "SafeCast: value doesn't fit in 32 bits"
    );
    return int32(value);
  }

  function toInt16(int256 value) internal pure returns (int16) {

    require(
      value >= type(int16).min && value <= type(int16).max,
      "SafeCast: value doesn't fit in 16 bits"
    );
    return int16(value);
  }

  function toInt8(int256 value) internal pure returns (int8) {

    require(
      value >= type(int8).min && value <= type(int8).max,
      "SafeCast: value doesn't fit in 8 bits"
    );
    return int8(value);
  }

  function toInt256(uint256 value) internal pure returns (int256) {

    require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
    return int256(value);
  }
}// AGPL-3.0
pragma solidity 0.8.10;


interface IACLManager {

    function ADDRESSES_PROVIDER()
        external
        view
        returns (IPoolAddressesProvider);


    function POOL_ADMIN_ROLE() external view returns (bytes32);


    function EMERGENCY_ADMIN_ROLE() external view returns (bytes32);


    function RISK_ADMIN_ROLE() external view returns (bytes32);


    function FLASH_BORROWER_ROLE() external view returns (bytes32);


    function BRIDGE_ROLE() external view returns (bytes32);


    function ASSET_LISTING_ADMIN_ROLE() external view returns (bytes32);


    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;


    function addPoolAdmin(address admin) external;


    function removePoolAdmin(address admin) external;


    function isPoolAdmin(address admin) external view returns (bool);


    function addEmergencyAdmin(address admin) external;


    function removeEmergencyAdmin(address admin) external;


    function isEmergencyAdmin(address admin) external view returns (bool);


    function addRiskAdmin(address admin) external;


    function removeRiskAdmin(address admin) external;


    function isRiskAdmin(address admin) external view returns (bool);


    function addFlashBorrower(address borrower) external;


    function removeFlashBorrower(address borrower) external;


    function isFlashBorrower(address borrower) external view returns (bool);


    function addBridge(address bridge) external;


    function removeBridge(address bridge) external;


    function isBridge(address bridge) external view returns (bool);


    function addAssetListingAdmin(address admin) external;


    function removeAssetListingAdmin(address admin) external;


    function isAssetListingAdmin(address admin) external view returns (bool);

}// BUSL-1.1
pragma solidity 0.8.10;


abstract contract IncentivizedERC20 is Context, IERC20Detailed {
    using WadRayMath for uint256;
    using SafeCast for uint256;

    modifier onlyPoolAdmin() {
        IACLManager aclManager = IACLManager(
            _addressesProvider.getACLManager()
        );
        require(
            aclManager.isPoolAdmin(msg.sender),
            Errors.CALLER_NOT_POOL_ADMIN
        );
        _;
    }

    modifier onlyPool() {
        require(_msgSender() == address(POOL), Errors.CALLER_MUST_BE_POOL);
        _;
    }

    struct UserState {
        uint128 balance;
        uint128 additionalData;
    }
    mapping(address => UserState) internal _userState;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    IRewardController internal _rewardController;
    IPoolAddressesProvider internal immutable _addressesProvider;
    IPool public immutable POOL;

    constructor(
        IPool pool,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) {
        _addressesProvider = pool.ADDRESSES_PROVIDER();
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        POOL = pool;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _userState[account].balance;
    }

    function getIncentivesController()
        external
        view
        virtual
        returns (IRewardController)
    {
        return _rewardController;
    }

    function setIncentivesController(IRewardController controller)
        external
        onlyPoolAdmin
    {
        _rewardController = controller;
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        uint128 castAmount = amount.toUint128();
        _transfer(_msgSender(), recipient, castAmount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        uint128 castAmount = amount.toUint128();
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - castAmount
        );
        _transfer(sender, recipient, castAmount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint128 amount
    ) internal virtual {
        uint128 oldSenderBalance = _userState[sender].balance;
        _userState[sender].balance = oldSenderBalance - amount;
        uint128 oldRecipientBalance = _userState[recipient].balance;
        _userState[recipient].balance = oldRecipientBalance + amount;

        IRewardController rewardControllerLocal = _rewardController;
        if (address(rewardControllerLocal) != address(0)) {
            uint256 currentTotalSupply = _totalSupply;
            rewardControllerLocal.handleAction(
                sender,
                currentTotalSupply,
                oldSenderBalance
            );
            if (sender != recipient) {
                rewardControllerLocal.handleAction(
                    recipient,
                    currentTotalSupply,
                    oldRecipientBalance
                );
            }
        }
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
}// BUSL-1.1
pragma solidity 0.8.10;


contract StableDebtToken is DebtTokenBase, IncentivizedERC20, IStableDebtToken {

    using WadRayMath for uint256;
    using SafeCast for uint256;

    uint256 public constant DEBT_TOKEN_REVISION = 0x1;

    mapping(address => uint40) internal _timestamps;

    uint128 internal _avgStableRate;

    uint40 internal _totalSupplyTimestamp;

    constructor(IPool pool)
        DebtTokenBase()
        IncentivizedERC20(
            pool,
            "STABLE_DEBT_TOKEN_IMPL",
            "STABLE_DEBT_TOKEN_IMPL",
            0
        )
    {
    }

    function initialize(
        IPool initializingPool,
        address underlyingAsset,
        IRewardController incentivesController,
        uint8 debtTokenDecimals,
        string memory debtTokenName,
        string memory debtTokenSymbol,
        bytes calldata params
    ) external override initializer {

        require(initializingPool == POOL, Errors.POOL_ADDRESSES_DO_NOT_MATCH);
        _setName(debtTokenName);
        _setSymbol(debtTokenSymbol);
        _setDecimals(debtTokenDecimals);

        _underlyingAsset = underlyingAsset;
        _rewardController = incentivesController;

        _domainSeparator = _calculateDomainSeparator();

        emit Initialized(
            underlyingAsset,
            address(POOL),
            address(incentivesController),
            debtTokenDecimals,
            debtTokenName,
            debtTokenSymbol,
            params
        );
    }

    function getRevision() internal pure virtual override returns (uint256) {

        return DEBT_TOKEN_REVISION;
    }

    function getAverageStableRate()
        external
        view
        virtual
        override
        returns (uint256)
    {

        return _avgStableRate;
    }

    function getUserLastUpdated(address user)
        external
        view
        virtual
        override
        returns (uint40)
    {

        return _timestamps[user];
    }

    function getUserStableRate(address user)
        external
        view
        virtual
        override
        returns (uint256)
    {

        return _userState[user].additionalData;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        uint256 accountBalance = super.balanceOf(account);
        uint256 stableRate = _userState[account].additionalData;
        if (accountBalance == 0) {
            return 0;
        }
        uint256 cumulatedInterest = MathUtils.calculateCompoundedInterest(
            stableRate,
            _timestamps[account]
        );
        return accountBalance.rayMul(cumulatedInterest);
    }

    struct MintLocalVars {
        uint256 previousSupply;
        uint256 nextSupply;
        uint256 amountInRay;
        uint256 currentStableRate;
        uint256 nextStableRate;
        uint256 currentAvgStableRate;
    }

    function mint(
        address user,
        address onBehalfOf,
        uint256 amount,
        uint256 rate
    )
        external
        virtual
        override
        onlyPool
        returns (
            bool,
            uint256,
            uint256
        )
    {

        MintLocalVars memory vars;

        if (user != onBehalfOf) {
            _decreaseBorrowAllowance(onBehalfOf, user, amount);
        }

        (
            ,
            uint256 currentBalance,
            uint256 balanceIncrease
        ) = _calculateBalanceIncrease(onBehalfOf);

        vars.previousSupply = totalSupply();
        vars.currentAvgStableRate = _avgStableRate;
        vars.nextSupply = _totalSupply = vars.previousSupply + amount;

        vars.amountInRay = amount.wadToRay();

        vars.currentStableRate = _userState[onBehalfOf].additionalData;
        vars.nextStableRate = (vars.currentStableRate.rayMul(
            currentBalance.wadToRay()
        ) + vars.amountInRay.rayMul(rate)).rayDiv(
                (currentBalance + amount).wadToRay()
            );

        _userState[onBehalfOf].additionalData = vars.nextStableRate.toUint128();

        _totalSupplyTimestamp = _timestamps[onBehalfOf] = uint40(
            block.timestamp
        );

        vars.currentAvgStableRate = _avgStableRate = (
            (vars.currentAvgStableRate.rayMul(vars.previousSupply.wadToRay()) +
                rate.rayMul(vars.amountInRay)).rayDiv(
                    vars.nextSupply.wadToRay()
                )
        ).toUint128();

        uint256 amountToMint = amount + balanceIncrease;
        _mint(onBehalfOf, amountToMint, vars.previousSupply);

        emit Transfer(address(0), onBehalfOf, amountToMint);
        emit Mint(
            user,
            onBehalfOf,
            amountToMint,
            currentBalance,
            balanceIncrease,
            vars.nextStableRate,
            vars.currentAvgStableRate,
            vars.nextSupply
        );

        return (
            currentBalance == 0,
            vars.nextSupply,
            vars.currentAvgStableRate
        );
    }

    function burn(address from, uint256 amount)
        external
        virtual
        override
        onlyPool
        returns (uint256, uint256)
    {

        (
            ,
            uint256 currentBalance,
            uint256 balanceIncrease
        ) = _calculateBalanceIncrease(from);

        uint256 previousSupply = totalSupply();
        uint256 nextAvgStableRate = 0;
        uint256 nextSupply = 0;
        uint256 userStableRate = _userState[from].additionalData;

        if (previousSupply <= amount) {
            _avgStableRate = 0;
            _totalSupply = 0;
        } else {
            nextSupply = _totalSupply = previousSupply - amount;
            uint256 firstTerm = uint256(_avgStableRate).rayMul(
                previousSupply.wadToRay()
            );
            uint256 secondTerm = userStableRate.rayMul(amount.wadToRay());

            if (secondTerm >= firstTerm) {
                nextAvgStableRate = _totalSupply = _avgStableRate = 0;
            } else {
                nextAvgStableRate = _avgStableRate = (
                    (firstTerm - secondTerm).rayDiv(nextSupply.wadToRay())
                ).toUint128();
            }
        }

        if (amount == currentBalance) {
            _userState[from].additionalData = 0;
            _timestamps[from] = 0;
        } else {
            _timestamps[from] = uint40(block.timestamp);
        }
        _totalSupplyTimestamp = uint40(block.timestamp);

        if (balanceIncrease > amount) {
            uint256 amountToMint = balanceIncrease - amount;
            _mint(from, amountToMint, previousSupply);
            emit Transfer(address(0), from, amountToMint);
            emit Mint(
                from,
                from,
                amountToMint,
                currentBalance,
                balanceIncrease,
                userStableRate,
                nextAvgStableRate,
                nextSupply
            );
        } else {
            uint256 amountToBurn = amount - balanceIncrease;
            _burn(from, amountToBurn, previousSupply);
            emit Transfer(from, address(0), amountToBurn);
            emit Burn(
                from,
                amountToBurn,
                currentBalance,
                balanceIncrease,
                nextAvgStableRate,
                nextSupply
            );
        }

        return (nextSupply, nextAvgStableRate);
    }

    function _calculateBalanceIncrease(address user)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 previousPrincipalBalance = super.balanceOf(user);

        if (previousPrincipalBalance == 0) {
            return (0, 0, 0);
        }

        uint256 newPrincipalBalance = balanceOf(user);

        return (
            previousPrincipalBalance,
            newPrincipalBalance,
            newPrincipalBalance - previousPrincipalBalance
        );
    }

    function getSupplyData()
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint40
        )
    {

        uint256 avgRate = _avgStableRate;
        return (
            super.totalSupply(),
            _calcTotalSupply(avgRate),
            avgRate,
            _totalSupplyTimestamp
        );
    }

    function getTotalSupplyAndAvgRate()
        external
        view
        override
        returns (uint256, uint256)
    {

        uint256 avgRate = _avgStableRate;
        return (_calcTotalSupply(avgRate), avgRate);
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _calcTotalSupply(_avgStableRate);
    }

    function getTotalSupplyLastUpdated()
        external
        view
        override
        returns (uint40)
    {

        return _totalSupplyTimestamp;
    }

    function principalBalanceOf(address user)
        external
        view
        virtual
        override
        returns (uint256)
    {

        return super.balanceOf(user);
    }

    function UNDERLYING_ASSET_ADDRESS()
        external
        view
        override
        returns (address)
    {

        return _underlyingAsset;
    }

    function _calcTotalSupply(uint256 avgRate) internal view returns (uint256) {

        uint256 principalSupply = super.totalSupply();

        if (principalSupply == 0) {
            return 0;
        }

        uint256 cumulatedInterest = MathUtils.calculateCompoundedInterest(
            avgRate,
            _totalSupplyTimestamp
        );

        return principalSupply.rayMul(cumulatedInterest);
    }

    function _mint(
        address account,
        uint256 amount,
        uint256 oldTotalSupply
    ) internal {

        uint128 castAmount = amount.toUint128();
        uint128 oldAccountBalance = _userState[account].balance;
        _userState[account].balance = oldAccountBalance + castAmount;

        if (address(_rewardController) != address(0)) {
            _rewardController.handleAction(
                account,
                oldTotalSupply,
                oldAccountBalance
            );
        }
    }

    function _burn(
        address account,
        uint256 amount,
        uint256 oldTotalSupply
    ) internal {

        uint128 castAmount = amount.toUint128();
        uint128 oldAccountBalance = _userState[account].balance;
        _userState[account].balance = oldAccountBalance - castAmount;

        if (address(_rewardController) != address(0)) {
            _rewardController.handleAction(
                account,
                oldTotalSupply,
                oldAccountBalance
            );
        }
    }

    function _EIP712BaseId() internal view override returns (string memory) {

        return name();
    }

    function transfer(address, uint256)
        external
        virtual
        override
        returns (bool)
    {

        revert(Errors.OPERATION_NOT_SUPPORTED);
    }

    function allowance(address, address)
        external
        view
        virtual
        override
        returns (uint256)
    {

        revert(Errors.OPERATION_NOT_SUPPORTED);
    }

    function approve(address, uint256)
        external
        virtual
        override
        returns (bool)
    {

        revert(Errors.OPERATION_NOT_SUPPORTED);
    }

    function transferFrom(
        address,
        address,
        uint256
    ) external virtual override returns (bool) {

        revert(Errors.OPERATION_NOT_SUPPORTED);
    }

    function increaseAllowance(address, uint256)
        external
        virtual
        override
        returns (bool)
    {

        revert(Errors.OPERATION_NOT_SUPPORTED);
    }

    function decreaseAllowance(address, uint256)
        external
        virtual
        override
        returns (bool)
    {

        revert(Errors.OPERATION_NOT_SUPPORTED);
    }
}