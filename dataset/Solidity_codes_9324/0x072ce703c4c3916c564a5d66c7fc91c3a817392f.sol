pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

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
pragma solidity >=0.6.6;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}
pragma solidity >=0.6.0;

interface IChainLinkInterface {


    function latestAnswer() external view returns (int256);

    function decimals() external view returns (uint8);


}// CC-BY-4.0
pragma solidity >=0.4.0;

library FullMath {

    function fullMul(uint256 x, uint256 y) internal pure returns (uint256 l, uint256 h) {

        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) internal pure returns (uint256) {

        (uint256 l, uint256 h) = fullMul(x, y);
        require(h < z);
        uint256 mm = mulmod(x, y, z);
        if (mm > l) h -= 1;
        l -= mm;
        uint256 pow2 = z & -z;
        z /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        return l * r;
    }
}

pragma solidity >=0.4.0;

library Babylonian {

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = uint256(1) << RESOLUTION;
    uint256 private constant Q224 = Q112 << RESOLUTION;
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
        require(y == 0 || (z = self._x * y) / y == self._x, 'FixedPoint: MUL_OVERFLOW');
        return uq144x112(z);
    }

    function muli(uq112x112 memory self, int256 y) internal pure returns (int256) {

        uint144 z = decode144(mul(self, uint256(y < 0 ? -y : y)));
        return y < 0 ? -int256(z) : z;
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

        require(upper <= uint112(-1), 'FixedPoint: MULUQ_OVERFLOW_UPPER');

        uint256 sum = uint256(upper << RESOLUTION) + uppers_lowero + uppero_lowers + (lower >> RESOLUTION);

        require(sum <= uint224(-1), 'FixedPoint: MULUQ_OVERFLOW_SUM');

        return uq112x112(uint224(sum));
    }

    function divuq(uq112x112 memory self, uq112x112 memory other) internal pure returns (uq112x112 memory) {

        require(other._x > 0, 'FixedPoint: DIV_BY_ZERO_DIVUQ');
        if (self._x == other._x) {
            return uq112x112(uint224(Q112));
        }
        if (self._x <= uint144(-1)) {
            uint256 value = (uint256(self._x) << RESOLUTION) / other._x;
            require(value <= uint224(-1), 'FixedPoint: DIVUQ_OVERFLOW');
            return uq112x112(uint224(value));
        }

        uint256 result = FullMath.mulDiv(Q112, self._x, other._x);
        require(result <= uint224(-1), 'FixedPoint: DIVUQ_OVERFLOW');
        return uq112x112(uint224(result));
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, 'FixedPoint: DIV_BY_ZERO_FRACTION');
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        require(self._x > 1, 'FixedPoint: DIV_BY_ZERO_RECIPROCAL_OR_OVERFLOW');
        return uq112x112(uint224(Q224 / self._x));
    }

    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 32) << 40));
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
pragma solidity ^0.6.6;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
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

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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
pragma solidity ^0.6.6;

interface ITokenOracleDemo {


    event UpdatePairCount(uint32 blockTimestamp, uint oldLength, uint newLength, uint count);
    event UpdatePairPriceLatest(address indexed pair, uint token0Price, uint token1Price, uint32 blockTimestamp);

    function decimals() external view returns (uint8);


    function getPairInfoLength() external view returns (uint);

    function updatePairs() external;

    function updatePairPriceAll() external;

    function updatePairPriceSingle(address pair) external returns (bool);

    function getPairToken(uint index) external view returns (address pair, address token0, address token1);

    function getPairTokenDecimals(uint index) external view returns (uint8 token0Decimals, uint8 token1Decimals);

    function getPairTokenPriceCumulativeLast(uint index) external view returns (uint price0CumulativeLast, uint price1CumulativeLast);

    function getPairPrice(address token0, address token1) external view returns (uint);

    function getPairPriceByIndex(uint index) external view returns (address pair, string memory token0Symbol, string memory token1Symbol, uint token0Price, uint token1Price, uint blockTimestamp);

    function getPairPriceBySymbol(string calldata token0, string calldata token1) external view returns (address pair, uint token0Price, uint token1Price, uint blockTimestamp);

    function getPairPriceByAddress(address pair) external view returns (string memory token0Symbol, string memory token1Symbol, uint token0Price, uint token1Price, uint blockTimestamp);

    function getPairUpdatePriceTime(address token0, address token1) external view returns (uint);


    function getTokenLength() external view returns (uint);

    function getTokenPriceUSD(address) external view returns (uint);

    function getTokenPriceByIndex(uint index) external view returns (address token, string memory symbol, uint price, uint blockTimestamp);

    function getTokenPriceByAddress(address token) external view returns (string memory symbol, uint price, uint blockTimestamp);

    function getTokenPriceBySymbol(string calldata symbol) external view returns (address token, uint price, uint blockTimestamp);    

    function getTokenPriceUpdateTime(address) external view returns (uint);


}
pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;


contract TokenOracleDemo is ITokenOracleDemo {

    using SafeMath for uint;
    using FixedPoint for *;

    uint8 public override constant decimals = 10;

    uint8 public constant maxUpdatePairCount = 10;

    IChainLinkInterface public constant ChainLinkETHUSD = IChainLinkInterface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    
    IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    struct PairInfo {
        IUniswapV2Pair pair;
        address token0;
        address token1;
        string token0Symbol;
        string token1Symbol;
        uint8 token0Decimals;
        uint8 token1Decimals;
        uint price0CumulativeLast;
        uint price1CumulativeLast;
        uint32 blockTimestampLast;
        uint token0Price;
        uint token1Price;
    }
    PairInfo[] public pairInfo;

    struct tokenPrice {
        address token;
        string symbol;
        uint price;
        uint blockTimestamp;
    }
    tokenPrice[] public tokenPriceData;
    mapping (address => uint) public tokenPriceMap;

    constructor() public {
        tokenPrice storage price = tokenPriceData.push();
        price.token = WETH;
        price.symbol = "WETH";
        price.price = uint(ChainLinkETHUSD.latestAnswer()).mul(uint(10)**decimals).div(uint(10)**ChainLinkETHUSD.decimals());
        price.blockTimestamp = block.timestamp;
        tokenPriceMap[WETH] = 0;

        for(uint i = 0; i < 10; i++){
            IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Factory.allPairs(i));
            PairInfo storage _pairInfo = pairInfo.push();
            _pairInfo.pair = pair;
            _pairInfo.token0 = pair.token0();
            _pairInfo.token1 = pair.token1();
            _pairInfo.token0Symbol = IERC20(pair.token0()).symbol();
            _pairInfo.token1Symbol = IERC20(pair.token1()).symbol();
            _pairInfo.token0Decimals = IERC20(pair.token0()).decimals();
            _pairInfo.token1Decimals = IERC20(pair.token1()).decimals();
            _pairInfo.price0CumulativeLast = pair.price0CumulativeLast();
            _pairInfo.price1CumulativeLast = pair.price1CumulativeLast();
            uint112 reserve0;
            uint112 reserve1;
            (reserve0, reserve1, _pairInfo.blockTimestampLast) = pair.getReserves();
        }
    }

    function getPairInfoLength() external override view returns (uint) {

        return pairInfo.length;
    }

    function updatePairs() external override {

        uint oldLength = pairInfo.length;
        uint newLength = uniswapV2Factory.allPairsLength();
        if (oldLength == newLength)
            return;

        uint count = newLength.sub(oldLength) > maxUpdatePairCount ? maxUpdatePairCount : newLength.sub(oldLength);
        for(uint i = 0; i < count; i++){
            IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Factory.allPairs(oldLength + i));
            PairInfo storage _pairInfo = pairInfo.push();
            _pairInfo.pair = pair;
            _pairInfo.token0 = pair.token0();
            _pairInfo.token1 = pair.token1();
            _pairInfo.token0Symbol = IERC20(pair.token0()).symbol();
            _pairInfo.token1Symbol = IERC20(pair.token1()).symbol();
            _pairInfo.token0Decimals = IERC20(pair.token0()).decimals();
            _pairInfo.token1Decimals = IERC20(pair.token1()).decimals();
            _pairInfo.price0CumulativeLast = pair.price0CumulativeLast();
            _pairInfo.price1CumulativeLast = pair.price1CumulativeLast();
            uint112 reserve0;
            uint112 reserve1;
            (reserve0, reserve1, _pairInfo.blockTimestampLast) = pair.getReserves();
        }

        emit UpdatePairCount(UniswapV2OracleLibrary.currentBlockTimestamp(), oldLength, newLength, count);
    }

    function updatePairPriceAll () external override {
        for(uint i = 0; i < pairInfo.length; i++){
            updatePairPriceLatest(address(pairInfo[i].pair), i);
        }
        updateTokenPriceUSD();
    }

    function updatePairPriceSingle(address pair) external override returns (bool) {


        bool bUpdate = false;
        for(uint i = 0; i < pairInfo.length; i++){
            if (address(pairInfo[i].pair) == pair) {
                bUpdate = updatePairPriceLatest(pair, i);
                updateTokenPriceUSD();
                break;
            }
        }
        return bUpdate;
    }

    function getPairToken(uint index) external override view returns (address pair, address token0, address token1) {

        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (address(pairInfo[index].pair), pairInfo[index].token0, pairInfo[index].token1);
    }

    function getPairTokenDecimals(uint index) external override view returns (uint8 token0Decimals, uint8 token1Decimals) {

        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (pairInfo[index].token0Decimals, pairInfo[index].token1Decimals);
    }

    function getPairTokenPriceCumulativeLast(uint index) external override view returns (uint price0CumulativeLast, uint price1CumulativeLast) {

        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (pairInfo[index].price0CumulativeLast, pairInfo[index].price1CumulativeLast);
    }

    function getPairPrice(address token0, address token1) external override view returns (uint) {

        for(uint i = 0; i < pairInfo.length; i++) {
            if((pairInfo[i].token0 == token0) && (pairInfo[i].token1 == token1)){
                return pairInfo[i].token0Price;
            }
            if((pairInfo[i].token0 == token1) && (pairInfo[i].token1 == token0)){
                return pairInfo[i].token1Price;
            }
        }           
    }

    function getPairPriceByIndex(uint index) external override view returns (address pair, string memory token0Symbol, string memory token1Symbol, uint token0Price, uint token1Price, uint blockTimestamp) {

        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (address(pairInfo[index].pair), pairInfo[index].token0Symbol, pairInfo[index].token1Symbol, pairInfo[index].token0Price, pairInfo[index].token1Price, pairInfo[index].blockTimestampLast);
    }

    function getPairPriceBySymbol(string calldata token0Symbol, string calldata token1Symbol) external override view returns (address pair, uint token0Price, uint token1Price, uint blockTimestamp) {

        for (uint i = 0; i < pairInfo.length; i++) {
            if ((keccak256(abi.encodePacked(pairInfo[i].token0Symbol)) == keccak256(abi.encodePacked(token0Symbol))) &&
                (keccak256(abi.encodePacked(pairInfo[i].token1Symbol)) == keccak256(abi.encodePacked(token1Symbol)))) {
                    return (address(pairInfo[i].pair), pairInfo[i].token0Price, pairInfo[i].token1Price, pairInfo[i].blockTimestampLast);
            }
        }        
    }

    function getPairPriceByAddress(address pair) external override view returns (string memory token0Symbol, string memory token1Symbol, uint token0Price, uint token1Price, uint blockTimestamp) {

        for (uint i = 0; i < pairInfo.length; i++) {
            if (address(pairInfo[i].pair) == pair) {
                return (pairInfo[i].token0Symbol, pairInfo[i].token1Symbol, pairInfo[i].token0Price, pairInfo[i].token1Price, pairInfo[i].blockTimestampLast);
            } 
        }        
    }

    function getPairUpdatePriceTime(address token0, address token1) external override view returns (uint){

        for(uint i = 0; i < pairInfo.length; i++) {
            if(((pairInfo[i].token0 == token0) && (pairInfo[i].token1 == token1)) ||
                ((pairInfo[i].token0 == token1) && (pairInfo[i].token1 == token0))){
                return pairInfo[i].blockTimestampLast;
            }
        }           
    }

    function getTokenLength() external override view returns (uint) {

        return tokenPriceData.length;
    }

    function getTokenPriceUSD(address token) external override view returns (uint){

        if (token == WETH) {
            return tokenPriceData[tokenPriceMap[WETH]].price;
        } else {
            if (tokenPriceMap[token] == 0) {
                return 0;
            } else {
                return tokenPriceData[tokenPriceMap[token]].price;                
            }
        }
        return 0;
    }

    function getTokenPriceByIndex(uint index) external override view returns (address token, string memory symbol, uint price, uint blockTimestamp){

        require(index < tokenPriceData.length, "TokenOracle: index is out of range");
        return (tokenPriceData[index].token, tokenPriceData[index].symbol, tokenPriceData[index].price, tokenPriceData[index].blockTimestamp);    
    }

    function getTokenPriceByAddress(address token) external override view returns (string memory symbol, uint price, uint blockTimestamp) {

        for (uint i = 0; i < tokenPriceData.length; i++) {
            if (address(tokenPriceData[i].token) == token) {
                return (tokenPriceData[i].symbol, tokenPriceData[i].price, tokenPriceData[i].blockTimestamp);
            } 
        }            
    }

    function getTokenPriceBySymbol(string calldata symbol) external override view returns (address token, uint price, uint blockTimestamp) {

        for (uint i = 0; i < tokenPriceData.length; i++) {
            if (keccak256(abi.encodePacked(tokenPriceData[i].symbol)) == keccak256(abi.encodePacked(symbol))) {
                return (tokenPriceData[i].token, tokenPriceData[i].price, tokenPriceData[i].blockTimestamp);
            } 
        }            
    }

    function getTokenPriceUpdateTime(address token) external override view returns (uint){

        if (token == WETH) {
            return tokenPriceData[tokenPriceMap[WETH]].blockTimestamp;
        } else {
            if (tokenPriceMap[token] == 0) {
                return 0;
            } else {
                return tokenPriceData[tokenPriceMap[token]].blockTimestamp;                
            }
        }
        return 0;
    }

    function updatePairPriceLatest(address pair, uint i) internal returns (bool) {


        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(pair);
        uint32 timeElapsed = blockTimestamp - pairInfo[i].blockTimestampLast; // overflow is desired
        if (timeElapsed == 0) {
            return false;
        }

        FixedPoint.uq112x112 memory price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - pairInfo[i].price0CumulativeLast) / timeElapsed));
        FixedPoint.uq112x112 memory price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - pairInfo[i].price1CumulativeLast) / timeElapsed));
        
        pairInfo[i].price0CumulativeLast = price0Cumulative;
        pairInfo[i].price1CumulativeLast = price1Cumulative;
        pairInfo[i].blockTimestampLast = blockTimestamp;

        pairInfo[i].token0Price = uint(price0Average.mul(uint(10)**pairInfo[i].token0Decimals).decode144()).mul(uint(10)**decimals).div(uint(10)**pairInfo[i].token1Decimals);
        pairInfo[i].token1Price = uint(price1Average.mul(uint(10)**pairInfo[i].token1Decimals).decode144()).mul(uint(10)**decimals).div(uint(10)**pairInfo[i].token0Decimals);

        emit UpdatePairPriceLatest(pair, pairInfo[i].token0Price, pairInfo[i].token1Price, UniswapV2OracleLibrary.currentBlockTimestamp());

        return true;
    }

    function newTokenPriceData(uint index) internal {

        if ((tokenPriceMap[pairInfo[index].token0] == 0) && (pairInfo[index].token0 != WETH)){
            tokenPrice storage price = tokenPriceData.push();
            price.token = pairInfo[index].token0;
            price.symbol = pairInfo[index].token0Symbol;
            price.price = 0;
            price.blockTimestamp = 0;
            tokenPriceMap[pairInfo[index].token0] = tokenPriceData.length - 1;
        } 
        if ((tokenPriceMap[pairInfo[index].token1] == 0) && (pairInfo[index].token1 != WETH)) {
            tokenPrice storage price = tokenPriceData.push();
            price.token = pairInfo[index].token1;
            price.symbol = pairInfo[index].token1Symbol;
            price.price = 0;
            price.blockTimestamp = 0;
            tokenPriceMap[pairInfo[index].token1] = tokenPriceData.length - 1;
        }         
    }

    function updateTokenPriceUSD() internal {

        uint ethPrice = uint(ChainLinkETHUSD.latestAnswer()).mul(uint(10)**decimals).div(uint(10)**ChainLinkETHUSD.decimals());
        tokenPriceData[tokenPriceMap[WETH]].price = ethPrice;
        tokenPriceData[tokenPriceMap[WETH]].blockTimestamp = block.timestamp;

        for(uint i = 0; i < pairInfo.length; i++){
            newTokenPriceData(i);
            if(pairInfo[i].token0 == WETH) {
                if(pairInfo[i].blockTimestampLast > tokenPriceData[tokenPriceMap[pairInfo[i].token1]].blockTimestamp){
                    tokenPriceData[tokenPriceMap[pairInfo[i].token1]].price = pairInfo[i].token1Price.mul(ethPrice).div(uint(10)**decimals);
                    tokenPriceData[tokenPriceMap[pairInfo[i].token1]].blockTimestamp = pairInfo[i].blockTimestampLast;
                }
            }    
            if(pairInfo[i].token1 == WETH) {
                if(pairInfo[i].blockTimestampLast > tokenPriceData[tokenPriceMap[pairInfo[i].token0]].blockTimestamp){
                    tokenPriceData[tokenPriceMap[pairInfo[i].token0]].price = pairInfo[i].token0Price.mul(ethPrice).div(uint(10)**decimals);
                    tokenPriceData[tokenPriceMap[pairInfo[i].token0]].blockTimestamp = pairInfo[i].blockTimestampLast;
                }
            }    
        }

        for (uint m = 0; m < 5; m++) {
            for(uint i = 0; i < pairInfo.length; i++){
                if((pairInfo[i].token0 == WETH) || (pairInfo[i].token1 == WETH)) {
                    continue;
                }
                newTokenPriceData(i);
                if(tokenPriceData[tokenPriceMap[pairInfo[i].token1]].price != 0) {
                    if(pairInfo[i].blockTimestampLast > tokenPriceData[tokenPriceMap[pairInfo[i].token0]].blockTimestamp){
                        tokenPriceData[tokenPriceMap[pairInfo[i].token0]].price = pairInfo[i].token0Price.mul(tokenPriceData[tokenPriceMap[pairInfo[i].token1]].price).div(uint(10)**decimals);
                        tokenPriceData[tokenPriceMap[pairInfo[i].token0]].blockTimestamp = pairInfo[i].blockTimestampLast;
                    }
                }
                if(tokenPriceData[tokenPriceMap[pairInfo[i].token0]].price != 0) {
                    if(pairInfo[i].blockTimestampLast > tokenPriceData[tokenPriceMap[pairInfo[i].token1]].blockTimestamp){
                        tokenPriceData[tokenPriceMap[pairInfo[i].token1]].price = pairInfo[i].token1Price.mul(tokenPriceData[tokenPriceMap[pairInfo[i].token0]].price).div(uint(10)**decimals);
                        tokenPriceData[tokenPriceMap[pairInfo[i].token1]].blockTimestamp = pairInfo[i].blockTimestampLast;
                    }
                }
            }            
        }
    }

}
