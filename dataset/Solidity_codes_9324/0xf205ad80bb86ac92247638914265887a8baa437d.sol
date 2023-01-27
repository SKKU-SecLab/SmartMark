
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
pragma abicoder v2;

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

interface IOracle {

    function getHistoricalTwap(
        address _pool,
        address _base,
        address _quote,
        uint32 _period,
        uint32 _periodToHistoricPrice
    ) external view returns (uint256);


    function getTwap(
        address _pool,
        address _base,
        address _quote,
        uint32 _period,
        bool _checkPeriod
    ) external view returns (uint256);


    function getMaxPeriod(address _pool) external view returns (uint32);


    function getTimeWeightedAverageTickSafe(address _pool, uint32 _period)
        external
        view
        returns (int24 timeWeightedAverageTick);

}// MIT

pragma solidity =0.7.6;


interface IWETH9 is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolState {

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees() external view returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolDerivedState {

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);


    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolActions {

    function initialize(uint160 sqrtPriceX96) external;


    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);


    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);


    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);


    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);


    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;


    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolEvents {

    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

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

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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
}//AGPL-3.0-only





pragma solidity >0.4.13;


library StrategyMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}// GPL-3.0-only

pragma solidity =0.7.6;





contract StrategyBase is ERC20 {
    using StrategyMath for uint256;
    using Address for address payable;

    IController public powerTokenController;

    address public immutable weth;
    address public immutable wPowerPerp;

    uint256 public immutable vaultId;

    constructor(address _powerTokenController, address _weth, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        require(_powerTokenController != address(0), "invalid controller address");
        require(_weth != address(0), "invalid weth address");

        weth = _weth;
        powerTokenController = IController(_powerTokenController);
        wPowerPerp = address(powerTokenController.wPowerPerp());
        vaultId = powerTokenController.mintWPowerPerpAmount(0, 0, 0);
    }
    function getStrategyVaultId() external view returns (uint256) {
        return vaultId;
    }

    function getVaultDetails() external view returns (address, uint256, uint256, uint256) {
        return _getVaultDetails();
    }

    function _mintWPowerPerp(
        address _to,
        uint256 _wAmount,
        uint256 _collateral,
        bool _keepWsqueeth
    ) internal {
        powerTokenController.mintWPowerPerpAmount{value: _collateral}(vaultId, _wAmount, 0);

        if (!_keepWsqueeth) {
            IWPowerPerp(wPowerPerp).transfer(_to, _wAmount);
        }
    }

    function _burnWPowerPerp(
        address _from,
        uint256 _amount,
        uint256 _collateralToWithdraw,
        bool _isOwnedWSqueeth
    ) internal {
        if (!_isOwnedWSqueeth) {
            IWPowerPerp(wPowerPerp).transferFrom(_from, address(this), _amount);
        }

        powerTokenController.burnWPowerPerpAmount(vaultId, _amount, _collateralToWithdraw);
    }

    function _mintStrategyToken(address _to, uint256 _amount) internal {
        _mint(_to, _amount);
    }

    function _getDebtFromStrategyAmount(uint256 _strategyAmount) internal view returns (uint256) {
        (, , ,uint256 strategyDebt) = _getVaultDetails();
        return strategyDebt.wmul(_strategyAmount).wdiv(totalSupply());
    }

    function _getVaultDetails() internal view returns (address, uint256, uint256, uint256) {
        VaultLib.Vault memory strategyVault = powerTokenController.vaults(vaultId);

        return (strategyVault.operator, strategyVault.NftCollateralId, strategyVault.collateralAmount, strategyVault.shortAmount);
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}// GPL-2.0-or-later
pragma solidity >=0.7.0;

library LowGasSafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0 <0.8.0;

library BytesLib {
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, 'slice_overflow');
        require(_start + _length >= _start, 'slice_overflow');
        require(_bytes.length >= _start + _length, 'slice_outOfBounds');

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
                case 0 {
                    tempBytes := mload(0x40)

                    let lengthmod := and(_length, 31)

                    let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                    let end := add(mc, _length)

                    for {
                        let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                default {
                    tempBytes := mload(0x40)
                    mstore(tempBytes, 0)

                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library Path {
    using BytesLib for bytes;

    uint256 private constant ADDR_SIZE = 20;
    uint256 private constant FEE_SIZE = 3;

    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    function hasMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    function numPools(bytes memory path) internal pure returns (uint256) {
        return ((path.length - ADDR_SIZE) / NEXT_OFFSET);
    }

    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint24 fee
        )
    {
        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    function getFirstPool(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(0, POP_OFFSET);
    }

    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }
}// GPL-2.0-or-later
pragma solidity =0.7.6;


library CallbackValidation {
    function verifyCallback(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (IUniswapV3Pool pool) {
        return verifyCallback(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee));
    }

    function verifyCallback(address factory, PoolAddress.PoolKey memory poolKey)
        internal
        view
        returns (IUniswapV3Pool pool)
    {
        pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));
        require(msg.sender == address(pool));
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library TickMath {
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), 'T');

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

    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
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
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library SafeCast {
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}// GPL-2.0-or-later

pragma solidity =0.7.6;



contract StrategyFlashSwap is IUniswapV3SwapCallback {
    using Path for bytes;
    using SafeCast for uint256;
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;

    address public immutable factory;

    struct SwapCallbackData {
        bytes path;
        address caller;
        uint8 callSource;
        bytes callData;
    }

    constructor(
        address _factory
    ) {
        require(_factory != address(0), "invalid factory address");
        factory = _factory;
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external override {
        require(amount0Delta > 0 || amount1Delta > 0); // swaps entirely within 0-liquidity regions are not supported

        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();

        CallbackValidation.verifyCallback(factory, tokenIn, tokenOut, fee);

        uint256 amountToPay =
            amount0Delta > 0
                ?  uint256(amount0Delta)
                :  uint256(amount1Delta);
        
        _strategyFlash(data.caller, tokenIn, tokenOut, fee, amountToPay, data.callData, data.callSource);
    }

    function _exactInFlashSwap(address _tokenIn, address _tokenOut, uint24 _fee, uint256 _amountIn, uint256 _amountOutMinimum, uint8 _callSource, bytes memory _data) internal {
        uint256 amountOut = _exactInputInternal(
            _amountIn,
            address(this),
            uint160(0),
            SwapCallbackData({path: abi.encodePacked(_tokenIn, _fee, _tokenOut), caller: msg.sender, callSource: _callSource, callData: _data})
        );
       
        require(amountOut >= _amountOutMinimum, "amount out less than min");
    }


    function _exactOutFlashSwap(address _tokenIn, address _tokenOut, uint24 _fee, uint256 _amountOut, uint256 _amountInMaximum, uint8 _callSource, bytes memory _data) internal {
        uint256 amountIn = _exactOutputInternal(
            _amountOut,
            address(this),
            uint160(0),
            SwapCallbackData({path: abi.encodePacked(_tokenOut, _fee, _tokenIn), caller: msg.sender, callSource: _callSource, callData: _data})
        );
        
        require(amountIn <= _amountInMaximum, "amount in greater than max");
    }


    function _strategyFlash(address /*_caller*/, address /*_tokenIn*/, address /*_tokenOut*/, uint24 /*_fee*/, uint256 /*_amountToPay*/, bytes memory _callData, uint8 _callSource) internal virtual {}
    
    function _exactInputInternal(
        uint256 _amountIn,
        address _recipient,
        uint160 _sqrtPriceLimitX96,
        SwapCallbackData memory data
    ) private returns (uint256) {
        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();
       
        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0, int256 amount1) =
            _getPool(tokenIn, tokenOut, fee).swap(
                _recipient,
                zeroForOne,
                _amountIn.toInt256(),
                _sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                    : _sqrtPriceLimitX96,
                abi.encode(data)
            );
        
        return uint256(-(zeroForOne ? amount1 : amount0));
    }

    function _exactOutputInternal(
        uint256 _amountOut,
        address _recipient,
        uint160 _sqrtPriceLimitX96,
        SwapCallbackData memory data
    ) private returns (uint256) {
        (address tokenOut, address tokenIn, uint24 fee) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;
        
        (int256 amount0Delta, int256 amount1Delta) =
            _getPool(tokenIn, tokenOut, fee).swap(
                _recipient,
                zeroForOne,
                -_amountOut.toInt256(),
                _sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                    : _sqrtPriceLimitX96,
                abi.encode(data)
            );

        (uint256 amountIn, uint256 amountOutReceived) = zeroForOne
            ? (uint256(amount0Delta), uint256(-amount1Delta))
            : (uint256(amount1Delta), uint256(-amount0Delta));
        if (_sqrtPriceLimitX96 == 0) require(amountOutReceived == _amountOut);

        return amountIn;
    }

    function _getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) private view returns (IUniswapV3Pool) {
        return IUniswapV3Pool(PoolAddress.computeAddress(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee)));
    }
}// MIT

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// GPL-2.0-or-later

pragma solidity =0.7.6;



library Power2Base {
    using SafeMath for uint256;

    uint32 private constant TWAP_PERIOD = 420 seconds;
    uint256 private constant INDEX_SCALE = 1e4;
    uint256 private constant ONE = 1e18;
    uint256 private constant ONE_ONE = 1e36;

    function _getIndex(
        uint32 _period,
        address _oracle,
        address _ethQuoteCurrencyPool,
        address _weth,
        address _quoteCurrency
    ) internal view returns (uint256) {
        uint256 ethQuoteCurrencyPrice = _getScaledTwap(
            _oracle,
            _ethQuoteCurrencyPool,
            _weth,
            _quoteCurrency,
            _period,
            false
        );
        return ethQuoteCurrencyPrice.mul(ethQuoteCurrencyPrice).div(ONE);
    }

    function _getUnscaledIndex(
        uint32 _period,
        address _oracle,
        address _ethQuoteCurrencyPool,
        address _weth,
        address _quoteCurrency
    ) internal view returns (uint256) {
        uint256 ethQuoteCurrencyPrice = _getTwap(_oracle, _ethQuoteCurrencyPool, _weth, _quoteCurrency, _period, false);
        return ethQuoteCurrencyPrice.mul(ethQuoteCurrencyPrice).div(ONE);
    }

    function _getDenormalizedMark(
        uint32 _period,
        address _oracle,
        address _wSqueethEthPool,
        address _ethQuoteCurrencyPool,
        address _weth,
        address _quoteCurrency,
        address _wSqueeth,
        uint256 _normalizationFactor
    ) internal view returns (uint256) {
        uint256 ethQuoteCurrencyPrice = _getScaledTwap(
            _oracle,
            _ethQuoteCurrencyPool,
            _weth,
            _quoteCurrency,
            _period,
            false
        );
        uint256 wsqueethEthPrice = _getTwap(_oracle, _wSqueethEthPool, _wSqueeth, _weth, _period, false);

        return wsqueethEthPrice.mul(ethQuoteCurrencyPrice).div(_normalizationFactor);
    }

    function _getDebtValueInEth(
        uint256 _debtAmount,
        address _oracle,
        address _wSqueethEthPool,
        address _wSqueeth,
        address _weth
    ) internal view returns (uint256) {
        uint256 wSqueethPrice = _getTwap(_oracle, _wSqueethEthPool, _wSqueeth, _weth, TWAP_PERIOD, false);
        return _debtAmount.mul(wSqueethPrice).div(ONE);
    }

    function _getScaledTwap(
        address _oracle,
        address _pool,
        address _base,
        address _quote,
        uint32 _period,
        bool _checkPeriod
    ) internal view returns (uint256) {
        uint256 twap = _getTwap(_oracle, _pool, _base, _quote, _period, _checkPeriod);
        return twap.div(INDEX_SCALE);
    }

    function _getTwap(
        address _oracle,
        address _pool,
        address _base,
        address _quote,
        uint32 _period,
        bool _checkPeriod
    ) internal view returns (uint256) {
        return IOracle(_oracle).getTwap(_pool, _base, _quote, _period, _checkPeriod);
    }

    function _getLongSettlementValue(
        uint256 _wsqueethAmount,
        uint256 _indexPriceForSettlement,
        uint256 _normalizationFactor
    ) internal pure returns (uint256) {
        return _wsqueethAmount.mul(_normalizationFactor).mul(_indexPriceForSettlement).div(ONE_ONE);
    }
}// GPL-3.0-only

pragma solidity =0.7.6;




contract CrabStrategy is StrategyBase, StrategyFlashSwap, ReentrancyGuard, Ownable {
    using StrategyMath for uint256;
    using Address for address payable;

    uint256 public strategyCap;

    uint32 public constant POWER_PERP_PERIOD = 420 seconds;
    uint32 public hedgingTwapPeriod = 420 seconds;

    enum FLASH_SOURCE {
        FLASH_DEPOSIT,
        FLASH_WITHDRAW,
        FLASH_HEDGE_SELL,
        FLASH_HEDGE_BUY
    }

    address public immutable ethWSqueethPool;
    address public immutable oracle;
    address public immutable ethQuoteCurrencyPool;
    address public immutable quoteCurrency;

    uint256 public deltaHedgeThreshold = 1e15;
    uint256 public hedgeTimeThreshold;
    uint256 public hedgePriceThreshold;
    uint256 public auctionTime;
    uint256 public minPriceMultiplier;
    uint256 public maxPriceMultiplier;

    uint256 public timeAtLastHedge;
    uint256 public priceAtLastHedge;

    bool private hasRedeemedInShutdown;

    struct FlashDepositData {
        uint256 totalDeposit;
    }

    struct FlashWithdrawData {
        uint256 crabAmount;
    }

    struct FlashHedgeData {
        uint256 wSqueethAmount;
        uint256 ethProceeds;
        uint256 minWSqueeth;
        uint256 minEth;
    }

    event Deposit(address indexed depositor, uint256 wSqueethAmount, uint256 lpAmount);
    event Withdraw(address indexed withdrawer, uint256 crabAmount, uint256 wSqueethAmount, uint256 ethWithdrawn);
    event WithdrawShutdown(address indexed withdrawer, uint256 crabAmount, uint256 ethWithdrawn);
    event FlashDeposit(address indexed depositor, uint256 depositedAmount, uint256 tradedAmountOut);
    event FlashWithdraw(address indexed withdrawer, uint256 crabAmount, uint256 wSqueethAmount);
    event FlashDepositCallback(address indexed depositor, uint256 flashswapDebt, uint256 excess);
    event FlashWithdrawCallback(address indexed withdrawer, uint256 flashswapDebt, uint256 excess);
    event TimeHedgeOnUniswap(
        address indexed hedger,
        uint256 hedgeTimestamp,
        uint256 auctionTriggerTimestamp,
        uint256 minWSqueeth,
        uint256 minEth
    );
    event PriceHedgeOnUniswap(
        address indexed hedger,
        uint256 hedgeTimestamp,
        uint256 auctionTriggerTimestamp,
        uint256 minWSqueeth,
        uint256 minEth
    );
    event TimeHedge(address indexed hedger, bool auctionType, uint256 hedgerPrice, uint256 auctionTriggerTimestamp);
    event PriceHedge(address indexed hedger, bool auctionType, uint256 hedgerPrice, uint256 auctionTriggerTimestamp);
    event Hedge(
        address indexed hedger,
        bool auctionType,
        uint256 hedgerPrice,
        uint256 auctionPrice,
        uint256 wSqueethHedgeTargetAmount,
        uint256 ethHedgetargetAmount
    );
    event HedgeOnUniswap(
        address indexed hedger,
        bool auctionType,
        uint256 auctionPrice,
        uint256 wSqueethHedgeTargetAmount,
        uint256 ethHedgetargetAmount
    );
    event ExecuteSellAuction(address indexed buyer, uint256 wSqueethSold, uint256 ethBought, bool isHedgingOnUniswap);
    event ExecuteBuyAuction(address indexed seller, uint256 wSqueethBought, uint256 ethSold, bool isHedgingOnUniswap);
    event SetStrategyCap(uint256 newCapAmount);
    event SetDeltaHedgeThreshold(uint256 newDeltaHedgeThreshold);
    event SetHedgingTwapPeriod(uint32 newHedgingTwapPeriod);
    event SetHedgeTimeThreshold(uint256 newHedgeTimeThreshold);
    event SetHedgePriceThreshold(uint256 newHedgePriceThreshold);
    event SetAuctionTime(uint256 newAuctionTime);
    event SetMinPriceMultiplier(uint256 newMinPriceMultiplier);
    event SetMaxPriceMultiplier(uint256 newMaxPriceMultiplier);

    constructor(
        address _wSqueethController,
        address _oracle,
        address _weth,
        address _uniswapFactory,
        address _ethWSqueethPool,
        uint256 _hedgeTimeThreshold,
        uint256 _hedgePriceThreshold,
        uint256 _auctionTime,
        uint256 _minPriceMultiplier,
        uint256 _maxPriceMultiplier
    ) StrategyBase(_wSqueethController, _weth, "Crab Strategy", "Crab") StrategyFlashSwap(_uniswapFactory) {
        require(_oracle != address(0), "invalid oracle address");
        require(_ethWSqueethPool != address(0), "invalid ETH:WSqueeth address");
        require(_hedgeTimeThreshold > 0, "invalid hedge time threshold");
        require(_hedgePriceThreshold > 0, "invalid hedge price threshold");
        require(_auctionTime > 0, "invalid auction time");
        require(_minPriceMultiplier < 1e18, "min price multiplier too high");
        require(_minPriceMultiplier > 0, "invalid min price multiplier");
        require(_maxPriceMultiplier > 1e18, "max price multiplier too low");

        oracle = _oracle;
        ethWSqueethPool = _ethWSqueethPool;
        hedgeTimeThreshold = _hedgeTimeThreshold;
        hedgePriceThreshold = _hedgePriceThreshold;
        auctionTime = _auctionTime;
        minPriceMultiplier = _minPriceMultiplier;
        maxPriceMultiplier = _maxPriceMultiplier;
        ethQuoteCurrencyPool = IController(_wSqueethController).ethQuoteCurrencyPool();
        quoteCurrency = IController(_wSqueethController).quoteCurrency();
    }

    receive() external payable {
        require(msg.sender == weth || msg.sender == address(powerTokenController), "Cannot receive eth");
    }

    function setStrategyCap(uint256 _capAmount) external onlyOwner {
        strategyCap = _capAmount;

        emit SetStrategyCap(_capAmount);
    }

    function redeemShortShutdown() external {
        hasRedeemedInShutdown = true;
        powerTokenController.redeemShort(vaultId);
    }

    function flashDeposit(uint256 _ethToDeposit) external payable nonReentrant {
        (uint256 cachedStrategyDebt, uint256 cachedStrategyCollateral) = _syncStrategyState();
        _checkStrategyCap(_ethToDeposit, cachedStrategyCollateral);

        (uint256 wSqueethToMint, ) = _calcWsqueethToMintAndFee(
            _ethToDeposit,
            cachedStrategyDebt,
            cachedStrategyCollateral
        );

        if (cachedStrategyDebt == 0 && cachedStrategyCollateral == 0) {
            uint256 wSqueethEthPrice = IOracle(oracle).getTwap(
                ethWSqueethPool,
                wPowerPerp,
                weth,
                hedgingTwapPeriod,
                true
            );
            timeAtLastHedge = block.timestamp;
            priceAtLastHedge = wSqueethEthPrice;
        }

        _exactInFlashSwap(
            wPowerPerp,
            weth,
            IUniswapV3Pool(ethWSqueethPool).fee(),
            wSqueethToMint,
            _ethToDeposit.sub(msg.value),
            uint8(FLASH_SOURCE.FLASH_DEPOSIT),
            abi.encodePacked(_ethToDeposit)
        );

        emit FlashDeposit(msg.sender, _ethToDeposit, wSqueethToMint);
    }

    function flashWithdraw(uint256 _crabAmount, uint256 _maxEthToPay) external nonReentrant {
        uint256 exactWSqueethNeeded = _getDebtFromStrategyAmount(_crabAmount);

        _exactOutFlashSwap(
            weth,
            wPowerPerp,
            IUniswapV3Pool(ethWSqueethPool).fee(),
            exactWSqueethNeeded,
            _maxEthToPay,
            uint8(FLASH_SOURCE.FLASH_WITHDRAW),
            abi.encodePacked(_crabAmount)
        );

        emit FlashWithdraw(msg.sender, _crabAmount, exactWSqueethNeeded);
    }

    function deposit() external payable nonReentrant {
        uint256 amount = msg.value;

        (uint256 wSqueethToMint, uint256 depositorCrabAmount) = _deposit(msg.sender, amount, false);

        emit Deposit(msg.sender, wSqueethToMint, depositorCrabAmount);
    }

    function withdraw(uint256 _crabAmount) external nonReentrant {
        uint256 wSqueethAmount = _getDebtFromStrategyAmount(_crabAmount);
        uint256 ethToWithdraw = _withdraw(msg.sender, _crabAmount, wSqueethAmount, false);

        payable(msg.sender).sendValue(ethToWithdraw);

        emit Withdraw(msg.sender, _crabAmount, wSqueethAmount, ethToWithdraw);
    }

    function withdrawShutdown(uint256 _crabAmount) external nonReentrant {
        require(powerTokenController.isShutDown(), "Squeeth contracts not shut down");
        require(hasRedeemedInShutdown, "Crab must redeemShortShutdown");

        uint256 strategyShare = _calcCrabRatio(_crabAmount, totalSupply());
        uint256 ethToWithdraw = _calcEthToWithdraw(strategyShare, address(this).balance);
        _burn(msg.sender, _crabAmount);

        payable(msg.sender).sendValue(ethToWithdraw);
        emit WithdrawShutdown(msg.sender, _crabAmount, ethToWithdraw);
    }

    function timeHedgeOnUniswap(uint256 _minWSqueeth, uint256 _minEth) external {
        (bool isTimeHedgeAllowed, uint256 auctionTriggerTime) = _isTimeHedge();

        require(isTimeHedgeAllowed, "Time hedging is not allowed");

        _hedgeOnUniswap(auctionTriggerTime, _minWSqueeth, _minEth);

        emit TimeHedgeOnUniswap(msg.sender, block.timestamp, auctionTriggerTime, _minWSqueeth, _minEth);
    }

    function priceHedgeOnUniswap(
        uint256 _auctionTriggerTime,
        uint256 _minWSqueeth,
        uint256 _minEth
    ) external payable {
        require(_isPriceHedge(_auctionTriggerTime), "Price hedging not allowed");

        _hedgeOnUniswap(_auctionTriggerTime, _minWSqueeth, _minEth);

        emit PriceHedgeOnUniswap(msg.sender, block.timestamp, _auctionTriggerTime, _minWSqueeth, _minEth);
    }

    function timeHedge(bool _isStrategySellingWSqueeth, uint256 _limitPrice) external payable nonReentrant {
        (bool isTimeHedgeAllowed, uint256 auctionTriggerTime) = _isTimeHedge();

        require(isTimeHedgeAllowed, "Time hedging is not allowed");

        _hedge(auctionTriggerTime, _isStrategySellingWSqueeth, _limitPrice);

        emit TimeHedge(msg.sender, _isStrategySellingWSqueeth, _limitPrice, auctionTriggerTime);
    }

    function priceHedge(
        uint256 _auctionTriggerTime,
        bool _isStrategySellingWSqueeth,
        uint256 _limitPrice
    ) external payable nonReentrant {
        require(_isPriceHedge(_auctionTriggerTime), "Price hedging not allowed");
        _hedge(_auctionTriggerTime, _isStrategySellingWSqueeth, _limitPrice);

        emit PriceHedge(msg.sender, _isStrategySellingWSqueeth, _limitPrice, _auctionTriggerTime);
    }

    function checkPriceHedge(uint256 _auctionTriggerTime) external view returns (bool) {
        return _isPriceHedge(_auctionTriggerTime);
    }

    function checkTimeHedge() external view returns (bool, uint256) {
        return _isTimeHedge();
    }

    function getWsqueethFromCrabAmount(uint256 _crabAmount) external view returns (uint256) {
        return _getDebtFromStrategyAmount(_crabAmount);
    }

    function setDeltaHedgeThreshold(uint256 _deltaHedgeThreshold) external onlyOwner {
        deltaHedgeThreshold = _deltaHedgeThreshold;

        emit SetDeltaHedgeThreshold(_deltaHedgeThreshold);
    }

    function setHedgingTwapPeriod(uint32 _hedgingTwapPeriod) external onlyOwner {
        require(_hedgingTwapPeriod >= 180, "twap period is too short");

        hedgingTwapPeriod = _hedgingTwapPeriod;

        emit SetHedgingTwapPeriod(_hedgingTwapPeriod);
    }

    function setHedgeTimeThreshold(uint256 _hedgeTimeThreshold) external onlyOwner {
        require(_hedgeTimeThreshold > 0, "invalid hedge time threshold");

        hedgeTimeThreshold = _hedgeTimeThreshold;

        emit SetHedgeTimeThreshold(_hedgeTimeThreshold);
    }

    function setHedgePriceThreshold(uint256 _hedgePriceThreshold) external onlyOwner {
        require(_hedgePriceThreshold > 0, "invalid hedge price threshold");

        hedgePriceThreshold = _hedgePriceThreshold;

        emit SetHedgePriceThreshold(_hedgePriceThreshold);
    }

    function setAuctionTime(uint256 _auctionTime) external onlyOwner {
        require(_auctionTime > 0, "invalid auction time");

        auctionTime = _auctionTime;

        emit SetAuctionTime(_auctionTime);
    }

    function setMinPriceMultiplier(uint256 _minPriceMultiplier) external onlyOwner {
        require(_minPriceMultiplier < 1e18, "min price multiplier too high");

        minPriceMultiplier = _minPriceMultiplier;

        emit SetMinPriceMultiplier(_minPriceMultiplier);
    }

    function setMaxPriceMultiplier(uint256 _maxPriceMultiplier) external onlyOwner {
        require(_maxPriceMultiplier > 1e18, "max price multiplier too low");

        maxPriceMultiplier = _maxPriceMultiplier;

        emit SetMaxPriceMultiplier(_maxPriceMultiplier);
    }

    function getAuctionDetails(uint256 _auctionTriggerTime)
        external
        view
        returns (
            bool,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        (uint256 strategyDebt, uint256 ethDelta) = _syncStrategyState();
        uint256 currentWSqueethPrice = IOracle(oracle).getTwap(
            ethWSqueethPool,
            wPowerPerp,
            weth,
            hedgingTwapPeriod,
            true
        );
        uint256 feeAdjustment = _calcFeeAdjustment();
        (bool isSellingAuction, ) = _checkAuctionType(strategyDebt, ethDelta, currentWSqueethPrice, feeAdjustment);
        uint256 auctionWSqueethEthPrice = _getAuctionPrice(_auctionTriggerTime, currentWSqueethPrice, isSellingAuction);
        (bool isStillSellingAuction, uint256 wSqueethToAuction) = _checkAuctionType(
            strategyDebt,
            ethDelta,
            auctionWSqueethEthPrice,
            feeAdjustment
        );
        bool isAuctionDirectionChanged = isSellingAuction != isStillSellingAuction;
        uint256 ethProceeds = wSqueethToAuction.wmul(auctionWSqueethEthPrice);

        return (isSellingAuction, wSqueethToAuction, ethProceeds, auctionWSqueethEthPrice, isAuctionDirectionChanged);
    }

    function _checkStrategyCap(uint256 _depositAmount, uint256 _strategyCollateral) internal view {
        require(_strategyCollateral.add(_depositAmount) <= strategyCap, "Deposit exceeds strategy cap");
    }

    function _strategyFlash(
        address _caller,
        address, /*_tokenIn*/
        address, /*_tokenOut*/
        uint24, /*_fee*/
        uint256 _amountToPay,
        bytes memory _callData,
        uint8 _callSource
    ) internal override {
        if (FLASH_SOURCE(_callSource) == FLASH_SOURCE.FLASH_DEPOSIT) {
            FlashDepositData memory data = abi.decode(_callData, (FlashDepositData));

            IWETH9(weth).withdraw(IWETH9(weth).balanceOf(address(this)));

            _deposit(_caller, data.totalDeposit, true);

            IWPowerPerp(wPowerPerp).transfer(ethWSqueethPool, _amountToPay);

            emit FlashDepositCallback(_caller, _amountToPay, address(this).balance);

            if (address(this).balance > 0) {
                payable(_caller).sendValue(address(this).balance);
            }
        } else if (FLASH_SOURCE(_callSource) == FLASH_SOURCE.FLASH_WITHDRAW) {
            FlashWithdrawData memory data = abi.decode(_callData, (FlashWithdrawData));

            uint256 ethToWithdraw = _withdraw(
                _caller,
                data.crabAmount,
                IWPowerPerp(wPowerPerp).balanceOf(address(this)),
                true
            );

            IWETH9(weth).deposit{value: _amountToPay}();
            IWETH9(weth).transfer(ethWSqueethPool, _amountToPay);

            uint256 proceeds = ethToWithdraw.sub(_amountToPay);

            emit FlashWithdrawCallback(_caller, _amountToPay, proceeds);

            if (proceeds > 0) {
                payable(_caller).sendValue(proceeds);
            }
        } else if (FLASH_SOURCE(_callSource) == FLASH_SOURCE.FLASH_HEDGE_SELL) {
            FlashHedgeData memory data = abi.decode(_callData, (FlashHedgeData));

            IWETH9(weth).withdraw(IWETH9(weth).balanceOf(address(this)));
            _executeSellAuction(_caller, data.ethProceeds, data.wSqueethAmount, data.ethProceeds, true);

            uint256 wSqueethProfit = data.wSqueethAmount.sub(_amountToPay);

            require(wSqueethProfit >= data.minWSqueeth, "profit is less than min wSqueeth");

            IWPowerPerp(wPowerPerp).transfer(ethWSqueethPool, _amountToPay);
            IWPowerPerp(wPowerPerp).transfer(_caller, wSqueethProfit);
        } else if (FLASH_SOURCE(_callSource) == FLASH_SOURCE.FLASH_HEDGE_BUY) {
            FlashHedgeData memory data = abi.decode(_callData, (FlashHedgeData));

            _executeBuyAuction(_caller, data.wSqueethAmount, data.ethProceeds, true);

            uint256 ethProfit = data.ethProceeds.sub(_amountToPay);

            require(ethProfit >= data.minEth, "profit is less than min ETH");

            IWETH9(weth).deposit{value: _amountToPay}();
            IWETH9(weth).transfer(ethWSqueethPool, _amountToPay);
            payable(_caller).sendValue(ethProfit);
        }
    }

    function _deposit(
        address _depositor,
        uint256 _amount,
        bool _isFlashDeposit
    ) internal returns (uint256, uint256) {
        (uint256 strategyDebt, uint256 strategyCollateral) = _syncStrategyState();
        _checkStrategyCap(_amount, strategyCollateral);

        (uint256 wSqueethToMint, uint256 ethFee) = _calcWsqueethToMintAndFee(_amount, strategyDebt, strategyCollateral);

        uint256 depositorCrabAmount = _calcSharesToMint(_amount.sub(ethFee), strategyCollateral, totalSupply());

        if (strategyDebt == 0 && strategyCollateral == 0) {
            uint256 wSqueethEthPrice = IOracle(oracle).getTwap(
                ethWSqueethPool,
                wPowerPerp,
                weth,
                hedgingTwapPeriod,
                true
            );
            timeAtLastHedge = block.timestamp;
            priceAtLastHedge = wSqueethEthPrice;
        }

        _mintWPowerPerp(_depositor, wSqueethToMint, _amount, _isFlashDeposit);
        _mintStrategyToken(_depositor, depositorCrabAmount);

        return (wSqueethToMint, depositorCrabAmount);
    }

    function _withdraw(
        address _from,
        uint256 _crabAmount,
        uint256 _wSqueethAmount,
        bool _isFlashWithdraw
    ) internal returns (uint256) {
        (, uint256 strategyCollateral) = _syncStrategyState();

        uint256 strategyShare = _calcCrabRatio(_crabAmount, totalSupply());
        uint256 ethToWithdraw = _calcEthToWithdraw(strategyShare, strategyCollateral);

        _burnWPowerPerp(_from, _wSqueethAmount, ethToWithdraw, _isFlashWithdraw);
        _burn(_from, _crabAmount);

        return ethToWithdraw;
    }

    function _hedge(
        uint256 _auctionTriggerTime,
        bool _isStrategySellingWSqueeth,
        uint256 _limitPrice
    ) internal {
        (
            bool isSellingAuction,
            uint256 wSqueethToAuction,
            uint256 ethProceeds,
            uint256 auctionWSqueethEthPrice
        ) = _startAuction(_auctionTriggerTime);

        require(_isStrategySellingWSqueeth == isSellingAuction, "wrong auction type");

        if (isSellingAuction) {
            require(auctionWSqueethEthPrice <= _limitPrice, "Auction price > max price");
            require(msg.value >= ethProceeds, "Low ETH amount received");

            _executeSellAuction(msg.sender, msg.value, wSqueethToAuction, ethProceeds, false);
        } else {
            require(msg.value == 0, "ETH attached for buy auction");
            require(auctionWSqueethEthPrice >= _limitPrice, "Auction price < min price");
            _executeBuyAuction(msg.sender, wSqueethToAuction, ethProceeds, false);
        }

        emit Hedge(
            msg.sender,
            _isStrategySellingWSqueeth,
            _limitPrice,
            auctionWSqueethEthPrice,
            wSqueethToAuction,
            ethProceeds
        );
    }

    function _hedgeOnUniswap(
        uint256 _auctionTriggerTime,
        uint256 _minWSqueeth,
        uint256 _minEth
    ) internal {
        (
            bool isSellingAuction,
            uint256 wSqueethToAuction,
            uint256 ethProceeds,
            uint256 auctionWSqueethEthPrice
        ) = _startAuction(_auctionTriggerTime);

        if (isSellingAuction) {
            _exactOutFlashSwap(
                wPowerPerp,
                weth,
                IUniswapV3Pool(ethWSqueethPool).fee(),
                ethProceeds,
                wSqueethToAuction,
                uint8(FLASH_SOURCE.FLASH_HEDGE_SELL),
                abi.encodePacked(wSqueethToAuction, ethProceeds, _minWSqueeth, _minEth)
            );
        } else {
            _exactOutFlashSwap(
                weth,
                wPowerPerp,
                IUniswapV3Pool(ethWSqueethPool).fee(),
                wSqueethToAuction,
                ethProceeds,
                uint8(FLASH_SOURCE.FLASH_HEDGE_BUY),
                abi.encodePacked(wSqueethToAuction, ethProceeds, _minWSqueeth, _minEth)
            );
        }

        emit HedgeOnUniswap(msg.sender, isSellingAuction, auctionWSqueethEthPrice, wSqueethToAuction, ethProceeds);
    }

    function _executeSellAuction(
        address _buyer,
        uint256 _buyerAmount,
        uint256 _wSqueethToSell,
        uint256 _ethToBuy,
        bool _isHedgingOnUniswap
    ) internal {
        if (_isHedgingOnUniswap) {
            _mintWPowerPerp(_buyer, _wSqueethToSell, _ethToBuy, true);
        } else {
            _mintWPowerPerp(_buyer, _wSqueethToSell, _ethToBuy, false);

            uint256 remainingEth = _buyerAmount.sub(_ethToBuy);

            if (remainingEth > 0) {
                payable(_buyer).sendValue(remainingEth);
            }
        }

        emit ExecuteSellAuction(_buyer, _wSqueethToSell, _ethToBuy, _isHedgingOnUniswap);
    }

    function _executeBuyAuction(
        address _seller,
        uint256 _wSqueethToBuy,
        uint256 _ethToSell,
        bool _isHedgingOnUniswap
    ) internal {
        _burnWPowerPerp(_seller, _wSqueethToBuy, _ethToSell, _isHedgingOnUniswap);

        if (!_isHedgingOnUniswap) {
            payable(_seller).sendValue(_ethToSell);
        }

        emit ExecuteBuyAuction(_seller, _wSqueethToBuy, _ethToSell, _isHedgingOnUniswap);
    }

    function _startAuction(uint256 _auctionTriggerTime)
        internal
        returns (
            bool,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 strategyDebt, uint256 ethDelta) = _syncStrategyState();
        uint256 currentWSqueethPrice = IOracle(oracle).getTwap(
            ethWSqueethPool,
            wPowerPerp,
            weth,
            hedgingTwapPeriod,
            true
        );
        uint256 feeAdjustment = _calcFeeAdjustment();
        (bool isSellingAuction, ) = _checkAuctionType(strategyDebt, ethDelta, currentWSqueethPrice, feeAdjustment);
        uint256 auctionWSqueethEthPrice = _getAuctionPrice(_auctionTriggerTime, currentWSqueethPrice, isSellingAuction);
        (bool isStillSellingAuction, uint256 wSqueethToAuction) = _checkAuctionType(
            strategyDebt,
            ethDelta,
            auctionWSqueethEthPrice,
            feeAdjustment
        );

        require(isSellingAuction == isStillSellingAuction, "auction direction changed");

        uint256 ethProceeds = wSqueethToAuction.wmul(auctionWSqueethEthPrice);

        timeAtLastHedge = block.timestamp;
        priceAtLastHedge = currentWSqueethPrice;

        return (isSellingAuction, wSqueethToAuction, ethProceeds, auctionWSqueethEthPrice);
    }

    function _syncStrategyState() internal view returns (uint256, uint256) {
        (, , uint256 syncedStrategyCollateral, uint256 syncedStrategyDebt) = _getVaultDetails();

        return (syncedStrategyDebt, syncedStrategyCollateral);
    }

    function _calcFeeAdjustment() internal view returns (uint256) {
        uint256 wSqueethEthPrice = Power2Base._getTwap(
            oracle,
            ethWSqueethPool,
            wPowerPerp,
            weth,
            POWER_PERP_PERIOD,
            false
        );
        uint256 feeRate = IController(powerTokenController).feeRate();
        return wSqueethEthPrice.mul(feeRate).div(10000);
    }

    function _calcWsqueethToMintAndFee(
        uint256 _depositedAmount,
        uint256 _strategyDebtAmount,
        uint256 _strategyCollateralAmount
    ) internal view returns (uint256, uint256) {
        uint256 wSqueethToMint;
        uint256 feeAdjustment = _calcFeeAdjustment();

        if (_strategyDebtAmount == 0 && _strategyCollateralAmount == 0) {
            require(totalSupply() == 0, "Crab contracts shut down");

            uint256 wSqueethEthPrice = IOracle(oracle).getTwap(
                ethWSqueethPool,
                wPowerPerp,
                weth,
                hedgingTwapPeriod,
                true
            );
            uint256 squeethDelta = wSqueethEthPrice.wmul(2e18);
            wSqueethToMint = _depositedAmount.wdiv(squeethDelta.add(feeAdjustment));
        } else {
            wSqueethToMint = _depositedAmount.wmul(_strategyDebtAmount).wdiv(
                _strategyCollateralAmount.add(_strategyDebtAmount.wmul(feeAdjustment))
            );
        }

        uint256 fee = wSqueethToMint.wmul(feeAdjustment);

        return (wSqueethToMint, fee);
    }

    function _isTimeHedge() internal view returns (bool, uint256) {
        uint256 auctionTriggerTime = timeAtLastHedge.add(hedgeTimeThreshold);

        return (block.timestamp >= auctionTriggerTime, auctionTriggerTime);
    }

    function _isPriceHedge(uint256 _auctionTriggerTime) internal view returns (bool) {
        if (_auctionTriggerTime < timeAtLastHedge) return false;
        uint32 secondsToPriceHedgeTrigger = uint32(block.timestamp.sub(_auctionTriggerTime));
        uint256 wSqueethEthPriceAtTriggerTime = IOracle(oracle).getHistoricalTwap(
            ethWSqueethPool,
            wPowerPerp,
            weth,
            secondsToPriceHedgeTrigger + hedgingTwapPeriod,
            secondsToPriceHedgeTrigger
        );
        uint256 cachedRatio = wSqueethEthPriceAtTriggerTime.wdiv(priceAtLastHedge);
        uint256 priceThreshold = cachedRatio > 1e18 ? (cachedRatio).sub(1e18) : uint256(1e18).sub(cachedRatio);

        return priceThreshold >= hedgePriceThreshold;
    }

    function _getAuctionPrice(
        uint256 _auctionTriggerTime,
        uint256 _wSqueethEthPrice,
        bool _isSellingAuction
    ) internal view returns (uint256) {
        uint256 auctionCompletionRatio = block.timestamp.sub(_auctionTriggerTime) >= auctionTime
            ? 1e18
            : (block.timestamp.sub(_auctionTriggerTime)).wdiv(auctionTime);

        uint256 priceMultiplier;
        if (_isSellingAuction) {
            priceMultiplier = maxPriceMultiplier.sub(
                auctionCompletionRatio.wmul(maxPriceMultiplier.sub(minPriceMultiplier))
            );
        } else {
            priceMultiplier = minPriceMultiplier.add(
                auctionCompletionRatio.wmul(maxPriceMultiplier.sub(minPriceMultiplier))
            );
        }

        return _wSqueethEthPrice.wmul(priceMultiplier);
    }

    function _checkAuctionType(
        uint256 _debt,
        uint256 _ethDelta,
        uint256 _wSqueethEthPrice,
        uint256 _feeAdjustment
    ) internal view returns (bool, uint256) {
        uint256 wSqueethDelta = _debt.wmul(2e18).wmul(_wSqueethEthPrice);

        (uint256 targetHedge, bool isSellingAuction) = _getTargetHedgeAndAuctionType(
            wSqueethDelta,
            _ethDelta,
            _wSqueethEthPrice,
            _feeAdjustment
        );

        require(targetHedge.wmul(_wSqueethEthPrice).wdiv(_ethDelta) > deltaHedgeThreshold, "strategy is delta neutral");

        return (isSellingAuction, targetHedge);
    }

    function _calcSharesToMint(
        uint256 _amount,
        uint256 _strategyCollateralAmount,
        uint256 _crabTotalSupply
    ) internal pure returns (uint256) {
        uint256 depositorShare = _amount.wdiv(_strategyCollateralAmount.add(_amount));

        if (_crabTotalSupply != 0) return _crabTotalSupply.wmul(depositorShare).wdiv(uint256(1e18).sub(depositorShare));

        return _amount;
    }

    function _calcCrabRatio(uint256 _crabAmount, uint256 _totalSupply) internal pure returns (uint256) {
        return _crabAmount.wdiv(_totalSupply);
    }

    function _calcEthToWithdraw(uint256 _crabRatio, uint256 _strategyCollateralAmount) internal pure returns (uint256) {
        return _strategyCollateralAmount.wmul(_crabRatio);
    }

    function _getTargetHedgeAndAuctionType(
        uint256 _wSqueethDelta,
        uint256 _ethDelta,
        uint256 _wSqueethEthPrice,
        uint256 _feeAdjustment
    ) internal pure returns (uint256, bool) {
        return
            (_wSqueethDelta > _ethDelta)
                ? ((_wSqueethDelta.sub(_ethDelta)).wdiv(_wSqueethEthPrice), false)
                : ((_ethDelta.sub(_wSqueethDelta)).wdiv(_wSqueethEthPrice.add(_feeAdjustment)), true);
    }
}