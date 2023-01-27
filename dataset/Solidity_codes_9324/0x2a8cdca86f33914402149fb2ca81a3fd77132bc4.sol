

pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


pragma solidity >=0.5.0;

interface IDXswapPair {

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

    function swapFee() external view returns (uint8);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

    function setSwapFee(uint8) external;

}


pragma solidity >=0.4.0;

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
}


pragma solidity >=0.5.0;



library DXswapOracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IDXswapPair(pair).price0CumulativeLast();
        price1Cumulative = IDXswapPair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IDXswapPair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}


pragma solidity =0.6.6;


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



library DXswapLibrary {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'DXswapLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'DXswapLibrary: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'2db943b381c6ef706828ea5e89f480bd449d4d3a2b98e6da97b30d0eb41fb6d6' // init code hash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IDXswapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    
    function getSwapFee(address factory, address tokenA, address tokenB) internal view returns (uint swapFee) {

        (address token0,) = sortTokens(tokenA, tokenB);
        swapFee = IDXswapPair(pairFor(factory, tokenA, tokenB)).swapFee();
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'DXswapLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'DXswapLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint swapFee) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'DXswapLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'DXswapLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(uint(10000).sub(swapFee));
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint swapFee) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'DXswapLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'DXswapLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(uint(10000).sub(swapFee));
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'DXswapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, getSwapFee(factory, path[i], path[i + 1]));
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'DXswapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, getSwapFee(factory, path[i - 1], path[i]));
        }
    }
}


pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;





contract OracleCreator {

    using FixedPoint for *;
    using SafeMath for uint256;

    event OracleCreated(
        uint256 indexed _oracleIndex,
        address indexed _factory,
        address indexed _pair,
        uint256 windowTime
    );

    struct Oracle{
      uint256 windowTime;
      address factory;
      address token0;
      address token1;
      IDXswapPair pair;
      uint32 blockTimestampLast;
      uint256 price0CumulativeLast;
      uint256 price1CumulativeLast;
      FixedPoint.uq112x112 price0Average;
      FixedPoint.uq112x112 price1Average;
      uint256 observationsCount;
      address owner;
    }

    mapping(uint256 => Oracle) public oracles;
    uint256 public oraclesIndex;

    function createOracle(
        uint256 windowTime,
        address factory,
        address pair
    ) public returns (uint256 oracleId) {

      address token0 = IDXswapPair(pair).token0();
      address token1 = IDXswapPair(pair).token1();
      oracles[oraclesIndex] = Oracle(windowTime, factory, token0, token1, IDXswapPair(pair), 0, 0, 0, FixedPoint.uq112x112(0), FixedPoint.uq112x112(0), 0, msg.sender);
      oracleId = oraclesIndex;
      oraclesIndex++;
      emit OracleCreated(oracleId, factory, pair, windowTime);
      update(oracleId);
    }

    function update(uint256 oracleIndex) public {

        require(msg.sender == oracles[oracleIndex].owner, 'ExampleOracleSimple: CALLER_NOT_OWNER');
        require(oracles[oracleIndex].observationsCount < 2, 'ExampleOracleSimple: FINISHED_OBERSERVATION');
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            DXswapOracleLibrary.currentCumulativePrices(address(oracles[oracleIndex].pair));
        uint32 timeElapsed = blockTimestamp - oracles[oracleIndex].blockTimestampLast; // overflow is desired

        require(oracles[oracleIndex].observationsCount == 0 || timeElapsed >= oracles[oracleIndex].windowTime, 'ExampleOracleSimple: PERIOD_NOT_ELAPSED');

        oracles[oracleIndex].price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - oracles[oracleIndex].price0CumulativeLast) / timeElapsed));
        oracles[oracleIndex].price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - oracles[oracleIndex].price1CumulativeLast) / timeElapsed));

        oracles[oracleIndex].price0CumulativeLast = price0Cumulative;
        oracles[oracleIndex].price1CumulativeLast = price1Cumulative;
        oracles[oracleIndex].blockTimestampLast = blockTimestamp;
        oracles[oracleIndex].observationsCount++;
    }

    function consult(uint256 oracleIndex, address token, uint amountIn) external view returns (uint amountOut) {

        if (token == oracles[oracleIndex].token0) {
            amountOut = oracles[oracleIndex].price0Average.mul(amountIn).decode144();
        } else {
            require(token == oracles[oracleIndex].token1, 'ExampleOracleSimple: INVALID_TOKEN');
            amountOut = oracles[oracleIndex].price1Average.mul(amountIn).decode144();
        }
    }

    function isOracleFinalized(uint256 oracleIndex) external view returns (bool){

      return oracles[oracleIndex].observationsCount == 2 ? true : false; 
    }

}