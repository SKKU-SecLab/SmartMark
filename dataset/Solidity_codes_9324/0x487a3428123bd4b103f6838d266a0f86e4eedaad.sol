

pragma solidity =0.8.11 >=0.8.0 <0.9.0 >=0.8.1 <0.9.0;
pragma experimental ABIEncoderV2;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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
}



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
}



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
}




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
}

/* pragma experimental ABIEncoderV2; */

interface IUniswapAdapterCaller {

    function onFlashSwapWETHForExactTokens(uint256 _wethAmount, uint256 _amountOut, bytes calldata _data) external;

}


interface IUniswapV2Pair {

    function token1() external view returns (address);

    function token0() external view returns (address);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

}


interface IUniswapV3Pool {

    function swap(address _recipient, bool _zeroForOne, int256 _amountSpecified, uint160 _sqrtPriceLimitX96, bytes memory _data) external returns (int256 amount0, int256 amount1);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function fee() external view returns (uint24);

}




interface IUniswapAdapter {


    enum UniswapVersion {
        UniswapV2,
        UniswapV3
    }

    struct LiquidityData {
        UniswapVersion version;
        IUniswapV2Pair pair;
        IUniswapV3Pool pool;
        address router;
    }

    struct FlashSwapWETHForExactTokensParams {
        IERC20 tokenOut;
        IUniswapAdapterCaller caller;
        LiquidityData liquidityData;
        uint256 amountOut;
        uint256 wethAmount;
    }

    enum FlashSwapType {
        FlashSwapWETHForExactTokens
    }



    event TokenConfigured(LiquidityData liquidityData);

    event FlashSwapped(FlashSwapWETHForExactTokensParams params);



    error InvalidUniswapVersion(uint8 version);

    error InvalidAmount(uint256 amount);

    error TokenNotConfigured(address token);

    error CallerNotAuthorized();

    error CallerNotRepay();

    error FlashSwapReceivedAmountInvalid(uint256 expected, uint256 got);



    function configure(
        address _token,
        UniswapVersion _version,
        address _pairOrPool,
        address _router
    ) external;




    function isConfigured(address _token) external view returns (bool);



    function flashSwapWETHForExactTokens(
        address _tokenOut,
        uint256 _amountOut,
        bytes memory _data
    ) external;


    function swapExactTokensForWETH(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) external returns (uint256 _amountOut);


    function swapTokensForExactWETH(
        address _tokenIn,
        uint256 _wethAmount,
        uint256 _amountInMax
    ) external returns (uint256 _amountIn);


    function swapExactWETHForTokens(
        address _tokenOut,
        uint256 _wethAmount,
        uint256 _amountOutMin
    ) external returns (uint256 _amountOut);


}


interface IUniswapV2Router02 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

}



interface IUniswapV3SwapRouter {

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
    function exactInputSingle(ExactInputSingleParams memory params) external returns (uint256 amountOut);

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
    function exactOutputSingle(ExactOutputSingleParams memory params) external returns (uint256 amountIn);

}



interface IWETH9 is IERC20 {

    function deposit() external payable;


    function withdraw(uint256) external;

}





contract UniswapAdapter is IUniswapAdapter, Ownable {


    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH9;


    IWETH9 public weth;

    mapping(address => LiquidityData) public liquidities;

    mapping(address => bool) private isValidCallbackCaller;



    constructor(address _weth) {
        weth = IWETH9(_weth);
    }



    function configure(address _token, UniswapVersion _version, address _pairOrPool, address _router) external onlyOwner {

        isValidCallbackCaller[_pairOrPool] = true;
        liquidities[_token] = LiquidityData({
            version: _version,
            pool: IUniswapV3Pool(_pairOrPool),
            pair: IUniswapV2Pair(_pairOrPool),
            router: _router
        });
        emit TokenConfigured(liquidities[_token]);
    }



    function onFlashSwapWETHForExactTokens(FlashSwapWETHForExactTokensParams memory _params, bytes memory _data) internal {

        _params.tokenOut.safeTransfer(address(_params.caller), _params.amountOut);

        uint256 prevBalance = weth.balanceOf(address(this));
        _params.caller.onFlashSwapWETHForExactTokens(_params.wethAmount, _params.amountOut, _data);
        uint256 balance = weth.balanceOf(address(this));

        if (balance < prevBalance + _params.wethAmount) revert CallerNotRepay();

        if (_params.liquidityData.version == UniswapVersion.UniswapV2) {
            weth.safeTransfer(address(_params.liquidityData.pair), _params.wethAmount);
        } else {
            weth.safeTransfer(address(_params.liquidityData.pool), _params.wethAmount);
        }

        emit FlashSwapped(_params);
    }



    function uniswapV2Call(address _sender, uint256 _amount0, uint256 _amount1, bytes memory _data) external {


        if (!isValidCallbackCaller[msg.sender]) revert CallerNotAuthorized();
        if (_sender != address(this)) revert CallerNotAuthorized();


        (FlashSwapType flashSwapType, bytes memory data) = abi.decode(_data, (FlashSwapType, bytes));

        if (flashSwapType == FlashSwapType.FlashSwapWETHForExactTokens) {
            (FlashSwapWETHForExactTokensParams memory params, bytes memory callData) = abi.decode(data, (FlashSwapWETHForExactTokensParams,bytes));
            uint256 amountOut = _amount0 == 0 ? _amount1 : _amount0;
            if (params.amountOut != amountOut) revert FlashSwapReceivedAmountInvalid(params.amountOut, amountOut);

            address[] memory path = new address[](2);
            path[0] = address(weth);
            path[1] = address(params.tokenOut);
            params.wethAmount = IUniswapV2Router02(params.liquidityData.router).getAmountsIn(params.amountOut, path)[0];

            onFlashSwapWETHForExactTokens(params, callData);
            return;
        }
    }

    function uniswapV3SwapCallback(int256 _amount0Delta, int256 _amount1Delta, bytes memory _data) external {


        if (!isValidCallbackCaller[msg.sender]) revert CallerNotAuthorized();


        (FlashSwapType flashSwapType, bytes memory data) = abi.decode(_data, (FlashSwapType, bytes));

        if (flashSwapType == FlashSwapType.FlashSwapWETHForExactTokens) {
            (FlashSwapWETHForExactTokensParams memory params, bytes memory callData) = abi.decode(data, (FlashSwapWETHForExactTokensParams,bytes));

            uint256 amountOut = _amount0Delta < 0 ?  uint256(-1 * _amount0Delta) : uint256(-1 * _amount1Delta);
            params.wethAmount = _amount0Delta > 0 ? uint256(_amount0Delta) : uint256(_amount1Delta);

            if (params.amountOut != amountOut) revert FlashSwapReceivedAmountInvalid(params.amountOut, amountOut);

            onFlashSwapWETHForExactTokens(params, callData);
            return;
        }
    }



    function isConfigured(address _token) public view returns (bool) {

        if (liquidities[_token].router == address(0)) return false;
        return true;
    }


    function flashSwapWETHForExactTokens(address _tokenOut, uint256 _amountOut, bytes memory _data) external {

        if (_amountOut == 0) revert InvalidAmount(0);
        if (!isConfigured(_tokenOut)) revert TokenNotConfigured(_tokenOut);

        LiquidityData memory metadata = liquidities[_tokenOut];


        FlashSwapWETHForExactTokensParams memory params = FlashSwapWETHForExactTokensParams({
            tokenOut: IERC20(_tokenOut),
            amountOut: _amountOut,
            caller: IUniswapAdapterCaller(msg.sender),
            liquidityData: metadata,
            wethAmount: 0 // Initialize as zero; It will be updated in the callback
        });
        bytes memory data = abi.encode(FlashSwapType.FlashSwapWETHForExactTokens, abi.encode(params, _data));

        if (metadata.version == UniswapVersion.UniswapV2) {
            uint256 amount0Out = _tokenOut == metadata.pair.token0() ? _amountOut : 0;
            uint256 amount1Out = _tokenOut == metadata.pair.token1() ? _amountOut : 0;

            metadata.pair.swap(amount0Out, amount1Out, address(this), data);
            return;
        }

        if (metadata.version == UniswapVersion.UniswapV3) {
            bool zeroForOne = _tokenOut == metadata.pool.token1() ? true : false;

            int256 amountSpecified = -1 * int256(_amountOut);
            uint160 sqrtPriceLimitX96 = (zeroForOne ? 4295128740 : 1461446703485210103287273052203988822378723970341);

            metadata.pool.swap(address(this), zeroForOne, amountSpecified, sqrtPriceLimitX96, data);
            return;
        }
    }

    function swapExactTokensForWETH(address _tokenIn, uint256 _amountIn, uint256 _amountOutMin) external returns (uint256 _amountOut) {

        if (!isConfigured(_tokenIn)) revert TokenNotConfigured(_tokenIn);

        LiquidityData memory metadata = liquidities[_tokenIn];
        IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).safeIncreaseAllowance(metadata.router, _amountIn);

        if (metadata.version == UniswapVersion.UniswapV2) {
            address[] memory path = new address[](2);
            path[0] = _tokenIn;
            path[1] = address(weth);
            _amountOut = IUniswapV2Router02(metadata.router).swapExactTokensForTokens(_amountIn, _amountOutMin, path, msg.sender, block.timestamp)[1];
        }

        if (metadata.version == UniswapVersion.UniswapV3) {
            IUniswapV3SwapRouter.ExactInputSingleParams memory params = IUniswapV3SwapRouter.ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: address(weth),
                fee: metadata.pool.fee(),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: _amountOutMin,
                sqrtPriceLimitX96: 0
            });
            _amountOut = IUniswapV3SwapRouter(metadata.router).exactInputSingle(params);
        }

        return _amountOut;
    }

    function swapTokensForExactWETH(address _tokenIn, uint256 _wethAmount, uint256 _amountInMax) external returns (uint256 _amountIn) {

        if (!isConfigured(_tokenIn)) revert TokenNotConfigured(_tokenIn);

        LiquidityData memory metadata = liquidities[_tokenIn];
        IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountInMax);
        IERC20(_tokenIn).safeIncreaseAllowance(metadata.router, _amountInMax);

        if (metadata.version == UniswapVersion.UniswapV2) {
            address[] memory path = new address[](2);
            path[0] = _tokenIn;
            path[1] = address(weth);
            _amountIn = IUniswapV2Router02(metadata.router).swapTokensForExactTokens(_wethAmount, _amountInMax, path, msg.sender, block.timestamp)[1];
        }

        if (metadata.version == UniswapVersion.UniswapV3) {
            IUniswapV3SwapRouter.ExactOutputSingleParams memory params = IUniswapV3SwapRouter.ExactOutputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: address(weth),
                fee: metadata.pool.fee(),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: _wethAmount,
                amountInMaximum: _amountInMax,
                sqrtPriceLimitX96: 0
            });
            _amountIn = IUniswapV3SwapRouter(metadata.router).exactOutputSingle(params);
        }

        if (_amountInMax > _amountIn) {
            IERC20(_tokenIn).safeTransfer(msg.sender, _amountInMax - _amountIn);
        }
        return _amountIn;
    }

    function swapExactWETHForTokens(address _tokenOut, uint256 _wethAmount, uint256 _amountOutMin) external returns (uint256 _amountOut) {

        if (!isConfigured(_tokenOut)) revert TokenNotConfigured(_tokenOut);

        LiquidityData memory metadata = liquidities[_tokenOut];
        IERC20(address(weth)).safeTransferFrom(msg.sender, address(this), _wethAmount);
        weth.safeIncreaseAllowance(metadata.router, _wethAmount);

        if (metadata.version == UniswapVersion.UniswapV2) {
            address[] memory path = new address[](2);
            path[0] = address(weth);
            path[1] = _tokenOut;
            _amountOut = IUniswapV2Router02(metadata.router).swapExactTokensForTokens(_wethAmount, _amountOutMin, path, msg.sender, block.timestamp)[1];
        }

        if (metadata.version == UniswapVersion.UniswapV3) {
            IUniswapV3SwapRouter.ExactInputSingleParams memory params = IUniswapV3SwapRouter.ExactInputSingleParams({
                tokenIn: address(weth),
                tokenOut: _tokenOut,
                fee: metadata.pool.fee(),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: _wethAmount,
                amountOutMinimum: _amountOutMin,
                sqrtPriceLimitX96: 0
            });
            _amountOut = IUniswapV3SwapRouter(metadata.router).exactInputSingle(params);
        }

        return _amountOut;
    }
}