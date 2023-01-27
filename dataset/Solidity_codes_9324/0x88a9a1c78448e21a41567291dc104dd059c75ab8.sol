

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




interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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

interface IRariFusePriceOracle {
    function price(address _token) external view returns (uint256 _price);
}



interface IRariFusePriceOracleAdapter {

    struct OracleMetadata {
        IRariFusePriceOracle oracle;
        uint8 decimals;
    }



    event OracleConfigured(
        address token,
        OracleMetadata metadata
    );



    error OracleNotExists(address token);



    function configure(
        address _token,
        address _rariFusePriceOracle
    ) external;



    function isConfigured(address _token) external view returns (bool);



    function price(address _token) external view returns (uint256 _price);

    function price(
        address _base,
        address _quote
    ) external view returns (uint256 _price);

}




contract RariFusePriceOracleAdapter is IRariFusePriceOracleAdapter, Ownable {

    mapping(address => OracleMetadata) public oracles;



    function configure(address _token, address _rariFusePriceOracle) external onlyOwner {
        oracles[_token] = OracleMetadata({
            oracle: IRariFusePriceOracle(_rariFusePriceOracle),
            decimals: IERC20Metadata(_token).decimals()
        });
        emit OracleConfigured(_token, oracles[_token]);
    }



    function isConfigured(address _token) external view returns (bool) {
        if (oracles[_token].decimals == 0) return false;
        return true;
    }



    function price(address _token) public view returns (uint256 _price) {
        if (oracles[_token].decimals == 0) revert OracleNotExists(_token);
        _price = oracles[_token].oracle.price(_token);
    }

    function price(address _base, address _quote) external view returns (uint256 _price) {
        uint256 basePriceInETH = price(_base);
        uint256 quotePriceInETH = price(_quote);
        uint256 priceInETH = (basePriceInETH * 1e18) / quotePriceInETH;
        _price = (priceInETH * (10**oracles[_quote].decimals)) / 1e18;
    }
}


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



interface IRiseTokenFactory {

    event TokenCreated(
        address token,
        address fCollateral,
        address fDebt,
        uint256 totalTokens
    );

    event FeeRecipientUpdated(address newRecipient);



    error TokenExists(address token);



    function setFeeRecipient(address _newRecipient) external;

    function create(
        address _fCollateral,
        address _fDebt,
        address _uniswapAdapter,
        address _oracleAdapter
    ) external returns (address _token);

}


interface IfERC20 {
    function mint(uint256 mintAmount) external returns (uint256);
    function redeem(uint256 redeemTokens) external returns (uint256);
    function redeemUnderlying(uint redeemAmount) external returns (uint256);
    function borrow(uint256 borrowAmount) external returns (uint256);
    function repayBorrow(uint256 repayAmount) external returns (uint256);
    function accrualBlockNumber() external returns (uint256);
    function borrowBalanceCurrent(address account) external returns (uint256);
    function comptroller() external returns (address);
    function underlying() external returns (address);
    function balanceOfUnderlying(address account) external returns (uint256);
    function totalBorrowsCurrent() external returns (uint256);
}





contract RiseTokenFactory is IRiseTokenFactory, Ownable {

    address[] public tokens;
    mapping(address => mapping(address => address)) public getToken;
    address public feeRecipient;



    constructor(address _feeRecipient) {
        feeRecipient = _feeRecipient;
    }



    function setFeeRecipient(address _newRecipient) external onlyOwner {
        feeRecipient = _newRecipient;
        emit FeeRecipientUpdated(_newRecipient);
    }

    function create(address _fCollateral, address _fDebt, address _uniswapAdapter, address _oracleAdapter) external onlyOwner returns (address _token) {
        address collateral = IfERC20(_fCollateral).underlying();
        address debt = IfERC20(_fDebt).underlying();
        if (getToken[collateral][debt] != address(0)) revert TokenExists(getToken[collateral][debt]);

        bytes memory creationCode = type(RiseToken).creationCode;
        string memory tokenName = string(abi.encodePacked(IERC20Metadata(collateral).symbol(), " 2x Long Risedle"));
        string memory tokenSymbol = string(abi.encodePacked(IERC20Metadata(collateral).symbol(), "RISE"));
        bytes memory constructorArgs = abi.encode(tokenName, tokenSymbol, address(this), _fCollateral, _fDebt, _uniswapAdapter, _oracleAdapter);
        bytes memory bytecode = abi.encodePacked(creationCode, constructorArgs);
        bytes32 salt = keccak256(abi.encodePacked(_fCollateral, _fDebt));
        assembly {
            _token := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        getToken[_fCollateral][_fDebt] = _token;
        getToken[_fDebt][_fCollateral] = _token; // populate mapping in the reverse direction
        tokens.push(_token);

        emit TokenCreated(_token, _fCollateral, _fDebt, tokens.length);
    }
}


interface IFuseComptroller {
    function getAccountLiquidity(address account) external returns (uint256 error, uint256 liquidity, uint256 shortfall);
    function enterMarkets(address[] calldata fTokens) external returns (uint256[] memory);
}



interface IRiseToken is IERC20 {


    enum FlashSwapType {
        Initialize,
        Buy,
        Sell
    }

    struct InitializeParams {
        uint256 borrowAmount;
        uint256 collateralAmount;
        uint256 shares;
        uint256 leverageRatio;
        uint256 nav;
        uint256 ethAmount;
        address initializer;
    }

    struct BuyParams {
        address buyer;
        address recipient;
        ERC20 tokenIn;
        uint256 collateralAmount;
        uint256 debtAmount;
        uint256 shares;
        uint256 fee;
        uint256 amountInMax;
        uint256 nav;
    }

    struct SellParams {
        address seller;
        address recipient;
        ERC20 tokenOut;
        uint256 collateralAmount;
        uint256 debtAmount;
        uint256 shares;
        uint256 fee;
        uint256 amountOutMin;
        uint256 nav;
    }



    event Initialized(InitializeParams params);

    event Buy(BuyParams params);

    event Sell(SellParams params);

    event ParamsUpdated(
        uint256 maxLeverageRatio,
        uint256 minLeverageRatio,
        uint256 step,
        uint256 discount,
        uint256 maxBuy
    );


    error NotUniswapAdapter();

    error InputAmountInvalid();

    error AlreadyInitialized();

    error NotInitialized();

    error SlippageTooHigh();

    error FailedToSendETH(address to, uint256 amount);

    error NoNeedToRebalance();

    error LiquidityIsNotEnough();

    error FuseError(uint256 code);



    function setParams(
        uint256 _minLeverageRatio,
        uint256 _maxLeverageRatio,
        uint256 _step,
        uint256 _discount,
        uint256 _maxBuy
    ) external;

    function initialize(InitializeParams memory _params) external payable;



    function collateralPerShare() external view returns (uint256 _cps);

    function debtPerShare() external view returns (uint256 _dps);

    function value(uint256 _shares) external view returns (uint256 _value);

    function value(
        uint256 _shares,
        address _quote
    ) external view returns (uint256 _value);

    function nav() external view returns (uint256 _nav);

    function leverageRatio() external view returns (uint256 _lr);



    function buy(
        uint256 _shares,
        address _recipient,
        address _tokenIn,
        uint256 _amountInMax
    ) external payable;

    function sell(
        uint256 _shares,
        address _recipient,
        address _tokenOut,
        uint256 _amountOutMin
    ) external;




    function swapExactCollateralForETH(
        uint256 _amountIn,
        uint256 _amountOutMin
    ) external returns (uint256 _amountOut);

    function swapExactETHForCollateral(
        uint256 _amountOutMin
    ) external payable returns (uint256 _amountOut);

}





contract RiseToken is IRiseToken, ERC20, Ownable {

    using SafeERC20 for ERC20;
    using SafeERC20 for IWETH9;


    IWETH9                     public weth;
    RiseTokenFactory           public factory;
    UniswapAdapter             public uniswapAdapter;
    RariFusePriceOracleAdapter public oracleAdapter;

    ERC20   public collateral;
    ERC20   public debt;
    IfERC20 public fCollateral;
    IfERC20 public fDebt;

    uint256 public totalCollateral;
    uint256 public totalDebt;
    uint256 public maxBuy = type(uint256).max;
    uint256 public fees = 0.001 ether;
    uint256 public minLeverageRatio = 1.7 ether;
    uint256 public maxLeverageRatio = 2.3 ether;
    uint256 public step = 0.2 ether;
    uint256 public discount = 0.006 ether; // 0.6%
    bool    public isInitialized;

    uint8 private cdecimals;
    uint8 private ddecimals;



    constructor(
        string memory _name,
        string memory _symbol,
        address _factory,
        address _fCollateral,
        address _fDebt,
        address _uniswapAdapter,
        address _oracleAdapter
    ) ERC20(_name, _symbol) {
        factory = RiseTokenFactory(_factory);
        uniswapAdapter = UniswapAdapter(_uniswapAdapter);
        oracleAdapter = RariFusePriceOracleAdapter(_oracleAdapter);
        fCollateral = IfERC20(_fCollateral);
        fDebt = IfERC20(_fDebt);
        collateral = ERC20(fCollateral.underlying());
        debt = ERC20(fDebt.underlying());
        weth = IWETH9(uniswapAdapter.weth());

        cdecimals = collateral.decimals();
        ddecimals = debt.decimals();

        transferOwnership(factory.owner());
    }



    function supplyThenBorrow(uint256 _collateralAmount, uint256 _borrowAmount) internal {
        collateral.safeIncreaseAllowance(address(fCollateral), _collateralAmount);
        uint256 fuseResponse;
        fuseResponse = fCollateral.mint(_collateralAmount);
        if (fuseResponse != 0) revert FuseError(fuseResponse);

        fuseResponse = fDebt.borrow(_borrowAmount);
        if (fuseResponse != 0) revert FuseError(fuseResponse);

        totalCollateral = fCollateral.balanceOfUnderlying(address(this));
        totalDebt = fDebt.borrowBalanceCurrent(address(this));
    }

    function repayThenRedeem(uint256 _repayAmount, uint256 _collateralAmount) internal {
        debt.safeIncreaseAllowance(address(fDebt), _repayAmount);
        uint256 repayResponse = fDebt.repayBorrow(_repayAmount);
        if (repayResponse != 0) revert FuseError(repayResponse);

        uint256 redeemResponse = fCollateral.redeemUnderlying(_collateralAmount);
        if (redeemResponse != 0) revert FuseError(redeemResponse);

        totalCollateral = fCollateral.balanceOfUnderlying(address(this));
        totalDebt = fDebt.borrowBalanceCurrent(address(this));
    }

    function onInitialize(uint256 _wethAmount, uint256 _collateralAmount, bytes memory _data) internal {
        isInitialized = true;
        (InitializeParams memory params) = abi.decode(_data, (InitializeParams));

        address[] memory markets = new address[](2);
        markets[0] = address(fCollateral);
        markets[1] = address(fDebt);
        uint256[] memory marketStatus = IFuseComptroller(fCollateral.comptroller()).enterMarkets(markets);
        if (marketStatus[0] != 0 && marketStatus[1] != 0) revert FuseError(marketStatus[0]);

        supplyThenBorrow(_collateralAmount, params.borrowAmount);

        debt.safeIncreaseAllowance(address(uniswapAdapter), params.borrowAmount);
        uint256 wethAmountFromBorrow = uniswapAdapter.swapExactTokensForWETH(address(debt)  , params.borrowAmount, 0);

        uint256 owedWETH = _wethAmount - wethAmountFromBorrow;
        if (owedWETH > params.ethAmount) revert SlippageTooHigh();

        uint256 excessETH = params.ethAmount - owedWETH;
        (bool sent, ) = params.initializer.call{value: excessETH}("");
        if (!sent) revert FailedToSendETH(params.initializer, excessETH);

        weth.deposit{ value: owedWETH }(); // Wrap the ETH to WETH
        weth.safeTransfer(address(uniswapAdapter), _wethAmount);

        _mint(params.initializer, params.shares);

        emit Initialized(params);
    }

    function onBuy(uint256 _wethAmount, uint256 _collateralAmount, bytes memory _data) internal {
        (BuyParams memory params) = abi.decode(_data, (BuyParams));

        supplyThenBorrow(_collateralAmount, params.debtAmount);

        debt.safeIncreaseAllowance(address(uniswapAdapter), params.debtAmount);
        uint256 wethAmountFromBorrow = uniswapAdapter.swapExactTokensForWETH(address(debt), params.debtAmount, 0);

        uint256 owedWETH = _wethAmount - wethAmountFromBorrow;

        if (address(params.tokenIn) == address(0)) {
            if (owedWETH > params.amountInMax) revert SlippageTooHigh();
            uint256 excessETH = params.amountInMax - owedWETH;
            (bool sent, ) = params.buyer.call{value: excessETH}("");
            if (!sent) revert FailedToSendETH(params.buyer, excessETH);
            weth.deposit{ value: owedWETH }();
        } else {
            params.tokenIn.safeTransferFrom(params.buyer, address(this), params.amountInMax);
            params.tokenIn.safeIncreaseAllowance(address(uniswapAdapter), params.amountInMax);
            uint256 amountIn = uniswapAdapter.swapTokensForExactWETH(address(params.tokenIn), owedWETH, params.amountInMax);
            if (amountIn < params.amountInMax) {
                params.tokenIn.safeTransfer(params.buyer, params.amountInMax - amountIn);
            }
        }

        weth.safeTransfer(address(uniswapAdapter), _wethAmount);

        _mint(params.recipient, params.shares);
        _mint(factory.feeRecipient(), params.fee);

        emit Buy(params);
    }

    uint256 private wethLeftFromFlashSwap;

    function onSell(uint256 _wethAmount, uint256 _debtAmount, bytes memory _data) internal {
        (SellParams memory params) = abi.decode(_data, (SellParams));

        repayThenRedeem(_debtAmount, params.collateralAmount);

        if (address(params.tokenOut) == address(collateral)) {
            collateral.safeIncreaseAllowance(address(uniswapAdapter), params.collateralAmount);
            uint256 collateralToBuyWETH = uniswapAdapter.swapTokensForExactWETH(address(collateral), _wethAmount, params.collateralAmount);
            uint256 collateralLeft = params.collateralAmount - collateralToBuyWETH;
            if (collateralLeft < params.amountOutMin) revert SlippageTooHigh();
            collateral.safeTransfer(params.recipient, collateralLeft);
        } else {
            collateral.safeIncreaseAllowance(address(uniswapAdapter), params.collateralAmount);
            uint256 wethAmountFromCollateral = uniswapAdapter.swapExactTokensForWETH(address(collateral), params.collateralAmount, 0);
            uint256 wethLeft = wethAmountFromCollateral - _wethAmount;

            if (address(params.tokenOut) == address(0)) {
                if (wethLeft < params.amountOutMin) revert SlippageTooHigh();
                weth.safeIncreaseAllowance(address(weth), wethLeft);
                weth.withdraw(wethLeft);
                (bool sent, ) = params.recipient.call{value: wethLeft}("");
                if (!sent) revert FailedToSendETH(params.recipient, wethLeft);
            }

            if (address(params.tokenOut) == address(debt)) {
                wethLeftFromFlashSwap = wethLeft;
            }

            if (address(params.tokenOut) != address(0) && (address(params.tokenOut) != address(debt))) {
                weth.safeIncreaseAllowance(address(uniswapAdapter), wethLeft);
                uint256 amountOut = uniswapAdapter.swapExactWETHForTokens(address(params.tokenOut), wethLeft, params.amountOutMin);
                params.tokenOut.safeTransfer(params.recipient, amountOut);
            }
        }

        weth.safeTransfer(address(uniswapAdapter), _wethAmount);

        ERC20(address(this)).safeTransferFrom(params.seller, factory.feeRecipient(), params.fee);
        _burn(params.seller, params.shares - params.fee);
        emit Sell(params);
    }



    function setParams(uint256 _minLeverageRatio, uint256 _maxLeverageRatio, uint256 _step, uint256 _discount, uint256 _newMaxBuy) external onlyOwner {
        minLeverageRatio = _minLeverageRatio;
        maxLeverageRatio = _maxLeverageRatio;
        step = _step;
        discount = _discount;
        maxBuy = _newMaxBuy;
        emit ParamsUpdated(minLeverageRatio, maxLeverageRatio, step, discount, maxBuy);
    }

    function initialize(InitializeParams memory _params) external payable onlyOwner {
        if (isInitialized == true) revert AlreadyInitialized();
        if (msg.value == 0) revert InputAmountInvalid();
        _params.ethAmount = msg.value;
        bytes memory data = abi.encode(FlashSwapType.Initialize, abi.encode(_params));
        uniswapAdapter.flashSwapWETHForExactTokens(address(collateral), _params.collateralAmount, data);
    }



    function onFlashSwapWETHForExactTokens(uint256 _wethAmount, uint256 _amountOut, bytes calldata _data) external {
        if (msg.sender != address(uniswapAdapter)) revert NotUniswapAdapter();

        (FlashSwapType flashSwapType, bytes memory data) = abi.decode(_data, (FlashSwapType,bytes));
        if (flashSwapType == FlashSwapType.Initialize) {
            onInitialize(_wethAmount, _amountOut, data);
            return;
        }

        if (flashSwapType == FlashSwapType.Buy) {
            onBuy(_wethAmount, _amountOut, data);
            return;
        }

        if (flashSwapType == FlashSwapType.Sell) {
            onSell(_wethAmount, _amountOut, data);
            return;
        }
    }


    function decimals() public view virtual override returns (uint8) {
        return cdecimals;
    }

    function collateralPerShare() public view returns (uint256 _cps) {
        if (!isInitialized) return 0;
        _cps = (totalCollateral * (10**cdecimals)) / totalSupply();
    }

    function debtPerShare() public view returns (uint256 _dps) {
        if (!isInitialized) return 0;
        _dps = (totalDebt * (10**cdecimals)) / totalSupply();
    }

    function value(uint256 _shares) public view returns (uint256 _value) {
        if (!isInitialized) return 0;
        if (_shares == 0) return 0;
        uint256 collateralAmount = (_shares * collateralPerShare()) / (10**cdecimals);
        uint256 debtAmount = (_shares * debtPerShare()) / (10**cdecimals);

        uint256 cPrice = oracleAdapter.price(address(collateral));
        uint256 dPrice = oracleAdapter.price(address(debt));

        uint256 collateralValue = (collateralAmount * cPrice) / (10**cdecimals);
        uint256 debtValue = (debtAmount * dPrice) / (10**ddecimals);

        _value = collateralValue - debtValue;
    }

    function value(uint256 _shares, address _quote) public view returns (uint256 _value) {
        uint256 valueInETH = value(_shares);
        if (valueInETH == 0) return 0;
        uint256 quoteDecimals = ERC20(_quote).decimals();
        uint256 quotePrice = oracleAdapter.price(_quote);
        uint256 amountInETH = (valueInETH * 1e18) / quotePrice;

        _value = (amountInETH * (10**quoteDecimals)) / 1e18;
    }

    function nav() public view returns (uint256 _nav) {
        if (!isInitialized) return 0;
        _nav = value(10**cdecimals);
    }

    function leverageRatio() public view returns (uint256 _lr) {
        if (!isInitialized) return 0;
        uint256 collateralPrice = oracleAdapter.price(address(collateral));
        uint256 collateralValue = (collateralPerShare() * collateralPrice) / (10**cdecimals);
        _lr = (collateralValue * 1e18) / nav();
    }



    function buy(uint256 _shares, address _recipient, address _tokenIn, uint256 _amountInMax) external payable {
        if (!isInitialized) revert NotInitialized();
        if (_shares > maxBuy) revert InputAmountInvalid();

        uint256 fee = ((fees * _shares) / 1e18);
        uint256 newShares = _shares + fee;
        BuyParams memory params = BuyParams({
            buyer: msg.sender,
            recipient: _recipient,
            tokenIn: ERC20(_tokenIn),
            amountInMax: _tokenIn == address(0) ? msg.value : _amountInMax,
            shares: _shares,
            collateralAmount: (newShares * collateralPerShare()) / (10**cdecimals),
            debtAmount: (newShares * debtPerShare()) / (10**cdecimals),
            fee: fee,
            nav: nav()
        });

        bytes memory data = abi.encode(FlashSwapType.Buy, abi.encode(params));
        uniswapAdapter.flashSwapWETHForExactTokens(address(collateral), params.collateralAmount, data);
    }

    function sell(uint256 _shares, address _recipient, address _tokenOut, uint256 _amountOutMin) external {
        if (!isInitialized) revert NotInitialized();

        uint256 fee = ((fees * _shares) / 1e18);
        uint256 newShares = _shares - fee;
        SellParams memory params = SellParams({
            seller: msg.sender,
            recipient: _recipient,
            tokenOut: ERC20(_tokenOut),
            amountOutMin: _amountOutMin,
            shares: _shares,
            collateralAmount: (newShares * collateralPerShare()) / (10**cdecimals),
            debtAmount: (newShares * debtPerShare()) / (10**cdecimals),
            fee: fee,
            nav: nav()
        });

        bytes memory data = abi.encode(FlashSwapType.Sell, abi.encode(params));
        uniswapAdapter.flashSwapWETHForExactTokens(address(debt), params.debtAmount, data);

        if (address(params.tokenOut) == address(debt)) {
            weth.safeIncreaseAllowance(address(uniswapAdapter), wethLeftFromFlashSwap);
            uint256 amountOut = uniswapAdapter.swapExactWETHForTokens(address(params.tokenOut), wethLeftFromFlashSwap, params.amountOutMin);
            params.tokenOut.safeTransfer(params.recipient, amountOut);
            wethLeftFromFlashSwap = 0;
        }
    }



    function swapExactCollateralForETH(uint256 _amountIn, uint256 _amountOutMin) external returns (uint256 _amountOut) {
        if (leverageRatio() > minLeverageRatio) revert NoNeedToRebalance();
        if (_amountIn == 0) return 0;

        uint256 price = oracleAdapter.price(address(collateral));
        price += (discount * price) / 1e18;
        _amountOut = (_amountIn * price) / (1e18);
        if (_amountOut < _amountOutMin) revert SlippageTooHigh();


        collateral.safeTransferFrom(msg.sender, address(this), _amountIn);

        uint256 borrowAmount = ((step * value((10**cdecimals), address(debt)) / 1e18) * totalSupply()) / (10**cdecimals);
        supplyThenBorrow(_amountIn, borrowAmount);

        debt.safeIncreaseAllowance(address(uniswapAdapter), borrowAmount);
        uint256 amountIn = uniswapAdapter.swapTokensForExactWETH(address(debt), _amountOut, borrowAmount);

        if (amountIn < borrowAmount) {
            uint256 repayAmount = borrowAmount - amountIn;
            debt.safeIncreaseAllowance(address(fDebt), repayAmount);
            uint256 repayResponse = fDebt.repayBorrow(repayAmount);
            if (repayResponse != 0) revert FuseError(repayResponse);
            totalDebt = fDebt.borrowBalanceCurrent(address(this));
        }

        weth.safeIncreaseAllowance(address(weth), _amountOut);
        weth.withdraw(_amountOut);

        (bool sent, ) = msg.sender.call{value: _amountOut}("");
        if (!sent) revert FailedToSendETH(msg.sender, _amountOut);
    }

    function swapExactETHForCollateral(uint256 _amountOutMin) external payable returns (uint256 _amountOut) {
        if (leverageRatio() < maxLeverageRatio) revert NoNeedToRebalance();
        if (msg.value == 0) return 0;

        uint256 price = oracleAdapter.price(address(collateral));
        price -= (discount * price) / 1e18;
        _amountOut = (msg.value * (10**cdecimals)) / price;
        if (_amountOut < _amountOutMin) revert SlippageTooHigh();

        weth.deposit{value: msg.value}();

        uint256 repayAmount = ((step * value((10**cdecimals), address(debt)) / 1e18) * totalSupply()) / (10**cdecimals);
        weth.safeIncreaseAllowance(address(uniswapAdapter), msg.value);
        uint256 repayAmountFromETH = uniswapAdapter.swapExactWETHForTokens(address(debt), msg.value, 0);
        if (repayAmountFromETH > repayAmount) revert LiquidityIsNotEnough();

        repayThenRedeem(repayAmountFromETH, _amountOut);

        collateral.safeTransfer(msg.sender, _amountOut);
    }

    receive() external payable {}
}