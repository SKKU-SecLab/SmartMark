



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





library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}





library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}






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





abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



pragma experimental "ABIEncoderV2";


interface ISetToken is IERC20 {



    enum ModuleState {
        NONE,
        PENDING,
        INITIALIZED
    }

    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    struct ComponentPosition {
      int256 virtualUnit;
      address[] externalPositionModules;
      mapping(address => ExternalPosition) externalPositions;
    }

    struct ExternalPosition {
      int256 virtualUnit;
      bytes data;
    }


    
    function addComponent(address _component) external;

    function removeComponent(address _component) external;

    function editDefaultPositionUnit(address _component, int256 _realUnit) external;

    function addExternalPositionModule(address _component, address _positionModule) external;

    function removeExternalPositionModule(address _component, address _positionModule) external;

    function editExternalPositionUnit(address _component, address _positionModule, int256 _realUnit) external;

    function editExternalPositionData(address _component, address _positionModule, bytes calldata _data) external;


    function invoke(address _target, uint256 _value, bytes calldata _data) external returns(bytes memory);


    function editPositionMultiplier(int256 _newMultiplier) external;


    function mint(address _account, uint256 _quantity) external;

    function burn(address _account, uint256 _quantity) external;


    function lock() external;

    function unlock() external;


    function addModule(address _module) external;

    function removeModule(address _module) external;

    function initializeModule() external;


    function setManager(address _manager) external;


    function manager() external view returns (address);

    function moduleStates(address _module) external view returns (ModuleState);

    function getModules() external view returns (address[] memory);

    
    function getDefaultPositionRealUnit(address _component) external view returns(int256);

    function getExternalPositionRealUnit(address _component, address _positionModule) external view returns(int256);

    function getComponents() external view returns(address[] memory);

    function getExternalPositionModules(address _component) external view returns(address[] memory);

    function getExternalPositionData(address _component, address _positionModule) external view returns(bytes memory);

    function isExternalPositionModule(address _component, address _module) external view returns(bool);

    function isComponent(address _component) external view returns(bool);

    
    function positionMultiplier() external view returns (int256);

    function getPositions() external view returns (Position[] memory);

    function getTotalComponentRealUnits(address _component) external view returns(int256);


    function isInitializedModule(address _module) external view returns(bool);

    function isPendingModule(address _module) external view returns(bool);

    function isLocked() external view returns (bool);

}




interface IBasicIssuanceModule {

    function getRequiredComponentUnitsForIssue(
        ISetToken _setToken,
        uint256 _quantity
    ) external returns(address[] memory, uint256[] memory);

    function issue(ISetToken _setToken, uint256 _quantity, address _to) external;

    function redeem(ISetToken _token, uint256 _quantity, address _to) external;

}



interface IController {

    function addSet(address _setToken) external;

    function feeRecipient() external view returns(address);

    function getModuleFee(address _module, uint256 _feeType) external view returns(uint256);

    function isModule(address _module) external view returns(bool);

    function isSet(address _setToken) external view returns(bool);

    function isSystemContract(address _contractAddress) external view returns (bool);

    function resourceId(uint256 _id) external view returns(address);

}




interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}




library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}







library PreciseUnitMath {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 constant internal PRECISE_UNIT = 10 ** 18;
    int256 constant internal PRECISE_UNIT_INT = 10 ** 18;

    uint256 constant internal MAX_UINT_256 = type(uint256).max;
    int256 constant internal MAX_INT_256 = type(int256).max;
    int256 constant internal MIN_INT_256 = type(int256).min;

    function preciseUnit() internal pure returns (uint256) {

        return PRECISE_UNIT;
    }

    function preciseUnitInt() internal pure returns (int256) {

        return PRECISE_UNIT_INT;
    }

    function maxUint256() internal pure returns (uint256) {

        return MAX_UINT_256;
    }

    function maxInt256() internal pure returns (int256) {

        return MAX_INT_256;
    }

    function minInt256() internal pure returns (int256) {

        return MIN_INT_256;
    }

    function preciseMul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(b).div(PRECISE_UNIT);
    }

    function preciseMul(int256 a, int256 b) internal pure returns (int256) {

        return a.mul(b).div(PRECISE_UNIT_INT);
    }

    function preciseMulCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0 || b == 0) {
            return 0;
        }
        return a.mul(b).sub(1).div(PRECISE_UNIT).add(1);
    }

    function preciseDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(PRECISE_UNIT).div(b);
    }


    function preciseDiv(int256 a, int256 b) internal pure returns (int256) {

        return a.mul(PRECISE_UNIT_INT).div(b);
    }

    function preciseDivCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "Cant divide by 0");

        return a > 0 ? a.mul(PRECISE_UNIT).sub(1).div(b).add(1) : 0;
    }

    function divDown(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "Cant divide by 0");
        require(a != MIN_INT_256 || b != -1, "Invalid input");

        int256 result = a.div(b);
        if (a ^ b < 0 && a % b != 0) {
            result -= 1;
        }

        return result;
    }

    function conservativePreciseMul(int256 a, int256 b) internal pure returns (int256) {

        return divDown(a.mul(b), PRECISE_UNIT_INT);
    }

    function conservativePreciseDiv(int256 a, int256 b) internal pure returns (int256) {

        return divDown(a.mul(PRECISE_UNIT_INT), b);
    }

    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {

        require(a > 0, "Value must be positive");

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

            result = previousResult.mul(a);
        }

        return result;
    }
}



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







library UniSushiV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function getReserves(address pair, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
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


pragma solidity 0.6.10;




contract ExchangeIssuance is ReentrancyGuard {

    
    using Address for address payable;
    using SafeMath for uint256;
    using PreciseUnitMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for ISetToken;
    
    
    enum Exchange { Uniswap, Sushiswap, None }


    uint256 constant private MAX_UINT96 = 2**96 - 1;
    address constant public ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    

    address public WETH;
    IUniswapV2Router02 public uniRouter;
    IUniswapV2Router02 public sushiRouter;
    
    address public immutable uniFactory;
    address public immutable sushiFactory;
    
    IController public immutable setController;
    IBasicIssuanceModule public immutable basicIssuanceModule;


    event ExchangeIssue(
        address indexed _recipient,     // The recipient address of the issued SetTokens
        ISetToken indexed _setToken,    // The issued SetToken
        IERC20 indexed _inputToken,     // The address of the input asset(ERC20/ETH) used to issue the SetTokens
        uint256 _amountInputToken,      // The amount of input tokens used for issuance
        uint256 _amountSetIssued        // The amount of SetTokens received by the recipient
    );

    event ExchangeRedeem(
        address indexed _recipient,     // The recipient address which redeemed the SetTokens
        ISetToken indexed _setToken,    // The redeemed SetToken
        IERC20 indexed _outputToken,    // The address of output asset(ERC20/ETH) received by the recipient
        uint256 _amountSetRedeemed,     // The amount of SetTokens redeemed for output tokens
        uint256 _amountOutputToken      // The amount of output tokens received by the recipient
    );

    event Refund(
        address indexed _recipient,     // The recipient address which redeemed the SetTokens
        uint256 _refundAmount           // The amount of ETH redunded to the recipient
    );
    
    
    modifier isSetToken(ISetToken _setToken) {

         require(setController.isSet(address(_setToken)), "ExchangeIssuance: INVALID SET");
         _;
    }
    

    constructor(
        address _weth,
        address _uniFactory,
        IUniswapV2Router02 _uniRouter, 
        address _sushiFactory, 
        IUniswapV2Router02 _sushiRouter, 
        IController _setController,
        IBasicIssuanceModule _basicIssuanceModule
    )
        public
    {
        uniFactory = _uniFactory;
        uniRouter = _uniRouter;

        sushiFactory = _sushiFactory;
        sushiRouter = _sushiRouter;
        
        setController = _setController;
        basicIssuanceModule = _basicIssuanceModule;
        
        WETH = _weth;
        IERC20(WETH).safeApprove(address(uniRouter), PreciseUnitMath.maxUint256());
        IERC20(WETH).safeApprove(address(sushiRouter), PreciseUnitMath.maxUint256());
    }
    
    
    function approveToken(IERC20 _token) public {

        _safeApprove(_token, address(uniRouter), MAX_UINT96);
        _safeApprove(_token, address(sushiRouter), MAX_UINT96);
        _safeApprove(_token, address(basicIssuanceModule), MAX_UINT96);
    }

    
    receive() external payable {
        require(msg.sender == WETH, "ExchangeIssuance: Direct deposits not allowed");
    }
    
    function approveTokens(IERC20[] calldata _tokens) external {

        for (uint256 i = 0; i < _tokens.length; i++) {
            approveToken(_tokens[i]);
        }
    }

    function approveSetToken(ISetToken _setToken) isSetToken(_setToken) external {

        address[] memory components = _setToken.getComponents();
        for (uint256 i = 0; i < components.length; i++) {
            require(
                _setToken.getExternalPositionModules(components[i]).length == 0,
                "ExchangeIssuance: EXTERNAL_POSITIONS_NOT_ALLOWED"
            );
            approveToken(IERC20(components[i]));
        }
    }

    function issueSetForExactToken(
        ISetToken _setToken,
        IERC20 _inputToken,
        uint256 _amountInput,
        uint256 _minSetReceive
    )   
        isSetToken(_setToken)
        external
        nonReentrant
        returns (uint256)
    {   

        require(_amountInput > 0, "ExchangeIssuance: INVALID INPUTS");
        
        _inputToken.safeTransferFrom(msg.sender, address(this), _amountInput);
        
        uint256 amountEth = address(_inputToken) == WETH
            ? _amountInput
            : _swapTokenForWETH(_inputToken, _amountInput);

        uint256 setTokenAmount = _issueSetForExactWETH(_setToken, _minSetReceive, amountEth);
        
        emit ExchangeIssue(msg.sender, _setToken, _inputToken, _amountInput, setTokenAmount);
        return setTokenAmount;
    }
    
    function issueSetForExactETH(
        ISetToken _setToken,
        uint256 _minSetReceive
    )
        isSetToken(_setToken)
        external
        payable
        nonReentrant
        returns(uint256)
    {

        require(msg.value > 0, "ExchangeIssuance: INVALID INPUTS");
        
        IWETH(WETH).deposit{value: msg.value}();
        
        uint256 setTokenAmount = _issueSetForExactWETH(_setToken, _minSetReceive, msg.value);
        
        emit ExchangeIssue(msg.sender, _setToken, IERC20(ETH_ADDRESS), msg.value, setTokenAmount);
        return setTokenAmount;
    }
    
    function issueExactSetFromToken(
        ISetToken _setToken,
        IERC20 _inputToken,
        uint256 _amountSetToken,
        uint256 _maxAmountInputToken
    )
        isSetToken(_setToken)
        external
        nonReentrant
        returns (uint256)
    {

        require(_amountSetToken > 0 && _maxAmountInputToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        _inputToken.safeTransferFrom(msg.sender, address(this), _maxAmountInputToken);
        
        uint256 initETHAmount = address(_inputToken) == WETH
            ? _maxAmountInputToken
            : _swapTokenForWETH(_inputToken, _maxAmountInputToken);
        
        uint256 amountEthSpent = _issueExactSetFromWETH(_setToken, _amountSetToken, initETHAmount);
        
        uint256 amountEthReturn = initETHAmount.sub(amountEthSpent);
        if (amountEthReturn > 0) {
            IWETH(WETH).withdraw(amountEthReturn);
            (payable(msg.sender)).sendValue(amountEthReturn);
        }
        
        emit Refund(msg.sender, amountEthReturn);
        emit ExchangeIssue(msg.sender, _setToken, _inputToken, _maxAmountInputToken, _amountSetToken);
        return amountEthReturn;
    }
    
    function issueExactSetFromETH(
        ISetToken _setToken,
        uint256 _amountSetToken
    )
        isSetToken(_setToken)
        external
        payable
        nonReentrant
        returns (uint256)
    {

        require(msg.value > 0 && _amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        IWETH(WETH).deposit{value: msg.value}();
        
        uint256 amountEth = _issueExactSetFromWETH(_setToken, _amountSetToken, msg.value);
        
        uint256 amountEthReturn = msg.value.sub(amountEth);
        
        if (amountEthReturn > 0) {
            IWETH(WETH).withdraw(amountEthReturn);
            (payable(msg.sender)).sendValue(amountEthReturn);
        }
        
        emit Refund(msg.sender, amountEthReturn);
        emit ExchangeIssue(msg.sender, _setToken, IERC20(ETH_ADDRESS), amountEth, _amountSetToken);
        return amountEthReturn;
    }
    
    function redeemExactSetForToken(
        ISetToken _setToken,
        IERC20 _outputToken,
        uint256 _amountSetToken,
        uint256 _minOutputReceive
    )
        isSetToken(_setToken)
        external
        nonReentrant
        returns (uint256)
    {

        require(_amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        address[] memory components = _setToken.getComponents();
        (
            uint256 totalEth, 
            uint256[] memory amountComponents, 
            Exchange[] memory exchanges
        ) =  _getAmountETHForRedemption(_setToken, components, _amountSetToken);
        
        uint256 outputAmount;
        if (address(_outputToken) == WETH) {
            require(totalEth > _minOutputReceive, "ExchangeIssuance: INSUFFICIENT_OUTPUT_AMOUNT");
            _redeemExactSet(_setToken, _amountSetToken);
            outputAmount = _liquidateComponentsForWETH(components, amountComponents, exchanges);
        } else {
            (uint256 totalOutput, Exchange outTokenExchange, ) = _getMaxTokenForExactToken(totalEth, address(WETH), address(_outputToken));
            require(totalOutput > _minOutputReceive, "ExchangeIssuance: INSUFFICIENT_OUTPUT_AMOUNT");
            _redeemExactSet(_setToken, _amountSetToken);
            uint256 outputEth = _liquidateComponentsForWETH(components, amountComponents, exchanges);
            outputAmount = _swapExactTokensForTokens(outTokenExchange, WETH, address(_outputToken), outputEth);
        }
        
        _outputToken.safeTransfer(msg.sender, outputAmount);
        emit ExchangeRedeem(msg.sender, _setToken, _outputToken, _amountSetToken, outputAmount);
        return outputAmount;
    }
    
    function redeemExactSetForETH(
        ISetToken _setToken,
        uint256 _amountSetToken,
        uint256 _minEthOut
    )
        isSetToken(_setToken)
        external
        nonReentrant
        returns (uint256)
    {

        require(_amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        address[] memory components = _setToken.getComponents();
        (
            uint256 totalEth, 
            uint256[] memory amountComponents, 
            Exchange[] memory exchanges
        ) =  _getAmountETHForRedemption(_setToken, components, _amountSetToken);
        
        require(totalEth > _minEthOut, "ExchangeIssuance: INSUFFICIENT_OUTPUT_AMOUNT");
        
        _redeemExactSet(_setToken, _amountSetToken);
        
        uint256 amountEthOut = _liquidateComponentsForWETH(components, amountComponents, exchanges);
        
        IWETH(WETH).withdraw(amountEthOut);
        (payable(msg.sender)).sendValue(amountEthOut);

        emit ExchangeRedeem(msg.sender, _setToken, IERC20(ETH_ADDRESS), _amountSetToken, amountEthOut);
        return amountEthOut;
    }

    function getEstimatedIssueSetAmount(
        ISetToken _setToken,
        IERC20 _inputToken,
        uint256 _amountInput
    )
        isSetToken(_setToken)
        external
        view
        returns (uint256)
    {

        require(_amountInput > 0, "ExchangeIssuance: INVALID INPUTS");
        
        uint256 amountEth;
        if (address(_inputToken) != WETH) {
            (amountEth, , ) = _getMaxTokenForExactToken(_amountInput, address(_inputToken), WETH);
        } else {
            amountEth = _amountInput;
        }
        
        address[] memory components = _setToken.getComponents();
        (uint256 setIssueAmount, , ) = _getSetIssueAmountForETH(_setToken, components, amountEth);
        return setIssueAmount;
    }
    
    function getAmountInToIssueExactSet(
        ISetToken _setToken,
        IERC20 _inputToken,
        uint256 _amountSetToken
    )
        isSetToken(_setToken)
        external
        view
        returns(uint256)
    {

        require(_amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        address[] memory components = _setToken.getComponents();
        (uint256 totalEth, , , , ) = _getAmountETHForIssuance(_setToken, components, _amountSetToken);
        
        if (address(_inputToken) == WETH) {
            return totalEth;
        }
        
        (uint256 tokenAmount, , ) = _getMinTokenForExactToken(totalEth, address(_inputToken), address(WETH));
        return tokenAmount;
    }
    
    function getAmountOutOnRedeemSet(
        ISetToken _setToken,
        address _outputToken,
        uint256 _amountSetToken
    ) 
        isSetToken(_setToken)
        external
        view
        returns (uint256)
    {

        require(_amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        address[] memory components = _setToken.getComponents();
        (uint256 totalEth, , ) = _getAmountETHForRedemption(_setToken, components, _amountSetToken);
        
        if (_outputToken == WETH) {
            return totalEth;
        }
        
        (uint256 tokenAmount, , ) = _getMaxTokenForExactToken(totalEth, WETH, _outputToken);
        return tokenAmount;
    }
    
    

    function _safeApprove(IERC20 _token, address _spender, uint256 _requiredAllowance) internal {

        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _requiredAllowance) {
            _token.safeIncreaseAllowance(_spender, MAX_UINT96 - allowance);
        }
    }
    
    function _issueSetForExactWETH(ISetToken _setToken, uint256 _minSetReceive, uint256 _totalEthAmount) internal returns (uint256) {

        
        address[] memory components = _setToken.getComponents();
        (
            uint256 setIssueAmount, 
            uint256[] memory amountEthIn, 
            Exchange[] memory exchanges
        ) = _getSetIssueAmountForETH(_setToken, components, _totalEthAmount);
        
        require(setIssueAmount > _minSetReceive, "ExchangeIssuance: INSUFFICIENT_OUTPUT_AMOUNT");
        
        for (uint256 i = 0; i < components.length; i++) {
            _swapExactTokensForTokens(exchanges[i], WETH, components[i], amountEthIn[i]);
        }
        
        basicIssuanceModule.issue(_setToken, setIssueAmount, msg.sender);
        return setIssueAmount;
    }
    
    function _issueExactSetFromWETH(ISetToken _setToken, uint256 _amountSetToken, uint256 _maxEther) internal returns (uint256) {

        
        address[] memory components = _setToken.getComponents();
        (
            uint256 sumEth,
            , 
            Exchange[] memory exchanges, 
            uint256[] memory amountComponents,
        ) = _getAmountETHForIssuance(_setToken, components, _amountSetToken);
        
        require(sumEth <= _maxEther, "ExchangeIssuance: INSUFFICIENT_INPUT_AMOUNT");
        
        uint256 totalEth = 0;
        for (uint256 i = 0; i < components.length; i++) {
            uint256 amountEth = _swapTokensForExactTokens(exchanges[i], WETH, components[i], amountComponents[i]);
            totalEth = totalEth.add(amountEth);
        }
        basicIssuanceModule.issue(_setToken, _amountSetToken, msg.sender);
        return totalEth;
    }
    
    function _redeemExactSet(ISetToken _setToken, uint256 _amount) internal returns (uint256) {

        _setToken.safeTransferFrom(msg.sender, address(this), _amount);
        basicIssuanceModule.redeem(_setToken, _amount, address(this));
    }
    
    function _liquidateComponentsForWETH(address[] memory _components, uint256[] memory _amountComponents, Exchange[] memory _exchanges)
        internal
        returns (uint256)
    {

        uint256 sumEth = 0;
        for (uint256 i = 0; i < _components.length; i++) {
            sumEth = _exchanges[i] == Exchange.None
                ? sumEth.add(_amountComponents[i]) 
                : sumEth.add(_swapExactTokensForTokens(_exchanges[i], _components[i], WETH, _amountComponents[i]));
        }
        return sumEth;
    }
    
    function _getAmountETHForIssuance(ISetToken _setToken, address[] memory _components, uint256 _amountSetToken)
        internal
        view
        returns (
            uint256 sumEth, 
            uint256[] memory amountEthIn, 
            Exchange[] memory exchanges, 
            uint256[] memory amountComponents, 
            address[] memory pairAddresses
        )
    {

        sumEth = 0;
        amountEthIn = new uint256[](_components.length);
        amountComponents = new uint256[](_components.length);
        exchanges = new Exchange[](_components.length);
        pairAddresses = new address[](_components.length);
        
        for (uint256 i = 0; i < _components.length; i++) {

            require(
                _setToken.getExternalPositionModules(_components[i]).length == 0,
                "ExchangeIssuance: EXTERNAL_POSITIONS_NOT_ALLOWED"
            );

            uint256 unit = uint256(_setToken.getDefaultPositionRealUnit(_components[i]));
            amountComponents[i] = uint256(unit).preciseMulCeil(_amountSetToken);
            
            (amountEthIn[i], exchanges[i], pairAddresses[i]) = _getMinTokenForExactToken(amountComponents[i], WETH, _components[i]);
            sumEth = sumEth.add(amountEthIn[i]);
        }
        return (sumEth, amountEthIn, exchanges, amountComponents, pairAddresses);
    }
    
    function _getAmountETHForRedemption(ISetToken _setToken, address[] memory _components, uint256 _amountSetToken)
        internal
        view
        returns (uint256, uint256[] memory, Exchange[] memory)
    {

        uint256 sumEth = 0;
        uint256 amountEth = 0;
        
        uint256[] memory amountComponents = new uint256[](_components.length);
        Exchange[] memory exchanges = new Exchange[](_components.length);
        
        for (uint256 i = 0; i < _components.length; i++) {
            
            require(
                _setToken.getExternalPositionModules(_components[i]).length == 0,
                "ExchangeIssuance: EXTERNAL_POSITIONS_NOT_ALLOWED"
            );
            
            uint256 unit = uint256(_setToken.getDefaultPositionRealUnit(_components[i]));
            amountComponents[i] = unit.preciseMul(_amountSetToken);
            
            (amountEth, exchanges[i], ) = _getMaxTokenForExactToken(amountComponents[i], _components[i], WETH);
            sumEth = sumEth.add(amountEth);
        }
        return (sumEth, amountComponents, exchanges);
    }
    
    function _getSetIssueAmountForETH(ISetToken _setToken, address[] memory _components, uint256 _amountEth) 
        internal
        view
        returns (uint256 setIssueAmount, uint256[] memory amountEthIn, Exchange[] memory exchanges)
    {

        uint256 sumEth;
        uint256[] memory unitAmountEthIn;
        uint256[] memory unitAmountComponents;
        address[] memory pairAddresses;
        (
            sumEth,
            unitAmountEthIn,
            exchanges, 
            unitAmountComponents,
            pairAddresses
        ) = _getAmountETHForIssuance(_setToken, _components, PreciseUnitMath.preciseUnit());
        
        setIssueAmount = PreciseUnitMath.maxUint256();
        amountEthIn = new uint256[](_components.length);
        
        for (uint256 i = 0; i < _components.length; i++) {
            
            amountEthIn[i] = unitAmountEthIn[i].mul(_amountEth).div(sumEth);
            
            uint256 amountComponent;
            if (exchanges[i] == Exchange.None) {
                amountComponent = amountEthIn[i];
            } else {
                (uint256 reserveIn, uint256 reserveOut) = UniSushiV2Library.getReserves(pairAddresses[i], WETH, _components[i]);
                amountComponent = UniSushiV2Library.getAmountOut(amountEthIn[i], reserveIn, reserveOut);
            }
            setIssueAmount = Math.min(amountComponent.preciseDiv(unitAmountComponents[i]), setIssueAmount);
        }
        return (setIssueAmount, amountEthIn, exchanges);
    }
    
    function _swapTokenForWETH(IERC20 _token, uint256 _amount) internal returns (uint256) {

        (, Exchange exchange, ) = _getMaxTokenForExactToken(_amount, address(_token), WETH);
        IUniswapV2Router02 router = _getRouter(exchange);
        _safeApprove(_token, address(router), _amount);
        return _swapExactTokensForTokens(exchange, address(_token), WETH, _amount);
    }
    
    function _swapExactTokensForTokens(Exchange _exchange, address _tokenIn, address _tokenOut, uint256 _amountIn) internal returns (uint256) {

        if (_tokenIn == _tokenOut) {
            return _amountIn;
        }
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        return _getRouter(_exchange).swapExactTokensForTokens(_amountIn, 0, path, address(this), block.timestamp)[1];
    }
    
    function _swapTokensForExactTokens(Exchange _exchange, address _tokenIn, address _tokenOut, uint256 _amountOut) internal returns (uint256) {

        if (_tokenIn == _tokenOut) {
            return _amountOut;
        }
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        return _getRouter(_exchange).swapTokensForExactTokens(_amountOut, PreciseUnitMath.maxUint256(), path, address(this), block.timestamp)[0];
    }
 
    function _getMinTokenForExactToken(uint256 _amountOut, address _tokenA, address _tokenB) internal view returns (uint256, Exchange, address) {

        if (_tokenA == _tokenB) {
            return (_amountOut, Exchange.None, ETH_ADDRESS);
        }
        
        uint256 maxIn = PreciseUnitMath.maxUint256() ; 
        uint256 uniTokenIn = maxIn;
        uint256 sushiTokenIn = maxIn;
        
        address uniswapPair = _getPair(uniFactory, _tokenA, _tokenB);
        if (uniswapPair != address(0)) {
            (uint256 reserveIn, uint256 reserveOut) = UniSushiV2Library.getReserves(uniswapPair, _tokenA, _tokenB);
            if (reserveOut > _amountOut) {
                uniTokenIn = UniSushiV2Library.getAmountIn(_amountOut, reserveIn, reserveOut);
            }
        }
        
        address sushiswapPair = _getPair(sushiFactory, _tokenA, _tokenB);
        if (sushiswapPair != address(0)) {
            (uint256 reserveIn, uint256 reserveOut) = UniSushiV2Library.getReserves(sushiswapPair, _tokenA, _tokenB);
            if (reserveOut > _amountOut) {
                sushiTokenIn = UniSushiV2Library.getAmountIn(_amountOut, reserveIn, reserveOut);
            }
        }
        
        require(!(uniTokenIn == maxIn && sushiTokenIn == maxIn), "ExchangeIssuance: ILLIQUID_SET_COMPONENT");
        return (uniTokenIn <= sushiTokenIn) ? (uniTokenIn, Exchange.Uniswap, uniswapPair) : (sushiTokenIn, Exchange.Sushiswap, sushiswapPair);
    }
    
    function _getMaxTokenForExactToken(uint256 _amountIn, address _tokenA, address _tokenB) internal view returns (uint256, Exchange, address) {

        if (_tokenA == _tokenB) {
            return (_amountIn, Exchange.None, ETH_ADDRESS);
        }
        
        uint256 uniTokenOut = 0;
        uint256 sushiTokenOut = 0;
        
        address uniswapPair = _getPair(uniFactory, _tokenA, _tokenB);
        if(uniswapPair != address(0)) {
            (uint256 reserveIn, uint256 reserveOut) = UniSushiV2Library.getReserves(uniswapPair, _tokenA, _tokenB);
            uniTokenOut = UniSushiV2Library.getAmountOut(_amountIn, reserveIn, reserveOut);
        }
        
        address sushiswapPair = _getPair(sushiFactory, _tokenA, _tokenB);
        if(sushiswapPair != address(0)) {
            (uint256 reserveIn, uint256 reserveOut) = UniSushiV2Library.getReserves(sushiswapPair, _tokenA, _tokenB);
            sushiTokenOut = UniSushiV2Library.getAmountOut(_amountIn, reserveIn, reserveOut);
        }
        
        require(!(uniTokenOut == 0 && sushiTokenOut == 0), "ExchangeIssuance: ILLIQUID_SET_COMPONENT");
        return (uniTokenOut >= sushiTokenOut) ? (uniTokenOut, Exchange.Uniswap, uniswapPair) : (sushiTokenOut, Exchange.Sushiswap, sushiswapPair); 
    }
    
    function _getPair(address _factory, address _tokenA, address _tokenB) internal view returns (address) {

        return IUniswapV2Factory(_factory).getPair(_tokenA, _tokenB);
    }
    
     function _getRouter(Exchange _exchange) internal view returns(IUniswapV2Router02) {

         return (_exchange == Exchange.Uniswap) ? uniRouter : sushiRouter;
     }
    
}