
pragma solidity 0.6.6;




enum BondType {NONE, PURE_SBT, SBT_SHAPE, LBT_SHAPE, TRIANGLE}





interface BondPricerInterface {

    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] calldata points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) external view returns (uint256 price, uint256 leverageE8);

}




library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}




library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}





library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}








library SafeMathDivRoundUp {

    using SafeMath for uint256;

    function divRoundUp(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        require(b > 0, errorMessage);
        return ((a - 1) / b) + 1;
    }

    function divRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {

        return divRoundUp(a, b, "SafeMathDivRoundUp: modulo by zero");
    }
}

abstract contract UseSafeMath {
    using SafeMath for uint256;
    using SafeMathDivRoundUp for uint256;
    using SafeMath for uint64;
    using SafeMathDivRoundUp for uint64;
    using SafeMath for uint16;
    using SignedSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
}




abstract contract AdvancedMath {
    int256 internal constant SQRT_2PI_E8 = 250662827;
    int256 internal constant PI_E8 = 314159265;
    int256 internal constant E_E8 = 271828182;
    int256 internal constant INV_E_E8 = 36787944; // 1/e
    int256 internal constant LOG2_E8 = 30102999;
    int256 internal constant LOG3_E8 = 47712125;

    int256 internal constant p = 23164190;
    int256 internal constant b1 = 31938153;
    int256 internal constant b2 = -35656378;
    int256 internal constant b3 = 178147793;
    int256 internal constant b4 = -182125597;
    int256 internal constant b5 = 133027442;

    function _sqrt(int256 x) internal pure returns (int256 y) {
        require(x >= 0, "cannot calculate the square root of a negative number");
        int256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function _logTaylor(int256 inputE4) internal pure returns (int256 outputE4) {
        require(inputE4 > 1, "input should be positive number");
        int256 inputE8 = inputE4 * 10**4;
        while (inputE8 < INV_E_E8) {
            inputE8 = (inputE8 * E_E8) / 10**8;
            outputE4 -= 10**4;
        }
        while (inputE8 > 10**8) {
            inputE8 = (inputE8 * INV_E_E8) / 10**8;
            outputE4 += 10**4;
        }
        outputE4 += _logTaylor1(inputE8 / 10**4 - 10**4);
    }

    function _logTaylor1(int256 inputE4) internal pure returns (int256 outputE4) {
        outputE4 =
            inputE4 -
            inputE4**2 /
            (2 * 10**4) +
            inputE4**3 /
            (3 * 10**8) -
            inputE4**4 /
            (4 * 10**12) +
            inputE4**5 /
            (5 * 10**16) -
            inputE4**6 /
            (6 * 10**20) +
            inputE4**7 /
            (7 * 10**24) -
            inputE4**8 /
            (8 * 10**28);
    }

    function _calcPnorm(int256 inputE4) internal pure returns (int256 outputE8) {
        require(inputE4 < 440 * 10**4 && inputE4 > -440 * 10**4, "input is too large");
        int256 _inputE4 = inputE4 > 0 ? inputE4 : inputE4 * (-1);
        int256 t = 10**16 / (10**8 + (p * _inputE4) / 10**4);
        int256 X2 = (inputE4 * inputE4) / 2;
        int256 exp2X2 = 10**8 +
            X2 +
            (X2**2 / (2 * 10**8)) +
            (X2**3 / (6 * 10**16)) +
            (X2**4 / (24 * 10**24)) +
            (X2**5 / (120 * 10**32)) +
            (X2**6 / (720 * 10**40));
        int256 Z = (10**24 / exp2X2) / SQRT_2PI_E8;
        int256 y = (b5 * t) / 10**8;
        y = ((y + b4) * t) / 10**8;
        y = ((y + b3) * t) / 10**8;
        y = ((y + b2) * t) / 10**8;
        y = 10**8 - (Z * ((y + b1) * t)) / 10**16;
        return inputE4 > 0 ? y : 10**8 - y;
    }
}







contract GeneralizedPricing is UseSafeMath, AdvancedMath {

    int256 internal constant SQRT_YEAR_E8 = 5615.69229926 * 10**8;

    int256 internal constant MIN_ND1_E8 = 0.0001 * 10**8;
    int256 internal constant MAX_ND1_E8 = 0.9999 * 10**8;
    uint256 internal constant MAX_LEVERAGE_E8 = 1000 * 10**8;

    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) public pure returns (uint256 price, uint256 leverageE8) {

        if (bondType == BondType.LBT_SHAPE) {
            (price, leverageE8) = _calcLbtShapePriceAndLeverage(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.SBT_SHAPE) {
            (price, leverageE8) = _calcSbtShapePrice(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.TRIANGLE) {
            (price, leverageE8) = _calcTrianglePrice(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.PURE_SBT) {
            (price, leverageE8) = _calcPureSBTPrice(points, spotPrice, volatilityE8, untilMaturity);
        }
    }


    function _calcLbtShapePriceAndLeverage(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {

        require(points.length == 3, "3 coordinates is needed for LBT price calculation");
        uint256 inclineE8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        (uint256 callOptionPriceE8, int256 nd1E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        price = (callOptionPriceE8 * inclineE8) / 10**8;
        leverageE8 = _calcLbtLeverage(
            uint256(spotPrice),
            price,
            (nd1E8 * int256(inclineE8)) / 10**8
        );
    }

    function _calcPureSBTPrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {

        require(points.length == 1, "1 coordinate is needed for pure SBT price calculation");
        (uint256 callOptionPrice1, int256 nd1E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        price = uint256(spotPrice) > callOptionPrice1 ? (uint256(spotPrice) - callOptionPrice1) : 0;
        leverageE8 = _calcLbtLeverage(uint256(spotPrice), price, 10**8 - nd1E8);
    }

    function _calcSbtShapePrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {

        require(points.length == 3, "3 coordinates is needed for SBT price calculation");
        uint256 inclineE8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        (uint256 callOptionPrice1, int256 nd11E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice2, int256 nd12E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[1]),
            volatilityE8,
            untilMaturity
        );
        price = callOptionPrice1 > callOptionPrice2
            ? (inclineE8 * (callOptionPrice1 - callOptionPrice2)) / 10**8
            : 0;
        leverageE8 = _calcLbtLeverage(
            uint256(spotPrice),
            price,
            (int256(inclineE8) * (nd11E8 - nd12E8)) / 10**8
        );
    }

    function _calcTrianglePrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {

        require(
            points.length == 4,
            "4 coordinates is needed for triangle option price calculation"
        );
        uint256 incline1E8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        uint256 incline2E8 = (points[2].mul(10**8)).div(points[3].sub(points[1]));
        (uint256 callOptionPrice1, int256 nd11E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice2, int256 nd12E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[1]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice3, int256 nd13E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[3]),
            volatilityE8,
            untilMaturity
        );
        int256 nd1E8 = ((nd11E8 * int256(incline1E8)) +
            (nd13E8 * int256(incline2E8)) -
            (int256(incline1E8 + incline2E8) * nd12E8)) / 10**8;

        uint256 price12 = (callOptionPrice1 * incline1E8) + (callOptionPrice3 * incline2E8);
        price = price12 > (incline1E8 + incline2E8) * callOptionPrice2
            ? (price12 - ((incline1E8 + incline2E8) * callOptionPrice2)) / 10**8
            : 0;
        leverageE8 = _calcLbtLeverage(uint256(spotPrice), price, nd1E8);
    }

    function _calcLbtPrice(
        int256 spotPrice,
        int256 strikePrice,
        int256 nd1E8,
        int256 nd2E8
    ) internal pure returns (int256 lbtPrice) {

        int256 lowestPrice = (spotPrice > strikePrice) ? spotPrice - strikePrice : 0;
        lbtPrice = (spotPrice * nd1E8 - strikePrice * nd2E8) / 10**8;
        if (lbtPrice < lowestPrice) {
            lbtPrice = lowestPrice;
        }
    }

    function _calcLbtLeverage(
        uint256 spotPrice,
        uint256 lbtPrice,
        int256 nd1E8
    ) internal pure returns (uint256 lbtLeverageE8) {

        int256 modifiedNd1E8 = nd1E8 < MIN_ND1_E8 ? MIN_ND1_E8 : nd1E8 > MAX_ND1_E8
            ? MAX_ND1_E8
            : nd1E8;
        return lbtPrice != 0 ? (uint256(modifiedNd1E8) * spotPrice) / lbtPrice : MAX_LEVERAGE_E8;
    }

    function calcCallOptionPrice(
        int256 spotPrice,
        int256 strikePrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) public pure returns (uint256 price, int256 nd1E8) {

        require(spotPrice > 0 && spotPrice < 10**13, "oracle price should be between 0 and 10^13");
        require(
            volatilityE8 > 0 && volatilityE8 < 10 * 10**8,
            "oracle volatility should be between 0% and 1000%"
        );
        require(
            untilMaturity > 0 && untilMaturity < 31536000,
            "the bond should not have expired and less than 1 year"
        );
        require(
            strikePrice > 0 && strikePrice < 10**13,
            "strike price should be between 0 and 10^13"
        );

        int256 spotPerStrikeE4 = (spotPrice * 10**4) / strikePrice;
        int256 sigE8 = (volatilityE8 * (_sqrt(untilMaturity)) * (10**8)) / SQRT_YEAR_E8;

        int256 logSigE4 = _logTaylor(spotPerStrikeE4);
        int256 d1E4 = ((logSigE4 * 10**8) / sigE8) + (sigE8 / (2 * 10**4));
        nd1E8 = _calcPnorm(d1E4);

        int256 d2E4 = d1E4 - (sigE8 / 10**4);
        int256 nd2E8 = _calcPnorm(d2E4);
        price = uint256(_calcLbtPrice(spotPrice, strikePrice, nd1E8, nd2E8));
    }
}






abstract contract CustomGeneralizedPricing is BondPricerInterface {
    using SafeMath for uint256;

    GeneralizedPricing internal immutable _originalBondPricerAddress;

    constructor(address originalBondPricerAddress) public {
        _originalBondPricerAddress = GeneralizedPricing(originalBondPricerAddress);
    }

    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] calldata points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) external view override returns (uint256 price, uint256 leverageE8) {
        (price, leverageE8) = _originalBondPricerAddress.calcPriceAndLeverage(
            bondType,
            points,
            spotPrice,
            volatilityE8,
            untilMaturity
        );
        if (bondType == BondType.LBT_SHAPE) {
            require(
                _isAcceptableLbt(points, spotPrice, volatilityE8, untilMaturity, price, leverageE8),
                "the liquid bond is not acceptable"
            );
        } else if (bondType == BondType.SBT_SHAPE) {
            require(
                _isAcceptableSbt(points, spotPrice, volatilityE8, untilMaturity, price, leverageE8),
                "the solid bond is not acceptable"
            );
        } else if (bondType == BondType.TRIANGLE) {
            require(
                _isAcceptableTriangleBond(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the triangle bond is not acceptable"
            );
        } else if (bondType == BondType.PURE_SBT) {
            require(
                _isAcceptablePureSbt(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the pure solid bond is not acceptable"
            );
        } else {
            require(
                _isAcceptableOtherBond(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the bond is not acceptable"
            );
        }
    }

    function originalBondPricer() external view returns (address originalBondPricerAddress) {
        originalBondPricerAddress = address(_originalBondPricerAddress);
    }

    function _isAcceptableLbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableSbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableTriangleBond(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptablePureSbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableOtherBond(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);
}




contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




abstract contract Time {
    function _getBlockTimestampSec() internal view returns (uint256 unixtimesec) {
        unixtimesec = block.timestamp; // solhint-disable-line not-rely-on-time
    }
}








contract SbtPricerWithStableBorder is CustomGeneralizedPricing, Ownable, Time {

    using SafeMath for uint256;

    uint16 internal _stableBorderE4;

    event LogUpdateStableBorder(uint16 stableBorderE4);

    constructor(address originalBondPricerAddress, uint16 stableBorderE4)
        public
        CustomGeneralizedPricing(originalBondPricerAddress)
    {
        _updateStableBorder(stableBorderE4);
    }

    function updateStableBorder(uint16 stableBorderE4) external onlyOwner {

        _updateStableBorder(stableBorderE4);
    }

    function getStableBorder() external view returns (uint16 stableBorderE4) {

        stableBorderE4 = _stableBorderE4;
    }

    function _updateStableBorder(uint16 stableBorderE4) internal {

        require(stableBorderE4 <= 10**4, "stable border must be less than or equal to 1.0000");
        _stableBorderE4 = stableBorderE4;
        emit LogUpdateStableBorder(stableBorderE4);
    }

    function _isAcceptableLbt(
        uint256[] memory,
        int256,
        int256,
        int256,
        uint256,
        uint256
    ) internal view override returns (bool) {

        _isNotAcceptable();
    }

    function _isAcceptableSbt(
        uint256[] memory,
        int256,
        int256,
        int256,
        uint256,
        uint256
    ) internal view override returns (bool) {

        _isNotAcceptable();
    }

    function _isAcceptableTriangleBond(
        uint256[] memory,
        int256,
        int256,
        int256,
        uint256,
        uint256
    ) internal view override returns (bool) {

        _isNotAcceptable();
    }

    function _isAcceptablePureSbt(
        uint256[] memory points,
        int256,
        int256,
        int256 untilMaturity,
        uint256 bondPriceE8,
        uint256
    ) internal view override returns (bool) {

        require(untilMaturity <= 12 weeks, "the bond maturity must be less than 12 weeks");
        uint256 strikePriceE8 = points[0];
        require(
            bondPriceE8.mul(10**4) >= strikePriceE8.mul(_stableBorderE4),
            "the bond does not meet the stable border"
        );
        return true;
    }

    function _isAcceptableOtherBond(
        uint256[] memory,
        int256,
        int256,
        int256,
        uint256,
        uint256
    ) internal view override returns (bool) {

        _isNotAcceptable();
    }

    function _isNotAcceptable() internal pure {

        revert("the bond is not pure SBT type");
    }
}