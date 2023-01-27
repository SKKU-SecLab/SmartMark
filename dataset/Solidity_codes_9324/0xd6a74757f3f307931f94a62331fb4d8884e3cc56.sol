
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



contract BrewlabsLiquidityManager is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public uniRouterAddress;

    uint256 public fee = 100; // 1%
    address public treasury = 0xE1f1dd010BBC2860F81c8F90Ea4E38dB949BB16F;
    address public walletA = 0xE1f1dd010BBC2860F81c8F90Ea4E38dB949BB16F;

    address public wethAddress;
    address[] public wethToBrewsPath;
    uint256 public slippageFactor = 9500; // 5% default slippage tolerance
    uint256 public constant slippageFactorUL = 8000;
    
    bool public buyBackBurn = false;
    uint256 public buyBackLimit = 1 ether;
    address public constant buyBackAddress = 0xE1f1dd010BBC2860F81c8F90Ea4E38dB949BB16F;
    
    event WalletAUpdated(address _addr);
    event FeeUpdated(uint256 _fee);
    event BuyBackStatusChanged(bool _status);
    event BuyBackLimitUpdated(uint256 _limit);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    constructor() {}

    function initialize(
        address _uniRouterAddress,
        address[] memory _wethToBrewsPath
    ) external onlyOwner {

        require(_uniRouterAddress != address(0x0), "Invalid address");
        
        uniRouterAddress = _uniRouterAddress;
        wethToBrewsPath = _wethToBrewsPath;

        wethAddress = IUniRouter02(uniRouterAddress).WETH();
    }

    function addLiquidity(address token0, address token1, uint256 _amount0, uint256 _amount1, uint256 _slipPage) external payable nonReentrant returns (uint256 amountA, uint256 amountB, uint256 liquidity) {

        require(_amount0 > 0 && _amount1 > 0, "amount is zero");
        require(_slipPage < 10000, "slippage cannot exceed 100%");
        require(token0 != token1, "cannot use same token for pair");

        uint256 beforeAmt = IERC20(token0).balanceOf(address(this));
        IERC20(token0).transferFrom(msg.sender, address(this), _amount0);
        uint256 token0Amt = IERC20(token0).balanceOf(address(this)).sub(beforeAmt);
        token0Amt = token0Amt.mul(10000 - fee).div(10000);

        beforeAmt = IERC20(token1).balanceOf(address(this));
        IERC20(token1).transferFrom(msg.sender, address(this), _amount1);
        uint256 token1Amt = IERC20(token1).balanceOf(address(this)).sub(beforeAmt);
        token1Amt = token1Amt.mul(10000 - fee).div(10000);
        
        (amountA, amountB, liquidity) = _addLiquidity( token0, token1, token0Amt, token1Amt, _slipPage);

        token0Amt = IERC20(token0).balanceOf(address(this));
        token1Amt = IERC20(token1).balanceOf(address(this));
        IERC20(token0).transfer(walletA, token0Amt);
        IERC20(token1).transfer(walletA, token1Amt);
    }

    function _addLiquidity(address token0, address token1, uint256 _amount0, uint256 _amount1, uint256 _slipPage) internal returns (uint256, uint256, uint256) {

        IERC20(token0).safeIncreaseAllowance(uniRouterAddress, _amount0);
        IERC20(token1).safeIncreaseAllowance(uniRouterAddress, _amount1);

        return IUniRouter02(uniRouterAddress).addLiquidity(
                token0,
                token1,
                _amount0,
                _amount1,
                _amount0.mul(10000 - _slipPage).div(10000),
                _amount1.mul(10000 - _slipPage).div(10000),
                msg.sender,
                block.timestamp.add(600)
            );
    }

    function addLiquidityETH(address token, uint256 _amount, uint256 _slipPage) external payable nonReentrant returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {

        require(_amount > 0, "amount is zero");
        require(_slipPage < 10000, "slippage cannot exceed 100%");
        require(msg.value > 0, "amount is zero");

        uint256 beforeAmt = IERC20(token).balanceOf(address(this));
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        uint256 tokenAmt = IERC20(token).balanceOf(address(this)).sub(beforeAmt);
        tokenAmt = tokenAmt.mul(10000 - fee).div(10000);

        uint256 ethAmt = msg.value;
        ethAmt = ethAmt.mul(10000 - fee).div(10000);
    
        IERC20(token).safeIncreaseAllowance(uniRouterAddress, tokenAmt);        
        (amountToken, amountETH, liquidity) = _addLiquidityETH(token, tokenAmt, ethAmt, _slipPage);

        tokenAmt = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(walletA, tokenAmt);

        if(buyBackBurn) {
            buyBack();
        } else {
            ethAmt = address(this).balance;
            payable(treasury).transfer(ethAmt);
        }
    }

    function _addLiquidityETH(address token, uint256 _amount, uint256 _ethAmt, uint256 _slipPage) internal returns (uint256, uint256, uint256) {

        IERC20(token).safeIncreaseAllowance(uniRouterAddress, _amount);        
        
        return IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            token,
            _amount,
            _amount.mul(10000 - _slipPage).div(10000),
            _ethAmt.mul(10000 - _slipPage).div(10000),
            msg.sender,
            block.timestamp.add(600)
        );
    }

    function removeLiquidity(address token0, address token1, uint256 _amount) external nonReentrant returns (uint256 amountA, uint256 amountB){

        require(_amount > 0, "amount is zero");
        
        address pair = getPair(token0, token1);
        IERC20(pair).transferFrom(msg.sender, address(this), _amount);
        IERC20(pair).safeIncreaseAllowance(uniRouterAddress, _amount);

        uint256 beforeAmt0 = IERC20(token0).balanceOf(address(this));
        uint256 beforeAmt1 = IERC20(token1).balanceOf(address(this));                
        IUniRouter02(uniRouterAddress).removeLiquidity(
            token0,
            token1,
            _amount,
            0,
            0,
            address(this),
            block.timestamp.add(600)
        );
        uint256 afterAmt0 = IERC20(token0).balanceOf(address(this));
        uint256 afterAmt1 = IERC20(token1).balanceOf(address(this));

        amountA = afterAmt0.sub(beforeAmt0);
        amountB = afterAmt1.sub(beforeAmt1);
        IERC20(token0).safeTransfer(msg.sender, amountA.mul(10000 - fee).div(10000));
        IERC20(token1).safeTransfer(msg.sender, amountB.mul(10000 - fee).div(10000));

        IERC20(token0).transfer(walletA, amountA.mul(fee).div(10000));
        IERC20(token1).transfer(walletA, amountB.mul(fee).div(10000));

        amountA = amountA.mul(10000 - fee).div(10000);
        amountB = amountB.mul(10000 - fee).div(10000);
    }

    function removeLiquidityETH(address token, uint256 _amount) external nonReentrant returns (uint256 amountToken, uint256 amountETH){

        require(_amount > 0, "amount is zero");
        
        address pair = getPair(token, wethAddress);
        IERC20(pair).transferFrom(msg.sender, address(this), _amount);
        IERC20(pair).safeIncreaseAllowance(uniRouterAddress, _amount);
        
        uint256 beforeAmt0 = IERC20(token).balanceOf(address(this));
        uint256 beforeAmt1 = address(this).balance;        
        IUniRouter02(uniRouterAddress).removeLiquidityETH(
            token,
            _amount,
            0,
            0,
            address(this),                
            block.timestamp.add(600)
        );
        uint256 afterAmt0 = IERC20(token).balanceOf(address(this));
        uint256 afterAmt1 = address(this).balance;
        
        amountToken = afterAmt0.sub(beforeAmt0);
        amountETH = afterAmt1.sub(beforeAmt1);
        IERC20(token).safeTransfer(msg.sender, amountToken.mul(10000 - fee).div(10000));
        payable(msg.sender).transfer(amountETH.mul(10000 - fee).div(10000));

        IERC20(token).transfer(walletA, amountToken.mul(fee).div(10000));
        payable(treasury).transfer(amountETH.mul(fee).div(10000));

        amountToken = amountToken.mul(10000 - fee).div(10000);
        amountETH = amountETH.mul(10000 - fee).div(10000);
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 _amount) external nonReentrant returns (uint256 amountETH){

        require(_amount > 0, "amount is zero");
        
        address pair = getPair(token, wethAddress);
        IERC20(pair).transferFrom(msg.sender, address(this), _amount);
        IERC20(pair).safeIncreaseAllowance(uniRouterAddress, _amount);

        uint256 beforeAmt0 = IERC20(token).balanceOf(address(this));
        uint256 beforeAmt1 = address(this).balance;
        IUniRouter02(uniRouterAddress).removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            _amount,
            0,
            0,
            address(this),
            block.timestamp.add(600)
        );
        uint256 afterAmt0 = IERC20(token).balanceOf(address(this));
        uint256 afterAmt1 = address(this).balance;
        
        uint256 amountToken = afterAmt0.sub(beforeAmt0);
        amountETH = afterAmt1.sub(beforeAmt1);
        IERC20(token).safeTransfer(msg.sender, amountToken.mul(10000 - fee).div(10000));
        payable(msg.sender).transfer(amountETH.mul(10000 - fee).div(10000));

        IERC20(token).transfer(walletA, amountToken.mul(fee).div(10000));
        payable(treasury).transfer(amountETH.mul(fee).div(10000));

        amountToken = amountToken.mul(10000 - fee).div(10000);
        amountETH = amountETH.mul(10000 - fee).div(10000);
    }
   
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function updateWalletA(address _walletA) external onlyOwner {

        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }

    function updateFee(uint256 _fee) external onlyOwner {

        require(_fee < 2000, "fee cannot exceed 20%");

        fee = _fee;
        emit FeeUpdated(_fee);
    }

    function setBuyBackStatus(bool _status) external onlyOwner {

        buyBackBurn = _status;

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0 && _status == false) {
            payable(walletA).transfer(ethAmt);
        }

        emit BuyBackStatusChanged(_status);
    }

    function setTreasury(address _treasury) external onlyOwner {

        require(_treasury != address(0x0), "Invalid address");
        treasury = _treasury;
    }

    function updateBuyBackLimit(uint256 _limit) external onlyOwner {

        require(_limit > 0, "Invalid amount");

        buyBackLimit = _limit;
        emit BuyBackLimitUpdated(_limit);
    }

    function buyBack() internal {

        uint256 wethAmt = address(this).balance;

        if(wethAmt > buyBackLimit) {
             _safeSwapWeth(
                wethAmt,
                wethToBrewsPath,
                buyBackAddress
            );
        }
    }

    function _safeSwapWeth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {

        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length.sub(1)];

        IUniRouter02(uniRouterAddress).swapExactETHForTokens{value: _amountIn}(
            amountOut.mul(slippageFactor).div(10000),
            _path,
            _to,
            block.timestamp.add(600)
        );
    }

    function getPair(address token0, address token1) public view returns (address) {

        address factory = IUniRouter02(uniRouterAddress).factory();
        return IUniV2Factory(factory).getPair(token0, token1);
    }

    receive() external payable {}
}