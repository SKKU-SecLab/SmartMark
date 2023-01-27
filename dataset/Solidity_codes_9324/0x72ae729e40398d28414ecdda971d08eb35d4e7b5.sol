



pragma solidity 0.8.1;

interface ICurve {

    function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns(uint256);


    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);

}

pragma solidity >=0.4.0;

interface IWETH9 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function balanceOf(address) external view returns (uint);


    function allowance(address, address) external view returns (uint);


    receive() external payable;

    function deposit() external payable;


    function withdraw(uint wad) external;


    function totalSupply() external view returns (uint);


    function approve(address guy, uint wad) external returns (bool);


    function transfer(address dst, uint wad) external returns (bool);


    function transferFrom(address src, address dst, uint wad)
    external
    returns (bool);

}



pragma solidity 0.8.1;

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


interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}

interface ISwapRouter is IUniswapV3SwapCallback {

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

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


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

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}



pragma solidity 0.8.1;

interface ILendingPool {

    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;


    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external;

}

interface ILendingPoolAddressesProvider {

    function getLendingPool() external view returns (address);

}

interface IFlashLoanReceiver {

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool);


    function ADDRESSES_PROVIDER() external view returns (ILendingPoolAddressesProvider);


    function LENDING_POOL() external view returns (ILendingPool);

}

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {

    ILendingPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    ILendingPool public immutable override LENDING_POOL;

    constructor(ILendingPoolAddressesProvider provider) {
        ADDRESSES_PROVIDER = provider;
        LENDING_POOL = ILendingPool(provider.getLendingPool());
    }
}




pragma solidity 0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



pragma solidity 0.8.1;


abstract contract bdToken is IERC20 {
    address public underlying;

    function redeem(uint redeemTokens) virtual external returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) virtual external returns (uint);
}

interface Stabilizer {

    function buy(uint amount) external;

    function sell(uint amount) external;

}


pragma solidity 0.8.1;







contract LiquidationController is
Ownable,
FlashLoanReceiverBase(ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5))
{

    bdToken public bdUSD;
    bdToken public bdETH;
    IWETH9 constant WETH = IWETH9(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public bUSD;
    ISwapRouter public swapRouter; // UniV3 Router
    ICurve public curvePool; //bUSD-3Pool

    address public Treasury = 0x3dFc49e5112005179Da613BdE5973229082dAc35;

    mapping(address => uint24) poolFee;

    using SafeERC20 for IERC20;

    constructor(address _curvePool, address _bdUSD, address _bdETH, address _bUSD, address _bdUSDC, address _swapRouter){
        curvePool = ICurve(_curvePool);
        bdUSD = bdToken(_bdUSD);
        bdETH = bdToken(_bdETH);
        bUSD = IERC20(_bUSD);
        swapRouter = ISwapRouter(_swapRouter);

        poolFee[_bdUSDC] = 500; //USDC-DAI
        poolFee[_bdETH] = 3000; //Eth-DAI
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator, 
        bytes calldata _params
    ) external override returns(bool){

        (address[] memory _borrowers, uint256[] memory _repayAmounts, address[] memory _bdCollaterals) = abi.decode(_params, (address[], uint256[], address[]));

        DAI.approve(address(curvePool), amounts[0]);

        curvePool.exchange_underlying(1,0,amounts[0],0);
        
        bUSD.approve(address(bdUSD), amounts[0]);
        
        for (uint i = 0; i < _borrowers.length; i++) {
            (uint result) = bdUSD.liquidateBorrow(_borrowers[i], _repayAmounts[i], _bdCollaterals[i]);
            
            if(result!=0){
                bUSD.approve(address(curvePool), _repayAmounts[i]);
                curvePool.exchange_underlying(0,1,_repayAmounts[i],0);
            }
        }
        
        for (uint j = 0; j < _bdCollaterals.length; j++) {
            bdToken bdCollateral = bdToken(_bdCollaterals[j]);
            uint collateralBalance = bdCollateral.balanceOf(address(this));

            if(collateralBalance == 0 && address(this).balance == 0){
                continue;
            }

            bdCollateral.redeem(collateralBalance);
            ISwapRouter.ExactInputSingleParams memory params;

            if(0 < address(this).balance){

                uint collateralAmount = address(this).balance;

                WETH.deposit{value: collateralAmount}();

                WETH.approve(address(swapRouter), collateralAmount);
                
                params =
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: address(WETH),
                    tokenOut: address(DAI),
                    fee: poolFee[_bdCollaterals[j]],
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: collateralAmount,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

            }
            else{
                address underlyingCollateral = bdCollateral.underlying();
                uint collateralAmount = IERC20(underlyingCollateral).balanceOf(address(this));

                IERC20(underlyingCollateral).approve(address(swapRouter), collateralAmount);

                params =
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: underlyingCollateral,
                    tokenOut: address(DAI),
                    fee: poolFee[_bdCollaterals[j]],
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: collateralAmount,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });
            }
            swapRouter.exactInputSingle(params);
        }
        
        uint totalDebt = amounts[0] + premiums[0];
        DAI.approve(address(LENDING_POOL), totalDebt);
        
        return true;
    }

    function executeLiquidations(
        address[] memory _borrowers,
        uint256[] memory _repayAmounts,
        address[] memory _bdCollaterals,
        uint256 _totalRepayAmount
    ) external {


        bytes memory params = abi.encode(_borrowers,_repayAmounts,_bdCollaterals);
                                                         
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _totalRepayAmount;

        address[] memory assets = new address[](1);
        assets[0] = address(DAI);

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;
        LENDING_POOL.flashLoan(address(this), assets, amounts, modes, address(this), params, 0);

        DAI.safeTransfer(Treasury, DAI.balanceOf(address(this)));
        bUSD.safeTransfer(Treasury, bUSD.balanceOf(address(this)));
    }

    function retrieve(address token, uint256 amount) external onlyOwner {

        IERC20 tokenContract = IERC20(token);
        tokenContract.safeTransfer(msg.sender, amount);
    }

    function updateAddress(address _newAddress, uint8 _index) external onlyOwner(){

        if(_index==0){
            curvePool = ICurve(_newAddress);
            return;
        }
        if(_index==1){
            bUSD = IERC20(_newAddress);
            return;
        }
        if(_index==2){
            bdETH = bdToken(_newAddress);
            return;
        }
        if(_index==3){
            bdUSD = bdToken(_newAddress);
            return;
        }
        if(_index==3){
            swapRouter = ISwapRouter(_newAddress);
            return;
        }
        if(_index==4){
            Treasury = _newAddress;
        }
    }

    function updateFee(address _bdToken, uint24 _newFee) external onlyOwner(){

        poolFee[_bdToken] = _newFee; //USDC-DAI
    }

    receive() external payable {}
}