


pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

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




interface IWETH {

    function deposit() external payable;

    function withdraw(uint wad) external;

}



interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address);

}



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

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}



interface IUniswapV2Router02 is IUniswapV2Router01 {

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

}




interface IIdeaToken is IERC20 {

    function initialize(string calldata __name, address owner) external;

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

}



interface IIdeaTokenNameVerifier {

    function verifyTokenName(string calldata name) external pure returns (bool);

}








struct IDPair {
    bool exists;
    uint marketID;
    uint tokenID;
}

struct TokenInfo {
    bool exists;
    uint id;
    string name;
    IIdeaToken ideaToken;
}

struct MarketDetails {
    bool exists;
    uint id;
    string name;

    IIdeaTokenNameVerifier nameVerifier;
    uint numTokens;

    uint baseCost;
    uint priceRise;
    uint hatchTokens;
    uint tradingFeeRate;
    uint platformFeeRate;

    bool allInterestToPlatform;
}

interface IIdeaTokenFactory {

    function addMarket(string calldata marketName, address nameVerifier,
                       uint baseCost, uint priceRise, uint hatchTokens,
                       uint tradingFeeRate, uint platformFeeRate, bool allInterestToPlatform) external;


    function addToken(string calldata tokenName, uint marketID, address lister) external;


    function isValidTokenName(string calldata tokenName, uint marketID) external view returns (bool);

    function getMarketIDByName(string calldata marketName) external view returns (uint);

    function getMarketDetailsByID(uint marketID) external view returns (MarketDetails memory);

    function getMarketDetailsByName(string calldata marketName) external view returns (MarketDetails memory);

    function getMarketDetailsByTokenAddress(address ideaToken) external view returns (MarketDetails memory);

    function getNumMarkets() external view returns (uint);

    function getTokenIDByName(string calldata tokenName, uint marketID) external view returns (uint);

    function getTokenInfo(uint marketID, uint tokenID) external view returns (TokenInfo memory);

    function getTokenIDPair(address token) external view returns (IDPair memory);

    function setTradingFee(uint marketID, uint tradingFeeRate) external;

    function setPlatformFee(uint marketID, uint platformFeeRate) external;

    function setNameVerifier(uint marketID, address nameVerifier) external;

}





struct CostAndPriceAmounts {
    uint total;
    uint raw;
    uint tradingFee;
    uint platformFee;
}

interface IIdeaTokenExchange {

    function sellTokens(address ideaToken, uint amount, uint minPrice, address recipient) external;

    function getPriceForSellingTokens(address ideaToken, uint amount) external view returns (uint);

    function getPricesForSellingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) external pure returns (CostAndPriceAmounts memory);

    function buyTokens(address ideaToken, uint amount, uint fallbackAmount, uint cost, address recipient) external;

    function getCostForBuyingTokens(address ideaToken, uint amount) external view returns (uint);

    function getCostsForBuyingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) external pure returns (CostAndPriceAmounts memory);

    function setTokenOwner(address ideaToken, address owner) external;

    function setPlatformOwner(uint marketID, address owner) external;

    function withdrawTradingFee() external;

    function withdrawTokenInterest(address token) external;

    function withdrawPlatformInterest(uint marketID) external;

    function withdrawPlatformFee(uint marketID) external;

    function getInterestPayable(address token) external view returns (uint);

    function getPlatformInterestPayable(uint marketID) external view returns (uint);

    function getPlatformFeePayable(uint marketID) external view returns (uint);

    function getTradingFeePayable() external view returns (uint);

    function setAuthorizer(address authorizer) external;

    function isTokenFeeDisabled(address ideaToken) external view returns (bool);

    function setTokenFeeKillswitch(address ideaToken, bool set) external;

}




struct LockedEntry {
    uint lockedUntil;
    uint lockedAmount;
}
    
interface IIdeaTokenVault {

    function lock(address ideaToken, uint amount, uint duration, address recipient) external;

    function withdraw(address ideaToken, uint[] calldata untils, address recipient) external;

    function getLockedEntries(address ideaToken, address user, uint maxEntries) external view returns (LockedEntry[] memory);

}





contract MultiAction {


    IIdeaTokenExchange _ideaTokenExchange;
    IIdeaTokenFactory _ideaTokenFactory;
    IIdeaTokenVault _ideaTokenVault;
    IERC20 public _dai;
    IUniswapV2Factory public _uniswapV2Factory;
    IUniswapV2Router02 public _uniswapV2Router02;
    IWETH public _weth;

    constructor(address ideaTokenExchange,
                address ideaTokenFactory,
                address ideaTokenVault,
                address dai,
                address uniswapV2Router02,
                address weth) public {

        require(ideaTokenExchange != address(0) &&
                ideaTokenFactory != address(0) &&
                ideaTokenVault != address(0) &&
                dai != address(0) &&
                uniswapV2Router02 != address(0) &&
                weth != address(0),
                "invalid-params");

        _ideaTokenExchange = IIdeaTokenExchange(ideaTokenExchange);
        _ideaTokenFactory = IIdeaTokenFactory(ideaTokenFactory);
        _ideaTokenVault = IIdeaTokenVault(ideaTokenVault);
        _dai = IERC20(dai);
        _uniswapV2Router02 = IUniswapV2Router02(uniswapV2Router02);
        _uniswapV2Factory = IUniswapV2Factory(IUniswapV2Router02(uniswapV2Router02).factory());
        _weth = IWETH(weth);
    }

    function convertAndBuy(address inputCurrency,
                           address ideaToken,
                           uint amount,
                           uint fallbackAmount,
                           uint cost,
                           uint lockDuration,
                           address recipient) external payable {


        IIdeaTokenExchange exchange = _ideaTokenExchange;

        uint buyAmount = amount;
        uint buyCost = exchange.getCostForBuyingTokens(ideaToken, amount);
        uint requiredInput = getInputForOutputInternal(inputCurrency, address(_dai), buyCost);

        if(requiredInput > cost) {
            buyCost = exchange.getCostForBuyingTokens(ideaToken, fallbackAmount);
            requiredInput = getInputForOutputInternal(inputCurrency, address(_dai), buyCost);
            require(requiredInput <= cost, "slippage");
            buyAmount = fallbackAmount;
        }

        convertAndBuyInternal(inputCurrency, ideaToken, requiredInput, buyAmount, buyCost, lockDuration, recipient);
    }

    function sellAndConvert(address outputCurrency,
                            address ideaToken,
                            uint amount,
                            uint minPrice,
                            address payable recipient) external {

        
        IIdeaTokenExchange exchange = _ideaTokenExchange;
        IERC20 dai = _dai;

        uint sellPrice = exchange.getPriceForSellingTokens(ideaToken, amount);
        uint output = getOutputForInputInternal(address(dai), outputCurrency, sellPrice);
        require(output >= minPrice, "slippage");

        pullERC20Internal(ideaToken, msg.sender, amount);
        exchange.sellTokens(ideaToken, amount, sellPrice, address(this));

        convertInternal(address(dai), outputCurrency, sellPrice, output);
        if(outputCurrency == address(0)) {
            recipient.transfer(output);
        } else {
            require(IERC20(outputCurrency).transfer(recipient, output), "transfer");
        }
    }

    function convertAddAndBuy(string calldata tokenName,
                              uint marketID,
                              address inputCurrency,
                              uint amount,
                              uint fallbackAmount,
                              uint cost,
                              uint lockDuration,
                              address recipient) external payable {


        IERC20 dai = _dai;

        uint buyAmount = amount;
        uint buyCost = getBuyCostFromZeroSupplyInternal(marketID, buyAmount);
        uint requiredInput = getInputForOutputInternal(inputCurrency, address(dai), buyCost);

        if(requiredInput > cost) {
            buyCost = getBuyCostFromZeroSupplyInternal(marketID, fallbackAmount);
            requiredInput = getInputForOutputInternal(inputCurrency, address(dai), buyCost);
            require(requiredInput <= cost, "slippage");
            buyAmount = fallbackAmount;
        }

        address ideaToken = addTokenInternal(tokenName, marketID);
        convertAndBuyInternal(inputCurrency, ideaToken, requiredInput, buyAmount, buyCost, lockDuration, recipient);
    }

    function addAndBuy(string calldata tokenName, uint marketID, uint amount, uint lockDuration, address recipient) external {

        uint cost = getBuyCostFromZeroSupplyInternal(marketID, amount);
        pullERC20Internal(address(_dai), msg.sender, cost);

        address ideaToken = addTokenInternal(tokenName, marketID);
        
        if(lockDuration > 0) {
            buyAndLockInternal(ideaToken, amount, cost, lockDuration, recipient);
        } else {
            buyInternal(ideaToken, amount, cost, recipient);
        }
    }

    function buyAndLock(address ideaToken, uint amount, uint fallbackAmount, uint cost, uint lockDuration, address recipient) external {


        IIdeaTokenExchange exchange = _ideaTokenExchange;

        uint buyAmount = amount;
        uint buyCost = exchange.getCostForBuyingTokens(ideaToken, amount);
        if(buyCost > cost) {
            buyCost = exchange.getCostForBuyingTokens(ideaToken, fallbackAmount);
            require(buyCost <= cost, "slippage");
            buyAmount = fallbackAmount;
        }

        pullERC20Internal(address(_dai), msg.sender, buyCost);
        buyAndLockInternal(ideaToken, buyAmount, buyCost, lockDuration, recipient);
    }

    function convertAndBuyInternal(address inputCurrency, address ideaToken, uint input, uint amount, uint cost, uint lockDuration, address recipient) internal {

        if(inputCurrency != address(0)) {
            pullERC20Internal(inputCurrency, msg.sender, input);
        }

        convertInternal(inputCurrency, address(_dai), input, cost);

        if(lockDuration > 0) {
            buyAndLockInternal(ideaToken, amount, cost, lockDuration, recipient);
        } else {
            buyInternal(ideaToken, amount, cost, recipient);
        }

        if(address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }

    function buyAndLockInternal(address ideaToken, uint amount, uint cost, uint lockDuration, address recipient) internal {


        IIdeaTokenVault vault = _ideaTokenVault;
    
        buyInternal(ideaToken, amount, cost, address(this));
        require(IERC20(ideaToken).approve(address(vault), amount), "approve");
        vault.lock(ideaToken, amount, lockDuration, recipient);
    }

    function buyInternal(address ideaToken, uint amount, uint cost, address recipient) internal {


        IIdeaTokenExchange exchange = _ideaTokenExchange;

        require(_dai.approve(address(exchange), cost), "approve");
        exchange.buyTokens(ideaToken, amount, amount, cost, recipient);
    }

    function addTokenInternal(string memory tokenName, uint marketID) internal returns (address) {


        IIdeaTokenFactory factory = _ideaTokenFactory;

        factory.addToken(tokenName, marketID, msg.sender);
        return address(factory.getTokenInfo(marketID, factory.getTokenIDByName(tokenName, marketID) ).ideaToken);
    }

    function pullERC20Internal(address token, address from, uint amount) internal {

        require(IERC20(token).allowance(from, address(this)) >= amount, "insufficient-allowance");
        require(IERC20(token).transferFrom(from, address(this), amount), "transfer");
    }

    function getBuyCostFromZeroSupplyInternal(uint marketID, uint amount) internal view returns (uint) {

        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByID(marketID);
        require(marketDetails.exists, "invalid-market");

        return _ideaTokenExchange.getCostsForBuyingTokens(marketDetails, 0, amount, false).total;
    }

    function getInputForOutputInternal(address inputCurrency, address outputCurrency, uint outputAmount) internal view returns (uint) {

        address[] memory path = getPathInternal(inputCurrency, outputCurrency);
        return _uniswapV2Router02.getAmountsIn(outputAmount, path)[0];
    }

    function getOutputForInputInternal(address inputCurrency, address outputCurrency, uint inputAmount) internal view returns (uint) {

        address[] memory path = getPathInternal(inputCurrency, outputCurrency);
        uint[] memory amountsOut = _uniswapV2Router02.getAmountsOut(inputAmount, path);
        return amountsOut[amountsOut.length - 1];
    }

    function getPathInternal(address inputCurrency, address outputCurrency) internal view returns (address[] memory) {


        address wethAddress = address(_weth);
        address updatedInputCurrency = inputCurrency == address(0) ? wethAddress : inputCurrency;
        address updatedOutputCurrency = outputCurrency == address(0) ? wethAddress : outputCurrency;

        IUniswapV2Factory uniswapFactory = _uniswapV2Factory;
        if(uniswapFactory.getPair(updatedInputCurrency, updatedOutputCurrency) != address(0)) {
             address[] memory path = new address[](2);
             path[0] = updatedInputCurrency;
             path[1] = updatedOutputCurrency;
             return path;
        }


        require(uniswapFactory.getPair(updatedInputCurrency, wethAddress) != address(0) &&
                uniswapFactory.getPair(wethAddress, updatedOutputCurrency) != address(0),
                "no-path");


        address[] memory path = new address[](3);
        path[0] = updatedInputCurrency;
        path[1] = wethAddress;
        path[2] = updatedOutputCurrency;

        return path;
    }

    function convertInternal(address inputCurrency, address outputCurrency, uint inputAmount, uint outputAmount) internal {

        
        IWETH weth = _weth;
        IUniswapV2Router02 router = _uniswapV2Router02;

        address[] memory path = getPathInternal(inputCurrency, outputCurrency);
    
        IERC20 inputERC20;
        if(inputCurrency == address(0)) {
            weth.deposit{value: inputAmount}();
            inputERC20 = IERC20(address(weth));
        } else {
            inputERC20 = IERC20(inputCurrency);
        }

        require(inputERC20.approve(address(router), inputAmount), "router-approve");

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(inputAmount,
                                                                     outputAmount,
                                                                     path,
                                                                     address(this),
                                                                     now + 1);

        if(outputCurrency == address(0)) {
            weth.withdraw(outputAmount);
        }
    }

    receive() external payable {
        require(msg.sender == address(_weth));
    } 
}