

pragma solidity >=0.6.2;

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


pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

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

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity 0.8.11;


interface ITetraguard is IERC20 {

    function upgradeToken(uint256 amount, address tokenHolder) external returns (uint256);

}


pragma solidity 0.8.11;


interface IQuadron is IERC20 {

    function buy(uint256 minTokensRequested) external payable;

    function sell(uint256 amount) external;

    function quoteAvgPriceForTokens(uint256 amount) external view returns (uint256);

    function updatePhase() external;

    function getPhase() external returns (uint8);

    function mintBonus() external;

    function addApprovedToken(address newToken) external;

}



pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;




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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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



pragma solidity 0.8.11;





contract Tetraguard is ITetraguard, ERC20 {

    IUniswapV2Router02 private uniswapRouter;

    IQuadron private qToken;

    address private UNISWAP_ROUTER_ADDRESS; // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private PAXG; // 0x45804880De22913dAFE09f4980848ECE6EcbAf78;
    address private WBTC; // 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private RESERVE;
    address private UPGRADE_TOKEN;

    uint32 private constant R_WBTC = 1;
    uint32 private constant R_ETH = 13;
    uint32 private constant R_PAXG = 26;
    uint32 private constant R_RESERVE = 23632;

    uint256 internal constant PHASE_1_END_SUPPLY = 65e6 * 1e18; 
    uint256 internal constant PHASE_2_END_SUPPLY = 68333333333333333333333333;
    uint256 internal constant MAX_BUY_ORDER = 2000 ether;
    uint256 internal constant MAX_SELL_ORDER = 400e3 * 1e18;    

    uint256 private remAlphaBonus = 7.5e6 * 1e18;
    uint256 private remBetaBonus = 4.5e6 * 1e18;
    uint256 private remGammaBonus = 3e6 * 1e18;
    uint256 private remAlphaRTokens = 6666666666666666666666667;
    uint256 private remBetaRTokens = 6666666666666666666666667;
    uint256 private remGammaRTokens = 6666666666666666666666666;
        
    address private owner;  // Contract owner

    constructor(address _quadron, address _paxg, address _wbtc, address _uniswapRouter) 
        ERC20("Tetraguard", "TETRA") {
        
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);

        qToken = IQuadron(_quadron);

        owner = address(msg.sender);

        UNISWAP_ROUTER_ADDRESS = _uniswapRouter;
        PAXG = _paxg;
        WBTC = _wbtc;
        RESERVE = _quadron;
        UPGRADE_TOKEN = msg.sender; // Initially, set the upgrade token address to the owner
    }

    function buy(uint256 deadline, uint256 priceWBTC, uint256 pricePAXG) external payable {
        require(deadline >= block.timestamp, "Deadline expired");
        require(msg.value <= MAX_BUY_ORDER, "Buy exceeded the maximum purchase amount");
        
        uint256 PriceOfBase;
        uint256 PriceOfBaseWBTC;
        uint256 PriceOfBasePAXG;
        uint256 PriceOfBaseEth;
        uint256 PriceOfReserve;
        uint256 prevRTokenTotalSupply = qToken.totalSupply();
        uint256 balance = address(this).balance;

        (PriceOfBase, PriceOfBaseWBTC, PriceOfBasePAXG, PriceOfBaseEth, PriceOfReserve) = getPriceOfBase();
        
        require(baseTokensToMint(PriceOfBase) >= 1, "Not enough Ether to purchase .0001 Tetraguard");
       
        require(1e4 * PriceOfBaseWBTC / R_WBTC <= priceWBTC, "Maximum wbtc price exceeded.");
        require(1e4 * PriceOfBasePAXG / R_PAXG <= pricePAXG, "Maximum paxg price exceeded.");

        payable(RESERVE).transfer(PriceOfBase * baseTokensToMint(PriceOfBase) * 1 / 100);

        qToken.buy{value: baseTokensToMint(PriceOfBase) * PriceOfReserve * 101 / 100}(reserveTokensToMint(baseTokensToMint(PriceOfBase)));

        uniswapRouter.swapETHForExactTokens{ 
            value: (baseTokensToMint(PriceOfBase) * PriceOfBaseWBTC * 101 / 100) 
            }(baseTokensToMint(PriceOfBase) * R_WBTC * 1e4, getPathForETHtoToken(WBTC), address(this), deadline);

        uniswapRouter.swapETHForExactTokens{ 
            value: (baseTokensToMint(PriceOfBase) * PriceOfBasePAXG * 101 / 100) 
            }(baseTokensToMint(PriceOfBase) * R_PAXG * 1e14 * 10000 / 9998, getPathForETHtoToken(PAXG), address(this), deadline);

        balance = msg.value - (balance - address(this).balance);  // amount of eth left in this transaction

        if(prevRTokenTotalSupply <= PHASE_1_END_SUPPLY) {
            bool success = qToken.transfer(msg.sender, calcBonusTokens(reserveTokensToMint(baseTokensToMint(PriceOfBase))));
            require(success, "Early buyer bonus transfer failed.");
        }
        
        _mint(msg.sender, baseTokensToMint(PriceOfBase) * 1e14);

        (bool successRefund,) = msg.sender.call{ value: (balance - amountEthInCoin(baseTokensToMint(PriceOfBase), PriceOfBaseEth)) }("");
        require(successRefund, "Refund failed");        
    }

    function sell(uint256 amount, uint256 deadline, uint256 priceWBTC, uint256 pricePAXG) external payable {
        require(balanceOf(msg.sender) >= amount, "Insufficient Tetraguard to sell");
        require(deadline >= block.timestamp, "Deadline expired");
        require(amount <= MAX_SELL_ORDER, "Sell exceeded maximum sale amount");

        bool success;

        uint256 amountBaseToken = (amount / 1e14) * 1e14;  // Get floor.  Mimimum amount of Tetraguard Tokens to transact is .0001
        require(amountBaseToken >= 1e14, "The minimum sale amount is .0001 token");

        uint256 MinProceedsWBTC;
        uint256 MinProceedsPAXG;
        
        (MinProceedsWBTC, MinProceedsPAXG) = estimateProceeds(amountBaseToken);

        require(1e18 * MinProceedsWBTC / (amountBaseToken * R_WBTC) >= priceWBTC, "Minimum wbtc price not met.");
        require(1e18 * MinProceedsPAXG / (amountBaseToken * R_PAXG) >= pricePAXG, "Minimum paxg price not met.");

        uint256 coinValueStart = address(this).balance;

        require(IERC20(WBTC).approve(address(UNISWAP_ROUTER_ADDRESS), 
            amountBaseToken * R_WBTC / 1e10), 'Approve failed');
        uniswapRouter.swapExactTokensForETH(amountBaseToken * R_WBTC / 1e10, MinProceedsWBTC, getPathFoqTokentoETH(WBTC), address(this), deadline);  // 1e10 accounts for 8 decimal places of WBTC, and that minimum purchase by this contract is 1e-4
        
        require(IERC20(PAXG).approve(address(UNISWAP_ROUTER_ADDRESS), amountBaseToken * R_PAXG), 'Approve failed');
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amountBaseToken * R_PAXG, MinProceedsPAXG, getPathFoqTokentoETH(PAXG), address(this), deadline);

        if(qToken.getPhase() == 3) {
            qToken.sell(amountBaseToken * R_RESERVE);
        } else {
            success = qToken.transfer(msg.sender, amountBaseToken * R_RESERVE);
            require(success, "Early buyer bonus transfer failed.");
        }

        uint coinValueEnd = address(this).balance;
        uint proceedsFromSwap = coinValueEnd - coinValueStart + (amountBaseToken * R_ETH);

        payable(RESERVE).transfer(proceedsFromSwap * 1 / 100); // transfer 1% fee to the Quadron

        _burn(msg.sender, amountBaseToken);

        (success,) = msg.sender.call{ value: (proceedsFromSwap * 99 / 100)}("");
        require(success, "Payment failed");
    }

    function reserveTokensToMint(uint256 tetraguardTokensToMint) internal pure returns (uint256) {
        return tetraguardTokensToMint * R_RESERVE * 1e14;
    }

    function baseTokensToMint(uint256 priceOfBase) internal view returns (uint256) {
        require(priceOfBase > 0, "The price of base token must be greater than zero");
        return msg.value / (101 * priceOfBase / 100);  // 1.01 represents the 1% Tetraguard fee
    }    

    function getPriceOfBase() internal view returns (uint256, uint256, uint256, uint256, uint256) {
       
        require(msg.value >= 1e14, "Insufficient ether sent to purchase 0.0001 token");
        
        uint256 PAXGtoETH = uniswapRouter.getAmountsOut(msg.value, getPathForETHtoToken(PAXG))[1];
        uint256 WBTCtoETH = uniswapRouter.getAmountsOut(msg.value, getPathForETHtoToken(WBTC))[1];

        uint256 PriceOfBasePAXG;
        uint256 PriceOfBaseWBTC;
        uint256 PriceOfBaseEth = 1e14; // base price of Eth


        require(PAXGtoETH > 0, "The price of PAXG is too high for this amount of Eth.");
        PriceOfBasePAXG = 1e14 * msg.value / PAXGtoETH;
        require(PriceOfBasePAXG > 0, "The price of PAXG has dropped too low to trade.");
        
        require(WBTCtoETH > 0, "The price of WBTC is too high for this amount of Eth.");
        PriceOfBaseWBTC = 1e4 * msg.value / WBTCtoETH; // 1e4 is required to scale WBTC, since it uses a fewer decimals than Eth.
        require(PriceOfBaseWBTC > 0, "The price of WBTC has dropped to low to trade.");
        
        uint256 PriceOfReserveEth = qToken.quoteAvgPriceForTokens(msg.value);

        PriceOfBasePAXG = R_PAXG * PriceOfBasePAXG * 10000 / 9998; // (10000 / 9998) to account for the PAXG 0.02% fee;
        PriceOfBaseEth = R_ETH * PriceOfBaseEth;
        PriceOfBaseWBTC = R_WBTC * PriceOfBaseWBTC;
        PriceOfReserveEth = R_RESERVE * PriceOfReserveEth / 1e4; // Scale to 0.0001 quadrons

        return (PriceOfBaseWBTC + PriceOfBasePAXG + PriceOfBaseEth + PriceOfReserveEth, PriceOfBaseWBTC, PriceOfBasePAXG, PriceOfBaseEth, PriceOfReserveEth);
    }

    function estimateProceeds(uint256 amount) internal view returns (uint256, uint256) {
        uint256 PAXGtoETH = uniswapRouter.getAmountsOut(amount * R_PAXG, getPathFoqTokentoETH(PAXG))[1];
        uint256 WBTCtoETH = uniswapRouter.getAmountsOut(amount * R_WBTC / 1e10, getPathFoqTokentoETH(WBTC))[1];

        uint256 PriceOfBasePAXG;
        uint256 PriceOfBaseWBTC;

        PriceOfBasePAXG = PAXGtoETH * 9998 / 10000;
        PriceOfBaseWBTC = WBTCtoETH;

        return (PriceOfBaseWBTC, PriceOfBasePAXG);
    }

    function getPathForETHtoToken(address tokenAddress) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = tokenAddress;
        
        return path;
    }
    
    function getPathFoqTokentoETH(address tokenAddress) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = uniswapRouter.WETH();        
        
        return path;
    }

    function amountEthInCoin(uint tokensToMint, uint priceOfBaseEth) private pure returns (uint) {
        return tokensToMint * priceOfBaseEth;
    }

    function calcBonusTokens(uint256 qTokensToMint) private returns (uint256) {
        uint256 alpha = 0;  // Amount of bonus tokens for phase alpha
        uint256 beta = 0;  // Amount of bonus tokens for phase beta
        uint256 gamma = 0;  // Amount of bonus tokens for phase gamma
        uint256 remainder = qTokensToMint;


        if(remainder > 0 && remAlphaRTokens > 0) {
            if(remainder > remAlphaRTokens) {
                remainder = remainder - remAlphaRTokens;
                remAlphaRTokens = 0;
                alpha = remAlphaBonus;
                remAlphaBonus = 0;
            } else {
                remAlphaRTokens = remAlphaRTokens - remainder;
                alpha = remainder * 1125 / 1000;
                remainder = 0;
                
                if(alpha > remAlphaBonus) {
                    alpha = remAlphaBonus;
                    remAlphaBonus = 0;
                    remAlphaRTokens = 0;
                } else {
                    remAlphaBonus = remAlphaBonus - alpha;
                }
            }
        }
        
        if(remainder > 0 && remBetaRTokens > 0) {
            if(remainder > remBetaRTokens) {
                remainder = remainder - remBetaRTokens;
                remBetaRTokens = 0;
                beta = remBetaBonus;
                remBetaBonus = 0;
            } else {
                remBetaRTokens = remBetaRTokens - remainder;
                beta = remainder * 675 / 1000;
                remainder = 0;
                
                if(beta > remBetaBonus) {
                    beta = remBetaBonus;
                    remBetaBonus = 0;
                    remBetaRTokens = 0;
                } else {
                    remBetaBonus = remBetaBonus - beta;
                }
            }            
        }
        
        if(remainder > 0 && remGammaRTokens > 0) {
            if(remainder > remGammaRTokens) {
                remGammaRTokens = 0;
                gamma = remGammaBonus;
                remGammaBonus = 0;
            } else {
                remGammaRTokens = remGammaRTokens - remainder;
                gamma = remainder * 45 / 100;
                
                if(gamma > remGammaBonus) {
                    gamma = remGammaBonus;
                    remGammaBonus = 0;
                    remGammaRTokens = 0;
                } else {
                    remGammaBonus = remGammaBonus - gamma;
                }
            }
        }
     
        return alpha + beta + gamma;
    }

    function mintBonusTokens() external isOwner {
        qToken.mintBonus();
    }

    function setUpgradeToken(address tokenAddress) external isOwner {
        UPGRADE_TOKEN = tokenAddress;
        qToken.addApprovedToken(tokenAddress);
    }

    function upgradeToken(uint256 amount, address tokenHolder) external override returns (uint256) {
        require(UPGRADE_TOKEN != address(0));
        require(msg.sender == UPGRADE_TOKEN, "Not authorized to upgrade");
        require(balanceOf(tokenHolder) >= amount, "Insufficient Tetraguard to upgrade");
        require(amount > 0, "Amount must be greater than zero");
        _burn(tokenHolder, amount); // burn the old token

        require(IERC20(WBTC).transfer(address(msg.sender), amount * R_WBTC / 1e10), "WBTC transfer failed");
        require(IERC20(PAXG).transfer(msg.sender, amount * R_PAXG), "WBTC transfer failed");
        require(qToken.transfer(msg.sender, amount * R_RESERVE), "Quadron transfer failed");

        (bool success,) = msg.sender.call{ value: (amount * R_ETH)}("");
        require(success, "Transfer Tetraguard ether failed.");

        return (amount * R_ETH);
    }
  
    receive() external payable {
    }
    
    fallback() external payable {
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
}