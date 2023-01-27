
pragma solidity 0.6.12;

interface IBPool {

    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);


    function getSpotPriceSansFee(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);


    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function transferFrom(
        address src,
        address dst,
        uint256 amt
    ) external returns (bool);


    function approve(address dst, uint256 amt) external returns (bool);


    function transfer(address dst, uint256 amt) external returns (bool);


    function balanceOf(address whom) external view returns (uint256);


    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


    function finalize() external;


    function rebind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function setSwapFee(uint256 swapFee) external;


    function setPublicSwap(bool publicSwap) external;


    function bind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function unbind(address token) external;


    function gulp(address token) external;


    function isBound(address token) external view returns (bool);


    function getBalance(address token) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function getSwapFee() external view returns (uint256);


    function isPublicSwap() external view returns (bool);


    function getDenormalizedWeight(address token) external view returns (uint256);


    function getTotalDenormalizedWeight() external view returns (uint256);


    function EXIT_FEE() external view returns (uint256);


    function calcPoolOutGivenSingleIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 poolAmountOut);


    function calcSingleInGivenPoolOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountIn);


    function calcSingleOutGivenPoolIn(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);


    function calcPoolInGivenSingleOut(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 poolAmountIn);


    function getCurrentTokens() external view returns (address[] memory tokens);

}// GPL-3.0-or-later
pragma solidity 0.6.12;


interface IBFactory {

    function newBPool() external returns (IBPool);


    function setBLabs(address b) external;


    function collect(IBPool pool) external;


    function isBPool(address b) external view returns (bool);


    function getBLabs() external view returns (address);

}// GPL-3.0-or-later
pragma solidity 0.6.12;



interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}// GPL-3.0-or-later
pragma solidity ^0.6.6;


contract BBronze {

    function getColor() external pure returns (bytes32) {

        return bytes32("BRONZE");
    }
}// GPL-3.0-or-later
pragma solidity ^0.6.6;


contract BConst is BBronze {

    uint256 public constant BONE = 10**18;

    uint256 public constant MIN_BOUND_TOKENS = 2;
    uint256 public constant MAX_BOUND_TOKENS = 8;

    uint256 public constant MIN_FEE = BONE / 10**6;
    uint256 public constant MAX_FEE = BONE / 10;
    uint256 public constant EXIT_FEE = 0;

    uint256 public constant MIN_WEIGHT = BONE;
    uint256 public constant MAX_WEIGHT = BONE * 50;
    uint256 public constant MAX_TOTAL_WEIGHT = BONE * 50;
    uint256 public constant MIN_BALANCE = BONE / 10**12;

    uint256 public constant INIT_POOL_SUPPLY = BONE * 100;

    uint256 public constant MIN_BPOW_BASE = 1 wei;
    uint256 public constant MAX_BPOW_BASE = (2 * BONE) - 1 wei;
    uint256 public constant BPOW_PRECISION = BONE / 10**10;

    uint256 public constant MAX_IN_RATIO = BONE / 2;
    uint256 public constant MAX_OUT_RATIO = (BONE / 3) + 1 wei;
}// GPL-3.0-or-later
pragma solidity ^0.6.6;




contract BNum is BConst {

    function btoi(uint256 a) internal pure returns (uint256) {

        return a / BONE;
    }

    function bfloor(uint256 a) internal pure returns (uint256) {

        return btoi(a) * BONE;
    }

    function badd(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint256 a, uint256 b) internal pure returns (uint256) {

        (uint256 c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint256 a, uint256 b) internal pure returns (uint256, bool) {

        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    function bmul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint256 c1 = c0 + (BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint256 c2 = c1 / BONE;
        return c2;
    }

    function bdiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL"); // bmul overflow
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require
        uint256 c2 = c1 / b;
        return c2;
    }

    function bpowi(uint256 a, uint256 n) internal pure returns (uint256) {

        uint256 z = n % 2 != 0 ? a : BONE;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

    function bpow(uint256 base, uint256 exp) internal pure returns (uint256) {

        require(base >= MIN_BPOW_BASE, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= MAX_BPOW_BASE, "ERR_BPOW_BASE_TOO_HIGH");

        uint256 whole = bfloor(exp);
        uint256 remain = bsub(exp, whole);

        uint256 wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint256 partialResult = bpowApprox(base, remain, BPOW_PRECISION);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(
        uint256 base,
        uint256 exp,
        uint256 precision
    ) internal pure returns (uint256) {

        uint256 a = exp;
        (uint256 x, bool xneg) = bsubSign(base, BONE);
        uint256 term = BONE;
        uint256 sum = term;
        bool negative = false;

        for (uint256 i = 1; term >= precision; i++) {
            uint256 bigK = i * BONE;
            (uint256 c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }
}// GPL-3.0-or-later
pragma solidity ^0.6.6;


contract BMath is BBronze, BConst, BNum {

    function calcSpotPrice(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 swapFee
    ) public pure returns (uint256 spotPrice) {

        uint256 numer = bdiv(tokenBalanceIn, tokenWeightIn);
        uint256 denom = bdiv(tokenBalanceOut, tokenWeightOut);
        uint256 ratio = bdiv(numer, denom);
        uint256 scale = bdiv(BONE, bsub(BONE, swapFee));
        return (spotPrice = bmul(ratio, scale));
    }

    function calcOutGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) public pure returns (uint256 tokenAmountOut) {

        uint256 weightRatio = bdiv(tokenWeightIn, tokenWeightOut);
        uint256 adjustedIn = bsub(BONE, swapFee);
        adjustedIn = bmul(tokenAmountIn, adjustedIn);
        uint256 y = bdiv(tokenBalanceIn, badd(tokenBalanceIn, adjustedIn));
        uint256 foo = bpow(y, weightRatio);
        uint256 bar = bsub(BONE, foo);
        tokenAmountOut = bmul(tokenBalanceOut, bar);
        return tokenAmountOut;
    }

    function calcInGivenOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) public pure returns (uint256 tokenAmountIn) {

        uint256 weightRatio = bdiv(tokenWeightOut, tokenWeightIn);
        uint256 diff = bsub(tokenBalanceOut, tokenAmountOut);
        uint256 y = bdiv(tokenBalanceOut, diff);
        uint256 foo = bpow(y, weightRatio);
        foo = bsub(foo, BONE);
        tokenAmountIn = bsub(BONE, swapFee);
        tokenAmountIn = bdiv(bmul(tokenBalanceIn, foo), tokenAmountIn);
        return tokenAmountIn;
    }

    function calcPoolOutGivenSingleIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) public pure returns (uint256 poolAmountOut) {

        uint256 normalizedWeight = bdiv(tokenWeightIn, totalWeight);
        uint256 zaz = bmul(bsub(BONE, normalizedWeight), swapFee);
        uint256 tokenAmountInAfterFee = bmul(tokenAmountIn, bsub(BONE, zaz));

        uint256 newTokenBalanceIn = badd(tokenBalanceIn, tokenAmountInAfterFee);
        uint256 tokenInRatio = bdiv(newTokenBalanceIn, tokenBalanceIn);

        uint256 poolRatio = bpow(tokenInRatio, normalizedWeight);
        uint256 newPoolSupply = bmul(poolRatio, poolSupply);
        poolAmountOut = bsub(newPoolSupply, poolSupply);
        return poolAmountOut;
    }

    function calcSingleInGivenPoolOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountOut,
        uint256 swapFee
    ) public pure returns (uint256 tokenAmountIn) {

        uint256 normalizedWeight = bdiv(tokenWeightIn, totalWeight);
        uint256 newPoolSupply = badd(poolSupply, poolAmountOut);
        uint256 poolRatio = bdiv(newPoolSupply, poolSupply);

        uint256 boo = bdiv(BONE, normalizedWeight);
        uint256 tokenInRatio = bpow(poolRatio, boo);
        uint256 newTokenBalanceIn = bmul(tokenInRatio, tokenBalanceIn);
        uint256 tokenAmountInAfterFee = bsub(newTokenBalanceIn, tokenBalanceIn);
        uint256 zar = bmul(bsub(BONE, normalizedWeight), swapFee);
        tokenAmountIn = bdiv(tokenAmountInAfterFee, bsub(BONE, zar));
        return tokenAmountIn;
    }

    function calcSingleOutGivenPoolIn(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountIn,
        uint256 swapFee
    ) public pure returns (uint256 tokenAmountOut) {

        uint256 normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        uint256 poolAmountInAfterExitFee = bmul(poolAmountIn, bsub(BONE, EXIT_FEE));
        uint256 newPoolSupply = bsub(poolSupply, poolAmountInAfterExitFee);
        uint256 poolRatio = bdiv(newPoolSupply, poolSupply);

        uint256 tokenOutRatio = bpow(poolRatio, bdiv(BONE, normalizedWeight));
        uint256 newTokenBalanceOut = bmul(tokenOutRatio, tokenBalanceOut);

        uint256 tokenAmountOutBeforeSwapFee = bsub(tokenBalanceOut, newTokenBalanceOut);

        uint256 zaz = bmul(bsub(BONE, normalizedWeight), swapFee);
        tokenAmountOut = bmul(tokenAmountOutBeforeSwapFee, bsub(BONE, zaz));
        return tokenAmountOut;
    }

    function calcPoolInGivenSingleOut(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) public pure returns (uint256 poolAmountIn) {

        uint256 normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        uint256 zoo = bsub(BONE, normalizedWeight);
        uint256 zar = bmul(zoo, swapFee);
        uint256 tokenAmountOutBeforeSwapFee = bdiv(tokenAmountOut, bsub(BONE, zar));

        uint256 newTokenBalanceOut = bsub(tokenBalanceOut, tokenAmountOutBeforeSwapFee);
        uint256 tokenOutRatio = bdiv(newTokenBalanceOut, tokenBalanceOut);

        uint256 poolRatio = bpow(tokenOutRatio, normalizedWeight);
        uint256 newPoolSupply = bmul(poolRatio, poolSupply);
        uint256 poolAmountInAfterExitFee = bsub(poolSupply, newPoolSupply);

        poolAmountIn = bdiv(poolAmountInAfterExitFee, bsub(BONE, EXIT_FEE));
        return poolAmountIn;
    }
}// MIT
pragma solidity >=0.6.6;


contract BRouter is BMath {

    uint256 constant MAX_UINT = 2**256 - 1;

    address public immutable factory;

    mapping(address => mapping(address => address)) public getPool;

    address[] public allPools;

    mapping(address => address) public initialLiquidityProviders;

    modifier ensure(uint256 deadline) {

        require(deadline >= block.timestamp, "DEADLINE EXPIRED");
        _;
    }

    constructor(address _factory) public {
        factory = _factory;
    }

    function addLiquidity(
        address tokenA, // Option
        address tokenB, // Collateral
        uint256 amountA, // Amount of Options to add to liquidity
        uint256 amountB // Amount of Collateral to add to liquidity
    ) external returns (uint256 poolTokens) {

        address poolAddress = getPool[tokenA][tokenB];
        IBPool pool;
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA), "Token A transfer failed");
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountB), "Token B transfer failed");

        if (poolAddress == address(0)) {
            pool = IBFactory(factory).newBPool();
            initialLiquidityProviders[address(pool)] = msg.sender;
            IERC20(tokenA).approve(address(pool), MAX_UINT);
            IERC20(tokenB).approve(address(pool), MAX_UINT);
            pool.bind(tokenA, amountA, BONE);
            pool.bind(tokenB, amountB, BONE);
            pool.setSwapFee(0.05 * 1e18); // 5% fee
            pool.finalize();
            addPool(tokenA, tokenB, address(pool)); // Add pool to the pool registry
        } else {
            pool = IBPool(poolAddress);
            uint256 poolTokensA = pool.getBalance(tokenA);
            uint256 poolTokensB = pool.getBalance(tokenB);
            uint256 ratioTokenA = bdiv(amountA, poolTokensA);
            uint256 ratioTokenB = bdiv(amountB, poolTokensB);
            uint256 poolAmountOut = bmul(pool.totalSupply(), min(ratioTokenA, ratioTokenB));
            poolAmountOut = bmul(poolAmountOut, 0.99999999 * 1e18);
            uint256[] memory maxAmountsIn = new uint256[](2);
            maxAmountsIn[0] = amountA;
            maxAmountsIn[1] = amountB;
            pool.joinPool(poolAmountOut, maxAmountsIn);
        }
        uint256 collected = pool.balanceOf(address(this));
        require(pool.transfer(msg.sender, collected), "ERR_ERC20_FAILED");

        uint256 stuckAmountA = IERC20(tokenA).balanceOf(address(this));
        uint256 stuckAmountB = IERC20(tokenB).balanceOf(address(this));

        require(IERC20(tokenA).transfer(msg.sender, stuckAmountA), "ERR_ERC20_FAILED");
        require(IERC20(tokenB).transfer(msg.sender, stuckAmountB), "ERR_ERC20_FAILED");

        return collected;
    }

    function removeLiquidity(
        address tokenA, // Option
        address tokenB, // Collateral
        uint256 poolAmountIn // Amount of pool share tokens to give up
    ) external returns (uint256[] memory amounts) {

        IBPool pool = IBPool(getPool[tokenA][tokenB]);
        pool.transferFrom(msg.sender, address(this), poolAmountIn);
        pool.approve(address(pool), poolAmountIn);

        if (bsub(pool.totalSupply(), poolAmountIn) == 0) {
            require(msg.sender == initialLiquidityProviders[address(pool)]);
        }

        uint256[] memory minAmountsOut = new uint256[](2);
        minAmountsOut[0] = 0;
        minAmountsOut[1] = 0;
        pool.exitPool(poolAmountIn, minAmountsOut);

        amounts = new uint256[](2);
        amounts[0] = IERC20(tokenA).balanceOf(address(this));
        amounts[1] = IERC20(tokenB).balanceOf(address(this));
        require(IERC20(tokenA).transfer(msg.sender, amounts[0]), "ERR_ERC20_FAILED");
        require(IERC20(tokenB).transfer(msg.sender, amounts[1]), "ERR_ERC20_FAILED");
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter) {

        return _swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline, MAX_UINT);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter) {

        return _swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline, maxPrice);
    }

    function getReserves(address poolAddress) external view returns (uint256[] memory reserves) {

        IBPool pool = IBPool(poolAddress);
        address[] memory tokens = pool.getCurrentTokens();
        reserves = new uint256[](2);
        reserves[0] = pool.getBalance(tokens[0]);
        reserves[1] = pool.getBalance(tokens[1]);
        return reserves;
    }

    function getReserves(address tokenA, address tokenB) external view returns (uint256[] memory reserves) {

        IBPool pool = getPoolByTokens(tokenA, tokenB);
        reserves = new uint256[](2);
        reserves[0] = pool.getBalance(tokenA);
        reserves[1] = pool.getBalance(tokenB);
        return reserves;
    }

    function getSpotPriceSansFee(address tokenA, address tokenB) external view returns (uint256 quote) {

        IBPool pool = getPoolByTokens(tokenA, tokenB);
        return pool.getSpotPriceSansFee(tokenA, tokenB);
    }

    function getSpotPriceWithFee(address tokenA, address tokenB) external view returns (uint256 amountOut) {

        IBPool pool = getPoolByTokens(tokenA, tokenB);
        return pool.getSpotPrice(tokenA, tokenB);
    }

    function getPoolShare(
        address tokenA,
        address tokenB,
        address owner
    ) external view returns (uint256 tokens, uint256 poolTokens) {

        IBPool pool = getPoolByTokens(tokenA, tokenB);
        tokens = pool.balanceOf(owner);
        poolTokens = pool.totalSupply();
    }

    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amountOut) {

        IBPool pool = getPoolByTokens(tokenIn, tokenOut);
        return
            calcOutGivenIn(
                pool.getBalance(tokenIn),
                pool.getDenormalizedWeight(tokenIn),
                pool.getBalance(tokenOut),
                pool.getDenormalizedWeight(tokenOut),
                amountIn,
                pool.getSwapFee()
            );
    }

    function getAmountIn(
        uint256 amountOut,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amountIn) {

        IBPool pool = getPoolByTokens(tokenIn, tokenOut);
        return
            calcInGivenOut(
                pool.getBalance(tokenIn),
                pool.getDenormalizedWeight(tokenIn),
                pool.getBalance(tokenOut),
                pool.getDenormalizedWeight(tokenOut),
                amountOut,
                pool.getSwapFee()
            );
    }

    function getSwapFee(address tokenA, address tokenB) external view returns (uint256 fee) {

        IBPool pool = getPoolByTokens(tokenA, tokenB);
        return pool.getSwapFee();
    }

    function getSwapFee(address poolAddress) external view returns (uint256 fee) {

        return IBPool(poolAddress).getSwapFee();
    }

    function getPoolByTokens(address tokenA, address tokenB) public view returns (IBPool pool) {

        address poolAddress = getPool[tokenA][tokenB];
        require(poolAddress != address(0), "Pool doesn't exist");
        return IBPool(poolAddress);
    }

    function getAllPoolsLength() public view returns (uint256) {

        return allPools.length;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function addPool(
        address tokenA,
        address tokenB,
        address poolAddress
    ) internal {

        getPool[tokenA][tokenB] = poolAddress;
        getPool[tokenB][tokenA] = poolAddress; // populate mapping in the reverse direction
        allPools.push(poolAddress);
    }

    function _swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint256 maxPrice
    ) internal ensure(deadline) returns (uint256 tokenAmountOut, uint256 spotPriceAfter) {

        IBPool pool = getPoolByTokens(path[0], path[1]);
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        (tokenAmountOut, spotPriceAfter) = pool.swapExactAmountIn(path[0], amountIn, path[1], amountOutMin, maxPrice);

        uint256 amount = IERC20(path[1]).balanceOf(address(this)); // Think if we should use tokenAmountOut
        require(IERC20(path[1]).transfer(to, amount), "ERR_ERC20_FAILED");
    }
}