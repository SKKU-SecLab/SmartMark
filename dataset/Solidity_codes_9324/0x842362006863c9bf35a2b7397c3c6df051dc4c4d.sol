
pragma solidity 0.7.6;

interface ITwapOracle {

    event OwnerSet(address owner);
    event UniswapPairSet(address uniswapPair);

    function decimalsConverter() external view returns (int256);


    function xDecimals() external view returns (uint8);


    function yDecimals() external view returns (uint8);


    function owner() external view returns (address);


    function uniswapPair() external view returns (address);


    function getPriceInfo() external view returns (uint256 priceAccumulator, uint32 priceTimestamp);


    function getSpotPrice() external view returns (uint256);


    function getAveragePrice(uint256 priceAccumulator, uint32 priceTimestamp) external view returns (uint256);


    function setOwner(address _owner) external;


    function setUniswapPair(address _uniswapPair) external;


    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore,
        bytes calldata data
    ) external view returns (uint256 yAfter);


    function tradeY(
        uint256 yAfter,
        uint256 yBefore,
        uint256 xBefore,
        bytes calldata data
    ) external view returns (uint256 xAfter);


    function depositTradeXIn(
        uint256 xLeft,
        uint256 xBefore,
        uint256 yBefore,
        bytes calldata data
    ) external view returns (uint256 xIn);


    function depositTradeYIn(
        uint256 yLeft,
        uint256 yBefore,
        uint256 xBefore,
        bytes calldata data
    ) external view returns (uint256 yIn);

}// GPL-3.0-or-later

pragma solidity 0.7.6;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}// GPL-3.0-or-later

pragma solidity 0.7.6;


library SafeMath {

    int256 private constant _INT256_MIN = -2**255;

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, 'SM4E');
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = sub(x, y, 'SM12');
    }

    function sub(
        uint256 x,
        uint256 y,
        string memory message
    ) internal pure returns (uint256 z) {

        require((z = x - y) <= x, message);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, 'SM2A');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, 'SM43');
        uint256 c = a / b;
        return c;
    }

    function ceil_div(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = div(a, b);
        if (c == mul(a, b)) {
            return c;
        } else {
            return add(c, 1);
        }
    }

    function toUint32(uint256 n) internal pure returns (uint32) {

        require(n <= type(uint32).max, 'SM50');
        return uint32(n);
    }

    function toUint112(uint256 n) internal pure returns (uint112) {

        require(n <= type(uint112).max, 'SM51');
        return uint112(n);
    }

    function toInt256(uint256 unsigned) internal pure returns (int256 signed) {

        require(unsigned <= uint256(type(int256).max), 'SM34');
        signed = int256(unsigned);
    }


    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), 'SM4D');

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), 'SM11');

        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), 'SM29');

        int256 c = a * b;
        require(c / a == b, 'SM29');

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, 'SM43');
        require(!(b == -1 && a == _INT256_MIN), 'SM42');

        int256 c = a / b;

        return c;
    }
}pragma solidity >=0.5.0;

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

}pragma solidity >=0.4.0;

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {

        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {

        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);
    }
}pragma solidity >=0.5.0;


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
}// GPL-3.0-or-later

pragma solidity 0.7.6;


contract TwapOracle is ITwapOracle {

    using SafeMath for uint256;
    using SafeMath for int256;
    uint8 public immutable override xDecimals;
    uint8 public immutable override yDecimals;
    int256 public immutable override decimalsConverter;
    address public override owner;
    address public override uniswapPair;

    constructor(uint8 _xDecimals, uint8 _yDecimals) {
        require(_xDecimals <= 75 && _yDecimals <= 75, 'TO4F');
        if (_yDecimals > _xDecimals) {
            require(_yDecimals - _xDecimals <= 18, 'TO47');
        } else {
            require(_xDecimals - _yDecimals <= 18, 'TO47');
        }
        owner = msg.sender;
        xDecimals = _xDecimals;
        yDecimals = _yDecimals;
        decimalsConverter = (10**(18 + _xDecimals - _yDecimals)).toInt256();

        emit OwnerSet(msg.sender);
    }

    function isContract(address addr) private view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setOwner(address _owner) external override {

        require(msg.sender == owner, 'TO00');
        require(_owner != address(0), 'TO02');
        require(_owner != owner, 'TO01');
        owner = _owner;
        emit OwnerSet(_owner);
    }

    function setUniswapPair(address _uniswapPair) external override {

        require(msg.sender == owner, 'TO00');
        require(_uniswapPair != uniswapPair, 'TO01');
        require(_uniswapPair != address(0), 'TO02');
        require(isContract(_uniswapPair), 'TO0B');
        uniswapPair = _uniswapPair;

        IUniswapV2Pair pairContract = IUniswapV2Pair(_uniswapPair);
        require(
            IERC20(pairContract.token0()).decimals() == xDecimals &&
                IERC20(pairContract.token1()).decimals() == yDecimals,
            'TO45'
        );

        (uint112 reserve0, uint112 reserve1, ) = pairContract.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'TO1F');
        emit UniswapPairSet(_uniswapPair);
    }

    function getPriceInfo() public view override returns (uint256 priceAccumulator, uint32 priceTimestamp) {

        IUniswapV2Pair pair = IUniswapV2Pair(uniswapPair);
        priceAccumulator = pair.price0CumulativeLast();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair.getReserves();

        priceTimestamp = uint32(block.timestamp);
        if (blockTimestampLast != priceTimestamp) {
            uint32 timeElapsed = priceTimestamp - blockTimestampLast;
            priceAccumulator += uint256(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
        }
    }

    function decodePriceInfo(bytes memory data) internal pure returns (uint256 price) {

        assembly {
            price := mload(add(data, 32))
        }
    }

    function getSpotPrice() external view override returns (uint256) {

        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(uniswapPair).getReserves();
        return uint256(reserve1).mul(uint256(decimalsConverter)).div(uint256(reserve0));
    }

    function getAveragePrice(uint256 priceAccumulator, uint32 priceTimestamp) public view override returns (uint256) {

        (uint256 currentPriceAccumulator, uint32 currentPriceTimestamp) = getPriceInfo();

        require(priceTimestamp < currentPriceTimestamp, 'TO20');

        return
            ((currentPriceAccumulator - priceAccumulator) / (currentPriceTimestamp - priceTimestamp)).mul(
                uint256(decimalsConverter)
            ) >> 112;
    }

    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore,
        bytes calldata data
    ) external view override returns (uint256 yAfter) {

        int256 xAfterInt = xAfter.toInt256();
        int256 xBeforeInt = xBefore.toInt256();
        int256 yBeforeInt = yBefore.toInt256();
        int256 averagePriceInt = decodePriceInfo(data).toInt256();

        int256 yTradedInt = xAfterInt.sub(xBeforeInt).mul(averagePriceInt);

        int256 yAfterInt = yBeforeInt.mul(decimalsConverter).sub(yTradedInt).div(decimalsConverter);
        require(yAfterInt >= 0, 'TO27');
        yAfter = uint256(yAfterInt);
    }

    function tradeY(
        uint256 yAfter,
        uint256 xBefore,
        uint256 yBefore,
        bytes calldata data
    ) external view override returns (uint256 xAfter) {

        int256 yAfterInt = yAfter.toInt256();
        int256 xBeforeInt = xBefore.toInt256();
        int256 yBeforeInt = yBefore.toInt256();
        int256 averagePriceInt = decodePriceInfo(data).toInt256();

        int256 xTradedInt = yAfterInt.sub(yBeforeInt).mul(decimalsConverter);

        int256 xAfterInt = xBeforeInt.mul(averagePriceInt).sub(xTradedInt).div(averagePriceInt);
        require(xAfterInt >= 0, 'TO28');

        xAfter = uint256(xAfterInt);
    }

    function depositTradeXIn(
        uint256 xLeft,
        uint256 xBefore,
        uint256 yBefore,
        bytes calldata data
    ) external view override returns (uint256) {

        if (xBefore == 0 || yBefore == 0) {
            return 0;
        }

        uint256 price = decodePriceInfo(data);
        uint256 numerator = xLeft.mul(yBefore);
        uint256 denominator = price.mul(xLeft.add(xBefore)).add(yBefore.mul(uint256(decimalsConverter)));
        uint256 xIn = numerator.mul(uint256(decimalsConverter)).div(denominator);

        if (xIn.mul(price).div(uint256(decimalsConverter)) >= yBefore || xIn >= xLeft) {
            return 0;
        }

        return xIn;
    }

    function depositTradeYIn(
        uint256 yLeft,
        uint256 xBefore,
        uint256 yBefore,
        bytes calldata data
    ) external view override returns (uint256) {

        if (xBefore == 0 || yBefore == 0) {
            return 0;
        }

        uint256 price = decodePriceInfo(data);
        uint256 numerator = price.mul(xBefore).mul(yLeft);
        uint256 denominator = price.mul(xBefore).add(yLeft.add(yBefore).mul(uint256(decimalsConverter)));
        uint256 yIn = numerator.div(denominator);

        if (yIn.mul(uint256(decimalsConverter)).div(price) >= xBefore || yIn >= yLeft) {
            return 0;
        }

        return yIn;
    }
}