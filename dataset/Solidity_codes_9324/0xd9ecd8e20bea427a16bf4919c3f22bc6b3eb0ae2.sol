
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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

interface IUniV2Factory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IUniRouter01 {

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

}// MIT

pragma solidity ^0.8.0;


interface IUniRouter02 is IUniRouter01 {

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

}// MIT

pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}// MIT
pragma solidity ^0.8.0;



interface IStaking {

    function performanceFee() external view returns(uint256);

    function setServiceInfo(address _addr, uint256 _fee) external;

}

interface IFarm {

    function setBuyBackWallet(address _addr) external;

}

contract ShamanTreasury is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool private isInitialized;
    uint256 private TIME_UNIT = 1 days;

    IERC20  public token;
    address public dividendToken;
    address public pair;

    uint256 public period = 30;                         // 30 days
    uint256 public withdrawalLimit = 500;               // 5% of total supply
    uint256 public liquidityWithdrawalLimit = 2000;     // 20% of LP supply
    uint256 public buybackRate = 9500;                  // 95%
    uint256 public addLiquidityRate = 9400;             // 94%

    uint256 private startTime;
    uint256 private sumWithdrawals = 0;
    uint256 private sumLiquidityWithdrawals = 0;

    uint256 public performanceFee = 100;     // 1%
    uint256 public performanceLpFee = 200;   // 2%
    address public feeWallet = 0xE1f1dd010BBC2860F81c8F90Ea4E38dB949BB16F;

    address public uniRouterAddress;
    address[] public wNativeToTokenPath;
    uint256 public slippageFactor = 800;    // 20%
    uint256 public constant slippageFactorUL = 995;

    event TokenBuyBack(uint256 amountETH, uint256 amountToken);
    event LiquidityAdded(uint256 amountETH, uint256 amountToken, uint256 liquidity);
    event SetSwapConfig(address router, uint256 slipPage, address[] path);
    event TransferBuyBackWallet(address staking, address wallet);
    event LiquidityWithdrawn(uint256 amount);
    event Withdrawn(uint256 amount);

    event AddLiquidityRateUpdated(uint256 percent);
    event BuybackRateUpdated(uint256 percent);
    event PeriodUpdated(uint256 duration);
    event LiquidityWithdrawLimitUpdated(uint256 percent);
    event WithdrawLimitUpdated(uint256 percent);
    event ServiceInfoUpdated(address wallet, uint256 performanceFee, uint256 liquidityFee);

    constructor() {}
   
    function initialize(
        IERC20 _token,
        address _dividendToken,
        address _uniRouter,
        address[] memory _wNativeToTokenPath
    ) external onlyOwner {

        require(!isInitialized, "Already initialized");

        isInitialized = true;

        token = _token;
        dividendToken = _dividendToken;
        pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(_wNativeToTokenPath[0], address(token));

        uniRouterAddress = _uniRouter;
        wNativeToTokenPath = _wNativeToTokenPath;
    }

    function buyBack() external onlyOwner nonReentrant{

        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt.mul(performanceFee).div(10000);
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt.sub(_fee);
        }

        ethAmt = ethAmt.mul(buybackRate).div(10000);
        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, wNativeToTokenPath, address(this));
            emit TokenBuyBack(amounts[0], amounts[amounts.length - 1]);
        }
    }

    function addLiquidity() external onlyOwner nonReentrant{

        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt.mul(performanceLpFee).div(10000);
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt.sub(_fee);
        }

        ethAmt = ethAmt.mul(addLiquidityRate).div(10000).div(2);
        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, wNativeToTokenPath, address(this));
            uint256 _tokenAmt = amounts[amounts.length - 1];
            emit TokenBuyBack(amounts[0], _tokenAmt);
            
            (uint256 amountToken, uint256 amountETH, uint256 liquidity) = _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
            emit LiquidityAdded(amountETH, amountToken, liquidity);
        }
    }

    function withdraw(uint256 _amount) external onlyOwner {

        uint256 tokenAmt = token.balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp.sub(startTime) > period.mul(TIME_UNIT)) {
            startTime = block.timestamp;
            sumWithdrawals = 0;
        }

        uint256 limit = withdrawalLimit.mul(token.totalSupply()).div(10000);
        require(sumWithdrawals.add(_amount) <= limit, "exceed maximum withdrawal limit for 30 days");

        token.safeTransfer(msg.sender, _amount);
        emit Withdrawn(_amount);
    }

    function withdrawLiquidity(uint256 _amount) external onlyOwner {

        uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp.sub(startTime) > period.mul(TIME_UNIT)) {
            startTime = block.timestamp;
            sumLiquidityWithdrawals = 0;
        }

        uint256 limit = liquidityWithdrawalLimit.mul(IERC20(pair).totalSupply()).div(10000);
        require(sumLiquidityWithdrawals.add(_amount) <= limit, "exceed maximum LP withdrawal limit for 30 days");

        IERC20(pair).safeTransfer(msg.sender, _amount);
        emit LiquidityWithdrawn(_amount);
    }

    
    function emergencyWithdraw() external onlyOwner {

        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        tokenAmt = IERC20(pair).balanceOf(address(this));
        if(tokenAmt > 0) {
            IERC20(pair).transfer(msg.sender, tokenAmt);
        }

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0) {
            payable(msg.sender).transfer(ethAmt);
        }
    }

    function harvest() external onlyOwner {

        if(dividendToken == address(0x0)) {
            uint256 ethAmt = address(dividendToken).balance;
            if(ethAmt > 0) {
                payable(msg.sender).transfer(ethAmt);
            }
        } else {
            uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
            if(tokenAmt > 0) {
                IERC20(dividendToken).transfer(msg.sender, tokenAmt);
            }
        }
    }

    function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {

        require(_period >= 10, "small period");
        period = _period;
        emit PeriodUpdated(_period);
    }

    function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {

        require(_percent < 10000, "Invalid percentage");
        
        liquidityWithdrawalLimit = _percent;
        emit LiquidityWithdrawLimitUpdated(_percent);
    }

    function setWithdrawalLimit(uint256 _percent) external onlyOwner {

        require(_percent < 10000, "Invalid percentage");
        
        withdrawalLimit = _percent;
        emit WithdrawLimitUpdated(_percent);
    }
    
    function setBuybackRate(uint256 _percent) external onlyOwner {

        require(_percent < 10000, "Invalid percentage");

        buybackRate = _percent;
        emit BuybackRateUpdated(_percent);
    }

    function setAddLiquidityRate(uint256 _percent) external onlyOwner {

        require(_percent < 10000, "Invalid percentage");

        addLiquidityRate = _percent;
        emit AddLiquidityRateUpdated(_percent);
    }

    function setServiceInfo(address _wallet, uint256 _fee) external {

        require(msg.sender == feeWallet, "Invalid setter");
        require(_wallet != feeWallet && _wallet != address(0x0), "Invalid new wallet");
        require(_fee < 500, "invalid performance fee");
       
        feeWallet = _wallet;
        performanceFee = _fee;
        performanceLpFee = _fee.mul(2);

        emit ServiceInfoUpdated(_wallet, performanceFee, performanceLpFee);
    }
    
    function setSwapSettings(address _uniRouter, uint256 _slipPage, address[] memory _path) external onlyOwner {

        require(_slipPage < 1000, "Invalid percentage");

        uniRouterAddress = _uniRouter;
        slippageFactor = _slipPage;
        wNativeToTokenPath = _path;

        emit SetSwapConfig(_uniRouter, _slipPage, _path);
    }

    function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {

        require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
        IFarm(_farm).setBuyBackWallet(_addr);

        emit TransferBuyBackWallet(_farm, _addr);
    }

    function setStakingServiceInfo(address _staking, address _addr) external onlyOwner {

        require(_staking != address(0x0) && _addr != address(0x0), "Invalid Address");
        uint256 _fee = IStaking(_staking).performanceFee();
        IStaking(_staking).setServiceInfo(_addr, _fee);

        emit TransferBuyBackWallet(_staking, _addr);
    }

    function recoverWrongTokens(address _token) external onlyOwner {

        require(_token != address(token) && _token != dividendToken && _token != pair, "Cannot be token & dividend token, pair");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }


    function _safeSwapEth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256[] memory amounts) {

        amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length.sub(1)];

        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            amountOut.mul(slippageFactor).div(1000),
            _path,
            _to,
            block.timestamp.add(600)
        );
    }

    function _addLiquidityEth(
        address _token,
        uint256 _ethAmt,
        uint256 _tokenAmt,
        address _to
    ) internal returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {

        IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

        (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            address(_token),
            _tokenAmt,
            0,
            0,
            _to,
            block.timestamp.add(600)
        );

        IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
    }

    receive() external payable {}
}