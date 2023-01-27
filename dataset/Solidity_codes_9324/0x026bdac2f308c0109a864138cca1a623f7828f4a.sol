

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


pragma solidity 0.5.12;

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

}


pragma solidity 0.5.12;






library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

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
}

interface IERC20 {

    function decimals() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}

interface IUniswapV1Factory {

    function getExchange(address token)
        external
        view
        returns (address exchange);

}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);

}

interface IUniswapExchange {

    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256 tokens_bought);


    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_bought);


    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256 tokens_bought);


    function getTokenToEthInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256 eth_bought);


    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 eth_bought);


    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);


    function ethToTokenTransferInput(
        uint256 min_tokens,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256 tokens_bought);


    function balanceOf(address _owner) external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

}

interface IUniswapV2Pair {

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

}

contract UniswapV2_ZapIn is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using Address for address;
    bool private stopped = false;
    uint16 public goodwill;
    address public dzgoodwillAddress;
    uint256 public defaultSlippage;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    IUniswapV1Factory public UniSwapV1FactoryAddress = IUniswapV1Factory(
        0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
    );

    IUniswapV2Factory public UniSwapV2FactoryAddress = IUniswapV2Factory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );

    address wethTokenAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(
        uint16 _goodwill,
        address _dzgoodwillAddress,
        uint256 _slippage
    ) public {
        goodwill = _goodwill;
        dzgoodwillAddress = _dzgoodwillAddress;
        defaultSlippage = _slippage;
    }

    modifier stopInEmergency {

        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function ZapIn(
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount,
        uint256 slippage
    ) public payable nonReentrant stopInEmergency returns (uint256) {

        uint256 toInvest;
        if (_FromTokenContractAddress == address(0)) {
            require(msg.value > 0, "Error: ETH not sent");
            toInvest = msg.value;
        } else {
            require(msg.value == 0, "Error: ETH sent");
            require(_amount > 0, "Error: Invalid ERC amount");
            TransferHelper.safeTransferFrom(
                _FromTokenContractAddress,
                msg.sender,
                address(this),
                _amount
            );
            toInvest = _amount;
        }

        uint256 withSlippage = slippage > 0 && slippage < 10000
            ? slippage
            : defaultSlippage;

        uint256 LPBought = _performZapIn(
            _FromTokenContractAddress,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            toInvest,
            withSlippage
        );

        address _ToUniPoolAddress = UniSwapV2FactoryAddress.getPair(
            _ToUnipoolToken0,
            _ToUnipoolToken1
        );

        uint256 goodwillPortion = _transferGoodwill(
            _ToUniPoolAddress,
            LPBought
        );

        TransferHelper.safeTransfer(
            _ToUniPoolAddress,
            msg.sender,
            SafeMath.sub(LPBought, goodwillPortion)
        );
        return SafeMath.sub(LPBought, goodwillPortion);
    }

    function _performZapIn(
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount,
        uint256 slippage
    ) internal returns (uint256) {

        uint256 token0Bought;
        uint256 token1Bought;

        if (canSwapFromV2(_ToUnipoolToken0, _ToUnipoolToken1)) {
            (token0Bought, token1Bought) = exchangeTokensV2(
                _FromTokenContractAddress,
                _ToUnipoolToken0,
                _ToUnipoolToken1,
                _amount,
                slippage
            );
        } else if (
            canSwapFromV1(_ToUnipoolToken0, _ToUnipoolToken1, _amount, _amount)
        ) {
            (token0Bought, token1Bought) = exchangeTokensV1(
                _FromTokenContractAddress,
                _ToUnipoolToken0,
                _ToUnipoolToken1,
                _amount,
                slippage
            );
        }

        require(token0Bought > 0 && token0Bought > 0, "Could not exchange");

        TransferHelper.safeApprove(
            _ToUnipoolToken0,
            address(uniswapV2Router),
            token0Bought
        );

        TransferHelper.safeApprove(
            _ToUnipoolToken1,
            address(uniswapV2Router),
            token1Bought
        );

        (uint256 amountA, uint256 amountB, uint256 LP) = uniswapV2Router
            .addLiquidity(
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            token0Bought,
            token1Bought,
            1,
            1,
            address(this),
            now + 60
        );

        uint256 residue;
        if (SafeMath.sub(token0Bought, amountA) > 0) {
            if (canSwapFromV2(_ToUnipoolToken0, _FromTokenContractAddress)) {
                residue = swapFromV2(
                    _ToUnipoolToken0,
                    _FromTokenContractAddress,
                    SafeMath.sub(token0Bought, amountA),
                    10000
                );
            } else {
                TransferHelper.safeTransfer(
                    _ToUnipoolToken0,
                    msg.sender,
                    SafeMath.sub(token0Bought, amountA)
                );
            }
        }

        if (SafeMath.sub(token1Bought, amountB) > 0) {
            if (canSwapFromV2(_ToUnipoolToken1, _FromTokenContractAddress)) {
                residue += swapFromV2(
                    _ToUnipoolToken1,
                    _FromTokenContractAddress,
                    SafeMath.sub(token1Bought, amountB),
                    10000
                );
            } else {
                TransferHelper.safeTransfer(
                    _ToUnipoolToken1,
                    msg.sender,
                    SafeMath.sub(token1Bought, amountB)
                );
            }
        }

        if (residue > 0) {
            TransferHelper.safeTransfer(
                _FromTokenContractAddress,
                msg.sender,
                residue
            );
        }

        return LP;
    }

    function exchangeTokensV1(
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount,
        uint256 slippage
    ) internal returns (uint256 token0Bought, uint256 token1Bought) {

        IUniswapV2Pair pair = IUniswapV2Pair(
            UniSwapV2FactoryAddress.getPair(_ToUnipoolToken0, _ToUnipoolToken1)
        );
        (uint256 res0, uint256 res1, ) = pair.getReserves();
        if (_FromTokenContractAddress == address(0)) {
            token0Bought = _eth2Token(_ToUnipoolToken0, _amount, slippage);
            uint256 amountToSwap = calculateSwapInAmount(res0, token0Bought);
            if (amountToSwap <= 0) amountToSwap = SafeMath.div(token0Bought, 2);
            token1Bought = _eth2Token(_ToUnipoolToken1, amountToSwap, slippage);
            token0Bought = SafeMath.sub(token0Bought, amountToSwap);
        } else {
            if (_ToUnipoolToken0 == _FromTokenContractAddress) {
                uint256 amountToSwap = calculateSwapInAmount(res0, _amount);
                if (amountToSwap <= 0) amountToSwap = SafeMath.div(_amount, 2);
                token1Bought = _token2Token(
                    _FromTokenContractAddress,
                    address(this),
                    _ToUnipoolToken1,
                    amountToSwap,
                    slippage
                );

                token0Bought = SafeMath.sub(_amount, amountToSwap);
            } else if (_ToUnipoolToken1 == _FromTokenContractAddress) {
                uint256 amountToSwap = calculateSwapInAmount(res1, _amount);
                if (amountToSwap <= 0) amountToSwap = SafeMath.div(_amount, 2);
                token0Bought = _token2Token(
                    _FromTokenContractAddress,
                    address(this),
                    _ToUnipoolToken0,
                    amountToSwap,
                    slippage
                );

                token1Bought = SafeMath.sub(_amount, amountToSwap);
            } else {
                token0Bought = _token2Token(
                    _FromTokenContractAddress,
                    address(this),
                    _ToUnipoolToken0,
                    _amount,
                    slippage
                );
                uint256 amountToSwap = calculateSwapInAmount(
                    res0,
                    token0Bought
                );
                if (amountToSwap <= 0) amountToSwap = SafeMath.div(_amount, 2);

                token1Bought = _token2Token(
                    _FromTokenContractAddress,
                    address(this),
                    _ToUnipoolToken1,
                    amountToSwap,
                    slippage
                );
                token0Bought = SafeMath.sub(token0Bought, amountToSwap);
            }
        }
    }

    function exchangeTokensV2(
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount,
        uint256 slippage
    ) internal returns (uint256 token0Bought, uint256 token1Bought) {

        IUniswapV2Pair pair = IUniswapV2Pair(
            UniSwapV2FactoryAddress.getPair(_ToUnipoolToken0, _ToUnipoolToken1)
        );
        (uint256 res0, uint256 res1, ) = pair.getReserves();
        if (
            canSwapFromV2(_FromTokenContractAddress, _ToUnipoolToken0) &&
            canSwapFromV2(_ToUnipoolToken0, _ToUnipoolToken1)
        ) {
            token0Bought = swapFromV2(
                _FromTokenContractAddress,
                _ToUnipoolToken0,
                _amount,
                slippage
            );
            uint256 amountToSwap = calculateSwapInAmount(res0, token0Bought);
            if (amountToSwap <= 0) amountToSwap = SafeMath.div(token0Bought, 2);
            token1Bought = swapFromV2(
                _ToUnipoolToken0,
                _ToUnipoolToken1,
                amountToSwap,
                slippage
            );
            token0Bought = SafeMath.sub(token0Bought, amountToSwap);
        } else if (
            canSwapFromV2(_FromTokenContractAddress, _ToUnipoolToken1) &&
            canSwapFromV2(_ToUnipoolToken0, _ToUnipoolToken1)
        ) {
            token1Bought = swapFromV2(
                _FromTokenContractAddress,
                _ToUnipoolToken1,
                _amount,
                slippage
            );
            uint256 amountToSwap = calculateSwapInAmount(res1, token1Bought);
            if (amountToSwap <= 0) amountToSwap = SafeMath.div(token1Bought, 2);
            token0Bought = swapFromV2(
                _ToUnipoolToken1,
                _ToUnipoolToken0,
                amountToSwap,
                slippage
            );
            token1Bought = SafeMath.sub(token1Bought, amountToSwap);
        }
    }

    function canSwapFromV1(
        address _fromToken,
        address _toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) public view returns (bool) {

        require(
            _fromToken != address(0) || _toToken != address(0),
            "Invalid Exchange values"
        );

        if (_fromToken == address(0)) {
            IUniswapExchange toExchange = IUniswapExchange(
                UniSwapV1FactoryAddress.getExchange(_toToken)
            );
            uint256 tokenBalance = IERC20(_toToken).balanceOf(
                address(toExchange)
            );
            uint256 ethBalance = address(toExchange).balance;
            if (tokenBalance > toAmount && ethBalance > fromAmount) return true;
        } else if (_toToken == address(0)) {
            IUniswapExchange fromExchange = IUniswapExchange(
                UniSwapV1FactoryAddress.getExchange(_fromToken)
            );
            uint256 tokenBalance = IERC20(_fromToken).balanceOf(
                address(fromExchange)
            );
            uint256 ethBalance = address(fromExchange).balance;
            if (tokenBalance > fromAmount && ethBalance > toAmount) return true;
        } else {
            IUniswapExchange toExchange = IUniswapExchange(
                UniSwapV1FactoryAddress.getExchange(_toToken)
            );
            IUniswapExchange fromExchange = IUniswapExchange(
                UniSwapV1FactoryAddress.getExchange(_fromToken)
            );
            uint256 balance1 = IERC20(_fromToken).balanceOf(
                address(fromExchange)
            );
            uint256 balance2 = IERC20(_toToken).balanceOf(address(toExchange));
            if (balance1 > fromAmount && balance2 > toAmount) return true;
        }
        return false;
    }

    function canSwapFromV2(address _fromToken, address _toToken)
        public
        view
        returns (bool)
    {

        require(
            _fromToken != address(0) || _toToken != address(0),
            "Invalid Exchange values"
        );

        if (_fromToken == _toToken) return true;

        if (_fromToken == address(0) || _fromToken == wethTokenAddress) {
            if (_toToken == wethTokenAddress || _toToken == address(0))
                return true;
            IUniswapV2Pair pair = IUniswapV2Pair(
                UniSwapV2FactoryAddress.getPair(_toToken, wethTokenAddress)
            );
            if (_haveReserve(pair)) return true;
        } else if (_toToken == address(0) || _toToken == wethTokenAddress) {
            if (_fromToken == wethTokenAddress || _fromToken == address(0))
                return true;
            IUniswapV2Pair pair = IUniswapV2Pair(
                UniSwapV2FactoryAddress.getPair(_fromToken, wethTokenAddress)
            );
            if (_haveReserve(pair)) return true;
        } else {
            IUniswapV2Pair pair1 = IUniswapV2Pair(
                UniSwapV2FactoryAddress.getPair(_fromToken, wethTokenAddress)
            );
            IUniswapV2Pair pair2 = IUniswapV2Pair(
                UniSwapV2FactoryAddress.getPair(_toToken, wethTokenAddress)
            );
            IUniswapV2Pair pair3 = IUniswapV2Pair(
                UniSwapV2FactoryAddress.getPair(_fromToken, _toToken)
            );
            if (_haveReserve(pair1) && _haveReserve(pair2)) return true;
            if (_haveReserve(pair3)) return true;
        }
        return false;
    }

    function _haveReserve(IUniswapV2Pair pair) internal view returns (bool) {

        if (address(pair) != address(0)) {
            (uint256 res0, uint256 res1, ) = pair.getReserves();
            if (res0 > 0 && res1 > 0) {
                return true;
            }
        }
    }

    function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
        public
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

    function swapFromV2(
        address _fromToken,
        address _toToken,
        uint256 amount,
        uint256 slippage
    ) internal returns (uint256) {

        require(
            _fromToken != address(0) || _toToken != address(0),
            "Invalid Exchange values"
        );
        if (_fromToken == _toToken) return amount;

        require(canSwapFromV2(_fromToken, _toToken), "Cannot be exchanged");
        require(amount > 0, "Invalid amount");

        if (_fromToken == address(0)) {
            if (_toToken == wethTokenAddress) {
                IWETH(wethTokenAddress).deposit.value(amount)();
                return amount;
            }
            address[] memory path = new address[](2);
            path[0] = wethTokenAddress;
            path[1] = _toToken;
            uint256 minTokens = uniswapV2Router.getAmountsOut(amount, path)[1];
            minTokens = SafeMath.div(
                SafeMath.mul(minTokens, SafeMath.sub(10000, slippage)),
                10000
            );
            uint256[] memory amounts = uniswapV2Router
                .swapExactETHForTokens
                .value(amount)(minTokens, path, address(this), now + 180);
            return amounts[1];
        } else if (_toToken == address(0)) {
            if (_fromToken == wethTokenAddress) {
                IWETH(wethTokenAddress).withdraw(amount);
                return amount;
            }
            address[] memory path = new address[](2);
            TransferHelper.safeApprove(
                _fromToken,
                address(uniswapV2Router),
                amount
            );
            path[0] = _fromToken;
            path[1] = wethTokenAddress;
            uint256 minTokens = uniswapV2Router.getAmountsOut(amount, path)[1];
            minTokens = SafeMath.div(
                SafeMath.mul(minTokens, SafeMath.sub(10000, slippage)),
                10000
            );
            uint256[] memory amounts = uniswapV2Router.swapExactTokensForETH(
                amount,
                minTokens,
                path,
                address(this),
                now + 180
            );
            return amounts[1];
        } else {
            TransferHelper.safeApprove(
                _fromToken,
                address(uniswapV2Router),
                amount
            );
            uint256 returnedAmount = _swapTokenToTokenV2(
                _fromToken,
                _toToken,
                amount,
                slippage
            );
            require(returnedAmount > 0, "Error in swap");
            return returnedAmount;
        }
    }

    function _swapTokenToTokenV2(
        address _fromToken,
        address _toToken,
        uint256 amount,
        uint256 slippage
    ) internal returns (uint256) {

        IUniswapV2Pair pair1 = IUniswapV2Pair(
            UniSwapV2FactoryAddress.getPair(_fromToken, wethTokenAddress)
        );
        IUniswapV2Pair pair2 = IUniswapV2Pair(
            UniSwapV2FactoryAddress.getPair(_toToken, wethTokenAddress)
        );
        IUniswapV2Pair pair3 = IUniswapV2Pair(
            UniSwapV2FactoryAddress.getPair(_fromToken, _toToken)
        );

        uint256[] memory amounts;

        if (_haveReserve(pair3)) {
            address[] memory path = new address[](2);
            path[0] = _fromToken;
            path[1] = _toToken;
            uint256 minTokens = uniswapV2Router.getAmountsOut(amount, path)[1];
            minTokens = SafeMath.div(
                SafeMath.mul(minTokens, SafeMath.sub(10000, slippage)),
                10000
            );
            amounts = uniswapV2Router.swapExactTokensForTokens(
                amount,
                minTokens,
                path,
                address(this),
                now + 180
            );
            return amounts[1];
        } else if (_haveReserve(pair1) && _haveReserve(pair2)) {
            address[] memory path = new address[](3);
            path[0] = _fromToken;
            path[1] = wethTokenAddress;
            path[2] = _toToken;
            uint256 minTokens = uniswapV2Router.getAmountsOut(amount, path)[2];
            minTokens = SafeMath.div(
                SafeMath.mul(minTokens, SafeMath.sub(10000, slippage)),
                10000
            );
            amounts = uniswapV2Router.swapExactTokensForTokens(
                amount,
                minTokens,
                path,
                address(this),
                now + 180
            );
            return amounts[2];
        }
        return 0;
    }

    function _eth2Token(
        address _tokenContractAddress,
        uint256 _amount,
        uint256 slippage
    ) internal returns (uint256 tokenBought) {

        IUniswapExchange FromUniSwapExchangeContractAddress = IUniswapExchange(
            UniSwapV1FactoryAddress.getExchange(_tokenContractAddress)
        );

        uint256 minTokenBought = FromUniSwapExchangeContractAddress
            .getEthToTokenInputPrice(_amount);
        minTokenBought = SafeMath.div(
            SafeMath.mul(minTokenBought, SafeMath.sub(10000, slippage)),
            10000
        );

        tokenBought = FromUniSwapExchangeContractAddress
            .ethToTokenSwapInput
            .value(_amount)(minTokenBought, SafeMath.add(now, 300));
    }

    function _token2Eth(
        address _FromTokenContractAddress,
        uint256 tokens2Trade,
        address _toWhomToIssue,
        uint256 slippage
    ) internal returns (uint256 ethBought) {

        IUniswapExchange FromUniSwapExchangeContractAddress = IUniswapExchange(
            UniSwapV1FactoryAddress.getExchange(_FromTokenContractAddress)
        );

        TransferHelper.safeApprove(
            _FromTokenContractAddress,
            address(FromUniSwapExchangeContractAddress),
            tokens2Trade
        );

        uint256 minEthBought = FromUniSwapExchangeContractAddress
            .getTokenToEthInputPrice(tokens2Trade);
        minEthBought = SafeMath.div(
            SafeMath.mul(minEthBought, SafeMath.sub(10000, slippage)),
            10000
        );

        ethBought = FromUniSwapExchangeContractAddress.tokenToEthTransferInput(
            tokens2Trade,
            minEthBought,
            SafeMath.add(now, 300),
            _toWhomToIssue
        );
        require(ethBought > 0, "Error in swapping Eth: 1");
    }

    function _token2Token(
        address _FromTokenContractAddress,
        address _ToWhomToIssue,
        address _ToTokenContractAddress,
        uint256 tokens2Trade,
        uint256 slippage
    ) internal returns (uint256 tokenBought) {

        IUniswapExchange FromUniSwapExchangeContractAddress = IUniswapExchange(
            UniSwapV1FactoryAddress.getExchange(_FromTokenContractAddress)
        );

        TransferHelper.safeApprove(
            _FromTokenContractAddress,
            address(FromUniSwapExchangeContractAddress),
            tokens2Trade
        );

        uint256 minEthBought = FromUniSwapExchangeContractAddress
            .getTokenToEthInputPrice(tokens2Trade);
        minEthBought = SafeMath.div(
            SafeMath.mul(minEthBought, SafeMath.sub(10000, slippage)),
            10000
        );

        uint256 minTokenBought = FromUniSwapExchangeContractAddress
            .getEthToTokenInputPrice(minEthBought);
        minTokenBought = SafeMath.div(
            SafeMath.mul(minTokenBought, SafeMath.sub(10000, slippage)),
            10000
        );

        tokenBought = FromUniSwapExchangeContractAddress
            .tokenToTokenTransferInput(
            tokens2Trade,
            minTokenBought,
            minEthBought,
            SafeMath.add(now, 300),
            _ToWhomToIssue,
            _ToTokenContractAddress
        );
        require(tokenBought > 0, "Error in swapping ERC: 1");
    }

    function _transferGoodwill(
        address _tokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 goodwillPortion) {

        goodwillPortion = SafeMath.div(
            SafeMath.mul(tokens2Trade, goodwill),
            10000
        );

        if (goodwillPortion == 0) {
            return 0;
        }

        TransferHelper.safeTransfer(
            _tokenContractAddress,
            dzgoodwillAddress,
            goodwillPortion
        );
    }

    function updateSlippage(uint256 _newSlippage) public onlyOwner {

        require(
            _newSlippage > 0 && _newSlippage < 10000,
            "Slippage Value not allowed"
        );
        defaultSlippage = _newSlippage;
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {

        require(
            _new_goodwill >= 0 && _new_goodwill < 10000,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_new_dzgoodwillAddress(address _new_dzgoodwillAddress)
        public
        onlyOwner
    {

        dzgoodwillAddress = _new_dzgoodwillAddress;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {

        uint256 qty = _TokenAddress.balanceOf(address(this));
        TransferHelper.safeTransfer(address(_TokenAddress), owner(), qty);
    }

    function toggleContractActive() public onlyOwner {

        stopped = !stopped;
    }

    function withdraw() public onlyOwner {

        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

    function destruct() public onlyOwner {

        address payable _to = owner().toPayable();
        selfdestruct(_to);
    }

    function() external payable {}
}