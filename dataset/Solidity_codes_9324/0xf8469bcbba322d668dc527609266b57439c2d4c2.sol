


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



pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
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


pragma solidity >=0.6.0;

interface IUniswapV2Pair {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}


pragma solidity >=0.7.2;

interface IUniswapV2Router01 {

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

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

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


pragma solidity >=0.7.2;
pragma experimental ABIEncoderV2;






contract UniswapAdapter {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public constant ethAddress = address(0);
    address public immutable wethAddress;
    address public immutable wbtcAddress;
    address public immutable diggAddress;
    string private constant _name = "UNISWAP";
    bool private constant _nonFungible = true;
    IUniswapV2Router02 public immutable sushiswapRouter;
    IUniswapV2Pair public immutable wbtcDiggSushiswap;
    IERC20 public immutable wbtcToken;
    IERC20 public immutable diggToken;
    uint256 private constant deadlineBuffer = 150;

    constructor(
        address _sushiswapRouter,
        address _wbtcAddress,
        address _wethAddress,
        address _wbtcDiggSushiswap,
        address _diggAddress
    ) {
        require(_sushiswapRouter != address(0), "!_sushiswapRouter");
        require(_wethAddress != address(0), "!_weth");
        require(_wbtcAddress != address(0), "!_wbtc");
        require(_wbtcDiggSushiswap != address(0), "!_wbtcDiggSushiswap");
        require(_diggAddress != address(0), "!_diggAddress");

        wbtcAddress = _wbtcAddress;
        wethAddress = _wethAddress;
        diggAddress = _diggAddress;
        sushiswapRouter = IUniswapV2Router02(_sushiswapRouter);
        wbtcDiggSushiswap = IUniswapV2Pair(_wbtcDiggSushiswap);
        wbtcToken = IERC20(_wbtcAddress);
        diggToken = IERC20(_diggAddress);
    }

    receive() external payable {}

    function protocolName() public pure returns (string memory) {

        return _name;
    }

    function nonFungible() external pure returns (bool) {

        return _nonFungible;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function getSwapAmt(uint256 amtA, uint256 resA)
        internal
        pure
        returns (uint256)
    {

        return
            sqrt(amtA.mul(resA.mul(3988000) + amtA.mul(3988009))).sub(
                amtA.mul(1997)
            ) / 1994;
    }

    function expectedWbtcOut(uint256 ethAmt) public view returns (uint256) {

        address[] memory path = new address[](2);
        path[0] = wethAddress;
        path[1] = wbtcAddress;
        uint256 wbtcOut = sushiswapRouter.getAmountsOut(ethAmt, path)[1];
        return wbtcOut;
    }

    function expectedDiggOut(uint256 wbtcAmt)
        public
        view
        returns (uint256 diggOut, uint256 tradeAmt)
    {

        (uint112 reserveAmt, , ) =
            IUniswapV2Pair(wbtcDiggSushiswap).getReserves();
        tradeAmt = getSwapAmt(reserveAmt, wbtcAmt);
        address[] memory path = new address[](2);
        path[0] = wbtcAddress;
        path[1] = diggAddress;
        diggOut = sushiswapRouter.getAmountsOut(tradeAmt, path)[1];
    }

    function convertEthToToken(
        uint256 inputAmount,
        address addr,
        uint256 amountOutMin
    ) internal returns (uint256) {

        uint256 amtOut =
            _convertEthToToken(
                inputAmount,
                addr,
                amountOutMin,
                sushiswapRouter
            );
        return amtOut;
    }

    function convertTokenToToken(
        address addr1,
        address addr2,
        uint256 amount,
        uint256 amountOutMin
    ) internal returns (uint256) {

        uint256 amtOut =
            _convertTokenToToken(
                addr1,
                addr2,
                amount,
                amountOutMin,
                sushiswapRouter
            );
        return amtOut;
    }

    function addLiquidity(
        address token1,
        address token2,
        uint256 amount1,
        uint256 amount2
    ) internal returns (uint256) {

        uint256 lpAmt =
            _addLiquidity(token1, token2, amount1, amount2, sushiswapRouter);
        return lpAmt;
    }

    function _convertEthToToken(
        uint256 inputAmount,
        address addr,
        uint256 amountOutMin,
        IUniswapV2Router02 router
    ) internal returns (uint256) {

        uint256 deadline = block.timestamp + deadlineBuffer;
        address[] memory path = new address[](2);
        path[0] = wethAddress;
        path[1] = addr;
        uint256 amtOut =
            router.swapExactETHForTokens{value: inputAmount}(
                amountOutMin,
                path,
                address(this),
                deadline
            )[1];
        return amtOut;
    }

    function _convertTokenToToken(
        address addr1,
        address addr2,
        uint256 amount,
        uint256 amountOutMin,
        IUniswapV2Router02 router
    ) internal returns (uint256) {

        uint256 deadline = block.timestamp + deadlineBuffer;
        address[] memory path = new address[](2);
        path[0] = addr1;
        path[1] = addr2;
        if (wbtcToken.allowance(address(this), address(router)) == 0) {
            wbtcToken.safeApprove(address(router), type(uint256).max);
        }
        uint256 amtOut =
            router.swapExactTokensForTokens(
                amount,
                amountOutMin,
                path,
                address(this),
                deadline
            )[1];
        return amtOut;
    }

    function _addLiquidity(
        address token1,
        address token2,
        uint256 amount1,
        uint256 amount2,
        IUniswapV2Router02 router
    ) internal returns (uint256) {

        uint256 deadline = block.timestamp + deadlineBuffer;
        if (wbtcToken.allowance(address(this), address(router)) < amount1) {
            wbtcToken.safeApprove(address(router), type(uint256).max);
        }
        if (diggToken.allowance(address(this), address(router)) < amount2) {
            diggToken.safeApprove(address(router), type(uint256).max);
        }
        (, , uint256 lpAmt) =
            router.addLiquidity(
                token1,
                token2,
                amount1,
                amount2,
                0,
                0,
                address(this),
                deadline
            );
        return lpAmt;
    }

    function _buyLp(
        uint256 userWbtcBal,
        address traderAccount,
        uint256 tradeAmt,
        uint256 minDiggAmtOut
    ) internal {

        uint256 diggAmt =
            convertTokenToToken(
                wbtcAddress,
                diggAddress,
                tradeAmt,
                minDiggAmtOut
            );
        uint256 lpAmt =
            addLiquidity(wbtcAddress, diggAddress, userWbtcBal, diggAmt);
        require(
            wbtcDiggSushiswap.transfer(traderAccount, lpAmt),
            "transfer failed"
        );
    }

    function buyLp(
        uint256 amt,
        uint256 tradeAmt,
        uint256 minWbtcAmtOut,
        uint256 minDiggAmtOut
    ) public payable {

        require(msg.value >= amt, "not enough funds");
        uint256 wbtcAmt = convertEthToToken(amt, wbtcAddress, minWbtcAmtOut);
        _buyLp(wbtcAmt, msg.sender, tradeAmt, minDiggAmtOut);
    }
}