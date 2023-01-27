
pragma solidity >=0.8.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}

pragma solidity >=0.8.0;

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

pragma solidity >=0.8.0;


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

}

pragma solidity >=0.8.0;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

pragma solidity >=0.8.0;



library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        uint160 a = uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
        pair = address(a);
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
}

pragma solidity 0.8.0;

library VeloxTransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        require(token != address(0), 'VeloxTransferHelper: ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        require(token != address(0), 'VeloxTransferHelper: ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        require(token != address(0), 'VeloxTransferHelper: TOKEN_ZERO_ADDRESS');
        require(from != address(0), 'VeloxTransferHelper: FROM_ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');
        
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

pragma solidity >=0.8.0;

abstract contract IERC20NONStandard {

    uint256 public totalSupply;
    function balanceOf(address owner) virtual public view returns (uint256 balance);

    function transfer(address to, uint256 value) virtual public;

    function transferFrom(address from, address to, uint256 value) virtual public;


    function approve(address spender, uint256 value) virtual public returns (bool success);
    function allowance(address owner, address spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.8.0;

contract SwapExceptions {


    event SwapException(uint exception, uint info, uint detail);

    enum Exception {
        NO_ERROR,
        GENERIC_ERROR,
        UNAUTHORIZED,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW,
        DIVISION_BY_ZERO,
        BAD_INPUT,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_TRANSFER_FAILED,
        MARKET_NOT_SUPPORTED,
        SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_RATE_CALCULATION_FAILED,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_OUT_FAILED,
        INSUFFICIENT_LIQUIDITY,
        INSUFFICIENT_BALANCE,
        INVALID_COLLATERAL_RATIO,
        MISSING_ASSET_PRICE,
        EQUITY_INSUFFICIENT_BALANCE,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        ASSET_NOT_PRICED,
        INVALID_LIQUIDATION_DISCOUNT,
        INVALID_COMBINED_RISK_PARAMETERS,
        ZERO_ORACLE_ADDRESS,
        CONTRACT_PAUSED
    }

    enum Reason {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        BORROW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        BORROW_ACCOUNT_SHORTFALL_PRESENT,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_AMOUNT_LIQUIDITY_SHORTFALL,
        BORROW_AMOUNT_VALUE_CALCULATION_FAILED,
        BORROW_CONTRACT_PAUSED,
        BORROW_MARKET_NOT_SUPPORTED,
        BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        BORROW_ORIGINATION_FEE_CALCULATION_FAILED,
        BORROW_TRANSFER_OUT_FAILED,
        EQUITY_WITHDRAWAL_AMOUNT_VALIDATION,
        EQUITY_WITHDRAWAL_CALCULATE_EQUITY,
        EQUITY_WITHDRAWAL_MODEL_OWNER_CHECK,
        EQUITY_WITHDRAWAL_TRANSFER_OUT_FAILED,
        LIQUIDATE_ACCUMULATED_BORROW_BALANCE_CALCULATION_FAILED,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_AMOUNT_SEIZE_CALCULATION_FAILED,
        LIQUIDATE_BORROW_DENOMINATED_COLLATERAL_CALCULATION_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_TOO_HIGH,
        LIQUIDATE_CONTRACT_PAUSED,
        LIQUIDATE_DISCOUNTED_REPAY_TO_EVEN_AMOUNT_CALCULATION_FAILED,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_BORROW_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_SUPPLY_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_BORROW_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_CASH_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_FETCH_ASSET_PRICE_FAILED,
        LIQUIDATE_TRANSFER_IN_FAILED,
        LIQUIDATE_TRANSFER_IN_NOT_POSSIBLE,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_CONTRACT_PAUSED,
        REPAY_BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_ASSET_PRICE_CHECK_ORACLE,
        SET_MARKET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_ORACLE_OWNER_CHECK,
        SET_ORIGINATION_FEE_OWNER_CHECK,
        SET_PAUSED_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RISK_PARAMETERS_OWNER_CHECK,
        SET_RISK_PARAMETERS_VALIDATION,
        SUPPLY_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        SUPPLY_CONTRACT_PAUSED,
        SUPPLY_MARKET_NOT_SUPPORTED,
        SUPPLY_NEW_BORROW_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_BORROW_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_CASH_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        SUPPLY_TRANSFER_IN_FAILED,
        SUPPLY_TRANSFER_IN_NOT_POSSIBLE,
        SUPPORT_MARKET_FETCH_PRICE_FAILED,
        SUPPORT_MARKET_OWNER_CHECK,
        SUPPORT_MARKET_PRICE_CHECK,
        SUSPEND_MARKET_OWNER_CHECK,
        WITHDRAW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        WITHDRAW_ACCOUNT_SHORTFALL_PRESENT,
        WITHDRAW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        WITHDRAW_AMOUNT_LIQUIDITY_SHORTFALL,
        WITHDRAW_AMOUNT_VALUE_CALCULATION_FAILED,
        WITHDRAW_CAPACITY_CALCULATION_FAILED,
        WITHDRAW_CONTRACT_PAUSED,
        WITHDRAW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_BORROW_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        WITHDRAW_TRANSFER_OUT_FAILED,
        WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE
    }

    function raiseException(Exception exception, Reason reason) internal returns (uint) {

        emit SwapException(uint(exception), uint(reason), 0);
        return uint(exception);
    }

    function raiseGenericException(Reason reason, uint genericException) internal returns (uint) {

        emit SwapException(uint(Exception.GENERIC_ERROR), uint(reason), genericException);
        return uint(Exception.GENERIC_ERROR);
    }

}

pragma solidity 0.8.0;




contract Swappable is SwapExceptions {

    function checkTransferIn(address asset, address from, uint amount) internal view returns (Exception) {


        IERC20 token = IERC20(asset);

        if (token.allowance(from, address(this)) < amount) {
            return Exception.TOKEN_INSUFFICIENT_ALLOWANCE;
        }

        if (token.balanceOf(from) < amount) {
            return Exception.TOKEN_INSUFFICIENT_BALANCE;
        }

        return Exception.NO_ERROR;
    }

    function doTransferIn(address asset, address from, uint amount) internal returns (Exception) {

        IERC20NONStandard token = IERC20NONStandard(asset);
        bool result;
        require(token.allowance(from, address(this)) >= amount, 'Not enough allowance from client');
        token.transferFrom(from, address(this), amount);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        if (!result) {
            return Exception.TOKEN_TRANSFER_FAILED;
        }

        return Exception.NO_ERROR;
    }

    function getCash(address asset) internal view returns (uint) {

        IERC20 token = IERC20(asset);
        return token.balanceOf(address(this));
    }

    function getBalanceOf(address asset, address from) internal view returns (uint) {

        IERC20 token = IERC20(asset);
        return token.balanceOf(from);
    }

    function doTransferOut(address asset, address to, uint amount) internal returns (Exception) {

        IERC20NONStandard token = IERC20NONStandard(asset);
        bool result;
        token.transfer(to, amount);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        if (!result) {
            return Exception.TOKEN_TRANSFER_OUT_FAILED;
        }

        return Exception.NO_ERROR;
    }
}

pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}

pragma solidity >=0.8.0;

interface IVeloxSwap {


    function withdrawToken(address token, uint256 amount) external;

    
    function withdrawETH(uint256 amount) external;


    function sellExactTokensForTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline) external returns (uint256 amountOut);


    function sellExactTokensForTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost) external returns (uint256 amountOut);


    function sellTokensForExactTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 maxTokenInAmount,
        uint256 tokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline) external;


    function sellTokensForExactTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 maxTokenInAmount,
        uint256 tokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost) external;


    function fundGasCost(address seller, uint256 wethAmount) external;


}

pragma solidity >=0.8.0;

abstract contract BackingStore {
    address public MAIN_CONTRACT;
    address public UNISWAP_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public ADMIN_ADDRESS;
}

pragma solidity 0.8.0;












contract VeloxSwapV2 is BackingStore, Ownable, Swappable, IVeloxSwap {


    modifier onlyAdmin() {

        require(ADMIN_ADDRESS == msg.sender, "VELOXSWAP: NOT_ADMIN");
        _;
    }

    struct SwapInput {
        address seller;
        address tokenInAddress;
        address tokenOutAddress;
        uint256 tokenInAmount;
        uint256 tokenOutAmount;
        uint16 feeFactor;
        bool takeFeeFromInput;
        uint256 deadline;
    }

    uint constant FEE_SCALE = 10000;
    uint constant GAS_FUNDING_ESTIMATED_GAS = 26233;

    IUniswapV2Router02 public immutable router;

    constructor() {
        router = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }

    event ValueSwapped(address indexed seller, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
    event GasFunded(address indexed seller, uint256 gasCost);

    function withdrawToken(address token, uint256 amount) onlyOwner override external {

        VeloxTransferHelper.safeTransfer(token, msg.sender, amount);
    }

    function withdrawETH(uint256 amount) onlyOwner override external {

        VeloxTransferHelper.safeTransferETH(msg.sender, amount);
    }

    function fundGasCost(address seller, uint256 wethAmount) onlyAdmin override public {

        VeloxTransferHelper.safeTransferFrom(router.WETH(), seller, ADMIN_ADDRESS, wethAmount);
        
        emit GasFunded(seller, wethAmount);
    }

    function sellExactTokensForTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost
    ) override onlyAdmin public returns (uint256 amountOut) {

        uint256 initialGas = gasleft();

        SwapInput memory input = SwapInput({ 
            seller: seller, tokenInAddress: tokenInAddress,
            tokenOutAddress: tokenOutAddress,
            tokenInAmount: tokenInAmount,
            tokenOutAmount: minTokenOutAmount,
            feeFactor: feeFactor,
            takeFeeFromInput: takeFeeFromInput,
            deadline: deadline });
        
        amountOut = swapTokens(input, true);
        
        uint256 gasCost = (initialGas - gasleft() + estimatedGasFundingCost) * tx.gasprice;

        fundGasCost(seller, gasCost);
    }

    function sellExactTokensForTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline
    ) override onlyAdmin public returns (uint256 amountOut) {

        amountOut = sellExactTokensForTokens(seller, tokenInAddress, tokenOutAddress, tokenInAmount, minTokenOutAmount, feeFactor, takeFeeFromInput, deadline, GAS_FUNDING_ESTIMATED_GAS);
    }

    function sellTokensForExactTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 maxTokenInAmount,
        uint256 tokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost) override onlyAdmin public {


        uint256 initialGas = gasleft();

        SwapInput memory input = SwapInput({ 
            seller: seller, tokenInAddress: tokenInAddress,
            tokenOutAddress: tokenOutAddress,
            tokenInAmount: maxTokenInAmount,
            tokenOutAmount: tokenOutAmount,
            feeFactor: feeFactor,
            takeFeeFromInput: takeFeeFromInput,
            deadline: deadline });
        
        swapTokens(input, false);
        
        uint256 gasCost = (initialGas - gasleft() + estimatedGasFundingCost) * tx.gasprice;

        fundGasCost(seller, gasCost);
    }

    function sellTokensForExactTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 maxTokenInAmount,
        uint256 tokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline) override onlyAdmin public {

        sellTokensForExactTokens(seller, tokenInAddress, tokenOutAddress, maxTokenInAmount, tokenOutAmount, feeFactor, takeFeeFromInput, deadline, GAS_FUNDING_ESTIMATED_GAS);
    }
    
    function swapTokens(SwapInput memory input, bool exactIn) public returns (uint256 amountOut) {

        uint256 amountInForSwap;
        uint256 amountOutForSwap;
        address swapTargetAddress;

        (amountInForSwap, amountOutForSwap, swapTargetAddress) 
            = prepareSwap(input);

        doSwap(input.tokenInAddress, input.tokenOutAddress, amountInForSwap, amountOutForSwap, swapTargetAddress, input.deadline, exactIn);

        amountOut = amountOutForSwap;

        if (!input.takeFeeFromInput) {
            amountOut = takeOutputFee(amountOutForSwap, input.feeFactor, input.tokenOutAddress, input.seller);
        }

        emit ValueSwapped(input.seller, input.tokenInAddress, input.tokenOutAddress, input.tokenInAmount, amountOut);
    }

    function prepareSwap(SwapInput memory input) private returns (uint256 amountInForSwap, uint256 amountOurForSwap, address targetAddress) {


        validateInput(input.seller, input.tokenInAddress, input.tokenOutAddress, input.tokenInAmount, input.tokenOutAmount, input.feeFactor, input.deadline);

        Exception exception = doTransferIn(input.tokenInAddress, input.seller, input.tokenInAmount);
        require(exception == Exception.NO_ERROR, 'VELOXSWAP: ALLOWANCE_TOO_LOW');

        checkLiquidity(input.tokenInAddress, input.tokenOutAddress, input.tokenOutAmount);

        (amountInForSwap, amountOurForSwap, targetAddress) = adjustInputBasedOnFee(input.takeFeeFromInput, input.feeFactor, input.tokenInAmount, input.tokenOutAmount, input.seller);
    }

    function validateInput(address seller, address tokenInAddress, address tokenOutAddress, uint256 tokenInAmount, uint256 tokenOutAmount, uint16 feeFactor, uint256 deadline) private view {

        require(deadline >= block.timestamp, 'VELOXSWAP: EXPIRED');
        require(feeFactor <= 30, 'VELOXSWAP: FEE_OVER_03_PERCENT');
        require(address(router) != address(0), 'VELOXSWAP: ROUTER_NOT_INSTANTIATED');

        address tokenWETH = router.WETH();
        require(tokenWETH != address(0), 'VELOXSWAP: WETH_ADDRESS_NOT_FOUND');

        require (seller != address(0) &&
                tokenInAddress != address(0) &&
                tokenOutAddress != address(0) &&
                tokenInAmount > 0 &&
                tokenOutAmount > 0,
        'VELOXSWAP: ZERO_DETECTED');

        require(tokenInAddress == tokenWETH || tokenOutAddress == tokenWETH, 'VELOXSWAP: INVALID_PATH');
    }

    function adjustInputBasedOnFee(bool takeFeeFromInput, uint16 feeFactor, uint256 amountIn, uint256 amountOut, address sellerAddress) private view
        returns (uint256 amountInForSwap, uint256 amountOurForSwap, address targetAddress) {

        if (takeFeeFromInput) {
            amountInForSwap = deductFee(amountIn, feeFactor);
            amountOurForSwap = deductFee(amountOut, feeFactor);

            targetAddress = sellerAddress;
        } else {
            amountInForSwap = amountIn;
            amountOurForSwap = amountOut;
            targetAddress = address(this);
        }
    }

    function doSwap(address  tokenInAddress, address tokenOutAddress, uint256 tokenInAmount, uint256 minTokenOutAmount, address targetAddress, uint256 deadline, bool exactIn) private {

        VeloxTransferHelper.safeApprove(tokenInAddress, address(router), tokenInAmount);

        address[] memory path = new address[](2);
        path[0] = tokenInAddress;
        path[1] = tokenOutAddress;

        if (exactIn) {
            router.swapExactTokensForTokens(
                tokenInAmount,
                minTokenOutAmount,
                path,
                targetAddress,
                deadline
            );
        } else {
            router.swapTokensForExactTokens(
                tokenInAmount,
                minTokenOutAmount,
                path,
                targetAddress,
                deadline
            );
        }
    }

    function checkLiquidity(address  tokenInAddress, address tokenOutAddress, uint256 minTokenOutAmount) private view {

        (uint256 reserveIn, uint256 reserveOut) = UniswapV2Library.getReserves(UNISWAP_FACTORY_ADDRESS, tokenInAddress, tokenOutAddress);
        require(reserveIn > 0 && reserveOut > 0, 'VELOXSWAP: ZERO_RESERVE_DETECTED');
        require(reserveOut > minTokenOutAmount, 'VELOXSWAP: NOT_ENOUGH_LIQUIDITY');
    }

    function takeOutputFee(uint256 amountOut, uint16 feeFactor, address tokenOutAddress,
                           address from) private returns (uint256 transferredAmount) {


        transferredAmount = deductFee(amountOut, feeFactor);
        Exception exception = doTransferOut(tokenOutAddress, from, transferredAmount);
        require (exception == Exception.NO_ERROR, 'VELOXSWAP: ERROR_GETTING_OUTPUT_FEE');
    }

    function deductFee(uint256 amount, uint16 feeFactor) private pure returns (uint256 deductedAmount) {

        deductedAmount = (amount * (FEE_SCALE - feeFactor)) / FEE_SCALE;
    }
}