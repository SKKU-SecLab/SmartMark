


pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.7.0;

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




pragma solidity ^0.7.0;

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




pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




pragma solidity ^0.7.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.7.0;

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




pragma solidity ^0.7.0;


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

    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}



pragma solidity 0.7.1;





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



pragma solidity 0.7.1;

interface LatestPriceOracleInterface {
    function isWorking() external returns (bool);

    function latestPrice() external returns (uint256);

    function latestTimestamp() external returns (uint256);
}



pragma solidity 0.7.1;


interface PriceOracleInterface is LatestPriceOracleInterface {
    function latestId() external returns (uint256);

    function getPrice(uint256 id) external returns (uint256);

    function getTimestamp(uint256 id) external returns (uint256);
}



pragma solidity 0.7.1;


interface OracleInterface is PriceOracleInterface {
    function getVolatility() external returns (uint256);

    function lastCalculatedVolatility() external view returns (uint256);
}



pragma solidity 0.7.1;

interface VolatilityOracleInterface {
    function getVolatility(uint64 untilMaturity) external view returns (uint64 volatilityE8);
}



pragma solidity 0.7.1;

interface TransferETHInterface {
    receive() external payable;

    event LogTransferETH(address indexed from, address indexed to, uint256 value);
}



pragma solidity 0.7.1;



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



pragma solidity 0.7.1;



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

    event LogIssueNewBonds(uint256 indexed bondGroupID, address indexed issuer, uint256 amount);

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

    event LogLiquidateBond(bytes32 indexed bondID, uint128 rateNumerator, uint128 rateDenominator);

    function registerNewBond(uint256 maturity, bytes calldata fnMap)
        external
        returns (
            bytes32 bondID,
            address bondTokenAddress,
            bytes32 fnMapID
        );

    function registerNewBondGroup(bytes32[] calldata bondIDList, uint256 maturity)
        external
        returns (uint256 bondGroupID);

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

    function getFnMap(bytes32 fnMapID) external view returns (bytes memory fnMap);

    function getBondGroup(uint256 bondGroupID)
        external
        view
        returns (bytes32[] memory bondIDs, uint256 maturity);

    function generateFnMapID(bytes calldata fnMap) external view returns (bytes32 fnMapID);

    function generateBondID(uint256 maturity, bytes calldata fnMap)
        external
        view
        returns (bytes32 bondID);
}



pragma solidity 0.7.1;

enum BondType {NONE, PURE_SBT, SBT_SHAPE, LBT_SHAPE, TRIANGLE}



pragma solidity 0.7.1;


interface BondPricerInterface {
    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] calldata points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) external view returns (uint256 price, uint256 leverageE8);
}



pragma solidity 0.7.1;

contract Polyline {
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
        int256 gradientNumerator = int256(leftSegment.right.y) - int256(leftSegment.left.y); // mutable
        int256 gradientDenominator = int256(leftSegment.right.x) - int256(leftSegment.left.x); // mutable

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

    function zipLineSegment(LineSegment memory segment) internal pure returns (uint256 zip) {
        uint256 x1U256 = uint256(segment.left.x) << (64 + 64 + 64); // uint64
        uint256 y1U256 = uint256(segment.left.y) << (64 + 64); // uint64
        uint256 x2U256 = uint256(segment.right.x) << 64; // uint64
        uint256 y2U256 = uint256(segment.right.y); // uint64
        zip = x1U256 | y1U256 | x2U256 | y2U256;
    }

    function unzipLineSegment(uint256 zip) internal pure returns (LineSegment memory) {
        uint64 x1 = uint64(zip >> (64 + 64 + 64));
        uint64 y1 = uint64(zip >> (64 + 64));
        uint64 x2 = uint64(zip >> 64);
        uint64 y2 = uint64(zip);
        return LineSegment({left: Point({x: x1, y: y1}), right: Point({x: x2, y: y2})});
    }

    function decodePolyline(bytes memory fnMap) internal pure returns (uint256[] memory) {
        return abi.decode(fnMap, (uint256[]));
    }
}



pragma solidity 0.7.1;




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

    function _isSBT(bytes memory fnMap) internal pure returns (bool isOk, uint256[] memory points) {
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



pragma solidity 0.7.1;

abstract contract Time {
    function _getBlockTimestampSec() internal view returns (uint256 unixtimesec) {
        unixtimesec = block.timestamp; // solhint-disable-line not-rely-on-time
    }
}



pragma solidity 0.7.1;










abstract contract BondExchange is Time {
    using SafeMath for uint256;
    using SafeCast for uint256;

    uint256 internal constant MIN_EXCHANGE_RATE_E8 = 0.000001 * 10**8;
    uint256 internal constant MAX_EXCHANGE_RATE_E8 = 1000000 * 10**8;

    int256 internal constant MAX_SPREAD_E8 = 10**8; // 100%

    uint8 internal constant DECIMALS_OF_BOND = 8;

    uint8 internal constant DECIMALS_OF_ORACLE_PRICE = 8;

    BondMakerInterface internal immutable _bondMakerContract;
    PriceOracleInterface internal immutable _priceOracleContract;
    VolatilityOracleInterface internal immutable _volatilityOracleContract;
    LatestPriceOracleInterface internal immutable _volumeCalculator;
    DetectBondShape internal immutable _bondShapeDetector;

    constructor(
        BondMakerInterface bondMakerAddress,
        VolatilityOracleInterface volatilityOracleAddress,
        LatestPriceOracleInterface volumeCalculatorAddress,
        DetectBondShape bondShapeDetector
    ) {
        _assertBondMakerDecimals(bondMakerAddress);
        _bondMakerContract = bondMakerAddress;
        _priceOracleContract = bondMakerAddress.oracleAddress();
        _volatilityOracleContract = VolatilityOracleInterface(volatilityOracleAddress);
        _volumeCalculator = volumeCalculatorAddress;
        _bondShapeDetector = bondShapeDetector;
    }

    function bondMakerAddress() external view returns (BondMakerInterface) {
        return _bondMakerContract;
    }

    function volumeCalculatorAddress() external view returns (LatestPriceOracleInterface) {
        return _volumeCalculator;
    }

    function _getLatestPrice(LatestPriceOracleInterface oracle) internal returns (uint256 priceE8) {
        return oracle.latestPrice();
    }

    function _getVolatility(VolatilityOracleInterface oracle, uint64 untilMaturity)
        internal
        view
        returns (uint256 volatilityE8)
    {
        return oracle.getVolatility(untilMaturity);
    }

    function _getBond(BondMakerInterface bondMaker, bytes32 bondID)
        internal
        view
        returns (
            ERC20 bondToken,
            uint256 maturity,
            uint256 sbtStrikePrice,
            bytes32 fnMapID
        )
    {
        address bondTokenAddress;
        (bondTokenAddress, maturity, sbtStrikePrice, fnMapID) = bondMaker.getBond(bondID);

        bondToken = ERC20(bondTokenAddress);
    }

    function _applyDecimalGap(
        uint256 baseAmount,
        uint8 decimalsOfBase,
        uint8 decimalsOfQuote
    ) internal pure returns (uint256 quoteAmount) {
        uint256 n;
        uint256 d;

        if (decimalsOfBase > decimalsOfQuote) {
            d = decimalsOfBase - decimalsOfQuote;
        } else if (decimalsOfBase < decimalsOfQuote) {
            n = decimalsOfQuote - decimalsOfBase;
        }

        require(n < 19 && d < 19, "decimal gap needs to be lower than 19");
        return baseAmount.mul(10**n).div(10**d);
    }

    function _calcBondPriceAndSpread(
        BondPricerInterface bondPricer,
        bytes32 bondID,
        int16 feeBaseE4
    ) internal returns (uint256 bondPriceE8, int256 spreadE8) {
        (, uint256 maturity, , ) = _getBond(_bondMakerContract, bondID);
        (bool isKnownBondType, BondType bondType, uint256[] memory points) = _bondShapeDetector
            .getBondTypeByID(_bondMakerContract, bondID, BondType.NONE);
        require(isKnownBondType, "cannot calculate the price of this bond");

        uint256 untilMaturity = maturity.sub(
            _getBlockTimestampSec(),
            "the bond should not have expired"
        );
        uint256 oraclePriceE8 = _getLatestPrice(_priceOracleContract);
        uint256 oracleVolatilityE8 = _getVolatility(
            _volatilityOracleContract,
            untilMaturity.toUint64()
        );

        uint256 leverageE8;
        (bondPriceE8, leverageE8) = bondPricer.calcPriceAndLeverage(
            bondType,
            points,
            oraclePriceE8.toInt256(),
            oracleVolatilityE8.toInt256(),
            untilMaturity.toInt256()
        );
        spreadE8 = _calcSpread(oracleVolatilityE8, leverageE8, feeBaseE4);
    }

    function _calcSpread(
        uint256 oracleVolatilityE8,
        uint256 leverageE8,
        int16 feeBaseE4
    ) internal pure returns (int256 spreadE8) {
        uint256 volE8 = oracleVolatilityE8 < 10**8 ? 10**8 : oracleVolatilityE8 > 2 * 10**8
            ? 2 * 10**8
            : oracleVolatilityE8;
        uint256 volTimesLevE16 = volE8 * leverageE8;
        spreadE8 =
            (feeBaseE4 *
                (feeBaseE4 < 0 || volTimesLevE16 < 10**16 ? 10**16 : volTimesLevE16).toInt256()) /
            10**12;
        spreadE8 = spreadE8 > MAX_SPREAD_E8 ? MAX_SPREAD_E8 : spreadE8;
    }

    function _calcUsdPrice(uint256 amount) internal returns (uint256) {
        return amount.mul(_getLatestPrice(_volumeCalculator)) / 10**8;
    }

    function _assertBondMakerDecimals(BondMakerInterface bondMaker) internal view {
        require(
            bondMaker.decimalsOfOraclePrice() == DECIMALS_OF_ORACLE_PRICE,
            "the decimals of oracle price must be 8"
        );
        require(
            bondMaker.decimalsOfBond() == DECIMALS_OF_BOND,
            "the decimals of bond token must be 8"
        );
    }

    function _assertExpectedPriceRange(
        uint256 actualAmount,
        uint256 expectedAmount,
        uint256 range
    ) internal pure {
        if (expectedAmount != 0) {
            require(
                actualAmount.mul(1000 + range).div(1000) >= expectedAmount,
                "out of expected price range"
            );
        }
    }
}




pragma solidity ^0.7.0;




library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity 0.7.1;



abstract contract BondVsErc20Exchange is BondExchange {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    struct VsErc20Pool {
        address seller;
        ERC20 swapPairToken;
        LatestPriceOracleInterface swapPairOracle;
        BondPricerInterface bondPricer;
        int16 feeBaseE4;
        bool isBondSale;
    }
    mapping(bytes32 => VsErc20Pool) internal _vsErc20Pool;

    event LogCreateErc20ToBondPool(
        bytes32 indexed poolID,
        address indexed seller,
        address indexed swapPairAddress
    );

    event LogCreateBondToErc20Pool(
        bytes32 indexed poolID,
        address indexed seller,
        address indexed swapPairAddress
    );

    event LogUpdateVsErc20Pool(
        bytes32 indexed poolID,
        address swapPairOracleAddress,
        address bondPricerAddress,
        int16 feeBase // decimal: 4
    );

    event LogDeleteVsErc20Pool(bytes32 indexed poolID);

    event LogExchangeErc20ToBond(
        address indexed buyer,
        bytes32 indexed bondID,
        bytes32 indexed poolID,
        uint256 bondAmount, // decimal: 8
        uint256 swapPairAmount, // decimal: ERC20.decimals()
        uint256 volume // USD, decimal: 8
    );

    event LogExchangeBondToErc20(
        address indexed buyer,
        bytes32 indexed bondID,
        bytes32 indexed poolID,
        uint256 bondAmount, // decimal: 8
        uint256 swapPairAmount, // decimal: ERC20.decimals()
        uint256 volume // USD, decimal: 8
    );

    modifier isExsistentVsErc20Pool(bytes32 poolID) {
        require(_vsErc20Pool[poolID].seller != address(0), "the exchange pair does not exist");
        _;
    }

    function exchangeErc20ToBond(
        bytes32 bondID,
        bytes32 poolID,
        uint256 swapPairAmount,
        uint256 expectedAmount,
        uint256 range
    ) external returns (uint256 bondAmount) {
        bondAmount = _exchangeErc20ToBond(msg.sender, bondID, poolID, swapPairAmount);
        _assertExpectedPriceRange(bondAmount, expectedAmount, range);
    }

    function exchangeBondToErc20(
        bytes32 bondID,
        bytes32 poolID,
        uint256 bondAmount,
        uint256 expectedAmount,
        uint256 range
    ) external returns (uint256 swapPairAmount) {
        swapPairAmount = _exchangeBondToErc20(msg.sender, bondID, poolID, bondAmount);
        _assertExpectedPriceRange(swapPairAmount, expectedAmount, range);
    }

    function calcRateBondToErc20(bytes32 bondID, bytes32 poolID) external returns (uint256 rateE8) {
        (rateE8, , , ) = _calcRateBondToErc20(bondID, poolID);
    }

    function generateVsErc20PoolID(
        address seller,
        address swapPairAddress,
        bool isBondSale
    ) external view returns (bytes32 poolID) {
        return _generateVsErc20PoolID(seller, swapPairAddress, isBondSale);
    }

    function createVsErc20Pool(
        ERC20 swapPairAddress,
        LatestPriceOracleInterface swapPairOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4,
        bool isBondSale
    ) external returns (bytes32 poolID) {
        return
            _createVsErc20Pool(
                msg.sender,
                swapPairAddress,
                swapPairOracleAddress,
                bondPricerAddress,
                feeBaseE4,
                isBondSale
            );
    }

    function updateVsErc20Pool(
        bytes32 poolID,
        LatestPriceOracleInterface swapPairOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external {
        require(_vsErc20Pool[poolID].seller == msg.sender, "not the owner of the pool ID");

        _updateVsErc20Pool(poolID, swapPairOracleAddress, bondPricerAddress, feeBaseE4);
    }

    function deleteVsErc20Pool(bytes32 poolID) external {
        require(_vsErc20Pool[poolID].seller == msg.sender, "not the owner of the pool ID");

        _deleteVsErc20Pool(poolID);
    }

    function getVsErc20Pool(bytes32 poolID)
        external
        view
        returns (
            address seller,
            ERC20 swapPairAddress,
            LatestPriceOracleInterface swapPairOracleAddress,
            BondPricerInterface bondPricerAddress,
            int16 feeBaseE4,
            bool isBondSale
        )
    {
        return _getVsErc20Pool(poolID);
    }

    function _exchangeErc20ToBond(
        address buyer,
        bytes32 bondID,
        bytes32 poolID,
        uint256 swapPairAmount
    ) internal returns (uint256 bondAmount) {
        (address seller, ERC20 swapPairToken, , , , bool isBondSale) = _getVsErc20Pool(poolID);
        require(isBondSale, "This pool is for buying bond");

        (ERC20 bondToken, , , ) = _getBond(_bondMakerContract, bondID);
        require(address(bondToken) != address(0), "the bond is not registered");

        uint256 volumeE8;
        {
            (uint256 rateE8, , uint256 swapPairPriceE8, ) = _calcRateBondToErc20(bondID, poolID);
            require(rateE8 > MIN_EXCHANGE_RATE_E8, "exchange rate is too small");
            require(rateE8 < MAX_EXCHANGE_RATE_E8, "exchange rate is too large");
            uint8 decimalsOfSwapPair = swapPairToken.decimals();
            bondAmount =
                _applyDecimalGap(swapPairAmount, decimalsOfSwapPair, DECIMALS_OF_BOND + 8) /
                rateE8;
            require(bondAmount != 0, "must transfer non-zero bond amount");
            volumeE8 = swapPairPriceE8.mul(swapPairAmount).div(10**uint256(decimalsOfSwapPair));
        }

        require(bondToken.transferFrom(seller, buyer, bondAmount), "fail to transfer bonds");
        swapPairToken.safeTransferFrom(buyer, seller, swapPairAmount);

        emit LogExchangeErc20ToBond(buyer, bondID, poolID, bondAmount, swapPairAmount, volumeE8);
    }

    function _exchangeBondToErc20(
        address buyer,
        bytes32 bondID,
        bytes32 poolID,
        uint256 bondAmount
    ) internal returns (uint256 swapPairAmount) {
        (address seller, ERC20 swapPairToken, , , , bool isBondSale) = _getVsErc20Pool(poolID);
        require(!isBondSale, "This pool is not for buying bond");

        (ERC20 bondToken, , , ) = _getBond(_bondMakerContract, bondID);
        require(address(bondToken) != address(0), "the bond is not registered");

        uint256 volumeE8;
        {
            (uint256 rateE8, uint256 bondPriceE8, , ) = _calcRateBondToErc20(bondID, poolID);
            require(rateE8 > MIN_EXCHANGE_RATE_E8, "exchange rate is too small");
            require(rateE8 < MAX_EXCHANGE_RATE_E8, "exchange rate is too large");
            uint8 decimalsOfSwapPair = swapPairToken.decimals();
            swapPairAmount = _applyDecimalGap(
                bondAmount.mul(rateE8),
                DECIMALS_OF_BOND + 8,
                decimalsOfSwapPair
            );
            require(swapPairAmount != 0, "must transfer non-zero token amount");
            volumeE8 = bondPriceE8.mul(bondAmount).div(10**uint256(DECIMALS_OF_BOND));
        }

        require(bondToken.transferFrom(buyer, seller, bondAmount), "fail to transfer bonds");
        swapPairToken.safeTransferFrom(seller, buyer, swapPairAmount);

        emit LogExchangeBondToErc20(buyer, bondID, poolID, bondAmount, swapPairAmount, volumeE8);
    }

    function _calcRateBondToErc20(bytes32 bondID, bytes32 poolID)
        internal
        returns (
            uint256 rateE8,
            uint256 bondPriceE8,
            uint256 swapPairPriceE8,
            int256 spreadE8
        )
    {
        (
            ,
            ,
            LatestPriceOracleInterface erc20Oracle,
            BondPricerInterface bondPricer,
            int16 feeBaseE4,
            bool isBondSale
        ) = _getVsErc20Pool(poolID);
        swapPairPriceE8 = _getLatestPrice(erc20Oracle);
        (bondPriceE8, spreadE8) = _calcBondPriceAndSpread(bondPricer, bondID, feeBaseE4);
        bondPriceE8 = _calcUsdPrice(bondPriceE8);
        rateE8 = bondPriceE8.mul(10**8).div(swapPairPriceE8, "ERC20 oracle price must be non-zero");

        if (isBondSale) {
            rateE8 = rateE8.mul(uint256(10**8 + spreadE8)) / 10**8;
        } else {
            rateE8 = rateE8.mul(10**8) / uint256(10**8 + spreadE8);
        }
    }

    function _generateVsErc20PoolID(
        address seller,
        address swapPairAddress,
        bool isBondSale
    ) internal view returns (bytes32 poolID) {
        return
            keccak256(
                abi.encode(
                    "Bond vs ERC20 exchange",
                    address(this),
                    seller,
                    swapPairAddress,
                    isBondSale
                )
            );
    }

    function _setVsErc20Pool(
        bytes32 poolID,
        address seller,
        ERC20 swapPairToken,
        LatestPriceOracleInterface swapPairOracle,
        BondPricerInterface bondPricer,
        int16 feeBaseE4,
        bool isBondSale
    ) internal {
        require(seller != address(0), "the pool ID already exists");
        require(address(swapPairToken) != address(0), "swapPairToken should be non-zero address");
        require(address(swapPairOracle) != address(0), "swapPairOracle should be non-zero address");
        require(address(bondPricer) != address(0), "bondPricer should be non-zero address");
        _vsErc20Pool[poolID] = VsErc20Pool({
            seller: seller,
            swapPairToken: swapPairToken,
            swapPairOracle: swapPairOracle,
            bondPricer: bondPricer,
            feeBaseE4: feeBaseE4,
            isBondSale: isBondSale
        });
    }

    function _createVsErc20Pool(
        address seller,
        ERC20 swapPairToken,
        LatestPriceOracleInterface swapPairOracle,
        BondPricerInterface bondPricer,
        int16 feeBaseE4,
        bool isBondSale
    ) internal returns (bytes32 poolID) {
        poolID = _generateVsErc20PoolID(seller, address(swapPairToken), isBondSale);
        require(_vsErc20Pool[poolID].seller == address(0), "the pool ID already exists");

        {
            uint256 price = _getLatestPrice(swapPairOracle);
            require(
                price != 0,
                "swapPairOracle has latestPrice() function which returns non-zero value"
            );
        }

        _setVsErc20Pool(
            poolID,
            seller,
            swapPairToken,
            swapPairOracle,
            bondPricer,
            feeBaseE4,
            isBondSale
        );

        if (isBondSale) {
            emit LogCreateErc20ToBondPool(poolID, seller, address(swapPairToken));
        } else {
            emit LogCreateBondToErc20Pool(poolID, seller, address(swapPairToken));
        }

        emit LogUpdateVsErc20Pool(poolID, address(swapPairOracle), address(bondPricer), feeBaseE4);
    }

    function _updateVsErc20Pool(
        bytes32 poolID,
        LatestPriceOracleInterface swapPairOracle,
        BondPricerInterface bondPricer,
        int16 feeBaseE4
    ) internal isExsistentVsErc20Pool(poolID) {
        (address seller, ERC20 swapPairToken, , , , bool isBondSale) = _getVsErc20Pool(poolID);
        _setVsErc20Pool(
            poolID,
            seller,
            swapPairToken,
            swapPairOracle,
            bondPricer,
            feeBaseE4,
            isBondSale
        );

        emit LogUpdateVsErc20Pool(poolID, address(swapPairOracle), address(bondPricer), feeBaseE4);
    }

    function _deleteVsErc20Pool(bytes32 poolID) internal isExsistentVsErc20Pool(poolID) {
        delete _vsErc20Pool[poolID];

        emit LogDeleteVsErc20Pool(poolID);
    }

    function _getVsErc20Pool(bytes32 poolID)
        internal
        view
        isExsistentVsErc20Pool(poolID)
        returns (
            address seller,
            ERC20 swapPairToken,
            LatestPriceOracleInterface swapPairOracle,
            BondPricerInterface bondPricer,
            int16 feeBaseE4,
            bool isBondSale
        )
    {
        VsErc20Pool memory exchangePair = _vsErc20Pool[poolID];
        seller = exchangePair.seller;
        swapPairToken = exchangePair.swapPairToken;
        swapPairOracle = exchangePair.swapPairOracle;
        bondPricer = exchangePair.bondPricer;
        feeBaseE4 = exchangePair.feeBaseE4;
        isBondSale = exchangePair.isBondSale;
    }
}



pragma solidity 0.7.1;


abstract contract TransferETH is TransferETHInterface {
    receive() external payable override {
        emit LogTransferETH(msg.sender, address(this), msg.value);
    }

    function _hasSufficientBalance(uint256 amount) internal view returns (bool ok) {
        address thisContract = address(this);
        return amount <= thisContract.balance;
    }

    function _transferETH(
        address payable recipient,
        uint256 amount,
        string memory errorMessage
    ) internal {
        require(_hasSufficientBalance(amount), errorMessage);
        (bool success, ) = recipient.call{value: amount}(""); // solhint-disable-line avoid-low-level-calls
        require(success, "transferring Ether failed");
        emit LogTransferETH(address(this), recipient, amount);
    }

    function _transferETH(address payable recipient, uint256 amount) internal {
        _transferETH(recipient, amount, "TransferETH: transfer amount exceeds balance");
    }
}



pragma solidity 0.7.1;



abstract contract BondVsEthExchange is BondExchange, TransferETH {
    using SafeMath for uint256;

    uint8 internal constant DECIMALS_OF_ETH = 18;

    struct VsEthPool {
        address seller;
        LatestPriceOracleInterface ethOracle;
        BondPricerInterface bondPricer;
        int16 feeBaseE4;
        bool isBondSale;
    }
    mapping(bytes32 => VsEthPool) internal _vsEthPool;

    mapping(address => uint256) internal _depositedEth;

    event LogCreateEthToBondPool(bytes32 indexed poolID, address indexed seller);

    event LogCreateBondToEthPool(bytes32 indexed poolID, address indexed seller);

    event LogUpdateVsEthPool(
        bytes32 indexed poolID,
        address ethOracleAddress,
        address bondPricerAddress,
        int16 feeBase // decimal: 4
    );

    event LogDeleteVsEthPool(bytes32 indexed poolID);

    event LogExchangeEthToBond(
        address indexed buyer,
        bytes32 indexed bondID,
        bytes32 indexed poolID,
        uint256 bondAmount, // decimal: 8
        uint256 swapPairAmount, // decimal: 18
        uint256 volume // USD, decimal: 8
    );

    event LogExchangeBondToEth(
        address indexed buyer,
        bytes32 indexed bondID,
        bytes32 indexed poolID,
        uint256 bondAmount, // decimal: 8
        uint256 swapPairAmount, // decimal: 18
        uint256 volume // USD, decimal: 8
    );

    modifier isExsistentVsEthPool(bytes32 poolID) {
        require(_vsEthPool[poolID].seller != address(0), "the exchange pair does not exist");
        _;
    }

    function exchangeEthToBond(
        bytes32 bondID,
        bytes32 poolID,
        uint256 ethAmount,
        uint256 expectedAmount,
        uint256 range
    ) external returns (uint256 bondAmount) {
        bondAmount = _exchangeEthToBond(msg.sender, bondID, poolID, ethAmount);
        _assertExpectedPriceRange(bondAmount, expectedAmount, range);
    }

    function exchangeBondToEth(
        bytes32 bondID,
        bytes32 poolID,
        uint256 bondAmount,
        uint256 expectedAmount,
        uint256 range
    ) external returns (uint256 ethAmount) {
        ethAmount = _exchangeBondToEth(msg.sender, bondID, poolID, bondAmount);
        _assertExpectedPriceRange(ethAmount, expectedAmount, range);
    }

    function calcRateBondToEth(bytes32 bondID, bytes32 poolID) external returns (uint256 rateE8) {
        (rateE8, , , ) = _calcRateBondToEth(bondID, poolID);
    }

    function generateVsEthPoolID(address seller, bool isBondSale)
        external
        view
        returns (bytes32 poolID)
    {
        return _generateVsEthPoolID(seller, isBondSale);
    }

    function createVsEthPool(
        LatestPriceOracleInterface ethOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4,
        bool isBondSale
    ) external returns (bytes32 poolID) {
        return
            _createVsEthPool(
                msg.sender,
                ethOracleAddress,
                bondPricerAddress,
                feeBaseE4,
                isBondSale
            );
    }

    function updateVsEthPool(
        bytes32 poolID,
        LatestPriceOracleInterface ethOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external {
        require(_vsEthPool[poolID].seller == msg.sender, "not the owner of the pool ID");

        _updateVsEthPool(poolID, ethOracleAddress, bondPricerAddress, feeBaseE4);
    }

    function deleteVsEthPool(bytes32 poolID) external {
        require(_vsEthPool[poolID].seller == msg.sender, "not the owner of the pool ID");

        _deleteVsEthPool(poolID);
    }

    function getVsEthPool(bytes32 poolID)
        external
        view
        returns (
            address seller,
            LatestPriceOracleInterface ethOracleAddress,
            BondPricerInterface bondPricerAddress,
            int16 feeBaseE4,
            bool isBondSale
        )
    {
        return _getVsEthPool(poolID);
    }

    function depositEth() external payable {
        _addEthAllowance(msg.sender, msg.value);
    }

    function withdrawEth() external returns (uint256 amount) {
        amount = _depositedEth[msg.sender];
        _transferEthFrom(msg.sender, msg.sender, amount);
    }

    function ethAllowance(address owner) external view returns (uint256 amount) {
        amount = _depositedEth[owner];
    }

    function _exchangeEthToBond(
        address buyer,
        bytes32 bondID,
        bytes32 poolID,
        uint256 swapPairAmount
    ) internal returns (uint256 bondAmount) {
        (address seller, , , , bool isBondSale) = _getVsEthPool(poolID);
        require(isBondSale, "This pool is for buying bond");

        (ERC20 bondToken, , , ) = _getBond(_bondMakerContract, bondID);
        require(address(bondToken) != address(0), "the bond is not registered");

        uint256 volumeE8;
        {
            (uint256 rateE8, , uint256 swapPairPriceE8, ) = _calcRateBondToEth(bondID, poolID);
            require(rateE8 > MIN_EXCHANGE_RATE_E8, "exchange rate is too small");
            require(rateE8 < MAX_EXCHANGE_RATE_E8, "exchange rate is too large");
            bondAmount =
                _applyDecimalGap(swapPairAmount, DECIMALS_OF_ETH, DECIMALS_OF_BOND + 8) /
                rateE8;
            require(bondAmount != 0, "must transfer non-zero bond amount");
            volumeE8 = swapPairPriceE8.mul(swapPairAmount).div(10**uint256(DECIMALS_OF_ETH));
        }

        require(bondToken.transferFrom(seller, buyer, bondAmount), "fail to transfer bonds");
        _transferEthFrom(buyer, seller, swapPairAmount);

        emit LogExchangeEthToBond(buyer, bondID, poolID, bondAmount, swapPairAmount, volumeE8);
    }

    function _exchangeBondToEth(
        address buyer,
        bytes32 bondID,
        bytes32 poolID,
        uint256 bondAmount
    ) internal returns (uint256 swapPairAmount) {
        (address seller, , , , bool isBondSale) = _getVsEthPool(poolID);
        require(!isBondSale, "This pool is not for buying bond");

        (ERC20 bondToken, , , ) = _getBond(_bondMakerContract, bondID);
        require(address(bondToken) != address(0), "the bond is not registered");

        uint256 volumeE8;
        {
            (uint256 rateE8, uint256 bondPriceE8, , ) = _calcRateBondToEth(bondID, poolID);
            require(rateE8 > MIN_EXCHANGE_RATE_E8, "exchange rate is too small");
            require(rateE8 < MAX_EXCHANGE_RATE_E8, "exchange rate is too large");
            swapPairAmount = _applyDecimalGap(
                bondAmount.mul(rateE8),
                DECIMALS_OF_BOND + 8,
                DECIMALS_OF_ETH
            );
            require(swapPairAmount != 0, "must transfer non-zero token amount");
            volumeE8 = bondPriceE8.mul(bondAmount).div(10**uint256(DECIMALS_OF_BOND));
        }

        require(bondToken.transferFrom(buyer, seller, bondAmount), "fail to transfer bonds");
        _transferEthFrom(seller, buyer, swapPairAmount);

        emit LogExchangeBondToEth(buyer, bondID, poolID, bondAmount, swapPairAmount, volumeE8);
    }

    function _calcRateBondToEth(bytes32 bondID, bytes32 poolID)
        internal
        returns (
            uint256 rateE8,
            uint256 bondPriceE8,
            uint256 swapPairPriceE8,
            int256 spreadE8
        )
    {
        (
            ,
            LatestPriceOracleInterface ethOracle,
            BondPricerInterface bondPricer,
            int16 feeBaseE4,
            bool isBondSale
        ) = _getVsEthPool(poolID);
        swapPairPriceE8 = _getLatestPrice(ethOracle);
        (bondPriceE8, spreadE8) = _calcBondPriceAndSpread(bondPricer, bondID, feeBaseE4);
        bondPriceE8 = _calcUsdPrice(bondPriceE8);
        rateE8 = bondPriceE8.mul(10**8).div(swapPairPriceE8, "ERC20 oracle price must be non-zero");

        if (isBondSale) {
            rateE8 = rateE8.mul(uint256(10**8 + spreadE8)) / 10**8;
        } else {
            rateE8 = rateE8.mul(uint256(10**8 - spreadE8)) / 10**8;
        }
    }

    function _generateVsEthPoolID(address seller, bool isBondSale)
        internal
        view
        returns (bytes32 poolID)
    {
        return keccak256(abi.encode("Bond vs ETH exchange", address(this), seller, isBondSale));
    }

    function _setVsEthPool(
        bytes32 poolID,
        address seller,
        LatestPriceOracleInterface ethOracle,
        BondPricerInterface bondPricer,
        int16 feeBaseE4,
        bool isBondSale
    ) internal {
        require(seller != address(0), "the pool ID already exists");
        require(address(ethOracle) != address(0), "ethOracle should be non-zero address");
        require(address(bondPricer) != address(0), "bondPricer should be non-zero address");
        _vsEthPool[poolID] = VsEthPool({
            seller: seller,
            ethOracle: ethOracle,
            bondPricer: bondPricer,
            feeBaseE4: feeBaseE4,
            isBondSale: isBondSale
        });
    }

    function _createVsEthPool(
        address seller,
        LatestPriceOracleInterface ethOracle,
        BondPricerInterface bondPricer,
        int16 feeBaseE4,
        bool isBondSale
    ) internal returns (bytes32 poolID) {
        poolID = _generateVsEthPoolID(seller, isBondSale);
        require(_vsEthPool[poolID].seller == address(0), "the pool ID already exists");

        {
            uint256 price = ethOracle.latestPrice();
            require(
                price != 0,
                "ethOracle has latestPrice() function which returns non-zero value"
            );
        }

        _setVsEthPool(poolID, seller, ethOracle, bondPricer, feeBaseE4, isBondSale);

        if (isBondSale) {
            emit LogCreateEthToBondPool(poolID, seller);
        } else {
            emit LogCreateBondToEthPool(poolID, seller);
        }

        emit LogUpdateVsEthPool(poolID, address(ethOracle), address(bondPricer), feeBaseE4);
    }

    function _updateVsEthPool(
        bytes32 poolID,
        LatestPriceOracleInterface ethOracle,
        BondPricerInterface bondPricer,
        int16 feeBaseE4
    ) internal isExsistentVsEthPool(poolID) {
        (address seller, , , , bool isBondSale) = _getVsEthPool(poolID);
        _setVsEthPool(poolID, seller, ethOracle, bondPricer, feeBaseE4, isBondSale);

        emit LogUpdateVsEthPool(poolID, address(ethOracle), address(bondPricer), feeBaseE4);
    }

    function _deleteVsEthPool(bytes32 poolID) internal isExsistentVsEthPool(poolID) {
        delete _vsEthPool[poolID];

        emit LogDeleteVsEthPool(poolID);
    }

    function _getVsEthPool(bytes32 poolID)
        internal
        view
        isExsistentVsEthPool(poolID)
        returns (
            address seller,
            LatestPriceOracleInterface ethOracle,
            BondPricerInterface bondPricer,
            int16 feeBaseE4,
            bool isBondSale
        )
    {
        VsEthPool memory exchangePair = _vsEthPool[poolID];
        seller = exchangePair.seller;
        ethOracle = exchangePair.ethOracle;
        bondPricer = exchangePair.bondPricer;
        feeBaseE4 = exchangePair.feeBaseE4;
        isBondSale = exchangePair.isBondSale;
    }

    function _transferEthFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _subEthAllowance(sender, amount);
        _transferETH(payable(recipient), amount);
    }

    function _addEthAllowance(address sender, uint256 amount) internal {
        _depositedEth[sender] += amount;
        require(_depositedEth[sender] >= amount, "overflow allowance");
    }

    function _subEthAllowance(address owner, uint256 amount) internal {
        require(_depositedEth[owner] >= amount, "insufficient allowance");
        _depositedEth[owner] -= amount;
    }
}



pragma solidity 0.7.1;


abstract contract BondVsBondExchange is BondExchange {
    using SafeMath for uint256;
    using SafeMathDivRoundUp for uint256;
    using SafeCast for uint256;

    uint8 internal constant DECIMALS_OF_BOND_VALUE = DECIMALS_OF_BOND + DECIMALS_OF_ORACLE_PRICE;

    struct VsBondPool {
        address seller;
        BondMakerInterface bondMakerForUser;
        VolatilityOracleInterface volatilityOracle;
        BondPricerInterface bondPricerForUser;
        BondPricerInterface bondPricer;
        int16 feeBaseE4;
    }
    mapping(bytes32 => VsBondPool) internal _vsBondPool;

    event LogCreateBondToBondPool(
        bytes32 indexed poolID,
        address indexed seller,
        address indexed bondMakerForUser
    );

    event LogUpdateVsBondPool(
        bytes32 indexed poolID,
        address bondPricerForUser,
        address bondPricer,
        int16 feeBase // decimal: 4
    );

    event LogDeleteVsBondPool(bytes32 indexed poolID);

    event LogExchangeBondToBond(
        address indexed buyer,
        bytes32 indexed bondID,
        bytes32 indexed poolID,
        uint256 bondAmount, // decimal: 8
        uint256 swapPairAmount, // USD, decimal: 8
        uint256 volume // USD, decimal: 8
    );

    modifier isExsistentVsBondPool(bytes32 poolID) {
        require(_vsBondPool[poolID].seller != address(0), "the exchange pair does not exist");
        _;
    }

    function exchangeBondToBond(
        bytes32 bondID,
        bytes32 poolID,
        bytes32[] calldata bondIDs,
        uint256 amountInDollarsE8,
        uint256 expectedAmount,
        uint256 range
    ) external returns (uint256 bondAmount) {
        uint256 amountInDollars = _applyDecimalGap(amountInDollarsE8, 8, DECIMALS_OF_BOND_VALUE);
        bondAmount = _exchangeBondToBond(msg.sender, bondID, poolID, bondIDs, amountInDollars);
        _assertExpectedPriceRange(bondAmount, expectedAmount, range);
    }

    function calcRateBondToUsd(bytes32 bondID, bytes32 poolID) external returns (uint256 rateE8) {
        (rateE8, , , ) = _calcRateBondToUsd(bondID, poolID);
    }

    function generateVsBondPoolID(address seller, address bondMakerForUser)
        external
        view
        returns (bytes32 poolID)
    {
        return _generateVsBondPoolID(seller, bondMakerForUser);
    }

    function createVsBondPool(
        BondMakerInterface bondMakerForUserAddress,
        VolatilityOracleInterface volatilityOracleAddress,
        BondPricerInterface bondPricerForUserAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external returns (bytes32 poolID) {
        return
            _createVsBondPool(
                msg.sender,
                bondMakerForUserAddress,
                volatilityOracleAddress,
                bondPricerForUserAddress,
                bondPricerAddress,
                feeBaseE4
            );
    }

    function updateVsBondPool(
        bytes32 poolID,
        VolatilityOracleInterface volatilityOracleAddress,
        BondPricerInterface bondPricerForUserAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external {
        require(_vsBondPool[poolID].seller == msg.sender, "not the owner of the pool ID");

        _updateVsBondPool(
            poolID,
            volatilityOracleAddress,
            bondPricerForUserAddress,
            bondPricerAddress,
            feeBaseE4
        );
    }

    function deleteVsBondPool(bytes32 poolID) external {
        require(_vsBondPool[poolID].seller == msg.sender, "not the owner of the pool ID");

        _deleteVsBondPool(poolID);
    }

    function getVsBondPool(bytes32 poolID)
        external
        view
        returns (
            address seller,
            BondMakerInterface bondMakerForUserAddress,
            VolatilityOracleInterface volatilityOracle,
            BondPricerInterface bondPricerForUserAddress,
            BondPricerInterface bondPricerAddress,
            int16 feeBaseE4,
            bool isBondSale
        )
    {
        return _getVsBondPool(poolID);
    }

    function totalBondAllowance(
        bytes32 poolID,
        bytes32[] calldata bondIDs,
        uint256 maturityBorder,
        address owner
    ) external returns (uint256 allowanceInDollarsE8) {
        (
            ,
            BondMakerInterface bondMakerForUser,
            VolatilityOracleInterface volatilityOracle,
            BondPricerInterface bondPricerForUser,
            ,
            ,

        ) = _getVsBondPool(poolID);
        uint256 allowanceInDollars = _totalBondAllowance(
            bondMakerForUser,
            volatilityOracle,
            bondPricerForUser,
            bondIDs,
            maturityBorder,
            owner
        );
        allowanceInDollarsE8 = _applyDecimalGap(allowanceInDollars, DECIMALS_OF_BOND_VALUE, 8);
    }

    function _exchangeBondToBond(
        address buyer,
        bytes32 bondID,
        bytes32 poolID,
        bytes32[] memory bondIDs,
        uint256 amountInDollars
    ) internal returns (uint256 bondAmount) {
        require(bondIDs.length != 0, "must input bonds for payment");

        BondMakerInterface bondMakerForUser;
        {
            bool isBondSale;
            (, bondMakerForUser, , , , , isBondSale) = _getVsBondPool(poolID);
            require(isBondSale, "This pool is for buying bond");
        }

        (ERC20 bondToken, uint256 maturity, , ) = _getBond(_bondMakerContract, bondID);
        require(address(bondToken) != address(0), "the bond is not registered");

        {
            (uint256 rateE8, , , ) = _calcRateBondToUsd(bondID, poolID);
            require(rateE8 > MIN_EXCHANGE_RATE_E8, "exchange rate is too small");
            require(rateE8 < MAX_EXCHANGE_RATE_E8, "exchange rate is too large");
            bondAmount =
                _applyDecimalGap(
                    amountInDollars,
                    DECIMALS_OF_BOND_VALUE,
                    bondToken.decimals() + 8
                ) /
                rateE8;
            require(bondAmount != 0, "must transfer non-zero bond amount");
        }

        {
            (
                address seller,
                ,
                VolatilityOracleInterface volatilityOracle,
                BondPricerInterface bondPricerForUser,
                ,
                ,

            ) = _getVsBondPool(poolID);
            require(bondToken.transferFrom(seller, buyer, bondAmount), "fail to transfer bonds");

            address buyerTmp = buyer; // avoid `stack too deep` error
            uint256 amountInDollarsTmp = amountInDollars; // avoid `stack too deep` error
            require(
                _batchTransferBondFrom(
                    bondMakerForUser,
                    volatilityOracle,
                    bondPricerForUser,
                    bondIDs,
                    maturity,
                    buyerTmp,
                    seller,
                    amountInDollarsTmp
                ),
                "fail to transfer ERC20 token"
            );
        }

        uint256 volumeE8 = _applyDecimalGap(amountInDollars, DECIMALS_OF_BOND_VALUE, 8);
        emit LogExchangeBondToBond(buyer, bondID, poolID, bondAmount, amountInDollars, volumeE8);
    }

    function _calcRateBondToUsd(bytes32 bondID, bytes32 poolID)
        internal
        returns (
            uint256 rateE8,
            uint256 bondPriceE8,
            uint256 swapPairPriceE8,
            int256 spreadE8
        )
    {
        (, , , , BondPricerInterface bondPricer, int16 feeBaseE4, ) = _getVsBondPool(poolID);
        (bondPriceE8, spreadE8) = _calcBondPriceAndSpread(bondPricer, bondID, feeBaseE4);
        bondPriceE8 = _calcUsdPrice(bondPriceE8);
        swapPairPriceE8 = 10**8;
        rateE8 = bondPriceE8.mul(uint256(10**8 + spreadE8)) / 10**8;
    }

    function _generateVsBondPoolID(address seller, address bondMakerForUser)
        internal
        view
        returns (bytes32 poolID)
    {
        return
            keccak256(abi.encode("Bond vs SBT exchange", address(this), seller, bondMakerForUser));
    }

    function _setVsBondPool(
        bytes32 poolID,
        address seller,
        BondMakerInterface bondMakerForUser,
        VolatilityOracleInterface volatilityOracle,
        BondPricerInterface bondPricerForUser,
        BondPricerInterface bondPricer,
        int16 feeBaseE4
    ) internal {
        require(seller != address(0), "the pool ID already exists");
        require(
            address(bondMakerForUser) != address(0),
            "bondMakerForUser should be non-zero address"
        );
        require(
            address(bondPricerForUser) != address(0),
            "bondPricerForUser should be non-zero address"
        );
        require(address(bondPricer) != address(0), "bondPricer should be non-zero address");
        _assertBondMakerDecimals(bondMakerForUser);
        _vsBondPool[poolID] = VsBondPool({
            seller: seller,
            bondMakerForUser: bondMakerForUser,
            volatilityOracle: volatilityOracle,
            bondPricerForUser: bondPricerForUser,
            bondPricer: bondPricer,
            feeBaseE4: feeBaseE4
        });
    }

    function _createVsBondPool(
        address seller,
        BondMakerInterface bondMakerForUser,
        VolatilityOracleInterface volatilityOracle,
        BondPricerInterface bondPricerForUser,
        BondPricerInterface bondPricer,
        int16 feeBaseE4
    ) internal returns (bytes32 poolID) {
        poolID = _generateVsBondPoolID(seller, address(bondMakerForUser));
        require(_vsBondPool[poolID].seller == address(0), "the pool ID already exists");

        _assertBondMakerDecimals(bondMakerForUser);
        _setVsBondPool(
            poolID,
            seller,
            bondMakerForUser,
            volatilityOracle,
            bondPricerForUser,
            bondPricer,
            feeBaseE4
        );

        emit LogCreateBondToBondPool(poolID, seller, address(bondMakerForUser));
        emit LogUpdateVsBondPool(
            poolID,
            address(bondPricerForUser),
            address(bondPricer),
            feeBaseE4
        );
    }

    function _updateVsBondPool(
        bytes32 poolID,
        VolatilityOracleInterface volatilityOracle,
        BondPricerInterface bondPricerForUser,
        BondPricerInterface bondPricer,
        int16 feeBaseE4
    ) internal isExsistentVsBondPool(poolID) {
        (address seller, BondMakerInterface bondMakerForUser, , , , , ) = _getVsBondPool(poolID);
        _setVsBondPool(
            poolID,
            seller,
            bondMakerForUser,
            volatilityOracle,
            bondPricerForUser,
            bondPricer,
            feeBaseE4
        );

        emit LogUpdateVsBondPool(
            poolID,
            address(bondPricerForUser),
            address(bondPricer),
            feeBaseE4
        );
    }

    function _deleteVsBondPool(bytes32 poolID) internal isExsistentVsBondPool(poolID) {
        delete _vsBondPool[poolID];

        emit LogDeleteVsBondPool(poolID);
    }

    function _getVsBondPool(bytes32 poolID)
        internal
        view
        isExsistentVsBondPool(poolID)
        returns (
            address seller,
            BondMakerInterface bondMakerForUser,
            VolatilityOracleInterface volatilityOracle,
            BondPricerInterface bondPricerForUser,
            BondPricerInterface bondPricer,
            int16 feeBaseE4,
            bool isBondSale
        )
    {
        VsBondPool memory exchangePair = _vsBondPool[poolID];
        seller = exchangePair.seller;
        bondMakerForUser = exchangePair.bondMakerForUser;
        volatilityOracle = exchangePair.volatilityOracle;
        bondPricerForUser = exchangePair.bondPricerForUser;
        bondPricer = exchangePair.bondPricer;
        feeBaseE4 = exchangePair.feeBaseE4;
        isBondSale = true;
    }

    function _batchTransferBondFrom(
        BondMakerInterface bondMaker,
        VolatilityOracleInterface volatilityOracle,
        BondPricerInterface bondPricer,
        bytes32[] memory bondIDs,
        uint256 maturityBorder,
        address sender,
        address recipient,
        uint256 amountInDollars
    ) internal returns (bool ok) {
        uint256 oraclePriceE8 = _getLatestPrice(bondMaker.oracleAddress());

        uint256 rest = amountInDollars; // mutable
        for (uint256 i = 0; i < bondIDs.length; i++) {
            ERC20 bond;
            uint256 oracleVolE8;
            {
                uint256 maturity;
                (bond, maturity, , ) = _getBond(bondMaker, bondIDs[i]);
                if (maturity > maturityBorder) continue; // skip transaction
                uint256 untilMaturity = maturity.sub(
                    _getBlockTimestampSec(),
                    "the bond should not have expired"
                );
                oracleVolE8 = _getVolatility(volatilityOracle, untilMaturity.toUint64());
            }

            uint256 allowance = bond.allowance(sender, address(this));
            if (allowance == 0) continue; // skip transaction

            BondMakerInterface bondMakerTmp = bondMaker; // avoid `stack too deep` error
            BondPricerInterface bondPricerTmp = bondPricer; // avoid `stack too deep` error
            bytes32 bondIDTmp = bondIDs[i]; // avoid `stack too deep` error
            uint256 bondPrice = _calcBondPrice(
                bondMakerTmp,
                bondPricerTmp,
                bondIDTmp,
                oraclePriceE8,
                oracleVolE8
            );
            if (bondPrice == 0) continue; // skip transaction

            if (rest <= allowance.mul(bondPrice)) {
                return bond.transferFrom(sender, recipient, rest.divRoundUp(bondPrice));
            }

            require(bond.transferFrom(sender, recipient, allowance), "fail to transfer bonds");
            rest -= allowance * bondPrice;
        }

        revert("insufficient bond allowance");
    }

    function _totalBondAllowance(
        BondMakerInterface bondMaker,
        VolatilityOracleInterface volatilityOracle,
        BondPricerInterface bondPricer,
        bytes32[] memory bondIDs,
        uint256 maturityBorder,
        address sender
    ) internal returns (uint256 allowanceInDollars) {
        uint256 oraclePriceE8 = _getLatestPrice(bondMaker.oracleAddress());

        for (uint256 i = 0; i < bondIDs.length; i++) {
            ERC20 bond;
            uint256 oracleVolE8;
            {
                uint256 maturity;
                (bond, maturity, , ) = _getBond(bondMaker, bondIDs[i]);
                if (maturity > maturityBorder) continue; // skip
                uint256 untilMaturity = maturity.sub(
                    _getBlockTimestampSec(),
                    "the bond should not have expired"
                );
                oracleVolE8 = _getVolatility(volatilityOracle, untilMaturity.toUint64());
            }

            uint256 balance = bond.balanceOf(sender);
            require(balance != 0, "includes no bond balance");

            uint256 allowance = bond.allowance(sender, address(this));
            require(allowance != 0, "includes no approved bond");

            uint256 bondPrice = _calcBondPrice(
                bondMaker,
                bondPricer,
                bondIDs[i],
                oraclePriceE8,
                oracleVolE8
            );
            require(bondPrice != 0, "includes worthless bond");

            allowanceInDollars = allowanceInDollars.add(allowance.mul(bondPrice));
        }
    }

    function _calcBondPrice(
        BondMakerInterface bondMaker,
        BondPricerInterface bondPricer,
        bytes32 bondID,
        uint256 oraclePriceE8,
        uint256 oracleVolatilityE8
    ) internal view returns (uint256) {
        int256 untilMaturity;
        {
            (, uint256 maturity, , ) = _getBond(bondMaker, bondID);
            untilMaturity = maturity
                .sub(_getBlockTimestampSec(), "the bond should not have expired")
                .toInt256();
        }

        BondType bondType;
        uint256[] memory points;
        {
            bool isKnownBondType;
            (isKnownBondType, bondType, points) = _bondShapeDetector.getBondTypeByID(
                bondMaker,
                bondID,
                BondType.NONE
            );
            if (!isKnownBondType) {
                revert("unknown bond type");
            }
        }

        try
            bondPricer.calcPriceAndLeverage(
                bondType,
                points,
                oraclePriceE8.toInt256(),
                oracleVolatilityE8.toInt256(),
                untilMaturity
            )
        returns (uint256 bondPriceE8, uint256) {
            return bondPriceE8;
        } catch {
            return 0;
        }
    }
}



pragma solidity 0.7.1;




contract GeneralizedDotc is BondVsBondExchange, BondVsErc20Exchange, BondVsEthExchange {
    constructor(
        BondMakerInterface bondMakerAddress,
        VolatilityOracleInterface volatilityOracleAddress,
        LatestPriceOracleInterface volumeCalculatorAddress,
        DetectBondShape bondShapeDetector
    )
        BondExchange(
            bondMakerAddress,
            volatilityOracleAddress,
            volumeCalculatorAddress,
            bondShapeDetector
        )
    {}
}