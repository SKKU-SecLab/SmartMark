

pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;


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


pragma solidity 0.6.6;





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


pragma solidity 0.6.6;

enum BondType {NONE, PURE_SBT, SBT_SHAPE, LBT_SHAPE, TRIANGLE}


pragma solidity 0.6.6;




contract DetectBondShape is UseSafeMath {

    function getBondType(bytes memory fnMap, BondType submittedType)
        public
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

    function unzipLineSegment(uint256 zip) internal pure returns (uint64[4] memory) {

        uint64 x1 = uint64(zip >> (64 + 64 + 64));
        uint64 y1 = uint64(zip >> (64 + 64));
        uint64 x2 = uint64(zip >> 64);
        uint64 y2 = uint64(zip);
        return [x1, y1, x2, y2];
    }

    function decodePolyline(bytes memory fnMap) internal pure returns (uint256[] memory) {

        return abi.decode(fnMap, (uint256[]));
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
        uint64[4] memory secondLine = unzipLineSegment(zippedLines[1]);
        if (
            secondLine[0] != 0 &&
            secondLine[1] == 0 &&
            secondLine[2] > secondLine[0] &&
            secondLine[3] != 0
        ) {
            uint256[] memory _lines = new uint256[](3);
            _lines[0] = secondLine[0];
            _lines[1] = secondLine[2];
            _lines[2] = secondLine[3];
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
        uint64[4] memory secondLine = unzipLineSegment(zippedLines[1]);
        uint64[4] memory thirdLine = unzipLineSegment(zippedLines[2]);
        uint64[4] memory forthLine = unzipLineSegment(zippedLines[3]);
        if (
            secondLine[0] != 0 &&
            secondLine[1] == 0 &&
            secondLine[2] > secondLine[0] &&
            secondLine[3] != 0 &&
            thirdLine[2] > secondLine[2] &&
            thirdLine[3] == 0 &&
            forthLine[2] > thirdLine[2] &&
            forthLine[3] == 0
        ) {
            uint256[] memory _lines = new uint256[](4);
            _lines[0] = secondLine[0];
            _lines[1] = secondLine[2];
            _lines[2] = secondLine[3];
            _lines[3] = thirdLine[2];
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
        uint64[4] memory secondLine = unzipLineSegment(zippedLines[1]);
        uint64[4] memory thirdLine = unzipLineSegment(zippedLines[2]);
        if (
            secondLine[0] != 0 &&
            secondLine[1] == 0 &&
            secondLine[2] > secondLine[0] &&
            secondLine[3] != 0 &&
            thirdLine[2] > secondLine[2] &&
            thirdLine[3] == secondLine[3]
        ) {
            uint256[] memory _lines = new uint256[](3);
            _lines[0] = secondLine[0];
            _lines[1] = secondLine[2];
            _lines[2] = secondLine[3];
            return (true, _lines);
        }
        return (false, points);
    }

    function _isSBT(bytes memory fnMap) internal pure returns (bool isOk, uint256[] memory points) {

        uint256[] memory zippedLines = decodePolyline(fnMap);
        if (zippedLines.length != 2) {
            return (false, points);
        }
        uint64[4] memory secondLine = unzipLineSegment(zippedLines[1]);

        if (
            secondLine[0] != 0 &&
            secondLine[1] == secondLine[0] &&
            secondLine[2] > secondLine[0] &&
            secondLine[3] == secondLine[1]
        ) {
            uint256[] memory _lines = new uint256[](1);
            _lines[0] = secondLine[0];
            return (true, _lines);
        }

        return (false, points);
    }
}