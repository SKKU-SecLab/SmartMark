pragma solidity >=0.6.8;

interface IUniswapV2Router01 {

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

interface IUniswapV2Router02 is IUniswapV2Router01 {

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

library UniswapV2LiquidityMathLibrary {

    using SafeMath for uint256;

    function computeProfitMaximizingTrade(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB
    ) pure internal returns (bool aToB, uint256 amountIn) {

        aToB = FullMath.mulDiv(reserveA, truePriceTokenB, reserveB) < truePriceTokenA;

        uint256 invariant = reserveA.mul(reserveB);

        uint256 leftSide = Babylonian.sqrt(
            FullMath.mulDiv(
                invariant.mul(1000),
                aToB ? truePriceTokenA : truePriceTokenB,
                (aToB ? truePriceTokenB : truePriceTokenA).mul(997)
            )
        );
        uint256 rightSide = (aToB ? reserveA.mul(1000) : reserveB.mul(1000)) / 997;

        if (leftSide < rightSide) return (false, 0);

        amountIn = leftSide.sub(rightSide);
    }

    function getReservesAfterArbitrage(
        address factory,
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB
    ) view internal returns (uint256 reserveA, uint256 reserveB) {

        (reserveA, reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);

        require(reserveA > 0 && reserveB > 0, 'UniswapV2ArbitrageLibrary: ZERO_PAIR_RESERVES');

        (bool aToB, uint256 amountIn) = computeProfitMaximizingTrade(truePriceTokenA, truePriceTokenB, reserveA, reserveB);

        if (amountIn == 0) {
            return (reserveA, reserveB);
        }

        if (aToB) {
            uint amountOut = UniswapV2Library.getAmountOut(amountIn, reserveA, reserveB);
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            uint amountOut = UniswapV2Library.getAmountOut(amountIn, reserveB, reserveA);
            reserveB += amountIn;
            reserveA -= amountOut;
        }
    }

    function computeLiquidityValue(
        uint256 reservesA,
        uint256 reservesB,
        uint256 totalSupply,
        uint256 liquidityAmount,
        bool feeOn,
        uint kLast
    ) internal pure returns (uint256 tokenAAmount, uint256 tokenBAmount) {

        if (feeOn && kLast > 0) {
            uint rootK = Babylonian.sqrt(reservesA.mul(reservesB));
            uint rootKLast = Babylonian.sqrt(kLast);
            if (rootK > rootKLast) {
                uint numerator1 = totalSupply;
                uint numerator2 = rootK.sub(rootKLast);
                uint denominator = rootK.mul(5).add(rootKLast);
                uint feeLiquidity = FullMath.mulDiv(numerator1, numerator2, denominator);
                totalSupply = totalSupply.add(feeLiquidity);
            }
        }
        return (reservesA.mul(liquidityAmount) / totalSupply, reservesB.mul(liquidityAmount) / totalSupply);
    }

    function getLiquidityValue(
        address factory,
        address tokenA,
        address tokenB,
        uint256 liquidityAmount
    ) internal view returns (uint256 tokenAAmount, uint256 tokenBAmount) {

        (uint256 reservesA, uint256 reservesB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, tokenA, tokenB));
        bool feeOn = IUniswapV2Factory(factory).feeTo() != address(0);
        uint kLast = feeOn ? pair.kLast() : 0;
        uint totalSupply = pair.totalSupply();
        return computeLiquidityValue(reservesA, reservesB, totalSupply, liquidityAmount, feeOn, kLast);
    }

    function getLiquidityValueAfterArbitrageToPrice(
        address factory,
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 liquidityAmount
    ) internal view returns (
        uint256 tokenAAmount,
        uint256 tokenBAmount
    ) {

        bool feeOn = IUniswapV2Factory(factory).feeTo() != address(0);
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, tokenA, tokenB));
        uint kLast = feeOn ? pair.kLast() : 0;
        uint totalSupply = pair.totalSupply();

        require(totalSupply >= liquidityAmount && liquidityAmount > 0, 'ComputeLiquidityValue: LIQUIDITY_AMOUNT');

        (uint reservesA, uint reservesB) = getReservesAfterArbitrage(factory, tokenA, tokenB, truePriceTokenA, truePriceTokenB);

        return computeLiquidityValue(reservesA, reservesB, totalSupply, liquidityAmount, feeOn, kLast);
    }
}


library Math {

    function min(uint x, uint y) internal pure returns (uint z) {

        z = x < y ? x : y;
    }

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

interface IERC20 {

    
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity >=0.6.8;



contract LiquidityMigrator {

    
    using SafeMath for uint;

    IUniswapV2Router02 router;
    uint constant MIN_ETH = 5e17;

    constructor(address _router) public {
        router = IUniswapV2Router02(_router);
    }

    function migrate(address _token, address pair,uint amount, uint slippage,uint deadline) external returns (uint,uint) {

        address token = _token; 
        require(IUniswapV2Pair(pair).token0() == router.WETH() || IUniswapV2Pair(pair).token1() == router.WETH());
        SafeERC20.safeTransferFrom(IERC20(pair),msg.sender,address(this),amount);
        removeLiquidity(pair,amount);
        uint samount0;
        uint samount1;
        address changeToken = IUniswapV2Pair(pair).token0() == router.WETH() ? (IUniswapV2Pair(pair).token1()) : (IUniswapV2Pair(pair).token0());
        (uint ethAmount,uint changeAmount) = (IERC20(router.WETH()).balanceOf(address(this)),IERC20(changeToken).balanceOf(address(this)));
        if (checkReserves(changeToken,router.WETH(),changeAmount) && swapPrice(changeToken,router.WETH(),changeAmount) >= MIN_ETH) {
            samount0 = swap(router.WETH(),token,ethAmount,slippage,deadline);
            samount1 = swap(changeToken,router.WETH(),changeAmount,slippage,deadline);
        } else {
            samount0 = swap(router.WETH(),token,ethAmount.div(2),slippage,deadline);
            samount1 = ethAmount.div(2);
            SafeERC20.safeTransfer(IERC20(changeToken), msg.sender, changeAmount);
        }
        addLiquidity(token, token,router.WETH(),samount0,samount1,msg.sender);
        
        return (samount0, samount1);
    }
    
    function removeLiquidity(address pair,uint amount) internal returns (uint,uint) {

        SafeERC20.safeTransfer(IERC20(pair),pair,amount);
        return IUniswapV2Pair(pair).burn(address(this));
    }
    
    function addLiquidity(address token, address token0,address token1,uint amount0,uint amount1,address to) internal returns (uint) {

        (amount0,amount1) = shapeReservesChange(token,router.WETH(),amount0,amount1);
        address pair = UniswapV2Library.pairFor(router.factory(),token0,token1);
        SafeERC20.safeTransfer(IERC20(token0),pair,amount0);
        SafeERC20.safeTransfer(IERC20(token1),pair,amount1);
        return IUniswapV2Pair(pair).mint(to);
    }
    
    function swap(address tokenIn,address tokenOut,uint amount,uint slippagePercent,uint deadline) internal returns (uint) {

        address pair = UniswapV2Library.pairFor(router.factory(),tokenIn,tokenOut);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        (uint reserveIn,uint reserveOut) = UniswapV2Library.getReserves(router.factory(),tokenIn,tokenOut);
        uint out = slippage(UniswapV2Library.getAmountOut(IERC20(tokenIn).balanceOf(pair),reserveIn,reserveOut),slippagePercent);
        SafeERC20.safeApprove(IERC20(tokenIn),address(router),amount);
        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,out,path,address(this),deadline);
        return IERC20(tokenOut).balanceOf(address(this));
    }

    function checkReserves(address tokenIn,address tokenOut,uint amount) internal view returns (bool) {

        (,uint reserveOut) = UniswapV2Library.getReserves(router.factory(),tokenIn,tokenOut);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        uint out = UniswapV2Library.getAmountsOut(router.factory(),amount,path)[1];
        if (reserveOut >= out) {
            return true;
        }
        
        return false;
    }
    
    function checkReserves(address tokenIn,address tokenOut,uint amount,uint reserveOut) internal view returns (bool) {

        if (tokenIn == tokenOut) {
            return true;
        }
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        uint out = UniswapV2Library.getAmountsOut(router.factory(),amount,path)[1];
        if (reserveOut >= out) {
            return true;
        }
        
        return false;
    }

    function slippage(uint amount,uint percent) internal pure returns (uint) {

        return amount.sub(amount.mul(percent).div(100));
}

    function shapeReservesChange(address token0,address token1,uint amount0,uint amount1) internal returns (uint,uint) {

        (uint reserve0,uint reserve1) = UniswapV2Library.getReserves(router.factory(),token0,token1);
        if (amount0 > amount1.mul(reserve0).div(reserve1)) {
            SafeERC20.safeTransfer(IERC20(token0),msg.sender,amount0.sub(amount1.mul(reserve0).div(reserve1)));
            amount0 = amount1.mul(reserve0).div(reserve1);
        } else if (amount1 > amount0.mul(reserve1).div(reserve0)) {
            SafeERC20.safeTransfer(IERC20(token1),msg.sender,amount1.sub(amount0.mul(reserve1).div(reserve0)));
            amount1 = amount0.mul(reserve1).div(reserve0);
        }
        return (amount0,amount1);
    }

    function shapeReserves(address token0,address token1,uint amount0,uint amount1) internal view returns (uint,uint) {

        (uint reserve0,uint reserve1) = UniswapV2Library.getReserves(router.factory(),token0,token1);
        if (amount0 > amount1.mul(reserve0).div(reserve1)) {
            amount0 = amount1.mul(reserve0).div(reserve1);
        } else if (amount1 > amount0.mul(reserve1).div(reserve0)) {
            amount1 = amount0.mul(reserve1).div(reserve0);
        }
        return (amount0,amount1);
    }

    function fromPair(address token, address pair,uint amount) external view returns (uint) {

        require(IUniswapV2Pair(pair).token0() == router.WETH() || IUniswapV2Pair(pair).token1() == router.WETH());
        (uint amount0,uint amount1) = UniswapV2LiquidityMathLibrary.getLiquidityValue(router.factory(),IUniswapV2Pair(pair).token0(),IUniswapV2Pair(pair).token1(),amount);
        address changeToken = IUniswapV2Pair(pair).token0() == router.WETH() ? (IUniswapV2Pair(pair).token1()) : (IUniswapV2Pair(pair).token0());
        (uint ethAmount,uint changeAmount) = IUniswapV2Pair(pair).token0() == router.WETH() ? (amount0,amount1) : (amount1,amount0);
        (,uint reserve) = UniswapV2Library.getReserves(router.factory(),changeToken,router.WETH());
        return fromPairCon(pair, changeToken, token, changeAmount, reserve, ethAmount);
    }
    
    
    function fromPairCon(address pair, address changeToken, address token, uint changeAmount, uint reserve, uint ethAmount) internal view returns(uint) {

        uint samount0;
        uint samount1;
        
        (uint reserveIn,uint reserveOut) = UniswapV2Library.getReserves(router.factory(),changeToken,router.WETH());
        (uint reserve0,uint reserve1) = UniswapV2Library.getReserves(router.factory(),token,router.WETH());
        if (checkReserves(changeToken,router.WETH(),changeAmount,reserve.sub(ethAmount)) && UniswapV2Library.getAmountOut(changeAmount,reserveIn.sub(changeAmount),reserveOut.sub(ethAmount)) >= MIN_ETH) {
            samount0 = swapPrice(router.WETH(),token,ethAmount);
            reserve0 = reserve0.sub(swapPrice(router.WETH(),token,ethAmount));
            reserve1 = reserve1.add(ethAmount);
            samount1 = UniswapV2Library.getAmountOut(changeAmount,reserveIn.sub(changeAmount),reserveOut.sub(ethAmount));
        } else {
            samount0 = swapPrice(router.WETH(),token,ethAmount.div(2));
            reserve0 = reserve0.sub(samount0);
            reserve1 = reserve1.add(ethAmount.div(2));
            samount1 = ethAmount.div(2);
        }
        
        (samount0,samount0) = shapeReserves(token,router.WETH(),samount0,samount1);
        return calculateLiquidity(pair,samount0,samount1,reserve0,reserve1);
    }
    
    
    
    function calculateLiquidity(address pair,uint samount0,uint samount1,uint _reserve0,uint _reserve1) internal view returns (uint) {

        uint _totalSupply = IERC20(pair).totalSupply();
        uint liquidity;
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(samount0.mul(samount1)).sub(10**3);
        } else {
            liquidity = Math.min(samount0.mul(_totalSupply) / _reserve0, samount1.mul(_totalSupply) / _reserve1);
        }
        return liquidity;
    }
    
    function swapPrice(address tokenIn,address tokenOut,uint amount) internal view returns (uint) {

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        return UniswapV2Library.getAmountsOut(router.factory(),amount,path)[1];
    }
    

    function getTokenPrice(address pair) external view returns (uint) {

        require(IUniswapV2Pair(pair).token0() == router.WETH() || IUniswapV2Pair(pair).token1() == router.WETH());
        address pairtoken = IUniswapV2Pair(pair).token0() == router.WETH() ? (IUniswapV2Pair(pair).token1()) : (IUniswapV2Pair(pair).token0());
        (uint reserve0,uint reserve1) = UniswapV2Library.getReserves(router.factory(),IUniswapV2Pair(pair).token0(),IUniswapV2Pair(pair).token1());
        uint price = IUniswapV2Pair(pair).token0() == router.WETH() ? (reserve0.mul(1e18).div(reserve1)) : (reserve1.mul(1e18).div(reserve0));
        return price.div(1 ** IERC20(pairtoken).decimals());
    }
    
    function getTokenSymbol(address pair) external view returns (string memory) {

        require(IUniswapV2Pair(pair).token0() == router.WETH() || IUniswapV2Pair(pair).token1() == router.WETH());
        address pairtoken = IUniswapV2Pair(pair).token0() == router.WETH() ? (IUniswapV2Pair(pair).token1()) : (IUniswapV2Pair(pair).token0());
        return IERC20(pairtoken).symbol();
    }
}