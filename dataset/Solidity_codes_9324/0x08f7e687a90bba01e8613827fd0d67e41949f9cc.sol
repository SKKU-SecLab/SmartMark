
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
    return (a * b + halfWAD) / WAD;
  }

  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, 'Division by Zero');
    uint256 halfB = b / 2;
    return (a * WAD + halfB) / b;
  }

  function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }
    return (a * b + halfRAY) / RAY;
  }

  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, 'Division by Zero');
    uint256 halfB = b / 2;
    return (a * RAY + halfB) / b;
  }

  function rayToWad(uint256 a) internal pure returns (uint256) {

    uint256 halfRatio = WAD_RAY_RATIO / 2;
    uint256 result = halfRatio + a;
    return result / WAD_RAY_RATIO;
  }

  function wadToRay(uint256 a) internal pure returns (uint256) {

    uint256 result = a * WAD_RAY_RATIO;
    return result;
  }
}// MIT
pragma solidity 0.8.3;


library Math {

  using WadRayMath for uint256;

  uint256 internal constant SECONDSPERYEAR = 365 days;

  function calculateLinearInterest(
    uint256 rate,
    uint256 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {

    uint256 timeDelta = currentTimestamp - uint256(lastUpdateTimestamp);

    return ((rate * timeDelta) / SECONDSPERYEAR) + WadRayMath.ray();
  }

  function calculateCompoundedInterest(
    uint256 rate,
    uint256 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {

    uint256 exp = currentTimestamp - lastUpdateTimestamp;

    if (exp == 0) {
      return WadRayMath.ray();
    }

    uint256 expMinusOne = exp - 1;

    uint256 expMinusTwo = exp > 2 ? exp - 2 : 0;

    uint256 ratePerSecond = rate / SECONDSPERYEAR;

    uint256 basePowerTwo = ratePerSecond.rayMul(ratePerSecond);
    uint256 basePowerThree = basePowerTwo.rayMul(ratePerSecond);

    uint256 secondTerm = (exp * expMinusOne * basePowerTwo) / 2;
    uint256 thirdTerm = (exp * expMinusOne * expMinusTwo * basePowerThree) / 6;

    return WadRayMath.ray() + (ratePerSecond * exp) + secondTerm + thirdTerm;
  }

  function calculateRateInIncreasingBalance(
    uint256 averageRate,
    uint256 totalBalance,
    uint256 amountIn,
    uint256 rate
  ) internal pure returns (uint256, uint256) {

    uint256 weightedAverageRate = totalBalance.wadToRay().rayMul(averageRate);
    uint256 weightedAmountRate = amountIn.wadToRay().rayMul(rate);

    uint256 newTotalBalance = totalBalance + amountIn;
    uint256 newAverageRate = (weightedAverageRate + weightedAmountRate).rayDiv(
      newTotalBalance.wadToRay()
    );

    return (newTotalBalance, newAverageRate);
  }

  function calculateRateInDecreasingBalance(
    uint256 averageRate,
    uint256 totalBalance,
    uint256 amountOut,
    uint256 rate
  ) internal pure returns (uint256, uint256) {

    if (totalBalance <= amountOut) {
      return (0, 0);
    }

    uint256 weightedAverageRate = totalBalance.wadToRay().rayMul(averageRate);
    uint256 weightedAmountRate = amountOut.wadToRay().rayMul(rate);

    if (weightedAverageRate <= weightedAmountRate) {
      return (0, 0);
    }

    uint256 newTotalBalance = totalBalance - amountOut;

    uint256 newAverageRate = (weightedAverageRate - weightedAmountRate).rayDiv(
      newTotalBalance.wadToRay()
    );

    return (newTotalBalance, newAverageRate);
  }
}// MIT
pragma solidity 0.8.3;



library Validation {

  using WadRayMath for uint256;
  using Validation for DataStruct.ReserveData;

  function validateDeposit(DataStruct.ReserveData storage reserve, uint256 amount) public view {

    require(amount != 0, 'InvalidAmount');
    require(!reserve.isPaused, 'ReservePaused');
    require(reserve.isActivated, 'ReserveInactivated');
  }

  function validateWithdraw(
    DataStruct.ReserveData storage reserve,
    address asset,
    uint256 amount,
    uint256 userLTokenBalance
  ) public view {

    require(amount != 0, 'InvalidAmount');
    require(!reserve.isPaused, 'ReservePaused');
    require(reserve.isActivated, 'ReserveInactivated');
    require(amount <= userLTokenBalance, 'InsufficientBalance');
    uint256 availableLiquidity = IERC20(asset).balanceOf(reserve.lTokenAddress);
    require(availableLiquidity >= amount, 'NotEnoughLiquidity');
  }

  function validateBorrow(
    DataStruct.ReserveData storage reserve,
    DataStruct.AssetBondData memory assetBond,
    address asset,
    uint256 borrowAmount
  ) public view {

    require(!reserve.isPaused, 'ReservePaused');
    require(reserve.isActivated, 'ReserveInactivated');
    require(assetBond.state == DataStruct.AssetBondState.CONFIRMED, 'OnlySignedTokenBorrowAllowed');
    require(msg.sender == assetBond.collateralServiceProvider, 'OnlyOwnerBorrowAllowed');
    uint256 availableLiquidity = IERC20(asset).balanceOf(reserve.lTokenAddress);
    require(availableLiquidity >= borrowAmount, 'NotEnoughLiquidity');
    require(block.timestamp >= assetBond.loanStartTimestamp, 'NotTimeForLoanStart');
    require(assetBond.loanStartTimestamp + 18 hours >= block.timestamp, 'TimeOutForCollateralize');
  }

  function validateLTokenTrasfer() internal pure {}


  function validateRepay(
    DataStruct.ReserveData storage reserve,
    DataStruct.AssetBondData memory assetBond
  ) public view {

    require(reserve.isActivated, 'ReserveInactivated');
    require(block.timestamp < assetBond.liquidationTimestamp, 'LoanExpired');
    require(
      (assetBond.state == DataStruct.AssetBondState.COLLATERALIZED ||
        assetBond.state == DataStruct.AssetBondState.DELINQUENT),
      'NotRepayableState'
    );
  }

  function validateLiquidation(
    DataStruct.ReserveData storage reserve,
    DataStruct.AssetBondData memory assetBond
  ) public view {

    require(reserve.isActivated, 'ReserveInactivated');
    require(assetBond.state == DataStruct.AssetBondState.LIQUIDATED, 'NotLiquidatbleState');
  }

  function validateSignAssetBond(DataStruct.AssetBondData storage assetBond) public view {

    require(assetBond.state == DataStruct.AssetBondState.SETTLED, 'OnlySettledTokenSignAllowed');
    require(assetBond.signer == msg.sender, 'NotAllowedSigner');
  }

  function validateSettleAssetBond(DataStruct.AssetBondData memory assetBond) public view {

    require(block.timestamp < assetBond.loanStartTimestamp, 'OnlySettledSigned');
    require(assetBond.loanStartTimestamp != assetBond.maturityTimestamp, 'LoanDurationInvalid');
  }

  function validateTokenId(DataStruct.AssetBondIdData memory idData) internal pure {

    require(idData.collateralLatitude < 9000000, 'InvaildLatitude');
    require(idData.collateralLongitude < 18000000, 'InvaildLongitude');
  }
}