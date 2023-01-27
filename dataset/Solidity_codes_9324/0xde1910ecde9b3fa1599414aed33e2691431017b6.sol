
pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// GPL-2.0
pragma solidity ^0.8.4;

enum Modules {
  Kernel, // 0
  UserPositions, // 1
  YieldManager, // 2
  IntegrationMap, // 3
  BiosRewards, // 4
  EtherRewards, // 5
  SushiSwapTrader, // 6
  UniswapTrader, // 7
  StrategyMap, // 8
  StrategyManager // 9
}

interface IModuleMap {

  function getModuleAddress(Modules key) external view returns (address);

}// GPL-2.0
pragma solidity ^0.8.4;


abstract contract ModuleMapConsumer is Initializable {
  IModuleMap public moduleMap;

  function __ModuleMapConsumer_init(address moduleMap_) internal initializer {
    moduleMap = IModuleMap(moduleMap_);
  }
}// GPL-2.0
pragma solidity ^0.8.4;

interface IKernel {

  function isManager(address account) external view returns (bool);


  function isOwner(address account) external view returns (bool);

}// GPL-2.0
pragma solidity ^0.8.4;


abstract contract Controlled is Initializable, ModuleMapConsumer {
  mapping(address => bool) internal _controllers;
  address[] public controllers;

  function __Controlled_init(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    for (uint256 i; i < controllers_.length; i++) {
      _controllers[controllers_[i]] = true;
    }
    controllers = controllers_;
    __ModuleMapConsumer_init(moduleMap_);
  }

  function addController(address controller) external onlyOwner {
    _controllers[controller] = true;
    bool added;
    for (uint256 i; i < controllers.length; i++) {
      if (controller == controllers[i]) {
        added = true;
      }
    }
    if (!added) {
      controllers.push(controller);
    }
  }

  modifier onlyOwner() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isOwner(msg.sender),
      "Controlled::onlyOwner: Caller is not owner"
    );
    _;
  }

  modifier onlyManager() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isManager(msg.sender),
      "Controlled::onlyManager: Caller is not manager"
    );
    _;
  }

  modifier onlyController() {
    require(
      _controllers[msg.sender],
      "Controlled::onlyController: Caller is not controller"
    );
    _;
  }
}// GPL-2.0
pragma solidity ^0.8.4;

interface IIntegrationMap {

  struct Integration {
    bool added;
    string name;
  }

  struct Token {
    uint256 id;
    bool added;
    bool acceptingDeposits;
    bool acceptingWithdrawals;
    uint256 biosRewardWeight;
    uint256 reserveRatioNumerator;
  }

  function addIntegration(address contractAddress, string memory name) external;


  function addToken(
    address tokenAddress,
    bool acceptingDeposits,
    bool acceptingWithdrawals,
    uint256 biosRewardWeight,
    uint256 reserveRatioNumerator
  ) external;


  function enableTokenDeposits(address tokenAddress) external;


  function disableTokenDeposits(address tokenAddress) external;


  function enableTokenWithdrawals(address tokenAddress) external;


  function disableTokenWithdrawals(address tokenAddress) external;


  function updateTokenRewardWeight(address tokenAddress, uint256 rewardWeight)
    external;


  function updateTokenReserveRatioNumerator(
    address tokenAddress,
    uint256 reserveRatioNumerator
  ) external;


  function getIntegrationAddress(uint256 integrationId)
    external
    view
    returns (address);


  function getIntegrationName(address integrationAddress)
    external
    view
    returns (string memory);


  function getWethTokenAddress() external view returns (address);


  function getBiosTokenAddress() external view returns (address);


  function getTokenAddress(uint256 tokenId) external view returns (address);


  function getTokenId(address tokenAddress) external view returns (uint256);


  function getTokenBiosRewardWeight(address tokenAddress)
    external
    view
    returns (uint256);


  function getBiosRewardWeightSum()
    external
    view
    returns (uint256 rewardWeightSum);


  function getTokenAcceptingDeposits(address tokenAddress)
    external
    view
    returns (bool);


  function getTokenAcceptingWithdrawals(address tokenAddress)
    external
    view
    returns (bool);


  function getIsTokenAdded(address tokenAddress) external view returns (bool);


  function getIsIntegrationAdded(address tokenAddress)
    external
    view
    returns (bool);


  function getTokenAddressesLength() external view returns (uint256);


  function getIntegrationAddressesLength() external view returns (uint256);


  function getTokenReserveRatioNumerator(address tokenAddress)
    external
    view
    returns (uint256);


  function getReserveRatioDenominator() external view returns (uint32);

}// GPL-2.0
pragma solidity ^0.8.4;

interface IUniswapFactory {

  function getPool(
    address tokenA,
    address tokenB,
    uint24 fee
  ) external view returns (address pool);

}// GPL-2.0
pragma solidity ^0.8.4;

interface IUniswapPositionManager {

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

  struct IncreaseLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  struct DecreaseLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  struct CollectParams {
    uint256 tokenId;
    address recipient;
    uint128 amount0Max;
    uint128 amount1Max;
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


  function increaseLiquidity(IncreaseLiquidityParams calldata params)
    external
    payable
    returns (
      uint128 liquidity,
      uint256 amount0,
      uint256 amount1
    );


  function decreaseLiquidity(DecreaseLiquidityParams calldata params)
    external
    payable
    returns (uint256 amount0, uint256 amount1);


  function collect(CollectParams calldata params)
    external
    payable
    returns (uint256 amount0, uint256 amount1);


  function burn(uint256 tokenId) external payable;


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

}// GPL-2.0
pragma solidity ^0.8.4;

interface IUniswapSwapRouter {

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

  struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
  }

  struct ExactOutputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 amountInMaximum;
  }

  function exactInputSingle(ExactInputSingleParams calldata params)
    external
    payable
    returns (uint256 amountOut);


  function exactOutputSingle(ExactOutputSingleParams calldata params)
    external
    payable
    returns (uint256 amountIn);


  function exactInput(ExactInputParams calldata params)
    external
    returns (uint256 amountOut);


  function exactOutput(ExactOutputParams calldata params)
    external
    returns (uint256 amountIn);

}// GPL-2.0
pragma solidity ^0.8.4;

interface IUniswapTrader {

  struct Path {
    address tokenOut;
    uint256 firstPoolFee;
    address tokenInTokenOut;
    uint256 secondPoolFee;
    address tokenIn;
  }

  function addPool(
    address tokenA,
    address tokenB,
    uint24 fee,
    uint24 slippageNumerator
  ) external;


  function updatePoolSlippageNumerator(
    address tokenA,
    address tokenB,
    uint256 poolIndex,
    uint24 slippageNumerator
  ) external;


  function updatePairPrimaryPool(
    address tokenA,
    address tokenB,
    uint256 primaryPoolIndex
  ) external;


  function swapExactInput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountIn
  ) external returns (bool tradeSuccess);


  function swapExactOutput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountOut
  ) external returns (bool tradeSuccess);


  function getAmountInMaximum(
    address tokenIn,
    address tokenOut,
    uint256 amountOut
  ) external view returns (uint256 amountInMaximum);


  function getEstimatedTokenOut(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) external view returns (uint256 amountOut);


  function getPathFor(address tokenOut, address tokenIn)
    external
    view
    returns (Path memory);


  function setPathFor(
    address tokenOut,
    address tokenIn,
    uint256 firstPoolFee,
    address tokenInTokenOut,
    uint256 secondPoolFee
  ) external;


  function getTokensSorted(address tokenA, address tokenB)
    external
    pure
    returns (address token0, address token1);


  function getTokenPairsLength() external view returns (uint256);


  function getTokenPairPoolsLength(address tokenA, address tokenB)
    external
    view
    returns (uint256);


  function getPoolFeeNumerator(
    address tokenA,
    address tokenB,
    uint256 poolId
  ) external view returns (uint24 feeNumerator);


  function getPoolAddress(address tokenA, address tokenB)
    external
    view
    returns (address pool);

}// GPL-2.0
pragma solidity ^0.8.4;

interface IUniswapPool {

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

}// GPL-2.0
pragma solidity >=0.7.6;

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

        uint256 twos = denominator & (~denominator + 1);
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
}// GPL-2.0
pragma solidity ^0.8.4;


contract UniswapTrader is
  Initializable,
  ModuleMapConsumer,
  Controlled,
  IUniswapTrader
{

  using SafeERC20Upgradeable for IERC20MetadataUpgradeable;

  struct Pool {
    uint24 feeNumerator;
    uint24 slippageNumerator;
  }

  struct TokenPair {
    address token0;
    address token1;
  }

  uint24 private constant FEE_DENOMINATOR = 1_000_000;
  uint24 private constant SLIPPAGE_DENOMINATOR = 1_000_000;
  address private factoryAddress;
  address private swapRouterAddress;

  mapping(address => mapping(address => Pool[])) private pools;
  mapping(address => mapping(address => Path)) private paths;
  mapping(address => mapping(address => bool)) private isMultihopPair;

  TokenPair[] private tokenPairs;

  event UniswapPoolAdded(
    address indexed token0,
    address indexed token1,
    uint24 fee,
    uint24 slippageNumerator
  );
  event UniswapPoolSlippageNumeratorUpdated(
    address indexed token0,
    address indexed token1,
    uint256 poolIndex,
    uint24 slippageNumerator
  );
  event UniswapPairPrimaryPoolUpdated(
    address indexed token0,
    address indexed token1,
    uint256 primaryPoolIndex
  );

  function initialize(
    address[] memory controllers_,
    address moduleMap_,
    address factoryAddress_,
    address swapRouterAddress_
  ) public initializer {

    __Controlled_init(controllers_, moduleMap_);
    __ModuleMapConsumer_init(moduleMap_);
    factoryAddress = factoryAddress_;
    swapRouterAddress = swapRouterAddress_;
  }

  function addPool(
    address tokenA,
    address tokenB,
    uint24 feeNumerator,
    uint24 slippageNumerator
  ) external override onlyManager {

    require(
      IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
        .getIsTokenAdded(tokenA),
      "UniswapTrader::addPool: TokenA has not been added in the Integration Map"
    );
    require(
      IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
        .getIsTokenAdded(tokenB),
      "UniswapTrader::addPool: TokenB has not been added in the Integration Map"
    );
    require(
      slippageNumerator <= SLIPPAGE_DENOMINATOR,
      "UniswapTrader::addPool: Slippage numerator cannot be greater than slippapge denominator"
    );
    require(
      IUniswapFactory(factoryAddress).getPool(tokenA, tokenB, feeNumerator) !=
        address(0),
      "UniswapTrader::addPool: Pool does not exist"
    );

    (address token0, address token1) = getTokensSorted(tokenA, tokenB);

    bool poolAdded;
    for (
      uint256 poolIndex;
      poolIndex < pools[token0][token1].length;
      poolIndex++
    ) {
      if (pools[token0][token1][poolIndex].feeNumerator == feeNumerator) {
        poolAdded = true;
      }
    }

    require(!poolAdded, "UniswapTrader::addPool: Pool has already been added");

    Pool memory newPool;
    newPool.feeNumerator = feeNumerator;
    newPool.slippageNumerator = slippageNumerator;
    pools[token0][token1].push(newPool);

    bool tokenPairAdded;
    for (uint256 pairIndex; pairIndex < tokenPairs.length; pairIndex++) {
      if (
        tokenPairs[pairIndex].token0 == token0 &&
        tokenPairs[pairIndex].token1 == token1
      ) {
        tokenPairAdded = true;
      }
    }

    if (!tokenPairAdded) {
      TokenPair memory newTokenPair;
      newTokenPair.token0 = token0;
      newTokenPair.token1 = token1;
      tokenPairs.push(newTokenPair);

      if (
        IERC20MetadataUpgradeable(token0).allowance(
          address(this),
          moduleMap.getModuleAddress(Modules.YieldManager)
        ) == 0
      ) {
        IERC20MetadataUpgradeable(token0).safeApprove(
          moduleMap.getModuleAddress(Modules.YieldManager),
          type(uint256).max
        );
      }

      if (
        IERC20MetadataUpgradeable(token1).allowance(
          address(this),
          moduleMap.getModuleAddress(Modules.YieldManager)
        ) == 0
      ) {
        IERC20MetadataUpgradeable(token1).safeApprove(
          moduleMap.getModuleAddress(Modules.YieldManager),
          type(uint256).max
        );
      }

      if (
        IERC20MetadataUpgradeable(token0).allowance(
          address(this),
          swapRouterAddress
        ) == 0
      ) {
        IERC20MetadataUpgradeable(token0).safeApprove(
          swapRouterAddress,
          type(uint256).max
        );
      }

      if (
        IERC20MetadataUpgradeable(token1).allowance(
          address(this),
          swapRouterAddress
        ) == 0
      ) {
        IERC20MetadataUpgradeable(token1).safeApprove(
          swapRouterAddress,
          type(uint256).max
        );
      }
    }

    emit UniswapPoolAdded(token0, token1, feeNumerator, slippageNumerator);
  }

  function updatePoolSlippageNumerator(
    address tokenA,
    address tokenB,
    uint256 poolIndex,
    uint24 slippageNumerator
  ) external override onlyManager {

    require(
      slippageNumerator <= SLIPPAGE_DENOMINATOR,
      "UniswapTrader:updatePoolSlippageNumerator: Slippage numerator must not be greater than slippage denominator"
    );
    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    require(
      pools[token0][token1][poolIndex].slippageNumerator != slippageNumerator,
      "UniswapTrader:updatePoolSlippageNumerator: Slippage numerator must be updated to a new number"
    );
    require(
      pools[token0][token1].length > poolIndex,
      "UniswapTrader:updatePoolSlippageNumerator: Pool does not exist"
    );

    pools[token0][token1][poolIndex].slippageNumerator = slippageNumerator;

    emit UniswapPoolSlippageNumeratorUpdated(
      token0,
      token1,
      poolIndex,
      slippageNumerator
    );
  }

  function updatePairPrimaryPool(
    address tokenA,
    address tokenB,
    uint256 primaryPoolIndex
  ) external override onlyManager {

    require(
      primaryPoolIndex != 0,
      "UniswapTrader::updatePairPrimaryPool: Specified index is already the primary pool"
    );
    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    require(
      primaryPoolIndex < pools[token0][token1].length,
      "UniswapTrader::updatePairPrimaryPool: Specified pool index does not exist"
    );

    uint24 newPrimaryPoolFeeNumerator = pools[token0][token1][primaryPoolIndex]
      .feeNumerator;
    uint24 newPrimaryPoolSlippageNumerator = pools[token0][token1][
      primaryPoolIndex
    ].slippageNumerator;

    pools[token0][token1][primaryPoolIndex].feeNumerator = pools[token0][
      token1
    ][0].feeNumerator;
    pools[token0][token1][primaryPoolIndex].slippageNumerator = pools[token0][
      token1
    ][0].slippageNumerator;

    pools[token0][token1][0].feeNumerator = newPrimaryPoolFeeNumerator;
    pools[token0][token1][0]
      .slippageNumerator = newPrimaryPoolSlippageNumerator;

    emit UniswapPairPrimaryPoolUpdated(token0, token1, primaryPoolIndex);
  }

  function swapExactInput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountIn
  ) external override onlyController returns (bool tradeSuccess) {

    IERC20MetadataUpgradeable tokenInErc20 = IERC20MetadataUpgradeable(tokenIn);

    if (isMultihopPair[tokenIn][tokenOut]) {
      Path memory path = getPathFor(tokenIn, tokenOut);
      IUniswapSwapRouter.ExactInputParams memory params = IUniswapSwapRouter
        .ExactInputParams({
          path: abi.encodePacked(
            path.tokenIn,
            path.firstPoolFee,
            path.tokenInTokenOut,
            path.secondPoolFee,
            path.tokenOut
          ),
          recipient: recipient,
          deadline: block.timestamp,
          amountIn: amountIn,
          amountOutMinimum: 0
        });

      try IUniswapSwapRouter(swapRouterAddress).exactInput(params) {
        tradeSuccess = true;
      } catch {
        tradeSuccess = false;
        tokenInErc20.safeTransfer(
          recipient,
          tokenInErc20.balanceOf(address(this))
        );
      }

      return tradeSuccess;
    }

    (address token0, address token1) = getTokensSorted(tokenIn, tokenOut);

    require(
      pools[token0][token1].length > 0,
      "UniswapTrader::swapExactInput: Pool has not been added"
    );
    require(
      tokenInErc20.balanceOf(address(this)) >= amountIn,
      "UniswapTrader::swapExactInput: Balance is less than trade amount"
    );

    uint256 amountOutMinimum = getAmountOutMinimum(tokenIn, tokenOut, amountIn);

    IUniswapSwapRouter.ExactInputSingleParams memory exactInputSingleParams;
    exactInputSingleParams.tokenIn = tokenIn;
    exactInputSingleParams.tokenOut = tokenOut;
    exactInputSingleParams.fee = pools[token0][token1][0].feeNumerator;
    exactInputSingleParams.recipient = recipient;
    exactInputSingleParams.deadline = block.timestamp;
    exactInputSingleParams.amountIn = amountIn;
    exactInputSingleParams.amountOutMinimum = amountOutMinimum;
    exactInputSingleParams.sqrtPriceLimitX96 = 0;

    try
      IUniswapSwapRouter(swapRouterAddress).exactInputSingle(
        exactInputSingleParams
      )
    {
      tradeSuccess = true;
    } catch {
      tradeSuccess = false;
      tokenInErc20.safeTransfer(
        recipient,
        tokenInErc20.balanceOf(address(this))
      );
    }
  }

  function swapExactOutput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountOut
  ) external override onlyController returns (bool tradeSuccess) {

    IERC20MetadataUpgradeable tokenInErc20 = IERC20MetadataUpgradeable(tokenIn);

    if (isMultihopPair[tokenIn][tokenOut]) {
      Path memory path = getPathFor(tokenIn, tokenOut);
      IUniswapSwapRouter.ExactOutputParams memory params = IUniswapSwapRouter
        .ExactOutputParams({
          path: abi.encodePacked(
            path.tokenIn,
            path.firstPoolFee,
            path.tokenInTokenOut,
            path.secondPoolFee,
            path.tokenOut
          ),
          recipient: recipient,
          deadline: block.timestamp,
          amountOut: amountOut,
          amountInMaximum: 0
        });

      try IUniswapSwapRouter(swapRouterAddress).exactOutput(params) {
        tradeSuccess = true;
      } catch {
        tradeSuccess = false;
        tokenInErc20.safeTransfer(
          recipient,
          tokenInErc20.balanceOf(address(this))
        );
      }

      return tradeSuccess;
    }
    (address token0, address token1) = getTokensSorted(tokenIn, tokenOut);
    require(
      pools[token0][token1][0].feeNumerator > 0,
      "UniswapTrader::swapExactOutput: Pool has not been added"
    );
    uint256 amountInMaximum = getAmountInMaximum(tokenIn, tokenOut, amountOut);
    require(
      tokenInErc20.balanceOf(address(this)) >= amountInMaximum,
      "UniswapTrader::swapExactOutput: Balance is less than trade amount"
    );

    IUniswapSwapRouter.ExactOutputSingleParams memory exactOutputSingleParams;
    exactOutputSingleParams.tokenIn = tokenIn;
    exactOutputSingleParams.tokenOut = tokenOut;
    exactOutputSingleParams.fee = pools[token0][token1][0].feeNumerator;
    exactOutputSingleParams.recipient = recipient;
    exactOutputSingleParams.deadline = block.timestamp;
    exactOutputSingleParams.amountOut = amountOut;
    exactOutputSingleParams.amountInMaximum = amountInMaximum;
    exactOutputSingleParams.sqrtPriceLimitX96 = 0;

    try
      IUniswapSwapRouter(swapRouterAddress).exactOutputSingle(
        exactOutputSingleParams
      )
    {
      tradeSuccess = true;
    } catch {
      tradeSuccess = false;
      tokenInErc20.safeTransfer(
        recipient,
        tokenInErc20.balanceOf(address(this))
      );
    }
  }

  function getPoolAddress(address tokenA, address tokenB)
    public
    view
    override
    returns (address pool)
  {

    uint24 feeNumerator = getPoolFeeNumerator(tokenA, tokenB, 0);
    pool = IUniswapFactory(factoryAddress).getPool(
      tokenA,
      tokenB,
      feeNumerator
    );
  }

  function getSqrtPriceX96(address tokenA, address tokenB)
    public
    view
    returns (uint256)
  {

    (uint160 sqrtPriceX96, , , , , , ) = IUniswapPool(
      getPoolAddress(tokenA, tokenB)
    ).slot0();
    return uint256(sqrtPriceX96);
  }

  function getPathFor(address tokenIn, address tokenOut)
    public
    view
    override
    returns (Path memory)
  {

    require(
      isMultihopPair[tokenIn][tokenOut],
      "There is an existing Pool for this pair"
    );

    return paths[tokenIn][tokenOut];
  }

  function setPathFor(
    address tokenIn,
    address tokenOut,
    uint256 firstPoolFee,
    address tokenInTokenOut,
    uint256 secondPoolFee
  ) public override onlyManager {

    paths[tokenIn][tokenOut] = Path(
      tokenIn,
      firstPoolFee,
      tokenInTokenOut,
      secondPoolFee,
      tokenOut
    );
    isMultihopPair[tokenIn][tokenOut] = true;
  }

  function getAmountOutMinimum(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) public view returns (uint256 amountOutMinimum) {

    uint256 estimatedAmountOut = getEstimatedTokenOut(
      tokenIn,
      tokenOut,
      amountIn
    );
    uint24 poolSlippageNumerator = getPoolSlippageNumerator(
      tokenIn,
      tokenOut,
      0
    );
    amountOutMinimum =
      (estimatedAmountOut * (SLIPPAGE_DENOMINATOR - poolSlippageNumerator)) /
      SLIPPAGE_DENOMINATOR;
  }

  function getAmountInMaximum(
    address tokenIn,
    address tokenOut,
    uint256 amountOut
  ) public view override returns (uint256 amountInMaximum) {

    uint256 estimatedAmountIn = getEstimatedTokenIn(
      tokenIn,
      tokenOut,
      amountOut
    );
    uint24 poolSlippageNumerator = getPoolSlippageNumerator(
      tokenIn,
      tokenOut,
      0
    );
    amountInMaximum =
      (estimatedAmountIn * (SLIPPAGE_DENOMINATOR + poolSlippageNumerator)) /
      SLIPPAGE_DENOMINATOR;
  }

  function getEstimatedTokenOut(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) public view override returns (uint256 amountOut) {

    if (isMultihopPair[tokenIn][tokenOut]) {
      Path memory path = getPathFor(tokenIn, tokenOut);
      uint256 amountOutTemp = getEstimatedTokenOut(
        path.tokenIn,
        path.tokenInTokenOut,
        amountIn
      );
      return
        getEstimatedTokenOut(
          path.tokenInTokenOut,
          path.tokenOut,
          amountOutTemp
        );
    }

    uint24 feeNumerator = getPoolFeeNumerator(tokenIn, tokenOut, 0);
    uint256 sqrtPriceX96 = getSqrtPriceX96(tokenIn, tokenOut);

    if (tokenIn < tokenOut) {
      amountOut =
        (FullMath.mulDiv(
          FullMath.mulDiv(amountIn, sqrtPriceX96, 2**96),
          sqrtPriceX96,
          2**96
        ) * (FEE_DENOMINATOR - feeNumerator)) /
        FEE_DENOMINATOR;
    } else {
      amountOut =
        (FullMath.mulDiv(
          FullMath.mulDiv(amountIn, 2**96, sqrtPriceX96),
          2**96,
          sqrtPriceX96
        ) * (FEE_DENOMINATOR - feeNumerator)) /
        FEE_DENOMINATOR;
    }
  }

  function getEstimatedTokenIn(
    address tokenIn,
    address tokenOut,
    uint256 amountOut
  ) public view returns (uint256 amountIn) {

    if (isMultihopPair[tokenIn][tokenOut]) {
      Path memory path = getPathFor(tokenIn, tokenOut);
      uint256 amountInTemp = getEstimatedTokenIn(
        path.tokenInTokenOut,
        path.tokenOut,
        amountOut
      );
      return
        getEstimatedTokenIn(path.tokenIn, path.tokenInTokenOut, amountInTemp);
    }

    uint24 feeNumerator = getPoolFeeNumerator(tokenIn, tokenOut, 0);
    uint256 sqrtPriceX96 = getSqrtPriceX96(tokenIn, tokenOut);

    if (tokenIn < tokenOut) {
      amountIn =
        (FullMath.mulDiv(
          FullMath.mulDiv(amountOut, 2**96, sqrtPriceX96),
          2**96,
          sqrtPriceX96
        ) * (FEE_DENOMINATOR - feeNumerator)) /
        FEE_DENOMINATOR;
    } else {
      amountIn =
        (FullMath.mulDiv(
          FullMath.mulDiv(amountOut, sqrtPriceX96, 2**96),
          sqrtPriceX96,
          2**96
        ) * (FEE_DENOMINATOR - feeNumerator)) /
        FEE_DENOMINATOR;
    }
  }

  function getPoolFeeNumerator(
    address tokenA,
    address tokenB,
    uint256 poolId
  ) public view override returns (uint24 feeNumerator) {

    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    require(
      poolId < pools[token0][token1].length,
      "UniswapTrader::getPoolFeeNumerator: Pool ID does not exist"
    );
    feeNumerator = pools[token0][token1][poolId].feeNumerator;
  }

  function getPoolSlippageNumerator(
    address tokenA,
    address tokenB,
    uint256 poolId
  ) public view returns (uint24 slippageNumerator) {

    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    return pools[token0][token1][poolId].slippageNumerator;
  }

  function getTokensSorted(address tokenA, address tokenB)
    public
    pure
    override
    returns (address token0, address token1)
  {

    if (tokenA < tokenB) {
      token0 = tokenA;
      token1 = tokenB;
    } else {
      token0 = tokenB;
      token1 = tokenA;
    }
  }

  function getTokensAndAmountsSorted(
    address tokenA,
    address tokenB,
    uint256 amountA,
    uint256 amountB
  )
    public
    pure
    returns (
      address token0,
      address token1,
      uint256 amount0,
      uint256 amount1
    )
  {

    if (tokenA < tokenB) {
      token0 = tokenA;
      token1 = tokenB;
      amount0 = amountA;
      amount1 = amountB;
    } else {
      token0 = tokenB;
      token1 = tokenA;
      amount0 = amountB;
      amount1 = amountA;
    }
  }

  function getFeeDenominator() external pure returns (uint24) {

    return FEE_DENOMINATOR;
  }

  function getSlippageDenominator() external pure returns (uint24) {

    return SLIPPAGE_DENOMINATOR;
  }

  function getTokenPairsLength() external view override returns (uint256) {

    return tokenPairs.length;
  }

  function getTokenPairPoolsLength(address tokenA, address tokenB)
    external
    view
    override
    returns (uint256)
  {

    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    return pools[token0][token1].length;
  }

  function getTokenPair(uint256 tokenPairIndex)
    external
    view
    returns (address, address)
  {

    require(
      tokenPairIndex < tokenPairs.length,
      "UniswapTrader::getTokenPair: Token pair does not exist"
    );
    return (
      tokenPairs[tokenPairIndex].token0,
      tokenPairs[tokenPairIndex].token1
    );
  }

  function getPool(
    address token0,
    address token1,
    uint256 poolIndex
  ) external view returns (uint24, uint24) {

    require(
      poolIndex < pools[token0][token1].length,
      "UniswapTrader:getPool: Pool does not exist"
    );
    return (
      pools[token0][token1][poolIndex].feeNumerator,
      pools[token0][token1][poolIndex].slippageNumerator
    );
  }
}