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

}// agpl-3.0
pragma solidity 0.8.10;

interface IRewardsDistributor {

    event AssetConfigUpdated(
        address indexed asset,
        address indexed reward,
        uint256 oldEmission,
        uint256 newEmission,
        uint256 oldDistributionEnd,
        uint256 newDistributionEnd,
        uint256 assetIndex
    );

    event Accrued(
        address indexed asset,
        address indexed reward,
        address indexed user,
        uint256 assetIndex,
        uint256 userIndex,
        uint256 rewardsAccrued
    );

    event EmissionManagerUpdated(
        address indexed oldEmissionManager,
        address indexed newEmissionManager
    );

    function setDistributionEnd(
        address asset,
        address reward,
        uint32 newDistributionEnd
    ) external;


    function setEmissionPerSecond(
        address asset,
        address[] calldata rewards,
        uint88[] calldata newEmissionsPerSecond
    ) external;


    function getDistributionEnd(address asset, address reward)
        external
        view
        returns (uint256);


    function getUserAssetIndex(
        address user,
        address asset,
        address reward
    ) external view returns (uint256);


    function getRewardsData(address asset, address reward)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function getRewardsByAsset(address asset)
        external
        view
        returns (address[] memory);


    function getRewardsList() external view returns (address[] memory);


    function getUserAccruedRewards(address user, address reward)
        external
        view
        returns (uint256);


    function getUserRewards(
        address[] calldata assets,
        address user,
        address reward
    ) external view returns (uint256);


    function getAllUserRewards(address[] calldata assets, address user)
        external
        view
        returns (address[] memory, uint256[] memory);


    function getAssetDecimals(address asset) external view returns (uint8);


    function getEmissionManager() external view returns (address);


    function setEmissionManager(address emissionManager) external;

}// AGPL-3.0
pragma solidity 0.8.10;

interface ITransferStrategyBase {

    event EmergencyWithdrawal(
        address indexed caller,
        address indexed token,
        address indexed to,
        uint256 amount
    );

    function performTransfer(
        address to,
        address reward,
        uint256 amount
    ) external returns (bool);


    function getIncentivesController() external view returns (address);


    function getRewardsAdmin() external view returns (address);


    function emergencyWithdrawal(
        address token,
        address to,
        uint256 amount
    ) external;

}// agpl-3.0
pragma solidity 0.8.10;

interface IEACAggregatorProxy {

    function decimals() external view returns (uint8);


    function latestAnswer() external view returns (int256);


    function latestTimestamp() external view returns (uint256);


    function latestRound() external view returns (uint256);


    function getAnswer(uint256 roundId) external view returns (int256);


    function getTimestamp(uint256 roundId) external view returns (uint256);


    event AnswerUpdated(
        int256 indexed current,
        uint256 indexed roundId,
        uint256 timestamp
    );
    event NewRound(uint256 indexed roundId, address indexed startedBy);
}// agpl-3.0
pragma solidity 0.8.10;


library RewardsDataTypes {

    struct RewardsConfigInput {
        uint88 emissionPerSecond;
        uint256 totalSupply;
        uint32 distributionEnd;
        address asset;
        address reward;
        ITransferStrategyBase transferStrategy;
        IEACAggregatorProxy rewardOracle;
    }

    struct UserAssetBalance {
        address asset;
        uint256 userBalance;
        uint256 totalSupply;
    }

    struct UserData {
        uint104 index; // matches reward index
        uint128 accrued;
    }

    struct RewardData {
        uint104 index;
        uint88 emissionPerSecond;
        uint32 lastUpdateTimestamp;
        uint32 distributionEnd;
        mapping(address => UserData) usersData;
    }

    struct AssetData {
        mapping(address => RewardData) rewards;
        mapping(uint128 => address) availableRewards;
        uint128 availableRewardsCount;
        uint8 decimals;
    }
}// agpl-3.0
pragma solidity 0.8.10;


interface IRewardsController is IRewardsDistributor {

    event ClaimerSet(address indexed user, address indexed claimer);

    event RewardsClaimed(
        address indexed user,
        address indexed reward,
        address indexed to,
        address claimer,
        uint256 amount
    );

    event TransferStrategyInstalled(
        address indexed reward,
        address indexed transferStrategy
    );

    event RewardOracleUpdated(
        address indexed reward,
        address indexed rewardOracle
    );

    function setClaimer(address user, address claimer) external;


    function setTransferStrategy(
        address reward,
        ITransferStrategyBase transferStrategy
    ) external;


    function setRewardOracle(address reward, IEACAggregatorProxy rewardOracle)
        external;


    function getRewardOracle(address reward) external view returns (address);


    function getClaimer(address user) external view returns (address);


    function getTransferStrategy(address reward)
        external
        view
        returns (address);


    function configureAssets(
        RewardsDataTypes.RewardsConfigInput[] memory config
    ) external;


    function handleAction(
        address user,
        uint256 userBalance,
        uint256 totalSupply
    ) external;


    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to,
        address reward
    ) external returns (uint256);


    function claimRewardsOnBehalf(
        address[] calldata assets,
        uint256 amount,
        address user,
        address to,
        address reward
    ) external returns (uint256);


    function claimRewardsToSelf(
        address[] calldata assets,
        uint256 amount,
        address reward
    ) external returns (uint256);


    function claimAllRewards(address[] calldata assets, address to)
        external
        returns (address[] memory rewardsList, uint256[] memory claimedAmounts);


    function claimAllRewardsOnBehalf(
        address[] calldata assets,
        address user,
        address to
    )
        external
        returns (address[] memory rewardsList, uint256[] memory claimedAmounts);


    function claimAllRewardsToSelf(address[] calldata assets)
        external
        returns (address[] memory rewardsList, uint256[] memory claimedAmounts);

}// agpl-3.0
pragma solidity 0.8.10;


interface IUiIncentiveDataProvider {

    struct AggregatedReserveIncentiveData {
        address underlyingAsset;
        IncentiveData aIncentiveData;
        IncentiveData vIncentiveData;
        IncentiveData sIncentiveData;
    }

    struct IncentiveData {
        address tokenAddress;
        address incentiveControllerAddress;
        RewardInfo[] rewardsTokenInformation;
    }

    struct RewardInfo {
        string rewardTokenSymbol;
        address rewardTokenAddress;
        address rewardOracleAddress;
        uint256 emissionPerSecond;
        uint256 incentivesLastUpdateTimestamp;
        uint256 tokenIncentivesIndex;
        uint256 emissionEndTimestamp;
        int256 rewardPriceFeed;
        uint8 rewardTokenDecimals;
        uint8 precision;
        uint8 priceFeedDecimals;
    }

    struct UserReserveIncentiveData {
        address underlyingAsset;
        UserIncentiveData xTokenIncentivesUserData;
        UserIncentiveData vTokenIncentivesUserData;
        UserIncentiveData sTokenIncentivesUserData;
    }

    struct UserIncentiveData {
        address tokenAddress;
        address incentiveControllerAddress;
        UserRewardInfo[] userRewardsInformation;
    }

    struct UserRewardInfo {
        string rewardTokenSymbol;
        address rewardOracleAddress;
        address rewardTokenAddress;
        uint256 userUnclaimedRewards;
        uint256 tokenIncentivesUserIndex;
        int256 rewardPriceFeed;
        uint8 priceFeedDecimals;
        uint8 rewardTokenDecimals;
    }

    function getReservesIncentivesData(IPoolAddressesProvider provider)
        external
        view
        returns (AggregatedReserveIncentiveData[] memory);


    function getUserReservesIncentivesData(
        IPoolAddressesProvider provider,
        address user
    ) external view returns (UserReserveIncentiveData[] memory);


    function getFullReservesIncentiveData(
        IPoolAddressesProvider provider,
        address user
    )
        external
        view
        returns (
            AggregatedReserveIncentiveData[] memory,
            UserReserveIncentiveData[] memory
        );

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
}// agpl-3.0
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


library ReserveConfiguration {

    uint256 internal constant LTV_MASK =                       0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
    uint256 internal constant LIQUIDATION_THRESHOLD_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
    uint256 internal constant LIQUIDATION_BONUS_MASK =         0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
    uint256 internal constant DECIMALS_MASK =                  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant ACTIVE_MASK =                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant FROZEN_MASK =                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant BORROWING_MASK =                 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant STABLE_BORROWING_MASK =          0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant PAUSED_MASK =                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant BORROWABLE_IN_ISOLATION_MASK =   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant SILOED_BORROWING_MASK =          0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant RESERVE_FACTOR_MASK =            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant BORROW_CAP_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000FFFFFFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant SUPPLY_CAP_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFF000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant LIQUIDATION_PROTOCOL_FEE_MASK =  0xFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant EMODE_CATEGORY_MASK =            0xFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant UNBACKED_MINT_CAP_MASK =         0xFFFFFFFFFFF000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant DEBT_CEILING_MASK =              0xF0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore

    uint256 internal constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
    uint256 internal constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
    uint256 internal constant RESERVE_DECIMALS_START_BIT_POSITION = 48;
    uint256 internal constant IS_ACTIVE_START_BIT_POSITION = 56;
    uint256 internal constant IS_FROZEN_START_BIT_POSITION = 57;
    uint256 internal constant BORROWING_ENABLED_START_BIT_POSITION = 58;
    uint256 internal constant STABLE_BORROWING_ENABLED_START_BIT_POSITION = 59;
    uint256 internal constant IS_PAUSED_START_BIT_POSITION = 60;
    uint256 internal constant BORROWABLE_IN_ISOLATION_START_BIT_POSITION = 61;
    uint256 internal constant SILOED_BORROWING_START_BIT_POSITION = 62;

    uint256 internal constant RESERVE_FACTOR_START_BIT_POSITION = 64;
    uint256 internal constant BORROW_CAP_START_BIT_POSITION = 80;
    uint256 internal constant SUPPLY_CAP_START_BIT_POSITION = 116;
    uint256 internal constant LIQUIDATION_PROTOCOL_FEE_START_BIT_POSITION = 152;
    uint256 internal constant EMODE_CATEGORY_START_BIT_POSITION = 168;
    uint256 internal constant UNBACKED_MINT_CAP_START_BIT_POSITION = 176;
    uint256 internal constant DEBT_CEILING_START_BIT_POSITION = 212;

    uint256 internal constant MAX_VALID_LTV = 65535;
    uint256 internal constant MAX_VALID_LIQUIDATION_THRESHOLD = 65535;
    uint256 internal constant MAX_VALID_LIQUIDATION_BONUS = 65535;
    uint256 internal constant MAX_VALID_DECIMALS = 255;
    uint256 internal constant MAX_VALID_RESERVE_FACTOR = 65535;
    uint256 internal constant MAX_VALID_BORROW_CAP = 68719476735;
    uint256 internal constant MAX_VALID_SUPPLY_CAP = 68719476735;
    uint256 internal constant MAX_VALID_LIQUIDATION_PROTOCOL_FEE = 65535;
    uint256 internal constant MAX_VALID_EMODE_CATEGORY = 255;
    uint256 internal constant MAX_VALID_UNBACKED_MINT_CAP = 68719476735;
    uint256 internal constant MAX_VALID_DEBT_CEILING = 1099511627775;

    uint256 public constant DEBT_CEILING_DECIMALS = 2;
    uint16 public constant MAX_RESERVES_COUNT = 128;

    function setLtv(DataTypes.ReserveConfigurationMap memory self, uint256 ltv)
        internal
        pure
    {

        require(ltv <= MAX_VALID_LTV, Errors.INVALID_LTV);

        self.data = (self.data & LTV_MASK) | ltv;
    }

    function getLtv(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (uint256)
    {

        return self.data & ~LTV_MASK;
    }

    function setLiquidationThreshold(
        DataTypes.ReserveConfigurationMap memory self,
        uint256 threshold
    ) internal pure {

        require(
            threshold <= MAX_VALID_LIQUIDATION_THRESHOLD,
            Errors.INVALID_LIQ_THRESHOLD
        );

        self.data =
            (self.data & LIQUIDATION_THRESHOLD_MASK) |
            (threshold << LIQUIDATION_THRESHOLD_START_BIT_POSITION);
    }

    function getLiquidationThreshold(
        DataTypes.ReserveConfigurationMap memory self
    ) internal pure returns (uint256) {

        return
            (self.data & ~LIQUIDATION_THRESHOLD_MASK) >>
            LIQUIDATION_THRESHOLD_START_BIT_POSITION;
    }

    function setLiquidationBonus(
        DataTypes.ReserveConfigurationMap memory self,
        uint256 bonus
    ) internal pure {

        require(bonus <= MAX_VALID_LIQUIDATION_BONUS, Errors.INVALID_LIQ_BONUS);

        self.data =
            (self.data & LIQUIDATION_BONUS_MASK) |
            (bonus << LIQUIDATION_BONUS_START_BIT_POSITION);
    }

    function getLiquidationBonus(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (uint256)
    {

        return
            (self.data & ~LIQUIDATION_BONUS_MASK) >>
            LIQUIDATION_BONUS_START_BIT_POSITION;
    }

    function setDecimals(
        DataTypes.ReserveConfigurationMap memory self,
        uint256 decimals
    ) internal pure {

        require(decimals <= MAX_VALID_DECIMALS, Errors.INVALID_DECIMALS);

        self.data =
            (self.data & DECIMALS_MASK) |
            (decimals << RESERVE_DECIMALS_START_BIT_POSITION);
    }

    function getDecimals(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (uint256)
    {

        return
            (self.data & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION;
    }

    function setActive(
        DataTypes.ReserveConfigurationMap memory self,
        bool active
    ) internal pure {

        self.data =
            (self.data & ACTIVE_MASK) |
            (uint256(active ? 1 : 0) << IS_ACTIVE_START_BIT_POSITION);
    }

    function getActive(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        return (self.data & ~ACTIVE_MASK) != 0;
    }

    function setFrozen(
        DataTypes.ReserveConfigurationMap memory self,
        bool frozen
    ) internal pure {

        self.data =
            (self.data & FROZEN_MASK) |
            (uint256(frozen ? 1 : 0) << IS_FROZEN_START_BIT_POSITION);
    }

    function getFrozen(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        return (self.data & ~FROZEN_MASK) != 0;
    }

    function setPaused(
        DataTypes.ReserveConfigurationMap memory self,
        bool paused
    ) internal pure {

        self.data =
            (self.data & PAUSED_MASK) |
            (uint256(paused ? 1 : 0) << IS_PAUSED_START_BIT_POSITION);
    }

    function getPaused(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        return (self.data & ~PAUSED_MASK) != 0;
    }

    function setSiloedBorrowing(
        DataTypes.ReserveConfigurationMap memory self,
        bool siloed
    ) internal pure {

        self.data =
            (self.data & SILOED_BORROWING_MASK) |
            (uint256(siloed ? 1 : 0) << SILOED_BORROWING_START_BIT_POSITION);
    }

    function getSiloedBorrowing(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        return (self.data & ~SILOED_BORROWING_MASK) != 0;
    }

    function setBorrowingEnabled(
        DataTypes.ReserveConfigurationMap memory self,
        bool enabled
    ) internal pure {

        self.data =
            (self.data & BORROWING_MASK) |
            (uint256(enabled ? 1 : 0) << BORROWING_ENABLED_START_BIT_POSITION);
    }

    function getBorrowingEnabled(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        return (self.data & ~BORROWING_MASK) != 0;
    }

    function setStableRateBorrowingEnabled(
        DataTypes.ReserveConfigurationMap memory self,
        bool enabled
    ) internal pure {

        self.data =
            (self.data & STABLE_BORROWING_MASK) |
            (uint256(enabled ? 1 : 0) <<
                STABLE_BORROWING_ENABLED_START_BIT_POSITION);
    }

    function getStableRateBorrowingEnabled(
        DataTypes.ReserveConfigurationMap memory self
    ) internal pure returns (bool) {

        return (self.data & ~STABLE_BORROWING_MASK) != 0;
    }

    function setReserveFactor(
        DataTypes.ReserveConfigurationMap memory self,
        uint256 reserveFactor
    ) internal pure {

        require(
            reserveFactor <= MAX_VALID_RESERVE_FACTOR,
            Errors.INVALID_RESERVE_FACTOR
        );

        self.data =
            (self.data & RESERVE_FACTOR_MASK) |
            (reserveFactor << RESERVE_FACTOR_START_BIT_POSITION);
    }

    function getReserveFactor(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (uint256)
    {

        return
            (self.data & ~RESERVE_FACTOR_MASK) >>
            RESERVE_FACTOR_START_BIT_POSITION;
    }

    function setBorrowCap(
        DataTypes.ReserveConfigurationMap memory self,
        uint256 borrowCap
    ) internal pure {

        require(borrowCap <= MAX_VALID_BORROW_CAP, Errors.INVALID_BORROW_CAP);

        self.data =
            (self.data & BORROW_CAP_MASK) |
            (borrowCap << BORROW_CAP_START_BIT_POSITION);
    }

    function getBorrowCap(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (uint256)
    {

        return (self.data & ~BORROW_CAP_MASK) >> BORROW_CAP_START_BIT_POSITION;
    }

    function setSupplyCap(
        DataTypes.ReserveConfigurationMap memory self,
        uint256 supplyCap
    ) internal pure {

        require(supplyCap <= MAX_VALID_SUPPLY_CAP, Errors.INVALID_SUPPLY_CAP);

        self.data =
            (self.data & SUPPLY_CAP_MASK) |
            (supplyCap << SUPPLY_CAP_START_BIT_POSITION);
    }

    function getSupplyCap(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (uint256)
    {

        return (self.data & ~SUPPLY_CAP_MASK) >> SUPPLY_CAP_START_BIT_POSITION;
    }

    function setLiquidationProtocolFee(
        DataTypes.ReserveConfigurationMap memory self,
        uint256 liquidationProtocolFee
    ) internal pure {

        require(
            liquidationProtocolFee <= MAX_VALID_LIQUIDATION_PROTOCOL_FEE,
            Errors.INVALID_LIQUIDATION_PROTOCOL_FEE
        );

        self.data =
            (self.data & LIQUIDATION_PROTOCOL_FEE_MASK) |
            (liquidationProtocolFee <<
                LIQUIDATION_PROTOCOL_FEE_START_BIT_POSITION);
    }

    function getLiquidationProtocolFee(
        DataTypes.ReserveConfigurationMap memory self
    ) internal pure returns (uint256) {

        return
            (self.data & ~LIQUIDATION_PROTOCOL_FEE_MASK) >>
            LIQUIDATION_PROTOCOL_FEE_START_BIT_POSITION;
    }

    function getFlags(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (
            bool,
            bool,
            bool,
            bool,
            bool
        )
    {

        uint256 dataLocal = self.data;

        return (
            (dataLocal & ~ACTIVE_MASK) != 0,
            (dataLocal & ~FROZEN_MASK) != 0,
            (dataLocal & ~BORROWING_MASK) != 0,
            (dataLocal & ~STABLE_BORROWING_MASK) != 0,
            (dataLocal & ~PAUSED_MASK) != 0
        );
    }

    function getParams(DataTypes.ReserveConfigurationMap memory self)
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

        uint256 dataLocal = self.data;

        return (
            dataLocal & ~LTV_MASK,
            (dataLocal & ~LIQUIDATION_THRESHOLD_MASK) >>
                LIQUIDATION_THRESHOLD_START_BIT_POSITION,
            (dataLocal & ~LIQUIDATION_BONUS_MASK) >>
                LIQUIDATION_BONUS_START_BIT_POSITION,
            (dataLocal & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION,
            (dataLocal & ~RESERVE_FACTOR_MASK) >>
                RESERVE_FACTOR_START_BIT_POSITION
        );
    }

    function getCaps(DataTypes.ReserveConfigurationMap memory self)
        internal
        pure
        returns (uint256, uint256)
    {

        uint256 dataLocal = self.data;

        return (
            (dataLocal & ~BORROW_CAP_MASK) >> BORROW_CAP_START_BIT_POSITION,
            (dataLocal & ~SUPPLY_CAP_MASK) >> SUPPLY_CAP_START_BIT_POSITION
        );
    }
}// BUSL-1.1
pragma solidity 0.8.10;


library UserConfiguration {

    using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

    uint256 internal constant BORROWING_MASK =
        0x5555555555555555555555555555555555555555555555555555555555555555;
    uint256 internal constant COLLATERAL_MASK =
        0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;

    function setBorrowing(
        DataTypes.UserConfigurationMap storage self,
        uint256 reserveIndex,
        bool borrowing
    ) internal {

        unchecked {
            require(
                reserveIndex < ReserveConfiguration.MAX_RESERVES_COUNT,
                Errors.INVALID_RESERVE_INDEX
            );
            uint256 bit = 1 << (reserveIndex << 1);
            if (borrowing) {
                self.data |= bit;
            } else {
                self.data &= ~bit;
            }
        }
    }

    function setUsingAsCollateral(
        DataTypes.UserConfigurationMap storage self,
        uint256 reserveIndex,
        bool usingAsCollateral
    ) internal {

        unchecked {
            require(
                reserveIndex < ReserveConfiguration.MAX_RESERVES_COUNT,
                Errors.INVALID_RESERVE_INDEX
            );
            uint256 bit = 1 << ((reserveIndex << 1) + 1);
            if (usingAsCollateral) {
                self.data |= bit;
            } else {
                self.data &= ~bit;
            }
        }
    }

    function isUsingAsCollateralOrBorrowing(
        DataTypes.UserConfigurationMap memory self,
        uint256 reserveIndex
    ) internal pure returns (bool) {

        unchecked {
            require(
                reserveIndex < ReserveConfiguration.MAX_RESERVES_COUNT,
                Errors.INVALID_RESERVE_INDEX
            );
            return (self.data >> (reserveIndex << 1)) & 3 != 0;
        }
    }

    function isBorrowing(
        DataTypes.UserConfigurationMap memory self,
        uint256 reserveIndex
    ) internal pure returns (bool) {

        unchecked {
            require(
                reserveIndex < ReserveConfiguration.MAX_RESERVES_COUNT,
                Errors.INVALID_RESERVE_INDEX
            );
            return (self.data >> (reserveIndex << 1)) & 1 != 0;
        }
    }

    function isUsingAsCollateral(
        DataTypes.UserConfigurationMap memory self,
        uint256 reserveIndex
    ) internal pure returns (bool) {

        unchecked {
            require(
                reserveIndex < ReserveConfiguration.MAX_RESERVES_COUNT,
                Errors.INVALID_RESERVE_INDEX
            );
            return (self.data >> ((reserveIndex << 1) + 1)) & 1 != 0;
        }
    }

    function isUsingAsCollateralOne(DataTypes.UserConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        uint256 collateralData = self.data & COLLATERAL_MASK;
        return
            collateralData != 0 && (collateralData & (collateralData - 1) == 0);
    }

    function isUsingAsCollateralAny(DataTypes.UserConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        return self.data & COLLATERAL_MASK != 0;
    }

    function isBorrowingOne(DataTypes.UserConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        uint256 borrowingData = self.data & BORROWING_MASK;
        return borrowingData != 0 && (borrowingData & (borrowingData - 1) == 0);
    }

    function isBorrowingAny(DataTypes.UserConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        return self.data & BORROWING_MASK != 0;
    }

    function isEmpty(DataTypes.UserConfigurationMap memory self)
        internal
        pure
        returns (bool)
    {

        return self.data == 0;
    }

    function getSiloedBorrowingState(
        DataTypes.UserConfigurationMap memory self,
        mapping(address => DataTypes.ReserveData) storage reservesData,
        mapping(uint256 => address) storage reservesList
    ) internal view returns (bool, address) {

        if (isBorrowingOne(self)) {
            uint256 assetId = _getFirstAssetIdByMask(self, BORROWING_MASK);
            address assetAddress = reservesList[assetId];
            if (reservesData[assetAddress].configuration.getSiloedBorrowing()) {
                return (true, assetAddress);
            }
        }

        return (false, address(0));
    }

    function _getFirstAssetIdByMask(
        DataTypes.UserConfigurationMap memory self,
        uint256 mask
    ) internal pure returns (uint256) {

        unchecked {
            uint256 bitmapData = self.data & mask;
            uint256 firstAssetPosition = bitmapData & ~(bitmapData - 1);
            uint256 id;

            while ((firstAssetPosition >>= 2) != 0) {
                id += 1;
            }
            return id;
        }
    }
}// AGPL-3.0
pragma solidity 0.8.10;


contract UiIncentiveDataProvider is IUiIncentiveDataProvider {

    using UserConfiguration for DataTypes.UserConfigurationMap;

    constructor() {}

    function getFullReservesIncentiveData(
        IPoolAddressesProvider provider,
        address user
    )
        external
        view
        override
        returns (
            AggregatedReserveIncentiveData[] memory,
            UserReserveIncentiveData[] memory
        )
    {

        return (
            _getReservesIncentivesData(provider),
            _getUserReservesIncentivesData(provider, user)
        );
    }

    function getReservesIncentivesData(IPoolAddressesProvider provider)
        external
        view
        override
        returns (AggregatedReserveIncentiveData[] memory)
    {

        return _getReservesIncentivesData(provider);
    }

    function _getReservesIncentivesData(IPoolAddressesProvider provider)
        private
        view
        returns (AggregatedReserveIncentiveData[] memory)
    {

        IPool pool = IPool(provider.getPool());
        address[] memory reserves = pool.getReservesList();
        AggregatedReserveIncentiveData[]
            memory reservesIncentiveData = new AggregatedReserveIncentiveData[](
                reserves.length
            );
        for (uint256 i = 0; i < reserves.length; i++) {
            AggregatedReserveIncentiveData
                memory reserveIncentiveData = reservesIncentiveData[i];
            reserveIncentiveData.underlyingAsset = reserves[i];

            DataTypes.ReserveData memory baseData = pool.getReserveData(
                reserves[i]
            );

            IRewardsController xTokenIncentiveController = IRewardsController(
                address(
                    IncentivizedERC20(baseData.xTokenAddress)
                        .getIncentivesController()
                )
            );

            RewardInfo[] memory aRewardsInformation;
            if (address(xTokenIncentiveController) != address(0)) {
                address[]
                    memory xTokenRewardAddresses = xTokenIncentiveController
                        .getRewardsByAsset(baseData.xTokenAddress);

                aRewardsInformation = new RewardInfo[](
                    xTokenRewardAddresses.length
                );
                for (uint256 j = 0; j < xTokenRewardAddresses.length; ++j) {
                    RewardInfo memory rewardInformation;
                    rewardInformation
                        .rewardTokenAddress = xTokenRewardAddresses[j];

                    (
                        rewardInformation.tokenIncentivesIndex,
                        rewardInformation.emissionPerSecond,
                        rewardInformation.incentivesLastUpdateTimestamp,
                        rewardInformation.emissionEndTimestamp
                    ) = xTokenIncentiveController.getRewardsData(
                        baseData.xTokenAddress,
                        rewardInformation.rewardTokenAddress
                    );

                    rewardInformation.precision = xTokenIncentiveController
                        .getAssetDecimals(baseData.xTokenAddress);
                    rewardInformation.rewardTokenDecimals = IERC20Detailed(
                        rewardInformation.rewardTokenAddress
                    ).decimals();
                    rewardInformation.rewardTokenSymbol = IERC20Detailed(
                        rewardInformation.rewardTokenAddress
                    ).symbol();

                    rewardInformation
                        .rewardOracleAddress = xTokenIncentiveController
                        .getRewardOracle(rewardInformation.rewardTokenAddress);
                    rewardInformation.priceFeedDecimals = IEACAggregatorProxy(
                        rewardInformation.rewardOracleAddress
                    ).decimals();
                    rewardInformation.rewardPriceFeed = IEACAggregatorProxy(
                        rewardInformation.rewardOracleAddress
                    ).latestAnswer();

                    aRewardsInformation[j] = rewardInformation;
                }
            }

            reserveIncentiveData.aIncentiveData = IncentiveData(
                baseData.xTokenAddress,
                address(xTokenIncentiveController),
                aRewardsInformation
            );

            IRewardsController vTokenIncentiveController = IRewardsController(
                address(
                    IncentivizedERC20(baseData.variableDebtTokenAddress)
                        .getIncentivesController()
                )
            );
            address[] memory vTokenRewardAddresses = vTokenIncentiveController
                .getRewardsByAsset(baseData.variableDebtTokenAddress);
            RewardInfo[] memory vRewardsInformation;

            if (address(vTokenIncentiveController) != address(0)) {
                vRewardsInformation = new RewardInfo[](
                    vTokenRewardAddresses.length
                );
                for (uint256 j = 0; j < vTokenRewardAddresses.length; ++j) {
                    RewardInfo memory rewardInformation;
                    rewardInformation
                        .rewardTokenAddress = vTokenRewardAddresses[j];

                    (
                        rewardInformation.tokenIncentivesIndex,
                        rewardInformation.emissionPerSecond,
                        rewardInformation.incentivesLastUpdateTimestamp,
                        rewardInformation.emissionEndTimestamp
                    ) = vTokenIncentiveController.getRewardsData(
                        baseData.variableDebtTokenAddress,
                        rewardInformation.rewardTokenAddress
                    );

                    rewardInformation.precision = vTokenIncentiveController
                        .getAssetDecimals(baseData.variableDebtTokenAddress);
                    rewardInformation.rewardTokenDecimals = IERC20Detailed(
                        rewardInformation.rewardTokenAddress
                    ).decimals();
                    rewardInformation.rewardTokenSymbol = IERC20Detailed(
                        rewardInformation.rewardTokenAddress
                    ).symbol();

                    rewardInformation
                        .rewardOracleAddress = vTokenIncentiveController
                        .getRewardOracle(rewardInformation.rewardTokenAddress);
                    rewardInformation.priceFeedDecimals = IEACAggregatorProxy(
                        rewardInformation.rewardOracleAddress
                    ).decimals();
                    rewardInformation.rewardPriceFeed = IEACAggregatorProxy(
                        rewardInformation.rewardOracleAddress
                    ).latestAnswer();

                    vRewardsInformation[j] = rewardInformation;
                }
            }

            reserveIncentiveData.vIncentiveData = IncentiveData(
                baseData.variableDebtTokenAddress,
                address(vTokenIncentiveController),
                vRewardsInformation
            );

            IRewardsController sTokenIncentiveController = IRewardsController(
                address(
                    IncentivizedERC20(baseData.stableDebtTokenAddress)
                        .getIncentivesController()
                )
            );
            address[] memory sTokenRewardAddresses = sTokenIncentiveController
                .getRewardsByAsset(baseData.stableDebtTokenAddress);
            RewardInfo[] memory sRewardsInformation;

            if (address(sTokenIncentiveController) != address(0)) {
                sRewardsInformation = new RewardInfo[](
                    sTokenRewardAddresses.length
                );
                for (uint256 j = 0; j < sTokenRewardAddresses.length; ++j) {
                    RewardInfo memory rewardInformation;
                    rewardInformation
                        .rewardTokenAddress = sTokenRewardAddresses[j];

                    (
                        rewardInformation.tokenIncentivesIndex,
                        rewardInformation.emissionPerSecond,
                        rewardInformation.incentivesLastUpdateTimestamp,
                        rewardInformation.emissionEndTimestamp
                    ) = sTokenIncentiveController.getRewardsData(
                        baseData.stableDebtTokenAddress,
                        rewardInformation.rewardTokenAddress
                    );

                    rewardInformation.precision = sTokenIncentiveController
                        .getAssetDecimals(baseData.stableDebtTokenAddress);
                    rewardInformation.rewardTokenDecimals = IERC20Detailed(
                        rewardInformation.rewardTokenAddress
                    ).decimals();
                    rewardInformation.rewardTokenSymbol = IERC20Detailed(
                        rewardInformation.rewardTokenAddress
                    ).symbol();

                    rewardInformation
                        .rewardOracleAddress = sTokenIncentiveController
                        .getRewardOracle(rewardInformation.rewardTokenAddress);
                    rewardInformation.priceFeedDecimals = IEACAggregatorProxy(
                        rewardInformation.rewardOracleAddress
                    ).decimals();
                    rewardInformation.rewardPriceFeed = IEACAggregatorProxy(
                        rewardInformation.rewardOracleAddress
                    ).latestAnswer();

                    sRewardsInformation[j] = rewardInformation;
                }
            }

            reserveIncentiveData.sIncentiveData = IncentiveData(
                baseData.stableDebtTokenAddress,
                address(sTokenIncentiveController),
                sRewardsInformation
            );
        }

        return (reservesIncentiveData);
    }

    function getUserReservesIncentivesData(
        IPoolAddressesProvider provider,
        address user
    ) external view override returns (UserReserveIncentiveData[] memory) {

        return _getUserReservesIncentivesData(provider, user);
    }

    function _getUserReservesIncentivesData(
        IPoolAddressesProvider provider,
        address user
    ) private view returns (UserReserveIncentiveData[] memory) {

        IPool pool = IPool(provider.getPool());
        address[] memory reserves = pool.getReservesList();

        UserReserveIncentiveData[]
            memory userReservesIncentivesData = new UserReserveIncentiveData[](
                user != address(0) ? reserves.length : 0
            );

        for (uint256 i = 0; i < reserves.length; i++) {
            DataTypes.ReserveData memory baseData = pool.getReserveData(
                reserves[i]
            );

            userReservesIncentivesData[i].underlyingAsset = reserves[i];

            IRewardsController xTokenIncentiveController = IRewardsController(
                address(
                    IncentivizedERC20(baseData.xTokenAddress)
                        .getIncentivesController()
                )
            );
            if (address(xTokenIncentiveController) != address(0)) {
                address[]
                    memory xTokenRewardAddresses = xTokenIncentiveController
                        .getRewardsByAsset(baseData.xTokenAddress);
                UserRewardInfo[]
                    memory aUserRewardsInformation = new UserRewardInfo[](
                        xTokenRewardAddresses.length
                    );
                for (uint256 j = 0; j < xTokenRewardAddresses.length; ++j) {
                    UserRewardInfo memory userRewardInformation;
                    userRewardInformation
                        .rewardTokenAddress = xTokenRewardAddresses[j];

                    userRewardInformation
                        .tokenIncentivesUserIndex = xTokenIncentiveController
                        .getUserAssetIndex(
                            user,
                            baseData.xTokenAddress,
                            userRewardInformation.rewardTokenAddress
                        );

                    userRewardInformation
                        .userUnclaimedRewards = xTokenIncentiveController
                        .getUserAccruedRewards(
                            user,
                            userRewardInformation.rewardTokenAddress
                        );
                    userRewardInformation.rewardTokenDecimals = IERC20Detailed(
                        userRewardInformation.rewardTokenAddress
                    ).decimals();
                    userRewardInformation.rewardTokenSymbol = IERC20Detailed(
                        userRewardInformation.rewardTokenAddress
                    ).symbol();

                    userRewardInformation
                        .rewardOracleAddress = xTokenIncentiveController
                        .getRewardOracle(
                            userRewardInformation.rewardTokenAddress
                        );
                    userRewardInformation
                        .priceFeedDecimals = IEACAggregatorProxy(
                        userRewardInformation.rewardOracleAddress
                    ).decimals();
                    userRewardInformation.rewardPriceFeed = IEACAggregatorProxy(
                        userRewardInformation.rewardOracleAddress
                    ).latestAnswer();

                    aUserRewardsInformation[j] = userRewardInformation;
                }

                userReservesIncentivesData[i]
                    .xTokenIncentivesUserData = UserIncentiveData(
                    baseData.xTokenAddress,
                    address(xTokenIncentiveController),
                    aUserRewardsInformation
                );
            }

            IRewardsController vTokenIncentiveController = IRewardsController(
                address(
                    IncentivizedERC20(baseData.variableDebtTokenAddress)
                        .getIncentivesController()
                )
            );
            if (address(vTokenIncentiveController) != address(0)) {
                address[]
                    memory vTokenRewardAddresses = vTokenIncentiveController
                        .getRewardsByAsset(baseData.variableDebtTokenAddress);
                UserRewardInfo[]
                    memory vUserRewardsInformation = new UserRewardInfo[](
                        vTokenRewardAddresses.length
                    );
                for (uint256 j = 0; j < vTokenRewardAddresses.length; ++j) {
                    UserRewardInfo memory userRewardInformation;
                    userRewardInformation
                        .rewardTokenAddress = vTokenRewardAddresses[j];

                    userRewardInformation
                        .tokenIncentivesUserIndex = vTokenIncentiveController
                        .getUserAssetIndex(
                            user,
                            baseData.variableDebtTokenAddress,
                            userRewardInformation.rewardTokenAddress
                        );

                    userRewardInformation
                        .userUnclaimedRewards = vTokenIncentiveController
                        .getUserAccruedRewards(
                            user,
                            userRewardInformation.rewardTokenAddress
                        );
                    userRewardInformation.rewardTokenDecimals = IERC20Detailed(
                        userRewardInformation.rewardTokenAddress
                    ).decimals();
                    userRewardInformation.rewardTokenSymbol = IERC20Detailed(
                        userRewardInformation.rewardTokenAddress
                    ).symbol();

                    userRewardInformation
                        .rewardOracleAddress = vTokenIncentiveController
                        .getRewardOracle(
                            userRewardInformation.rewardTokenAddress
                        );
                    userRewardInformation
                        .priceFeedDecimals = IEACAggregatorProxy(
                        userRewardInformation.rewardOracleAddress
                    ).decimals();
                    userRewardInformation.rewardPriceFeed = IEACAggregatorProxy(
                        userRewardInformation.rewardOracleAddress
                    ).latestAnswer();

                    vUserRewardsInformation[j] = userRewardInformation;
                }

                userReservesIncentivesData[i]
                    .vTokenIncentivesUserData = UserIncentiveData(
                    baseData.variableDebtTokenAddress,
                    address(xTokenIncentiveController),
                    vUserRewardsInformation
                );
            }

            IRewardsController sTokenIncentiveController = IRewardsController(
                address(
                    IncentivizedERC20(baseData.stableDebtTokenAddress)
                        .getIncentivesController()
                )
            );
            if (address(sTokenIncentiveController) != address(0)) {
                address[]
                    memory sTokenRewardAddresses = sTokenIncentiveController
                        .getRewardsByAsset(baseData.stableDebtTokenAddress);
                UserRewardInfo[]
                    memory sUserRewardsInformation = new UserRewardInfo[](
                        sTokenRewardAddresses.length
                    );
                for (uint256 j = 0; j < sTokenRewardAddresses.length; ++j) {
                    UserRewardInfo memory userRewardInformation;
                    userRewardInformation
                        .rewardTokenAddress = sTokenRewardAddresses[j];

                    userRewardInformation
                        .tokenIncentivesUserIndex = sTokenIncentiveController
                        .getUserAssetIndex(
                            user,
                            baseData.stableDebtTokenAddress,
                            userRewardInformation.rewardTokenAddress
                        );

                    userRewardInformation
                        .userUnclaimedRewards = sTokenIncentiveController
                        .getUserAccruedRewards(
                            user,
                            userRewardInformation.rewardTokenAddress
                        );
                    userRewardInformation.rewardTokenDecimals = IERC20Detailed(
                        userRewardInformation.rewardTokenAddress
                    ).decimals();
                    userRewardInformation.rewardTokenSymbol = IERC20Detailed(
                        userRewardInformation.rewardTokenAddress
                    ).symbol();

                    userRewardInformation
                        .rewardOracleAddress = sTokenIncentiveController
                        .getRewardOracle(
                            userRewardInformation.rewardTokenAddress
                        );
                    userRewardInformation
                        .priceFeedDecimals = IEACAggregatorProxy(
                        userRewardInformation.rewardOracleAddress
                    ).decimals();
                    userRewardInformation.rewardPriceFeed = IEACAggregatorProxy(
                        userRewardInformation.rewardOracleAddress
                    ).latestAnswer();

                    sUserRewardsInformation[j] = userRewardInformation;
                }

                userReservesIncentivesData[i]
                    .sTokenIncentivesUserData = UserIncentiveData(
                    baseData.stableDebtTokenAddress,
                    address(xTokenIncentiveController),
                    sUserRewardsInformation
                );
            }
        }

        return (userReservesIncentivesData);
    }
}