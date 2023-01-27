

pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity =0.5.16;


library Math {

    function min(uint x, uint y) internal pure returns (uint z) {

        z = x < y ? x : y;
    }

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


pragma solidity >=0.5.0;

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


pragma solidity >=0.5.0;

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


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



pragma solidity >=0.5.0;

interface IUniswapV2Router02 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}


pragma solidity 0.5.16;

interface IBank {       


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function totalETH() external view returns (uint256);


    function deposit() external payable;


    function withdraw(uint256 share) external;


}


pragma solidity =0.5.16;







library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

contract IbETHRouter is Ownable {

    using SafeMath for uint256;

    address public router;
    address public ibETH; 
    address public alpha;     
    address public lpToken;     

    constructor(address _router, address _ibETH, address _alpha) public {
        router = _router;
        ibETH = _ibETH;   
        alpha = _alpha;                             
        address factory = IUniswapV2Router02(router).factory();   
        lpToken = IUniswapV2Factory(factory).getPair(ibETH, alpha);                  
        IUniswapV2Pair(lpToken).approve(router, uint256(-1)); // 100% trust in the router        
        IBank(ibETH).approve(router, uint256(-1)); // 100% trust in the router        
        IERC20(alpha).approve(router, uint256(-1)); // 100% trust in the router        
    }

    function() external payable {
        assert(msg.sender == ibETH); // only accept ETH via fallback from the Bank contract
    }

    function ibETHForExactETH(uint256 amountETH) public view returns (uint256) {

        uint256 totalETH = IBank(ibETH).totalETH();        
        return totalETH == 0 ? amountETH : amountETH.mul(IBank(ibETH).totalSupply()).add(totalETH).sub(1).div(totalETH); 
    }   
    
    function addLiquidityETH(        
        uint256 amountAlphaDesired,
        uint256 amountAlphaMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable        
        returns (
            uint256 amountAlpha,
            uint256 amountETH,
            uint256 liquidity
        ) {                

        TransferHelper.safeTransferFrom(alpha, msg.sender, address(this), amountAlphaDesired);
        IBank(ibETH).deposit.value(msg.value)();   
        uint256 amountIbETHDesired = IBank(ibETH).balanceOf(address(this)); 
        uint256 amountIbETH;
        (amountAlpha, amountIbETH, liquidity) = IUniswapV2Router02(router).addLiquidity(
            alpha,
            ibETH,
            amountAlphaDesired,            
            amountIbETHDesired,
            amountAlphaMin,            
            0,
            to,
            deadline
        );         
        if (amountAlphaDesired > amountAlpha) {
            TransferHelper.safeTransfer(alpha, msg.sender, amountAlphaDesired.sub(amountAlpha));
        }                       
        IBank(ibETH).withdraw(amountIbETHDesired.sub(amountIbETH));        
        amountETH = msg.value - address(this).balance;
        if (amountETH > 0) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        }
        require(amountETH >= amountETHMin, "IbETHRouter: require more ETH than amountETHmin");
    }

    function optimalDeposit(
        uint256 amtA,
        uint256 amtB,
        uint256 resA,
        uint256 resB
    ) internal pure returns (uint256 swapAmt, bool isReversed) {

        if (amtA.mul(resB) >= amtB.mul(resA)) {
            swapAmt = _optimalDepositA(amtA, amtB, resA, resB);
            isReversed = false;
        } else {
            swapAmt = _optimalDepositA(amtB, amtA, resB, resA);
            isReversed = true;
        }
    }

    function _optimalDepositA(
        uint256 amtA,
        uint256 amtB,
        uint256 resA,
        uint256 resB
    ) internal pure returns (uint256) {

        require(amtA.mul(resB) >= amtB.mul(resA), "Reversed");

        uint256 a = 997;
        uint256 b = uint256(1997).mul(resA);
        uint256 _c = (amtA.mul(resB)).sub(amtB.mul(resA));
        uint256 c = _c.mul(1000).div(amtB.add(resB)).mul(resA);

        uint256 d = a.mul(c).mul(4);
        uint256 e = Math.sqrt(b.mul(b).add(d));

        uint256 numerator = e.sub(b);
        uint256 denominator = a.mul(2);

        return numerator.div(denominator);
    }

    function addLiquidityTwoSidesOptimal(        
        uint256 amountIbETHDesired,        
        uint256 amountAlphaDesired,        
        uint256 amountLPMin,
        address to,
        uint256 deadline
    )
        external        
        returns (            
            uint256 liquidity
        ) {        

        if (amountIbETHDesired > 0) {
            TransferHelper.safeTransferFrom(ibETH, msg.sender, address(this), amountIbETHDesired);    
        }
        if (amountAlphaDesired > 0) {
            TransferHelper.safeTransferFrom(alpha, msg.sender, address(this), amountAlphaDesired);    
        }        
        uint256 swapAmt;
        bool isReversed;
        {
            (uint256 r0, uint256 r1, ) = IUniswapV2Pair(lpToken).getReserves();
            (uint256 ibETHReserve, uint256 alphaReserve) = IUniswapV2Pair(lpToken).token0() == ibETH ? (r0, r1) : (r1, r0);
            (swapAmt, isReversed) = optimalDeposit(amountIbETHDesired, amountAlphaDesired, ibETHReserve, alphaReserve);
        }
        address[] memory path = new address[](2);
        (path[0], path[1]) = isReversed ? (alpha, ibETH) : (ibETH, alpha);        
        IUniswapV2Router02(router).swapExactTokensForTokens(swapAmt, 0, path, address(this), now);                
        (,, liquidity) = IUniswapV2Router02(router).addLiquidity(
            alpha,
            ibETH,
            IERC20(alpha).balanceOf(address(this)),            
            IBank(ibETH).balanceOf(address(this)),
            0,            
            0,
            to,
            deadline
        );        
        uint256 dustAlpha = IERC20(alpha).balanceOf(address(this));
        uint256 dustIbETH = IBank(ibETH).balanceOf(address(this));
        if (dustAlpha > 0) {
            TransferHelper.safeTransfer(alpha, msg.sender, dustAlpha);
        }    
        if (dustIbETH > 0) {
            TransferHelper.safeTransfer(ibETH, msg.sender, dustIbETH);
        }                    
        require(liquidity >= amountLPMin, "IbETHRouter: receive less lpToken than amountLPMin");
    }

    function addLiquidityTwoSidesOptimalETH(                
        uint256 amountAlphaDesired,        
        uint256 amountLPMin,
        address to,
        uint256 deadline
    )
        external
        payable        
        returns (            
            uint256 liquidity
        ) {                

        if (amountAlphaDesired > 0) {
            TransferHelper.safeTransferFrom(alpha, msg.sender, address(this), amountAlphaDesired);    
        }       
        IBank(ibETH).deposit.value(msg.value)();   
        uint256 amountIbETHDesired = IBank(ibETH).balanceOf(address(this));                  
        uint256 swapAmt;
        bool isReversed;
        {
            (uint256 r0, uint256 r1, ) = IUniswapV2Pair(lpToken).getReserves();
            (uint256 ibETHReserve, uint256 alphaReserve) = IUniswapV2Pair(lpToken).token0() == ibETH ? (r0, r1) : (r1, r0);
            (swapAmt, isReversed) = optimalDeposit(amountIbETHDesired, amountAlphaDesired, ibETHReserve, alphaReserve);
        }        
        address[] memory path = new address[](2);
        (path[0], path[1]) = isReversed ? (alpha, ibETH) : (ibETH, alpha);        
        IUniswapV2Router02(router).swapExactTokensForTokens(swapAmt, 0, path, address(this), now);                
        (,, liquidity) = IUniswapV2Router02(router).addLiquidity(
            alpha,
            ibETH,
            IERC20(alpha).balanceOf(address(this)),            
            IBank(ibETH).balanceOf(address(this)),
            0,            
            0,
            to,
            deadline
        );        
        uint256 dustAlpha = IERC20(alpha).balanceOf(address(this));
        uint256 dustIbETH = IBank(ibETH).balanceOf(address(this));
        if (dustAlpha > 0) {
            TransferHelper.safeTransfer(alpha, msg.sender, dustAlpha);
        }    
        if (dustIbETH > 0) {
            TransferHelper.safeTransfer(ibETH, msg.sender, dustIbETH);
        }                    
        require(liquidity >= amountLPMin, "IbETHRouter: receive less lpToken than amountLPMin");
    }
      
    function removeLiquidityETH(        
        uint256 liquidity,
        uint256 amountAlphaMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public returns (uint256 amountAlpha, uint256 amountETH) {                  

        TransferHelper.safeTransferFrom(lpToken, msg.sender, address(this), liquidity);          
        uint256 amountIbETH;
        (amountAlpha, amountIbETH) = IUniswapV2Router02(router).removeLiquidity(
            alpha,
            ibETH,
            liquidity,
            amountAlphaMin,
            0,
            address(this),
            deadline
        );                        
        TransferHelper.safeTransfer(alpha, to, amountAlpha); 
        IBank(ibETH).withdraw(amountIbETH);        
        amountETH = address(this).balance;
        if (amountETH > 0) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        }
        require(amountETH >= amountETHMin, "IbETHRouter: receive less ETH than amountETHmin");                               
    }

    function removeLiquidityAllAlpha(        
        uint256 liquidity,
        uint256 amountAlphaMin,        
        address to,
        uint256 deadline
    ) public returns (uint256 amountAlpha) {                  

        TransferHelper.safeTransferFrom(lpToken, msg.sender, address(this), liquidity);          
        (uint256 removeAmountAlpha, uint256 removeAmountIbETH) = IUniswapV2Router02(router).removeLiquidity(
            alpha,
            ibETH,
            liquidity,
            0,
            0,
            address(this),
            deadline
        );        
        address[] memory path = new address[](2);
        path[0] = ibETH;
        path[1] = alpha;
        uint256[] memory amounts = IUniswapV2Router02(router).swapExactTokensForTokens(removeAmountIbETH, 0, path, to, deadline);               
        TransferHelper.safeTransfer(alpha, to, removeAmountAlpha);                        
        amountAlpha = removeAmountAlpha.add(amounts[1]);
        require(amountAlpha >= amountAlphaMin, "IbETHRouter: receive less Alpha than amountAlphaMin");                               
    }       

    function swapExactETHForAlpha(
        uint256 amountAlphaOutMin,        
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts) {                           

        IBank(ibETH).deposit.value(msg.value)();   
        address[] memory path = new address[](2);
        path[0] = ibETH;
        path[1] = alpha;     
        uint256[] memory swapAmounts = IUniswapV2Router02(router).swapExactTokensForTokens(IBank(ibETH).balanceOf(address(this)), amountAlphaOutMin, path, to, deadline);
        amounts = new uint256[](2);        
        amounts[0] = msg.value;
        amounts[1] = swapAmounts[1];
    }

    function swapAlphaForExactETH(
        uint256 amountETHOut,
        uint256 amountAlphaInMax,         
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {

        TransferHelper.safeTransferFrom(alpha, msg.sender, address(this), amountAlphaInMax);
        address[] memory path = new address[](2);
        path[0] = alpha;
        path[1] = ibETH;
        IBank(ibETH).withdraw(0);
        uint256[] memory swapAmounts = IUniswapV2Router02(router).swapTokensForExactTokens(ibETHForExactETH(amountETHOut), amountAlphaInMax, path, address(this), deadline);                           
        IBank(ibETH).withdraw(swapAmounts[1]);
        amounts = new uint256[](2);
        amounts[0] = swapAmounts[0];
        amounts[1] = address(this).balance;
        TransferHelper.safeTransferETH(to, address(this).balance);        
        if (amountAlphaInMax > amounts[0]) {
            TransferHelper.safeTransfer(alpha, msg.sender, amountAlphaInMax.sub(amounts[0]));
        }                    
    }

    function swapExactAlphaForETH(
        uint256 amountAlphaIn,
        uint256 amountETHOutMin,         
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {

        TransferHelper.safeTransferFrom(alpha, msg.sender, address(this), amountAlphaIn); 
        address[] memory path = new address[](2);
        path[0] = alpha;
        path[1] = ibETH;
        uint256[] memory swapAmounts = IUniswapV2Router02(router).swapExactTokensForTokens(amountAlphaIn, 0, path, address(this), deadline);                        
        IBank(ibETH).withdraw(swapAmounts[1]);        
        amounts = new uint256[](2);
        amounts[0] = swapAmounts[0];
        amounts[1] = address(this).balance;
        TransferHelper.safeTransferETH(to, amounts[1]);
        require(amounts[1] >= amountETHOutMin, "IbETHRouter: receive less ETH than amountETHmin");                                       
    }

    function swapETHForExactAlpha(
        uint256 amountAlphaOut,          
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts) {             

        IBank(ibETH).deposit.value(msg.value)();              
        uint256 amountIbETHInMax = IBank(ibETH).balanceOf(address(this));        
        address[] memory path = new address[](2);
        path[0] = ibETH;
        path[1] = alpha;                
        uint256[] memory swapAmounts = IUniswapV2Router02(router).swapTokensForExactTokens(amountAlphaOut, amountIbETHInMax, path, to, deadline);                                                
        amounts = new uint256[](2);               
        amounts[0] = msg.value;
        amounts[1] = swapAmounts[1];
        if (amountIbETHInMax > swapAmounts[0]) {                         
            IBank(ibETH).withdraw(amountIbETHInMax.sub(swapAmounts[0]));                    
            amounts[0] = msg.value - address(this).balance;
            TransferHelper.safeTransferETH(to, address(this).balance);
        }                                       
    }   

    function recover(address token, address to, uint256 value) external onlyOwner {        

        TransferHelper.safeTransfer(token, to, value);                
    }

    function recoverETH(address to, uint256 value) external onlyOwner {        

        TransferHelper.safeTransferETH(to, value);                
    }
}