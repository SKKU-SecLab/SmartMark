

pragma solidity =0.7.6;

abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = ChainId.get();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (ChainId.get() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                ChainId.get(),
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "RC");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

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
}

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Permit {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}

pragma solidity >=0.5.0;

interface IUniswapV3PoolActions {


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

}

pragma solidity >=0.5.0;

interface IUniswapV3PoolDerivedState {

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

}

pragma solidity >=0.5.0;

interface IUniswapV3PoolImmutables {


    function token0() external view returns (address);


    function token1() external view returns (address);


    function tickSpacing() external view returns (int24);

}

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

}

pragma solidity 0.7.6;

interface ISorbettoFragola {

    function token0() external view returns (address);


    function token1() external view returns (address);

    
    function tickSpacing() external view returns (int24);


    function pool03() external view returns (IUniswapV3Pool);


    function universalMultiplier() external view returns (uint256);


    function tickLower() external view returns (int24);


    function tickUpper() external view returns (int24);


    function deposit(uint256 amount0Desired, uint256 amount1Desired) external payable returns (uint256 shares, uint256 amount0,uint256 amount1);


    function withdraw(uint256 shares) external returns (uint256 amount0, uint256 amount1);


    function rerange() external;


    function rebalance() external;

}

pragma solidity 0.7.6;

interface ISorbettoStrategy {

    function twapDuration() external view returns (uint32);


    function maxTwapDeviation() external view returns (int24);


    function tickRangeMultiplier() external view returns (int24);


    function protocolFee() external view returns (uint24);


    function priceImpactPercentage() external view returns (uint24);

}

pragma solidity >=0.5.0;

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions
{


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

pragma solidity >=0.7.0;

library ChainId {

    function get() internal pure returns (uint256 chainId) {

        assembly {
            chainId := chainid()
        }
    }
}

pragma solidity =0.7.6;

library ECDSA {

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ISS");
        require(v == 27 || v == 28, "ISV");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "IS");

        return signer;
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

pragma solidity ^0.7.0;

library Counters {

    using LowGasSafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }
}

pragma solidity >=0.4.0;

library FixedPoint96 {

    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}

pragma solidity >=0.4.0;

library FixedPoint128 {

    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
}

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
}

pragma solidity >=0.5.0;

library LiquidityAmounts {

    function toUint128(uint256 x) private pure returns (uint128 y) {

        require((y = uint128(x)) == x);
    }

    function getLiquidityForAmount0(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
        return toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    function getLiquidityForAmount1(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return toUint128(FullMath.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
    }

    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
        }
    }

    function getAmount0ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            FullMath.mulDiv(
                uint256(liquidity) << FixedPoint96.RESOLUTION,
                sqrtRatioBX96 - sqrtRatioAX96,
                sqrtRatioBX96
            ) / sqrtRatioAX96;
    }

    function getAmount1ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount1) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
        } else {
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }
}

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

    function sub(uint256 x, uint256 y, string memory errorMessage) internal pure returns (uint256 z) {

        require((z = x - y) <= x, errorMessage);
    }

    function add(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x + y) >= x == (y >= 0));
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x - y) <= x == (y >= 0));
    }

    function add128(uint128 x, uint128 y) internal pure returns (uint128 z) {

        require((z = x + y) >= x);
    }

    function sub128(uint128 x, uint128 y) internal pure returns (uint128 z) {

        require((z = x - y) <= x);
    }

    function mul128(uint128 x, uint128 y) internal pure returns (uint128 z) {

        require(x == 0 || (z = x * y) / x == y);
    }

    function add160(uint160 x, uint160 y) internal pure returns (uint160 z) {

        require((z = x + y) >= x);
    }

    function sub160(uint160 x, uint160 y) internal pure returns (uint160 z) {

        require((z = x - y) <= x);
    }

    function mul160(uint160 x, uint160 y) internal pure returns (uint160 z) {

        require(x == 0 || (z = x * y) / x == y);
    }
}

pragma solidity 0.7.6;
pragma abicoder v2;
library PoolActions {

    using PoolVariables for IUniswapV3Pool;
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    function burnLiquidityShare(
        IUniswapV3Pool pool,
        int24 tickLower,
        int24 tickUpper,
        uint256 totalSupply,
        uint256 share,
        address to
    ) internal returns (uint256 amount0, uint256 amount1) {

        require(totalSupply > 0, "TS");
        uint128 liquidityInPool = pool.positionLiquidity(tickLower, tickUpper);
        uint256 liquidity = uint256(liquidityInPool).mul(share) / totalSupply;
        

        if (liquidity > 0) {
            (amount0, amount1) = pool.burn(tickLower, tickUpper, liquidity.toUint128());

            if (amount0 > 0 || amount1 > 0) {
                (amount0, amount0) = pool.collect(
                    to,
                    tickLower,
                    tickUpper,
                    amount0.toUint128(),
                    amount1.toUint128()
                );
            }
        }
    }

    function burnExactLiquidity(
        IUniswapV3Pool pool,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        address to
    ) internal returns (uint256 amount0, uint256 amount1) {

        uint128 liquidityInPool = pool.positionLiquidity(tickLower, tickUpper);
        require(liquidityInPool >= liquidity);
        (amount0, amount1) = pool.burn(tickLower, tickUpper, liquidity);

        if (amount0 > 0 || amount1 > 0) {
            (amount0, amount0) = pool.collect(
                to,
                tickLower,
                tickUpper,
                amount0.toUint128(),
                amount1.toUint128()
            );
        }
    }

    function burnAllLiquidity(
        IUniswapV3Pool pool,
        int24 tickLower,
        int24 tickUpper
    ) internal {

        
        uint128 liquidity = pool.positionLiquidity(tickLower, tickUpper);
        if (liquidity > 0) {
            pool.burn(tickLower, tickUpper, liquidity);
        }
        
        pool.collect(
            address(this),
            tickLower,
            tickUpper,
            type(uint128).max,
            type(uint128).max
        );
    }
}

pragma solidity >=0.5.0;

library PoolVariables {

    using LowGasSafeMath for uint256;

    struct Info {
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0;
        uint256 amount1;
        uint128 liquidity;
        int24 tickLower;
        int24 tickUpper;
    }

    function amountsForLiquidity(
        IUniswapV3Pool pool,
        uint128 liquidity,
        int24 _tickLower,
        int24 _tickUpper
    ) internal view returns (uint256, uint256) {

        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        return
            LiquidityAmounts.getAmountsForLiquidity(
                sqrtRatioX96,
                TickMath.getSqrtRatioAtTick(_tickLower),
                TickMath.getSqrtRatioAtTick(_tickUpper),
                liquidity
            );
    }

    function liquidityForAmounts(
        IUniswapV3Pool pool,
        uint256 amount0,
        uint256 amount1,
        int24 _tickLower,
        int24 _tickUpper
    ) internal view returns (uint128) {

        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();

        return
            LiquidityAmounts.getLiquidityForAmounts(
                sqrtRatioX96,
                TickMath.getSqrtRatioAtTick(_tickLower),
                TickMath.getSqrtRatioAtTick(_tickUpper),
                amount0,
                amount1
            );
    }

    function positionAmounts(IUniswapV3Pool pool, int24 _tickLower, int24 _tickUpper)
        internal
        view
        returns (uint256 amount0, uint256 amount1)
    {   

        bytes32 positionKey = PositionKey.compute(address(this), _tickLower, _tickUpper);
        (uint128 liquidity, , , uint128 tokensOwed0, uint128 tokensOwed1) =
            pool.positions(positionKey);
        (amount0, amount1) = amountsForLiquidity(pool, liquidity, _tickLower, _tickUpper);
        amount0 = amount0.add(uint256(tokensOwed0));
        amount1 = amount1.add(uint256(tokensOwed1));
    }

    function positionLiquidity(IUniswapV3Pool pool, int24 _tickLower, int24 _tickUpper)
        internal
        view
        returns (uint128 liquidity)
    {

        bytes32 positionKey = PositionKey.compute(address(this), _tickLower, _tickUpper);
        (liquidity, , , , ) = pool.positions(positionKey);
    }

    function checkRange(int24 tickLower, int24 tickUpper) internal pure {

        require(tickLower < tickUpper, "TLU");
        require(tickLower >= TickMath.MIN_TICK, "TLM");
        require(tickUpper <= TickMath.MAX_TICK, "TUM");
    }

    function floor(int24 tick, int24 tickSpacing) internal pure returns (int24) {

        int24 compressed = tick / tickSpacing;
        if (tick < 0 && tick % tickSpacing != 0) compressed--;
        return compressed * tickSpacing;
    }

    function getPositionTicks(IUniswapV3Pool pool, uint256 amount0Desired, uint256 amount1Desired, int24 baseThreshold, int24 tickSpacing) internal view returns(int24 tickLower, int24 tickUpper) {

        Info memory cache = 
            Info(amount0Desired, amount1Desired, 0, 0, 0, 0, 0);
        ( uint160 sqrtPriceX96, int24 currentTick, , , , , ) = pool.slot0();
        (cache.tickLower, cache.tickUpper) = baseTicks(currentTick, baseThreshold, tickSpacing);
        (cache.amount0, cache.amount1) = amountsForTicks(pool, cache.amount0Desired, cache.amount1Desired, cache.tickLower, cache.tickUpper);
        cache.liquidity = liquidityForAmounts(pool, cache.amount0, cache.amount1, cache.tickLower, cache.tickUpper);
        bool zeroGreaterOne = amountsDirection(cache.amount0Desired, cache.amount1Desired, cache.amount0, cache.amount1);
        if ( zeroGreaterOne) {
            uint160 nextSqrtPrice0 = SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp(sqrtPriceX96, cache.liquidity, cache.amount0Desired, false);
            cache.tickUpper = PoolVariables.floor(TickMath.getTickAtSqrtRatio(nextSqrtPrice0), tickSpacing);
        }
        else{
            uint160 nextSqrtPrice1 = SqrtPriceMath.getNextSqrtPriceFromAmount1RoundingDown(sqrtPriceX96, cache.liquidity, cache.amount1Desired, false);
            cache.tickLower = PoolVariables.floor(TickMath.getTickAtSqrtRatio(nextSqrtPrice1), tickSpacing);
        }
        checkRange(cache.tickLower, cache.tickUpper);
        
        tickLower = cache.tickLower;
        tickUpper = cache.tickUpper;
    }

    function amountsForTicks(IUniswapV3Pool pool, uint256 amount0Desired, uint256 amount1Desired, int24 _tickLower, int24 _tickUpper) internal view returns(uint256 amount0, uint256 amount1) {

        uint128 liquidity = liquidityForAmounts(pool, amount0Desired, amount1Desired, _tickLower, _tickUpper);

        (amount0, amount1) = amountsForLiquidity(pool, liquidity, _tickLower, _tickUpper);
    }

    function baseTicks(int24 currentTick, int24 baseThreshold, int24 tickSpacing) internal pure returns(int24 tickLower, int24 tickUpper) {

        
        int24 tickFloor = floor(currentTick, tickSpacing);

        tickLower = tickFloor - baseThreshold;
        tickUpper = tickFloor + baseThreshold;
    }

    function amountsDirection(uint256 amount0Desired, uint256 amount1Desired, uint256 amount0, uint256 amount1) internal pure returns (bool zeroGreaterOne) {

        zeroGreaterOne =  amount0Desired.sub(amount0).mul(amount1Desired) > amount1Desired.sub(amount1).mul(amount0Desired) ?  true : false;
    }

    function checkDeviation(IUniswapV3Pool pool, int24 maxTwapDeviation, uint32 twapDuration) internal view {

        (, int24 currentTick, , , , , ) = pool.slot0();
        int24 twap = getTwap(pool, twapDuration);
        int24 deviation = currentTick > twap ? currentTick - twap : twap - currentTick;
        require(deviation <= maxTwapDeviation, "PSC");
    }

    function getTwap(IUniswapV3Pool pool, uint32 twapDuration) internal view returns (int24) {

        uint32 _twapDuration = twapDuration;
        uint32[] memory secondsAgo = new uint32[](2);
        secondsAgo[0] = _twapDuration;
        secondsAgo[1] = 0;

        (int56[] memory tickCumulatives, ) = pool.observe(secondsAgo);
        return int24((tickCumulatives[1] - tickCumulatives[0]) / _twapDuration);
    }
}

pragma solidity >=0.5.0;

library PositionKey {

    function compute(
        address owner,
        int24 tickLower,
        int24 tickUpper
    ) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(owner, tickLower, tickUpper));
    }
}

pragma solidity >=0.5.0;

library PriceMath {

    using LowGasSafeMath for uint256;
    using UnsafeMath for uint256;
    function token0ValuePrice(uint256 sqrtPriceX96, uint256 token0Power) internal pure returns(uint256 price) {

        return sqrtPriceX96.mul(sqrtPriceX96).mul(token0Power) >> (96*2);
    }

    function sqrtPriceX96ForToken0Value(uint256 price, uint256 token0Power) internal pure returns (uint256) {

        return Babylonian.sqrt((price << (96*2)).unsafeDiv(token0Power));
    }

}

pragma solidity >=0.5.0;

library SafeCast {

    function toUint160(uint256 y) internal pure returns (uint160 z) {

        require((z = uint160(y)) == y);
    }

    function toUint128(uint256 y) internal pure returns (uint128 z) {

        require((z = uint128(y)) == y);
    }

    function toInt128(int256 y) internal pure returns (int128 z) {

        require((z = int128(y)) == y);
    }

    function toInt256(uint256 y) internal pure returns (int256 z) {

        require(y < 2**255);
        z = int256(y);
    }
}

pragma solidity >=0.5.0;

library SqrtPriceMath {

    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    function getNextSqrtPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {

        if (amount == 0) return sqrtPX96;
        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;

        if (add) {
            uint256 product;
            if ((product = amount * sqrtPX96) / amount == sqrtPX96) {
                uint256 denominator = numerator1 + product;
                if (denominator >= numerator1)
                    return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));
            }

            return uint160(UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount)));
        } else {
            uint256 product;
            require((product = amount * sqrtPX96) / amount == sqrtPX96 && numerator1 > product);
            uint256 denominator = numerator1 - product;
            return FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();
        }
    }

    function getNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {

        if (add) {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? (amount << FixedPoint96.RESOLUTION) / liquidity
                        : FullMath.mulDiv(amount, FixedPoint96.Q96, liquidity)
                );

            return uint256(sqrtPX96).add(quotient).toUint160();
        } else {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? UnsafeMath.divRoundingUp(amount << FixedPoint96.RESOLUTION, liquidity)
                        : FullMath.mulDivRoundingUp(amount, FixedPoint96.Q96, liquidity)
                );

            require(sqrtPX96 > quotient);
            return uint160(sqrtPX96 - quotient);
        }
    }
}

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
}

pragma solidity >=0.6.0;

library TransferHelper {

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}

pragma solidity >=0.5.0;

library UnsafeMath {

    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }

    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assembly {
            z := div(x, y)
        }
    }
}

pragma solidity ^0.7.0;

contract ERC20 is Context, IERC20 {

    using LowGasSafeMath for uint256;

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "TEA"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "DEB"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "FZA");
        require(recipient != address(0), "TZA");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "TEB");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "MZA");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "BZA");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "BEB");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "AFZA");
        require(spender != address(0), "ATZA");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

pragma solidity =0.7.6;

abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;
 
    bytes32 private immutable _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    constructor(string memory name) EIP712(name, "1") {
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(block.timestamp <= deadline, "ED");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "IS");

        _approve(owner, spender, value);
    }

    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}



pragma solidity =0.7.6;

interface IWETH9 is IERC20 {
    function deposit() external payable;
}

pragma solidity 0.7.6;

contract SorbettoFragola is ERC20Permit, ReentrancyGuard, ISorbettoFragola {
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for uint160;
    using LowGasSafeMath for uint128;
    using UnsafeMath for uint256;
    using SafeCast for uint256;
    using PoolVariables for IUniswapV3Pool;
    using PoolActions for IUniswapV3Pool;
    
    struct MintCallbackData {
        address payer;
    }
    struct SwapCallbackData {
        bool zeroForOne;
    }
    struct UserInfo {
        uint256 token0Rewards; // The amount of fees in token 0
        uint256 token1Rewards; // The amount of fees in token 1
        uint256 token0PerSharePaid; // Token 0 reward debt 
        uint256 token1PerSharePaid; // Token 1 reward debt
    }

    event Deposit(
        address indexed sender,
        uint256 liquidity,
        uint256 amount0,
        uint256 amount1
    );
    
    event Withdraw(
        address indexed sender,
        uint256 shares,
        uint256 amount0,
        uint256 amount1
    );
    
    event CollectFees(
        uint256 feesFromPool0,
        uint256 feesFromPool1,
        uint256 usersFees0,
        uint256 usersFees1
    );

    event Rerange(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1
    );
    
    event RewardPaid(
        address indexed sender,
        uint256 fees0,
        uint256 fees1
    );
    
    event Snapshot(uint256 totalAmount0, uint256 totalAmount1);
    
    modifier onlyGovernance {
        require(msg.sender == governance, "NA");
        _;
    }
    
    mapping(address => UserInfo) public userInfo; // Info of each user that provides liquidity tokens.

    uint256 public immutable token0DecimalPower = 1e18; //WETH
    uint256 public immutable token1DecimalPower = 1e6; //USDT
    address public immutable override token0;
    address public immutable override token1;
    address public immutable weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    int24 public immutable override tickSpacing;
    uint24 immutable GLOBAL_DIVISIONER = 1e6; // for basis point (0.0001%)

    IUniswapV3Pool public override pool03;
    uint256 public maxTotalSupply;
    uint256 public accruedProtocolFees0;
    uint256 public accruedProtocolFees1;
    uint256 public usersFees0;
    uint256 public usersFees1;
    uint256 public token0PerShareStored;
    uint256 public token1PerShareStored;
    uint256 public override universalMultiplier;
    
    address public governance;
    address public pendingGovernance;
    address public strategy;
    int24 public override tickLower;
    int24 public override tickUpper;
    bool public finalized;
    
     constructor(
        address _pool03,
        address _strategy,
        uint256 _maxTotalSupply
    ) ERC20("Popsicle LP V3 WETH/USDT", "PLP") ERC20Permit("Popsicle LP V3 WETH/USDT") {
        pool03 = IUniswapV3Pool(_pool03);
        strategy = _strategy;
        token0 = pool03.token0();
        token1 = pool03.token1();
        tickSpacing = pool03.tickSpacing();
        maxTotalSupply = _maxTotalSupply;
        governance = msg.sender;
    }
    function init() external onlyGovernance {
        require(!finalized, "F");
        finalized = true;
        int24 baseThreshold = tickSpacing * ISorbettoStrategy(strategy).tickRangeMultiplier();
        (uint160 sqrtPriceX96, int24 currentTick, , , , , ) = pool03.slot0();
        int24 tickFloor = PoolVariables.floor(currentTick, tickSpacing);
        
        tickLower = tickFloor - baseThreshold;
        tickUpper = tickFloor + baseThreshold;
        universalMultiplier = PriceMath.token0ValuePrice(sqrtPriceX96, token0DecimalPower);
    }
    
     function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired
    )
        external
        payable
        override
        nonReentrant
        checkDeviation
        updateVault(msg.sender)
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        )
    {
        require(amount0Desired > 0 && amount1Desired > 0, "ANV");

        uint128 liquidity = pool03.liquidityForAmounts(amount0Desired, amount1Desired, tickLower, tickUpper);
        
        (amount0, amount1) = pool03.mint(
            address(this),
            tickLower,
            tickUpper,
            liquidity,
            abi.encode(MintCallbackData({payer: msg.sender})));

        shares = _calcShare(amount0, amount1);

        _mint(msg.sender, shares);
        require(totalSupply() <= maxTotalSupply, "MTS");
        refundETH();
        emit Deposit(msg.sender, shares, amount0, amount1);
    }
    
    function withdraw(
        uint256 shares
    ) 
        external
        override
        nonReentrant
        checkDeviation
        updateVault(msg.sender)
        returns (
            uint256 amount0,
            uint256 amount1
        )
    {
        require(shares > 0, "S");


        (amount0, amount1) = pool03.burnLiquidityShare(tickLower, tickUpper, totalSupply(), shares,  msg.sender);
        
        _burn(msg.sender, shares);
        emit Withdraw(msg.sender, shares, amount0, amount1);
    }
    
    function rerange() external override nonReentrant checkDeviation updateVault(address(0)) {

        pool03.burnAllLiquidity(tickLower, tickUpper);
        

        uint256 balance0 = _balance0();
        uint256 balance1 = _balance1();
        emit Snapshot(balance0, balance1);

        int24 baseThreshold = tickSpacing * ISorbettoStrategy(strategy).tickRangeMultiplier();

        (tickLower, tickUpper) = pool03.getPositionTicks(balance0, balance1, baseThreshold, tickSpacing);

        uint128 liquidity = pool03.liquidityForAmounts(balance0, balance1, tickLower, tickUpper);
        
        (uint256 amount0, uint256 amount1) = pool03.mint(
            address(this),
            tickLower,
            tickUpper,
            liquidity,
            abi.encode(MintCallbackData({payer: address(this)})));
        
        emit Rerange(tickLower, tickUpper, amount0, amount1);
    }

    function rebalance() external override onlyGovernance nonReentrant checkDeviation updateVault(address(0))  {

        pool03.burnAllLiquidity(tickLower, tickUpper);
        
        (uint160 sqrtPriceX96, int24 currentTick, , , , , ) = pool03.slot0();
        PoolVariables.Info memory cache = 
            PoolVariables.Info(0, 0, 0, 0, 0, 0, 0);
        int24 baseThreshold = tickSpacing * ISorbettoStrategy(strategy).tickRangeMultiplier();
        (cache.tickLower, cache.tickUpper) = PoolVariables.baseTicks(currentTick, baseThreshold, tickSpacing);
        
        cache.amount0Desired = _balance0();
        cache.amount1Desired = _balance1();
        emit Snapshot(cache.amount0Desired, cache.amount1Desired);
        cache.liquidity = pool03.liquidityForAmounts(cache.amount0Desired, cache.amount1Desired, cache.tickLower, cache.tickUpper);

        (cache.amount0, cache.amount1) = pool03.amountsForLiquidity(cache.liquidity, cache.tickLower, cache.tickUpper);

        bool zeroForOne = PoolVariables.amountsDirection(cache.amount0Desired, cache.amount1Desired, cache.amount0, cache.amount1);
        int256 amountSpecified = 
            zeroForOne
                ? int256(cache.amount0Desired.sub(cache.amount0).unsafeDiv(2))
                : int256(cache.amount1Desired.sub(cache.amount1).unsafeDiv(2)); // always positive. "overflow" safe convertion cuz we are dividing by 2

        uint160 exactSqrtPriceImpact = sqrtPriceX96.mul160(ISorbettoStrategy(strategy).priceImpactPercentage() / 2) / 1e6;
        uint160 sqrtPriceLimitX96 = zeroForOne ?  sqrtPriceX96.sub160(exactSqrtPriceImpact) : sqrtPriceX96.add160(exactSqrtPriceImpact);

        pool03.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            abi.encode(SwapCallbackData({zeroForOne: zeroForOne}))
        );


        (sqrtPriceX96, currentTick, , , , , ) = pool03.slot0();

        cache.amount0Desired = _balance0();
        cache.amount1Desired = _balance1();
        emit Snapshot(cache.amount0Desired, cache.amount1Desired);
        (tickLower, tickUpper) = pool03.getPositionTicks(cache.amount0Desired, cache.amount1Desired, baseThreshold, tickSpacing);

        cache.liquidity = pool03.liquidityForAmounts(cache.amount0Desired, cache.amount1Desired, tickLower, tickUpper);

        (cache.amount0, cache.amount1) = pool03.mint(
            address(this),
            tickLower,
            tickUpper,
            cache.liquidity,
            abi.encode(MintCallbackData({payer: address(this)})));
        emit Rerange(tickLower, tickUpper, cache.amount0, cache.amount1);
    }

    function _calcShare(uint256 amount0Desired, uint256 amount1Desired)
        internal
        view
        returns (
            uint256 shares
        )
    {
        shares = amount0Desired.mul(universalMultiplier).unsafeDiv(token1DecimalPower).add(amount1Desired.mul(1e12)); // Mul(1e12) Recalculated to match precisions
    }
    
    function _balance0() internal view returns (uint256) {
        return IERC20(token0).balanceOf(address(this));
    }

    function _balance1() internal view returns (uint256) {
        return IERC20(token1).balanceOf(address(this));
    }
    
    function _earnFees() internal returns (uint256 userCollect0, uint256 userCollect1) {
        pool03.burn(tickLower, tickUpper, 0);
        
        (uint256 collect0, uint256 collect1) =
            pool03.collect(
                address(this),
                tickLower,
                tickUpper,
                type(uint128).max,
                type(uint128).max
            );

        uint256 feeToProtocol0 = collect0.mul(ISorbettoStrategy(strategy).protocolFee()).unsafeDiv(GLOBAL_DIVISIONER);
        uint256 feeToProtocol1 = collect1.mul(ISorbettoStrategy(strategy).protocolFee()).unsafeDiv(GLOBAL_DIVISIONER);
        accruedProtocolFees0 = accruedProtocolFees0.add(feeToProtocol0);
        accruedProtocolFees1 = accruedProtocolFees1.add(feeToProtocol1);
        userCollect0 = collect0.sub(feeToProtocol0);
        userCollect1 = collect1.sub(feeToProtocol1);
        usersFees0 = usersFees0.add(userCollect0);
        usersFees1 = usersFees1.add(userCollect1);
        emit CollectFees(collect0, collect1, usersFees0, usersFees1);
    }

    function position() external view returns (uint128 liquidity, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, uint128 tokensOwed0, uint128 tokensOwed1) {
        bytes32 positionKey = PositionKey.compute(address(this), tickLower, tickUpper);
        (liquidity, feeGrowthInside0LastX128, feeGrowthInside1LastX128, tokensOwed0, tokensOwed1) = pool03.positions(positionKey);
    }
    
    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool03));
        MintCallbackData memory decoded = abi.decode(data, (MintCallbackData));
        if (amount0 > 0) pay(token0, decoded.payer, msg.sender, amount0);
        if (amount1 > 0) pay(token1, decoded.payer, msg.sender, amount1);
    }

    function uniswapV3SwapCallback(
        int256 amount0,
        int256 amount1,
        bytes calldata _data
    ) external {
        require(msg.sender == address(pool03));
        require(amount0 > 0 || amount1 > 0); // swaps entirely within 0-liquidity regions are not supported
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        bool zeroForOne = data.zeroForOne;

        if (zeroForOne) pay(token0, address(this), msg.sender, uint256(amount0)); 
        else pay(token1, address(this), msg.sender, uint256(amount1));
    }

    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == weth && address(this).balance >= value) {
            IWETH9(weth).deposit{value: value}(); // wrap only what is needed to pay
            IWETH9(weth).transfer(recipient, value);
        } else if (payer == address(this)) {
            TransferHelper.safeTransfer(token, recipient, value);
        } else {
            TransferHelper.safeTransferFrom(token, payer, recipient, value);
        }
    }
    
    
    function collectProtocolFees(
        uint256 amount0,
        uint256 amount1
    ) external nonReentrant onlyGovernance updateVault(address(0)) {
        require(accruedProtocolFees0 >= amount0, "A0");
        require(accruedProtocolFees1 >= amount1, "A1");
        
        uint256 balance0 = _balance0();
        uint256 balance1 = _balance1();
        
        if (balance0 >= amount0 && balance1 >= amount1)
        {
            if (amount0 > 0) pay(token0, address(this), msg.sender, amount0);
            if (amount1 > 0) pay(token1, address(this), msg.sender, amount1);
        }
        else
        {
            uint128 liquidity = pool03.liquidityForAmounts(amount0, amount1, tickLower, tickUpper);
            pool03.burnExactLiquidity(tickLower, tickUpper, liquidity, msg.sender);
        
        }
        
        accruedProtocolFees0 = accruedProtocolFees0.sub(amount0);
        accruedProtocolFees1 = accruedProtocolFees1.sub(amount1);
        emit RewardPaid(msg.sender, amount0, amount1);
    }
    
    function collectFees(uint256 amount0, uint256 amount1) external updateVault(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];

        require(user.token0Rewards >= amount0, "A0");
        require(user.token1Rewards >= amount1, "A1");

        uint256 balance0 = _balance0();
        uint256 balance1 = _balance1();

        if (balance0 >= amount0 && balance1 >= amount1) {

            if (amount0 > 0) pay(token0, address(this), msg.sender, amount0);
            if (amount1 > 0) pay(token1, address(this), msg.sender, amount1);
        }
        else {
            
            uint128 liquidity = pool03.liquidityForAmounts(amount0, amount1, tickLower, tickUpper);
            (amount0, amount1) = pool03.burnExactLiquidity(tickLower, tickUpper, liquidity, msg.sender);
        }
        user.token0Rewards = user.token0Rewards.sub(amount0);
        user.token1Rewards = user.token1Rewards.sub(amount1);
        emit RewardPaid(msg.sender, amount0, amount1);
    }
    
    modifier updateVault(address account) {
        _updateFeesReward(account);
        _;
    }

    modifier checkDeviation() {
        pool03.checkDeviation(ISorbettoStrategy(strategy).maxTwapDeviation(), ISorbettoStrategy(strategy).twapDuration());
        _;
    }

    modifier onlyPool() {
        require(msg.sender == address(pool03), "FP");
        _;
    }
    
    function _updateFeesReward(address account) internal {
        uint liquidity = pool03.positionLiquidity(tickLower, tickUpper);
        if (liquidity == 0) return; // we can't poke when liquidity is zero
        (uint256 collect0, uint256 collect1) = _earnFees();
        
        
        token0PerShareStored = _tokenPerShare(collect0, token0PerShareStored);
        token1PerShareStored = _tokenPerShare(collect1, token1PerShareStored);

        if (account != address(0)) {
            UserInfo storage user = userInfo[msg.sender];
            user.token0Rewards = _fee0Earned(account, token0PerShareStored);
            user.token0PerSharePaid = token0PerShareStored;
            
            user.token1Rewards = _fee1Earned(account, token1PerShareStored);
            user.token1PerSharePaid = token1PerShareStored;
        }
    }
    
    function _fee0Earned(address account, uint256 fee0PerShare_) internal view returns (uint256) {
        UserInfo memory user = userInfo[account];
        return
            balanceOf(account)
            .mul(fee0PerShare_.sub(user.token0PerSharePaid))
            .unsafeDiv(1e18)
            .add(user.token0Rewards);
    }
    
    function _fee1Earned(address account, uint256 fee1PerShare_) internal view returns (uint256) {
        UserInfo memory user = userInfo[account];
        return
            balanceOf(account)
            .mul(fee1PerShare_.sub(user.token1PerSharePaid))
            .unsafeDiv(1e18)
            .add(user.token1Rewards);
    }
    
    function _tokenPerShare(uint256 collected, uint256 tokenPerShareStored) internal view returns (uint256) {
        uint _totalSupply = totalSupply();
        if (_totalSupply > 0) {
            return tokenPerShareStored
            .add(
                collected
                .mul(1e18)
                .unsafeDiv(_totalSupply)
            );
        }
        return tokenPerShareStored;
    }
    
    function refundETH() internal {
        if (address(this).balance > 0) TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }

    function setGovernance(address _governance) external onlyGovernance {
        pendingGovernance = _governance;
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "PG");
        governance = msg.sender;
    }

    function setMaxTotalSupply(uint256 _maxTotalSupply) external onlyGovernance {
        maxTotalSupply = _maxTotalSupply;
    }

    function setStrategy(address _strategy) external onlyGovernance {
        require(_strategy != address(0), "NA");
        strategy = _strategy;
    }
}