
pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

contract YamGoverned {

    event NewGov(address oldGov, address newGov);
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    address public gov;
    address public pendingGov;

    modifier onlyGov {

        require(msg.sender == gov, "!gov");
        _;
    }

    function _setPendingGov(address who)
        public
        onlyGov
    {

        address old = pendingGov;
        pendingGov = who;
        emit NewPendingGov(old, who);
    }

    function _acceptGov()
        public
    {

        require(msg.sender == pendingGov, "!pendingGov");
        address oldgov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldgov, gov);
    }
}

contract YamSubGoverned is YamGoverned {

    event SubGovModified(
        address account,
        bool isSubGov
    );
    mapping(address => bool) public isSubGov;

    modifier onlyGovOrSubGov() {

        require(msg.sender == gov || isSubGov[msg.sender]);
        _;
    }

    function setIsSubGov(address subGov, bool _isSubGov)
        public
        onlyGov
    {

        isSubGov[subGov] = _isSubGov;
        emit SubGovModified(subGov, _isSubGov);
    }
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
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

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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

library Babylonian {

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = uint(1) << RESOLUTION;
    uint private constant Q224 = Q112 << RESOLUTION;

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

    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');
        return uq112x112(uint224(Q224 / self._x));
    }

    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair,
        bool isToken0
    ) internal view returns (uint priceCumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (isToken0) {
          priceCumulative = IUniswapV2Pair(pair).price0CumulativeLast();

          if (blockTimestampLast != blockTimestamp) {
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              priceCumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
          }
        } else {
          priceCumulative = IUniswapV2Pair(pair).price1CumulativeLast();
          if (blockTimestampLast != blockTimestamp) {
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              priceCumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
          }
        }

    }
}

interface UniRouter2 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

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

contract TWAPBoundLib {

    using SafeMath for uint256;

    uint256 public constant BASE = 10**18;

    function getCurrentDestinationAmount(
        IUniswapV2Pair pool1,
        IUniswapV2Pair pool2,
        address sourceToken,
        address destinationToken,
        uint256 sourceAmount
    ) internal view returns (uint256) {

        bool sourceIsToken0 = pool1.token0() == sourceToken;
        uint256 inReserves;
        uint256 outReserves;
        (inReserves, outReserves, ) = pool1.getReserves();
        uint256 destinationAmount = UniswapV2Library.getAmountOut(
            sourceAmount,
            sourceIsToken0 ? inReserves : outReserves,
            sourceIsToken0 ? outReserves : inReserves
        );
        if (address(pool2) != address(0x0)) {
            bool middleIsToken0 = pool2.token1() == destinationToken;
            (inReserves, outReserves, ) = pool2.getReserves();
            destinationAmount = UniswapV2Library.getAmountOut(
                destinationAmount,
                middleIsToken0 ? inReserves : outReserves,
                middleIsToken0 ? outReserves : inReserves
            );
        }
        return destinationAmount;
    }

    event TestTWAPDestinationAmount(
        uint256 twap,
        uint256 minimum,
        uint256 obtained
    );

    function withinBounds(
        IUniswapV2Pair pool1,
        IUniswapV2Pair pool2,
        address sourceToken,
        address destinationToken,
        uint256 sourceAmount,
        uint256 destinationAmount,
        uint256 lastCumulativePricePool1,
        uint256 lastCumulativePricePool2,
        uint256 timeSinceLastCumulativePriceUpdate,
        uint64 slippageLimit
    ) internal returns (bool) {

        uint256 twapDestinationAmount = getTWAPDestinationAmount(
            pool1,
            pool2,
            sourceToken,
            destinationToken,
            sourceAmount,
            lastCumulativePricePool1,
            lastCumulativePricePool2,
            timeSinceLastCumulativePriceUpdate
        );
        uint256 minimum = twapDestinationAmount.mul(BASE.sub(slippageLimit)).div(
            BASE
        );
        emit TestTWAPDestinationAmount(
            twapDestinationAmount,
            minimum,
            destinationAmount
        );
        return destinationAmount >= minimum;
    }

    function getCumulativePrices(
        IUniswapV2Pair pool1,
        IUniswapV2Pair pool2,
        address sourceToken,
        address destinationToken
    )
        internal
        view
        returns (uint256 cumulativePricePool1, uint256 cumulativePricePool2)
    {

        (cumulativePricePool1, ) = UniswapV2OracleLibrary
            .currentCumulativePrices(
                address(pool1),
                pool1.token0() == sourceToken
            );

        if (address(pool2) != address(0x0)) {
            (cumulativePricePool2, ) = UniswapV2OracleLibrary
                .currentCumulativePrices(
                    address(pool2),
                    pool2.token1() == destinationToken
                );
        }
    }

    function getTWAPDestinationAmount(
        IUniswapV2Pair pool1,
        IUniswapV2Pair pool2,
        address sourceToken,
        address destinationToken,
        uint256 sourceAmount,
        uint256 lastCumulativePricePool1,
        uint256 lastCumulativePricePool2,
        uint256 timeSinceLastCumulativePriceUpdate
    ) internal view returns (uint256 price) {

        uint256 cumulativePricePool1;
        uint256 cumulativePricePool2;
        (cumulativePricePool1, cumulativePricePool2) = getCumulativePrices(
            pool1,
            pool2,
            sourceToken,
            destinationToken
        );
        uint256 priceAverageHop1 = uint256(
            uint224(
                (cumulativePricePool1 - lastCumulativePricePool1) /
                    timeSinceLastCumulativePriceUpdate
            )
        );

        if (priceAverageHop1 > uint192(-1)) {
            priceAverageHop1 = (priceAverageHop1 >> 112) * BASE;
        } else {
            priceAverageHop1 = (priceAverageHop1 * BASE) >> 112;
        }

        uint256 outputAmount = sourceAmount.mul(priceAverageHop1).div(BASE);

        if (address(pool2) != address(0)) {
            uint256 priceAverageHop2 = uint256(
                uint224(
                    (cumulativePricePool2 - lastCumulativePricePool2) /
                        timeSinceLastCumulativePriceUpdate
                )
            );

            if (priceAverageHop2 > uint192(-1)) {
                priceAverageHop2 = (priceAverageHop2 >> 112) * BASE;
            } else {
                priceAverageHop2 = (priceAverageHop2 * BASE) >> 112;
            }

            outputAmount = outputAmount.mul(priceAverageHop2).div(BASE);
        }
        return outputAmount;
    }
}


contract Swapper is YamSubGoverned, TWAPBoundLib {

    struct SwapParams {
        address sourceToken;
        address destinationToken;
        address router;
        address pool1;
        address pool2;
        uint128 sourceAmount;
        uint64 slippageLimit;
    }

    struct SwapState {
        SwapParams params;
        uint256 lastCumulativePriceUpdate;
        uint256 lastCumulativePricePool1;
        uint256 lastCumulativePricePool2;
    }

    uint64 private constant MIN_TWAP_TIME = 1 hours;
    uint64 private constant MAX_TWAP_TIME = 3 hours;

    SwapState[] public swaps;

    address public reserves;

    constructor(address _gov, address _reserves) public {
        gov = _gov;
        reserves = _reserves;
    }

    function addSwap(SwapParams calldata params) external onlyGovOrSubGov {

        swaps.push(
            SwapState({
                params: params,
                lastCumulativePriceUpdate: 0,
                lastCumulativePricePool1: 0,
                lastCumulativePricePool2: 0
            })
        );
    }
 
    function setReserves(address _reserves) external onlyGovOrSubGov {

        reserves = _reserves;
    }
    function removeSwap(uint16 index) external onlyGovOrSubGov {

        _removeSwap(index);
    }


    function execute(
        uint16 swapId,
        uint128 amountToTrade,
        uint256 minDestinationAmount
    ) external {

        SwapState memory swap = swaps[swapId];
        require(swap.params.sourceAmount > 0);
        require(amountToTrade <= swap.params.sourceAmount);
        uint256 timestamp = block.timestamp;
        uint256 timeSinceLastCumulativePriceUpdate = timestamp -
            swap.lastCumulativePriceUpdate;
        require(
            timeSinceLastCumulativePriceUpdate >= MIN_TWAP_TIME &&
                timeSinceLastCumulativePriceUpdate <= MAX_TWAP_TIME
        );
        IERC20(swap.params.sourceToken).transferFrom(
            reserves,
            address(this),
            amountToTrade
        );
        if (
            IERC20(swap.params.sourceToken).allowance(
                address(this),
                swap.params.router
            ) < amountToTrade
        ) {
            IERC20(swap.params.sourceToken).approve(
                swap.params.router,
                uint256(-1)
            );
        }
        address[] memory path;
        if (swap.params.pool2 == address(0x0)) {
            path = new address[](2);
            path[0] = swap.params.sourceToken;
            path[1] = swap.params.destinationToken;
        } else {
            address token0 = IUniswapV2Pair(swap.params.pool1).token0();
            path = new address[](3);
            path[0] = swap.params.sourceToken;
            path[1] = token0 == swap.params.sourceToken
                ? IUniswapV2Pair(swap.params.pool1).token1()
                : token0;
            path[2] = swap.params.destinationToken;
        }
        uint256[] memory amounts = UniRouter2(swap.params.router)
            .swapExactTokensForTokens(
                uint256(amountToTrade),
                minDestinationAmount,
                path,
                reserves,
                timestamp
            );

        require(
            TWAPBoundLib.withinBounds(
                IUniswapV2Pair(swap.params.pool1),
                IUniswapV2Pair(swap.params.pool2),
                swap.params.sourceToken,
                swap.params.destinationToken,
                uint256(amountToTrade),
                amounts[amounts.length - 1],
                swap.lastCumulativePricePool1,
                swap.lastCumulativePricePool2,
                timeSinceLastCumulativePriceUpdate,
                swap.params.slippageLimit
            )
        );
        if(amountToTrade == swap.params.sourceAmount){
            _removeSwap(swapId);
        } else {
            swaps[swapId].params.sourceAmount -= amountToTrade;
        }
    }

    function updateCumulativePrice(uint16 swapId) external {

        SwapState memory swap = swaps[swapId];
        uint256 timestamp = block.timestamp;
        require(timestamp - swap.lastCumulativePriceUpdate > MAX_TWAP_TIME);
        (
            swaps[swapId].lastCumulativePricePool1,
            swaps[swapId].lastCumulativePricePool2
        ) = TWAPBoundLib.getCumulativePrices(
            IUniswapV2Pair(swap.params.pool1),
            IUniswapV2Pair(swap.params.pool2),
            swap.params.sourceToken,
            swap.params.destinationToken
        );
        swaps[swapId].lastCumulativePriceUpdate = timestamp;
    }


    function _removeSwap(uint16 index) internal {

        swaps[index] = SwapState({
            params: SwapParams(
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0,
                0
            ),
            lastCumulativePriceUpdate: 0,
            lastCumulativePricePool1: 0,
            lastCumulativePricePool2: 0
        });
    }
}