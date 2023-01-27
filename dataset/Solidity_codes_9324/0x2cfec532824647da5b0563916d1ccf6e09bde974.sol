
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
pragma solidity 0.8.11;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.11;

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
pragma solidity 0.8.11;

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address vTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    uint8 id;
  }

  struct NFTVaultData {
    NFTVaultConfigurationMap configuration;
    address nTokenAddress;
    address nftEligibility;
    uint32 id;
    uint40 expiration;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct NFTVaultConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
    uint256 nData;
  }

  struct PoolReservesData {
    uint256 count;
    mapping(address => ReserveData) data;
    mapping(uint256 => address) list;
  }

  struct PoolNFTVaultsData {
    uint256 count;
    mapping(address => NFTVaultData) data;
    mapping(uint256 => address) list;
  }

  struct TimeLock {
    uint40 expiration;
    uint16 lockType;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}// agpl-3.0
pragma solidity 0.8.11;
pragma abicoder v2;


interface ILendingPool {

  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  event DepositNFT(
    address indexed vault, 
    address user,
    address indexed onBehalfOf, 
    uint256[] tokenIds, 
    uint256[] amounts,
    uint16 indexed referral
  );

  event WithdrawNFT(
    address indexed vault, 
    address indexed user, 
    address indexed to, 
    uint256[] tokenIds,
    uint256[] amounts
  );

  event NFTFlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256[] tokenIds,
    uint256[] amounts,
    uint256 premium,
    uint16 referralCode
  );


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

  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  event NFTVaultUsedAsCollateralEnabled(address indexed nftVault, address indexed user);

  event NFTVaultUsedAsCollateralDisabled(address indexed nftVault, address indexed user);

  event Paused();

  event Unpaused();

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


  function depositNFT(
    address nft,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function depositAndLockNFT(
    address nft,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts,
    address onBehalfOf,
    uint16 lockType,
    uint16 referralCode
  ) external;


  function withdrawNFT(
    address nft,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts,
    address to
  ) external returns (uint256[] memory);


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


  function nftLiquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    bool receiveNToken
  ) external;


  function nftFlashLoan(
    address receiverAddress,
    address asset,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts,
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
    address vTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;


  function initNFTVault(
    address vault,
    address nTokenAddress,
    address nftEligibility
  ) external;


  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;


  function setConfiguration(address reserve, uint256 configuration) external;

  function setNFTVaultConfiguration(address reserve, uint256 configuration) external;

  function setNFTVaultActionExpiration(address nftValue, uint40 expiration) external;

  function setNFTVaultEligibility(address nftValue, address eligibility) external;


  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);


  function getNFTVaultConfiguration(address asset)
    external
    view
    returns (DataTypes.NFTVaultConfigurationMap memory);


  function getUserConfiguration(address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);


  function getReserveNormalizedIncome(address asset) external view returns (uint256);


  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


  function getNFTVaultData(address asset) external view returns (DataTypes.NFTVaultData memory);


  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;


  function finalizeNFTSingleTransfer(
    address asset,
    address from,
    address to,
    uint256 tokenId,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;


  function finalizeNFTBatchTransfer(
    address asset,
    address from,
    address to,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;


  function getReservesList() external view returns (address[] memory);

  function getNFTVaultsList() external view returns (address[] memory);



  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);


  function setPause(bool val) external;


  function paused() external view returns (bool);

}// agpl-3.0
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

interface IAaveIncentivesController {

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


  function configureAssets(address[] calldata assetsToConfig, uint256[] calldata emissionsPerSecond)
    external;


  function handleAction(
    address asset,
    uint256 userBalance,
    uint256 totalSupply
  ) external;


  function getRewardsBalance(address[] calldata assetsToCheck, address user)
    external
    view
    returns (uint256);


  function claimRewards(
    address[] calldata assetsToClaim,
    uint256 amount,
    address to
  ) external returns (uint256);


  function claimRewardsOnBehalf(
    address[] calldata assetsToClaim,
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
pragma solidity 0.8.11;


interface IInitializableVToken {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address treasury,
    address incentivesController,
    uint8 vTokenDecimals,
    string vTokenName,
    string vTokenSymbol,
    bytes params
  );

  function initialize(
    ILendingPool pool,
    address treasury,
    address underlyingAsset,
    IAaveIncentivesController incentivesController,
    uint8 vTokenDecimals,
    string calldata vTokenName,
    string calldata vTokenSymbol,
    bytes calldata params
  ) external;

}// agpl-3.0
pragma solidity 0.8.11;


interface IVToken is IERC20, IScaledBalanceToken, IInitializableVToken {

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


  function handleRepayment(address user, uint256 amount) external;


  function getIncentivesController() external view returns (IAaveIncentivesController);


  function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}pragma solidity 0.8.11;


interface ITimeLockableERC721 is IERC721 {

  event TimeLocked(
    uint256 indexed tokenid,
    uint256 indexed lockType,
    uint40 indexed expirationTime
  );

  function lock(uint256 tokenid, uint16 lockType) external;


  function getUnlockTime(uint256 tokenId) external view returns(uint40 unlockTime);


  function getLockData(uint256 tokenId) external view returns(DataTypes.TimeLock memory lock);


  function unlockedBalanceOfBatch(address user, uint256[] memory tokenIds) external view returns(uint256[] memory amounts);


  function tokensAndLocksByAccount(address user) external view returns(uint256[] memory tokenIds, DataTypes.TimeLock[] memory locks);

}// agpl-3.0
pragma solidity 0.8.11;


interface IInitializableNToken {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    string nTokenName,
    string nTokenSymbol,
    string baseURI,
    bytes params
  );

  function initialize(
    ILendingPool pool,
    address underlyingAsset,
    string calldata nTokenName,
    string calldata nTokenSymbol,
    string calldata baseURI,
    bytes calldata params
  ) external;

}// agpl-3.0
pragma solidity 0.8.11;


interface INToken is ITimeLockableERC721, IInitializableNToken {

    event Mint(address indexed from, uint256 tokenId, uint256 value);

    function mint(
        address user,
        uint256 tokenId,
        uint256 amount
    ) external returns (bool);


  event Burn(address indexed from, address indexed target, uint256 tokenId, uint256 value);

  event BalanceTransfer(address indexed from, address indexed to, uint256 tokenId, uint256 amount);

  event BalanceBatchTransfer(address indexed from, address indexed to, uint256[] tokenIds, uint256[] amounts);

  function burn(
    address user,
    address receiverOfUnderlying,
    uint256 tokenId,
    uint256 amount
  ) external;


  function burnBatch(
    address user,
    address receiverOfUnderlying,
    uint256[] memory tokenIds,
    uint256[] memory amounts
  ) external;


  function transferOnLiquidation(
    address from,
    address to,
    uint256[] memory tokenIds,
    uint256[] memory values
  ) external;


  function transferUnderlyingTo(address user, uint256 tokenId, uint256 amount) external returns (uint256);


  function getLiquidationAmounts(address user, uint256 maxTotal, uint256[] memory tokenIds, uint256[] memory amounts) external view returns(uint256, uint256[] memory);


  function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;



interface IERC721WithStat is IERC721Enumerable{

    function balanceOfBatch(address user, uint256[] calldata ids) external view returns (uint256[] memory);

    function tokensByAccount(address account) external view returns (uint256[] memory);

    function getUserBalanceAndSupply(address user) external view returns (uint256, uint256);

}// agpl-3.0
pragma solidity 0.8.11;


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
    IAaveIncentivesController incentivesController,
    uint8 debtTokenDecimals,
    string memory debtTokenName,
    string memory debtTokenSymbol,
    bytes calldata params
  ) external;

}// agpl-3.0
pragma solidity 0.8.11;


interface IVariableDebtToken is IScaledBalanceToken, IInitializableDebtToken {

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


  function getIncentivesController() external view returns (IAaveIncentivesController);

}// agpl-3.0
pragma solidity 0.8.11;


interface IPriceOracleGetter {

  function getAssetPrice(address asset) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.11;
interface ILendingPoolCollateralManager {

  struct NFTLiquidationCallData{
    uint256 debtToCover;
    uint256 extraAssetToPay;
    uint256[] liquidatedCollateralTokenIds;
    uint256[] liquidatedCollateralAmounts;
    address liquidator;
    bool receiveNToken;
  }

  event NFTLiquidationCall(
    address indexed collateral,
    address indexed principal,
    address indexed user,
    bytes data
  );

  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  event NFTVaultUsedAsCollateralDisabled(address indexed vault, address indexed user);

  event NFTVaultUsedAsCollateralEnabled(address indexed vault, address indexed user);

  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount
  );

  struct NFTLiquidationCallParameters {
    address collateralAsset;
    address debtAsset;
    address user;
    uint256[] tokenIds;
    uint256[] amounts;
    bool receiveNToken;
  }

  function nftLiquidationCall(
    NFTLiquidationCallParameters memory params
  ) external returns (uint256, string memory);

}// MIT

pragma solidity ^0.8.0;

interface INFTXEligibility {

    function name() external pure returns (string memory);

    function finalized() external view returns (bool);

    function targetAsset() external pure returns (address);

    function checkAllEligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool);

    function checkEligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool[] memory);

    function checkAllIneligible(uint256[] calldata tokenIds)
        external
        view
        returns (bool);

    function checkIsEligible(uint256 tokenId) external view returns (bool);


    function __NFTXEligibility_init_bytes(bytes calldata configData) external;

    function beforeMintHook(uint256[] calldata tokenIds) external;

    function afterMintHook(uint256[] calldata tokenIds) external;

    function beforeRedeemHook(uint256[] calldata tokenIds) external;

    function afterRedeemHook(uint256[] calldata tokenIds) external;

    function afterLiquidationHook(uint256[] calldata tokenIds, uint256[] calldata amounts) external;

}// agpl-3.0
pragma solidity 0.8.11;

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
}// LGPL-3.0-or-later
pragma solidity 0.8.11;


library GPv2SafeERC20 {

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {

    bytes4 selector_ = token.transfer.selector;

    assembly {
      let freeMemoryPointer := mload(0x40)
      mstore(freeMemoryPointer, selector_)
      mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(freeMemoryPointer, 36), value)

      if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }

    require(getLastTransferResult(token), 'GPv2: failed transfer');
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {

    bytes4 selector_ = token.transferFrom.selector;

    assembly {
      let freeMemoryPointer := mload(0x40)
      mstore(freeMemoryPointer, selector_)
      mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(freeMemoryPointer, 68), value)

      if iszero(call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }

    require(getLastTransferResult(token), 'GPv2: failed transferFrom');
  }

  function getLastTransferResult(IERC20 token) private view returns (bool success) {

    assembly {
      function revertWithMessage(length, message) {
        mstore(0x00, '\x08\xc3\x79\xa0')
        mstore(0x04, 0x20)
        mstore(0x24, length)
        mstore(0x44, message)
        revert(0x00, 0x64)
      }

      switch returndatasize()
      case 0 {
        if iszero(extcodesize(token)) {
          revertWithMessage(20, 'GPv2: not a contract')
        }

        success := 1
      }
      case 32 {
        returndatacopy(0, 0, returndatasize())

        success := iszero(iszero(mload(0)))
      }
      default {
        revertWithMessage(31, 'GPv2: malformed transfer result')
      }
    }
  }
}// agpl-3.0
pragma solidity 0.8.11;

interface IReserveInterestRateStrategy {

  function baseVariableBorrowRate() external view returns (uint256);


  function getMaxVariableBorrowRate() external view returns (uint256);


  function calculateInterestRates(
    address reserve,
    uint256 availableLiquidity,
    uint256 totalStableDebt,
    uint256 totalVariableDebt,
    uint256 averageStableBorrowRate,
    uint256 reserveFactor
  )
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );


  function calculateInterestRates(
    address reserve,
    address vToken,
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
pragma solidity 0.8.11;

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
  string public constant LPC_INVALID_VTOKEN_POOL_ADDRESS = '35'; // 'The liquidity of the reserve needs to be 0'
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
  string public constant LP_CALLER_MUST_BE_AN_VTOKEN = '63';
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
  string public constant CT_CALLER_MUST_BE_CLAIM_ADMIN = '81';
  string public constant CT_TOKEN_CAN_NOT_BE_UNDERLYING = '82';
  string public constant CT_TOKEN_CAN_NOT_BE_SELF = '83';
  string public constant VL_NFT_LOCK_ACTION_IS_EXPIRED = '84';
  string public constant NL_VAULT_ALREADY_INITIALIZED = '100'; // 'NFT vault has already been initialized'
  string public constant VL_NFT_INELIGIBLE_TOKEN_ID = '130';
  string public constant LP_TOKEN_AND_AMOUNT_LENGTH_NOT_MATCH = "148";


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
pragma solidity 0.8.11;


library ReserveConfiguration {

  uint256 constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
  uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
  uint256 constant LIQUIDATION_BONUS_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
  uint256 constant DECIMALS_MASK =              0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFF; // prettier-ignore
  uint256 constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant BORROWING_MASK =             0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant STABLE_BORROWING_MASK =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant RESERVE_FACTOR_MASK =        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFF; // prettier-ignore

  uint256 constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
  uint256 constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
  uint256 constant RESERVE_DECIMALS_START_BIT_POSITION = 48;
  uint256 constant IS_ACTIVE_START_BIT_POSITION = 56;
  uint256 constant IS_FROZEN_START_BIT_POSITION = 57;
  uint256 constant BORROWING_ENABLED_START_BIT_POSITION = 58;
  uint256 constant STABLE_BORROWING_ENABLED_START_BIT_POSITION = 59;
  uint256 constant RESERVE_FACTOR_START_BIT_POSITION = 64;

  uint256 constant MAX_VALID_LTV = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_THRESHOLD = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_BONUS = 65535;
  uint256 constant MAX_VALID_DECIMALS = 255;
  uint256 constant MAX_VALID_RESERVE_FACTOR = 65535;

  function setLtv(DataTypes.ReserveConfigurationMap memory self, uint256 ltv) internal pure {

    require(ltv <= MAX_VALID_LTV, Errors.RC_INVALID_LTV);

    self.data = (self.data & LTV_MASK) | ltv;
  }

  function getLtv(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {

    return self.data & ~LTV_MASK;
  }

  function setLiquidationThreshold(DataTypes.ReserveConfigurationMap memory self, uint256 threshold)
    internal
    pure
  {

    require(threshold <= MAX_VALID_LIQUIDATION_THRESHOLD, Errors.RC_INVALID_LIQ_THRESHOLD);

    self.data =
      (self.data & LIQUIDATION_THRESHOLD_MASK) |
      (threshold << LIQUIDATION_THRESHOLD_START_BIT_POSITION);
  }

  function getLiquidationThreshold(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (uint256)
  {

    return (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION;
  }

  function setLiquidationBonus(DataTypes.ReserveConfigurationMap memory self, uint256 bonus)
    internal
    pure
  {

    require(bonus <= MAX_VALID_LIQUIDATION_BONUS, Errors.RC_INVALID_LIQ_BONUS);

    self.data =
      (self.data & LIQUIDATION_BONUS_MASK) |
      (bonus << LIQUIDATION_BONUS_START_BIT_POSITION);
  }

  function getLiquidationBonus(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (uint256)
  {

    return (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION;
  }

  function setDecimals(DataTypes.ReserveConfigurationMap memory self, uint256 decimals)
    internal
    pure
  {

    require(decimals <= MAX_VALID_DECIMALS, Errors.RC_INVALID_DECIMALS);

    self.data = (self.data & DECIMALS_MASK) | (decimals << RESERVE_DECIMALS_START_BIT_POSITION);
  }

  function getDecimals(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (uint256)
  {

    return (self.data & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION;
  }

  function setActive(DataTypes.ReserveConfigurationMap memory self, bool active) internal pure {

    self.data =
      (self.data & ACTIVE_MASK) |
      (uint256(active ? 1 : 0) << IS_ACTIVE_START_BIT_POSITION);
  }

  function getActive(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~ACTIVE_MASK) != 0;
  }

  function setFrozen(DataTypes.ReserveConfigurationMap memory self, bool frozen) internal pure {

    self.data =
      (self.data & FROZEN_MASK) |
      (uint256(frozen ? 1 : 0) << IS_FROZEN_START_BIT_POSITION);
  }

  function getFrozen(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~FROZEN_MASK) != 0;
  }

  function setBorrowingEnabled(DataTypes.ReserveConfigurationMap memory self, bool enabled)
    internal
    pure
  {

    self.data =
      (self.data & BORROWING_MASK) |
      (uint256(enabled ? 1 : 0) << BORROWING_ENABLED_START_BIT_POSITION);
  }

  function getBorrowingEnabled(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
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
      (uint256(enabled ? 1 : 0) << STABLE_BORROWING_ENABLED_START_BIT_POSITION);
  }

  function getStableRateBorrowingEnabled(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (bool)
  {

    return (self.data & ~STABLE_BORROWING_MASK) != 0;
  }

  function setReserveFactor(DataTypes.ReserveConfigurationMap memory self, uint256 reserveFactor)
    internal
    pure
  {

    require(reserveFactor <= MAX_VALID_RESERVE_FACTOR, Errors.RC_INVALID_RESERVE_FACTOR);

    self.data =
      (self.data & RESERVE_FACTOR_MASK) |
      (reserveFactor << RESERVE_FACTOR_START_BIT_POSITION);
  }

  function getReserveFactor(DataTypes.ReserveConfigurationMap storage self)
    internal
    view
    returns (uint256)
  {

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

    uint256 dataLocal = self.data;

    return (
      (dataLocal & ~ACTIVE_MASK) != 0,
      (dataLocal & ~FROZEN_MASK) != 0,
      (dataLocal & ~BORROWING_MASK) != 0,
      (dataLocal & ~STABLE_BORROWING_MASK) != 0
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

    uint256 dataLocal = self.data;

    return (
      dataLocal & ~LTV_MASK,
      (dataLocal & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (dataLocal & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION,
      (dataLocal & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION,
      (dataLocal & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION
    );
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

    return (
      self.data & ~LTV_MASK,
      (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION,
      (self.data & ~DECIMALS_MASK) >> RESERVE_DECIMALS_START_BIT_POSITION,
      (self.data & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION
    );
  }

  function getFlagsMemory(DataTypes.ReserveConfigurationMap memory self)
    internal
    pure
    returns (
      bool,
      bool,
      bool,
      bool
    )
  {

    return (
      (self.data & ~ACTIVE_MASK) != 0,
      (self.data & ~FROZEN_MASK) != 0,
      (self.data & ~BORROWING_MASK) != 0,
      (self.data & ~STABLE_BORROWING_MASK) != 0
    );
  }
}// agpl-3.0
pragma solidity 0.8.11;



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
pragma solidity 0.8.11;


library MathUtils {

  using WadRayMath for uint256;

  uint256 internal constant SECONDS_PER_YEAR = 365 days;


  function calculateLinearInterest(uint256 rate, uint40 lastUpdateTimestamp)
    internal
    view
    returns (uint256)
  {

    uint256 timeDifference = block.timestamp - uint256(lastUpdateTimestamp);

    return (rate * timeDifference / SECONDS_PER_YEAR + WadRayMath.ray());
  }

  function calculateCompoundedInterest(
    uint256 rate,
    uint40 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {

    uint256 exp = currentTimestamp - uint256(lastUpdateTimestamp);

    if (exp == 0) {
      return WadRayMath.ray();
    }

    uint256 expMinusOne = exp - 1;

    uint256 expMinusTwo = exp > 2 ? exp - 2 : 0;

    uint256 ratePerSecond = rate / SECONDS_PER_YEAR;

    uint256 basePowerTwo = ratePerSecond.rayMul(ratePerSecond);
    uint256 basePowerThree = basePowerTwo.rayMul(ratePerSecond);

    uint256 secondTerm = exp * expMinusOne * basePowerTwo/ 2;
    uint256 thirdTerm = exp * expMinusOne * expMinusTwo * basePowerThree / 6;

    return WadRayMath.ray() + ratePerSecond * exp + secondTerm + thirdTerm;
  }

  function calculateCompoundedInterest(uint256 rate, uint40 lastUpdateTimestamp)
    internal
    view
    returns (uint256)
  {

    return calculateCompoundedInterest(rate, lastUpdateTimestamp, block.timestamp);
  }
}// agpl-3.0
pragma solidity 0.8.11;



library PercentageMath {

  uint256 constant PERCENTAGE_FACTOR = 1e4; //percentage plus two decimals
  uint256 constant HALF_PERCENT = PERCENTAGE_FACTOR / 2;

  function percentMul(uint256 value, uint256 percentage) internal pure returns (uint256) {

    if (value == 0 || percentage == 0) {
      return 0;
    }

    require(
      value <= (type(uint256).max - HALF_PERCENT) / percentage,
      Errors.MATH_MULTIPLICATION_OVERFLOW
    );

    return (value * percentage + HALF_PERCENT) / PERCENTAGE_FACTOR;
  }

  function percentDiv(uint256 value, uint256 percentage) internal pure returns (uint256) {

    require(percentage != 0, Errors.MATH_DIVISION_BY_ZERO);
    uint256 halfPercentage = percentage / 2;

    require(
      value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR,
      Errors.MATH_MULTIPLICATION_OVERFLOW
    );

    return (value * PERCENTAGE_FACTOR + halfPercentage) / percentage;
  }
}// agpl-3.0
pragma solidity 0.8.11;


library ReserveLogic {

  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using GPv2SafeERC20 for IERC20;

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

  function getNormalizedIncome(DataTypes.ReserveData storage reserve)
    internal
    view
    returns (uint256)
  {

    uint40 timestamp = reserve.lastUpdateTimestamp;

    if (timestamp == uint40(block.timestamp)) {
      return reserve.liquidityIndex;
    }

    uint256 cumulated =
      MathUtils.calculateLinearInterest(reserve.currentLiquidityRate, timestamp).rayMul(
        reserve.liquidityIndex
      );

    return cumulated;
  }

  function getNormalizedDebt(DataTypes.ReserveData storage reserve)
    internal
    view
    returns (uint256)
  {

    uint40 timestamp = reserve.lastUpdateTimestamp;

    if (timestamp == uint40(block.timestamp)) {
      return reserve.variableBorrowIndex;
    }

    uint256 cumulated =
      MathUtils.calculateCompoundedInterest(reserve.currentVariableBorrowRate, timestamp).rayMul(
        reserve.variableBorrowIndex
      );

    return cumulated;
  }

  function updateState(DataTypes.ReserveData storage reserve) internal {

    uint256 scaledVariableDebt =
      IVariableDebtToken(reserve.variableDebtTokenAddress).scaledTotalSupply();
    uint256 previousVariableBorrowIndex = reserve.variableBorrowIndex;
    uint256 previousLiquidityIndex = reserve.liquidityIndex;
    uint40 lastUpdatedTimestamp = reserve.lastUpdateTimestamp;

    (uint256 newLiquidityIndex, uint256 newVariableBorrowIndex) =
      _updateIndexes(
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
  }

  function cumulateToLiquidityIndex(
    DataTypes.ReserveData storage reserve,
    uint256 totalLiquidity,
    uint256 amount
  ) internal {

    uint256 amountToLiquidityRatio = amount.wadToRay().rayDiv(totalLiquidity.wadToRay());

    uint256 result = amountToLiquidityRatio + WadRayMath.ray();

    result = result.rayMul(reserve.liquidityIndex);
    require(result <= type(uint128).max, Errors.RL_LIQUIDITY_INDEX_OVERFLOW);

    reserve.liquidityIndex = uint128(result);
  }

  function init(
    DataTypes.ReserveData storage reserve,
    address vTokenAddress,
    address stableDebtTokenAddress,
    address variableDebtTokenAddress,
    address interestRateStrategyAddress
  ) external {

    require(reserve.vTokenAddress == address(0), Errors.RL_RESERVE_ALREADY_INITIALIZED);

    reserve.liquidityIndex = uint128(WadRayMath.ray());
    reserve.variableBorrowIndex = uint128(WadRayMath.ray());
    reserve.vTokenAddress = vTokenAddress;
    reserve.stableDebtTokenAddress = stableDebtTokenAddress;
    reserve.variableDebtTokenAddress = variableDebtTokenAddress;
    reserve.interestRateStrategyAddress = interestRateStrategyAddress;
  }

  struct UpdateInterestRatesLocalVars {
    uint256 availableLiquidity;
    uint256 newLiquidityRate;
    uint256 newVariableRate;
    uint256 totalVariableDebt;
  }

  function updateInterestRates(
    DataTypes.ReserveData storage reserve,
    address reserveAddress,
    address vTokenAddress,
    uint256 liquidityAdded,
    uint256 liquidityTaken
  ) internal {

    UpdateInterestRatesLocalVars memory vars;



    vars.totalVariableDebt = IVariableDebtToken(reserve.variableDebtTokenAddress)
      .scaledTotalSupply()
      .rayMul(reserve.variableBorrowIndex);

    (
      vars.newLiquidityRate,
      ,
      vars.newVariableRate
    ) = IReserveInterestRateStrategy(reserve.interestRateStrategyAddress).calculateInterestRates(
      reserveAddress,
      vTokenAddress,
      liquidityAdded,
      liquidityTaken,
      0,//vars.totalStableDebt,
      vars.totalVariableDebt,
      0,//vars.avgStableRate,
      reserve.configuration.getReserveFactor()
    );
    require(vars.newLiquidityRate <= type(uint128).max, Errors.RL_LIQUIDITY_RATE_OVERFLOW);
    require(vars.newVariableRate <= type(uint128).max, Errors.RL_VARIABLE_BORROW_RATE_OVERFLOW);

    reserve.currentLiquidityRate = uint128(vars.newLiquidityRate);
    reserve.currentVariableBorrowRate = uint128(vars.newVariableRate);

    emit ReserveDataUpdated(
      reserveAddress,
      vars.newLiquidityRate,
      0, //vars.newStableRate,
      vars.newVariableRate,
      reserve.liquidityIndex,
      reserve.variableBorrowIndex
    );
  }

  struct MintToTreasuryLocalVars {
    uint256 currentVariableDebt;
    uint256 previousVariableDebt;
    uint256 totalDebtAccrued;
    uint256 amountToMint;
    uint256 reserveFactor;
  }

  function _mintToTreasury(
    DataTypes.ReserveData storage reserve,
    uint256 scaledVariableDebt,
    uint256 previousVariableBorrowIndex,
    uint256 newLiquidityIndex,
    uint256 newVariableBorrowIndex,
    uint40 timestamp
  ) internal {

    MintToTreasuryLocalVars memory vars;

    vars.reserveFactor = reserve.configuration.getReserveFactor();

    if (vars.reserveFactor == 0) {
      return;
    }


    vars.previousVariableDebt = scaledVariableDebt.rayMul(previousVariableBorrowIndex);

    vars.currentVariableDebt = scaledVariableDebt.rayMul(newVariableBorrowIndex);



    vars.totalDebtAccrued = vars.currentVariableDebt - vars.previousVariableDebt;

    vars.amountToMint = vars.totalDebtAccrued.percentMul(vars.reserveFactor);

    if (vars.amountToMint != 0) {
      IVToken(reserve.vTokenAddress).mintToTreasury(vars.amountToMint, newLiquidityIndex);
    }
  }

  function _updateIndexes(
    DataTypes.ReserveData storage reserve,
    uint256 scaledVariableDebt,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex,
    uint40 timestamp
  ) internal returns (uint256, uint256) {

    uint256 currentLiquidityRate = reserve.currentLiquidityRate;

    uint256 newLiquidityIndex = liquidityIndex;
    uint256 newVariableBorrowIndex = variableBorrowIndex;

    if (currentLiquidityRate > 0) {
      uint256 cumulatedLiquidityInterest =
        MathUtils.calculateLinearInterest(currentLiquidityRate, timestamp);
      newLiquidityIndex = cumulatedLiquidityInterest.rayMul(liquidityIndex);
      require(newLiquidityIndex <= type(uint128).max, Errors.RL_LIQUIDITY_INDEX_OVERFLOW);

      reserve.liquidityIndex = uint128(newLiquidityIndex);

      if (scaledVariableDebt != 0) {
        uint256 cumulatedVariableBorrowInterest =
          MathUtils.calculateCompoundedInterest(reserve.currentVariableBorrowRate, timestamp);
        newVariableBorrowIndex = cumulatedVariableBorrowInterest.rayMul(variableBorrowIndex);
        require(
          newVariableBorrowIndex <= type(uint128).max,
          Errors.RL_VARIABLE_BORROW_INDEX_OVERFLOW
        );
        reserve.variableBorrowIndex = uint128(newVariableBorrowIndex);
      }
    }

    reserve.lastUpdateTimestamp = uint40(block.timestamp);
    return (newLiquidityIndex, newVariableBorrowIndex);
  }
}// agpl-3.0
pragma solidity 0.8.11;


library NFTVaultConfiguration {

  uint256 constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
  uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
  uint256 constant LIQUIDATION_BONUS_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
  uint256 constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore

  uint256 constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
  uint256 constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
  uint256 constant IS_ACTIVE_START_BIT_POSITION = 56;
  uint256 constant IS_FROZEN_START_BIT_POSITION = 57;

  uint256 constant MAX_VALID_LTV = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_THRESHOLD = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_BONUS = 65535;

  function setLtv(DataTypes.NFTVaultConfigurationMap memory self, uint256 ltv) internal pure {

    require(ltv <= MAX_VALID_LTV, Errors.RC_INVALID_LTV);

    self.data = (self.data & LTV_MASK) | ltv;
  }

  function getLtv(DataTypes.NFTVaultConfigurationMap storage self) internal view returns (uint256) {

    return self.data & ~LTV_MASK;
  }

  function setLiquidationThreshold(DataTypes.NFTVaultConfigurationMap memory self, uint256 threshold)
    internal
    pure
  {

    require(threshold <= MAX_VALID_LIQUIDATION_THRESHOLD, Errors.RC_INVALID_LIQ_THRESHOLD);

    self.data =
      (self.data & LIQUIDATION_THRESHOLD_MASK) |
      (threshold << LIQUIDATION_THRESHOLD_START_BIT_POSITION);
  }

  function getLiquidationThreshold(DataTypes.NFTVaultConfigurationMap storage self)
    internal
    view
    returns (uint256)
  {

    return (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION;
  }

  function setLiquidationBonus(DataTypes.NFTVaultConfigurationMap memory self, uint256 bonus)
    internal
    pure
  {

    require(bonus <= MAX_VALID_LIQUIDATION_BONUS, Errors.RC_INVALID_LIQ_BONUS);

    self.data =
      (self.data & LIQUIDATION_BONUS_MASK) |
      (bonus << LIQUIDATION_BONUS_START_BIT_POSITION);
  }

  function getLiquidationBonus(DataTypes.NFTVaultConfigurationMap storage self)
    internal
    view
    returns (uint256)
  {

    return (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION;
  }

  function setActive(DataTypes.NFTVaultConfigurationMap memory self, bool active) internal pure {

    self.data =
      (self.data & ACTIVE_MASK) |
      (uint256(active ? 1 : 0) << IS_ACTIVE_START_BIT_POSITION);
  }

  function getActive(DataTypes.NFTVaultConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~ACTIVE_MASK) != 0;
  }

  function setFrozen(DataTypes.NFTVaultConfigurationMap memory self, bool frozen) internal pure {

    self.data =
      (self.data & FROZEN_MASK) |
      (uint256(frozen ? 1 : 0) << IS_FROZEN_START_BIT_POSITION);
  }

  function getFrozen(DataTypes.NFTVaultConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~FROZEN_MASK) != 0;
  }

  function getFlags(DataTypes.NFTVaultConfigurationMap storage self)
    internal
    view
    returns (
      bool,
      bool
    )
  {

    uint256 dataLocal = self.data;

    return (
      (dataLocal & ~ACTIVE_MASK) != 0,
      (dataLocal & ~FROZEN_MASK) != 0
    );
  }

  function getParams(DataTypes.NFTVaultConfigurationMap storage self)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {

    uint256 dataLocal = self.data;

    return (
      dataLocal & ~LTV_MASK,
      (dataLocal & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (dataLocal & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION      
    );
  }

  function getParamsMemory(DataTypes.NFTVaultConfigurationMap memory self)
    internal
    pure
    returns (
      uint256,
      uint256,
      uint256
    )
  {

    return (
      self.data & ~LTV_MASK,
      (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION,
      (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION
    );
  }

  function getFlagsMemory(DataTypes.NFTVaultConfigurationMap memory self)
    internal
    pure
    returns (
      bool,
      bool
    )
  {

    return (
      (self.data & ~ACTIVE_MASK) != 0,
      (self.data & ~FROZEN_MASK) != 0
    );
  }
}// agpl-3.0
pragma solidity 0.8.11;


library NFTVaultLogic {

  using NFTVaultLogic for DataTypes.NFTVaultData;
  using NFTVaultConfiguration for DataTypes.NFTVaultConfigurationMap;

  function init(
    DataTypes.NFTVaultData storage reserve,
    address nTokenAddress,
    address nftEligibility
  ) external {

    require(reserve.nTokenAddress == address(0), Errors.NL_VAULT_ALREADY_INITIALIZED);
    reserve.nTokenAddress = nTokenAddress;
    reserve.nftEligibility = nftEligibility;
  }

}// agpl-3.0
pragma solidity 0.8.11;


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

  function setUsingNFTVaultAsCollateral(
    DataTypes.UserConfigurationMap storage self,
    uint256 vaultIndex,
    bool usingAsCollateral
  ) internal {

    require(vaultIndex < 256, Errors.UL_INVALID_INDEX);
    self.nData =
      (self.nData & ~(1 << vaultIndex)) |
      (uint256(usingAsCollateral ? 1 : 0) << vaultIndex);
  }

  function isUsingAsCollateralOrBorrowing(
    DataTypes.UserConfigurationMap memory self,
    uint256 reserveIndex
  ) internal pure returns (bool) {

    require(reserveIndex < 128, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 2)) & 3 != 0;
  }

  function isBorrowing(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex)
    internal
    pure
    returns (bool)
  {

    require(reserveIndex < 128, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 2)) & 1 != 0;
  }

  function isUsingAsCollateral(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex)
    internal
    pure
    returns (bool)
  {

    require(reserveIndex < 128, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 2 + 1)) & 1 != 0;
  }

  function isUsingNFTVaultAsCollateral(DataTypes.UserConfigurationMap memory self, uint256 vaultIndex)
    internal
    pure
    returns (bool)
  {

    require(vaultIndex < 256, Errors.UL_INVALID_INDEX);
    return (self.nData >> vaultIndex) & 1 != 0;
  }

  function isBorrowingAny(DataTypes.UserConfigurationMap memory self) internal pure returns (bool) {

    return self.data & BORROWING_MASK != 0;
  }

  function isEmpty(DataTypes.UserConfigurationMap memory self) internal pure returns (bool) {

    return self.data == 0 && self.nData == 0;
  }
}// agpl-3.0
pragma solidity 0.8.11;


library GenericLogic {

  using ReserveLogic for DataTypes.ReserveData;
  using NFTVaultLogic for DataTypes.NFTVaultData;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using NFTVaultConfiguration for DataTypes.NFTVaultConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 public constant HEALTH_FACTOR_LIQUIDATION_THRESHOLD = 1 ether;

  struct balanceDecreaseAllowedLocalVars {
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
    DataTypes.PoolReservesData storage reserves,
    DataTypes.PoolNFTVaultsData storage nftVaults,
    DataTypes.UserConfigurationMap calldata userConfig,
    address oracle
  ) external view returns (bool) {

    if (!userConfig.isBorrowingAny()) {
      return true;
    }

    balanceDecreaseAllowedLocalVars memory vars;

    (, vars.liquidationThreshold, ) = nftVaults.data[asset]
      .configuration
      .getParams();

    if (vars.liquidationThreshold == 0) {
      return true;
    }

    (
      vars.totalCollateralInETH,
      vars.totalDebtInETH,
      ,
      vars.avgLiquidationThreshold,

    ) = calculateUserAccountData(user, reserves, nftVaults, userConfig, oracle);

    if (vars.totalDebtInETH == 0) {
      return true;
    }

    vars.amountToDecreaseInETH = IPriceOracleGetter(oracle).getAssetPrice(asset) * amount;

    vars.collateralBalanceAfterDecrease = vars.totalCollateralInETH - vars.amountToDecreaseInETH;

    if (vars.collateralBalanceAfterDecrease == 0) {
      return false;
    }

    vars.liquidationThresholdAfterDecrease = (vars.totalCollateralInETH * vars.avgLiquidationThreshold
      - vars.amountToDecreaseInETH * vars.liquidationThreshold)
      / vars.collateralBalanceAfterDecrease;

    uint256 healthFactorAfterDecrease =
      calculateHealthFactorFromBalances(
        vars.collateralBalanceAfterDecrease,
        vars.totalDebtInETH,
        vars.liquidationThresholdAfterDecrease
      );

    return healthFactorAfterDecrease >= GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD;
  }

  struct CalculateUserAccountDataVars {
    uint256 reserveUnitPrice;
    uint256 tokenUnit;
    uint256 compoundedLiquidityBalance;
    uint256 compoundedBorrowBalance;
    uint256 decimals;
    uint256 ltv;
    uint256 liquidationThreshold;
    uint256 i;
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
    DataTypes.PoolReservesData storage reserves,
    DataTypes.PoolNFTVaultsData storage nftVaults,
    DataTypes.UserConfigurationMap memory userConfig,
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

    CalculateUserAccountDataVars memory vars;

    if (userConfig.isEmpty()) {
      return (0, 0, 0, 0, type(uint256).max);
    }
    for (vars.i = 0; vars.i < reserves.count; vars.i++) {
      if (!userConfig.isUsingAsCollateralOrBorrowing(vars.i)) {
        continue;
      }

      vars.currentReserveAddress = reserves.list[vars.i];
      DataTypes.ReserveData storage currentReserve = reserves.data[vars.currentReserveAddress];

      (vars.ltv, vars.liquidationThreshold, , vars.decimals, ) = currentReserve
        .configuration
        .getParams();

      vars.tokenUnit = 10**vars.decimals;
      vars.reserveUnitPrice = IPriceOracleGetter(oracle).getAssetPrice(vars.currentReserveAddress);

      if (vars.liquidationThreshold != 0 && userConfig.isUsingAsCollateral(vars.i)) {
        vars.compoundedLiquidityBalance = IERC20(currentReserve.vTokenAddress).balanceOf(user);

        uint256 liquidityBalanceETH =
          vars.reserveUnitPrice * vars.compoundedLiquidityBalance / vars.tokenUnit;

        vars.totalCollateralInETH = vars.totalCollateralInETH + liquidityBalanceETH;

        vars.avgLtv = vars.avgLtv + liquidityBalanceETH * vars.ltv;
        vars.avgLiquidationThreshold = vars.avgLiquidationThreshold
          + liquidityBalanceETH * vars.liquidationThreshold;
      }

      if (userConfig.isBorrowing(vars.i)) {
        vars.compoundedBorrowBalance = IERC20(currentReserve.variableDebtTokenAddress).balanceOf(user);

        vars.totalDebtInETH = vars.totalDebtInETH
          + vars.reserveUnitPrice * vars.compoundedBorrowBalance / vars.tokenUnit;
      }
    }

    for (vars.i = 0; vars.i < nftVaults.count; vars.i++) {
      if (!userConfig.isUsingNFTVaultAsCollateral(vars.i)) {
        continue;
      }

      vars.currentReserveAddress = nftVaults.list[vars.i];
      DataTypes.NFTVaultData storage currentVault = nftVaults.data[vars.currentReserveAddress];

      (vars.ltv, vars.liquidationThreshold, ) = currentVault
        .configuration
        .getParams();

      vars.reserveUnitPrice = IPriceOracleGetter(oracle).getAssetPrice(vars.currentReserveAddress);

      if (vars.liquidationThreshold != 0 && userConfig.isUsingNFTVaultAsCollateral(vars.i)) {
        vars.compoundedLiquidityBalance = IERC721WithStat(currentVault.nTokenAddress).balanceOf(user);

        uint256 liquidityBalanceETH =
          vars.reserveUnitPrice * vars.compoundedLiquidityBalance;

        vars.totalCollateralInETH = vars.totalCollateralInETH + liquidityBalanceETH;

        vars.avgLtv = vars.avgLtv + liquidityBalanceETH * vars.ltv;
        vars.avgLiquidationThreshold = vars.avgLiquidationThreshold
          + liquidityBalanceETH * vars.liquidationThreshold;
      }
    }

    vars.avgLtv = vars.totalCollateralInETH > 0 ? vars.avgLtv / vars.totalCollateralInETH : 0;
    vars.avgLiquidationThreshold = vars.totalCollateralInETH > 0
      ? vars.avgLiquidationThreshold / vars.totalCollateralInETH
      : 0;

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

    if (totalDebtInETH == 0) return type(uint256).max;

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
pragma solidity 0.8.11;


library Helpers {

  function getUserCurrentDebt(address user, DataTypes.ReserveData storage reserve)
    internal
    view
    returns (uint256, uint256)
  {

    return (
      0, //IERC20(reserve.stableDebtTokenAddress).balanceOf(user),
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }

  function getUserCurrentDebtMemory(address user, DataTypes.ReserveData memory reserve)
    internal
    view
    returns (uint256, uint256)
  {

    return (
      0, //IERC20(reserve.stableDebtTokenAddress).balanceOf(user),
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }
}// agpl-3.0
pragma solidity 0.8.11;


library ValidationLogic {

  using ReserveLogic for DataTypes.ReserveData;
  using NFTVaultLogic for DataTypes.NFTVaultData;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using GPv2SafeERC20 for IERC20;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using NFTVaultConfiguration for DataTypes.NFTVaultConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 public constant REBALANCE_UP_LIQUIDITY_RATE_THRESHOLD = 4000;
  uint256 public constant REBALANCE_UP_USAGE_RATIO_THRESHOLD = 0.95 * 1e27; //usage ratio of 95%

  function validateDeposit(DataTypes.ReserveData storage reserve, uint256 amount) external view {

    (bool isActive, bool isFrozen, , ) = reserve.configuration.getFlags();

    require(amount != 0, Errors.VL_INVALID_AMOUNT);
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!isFrozen, Errors.VL_RESERVE_FROZEN);
  }

  function validateDepositNFT(DataTypes.NFTVaultData storage vault, uint256[] memory ids, uint256[] memory amounts) external view {

    (bool isActive, bool isFrozen) = vault.configuration.getFlags();

    require(ids.length != 0, Errors.VL_INVALID_AMOUNT);
    for(uint256 i = 0; i < ids.length; ++i) {
      require(amounts[i] != 0, Errors.VL_INVALID_AMOUNT);
    }
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!isFrozen, Errors.VL_RESERVE_FROZEN);
    INFTXEligibility eligibility = INFTXEligibility(vault.nftEligibility);
    require(eligibility.checkAllEligible(ids), Errors.VL_NFT_INELIGIBLE_TOKEN_ID);
  }

  function validateLockNFT(DataTypes.NFTVaultData storage vault, uint40 now) external view {

    require(vault.expiration >= now, Errors.VL_NFT_LOCK_ACTION_IS_EXPIRED);
  }

  function validateWithdraw(
    address reserveAddress,
    uint256 amount,
    uint256 userBalance,
    DataTypes.PoolReservesData storage reserves,
    DataTypes.UserConfigurationMap storage userConfig,
    address oracle
  ) external view {

    require(amount != 0, Errors.VL_INVALID_AMOUNT);
    require(amount <= userBalance, Errors.VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE);

    (bool isActive, , , ) = reserves.data[reserveAddress].configuration.getFlags();
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);
  }

  function validateWithdrawNFT(
    address vaultAddress,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts,
    uint256[] calldata userBalances,
    DataTypes.PoolReservesData storage reserves,
    DataTypes.PoolNFTVaultsData storage nftVaults,
    DataTypes.UserConfigurationMap storage userConfig,
    address oracle
  ) external view {

    require(tokenIds.length == amounts.length, Errors.VL_INVALID_AMOUNT);
    uint256 amount;
    for(uint256 i = 0; i < tokenIds.length; ++i) {
      require(amounts[i] != 0, Errors.VL_INVALID_AMOUNT);
      require(amounts[i] <= userBalances[i], Errors.VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE);
      amount = amount + amounts[i];
    }

    (bool isActive, ) = nftVaults.data[vaultAddress].configuration.getFlags();
    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);

    require(
      GenericLogic.balanceDecreaseAllowed(
        vaultAddress,
        msg.sender,
        amount,
        reserves,
        nftVaults,
        userConfig,
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
  }

  function validateBorrow(
    address asset,
    DataTypes.ReserveData storage reserve,
    address userAddress,
    uint256 amount,
    uint256 amountInETH,
    uint256 interestRateMode,
    uint256 maxStableLoanPercent,
    DataTypes.PoolReservesData storage reserves,
    DataTypes.PoolNFTVaultsData storage nftVaults,
    DataTypes.UserConfigurationMap storage userConfig,
    address oracle
  ) external view {

    ValidateBorrowLocalVars memory vars;

    (vars.isActive, vars.isFrozen, vars.borrowingEnabled, ) = reserve
      .configuration
      .getFlags();

    require(vars.isActive, Errors.VL_NO_ACTIVE_RESERVE);
    require(!vars.isFrozen, Errors.VL_RESERVE_FROZEN);
    require(amount != 0, Errors.VL_INVALID_AMOUNT);

    require(vars.borrowingEnabled, Errors.VL_BORROWING_NOT_ENABLED);

    require(
      uint256(DataTypes.InterestRateMode.VARIABLE) == interestRateMode,
      Errors.VL_INVALID_INTEREST_RATE_MODE_SELECTED
    );

    (
      vars.userCollateralBalanceETH,
      vars.userBorrowBalanceETH,
      vars.currentLtv,
      vars.currentLiquidationThreshold,
      vars.healthFactor
    ) = GenericLogic.calculateUserAccountData(
      userAddress,
      reserves,
      nftVaults,
      userConfig,
      oracle
    );

    require(vars.userCollateralBalanceETH > 0, Errors.VL_COLLATERAL_BALANCE_IS_0);

    require(
      vars.healthFactor > GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      Errors.VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD
    );

    vars.amountOfCollateralNeededETH = (vars.userBorrowBalanceETH + amountInETH).percentDiv(
      vars.currentLtv
    ); //LTV is calculated in percentage

    require(
      vars.amountOfCollateralNeededETH <= vars.userCollateralBalanceETH,
      Errors.VL_COLLATERAL_CANNOT_COVER_NEW_BORROW
    );

  }

  function validateRepay(
    DataTypes.ReserveData storage reserve,
    uint256 amountSent,
    DataTypes.InterestRateMode rateMode,
    address onBehalfOf,
    uint256 stableDebt,
    uint256 variableDebt
  ) external view {

    bool isActive = reserve.configuration.getActive();

    require(isActive, Errors.VL_NO_ACTIVE_RESERVE);

    require(amountSent > 0, Errors.VL_INVALID_AMOUNT);

    require(
        (variableDebt > 0 &&
          DataTypes.InterestRateMode(rateMode) == DataTypes.InterestRateMode.VARIABLE),
      Errors.VL_NO_DEBT_OF_SELECTED_TYPE
    );

    require(
      amountSent != type(uint256).max || msg.sender == onBehalfOf,
      Errors.VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF
    );
  }

  function validateNFTFlashloan(address asset, uint256[] memory tokenIds, uint256[] memory amounts, uint256[] memory userBalances) internal pure {

    require(tokenIds.length == amounts.length, Errors.VL_INCONSISTENT_FLASHLOAN_PARAMS);
    for(uint256 i = 0; i < tokenIds.length; ++i) {
      require(amounts[i] != 0, Errors.VL_INVALID_AMOUNT);
      require(amounts[i] <= userBalances[i], Errors.VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE);
    }
  }

  function validateNFTLiquidationCall(
    DataTypes.NFTVaultData storage collateralVault,
    DataTypes.ReserveData storage principalReserve,
    DataTypes.UserConfigurationMap storage userConfig,
    uint256 userHealthFactor,
    uint256 userStableDebt,
    uint256 userVariableDebt
  ) internal view returns (uint256, string memory) {

    if (
      !collateralVault.configuration.getActive() || !principalReserve.configuration.getActive()
    ) {
      return (
        uint256(Errors.CollateralManagerErrors.NO_ACTIVE_RESERVE),
        Errors.VL_NO_ACTIVE_RESERVE
      );
    }

    if (userHealthFactor >= GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD) {
      return (
        uint256(Errors.CollateralManagerErrors.HEALTH_FACTOR_ABOVE_THRESHOLD),
        Errors.LPCM_HEALTH_FACTOR_NOT_BELOW_THRESHOLD
      );
    }

    bool isCollateralEnabled =
      collateralVault.configuration.getLiquidationThreshold() > 0 &&
        userConfig.isUsingNFTVaultAsCollateral(collateralVault.id);

    if (!isCollateralEnabled) {
      return (
        uint256(Errors.CollateralManagerErrors.COLLATERAL_CANNOT_BE_LIQUIDATED),
        Errors.LPCM_COLLATERAL_CANNOT_BE_LIQUIDATED
      );
    }

    if (userVariableDebt == 0) {
      return (
        uint256(Errors.CollateralManagerErrors.CURRRENCY_NOT_BORROWED),
        Errors.LPCM_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER
      );
    }

    return (uint256(Errors.CollateralManagerErrors.NO_ERROR), Errors.LPCM_NO_ERRORS);
  }

  function validateTransfer(
    address from,
    DataTypes.PoolReservesData storage reserves,
    DataTypes.PoolNFTVaultsData storage nftVaults,
    DataTypes.UserConfigurationMap storage userConfig,
    address oracle
  ) internal view {

    (, , , , uint256 healthFactor) =
      GenericLogic.calculateUserAccountData(
        from,
        reserves,
        nftVaults,
        userConfig,
        oracle
      );

    require(
      healthFactor >= GenericLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      Errors.VL_TRANSFER_NOT_ALLOWED
    );
  }
}// agpl-3.0
pragma solidity 0.8.11;


contract LendingPoolStorage {

  using ReserveLogic for DataTypes.ReserveData;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using NFTVaultLogic for DataTypes.NFTVaultData;
  using NFTVaultConfiguration for DataTypes.NFTVaultConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  ILendingPoolAddressesProvider internal _addressesProvider;
  INFTXEligibility internal _nftEligibility;

  DataTypes.PoolReservesData internal _reserves;
  DataTypes.PoolNFTVaultsData internal _nftVaults;

  mapping(address => DataTypes.UserConfigurationMap) internal _usersConfig;

  bool internal _paused;

  uint256 internal _maxStableRateBorrowSizePercent;

  uint256 internal _flashLoanPremiumTotal;

  uint256 internal _maxNumberOfReserves;
  uint256 internal _maxNumberOfNFTVaults;
}// agpl-3.0
pragma solidity 0.8.11;


contract LendingPoolCollateralManager is
  ILendingPoolCollateralManager,
  VersionedInitializable,
  LendingPoolStorage
{

  using GPv2SafeERC20 for IERC20;
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using ReserveLogic for DataTypes.ReserveData;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using NFTVaultConfiguration for DataTypes.NFTVaultConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  uint256 internal constant LIQUIDATION_CLOSE_FACTOR_PERCENT = 5000;

  function getRevision() internal pure override returns (uint256) {

    return 0;
  }

  struct NFTLiquidationCallLocalVars {
    uint256[] maxCollateralAmountsToLiquidate;
    uint256 userVariableDebt;
    uint256 maxLiquidatableDebt;
    uint256 actualDebtToLiquidate;
    uint256 liquidationRatio;
    uint256 extraDebtAssetToPay;
    uint256 healthFactor;
    uint256 userCollateralBalance;
    uint256 totalCollateralToLiquidate;
    uint256 liquidatorPreviousNTokenBalance;
    INToken collateralNtoken;
    IERC721WithStat collateralTokenData;
    bool isCollateralEnabled;
    DataTypes.InterestRateMode borrowRateMode;
    uint256 errorCode;
    string errorMsg;
  }

  struct AvailableNFTCollateralToLiquidateParameters {
    address collateralAsset;
    address debtAsset;
    address user;
    uint256 debtToCover;
    uint256 userTotalDebt;
    uint256[] tokenIdsToLiquidate;
    uint256[] amountsToLiquidate;
  }

  function nftLiquidationCall(
    NFTLiquidationCallParameters calldata params
  ) external override returns (uint256, string memory) {

    DataTypes.NFTVaultData storage collateralVault = _nftVaults.data[params.collateralAsset];
    DataTypes.ReserveData storage debtReserve = _reserves.data[params.debtAsset];
    DataTypes.UserConfigurationMap storage userConfig = _usersConfig[params.user];

    NFTLiquidationCallLocalVars memory vars;

    (, , , , vars.healthFactor) = GenericLogic.calculateUserAccountData(
      params.user,
      _reserves,
      _nftVaults,
      userConfig,
      _addressesProvider.getPriceOracle()
    );

    (, vars.userVariableDebt) = Helpers.getUserCurrentDebt(params.user, debtReserve);

    (vars.errorCode, vars.errorMsg) = ValidationLogic.validateNFTLiquidationCall(
      collateralVault,
      debtReserve,
      userConfig,
      vars.healthFactor,
      0,//vars.userStableDebt,
      vars.userVariableDebt
    );

    if (Errors.CollateralManagerErrors(vars.errorCode) != Errors.CollateralManagerErrors.NO_ERROR) {
      return (vars.errorCode, vars.errorMsg);
    }

    vars.collateralNtoken = INToken(collateralVault.nTokenAddress);
    vars.collateralTokenData = IERC721WithStat(collateralVault.nTokenAddress);

    vars.maxLiquidatableDebt = vars.userVariableDebt.percentMul(
      LIQUIDATION_CLOSE_FACTOR_PERCENT
    );

    vars.actualDebtToLiquidate = vars.maxLiquidatableDebt;
    {
      AvailableNFTCollateralToLiquidateParameters memory callparams;
      callparams.collateralAsset = params.collateralAsset;
      callparams.debtAsset = params.debtAsset;
      callparams.user = params.user;
      callparams.debtToCover = vars.actualDebtToLiquidate;
      callparams.userTotalDebt = vars.userVariableDebt;
      callparams.tokenIdsToLiquidate = params.tokenIds;
      callparams.amountsToLiquidate = params.amounts;
      (
        vars.maxCollateralAmountsToLiquidate,
        vars.totalCollateralToLiquidate,
        vars.actualDebtToLiquidate,
        vars.extraDebtAssetToPay
      ) = _calculateAvailableNFTCollateralToLiquidate(
        collateralVault,
        debtReserve,
        callparams
      );
    }


    debtReserve.updateState();

    IVariableDebtToken(debtReserve.variableDebtTokenAddress).burn(
      params.user,
      vars.actualDebtToLiquidate,
      debtReserve.variableBorrowIndex
    );

    debtReserve.updateInterestRates(
      params.debtAsset,
      debtReserve.vTokenAddress,
      vars.actualDebtToLiquidate + vars.extraDebtAssetToPay,
      0
    );

    if (params.receiveNToken) {
      vars.liquidatorPreviousNTokenBalance = vars.collateralTokenData.balanceOf(msg.sender);
      vars.collateralNtoken.transferOnLiquidation(params.user, msg.sender, params.tokenIds, vars.maxCollateralAmountsToLiquidate);

      if (vars.liquidatorPreviousNTokenBalance == 0) {
        {
          DataTypes.UserConfigurationMap storage liquidatorConfig = _usersConfig[msg.sender];
          liquidatorConfig.setUsingNFTVaultAsCollateral(collateralVault.id, true);
        }
        emit NFTVaultUsedAsCollateralEnabled(params.collateralAsset, msg.sender);
      }
    } else {
      vars.collateralNtoken.burnBatch(
        params.user,
        msg.sender,
        params.tokenIds,
        vars.maxCollateralAmountsToLiquidate
      );
      INFTXEligibility(collateralVault.nftEligibility).afterLiquidationHook(params.tokenIds, vars.maxCollateralAmountsToLiquidate);
    }

    if (vars.totalCollateralToLiquidate == vars.collateralTokenData.balanceOf(params.user)) {
      userConfig.setUsingNFTVaultAsCollateral(collateralVault.id, false);
      emit NFTVaultUsedAsCollateralDisabled(params.collateralAsset, params.user);
    }

    IERC20(params.debtAsset).safeTransferFrom(
      msg.sender,
      debtReserve.vTokenAddress,
      vars.actualDebtToLiquidate + vars.extraDebtAssetToPay
    );

    if (vars.extraDebtAssetToPay != 0) {
      IVToken(debtReserve.vTokenAddress).mint(params.user, vars.extraDebtAssetToPay, debtReserve.liquidityIndex);
      emit Deposit(params.debtAsset, msg.sender, params.user, vars.extraDebtAssetToPay);
    }

    NFTLiquidationCallData memory data;
    data.debtToCover = vars.actualDebtToLiquidate;
    data.extraAssetToPay = vars.extraDebtAssetToPay;
    data.liquidatedCollateralTokenIds = params.tokenIds;
    data.liquidatedCollateralAmounts = vars.maxCollateralAmountsToLiquidate;
    data.liquidator = msg.sender;
    data.receiveNToken = params.receiveNToken;
    emit NFTLiquidationCall(
      params.collateralAsset,
      params.debtAsset,
      params.user,
      abi.encode(data)
    );

    return (uint256(Errors.CollateralManagerErrors.NO_ERROR), Errors.LPCM_NO_ERRORS);
  }

  struct AvailableNFTCollateralToLiquidateLocalVars {
    uint256 userCompoundedBorrowBalance;
    uint256 liquidationBonus;
    uint256 collateralPrice;
    uint256 debtAssetPrice;
    uint256 valueOfDebtToLiquidate;
    uint256 valueOfAllDebt;
    uint256 valueOfCollateral;
    uint256 extraDebtAssetToPay;
    uint256 maxCollateralBalanceToLiquidate;
    uint256 totalCollateralBalanceToLiquidate;
    uint256[] collateralAmountsToLiquidate;
    uint256 debtAssetDecimals;
  }



  function _calculateAvailableNFTCollateralToLiquidate(
    DataTypes.NFTVaultData storage collateralVault,
    DataTypes.ReserveData storage debtReserve,
    AvailableNFTCollateralToLiquidateParameters memory params
  ) internal view returns (uint256[] memory, uint256, uint256, uint256) {

    uint256 debtAmountNeeded = 0;
    IPriceOracleGetter oracle = IPriceOracleGetter(_addressesProvider.getPriceOracle());

    AvailableNFTCollateralToLiquidateLocalVars memory vars;
    vars.collateralAmountsToLiquidate = new uint256[](params.amountsToLiquidate.length);


    vars.collateralPrice = oracle.getAssetPrice(params.collateralAsset);
    vars.debtAssetPrice = oracle.getAssetPrice(params.debtAsset);

    (, , vars.liquidationBonus) = collateralVault
      .configuration
      .getParams();
    vars.debtAssetDecimals = debtReserve.configuration.getDecimals();

    vars.valueOfCollateral = vars.collateralPrice * (10**vars.debtAssetDecimals);
    vars.maxCollateralBalanceToLiquidate = ((vars.debtAssetPrice * params.debtToCover)
      .percentMul(vars.liquidationBonus)
      + vars.valueOfCollateral - 1)
      / vars.valueOfCollateral;
    (vars.totalCollateralBalanceToLiquidate, vars.collateralAmountsToLiquidate) = 
      INToken(collateralVault.nTokenAddress).getLiquidationAmounts(params.user, vars.maxCollateralBalanceToLiquidate, params.tokenIdsToLiquidate, params.amountsToLiquidate);

    debtAmountNeeded = (vars.valueOfCollateral
        * vars.totalCollateralBalanceToLiquidate
        / vars.debtAssetPrice)
        .percentDiv(vars.liquidationBonus);
    if (vars.totalCollateralBalanceToLiquidate < vars.maxCollateralBalanceToLiquidate) {
      vars.extraDebtAssetToPay = 0;
    } else if (debtAmountNeeded <= params.userTotalDebt){
      vars.extraDebtAssetToPay = 0;
    } else {
      vars.extraDebtAssetToPay = debtAmountNeeded - params.userTotalDebt;
      debtAmountNeeded = params.userTotalDebt;
    }
    return (vars.collateralAmountsToLiquidate, vars.totalCollateralBalanceToLiquidate, debtAmountNeeded, vars.extraDebtAssetToPay);
  }
}