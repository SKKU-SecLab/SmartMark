pragma solidity 0.7.4;

interface OrionVaultInterface {


    function getLockedStakeBalance(address user) external view returns (uint64);


    function seizeFromStake(address user, address receiver, uint64 amount) external;


}pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

interface PriceOracleDataTypes {

    struct PriceDataOut {
        uint64 price;
        uint64 timestamp;
    }

}pragma solidity 0.7.4;


interface PriceOracleInterface is PriceOracleDataTypes {

    function assetPrices(address) external view returns (PriceDataOut memory);

    function givePrices(address[] calldata assetAddresses) external view returns (PriceDataOut[] memory);

}pragma solidity 0.7.4;


library MarginalFunctionality {


    struct Liability {
        address asset;
        uint64 timestamp;
        uint192 outstandingAmount;
    }

    enum PositionState {
        POSITIVE,
        NEGATIVE, // weighted position below 0
        OVERDUE,  // liability is not returned for too long
        NOPRICE,  // some assets has no price or expired
        INCORRECT // some of the basic requirements are not met:
    }
    struct Position {
        PositionState state;
        int256 weightedPosition;
        int256 totalPosition;
        int256 totalLiabilities;
    }

    struct UsedConstants {
      address user;
      address _oracleAddress;
      address _orionVaultContractAddress;
      address _orionTokenAddress;
      uint64 positionOverdue;
      uint64 priceOverdue;
      uint8 stakeRisk;
      uint8 liquidationPremium;
    }


    function uint8Percent(int192 _a, uint8 b) internal pure returns (int192 c) {

        int a = int256(_a);
        int d = 255;
        c = int192((a>65536) ? (a/d)*b : a*b/d );
    }

    function calcAssets(address[] storage collateralAssets,
                        mapping(address => mapping(address => int192)) storage assetBalances,
                        mapping(address => uint8) storage assetRisks,
                        UsedConstants memory constants)
             internal view returns
        (bool outdated, int192 weightedPosition, int192 totalPosition) {

        uint256 collateralAssetsLength = collateralAssets.length;
        for(uint256 i = 0; i < collateralAssetsLength; i++) {
          address asset = collateralAssets[i];
          if(assetBalances[constants.user][asset]<0)
              continue; // will be calculated in calcLiabilities
          (uint64 price, uint64 timestamp) = (1e8, 0xfffffff000000000);

          if(asset != constants._orionTokenAddress) {
            PriceOracleInterface.PriceDataOut memory assetPriceData = PriceOracleInterface(constants._oracleAddress).assetPrices(asset);//TODO givePrices
            (price, timestamp) = (assetPriceData.price, assetPriceData.timestamp);
          }

          int192 assetValue = int192(int256(assetBalances[constants.user][asset])*price/1e8);
          if(assetValue>0) {
            weightedPosition += uint8Percent(assetValue, assetRisks[asset]);
            totalPosition += assetValue;
            outdated = outdated ||
                            ((timestamp + constants.priceOverdue) < block.timestamp);
          }
        }
        return (outdated, weightedPosition, totalPosition);
    }

    function calcLiabilities(mapping(address => Liability[]) storage liabilities,
                             mapping(address => mapping(address => int192)) storage assetBalances,
                             UsedConstants memory constants
                             )
             internal view returns
        (bool outdated, bool overdue, int192 weightedPosition, int192 totalPosition) {

        uint256 liabilitiesLength = liabilities[constants.user].length;
        for(uint256 i = 0; i < liabilitiesLength; i++) {
          Liability storage liability = liabilities[constants.user][i];
          PriceOracleInterface.PriceDataOut memory assetPriceData = PriceOracleInterface(constants._oracleAddress).assetPrices(liability.asset);//TODO givePrices
          (uint64 price, uint64 timestamp) = (assetPriceData.price, assetPriceData.timestamp);
          int192 liabilityValue = int192(
                                         int256(assetBalances[constants.user][liability.asset])
                                         *price/1e8
                                        );
          weightedPosition += liabilityValue; //already negative since balance is negative
          totalPosition += liabilityValue;
          overdue = overdue || ((liability.timestamp + constants.positionOverdue) < block.timestamp);
          outdated = outdated ||
                          ((timestamp + constants.priceOverdue) < block.timestamp);
        }

        return (outdated, overdue, weightedPosition, totalPosition);
    }

    function calcPosition(
                        address[] storage collateralAssets,
                        mapping(address => Liability[]) storage liabilities,
                        mapping(address => mapping(address => int192)) storage assetBalances,
                        mapping(address => uint8) storage assetRisks,
                        UsedConstants memory constants
                        )
             public view returns (Position memory result) {

        (bool outdatedPrice, int192 weightedPosition, int192 totalPosition) =
          calcAssets(collateralAssets,
                     assetBalances,
                     assetRisks,
                     constants);
        (bool _outdatedPrice, bool overdue, int192 _weightedPosition, int192 _totalPosition) =
           calcLiabilities(liabilities,
                           assetBalances,
                           constants
                           );
        uint64 lockedAmount = OrionVaultInterface(constants._orionVaultContractAddress)
                                  .getLockedStakeBalance(constants.user);
        int192 weightedStake = uint8Percent(int192(lockedAmount), constants.stakeRisk);
        weightedPosition += weightedStake;
        totalPosition += lockedAmount;

        weightedPosition += _weightedPosition;
        totalPosition += _totalPosition;
        outdatedPrice = outdatedPrice || _outdatedPrice;
        bool incorrect = (liabilities[constants.user].length>0) && (lockedAmount==0);
        if(_totalPosition<0) {
          result.totalLiabilities = _totalPosition;
        }
        if(weightedPosition<0) {
          result.state = PositionState.NEGATIVE;
        }
        if(outdatedPrice) {
          result.state = PositionState.NOPRICE;
        }
        if(overdue) {
          result.state = PositionState.OVERDUE;
        }
        if(incorrect) {
          result.state = PositionState.INCORRECT;
        }
        result.weightedPosition = weightedPosition;
        result.totalPosition = totalPosition;
    }

    function removeLiability(address user,
                             address asset,
                             mapping(address => Liability[]) storage liabilities)
        public      {

        uint256 length = liabilities[user].length;
        for (uint256 i = 0; i < length; i++) {
          if (liabilities[user][i].asset == asset) {
            if (length>1) {
              liabilities[user][i] = liabilities[user][length - 1];
            }
            liabilities[user].pop();
            break;
          }
        }
    }

    function updateLiability(address user,
                             address asset,
                             mapping(address => Liability[]) storage liabilities,
                             uint112 depositAmount,
                             int192 currentBalance)
        public      {

        if(currentBalance>=0) {
            removeLiability(user,asset,liabilities);
        } else {
            uint256 i;
            uint256 liabilitiesLength=liabilities[user].length;
            for(; i<liabilitiesLength-1; i++) {
                if(liabilities[user][i].asset == asset)
                  break;
              }
            Liability storage liability = liabilities[user][i];
            if(depositAmount>=liability.outstandingAmount) {
                liability.outstandingAmount = uint192(-currentBalance);
                liability.timestamp = uint64(block.timestamp);
            } else {
                liability.outstandingAmount -= depositAmount;
            }
        }
    }

    function partiallyLiquidate(address[] storage collateralAssets,
                                mapping(address => Liability[]) storage liabilities,
                                mapping(address => mapping(address => int192)) storage assetBalances,
                                mapping(address => uint8) storage assetRisks,
                                UsedConstants memory constants,
                                address redeemedAsset,
                                uint112 amount) public {

        Position memory initialPosition = calcPosition(collateralAssets,
                                           liabilities,
                                           assetBalances,
                                           assetRisks,
                                           constants);
        require(initialPosition.state == PositionState.NEGATIVE ||
                initialPosition.state == PositionState.OVERDUE  , "E7");
        address liquidator = msg.sender;
        require(assetBalances[liquidator][redeemedAsset]>=amount,"E8");
        require(assetBalances[constants.user][redeemedAsset]<0,"E15");
        assetBalances[liquidator][redeemedAsset] -= amount;
        assetBalances[constants.user][redeemedAsset] += amount;
        if(assetBalances[constants.user][redeemedAsset] >= 0)
          removeLiability(constants.user, redeemedAsset, liabilities);
        PriceOracleInterface.PriceDataOut memory assetPriceData = PriceOracleInterface(constants._oracleAddress).assetPrices(redeemedAsset);
        (uint64 price, uint64 timestamp) = (assetPriceData.price, assetPriceData.timestamp);
        require((timestamp + constants.priceOverdue) > block.timestamp, "E9"); //Price is outdated

        reimburseLiquidator(amount, price, liquidator, assetBalances, constants);
        Position memory finalPosition = calcPosition(collateralAssets,
                                           liabilities,
                                           assetBalances,
                                           assetRisks,
                                           constants);
        require( int(finalPosition.state)<3 && //POSITIVE,NEGATIVE or OVERDUE
                 (finalPosition.weightedPosition>initialPosition.weightedPosition),
                 "E10");//Incorrect state position after liquidation
       if(finalPosition.state == PositionState.POSITIVE)
         require (finalPosition.weightedPosition<10e8,"Can not liquidate to very positive state");

    }

    function reimburseLiquidator(
                       uint112 amount,
                       uint64 price,
                       address liquidator,
                       mapping(address => mapping(address => int192)) storage assetBalances,
                       UsedConstants memory constants)
             internal
             {

        int192 _orionAmount = int192(int256(amount)*price/1e8);
        _orionAmount += uint8Percent(_orionAmount,constants.liquidationPremium); //Liquidation premium
        require(_orionAmount == int64(_orionAmount), "E11");
        int64 orionAmount = int64(_orionAmount);
        int64 onBalanceOrion = int64(assetBalances[constants.user][constants._orionTokenAddress]);
        (int64 fromBalance, int64 fromStake) = (onBalanceOrion>orionAmount)?
                                                 (orionAmount, 0) :
                                                 (onBalanceOrion>0)?
                                                   (onBalanceOrion, orionAmount-onBalanceOrion) :
                                                   (0, orionAmount);

        if(fromBalance>0) {
          assetBalances[constants.user][constants._orionTokenAddress] -= int192(fromBalance);
          assetBalances[liquidator][constants._orionTokenAddress] += int192(fromBalance);
        }
        if(fromStake>0) {
          OrionVaultInterface(constants._orionVaultContractAddress).seizeFromStake(constants.user, liquidator, uint64(fromStake));
        }
    }
}