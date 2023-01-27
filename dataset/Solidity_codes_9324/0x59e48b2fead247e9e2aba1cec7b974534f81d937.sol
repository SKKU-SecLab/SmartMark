

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



pragma solidity 0.6.12;


interface IDMMFactory {

    function createPool(
        IERC20 tokenA,
        IERC20 tokenB,
        uint32 ampBps
    ) external returns (address pool);


    function setFeeConfiguration(address feeTo, uint16 governmentFeeBps) external;


    function setFeeToSetter(address) external;


    function getFeeConfiguration() external view returns (address feeTo, uint16 governmentFeeBps);


    function feeToSetter() external view returns (address);


    function allPools(uint256) external view returns (address pool);


    function allPoolsLength() external view returns (uint256);


    function getUnamplifiedPool(IERC20 token0, IERC20 token1) external view returns (address);


    function getPools(IERC20 token0, IERC20 token1)
        external
        view
        returns (address[] memory _tokenPools);


    function isPool(
        IERC20 token0,
        IERC20 token1,
        address pool
    ) external view returns (bool);

}


pragma solidity 0.6.12;


interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256) external;

}



pragma solidity 0.6.12;


interface IDMMExchangeRouter {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function getAmountsOut(
        uint256 amountIn,
        address[] calldata poolsPath,
        IERC20[] calldata path
    ) external view returns (uint256[] memory amounts);


    function getAmountsIn(
        uint256 amountOut,
        address[] calldata poolsPath,
        IERC20[] calldata path
    ) external view returns (uint256[] memory amounts);

}



pragma solidity 0.6.12;


interface IDMMLiquidityRouter {

    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        address pool,
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


    function addLiquidityNewPool(
        IERC20 tokenA,
        IERC20 tokenB,
        uint32 ampBps,
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


    function addLiquidityNewPoolETH(
        IERC20 token,
        uint32 ampBps,
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


    function addLiquidityETH(
        IERC20 token,
        address pool,
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
        IERC20 tokenA,
        IERC20 tokenB,
        address pool,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityWithPermit(
        IERC20 tokenA,
        IERC20 tokenB,
        address pool,
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


    function removeLiquidityETH(
        IERC20 token,
        address pool,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityETHWithPermit(
        IERC20 token,
        address pool,
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


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

}



pragma solidity 0.6.12;





interface IDMMRouter01 is IDMMExchangeRouter, IDMMLiquidityRouter {

    function factory() external pure returns (address);


    function weth() external pure returns (IWETH);

}



pragma solidity 0.6.12;


interface IDMMRouter02 is IDMMRouter01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        IERC20 token,
        address pool,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        IERC20 token,
        address pool,
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
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external;

}



pragma solidity 0.6.12;


interface IERC20Permit is IERC20 {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}



pragma solidity 0.6.12;



interface IDMMPool {

    function mint(address to) external returns (uint256 liquidity);


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function sync() external;


    function getReserves() external view returns (uint112 reserve0, uint112 reserve1);


    function getTradeInfo()
        external
        view
        returns (
            uint112 _vReserve0,
            uint112 _vReserve1,
            uint112 reserve0,
            uint112 reserve1,
            uint256 feeInPrecision
        );


    function token0() external view returns (IERC20);


    function token1() external view returns (IERC20);


    function ampBps() external view returns (uint32);


    function factory() external view returns (IDMMFactory);


    function kLast() external view returns (uint256);

}



pragma solidity 0.6.12;




library DMMLibrary {

    using SafeMath for uint256;

    uint256 public constant PRECISION = 1e18;

    function sortTokens(IERC20 tokenA, IERC20 tokenB)
        internal
        pure
        returns (IERC20 token0, IERC20 token1)
    {

        require(tokenA != tokenB, "DMMLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(address(token0) != address(0), "DMMLibrary: ZERO_ADDRESS");
    }

    function getTradeInfo(
        address pool,
        IERC20 tokenA,
        IERC20 tokenB
    )
        internal
        view
        returns (
            uint256 reserveA,
            uint256 reserveB,
            uint256 vReserveA,
            uint256 vReserveB,
            uint256 feeInPrecision
        )
    {

        (IERC20 token0, ) = sortTokens(tokenA, tokenB);
        uint256 reserve0;
        uint256 reserve1;
        uint256 vReserve0;
        uint256 vReserve1;
        (reserve0, reserve1, vReserve0, vReserve1, feeInPrecision) = IDMMPool(pool).getTradeInfo();
        (reserveA, reserveB, vReserveA, vReserveB) = tokenA == token0
            ? (reserve0, reserve1, vReserve0, vReserve1)
            : (reserve1, reserve0, vReserve1, vReserve0);
    }

    function getReserves(
        address pool,
        IERC20 tokenA,
        IERC20 tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        (IERC20 token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1) = IDMMPool(pool).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {

        require(amountA > 0, "DMMLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "DMMLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 vReserveIn,
        uint256 vReserveOut,
        uint256 feeInPrecision
    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, "DMMLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "DMMLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(PRECISION.sub(feeInPrecision)).div(PRECISION);
        uint256 numerator = amountInWithFee.mul(vReserveOut);
        uint256 denominator = vReserveIn.add(amountInWithFee);
        amountOut = numerator.div(denominator);
        require(reserveOut > amountOut, "DMMLibrary: INSUFFICIENT_LIQUIDITY");
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 vReserveIn,
        uint256 vReserveOut,
        uint256 feeInPrecision
    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, "DMMLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > amountOut, "DMMLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = vReserveIn.mul(amountOut);
        uint256 denominator = vReserveOut.sub(amountOut);
        amountIn = numerator.div(denominator).add(1);
        numerator = amountIn.mul(PRECISION);
        denominator = PRECISION.sub(feeInPrecision);
        amountIn = numerator.add(denominator - 1).div(denominator);
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] memory poolsPath,
        IERC20[] memory path
    ) internal view returns (uint256[] memory amounts) {

        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (
                uint256 reserveIn,
                uint256 reserveOut,
                uint256 vReserveIn,
                uint256 vReserveOut,
                uint256 feeInPrecision
            ) = getTradeInfo(poolsPath[i], path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(
                amounts[i],
                reserveIn,
                reserveOut,
                vReserveIn,
                vReserveOut,
                feeInPrecision
            );
        }
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] memory poolsPath,
        IERC20[] memory path
    ) internal view returns (uint256[] memory amounts) {

        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (
                uint256 reserveIn,
                uint256 reserveOut,
                uint256 vReserveIn,
                uint256 vReserveOut,
                uint256 feeInPrecision
            ) = getTradeInfo(poolsPath[i - 1], path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(
                amounts[i],
                reserveIn,
                reserveOut,
                vReserveIn,
                vReserveOut,
                feeInPrecision
            );
        }
    }
}



pragma solidity 0.6.12;










contract DMMRouter02 is IDMMRouter02 {

    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;
    using SafeMath for uint256;

    uint256 internal constant BPS = 10000;

    address public immutable override factory;
    IWETH public immutable override weth;

    modifier ensure(uint256 deadline) {

        require(deadline >= block.timestamp, "DMMRouter: EXPIRED");
        _;
    }

    constructor(address _factory, IWETH _weth) public {
        factory = _factory;
        weth = _weth;
    }

    receive() external payable {
        assert(msg.sender == address(weth)); // only accept ETH via fallback from the WETH contract
    }

    function _addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        address pool,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual view returns (uint256 amountA, uint256 amountB) {

        (uint256 reserveA, uint256 reserveB) = DMMLibrary.getReserves(pool, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = DMMLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "DMMRouter: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = DMMLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "DMMRouter: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        address pool,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {

        verifyPoolAddress(tokenA, tokenB, pool);
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            pool,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        SafeERC20.safeTransferFrom(tokenA, msg.sender, pool, amountA);
        SafeERC20.safeTransferFrom(tokenB, msg.sender, pool, amountB);
        liquidity = IDMMPool(pool).mint(to);
    }

    function addLiquidityETH(
        IERC20 token,
        address pool,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        public
        override
        payable
        ensure(deadline)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {

        verifyPoolAddress(token, weth, pool);
        (amountToken, amountETH) = _addLiquidity(
            token,
            weth,
            pool,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        token.safeTransferFrom(msg.sender, pool, amountToken);
        weth.deposit{value: amountETH}();
        weth.safeTransfer(pool, amountETH);
        liquidity = IDMMPool(pool).mint(to);
        if (msg.value > amountETH) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
        }
    }

    function addLiquidityNewPool(
        IERC20 tokenA,
        IERC20 tokenB,
        uint32 ampBps,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        override
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {

        address pool;
        if (ampBps == BPS) {
            pool = IDMMFactory(factory).getUnamplifiedPool(tokenA, tokenB);
        }
        if (pool == address(0)) {
            pool = IDMMFactory(factory).createPool(tokenA, tokenB, ampBps);
        }
        (amountA, amountB, liquidity) = addLiquidity(
            tokenA,
            tokenB,
            pool,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    function addLiquidityNewPoolETH(
        IERC20 token,
        uint32 ampBps,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        override
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {

        address pool;
        if (ampBps == BPS) {
            pool = IDMMFactory(factory).getUnamplifiedPool(token, weth);
        }
        if (pool == address(0)) {
            pool = IDMMFactory(factory).createPool(token, weth, ampBps);
        }
        (amountToken, amountETH, liquidity) = addLiquidityETH(
            token,
            pool,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    function removeLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        address pool,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) public override ensure(deadline) returns (uint256 amountA, uint256 amountB) {

        verifyPoolAddress(tokenA, tokenB, pool);
        IERC20(pool).safeTransferFrom(msg.sender, pool, liquidity); // send liquidity to pool
        (uint256 amount0, uint256 amount1) = IDMMPool(pool).burn(to);
        (IERC20 token0, ) = DMMLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "DMMRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "DMMRouter: INSUFFICIENT_B_AMOUNT");
    }

    function removeLiquidityETH(
        IERC20 token,
        address pool,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public override ensure(deadline) returns (uint256 amountToken, uint256 amountETH) {

        (amountToken, amountETH) = removeLiquidity(
            token,
            weth,
            pool,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        token.safeTransfer(to, amountToken);
        IWETH(weth).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityWithPermit(
        IERC20 tokenA,
        IERC20 tokenB,
        address pool,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountA, uint256 amountB) {

        uint256 value = approveMax ? uint256(-1) : liquidity;
        IERC20Permit(pool).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            pool,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    function removeLiquidityETHWithPermit(
        IERC20 token,
        address pool,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint256 amountToken, uint256 amountETH) {

        uint256 value = approveMax ? uint256(-1) : liquidity;
        IERC20Permit(pool).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(
            token,
            pool,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        IERC20 token,
        address pool,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public override ensure(deadline) returns (uint256 amountETH) {

        (, amountETH) = removeLiquidity(
            token,
            weth,
            pool,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        token.safeTransfer(to, IERC20(token).balanceOf(address(this)));
        IWETH(weth).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        IERC20 token,
        address pool,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint256 amountETH) {

        uint256 value = approveMax ? uint256(-1) : liquidity;
        IERC20Permit(pool).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            pool,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    function _swap(
        uint256[] memory amounts,
        address[] memory poolsPath,
        IERC20[] memory path,
        address _to
    ) private {

        for (uint256 i; i < path.length - 1; i++) {
            (IERC20 input, IERC20 output) = (path[i], path[i + 1]);
            (IERC20 token0, ) = DMMLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? poolsPath[i + 1] : _to;
            IDMMPool(poolsPath[i]).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory poolsPath,
        IERC20[] memory path,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256[] memory amounts) {

        verifyPoolsPathSwap(poolsPath, path);
        amounts = DMMLibrary.getAmountsOut(amountIn, poolsPath, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "DMMRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IERC20(path[0]).safeTransferFrom(msg.sender, poolsPath[0], amounts[0]);
        _swap(amounts, poolsPath, path, to);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory poolsPath,
        IERC20[] memory path,
        address to,
        uint256 deadline
    ) public override ensure(deadline) returns (uint256[] memory amounts) {

        verifyPoolsPathSwap(poolsPath, path);
        amounts = DMMLibrary.getAmountsIn(amountOut, poolsPath, path);
        require(amounts[0] <= amountInMax, "DMMRouter: EXCESSIVE_INPUT_AMOUNT");
        path[0].safeTransferFrom(msg.sender, poolsPath[0], amounts[0]);
        _swap(amounts, poolsPath, path, to);
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external override payable ensure(deadline) returns (uint256[] memory amounts) {

        require(path[0] == weth, "DMMRouter: INVALID_PATH");
        verifyPoolsPathSwap(poolsPath, path);
        amounts = DMMLibrary.getAmountsOut(msg.value, poolsPath, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "DMMRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWETH(weth).deposit{value: amounts[0]}();
        weth.safeTransfer(poolsPath[0], amounts[0]);
        _swap(amounts, poolsPath, path, to);
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {

        require(path[path.length - 1] == weth, "DMMRouter: INVALID_PATH");
        verifyPoolsPathSwap(poolsPath, path);
        amounts = DMMLibrary.getAmountsIn(amountOut, poolsPath, path);
        require(amounts[0] <= amountInMax, "DMMRouter: EXCESSIVE_INPUT_AMOUNT");
        path[0].safeTransferFrom(msg.sender, poolsPath[0], amounts[0]);
        _swap(amounts, poolsPath, path, address(this));
        IWETH(weth).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {

        require(path[path.length - 1] == weth, "DMMRouter: INVALID_PATH");
        verifyPoolsPathSwap(poolsPath, path);
        amounts = DMMLibrary.getAmountsOut(amountIn, poolsPath, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "DMMRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        path[0].safeTransferFrom(msg.sender, poolsPath[0], amounts[0]);
        _swap(amounts, poolsPath, path, address(this));
        IWETH(weth).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external override payable ensure(deadline) returns (uint256[] memory amounts) {

        require(path[0] == weth, "DMMRouter: INVALID_PATH");
        verifyPoolsPathSwap(poolsPath, path);
        amounts = DMMLibrary.getAmountsIn(amountOut, poolsPath, path);
        require(amounts[0] <= msg.value, "DMMRouter: EXCESSIVE_INPUT_AMOUNT");
        IWETH(weth).deposit{value: amounts[0]}();
        weth.safeTransfer(poolsPath[0], amounts[0]);
        _swap(amounts, poolsPath, path, to);
        if (msg.value > amounts[0]) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
        }
    }

    function _swapSupportingFeeOnTransferTokens(
        address[] memory poolsPath,
        IERC20[] memory path,
        address _to
    ) internal {

        verifyPoolsPathSwap(poolsPath, path);
        for (uint256 i; i < path.length - 1; i++) {
            (IERC20 input, IERC20 output) = (path[i], path[i + 1]);
            (IERC20 token0, ) = DMMLibrary.sortTokens(input, output);
            IDMMPool pool = IDMMPool(poolsPath[i]);
            uint256 amountOutput;
            {
                (
                    uint256 reserveIn,
                    uint256 reserveOut,
                    uint256 vReserveIn,
                    uint256 vReserveOut,
                    uint256 feeInPrecision
                ) = DMMLibrary.getTradeInfo(poolsPath[i], input, output);
                uint256 amountInput = IERC20(input).balanceOf(address(pool)).sub(reserveIn);
                amountOutput = DMMLibrary.getAmountOut(
                    amountInput,
                    reserveIn,
                    reserveOut,
                    vReserveIn,
                    vReserveOut,
                    feeInPrecision
                );
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? poolsPath[i + 1] : _to;
            pool.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory poolsPath,
        IERC20[] memory path,
        address to,
        uint256 deadline
    ) public override ensure(deadline) {

        path[0].safeTransferFrom(msg.sender, poolsPath[0], amountIn);
        uint256 balanceBefore = path[path.length - 1].balanceOf(to);
        _swapSupportingFeeOnTransferTokens(poolsPath, path, to);
        uint256 balanceAfter = path[path.length - 1].balanceOf(to);
        require(
            balanceAfter >= balanceBefore.add(amountOutMin),
            "DMMRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external override payable ensure(deadline) {

        require(path[0] == weth, "DMMRouter: INVALID_PATH");
        uint256 amountIn = msg.value;
        IWETH(weth).deposit{value: amountIn}();
        weth.safeTransfer(poolsPath[0], amountIn);
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(poolsPath, path, to);
        require(
            path[path.length - 1].balanceOf(to).sub(balanceBefore) >= amountOutMin,
            "DMMRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata poolsPath,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) {

        require(path[path.length - 1] == weth, "DMMRouter: INVALID_PATH");
        path[0].safeTransferFrom(msg.sender, poolsPath[0], amountIn);
        _swapSupportingFeeOnTransferTokens(poolsPath, path, address(this));
        uint256 amountOut = IWETH(weth).balanceOf(address(this));
        require(amountOut >= amountOutMin, "DMMRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(weth).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external override pure returns (uint256 amountB) {

        return DMMLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata poolsPath,
        IERC20[] calldata path
    ) external override view returns (uint256[] memory amounts) {

        verifyPoolsPathSwap(poolsPath, path);
        return DMMLibrary.getAmountsOut(amountIn, poolsPath, path);
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata poolsPath,
        IERC20[] calldata path
    ) external override view returns (uint256[] memory amounts) {

        verifyPoolsPathSwap(poolsPath, path);
        return DMMLibrary.getAmountsIn(amountOut, poolsPath, path);
    }

    function verifyPoolsPathSwap(address[] memory poolsPath, IERC20[] memory path) internal view {

        require(path.length >= 2, "DMMRouter: INVALID_PATH");
        require(poolsPath.length == path.length - 1, "DMMRouter: INVALID_POOLS_PATH");
        for (uint256 i = 0; i < poolsPath.length; i++) {
            verifyPoolAddress(path[i], path[i + 1], poolsPath[i]);
        }
    }

    function verifyPoolAddress(
        IERC20 tokenA,
        IERC20 tokenB,
        address pool
    ) internal view {

        require(IDMMFactory(factory).isPool(tokenA, tokenB, pool), "DMMRouter: INVALID_POOL");
    }
}