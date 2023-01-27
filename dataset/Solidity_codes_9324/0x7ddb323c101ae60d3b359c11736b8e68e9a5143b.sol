

pragma solidity =0.6.7 >=0.4.0 >=0.5.0;


contract GebMath {

    uint256 public constant RAY = 10 ** 27;
    uint256 public constant WAD = 10 ** 18;

    function ray(uint x) public pure returns (uint z) {

        z = multiply(x, 10 ** 9);
    }
    function rad(uint x) public pure returns (uint z) {

        z = multiply(x, 10 ** 27);
    }
    function minimum(uint x, uint y) public pure returns (uint z) {

        z = (x <= y) ? x : y;
    }
    function addition(uint x, uint y) public pure returns (uint z) {

        z = x + y;
        require(z >= x, "uint-uint-add-overflow");
    }
    function subtract(uint x, uint y) public pure returns (uint z) {

        z = x - y;
        require(z <= x, "uint-uint-sub-underflow");
    }
    function multiply(uint x, uint y) public pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "uint-uint-mul-overflow");
    }
    function rmultiply(uint x, uint y) public pure returns (uint z) {

        z = multiply(x, y) / RAY;
    }
    function rdivide(uint x, uint y) public pure returns (uint z) {

        z = multiply(x, RAY) / y;
    }
    function wdivide(uint x, uint y) public pure returns (uint z) {

        z = multiply(x, WAD) / y;
    }
    function wmultiply(uint x, uint y) public pure returns (uint z) {

        z = multiply(x, y) / WAD;
    }
    function rpower(uint x, uint n, uint base) public pure returns (uint z) {

        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    x := div(xxRound, base)
                    if mod(n,2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z := div(zxRound, base)
                    }
                }
            }
        }
    }
}


interface IUniswapV3Factory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);


    function feeAmountTickSpacing(uint24 fee) external view returns (int24);


    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);


    function setOwner(address _owner) external;


    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;

}


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

}


interface IUniswapV3PoolDerivedState {

    function secondsInside(int24 tickLower, int24 tickUpper) external view returns (uint32);


    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory liquidityCumulatives);

}


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
}


interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}


interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}


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
            uint256 feeGrowthOutside1X128
        );


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function secondsOutside(int24 wordPosition) external view returns (uint256);


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
            uint160 liquidityCumulative,
            bool initialized
        );

}



interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


}


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
      require(result < (0 - uint256(1)));
      result++;
    }
  }
}


library TickMath {

  int24 internal constant MIN_TICK = -887272;
  int24 internal constant MAX_TICK = -MIN_TICK;

  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

  function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {

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

    if (tick > 0) ratio = (0 - uint256(1)) / ratio;

    sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
  }

  function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {

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
}




abstract contract ConverterFeedLike_3 {
    function getResultWithValidity() virtual external view returns (uint256,bool);
    function updateResult(address) virtual external;
}

abstract contract IncreasingRewardRelayerLike_3 {
    function reimburseCaller(address) virtual external;
}

contract UniswapV3ConverterMedianizer is GebMath {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "UniswapV3ConverterMedianizer/account-not-authorized");
        _;
    }

    struct ConverterFeedObservation {
        uint timestamp;
        uint timeAdjustedPrice;
    }

    uint256              public defaultAmountIn;
    address              public targetToken;
    address              public denominationToken;
    IUniswapV3Pool       public uniswapPool;

    uint256                    public converterPriceCumulative;
    ConverterFeedLike_3          public converterFeed;
    ConverterFeedObservation[] public converterFeedObservations;


    bytes32 public symbol = "raiusd";
    uint8   public granularity;
    uint256 public lastUpdateTime;
    uint256 public updates;
    uint32 public windowSize;
    uint256 public maxWindowSize;
    uint256 public periodSize;
    uint256 public converterFeedScalingFactor;
    uint256 private medianPrice;
    uint256 public validityFlag;

    IncreasingRewardRelayerLike_3 public relayer;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(
      bytes32 parameter,
      address addr
    );
    event ModifyParameters(
      bytes32 parameter,
      uint256 val
    );
    event UpdateResult(uint256 medianPrice, uint256 lastUpdateTime);
    event FailedConverterFeedUpdate(bytes reason);
    event FailedUniswapPairSync(bytes reason);

    constructor(
      address converterFeed_,
      address uniswapPool_,
      uint256 defaultAmountIn_,
      uint32 windowSize_,
      uint256 converterFeedScalingFactor_,
      uint256 maxWindowSize_,
      uint8   granularity_
    ) public {
        require(uniswapPool_ != address(0), "UniswapV3ConverterMedianizer/null-uniswap-factory");
        require(granularity_ > 1, 'UniswapV3ConverterMedianizer/null-granularity');
        require(windowSize_ > 0, 'UniswapV3ConverterMedianizer/null-window-size');
        require(maxWindowSize_ > windowSize_, 'UniswapV3ConverterMedianizer/invalid-max-window-size');
        require(defaultAmountIn_ > 0, 'UniswapV3ConverterMedianizer/invalid-default-amount-in');
        require(converterFeedScalingFactor_ > 0, 'UniswapV3ConverterMedianizer/null-feed-scaling-factor');
        require(
            (periodSize = windowSize_ / granularity_) * granularity_ == windowSize_,
            'UniswapConverterBasicAveragePriceFeedMedianizer/window-not-evenly-divisible'
        );

        authorizedAccounts[msg.sender] = 1;

        converterFeed                  = ConverterFeedLike_3(converterFeed_);
        uniswapPool                    = IUniswapV3Pool(uniswapPool_);
        defaultAmountIn                = defaultAmountIn_;
        windowSize                     = windowSize_;
        maxWindowSize                  = maxWindowSize_;
        converterFeedScalingFactor     = converterFeedScalingFactor_;
        granularity                    = granularity_;
        validityFlag                   = 1;

        for (uint i = converterFeedObservations.length; i < granularity; i++) {
            converterFeedObservations.push();
        }

        emit AddAuthorization(msg.sender);
        emit ModifyParameters(bytes32("converterFeed"), converterFeed_);
        emit ModifyParameters(bytes32("maxWindowSize"), maxWindowSize_);
    }

    function modifyParameters(bytes32 parameter, address data) external isAuthorized {

        require(data != address(0), "UniswapV3ConverterMedianizer/null-data");
        if (parameter == "converterFeed") {
          require(data != address(0), "UniswapV3ConverterMedianizer/null-converter-feed");
          converterFeed = ConverterFeedLike_3(data);
        }
        else if (parameter == "targetToken") {
          require(targetToken == address(0), "UniswapV3ConverterMedianizer/target-already-set");
          
          require(data == uniswapPool.token0() || data == uniswapPool.token1(),"UniswapV3ConverterMedianizer/target-not-from-pool");
          targetToken = data;
          if(targetToken == uniswapPool.token0()) 
            denominationToken = uniswapPool.token1();
          else {
            denominationToken = uniswapPool.token0();
          }
        }
        else if (parameter == "relayer") {
          relayer = IncreasingRewardRelayerLike_3(data);
        }
        else revert("UniswapV3ConverterMedianizer/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }
    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {

        if (parameter == "validityFlag") {
          require(either(data == 1, data == 0), "UniswapV3ConverterMedianizer/invalid-data");
          validityFlag = data;
        }
        else if (parameter == "defaultAmountIn") {
          require(data > 0, "UniswapV3ConverterMedianizer/invalid-default-amount-in");
          defaultAmountIn = data;
        }
        else if (parameter == "maxWindowSize") {
          require(data > windowSize, 'UniswapV3ConverterMedianizer/invalid-max-window-size');
          maxWindowSize = data;
        }
        else revert("UniswapV3ConverterMedianizer/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }
    function both(bool x, bool y) private pure returns (bool z) {

        assembly{ z := and(x, y)}
    }

    function getTimeElapsedSinceFirstObservationInWindow()
      private view returns (uint256 time) {

        uint8 firtObservationIndex = uint8(addition(updates, 1) % granularity);
        uint8 latestObservationIndex = uint8(updates % granularity);
        time = subtract(converterFeedObservations[latestObservationIndex].timestamp, converterFeedObservations[firtObservationIndex].timestamp - periodSize);
    }

    function converterComputeAmountOut(
        uint256 timeElapsed,
        uint256 amountIn
    ) public view returns (uint256 amountOut) {

        require(timeElapsed > 0, "UniswapConsecutiveSlotsPriceFeedMedianizer/null-time-elapsed");
        if(updates >= granularity) {
          uint256 priceAverage = converterPriceCumulative / timeElapsed;
          amountOut           = multiply(priceAverage,amountIn) / converterFeedScalingFactor;
        } 
    }

    function updateResult(address feeReceiver) external {

        require(address(relayer) != address(0), "UniswapV3ConverterMedianizer/null-relayer");
        require(targetToken != address(0), "UniswapV3ConverterMedianizer/null-target-token");

        address finalFeeReceiver = (feeReceiver == address(0)) ? msg.sender : feeReceiver;

        try converterFeed.updateResult(finalFeeReceiver) {}
        catch (bytes memory converterRevertReason) {
          emit FailedConverterFeedUpdate(converterRevertReason);
        }

        uint256 timeSinceLast = updates == 0 ? periodSize :subtract(now, lastUpdateTime);

        require(timeSinceLast>= periodSize, "UniswapV3ConverterMedianizer/not-enough-time-elapsed");

        updates = addition(updates, 1);
        uint8 observationIndex = uint8(updates % granularity);
        
        updateObservations(observationIndex, timeSinceLast);

        if (updates >= granularity ) medianPrice = getMedianPrice();
        lastUpdateTime  = now;
        
        emit UpdateResult(medianPrice, lastUpdateTime);

        relayer.reimburseCaller(finalFeeReceiver);
}

    function updateObservations(uint8 observationIndex, uint256 timeSinceLastObservation) internal {

        ConverterFeedObservation storage latestConverterFeedObservation = converterFeedObservations[observationIndex];

        if (updates >= granularity) {
            converterPriceCumulative = subtract(converterPriceCumulative, latestConverterFeedObservation.timeAdjustedPrice);
        }

        (uint256 priceFeedValue, bool hasValidValue) = converterFeed.getResultWithValidity();
        require(hasValidValue, "UniswapConverterBasicAveragePriceFeedMedianizer/invalid-converter-price-feed");

        latestConverterFeedObservation.timestamp          = now;
        latestConverterFeedObservation.timeAdjustedPrice  = multiply(priceFeedValue, timeSinceLastObservation);

        converterPriceCumulative = addition(converterPriceCumulative, latestConverterFeedObservation.timeAdjustedPrice);
    }

    function getMedianPrice() private view returns (uint256 meanPrice) {

        require(targetToken != address(0), "UniswapV3ConverterMedianizer/null-target-token");
        uint256 timeElapsed      = getTimeElapsedSinceFirstObservationInWindow();
        int24 medianTick         = getUniswapMeanTick(windowSize);
        uint256 uniswapAmountOut = getQuoteAtTick(medianTick, uint128(defaultAmountIn),targetToken, denominationToken);
        meanPrice               = converterComputeAmountOut(timeElapsed, uniswapAmountOut);
    }

    function getUniswapMeanTick(uint32 period) internal view returns (int24 timeWeightedAverageTick) {

        require(period != 0, 'UniswapV3ConverterMedianizer/invalid-period');

        uint32[] memory secondAgos = new uint32[](2);
        secondAgos[0] = period;
        secondAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(uniswapPool).observe(secondAgos);
        int56 tickCumulativesDelta         = tickCumulatives[1] - tickCumulatives[0];

        timeWeightedAverageTick           = int24(tickCumulativesDelta / period);

        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % period != 0)) timeWeightedAverageTick--;
    }

    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {

        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);
        uint128 maxUint = uint128(0-1);

        if (sqrtRatioX96 <= maxUint) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    function read() external view returns (uint256) {

        uint256 value = getMedianPrice();
        require(
          both(both(both(value > 0, updates >= granularity), validityFlag == 1),getTimeElapsedSinceFirstObservationInWindow()<= maxWindowSize),
          "UniswapV3ConverterMedianizer/invalid-price-feed"
        );
        return value;
    }
    function getResultWithValidity() external view returns (uint256, bool) {

        return (medianPrice, both(both(medianPrice > 0, updates >= granularity), validityFlag == 1));
    }

    function getMedianWithMedianizedPrice(uint256 medianizedETH) external view returns(uint256) {

        int24 medianTick         = getUniswapMeanTick(windowSize);
        uint256 uniswapAmountOut = getQuoteAtTick(medianTick, uint128(defaultAmountIn),targetToken, denominationToken);
        return multiply(medianizedETH,uniswapAmountOut) / converterFeedScalingFactor;
    }
    
    function getMedianWithMedianizedAndWindow(uint32 _windowSize, uint256 medianizedETH) external view returns(uint256) {

        int24 medianTick         = getUniswapMeanTick(_windowSize);
        uint256 uniswapAmountOut = getQuoteAtTick(medianTick, uint128(defaultAmountIn),targetToken, denominationToken);
        return multiply(medianizedETH,uniswapAmountOut) / converterFeedScalingFactor;
    }
}