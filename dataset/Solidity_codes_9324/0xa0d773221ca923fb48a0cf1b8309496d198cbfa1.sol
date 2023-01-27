
pragma solidity 0.6.6;





interface TransferETHInterface {

    receive() external payable;

    event LogTransferETH(address indexed from, address indexed to, uint256 value);
}




interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}







interface BondTokenInterface is IERC20 {

    event LogExpire(uint128 rateNumerator, uint128 rateDenominator, bool firstTime);

    function mint(address account, uint256 amount) external returns (bool success);


    function expire(uint128 rateNumerator, uint128 rateDenominator)
        external
        returns (bool firstTime);


    function simpleBurn(address account, uint256 amount) external returns (bool success);


    function burn(uint256 amount) external returns (bool success);


    function burnAll() external returns (uint256 amount);


    function getRate() external view returns (uint128 rateNumerator, uint128 rateDenominator);

}





interface LatestPriceOracleInterface {

    function isWorking() external returns (bool);


    function latestPrice() external returns (uint256);


    function latestTimestamp() external returns (uint256);

}






interface PriceOracleInterface is LatestPriceOracleInterface {

    function latestId() external returns (uint256);


    function getPrice(uint256 id) external returns (uint256);


    function getTimestamp(uint256 id) external returns (uint256);

}






interface BondMakerInterface {

    event LogNewBond(
        bytes32 indexed bondID,
        address indexed bondTokenAddress,
        uint256 indexed maturity,
        bytes32 fnMapID
    );

    event LogNewBondGroup(
        uint256 indexed bondGroupID,
        uint256 indexed maturity,
        uint64 indexed sbtStrikePrice,
        bytes32[] bondIDs
    );

    event LogIssueNewBonds(
        uint256 indexed bondGroupID,
        address indexed issuer,
        uint256 amount
    );

    event LogReverseBondGroupToCollateral(
        uint256 indexed bondGroupID,
        address indexed owner,
        uint256 amount
    );

    event LogExchangeEquivalentBonds(
        address indexed owner,
        uint256 indexed inputBondGroupID,
        uint256 indexed outputBondGroupID,
        uint256 amount
    );

    event LogLiquidateBond(
        bytes32 indexed bondID,
        uint128 rateNumerator,
        uint128 rateDenominator
    );

    function registerNewBond(uint256 maturity, bytes calldata fnMap)
        external
        returns (
            bytes32 bondID,
            address bondTokenAddress,
            bytes32 fnMapID
        );


    function registerNewBondGroup(
        bytes32[] calldata bondIDList,
        uint256 maturity
    ) external returns (uint256 bondGroupID);


    function reverseBondGroupToCollateral(uint256 bondGroupID, uint256 amount)
        external
        returns (bool success);


    function exchangeEquivalentBonds(
        uint256 inputBondGroupID,
        uint256 outputBondGroupID,
        uint256 amount,
        bytes32[] calldata exceptionBonds
    ) external returns (bool);


    function liquidateBond(uint256 bondGroupID, uint256 oracleHintID)
        external
        returns (uint256 totalPayment);


    function collateralAddress() external view returns (address);


    function oracleAddress() external view returns (PriceOracleInterface);


    function feeTaker() external view returns (address);


    function decimalsOfBond() external view returns (uint8);


    function decimalsOfOraclePrice() external view returns (uint8);


    function maturityScale() external view returns (uint256);


    function nextBondGroupID() external view returns (uint256);


    function getBond(bytes32 bondID)
        external
        view
        returns (
            address bondAddress,
            uint256 maturity,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        );


    function getFnMap(bytes32 fnMapID)
        external
        view
        returns (bytes memory fnMap);


    function getBondGroup(uint256 bondGroupID)
        external
        view
        returns (bytes32[] memory bondIDs, uint256 maturity);


    function generateFnMapID(bytes calldata fnMap)
        external
        view
        returns (bytes32 fnMapID);


    function generateBondID(uint256 maturity, bytes calldata fnMap)
        external
        view
        returns (bytes32 bondID);

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





contract Polyline is UseSafeMath {

    struct Point {
        uint64 x; // Value of the x-axis of the x-y plane
        uint64 y; // Value of the y-axis of the x-y plane
    }

    struct LineSegment {
        Point left; // The left end of the line definition range
        Point right; // The right end of the line definition range
    }

    function _mapXtoY(LineSegment memory line, uint64 x)
        internal
        pure
        returns (uint128 numerator, uint64 denominator)
    {

        int256 x1 = int256(line.left.x);
        int256 y1 = int256(line.left.y);
        int256 x2 = int256(line.right.x);
        int256 y2 = int256(line.right.y);

        require(x2 > x1, "must be left.x < right.x");

        denominator = uint64(x2 - x1);

        int256 n = (x - x1) * y2 + (x2 - x) * y1;

        require(n >= 0, "underflow n");
        require(n < 2**128, "system error: overflow n");
        numerator = uint128(n);
    }

    function assertLineSegment(LineSegment memory segment) internal pure {

        uint64 x1 = segment.left.x;
        uint64 x2 = segment.right.x;
        require(x1 < x2, "must be left.x < right.x");
    }

    function assertPolyline(LineSegment[] memory polyline) internal pure {

        uint256 numOfSegment = polyline.length;
        require(numOfSegment != 0, "polyline must not be empty array");

        LineSegment memory leftSegment = polyline[0]; // mutable
        int256 gradientNumerator = int256(leftSegment.right.y) -
            int256(leftSegment.left.y); // mutable
        int256 gradientDenominator = int256(leftSegment.right.x) -
            int256(leftSegment.left.x); // mutable

        require(
            leftSegment.left.x == uint64(0),
            "the x coordinate of left end of the first segment must be 0"
        );
        require(
            leftSegment.left.y == uint64(0),
            "the y coordinate of left end of the first segment must be 0"
        );

        assertLineSegment(leftSegment);

        LineSegment memory rightSegment; // mutable
        for (uint256 i = 1; i < numOfSegment; i++) {
            rightSegment = polyline[i];

            assertLineSegment(rightSegment);

            require(
                leftSegment.right.x == rightSegment.left.x,
                "given polyline has an undefined domain."
            );

            require(
                leftSegment.right.y == rightSegment.left.y,
                "given polyline is not a continuous function"
            );

            int256 nextGradientNumerator = int256(rightSegment.right.y) -
                int256(rightSegment.left.y);
            int256 nextGradientDenominator = int256(rightSegment.right.x) -
                int256(rightSegment.left.x);
            require(
                nextGradientNumerator * gradientDenominator !=
                    nextGradientDenominator * gradientNumerator,
                "the sequential segments must not have the same gradient"
            );

            leftSegment = rightSegment;
            gradientNumerator = nextGradientNumerator;
            gradientDenominator = nextGradientDenominator;
        }


        require(
            gradientNumerator >= 0 && gradientNumerator <= gradientDenominator,
            "the gradient of last line segment must be non-negative, and equal to or less than 1"
        );
    }

    function zipLineSegment(LineSegment memory segment)
        internal
        pure
        returns (uint256 zip)
    {

        uint256 x1U256 = uint256(segment.left.x) << (64 + 64 + 64); // uint64
        uint256 y1U256 = uint256(segment.left.y) << (64 + 64); // uint64
        uint256 x2U256 = uint256(segment.right.x) << 64; // uint64
        uint256 y2U256 = uint256(segment.right.y); // uint64
        zip = x1U256 | y1U256 | x2U256 | y2U256;
    }

    function unzipLineSegment(uint256 zip)
        internal
        pure
        returns (LineSegment memory)
    {

        uint64 x1 = uint64(zip >> (64 + 64 + 64));
        uint64 y1 = uint64(zip >> (64 + 64));
        uint64 x2 = uint64(zip >> 64);
        uint64 y2 = uint64(zip);
        return
            LineSegment({
                left: Point({x: x1, y: y1}),
                right: Point({x: x2, y: y2})
            });
    }

    function decodePolyline(bytes memory fnMap)
        internal
        pure
        returns (uint256[] memory)
    {

        return abi.decode(fnMap, (uint256[]));
    }
}




enum BondType {NONE, PURE_SBT, SBT_SHAPE, LBT_SHAPE, TRIANGLE}







contract DetectBondShape is Polyline {

    function getBondTypeByID(
        BondMakerInterface bondMaker,
        bytes32 bondID,
        BondType submittedType
    )
        public
        view
        returns (
            bool success,
            BondType,
            uint256[] memory points
        )
    {

        (, , , bytes32 fnMapID) = bondMaker.getBond(bondID);
        bytes memory fnMap = bondMaker.getFnMap(fnMapID);
        return _getBondType(fnMap, submittedType);
    }

    function getBondType(bytes calldata fnMap, BondType submittedType)
        external
        pure
        returns (
            bool success,
            BondType,
            uint256[] memory points
        )
    {

        uint256[] memory polyline = decodePolyline(fnMap);
        LineSegment[] memory segments = new LineSegment[](polyline.length);
        for (uint256 i = 0; i < polyline.length; i++) {
            segments[i] = unzipLineSegment(polyline[i]);
        }
        assertPolyline(segments);

        return _getBondType(fnMap, submittedType);
    }

    function _getBondType(bytes memory fnMap, BondType submittedType)
        internal
        pure
        returns (
            bool success,
            BondType,
            uint256[] memory points
        )
    {

        if (submittedType == BondType.NONE) {
            (success, points) = _isSBT(fnMap);
            if (success) {
                return (success, BondType.PURE_SBT, points);
            }

            (success, points) = _isSBTShape(fnMap);
            if (success) {
                return (success, BondType.SBT_SHAPE, points);
            }

            (success, points) = _isLBTShape(fnMap);
            if (success) {
                return (success, BondType.LBT_SHAPE, points);
            }

            (success, points) = _isTriangle(fnMap);
            if (success) {
                return (success, BondType.TRIANGLE, points);
            }

            return (false, BondType.NONE, points);
        } else if (submittedType == BondType.PURE_SBT) {
            (success, points) = _isSBT(fnMap);
            if (success) {
                return (success, BondType.PURE_SBT, points);
            }
        } else if (submittedType == BondType.SBT_SHAPE) {
            (success, points) = _isSBTShape(fnMap);
            if (success) {
                return (success, BondType.SBT_SHAPE, points);
            }
        } else if (submittedType == BondType.LBT_SHAPE) {
            (success, points) = _isLBTShape(fnMap);
            if (success) {
                return (success, BondType.LBT_SHAPE, points);
            }
        } else if (submittedType == BondType.TRIANGLE) {
            (success, points) = _isTriangle(fnMap);
            if (success) {
                return (success, BondType.TRIANGLE, points);
            }
        }

        return (false, BondType.NONE, points);
    }

    function _isLBTShape(bytes memory fnMap)
        internal
        pure
        returns (bool isOk, uint256[] memory points)
    {

        uint256[] memory zippedLines = decodePolyline(fnMap);
        if (zippedLines.length != 2) {
            return (false, points);
        }
        LineSegment memory secondLine = unzipLineSegment(zippedLines[1]);
        if (
            secondLine.left.x != 0 &&
            secondLine.left.y == 0 &&
            secondLine.right.x > secondLine.left.x &&
            secondLine.right.y != 0
        ) {
            uint256[] memory _lines = new uint256[](3);
            _lines[0] = secondLine.left.x;
            _lines[1] = secondLine.right.x;
            _lines[2] = secondLine.right.y;
            return (true, _lines);
        }
        return (false, points);
    }

    function _isTriangle(bytes memory fnMap)
        internal
        pure
        returns (bool isOk, uint256[] memory points)
    {

        uint256[] memory zippedLines = decodePolyline(fnMap);
        if (zippedLines.length != 4) {
            return (false, points);
        }
        LineSegment memory secondLine = unzipLineSegment(zippedLines[1]);
        LineSegment memory thirdLine = unzipLineSegment(zippedLines[2]);
        LineSegment memory forthLine = unzipLineSegment(zippedLines[3]);
        if (
            secondLine.left.x != 0 &&
            secondLine.left.y == 0 &&
            secondLine.right.x > secondLine.left.x &&
            secondLine.right.y != 0 &&
            thirdLine.right.x > secondLine.right.x &&
            thirdLine.right.y == 0 &&
            forthLine.right.x > thirdLine.right.x &&
            forthLine.right.y == 0
        ) {
            uint256[] memory _lines = new uint256[](4);
            _lines[0] = secondLine.left.x;
            _lines[1] = secondLine.right.x;
            _lines[2] = secondLine.right.y;
            _lines[3] = thirdLine.right.x;
            return (true, _lines);
        }
        return (false, points);
    }

    function _isSBTShape(bytes memory fnMap)
        internal
        pure
        returns (bool isOk, uint256[] memory points)
    {

        uint256[] memory zippedLines = decodePolyline(fnMap);
        if (zippedLines.length != 3) {
            return (false, points);
        }
        LineSegment memory secondLine = unzipLineSegment(zippedLines[1]);
        LineSegment memory thirdLine = unzipLineSegment(zippedLines[2]);
        if (
            secondLine.left.x != 0 &&
            secondLine.left.y == 0 &&
            secondLine.right.x > secondLine.left.x &&
            secondLine.right.y != 0 &&
            thirdLine.right.x > secondLine.right.x &&
            thirdLine.right.y == secondLine.right.y
        ) {
            uint256[] memory _lines = new uint256[](3);
            _lines[0] = secondLine.left.x;
            _lines[1] = secondLine.right.x;
            _lines[2] = secondLine.right.y;
            return (true, _lines);
        }
        return (false, points);
    }

    function _isSBT(bytes memory fnMap)
        internal
        pure
        returns (bool isOk, uint256[] memory points)
    {

        uint256[] memory zippedLines = decodePolyline(fnMap);
        if (zippedLines.length != 2) {
            return (false, points);
        }
        LineSegment memory secondLine = unzipLineSegment(zippedLines[1]);

        if (
            secondLine.left.x != 0 &&
            secondLine.left.y == secondLine.left.x &&
            secondLine.right.x > secondLine.left.x &&
            secondLine.right.y == secondLine.left.y
        ) {
            uint256[] memory _lines = new uint256[](1);
            _lines[0] = secondLine.left.x;
            return (true, _lines);
        }

        return (false, points);
    }
}