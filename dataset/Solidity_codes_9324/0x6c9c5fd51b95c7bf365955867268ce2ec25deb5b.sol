

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.7.0;

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
}

pragma solidity ^0.7.0;

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


pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

interface uniV3Router {


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

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactInputSingle(ExactInputSingleParams memory params) external returns (uint256 amountOut);


    function exactOutputSingle(ExactOutputSingleParams calldata params) external;


    function exactOutput(ExactOutputParams memory params) external returns (uint256 amountIn);

}

interface uniOracle {

   function quoteExactOutputSingle(
    address tokenIn,
    address tokenOut,
    uint24 fee,
    uint256 amountOut,
    uint160 sqrtPriceLimitX96
  ) external returns (uint256 amountIn);

}



pragma solidity ^0.7.0;

interface IBalancer{

    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);


    function queryBatchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        address[] memory assets,
        FundManagement memory funds
    ) external returns (int256[] memory assetDeltas);

}


pragma solidity ^0.7.0;

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



pragma solidity ^0.7.0;




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

pragma solidity ^0.7.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity ^0.7.0;


interface IWETH is IERC20 {

  function deposit() external payable;

  function withdraw(uint) external;

  function decimals() external view returns(uint8);

}


pragma solidity ^0.7.0;

interface IBentoBoxV1 {

    event LogDeploy(address indexed masterContract, bytes data, address indexed cloneAddress);
    event LogDeposit(address indexed token, address indexed from, address indexed to, uint256 amount, uint256 share);
    event LogFlashLoan(address indexed borrower, address indexed token, uint256 amount, uint256 feeAmount, address indexed receiver);
    event LogRegisterProtocol(address indexed protocol);
    event LogSetMasterContractApproval(address indexed masterContract, address indexed user, bool approved);
    event LogStrategyDivest(address indexed token, uint256 amount);
    event LogStrategyInvest(address indexed token, uint256 amount);
    event LogStrategyLoss(address indexed token, uint256 amount);
    event LogStrategyProfit(address indexed token, uint256 amount);
    event LogStrategyQueued(address indexed token, address indexed strategy);
    event LogStrategySet(address indexed token, address indexed strategy);
    event LogStrategyTargetPercentage(address indexed token, uint256 targetPercentage);
    event LogTransfer(address indexed token, address indexed from, address indexed to, uint256 share);
    event LogWhiteListMasterContract(address indexed masterContract, bool approved);
    event LogWithdraw(address indexed token, address indexed from, address indexed to, uint256 amount, uint256 share);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    struct AccrueInfo {
        uint64 interestPerSecond;
        uint64 lastAccrued;
        uint128 feesEarnedFraction;
    }

    function batch(bytes[] calldata calls, bool revertOnFail) external payable returns (bool[] memory successes, bytes[] memory results);


    function claimOwnership() external;


    function deploy(
        address masterContract,
        bytes calldata data,
        bool useCreate2
    ) external payable;


    function deposit(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);



    function harvest(
        IERC20 token,
        bool balance,
        uint256 maxChangeAmount
    ) external;


    function masterContractApproved(address, address) external view returns (bool);


    function masterContractOf(address) external view returns (address);


    function nonces(address) external view returns (uint256);


    function owner() external view returns (address);


    function pendingOwner() external view returns (address);


    function permitToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function registerProtocol() external;


    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;



    function setStrategyTargetPercentage(IERC20 token, uint64 targetPercentage_) external;


    function strategyData(IERC20)
        external
        view
        returns (
            uint64 strategyStartDate,
            uint64 targetPercentage,
            uint128 balance
        );


    function toAmount(
        IERC20 token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);


    function toShare(
        IERC20 token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);


    function transfer(
        IERC20 token,
        address from,
        address to,
        uint256 share
    ) external;


    function transferMultiple(
        IERC20 token,
        address from,
        address[] calldata tos,
        uint256[] calldata shares
    ) external;


    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) external;


    function whitelistMasterContract(address masterContract, bool approved) external;


    function whitelistedMasterContracts(address) external view returns (bool);


    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);

}

pragma solidity ^0.7.0;

interface IPie is IERC20 {

    function joinPool(uint256 _amount) external;

    function exitPool(uint256 _amount) external;

    function calcTokensForAmount(uint256 _amount) external view  returns(address[] memory tokens, uint256[] memory amounts);

}

pragma solidity ^0.7.0;

interface IPieRegistry {

    function inRegistry(address _pool) external view returns(bool);

    function entries(uint256 _index) external view returns(address);

    function addSmartPool(address _smartPool) external;

    function removeSmartPool(uint256 _index) external;

}


pragma solidity ^0.7.0;

interface ILendingLogic {

    function getAPRFromUnderlying(address _token) external view returns(uint256);


    function getAPRFromWrapped(address _token) external view returns(uint256);


    function lend(address _underlying, uint256 _amount, address _tokenHolder) external view returns(address[] memory targets, bytes[] memory data);


    function unlend(address _wrapped, uint256 _amount, address _tokenHolder) external view returns(address[] memory targets, bytes[] memory data);


    function exchangeRate(address _wrapped) external returns(uint256);


    function exchangeRateView(address _wrapped) external view returns(uint256);

}

pragma solidity ^0.7.0;

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

}


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

}

pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

contract Recipe is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IWETH immutable WETH;
    ILendingRegistry immutable lendingRegistry;
    IPieRegistry immutable pieRegistry;
    IBalancer balancer = IBalancer(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    uniOracle oracle = uniOracle(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    uniV3Router uniRouter = uniV3Router(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IUniRouter sushiRouter = IUniRouter(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    mapping(address => bytes32) balancerViable;
    mapping(address => uint16) uniFee;

    struct BestPrice {
        uint price;
        uint dexIndex;
    }

    constructor(
        address _weth,
        address _lendingRegistry,
        address _pieRegistry,
        address _bentoBox,
        address _masterContract
    ) {
        require(_weth != address(0), "WETH_ZERO");
        require(_lendingRegistry != address(0), "LENDING_MANAGER_ZERO");
        require(_pieRegistry != address(0), "PIE_REGISTRY_ZERO");

        WETH = IWETH(_weth);
        lendingRegistry = ILendingRegistry(_lendingRegistry);
        pieRegistry = IPieRegistry(_pieRegistry);

        _bentoBox.call{value : 0}(abi.encodeWithSelector(IBentoBoxV1.setMasterContractApproval.selector, address(this), _masterContract, true, 0, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000));
    }

    function toPie(address _pie, uint256 _outputAmount, uint16[] memory _dexIndex) external payable {


        address(WETH).call{value : msg.value}("");

        uint256 outputAmount = _bake(address(WETH), _pie, _outputAmount, _dexIndex);
        IERC20(_pie).safeTransfer(_msgSender(), outputAmount);
        uint256 wethBalance = WETH.balanceOf(address(this));
        if (wethBalance != 0) {
            WETH.withdraw(wethBalance);
            payable(msg.sender).transfer(wethBalance);
        }
    }

    function bake(
        address _outputToken,
        uint256 _maxInput,
        uint256 _mintAmount,
        uint16[] memory _dexIndex
    ) external returns (uint256 inputAmountUsed, uint256 outputAmount) {

        IERC20 outputToken = IERC20(_outputToken);

        IERC20(address(WETH)).safeTransferFrom(_msgSender(), address(this), _maxInput);

        outputAmount = _bake(address(WETH), _outputToken, _mintAmount, _dexIndex);

        uint256 remainingInputBalance = WETH.balanceOf(address(this));

        if (remainingInputBalance > 0) {
            WETH.transfer(_msgSender(), WETH.balanceOf(address(this)));
        }

        outputToken.safeTransfer(_msgSender(), outputAmount);

        return (inputAmountUsed, outputAmount);
    }

    function _bake(address _inputToken, address _outputToken, uint256 _mintAmount, uint16[] memory _dexIndex) internal returns (uint256 outputAmount) {

        require(_inputToken == address(WETH));
        require(pieRegistry.inRegistry(_outputToken));

        swapPie(_outputToken, _mintAmount, _dexIndex);

        outputAmount = IERC20(_outputToken).balanceOf(address(this));

        return (outputAmount);
    }

    function swap(address _inputToken, address _outputToken, uint256 _outputAmount, uint16 _dexIndex) internal {

        if (_inputToken == _outputToken) {
            return;
        }

        address underlying = lendingRegistry.wrappedToUnderlying(_outputToken);
        if (underlying != address(0)) {
            ILendingLogic lendingLogic = getLendingLogicFromWrapped(_outputToken);
            uint256 exchangeRate = lendingLogic.exchangeRate(_outputToken);
            uint256 underlyingAmount = _outputAmount.mul(exchangeRate).div(1e18).add(1);
            swap(_inputToken, underlying, underlyingAmount, _dexIndex);
            (address[] memory targets, bytes[] memory data) = lendingLogic.lend(underlying, underlyingAmount, address(this));

            for (uint256 i = 0; i < targets.length; i ++) {
                (bool success,) = targets[i].call{value : 0}(data[i]);
                require(success, "CALL_FAILED");
            }
            return;
        }

        dexSwap(_inputToken, _outputToken, _outputAmount, _dexIndex);
    }

    function swapPie(address _pie, uint256 _outputAmount, uint16[] memory _dexIndex) internal {

	    IPie pie = IPie(_pie);
        (address[] memory tokens, uint256[] memory amounts) = pie.calcTokensForAmount(_outputAmount);
	    for (uint256 i = 0; i < tokens.length; i ++) {
            swap(address(WETH), tokens[i], amounts[i], _dexIndex[i]);
            IERC20 token = IERC20(tokens[i]);
            token.approve(_pie, 0);
            token.approve(_pie, amounts[i]);
            require(amounts[i] <= token.balanceOf(address(this)), "We are trying to deposit more then we have");
        }
        pie.joinPool(_outputAmount);
    }

    function dexSwap(address _assetIn, address _assetOut, uint _amountOut, uint16 _dexIndex) public {

        if (_dexIndex == 0) {
            uniV3Router.ExactOutputSingleParams memory params = uniV3Router.ExactOutputSingleParams(
                _assetIn,
                _assetOut,
                500,
                address(this),
                block.timestamp + 1,
                _amountOut,
                type(uint256).max,
                0
            );
            IERC20(_assetIn).approve(address(uniRouter), 0);
            IERC20(_assetIn).approve(address(uniRouter), type(uint256).max);
            uniRouter.exactOutputSingle(params);
            return;
        }
        if (_dexIndex == 1) {
            uniV3Router.ExactOutputSingleParams memory params = uniV3Router.ExactOutputSingleParams(
                _assetIn,
                _assetOut,
                3000,
                address(this),
                block.timestamp + 1,
                _amountOut,
                type(uint256).max,
                0
            );

            IERC20(_assetIn).approve(address(uniRouter), 0);
            IERC20(_assetIn).approve(address(uniRouter), type(uint256).max);
            uniRouter.exactOutputSingle(params);
            return;
        }
        if (_dexIndex == 2) {
            address[] memory route = new address[](2);
            route[0] = _assetIn;
            route[1] = _assetOut;
            IERC20(_assetIn).approve(address(sushiRouter), 0);
            IERC20(_assetIn).approve(address(sushiRouter), type(uint256).max);
            sushiRouter.swapTokensForExactTokens(_amountOut, type(uint256).max, route, address(this), block.timestamp + 1);
            return;
        }
        if (_dexIndex == 3) {
            IBalancer.SwapKind kind = IBalancer.SwapKind.GIVEN_OUT;
            IBalancer.SingleSwap memory singleSwap = IBalancer.SingleSwap(
                balancerViable[_assetOut],
                kind,
                _assetIn,
                _assetOut,
                _amountOut,
                ""
            );
            IBalancer.FundManagement memory funds = IBalancer.FundManagement(
                address(this),
                false,
                payable(address(this)),
                false
            );

            IERC20(_assetIn).approve(address(balancer), 0);
            IERC20(_assetIn).approve(address(balancer), type(uint256).max);
            balancer.swap(
                singleSwap,
                funds,
                type(uint256).max,
                block.timestamp + 1
            );
        }
        else {
            revert("ERROR: Invalid dex index.");
        }

    }

    function getBestPrice(address _assetIn, address _assetOut, uint _amountOut) internal returns (BestPrice memory bestPrice){

        uint uniAmount1;
        uint uniAmount2;
        uint sushiAmount;
        uint balancerAmount;
        BestPrice memory bestPrice;

        if (uniFee[_assetOut] == 500) {
            try oracle.quoteExactOutputSingle(_assetIn, _assetOut, 500, _amountOut, 0) returns (uint256 returnAmount) {
                uniAmount1 = returnAmount;
            } catch {
                uniAmount1 = type(uint256).max;
            }
            bestPrice.price = uniAmount1;
            bestPrice.dexIndex = 0;
        }
        else if (uniFee[_assetOut] == 3000) {
            try oracle.quoteExactOutputSingle(_assetIn, _assetOut, 3000, _amountOut, 0) returns (uint256 returnAmount) {
                uniAmount2 = returnAmount;
            } catch {
                uniAmount2 = type(uint256).max;
            }
            bestPrice.price = uniAmount2;
            bestPrice.dexIndex = 1;
        }
        else {
            try oracle.quoteExactOutputSingle(_assetIn, _assetOut, 500, _amountOut, 0) returns (uint256 returnAmount) {
                uniAmount1 = returnAmount;
            } catch {
                uniAmount1 = type(uint256).max;
            }
            bestPrice.price = uniAmount1;
            bestPrice.dexIndex = 0;
            try oracle.quoteExactOutputSingle(_assetIn, _assetOut, 3000, _amountOut, 0) returns (uint256 returnAmount) {
                uniAmount2 = returnAmount;
            } catch {
                uniAmount2 = type(uint256).max;
            }
            if (bestPrice.price > uniAmount2) {
                bestPrice.price = uniAmount2;
                bestPrice.dexIndex = 1;
            }
        }

        address[] memory route = new address[](2);
        route[0] = _assetIn;
        route[1] = _assetOut;
        try sushiRouter.getAmountsIn(_amountOut, route) returns (uint256[] memory amounts) {
            sushiAmount = amounts[0];
        } catch {
            sushiAmount = type(uint256).max;
        }
        if (bestPrice.price > sushiAmount) {
            bestPrice.price = sushiAmount;
            bestPrice.dexIndex = 2;
        }

        if (balancerViable[_assetOut] != "") {
            IBalancer.SwapKind kind = IBalancer.SwapKind.GIVEN_OUT;

            address[] memory assets = new address[](2);
            assets[0] = _assetIn;
            assets[1] = _assetOut;

            IBalancer.BatchSwapStep[] memory swapStep = new IBalancer.BatchSwapStep[](1);
            swapStep[0] = IBalancer.BatchSwapStep(balancerViable[_assetOut], 0, 1, _amountOut, "");

            IBalancer.FundManagement memory funds = IBalancer.FundManagement(payable(msg.sender), false, payable(msg.sender), false);

            try balancer.queryBatchSwap(kind, swapStep, assets, funds) returns (int[] memory amounts) {
                balancerAmount = uint(amounts[0]);
            } catch {
                balancerAmount = type(uint256).max;
            }
            if (bestPrice.price > balancerAmount) {
                bestPrice.price = balancerAmount;
                bestPrice.dexIndex = 3;
            }
        }
        return bestPrice;
    }

    function getPricePie(address _pie, uint256 _pieAmount) public returns (uint256 mintPrice, uint16[] memory dexIndex) {

        require(pieRegistry.inRegistry(_pie));

        (address[] memory tokens, uint256[] memory amounts) = IPie(_pie).calcTokensForAmount(_pieAmount);
        dexIndex = new uint16[](tokens.length);

        BestPrice memory bestPrice;
        for (uint256 i = 0; i < tokens.length; i ++) {
            require(amounts[i] != 0, "RECIPE: Mint amount to low");
	        address underlying = lendingRegistry.wrappedToUnderlying(tokens[i]);
            if(underlying != address(0)) {
                address wrapedToken = tokens[i];
                tokens[i] = underlying;
                ILendingLogic lendingLogic = getLendingLogicFromWrapped(wrapedToken);
                uint256 exchangeRate = lendingLogic.exchangeRate(wrapedToken);
                amounts[i] = amounts[i].mul(exchangeRate).div(1e18);
            }            
	        bestPrice = getBestPrice(address(WETH), tokens[i], amounts[i]);
            mintPrice += bestPrice.price;
            dexIndex[i] = uint16(bestPrice.dexIndex);
        }

        return (mintPrice, dexIndex);
    }

    function getLendingLogicFromWrapped(address _wrapped) internal view returns (ILendingLogic) {

        return ILendingLogic(
            lendingRegistry.protocolToLogic(
                lendingRegistry.wrappedToProtocol(
                    _wrapped
                )
            )
        );
    }


    function setUniPoolMapping(address _outputAsset, uint16 _Fee) external onlyOwner {

        uniFee[_outputAsset] = _Fee;
    }

    function setBalancerPoolMapping(address _inputAsset, bytes32 _pool) external onlyOwner {

        balancerViable[_inputAsset] = _pool;
    }

    function saveToken(address _token, address _to, uint256 _amount) external onlyOwner {

        IERC20(_token).transfer(_to, _amount);
    }

    function saveEth(address payable _to, uint256 _amount) external onlyOwner {

        _to.call{value : _amount}("");
    }

    receive() external payable{}
}