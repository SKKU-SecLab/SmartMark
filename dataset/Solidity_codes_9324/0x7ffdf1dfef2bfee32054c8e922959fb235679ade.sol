


pragma solidity 0.6.7;

abstract contract SAFEEngineLike {
    function transferInternalCoins(address,address,uint256) virtual external;
    function transferCollateral(bytes32,address,address,uint256) virtual external;
}
abstract contract OracleRelayerLike {
    function redemptionPrice() virtual public returns (uint256);
}
abstract contract OracleLike {
    function priceSource() virtual public view returns (address);
    function getResultWithValidity() virtual public view returns (uint256, bool);
}
abstract contract LiquidationEngineLike {
    function removeCoinsFromAuction(uint256) virtual public;
}




contract IncreasingDiscountCollateralAuctionHouse {

    mapping (address => uint256) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "IncreasingDiscountCollateralAuctionHouse/account-not-authorized");
        _;
    }

    struct Bid {
        uint256 amountToSell;                                                                                         // [wad]
        uint256 amountToRaise;                                                                                        // [rad]
        uint256 currentDiscount;                                                                                      // [wad]
        uint256 maxDiscount;                                                                                          // [wad]
        uint256 perSecondDiscountUpdateRate;                                                                          // [ray]
        uint256 latestDiscountUpdateTime;                                                                             // [unix timestamp]
        uint48  discountIncreaseDeadline;                                                                             // [unix epoch time]
        address forgoneCollateralReceiver;
        address auctionIncomeRecipient;
    }

    mapping (uint256 => Bid) public bids;

    SAFEEngineLike public safeEngine;
    bytes32        public collateralType;

    uint256  public   minimumBid = 5 * WAD;                                                                           // [wad]
    uint48   public   totalAuctionLength = uint48(-1);                                                                // [seconds]
    uint256  public   auctionsStarted = 0;
    uint256  public   lastReadRedemptionPrice;
    uint256  public   minDiscount = 0.95E18;                      // 5% discount                                      // [wad]
    uint256  public   maxDiscount = 0.95E18;                      // 5% discount                                      // [wad]
    uint256  public   perSecondDiscountUpdateRate = RAY;                                                              // [ray]
    uint256  public   maxDiscountUpdateRateTimeline  = 1 hours;                                                       // [seconds]
    uint256  public   lowerCollateralMedianDeviation = 0.90E18;   // 10% deviation                                    // [wad]
    uint256  public   upperCollateralMedianDeviation = 0.95E18;   // 5% deviation                                     // [wad]
    uint256  public   lowerSystemCoinMedianDeviation = WAD;       // 0% deviation                                     // [wad]
    uint256  public   upperSystemCoinMedianDeviation = WAD;       // 0% deviation                                     // [wad]
    uint256  public   minSystemCoinMedianDeviation   = 0.999E18;                                                      // [wad]

    OracleRelayerLike     public oracleRelayer;
    OracleLike            public collateralFSM;
    OracleLike            public systemCoinOracle;
    LiquidationEngineLike public liquidationEngine;

    bytes32 public constant AUCTION_HOUSE_TYPE = bytes32("COLLATERAL");
    bytes32 public constant AUCTION_TYPE       = bytes32("INCREASING_DISCOUNT");

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event StartAuction(
        uint256 id,
        uint256 auctionsStarted,
        uint256 amountToSell,
        uint256 initialBid,
        uint256 indexed amountToRaise,
        uint256 startingDiscount,
        uint256 maxDiscount,
        uint256 perSecondDiscountUpdateRate,
        uint48  discountIncreaseDeadline,
        address indexed forgoneCollateralReceiver,
        address indexed auctionIncomeRecipient
    );
    event ModifyParameters(bytes32 parameter, uint256 data);
    event ModifyParameters(bytes32 parameter, address data);
    event BuyCollateral(uint256 indexed id, uint256 wad, uint256 boughtCollateral);
    event SettleAuction(uint256 indexed id, uint256 leftoverCollateral);
    event TerminateAuctionPrematurely(uint256 indexed id, address sender, uint256 collateralAmount);

    constructor(address safeEngine_, address liquidationEngine_, bytes32 collateralType_) public {
        safeEngine = SAFEEngineLike(safeEngine_);
        liquidationEngine = LiquidationEngineLike(liquidationEngine_);
        collateralType = collateralType_;
        authorizedAccounts[msg.sender] = 1;
        emit AddAuthorization(msg.sender);
    }

    function addUint48(uint48 x, uint48 y) internal pure returns (uint48 z) {

        require((z = x + y) >= x, "IncreasingDiscountCollateralAuctionHouse/add-uint48-overflow");
    }
    function addUint256(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "IncreasingDiscountCollateralAuctionHouse/add-uint256-overflow");
    }
    function subtract(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "IncreasingDiscountCollateralAuctionHouse/sub-underflow");
    }
    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "IncreasingDiscountCollateralAuctionHouse/mul-overflow");
    }
    uint256 constant WAD = 10 ** 18;
    function wmultiply(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = multiply(x, y) / WAD;
    }
    uint256 constant RAY = 10 ** 27;
    function rdivide(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y > 0, "IncreasingDiscountCollateralAuctionHouse/rdiv-by-zero");
        z = multiply(x, RAY) / y;
    }
    function rmultiply(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x * y;
        require(y == 0 || z / y == x, "IncreasingDiscountCollateralAuctionHouse/rmul-overflow");
        z = z / RAY;
    }
    function wdivide(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y > 0, "IncreasingDiscountCollateralAuctionHouse/wdiv-by-zero");
        z = multiply(x, WAD) / y;
    }
    function minimum(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = (x <= y) ? x : y;
    }
    function maximum(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = (x >= y) ? x : y;
    }
    function rpower(uint256 x, uint256 n, uint256 b) internal pure returns (uint256 z) {

      assembly {
        switch x case 0 {switch n case 0 {z := b} default {z := 0}}
        default {
          switch mod(n, 2) case 0 { z := b } default { z := x }
          let half := div(b, 2)  // for rounding.
          for { n := div(n, 2) } n { n := div(n,2) } {
            let xx := mul(x, x)
            if iszero(eq(div(xx, x), x)) { revert(0,0) }
            let xxRound := add(xx, half)
            if lt(xxRound, xx) { revert(0,0) }
            x := div(xxRound, b)
            if mod(n,2) {
              let zx := mul(z, x)
              if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
              let zxRound := add(zx, half)
              if lt(zxRound, zx) { revert(0,0) }
              z := div(zxRound, b)
            }
          }
        }
      }
    }

    function either(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := or(x, y)}
    }
    function both(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := and(x, y)}
    }

    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {
        if (parameter == "minDiscount") {
            require(both(data >= maxDiscount, data < WAD), "IncreasingDiscountCollateralAuctionHouse/invalid-min-discount");
            minDiscount = data;
        }
        else if (parameter == "maxDiscount") {
            require(both(both(data <= minDiscount, data < WAD), data > 0), "IncreasingDiscountCollateralAuctionHouse/invalid-max-discount");
            maxDiscount = data;
        }
        else if (parameter == "perSecondDiscountUpdateRate") {
            require(data <= RAY, "IncreasingDiscountCollateralAuctionHouse/invalid-discount-update-rate");
            perSecondDiscountUpdateRate = data;
        }
        else if (parameter == "maxDiscountUpdateRateTimeline") {
            require(both(data > 0, uint256(uint48(-1)) > addUint256(now, data)), "IncreasingDiscountCollateralAuctionHouse/invalid-update-rate-time");
            maxDiscountUpdateRateTimeline = data;
        }
        else if (parameter == "lowerCollateralMedianDeviation") {
            require(data <= WAD, "IncreasingDiscountCollateralAuctionHouse/invalid-lower-collateral-median-deviation");
            lowerCollateralMedianDeviation = data;
        }
        else if (parameter == "upperCollateralMedianDeviation") {
            require(data <= WAD, "IncreasingDiscountCollateralAuctionHouse/invalid-upper-collateral-median-deviation");
            upperCollateralMedianDeviation = data;
        }
        else if (parameter == "lowerSystemCoinMedianDeviation") {
            require(data <= WAD, "IncreasingDiscountCollateralAuctionHouse/invalid-lower-system-coin-median-deviation");
            lowerSystemCoinMedianDeviation = data;
        }
        else if (parameter == "upperSystemCoinMedianDeviation") {
            require(data <= WAD, "IncreasingDiscountCollateralAuctionHouse/invalid-upper-system-coin-median-deviation");
            upperSystemCoinMedianDeviation = data;
        }
        else if (parameter == "minSystemCoinMedianDeviation") {
            minSystemCoinMedianDeviation = data;
        }
        else if (parameter == "minimumBid") {
            require(data >= WAD, "IncreasingDiscountCollateralAuctionHouse/invalid-minimum-bid");
            minimumBid = data;
        }
        else revert("IncreasingDiscountCollateralAuctionHouse/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }
    function modifyParameters(bytes32 parameter, address data) external isAuthorized {
        if (parameter == "oracleRelayer") oracleRelayer = OracleRelayerLike(data);
        else if (parameter == "collateralFSM") {
          collateralFSM = OracleLike(data);
          collateralFSM.priceSource();
        }
        else if (parameter == "systemCoinOracle") systemCoinOracle = OracleLike(data);
        else if (parameter == "liquidationEngine") liquidationEngine = LiquidationEngineLike(data);
        else revert("IncreasingDiscountCollateralAuctionHouse/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    function getBoughtCollateral(
        uint256 id,
        uint256 collateralFsmPriceFeedValue,
        uint256 collateralMedianPriceFeedValue,
        uint256 systemCoinPriceFeedValue,
        uint256 adjustedBid,
        uint256 customDiscount
    ) private view returns (uint256) {
        uint256 discountedCollateralPrice =
          getDiscountedCollateralPrice(
            collateralFsmPriceFeedValue,
            collateralMedianPriceFeedValue,
            systemCoinPriceFeedValue,
            customDiscount
          );
        uint256 boughtCollateral = wdivide(adjustedBid, discountedCollateralPrice);
        boughtCollateral = (boughtCollateral > bids[id].amountToSell) ? bids[id].amountToSell : boughtCollateral;

        return boughtCollateral;
    }
    function updateCurrentDiscount(uint256 id) private returns (uint256) {
        Bid storage auctionBidData              = bids[id];
        auctionBidData.currentDiscount          = getNextCurrentDiscount(id);
        auctionBidData.latestDiscountUpdateTime = now;
        return auctionBidData.currentDiscount;
    }

    function getCollateralMedianPrice() public view returns (uint256 priceFeed) {
        address collateralMedian;
        try collateralFSM.priceSource() returns (address median) {
          collateralMedian = median;
        } catch (bytes memory revertReason) {}

        if (collateralMedian == address(0)) return 0;

        try OracleLike(collateralMedian).getResultWithValidity()
          returns (uint256 price, bool valid) {
          if (valid) {
            priceFeed = uint256(price);
          }
        } catch (bytes memory revertReason) {
          return 0;
        }
    }
    function getSystemCoinMarketPrice() public view returns (uint256 priceFeed) {
        if (address(systemCoinOracle) == address(0)) return 0;

        try systemCoinOracle.getResultWithValidity()
          returns (uint256 price, bool valid) {
          if (valid) {
            priceFeed = uint256(price) * 10 ** 9; // scale to RAY
          }
        } catch (bytes memory revertReason) {
          return 0;
        }
    }
    function getSystemCoinFloorDeviatedPrice(uint256 redemptionPrice) public view returns (uint256 floorPrice) {
        uint256 minFloorDeviatedPrice = wmultiply(redemptionPrice, minSystemCoinMedianDeviation);
        floorPrice = wmultiply(redemptionPrice, lowerSystemCoinMedianDeviation);
        floorPrice = (floorPrice <= minFloorDeviatedPrice) ? floorPrice : redemptionPrice;
    }
    function getSystemCoinCeilingDeviatedPrice(uint256 redemptionPrice) public view returns (uint256 ceilingPrice) {
        uint256 minCeilingDeviatedPrice = wmultiply(redemptionPrice, subtract(2 * WAD, minSystemCoinMedianDeviation));
        ceilingPrice = wmultiply(redemptionPrice, subtract(2 * WAD, upperSystemCoinMedianDeviation));
        ceilingPrice = (ceilingPrice >= minCeilingDeviatedPrice) ? ceilingPrice : redemptionPrice;
    }
    function getCollateralFSMAndFinalSystemCoinPrices(uint256 systemCoinRedemptionPrice) public view returns (uint256, uint256) {
        require(systemCoinRedemptionPrice > 0, "IncreasingDiscountCollateralAuctionHouse/invalid-redemption-price-provided");
        (uint256 collateralFsmPriceFeedValue, bool collateralFsmHasValidValue) = collateralFSM.getResultWithValidity();
        if (!collateralFsmHasValidValue) {
          return (0, 0);
        }

        uint256 systemCoinAdjustedPrice  = systemCoinRedemptionPrice;
        uint256 systemCoinPriceFeedValue = getSystemCoinMarketPrice();

        if (systemCoinPriceFeedValue > 0) {
          uint256 floorPrice   = getSystemCoinFloorDeviatedPrice(systemCoinAdjustedPrice);
          uint256 ceilingPrice = getSystemCoinCeilingDeviatedPrice(systemCoinAdjustedPrice);

          if (uint(systemCoinPriceFeedValue) < systemCoinAdjustedPrice) {
            systemCoinAdjustedPrice = maximum(uint256(systemCoinPriceFeedValue), floorPrice);
          } else {
            systemCoinAdjustedPrice = minimum(uint256(systemCoinPriceFeedValue), ceilingPrice);
          }
        }

        return (uint256(collateralFsmPriceFeedValue), systemCoinAdjustedPrice);
    }
    function getFinalBaseCollateralPrice(
        uint256 collateralFsmPriceFeedValue,
        uint256 collateralMedianPriceFeedValue
    ) public view returns (uint256) {
        uint256 floorPrice   = wmultiply(collateralFsmPriceFeedValue, lowerCollateralMedianDeviation);
        uint256 ceilingPrice = wmultiply(collateralFsmPriceFeedValue, subtract(2 * WAD, upperCollateralMedianDeviation));

        uint256 adjustedMedianPrice = (collateralMedianPriceFeedValue == 0) ?
          collateralFsmPriceFeedValue : collateralMedianPriceFeedValue;

        if (adjustedMedianPrice < collateralFsmPriceFeedValue) {
          return maximum(adjustedMedianPrice, floorPrice);
        } else {
          return minimum(adjustedMedianPrice, ceilingPrice);
        }
    }
    function getDiscountedCollateralPrice(
        uint256 collateralFsmPriceFeedValue,
        uint256 collateralMedianPriceFeedValue,
        uint256 systemCoinPriceFeedValue,
        uint256 customDiscount
    ) public view returns (uint256) {
        return wmultiply(
          rdivide(getFinalBaseCollateralPrice(collateralFsmPriceFeedValue, collateralMedianPriceFeedValue), systemCoinPriceFeedValue),
          customDiscount
        );
    }
    function getNextCurrentDiscount(uint256 id) public view returns (uint256) {
        if (bids[id].forgoneCollateralReceiver == address(0)) return RAY;
        uint256 nextDiscount = bids[id].currentDiscount;

        if (both(uint48(now) < bids[id].discountIncreaseDeadline, bids[id].currentDiscount > bids[id].maxDiscount)) {
            nextDiscount = rmultiply(
              rpower(bids[id].perSecondDiscountUpdateRate, subtract(now, bids[id].latestDiscountUpdateTime), RAY),
              bids[id].currentDiscount
            );

            if (nextDiscount <= bids[id].maxDiscount) {
              nextDiscount = bids[id].maxDiscount;
            }
        } else {
            bool currentZeroMaxNonZero = both(bids[id].currentDiscount == 0, bids[id].maxDiscount > 0);
            bool doneUpdating          = both(uint48(now) >= bids[id].discountIncreaseDeadline, bids[id].currentDiscount != bids[id].maxDiscount);

            if (either(currentZeroMaxNonZero, doneUpdating)) {
              nextDiscount = bids[id].maxDiscount;
            }
        }

        return nextDiscount;
    }
    function getAdjustedBid(
        uint256 id, uint256 wad
    ) public view returns (bool, uint256) {
        if (either(
          either(bids[id].amountToSell == 0, bids[id].amountToRaise == 0),
          either(wad == 0, wad < minimumBid)
        )) {
          return (false, wad);
        }

        uint256 remainingToRaise = bids[id].amountToRaise;

        uint256 adjustedBid = wad;
        if (multiply(adjustedBid, RAY) > remainingToRaise) {
            adjustedBid = addUint256(remainingToRaise / RAY, 1);
        }

        remainingToRaise = (multiply(adjustedBid, RAY) > remainingToRaise) ? 0 : subtract(bids[id].amountToRaise, multiply(adjustedBid, RAY));
        if (both(remainingToRaise > 0, remainingToRaise < RAY)) {
            return (false, adjustedBid);
        }

        return (true, adjustedBid);
    }

    function startAuction(
        address forgoneCollateralReceiver,
        address auctionIncomeRecipient,
        uint256 amountToRaise,
        uint256 amountToSell,
        uint256 initialBid
    ) public isAuthorized returns (uint256 id) {
        require(auctionsStarted < uint256(-1), "IncreasingDiscountCollateralAuctionHouse/overflow");
        require(amountToSell > 0, "IncreasingDiscountCollateralAuctionHouse/no-collateral-for-sale");
        require(amountToRaise > 0, "IncreasingDiscountCollateralAuctionHouse/nothing-to-raise");
        require(amountToRaise >= RAY, "IncreasingDiscountCollateralAuctionHouse/dusty-auction");
        id = ++auctionsStarted;

        uint48 discountIncreaseDeadline      = addUint48(uint48(now), uint48(maxDiscountUpdateRateTimeline));

        bids[id].currentDiscount             = minDiscount;
        bids[id].maxDiscount                 = maxDiscount;
        bids[id].perSecondDiscountUpdateRate = perSecondDiscountUpdateRate;
        bids[id].discountIncreaseDeadline    = discountIncreaseDeadline;
        bids[id].latestDiscountUpdateTime    = now;
        bids[id].amountToSell                = amountToSell;
        bids[id].forgoneCollateralReceiver   = forgoneCollateralReceiver;
        bids[id].auctionIncomeRecipient      = auctionIncomeRecipient;
        bids[id].amountToRaise               = amountToRaise;

        safeEngine.transferCollateral(collateralType, msg.sender, address(this), amountToSell);

        emit StartAuction(
          id,
          auctionsStarted,
          amountToSell,
          initialBid,
          amountToRaise,
          minDiscount,
          maxDiscount,
          perSecondDiscountUpdateRate,
          discountIncreaseDeadline,
          forgoneCollateralReceiver,
          auctionIncomeRecipient
        );
    }
    function getApproximateCollateralBought(uint256 id, uint256 wad) external view returns (uint256, uint256) {
        if (lastReadRedemptionPrice == 0) return (0, wad);

        (bool validAuctionAndBid, uint256 adjustedBid) = getAdjustedBid(id, wad);
        if (!validAuctionAndBid) {
            return (0, adjustedBid);
        }

        (uint256 collateralFsmPriceFeedValue, uint256 systemCoinPriceFeedValue) = getCollateralFSMAndFinalSystemCoinPrices(lastReadRedemptionPrice);
        if (collateralFsmPriceFeedValue == 0) {
          return (0, adjustedBid);
        }

        return (getBoughtCollateral(
          id,
          collateralFsmPriceFeedValue,
          getCollateralMedianPrice(),
          systemCoinPriceFeedValue,
          adjustedBid,
          bids[id].currentDiscount
        ), adjustedBid);
    }
    function getCollateralBought(uint256 id, uint256 wad) external returns (uint256, uint256) {
        (bool validAuctionAndBid, uint256 adjustedBid) = getAdjustedBid(id, wad);
        if (!validAuctionAndBid) {
            return (0, adjustedBid);
        }

        lastReadRedemptionPrice = oracleRelayer.redemptionPrice();

        (uint256 collateralFsmPriceFeedValue, uint256 systemCoinPriceFeedValue) = getCollateralFSMAndFinalSystemCoinPrices(lastReadRedemptionPrice);
        if (collateralFsmPriceFeedValue == 0) {
          return (0, adjustedBid);
        }

        return (getBoughtCollateral(
          id,
          collateralFsmPriceFeedValue,
          getCollateralMedianPrice(),
          systemCoinPriceFeedValue,
          adjustedBid,
          updateCurrentDiscount(id)
        ), adjustedBid);
    }
    function buyCollateral(uint256 id, uint256 wad) external {
        require(both(bids[id].amountToSell > 0, bids[id].amountToRaise > 0), "IncreasingDiscountCollateralAuctionHouse/inexistent-auction");
        require(both(wad > 0, wad >= minimumBid), "IncreasingDiscountCollateralAuctionHouse/invalid-bid");

        uint256 adjustedBid = wad;
        if (multiply(adjustedBid, RAY) > bids[id].amountToRaise) {
            adjustedBid = addUint256(bids[id].amountToRaise / RAY, 1);
        }

        lastReadRedemptionPrice = oracleRelayer.redemptionPrice();

        (uint256 collateralFsmPriceFeedValue, uint256 systemCoinPriceFeedValue) = getCollateralFSMAndFinalSystemCoinPrices(lastReadRedemptionPrice);
        require(collateralFsmPriceFeedValue > 0, "IncreasingDiscountCollateralAuctionHouse/collateral-fsm-invalid-value");

        uint256 boughtCollateral = getBoughtCollateral(
            id, collateralFsmPriceFeedValue, getCollateralMedianPrice(), systemCoinPriceFeedValue, adjustedBid, updateCurrentDiscount(id)
        );
        require(boughtCollateral > 0, "IncreasingDiscountCollateralAuctionHouse/null-bought-amount");
        bids[id].amountToSell = subtract(bids[id].amountToSell, boughtCollateral);

        uint256 remainingToRaise = (either(multiply(wad, RAY) >= bids[id].amountToRaise, bids[id].amountToSell == 0)) ?
            bids[id].amountToRaise : subtract(bids[id].amountToRaise, multiply(wad, RAY));

        bids[id].amountToRaise = (multiply(adjustedBid, RAY) > bids[id].amountToRaise) ?
            0 : subtract(bids[id].amountToRaise, multiply(adjustedBid, RAY));

        require(
          either(bids[id].amountToRaise == 0, bids[id].amountToRaise >= multiply(minimumBid, RAY)),
          "IncreasingDiscountCollateralAuctionHouse/invalid-left-to-raise"
        );

        safeEngine.transferInternalCoins(msg.sender, bids[id].auctionIncomeRecipient, multiply(adjustedBid, RAY));
        safeEngine.transferCollateral(collateralType, address(this), msg.sender, boughtCollateral);

        emit BuyCollateral(id, adjustedBid, boughtCollateral);

        bool soldAll = either(bids[id].amountToRaise == 0, bids[id].amountToSell == 0);
        if (soldAll) {
            liquidationEngine.removeCoinsFromAuction(remainingToRaise);
        } else {
            liquidationEngine.removeCoinsFromAuction(multiply(adjustedBid, RAY));
        }

        if (soldAll) {
            safeEngine.transferCollateral(collateralType, address(this), bids[id].forgoneCollateralReceiver, bids[id].amountToSell);
            delete bids[id];
            emit SettleAuction(id, bids[id].amountToSell);
        }
    }
    function settleAuction(uint256 id) external {
        return;
    }
    function terminateAuctionPrematurely(uint256 id) external isAuthorized {
        require(both(bids[id].amountToSell > 0, bids[id].amountToRaise > 0), "IncreasingDiscountCollateralAuctionHouse/inexistent-auction");
        liquidationEngine.removeCoinsFromAuction(bids[id].amountToRaise);
        safeEngine.transferCollateral(collateralType, address(this), msg.sender, bids[id].amountToSell);
        delete bids[id];
        emit TerminateAuctionPrematurely(id, msg.sender, bids[id].amountToSell);
    }

    function bidAmount(uint256 id) public view returns (uint256) {
        return 0;
    }
    function remainingAmountToSell(uint256 id) public view returns (uint256) {
        return bids[id].amountToSell;
    }
    function forgoneCollateralReceiver(uint256 id) public view returns (address) {
        return bids[id].forgoneCollateralReceiver;
    }
    function raisedAmount(uint256 id) public view returns (uint256) {
        return 0;
    }
    function amountToRaise(uint256 id) public view returns (uint256) {
        return bids[id].amountToRaise;
    }
}