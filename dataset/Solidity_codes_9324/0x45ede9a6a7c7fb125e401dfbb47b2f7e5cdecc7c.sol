
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT
pragma solidity ^0.8.0;
interface IConvexDeposit{

    function depositAll(uint256 _pid, bool _stake) external; 

}// MIT
pragma solidity ^0.8.0;
interface IConvexWithdraw{

    function withdrawAndUnwrap(uint256, bool) external;

    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getReward() external;

}// MIT
pragma solidity ^0.8.0;
interface ICurvePool { 

    function add_liquidity(uint256[4] memory, uint256) external returns(uint256);

    function remove_liquidity_one_coin(uint256, int128, uint256) external returns(uint256);

    function calc_token_amount(uint256[4] memory, bool) external returns(uint256);

    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);

}// MIT
pragma solidity ^0.8.0;
interface ICurvePool2 { 

    function add_liquidity(uint256[4] memory, uint256) external;

    function remove_liquidity_one_coin(uint256, int128, uint256) external;

    function remove_liquidity_imbalance(uint256[4] memory, uint256) external;

    function get_virtual_price() external returns (uint256);

    function calc_token_amount(uint256[4] memory, bool) external returns(uint256);

    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);

}// MIT
pragma solidity ^0.8.0;

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);

}// MIT
pragma solidity ^0.8.0;

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

}// MIT
pragma solidity ^0.8.0;
interface ITangoFactory { 

    function secretInvest(address, address, uint256) external;

    function secretWithdraw(address , uint256) external;

    function operatorClaimRewardsToSCRT(address) external;

}// MIT
pragma solidity ^0.8.0;

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}// MIT
pragma solidity ^0.8.0;

interface ISecretBridge {

    function swap(bytes memory _recipient)
        external
        payable;

}// MIT
pragma solidity ^0.8.0;

contract Constant { 

    address public constant uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public constant uniswapV2Factory =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 public constant deadline =
        0xf000000000000000000000000000000000000000000000000000000000000000;
    address public constant ust = 0xa47c8bf37f92aBed4A126BDA807A7b7498661acD;
    address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public constant curveBUSDPool = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;
    address public constant curveUSTPool = 0x890f4e345B1dAED0367A877a1612f86A1f86985f;
    address public constant curveLpToken = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
    address public constant curveExchangeBUSD = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
    address public constant convexDeposit = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
    address public constant convexWithDrawAndClaim = 0x602c4cD53a715D8a7cf648540FAb0d3a2d546560;
    uint256 public constant pidBUSD = 3;
}

contract SecretStrategyBUSD is ITangoFactory, Constant, Ownable { 

    using SafeERC20 for IERC20;

    uint256 public secretUST;
    uint256 public reserveUST;
    uint256 public minReserve;
    uint256 public stakedBalance;
    uint256 public depositFee;
    uint256 public rewardFee;
    uint256 public totalDepositFee;
    uint256 public totalRewardFee;
    uint256 public totalUSTDeposited;
    address public router;
    bytes   public receiver;

    mapping(address => bool) isOperator;
    modifier onlyRouter() {

        require(msg.sender == router,"Only-router");
        _;
    }

    modifier onlyOperator() { 

        require(isOperator[msg.sender], "Only-operator");
        _;
    }
    event Invest(address _user, uint256 _amount);
    event Withdraw(address _user, uint256 _amount);
    event Balance(uint256 _secretUST, uint256 _reserveUST);
    constructor(address _router, uint256 _minReserve) Ownable() {
        router = _router;
        minReserve = _minReserve;
        IERC20(curveLpToken).safeApprove(curveBUSDPool, type(uint256).max);
        IERC20(curveLpToken).safeApprove(convexDeposit, type(uint256).max);
        IERC20(usdc).safeApprove(curveUSTPool, type(uint256).max);
        IERC20(dai).safeApprove(curveUSTPool, type(uint256).max);
        IERC20(ust).safeApprove(curveUSTPool, type(uint256).max);

        IERC20(usdc).safeApprove(curveBUSDPool, type(uint256).max);
        IERC20(dai).safeApprove(curveBUSDPool, type(uint256).max);
        transferOwnership(0xE9bee5553E50aEAB2163BA589acAaB79FFE9Aa74);
    }

    function adminSetFee(uint256 _depositFee, uint256 _rewardFee) external onlyOwner() {

        depositFee = _depositFee;
        rewardFee = _rewardFee;
    }

    function adminSetMinReversed(uint256 _minReserve) external onlyOwner() {

        minReserve = _minReserve;
    }

    function adminSetRewardRecipient(bytes memory _receiver) external onlyOwner() {

        receiver = _receiver;
    }

    function adminWhiteListOperator(address _operator, bool _whitelist) external onlyOwner() {

        isOperator[_operator] = _whitelist;
    }

    function adminCollectFee(address _to) external onlyOwner() {

        IERC20(ust).safeTransfer(_to, totalDepositFee);
        IERC20(wETH).safeTransfer(_to, totalRewardFee);
        totalDepositFee = 0;
        totalRewardFee = 0;
    }

    function adminFillReserve(uint256 _amount) external onlyOwner() {

        IERC20(ust).safeTransferFrom(msg.sender, address(this), _amount);
        reserveUST = _amount;
    }

    function adminWithdrawToken(address _token, address _to, uint256 _amount) external onlyOwner() {

        if(_token == address(0)) {
            (bool success, ) = _to.call{value: address(this).balance}("");
            require(success);
            return;
        }
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function _uniswapSwapToken(
        address _router,
        address _fromToken,
        address _toToken,
        uint256 _swapAmount
    ) private returns (uint256 _amountOut) {

        if(IERC20(_fromToken).allowance(address(this), _router) == 0) {
            IERC20(_fromToken).safeApprove(_router, type(uint256).max);
        }        
        address[] memory path;
        if(_fromToken == wETH || _toToken == wETH) {
            path = new address[](2);
            path[0] = _fromToken == wETH ? wETH : _fromToken;
			path[1] = _toToken == wETH ? wETH : _toToken;
        } else { 
            path = new address[](3);
            path[0] = _fromToken;
            path[1] = wETH;
            path[2] = _toToken;
        }
       
        _amountOut = IUniswapV2Router02(_router)
            .swapExactTokensForTokens(
            _swapAmount,
            0,
            path,
            address(this),
            deadline
        )[path.length - 1];
    }

    function _curveAddLiquidity(address _curvePool, uint256[4] memory _param) private returns(uint256) { 

        return ICurvePool(_curvePool).add_liquidity(_param, 0);
    }

    function _curveRemoveLiquidity(address _curvePool, uint256 _curveLpBalance, int128 i) private returns(uint256) { 

        return ICurvePool(_curvePool).remove_liquidity_one_coin(_curveLpBalance, i, 0);
    }

    function calculateLpAmount(address _curvePool, uint256 _daiAmount) private returns (uint256){

        return ICurvePool(_curvePool).calc_token_amount([_daiAmount, 0, 0, 0], false);
    }
    
    function exchangeUnderlying(address _curvePool, uint256 _dx, int128 i, int128 j) private returns (uint256) {

        return ICurvePool(_curvePool).exchange_underlying(i, j, _dx, 0);
    }

    function secretInvest(address _user, address _token, uint256 _amount) external override onlyRouter() {

        uint256 depositAmount = _amount;
        if(depositFee > 0) {
            uint256 fee = depositAmount * depositFee / 10000;
            depositAmount = depositAmount - fee;
            totalDepositFee = totalDepositFee + fee;
        }
        secretUST = secretUST + depositAmount;
        totalUSTDeposited = totalUSTDeposited + _amount;
        emit Invest(_user, _amount);
    }


    function withrawFromPool(uint256 _amount) private returns(uint256) { 

        uint256 lpAmount = calculateLpAmount(curveExchangeBUSD ,_amount) * 101 / 100; // extra 1%
        _withdraw(convexWithDrawAndClaim, lpAmount);
        uint256 balanceUSDC = IERC20(usdc).balanceOf(address(this));
        ICurvePool2(curveBUSDPool).remove_liquidity_one_coin(lpAmount, 1, 0);
        uint256 swapBalance = IERC20(usdc).balanceOf(address(this)) - balanceUSDC;
        uint256 balanceUST = exchangeUnderlying(curveUSTPool, swapBalance, 2, 0);
        return balanceUST;
    }

    function operatorClaimRewards() external onlyOperator() {

        IConvexWithdraw(convexWithDrawAndClaim).getReward();
    }

    function operatorRebalanceReserve() external onlyOperator() { 

        require(reserveUST < minReserve, "No-need-rebalance-now");
        uint256 _amount = minReserve - reserveUST;
        reserveUST = reserveUST + withrawFromPool(_amount);
        require(IERC20(ust).balanceOf(address(this)) >= reserveUST, "Something-went-wrong");
    }

    function secretWithdraw(address _user, uint256 _amount) external override onlyRouter() {

        emit Withdraw(_user, _amount);
        if (secretUST >= _amount) {
            IERC20(ust).safeTransfer(_user, _amount);
            secretUST = secretUST - _amount;
            emit Balance(secretUST, reserveUST);
            return;
        }
        else if(secretUST + reserveUST >= _amount) { 
            reserveUST = reserveUST + secretUST - _amount;
            secretUST = 0;
            IERC20(ust).safeTransfer(_user, _amount);
            emit Balance(secretUST, reserveUST);
            return;
        }
        else { 
            uint256 balanceUST = withrawFromPool(_amount);
            require(balanceUST >= _amount);
            IERC20(ust).safeTransfer(_user, _amount);
            if(balanceUST > _amount) { 
                reserveUST = reserveUST + balanceUST - _amount;
            }
        }
    }

    function operatorClaimRewardsToSCRT(address _secretBridge) external override onlyOperator() { 

        uint256 wETHBalanceBefore = IERC20(wETH).balanceOf(address(this));
        uint256 balanceCRV = IERC20(crv).balanceOf(address(this));
        uint256 balanceCVX = IERC20(cvx).balanceOf(address(this));
        IConvexWithdraw(convexWithDrawAndClaim).getReward();
        uint256 amountCRV = IERC20(crv).balanceOf(address(this)) - balanceCRV;
        uint256 amountCVX = IERC20(cvx).balanceOf(address(this)) - balanceCVX;
        if(amountCRV > 0) {
            _uniswapSwapToken(uniRouter, crv, wETH, amountCRV);
        }
        if(amountCVX > 0) {
            _uniswapSwapToken(sushiRouter, cvx, wETH, amountCVX);
        }
        uint256 wETHBalanceAfter = IERC20(wETH).balanceOf(address(this));
        uint256 balanceDiff = wETHBalanceAfter - wETHBalanceBefore;
        if(rewardFee > 0) {
            uint256 fee = balanceDiff * rewardFee / 10000;
            balanceDiff = balanceDiff - fee;
            totalRewardFee = totalRewardFee + fee;
        }
        IWETH(wETH).withdraw(balanceDiff);
        ISecretBridge(_secretBridge).swap{value: balanceDiff}(receiver);
    }

    function operatorInvest() external onlyOperator() {

        uint256 amountUSDC = exchangeUnderlying(curveUSTPool, secretUST, 0, 2);
        uint256 balanceLP = IERC20(curveLpToken).balanceOf(address(this));
        ICurvePool2(curveBUSDPool).add_liquidity([0, amountUSDC, 0, 0], 0); 
        uint256 balanceDiff = IERC20(curveLpToken).balanceOf(address(this)) - balanceLP;
        require(balanceDiff > 0, "Invalid-balance");
        _stake(convexDeposit, pidBUSD, balanceDiff);
        secretUST = 0;
    }

    function _stake(address _pool, uint256 _pid, uint256 _stakeAmount) private {

        IConvexDeposit(_pool).depositAll(_pid, true);
        stakedBalance = stakedBalance + _stakeAmount;
    }

    function _withdraw(address _pool, uint256 _amount) private {

        IConvexWithdraw(_pool).withdrawAndUnwrap(_amount, false);
        stakedBalance = stakedBalance - _amount;
    }

    function getStakingInfor() public view returns(uint256, uint256) { 

        uint256 currentStakedBalance = IConvexWithdraw(convexWithDrawAndClaim).balanceOf(address(this));
        uint256 rewardBalance = IConvexWithdraw(convexWithDrawAndClaim).earned(address(this));
        return (currentStakedBalance, rewardBalance);
    }

    receive() external payable {
        
    }
}