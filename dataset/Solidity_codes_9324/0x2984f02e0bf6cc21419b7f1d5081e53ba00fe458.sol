pragma solidity 0.8.1;

interface IRecipe {

    function bake(
        address _inputToken,
        address _outputToken,
        uint256 _maxInput,
        bytes memory _data
    ) external returns (uint256 inputAmountUsed, uint256 outputAmount);

}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IUniRouter is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}//Unlicense
pragma solidity 0.8.1;
pragma experimental ABIEncoderV2;

interface ILendingRegistry {

    function wrappedToProtocol(address _wrapped) external view returns(bytes32);

    function wrappedToUnderlying(address _wrapped) external view returns(address);

    function underlyingToProtocolWrapped(address _underlying, bytes32 protocol) external view returns (address);

    function protocolToLogic(bytes32 _protocol) external view returns (address);


    function setWrappedToProtocol(address _wrapped, bytes32 _protocol) external;


    function setWrappedToUnderlying(address _wrapped, address _underlying) external;


    function setProtocolToLogic(bytes32 _protocol, address _logic) external;

    function setUnderlyingToProtocolWrapped(address _underlying, bytes32 _protocol, address _wrapped) external;


    function getLendTXData(address _underlying, uint256 _amount, bytes32 _protocol) external view returns(address[] memory targets, bytes[] memory data);


    function getUnlendTXData(address _wrapped, uint256 _amount) external view returns(address[] memory targets, bytes[] memory data);

}//Unlicense
pragma solidity 0.8.1;

interface ILendingLogic {

    function lend(address _underlying, uint256 _amount) external view returns(address[] memory targets, bytes[] memory data);

    
    function unlend(address _wrapped, uint256 _amount) external view returns(address[] memory targets, bytes[] memory data);


    function exchangeRate(address _wrapped) external returns(uint256);


    function exchangeRateView(address _wrapped) external view returns(uint256);

}//Unlicense
pragma solidity 0.8.1;
interface IPieRegistry {

    function inRegistry(address _pool) external view returns(bool);

    function entries(uint256 _index) external view returns(address);

    function addSmartPool(address _smartPool) external;

    function removeSmartPool(uint256 _index) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//Unlicense
pragma solidity 0.8.1;


interface IPie is IERC20 {

    function joinPool(uint256 _amount) external;

    function exitPool(uint256 _amount) external;

    function calcTokensForAmount(uint256 _amount) external view  returns(address[] memory tokens, uint256[] memory amounts);

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

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
}//Unlicense
pragma solidity 0.8.1;



contract UniPieRecipe is IRecipe, Ownable {

    using SafeERC20 for IERC20;

    IERC20 immutable WETH;
    IUniRouter immutable uniRouter;
    IUniRouter immutable sushiRouter;
    ILendingRegistry immutable lendingRegistry;
    IPieRegistry immutable pieRegistry;

    event HopUpdated(address indexed _token, address indexed _hop);

    mapping(address => CustomHop) public customHops;

    struct CustomHop {
        address hop;
    }

    enum DexChoice {Uni, Sushi}

    constructor(
        address _weth,
        address _uniRouter,
        address _sushiRouter,
        address _lendingRegistry,
        address _pieRegistry
    ) { 
        require(_weth != address(0), "WETH_ZERO");
        require(_uniRouter != address(0), "UNI_ROUTER_ZERO");
        require(_sushiRouter != address(0), "SUSHI_ROUTER_ZERO");
        require(_lendingRegistry != address(0), "LENDING_MANAGER_ZERO");
        require(_pieRegistry != address(0), "PIE_REGISTRY_ZERO");

        WETH = IERC20(_weth);
        uniRouter = IUniRouter(_uniRouter);
        sushiRouter = IUniRouter(_sushiRouter);
        lendingRegistry = ILendingRegistry(_lendingRegistry);
        pieRegistry = IPieRegistry(_pieRegistry);
    }

    function bake(
        address _inputToken,
        address _outputToken,
        uint256 _maxInput,
        bytes memory _data
    ) external override returns(uint256 inputAmountUsed, uint256 outputAmount) {

        IERC20 inputToken = IERC20(_inputToken);
        IERC20 outputToken = IERC20(_outputToken);

        inputToken.safeTransferFrom(_msgSender(), address(this), _maxInput);

        (uint256 mintAmount) = abi.decode(_data, (uint256));

        outputAmount = _bake(_inputToken, _outputToken, _maxInput, mintAmount);

        uint256 remainingInputBalance = inputToken.balanceOf(address(this));
        if(remainingInputBalance > 0) {
            inputToken.transfer(_msgSender(), remainingInputBalance);
        }

        outputToken.safeTransfer(_msgSender(), outputAmount);  

        return(inputAmountUsed, outputAmount);
    }

    function _bake(address _inputToken, address _outputToken, uint256 _maxInput, uint256 _mintAmount) internal returns(uint256 outputAmount) {

        swap(_inputToken, _outputToken, _mintAmount);

        outputAmount = IERC20(_outputToken).balanceOf(address(this));

        return(outputAmount);
    }

    function swap(address _inputToken, address _outputToken, uint256 _outputAmount) internal {


        if(_inputToken == _outputToken) {
            return;
        }

        if(_inputToken != address(WETH)) {
            uint256 wethAmount = getPrice(address(WETH), _outputToken, _outputAmount);
            swapUniOrSushi(_inputToken, address(WETH), wethAmount);
            swap(address(WETH), _outputToken, _outputAmount);
            return;
        }

        if(pieRegistry.inRegistry(_outputToken)) {
            swapPie(_outputToken, _outputAmount);
            return;
        }

        address underlying = lendingRegistry.wrappedToUnderlying(_outputToken);
        if(underlying != address(0)) {
            ILendingLogic lendingLogic = getLendingLogicFromWrapped(_outputToken);
            uint256 exchangeRate = lendingLogic.exchangeRate(_outputToken); // wrapped to underlying
            uint256 underlyingAmount = _outputAmount * exchangeRate / (10**18) + 1;

            swap(_inputToken, underlying, underlyingAmount);
            (address[] memory targets, bytes[] memory data) = lendingLogic.lend(underlying, underlyingAmount);

            for(uint256 i = 0; i < targets.length; i ++) {
                (bool success, ) = targets[i].call{ value: 0 }(data[i]);
                require(success, "CALL_FAILED");
            }

            return;
        }

        swapUniOrSushi(_inputToken, _outputToken, _outputAmount);
    }

    function swapPie(address _pie, uint256 _outputAmount) internal {

        IPie pie = IPie(_pie);
        (address[] memory tokens, uint256[] memory amounts) = pie.calcTokensForAmount(_outputAmount);

        for(uint256 i = 0; i < tokens.length; i ++) {
            swap(address(WETH), tokens[i], amounts[i]);
            IERC20 token = IERC20(tokens[i]);
            token.approve(_pie, 0);
            token.approve(_pie, amounts[i]);
        }

        pie.joinPool(_outputAmount);
    }

    function swapUniOrSushi(address _inputToken, address _outputToken, uint256 _outputAmount) internal {

        (uint256 inputAmount, DexChoice dex) = getBestPriceSushiUni(_inputToken, _outputToken, _outputAmount);

        address[] memory route = getRoute(_inputToken, _outputToken);

        IERC20 _inputToken = IERC20(_inputToken);

        CustomHop memory customHop = customHops[_outputToken];

        if(address(_inputToken) == _outputToken) {
            return;
        }

        if(customHop.hop != address(0)) {
            (uint256 hopAmount,) = getBestPriceSushiUni(customHop.hop, _outputToken, _outputAmount);

            swapUniOrSushi(address(_inputToken), customHop.hop, hopAmount);
            swapUniOrSushi(customHop.hop, _outputToken, _outputAmount);

            return;
        }

        if(dex == DexChoice.Sushi) {
            _inputToken.approve(address(sushiRouter), 0);
            _inputToken.approve(address(sushiRouter), type(uint256).max);
            sushiRouter.swapTokensForExactTokens(_outputAmount, type(uint256).max, route, address(this), block.timestamp + 1);
        } else {
            _inputToken.approve(address(uniRouter), 0);
            _inputToken.approve(address(uniRouter), type(uint256).max);
            uniRouter.swapTokensForExactTokens(_outputAmount, type(uint256).max, route, address(this), block.timestamp + 1);
        }

    }

    function setCustomHop(address _token, address _hop) external onlyOwner {

        customHops[_token] = CustomHop({
            hop: _hop
        });
    }

    function saveToken(address _token, address _to, uint256 _amount) external onlyOwner {

        IERC20(_token).transfer(_to, _amount);
    }
  
    function saveEth(address payable _to, uint256 _amount) external onlyOwner {

        _to.call{value: _amount}("");
    }

    function getPrice(address _inputToken, address _outputToken, uint256 _outputAmount) public returns(uint256)  {

        if(_inputToken == _outputToken) {
            return _outputAmount;
        }


        address underlying = lendingRegistry.wrappedToUnderlying(_outputToken);
        if(underlying != address(0)) {
            ILendingLogic lendingLogic = getLendingLogicFromWrapped(_outputToken);
            uint256 exchangeRate = lendingLogic.exchangeRate(_outputToken); // wrapped to underlying
            uint256 underlyingAmount = _outputAmount * exchangeRate / (10**18) + 1;

            return getPrice(_inputToken, underlying, underlyingAmount);
        }

        if(pieRegistry.inRegistry(_outputToken)) {
            uint256 ethAmount =  getPricePie(_outputToken, _outputAmount);

            if(_inputToken != address(WETH)) {
                return getPrice(_inputToken, address(WETH), ethAmount);
            }

            return ethAmount;
        }

        if(_inputToken != address(WETH) && _outputToken != address(WETH)) {
            (uint256 middleInputAmount,) = getBestPriceSushiUni(address(WETH), _outputToken, _outputAmount);
            (uint256 inputAmount,) = getBestPriceSushiUni(_inputToken, address(WETH), middleInputAmount);

            return inputAmount;
        }

        (uint256 inputAmount,) = getBestPriceSushiUni(_inputToken, _outputToken, _outputAmount);

        return inputAmount;
    }

    function getBestPriceSushiUni(address _inputToken, address _outputToken, uint256 _outputAmount) internal returns(uint256, DexChoice) {

        uint256 sushiAmount = getPriceUniLike(_inputToken, _outputToken, _outputAmount, sushiRouter);
        uint256 uniAmount = getPriceUniLike(_inputToken, _outputToken, _outputAmount, uniRouter);

        if(uniAmount < sushiAmount) {
            return (uniAmount, DexChoice.Uni);
        }

        return (sushiAmount, DexChoice.Sushi);
    }

    function getRoute(address _inputToken, address _outputToken) internal returns(address[] memory route) {

        if(_inputToken != address(WETH) && _outputToken != address(WETH)) {
            route = new address[](3);
            route[0] = _inputToken;
            route[1] = address(WETH);
            route[2] = _outputToken;
            return route;
        }

        route = new address[](2);
        route[0] = _inputToken;
        route[1] = _outputToken;

        return route;
    }

    function getPriceUniLike(address _inputToken, address _outputToken, uint256 _outputAmount, IUniRouter _router) internal returns(uint256) {

        if(_inputToken == _outputToken) {
            return(_outputAmount);
        }
        
        try _router.getAmountsIn(_outputAmount, getRoute(_inputToken, _outputToken)) returns(uint256[] memory amounts) {
            return amounts[0];
        } catch {
            return type(uint256).max;
        }
    }

    function getPricePie(address _pie, uint256 _pieAmount) internal returns(uint256) {

        IPie pie = IPie(_pie);
        (address[] memory tokens, uint256[] memory amounts) = pie.calcTokensForAmount(_pieAmount);

        uint256 inputAmount = 0;

        for(uint256 i = 0; i < tokens.length; i ++) {
            inputAmount += getPrice(address(WETH), tokens[i], amounts[i]);
        }

        return inputAmount;
    }

    function getLendingLogicFromWrapped(address _wrapped) internal view returns(ILendingLogic) {

        return ILendingLogic(
                lendingRegistry.protocolToLogic(
                    lendingRegistry.wrappedToProtocol(
                        _wrapped
                    )
                )
        );
    }

    function encodeData(uint256 _outputAmount) external pure returns(bytes memory){

        return abi.encode((_outputAmount));
    }
}//Unlicense
pragma solidity 0.8.1;


interface IWETH is IERC20 {

    function withdraw(uint wad) external;

}//Unlicense
pragma solidity 0.8.1;


contract V1CompatibleRecipe is UniPieRecipe {

    using SafeERC20 for IERC20;

    constructor(
        address _weth,
        address _uniRouter,
        address _sushiRouter,
        address _lendingRegistry,
        address _pieRegistry) UniPieRecipe(_weth, _uniRouter, _sushiRouter, _lendingRegistry, _pieRegistry) {
    }

    function toPie(address _pie, uint256 _outputAmount) external payable {

        uint256 calculatedSpend = getPrice(address(WETH), _pie, _outputAmount);

        address(WETH).call{value: msg.value}("");
        
        uint256 outputAmount = _bake(address(WETH), _pie, msg.value, _outputAmount);

        IERC20(_pie).safeTransfer(_msgSender(), outputAmount);

        uint256 wethBalance = WETH.balanceOf(address(this));
        if(wethBalance != 0) {
            IWETH(address(WETH)).withdraw(wethBalance);
            payable(msg.sender).transfer(wethBalance);
        }
    }

    function calcToPie(address _pie, uint256 _poolAmount) external returns(uint256) {

        return getPrice(address(WETH), _pie, _poolAmount);
    }

    fallback () external payable {}
}