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


interface IInitializableOToken {

    event Initialized(
        address indexed underlyingAsset,
        address indexed pool,
        address treasury,
        address incentivesController,
        uint8 oTokenDecimals,
        string oTokenName,
        string oTokenSymbol,
        bytes params
    );

    function initialize(
        IPool pool,
        address treasury,
        address underlyingAsset,
        IRewardController incentivesController,
        uint8 oTokenDecimals,
        string calldata oTokenName,
        string calldata oTokenSymbol,
        bytes calldata params
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

}// agpl-3.0
pragma solidity 0.8.10;

abstract contract Proxy {
  fallback() external payable {
    _fallback();
  }

  function _implementation() internal view virtual returns (address);

  function _delegate(address implementation) internal {
    assembly {
      calldatacopy(0, 0, calldatasize())

      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      returndatacopy(0, 0, returndatasize())

      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  function _willFallback() internal virtual {}

  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}// agpl-3.0
pragma solidity 0.8.10;

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

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
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
}// agpl-3.0
pragma solidity 0.8.10;


contract BaseUpgradeabilityProxy is Proxy {

  event Upgraded(address indexed implementation);

  bytes32 internal constant IMPLEMENTATION_SLOT =
    0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  function _implementation() internal view override returns (address impl) {

    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  function _upgradeTo(address newImplementation) internal {

    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  function _setImplementation(address newImplementation) internal {

    require(
      Address.isContract(newImplementation),
      'Cannot set a proxy implementation to a non-contract address'
    );

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}// agpl-3.0
pragma solidity 0.8.10;


contract InitializableUpgradeabilityProxy is BaseUpgradeabilityProxy {

  function initialize(address _logic, bytes memory _data) public payable {

    require(_implementation() == address(0));
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if (_data.length > 0) {
      (bool success, ) = _logic.delegatecall(_data);
      require(success);
    }
  }
}// AGPL-3.0
pragma solidity 0.8.10;


contract BaseImmutableAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {

    address internal immutable _admin;

    constructor(address admin) {
        _admin = admin;
    }

    modifier ifAdmin() {

        if (msg.sender == _admin) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address) {

        return _admin;
    }

    function implementation() external ifAdmin returns (address) {

        return _implementation();
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data)
        external
        payable
        ifAdmin
    {

        _upgradeTo(newImplementation);
        (bool success, ) = newImplementation.delegatecall(data);
        require(success);
    }

    function _willFallback() internal virtual override {

        require(
            msg.sender != _admin,
            "Cannot call fallback function from the proxy admin"
        );
        super._willFallback();
    }
}// AGPL-3.0
pragma solidity 0.8.10;


contract InitializableImmutableAdminUpgradeabilityProxy is
    BaseImmutableAdminUpgradeabilityProxy,
    InitializableUpgradeabilityProxy
{

    constructor(address admin) BaseImmutableAdminUpgradeabilityProxy(admin) {
    }

    function _willFallback()
        internal
        override(BaseImmutableAdminUpgradeabilityProxy, Proxy)
    {

        BaseImmutableAdminUpgradeabilityProxy._willFallback();
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


library ConfiguratorInputTypes {

    struct InitReserveInput {
        address xTokenImpl;
        address stableDebtTokenImpl;
        address variableDebtTokenImpl;
        uint8 underlyingAssetDecimals;
        address interestRateStrategyAddress;
        address underlyingAsset;
        DataTypes.AssetType assetType;
        address treasury;
        address incentivesController;
        string xTokenName;
        string xTokenSymbol;
        string variableDebtTokenName;
        string variableDebtTokenSymbol;
        string stableDebtTokenName;
        string stableDebtTokenSymbol;
        bytes params;
    }

    struct UpdateXTokenInput {
        address asset;
        address treasury;
        address incentivesController;
        string name;
        string symbol;
        address implementation;
        bytes params;
    }

    struct UpdateDebtTokenInput {
        address asset;
        address incentivesController;
        string name;
        string symbol;
        address implementation;
        bytes params;
    }
}// BUSL-1.1
pragma solidity 0.8.10;


library ConfiguratorLogic {

    using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

    event ReserveInitialized(
        address indexed asset,
        address indexed xToken,
        address stableDebtToken,
        address variableDebtToken,
        address interestRateStrategyAddress
    );
    event XTokenUpgraded(
        address indexed asset,
        address indexed proxy,
        address indexed implementation
    );
    event StableDebtTokenUpgraded(
        address indexed asset,
        address indexed proxy,
        address indexed implementation
    );
    event VariableDebtTokenUpgraded(
        address indexed asset,
        address indexed proxy,
        address indexed implementation
    );

    function executeInitReserve(
        IPool pool,
        ConfiguratorInputTypes.InitReserveInput calldata input
    ) public {

        address xTokenProxyAddress = _initTokenWithProxy(
            input.xTokenImpl,
            abi.encodeWithSelector(
                IInitializableOToken.initialize.selector,
                pool,
                input.treasury,
                input.underlyingAsset,
                input.incentivesController,
                input.underlyingAssetDecimals,
                input.xTokenName,
                input.xTokenSymbol,
                input.params
            )
        );

        address stableDebtTokenProxyAddress = _initTokenWithProxy(
            input.stableDebtTokenImpl,
            abi.encodeWithSelector(
                IInitializableDebtToken.initialize.selector,
                pool,
                input.underlyingAsset,
                input.incentivesController,
                input.underlyingAssetDecimals,
                input.stableDebtTokenName,
                input.stableDebtTokenSymbol,
                input.params
            )
        );

        address variableDebtTokenProxyAddress = _initTokenWithProxy(
            input.variableDebtTokenImpl,
            abi.encodeWithSelector(
                IInitializableDebtToken.initialize.selector,
                pool,
                input.underlyingAsset,
                input.incentivesController,
                input.underlyingAssetDecimals,
                input.variableDebtTokenName,
                input.variableDebtTokenSymbol,
                input.params
            )
        );

        pool.initReserve(
            input.underlyingAsset,
            input.assetType,
            xTokenProxyAddress,
            stableDebtTokenProxyAddress,
            variableDebtTokenProxyAddress,
            input.interestRateStrategyAddress
        );

        DataTypes.ReserveConfigurationMap memory currentConfig = DataTypes
            .ReserveConfigurationMap(0);

        currentConfig.setDecimals(input.underlyingAssetDecimals);

        currentConfig.setActive(true);
        currentConfig.setPaused(false);
        currentConfig.setFrozen(false);

        pool.setConfiguration(input.underlyingAsset, currentConfig);

        emit ReserveInitialized(
            input.underlyingAsset,
            xTokenProxyAddress,
            stableDebtTokenProxyAddress,
            variableDebtTokenProxyAddress,
            input.interestRateStrategyAddress
        );
    }

    function executeUpdateXToken(
        IPool cachedPool,
        ConfiguratorInputTypes.UpdateXTokenInput calldata input
    ) public {

        DataTypes.ReserveData memory reserveData = cachedPool.getReserveData(
            input.asset
        );

        (, , , uint256 decimals, ) = cachedPool
            .getConfiguration(input.asset)
            .getParams();

        bytes memory encodedCall = abi.encodeWithSelector(
            IInitializableOToken.initialize.selector,
            cachedPool,
            input.treasury,
            input.asset,
            input.incentivesController,
            decimals,
            input.name,
            input.symbol,
            input.params
        );

        _upgradeTokenImplementation(
            reserveData.xTokenAddress,
            input.implementation,
            encodedCall
        );

        emit XTokenUpgraded(
            input.asset,
            reserveData.xTokenAddress,
            input.implementation
        );
    }

    function executeUpdateStableDebtToken(
        IPool cachedPool,
        ConfiguratorInputTypes.UpdateDebtTokenInput calldata input
    ) public {

        DataTypes.ReserveData memory reserveData = cachedPool.getReserveData(
            input.asset
        );

        (, , , uint256 decimals, ) = cachedPool
            .getConfiguration(input.asset)
            .getParams();

        bytes memory encodedCall = abi.encodeWithSelector(
            IInitializableDebtToken.initialize.selector,
            cachedPool,
            input.asset,
            input.incentivesController,
            decimals,
            input.name,
            input.symbol,
            input.params
        );

        _upgradeTokenImplementation(
            reserveData.stableDebtTokenAddress,
            input.implementation,
            encodedCall
        );

        emit StableDebtTokenUpgraded(
            input.asset,
            reserveData.stableDebtTokenAddress,
            input.implementation
        );
    }

    function executeUpdateVariableDebtToken(
        IPool cachedPool,
        ConfiguratorInputTypes.UpdateDebtTokenInput calldata input
    ) public {

        DataTypes.ReserveData memory reserveData = cachedPool.getReserveData(
            input.asset
        );

        (, , , uint256 decimals, ) = cachedPool
            .getConfiguration(input.asset)
            .getParams();

        bytes memory encodedCall = abi.encodeWithSelector(
            IInitializableDebtToken.initialize.selector,
            cachedPool,
            input.asset,
            input.incentivesController,
            decimals,
            input.name,
            input.symbol,
            input.params
        );

        _upgradeTokenImplementation(
            reserveData.variableDebtTokenAddress,
            input.implementation,
            encodedCall
        );

        emit VariableDebtTokenUpgraded(
            input.asset,
            reserveData.variableDebtTokenAddress,
            input.implementation
        );
    }

    function _initTokenWithProxy(
        address implementation,
        bytes memory initParams
    ) internal returns (address) {

        InitializableImmutableAdminUpgradeabilityProxy proxy = new InitializableImmutableAdminUpgradeabilityProxy(
                address(this)
            );

        proxy.initialize(implementation, initParams);

        return address(proxy);
    }

    function _upgradeTokenImplementation(
        address proxyAddress,
        address implementation,
        bytes memory initParams
    ) internal {

        InitializableImmutableAdminUpgradeabilityProxy proxy = InitializableImmutableAdminUpgradeabilityProxy(
                payable(proxyAddress)
            );

        proxy.upgradeToAndCall(implementation, initParams);
    }
}