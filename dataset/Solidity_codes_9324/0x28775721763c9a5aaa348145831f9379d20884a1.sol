
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// AGPL-3.0

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// AGPL-3.0

pragma solidity ^0.8.0;


interface IPool {

    function coins(uint256 index) external view returns(IERC20);

    function getA() external view returns (uint256);

    function getTokenIndex(address token) external view returns (uint8);


    function getVirtualPrice() external view returns (uint256);


    function calculateSwap(uint8 tokenIndexFrom, uint8 tokenIndexTo, uint256 dx) external view returns (uint256 dy);

    function calculateRemoveLiquidity(uint256 amount) external view returns (uint256[] memory);

    function calculateTokenAmount(uint256[] calldata amounts, bool deposit) external view returns (uint256);

    function calculateWithdrawOneToken(uint256 tokenAmount, uint8 tokenIndex) external view returns (uint256 amount);


    function swap(uint8 tokenIndexFrom, uint8 tokenIndexTo, uint256 dx, uint256 minDy, uint256 deadline) external returns (uint256);

    function addLiquidity(uint256[] memory amounts, uint256 minToMint, uint256 deadline) external returns (uint256);

    function removeLiquidity(uint256 amount, uint256[] calldata minAmounts, uint256 deadline) external returns (uint256[] memory);

    function removeLiquidityOneToken(uint256 tokenAmount, uint8 tokenIndex, uint256 minAmount, uint256 deadline) external returns (uint256);

    function removeLiquidityImbalance(uint256[] calldata amounts, uint256 maxBurnAmount, uint256 deadline) external returns (uint256);


    function applySwapFee(uint256 newSwapFee) external;

    function applyAdminFee(uint256 newAdminFee) external;

    function getAdminBalance(uint256 index) external view returns (uint256);

    function withdrawAdminFee(address receiver) external;

    function rampA(uint256 _futureA, uint256 _futureTime) external;

    function stopRampA() external;

}// AGPL-3.0

pragma solidity >=0.8.0;

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

}// AGPL-3.0

pragma solidity ^0.8.0;

interface IWETH {

    function deposit() external payable;

    function withdraw(uint wad) external;


    function transfer(address dst, uint wad) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// AGPL-3.0

pragma solidity >=0.8.0;


library EthereumUniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            )))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
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
}// AGPL-3.0

pragma solidity >=0.8.0;

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

}// AGPL-3.0

pragma solidity ^0.8.0;

interface IWrapper {

    function bridgeOut(
        address pTokenAddress,
        uint256 amount,
        uint64 toChainId,
        bytes memory toAddress,
        bytes memory callData
    ) external payable returns(bool);


    function swapAndBridgeOut(
        address poolAddress, address tokenFrom, address tokenTo, uint256 dx, uint256 minDy, uint256 deadline, // args for swap
        uint64 toChainId, bytes memory toAddress, bytes memory callData                                       // args for bridge
    ) external payable returns(bool);


    function swapAndBridgeOutNativeToken(
        address poolAddress, address tokenTo, uint256 dx, uint256 minDy, uint256 deadline, // args for swap
        uint64 toChainId, bytes memory toAddress, bytes memory callData                    // args for bridge
    ) external payable returns(bool);


    function depositAndBridgeOut(
        address originalToken,
        address pTokenAddress,
        uint256 amount,
        uint64 toChainId,
        bytes memory toAddress,
        bytes memory callData
    ) external payable returns(bool);


    function depositAndBridgeOutNativeToken(
        address pTokenAddress,
        uint256 amount,
        uint64 toChainId,
        bytes memory toAddress,
        bytes memory callData
    ) external payable returns(bool);


    function bridgeOutAndWithdraw(
        address pTokenAddress,
        uint64 toChainId,
        bytes memory toAddress,
        uint256 amount
    ) external payable returns(bool);

}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// AGPL-3.0

pragma solidity ^0.8.0;


contract O3EthereumUniswapAggregator is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event LOG_AGG_SWAP (
        uint256 amountOut,
        uint256 fee
    );

    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public O3Wrapper = 0xeCF2B548e5c21028B0b60363207700fA421B6EcB;
    address public feeCollector;

    uint256 public aggregatorFee = 3 * 10 ** 7;
    uint256 public constant FEE_DENOMINATOR = 10 ** 10;
    uint256 private constant MAX_AGGREGATOR_FEE = 5 * 10**8;

    modifier ensure(uint deadline) {

        require(deadline >= block.timestamp, 'O3Aggregator: EXPIRED');
        _;
    }

    constructor (address _feeCollector) {
        feeCollector = _feeCollector;
    }

    receive() external payable { }

    function setWETH(address _weth) external onlyOwner {

        WETH = _weth;
    }

    function setFactory(address _factory) external onlyOwner {

        factory = _factory;
    }

    function setO3Wrapper(address _wrapper) external onlyOwner {

        O3Wrapper = _wrapper;
    }

    function setFeeCollector(address _feeCollector) external onlyOwner {

        feeCollector = _feeCollector;
    }

    function setAggregatorFee(uint _fee) external onlyOwner {

        require(_fee < MAX_AGGREGATOR_FEE, "aggregator fee exceeds maximum");
        aggregatorFee = _fee;
    }

    function rescueFund(address tokenAddress) external onlyOwner {

        IERC20 token = IERC20(tokenAddress);
        if (tokenAddress == WETH && address(this).balance > 0) {
            (bool success,) = _msgSender().call{value: address(this).balance}(new bytes(0));
            require(success, 'ETH_TRANSFER_FAILED');
        }
        token.safeTransfer(_msgSender(), token.balanceOf(address(this)));
    }

    function swapExactPTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        address callproxy,
        address poolAddress,
        uint poolAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline,
        uint aggSwapAmountOutMin,
        bool unwrapETH
    ) external virtual ensure(deadline) {

        address caller = _msgSender();

        if (callproxy != address(0) && amountIn == 0) {
            amountIn = IERC20(path[0]).allowance(callproxy, address(this));
            caller = callproxy;
        }

        require(amountIn != 0, "O3Aggregator: amountIn cannot be zero");
        IERC20(path[0]).safeTransferFrom(caller, address(this), amountIn);

        IERC20(path[0]).safeApprove(poolAddress, amountIn);
        amountIn = IPool(poolAddress).swap(1, 0, amountIn, poolAmountOutMin, deadline);

        uint amountOut = _swapExactTokensForTokensSupportingFeeOnTransferTokens(false, amountIn, aggSwapAmountOutMin, path[1:]);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);
        emit LOG_AGG_SWAP(amountOut, feeAmount);

        if (unwrapETH) {
            require(path[path.length - 1] == WETH, "O3Aggregator: INVALID_PATH");
            IWETH(WETH).withdraw(amountOut);
            _sendETH(feeCollector, feeAmount);
            _sendETH(to, amountOut.sub(feeAmount));
        } else {
            IERC20(path[path.length-1]).safeTransfer(feeCollector, feeAmount);
            IERC20(path[path.length-1]).safeTransfer(to, amountOut.sub(feeAmount));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint swapAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) {

        uint amountOut = _swapExactTokensForTokensSupportingFeeOnTransferTokens(true, amountIn, swapAmountOutMin, path);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);
        emit LOG_AGG_SWAP(amountOut, feeAmount);

        IERC20(path[path.length-1]).safeTransfer(feeCollector, feeAmount);
        IERC20(path[path.length-1]).safeTransfer(to, amountOut.sub(feeAmount));
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokensCrossChain(
        uint amountIn, uint swapAmountOutMin, address[] calldata path,         // args for dex
        address poolAddress, address tokenTo, uint256 minDy, uint256 deadline, // args for swap
        uint64 toChainId, bytes memory toAddress, bytes memory callData        // args for wrapper
    ) external virtual payable ensure(deadline) returns (bool) {

        (uint swapperAmountIn, address tokenFrom) = _swapExactTokensForTokensSupportingFeeOnTransferTokensCrossChain(amountIn, swapAmountOutMin, path);

        IERC20(tokenFrom).safeApprove(O3Wrapper, swapperAmountIn);

        return IWrapper(O3Wrapper).swapAndBridgeOut{value: msg.value}(
            poolAddress, tokenFrom, tokenTo, swapperAmountIn, minDy, deadline,
            toChainId, toAddress, callData
        );
    }

    function _swapExactTokensForTokensSupportingFeeOnTransferTokensCrossChain(
        uint amountIn, uint swapAmountOutMin, address[] calldata path
    ) internal returns (uint256, address) {

        uint amountOut = _swapExactTokensForTokensSupportingFeeOnTransferTokens(true, amountIn, swapAmountOutMin, path);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);
        IERC20(path[path.length-1]).safeTransfer(feeCollector, feeAmount);
        emit LOG_AGG_SWAP(amountOut, feeAmount);

        return (amountOut.sub(feeAmount), path[path.length-1]);
    }

    function _swapExactTokensForTokensSupportingFeeOnTransferTokens(
        bool pull,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path
    ) internal virtual returns (uint) {

        if (pull) {
            IERC20(path[0]).safeTransferFrom(
                msg.sender, EthereumUniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
            );
        } else {
            IERC20(path[0]).safeTransfer(EthereumUniswapV2Library.pairFor(factory, path[0], path[1]), amountIn);
        }

        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= amountOutMin, 'O3Aggregator: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint swapAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual payable ensure(deadline) {

        uint amountOut = _swapExactETHForTokensSupportingFeeOnTransferTokens(swapAmountOutMin, path, 0);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);
        emit LOG_AGG_SWAP(amountOut, feeAmount);

        IERC20(path[path.length-1]).safeTransfer(feeCollector, feeAmount);
        IERC20(path[path.length - 1]).safeTransfer(to, amountOut.sub(feeAmount));
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokensCrossChain(
        uint swapAmountOutMin, address[] calldata path, uint fee,              // args for dex
        address poolAddress, address tokenTo, uint256 minDy, uint256 deadline, // args for swap
        uint64 toChainId, bytes memory toAddress, bytes memory callData        // args for wrapper
    ) external virtual payable ensure(deadline) returns (bool) {

        (uint swapperAmountIn, address tokenFrom) = _swapExactETHForTokensSupportingFeeOnTransferTokensCrossChain(swapAmountOutMin, path, fee);

        IERC20(tokenFrom).safeApprove(O3Wrapper, swapperAmountIn);

        return IWrapper(O3Wrapper).swapAndBridgeOut{value: fee}(
            poolAddress, tokenFrom, tokenTo, swapperAmountIn, minDy, deadline,
            toChainId, toAddress, callData
        );
    }

    function _swapExactETHForTokensSupportingFeeOnTransferTokensCrossChain(
        uint swapAmountOutMin, address[] calldata path, uint fee
    ) internal returns (uint, address) {

        uint amountOut = _swapExactETHForTokensSupportingFeeOnTransferTokens(swapAmountOutMin, path, fee);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);
        IERC20(path[path.length-1]).safeTransfer(feeCollector, feeAmount);
        emit LOG_AGG_SWAP(amountOut, feeAmount);

        return (amountOut.sub(feeAmount), path[path.length-1]);
    }

    function _swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint swapAmountOutMin,
        address[] calldata path,
        uint fee
    ) internal virtual returns (uint) {

        require(path[0] == WETH, 'O3Aggregator: INVALID_PATH');
        uint amountIn = msg.value.sub(fee);
        require(amountIn > 0, 'O3Aggregator: INSUFFICIENT_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(EthereumUniswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= swapAmountOutMin, 'O3Aggregator: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint swapAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) {

        uint amountOut = _swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, swapAmountOutMin, path);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);
        emit LOG_AGG_SWAP(amountOut, feeAmount);

        IWETH(WETH).withdraw(amountOut);

        _sendETH(feeCollector, feeAmount);
        _sendETH(to, amountOut.sub(feeAmount));
    }

    function _swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint swapAmountOutMin,
        address[] calldata path
    ) internal virtual returns (uint) {

        require(path[path.length - 1] == WETH, 'O3Aggregator: INVALID_PATH');
        IERC20(path[0]).safeTransferFrom(
            msg.sender, EthereumUniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(WETH).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= swapAmountOutMin, 'O3Aggregator: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    function _sendETH(address to, uint256 amount) internal {

        (bool success,) = to.call{value:amount}(new bytes(0));
        require(success, 'O3Aggregator: ETH_TRANSFER_FAILED');
    }

    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {

        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = EthereumUniswapV2Library.sortTokens(input, output);
            require(IUniswapV2Factory(factory).getPair(input, output) != address(0), "O3Aggregator: PAIR_NOT_EXIST");
            IUniswapV2Pair pair = IUniswapV2Pair(EthereumUniswapV2Library.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1,) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = EthereumUniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? EthereumUniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
}