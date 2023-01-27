
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT
pragma solidity 0.8.3;

library DataStruct {

  struct ReserveData {
    uint256 moneyPoolFactor;
    uint256 lTokenInterestIndex;
    uint256 borrowAPY;
    uint256 depositAPY;
    uint256 lastUpdateTimestamp;
    address lTokenAddress;
    address dTokenAddress;
    address interestModelAddress;
    address tokenizerAddress;
    uint8 id;
    bool isPaused;
    bool isActivated;
  }

  struct AssetBondData {
    AssetBondState state;
    address borrower;
    address signer;
    address collateralServiceProvider;
    uint256 principal;
    uint256 debtCeiling;
    uint256 couponRate;
    uint256 interestRate;
    uint256 delinquencyRate;
    uint256 loanStartTimestamp;
    uint256 collateralizeTimestamp;
    uint256 maturityTimestamp;
    uint256 liquidationTimestamp;
    string ipfsHash; // refactor : gas
    string signerOpinionHash;
  }

  struct AssetBondIdData {
    uint256 nonce;
    uint256 countryCode;
    uint256 collateralServiceProviderIdentificationNumber;
    uint256 collateralLatitude;
    uint256 collateralLatitudeSign;
    uint256 collateralLongitude;
    uint256 collateralLongitudeSign;
    uint256 collateralDetail;
    uint256 collateralCategory;
    uint256 productNumber;
  }

  enum AssetBondState {
    EMPTY,
    SETTLED,
    CONFIRMED,
    COLLATERALIZED,
    DELINQUENT,
    REDEEMED,
    LIQUIDATED
  }
}// MIT
pragma solidity 0.8.3;


interface ILToken is IERC20 {

  event Mint(address indexed account, uint256 amount, uint256 index);

  event Burn(
    address indexed account,
    address indexed underlyingAssetReceiver,
    uint256 amount,
    uint256 index
  );

  event BalanceTransfer(address indexed account, address indexed to, uint256 amount, uint256 index);

  function mint(
    address account,
    uint256 amount,
    uint256 index
  ) external;


  function burn(
    address account,
    address receiver,
    uint256 amount,
    uint256 index
  ) external;


  function getUnderlyingAsset() external view returns (address);


  function implicitBalanceOf(address account) external view returns (uint256);


  function implicitTotalSupply() external view returns (uint256);


  function transferUnderlyingTo(address underlyingAssetReceiver, uint256 amount) external;


  function updateIncentivePool(address newIncentivePool) external;

}// MIT
pragma solidity 0.8.3;


interface IDToken is IERC20Metadata {

  event Mint(
    address indexed account,
    address indexed receiver,
    uint256 amount,
    uint256 currentBalance,
    uint256 balanceIncrease,
    uint256 newRate,
    uint256 avgStableRate,
    uint256 newTotalSupply
  );

  event Burn(
    address indexed account,
    uint256 amount,
    uint256 currentBalance,
    uint256 balanceIncrease,
    uint256 avgStableRate,
    uint256 newTotalSupply
  );

  function mint(
    address account,
    address receiver,
    uint256 amount,
    uint256 rate
  ) external;


  function burn(address account, uint256 amount) external;


  function getTotalAverageRealAssetBorrowRate() external view returns (uint256);


  function getUserAverageRealAssetBorrowRate(address account) external view returns (uint256);


  function getUserLastUpdateTimestamp(address account) external view returns (uint256);


  function getDTokenData()
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    );


  function getTotalSupplyLastUpdated() external view returns (uint256);


  function getTotalSupplyAndAvgRate() external view returns (uint256, uint256);


  function principalBalanceOf(address account) external view returns (uint256);

}// MIT
pragma solidity 0.8.3;


interface IMoneyPool {

  event NewReserve(
    address indexed asset,
    address lToken,
    address dToken,
    address interestModel,
    address tokenizer,
    address incentivePool,
    uint256 moneyPoolFactor
  );

  event Deposit(address indexed asset, address indexed account, uint256 amount);

  event Withdraw(
    address indexed asset,
    address indexed account,
    address indexed to,
    uint256 amount
  );

  event Borrow(
    address indexed asset,
    address indexed collateralServiceProvider,
    address indexed borrower,
    uint256 tokenId,
    uint256 borrowAPY,
    uint256 borrowAmount
  );

  event Repay(
    address indexed asset,
    address indexed borrower,
    uint256 tokenId,
    uint256 userDTokenBalance,
    uint256 feeOnCollateralServiceProvider
  );

  event Liquidation(
    address indexed asset,
    address indexed borrower,
    uint256 tokenId,
    uint256 userDTokenBalance,
    uint256 feeOnCollateralServiceProvider
  );

  function deposit(
    address asset,
    address account,
    uint256 amount
  ) external;


  function withdraw(
    address asset,
    address account,
    uint256 amount
  ) external;


  function borrow(address asset, uint256 tokenID) external;


  function repay(address asset, uint256 tokenId) external;


  function liquidate(address asset, uint256 tokenId) external;


  function getLTokenInterestIndex(address asset) external view returns (uint256);


  function getReserveData(address asset) external view returns (DataStruct.ReserveData memory);


  function addNewReserve(
    address asset,
    address lToken,
    address dToken,
    address interestModel,
    address tokenizer,
    address incentivePool,
    uint256 moneyPoolFactor_
  ) external;

}// MIT
pragma solidity 0.8.3;


interface ITokenizer is IERC721 {

  event EmptyAssetBondMinted(address indexed account, uint256 tokenId);

  event AssetBondSettled(
    address indexed borrower,
    address indexed signer,
    uint256 tokenId,
    uint256 principal,
    uint256 couponRate,
    uint256 delinquencyRate,
    uint256 debtCeiling,
    uint256 maturityTimestamp,
    uint256 liquidationTimestamp,
    uint256 loanStartTimestamp,
    string ifpsHash
  );

  event AssetBondSigned(address indexed signer, uint256 tokenId, string signerOpinionHash);

  event AssetBondCollateralized(
    address indexed account,
    uint256 tokenId,
    uint256 borrowAmount,
    uint256 interestRate
  );

  event AssetBondReleased(address indexed borrower, uint256 tokenId);

  event AssetBondLiquidated(address indexed liquidator, uint256 tokenId);

  function mintAssetBond(address account, uint256 id) external;


  function collateralizeAssetBond(
    address collateralServiceProvider,
    uint256 tokenId,
    uint256 borrowAmount,
    uint256 borrowAPY
  ) external;


  function releaseAssetBond(address account, uint256 tokenId) external;


  function liquidateAssetBond(address account, uint256 tokenId) external;


  function getAssetBondIdData(uint256 tokenId)
    external
    view
    returns (DataStruct.AssetBondIdData memory);


  function getAssetBondData(uint256 tokenId)
    external
    view
    returns (DataStruct.AssetBondData memory);


  function getAssetBondDebtData(uint256 tokenId) external view returns (uint256, uint256);


  function getMinter(uint256 tokenId) external view returns (address);

}// MIT
pragma solidity 0.8.3;




contract DataPipeline {

  IMoneyPool public moneyPool;

  constructor(address moneyPool_) {
    moneyPool = IMoneyPool(moneyPool_);
  }

  struct UserDataLocalVars {
    uint256 underlyingAssetBalance;
    uint256 lTokenBalance;
    uint256 implicitLtokenBalance;
    uint256 dTokenBalance;
    uint256 principalDTokenBalance;
    uint256 averageRealAssetBorrowRate;
    uint256 lastUpdateTimestamp;
  }

  function getUserData(address asset, address user)
    external
    view
    returns (UserDataLocalVars memory)
  {

    UserDataLocalVars memory vars;
    DataStruct.ReserveData memory reserve = moneyPool.getReserveData(asset);

    vars.underlyingAssetBalance = IERC20(asset).balanceOf(user);
    vars.lTokenBalance = ILToken(reserve.lTokenAddress).balanceOf(user);
    vars.implicitLtokenBalance = ILToken(reserve.lTokenAddress).implicitBalanceOf(user);
    vars.dTokenBalance = IDToken(reserve.dTokenAddress).balanceOf(user);
    vars.principalDTokenBalance = IDToken(reserve.dTokenAddress).principalBalanceOf(user);
    vars.averageRealAssetBorrowRate = IDToken(reserve.dTokenAddress)
    .getUserAverageRealAssetBorrowRate(user);
    vars.lastUpdateTimestamp = IDToken(reserve.dTokenAddress).getUserLastUpdateTimestamp(user);

    return vars;
  }

  struct ReserveDataLocalVars {
    uint256 totalLTokenSupply;
    uint256 implicitLTokenSupply;
    uint256 lTokenInterestIndex;
    uint256 principalDTokenSupply;
    uint256 totalDTokenSupply;
    uint256 averageRealAssetBorrowRate;
    uint256 dTokenLastUpdateTimestamp;
    uint256 borrowAPY;
    uint256 depositAPY;
    uint256 moneyPooLastUpdateTimestamp;
  }

  function getReserveData(address asset) external view returns (ReserveDataLocalVars memory) {

    ReserveDataLocalVars memory vars;
    DataStruct.ReserveData memory reserve = moneyPool.getReserveData(asset);

    vars.totalLTokenSupply = ILToken(reserve.lTokenAddress).totalSupply();
    vars.implicitLTokenSupply = ILToken(reserve.lTokenAddress).implicitTotalSupply();
    vars.lTokenInterestIndex = reserve.lTokenInterestIndex;
    (
      vars.principalDTokenSupply,
      vars.totalDTokenSupply,
      vars.averageRealAssetBorrowRate,
      vars.dTokenLastUpdateTimestamp
    ) = IDToken(reserve.dTokenAddress).getDTokenData();
    vars.borrowAPY = reserve.borrowAPY;
    vars.depositAPY = reserve.depositAPY;
    vars.moneyPooLastUpdateTimestamp = reserve.lastUpdateTimestamp;

    return vars;
  }

  struct AssetBondStateDataLocalVars {
    DataStruct.AssetBondState assetBondState;
    address tokenOwner;
    uint256 debtOnMoneyPool;
    uint256 feeOnCollateralServiceProvider;
  }

  function getAssetBondStateData(address asset, uint256 tokenId)
    external
    view
    returns (AssetBondStateDataLocalVars memory)
  {

    AssetBondStateDataLocalVars memory vars;

    DataStruct.ReserveData memory reserve = moneyPool.getReserveData(asset);
    DataStruct.AssetBondData memory assetBond = ITokenizer(reserve.tokenizerAddress)
    .getAssetBondData(tokenId);

    vars.assetBondState = assetBond.state;
    vars.tokenOwner = ITokenizer(reserve.tokenizerAddress).ownerOf(tokenId);
    (vars.debtOnMoneyPool, vars.feeOnCollateralServiceProvider) = ITokenizer(
      reserve.tokenizerAddress
    ).getAssetBondDebtData(tokenId);

    return vars;
  }
}