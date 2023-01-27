
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity 0.8.4;


interface IERC20Detailed is IERC20MetadataUpgradeable {


}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity 0.8.4;


interface IERC721Detailed is IERC721MetadataUpgradeable {


}// agpl-3.0
pragma solidity 0.8.4;

interface ILendPoolAddressesProvider {

  event MarketIdSet(string newMarketId);
  event LendPoolUpdated(address indexed newAddress, bytes encodedCallData);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendPoolConfiguratorUpdated(address indexed newAddress, bytes encodedCallData);
  event ReserveOracleUpdated(address indexed newAddress);
  event NftOracleUpdated(address indexed newAddress);
  event LendPoolLoanUpdated(address indexed newAddress, bytes encodedCallData);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy, bytes encodedCallData);
  event BNFTRegistryUpdated(address indexed newAddress);
  event IncentivesControllerUpdated(address indexed newAddress);
  event UIDataProviderUpdated(address indexed newAddress);
  event BendDataProviderUpdated(address indexed newAddress);
  event WalletBalanceProviderUpdated(address indexed newAddress);

  function getMarketId() external view returns (string memory);


  function setMarketId(string calldata marketId) external;


  function setAddress(bytes32 id, address newAddress) external;


  function setAddressAsProxy(
    bytes32 id,
    address impl,
    bytes memory encodedCallData
  ) external;


  function getAddress(bytes32 id) external view returns (address);


  function getLendPool() external view returns (address);


  function setLendPoolImpl(address pool, bytes memory encodedCallData) external;


  function getLendPoolConfigurator() external view returns (address);


  function setLendPoolConfiguratorImpl(address configurator, bytes memory encodedCallData) external;


  function getPoolAdmin() external view returns (address);


  function setPoolAdmin(address admin) external;


  function getEmergencyAdmin() external view returns (address);


  function setEmergencyAdmin(address admin) external;


  function getReserveOracle() external view returns (address);


  function setReserveOracle(address reserveOracle) external;


  function getNFTOracle() external view returns (address);


  function setNFTOracle(address nftOracle) external;


  function getLendPoolLoan() external view returns (address);


  function setLendPoolLoanImpl(address loan, bytes memory encodedCallData) external;


  function getBNFTRegistry() external view returns (address);


  function setBNFTRegistry(address factory) external;


  function getIncentivesController() external view returns (address);


  function setIncentivesController(address controller) external;


  function getUIDataProvider() external view returns (address);


  function setUIDataProvider(address provider) external;


  function getBendDataProvider() external view returns (address);


  function setBendDataProvider(address provider) external;


  function getWalletBalanceProvider() external view returns (address);


  function setWalletBalanceProvider(address provider) external;

}// agpl-3.0
pragma solidity 0.8.4;

interface IIncentivesController {

  function handleAction(
    address asset,
    uint256 totalSupply,
    uint256 userBalance
  ) external;

}// agpl-3.0
pragma solidity 0.8.4;


interface IUiPoolDataProvider {

  struct AggregatedReserveData {
    address underlyingAsset;
    string name;
    string symbol;
    uint256 decimals;
    uint256 reserveFactor;
    bool borrowingEnabled;
    bool isActive;
    bool isFrozen;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 liquidityRate;
    uint128 variableBorrowRate;
    uint40 lastUpdateTimestamp;
    address bTokenAddress;
    address debtTokenAddress;
    address interestRateAddress;
    uint256 availableLiquidity;
    uint256 totalVariableDebt;
    uint256 priceInEth;
    uint256 variableRateSlope1;
    uint256 variableRateSlope2;
  }

  struct UserReserveData {
    address underlyingAsset;
    uint256 bTokenBalance;
    uint256 variableDebt;
  }

  struct AggregatedNftData {
    address underlyingAsset;
    string name;
    string symbol;
    uint256 ltv;
    uint256 liquidationThreshold;
    uint256 liquidationBonus;
    uint256 redeemDuration;
    uint256 auctionDuration;
    uint256 redeemFine;
    uint256 redeemThreshold;
    uint256 minBidFine;
    bool isActive;
    bool isFrozen;
    address bNftAddress;
    uint256 priceInEth;
    uint256 totalCollateral;
  }

  struct UserNftData {
    address underlyingAsset;
    address bNftAddress;
    uint256 totalCollateral;
  }

  struct AggregatedLoanData {
    uint256 loanId;
    uint256 state;
    address reserveAsset;
    uint256 totalCollateralInReserve;
    uint256 totalDebtInReserve;
    uint256 availableBorrowsInReserve;
    uint256 healthFactor;
    uint256 liquidatePrice;
    address bidderAddress;
    uint256 bidPrice;
    uint256 bidBorrowAmount;
    uint256 bidFine;
  }

  function getReservesList(ILendPoolAddressesProvider provider) external view returns (address[] memory);


  function getSimpleReservesData(ILendPoolAddressesProvider provider)
    external
    view
    returns (AggregatedReserveData[] memory);


  function getUserReservesData(ILendPoolAddressesProvider provider, address user)
    external
    view
    returns (UserReserveData[] memory);


  function getReservesData(ILendPoolAddressesProvider provider, address user)
    external
    view
    returns (AggregatedReserveData[] memory, UserReserveData[] memory);


  function getNftsList(ILendPoolAddressesProvider provider) external view returns (address[] memory);


  function getSimpleNftsData(ILendPoolAddressesProvider provider) external view returns (AggregatedNftData[] memory);


  function getUserNftsData(ILendPoolAddressesProvider provider, address user)
    external
    view
    returns (UserNftData[] memory);


  function getNftsData(ILendPoolAddressesProvider provider, address user)
    external
    view
    returns (AggregatedNftData[] memory, UserNftData[] memory);


  function getSimpleLoansData(
    ILendPoolAddressesProvider provider,
    address[] memory nftAssets,
    uint256[] memory nftTokenIds
  ) external view returns (AggregatedLoanData[] memory);

}// agpl-3.0
pragma solidity 0.8.4;

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint40 lastUpdateTimestamp;
    address bTokenAddress;
    address debtTokenAddress;
    address interestRateAddress;
    uint8 id;
  }

  struct NftData {
    NftConfigurationMap configuration;
    address bNftAddress;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct NftConfigurationMap {
    uint256 data;
  }

  enum LoanState {
    None,
    Created,
    Active,
    Auction,
    Repaid,
    Defaulted
  }

  struct LoanData {
    uint256 loanId;
    LoanState state;
    address borrower;
    address nftAsset;
    uint256 nftTokenId;
    address reserveAsset;
    uint256 scaledAmount;
    uint256 bidStartTimestamp;
    address bidderAddress;
    uint256 bidPrice;
    uint256 bidBorrowAmount;
    address firstBidderAddress;
  }

  struct ExecuteDepositParams {
    address initiator;
    address asset;
    uint256 amount;
    address onBehalfOf;
    uint16 referralCode;
  }

  struct ExecuteWithdrawParams {
    address initiator;
    address asset;
    uint256 amount;
    address to;
  }

  struct ExecuteBorrowParams {
    address initiator;
    address asset;
    uint256 amount;
    address nftAsset;
    uint256 nftTokenId;
    address onBehalfOf;
    uint16 referralCode;
  }

  struct ExecuteBatchBorrowParams {
    address initiator;
    address[] assets;
    uint256[] amounts;
    address[] nftAssets;
    uint256[] nftTokenIds;
    address onBehalfOf;
    uint16 referralCode;
  }

  struct ExecuteRepayParams {
    address initiator;
    address nftAsset;
    uint256 nftTokenId;
    uint256 amount;
  }

  struct ExecuteBatchRepayParams {
    address initiator;
    address[] nftAssets;
    uint256[] nftTokenIds;
    uint256[] amounts;
  }

  struct ExecuteAuctionParams {
    address initiator;
    address nftAsset;
    uint256 nftTokenId;
    uint256 bidPrice;
    address onBehalfOf;
  }

  struct ExecuteRedeemParams {
    address initiator;
    address nftAsset;
    uint256 nftTokenId;
    uint256 amount;
    uint256 bidFine;
  }

  struct ExecuteLiquidateParams {
    address initiator;
    address nftAsset;
    uint256 nftTokenId;
    uint256 amount;
  }
}// agpl-3.0
pragma solidity 0.8.4;


interface ILendPool {

  event Deposit(
    address user,
    address indexed reserve,
    uint256 amount,
    address indexed onBehalfOf,
    uint16 indexed referral
  );

  event Withdraw(address indexed user, address indexed reserve, uint256 amount, address indexed to);

  event Borrow(
    address user,
    address indexed reserve,
    uint256 amount,
    address nftAsset,
    uint256 nftTokenId,
    address indexed onBehalfOf,
    uint256 borrowRate,
    uint256 loanId,
    uint16 indexed referral
  );

  event Repay(
    address user,
    address indexed reserve,
    uint256 amount,
    address indexed nftAsset,
    uint256 nftTokenId,
    address indexed borrower,
    uint256 loanId
  );

  event Auction(
    address user,
    address indexed reserve,
    uint256 bidPrice,
    address indexed nftAsset,
    uint256 nftTokenId,
    address onBehalfOf,
    address indexed borrower,
    uint256 loanId
  );

  event Redeem(
    address user,
    address indexed reserve,
    uint256 borrowAmount,
    uint256 fineAmount,
    address indexed nftAsset,
    uint256 nftTokenId,
    address indexed borrower,
    uint256 loanId
  );

  event Liquidate(
    address user,
    address indexed reserve,
    uint256 repayAmount,
    uint256 remainAmount,
    address indexed nftAsset,
    uint256 nftTokenId,
    address indexed borrower,
    uint256 loanId
  );

  event Paused();

  event Unpaused();

  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  function deposit(
    address reserve,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function withdraw(
    address reserve,
    uint256 amount,
    address to
  ) external returns (uint256);


  function borrow(
    address reserveAsset,
    uint256 amount,
    address nftAsset,
    uint256 nftTokenId,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function batchBorrow(
    address[] calldata assets,
    uint256[] calldata amounts,
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function repay(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
  ) external returns (uint256, bool);


  function batchRepay(
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    uint256[] calldata amounts
  ) external returns (uint256[] memory, bool[] memory);


  function auction(
    address nftAsset,
    uint256 nftTokenId,
    uint256 bidPrice,
    address onBehalfOf
  ) external;


  function redeem(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount,
    uint256 bidFine
  ) external returns (uint256);


  function liquidate(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
  ) external returns (uint256);


  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromBefore,
    uint256 balanceToBefore
  ) external view;


  function getReserveConfiguration(address asset) external view returns (DataTypes.ReserveConfigurationMap memory);


  function getNftConfiguration(address asset) external view returns (DataTypes.NftConfigurationMap memory);


  function getReserveNormalizedIncome(address asset) external view returns (uint256);


  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


  function getReservesList() external view returns (address[] memory);


  function getNftData(address asset) external view returns (DataTypes.NftData memory);


  function getNftCollateralData(address nftAsset, address reserveAsset)
    external
    view
    returns (
      uint256 totalCollateralInETH,
      uint256 totalCollateralInReserve,
      uint256 availableBorrowsInETH,
      uint256 availableBorrowsInReserve,
      uint256 ltv,
      uint256 liquidationThreshold,
      uint256 liquidationBonus
    );


  function getNftDebtData(address nftAsset, uint256 nftTokenId)
    external
    view
    returns (
      uint256 loanId,
      address reserveAsset,
      uint256 totalCollateral,
      uint256 totalDebt,
      uint256 availableBorrows,
      uint256 healthFactor
    );


  function getNftAuctionData(address nftAsset, uint256 nftTokenId)
    external
    view
    returns (
      uint256 loanId,
      address bidderAddress,
      uint256 bidPrice,
      uint256 bidBorrowAmount,
      uint256 bidFine
    );


  function getNftLiquidatePrice(address nftAsset, uint256 nftTokenId)
    external
    view
    returns (uint256 liquidatePrice, uint256 paybackAmount);


  function getNftsList() external view returns (address[] memory);


  function setPause(bool val) external;


  function paused() external view returns (bool);


  function getAddressesProvider() external view returns (ILendPoolAddressesProvider);


  function initReserve(
    address asset,
    address bTokenAddress,
    address debtTokenAddress,
    address interestRateAddress
  ) external;


  function initNft(address asset, address bNftAddress) external;


  function setReserveInterestRateAddress(address asset, address rateAddress) external;


  function setReserveConfiguration(address asset, uint256 configuration) external;


  function setNftConfiguration(address asset, uint256 configuration) external;


  function setMaxNumberOfReserves(uint256 val) external;


  function setMaxNumberOfNfts(uint256 val) external;


  function getMaxNumberOfReserves() external view returns (uint256);


  function getMaxNumberOfNfts() external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;


interface ILendPoolLoan {

  event Initialized(address indexed pool);

  event LoanCreated(
    address indexed user,
    address indexed onBehalfOf,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amount,
    uint256 borrowIndex
  );

  event LoanUpdated(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amountAdded,
    uint256 amountTaken,
    uint256 borrowIndex
  );

  event LoanRepaid(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amount,
    uint256 borrowIndex
  );

  event LoanAuctioned(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount,
    uint256 borrowIndex,
    address bidder,
    uint256 price,
    address previousBidder,
    uint256 previousPrice
  );

  event LoanRedeemed(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amountTaken,
    uint256 borrowIndex
  );

  event LoanLiquidated(
    address indexed user,
    uint256 indexed loanId,
    address nftAsset,
    uint256 nftTokenId,
    address reserveAsset,
    uint256 amount,
    uint256 borrowIndex
  );

  function initNft(address nftAsset, address bNftAddress) external;


  function createLoan(
    address initiator,
    address onBehalfOf,
    address nftAsset,
    uint256 nftTokenId,
    address bNftAddress,
    address reserveAsset,
    uint256 amount,
    uint256 borrowIndex
  ) external returns (uint256);


  function updateLoan(
    address initiator,
    uint256 loanId,
    uint256 amountAdded,
    uint256 amountTaken,
    uint256 borrowIndex
  ) external;


  function repayLoan(
    address initiator,
    uint256 loanId,
    address bNftAddress,
    uint256 amount,
    uint256 borrowIndex
  ) external;


  function auctionLoan(
    address initiator,
    uint256 loanId,
    address onBehalfOf,
    uint256 bidPrice,
    uint256 borrowAmount,
    uint256 borrowIndex
  ) external;


  function redeemLoan(
    address initiator,
    uint256 loanId,
    uint256 amountTaken,
    uint256 borrowIndex
  ) external;


  function liquidateLoan(
    address initiator,
    uint256 loanId,
    address bNftAddress,
    uint256 borrowAmount,
    uint256 borrowIndex
  ) external;


  function borrowerOf(uint256 loanId) external view returns (address);


  function getCollateralLoanId(address nftAsset, uint256 nftTokenId) external view returns (uint256);


  function getLoan(uint256 loanId) external view returns (DataTypes.LoanData memory loanData);


  function getLoanCollateralAndReserve(uint256 loanId)
    external
    view
    returns (
      address nftAsset,
      uint256 nftTokenId,
      address reserveAsset,
      uint256 scaledAmount
    );


  function getLoanReserveBorrowScaledAmount(uint256 loanId) external view returns (address, uint256);


  function getLoanReserveBorrowAmount(uint256 loanId) external view returns (address, uint256);


  function getLoanHighestBid(uint256 loanId) external view returns (address, uint256);


  function getNftCollateralAmount(address nftAsset) external view returns (uint256);


  function getUserNftCollateralAmount(address user, address nftAsset) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface IReserveOracleGetter {

  function getAssetPrice(address asset) external view returns (uint256);


  function getTwapPrice(address _priceFeedKey, uint256 _interval) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface INFTOracleGetter {

  function getAssetPrice(address asset) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;



interface IBToken is IScaledBalanceToken, IERC20Upgradeable, IERC20MetadataUpgradeable {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address treasury,
    address incentivesController
  );

  function initialize(
    ILendPoolAddressesProvider addressProvider,
    address treasury,
    address underlyingAsset,
    uint8 bTokenDecimals,
    string calldata bTokenName,
    string calldata bTokenSymbol
  ) external;


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


  function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);


  function getIncentivesController() external view returns (IIncentivesController);


  function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// agpl-3.0
pragma solidity 0.8.4;



interface IDebtToken is IScaledBalanceToken, IERC20Upgradeable, IERC20MetadataUpgradeable {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address incentivesController,
    uint8 debtTokenDecimals,
    string debtTokenName,
    string debtTokenSymbol
  );

  function initialize(
    ILendPoolAddressesProvider addressProvider,
    address underlyingAsset,
    uint8 debtTokenDecimals,
    string memory debtTokenName,
    string memory debtTokenSymbol
  ) external;


  event Mint(address indexed from, uint256 value, uint256 index);

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


  function getIncentivesController() external view returns (IIncentivesController);


  function approveDelegation(address delegatee, uint256 amount) external;


  function borrowAllowance(address fromUser, address toUser) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

library Errors {

  enum ReturnCode {
    SUCCESS,
    FAILED
  }

  string public constant SUCCESS = "0";

  string public constant CALLER_NOT_POOL_ADMIN = "100"; // 'The caller must be the pool admin'
  string public constant CALLER_NOT_ADDRESS_PROVIDER = "101";
  string public constant INVALID_FROM_BALANCE_AFTER_TRANSFER = "102";
  string public constant INVALID_TO_BALANCE_AFTER_TRANSFER = "103";
  string public constant CALLER_NOT_ONBEHALFOF_OR_IN_WHITELIST = "104";

  string public constant MATH_MULTIPLICATION_OVERFLOW = "200";
  string public constant MATH_ADDITION_OVERFLOW = "201";
  string public constant MATH_DIVISION_BY_ZERO = "202";

  string public constant VL_INVALID_AMOUNT = "301"; // 'Amount must be greater than 0'
  string public constant VL_NO_ACTIVE_RESERVE = "302"; // 'Action requires an active reserve'
  string public constant VL_RESERVE_FROZEN = "303"; // 'Action cannot be performed because the reserve is frozen'
  string public constant VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE = "304"; // 'User cannot withdraw more than the available balance'
  string public constant VL_BORROWING_NOT_ENABLED = "305"; // 'Borrowing is not enabled'
  string public constant VL_COLLATERAL_BALANCE_IS_0 = "306"; // 'The collateral balance is 0'
  string public constant VL_HEALTH_FACTOR_LOWER_THAN_LIQUIDATION_THRESHOLD = "307"; // 'Health factor is lesser than the liquidation threshold'
  string public constant VL_COLLATERAL_CANNOT_COVER_NEW_BORROW = "308"; // 'There is not enough collateral to cover a new borrow'
  string public constant VL_NO_DEBT_OF_SELECTED_TYPE = "309"; // 'for repayment of stable debt, the user needs to have stable debt, otherwise, he needs to have variable debt'
  string public constant VL_NO_ACTIVE_NFT = "310";
  string public constant VL_NFT_FROZEN = "311";
  string public constant VL_SPECIFIED_CURRENCY_NOT_BORROWED_BY_USER = "312"; // 'User did not borrow the specified currency'
  string public constant VL_INVALID_HEALTH_FACTOR = "313";
  string public constant VL_INVALID_ONBEHALFOF_ADDRESS = "314";
  string public constant VL_INVALID_TARGET_ADDRESS = "315";
  string public constant VL_INVALID_RESERVE_ADDRESS = "316";
  string public constant VL_SPECIFIED_LOAN_NOT_BORROWED_BY_USER = "317";
  string public constant VL_SPECIFIED_RESERVE_NOT_BORROWED_BY_USER = "318";
  string public constant VL_HEALTH_FACTOR_HIGHER_THAN_LIQUIDATION_THRESHOLD = "319";

  string public constant LP_CALLER_NOT_LEND_POOL_CONFIGURATOR = "400"; // 'The caller of the function is not the lending pool configurator'
  string public constant LP_IS_PAUSED = "401"; // 'Pool is paused'
  string public constant LP_NO_MORE_RESERVES_ALLOWED = "402";
  string public constant LP_NOT_CONTRACT = "403";
  string public constant LP_BORROW_NOT_EXCEED_LIQUIDATION_THRESHOLD = "404";
  string public constant LP_BORROW_IS_EXCEED_LIQUIDATION_PRICE = "405";
  string public constant LP_NO_MORE_NFTS_ALLOWED = "406";
  string public constant LP_INVALIED_USER_NFT_AMOUNT = "407";
  string public constant LP_INCONSISTENT_PARAMS = "408";
  string public constant LP_NFT_IS_NOT_USED_AS_COLLATERAL = "409";
  string public constant LP_CALLER_MUST_BE_AN_BTOKEN = "410";
  string public constant LP_INVALIED_NFT_AMOUNT = "411";
  string public constant LP_NFT_HAS_USED_AS_COLLATERAL = "412";
  string public constant LP_DELEGATE_CALL_FAILED = "413";
  string public constant LP_AMOUNT_LESS_THAN_EXTRA_DEBT = "414";
  string public constant LP_AMOUNT_LESS_THAN_REDEEM_THRESHOLD = "415";
  string public constant LP_AMOUNT_GREATER_THAN_MAX_REPAY = "416";

  string public constant LPL_INVALID_LOAN_STATE = "480";
  string public constant LPL_INVALID_LOAN_AMOUNT = "481";
  string public constant LPL_INVALID_TAKEN_AMOUNT = "482";
  string public constant LPL_AMOUNT_OVERFLOW = "483";
  string public constant LPL_BID_PRICE_LESS_THAN_LIQUIDATION_PRICE = "484";
  string public constant LPL_BID_PRICE_LESS_THAN_HIGHEST_PRICE = "485";
  string public constant LPL_BID_REDEEM_DURATION_HAS_END = "486";
  string public constant LPL_BID_USER_NOT_SAME = "487";
  string public constant LPL_BID_REPAY_AMOUNT_NOT_ENOUGH = "488";
  string public constant LPL_BID_AUCTION_DURATION_HAS_END = "489";
  string public constant LPL_BID_AUCTION_DURATION_NOT_END = "490";
  string public constant LPL_BID_PRICE_LESS_THAN_BORROW = "491";
  string public constant LPL_INVALID_BIDDER_ADDRESS = "492";
  string public constant LPL_AMOUNT_LESS_THAN_BID_FINE = "493";
  string public constant LPL_INVALID_BID_FINE = "494";

  string public constant CT_CALLER_MUST_BE_LEND_POOL = "500"; // 'The caller of this function must be a lending pool'
  string public constant CT_INVALID_MINT_AMOUNT = "501"; //invalid amount to mint
  string public constant CT_INVALID_BURN_AMOUNT = "502"; //invalid amount to burn
  string public constant CT_BORROW_ALLOWANCE_NOT_ENOUGH = "503";

  string public constant RL_RESERVE_ALREADY_INITIALIZED = "601"; // 'Reserve has already been initialized'
  string public constant RL_LIQUIDITY_INDEX_OVERFLOW = "602"; //  Liquidity index overflows uint128
  string public constant RL_VARIABLE_BORROW_INDEX_OVERFLOW = "603"; //  Variable borrow index overflows uint128
  string public constant RL_LIQUIDITY_RATE_OVERFLOW = "604"; //  Liquidity rate overflows uint128
  string public constant RL_VARIABLE_BORROW_RATE_OVERFLOW = "605"; //  Variable borrow rate overflows uint128

  string public constant LPC_RESERVE_LIQUIDITY_NOT_0 = "700"; // 'The liquidity of the reserve needs to be 0'
  string public constant LPC_INVALID_CONFIGURATION = "701"; // 'Invalid risk parameters for the reserve'
  string public constant LPC_CALLER_NOT_EMERGENCY_ADMIN = "702"; // 'The caller must be the emergency admin'
  string public constant LPC_INVALIED_BNFT_ADDRESS = "703";
  string public constant LPC_INVALIED_LOAN_ADDRESS = "704";
  string public constant LPC_NFT_LIQUIDITY_NOT_0 = "705";

  string public constant RC_INVALID_LTV = "730";
  string public constant RC_INVALID_LIQ_THRESHOLD = "731";
  string public constant RC_INVALID_LIQ_BONUS = "732";
  string public constant RC_INVALID_DECIMALS = "733";
  string public constant RC_INVALID_RESERVE_FACTOR = "734";
  string public constant RC_INVALID_REDEEM_DURATION = "735";
  string public constant RC_INVALID_AUCTION_DURATION = "736";
  string public constant RC_INVALID_REDEEM_FINE = "737";
  string public constant RC_INVALID_REDEEM_THRESHOLD = "738";
  string public constant RC_INVALID_MIN_BID_FINE = "739";
  string public constant RC_INVALID_MAX_BID_FINE = "740";

  string public constant LPAPR_PROVIDER_NOT_REGISTERED = "760"; // 'Provider is not registered'
  string public constant LPAPR_INVALID_ADDRESSES_PROVIDER_ID = "761";
}// agpl-3.0
pragma solidity 0.8.4;



library WadRayMath {

  uint256 internal constant WAD = 1e18;
  uint256 internal constant HALF_WAD = WAD / 2;

  uint256 internal constant RAY = 1e27;
  uint256 internal constant HALF_RAY = RAY / 2;

  uint256 internal constant WAD_RAY_RATIO = 1e9;

  function ray() internal pure returns (uint256) {

    return RAY;
  }


  function wad() internal pure returns (uint256) {

    return WAD;
  }

  function halfRay() internal pure returns (uint256) {

    return HALF_RAY;
  }

  function halfWad() internal pure returns (uint256) {

    return HALF_WAD;
  }

  function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }

    require(a <= (type(uint256).max - HALF_WAD) / b, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (a * b + HALF_WAD) / WAD;
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

    require(a <= (type(uint256).max - HALF_RAY) / b, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (a * b + HALF_RAY) / RAY;
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
pragma solidity 0.8.4;


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

  function setActive(DataTypes.ReserveConfigurationMap memory self, bool active) internal pure {

    self.data = (self.data & ACTIVE_MASK) | (uint256(active ? 1 : 0) << IS_ACTIVE_START_BIT_POSITION);
  }

  function getActive(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~ACTIVE_MASK) != 0;
  }

  function setFrozen(DataTypes.ReserveConfigurationMap memory self, bool frozen) internal pure {

    self.data = (self.data & FROZEN_MASK) | (uint256(frozen ? 1 : 0) << IS_FROZEN_START_BIT_POSITION);
  }

  function getFrozen(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~FROZEN_MASK) != 0;
  }

  function setBorrowingEnabled(DataTypes.ReserveConfigurationMap memory self, bool enabled) internal pure {

    self.data = (self.data & BORROWING_MASK) | (uint256(enabled ? 1 : 0) << BORROWING_ENABLED_START_BIT_POSITION);
  }

  function getBorrowingEnabled(DataTypes.ReserveConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~BORROWING_MASK) != 0;
  }

  function setStableRateBorrowingEnabled(DataTypes.ReserveConfigurationMap memory self, bool enabled) internal pure {

    self.data =
      (self.data & STABLE_BORROWING_MASK) |
      (uint256(enabled ? 1 : 0) << STABLE_BORROWING_ENABLED_START_BIT_POSITION);
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
pragma solidity 0.8.4;


library NftConfiguration {

  uint256 constant LTV_MASK =                   0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000; // prettier-ignore
  uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF; // prettier-ignore
  uint256 constant LIQUIDATION_BONUS_MASK =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFF; // prettier-ignore
  uint256 constant ACTIVE_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant FROZEN_MASK =                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant REDEEM_DURATION_MASK =       0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant AUCTION_DURATION_MASK =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant REDEEM_FINE_MASK =           0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant REDEEM_THRESHOLD_MASK =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore
  uint256 constant MIN_BIDFINE_MASK      =      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore

  uint256 constant LIQUIDATION_THRESHOLD_START_BIT_POSITION = 16;
  uint256 constant LIQUIDATION_BONUS_START_BIT_POSITION = 32;
  uint256 constant IS_ACTIVE_START_BIT_POSITION = 56;
  uint256 constant IS_FROZEN_START_BIT_POSITION = 57;
  uint256 constant REDEEM_DURATION_START_BIT_POSITION = 64;
  uint256 constant AUCTION_DURATION_START_BIT_POSITION = 72;
  uint256 constant REDEEM_FINE_START_BIT_POSITION = 80;
  uint256 constant REDEEM_THRESHOLD_START_BIT_POSITION = 96;
  uint256 constant MIN_BIDFINE_START_BIT_POSITION = 112;

  uint256 constant MAX_VALID_LTV = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_THRESHOLD = 65535;
  uint256 constant MAX_VALID_LIQUIDATION_BONUS = 65535;
  uint256 constant MAX_VALID_REDEEM_DURATION = 255;
  uint256 constant MAX_VALID_AUCTION_DURATION = 255;
  uint256 constant MAX_VALID_REDEEM_FINE = 65535;
  uint256 constant MAX_VALID_REDEEM_THRESHOLD = 65535;
  uint256 constant MAX_VALID_MIN_BIDFINE = 65535;

  function setLtv(DataTypes.NftConfigurationMap memory self, uint256 ltv) internal pure {

    require(ltv <= MAX_VALID_LTV, Errors.RC_INVALID_LTV);

    self.data = (self.data & LTV_MASK) | ltv;
  }

  function getLtv(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return self.data & ~LTV_MASK;
  }

  function setLiquidationThreshold(DataTypes.NftConfigurationMap memory self, uint256 threshold) internal pure {

    require(threshold <= MAX_VALID_LIQUIDATION_THRESHOLD, Errors.RC_INVALID_LIQ_THRESHOLD);

    self.data = (self.data & LIQUIDATION_THRESHOLD_MASK) | (threshold << LIQUIDATION_THRESHOLD_START_BIT_POSITION);
  }

  function getLiquidationThreshold(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~LIQUIDATION_THRESHOLD_MASK) >> LIQUIDATION_THRESHOLD_START_BIT_POSITION;
  }

  function setLiquidationBonus(DataTypes.NftConfigurationMap memory self, uint256 bonus) internal pure {

    require(bonus <= MAX_VALID_LIQUIDATION_BONUS, Errors.RC_INVALID_LIQ_BONUS);

    self.data = (self.data & LIQUIDATION_BONUS_MASK) | (bonus << LIQUIDATION_BONUS_START_BIT_POSITION);
  }

  function getLiquidationBonus(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~LIQUIDATION_BONUS_MASK) >> LIQUIDATION_BONUS_START_BIT_POSITION;
  }

  function setActive(DataTypes.NftConfigurationMap memory self, bool active) internal pure {

    self.data = (self.data & ACTIVE_MASK) | (uint256(active ? 1 : 0) << IS_ACTIVE_START_BIT_POSITION);
  }

  function getActive(DataTypes.NftConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~ACTIVE_MASK) != 0;
  }

  function setFrozen(DataTypes.NftConfigurationMap memory self, bool frozen) internal pure {

    self.data = (self.data & FROZEN_MASK) | (uint256(frozen ? 1 : 0) << IS_FROZEN_START_BIT_POSITION);
  }

  function getFrozen(DataTypes.NftConfigurationMap storage self) internal view returns (bool) {

    return (self.data & ~FROZEN_MASK) != 0;
  }

  function setRedeemDuration(DataTypes.NftConfigurationMap memory self, uint256 redeemDuration) internal pure {

    require(redeemDuration <= MAX_VALID_REDEEM_DURATION, Errors.RC_INVALID_REDEEM_DURATION);

    self.data = (self.data & REDEEM_DURATION_MASK) | (redeemDuration << REDEEM_DURATION_START_BIT_POSITION);
  }

  function getRedeemDuration(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~REDEEM_DURATION_MASK) >> REDEEM_DURATION_START_BIT_POSITION;
  }

  function setAuctionDuration(DataTypes.NftConfigurationMap memory self, uint256 auctionDuration) internal pure {

    require(auctionDuration <= MAX_VALID_AUCTION_DURATION, Errors.RC_INVALID_AUCTION_DURATION);

    self.data = (self.data & AUCTION_DURATION_MASK) | (auctionDuration << AUCTION_DURATION_START_BIT_POSITION);
  }

  function getAuctionDuration(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~AUCTION_DURATION_MASK) >> AUCTION_DURATION_START_BIT_POSITION;
  }

  function setRedeemFine(DataTypes.NftConfigurationMap memory self, uint256 redeemFine) internal pure {

    require(redeemFine <= MAX_VALID_REDEEM_FINE, Errors.RC_INVALID_REDEEM_FINE);

    self.data = (self.data & REDEEM_FINE_MASK) | (redeemFine << REDEEM_FINE_START_BIT_POSITION);
  }

  function getRedeemFine(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~REDEEM_FINE_MASK) >> REDEEM_FINE_START_BIT_POSITION;
  }

  function setRedeemThreshold(DataTypes.NftConfigurationMap memory self, uint256 redeemThreshold) internal pure {

    require(redeemThreshold <= MAX_VALID_REDEEM_THRESHOLD, Errors.RC_INVALID_REDEEM_THRESHOLD);

    self.data = (self.data & REDEEM_THRESHOLD_MASK) | (redeemThreshold << REDEEM_THRESHOLD_START_BIT_POSITION);
  }

  function getRedeemThreshold(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return (self.data & ~REDEEM_THRESHOLD_MASK) >> REDEEM_THRESHOLD_START_BIT_POSITION;
  }

  function setMinBidFine(DataTypes.NftConfigurationMap memory self, uint256 minBidFine) internal pure {

    require(minBidFine <= MAX_VALID_MIN_BIDFINE, Errors.RC_INVALID_MIN_BID_FINE);

    self.data = (self.data & MIN_BIDFINE_MASK) | (minBidFine << MIN_BIDFINE_START_BIT_POSITION);
  }

  function getMinBidFine(DataTypes.NftConfigurationMap storage self) internal view returns (uint256) {

    return ((self.data & ~MIN_BIDFINE_MASK) >> MIN_BIDFINE_START_BIT_POSITION);
  }

  function getFlags(DataTypes.NftConfigurationMap storage self) internal view returns (bool, bool) {

    uint256 dataLocal = self.data;

    return ((dataLocal & ~ACTIVE_MASK) != 0, (dataLocal & ~FROZEN_MASK) != 0);
  }

  function getFlagsMemory(DataTypes.NftConfigurationMap memory self) internal pure returns (bool, bool) {

    return ((self.data & ~ACTIVE_MASK) != 0, (self.data & ~FROZEN_MASK) != 0);
  }

  function getCollateralParams(DataTypes.NftConfigurationMap storage self)
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

  function getAuctionParams(DataTypes.NftConfigurationMap storage self)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    uint256 dataLocal = self.data;

    return (
      (dataLocal & ~REDEEM_DURATION_MASK) >> REDEEM_DURATION_START_BIT_POSITION,
      (dataLocal & ~AUCTION_DURATION_MASK) >> AUCTION_DURATION_START_BIT_POSITION,
      (dataLocal & ~REDEEM_FINE_MASK) >> REDEEM_FINE_START_BIT_POSITION,
      (dataLocal & ~REDEEM_THRESHOLD_MASK) >> REDEEM_THRESHOLD_START_BIT_POSITION
    );
  }

  function getCollateralParamsMemory(DataTypes.NftConfigurationMap memory self)
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

  function getAuctionParamsMemory(DataTypes.NftConfigurationMap memory self)
    internal
    pure
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    )
  {

    return (
      (self.data & ~REDEEM_DURATION_MASK) >> REDEEM_DURATION_START_BIT_POSITION,
      (self.data & ~AUCTION_DURATION_MASK) >> AUCTION_DURATION_START_BIT_POSITION,
      (self.data & ~REDEEM_FINE_MASK) >> REDEEM_FINE_START_BIT_POSITION,
      (self.data & ~REDEEM_THRESHOLD_MASK) >> REDEEM_THRESHOLD_START_BIT_POSITION
    );
  }

  function getMinBidFineMemory(DataTypes.NftConfigurationMap memory self) internal pure returns (uint256) {

    return ((self.data & ~MIN_BIDFINE_MASK) >> MIN_BIDFINE_START_BIT_POSITION);
  }
}// agpl-3.0
pragma solidity 0.8.4;

interface IInterestRate {

  function baseVariableBorrowRate() external view returns (uint256);


  function getMaxVariableBorrowRate() external view returns (uint256);


  function calculateInterestRates(
    address reserve,
    uint256 availableLiquidity,
    uint256 totalVariableDebt,
    uint256 reserveFactor
  ) external view returns (uint256, uint256);


  function calculateInterestRates(
    address reserve,
    address bToken,
    uint256 liquidityAdded,
    uint256 liquidityTaken,
    uint256 totalVariableDebt,
    uint256 reserveFactor
  ) external view returns (uint256 liquidityRate, uint256 variableBorrowRate);

}// agpl-3.0
pragma solidity 0.8.4;



library PercentageMath {

  uint256 constant PERCENTAGE_FACTOR = 1e4; //percentage plus two decimals
  uint256 constant HALF_PERCENT = PERCENTAGE_FACTOR / 2;
  uint256 constant ONE_PERCENT = 1e2; //100, 1%
  uint256 constant TEN_PERCENT = 1e3; //1000, 10%
  uint256 constant ONE_THOUSANDTH_PERCENT = 1e1; //10, 0.1%
  uint256 constant ONE_TEN_THOUSANDTH_PERCENT = 1; //1, 0.01%

  function percentMul(uint256 value, uint256 percentage) internal pure returns (uint256) {

    if (value == 0 || percentage == 0) {
      return 0;
    }

    require(value <= (type(uint256).max - HALF_PERCENT) / percentage, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (value * percentage + HALF_PERCENT) / PERCENTAGE_FACTOR;
  }

  function percentDiv(uint256 value, uint256 percentage) internal pure returns (uint256) {

    require(percentage != 0, Errors.MATH_DIVISION_BY_ZERO);
    uint256 halfPercentage = percentage / 2;

    require(value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR, Errors.MATH_MULTIPLICATION_OVERFLOW);

    return (value * PERCENTAGE_FACTOR + halfPercentage) / percentage;
  }
}// agpl-3.0
pragma solidity 0.8.4;



contract InterestRate is IInterestRate {

  using WadRayMath for uint256;
  using PercentageMath for uint256;

  ILendPoolAddressesProvider public immutable addressesProvider;

  uint256 public immutable OPTIMAL_UTILIZATION_RATE;


  uint256 public immutable EXCESS_UTILIZATION_RATE;

  uint256 internal immutable _baseVariableBorrowRate;

  uint256 internal immutable _variableRateSlope1;

  uint256 internal immutable _variableRateSlope2;

  constructor(
    ILendPoolAddressesProvider provider,
    uint256 optimalUtilizationRate_,
    uint256 baseVariableBorrowRate_,
    uint256 variableRateSlope1_,
    uint256 variableRateSlope2_
  ) {
    addressesProvider = provider;
    OPTIMAL_UTILIZATION_RATE = optimalUtilizationRate_;
    EXCESS_UTILIZATION_RATE = WadRayMath.ray() - (optimalUtilizationRate_);
    _baseVariableBorrowRate = baseVariableBorrowRate_;
    _variableRateSlope1 = variableRateSlope1_;
    _variableRateSlope2 = variableRateSlope2_;
  }

  function variableRateSlope1() external view returns (uint256) {

    return _variableRateSlope1;
  }

  function variableRateSlope2() external view returns (uint256) {

    return _variableRateSlope2;
  }

  function baseVariableBorrowRate() external view override returns (uint256) {

    return _baseVariableBorrowRate;
  }

  function getMaxVariableBorrowRate() external view override returns (uint256) {

    return _baseVariableBorrowRate + (_variableRateSlope1) + (_variableRateSlope2);
  }

  function calculateInterestRates(
    address reserve,
    address bToken,
    uint256 liquidityAdded,
    uint256 liquidityTaken,
    uint256 totalVariableDebt,
    uint256 reserveFactor
  ) external view override returns (uint256, uint256) {

    uint256 availableLiquidity = IERC20Upgradeable(reserve).balanceOf(bToken);
    availableLiquidity = availableLiquidity + (liquidityAdded) - (liquidityTaken);

    return calculateInterestRates(reserve, availableLiquidity, totalVariableDebt, reserveFactor);
  }

  struct CalcInterestRatesLocalVars {
    uint256 totalDebt;
    uint256 currentVariableBorrowRate;
    uint256 currentLiquidityRate;
    uint256 utilizationRate;
  }

  function calculateInterestRates(
    address reserve,
    uint256 availableLiquidity,
    uint256 totalVariableDebt,
    uint256 reserveFactor
  ) public view override returns (uint256, uint256) {

    reserve;

    CalcInterestRatesLocalVars memory vars;

    vars.totalDebt = totalVariableDebt;
    vars.currentVariableBorrowRate = 0;
    vars.currentLiquidityRate = 0;

    vars.utilizationRate = vars.totalDebt == 0 ? 0 : vars.totalDebt.rayDiv(availableLiquidity + (vars.totalDebt));

    if (vars.utilizationRate > OPTIMAL_UTILIZATION_RATE) {
      uint256 excessUtilizationRateRatio = (vars.utilizationRate - (OPTIMAL_UTILIZATION_RATE)).rayDiv(
        EXCESS_UTILIZATION_RATE
      );

      vars.currentVariableBorrowRate =
        _baseVariableBorrowRate +
        (_variableRateSlope1) +
        (_variableRateSlope2.rayMul(excessUtilizationRateRatio));
    } else {
      vars.currentVariableBorrowRate =
        _baseVariableBorrowRate +
        (vars.utilizationRate.rayMul(_variableRateSlope1).rayDiv(OPTIMAL_UTILIZATION_RATE));
    }

    vars.currentLiquidityRate = _getOverallBorrowRate(totalVariableDebt, vars.currentVariableBorrowRate)
      .rayMul(vars.utilizationRate)
      .percentMul(PercentageMath.PERCENTAGE_FACTOR - (reserveFactor));

    return (vars.currentLiquidityRate, vars.currentVariableBorrowRate);
  }

  function _getOverallBorrowRate(uint256 totalVariableDebt, uint256 currentVariableBorrowRate)
    internal
    pure
    returns (uint256)
  {

    uint256 totalDebt = totalVariableDebt;

    if (totalDebt == 0) return 0;

    uint256 weightedVariableRate = totalVariableDebt.wadToRay().rayMul(currentVariableBorrowRate);

    uint256 overallBorrowRate = weightedVariableRate.rayDiv(totalDebt.wadToRay());

    return overallBorrowRate;
  }
}// agpl-3.0
pragma solidity 0.8.4;


contract UiPoolDataProvider is IUiPoolDataProvider {

  using WadRayMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using NftConfiguration for DataTypes.NftConfigurationMap;

  IReserveOracleGetter public immutable reserveOracle;
  INFTOracleGetter public immutable nftOracle;

  constructor(IReserveOracleGetter _reserveOracle, INFTOracleGetter _nftOracle) {
    reserveOracle = _reserveOracle;
    nftOracle = _nftOracle;
  }

  function getInterestRateStrategySlopes(InterestRate interestRate) internal view returns (uint256, uint256) {

    return (interestRate.variableRateSlope1(), interestRate.variableRateSlope2());
  }

  function getReservesList(ILendPoolAddressesProvider provider) public view override returns (address[] memory) {

    ILendPool lendPool = ILendPool(provider.getLendPool());
    return lendPool.getReservesList();
  }

  function getSimpleReservesData(ILendPoolAddressesProvider provider)
    public
    view
    override
    returns (AggregatedReserveData[] memory)
  {

    ILendPool lendPool = ILendPool(provider.getLendPool());
    address[] memory reserves = lendPool.getReservesList();
    AggregatedReserveData[] memory reservesData = new AggregatedReserveData[](reserves.length);

    for (uint256 i = 0; i < reserves.length; i++) {
      AggregatedReserveData memory reserveData = reservesData[i];

      DataTypes.ReserveData memory baseData = lendPool.getReserveData(reserves[i]);

      _fillReserveData(reserveData, reserves[i], baseData);
    }

    return (reservesData);
  }

  function getUserReservesData(ILendPoolAddressesProvider provider, address user)
    external
    view
    override
    returns (UserReserveData[] memory)
  {

    ILendPool lendPool = ILendPool(provider.getLendPool());
    address[] memory reserves = lendPool.getReservesList();

    UserReserveData[] memory userReservesData = new UserReserveData[](user != address(0) ? reserves.length : 0);

    for (uint256 i = 0; i < reserves.length; i++) {
      DataTypes.ReserveData memory baseData = lendPool.getReserveData(reserves[i]);

      _fillUserReserveData(userReservesData[i], user, reserves[i], baseData);
    }

    return (userReservesData);
  }

  function getReservesData(ILendPoolAddressesProvider provider, address user)
    external
    view
    override
    returns (AggregatedReserveData[] memory, UserReserveData[] memory)
  {

    ILendPool lendPool = ILendPool(provider.getLendPool());
    address[] memory reserves = lendPool.getReservesList();

    AggregatedReserveData[] memory reservesData = new AggregatedReserveData[](reserves.length);
    UserReserveData[] memory userReservesData = new UserReserveData[](user != address(0) ? reserves.length : 0);

    for (uint256 i = 0; i < reserves.length; i++) {
      AggregatedReserveData memory reserveData = reservesData[i];

      DataTypes.ReserveData memory baseData = lendPool.getReserveData(reserves[i]);
      _fillReserveData(reserveData, reserves[i], baseData);

      if (user != address(0)) {
        _fillUserReserveData(userReservesData[i], user, reserves[i], baseData);
      }
    }

    return (reservesData, userReservesData);
  }

  function _fillReserveData(
    AggregatedReserveData memory reserveData,
    address reserveAsset,
    DataTypes.ReserveData memory baseData
  ) internal view {

    reserveData.underlyingAsset = reserveAsset;

    reserveData.liquidityIndex = baseData.liquidityIndex;
    reserveData.variableBorrowIndex = baseData.variableBorrowIndex;
    reserveData.liquidityRate = baseData.currentLiquidityRate;
    reserveData.variableBorrowRate = baseData.currentVariableBorrowRate;
    reserveData.lastUpdateTimestamp = baseData.lastUpdateTimestamp;
    reserveData.bTokenAddress = baseData.bTokenAddress;
    reserveData.debtTokenAddress = baseData.debtTokenAddress;
    reserveData.interestRateAddress = baseData.interestRateAddress;
    reserveData.priceInEth = reserveOracle.getAssetPrice(reserveData.underlyingAsset);

    reserveData.availableLiquidity = IERC20Detailed(reserveData.underlyingAsset).balanceOf(reserveData.bTokenAddress);
    reserveData.totalVariableDebt = IDebtToken(reserveData.debtTokenAddress).totalSupply();

    reserveData.symbol = IERC20Detailed(reserveData.underlyingAsset).symbol();
    reserveData.name = IERC20Detailed(reserveData.underlyingAsset).name();

    (, , , reserveData.decimals, reserveData.reserveFactor) = baseData.configuration.getParamsMemory();
    (reserveData.isActive, reserveData.isFrozen, reserveData.borrowingEnabled, ) = baseData
      .configuration
      .getFlagsMemory();
    (reserveData.variableRateSlope1, reserveData.variableRateSlope2) = getInterestRateStrategySlopes(
      InterestRate(reserveData.interestRateAddress)
    );
  }

  function _fillUserReserveData(
    UserReserveData memory userReserveData,
    address user,
    address reserveAsset,
    DataTypes.ReserveData memory baseData
  ) internal view {

    userReserveData.underlyingAsset = reserveAsset;
    userReserveData.bTokenBalance = IBToken(baseData.bTokenAddress).balanceOf(user);
    userReserveData.variableDebt = IDebtToken(baseData.debtTokenAddress).balanceOf(user);
  }

  function getNftsList(ILendPoolAddressesProvider provider) external view override returns (address[] memory) {

    ILendPool lendPool = ILendPool(provider.getLendPool());
    return lendPool.getNftsList();
  }

  function getSimpleNftsData(ILendPoolAddressesProvider provider)
    external
    view
    override
    returns (AggregatedNftData[] memory)
  {

    ILendPool lendPool = ILendPool(provider.getLendPool());
    ILendPoolLoan lendPoolLoan = ILendPoolLoan(provider.getLendPoolLoan());
    address[] memory nfts = lendPool.getNftsList();
    AggregatedNftData[] memory nftsData = new AggregatedNftData[](nfts.length);

    for (uint256 i = 0; i < nfts.length; i++) {
      AggregatedNftData memory nftData = nftsData[i];

      DataTypes.NftData memory baseData = lendPool.getNftData(nfts[i]);

      _fillNftData(nftData, nfts[i], baseData, lendPoolLoan);
    }

    return (nftsData);
  }

  function getUserNftsData(ILendPoolAddressesProvider provider, address user)
    external
    view
    override
    returns (UserNftData[] memory)
  {

    ILendPool lendPool = ILendPool(provider.getLendPool());
    ILendPoolLoan lendPoolLoan = ILendPoolLoan(provider.getLendPoolLoan());
    address[] memory nfts = lendPool.getNftsList();

    UserNftData[] memory userNftsData = new UserNftData[](user != address(0) ? nfts.length : 0);

    for (uint256 i = 0; i < nfts.length; i++) {
      UserNftData memory userNftData = userNftsData[i];

      DataTypes.NftData memory baseData = lendPool.getNftData(nfts[i]);

      _fillUserNftData(userNftData, user, nfts[i], baseData, lendPoolLoan);
    }

    return (userNftsData);
  }

  function getNftsData(ILendPoolAddressesProvider provider, address user)
    external
    view
    override
    returns (AggregatedNftData[] memory, UserNftData[] memory)
  {

    ILendPool lendPool = ILendPool(provider.getLendPool());
    ILendPoolLoan lendPoolLoan = ILendPoolLoan(provider.getLendPoolLoan());
    address[] memory nfts = lendPool.getNftsList();

    AggregatedNftData[] memory nftsData = new AggregatedNftData[](nfts.length);
    UserNftData[] memory userNftsData = new UserNftData[](user != address(0) ? nfts.length : 0);

    for (uint256 i = 0; i < nfts.length; i++) {
      AggregatedNftData memory nftData = nftsData[i];
      UserNftData memory userNftData = userNftsData[i];

      DataTypes.NftData memory baseData = lendPool.getNftData(nfts[i]);

      _fillNftData(nftData, nfts[i], baseData, lendPoolLoan);
      if (user != address(0)) {
        _fillUserNftData(userNftData, user, nfts[i], baseData, lendPoolLoan);
      }
    }

    return (nftsData, userNftsData);
  }

  function _fillNftData(
    AggregatedNftData memory nftData,
    address nftAsset,
    DataTypes.NftData memory baseData,
    ILendPoolLoan lendPoolLoan
  ) internal view {

    nftData.underlyingAsset = nftAsset;

    nftData.bNftAddress = baseData.bNftAddress;
    nftData.priceInEth = nftOracle.getAssetPrice(nftData.underlyingAsset);

    nftData.totalCollateral = lendPoolLoan.getNftCollateralAmount(nftAsset);

    nftData.symbol = IERC721Detailed(nftData.underlyingAsset).symbol();
    nftData.name = IERC721Detailed(nftData.underlyingAsset).name();

    (nftData.ltv, nftData.liquidationThreshold, nftData.liquidationBonus) = baseData
      .configuration
      .getCollateralParamsMemory();
    (nftData.redeemDuration, nftData.auctionDuration, nftData.redeemFine, nftData.redeemThreshold) = baseData
      .configuration
      .getAuctionParamsMemory();
    (nftData.isActive, nftData.isFrozen) = baseData.configuration.getFlagsMemory();
    nftData.minBidFine = baseData.configuration.getMinBidFineMemory();
  }

  function _fillUserNftData(
    UserNftData memory userNftData,
    address user,
    address nftAsset,
    DataTypes.NftData memory baseData,
    ILendPoolLoan lendPoolLoan
  ) internal view {

    userNftData.underlyingAsset = nftAsset;

    userNftData.bNftAddress = baseData.bNftAddress;

    userNftData.totalCollateral = lendPoolLoan.getUserNftCollateralAmount(user, nftAsset);
  }

  function getSimpleLoansData(
    ILendPoolAddressesProvider provider,
    address[] memory nftAssets,
    uint256[] memory nftTokenIds
  ) external view override returns (AggregatedLoanData[] memory) {

    require(nftAssets.length == nftTokenIds.length, Errors.LP_INCONSISTENT_PARAMS);

    ILendPool lendPool = ILendPool(provider.getLendPool());
    ILendPoolLoan poolLoan = ILendPoolLoan(provider.getLendPoolLoan());

    AggregatedLoanData[] memory loansData = new AggregatedLoanData[](nftAssets.length);

    for (uint256 i = 0; i < nftAssets.length; i++) {
      AggregatedLoanData memory loanData = loansData[i];

      (
        loanData.loanId,
        loanData.reserveAsset,
        loanData.totalCollateralInReserve,
        loanData.totalDebtInReserve,
        loanData.availableBorrowsInReserve,
        loanData.healthFactor
      ) = lendPool.getNftDebtData(nftAssets[i], nftTokenIds[i]);

      DataTypes.LoanData memory loan = poolLoan.getLoan(loanData.loanId);
      loanData.state = uint256(loan.state);

      (loanData.liquidatePrice, ) = lendPool.getNftLiquidatePrice(nftAssets[i], nftTokenIds[i]);

      (, loanData.bidderAddress, loanData.bidPrice, loanData.bidBorrowAmount, loanData.bidFine) = lendPool
        .getNftAuctionData(nftAssets[i], nftTokenIds[i]);
    }

    return loansData;
  }
}