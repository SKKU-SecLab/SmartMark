
pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// MIT

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
}// MIT

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
}// MIT

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
}interface IUniswapV2Router02 {
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

}interface IUniswapV2Pair {
    function token0() external pure returns (address);


    function token1() external pure returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );


    function totalSupply() external view returns (uint256);

}interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);

}interface IXPriceOracle {
    function update() external;


    function consult(address token, uint256 amountIn)
        external
        view
        returns (uint256);

}// import "@uniswap/lib/contracts/libraries/Babylonian.sol";
library Babylonian {

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}pragma solidity ^0.7.0;



contract XPoolHandler is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    IUniswapV2Factory private constant UniSwapV2FactoryAddress =
        IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    IUniswapV2Router02 private constant uniswapRouter =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address private constant wethTokenAddress =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 private constant deadline =
        0xf000000000000000000000000000000000000000000000000000000000000000;

    uint256 public totalRaised;
    uint256 public xFitThreeshold;
    uint256 public fundsSplitFactor;

    event INTERNAL_SWAP(address sender, uint256 tokensBought);

    event SWAP_TOKENS(
        address sender,
        uint256 amount,
        address fromToken,
        address toToken
    );
    event POOL_LIQUIDITY(
        address sender,
        address pool,
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB
    );
    event REMOVE_LIQUIDITY(
        address sender,
        address pool,
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB
    );

    constructor(uint256 _xFitThreeshold, uint256 _fundsSplitFactor) {
        xFitThreeshold = _xFitThreeshold;
        fundsSplitFactor = _fundsSplitFactor;
    }

    function redeemLPTokens(
        address _FromUniPoolAddress,
        uint256 _lpTokensAmount
    ) internal nonReentrant returns (uint256, uint256) {

        IUniswapV2Pair pair = IUniswapV2Pair(_FromUniPoolAddress);

        require(address(pair) != address(0), "Error: Invalid Unipool Address");

        address token0 = pair.token0();
        address token1 = pair.token1();

        IERC20(_FromUniPoolAddress).safeApprove(address(uniswapRouter), 0);
        IERC20(_FromUniPoolAddress).safeApprove(
            address(uniswapRouter),
            _lpTokensAmount
        );
        uint256 amountA;
        uint256 amountB;
        if (token0 == wethTokenAddress || token1 == wethTokenAddress) {
            address _token = token0 == wethTokenAddress ? token1 : token0;
            (amountA, amountB) = uniswapRouter.removeLiquidityETH(
                _token,
                _lpTokensAmount,
                1,
                1,
                address(this),
                deadline
            );
            IERC20(_token).safeTransfer(msg.sender, amountA);
            Address.sendValue(msg.sender, amountB);
        } else {
            (amountA, amountB) = uniswapRouter.removeLiquidity(
                token0,
                token1,
                _lpTokensAmount,
                1,
                1,
                address(this),
                deadline
            );

            IERC20(token0).safeTransfer(msg.sender, amountA);
            IERC20(token1).safeTransfer(msg.sender, amountB);
        }
        emit REMOVE_LIQUIDITY(
            msg.sender,
            _FromUniPoolAddress,
            token0,
            amountA,
            token1,
            amountB
        );
        return (amountA, amountB);
    }

    function poolLiquidity(
        address _FromTokenContractAddress,
        address _pairAddress,
        address _xPoolOracle,
        uint256 _amount,
        uint256 _minPoolTokens
    ) internal nonReentrant returns (uint256, uint256) {

        uint256 toInvest = _pullTokens(_FromTokenContractAddress, _amount);
        uint256 LPBought;
        uint256 fundingRaised;
        (address _ToUniswapToken0, address _ToUniswapToken1) =
            _getPairTokens(_pairAddress);

        if (_FromTokenContractAddress == _ToUniswapToken0) {
            (LPBought, fundingRaised) = _poolLiquidityInternal(
                _FromTokenContractAddress,
                _ToUniswapToken1,
                _pairAddress,
                _xPoolOracle,
                toInvest
            );
        } else {
            (LPBought, fundingRaised) = _poolLiquidityInternal(
                _FromTokenContractAddress,
                _ToUniswapToken0,
                _pairAddress,
                _xPoolOracle,
                toInvest
            );
        }

        require(LPBought >= _minPoolTokens, "ERR: High Slippage");

        IXPriceOracle(_xPoolOracle).update();

        return (LPBought, fundingRaised);
    }

    function _getPairTokens(address _pairAddress)
        internal
        pure
        returns (address token0, address token1)
    {

        IUniswapV2Pair uniPair = IUniswapV2Pair(_pairAddress);
        token0 = uniPair.token0();
        token1 = uniPair.token1();
    }

    function _pullTokens(address token, uint256 amount)
        internal
        returns (uint256 value)
    {

        if (token == address(0)) {
            require(msg.value > 0, "No eth sent");
            return msg.value;
        }
        require(amount > 0, "Invalid token amount");
        require(msg.value == 0, "Eth sent with token");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        return amount;
    }

    struct TokenSwapVars {
        uint256 amountToSwap;
        uint256 destTokensAmount;
        uint256 fromTokensBought;
        uint256 toTokensBought;
        uint256 destTokenReserve;
        uint256 fundingRaised;
    }

    function _poolLiquidityInternal(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        address _pairAddress,
        address _xPoolOracle,
        uint256 _amount
    ) internal returns (uint256, uint256) {

        TokenSwapVars memory tokenSwapVars;

        tokenSwapVars.amountToSwap = _amount / 2;

        tokenSwapVars.destTokensAmount = IXPriceOracle(_xPoolOracle).consult(
            _FromTokenContractAddress,
            tokenSwapVars.amountToSwap
        );

        uint256 splittedFunds =
            _amount.sub(tokenSwapVars.amountToSwap).mul(fundsSplitFactor).div(
                1e18
            );

        tokenSwapVars.destTokenReserve = IERC20(_ToTokenContractAddress)
            .balanceOf(address(this));

        if (
            tokenSwapVars.destTokenReserve > xFitThreeshold &&
            tokenSwapVars.destTokensAmount <
            (tokenSwapVars.destTokenReserve.sub(xFitThreeshold))
        ) {
            tokenSwapVars.fromTokensBought = tokenSwapVars.amountToSwap;
            tokenSwapVars.toTokensBought = tokenSwapVars.destTokensAmount;
            swapSplittedFunds(
                _FromTokenContractAddress,
                _ToTokenContractAddress,
                splittedFunds
            );
            tokenSwapVars.fundingRaised = _amount
                .sub(tokenSwapVars.amountToSwap)
                .sub(splittedFunds);
            totalRaised = totalRaised.add(tokenSwapVars.fundingRaised);
            emit INTERNAL_SWAP(msg.sender, tokenSwapVars.toTokensBought);
        }
        else {
            (
                tokenSwapVars.fromTokensBought,
                tokenSwapVars.toTokensBought
            ) = _swapTokens(
                _FromTokenContractAddress,
                IUniswapV2Pair(_pairAddress),
                _amount
            );
        }

        (uint256 lpAmount, uint256 amountA, uint256 amountB) =
            _uniDeposit(
                _FromTokenContractAddress,
                _ToTokenContractAddress,
                tokenSwapVars.fromTokensBought,
                tokenSwapVars.toTokensBought,
                tokenSwapVars.fundingRaised > 0
            );

        emit POOL_LIQUIDITY(
            msg.sender,
            _pairAddress,
            _FromTokenContractAddress,
            amountA,
            _ToTokenContractAddress,
            amountB
        );

        return (lpAmount, tokenSwapVars.fundingRaised);
    }

    function swapSplittedFunds(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 _splittedFunds
    ) internal {

        _swapTokensInternal(
            _FromTokenContractAddress,
            _ToTokenContractAddress,
            _splittedFunds
        );
    }

    function _uniDeposit(
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 token0Bought,
        uint256 token1Bought,
        bool isInternalSwap
    )
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        IERC20(_ToUnipoolToken0).safeApprove(address(uniswapRouter), 0);
        IERC20(_ToUnipoolToken1).safeApprove(address(uniswapRouter), 0);

        IERC20(_ToUnipoolToken0).safeApprove(
            address(uniswapRouter),
            token0Bought
        );
        IERC20(_ToUnipoolToken1).safeApprove(
            address(uniswapRouter),
            token1Bought
        );

        (uint256 amountA, uint256 amountB, uint256 LP) =
            uniswapRouter.addLiquidity(
                _ToUnipoolToken0,
                _ToUnipoolToken1,
                token0Bought,
                token1Bought,
                1,
                1,
                address(this),
                deadline
            );

        if (token0Bought.sub(amountA) > 0) {
            IERC20(_ToUnipoolToken0).safeTransfer(
                msg.sender,
                token0Bought.sub(amountA)
            );
        }

        if (!isInternalSwap) {

            if (token1Bought.sub(amountB) > 0) {
                IERC20(_ToUnipoolToken1).safeTransfer(
                    msg.sender,
                    token1Bought.sub(amountB)
                );
            }
        }

        return (LP, amountA, amountB);
    }

    function _swapTokens(
        address _fromContractAddress,
        IUniswapV2Pair _pair,
        uint256 _amount
    ) internal returns (uint256 fromTokensBought, uint256 toTokensBought) {

        (address _ToUnipoolToken0, address _ToUnipoolToken1) =
            _getPairTokens(address(_pair));

        (uint256 res0, uint256 res1, ) = _pair.getReserves();

        if (_fromContractAddress == _ToUnipoolToken0) {
            uint256 amountToSwap = calculateSwapInAmount(res0, _amount);
            if (amountToSwap == 0) amountToSwap = _amount.div(2);
            toTokensBought = _swapTokensInternal(
                _fromContractAddress,
                _ToUnipoolToken1,
                amountToSwap
            );
            fromTokensBought = _amount.sub(amountToSwap);
        } else {
            uint256 amountToSwap = calculateSwapInAmount(res1, _amount);
            if (amountToSwap == 0) amountToSwap = _amount.div(2);
            toTokensBought = _swapTokensInternal(
                _fromContractAddress,
                _ToUnipoolToken0,
                amountToSwap
            );
            fromTokensBought = _amount.sub(amountToSwap);
        }
    }

    function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
        internal
        pure
        returns (uint256)
    {

        return
            Babylonian
                .sqrt(
                reserveIn.mul(userIn.mul(3988000) + reserveIn.mul(3988009))
            )
                .sub(reserveIn.mul(1997)) / 1994;
    }

    function _swapTokensInternal(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 tokenBought) {

        if (_FromTokenContractAddress == _ToTokenContractAddress) {
            return tokens2Trade;
        }
        IERC20(_FromTokenContractAddress).safeApprove(
            address(uniswapRouter),
            0
        );
        IERC20(_FromTokenContractAddress).safeApprove(
            address(uniswapRouter),
            tokens2Trade
        );

        address[] memory path = new address[](2);
        path[0] = _FromTokenContractAddress;
        path[1] = _ToTokenContractAddress;

        tokenBought = uniswapRouter.swapExactTokensForTokens(
            tokens2Trade,
            1,
            path,
            address(this),
            deadline
        )[path.length - 1];

        require(tokenBought > 0, "Error Swapping Tokens 2");
        emit SWAP_TOKENS(
            msg.sender,
            tokens2Trade,
            _FromTokenContractAddress,
            _ToTokenContractAddress
        );
    }

    function getEstimatedLPTokens(
        uint256 _amountIn,
        address _FromTokenContractAddress,
        address _pair
    ) public view returns (uint256 estimatedLps) {

        (uint256 res0, uint256 res1, ) = IUniswapV2Pair(_pair).getReserves();
        (address _ToUnipoolToken0, address _ToUnipoolToken1) =
            _getPairTokens(_pair);
        if (_FromTokenContractAddress == _ToUnipoolToken0) {
            uint256 amountToSwap = calculateSwapInAmount(res0, _amountIn);
            estimatedLps = _amountIn
                .sub(amountToSwap)
                .mul(IUniswapV2Pair(_pair).totalSupply())
                .div(res0);
        } else if (_FromTokenContractAddress == _ToUnipoolToken1) {
            uint256 amountToSwap = calculateSwapInAmount(res1, _amountIn);
            estimatedLps = _amountIn
                .sub(amountToSwap)
                .mul(IUniswapV2Pair(_pair).totalSupply())
                .div(res1);
        }
    }


    function setXFitThreeshold(uint256 _xFitThreeshold) public onlyOwner {

        xFitThreeshold = _xFitThreeshold;
    }

    function setFundsSplitFactor(uint256 _fundsSplitFactor) public onlyOwner {

        require(_fundsSplitFactor <= 1e18, "Invalid fundsSplitFactor Value");
        fundsSplitFactor = _fundsSplitFactor;
    }
}// MIT

pragma solidity ^0.7.0;

interface IErc20WithDecimals {

    function decimals() external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.7.0;



contract XFai is XPoolHandler, Pausable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 lastDepositedBlock;
    }


    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        IERC20 inputToken; // Token in which Single sided liquidity can be provided
        IXPriceOracle xPoolOracle;
        uint256 allocPoint; // How many allocation points assigned to this pool. XFITs to distribute per block.
        uint256 lastRewardBlock; // Last block number that XFITs distribution occurs.
        uint256 accXFITPerShare; // Accumulated XFITs per share, times 1e18. See below.
    }

    IERC20 public immutable XFIT;

    address public devaddr;
    uint256 public immutable bonusEndBlock;
    uint256 public XFITPerBlock;

    uint256 public totalLiquidity;

    uint256 public constant BONUS_MULTIPLIER = 2;

    uint256 public constant REWARD_FACTOR = 10;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public immutable startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        IERC20 _XFIT,
        address _devaddr,
        uint256 _XFITPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _xFitThreeshold,
        uint256 _fundsSplitFactor
    ) XPoolHandler(_xFitThreeshold, _fundsSplitFactor) {
        XFIT = _XFIT;
        devaddr = _devaddr;
        XFITPerBlock = _XFITPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(
        IERC20 _lpToken,
        IERC20 _inputToken,
        IXPriceOracle _xPoolOracle,
        bool _withUpdate
    ) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                inputToken: _inputToken,
                xPoolOracle: _xPoolOracle,
                allocPoint: 0,
                lastRewardBlock: lastRewardBlock,
                accXFITPerShare: 0
            })
        );
    }

    function _setInternal(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) internal {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function _getNormalisedLiquidity(IERC20 _inputToken, uint256 _lpAmount)
        internal
        view
        returns (uint256 normalizedAmount)
    {

        normalizedAmount = _lpAmount;
        if (IErc20WithDecimals(address(_inputToken)).decimals() == 6) {
            normalizedAmount = _lpAmount.mul(1e6);
        }
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _to.sub(bonusEndBlock)
                );
        }
    }

    function pendingXFIT(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accXFITPerShare = pool.accXFITPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 XFITReward =
                multiplier.mul(XFITPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accXFITPerShare = accXFITPerShare.add(
                XFITReward.mul(1e18).div(lpSupply)
            );
        }
        return user.amount.mul(accXFITPerShare).div(1e18).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    function massUpdateAllocationPoints() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            uint256 lpSupply = pool.lpToken.balanceOf(address(this));
            if (lpSupply == 0) {
                return;
            }
            if (totalLiquidity == 0) {
                _setInternal(pid, 0, false);
            } else {
                _setInternal(
                    pid,
                    _getNormalisedLiquidity(pool.inputToken, lpSupply)
                        .mul(1e18)
                        .div(totalLiquidity),
                    false
                );
            }
        }
    }

    function depositLPWithToken(
        uint256 _pid,
        uint256 _amount,
        uint256 _minPoolTokens
    ) public whenNotPaused {

        massUpdatePools();
        PoolInfo storage pool = poolInfo[_pid];
        (uint256 lpTokensBought, uint256 fundingRaised) =
            poolLiquidity(
                address(pool.inputToken),
                address(pool.lpToken),
                address(pool.xPoolOracle),
                _amount,
                _minPoolTokens
            );
        if (fundingRaised > 0) {
            pool.inputToken.safeTransfer(devaddr, fundingRaised);
        }
        _depositInternal(_pid, lpTokensBought, false);
    }

    function depositLP(uint256 _pid, uint256 _amount) public whenNotPaused {

        massUpdatePools();
        _depositInternal(_pid, _amount, true);
    }

    function withdrawLPWithToken(uint256 _pid, uint256 _amount)
        public
        whenNotPaused
    {

        massUpdatePools();
        uint256 actualWithdrawAmount = _withdrawInternal(_pid, _amount, false);
        PoolInfo storage pool = poolInfo[_pid];
        redeemLPTokens(address(pool.lpToken), actualWithdrawAmount);
    }

    function withdrawLP(uint256 _pid, uint256 _amount) public whenNotPaused {

        massUpdatePools();
        _withdrawInternal(_pid, _amount, true);
    }

    function _depositInternal(
        uint256 _pid,
        uint256 _amount,
        bool withLPTokens
    ) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accXFITPerShare).div(1e18).sub(
                    user.rewardDebt
                );
            if (pending > 0) {
                safeXFITTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            if (withLPTokens == true) {
                pool.lpToken.safeTransferFrom(
                    address(msg.sender),
                    address(this),
                    _amount
                );
            }
            user.amount = user.amount.add(_amount);
        }
        totalLiquidity = totalLiquidity.add(
            _getNormalisedLiquidity(pool.inputToken, _amount)
        );
        massUpdateAllocationPoints();
        user.rewardDebt = user.amount.mul(pool.accXFITPerShare).div(1e18);
        user.lastDepositedBlock = block.number;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function _withdrawInternal(
        uint256 _pid,
        uint256 _amount,
        bool withLPTokens
    ) internal returns (uint256) {

        massUpdatePools();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        uint256 pending =
            user.amount.mul(pool.accXFITPerShare).div(1e18).sub(
                user.rewardDebt
            );
        if (pending > 0) {
            safeXFITTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            require(
                block.number >= user.lastDepositedBlock.add(10),
                "Withdraw: Can only withdraw after 10 blocks"
            );
            user.amount = user.amount.sub(_amount);
            if (withLPTokens == true) {
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }
        }
        totalLiquidity = totalLiquidity.sub(
            _getNormalisedLiquidity(pool.inputToken, _amount)
        );
        massUpdateAllocationPoints();
        user.rewardDebt = user.amount.mul(pool.accXFITPerShare).div(1e18);
        emit Withdraw(msg.sender, _pid, _amount);
        return _amount;
    }

    function _updatePool(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        if (totalLiquidity > 0) {
            _setInternal(
                _pid,
                _getNormalisedLiquidity(pool.inputToken, lpSupply)
                    .mul(1e18)
                    .div(totalLiquidity),
                false
            );
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 XFITReward =
            multiplier.mul(XFITPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        XFIT.transfer(devaddr, XFITReward.div(REWARD_FACTOR));
        pool.accXFITPerShare = pool.accXFITPerShare.add(
            XFITReward.mul(1e18).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function safeXFITTransfer(address _to, uint256 _amount) internal {

        uint256 XFITBal = XFIT.balanceOf(address(this));
        if (_amount > XFITBal) {
            XFIT.transfer(_to, XFITBal);
        } else {
            XFIT.transfer(_to, _amount);
        }
    }


    function dev(address _devaddr) public onlyOwner {

        devaddr = _devaddr;
    }

    function setPriceOracle(uint256 _pid, IXPriceOracle _xPoolOracle)
        public
        onlyOwner
    {

        PoolInfo storage pool = poolInfo[_pid];
        pool.xPoolOracle = _xPoolOracle;
    }

    function pauseDistribution() public onlyOwner {

        _pause();
    }

    function resumeDistribution() public onlyOwner {

        _unpause();
    }

    function setXFITRewardPerBlock(uint256 _newReward) public onlyOwner {

        massUpdatePools();
        XFITPerBlock = _newReward;
    }

    function withdrawAdminXFIT(uint256 amount) public onlyOwner {

        XFIT.transfer(msg.sender, amount);
    }

    function withdrawAdminFunding(uint256 _pid, uint256 _amount)
        public
        onlyOwner
    {

        PoolInfo memory pool = poolInfo[_pid];
        pool.inputToken.safeTransfer(msg.sender, _amount);
    }
}