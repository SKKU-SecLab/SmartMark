pragma solidity 0.8.9;

library Decimal {

    uint256 internal constant ONE = 1e18;

    function mulDecimal(uint256 number, uint256 decimal)
        internal
        pure
        returns (uint256)
    {

        return (number * decimal) / ONE;
    }

    function divDecimal(uint256 number, uint256 decimal)
        internal
        pure
        returns (uint256)
    {

        return (number * ONE) / decimal;
    }
}// MIT
pragma solidity 0.8.9;

interface IInterestRateModel {

    function getBorrowRate(
        uint256 balance,
        uint256 totalBorrows,
        uint256 totalReserves
    ) external view returns (uint256);


    function utilizationRate(
        uint256 balance,
        uint256 borrows,
        uint256 reserves
    ) external pure returns (uint256);


    function getSupplyRate(
        uint256 balance,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactor
    ) external view returns (uint256);

}// MIT
pragma solidity 0.8.9;


contract InterestRateModel is IInterestRateModel {

    using Decimal for uint256;

    uint256 public immutable baseRate;

    uint256 public immutable multiplier;

    uint256 public immutable jumpMultiplier;

    uint256 public immutable kink;

    constructor(
        uint256 baseRate_,
        uint256 multiplier_,
        uint256 jumpMultiplier_,
        uint256 kink_
    ) {
        baseRate = baseRate_;
        multiplier = multiplier_;
        jumpMultiplier = jumpMultiplier_;
        kink = kink_;
    }

    function utilizationRate(
        uint256 balance,
        uint256 borrows,
        uint256 reserves
    ) public pure returns (uint256) {

        if (borrows == 0) {
            return 0;
        }
        return borrows.divDecimal(balance + borrows - reserves);
    }

    function getBorrowRate(
        uint256 balance,
        uint256 borrows,
        uint256 reserves
    ) public view returns (uint256) {

        if (borrows == 0) {
            return 0;
        }

        uint256 util = utilizationRate(balance, borrows, reserves);
        if (util <= kink) {
            return baseRate + multiplier.mulDecimal(util);
        } else {
            return
                baseRate +
                multiplier.mulDecimal(kink) +
                jumpMultiplier.mulDecimal(util - kink);
        }
    }

    function getSupplyRate(
        uint256 balance,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactor
    ) external view returns (uint256) {

        uint256 util = utilizationRate(balance, borrows, reserves);

        return
            util
                .mulDecimal(getBorrowRate(balance, borrows, reserves))
                .mulDecimal(Decimal.ONE - reserveFactor);
    }
}