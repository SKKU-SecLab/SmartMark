pragma solidity ^0.8.0;

interface IArchRouterImmutableState {

    function uniV3Factory() external view returns (address);


    function WETH() external view returns (address);

}// GPL-2.0-or-later
pragma solidity ^0.8.0;


abstract contract ArchRouterImmutableState is IArchRouterImmutableState {
    address public immutable override uniV3Factory;
    address public immutable override WETH;

    constructor(address _uniV3Factory, address _WETH) {
        uniV3Factory = _uniV3Factory;
        WETH = _WETH;
    }
}// MIT
pragma solidity ^0.8.0;
interface IERC20Extended {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function version() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferWithAuthorization(address from, address to, uint256 value, uint256 validAfter, uint256 validBefore, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) external;

    function receiveWithAuthorization(address from, address to, uint256 value, uint256 validAfter, uint256 validBefore, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function nonces(address) external view returns (uint);

    function getDomainSeparator() external view returns (bytes32);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function DOMAIN_TYPEHASH() external view returns (bytes32);

    function VERSION_HASH() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH() external view returns (bytes32);

    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH() external view returns (bytes32);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
}// MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {

  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3Pool
{

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

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


interface IUniV3Router is IUniswapV3SwapCallback {

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
pragma solidity ^0.8.0;

interface IWETH {

    function deposit() external payable;

    function withdraw(uint256) external;

    function transfer(address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

}// MIT
pragma solidity ^0.8.0;


library RouteLib {

  address internal constant _SUSHI_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
  bytes32 internal constant _SUSHI_ROUTER_INIT_HASH = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;
  bytes32 internal constant _UNI_V2_ROUTER_INIT_HASH = 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;
  bytes32 internal constant _UNI_V3_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

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

  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

    require(tokenA != tokenB, 'RouteLib: IDENTICAL_ADDRESSES');
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), 'RouteLib: ZERO_ADDRESS');
  }

  function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

    (address token0, address token1) = sortTokens(tokenA, tokenB);
    bytes32 initHash = factory == _SUSHI_FACTORY ? _SUSHI_ROUTER_INIT_HASH : _UNI_V2_ROUTER_INIT_HASH;
    pair = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex'ff',
              factory,
              keccak256(abi.encodePacked(token0, token1)),
              initHash // init code hash
            )
          )
        )
      )
    );
  }

  function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {

      require(key.token0 < key.token1);
      pool = address(
          uint160(
              uint256(
                  keccak256(
                      abi.encodePacked(
                          hex'ff',
                          factory,
                          keccak256(abi.encode(key.token0, key.token1, key.fee)),
                          _UNI_V3_INIT_CODE_HASH
                      )
                  )
              )
          )
      );
  }

  function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

    (address token0,) = sortTokens(tokenA, tokenB);
    (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

    require(amountA > 0, 'RouteLib: INSUFFICIENT_AMOUNT');
    require(reserveA > 0 && reserveB > 0, 'RouteLib: INSUFFICIENT_LIQUIDITY');
    amountB = amountA * (reserveB) / reserveA;
  }

  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

    require(amountIn > 0, 'RouteLib: INSUFFICIENT_INPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'RouteLib: INSUFFICIENT_LIQUIDITY');
    uint amountInWithFee = amountIn * 997;
    uint numerator = amountInWithFee * reserveOut;
    uint denominator = reserveIn * 1000 + amountInWithFee;
    amountOut = numerator / denominator;
  }

  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

    require(amountOut > 0, 'RouteLib: INSUFFICIENT_OUTPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'RouteLib: INSUFFICIENT_LIQUIDITY');
    uint numerator = reserveIn * amountOut * 1000;
    uint denominator = (reserveOut - amountOut) * 997;
    amountIn = (numerator / denominator) + 1;
  }

  function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

    require(path.length >= 2, 'RouteLib: INVALID_PATH');
    amounts = new uint[](path.length);
    amounts[0] = amountIn;
    for (uint i; i < path.length - 1; i++) {
      (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
      amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
    }
  }

  function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

    require(path.length >= 2, 'RouteLib: INVALID_PATH');
    amounts = new uint[](path.length);
    amounts[amounts.length - 1] = amountOut;
    for (uint i = path.length - 1; i > 0; i--) {
      (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
      amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
    }
  }
}// MIT
pragma solidity ^0.8.0;

library TransferHelper {

  function safeApprove(
    address token,
    address to,
    uint256 value
  ) internal {

    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::safeApprove: approve failed'
    );
  }

  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {

    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::safeTransfer: transfer failed'
    );
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
  ) internal {

    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::transferFrom: transferFrom failed'
    );
  }

  function safeTransferETH(address to, uint256 value) internal {

    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
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
pragma solidity ^0.8.0;

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
pragma solidity ^0.8.0;


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
pragma solidity ^0.8.0;


library CallbackValidation {

    function verifyCallback(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (IUniswapV3Pool pool) {

        return verifyCallback(factory, RouteLib.getPoolKey(tokenA, tokenB, fee));
    }

    function verifyCallback(address factory, RouteLib.PoolKey memory poolKey)
        internal
        view
        returns (IUniswapV3Pool pool)
    {

        pool = IUniswapV3Pool(RouteLib.computeAddress(factory, poolKey));
        require(msg.sender == address(pool));
    }
}// GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IPayments {

    function unwrapWETH(uint256 amountMinimum, address recipient) external payable;


    function refundETH() external payable;


    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;


    function unwrapWETHAndTip(
        uint256 tipAmount, 
        uint256 amountMinimum,
        address recipient
    ) external payable;


    function tip(
        uint256 tipAmount
    ) external payable;

}// GPL-2.0-or-later
pragma solidity ^0.8.0;


interface IPaymentsWithFee is IPayments {

    function unwrapWETHWithFee(
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) external payable;


    function sweepTokenWithFee(
        address token,
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) external payable;

}// GPL-2.0-or-later
pragma solidity ^0.8.0;


abstract contract Payments is IPayments, ArchRouterImmutableState {
    receive() external payable {
        require(msg.sender == WETH, 'Not WETH');
    }

    function unwrapWETH(uint256 amountMinimum, address recipient) external payable override {
        uint256 balanceWETH = withdrawWETH(amountMinimum);
        TransferHelper.safeTransferETH(recipient, balanceWETH);
    }

    function unwrapWETHAndTip(uint256 tipAmount, uint256 amountMinimum, address recipient) external payable override {
        uint256 balanceWETH = withdrawWETH(amountMinimum);
        tip(tipAmount);
        if(balanceWETH > tipAmount) {
            TransferHelper.safeTransferETH(recipient, balanceWETH - tipAmount);
        }
    }

    function tip(uint256 tipAmount) public payable override {
        TransferHelper.safeTransferETH(block.coinbase, tipAmount);
    }

    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable override {
        uint256 balanceToken = IERC20Extended(token).balanceOf(address(this));
        require(balanceToken >= amountMinimum, 'Insufficient token');

        if (balanceToken > 0) {
            TransferHelper.safeTransfer(token, recipient, balanceToken);
        }
    }

    function refundETH() external payable override {
        if (address(this).balance > 0) TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }

    function withdrawWETH(uint256 amountMinimum) public returns(uint256 balanceWETH){
        balanceWETH = IWETH(WETH).balanceOf(address(this));
        require(balanceWETH >= amountMinimum && balanceWETH > 0, 'Insufficient WETH');
        IWETH(WETH).withdraw(balanceWETH);
    }

    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH && address(this).balance >= value) {
            IWETH(WETH).deposit{value: value}(); // wrap only what is needed to pay
            IWETH(WETH).transfer(recipient, value);
        } else if (payer == address(this)) {
            TransferHelper.safeTransfer(token, recipient, value);
        } else {
            TransferHelper.safeTransferFrom(token, payer, recipient, value);
        }
    }
}// GPL-2.0-or-later
pragma solidity ^0.8.0;


abstract contract PaymentsWithFee is Payments, IPaymentsWithFee {
    function unwrapWETHWithFee(
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) public payable override {
        require(feeBips > 0 && feeBips <= 100);

        uint256 balanceWETH = IWETH(WETH).balanceOf(address(this));
        require(balanceWETH >= amountMinimum, 'Insufficient WETH');

        if (balanceWETH > 0) {
            IWETH(WETH).withdraw(balanceWETH);
            uint256 feeAmount = (balanceWETH * feeBips) / 10_000;
            if (feeAmount > 0) TransferHelper.safeTransferETH(feeRecipient, feeAmount);
            TransferHelper.safeTransferETH(recipient, balanceWETH - feeAmount);
        }
    }

    function sweepTokenWithFee(
        address token,
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) public payable override {
        require(feeBips > 0 && feeBips <= 100);

        uint256 balanceToken = IERC20Extended(token).balanceOf(address(this));
        require(balanceToken >= amountMinimum, 'Insufficient token');

        if (balanceToken > 0) {
            uint256 feeAmount = (balanceToken * feeBips) / 10_000;
            if (feeAmount > 0) TransferHelper.safeTransfer(token, feeRecipient, feeAmount);
            TransferHelper.safeTransfer(token, recipient, balanceToken - feeAmount);
        }
    }
}// GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IMulticall {

    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

}// GPL-2.0-or-later
pragma solidity ^0.8.0;


abstract contract Multicall is IMulticall {
    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}// GPL-2.0-or-later
pragma solidity ^0.8.0;

interface ISelfPermit {

    function selfPermit(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;


    function selfPermitIfNecessary(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;


    function selfPermitAllowed(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;


    function selfPermitAllowedIfNecessary(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

}// GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IERC20PermitAllowed {

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// GPL-2.0-or-later
pragma solidity ^0.8.0;


abstract contract SelfPermit is ISelfPermit {
    function selfPermit(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable override {
        IERC20Extended(token).permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    function selfPermitIfNecessary(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable override {
        if (IERC20Extended(token).allowance(msg.sender, address(this)) < value) selfPermit(token, value, deadline, v, r, s);
    }

    function selfPermitAllowed(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable override {
        IERC20PermitAllowed(token).permit(msg.sender, address(this), nonce, expiry, true, v, r, s);
    }

    function selfPermitAllowedIfNecessary(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable override {
        if (IERC20Extended(token).allowance(msg.sender, address(this)) < type(uint256).max)
            selfPermitAllowed(token, nonce, expiry, v, r, s);
    }
}//MIT
pragma solidity ^0.8.0;



contract ArcherSwapRouter is
    IUniV3Router,
    ArchRouterImmutableState,
    PaymentsWithFee,
    Multicall,
    SelfPermit
{

    using Path for bytes;
    using SafeCast for uint256;

    uint256 private constant DEFAULT_AMOUNT_IN_CACHED = type(uint256).max;

    uint256 private amountInCached = DEFAULT_AMOUNT_IN_CACHED;

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;

    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    struct Trade {
        uint amountIn;
        uint amountOut;
        address[] path;
        address payable to;
        uint256 deadline;
    }

    struct SwapCallbackData {
        bytes path;
        address payer;
    }

    constructor(address _uniV3Factory, address _WETH) ArchRouterImmutableState(_uniV3Factory, _WETH) {}

    function swapExactTokensForETHAndTipAmount(
        address factory,
        Trade calldata trade,
        uint256 tipAmount
    ) external payable {

        require(trade.path[trade.path.length - 1] == WETH, 'ArchRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            trade.path[0], msg.sender, RouteLib.pairFor(factory, trade.path[0], trade.path[1]), trade.amountIn
        );
        _exactInputSwap(factory, trade.path, address(this));
        uint256 amountOut = IWETH(WETH).balanceOf(address(this));
        require(amountOut >= trade.amountOut, 'ArchRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);

        tip(tipAmount);
        TransferHelper.safeTransferETH(trade.to, amountOut - tipAmount);
    }

    function swapTokensForExactETHAndTipAmount(
        address factory,
        Trade calldata trade,
        uint256 tipAmount
    ) external payable {

        require(trade.path[trade.path.length - 1] == WETH, 'ArchRouter: INVALID_PATH');
        uint[] memory amounts = RouteLib.getAmountsIn(factory, trade.amountOut, trade.path);
        require(amounts[0] <= trade.amountIn, 'ArchRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            trade.path[0], msg.sender, RouteLib.pairFor(factory, trade.path[0], trade.path[1]), amounts[0]
        );
        _exactOutputSwap(factory, amounts, trade.path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        tip(tipAmount);
        TransferHelper.safeTransferETH(trade.to, trade.amountOut - tipAmount);
    }

    function swapExactETHForTokensAndTipAmount(
        address factory,
        Trade calldata trade,
        uint256 tipAmount
    ) external payable {

        tip(tipAmount);
        require(trade.path[0] == WETH, 'ArchRouter: INVALID_PATH');
        uint256 inputAmount = msg.value - tipAmount;
        IWETH(WETH).deposit{value: inputAmount}();
        assert(IWETH(WETH).transfer(RouteLib.pairFor(factory, trade.path[0], trade.path[1]), inputAmount));
        uint256 balanceBefore = IERC20Extended(trade.path[trade.path.length - 1]).balanceOf(trade.to);
        _exactInputSwap(factory, trade.path, trade.to);
        require(
            IERC20Extended(trade.path[trade.path.length - 1]).balanceOf(trade.to) - balanceBefore >= trade.amountOut,
            'ArchRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapETHForExactTokensAndTipAmount(
        address factory,
        Trade calldata trade,
        uint256 tipAmount
    ) external payable {

        tip(tipAmount);
        require(trade.path[0] == WETH, 'ArchRouter: INVALID_PATH');
        uint[] memory amounts = RouteLib.getAmountsIn(factory, trade.amountOut, trade.path);
        uint256 inputAmount = msg.value - tipAmount;
        require(amounts[0] <= inputAmount, 'ArchRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(RouteLib.pairFor(factory, trade.path[0], trade.path[1]), amounts[0]));
        _exactOutputSwap(factory, amounts, trade.path, trade.to);

        if (inputAmount > amounts[0]) {
            TransferHelper.safeTransferETH(msg.sender, inputAmount - amounts[0]);
        }
    }

    function swapExactTokensForTokensAndTipAmount(
        address factory,
        Trade calldata trade
    ) external payable {

        tip(msg.value);
        _swapExactTokensForTokens(factory, trade);
    }

    function swapExactTokensForTokensAndTipPct(
        address factory,
        Trade calldata trade,
        address[] calldata pathToEth,
        uint32 tipPct
    ) external payable {

        _swapExactTokensForTokens(factory, trade);
        IERC20Extended toToken = IERC20Extended(pathToEth[0]);
        uint256 contractTokenBalance = toToken.balanceOf(address(this));
        uint256 tipAmount = (contractTokenBalance * tipPct) / 1000000;
        TransferHelper.safeTransfer(pathToEth[0], trade.to, contractTokenBalance - tipAmount);
        _tipWithTokens(factory, pathToEth);
    }

    function swapTokensForExactTokensAndTipAmount(
        address factory,
        Trade calldata trade
    ) external payable {

        tip(msg.value);
        _swapTokensForExactTokens(factory, trade);
    }

    function swapTokensForExactTokensAndTipPct(
        address factory,
        Trade calldata trade,
        address[] calldata pathToEth,
        uint32 tipPct
    ) external payable {

        _swapTokensForExactTokens(factory, trade);
        IERC20Extended toToken = IERC20Extended(pathToEth[0]);
        uint256 contractTokenBalance = toToken.balanceOf(address(this));
        uint256 tipAmount = (contractTokenBalance * tipPct) / 1000000;
        TransferHelper.safeTransfer(pathToEth[0], trade.to, contractTokenBalance - tipAmount);
        _tipWithTokens(factory, pathToEth);
    }

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) private view returns (IUniswapV3Pool) {

        return IUniswapV3Pool(RouteLib.computeAddress(uniV3Factory, RouteLib.getPoolKey(tokenA, tokenB, fee)));
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external override {

        require(amount0Delta > 0 || amount1Delta > 0); // swaps entirely within 0-liquidity regions are not supported
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();
        CallbackValidation.verifyCallback(uniV3Factory, tokenIn, tokenOut, fee);

        (bool isExactInput, uint256 amountToPay) =
            amount0Delta > 0
                ? (tokenIn < tokenOut, uint256(amount0Delta))
                : (tokenOut < tokenIn, uint256(amount1Delta));
        if (isExactInput) {
            pay(tokenIn, data.payer, msg.sender, amountToPay);
        } else {
            if (data.path.hasMultiplePools()) {
                data.path = data.path.skipToken();
                _exactOutputInternal(amountToPay, msg.sender, 0, data);
            } else {
                amountInCached = amountToPay;
                tokenIn = tokenOut; // swap in/out because exact output swaps are reversed
                pay(tokenIn, data.payer, msg.sender, amountToPay);
            }
        }
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        public
        payable
        override
        returns (uint256 amountOut)
    {

        amountOut = _exactInputInternal(
            params.amountIn,
            params.recipient,
            params.sqrtPriceLimitX96,
            SwapCallbackData({path: abi.encodePacked(params.tokenIn, params.fee, params.tokenOut), payer: msg.sender})
        );
        require(amountOut >= params.amountOutMinimum, 'Too little received');
    }

    function exactInputSingleAndTipAmount(ExactInputSingleParams calldata params, uint256 tipAmount)
        external
        payable
        returns (uint256 amountOut)
    {

        amountOut = exactInputSingle(params);
        tip(tipAmount);
    }

    function exactInput(ExactInputParams memory params)
        public
        payable
        override
        returns (uint256 amountOut)
    {

        address payer = msg.sender; // msg.sender pays for the first hop

        while (true) {
            bool hasMultiplePools = params.path.hasMultiplePools();

            params.amountIn = _exactInputInternal(
                params.amountIn,
                hasMultiplePools ? address(this) : params.recipient, // for intermediate swaps, this contract custodies
                0,
                SwapCallbackData({
                    path: params.path.getFirstPool(), // only the first pool in the path is necessary
                    payer: payer
                })
            );

            if (hasMultiplePools) {
                payer = address(this); // at this point, the caller has paid
                params.path = params.path.skipToken();
            } else {
                amountOut = params.amountIn;
                break;
            }
        }

        require(amountOut >= params.amountOutMinimum, 'Too little received');
    }

    function exactInputAndTipAmount(ExactInputParams calldata params, uint256 tipAmount)
        external
        payable
        returns (uint256 amountOut)
    {

        amountOut = exactInput(params);
        tip(tipAmount);
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params)
        public
        payable
        override
        returns (uint256 amountIn)
    {

        amountIn = _exactOutputInternal(
            params.amountOut,
            params.recipient,
            params.sqrtPriceLimitX96,
            SwapCallbackData({path: abi.encodePacked(params.tokenOut, params.fee, params.tokenIn), payer: msg.sender})
        );

        require(amountIn <= params.amountInMaximum, 'Too much requested');
        amountInCached = DEFAULT_AMOUNT_IN_CACHED;
    }

    function exactOutputSingleAndTipAmount(ExactOutputSingleParams calldata params, uint256 tipAmount)
        external
        payable
        returns (uint256 amountIn)
    {

        amountIn = exactOutputSingle(params);
        tip(tipAmount);
    }

    function exactOutput(ExactOutputParams calldata params)
        public
        payable
        override
        returns (uint256 amountIn)
    {

        _exactOutputInternal(
            params.amountOut,
            params.recipient,
            0,
            SwapCallbackData({path: params.path, payer: msg.sender})
        );

        amountIn = amountInCached;
        require(amountIn <= params.amountInMaximum, 'Too much requested');
        amountInCached = DEFAULT_AMOUNT_IN_CACHED;
    }

    function exactOutputAndTipAmount(ExactOutputParams calldata params, uint256 tipAmount)
        external
        payable
        returns (uint256 amountIn)
    {

        amountIn = exactOutput(params);
        tip(tipAmount);
    }

    function _exactInputInternal(
        uint256 amountIn,
        address recipient,
        uint160 sqrtPriceLimitX96,
        SwapCallbackData memory data
    ) private returns (uint256 amountOut) {

        if (recipient == address(0)) recipient = address(this);

        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0, int256 amount1) =
            getPool(tokenIn, tokenOut, fee).swap(
                recipient,
                zeroForOne,
                amountIn.toInt256(),
                sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1)
                    : sqrtPriceLimitX96,
                abi.encode(data)
            );

        return uint256(-(zeroForOne ? amount1 : amount0));
    }

    function _exactOutputInternal(
        uint256 amountOut,
        address recipient,
        uint160 sqrtPriceLimitX96,
        SwapCallbackData memory data
    ) private returns (uint256 amountIn) {

        if (recipient == address(0)) recipient = address(this);

        (address tokenOut, address tokenIn, uint24 fee) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0Delta, int256 amount1Delta) =
            getPool(tokenIn, tokenOut, fee).swap(
                recipient,
                zeroForOne,
                -amountOut.toInt256(),
                sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1)
                    : sqrtPriceLimitX96,
                abi.encode(data)
            );

        uint256 amountOutReceived;
        (amountIn, amountOutReceived) = zeroForOne
            ? (uint256(amount0Delta), uint256(-amount1Delta))
            : (uint256(amount1Delta), uint256(-amount0Delta));
        if (sqrtPriceLimitX96 == 0) require(amountOutReceived == amountOut);
    }

    function _swapExactTokensForTokens(
        address factory,
        Trade calldata trade
    ) internal {

        TransferHelper.safeTransferFrom(
            trade.path[0], msg.sender, RouteLib.pairFor(factory, trade.path[0], trade.path[1]), trade.amountIn
        );
        uint balanceBefore = IERC20Extended(trade.path[trade.path.length - 1]).balanceOf(trade.to);
        _exactInputSwap(factory, trade.path, trade.to);
        require(
            IERC20Extended(trade.path[trade.path.length - 1]).balanceOf(trade.to) - balanceBefore >= trade.amountOut,
            'ArchRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function _swapTokensForExactTokens(
        address factory,
        Trade calldata trade
    ) internal {

        uint[] memory amounts = RouteLib.getAmountsIn(factory, trade.amountOut, trade.path);
        require(amounts[0] <= trade.amountIn, 'ArchRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            trade.path[0], msg.sender, RouteLib.pairFor(factory, trade.path[0], trade.path[1]), amounts[0]
        );
        _exactOutputSwap(factory, amounts, trade.path, trade.to);
    }

    function _exactInputSwap(
        address factory, 
        address[] memory path,
        address _to
    ) internal virtual {

        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = RouteLib.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(RouteLib.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            {
                (uint reserve0, uint reserve1,) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20Extended(input).balanceOf(address(pair)) - reserveInput;
                amountOutput = RouteLib.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? RouteLib.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function _exactOutputSwap(
        address factory, 
        uint[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {

        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = RouteLib.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? RouteLib.pairFor(factory, output, path[i + 2]) : _to;
            IUniswapV2Pair(RouteLib.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    function _tipWithTokens(
        address factory,
        address[] memory path
    ) internal {

        _exactInputSwap(factory, path, address(this));
        uint256 amountOut = IWETH(WETH).balanceOf(address(this));
        IWETH(WETH).withdraw(amountOut);

        tip(address(this).balance);
    }
}