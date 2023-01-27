



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
}




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
}




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
}




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
}




pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
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



pragma solidity >=0.6.2;

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




pragma solidity ^0.8.0;

interface IBakeryV2Router {

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactBNBForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}




pragma solidity ^0.8.0;

interface IDODOV2Proxy {

    function dodoSwapV2ETHToToken(
        address toToken,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external payable returns (uint256 returnAmount);


    function dodoSwapV2TokenToETH(
        address fromToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external returns (uint256 returnAmount);


    function dodoSwapV2TokenToToken(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external returns (uint256 returnAmount);


    function dodoSwapV1(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external payable returns (uint256 returnAmount);

}




pragma solidity ^0.8.0;

interface IVyperSwap {

    function exchange(
        int128 tokenIndexFrom,
        int128 tokenIndexTo,
        uint256 dx,
        uint256 minDy
    ) external;

}




pragma solidity ^0.8.0;

interface IVyperUnderlyingSwap {

    function exchange(
        int128 tokenIndexFrom,
        int128 tokenIndexTo,
        uint256 dx,
        uint256 minDy
    ) external;


    function exchange_underlying(
        int128 tokenIndexFrom,
        int128 tokenIndexTo,
        uint256 dx,
        uint256 minDy
    ) external;

}




pragma solidity ^0.8.0;

interface IDoppleSwap {

    function getTokenIndex(address tokenAddress) external view returns (uint8);


    function swap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function ownableUpgradeableInitialize() internal {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            'Ownable: new owner is the zero address'
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;










contract ArkenDexV1 is Initializable, OwnableUpgradeable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public constant _DEADLINE_ = 2**256 - 1;
    address public constant _ETH_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address payable public _FEE_WALLET_ADDR_;
    address public _DODO_APPROVE_ADDR_;
    address public _WETH_;
    address public _WETH_DFYN_;

    event Swapped(
        address srcToken,
        address dstToken,
        uint256 amountIn,
        uint256 returnAmount
    );
    event UpdateVyper(address dexAddr, address[] tokens);
    event Received(address sender, uint256 amount);
    event FeeWalletUpdated(address newFeeWallet);
    event WETHUpdated(address newWETH);
    event WETHDfynUpdated(address newWETHDfyn);
    event DODOApproveUpdated(address newDODOApproveAddress);

    constructor() initializer {}

    function initialize(
        address _ownerAddress,
        address payable _feeWalletAddress,
        address _wrappedEther,
        address _wrappedEtherDfyn,
        address _dodoApproveAddress
    ) public initializer {

        _FEE_WALLET_ADDR_ = _feeWalletAddress;
        _DODO_APPROVE_ADDR_ = _dodoApproveAddress;
        _WETH_ = _wrappedEther;
        _WETH_DFYN_ = _wrappedEtherDfyn;
        OwnableUpgradeable.ownableUpgradeableInitialize();
        transferOwnership(_ownerAddress);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function updateFeeWallet(address payable _feeWallet) external onlyOwner {

        _FEE_WALLET_ADDR_ = _feeWallet;
        emit FeeWalletUpdated(_FEE_WALLET_ADDR_);
    }

    function updateWETH(address _weth) external onlyOwner {

        _WETH_ = _weth;
        emit WETHUpdated(_WETH_);
    }

    function updateWETHDfyn(address _weth_dfyn) external onlyOwner {

        _WETH_DFYN_ = _weth_dfyn;
        emit WETHDfynUpdated(_WETH_DFYN_);
    }

    function updateDODOApproveAddress(address _dodoApproveAddress)
        external
        onlyOwner
    {

        _DODO_APPROVE_ADDR_ = _dodoApproveAddress;
        emit DODOApproveUpdated(_DODO_APPROVE_ADDR_);
    }


    enum RouterInterface {
        UNISWAP,
        BAKERY,
        VYPER,
        VYPER_UNDERLYING,
        DOPPLE,
        DODO_V2,
        DODO_V1,
        DFYN
    }
    struct TradeRoute {
        address dexAddr;
        uint256 direction; // DODO
        uint256 part;
        int128 fromTokenIndex; // Vyper
        int128 toTokenIndex; // Vyper
        address[] paths;
        address[] lpAddresses; // Mostly DODO
        RouterInterface dexInterface;
    }
    struct MultiSwapDesctiption {
        IERC20 srcToken;
        IERC20 dstToken;
        TradeRoute[] routes;
        uint256 amountIn;
        uint256 amountOutMin;
        address payable to;
    }

    function multiTrade(MultiSwapDesctiption memory desc)
        external
        payable
        returns (uint256 returnAmount, uint256 blockNumber)
    {

        IERC20 dstToken = desc.dstToken;
        IERC20 srcToken = desc.srcToken;
        uint256 beforeDstAmt;
        if (_ETH_ == address(desc.dstToken)) {
            beforeDstAmt = desc.to.balance;
        } else {
            beforeDstAmt = dstToken.balanceOf(desc.to);
        }
        (returnAmount, blockNumber) = _trade(desc);
        if (_ETH_ == address(desc.dstToken)) {
            (bool sent, ) = desc.to.call{value: returnAmount}('');
            require(sent, 'Failed to send Ether');
        } else {
            dstToken.safeTransfer(desc.to, returnAmount);
        }
        uint256 afterDstAmt;
        if (_ETH_ == address(desc.dstToken)) {
            afterDstAmt = desc.to.balance;
        } else {
            afterDstAmt = dstToken.balanceOf(desc.to);
        }
        uint256 receivedAmt = afterDstAmt.sub(beforeDstAmt);
        require(
            receivedAmt > desc.amountOutMin,
            'Received token is not enough'
        );

        emit Swapped(
            address(srcToken),
            address(dstToken),
            desc.amountIn,
            returnAmount
        );
    }

    function _trade(MultiSwapDesctiption memory desc)
        internal
        returns (uint256 returnAmount, uint256 blockNumber)
    {

        require(desc.amountIn > 0, 'Amount-in needs to be more than zero');
        blockNumber = block.number;

        IERC20 srcToken = desc.srcToken;

        if (_ETH_ == address(desc.srcToken)) {
            require(msg.value == desc.amountIn, 'Value not match amountIn');
        } else {
            uint256 allowance = srcToken.allowance(msg.sender, address(this));
            require(allowance >= desc.amountIn, 'Allowance not enough');
            srcToken.safeTransferFrom(msg.sender, address(this), desc.amountIn);
        }

        TradeRoute[] memory routes = desc.routes;
        uint256 srcTokenAmount;

        for (uint256 i = 0; i < routes.length; i++) {
            TradeRoute memory route = routes[i];
            IERC20 startToken = IERC20(route.paths[0]);
            IERC20 endToken = IERC20(route.paths[route.paths.length - 1]);
            if (_ETH_ == address(startToken)) {
                srcTokenAmount = address(this).balance;
            } else {
                srcTokenAmount = startToken.balanceOf(address(this));
            }
            uint256 inputAmount = srcTokenAmount.mul(route.part).div(100000000); // 1% = 10^6
            require(
                route.part <= 100000000,
                'Route percentage can not exceed 100000000'
            );
            if (route.dexInterface == RouterInterface.BAKERY) {
                _tradeIBakery(
                    startToken,
                    endToken,
                    inputAmount,
                    0,
                    route.paths,
                    address(this),
                    route.dexAddr
                );
            } else if (route.dexInterface == RouterInterface.VYPER) {
                _tradeVyper(
                    startToken,
                    endToken,
                    inputAmount,
                    0,
                    route.dexAddr,
                    route.fromTokenIndex,
                    route.toTokenIndex
                );
            } else if (route.dexInterface == RouterInterface.VYPER_UNDERLYING) {
                _tradeVyperUnderlying(
                    startToken,
                    endToken,
                    inputAmount,
                    0,
                    route.dexAddr,
                    route.fromTokenIndex,
                    route.toTokenIndex
                );
            } else if (route.dexInterface == RouterInterface.DOPPLE) {
                _tradeDopple(
                    startToken,
                    endToken,
                    inputAmount,
                    0,
                    route.dexAddr
                );
            } else if (route.dexInterface == RouterInterface.DODO_V2) {
                _tradeIDODOV2(
                    startToken,
                    endToken,
                    inputAmount,
                    1, // DODO doesn't allow zero min amount
                    route.lpAddresses,
                    route.direction,
                    route.dexAddr
                );
            } else if (route.dexInterface == RouterInterface.DODO_V1) {
                _tradeIDODOV1(
                    startToken,
                    endToken,
                    inputAmount,
                    1, // DODO doesn't allow zero min amount
                    route.lpAddresses,
                    route.direction,
                    route.dexAddr
                );
            } else if (route.dexInterface == RouterInterface.DFYN) {
                _tradeIDfyn(
                    startToken,
                    endToken,
                    inputAmount,
                    0,
                    route.paths,
                    address(this),
                    route.dexAddr
                );
            } else {
                _tradeIUniswap(
                    startToken,
                    endToken,
                    inputAmount,
                    0,
                    route.paths,
                    address(this),
                    route.dexAddr
                );
            }
        }

        if (_ETH_ == address(desc.dstToken)) {
            returnAmount = address(this).balance;
        } else {
            returnAmount = desc.dstToken.balanceOf(address(this));
        }

        returnAmount = _collectFee(returnAmount, desc.dstToken);
        require(
            returnAmount >= desc.amountOutMin,
            'Return amount is not enough'
        );
    }


    function _collectFee(uint256 amount, IERC20 token)
        private
        returns (uint256 remainingAmount)
    {

        uint256 fee = amount.div(1000); // 0.1%
        require(fee < amount, 'Fee exceeds amount');
        if (_ETH_ == address(token)) {
            _FEE_WALLET_ADDR_.transfer(fee);
        } else {
            token.safeTransfer(_FEE_WALLET_ADDR_, fee);
        }
        remainingAmount = amount.sub(fee);
    }


    function _tradeIUniswap(
        IERC20 _src,
        IERC20 _dest,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address[] memory paths,
        address to,
        address dexAddr
    ) private returns (uint256[] memory amounts) {

        IUniswapV2Router02 uniRouter = IUniswapV2Router02(dexAddr);
        if (_ETH_ == address(_src)) {
            if (paths[0] == address(_ETH_)) {
                paths[0] = address(_WETH_);
            }
            amounts = uniRouter.swapExactETHForTokens{value: inputAmount}(
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        } else if (_ETH_ == address(_dest)) {
            if (paths[paths.length - 1] == address(_ETH_)) {
                paths[paths.length - 1] = address(_WETH_);
            }
            _src.safeApprove(dexAddr, inputAmount);
            amounts = uniRouter.swapExactTokensForETH(
                inputAmount,
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        } else {
            _src.safeApprove(dexAddr, inputAmount);
            amounts = uniRouter.swapExactTokensForTokens(
                inputAmount,
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        }
    }

    function _tradeIDfyn(
        IERC20 _src,
        IERC20 _dest,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address[] memory paths,
        address to,
        address dexAddr
    ) private returns (uint256[] memory amounts) {

        IUniswapV2Router02 uniRouter = IUniswapV2Router02(dexAddr);
        if (_ETH_ == address(_src)) {
            if (paths[0] == address(_ETH_)) {
                paths[0] = address(_WETH_DFYN_);
            }
            amounts = uniRouter.swapExactETHForTokens{value: inputAmount}(
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        } else if (_ETH_ == address(_dest)) {
            if (paths[paths.length - 1] == address(_ETH_)) {
                paths[paths.length - 1] = address(_WETH_DFYN_);
            }
            _src.safeApprove(dexAddr, inputAmount);
            amounts = uniRouter.swapExactTokensForETH(
                inputAmount,
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        } else {
            _src.safeApprove(dexAddr, inputAmount);
            amounts = uniRouter.swapExactTokensForTokens(
                inputAmount,
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        }
    }

    function _tradeIDODOV2(
        IERC20 _src,
        IERC20 _dest,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address[] memory dodoPairs,
        uint256 direction,
        address dexAddr
    ) private returns (uint256 amount) {

        IDODOV2Proxy dodoProxy = IDODOV2Proxy(dexAddr);
        if (_ETH_ == address(_src)) {
            amount = dodoProxy.dodoSwapV2ETHToToken{value: inputAmount}(
                address(_dest),
                minOutputAmount,
                dodoPairs,
                direction,
                false,
                _DEADLINE_
            );
        } else if (_ETH_ == address(_dest)) {
            _src.safeApprove(_DODO_APPROVE_ADDR_, inputAmount);
            amount = dodoProxy.dodoSwapV2TokenToETH(
                address(_src),
                inputAmount,
                minOutputAmount,
                dodoPairs,
                direction,
                false,
                _DEADLINE_
            );
        } else {
            _src.safeApprove(_DODO_APPROVE_ADDR_, inputAmount);
            amount = dodoProxy.dodoSwapV2TokenToToken(
                address(_src),
                address(_dest),
                inputAmount,
                minOutputAmount,
                dodoPairs,
                direction,
                false,
                _DEADLINE_
            );
        }
    }

    function _tradeIDODOV1(
        IERC20 _src,
        IERC20 _dest,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address[] memory dodoPairs,
        uint256 direction,
        address dexAddr
    ) private returns (uint256 amount) {

        IDODOV2Proxy dodoProxy = IDODOV2Proxy(dexAddr);
        if (_ETH_ == address(_src)) {
            amount = dodoProxy.dodoSwapV1{value: inputAmount}(
                address(_src),
                address(_dest),
                inputAmount,
                minOutputAmount,
                dodoPairs,
                direction,
                false,
                _DEADLINE_
            );
        } else {
            _src.safeApprove(_DODO_APPROVE_ADDR_, inputAmount);
            amount = dodoProxy.dodoSwapV1(
                address(_src),
                address(_dest),
                inputAmount,
                minOutputAmount,
                dodoPairs,
                direction,
                false,
                _DEADLINE_
            );
        }
    }

    function _tradeIBakery(
        IERC20 _src,
        IERC20 _dest,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address[] memory paths,
        address to,
        address dexAddr
    ) private returns (uint256[] memory amounts) {

        IBakeryV2Router bakeryRouter = IBakeryV2Router(dexAddr);
        if (_ETH_ == address(_src)) {
            if (paths[0] == address(_ETH_)) {
                paths[0] = address(_WETH_);
            }
            amounts = bakeryRouter.swapExactBNBForTokens{value: inputAmount}(
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        } else if (_ETH_ == address(_dest)) {
            if (paths[paths.length - 1] == address(_ETH_)) {
                paths[paths.length - 1] = address(_WETH_);
            }
            _src.safeApprove(dexAddr, inputAmount);
            amounts = bakeryRouter.swapExactTokensForBNB(
                inputAmount,
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        } else {
            _src.safeApprove(dexAddr, inputAmount);
            amounts = bakeryRouter.swapExactTokensForTokens(
                inputAmount,
                minOutputAmount,
                paths,
                to,
                _DEADLINE_
            );
        }
    }

    function _tradeVyper(
        IERC20 _src,
        IERC20,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address dexAddr,
        int128 fromTokenIndex,
        int128 toTokenIndex
    ) private {

        IVyperSwap vyperSwap = IVyperSwap(dexAddr);
        _src.safeApprove(dexAddr, inputAmount);
        vyperSwap.exchange(
            fromTokenIndex,
            toTokenIndex,
            inputAmount,
            minOutputAmount
        );
    }

    function _tradeVyperUnderlying(
        IERC20 _src,
        IERC20,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address dexAddr,
        int128 fromTokenIndex,
        int128 toTokenIndex
    ) private {

        IVyperUnderlyingSwap vyperSwap = IVyperUnderlyingSwap(dexAddr);
        _src.safeApprove(dexAddr, inputAmount);
        vyperSwap.exchange_underlying(
            fromTokenIndex,
            toTokenIndex,
            inputAmount,
            minOutputAmount
        );
    }

    function _tradeDopple(
        IERC20 _src,
        IERC20 _dest,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address dexAddr
    ) private returns (uint256 amount) {

        IDoppleSwap doppleSwap = IDoppleSwap(dexAddr);
        _src.safeApprove(dexAddr, inputAmount);
        uint8 tokenIndexFrom = doppleSwap.getTokenIndex(address(_src));
        uint8 tokenIndexTo = doppleSwap.getTokenIndex(address(_dest));
        amount = doppleSwap.swap(
            tokenIndexFrom,
            tokenIndexTo,
            inputAmount,
            minOutputAmount,
            _DEADLINE_
        );
    }

    function testTransfer(MultiSwapDesctiption memory desc)
        external
        payable
        returns (uint256 returnAmount, uint256 blockNumber)
    {

        IERC20 dstToken = desc.dstToken;
        (returnAmount, blockNumber) = _trade(desc);
        uint256 beforeAmount = dstToken.balanceOf(desc.to);
        dstToken.safeTransfer(desc.to, returnAmount);
        uint256 afterAmount = dstToken.balanceOf(desc.to);
        uint256 got = afterAmount.sub(beforeAmount);
        require(got == returnAmount, 'ArkenTester: Has Tax');
    }
}