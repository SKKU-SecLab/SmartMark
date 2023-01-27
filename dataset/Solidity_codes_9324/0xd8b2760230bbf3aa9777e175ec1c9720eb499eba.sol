


pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


pragma solidity 0.7.5;

interface IUniswapV2Pair {


    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    )
        external;

}




pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity 0.7.5;




library NewUniswapV2Lib {

    using SafeMath for uint256;

    function getReservesByPair(
        address pair,
        bool direction
    )
        internal
        view
        returns (uint256 reserveIn, uint256 reserveOut)
    {

        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pair).getReserves();
        (reserveIn, reserveOut) = direction ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getAmountOut(
        uint256 amountIn,
        address pair,
        bool direction,
        uint256 fee
    )
        internal
        view
        returns (uint256 amountOut)
    {

        require(amountIn > 0, "UniswapV2Lib: INSUFFICIENT_INPUT_AMOUNT");
        (uint256 reserveIn, uint256 reserveOut) = getReservesByPair(pair, direction);
        uint256 amountInWithFee = amountIn.mul(fee);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = uint256(numerator / denominator);
    }

    function getAmountIn(
        uint256 amountOut,
        address pair,
        bool direction,
        uint256 fee
    )
        internal
        view
        returns (uint256 amountIn)
    {

        require(amountOut > 0, "UniswapV2Lib: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint256 reserveIn, uint256 reserveOut) = getReservesByPair(pair, direction);
        require(reserveOut > amountOut, "UniswapV2Lib: reserveOut should be greater than amountOut");
        uint256 numerator = reserveIn.mul(amountOut).mul(10000);
        uint256 denominator = reserveOut.sub(amountOut).mul(fee);
        amountIn = (numerator / denominator).add(1);
    }
}




pragma solidity >=0.6.2 <0.8.0;

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
}




pragma solidity >=0.6.0 <0.8.0;




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

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.7.5;


interface ITokenTransferProxy {


    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        external;

}


pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;





interface IERC20Permit {

    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

}

interface IERC20PermitLegacy {

    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

}

library Utils {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    
    uint256 constant MAX_UINT = type(uint256).max;

    struct SellData {
        address fromToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        Utils.Path[] path;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    struct BuyData {
        address adapter;
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        address payable beneficiary;
        Utils.Route[] route;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    struct MegaSwapSellData {
        address fromToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        Utils.MegaSwapPath[] path;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    struct SimpleData {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address[] callees;
        bytes exchangeData;
        uint256[] startIndexes;
        uint256[] values;
        address payable beneficiary;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    struct Adapter {
        address payable adapter;
        uint256 percent;
        uint256 networkFee;//NOT USED
        Route[] route;
    }

    struct Route {
        uint256 index;//Adapter at which index needs to be used
        address targetExchange;
        uint percent;
        bytes payload;
        uint256 networkFee;//NOT USED - Network fee is associated with 0xv3 trades
    }

    struct MegaSwapPath {
        uint256 fromAmountPercent;
        Path[] path;
    }

    struct Path {
        address to;
        uint256 totalNetworkFee;//NOT USED - Network fee is associated with 0xv3 trades
        Adapter[] adapters;
    }

    function ethAddress() internal pure returns (address) {return ETH_ADDRESS;}


    function maxUint() internal pure returns (uint256) {return MAX_UINT;}


    function approve(
        address addressToApprove,
        address token,
        uint256 amount
    ) internal {

        if (token != ETH_ADDRESS) {
            IERC20 _token = IERC20(token);

            uint allowance = _token.allowance(address(this), addressToApprove);

            if (allowance < amount) {
                _token.safeApprove(addressToApprove, 0);
                _token.safeIncreaseAllowance(addressToApprove, MAX_UINT);
            }
        }
    }

    function transferTokens(
        address token,
        address payable destination,
        uint256 amount
    )
    internal
    {

        if (amount > 0) {
            if (token == ETH_ADDRESS) {
                (bool result, ) = destination.call{value: amount, gas: 10000}("");
                require(result, "Failed to transfer Ether");
            }
            else {
                IERC20(token).safeTransfer(destination, amount);
            }
        }

    }

    function tokenBalance(
        address token,
        address account
    )
    internal
    view
    returns (uint256)
    {

        if (token == ETH_ADDRESS) {
            return account.balance;
        } else {
            return IERC20(token).balanceOf(account);
        }
    }

    function permit(
        address token,
        bytes memory permit
    )
        internal
    {

        if (permit.length == 32 * 7) {
            (bool success,) = token.call(abi.encodePacked(IERC20Permit.permit.selector, permit));
            require(success, "Permit failed");
        }

        if (permit.length == 32 * 8) {
            (bool success,) = token.call(abi.encodePacked(IERC20PermitLegacy.permit.selector, permit));
            require(success, "Permit failed");
        }
    }

}


pragma solidity 0.7.5;



abstract contract IWETH is IERC20 {
    function deposit() external virtual payable;
    function withdraw(uint256 amount) external virtual;
}


pragma solidity 0.7.5;







abstract contract NewUniswapV2 {
    using SafeMath for uint256;

    uint256 constant FEE_OFFSET = 161;
    uint256 constant DIRECTION_FLAG =
        0x0000000000000000000000010000000000000000000000000000000000000000;

    struct UniswapV2Data {
        address weth;
        uint256[] pools;
    }

    function swapOnUniswapV2Fork(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        bytes calldata payload
    )
        internal
    {
        UniswapV2Data memory data = abi.decode(payload, (UniswapV2Data));
        _swapOnUniswapV2Fork(
            address(fromToken),
            fromAmount,
            data.weth,
            data.pools
        );
    }

    function buyOnUniswapFork(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountInMax,
        uint256 amountOut,
        bytes calldata payload
    )
        internal
    {
        UniswapV2Data memory data = abi.decode(payload, (UniswapV2Data));

        _buyOnUniswapFork(
            address(fromToken),
            amountInMax,
            amountOut,
            data.weth,
            data.pools
        );
    }

    function _buyOnUniswapFork(
        address tokenIn,
        uint256 amountInMax,
        uint256 amountOut,
        address weth,
        uint256[] memory pools
    )
        private
        returns (uint256 tokensSold)
    {
        uint256 pairs = pools.length;

        require(pairs != 0, "At least one pool required");

        uint256[] memory amounts = new uint256[](pairs + 1);

        amounts[pairs] = amountOut;

        for (uint256 i = pairs; i != 0; --i) {
            uint256 p = pools[i - 1];
            amounts[i - 1] = NewUniswapV2Lib.getAmountIn(
                amounts[i],
                address(p),
                p & DIRECTION_FLAG == 0,
                p >> FEE_OFFSET
            );
        }

        tokensSold = amounts[0];
        require(tokensSold <= amountInMax, "UniswapV2Router: INSUFFICIENT_INPUT_AMOUNT");
        bool tokensBoughtEth;

        if (tokenIn == Utils.ethAddress()) {
            IWETH(weth).deposit{value: tokensSold}();
            require(IWETH(weth).transfer(address(pools[0]), tokensSold));
        } else {
            TransferHelper.safeTransfer(tokenIn, address(pools[0]), tokensSold);
            tokensBoughtEth = weth != address(0);
        }

        for (uint256 i = 0; i < pairs; ++i) {
            uint256 p = pools[i];
            (uint256 amount0Out, uint256 amount1Out) = p & DIRECTION_FLAG == 0
                ? (uint256(0), amounts[i + 1]) : (amounts[i + 1], uint256(0));
            IUniswapV2Pair(address(p)).swap(
                amount0Out,
                amount1Out,
                i + 1 == pairs ? address(this) : address(pools[i + 1]),
                ""
            );
        }

        if (tokensBoughtEth) {
            IWETH(weth).withdraw(amountOut);
        }
    }

    function _swapOnUniswapV2Fork(
        address tokenIn,
        uint256 amountIn,
        address weth,
        uint256[] memory pools
    )
        private
        returns (uint256 tokensBought)
    {
        uint256 pairs = pools.length;

        require(pairs != 0, "At least one pool required");

        bool tokensBoughtEth;

        if (tokenIn == Utils.ethAddress()) {
            IWETH(weth).deposit{value: amountIn}();
            require(IWETH(weth).transfer(address(pools[0]), amountIn));
        } else {
            TransferHelper.safeTransfer(tokenIn, address(pools[0]), amountIn);
            tokensBoughtEth = weth != address(0);
        }

        tokensBought = amountIn;

        for (uint256 i = 0; i < pairs; ++i) {
            uint256 p = pools[i];
            address pool = address(p);
            bool direction = p & DIRECTION_FLAG == 0;

            tokensBought = NewUniswapV2Lib.getAmountOut(
                tokensBought, pool, direction, p >> FEE_OFFSET
            );
            (uint256 amount0Out, uint256 amount1Out) = direction
                ? (uint256(0), tokensBought) : (tokensBought, uint256(0));
            IUniswapV2Pair(pool).swap(
                amount0Out,
                amount1Out,
                i + 1 == pairs ? address(this) : address(pools[i + 1]),
                ""
            );
        }

        if (tokensBoughtEth) {
            IWETH(weth).withdraw(tokensBought);
        }
    }
}


pragma solidity 0.7.5;


interface ISwapRouterUniV3 {


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

  function exactInputSingle(ExactInputSingleParams calldata params)
  external payable
  returns (uint256 amountOut);


  function exactOutputSingle(ExactOutputSingleParams calldata params)
  external payable returns (uint256 amountIn);


}


pragma solidity 0.7.5;


contract WethProvider {

    address public immutable WETH;

    constructor(address weth) public {
        WETH = weth;
    }
}


pragma solidity 0.7.5;





abstract contract UniswapV3 is WethProvider{

  struct UniswapV3Data {
    uint24 fee;
    uint256 deadline;
    uint160 sqrtPriceLimitX96;
  }

  function swapOnUniswapV3(
    IERC20 fromToken,
    IERC20 toToken,
    uint256 fromAmount,
    address exchange,
    bytes calldata payload
  )
    internal
  {

    UniswapV3Data memory data = abi.decode(payload, (UniswapV3Data));

    address _fromToken = address(fromToken) == Utils.ethAddress()
    ? WETH : address(fromToken);
    address _toToken = address(toToken) == Utils.ethAddress()
    ? WETH : address(toToken);

    if (address(fromToken) == Utils.ethAddress()) {
      IWETH(WETH).deposit{value : fromAmount}();
    }

    Utils.approve(address(exchange), _fromToken, fromAmount);

    ISwapRouterUniV3(exchange).exactInputSingle(ISwapRouterUniV3.ExactInputSingleParams(
      {
      tokenIn : _fromToken,
      tokenOut : _toToken,
      fee : data.fee,
      recipient : address(this),
      deadline : data.deadline,
      amountIn : fromAmount,
      amountOutMinimum : 1,
      sqrtPriceLimitX96 : data.sqrtPriceLimitX96
      }
      )
    );

    if (address(toToken) == Utils.ethAddress()) {
      IWETH(WETH).withdraw(
        IERC20(WETH).balanceOf(address(this))
      );
    }

  }


  function buyOnUniswapV3(
    IERC20 fromToken,
    IERC20 toToken,
    uint256 fromAmount,
    uint256 toAmount,
    address exchange,
    bytes calldata payload
  )
    internal
  {

    UniswapV3Data memory data = abi.decode(payload, (UniswapV3Data));

    address _fromToken = address(fromToken) == Utils.ethAddress()
    ? WETH : address(fromToken);
    address _toToken = address(toToken) == Utils.ethAddress()
    ? WETH : address(toToken);

    if (address(fromToken) == Utils.ethAddress()) {
      IWETH(WETH).deposit{value : fromAmount}();
    }

    Utils.approve(address(exchange), _fromToken, fromAmount);

    ISwapRouterUniV3(exchange).exactOutputSingle(ISwapRouterUniV3.ExactOutputSingleParams(
      {
      tokenIn : _fromToken,
      tokenOut : _toToken,
      fee : data.fee,
      recipient : address(this),
      deadline : data.deadline,
      amountOut : toAmount,
      amountInMaximum : fromAmount,
      sqrtPriceLimitX96 : data.sqrtPriceLimitX96
      }
      )
    );

    if (
      address(fromToken) == Utils.ethAddress() ||
      address(toToken) == Utils.ethAddress()
    ) {
      IWETH(WETH).withdraw(
        IERC20(WETH).balanceOf(address(this))
      );
    }

  }
}



pragma solidity 0.7.5;



library LibOrderV4 {

    struct Order {
        IERC20 makerToken;
        IERC20 takerToken;
        uint128 makerAmount;
        uint128 takerAmount;
        address maker;
        address taker;
        address txOrigin;
        bytes32 pool;
        uint64 expiry;
        uint256 salt;
    }

    enum SignatureType {
        ILLEGAL,
        INVALID,
        EIP712,
        ETHSIGN
    }

    struct Signature {
        SignatureType signatureType;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}


pragma solidity 0.7.5;






interface IZeroxV4 {


    function fillRfqOrder(
        LibOrderV4.Order calldata order,
        LibOrderV4.Signature calldata signature,
        uint128 takerTokenFillAmount
    )
        external
        payable
        returns (uint128, uint128);

}

abstract contract ZeroxV4 is WethProvider {
    using SafeMath for uint256;

    struct ZeroxV4Data {
        LibOrderV4.Order order;
        LibOrderV4.Signature signature;
    }

    function swapOnZeroXv4(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        address exchange,
        bytes calldata payload
    )
        internal
    {
        if (address(fromToken) == Utils.ethAddress()) {
            IWETH(WETH).deposit{value: fromAmount}();
        }

        _swapOn0xV4(
            fromToken,
            toToken,
            fromAmount,
            exchange,
            payload
        );
    }

    function buyOnZeroXv4(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmountMax,
        uint256 toAmount,
        address exchange,
        bytes calldata payload
    )
        internal
    {
        ZeroxV4Data memory data = abi.decode(payload, (ZeroxV4Data));

        require(toAmount <= data.order.makerAmount, "insufficient makerAmount");
        uint256 fromAmount = toAmount
            .mul(data.order.takerAmount)
            .add(data.order.makerAmount - 1) // make divide round up
            .div(data.order.makerAmount);
        require(fromAmount <= fromAmountMax, "insufficient fromAmountMax");

        address _fromToken = address(fromToken);
        address _toToken = address(toToken);
        require(_fromToken != _toToken, "fromToken should be different from toToken");

        if (address(fromToken) == Utils.ethAddress()) {
            _fromToken = WETH;
            IWETH(WETH).deposit{value: fromAmount}();
        }
        else if (address(toToken) == Utils.ethAddress()) {
            _toToken = WETH;
        }

        require(address(data.order.takerToken) == address(_fromToken), "Invalid from token!!");
        require(address(data.order.makerToken) == address(_toToken), "Invalid to token!!");

        Utils.approve(exchange, address(_fromToken), fromAmount);

        IZeroxV4(exchange).fillRfqOrder(
            data.order,
            data.signature,
            uint128(fromAmount)
        );

        if (
            address(fromToken) == Utils.ethAddress() ||
            address(toToken) == Utils.ethAddress()
        ) {
            uint256 amount = IERC20(WETH).balanceOf(address(this));
            if (amount > 0) {
                IWETH(WETH).withdraw(amount);
            }
        }
    }

    function _swapOn0xV4(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        address exchange,
        bytes memory payload) private {

        ZeroxV4Data memory data = abi.decode(payload, (ZeroxV4Data));

        address _fromToken = address(fromToken);
        address _toToken = address(toToken);
        require(_fromToken != _toToken, "fromToken should be different from toToken");

        if (address(fromToken) == Utils.ethAddress()) {
            _fromToken = WETH;
        }
        else if (address(toToken) == Utils.ethAddress()) {
            _toToken = WETH;
        }

        require(address(data.order.takerToken) == address(_fromToken), "Invalid from token!!");
        require(address(data.order.makerToken) == address(_toToken), "Invalid to token!!");

        Utils.approve(exchange, address(_fromToken), fromAmount);

        IZeroxV4(exchange).fillRfqOrder(
            data.order,
            data.signature,
            uint128(fromAmount)
        );

        if (address(toToken) == Utils.ethAddress()) {
            uint256 receivedAmount = Utils.tokenBalance(WETH, address(this));
            IWETH(WETH).withdraw(receivedAmount);
        }
    }
}


pragma solidity 0.7.5;


interface IBalancerPool {

    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut,
        uint maxPrice
    )
        external
        returns (
            uint tokenAmountOut,
            uint spotPriceAfter
        );



    function swapExactAmountOut(
        address tokenIn,
        uint maxAmountIn,
        address tokenOut,
        uint tokenAmountOut,
        uint maxPrice
    )
        external
        returns (
            uint tokenAmountIn,
            uint spotPriceAfter
        );

}


pragma solidity 0.7.5;






interface IBalancerProxy {


  struct Swap {
        address pool;
        uint tokenInParam; // tokenInAmount / maxAmountIn / limitAmountIn
        uint tokenOutParam; // minAmountOut / tokenAmountOut / limitAmountOut
        uint maxPrice;
    }

    function batchSwapExactIn(
        Swap[] calldata swaps,
        address tokenIn,
        address tokenOut,
        uint totalAmountIn,
        uint minTotalAmountOut
    )
        external
        returns (uint totalAmountOut);


    function batchSwapExactOut(
        Swap[] calldata swaps,
        address tokenIn,
        address tokenOut,
        uint maxTotalAmountIn
    )
        external
        returns (uint totalAmountIn);


    function batchEthInSwapExactIn(
        Swap[] calldata swaps,
        address tokenOut,
        uint minTotalAmountOut
    )
        external
        payable
        returns (uint totalAmountOut);


    function batchEthOutSwapExactIn(
        Swap[] calldata swaps,
        address tokenIn,
        uint totalAmountIn,
        uint minTotalAmountOut
    )
        external
        returns (uint totalAmountOut);


    function batchEthInSwapExactOut(
        Swap[] calldata swaps,
        address tokenOut
    )
        external
        payable
        returns (uint totalAmountIn);


    function batchEthOutSwapExactOut(
        Swap[] calldata swaps,
        address tokenIn,
        uint maxTotalAmountIn
    )
        external
        returns (uint totalAmountIn);

}

abstract contract Balancer is WethProvider {
    using SafeMath for uint256;

    struct BalancerData {
        IBalancerProxy.Swap[] swaps;
    }

    function swapOnBalancer(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        address exchangeProxy,
        bytes calldata payload
    )
        internal
    {
        BalancerData memory data = abi.decode(payload, (BalancerData));

        address _fromToken = address(fromToken) == Utils.ethAddress()
            ? WETH : address(fromToken);
        address _toToken = address(toToken) == Utils.ethAddress()
            ? WETH : address(toToken);

        if (address(fromToken) == Utils.ethAddress()) {
             IWETH(WETH).deposit{value: fromAmount}();
        }

        uint256 totalInParam;
        for (uint i = 0; i < data.swaps.length; ++i) {
            totalInParam = totalInParam.add(data.swaps[i].tokenInParam);
        }

        for (uint i = 0; i < data.swaps.length; ++i) {
            IBalancerProxy.Swap memory _swap = data.swaps[i];
            uint256 adjustedInParam =
                _swap.tokenInParam.mul(fromAmount).div(totalInParam);
            Utils.approve(
                _swap.pool,
                _fromToken,
                adjustedInParam
            );
            IBalancerPool(_swap.pool).swapExactAmountIn(
                _fromToken,
                adjustedInParam,
                _toToken,
                _swap.tokenOutParam,
                _swap.maxPrice
            );
        }

        if (address(toToken) == Utils.ethAddress()) {
            IWETH(WETH).withdraw(
                IERC20(WETH).balanceOf(address(this))
            );
        }
    }

    function buyOnBalancer(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchangeProxy,
        bytes calldata payload
    )
        internal
    {
        BalancerData memory data = abi.decode(payload, (BalancerData));

        address _fromToken = address(fromToken) == Utils.ethAddress()
            ? WETH : address(fromToken);
        address _toToken = address(toToken) == Utils.ethAddress()
            ? WETH : address(toToken);

        if (address(fromToken) == Utils.ethAddress()) {
            IWETH(WETH).deposit{value: fromAmount}();
        }

        _buyOnBalancer(
            _fromToken,
            _toToken,
            fromAmount,
            toAmount,
            data
        );

        if (
            address(fromToken) == Utils.ethAddress() ||
            address(toToken) == Utils.ethAddress()
        ) {
            IWETH(WETH).withdraw(
                IERC20(WETH).balanceOf(address(this))
            );
        }
    }

    function _buyOnBalancer(
        address _fromToken,
        address _toToken,
        uint256 fromAmount,
        uint256 toAmount,
        BalancerData memory data
    )
        private
    {
        uint256 totalInParam;
        uint256 totalOutParam;
        for (uint i = 0; i < data.swaps.length; ++i) {
            IBalancerProxy.Swap memory _swap = data.swaps[i];
            totalInParam = totalInParam.add(_swap.tokenInParam);
            totalOutParam = totalOutParam.add(_swap.tokenOutParam);
        }

        for (uint i = 0; i < data.swaps.length; ++i) {
            IBalancerProxy.Swap memory _swap = data.swaps[i];
            uint256 adjustedInParam =
                _swap.tokenInParam.mul(fromAmount).div(totalInParam);
            uint256 adjustedOutParam =
                _swap.tokenOutParam.mul(toAmount)
                    .add(totalOutParam - 1).div(totalOutParam);
            Utils.approve(_swap.pool, _fromToken, adjustedInParam);
            IBalancerPool(_swap.pool).swapExactAmountOut(
                _fromToken,
                adjustedInParam,
                _toToken,
                adjustedOutParam,
                _swap.maxPrice
            );
        }
    }
}


pragma solidity 0.7.5;



interface IBuyAdapter {


    function initialize(bytes calldata data) external;


    function buy(
        uint256 index,
        IERC20 fromToken,
        IERC20 toToken,
        uint256 maxFromAmount,
        uint256 toAmount,
        address targetExchange,
        bytes calldata payload
    )
        external
        payable;

}


pragma solidity 0.7.5;






contract BuyAdapter is IBuyAdapter, NewUniswapV2, UniswapV3, ZeroxV4, Balancer {

    using SafeMath for uint256;

    constructor(
        address _weth
    )
        WethProvider(_weth)
        public
    {
    }

    function initialize(bytes calldata data) override external {

        revert("METHOD NOT IMPLEMENTED");
    }

    function buy(
        uint256 index,
        IERC20 fromToken,
        IERC20 toToken,
        uint256 maxFromAmount,
        uint256 toAmount,
        address targetExchange,
        bytes calldata payload
    )
        external
        override
        payable
    {

        if (index == 1) {
            buyOnUniswapFork(
                fromToken,
                toToken,
                maxFromAmount,
                toAmount,
                payload
            );
        }
        else if (index == 2) {
            buyOnUniswapV3(
                fromToken,
                toToken,
                maxFromAmount,
                toAmount,
                targetExchange,
                payload
            );
        }
        else if (index == 3) {
            buyOnZeroXv4(
                fromToken,
                toToken,
                maxFromAmount,
                toAmount,
                targetExchange,
                payload
            );
        }
        else if (index == 4) {
            buyOnBalancer(
                fromToken,
                toToken,
                maxFromAmount,
                toAmount,
                targetExchange,
                payload
            );
        }
        else {
            revert("Index not supported");
        }
    }
}