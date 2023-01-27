

pragma solidity 0.5.17;

interface IXPool {

    event Approval(address indexed src, address indexed dst, uint256 amt);
    event Transfer(address indexed src, address indexed dst, uint256 amt);

    function totalSupply() external view returns (uint256);


    function balanceOf(address whom) external view returns (uint256);


    function allowance(address src, address dst)
        external
        view
        returns (uint256);


    function approve(address dst, uint256 amt) external returns (bool);


    function transfer(address dst, uint256 amt) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amt
    ) external returns (bool);


    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOut(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function swapExactAmountInRefer(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice,
        address referrer
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOutRefer(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice,
        address referrer
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function isBound(address token) external view returns (bool);


    function getFinalTokens() external view returns (address[] memory tokens);


    function getBalance(address token) external view returns (uint256);


    function swapFee() external view returns (uint256);


    function exitFee() external view returns (uint256);


    function finalized() external view returns (uint256);


    function controller() external view returns (uint256);


    function isFarmPool() external view returns (uint256);


    function xconfig() external view returns (uint256);


    function getDenormalizedWeight(address) external view returns (uint256);


    function getTotalDenormalizedWeight() external view returns (uint256);


    function getVersion() external view returns (bytes32);


    function calcInGivenOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut,
        uint256 _swapFee
    ) external pure returns (uint256 tokenAmountIn);


    function calcOutGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn,
        uint256 _swapFee
    ) external pure returns (uint256 tokenAmountOut);


    function setController(address _controller) external;


    function setExitFee(uint256 newFee) external;


    function finalize(uint256 _swapFee) external;


    function bind(address token, uint256 denorm) external;


    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn)
        external;


    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut)
        external;


    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);


    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);


    function updateSafu(address safu, uint256 fee) external;


    function updateFarm(bool isFarm) external;

}


pragma solidity 0.5.17;


interface IXFactory {

    function newXPool() external returns (IXPool);

}


pragma solidity 0.5.17;

interface IXConfig {

    function getCore() external view returns (address);


    function getSAFU() external view returns (address);


    function getMaxExitFee() external view returns (uint256);


    function getSafuFee() external view returns (uint256);


    function getSwapProxy() external view returns (address);


    function dedupPool(address[] calldata tokens, uint256[] calldata denorms)
        external
        returns (bool exist, bytes32 sig);


    function addPoolSig(bytes32 sig, address pool) external;

}


pragma solidity 0.5.17;

interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _to, uint256 _value)
        external
        returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function approve(address _spender, uint256 _value)
        external
        returns (bool success);


    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

}


pragma solidity 0.5.17;

library XNum {

    uint256 public constant BONE = 10**18;
    uint256 public constant MIN_BPOW_BASE = 1 wei;
    uint256 public constant MAX_BPOW_BASE = (2 * BONE) - 1 wei;
    uint256 public constant BPOW_PRECISION = BONE / 10**10;

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

    function bsubSign(uint256 a, uint256 b)
        internal
        pure
        returns (uint256, bool)
    {

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
}


pragma solidity 0.5.17;


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash =
            0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call.value(amount).gas(9100)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}


pragma solidity 0.5.17;




library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}


pragma solidity 0.5.17;


contract ReentrancyGuard {

    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;








interface IWETH {

    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address, uint256) external returns (bool);


    function transfer(address to, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    function deposit() external payable;


    function withdraw(uint256 amount) external;

}

contract XSwapProxyV1 is ReentrancyGuard {

    using XNum for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant MAX = 2**256 - 1;
    uint256 public constant BONE = 10**18;
    uint256 public constant MIN_BOUND_TOKENS = 2;
    uint256 public constant MAX_BOUND_TOKENS = 8;

    uint256 public constant MIN_BATCH_SWAPS = 1;
    uint256 public constant MAX_BATCH_SWAPS = 4;

    address public constant ETH_ADDR =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    IWETH weth;

    IXConfig public xconfig;

    constructor(address _weth, address _xconfig) public {
        weth = IWETH(_weth);
        xconfig = IXConfig(_xconfig);
    }

    function() external payable {}

    struct Swap {
        address pool;
        uint256 tokenInParam; // tokenInAmount / maxAmountIn
        uint256 tokenOutParam; // minAmountOut / tokenAmountOut
        uint256 maxPrice;
    }

    function batchSwapExactIn(
        Swap[] memory swaps,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut
    ) public payable returns (uint256 totalAmountOut) {

        return
            batchSwapExactInRefer(
                swaps,
                tokenIn,
                tokenOut,
                totalAmountIn,
                minTotalAmountOut,
                address(0x0)
            );
    }

    function batchSwapExactInRefer(
        Swap[] memory swaps,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut,
        address referrer
    ) public payable nonReentrant returns (uint256 totalAmountOut) {

        require(
            swaps.length >= MIN_BATCH_SWAPS && swaps.length <= MAX_BATCH_SWAPS,
            "ERR_BATCH_COUNT"
        );

        IERC20 TI = IERC20(tokenIn);
        if (transferFromAllTo(TI, totalAmountIn, address(this))) {
            TI = IERC20(address(weth));
        }

        IERC20 TO = IERC20(tokenOut);
        if (tokenOut == ETH_ADDR) {
            TO = IERC20(address(weth));
        }
        require(TI != TO, "ERR_SAME_TOKEN");

        uint256 actualTotalIn = 0;
        for (uint256 i = 0; i < swaps.length; i++) {
            Swap memory swap = swaps[i];
            IXPool pool = IXPool(swap.pool);

            if (TI.allowance(address(this), swap.pool) < totalAmountIn) {
                TI.safeApprove(swap.pool, 0);
                TI.safeApprove(swap.pool, MAX);
            }

            (uint256 tokenAmountOut, ) =
                pool.swapExactAmountInRefer(
                    address(TI),
                    swap.tokenInParam,
                    address(TO),
                    swap.tokenOutParam,
                    swap.maxPrice,
                    referrer
                );

            actualTotalIn = actualTotalIn.badd(swap.tokenInParam);
            totalAmountOut = tokenAmountOut.badd(totalAmountOut);
        }
        require(actualTotalIn <= totalAmountIn, "ERR_ACTUAL_IN");
        require(totalAmountOut >= minTotalAmountOut, "ERR_LIMIT_OUT");

        transferAll(tokenOut, totalAmountOut);
        transferAll(tokenIn, getBalance(address(TI)));
    }

    function batchSwapExactOut(
        Swap[] memory swaps,
        address tokenIn,
        address tokenOut,
        uint256 maxTotalAmountIn
    ) public payable returns (uint256 totalAmountIn) {

        return
            batchSwapExactOutRefer(
                swaps,
                tokenIn,
                tokenOut,
                maxTotalAmountIn,
                address(0x0)
            );
    }

    function batchSwapExactOutRefer(
        Swap[] memory swaps,
        address tokenIn,
        address tokenOut,
        uint256 maxTotalAmountIn,
        address referrer
    ) public payable nonReentrant returns (uint256 totalAmountIn) {

        require(
            swaps.length >= MIN_BATCH_SWAPS && swaps.length <= MAX_BATCH_SWAPS,
            "ERR_BATCH_COUNT"
        );

        IERC20 TI = IERC20(tokenIn);
        if (transferFromAllTo(TI, maxTotalAmountIn, address(this))) {
            TI = IERC20(address(weth));
        }

        IERC20 TO = IERC20(tokenOut);
        if (tokenOut == ETH_ADDR) {
            TO = IERC20(address(weth));
        }
        require(TI != TO, "ERR_SAME_TOKEN");

        for (uint256 i = 0; i < swaps.length; i++) {
            Swap memory swap = swaps[i];
            IXPool pool = IXPool(swap.pool);

            if (TI.allowance(address(this), swap.pool) < maxTotalAmountIn) {
                TI.safeApprove(swap.pool, 0);
                TI.safeApprove(swap.pool, MAX);
            }

            (uint256 tokenAmountIn, ) =
                pool.swapExactAmountOutRefer(
                    address(TI),
                    swap.tokenInParam,
                    address(TO),
                    swap.tokenOutParam,
                    swap.maxPrice,
                    referrer
                );
            totalAmountIn = tokenAmountIn.badd(totalAmountIn);
        }
        require(totalAmountIn <= maxTotalAmountIn, "ERR_LIMIT_IN");

        transferAll(tokenOut, getBalance(tokenOut));
        transferAll(tokenIn, getBalance(address(TI)));
    }

    struct MSwap {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount; // tokenInAmount / tokenOutAmount
        uint256 limitReturnAmount; // minAmountOut / maxAmountIn
        uint256 maxPrice;
    }

    function multihopBatchSwapExactIn(
        MSwap[][] memory swapSequences,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut
    ) public payable returns (uint256 totalAmountOut) {

        return
            multihopBatchSwapExactInRefer(
                swapSequences,
                tokenIn,
                tokenOut,
                totalAmountIn,
                minTotalAmountOut,
                address(0x0)
            );
    }

    function multihopBatchSwapExactInRefer(
        MSwap[][] memory swapSequences,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut,
        address referrer
    ) public payable nonReentrant returns (uint256 totalAmountOut) {

        require(
            swapSequences.length >= MIN_BATCH_SWAPS &&
                swapSequences.length <= MAX_BATCH_SWAPS,
            "ERR_BATCH_COUNT"
        );

        IERC20 TI = IERC20(tokenIn);
        if (transferFromAllTo(TI, totalAmountIn, address(this))) {
            TI = IERC20(address(weth));
        }

        uint256 actualTotalIn = 0;
        for (uint256 i = 0; i < swapSequences.length; i++) {
            require(
                address(TI) == swapSequences[i][0].tokenIn,
                "ERR_NOT_MATCH"
            );
            actualTotalIn = actualTotalIn.badd(swapSequences[i][0].swapAmount);

            uint256 tokenAmountOut = 0;
            for (uint256 k = 0; k < swapSequences[i].length; k++) {
                MSwap memory swap = swapSequences[i][k];

                IERC20 SwapTokenIn = IERC20(swap.tokenIn);
                if (k == 1) {
                    swap.swapAmount = tokenAmountOut;
                }

                if (
                    SwapTokenIn.allowance(address(this), swap.pool) <
                    totalAmountIn
                ) {
                    SwapTokenIn.safeApprove(swap.pool, 0);
                    SwapTokenIn.safeApprove(swap.pool, MAX);
                }

                (tokenAmountOut, ) = IXPool(swap.pool).swapExactAmountInRefer(
                    swap.tokenIn,
                    swap.swapAmount,
                    swap.tokenOut,
                    swap.limitReturnAmount,
                    swap.maxPrice,
                    referrer
                );
            }
            totalAmountOut = tokenAmountOut.badd(totalAmountOut);
        }

        require(actualTotalIn <= totalAmountIn, "ERR_ACTUAL_IN");
        require(totalAmountOut >= minTotalAmountOut, "ERR_LIMIT_OUT");

        transferAll(tokenOut, totalAmountOut);
        transferAll(tokenIn, getBalance(address(TI)));
    }

    function multihopBatchSwapExactOut(
        MSwap[][] memory swapSequences,
        address tokenIn,
        address tokenOut,
        uint256 maxTotalAmountIn
    ) public payable returns (uint256 totalAmountIn) {

        return
            multihopBatchSwapExactOutRefer(
                swapSequences,
                tokenIn,
                tokenOut,
                maxTotalAmountIn,
                address(0x0)
            );
    }

    function multihopBatchSwapExactOutRefer(
        MSwap[][] memory swapSequences,
        address tokenIn,
        address tokenOut,
        uint256 maxTotalAmountIn,
        address referrer
    ) public payable nonReentrant returns (uint256 totalAmountIn) {

        require(
            swapSequences.length >= MIN_BATCH_SWAPS &&
                swapSequences.length <= MAX_BATCH_SWAPS,
            "ERR_BATCH_COUNT"
        );

        IERC20 TI = IERC20(tokenIn);
        if (transferFromAllTo(TI, maxTotalAmountIn, address(this))) {
            TI = IERC20(address(weth));
        }

        for (uint256 i = 0; i < swapSequences.length; i++) {
            require(
                address(TI) == swapSequences[i][0].tokenIn,
                "ERR_NOT_MATCH"
            );

            uint256 tokenAmountInFirstSwap = 0;
            if (swapSequences[i].length == 1) {
                MSwap memory swap = swapSequences[i][0];
                IERC20 SwapTokenIn = IERC20(swap.tokenIn);

                if (
                    SwapTokenIn.allowance(address(this), swap.pool) <
                    maxTotalAmountIn
                ) {
                    SwapTokenIn.safeApprove(swap.pool, 0);
                    SwapTokenIn.safeApprove(swap.pool, MAX);
                }

                (tokenAmountInFirstSwap, ) = IXPool(swap.pool)
                    .swapExactAmountOutRefer(
                    swap.tokenIn,
                    swap.limitReturnAmount,
                    swap.tokenOut,
                    swap.swapAmount,
                    swap.maxPrice,
                    referrer
                );
            } else {
                uint256 intermediateTokenAmount;
                MSwap memory secondSwap = swapSequences[i][1];
                IXPool poolSecondSwap = IXPool(secondSwap.pool);
                intermediateTokenAmount = poolSecondSwap.calcInGivenOut(
                    poolSecondSwap.getBalance(secondSwap.tokenIn),
                    poolSecondSwap.getDenormalizedWeight(secondSwap.tokenIn),
                    poolSecondSwap.getBalance(secondSwap.tokenOut),
                    poolSecondSwap.getDenormalizedWeight(secondSwap.tokenOut),
                    secondSwap.swapAmount,
                    poolSecondSwap.swapFee()
                );

                MSwap memory firstSwap = swapSequences[i][0];
                IERC20 FirstSwapTokenIn = IERC20(firstSwap.tokenIn);
                IXPool poolFirstSwap = IXPool(firstSwap.pool);
                if (
                    FirstSwapTokenIn.allowance(address(this), firstSwap.pool) <
                    MAX
                ) {
                    FirstSwapTokenIn.safeApprove(firstSwap.pool, 0);
                    FirstSwapTokenIn.safeApprove(firstSwap.pool, MAX);
                }

                (tokenAmountInFirstSwap, ) = poolFirstSwap.swapExactAmountOut(
                    firstSwap.tokenIn,
                    firstSwap.limitReturnAmount,
                    firstSwap.tokenOut,
                    intermediateTokenAmount, // This is the amount of token B we need
                    firstSwap.maxPrice
                );

                IERC20 SecondSwapTokenIn = IERC20(secondSwap.tokenIn);
                if (
                    SecondSwapTokenIn.allowance(
                        address(this),
                        secondSwap.pool
                    ) < MAX
                ) {
                    SecondSwapTokenIn.safeApprove(secondSwap.pool, 0);
                    SecondSwapTokenIn.safeApprove(secondSwap.pool, MAX);
                }

                poolSecondSwap.swapExactAmountOut(
                    secondSwap.tokenIn,
                    secondSwap.limitReturnAmount,
                    secondSwap.tokenOut,
                    secondSwap.swapAmount,
                    secondSwap.maxPrice
                );
            }
            totalAmountIn = tokenAmountInFirstSwap.badd(totalAmountIn);
        }

        require(totalAmountIn <= maxTotalAmountIn, "ERR_LIMIT_IN");

        transferAll(tokenOut, getBalance(tokenOut));
        transferAll(tokenIn, getBalance(address(TI)));
    }

    function create(
        address factoryAddress,
        address[] calldata tokens,
        uint256[] calldata balances,
        uint256[] calldata denorms,
        uint256 swapFee,
        uint256 exitFee
    ) external payable nonReentrant returns (address) {

        require(tokens.length == balances.length, "ERR_LENGTH_MISMATCH");
        require(tokens.length == denorms.length, "ERR_LENGTH_MISMATCH");
        require(tokens.length >= MIN_BOUND_TOKENS, "ERR_MIN_TOKENS");
        require(tokens.length <= MAX_BOUND_TOKENS, "ERR_MAX_TOKENS");

        (bool exist, bytes32 sig) = xconfig.dedupPool(tokens, denorms);
        require(!exist, "ERR_POOL_EXISTS");

        IXPool pool = IXFactory(factoryAddress).newXPool();
        bool hasETH = false;
        for (uint256 i = 0; i < tokens.length; i++) {
            if (
                transferFromAllTo(IERC20(tokens[i]), balances[i], address(pool))
            ) {
                hasETH = true;
                pool.bind(address(weth), denorms[i]);
            } else {
                pool.bind(tokens[i], denorms[i]);
            }
        }
        require(msg.value == 0 || hasETH, "ERR_INVALID_PAY");
        pool.setExitFee(exitFee);
        pool.finalize(swapFee);

        xconfig.addPoolSig(sig, address(pool));
        pool.transfer(msg.sender, pool.balanceOf(address(this)));

        return address(pool);
    }

    function joinPool(
        address poolAddress,
        uint256 poolAmountOut,
        uint256[] calldata maxAmountsIn
    ) external payable nonReentrant {

        IXPool pool = IXPool(poolAddress);

        address[] memory tokens = pool.getFinalTokens();
        require(maxAmountsIn.length == tokens.length, "ERR_LENGTH_MISMATCH");

        bool hasEth = false;
        for (uint8 i = 0; i < tokens.length; i++) {
            if (msg.value > 0 && tokens[i] == address(weth)) {
                transferFromAllAndApprove(
                    ETH_ADDR,
                    maxAmountsIn[i],
                    poolAddress
                );
                hasEth = true;
            } else {
                transferFromAllAndApprove(
                    tokens[i],
                    maxAmountsIn[i],
                    poolAddress
                );
            }
        }
        require(msg.value == 0 || hasEth, "ERR_INVALID_PAY");
        pool.joinPool(poolAmountOut, maxAmountsIn);
        for (uint8 i = 0; i < tokens.length; i++) {
            if (hasEth && tokens[i] == address(weth)) {
                transferAll(ETH_ADDR, getBalance(ETH_ADDR));
            } else {
                transferAll(tokens[i], getBalance(tokens[i]));
            }
        }
        pool.transfer(msg.sender, pool.balanceOf(address(this)));
    }

    function joinswapExternAmountIn(
        address poolAddress,
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external payable nonReentrant {

        IXPool pool = IXPool(poolAddress);

        bool hasEth = false;
        if (transferFromAllAndApprove(tokenIn, tokenAmountIn, poolAddress)) {
            hasEth = true;
        }
        require(msg.value == 0 || hasEth, "ERR_INVALID_PAY");

        if (hasEth) {
            uint256 poolAmountOut =
                pool.joinswapExternAmountIn(
                    address(weth),
                    tokenAmountIn,
                    minPoolAmountOut
                );
            pool.transfer(msg.sender, poolAmountOut);
        } else {
            uint256 poolAmountOut =
                pool.joinswapExternAmountIn(
                    tokenIn,
                    tokenAmountIn,
                    minPoolAmountOut
                );
            pool.transfer(msg.sender, poolAmountOut);
        }
    }

    function getBalance(address token) internal view returns (uint256) {

        if (token == ETH_ADDR) {
            return weth.balanceOf(address(this));
        }
        return IERC20(token).balanceOf(address(this));
    }

    function transferAll(address token, uint256 amount)
        internal
        returns (bool)
    {

        if (amount == 0) {
            return true;
        }
        if (token == ETH_ADDR) {
            weth.withdraw(amount);
            (bool xfer, ) = msg.sender.call.value(amount).gas(9100)("");
            require(xfer, "ERR_ETH_FAILED");
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
        return true;
    }

    function transferFromAllTo(
        IERC20 token,
        uint256 amount,
        address to
    ) internal returns (bool hasETH) {

        hasETH = false;
        if (address(token) == ETH_ADDR) {
            require(amount == msg.value, "ERR_TOKEN_AMOUNT");
            weth.deposit.value(amount)();
            if (to != address(this)) {
                weth.transfer(to, amount);
            }
            hasETH = true;
        } else {
            token.safeTransferFrom(msg.sender, to, amount);
        }
    }

    function transferFromAllAndApprove(
        address token,
        uint256 amount,
        address spender
    ) internal returns (bool hasETH) {

        hasETH = false;
        if (token == ETH_ADDR) {
            require(amount == msg.value, "ERR_TOKEN_AMOUNT");
            weth.deposit.value(amount)();
            if (weth.allowance(address(this), spender) < amount) {
                IERC20(address(weth)).safeApprove(spender, 0);
                IERC20(address(weth)).safeApprove(spender, amount);
            }
            hasETH = true;
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            if (IERC20(token).allowance(address(this), spender) < amount) {
                IERC20(token).safeApprove(spender, 0);
                IERC20(token).safeApprove(spender, amount);
            }
        }
    }
}