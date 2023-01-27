

pragma solidity ^0.6.7;

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


contract BabylonianMath {

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

contract FixedPointMath is BabylonianMath {

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

    function divide(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {

        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function multiply(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {

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

        return uq112x112(uint224(super.sqrt(uint256(self._x)) << 56));
    }
}

contract UniswapV2Library {

    function addition(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'UniswapV2Library: add-overflow');
    }
    function subtract(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'UniswapV2Library: sub-underflow');
    }
    function multiply(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'UniswapV2Library: mul-overflow');
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        return IUniswapV2Factory(factory).getPair(tokenA, tokenB);
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = multiply(amountA, reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = multiply(amountIn, 997);
        uint numerator = multiply(amountInWithFee, reserveOut);
        uint denominator = addition(multiply(reserveIn, 1000), amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = multiply(multiply(reserveIn, amountOut), 1000);
        uint denominator = multiply(subtract(reserveOut, amountOut), 997);
        amountIn = addition((numerator / denominator), 1);
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

contract UniswapV2OracleLibrary is FixedPointMath {

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
            price0Cumulative += uint(fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

abstract contract ConverterFeedLike {
    function getResultWithValidity() virtual external view returns (uint256,bool);
    function updateResult(address) virtual external;
}
abstract contract StabilityFeeTreasuryLike {
    function getAllowance(address) virtual external view returns (uint, uint);
    function systemCoin() virtual external view returns (address);
    function pullFunds(address, address, uint) virtual external;
}

contract UniswapConsecutiveSlotsPriceFeedMedianizer is UniswapV2Library, UniswapV2OracleLibrary {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "UniswapConsecutiveSlotsPriceFeedMedianizer/account-not-authorized");
        _;
    }

    struct UniswapObservation {
        uint timestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }
    struct ConverterFeedObservation {
        uint timestamp;
        uint timeAdjustedPrice;
    }

    uint256              public defaultAmountIn;
    address              public targetToken;
    address              public denominationToken;
    address              public uniswapPair;

    IUniswapV2Factory    public uniswapFactory;

    UniswapObservation[] public uniswapObservations;

    uint256                    public converterPriceCumulative;

    ConverterFeedLike          public converterFeed;
    ConverterFeedObservation[] public converterFeedObservations;

    bytes32 public symbol = "raiusd";

    uint8   public granularity;
    uint256 public lastUpdateTime;
    uint256 public updates;
    uint256 public windowSize;
    uint256 public maxWindowSize;
    uint256 public periodSize;
    uint256 public converterFeedScalingFactor;
    uint256 private medianPrice;
    uint256 public baseUpdateCallerReward;          // [wad]
    uint256 public maxUpdateCallerReward;           // [wad]
    uint256 public maxRewardIncreaseDelay;
    uint256 public perSecondCallerRewardIncrease;   // [ray]
    StabilityFeeTreasuryLike  public treasury;

    event ModifyParameters(bytes32 parameter, address data);
    event ModifyParameters(bytes32 parameter, uint256 data);
    event UpdateResult(uint256 medianPrice, uint256 lastUpdateTime);
    event FailedConverterFeedUpdate(bytes reason);
    event FailedUniswapPairSync(bytes reason);
    event FailRewardCaller(bytes revertReason, address feeReceiver, uint256 amount);
    event RewardCaller(address feeReceiver, uint256 amount);
    event AddAuthorization(address account);
    event RemoveAuthorization(address account);

    constructor(
      address converterFeed_,
      address uniswapFactory_,
      address treasury_,
      uint256 defaultAmountIn_,
      uint256 windowSize_,
      uint256 converterFeedScalingFactor_,
      uint256 baseUpdateCallerReward_,
      uint256 maxUpdateCallerReward_,
      uint256 perSecondCallerRewardIncrease_,
      uint256 maxWindowSize_,
      uint8   granularity_
    ) public {
        require(uniswapFactory_ != address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/null-uniswap-factory");
        require(granularity_ > 1, 'UniswapConsecutiveSlotsPriceFeedMedianizer/null-granularity');
        require(windowSize_ > 0, 'UniswapConsecutiveSlotsPriceFeedMedianizer/null-window-size');
        require(maxWindowSize_ > windowSize_, 'UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-max-window-size');
        require(defaultAmountIn_ > 0, 'UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-default-amount-in');
        require(converterFeedScalingFactor_ > 0, 'UniswapConsecutiveSlotsPriceFeedMedianizer/null-feed-scaling-factor');
        require(
            (periodSize = windowSize_ / granularity_) * granularity_ == windowSize_,
            'UniswapConsecutiveSlotsPriceFeedMedianizer/window-not-evenly-divisible'
        );
        require(maxUpdateCallerReward_ > baseUpdateCallerReward_, "UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-max-reward");
        require(perSecondCallerRewardIncrease_ >= RAY, "UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-reward-increase");
        if (address(treasury_) != address(0)) {
          require(StabilityFeeTreasuryLike(treasury_).systemCoin() != address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/treasury-coin-not-set");
        }
        authorizedAccounts[msg.sender] = 1;
        converterFeed                  = ConverterFeedLike(converterFeed_);
        treasury                       = StabilityFeeTreasuryLike(treasury_);
        uniswapFactory                 = IUniswapV2Factory(uniswapFactory_);
        defaultAmountIn                = defaultAmountIn_;
        windowSize                     = windowSize_;
        maxWindowSize                  = maxWindowSize_;
        converterFeedScalingFactor     = converterFeedScalingFactor_;
        baseUpdateCallerReward         = baseUpdateCallerReward_;
        maxUpdateCallerReward          = maxUpdateCallerReward_;
        perSecondCallerRewardIncrease  = perSecondCallerRewardIncrease_;
        granularity                    = granularity_;
        maxRewardIncreaseDelay         = uint(-1);
        lastUpdateTime                 = now;
        emit AddAuthorization(msg.sender);
        emit ModifyParameters(bytes32("treasury"), treasury_);
        emit ModifyParameters(bytes32("converterFeed"), converterFeed_);
        emit ModifyParameters(bytes32("maxWindowSize"), maxWindowSize_);
        emit ModifyParameters(bytes32("baseUpdateCallerReward"), baseUpdateCallerReward);
        emit ModifyParameters(bytes32("maxUpdateCallerReward"), maxUpdateCallerReward);
        emit ModifyParameters(bytes32("perSecondCallerRewardIncrease"), perSecondCallerRewardIncrease);
    }

    uint256 internal constant WAD = 10 ** 18;
    uint256 internal constant RAY = 10 ** 27;
    function minimum(uint x, uint y) internal pure returns (uint z) {

        z = (x <= y) ? x : y;
    }
    function wmultiply(uint x, uint y) internal pure returns (uint z) {

        z = multiply(x, y) / WAD;
    }
    function rmultiply(uint x, uint y) internal pure returns (uint z) {

        z = multiply(x, y) / RAY;
    }
    function rpower(uint x, uint n, uint base) internal pure returns (uint z) {

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

    function modifyParameters(bytes32 parameter, address data) external isAuthorized {
        require(data != address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/null-data");
        if (parameter == "converterFeed") {
          require(data != address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/null-converter-feed");
          converterFeed = ConverterFeedLike(data);
        }
        else if (parameter == "treasury") {
      	  require(StabilityFeeTreasuryLike(data).systemCoin() != address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/treasury-coin-not-set");
      	  treasury = StabilityFeeTreasuryLike(data);
      	}
        else if (parameter == "targetToken") {
          require(uniswapPair == address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/pair-already-set");
          targetToken = data;
          if (denominationToken != address(0)) {
            uniswapPair = uniswapFactory.getPair(targetToken, denominationToken);
            require(uniswapPair != address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/null-uniswap-pair");
          }
        }
        else if (parameter == "denominationToken") {
          require(uniswapPair == address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/pair-already-set");
          denominationToken = data;
          if (targetToken != address(0)) {
            uniswapPair = uniswapFactory.getPair(targetToken, denominationToken);
            require(uniswapPair != address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/null-uniswap-pair");
          }
        }
        else revert("UniswapConsecutiveSlotsPriceFeedMedianizer/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }
    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {
        if (parameter == "baseUpdateCallerReward") baseUpdateCallerReward = data;
        else if (parameter == "maxUpdateCallerReward") {
          require(data > baseUpdateCallerReward, "UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-max-reward");
          maxUpdateCallerReward = data;
        }
        else if (parameter == "perSecondCallerRewardIncrease") {
          require(data >= RAY, "UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-reward-increase");
          perSecondCallerRewardIncrease = data;
        }
        else if (parameter == "maxRewardIncreaseDelay") {
          require(data > 0, "UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-max-increase-delay");
          maxRewardIncreaseDelay = data;
        }
        else if (parameter == "defaultAmountIn") {
          require(data > 0, "UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-default-amount-in");
          defaultAmountIn = data;
        }
        else if (parameter == "maxWindowSize") {
          require(data > windowSize, 'UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-max-window-size');
          maxWindowSize = data;
        }
        else revert("UniswapConsecutiveSlotsPriceFeedMedianizer/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    function either(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := or(x, y)}
    }
    function both(bool x, bool y) private pure returns (bool z) {
        assembly{ z := and(x, y)}
    }
    function getFirstObservationsInWindow()
      private view returns (UniswapObservation storage firstUniswapObservation, ConverterFeedObservation storage firstConverterFeedObservation) {
        uint256 earliestObservationIndex = earliestObservationIndex();
        firstUniswapObservation          = uniswapObservations[earliestObservationIndex];
        firstConverterFeedObservation    = converterFeedObservations[earliestObservationIndex];
    }
    function timeElapsedSinceFirstObservation() public view returns (uint256) {
        if (updates > 1) {
          (
            UniswapObservation storage firstUniswapObservation,
          ) = getFirstObservationsInWindow();
          return subtract(now, firstUniswapObservation.timestamp);
        }
        return 0;
    }
    function getMedianPrice(uint256 price0Cumulative, uint256 price1Cumulative) private view returns (uint256) {
        if (updates > 1) {
          (
            UniswapObservation storage firstUniswapObservation,
          ) = getFirstObservationsInWindow();

          uint timeSinceFirst = subtract(now, firstUniswapObservation.timestamp);
          (address token0,)   = sortTokens(targetToken, denominationToken);
          uint256 uniswapAmountOut;

          if (token0 == targetToken) {
              uniswapAmountOut = uniswapComputeAmountOut(
                firstUniswapObservation.price0Cumulative, price0Cumulative, timeSinceFirst, defaultAmountIn
              );
          } else {
              uniswapAmountOut = uniswapComputeAmountOut(
                firstUniswapObservation.price1Cumulative, price1Cumulative, timeSinceFirst, defaultAmountIn
              );
          }

          return converterComputeAmountOut(timeSinceFirst, uniswapAmountOut);
        }

        return medianPrice;
    }
    function earliestObservationIndex() public view returns (uint256) {
        if (updates <= granularity) {
          return 0;
        }
        return subtract(updates, uint(granularity));
    }
    function getObservationListLength() public view returns (uint256, uint256) {
        return (uniswapObservations.length, converterFeedObservations.length);
    }

    function treasuryAllowance() public view returns (uint256) {
        (uint total, uint perBlock) = treasury.getAllowance(address(this));
        return minimum(total, perBlock);
    }
    function getCallerReward() public view returns (uint256) {
        if (lastUpdateTime == 0) return baseUpdateCallerReward;
        uint256 timeElapsed = subtract(now, lastUpdateTime);
        if (timeElapsed < periodSize) {
            return 0;
        }
        uint256 baseReward   = baseUpdateCallerReward;
        uint256 adjustedTime = subtract(timeElapsed, periodSize);
        if (adjustedTime > 0) {
            adjustedTime = (adjustedTime > maxRewardIncreaseDelay) ? maxRewardIncreaseDelay : adjustedTime;
            baseReward = rmultiply(rpower(perSecondCallerRewardIncrease, adjustedTime, RAY), baseReward);
        }
        uint256 maxReward = minimum(maxUpdateCallerReward, treasuryAllowance() / RAY);
        if (baseReward > maxReward) {
            baseReward = maxReward;
        }
        return baseReward;
    }
    function rewardCaller(address proposedFeeReceiver, uint256 reward) internal {
        if (address(treasury) == proposedFeeReceiver) return;
        if (either(address(treasury) == address(0), reward == 0)) return;
        address finalFeeReceiver = (proposedFeeReceiver == address(0)) ? msg.sender : proposedFeeReceiver;
        try treasury.pullFunds(finalFeeReceiver, treasury.systemCoin(), reward) {
            emit RewardCaller(finalFeeReceiver, reward);
        }
        catch(bytes memory revertReason) {
            emit FailRewardCaller(revertReason, finalFeeReceiver, reward);
        }
    }

    function uniswapComputeAmountOut(
        uint256 priceCumulativeStart,
        uint256 priceCumulativeEnd,
        uint256 timeElapsed,
        uint256 amountIn
    ) public pure returns (uint256 amountOut) {
        require(priceCumulativeEnd >= priceCumulativeStart, "UniswapConverterBasicAveragePriceFeedMedianizer/invalid-end-cumulative");
        require(timeElapsed > 0, "UniswapConsecutiveSlotsPriceFeedMedianizer/null-time-elapsed");
        uq112x112 memory priceAverage = uq112x112(
            uint224((priceCumulativeEnd - priceCumulativeStart) / timeElapsed)
        );
        amountOut = decode144(multiply(priceAverage, amountIn));
    }

    function converterComputeAmountOut(
        uint256 timeElapsed,
        uint256 amountIn
    ) public view returns (uint256 amountOut) {
        require(timeElapsed > 0, "UniswapConsecutiveSlotsPriceFeedMedianizer/null-time-elapsed");
        uint256 priceAverage = converterPriceCumulative / timeElapsed;
        amountOut            = multiply(amountIn, priceAverage) / converterFeedScalingFactor;
    }

    function updateResult(address feeReceiver) external {
        require(uniswapPair != address(0), "UniswapConsecutiveSlotsPriceFeedMedianizer/null-uniswap-pair");

        address finalFeeReceiver = (feeReceiver == address(0)) ? msg.sender : feeReceiver;

        try converterFeed.updateResult(finalFeeReceiver) {}
        catch (bytes memory converterRevertReason) {
          emit FailedConverterFeedUpdate(converterRevertReason);
        }

        uint256 timeElapsedSinceLatest = (uniswapObservations.length == 0) ?
          subtract(now, lastUpdateTime) : subtract(now, uniswapObservations[uniswapObservations.length - 1].timestamp);
        if (uniswapObservations.length > 0) {
          require(timeElapsedSinceLatest >= periodSize, "UniswapConsecutiveSlotsPriceFeedMedianizer/not-enough-time-elapsed");
        }

        try IUniswapV2Pair(uniswapPair).sync() {}
        catch (bytes memory uniswapRevertReason) {
          emit FailedUniswapPairSync(uniswapRevertReason);
        }

        uint256 callerReward = getCallerReward();

        (uint uniswapPrice0Cumulative, uint uniswapPrice1Cumulative,) = currentCumulativePrices(uniswapPair);

        updateObservations(timeElapsedSinceLatest, uniswapPrice0Cumulative, uniswapPrice1Cumulative);

        medianPrice    = getMedianPrice(uniswapPrice0Cumulative, uniswapPrice1Cumulative);
        lastUpdateTime = now;
        updates        = addition(updates, 1);

        emit UpdateResult(medianPrice, lastUpdateTime);

        rewardCaller(feeReceiver, callerReward);
    }
    function updateObservations(
      uint256 timeElapsedSinceLatest,
      uint256 uniswapPrice0Cumulative,
      uint256 uniswapPrice1Cumulative
    ) internal {
        (uint256 priceFeedValue, bool hasValidValue) = converterFeed.getResultWithValidity();
        require(hasValidValue, "UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-converter-price-feed");
        uint256 newTimeAdjustedPrice = multiply(priceFeedValue, timeElapsedSinceLatest);

        converterFeedObservations.push(ConverterFeedObservation(now, newTimeAdjustedPrice));
        uniswapObservations.push(UniswapObservation(now, uniswapPrice0Cumulative, uniswapPrice1Cumulative));

        converterPriceCumulative = addition(converterPriceCumulative, newTimeAdjustedPrice);

        if (updates >= granularity) {
          (
            ,
            ConverterFeedObservation storage firstConverterFeedObservation
          ) = getFirstObservationsInWindow();
          converterPriceCumulative = subtract(converterPriceCumulative, firstConverterFeedObservation.timeAdjustedPrice);
        }
    }

    function read() external view returns (uint256) {
        require(both(both(medianPrice > 0, updates > granularity), timeElapsedSinceFirstObservation() <= maxWindowSize), "UniswapConsecutiveSlotsPriceFeedMedianizer/invalid-price-feed");
        return medianPrice;
    }
    function getResultWithValidity() external view returns (uint256, bool) {
        return (medianPrice, both(both(medianPrice > 0, updates > granularity), timeElapsedSinceFirstObservation() <= maxWindowSize));
    }
}

contract UniswapConsecutiveSlotsMedianPRAIUSD is UniswapConsecutiveSlotsPriceFeedMedianizer {

    constructor(
      address uniswapFactory_,
      uint256 defaultAmountIn_,
      uint256 windowSize_,
      uint256 converterFeedScalingFactor_,
      uint256 baseUpdateCallerReward_,
      uint256 maxUpdateCallerReward_,
      uint256 perSecondCallerRewardIncrease_,
      uint256 maxWindow_,
      uint8   granularity_
    ) UniswapConsecutiveSlotsPriceFeedMedianizer(
        address(0),
        uniswapFactory_,
        address(0),
        defaultAmountIn_,
        windowSize_,
        converterFeedScalingFactor_,
        baseUpdateCallerReward_,
        maxUpdateCallerReward_,
        perSecondCallerRewardIncrease_,
        maxWindow_,
        granularity_
    ) public {
        symbol = "PRAIUSD";
    }
}