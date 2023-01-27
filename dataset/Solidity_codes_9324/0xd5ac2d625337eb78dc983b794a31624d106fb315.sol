

pragma solidity >=0.4.0;

library FullMath {

    function fullMul(uint256 x, uint256 y) internal pure returns (uint256 l, uint256 h) {

        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {

        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {

        (uint256 l, uint256 h) = fullMul(x, y);

        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;

        if (h == 0) return l / d;

        require(h < d, 'FullMath: FULLDIV_OVERFLOW');
        return fullDiv(l, h, d);
    }
}



pragma solidity >=0.4.0;

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {

        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}


pragma solidity >=0.5.0;

library BitMath {

    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {

        require(x > 0, 'BitMath::mostSignificantBit: zero');

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }

    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {

        require(x > 0, 'BitMath::leastSignificantBit: zero');

        r = 255;
        if (x & uint128(-1) > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & uint64(-1) > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & uint32(-1) > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & uint16(-1) > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & uint8(-1) > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}


pragma solidity >=0.4.0;




library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 public constant RESOLUTION = 112;
    uint256 public constant Q112 = 0x10000000000000000000000000000; // 2**112
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000; // 2**224
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);
    }

    function mul(uq112x112 memory self, uint256 y) internal pure returns (uq144x112 memory) {

        uint256 z = 0;
        require(y == 0 || (z = self._x * y) / y == self._x, 'FixedPoint::mul: overflow');
        return uq144x112(z);
    }

    function muli(uq112x112 memory self, int256 y) internal pure returns (int256) {

        uint256 z = FullMath.mulDiv(self._x, uint256(y < 0 ? -y : y), Q112);
        require(z < 2**255, 'FixedPoint::muli: overflow');
        return y < 0 ? -int256(z) : int256(z);
    }

    function muluq(uq112x112 memory self, uq112x112 memory other) internal pure returns (uq112x112 memory) {

        if (self._x == 0 || other._x == 0) {
            return uq112x112(0);
        }
        uint112 upper_self = uint112(self._x >> RESOLUTION); // * 2^0
        uint112 lower_self = uint112(self._x & LOWER_MASK); // * 2^-112
        uint112 upper_other = uint112(other._x >> RESOLUTION); // * 2^0
        uint112 lower_other = uint112(other._x & LOWER_MASK); // * 2^-112

        uint224 upper = uint224(upper_self) * upper_other; // * 2^0
        uint224 lower = uint224(lower_self) * lower_other; // * 2^-224
        uint224 uppers_lowero = uint224(upper_self) * lower_other; // * 2^-112
        uint224 uppero_lowers = uint224(upper_other) * lower_self; // * 2^-112

        require(upper <= uint112(-1), 'FixedPoint::muluq: upper overflow');

        uint256 sum = uint256(upper << RESOLUTION) + uppers_lowero + uppero_lowers + (lower >> RESOLUTION);

        require(sum <= uint224(-1), 'FixedPoint::muluq: sum overflow');

        return uq112x112(uint224(sum));
    }

    function divuq(uq112x112 memory self, uq112x112 memory other) internal pure returns (uq112x112 memory) {

        require(other._x > 0, 'FixedPoint::divuq: division by zero');
        if (self._x == other._x) {
            return uq112x112(uint224(Q112));
        }
        if (self._x <= uint144(-1)) {
            uint256 value = (uint256(self._x) << RESOLUTION) / other._x;
            require(value <= uint224(-1), 'FixedPoint::divuq: overflow');
            return uq112x112(uint224(value));
        }

        uint256 result = FullMath.mulDiv(Q112, self._x, other._x);
        require(result <= uint224(-1), 'FixedPoint::divuq: overflow');
        return uq112x112(uint224(result));
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, 'FixedPoint::fraction: division by zero');
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        }
    }

    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        require(self._x != 0, 'FixedPoint::reciprocal: reciprocal of zero');
        require(self._x != 1, 'FixedPoint::reciprocal: overflow');
        return uq112x112(uint224(Q224 / self._x));
    }

    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        if (self._x <= uint144(-1)) {
            return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << safeShiftBits) << ((112 - safeShiftBits) / 2)));
    }
}


pragma solidity >=0.5.16;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}


pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}


pragma solidity >=0.5.0;



library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}


pragma solidity >=0.5.0;



library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}


pragma solidity 0.6.6;

contract Ownable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity =0.6.6;

contract GenesisOracleData {

    uint256 btcDaySartTime = 1609459200;
    uint256[] btcCumulativePrice =[13156445312852852539359295945662818759419881,13288872208569578371525385887174570655064771,13424990104470608910139046534678229196602339,13576010582627460012382040137815553501083556,13718353948100810240829766482855510374756456,13863751964579947155899545124117778945297264,14019368695514137871117205429174082285171872,14190956240363168830339614495427902738151333,14369545059231887761089065295675633119376988,14550366346775100595315741967053671358718210];
}


pragma solidity =0.6.6;








contract GenesisOracle is Ownable,GenesisOracleData {

    using FixedPoint for *;
    using SafeMath for uint;
    struct Observation {
        uint timestamp;
        uint price0;
        uint price0Cumulative;
    }

    uint256 public windowSize = 86400;//one day
    uint256 public granularity = 24;//24 times
    uint256 public periodSize = windowSize/ granularity;

    address public uniFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public susiFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;//use uni

    address public uniWbtcUsdtLp =  0x004375Dff511095CC5A197A54140a24eFEF3A416;//lp
    address public wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;//wbtc
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;//usdc

    address public btch = address(0);//btch
    address public susiBtchWbtcLp = address(0);

    uint256 public btcDecimal = 1e8;
    uint256 public usdcDecimal = 1e6;
    uint256 public btchDecimal = 1e9;

    uint256 public priceDecimal = 1e8;

    uint256 public daySeconds = 86400;

    uint256 public lastUpdateTime;

    mapping(uint256=>uint256) public sushiBtchDayPrice;
    mapping(uint256=>uint256) public uiniAvgBtcDayCumulativePrice;
    mapping(address =>mapping(uint256=>Observation)) public pairObservations;

    event SetBtcAvg24Price(address indexed from,uint256 avgPrice,uint256 periodIdx);
    event BtchAvg24Price(address indexed from,uint256 avgPrice,uint256 periodIdx);

    constructor() public {
        uint256 idx = btcDaySartTime/daySeconds;
        for(uint256 i=0;i<btcCumulativePrice.length;i++){
            uiniAvgBtcDayCumulativePrice[idx++] = btcCumulativePrice[i];
        }
    }

    function setTimeWndGranularity(uint windowSize_, uint8 granularity_)  external onlyOwner {

        require(granularity_ > 1, 'SlidingWindowOracle: GRANULARITY');
        require(
        (periodSize = windowSize_ / granularity_) * granularity_ == windowSize_,
        'SlidingWindowOracle: WINDOW_NOT_EVENLY_DIVISIBLE'
        );
        windowSize = windowSize_;
        granularity = granularity_;
    }

    function setFactoryAddress(address uniFactory_,address susiFactory_) external onlyOwner{

        uniFactory = uniFactory_;
        susiFactory = susiFactory_;
    }

    function initBtch(address btch_,uint256 btchDecimal_) external onlyOwner{

        btch = btch_;
        btchDecimal = btchDecimal_;
    }

    function setBtc(address wbtc_,uint256 btcDecimal_) external onlyOwner{

        wbtc = wbtc_;
        btcDecimal = btcDecimal_;
    }

    function setUsdc(address usdc_,uint256 usdcDecimal_) external onlyOwner{

        usdc = usdc_;
        usdcDecimal = usdcDecimal_;
    }

    function setBtcCumulativeDayPrice(uint256[] calldata _timestamps,uint256[] calldata _btcCumulativePrice) external onlyOwner {

         require(_timestamps.length== _btcCumulativePrice.length,"array length is not equal!");
         for(uint256 i=0;i<_timestamps.length;i++){
            uint256 dayidx = _timestamps[i]/daySeconds;
            uiniAvgBtcDayCumulativePrice[dayidx] = _btcCumulativePrice[i];
        }
    }

    function btchSetCumulativeDayPrice(uint256[] calldata _timestamps,uint256[] calldata _btchDayCumulativeprices) external onlyOwner{

        require(_timestamps.length== _btchDayCumulativeprices.length,"array length is not equal!");
        for(uint256 i=0;i< _timestamps.length;i++) {
            uint256 dayidx = _timestamps[i]/daySeconds;
            sushiBtchDayPrice[dayidx] = _btchDayCumulativeprices[i];
        }
    }

    function setBtcCumOberverVationData(uint256[] calldata _timestamps,uint256[] calldata _data)  external onlyOwner {

        require(_timestamps.length==_data.length,"array length is not equal");
        uint256 idx = 0;
        for(uint256 i=0;i<_timestamps.length;i++)  {
           idx = _timestamps[i]/periodSize;
           pairObservations[wbtc][idx] = Observation(block.timestamp,0,_data[i]);
       }
    }

    function btchSetCumOberverVationData(uint256[] calldata _timestamps,uint256[] calldata _data)  external onlyOwner {

        require(_timestamps.length==_data.length,"array length is not equal");
        uint256 idx = 0;
        for(uint256 i=0;i<_timestamps.length;i++)  {
           idx = _timestamps[i]/periodSize;
           pairObservations[btch][idx] = Observation(block.timestamp,0,_data[i]);
        }
    }
    function computeAmountOut(
        uint priceCumulativeStart,
        uint priceCumulativeEnd,
        uint timeElapsed,
        uint amountIn
    ) internal pure returns (uint amountOut) {

        if(timeElapsed==0) {
            return 0;
        }
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulativeEnd - priceCumulativeStart) / timeElapsed)
        );

        amountOut = priceAverage.mul(amountIn).decode144();
    }
    function getTimeAvgPrice(address factory,
        address tokenIn,
        uint amountIn,
        uint priceInCumulativeStart,
        uint priceInCumulativeEnd,
        uint startTime,
        uint endTime,
        address tokenOut)
        internal view returns (uint amountOut)
    {

        if(startTime==0||endTime==0||startTime>=block.timestamp
           ||priceInCumulativeStart>priceInCumulativeEnd) {
            return 0;
        }

        address pair = UniswapV2Library.pairFor(factory, tokenIn, tokenOut);
        uint timeElapsed = block.timestamp.sub(startTime);
        (uint price0Cumulative,,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        if(price0Cumulative<priceInCumulativeEnd) {
            price0Cumulative = priceInCumulativeEnd;
            timeElapsed = endTime.sub(startTime);
        }
        return computeAmountOut(priceInCumulativeStart, price0Cumulative, timeElapsed, amountIn);
    }

    function getBTCHBTC() public view returns(uint256){

        if(btch==address(0)||wbtc==address(0)) {
            return 0;
        }

        (uint256 btchReserve/*reserveA*/,uint256 wbtcReserve/*reserveB*/)= UniswapV2Library.getReserves(susiFactory, btch/*tokenA*/, wbtc/*tokenB*/);
        if(btchReserve==0) {
            return 0;
        }

        return UniswapV2Library.quote(btchDecimal,btchReserve,wbtcReserve);
    }

    function getBTCHBTC24() public view returns(uint256){

        if(btch==address(0)) {
            return 0;
        }

        uint256 idx = block.timestamp/periodSize;
        uint256 i = idx - daySeconds/periodSize;
        uint startTime = pairObservations[btch][i].timestamp;
        uint priceStart = pairObservations[btch][i].price0Cumulative;
        if(priceStart==0) {
            for(;i<idx;i++) {
                priceStart = pairObservations[btch][i].price0Cumulative;
                if(priceStart>0) {
                    startTime = pairObservations[btch][i].timestamp;
                    break;
                }
            }
        }


        uint priceEnd = pairObservations[btch][idx].price0Cumulative;
        uint j=idx;
        uint endTime = pairObservations[btch][j].timestamp;
        if(priceEnd==0) {
            for(;j>i;j--) {
                priceEnd = pairObservations[btch][j].price0Cumulative;
                if(priceEnd>0) {
                    endTime = pairObservations[btch][j].timestamp;
                    break;
                }
            }
        }

        uint timeAvgPrice = getTimeAvgPrice(susiFactory,btch,btchDecimal,priceStart,priceEnd,startTime,endTime,wbtc);
        if(timeAvgPrice>0) {
            return timeAvgPrice;
        }

        return getBTCHBTC();
    }

    function getBTCUSDC() public view returns(uint256){

        if(wbtc==address(0)||usdc==address(0)) {
            return 0;
        }
        (uint256 btcReserve/*reserveA*/,uint256 usdcReserve/*reserveB*/)= UniswapV2Library.getReserves(uniFactory, wbtc/*tokenA*/, usdc/*tokenB*/);
        if(btcReserve==0) {
            return 0;
        }
        return UniswapV2Library.quote(btcDecimal,btcReserve,usdcReserve);
    }

    function getBTCUSDC24() public view returns(uint256){

        if(wbtc==address(0)) {
            return 0;
        }

        uint256 idx = block.timestamp/periodSize;
        uint256 i = idx - daySeconds/periodSize;
        uint priceStart = pairObservations[wbtc][i].price0Cumulative;
        uint startTime = pairObservations[wbtc][i].timestamp;
        if(priceStart==0) {
            for(;i<idx;i++) {
                priceStart = pairObservations[wbtc][i].price0Cumulative;
                if(priceStart>0) {
                    startTime = pairObservations[wbtc][i].timestamp;
                    break;
                }
            }
        }


        uint priceEnd = pairObservations[wbtc][idx].price0Cumulative;
        uint j=idx;
        uint endTime = pairObservations[wbtc][j].timestamp;
        if(priceEnd==0) {
            for(;j>i;j--) {
                priceEnd = pairObservations[wbtc][j].price0Cumulative;
                if(priceEnd>0) {
                    endTime = pairObservations[wbtc][j].timestamp;
                    break;
                }
            }
        }

        uint timeAvgPrice = getTimeAvgPrice(uniFactory,wbtc,btcDecimal,priceStart,priceEnd,startTime,endTime,usdc);
        if(timeAvgPrice>0) {
            return timeAvgPrice;
        }

        return getBTCUSDC();
    }

    function getBTCUSDC365() external view returns(uint256) {

       uint256 dayidx = block.timestamp/daySeconds;
       uint256 startIdx = dayidx -365;
       uint startTime = startIdx*daySeconds;
       uint priceStart = uiniAvgBtcDayCumulativePrice[startIdx];
       if(priceStart==0) {
           for(;startIdx<dayidx;startIdx++) {
               priceStart = uiniAvgBtcDayCumulativePrice[startIdx];
               if(priceStart>0) {
                   startTime = startIdx*daySeconds;
                   break;
               }
           }
       }

       uint priceEnd = uiniAvgBtcDayCumulativePrice[dayidx];
       uint j=dayidx;
       uint endTime = j*daySeconds;
       if(priceEnd==0) {
            for(;j>startIdx;j--) {
                priceEnd = uiniAvgBtcDayCumulativePrice[j];
                if(priceEnd>0) {
                    endTime = j*daySeconds;
                    break;
                }
            }
       }
       uint timeAvgPrice = getTimeAvgPrice(uniFactory,wbtc,btcDecimal,priceStart,priceEnd,startTime,endTime,usdc);
       if(timeAvgPrice>0) {
           return timeAvgPrice;
       }
       return  getBTCUSDC24();
    }

    function needUpdate() public view returns (bool) {

        uint256 idx = block.timestamp/periodSize;
        bool timeupdate = (block.timestamp-lastUpdateTime)>(periodSize/2);
        bool uniupdate = (pairObservations[wbtc][idx].timestamp==0);
        bool susiupdate = (pairObservations[btch][idx].timestamp==0);
        return (uniupdate&&susiupdate&&timeupdate);
    }

    function update() external {

        if((block.timestamp-lastUpdateTime)<(periodSize/2)) {
            return;
        }
        updateOberverVation();
        lastUpdateTime = block.timestamp;
    }

    function updateOberverVation() private {

        uint256 idx = block.timestamp/periodSize;
        uint256 price = 0;

        if(wbtc!=address(0)) {
            if(pairObservations[wbtc][idx].timestamp==0) {
                address pair = UniswapV2Library.pairFor(uniFactory,wbtc,usdc);
                (uint price0Cumulative,,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);

                price = getBTCUSDC();
                pairObservations[wbtc][idx] = Observation(block.timestamp,price,price0Cumulative);

                uint256 dayidx = block.timestamp/daySeconds;
                if(uiniAvgBtcDayCumulativePrice[dayidx]==0) {
                    uiniAvgBtcDayCumulativePrice[dayidx]=price0Cumulative;
                }

                emit SetBtcAvg24Price(msg.sender,price,idx);
            }
        }

        if(btch!=address(0)) {
              if(pairObservations[btch][idx].timestamp==0) {
                address pair = UniswapV2Library.pairFor(susiFactory,btch,wbtc);
                (uint price0Cumulative,,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);

                price = getBTCHBTC();
                pairObservations[btch][idx] = Observation(block.timestamp,price,price0Cumulative);

                emit BtchAvg24Price(msg.sender,price,idx);
              }
        }
    }
}