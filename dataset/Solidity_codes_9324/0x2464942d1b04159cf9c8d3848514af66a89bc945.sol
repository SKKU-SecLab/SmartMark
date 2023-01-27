

pragma solidity 0.7.1;

interface TransferETHInterface {

    receive() external payable;

    event LogTransferETH(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.7.0;

interface IERC20 {

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

interface SimpleStrategyInterface {

    function calcNextMaturity() external view returns (uint256 nextTimeStamp);


    function calcCallStrikePrice(
        uint256 currentPriceE8,
        uint64 priceUnit,
        bool isReversedOracle
    ) external pure returns (uint256 callStrikePrice);


    function calcRoundPrice(
        uint256 price,
        uint64 priceUnit,
        uint8 divisor
    ) external pure returns (uint256 roundedPrice);


    function getTrancheBonds(
        BondMakerInterface bondMaker,
        address aggregatorAddress,
        uint256 issueBondGroupIdOrStrikePrice,
        uint256 price,
        uint256[] calldata bondGroupList,
        uint64 priceUnit,
        bool isReversedOracle
    )
        external
        view
        returns (
            uint256 issueAmount,
            uint256 ethAmount,
            uint256[2] memory IDAndAmountOfBurn
        );


    function getCurrentStrikePrice(
        uint256 currentPriceE8,
        uint64 priceUnit,
        bool isReversedOracle
    ) external pure returns (uint256);


    function getCurrentSpread(
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) external view returns (int16);


    function registerCurrentFeeBase(
        int16 currentFeeBase,
        uint256 currentCollateralPerToken,
        uint256 nextCollateralPerToken,
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) external;

}


pragma solidity 0.7.1;

interface VolatilityOracleInterface {

    function getVolatility(uint64 untilMaturity) external view returns (uint64 volatilityE8);

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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_) {
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

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


pragma solidity 0.7.1;

interface ExchangeInterface {
    function changeSpread(int16 spread) external;

    function createVsBondPool(
        BondMakerInterface bondMakerForUserAddress,
        VolatilityOracleInterface volatilityOracleAddress,
        BondPricerInterface bondPricerForUserAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external returns (bytes32 poolID);

    function createVsErc20Pool(
        ERC20 swapPairAddress,
        LatestPriceOracleInterface swapPairOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4,
        bool isBondSale
    ) external returns (bytes32 poolID);

    function createVsEthPool(
        LatestPriceOracleInterface ethOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4,
        bool isBondSale
    ) external returns (bytes32 poolID);

    function updateVsBondPool(
        bytes32 poolID,
        VolatilityOracleInterface volatilityOracleAddress,
        BondPricerInterface bondPricerForUserAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external;

    function updateVsErc20Pool(
        bytes32 poolID,
        LatestPriceOracleInterface swapPairOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external;

    function updateVsEthPool(
        bytes32 poolID,
        LatestPriceOracleInterface ethOracleAddress,
        BondPricerInterface bondPricerAddress,
        int16 feeBaseE4
    ) external;

    function generateVsBondPoolID(address seller, address bondMakerForUser)
        external
        view
        returns (bytes32 poolID);

    function generateVsErc20PoolID(
        address seller,
        address swapPairAddress,
        bool isBondSale
    ) external view returns (bytes32 poolID);

    function generateVsEthPoolID(address seller, bool isBondSale)
        external
        view
        returns (bytes32 poolID);

    function withdrawEth() external;

    function depositEth() external payable;

    function ethAllowance(address owner) external view returns (uint256 amount);

    function bondMakerAddress() external view returns (BondMakerInterface);
}


pragma experimental ABIEncoderV2;
pragma solidity 0.7.1;

interface SimpleAggregatorInterface {
    struct TotalReward {
        uint64 term;
        uint64 value;
    }

    enum AggregatorPhase {BEFORE_START, ACTIVE, COOL_TIME, AFTER_MATURITY, EXPIRED}

    function renewMaturity() external;

    function removeLiquidity(uint128 amount) external returns (bool success);

    function settleTokens() external returns (uint256 unsentETH, uint256 unsentToken);

    function changeSpread() external;

    function liquidateBonds() external;

    function trancheBonds() external;

    function claimReward() external;

    function addSuitableBondGroup() external returns (uint256 bondGroupID);

    function getCollateralAddress() external view returns (address);

    function getCollateralAmount() external view returns (uint256);

    function getCollateralDecimal() external view returns (int16);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function getExpectedBalance(address user, bool hasReservation)
        external
        view
        returns (uint256 expectedBalance);

    function getCurrentPhase() external view returns (AggregatorPhase);

    function updateStartBondGroupId() external;

    function getInfo()
        external
        view
        returns (
            address bondMaker,
            address strategy,
            address dotc,
            address bondPricerAddress,
            address oracleAddress,
            address rewardTokenAddress,
            address registratorAddress,
            address owner,
            bool reverseOracle,
            uint64 basePriceUnit,
            uint128 maxSupply
        );

    function getCurrentStatus()
        external
        view
        returns (
            uint256 term,
            int16 feeBase,
            uint32 uncheckbondGroupId,
            uint64 unit,
            uint64 trancheTime,
            bool isDanger
        );

    function getTermInfo(uint256 term)
        external
        view
        returns (
            uint64 maturity,
            uint64 solidStrikePrice,
            bytes32 SBTID
        );

    function getBondGroupIDFromTermAndPrice(uint256 term, uint256 price)
        external
        view
        returns (uint256 bondGroupID);

    function getRewardAmount(address user) external view returns (uint64);

    function getTotalRewards() external view returns (TotalReward[] memory);

    function isTotalSupplySafe() external view returns (bool);

    function getTotalUnmovedAssets() external view returns (uint256, uint256);

    function totalShareData(uint256 term)
        external
        view
        returns (uint128 totalShare, uint128 totalCollateralPerToken);

    function getCollateralPerToken(uint256 term) external view returns (uint256);

    function getBondGroupIdFromStrikePrice(uint256 term, uint256 strikePrice)
        external
        view
        returns (uint256);

    function getBalanceData(address user)
        external
        view
        returns (
            uint128 amount,
            uint64 term,
            uint64 rewardAmount
        );

    function getIssuableBondGroups() external view returns (uint256[] memory);

    function getLiquidationData(uint256 term)
        external
        view
        returns (
            bool isLiquidated,
            uint32 liquidatedBondGroupID,
            uint32 endBondGroupId
        );
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


pragma solidity ^0.7.0;

library SafeCast {
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


pragma solidity 0.7.1;

contract StrategyForSimpleAggregator is SimpleStrategyInterface, Polyline {
    using SafeMath for uint256;
    using SafeCast for uint256;
    struct FeeInfo {
        int16 currentFeeBase;
        int32 upwardDifference;
        int32 downwardDifference;
    }
    uint256 constant WEEK_LENGTH = 3;
    mapping(bytes32 => address[]) public aggregators;
    mapping(bytes32 => FeeInfo) public feeBases;
    uint256 internal immutable TERM_INTERVAL;
    uint256 internal immutable TERM_CORRECTION_FACTOR;
    int16 constant INITIAL_FEEBASE = 250;

    constructor(uint256 termInterval, uint256 termCF) {
        TERM_INTERVAL = termInterval;
        TERM_CORRECTION_FACTOR = termCF;
    }

    function calcNextMaturity() public view override returns (uint256 nextTimeStamp) {
        uint256 week = (block.timestamp - TERM_CORRECTION_FACTOR).div(TERM_INTERVAL);
        nextTimeStamp = ((week + WEEK_LENGTH) * TERM_INTERVAL) + (TERM_CORRECTION_FACTOR);
    }

    function getTrancheBonds(
        BondMakerInterface bondMaker,
        address aggregatorAddress,
        uint256 issueBondGroupId,
        uint256 price,
        uint256[] calldata bondGroupList,
        uint64 priceUnit,
        bool isReversedOracle
    )
        public
        view
        virtual
        override
        returns (
            uint256 issueAmount,
            uint256,
            uint256[2] memory IDAndAmountOfBurn
        )
    {
        price = calcRoundPrice(price, priceUnit, 1);
        uint256 baseAmount = _getBaseAmount(SimpleAggregatorInterface(aggregatorAddress));
        for (uint64 i = 0; i < bondGroupList.length; i++) {
            (issueAmount, ) = _getLBTStrikePrice(bondMaker, bondGroupList[i], isReversedOracle);
            if ((issueAmount > price + priceUnit * 5 || issueAmount < price.sub(priceUnit * 5))) {
                uint256 balance = _getMinBondAmount(bondMaker, bondGroupList[i], aggregatorAddress);
                if (balance > baseAmount / 2 && balance > IDAndAmountOfBurn[1]) {
                    IDAndAmountOfBurn[0] = bondGroupList[i];
                    IDAndAmountOfBurn[1] = balance;
                }
            }
        }
        {
            uint256 balance = _getMinBondAmount(bondMaker, issueBondGroupId, aggregatorAddress);
            baseAmount = baseAmount + (IDAndAmountOfBurn[1] / 5);
            if (balance < baseAmount && issueBondGroupId != 0) {
                issueAmount = baseAmount - balance;
            } else {
                issueAmount = 0;
            }
        }
    }

    function registerCurrentFeeBase(
        int16 currentFeeBase,
        uint256 currentCollateralPerToken,
        uint256 nextCollateralPerToken,
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) public override {
        bytes32 aggregatorID = generateAggregatorID(owner, oracleAddress, isReversedOracle);
        int16 feeBase = _calcFeeBase(
            currentFeeBase,
            currentCollateralPerToken,
            nextCollateralPerToken,
            feeBases[aggregatorID].upwardDifference,
            feeBases[aggregatorID].downwardDifference
        );
        address[] memory aggregatorAddresses = aggregators[aggregatorID];
        require(_isValidAggregator(aggregatorAddresses), "sender is invalid aggregator");
        if (feeBase < INITIAL_FEEBASE) {
            feeBases[aggregatorID].currentFeeBase = INITIAL_FEEBASE;
        } else if (feeBase >= 1000) {
            feeBases[aggregatorID].currentFeeBase = 999;
        } else {
            feeBases[aggregatorID].currentFeeBase = feeBase;
        }
    }

    function _calcFeeBase(
        int16 currentFeeBase,
        uint256 currentCollateralPerToken,
        uint256 nextCollateralPerToken,
        int32 upwardDifference,
        int32 downwardDifference
    )
        internal
        pure
        returns (
            int16
        )
    {
        if (
            nextCollateralPerToken.mul(100).div(105) > currentCollateralPerToken &&
            currentFeeBase > downwardDifference
        ) {
            return int16(currentFeeBase - downwardDifference);
        } else if (nextCollateralPerToken.mul(105).div(100) < currentCollateralPerToken) {
            return int16(currentFeeBase + upwardDifference);
        }
        return currentFeeBase;
    }

    function _isValidAggregator(address[] memory aggregatorAddresses) internal view returns (bool) {
        for (uint256 i = 0; i < aggregatorAddresses.length; i++) {
            if (aggregatorAddresses[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function registerAggregators(
        address oracleAddress,
        bool isReversedOracle,
        address[] calldata aggregatorAddresses,
        int32 upwardDifference,
        int32 downwardDifference
    ) external {
        bytes32 aggregatorID = generateAggregatorID(msg.sender, oracleAddress, isReversedOracle);
        require(aggregators[aggregatorID].length == 0, "This aggregator ID is already registered");
        aggregators[aggregatorID] = aggregatorAddresses;
        feeBases[aggregatorID] = FeeInfo(INITIAL_FEEBASE, upwardDifference, downwardDifference);
    }

    function generateAggregatorID(
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(owner, oracleAddress, isReversedOracle));
    }

    function calcCallStrikePrice(
        uint256 currentPriceE8,
        uint64 priceUnit,
        bool isReversedOracle
    ) external pure override returns (uint256 callStrikePrice) {
        if (isReversedOracle) {
            callStrikePrice = _getReversedValue(
                calcRoundPrice(currentPriceE8, priceUnit, 1),
                isReversedOracle
            );
        } else {
            callStrikePrice = calcRoundPrice(currentPriceE8, priceUnit, 1);
        }
    }

    function getCurrentStrikePrice(
        uint256 currentPriceE8,
        uint64 priceUnit,
        bool isReversedOracle
    ) external pure override returns (uint256 strikePrice) {
        if (isReversedOracle) {
            strikePrice = _getReversedValue(
                calcRoundPrice(currentPriceE8 * 2, priceUnit, 1),
                isReversedOracle
            );
        } else {
            strikePrice = calcRoundPrice(currentPriceE8, priceUnit, 2);
        }
        return strikePrice;
    }

    function getCurrentSpread(
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) public view override returns (int16) {
        bytes32 aggregatorID = generateAggregatorID(owner, oracleAddress, isReversedOracle);
        if (feeBases[aggregatorID].currentFeeBase == 0) {
            return INITIAL_FEEBASE;
        }
        return feeBases[aggregatorID].currentFeeBase;
    }

    function _getReversedValue(uint256 value, bool isReversedOracle)
        internal
        pure
        returns (uint256)
    {
        if (!isReversedOracle) {
            return value;
        } else {
            return 10**16 / value;
        }
    }

    function _getBaseAmount(SimpleAggregatorInterface aggregator) internal view returns (uint256) {
        uint256 collateralAmount = aggregator.getCollateralAmount();
        int16 decimalGap = int16(aggregator.getCollateralDecimal()) - 8;
        return _applyDecimalGap(collateralAmount.div(5), decimalGap);
    }

    function _applyDecimalGap(uint256 amount, int16 decimalGap) internal pure returns (uint256) {
        if (decimalGap < 0) {
            return amount.mul(10**uint256(decimalGap * -1));
        } else {
            return amount / (10**uint256(decimalGap));
        }
    }

    function calcRoundPrice(
        uint256 price,
        uint64 priceUnit,
        uint8 divisor
    ) public pure override returns (uint256 roundedPrice) {
        roundedPrice = price.div(priceUnit * divisor).mul(priceUnit);
    }

    function getFeeInfo(
        address owner,
        address oracleAddress,
        bool isReversedOracle
    )
        public
        view
        returns (
            int16 currentFeeBase,
            int32 upwardDifference,
            int32 downwardDifference
        )
    {
        bytes32 aggregatorID = generateAggregatorID(owner, oracleAddress, isReversedOracle);
        return (
            feeBases[aggregatorID].currentFeeBase,
            feeBases[aggregatorID].upwardDifference,
            feeBases[aggregatorID].downwardDifference
        );
    }

    function _getLBTStrikePrice(
        BondMakerInterface bondMaker,
        uint256 bondGroupID,
        bool isReversedOracle
    ) public view returns (uint128, address) {
        (bytes32[] memory bondIDs, ) = bondMaker.getBondGroup(bondGroupID);
        (address bondAddress, , , bytes32 fnMapID) = bondMaker.getBond(bondIDs[1]);
        bytes memory fnMap = bondMaker.getFnMap(fnMapID);
        uint256[] memory zippedLines = decodePolyline(fnMap);
        LineSegment memory secondLine = unzipLineSegment(zippedLines[1]);
        return (
            _getReversedValue(uint256(secondLine.left.x), isReversedOracle).toUint128(),
            bondAddress
        );
    }

    function _getMinBondAmount(
        BondMakerInterface bondMaker,
        uint256 bondGroupID,
        address aggregatorAddress
    ) internal view returns (uint256 balance) {
        (bytes32[] memory bondIDs, ) = bondMaker.getBondGroup(bondGroupID);
        for (uint256 i = 0; i < bondIDs.length; i++) {
            (address bondAddress, , , ) = bondMaker.getBond(bondIDs[i]);
            uint256 bondBalance = IERC20(bondAddress).balanceOf(aggregatorAddress);
            if (i == 0) {
                balance = bondBalance;
            } else if (balance > bondBalance) {
                balance = bondBalance;
            }
        }
    }
}


pragma solidity 0.7.1;

contract StrategyForSimpleAggregatorETH is StrategyForSimpleAggregator {
    using SafeMath for uint256;
    ExchangeInterface internal immutable exchange;

    constructor(
        ExchangeInterface _exchange,
        uint256 termInterval,
        uint256 termCF
    ) StrategyForSimpleAggregator(termInterval, termCF) {
        exchange = _exchange;
        require(address(_exchange) != address(0), "_exchange cannot be zero");
    }

    function getTrancheBonds(
        BondMakerInterface bondMaker,
        address aggregatorAddress,
        uint256 issueBondGroupId,
        uint256 price,
        uint256[] calldata bondGroupList,
        uint64 priceUnit,
        bool isReversedOracle
    )
        public
        view
        override
        returns (
            uint256 issueAmount,
            uint256 ethAmount,
            uint256[2] memory IDAndAmountOfBurn
        )
    {
        if (SimpleAggregatorInterface(aggregatorAddress).getCollateralAddress() == address(0)) {
            uint256 currentDepositAmount = exchange.ethAllowance(aggregatorAddress);
            uint256 baseETHAmount = aggregatorAddress.balance.div(10);
            if (currentDepositAmount < baseETHAmount) {
                ethAmount = baseETHAmount.sub(currentDepositAmount);
            }
        }

        (issueAmount, , IDAndAmountOfBurn) = super.getTrancheBonds(
            bondMaker,
            aggregatorAddress,
            issueBondGroupId,
            price,
            bondGroupList,
            priceUnit,
            isReversedOracle
        );
    }
}