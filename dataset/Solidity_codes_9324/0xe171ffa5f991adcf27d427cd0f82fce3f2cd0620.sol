
pragma solidity 0.8.6;

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
}

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



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

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
}
interface IUniswapV2Router01 {

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


    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

}

interface IController {

    function getClusterAmountFromEth(uint256 _ethAmount, address _cluster) external view returns (uint256);


    function addClusterToRegister(address indexAddr) external;


    function getDHVPriceInETH(address _cluster) external view returns (uint256);


    function getUnderlyingsInfo(address _cluster, uint256 _ethAmount)
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256,
            uint256
        );


    function getUnderlyingsAmountsFromClusterAmount(uint256 _clusterAmount, address _clusterAddress) external view returns (uint256[] memory);


    function getEthAmountFromUnderlyingsAmounts(uint256[] memory _underlyingsAmounts, address _cluster) external view returns (uint256);


    function adapters(address _cluster) external view returns (address);


    function dhvTokenInstance() external view returns (address);


    function getDepositComission(address _cluster, uint256 _ethValue) external view returns (uint256);


    function getRedeemComission(address _cluster, uint256 _ethValue) external view returns (uint256);


    function getClusterPrice(address _cluster) external view returns (uint256);

}

interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;

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

contract DexAdapterCore is Ownable {

    using SafeERC20 for IERC20;
    using Address for address;

    enum PathType {
        ETH_TO_TOKEN,
        TOKEN_TO_ETH,
        TOKEN_TO_TOKEN
    }

    address public router;
    address public WETH;
    address public USDT;
    mapping(address => address[]) public ethToToken;
    mapping(address => address[]) public tokenToEth;

    constructor(
        address _router,
        address _weth,
        address _usdt
    ) {
        require(_router != address(0) && _weth != address(0) && _usdt != address(0), "Zero address");
        router = _router;
        WETH = _weth;
        USDT = _usdt;
    }

    receive() external payable {}


    function swapETHToUnderlying(address underlying, uint256 underlyingAmount) external payable virtual {

        if (underlying == WETH) {
            IWETH(WETH).deposit{value: msg.value}();
            IERC20(WETH).safeTransfer(msg.sender, msg.value);
        } else {
            address[] memory path = getPath(PathType.ETH_TO_TOKEN, WETH, underlying);
            address _router = _getRouter(underlying);
            IUniswapV2Router01(_router).swapExactETHForTokens{value: msg.value}(underlyingAmount, path, msg.sender, block.timestamp + 100);
        }
    }

    function swapUnderlyingsToETH(uint256[] memory underlyingAmounts, address[] memory underlyings) external virtual {

        uint256 balance;
        for (uint256 i = 0; i < underlyings.length; i++) {
            if (underlyingAmounts[i] == 0) {
                continue;
            }
            IERC20(underlyings[i]).safeTransferFrom(msg.sender, address(this), underlyingAmounts[i]);
            if (underlyings[i] == WETH) {
                IWETH(WETH).withdraw(underlyingAmounts[i]);
                Address.sendValue(payable(msg.sender), underlyingAmounts[i]);
            } else {
                balance = IERC20(underlyings[i]).balanceOf(address(this));
                address[] memory path = getPath(PathType.TOKEN_TO_ETH, underlyings[i], WETH);
                address _router = _getRouter(underlyings[i]);

                IERC20(underlyings[i]).safeApprove(_router, 0);
                IERC20(underlyings[i]).safeApprove(_router, balance);
                IUniswapV2Router01(_router).swapExactTokensForETH(balance, 0, path, msg.sender, block.timestamp + 100);
            }
        }
    }

    function swapTokenToToken(
        uint256 _amountToSwap,
        address _tokenToSwap,
        address _tokenToReceive
    ) external virtual returns (uint256) {

        address[] memory path = getPath(PathType.TOKEN_TO_TOKEN, _tokenToSwap, _tokenToReceive);

        IERC20(_tokenToSwap).safeTransferFrom(msg.sender, address(this), _amountToSwap);
        IERC20(_tokenToSwap).safeApprove(router, 0);
        IERC20(_tokenToSwap).safeApprove(router, _amountToSwap);

        return IUniswapV2Router01(router).swapExactTokensForTokens(_amountToSwap, 0, path, msg.sender, block.timestamp + 100)[path.length - 1];
    }


    function getUnderlyingAmount(
        uint256 _amount,
        address _tokenToSwap,
        address _tokenToReceive
    ) external view virtual returns (uint256) {

        if (_tokenToSwap == _tokenToReceive) return _amount;

        address[] memory path = getPath(PathType.TOKEN_TO_TOKEN, _tokenToSwap, _tokenToReceive);
        address _router = _getRouter(_tokenToSwap);
        return IUniswapV2Router01(_router).getAmountsOut(_amount, path)[path.length - 1];
    }

    function getTokensPrices(address[] memory _tokens) external view virtual returns (uint256[] memory) {

        uint256[] memory prices = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_tokens[i] == WETH) {
                prices[i] = 1 ether;
            } else {
                address[] memory path = getPath(PathType.TOKEN_TO_ETH, _tokens[i], WETH);
                address _router = _getRouter(_tokens[i]);
                prices[i] = IUniswapV2Router01(_router).getAmountsOut(10**IERC20Metadata(_tokens[i]).decimals(), path)[path.length - 1];
            }
        }
        return prices;
    }

    function getEthPrice() external view virtual returns (uint256) {

        address[] memory path = getPath(PathType.ETH_TO_TOKEN, WETH, USDT);
        return IUniswapV2Router01(router).getAmountsOut(1 ether, path)[1];
    }

    function getDHVPriceInETH(address _dhvToken) external view virtual returns (uint256) {

        address[] memory path = getPath(PathType.TOKEN_TO_ETH, _dhvToken, WETH);
        return IUniswapV2Router01(router).getAmountsOut(1 ether, path)[1];
    }

    function getPath(
        PathType _pathType,
        address _tokenToSwap,
        address _tokenToReceive
    ) public view virtual returns (address[] memory) {

        address[] memory path;
        if (_pathType == PathType.ETH_TO_TOKEN) {
            path = ethToToken[_tokenToReceive];
        } else if (_pathType == PathType.TOKEN_TO_ETH) {
            path = tokenToEth[_tokenToSwap];
        }

        if (path.length > 0) {
            return path;
        }

        path = _tokenToSwap == WETH || _tokenToReceive == WETH ? new address[](2) : new address[](3);
        if (path.length == 2) {
            path[0] = _tokenToSwap;
            path[1] = _tokenToReceive;
        } else {
            path[0] = _tokenToSwap;
            path[1] = WETH;
            path[2] = _tokenToReceive;
        }

        return path;
    }

    function getEthAmountWithSlippage(uint256 _amount, address _tokenToSwap) external view virtual returns (uint256) {

        if (_tokenToSwap == WETH) {
            return _amount;
        }
        address[] memory path = getPath(PathType.ETH_TO_TOKEN, WETH, _tokenToSwap);
        address _router = _getRouter(_tokenToSwap);
        return IUniswapV2Router01(_router).getAmountsIn(_amount, path)[0];
    }


    function setPath(
        PathType _pathType,
        address _underlying,
        address[] memory _path
    ) public virtual onlyOwner {

        if (_pathType == PathType.ETH_TO_TOKEN) {
            ethToToken[_underlying] = _path;
        } else if (_pathType == PathType.TOKEN_TO_ETH) {
            tokenToEth[_underlying] = _path;
        }
    }


    function _getRouter(address _token) internal view virtual returns (address) {

        return router;
    }
}

contract UniswapAdapter is DexAdapterCore {

    constructor()
        DexAdapterCore(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), // Uniswap router
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // WETH
            address(0xdAC17F958D2ee523a2206206994597C13D831ec7) // USDT
        )
    {}
}