
pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.7.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.7.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;


interface ISwapRouter is IUniswapV3SwapCallback {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}// MIT

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
}// MIT

pragma solidity =0.7.6;


interface IWPowerPerp is IERC20 {

    function mint(address _account, uint256 _amount) external;


    function burn(address _account, uint256 _amount) external;

}// MIT

pragma solidity =0.7.6;


interface IWETH9 is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;

}// MIT

pragma solidity =0.7.6;

interface IShortPowerPerp is IERC721 {

    function nextId() external view returns (uint256);


    function mintNFT(address recipient) external returns (uint256 _newId);

}// MIT

pragma solidity ^0.7.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.7.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;

interface IPoolInitializer {

    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;


interface IERC721Permit is IERC721 {

    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

}// GPL-2.0-or-later
pragma solidity >=0.7.5;

interface IPeripheryPayments {

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;


    function refundETH() external payable;


    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IPeripheryImmutableState {

    function factory() external view returns (address);


    function WETH9() external view returns (address);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library PoolAddress {

    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {

        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {

        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}// GPL-2.0-or-later
pragma solidity >=0.7.5;



interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{

    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );


    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );


    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);


    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);


    function burn(uint256 tokenId) external payable;

}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library TickMathExternal {

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    function getSqrtRatioAtTick(int24 tick) public pure returns (uint160 sqrtPriceX96) {

        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), "T");

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    function getTickAtSqrtRatio(uint160 sqrtPriceX96) external pure returns (int24 tick) {

        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, "R");
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}// MIT
pragma solidity >=0.4.0;

library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = -denominator & denominator;
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library UnsafeMath {

    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }
}// GPL-2.0-or-later
pragma solidity >=0.4.0;

library FixedPoint96 {

    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


library SqrtPriceMathPartial {

    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) external pure returns (uint256 amount0) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
        uint256 numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

        require(sqrtRatioAX96 > 0);

        return
            roundUp
                ? UnsafeMath.divRoundingUp(
                    FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtRatioBX96),
                    sqrtRatioAX96
                )
                : FullMath.mulDiv(numerator1, numerator2, sqrtRatioBX96) / sqrtRatioAX96;
    }

    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) external pure returns (uint256 amount1) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            roundUp
                ? FullMath.mulDivRoundingUp(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }
}//MIT

pragma solidity =0.7.6;

library Uint256Casting {

    function toUint128(uint256 y) internal pure returns (uint128 z) {

        require((z = uint128(y)) == y, "OF128");
    }

    function toUint96(uint256 y) internal pure returns (uint96 z) {

        require((z = uint96(y)) == y, "OF96");
    }

    function toUint32(uint256 y) internal pure returns (uint32 z) {

        require((z = uint32(y)) == y, "OF32");
    }
}//GPL-2.0-or-later

pragma solidity =0.7.6;



library VaultLib {

    using SafeMath for uint256;
    using Uint256Casting for uint256;

    uint256 constant ONE_ONE = 1e36;

    uint256 public constant CR_NUMERATOR = 3;
    uint256 public constant CR_DENOMINATOR = 2;

    struct Vault {
        address operator;
        uint32 NftCollateralId;
        uint96 collateralAmount;
        uint128 shortAmount;
    }

    function addEthCollateral(Vault memory _vault, uint256 _amount) internal pure {

        _vault.collateralAmount = uint256(_vault.collateralAmount).add(_amount).toUint96();
    }

    function addUniNftCollateral(Vault memory _vault, uint256 _tokenId) internal pure {

        require(_vault.NftCollateralId == 0, "V1");
        require(_tokenId != 0, "C23");
        _vault.NftCollateralId = _tokenId.toUint32();
    }

    function removeEthCollateral(Vault memory _vault, uint256 _amount) internal pure {

        _vault.collateralAmount = uint256(_vault.collateralAmount).sub(_amount).toUint96();
    }

    function removeUniNftCollateral(Vault memory _vault) internal pure {

        require(_vault.NftCollateralId != 0, "V2");
        _vault.NftCollateralId = 0;
    }

    function addShort(Vault memory _vault, uint256 _amount) internal pure {

        _vault.shortAmount = uint256(_vault.shortAmount).add(_amount).toUint128();
    }

    function removeShort(Vault memory _vault, uint256 _amount) internal pure {

        _vault.shortAmount = uint256(_vault.shortAmount).sub(_amount).toUint128();
    }

    function getVaultStatus(
        Vault memory _vault,
        address _positionManager,
        uint256 _normalizationFactor,
        uint256 _ethQuoteCurrencyPrice,
        uint256 _minCollateral,
        int24 _wsqueethPoolTick,
        bool _isWethToken0
    ) internal view returns (bool, bool) {

        if (_vault.shortAmount == 0) return (true, false);

        uint256 debtValueInETH = uint256(_vault.shortAmount).mul(_normalizationFactor).mul(_ethQuoteCurrencyPrice).div(
            ONE_ONE
        );
        uint256 totalCollateral = _getEffectiveCollateral(
            _vault,
            _positionManager,
            _normalizationFactor,
            _ethQuoteCurrencyPrice,
            _wsqueethPoolTick,
            _isWethToken0
        );

        bool isDust = totalCollateral < _minCollateral;
        bool isAboveWater = totalCollateral.mul(CR_DENOMINATOR) >= debtValueInETH.mul(CR_NUMERATOR);
        return (isAboveWater, isDust);
    }

    function _getEffectiveCollateral(
        Vault memory _vault,
        address _positionManager,
        uint256 _normalizationFactor,
        uint256 _ethQuoteCurrencyPrice,
        int24 _wsqueethPoolTick,
        bool _isWethToken0
    ) internal view returns (uint256) {

        if (_vault.NftCollateralId == 0) return _vault.collateralAmount;

        (uint256 nftEthAmount, uint256 nftWsqueethAmount) = _getUniPositionBalances(
            _positionManager,
            _vault.NftCollateralId,
            _wsqueethPoolTick,
            _isWethToken0
        );
        uint256 wSqueethIndexValueInEth = nftWsqueethAmount.mul(_normalizationFactor).mul(_ethQuoteCurrencyPrice).div(
            ONE_ONE
        );
        return nftEthAmount.add(wSqueethIndexValueInEth).add(_vault.collateralAmount);
    }

    function _getUniPositionBalances(
        address _positionManager,
        uint256 _tokenId,
        int24 _wPowerPerpPoolTick,
        bool _isWethToken0
    ) internal view returns (uint256 ethAmount, uint256 wPowerPerpAmount) {

        (
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = _getUniswapPositionInfo(_positionManager, _tokenId);
        (uint256 amount0, uint256 amount1) = _getToken0Token1Balances(
            tickLower,
            tickUpper,
            _wPowerPerpPoolTick,
            liquidity
        );

        return
            _isWethToken0
                ? (amount0 + tokensOwed0, amount1 + tokensOwed1)
                : (amount1 + tokensOwed1, amount0 + tokensOwed0);
    }

    function _getUniswapPositionInfo(address _positionManager, uint256 _tokenId)
        internal
        view
        returns (
            int24,
            int24,
            uint128,
            uint128,
            uint128
        )
    {

        INonfungiblePositionManager positionManager = INonfungiblePositionManager(_positionManager);
        (
            ,
            ,
            ,
            ,
            ,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            ,
            ,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = positionManager.positions(_tokenId);
        return (tickLower, tickUpper, liquidity, tokensOwed0, tokensOwed1);
    }

    function _getToken0Token1Balances(
        int24 _tickLower,
        int24 _tickUpper,
        int24 _tick,
        uint128 _liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {

        uint160 sqrtPriceX96 = TickMathExternal.getSqrtRatioAtTick(_tick);

        if (_tick < _tickLower) {
            amount0 = SqrtPriceMathPartial.getAmount0Delta(
                TickMathExternal.getSqrtRatioAtTick(_tickLower),
                TickMathExternal.getSqrtRatioAtTick(_tickUpper),
                _liquidity,
                true
            );
        } else if (_tick < _tickUpper) {
            amount0 = SqrtPriceMathPartial.getAmount0Delta(
                sqrtPriceX96,
                TickMathExternal.getSqrtRatioAtTick(_tickUpper),
                _liquidity,
                true
            );
            amount1 = SqrtPriceMathPartial.getAmount1Delta(
                TickMathExternal.getSqrtRatioAtTick(_tickLower),
                sqrtPriceX96,
                _liquidity,
                true
            );
        } else {
            amount1 = SqrtPriceMathPartial.getAmount1Delta(
                TickMathExternal.getSqrtRatioAtTick(_tickLower),
                TickMathExternal.getSqrtRatioAtTick(_tickUpper),
                _liquidity,
                true
            );
        }
    }
}// MIT

pragma solidity =0.7.6;



interface IController {

    function ethQuoteCurrencyPool() external view returns (address);


    function feeRate() external view returns (uint256);


    function getFee(
        uint256 _vaultId,
        uint256 _wPowerPerpAmount,
        uint256 _collateralAmount
    ) external view returns (uint256);


    function quoteCurrency() external view returns (address);


    function vaults(uint256 _vaultId) external view returns (VaultLib.Vault memory);


    function shortPowerPerp() external view returns (address);


    function wPowerPerp() external view returns (address);


    function getExpectedNormalizationFactor() external view returns (uint256);


    function mintPowerPerpAmount(
        uint256 _vaultId,
        uint256 _powerPerpAmount,
        uint256 _uniTokenId
    ) external payable returns (uint256 vaultId, uint256 wPowerPerpAmount);


    function mintWPowerPerpAmount(
        uint256 _vaultId,
        uint256 _wPowerPerpAmount,
        uint256 _uniTokenId
    ) external payable returns (uint256 vaultId);


    function deposit(uint256 _vaultId) external payable;


    function withdraw(uint256 _vaultId, uint256 _amount) external payable;


    function burnWPowerPerpAmount(
        uint256 _vaultId,
        uint256 _wPowerPerpAmount,
        uint256 _withdrawAmount
    ) external;


    function burnOnPowerPerpAmount(
        uint256 _vaultId,
        uint256 _powerPerpAmount,
        uint256 _withdrawAmount
    ) external returns (uint256 wPowerPerpAmount);


    function liquidate(uint256 _vaultId, uint256 _maxDebtAmount) external returns (uint256);


    function updateOperator(uint256 _vaultId, address _operator) external;


    function applyFunding() external;


    function redeemShort(uint256 _vaultId) external;


    function reduceDebtShutdown(uint256 _vaultId) external;


    function isShutDown() external returns (bool);

}// MIT

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// GPL-2.0-or-later

pragma solidity =0.7.6;



contract ShortHelper is IERC721Receiver, ReentrancyGuard {

    using SafeMath for uint256;
    using Address for address payable;

    IController public immutable controller;
    ISwapRouter public immutable router;
    IWETH9 public immutable weth;
    IShortPowerPerp public immutable shortPowerPerp;
    address public immutable wPowerPerp;

    constructor(
        address _controllerAddr,
        address _swapRouter,
        address _wethAddr
    ) {
        require(_controllerAddr != address(0), "Invalid controller address");
        require(_swapRouter != address(0), "Invalid swap router address");
        require(_wethAddr != address(0), "Invalid weth address");
        IController _controller = IController(_controllerAddr);
        router = ISwapRouter(_swapRouter);
        wPowerPerp = _controller.wPowerPerp();
        IWPowerPerp _wPowerPerp = IWPowerPerp(_controller.wPowerPerp());
        IWETH9 _weth = IWETH9(_wethAddr);
        _wPowerPerp.approve(_swapRouter, type(uint256).max);
        _weth.approve(_swapRouter, type(uint256).max);

        shortPowerPerp = IShortPowerPerp(_controller.shortPowerPerp());
        weth = _weth;
        controller = _controller;
    }

    function openShort(
        uint256 _vaultId,
        uint256 _powerPerpAmount,
        uint256 _uniNftId,
        ISwapRouter.ExactInputSingleParams memory _exactInputParams
    ) external payable nonReentrant {

        if (_vaultId != 0) require(shortPowerPerp.ownerOf(_vaultId) == msg.sender, "Not allowed");
        require(
            _exactInputParams.tokenOut == address(weth) && _exactInputParams.tokenIn == wPowerPerp,
            "Wrong swap tokens"
        );

        (uint256 vaultId, uint256 wPowerPerpAmount) = controller.mintPowerPerpAmount{value: msg.value}(
            _vaultId,
            _powerPerpAmount,
            _uniNftId
        );
        _exactInputParams.amountIn = wPowerPerpAmount;

        uint256 amountOut = router.exactInputSingle(_exactInputParams);

        if (_exactInputParams.recipient == address(this)) {
            weth.withdraw(amountOut);
            payable(msg.sender).sendValue(amountOut);
        }

        if (_vaultId == 0) shortPowerPerp.safeTransferFrom(address(this), msg.sender, vaultId);
    }

    function closeShort(
        uint256 _vaultId,
        uint256 _wPowerPerpAmount,
        uint256 _withdrawAmount,
        ISwapRouter.ExactOutputSingleParams memory _exactOutputParams
    ) external payable nonReentrant {

        require(shortPowerPerp.ownerOf(_vaultId) == msg.sender, "Not allowed");
        require(
            _exactOutputParams.tokenOut == wPowerPerp && _exactOutputParams.tokenIn == address(weth),
            "Wrong swap tokens"
        );

        weth.deposit{value: msg.value}();

        uint256 amountIn = router.exactOutputSingle(_exactOutputParams);

        controller.burnWPowerPerpAmount(_vaultId, _wPowerPerpAmount, _withdrawAmount);

        weth.withdraw(msg.value.sub(amountIn));
        payable(msg.sender).sendValue(address(this).balance);
    }

    receive() external payable {
        require(msg.sender == address(weth) || msg.sender == address(controller), "can't receive eth");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}