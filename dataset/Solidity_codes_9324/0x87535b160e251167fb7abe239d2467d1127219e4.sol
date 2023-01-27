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

}// MIT
pragma solidity ^0.8.0;

interface ITipJar {

    function tip() external payable;

    function updateMinerSplit(address minerAddress, address splitTo, uint32 splitPct) external;

    function setFeeCollector(address newCollector) external;

    function setFee(uint32 newFee) external;

    function changeAdmin(address newAdmin) external;

    function upgradeTo(address newImplementation) external;

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable; 

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

    function safeTransfer(IERC20Extended token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Extended token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Extended token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Extended token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Extended token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Extended token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}//MIT
pragma solidity ^0.8.0;



contract ArcherSwapRouter {

    using SafeERC20 for IERC20Extended;

    receive() external payable {}
    
    fallback() external payable {}

    ITipJar public immutable tipJar;

    struct Trade {
        uint amountIn;
        uint amountOut;
        address[] path;
        address payable to;
        uint256 deadline;
    }

    struct AddLiquidity {
        address tokenA;
        address tokenB;
        uint amountADesired;
        uint amountBDesired;
        uint amountAMin;
        uint amountBMin;
        address to;
        uint deadline;
    }

    struct RemoveLiquidity {
        IERC20Extended lpToken;
        address tokenA;
        address tokenB;
        uint liquidity;
        uint amountAMin;
        uint amountBMin;
        address to;
        uint deadline;
    }

    struct Permit {
        IERC20Extended token;
        uint256 amount;
        uint deadline;
        uint8 v;
        bytes32 r; 
        bytes32 s;
    }

    constructor(address _tipJar) {
        tipJar = ITipJar(_tipJar);
    }

    function addLiquidityAndTipAmount(
        IUniRouter router,
        AddLiquidity calldata liquidity
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _addLiquidity(
            router,
            liquidity.tokenA, 
            liquidity.tokenB, 
            liquidity.amountADesired, 
            liquidity.amountBDesired, 
            liquidity.amountAMin,
            liquidity.amountBMin,
            liquidity.to,
            liquidity.deadline
        );
    }

    function addLiquidityWithPermitAndTipAmount(
        IUniRouter router,
        AddLiquidity calldata liquidity,
        Permit calldata permitA,
        Permit calldata permitB
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        if(permitA.amount > 0) {
            _permit(permitA.token, permitA.amount, permitA.deadline, permitA.v, permitA.r, permitA.s);
        }
        if(permitB.amount > 0) {
            _permit(permitB.token, permitB.amount, permitB.deadline, permitB.v, permitB.r, permitB.s);
        }
        _tipAmountETH(msg.value);
        _addLiquidity(
            router,
            liquidity.tokenA, 
            liquidity.tokenB, 
            liquidity.amountADesired, 
            liquidity.amountBDesired, 
            liquidity.amountAMin, 
            liquidity.amountBMin,
            liquidity.to,
            liquidity.deadline
        );
    }

    function addLiquidityETHAndTipAmount(
        IUniRouter router,
        AddLiquidity calldata liquidity,
        uint256 tipAmount
    ) external payable {

        require(tipAmount > 0, "tip amount must be > 0");
        require(msg.value >= liquidity.amountBDesired + tipAmount, "must send ETH to cover tip + liquidity");
        _tipAmountETH(tipAmount);
        _addLiquidityETH(
            router,
            liquidity.tokenA,
            liquidity.amountADesired, 
            liquidity.amountBDesired, 
            liquidity.amountAMin,
            liquidity.amountBMin,
            liquidity.to,
            liquidity.deadline
        );
    }

    function addLiquidityETHWithPermitAndTipAmount(
        IUniRouter router,
        AddLiquidity calldata liquidity,
        Permit calldata permit,
        uint256 tipAmount
    ) external payable {

        require(tipAmount > 0, "tip amount must be > 0");
        require(msg.value >= liquidity.amountBDesired + tipAmount, "must send ETH to cover tip + liquidity");
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _tipAmountETH(tipAmount);
        _addLiquidityETH(
            router,
            liquidity.tokenA,
            liquidity.amountADesired, 
            liquidity.amountBDesired, 
            liquidity.amountAMin,
            liquidity.amountBMin,
            liquidity.to,
            liquidity.deadline
        );
    }

    function removeLiquidityAndTipAmount(
        IUniRouter router,
        RemoveLiquidity calldata liquidity
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _removeLiquidity(
            router,
            liquidity.lpToken,
            liquidity.tokenA, 
            liquidity.tokenB, 
            liquidity.liquidity,
            liquidity.amountAMin,
            liquidity.amountBMin,
            liquidity.to,
            liquidity.deadline
        );
    }

    function removeLiquidityETHAndTipAmount(
        IUniRouter router,
        RemoveLiquidity calldata liquidity
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _removeLiquidityETH(
            router,
            liquidity.lpToken,
            liquidity.tokenA,
            liquidity.liquidity, 
            liquidity.amountAMin,
            liquidity.amountBMin,
            liquidity.to,
            liquidity.deadline
        );
    }

    function removeLiquidityWithPermitAndTipAmount(
        IUniRouter router,
        RemoveLiquidity calldata liquidity,
        Permit calldata permit
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _removeLiquidity(
            router,
            liquidity.lpToken,
            liquidity.tokenA, 
            liquidity.tokenB, 
            liquidity.liquidity,
            liquidity.amountAMin,
            liquidity.amountBMin,
            liquidity.to,
            liquidity.deadline
        );
    }

    function removeLiquidityETHWithPermitAndTipAmount(
        IUniRouter router,
        RemoveLiquidity calldata liquidity,
        Permit calldata permit
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _removeLiquidityETH(
            router,
            liquidity.lpToken,
            liquidity.tokenA,
            liquidity.liquidity, 
            liquidity.amountAMin,
            liquidity.amountBMin,
            liquidity.to,
            liquidity.deadline
        );
    }

    function swapExactTokensForETHAndTipAmount(
        IUniRouter router,
        Trade calldata trade
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _swapExactTokensForETH(router, trade.amountIn, trade.amountOut, trade.path, trade.to, trade.deadline);
    }

    function swapExactTokensForETHWithPermitAndTipAmount(
        IUniRouter router,
        Trade calldata trade,
        Permit calldata permit
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _tipAmountETH(msg.value);
        _swapExactTokensForETH(router, trade.amountIn, trade.amountOut, trade.path, trade.to, trade.deadline);
    }

    function swapExactTokensForETHAndTipPct(
        IUniRouter router,
        Trade calldata trade,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        _swapExactTokensForETH(router, trade.amountIn, trade.amountOut, trade.path, address(this), trade.deadline);
        _tipPctETH(tipPct);
        _transferContractETHBalance(trade.to);
    }

    function swapExactTokensForETHWithPermitAndTipPct(
        IUniRouter router,
        Trade calldata trade,
        Permit calldata permit,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _swapExactTokensForETH(router, trade.amountIn, trade.amountOut, trade.path, address(this), trade.deadline);
        _tipPctETH(tipPct);
        _transferContractETHBalance(trade.to);
    }

    function swapTokensForExactETHAndTipAmount(
        IUniRouter router,
        Trade calldata trade
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _swapTokensForExactETH(router, trade.amountOut, trade.amountIn, trade.path, trade.to, trade.deadline);
    }

    function swapTokensForExactETHWithPermitAndTipAmount(
        IUniRouter router,
        Trade calldata trade,
        Permit calldata permit
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _swapTokensForExactETH(router, trade.amountOut, trade.amountIn, trade.path, trade.to, trade.deadline);
    }

    function swapTokensForExactETHAndTipPct(
        IUniRouter router,
        Trade calldata trade,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        _swapTokensForExactETH(router, trade.amountOut, trade.amountIn, trade.path, address(this), trade.deadline);
        _tipPctETH(tipPct);
        _transferContractETHBalance(trade.to);
    }

    function swapTokensForExactETHWithPermitAndTipPct(
        IUniRouter router,
        Trade calldata trade,
        Permit calldata permit,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _swapTokensForExactETH(router, trade.amountOut, trade.amountIn, trade.path, address(this), trade.deadline);
        _tipPctETH(tipPct);
        _transferContractETHBalance(trade.to);
    }

    function swapExactETHForTokensWithTipAmount(
        IUniRouter router,
        Trade calldata trade,
        uint256 tipAmount
    ) external payable {

        require(tipAmount > 0, "tip amount must be > 0");
        require(msg.value >= tipAmount, "must send ETH to cover tip");
        _tipAmountETH(tipAmount);
        _swapExactETHForTokens(router, trade.amountIn, trade.amountOut, trade.path, trade.to, trade.deadline);
    }

    function swapExactETHForTokensWithTipPct(
        IUniRouter router,
        Trade calldata trade,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        require(msg.value > 0, "must send ETH to cover tip");
        uint256 tipAmount = (msg.value * tipPct) / 1000000;
        _tipAmountETH(tipAmount);
        _swapExactETHForTokens(router, trade.amountIn, trade.amountOut, trade.path, trade.to, trade.deadline);
    }

    function swapETHForExactTokensWithTipAmount(
        IUniRouter router,
        Trade calldata trade,
        uint256 tipAmount
    ) external payable {

        require(tipAmount > 0, "tip amount must be > 0");
        require(msg.value >= tipAmount, "must send ETH to cover tip");
        _tipAmountETH(tipAmount);
        _swapETHForExactTokens(router, trade.amountOut, trade.amountIn, trade.path, trade.to, trade.deadline);
    }

    function swapETHForExactTokensWithTipPct(
        IUniRouter router,
        Trade calldata trade,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        require(msg.value > 0, "must send ETH to cover tip");
        uint256 tipAmount = (msg.value * tipPct) / 1000000;
        _tipAmountETH(tipAmount);
        _swapETHForExactTokens(router, trade.amountOut, trade.amountIn, trade.path, trade.to, trade.deadline);
    }

    function swapExactTokensForTokensWithTipAmount(
        IUniRouter router,
        Trade calldata trade
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _swapExactTokensForTokens(router, trade.amountIn, trade.amountOut, trade.path, trade.to, trade.deadline);
    }

    function swapExactTokensForTokensWithPermitAndTipAmount(
        IUniRouter router,
        Trade calldata trade,
        Permit calldata permit
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _swapExactTokensForTokens(router, trade.amountIn, trade.amountOut, trade.path, trade.to, trade.deadline);
    }

    function swapExactTokensForTokensWithTipPct(
        IUniRouter router,
        Trade calldata trade,
        address[] calldata pathToEth,
        uint256 minEth,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        _swapExactTokensForTokens(router, trade.amountIn, trade.amountOut, trade.path, address(this), trade.deadline);
        IERC20Extended toToken = IERC20Extended(pathToEth[0]);
        uint256 contractTokenBalance = toToken.balanceOf(address(this));
        uint256 tipAmount = (contractTokenBalance * tipPct) / 1000000;
        _tipWithTokens(router, tipAmount, pathToEth, trade.deadline, minEth);
        _transferContractTokenBalance(toToken, trade.to);
    }

    function swapExactTokensForTokensWithPermitAndTipPct(
        IUniRouter router,
        Trade calldata trade,
        Permit calldata permit,
        address[] calldata pathToEth,
        uint256 minEth,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _swapExactTokensForTokens(router, trade.amountIn, trade.amountOut, trade.path, address(this), trade.deadline);
        IERC20Extended toToken = IERC20Extended(pathToEth[0]);
        uint256 contractTokenBalance = toToken.balanceOf(address(this));
        uint256 tipAmount = (contractTokenBalance * tipPct) / 1000000;
        _tipWithTokens(router, tipAmount, pathToEth, trade.deadline, minEth);
        _transferContractTokenBalance(toToken, trade.to);
    }

    function swapTokensForExactTokensWithTipAmount(
        IUniRouter router,
        Trade calldata trade
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _swapTokensForExactTokens(router, trade.amountOut, trade.amountIn, trade.path, trade.to, trade.deadline);
    }

    function swapTokensForExactTokensWithPermitAndTipAmount(
        IUniRouter router,
        Trade calldata trade,
        Permit calldata permit
    ) external payable {

        require(msg.value > 0, "tip amount must be > 0");
        _tipAmountETH(msg.value);
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _swapTokensForExactTokens(router, trade.amountOut, trade.amountIn, trade.path, trade.to, trade.deadline);
    }

    function swapTokensForExactTokensWithTipPct(
        IUniRouter router,
        Trade calldata trade,
        address[] calldata pathToEth,
        uint256 minEth,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        _swapTokensForExactTokens(router, trade.amountOut, trade.amountIn, trade.path, address(this), trade.deadline);
        IERC20Extended toToken = IERC20Extended(pathToEth[0]);
        uint256 contractTokenBalance = toToken.balanceOf(address(this));
        uint256 tipAmount = (contractTokenBalance * tipPct) / 1000000;
        _tipWithTokens(router, tipAmount, pathToEth, trade.deadline, minEth);
        _transferContractTokenBalance(toToken, trade.to);
    }

    function swapTokensForExactTokensWithPermitAndTipPct(
        IUniRouter router,
        Trade calldata trade,
        Permit calldata permit,
        address[] calldata pathToEth,
        uint256 minEth,
        uint32 tipPct
    ) external payable {

        require(tipPct > 0, "tipPct must be > 0");
        _permit(permit.token, permit.amount, permit.deadline, permit.v, permit.r, permit.s);
        _swapTokensForExactTokens(router, trade.amountOut, trade.amountIn, trade.path, address(this), trade.deadline);
        IERC20Extended toToken = IERC20Extended(pathToEth[0]);
        uint256 contractTokenBalance = toToken.balanceOf(address(this));
        uint256 tipAmount = (contractTokenBalance * tipPct) / 1000000;
        _tipWithTokens(router, tipAmount, pathToEth, trade.deadline, minEth);
        _transferContractTokenBalance(toToken, trade.to);
    }

    function _addLiquidity(
        IUniRouter router,
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) internal {

        IERC20Extended fromToken = IERC20Extended(tokenA);
        IERC20Extended toToken = IERC20Extended(tokenB);
        fromToken.safeTransferFrom(msg.sender, address(this), amountADesired);
        fromToken.safeIncreaseAllowance(address(router), amountADesired);
        toToken.safeTransferFrom(msg.sender, address(this), amountBDesired);
        toToken.safeIncreaseAllowance(address(router), amountBDesired);
        (uint256 amountA, uint256 amountB, ) = router.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);
        if(amountADesired > amountA) {
            fromToken.safeTransfer(msg.sender, fromToken.balanceOf(address(this)));
        }
        if(amountBDesired > amountB) {
            toToken.safeTransfer(msg.sender, toToken.balanceOf(address(this)));
        }
    }

    function _addLiquidityETH(
        IUniRouter router,
        address token,
        uint amountTokenDesired,
        uint amountETHDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) internal {

        IERC20Extended fromToken = IERC20Extended(token);
        fromToken.safeTransferFrom(msg.sender, address(this), amountTokenDesired);
        fromToken.safeIncreaseAllowance(address(router), amountTokenDesired);
        (uint256 amountToken, uint256 amountETH, ) = router.addLiquidityETH{value: amountETHDesired}(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);
        if(amountTokenDesired > amountToken) {
            fromToken.safeTransfer(msg.sender, amountTokenDesired - amountToken);
        }
        if(amountETHDesired > amountETH) {
            (bool success, ) = msg.sender.call{value: amountETHDesired - amountETH}("");
            require(success);
        }
    }

    function _removeLiquidity(
        IUniRouter router,
        IERC20Extended lpToken,
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) internal {

        lpToken.safeTransferFrom(msg.sender, address(this), liquidity);
        lpToken.safeIncreaseAllowance(address(router), liquidity);
        (uint256 amountA, uint256 amountB) = router.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
        IERC20Extended fromToken = IERC20Extended(tokenA);
        IERC20Extended toToken = IERC20Extended(tokenB);
        fromToken.safeTransfer(msg.sender, amountA);
        toToken.safeTransfer(msg.sender, amountB);
    }

    function _removeLiquidityETH(
        IUniRouter router,
        IERC20Extended lpToken,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) internal {

        lpToken.safeTransferFrom(msg.sender, address(this), liquidity);
        lpToken.safeIncreaseAllowance(address(router), liquidity);
        (uint256 amountToken, uint256 amountETH) = router.removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
        IERC20Extended fromToken = IERC20Extended(token);
        fromToken.safeTransfer(msg.sender, amountToken);
        (bool success, ) = msg.sender.call{value: amountETH}("");
        require(success);
    }

    function _swapExactETHForTokens(
        IUniRouter router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) internal {

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(amountOutMin, path, to, deadline);
    }

    function _swapETHForExactTokens(
        IUniRouter router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) internal {

        router.swapETHForExactTokens{value: amountInMax}(amountOut, path, to, deadline);
    }

    function _swapTokensForExactETH(
        IUniRouter router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) internal {

        IERC20Extended fromToken = IERC20Extended(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountInMax);
        fromToken.safeIncreaseAllowance(address(router), amountInMax);
        router.swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);
    }

    function _swapExactTokensForETH(
        IUniRouter router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) internal {

        IERC20Extended fromToken = IERC20Extended(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        fromToken.safeIncreaseAllowance(address(router), amountIn);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function _swapExactTokensForTokens(
        IUniRouter router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) internal {

        IERC20Extended fromToken = IERC20Extended(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        fromToken.safeIncreaseAllowance(address(router), amountIn);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function _swapTokensForExactTokens(
        IUniRouter router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) internal {

        IERC20Extended fromToken = IERC20Extended(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountInMax);
        fromToken.safeIncreaseAllowance(address(router), amountInMax);
        router.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
    }

    function _tipPctETH(uint32 tipPct) internal {

        uint256 contractBalance = address(this).balance;
        uint256 tipAmount = (contractBalance * tipPct) / 1000000;
        tipJar.tip{value: tipAmount}();
    }

    function _tipAmountETH(uint256 tipAmount) internal {

        tipJar.tip{value: tipAmount}();
    }

    function _transferContractETHBalance(address payable to) internal {

        (bool success, ) = to.call{value: address(this).balance}("");
        require(success);
    }

    function _transferContractTokenBalance(IERC20Extended token, address payable to) internal {

        token.safeTransfer(to, token.balanceOf(address(this)));
    }

    function _tipWithTokens(
        IUniRouter router,
        uint amountIn,
        address[] memory path,
        uint256 deadline,
        uint256 minEth
    ) internal {

        IERC20Extended(path[0]).safeIncreaseAllowance(address(router), amountIn);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, minEth, path, address(this), deadline);
        tipJar.tip{value: address(this).balance}();
    }

    function _permit(
        IERC20Extended token, 
        uint amount,
        uint deadline,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) internal {

        token.permit(msg.sender, address(this), amount, deadline, v, r, s);
    }
}