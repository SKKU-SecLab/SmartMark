




pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call.value(amount)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}


pragma solidity ^0.5.0;

contract Context {

    constructor() internal {}


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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

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


pragma solidity ^0.5.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IBFactory {

    function isBPool(address b) external view returns (bool);

}

interface IBpool {

    function isPublicSwap() external view returns (bool);


    function isBound(address t) external view returns (bool);


    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOut(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function getSpotPrice(address tokenIn, address tokenOut)
        external
        view
        returns (uint256 spotPrice);

}

interface IUniswapRouter02 {

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
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


    function swapETHForExactTokens(
        uint256 amountOut,
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

}

interface ICurve {

    function underlying_coins(int128 index) external view returns (address);


    function coins(int128 index) external view returns (address);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256 dy);


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minDy
    ) external;


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minDy
    ) external;

}

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256 amount) external;

}

interface ICompound {

    function markets(address cToken)
        external
        view
        returns (bool isListed, uint256 collateralFactorMantissa);


    function underlying() external returns (address);

}

interface ICompoundToken {

    function underlying() external view returns (address);


    function exchangeRateStored() external view returns (uint256);


    function mint(uint256 mintAmount) external returns (uint256);


    function redeem(uint256 redeemTokens) external returns (uint256);

}

interface ICompoundEther {

    function mint() external payable;


    function redeem(uint256 redeemTokens) external returns (uint256);

}

interface IIearn {

    function token() external view returns (address);


    function calcPoolValueInToken() external view returns (uint256);


    function deposit(uint256 _amount) external;


    function withdraw(uint256 _shares) external;

}

interface IAToken {

    function redeem(uint256 _amount) external;


    function underlyingAssetAddress() external returns (address);

}

interface IAaveLendingPoolAddressesProvider {

    function getLendingPool() external view returns (address);


    function getLendingPoolCore() external view returns (address payable);

}

interface IAaveLendingPool {

    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;

}

contract Zapper_Swap_General_V1_3 is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    IUniswapRouter02 private constant uniswapRouter = IUniswapRouter02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    IAaveLendingPoolAddressesProvider
        private constant lendingPoolAddressProvider = IAaveLendingPoolAddressesProvider(
        0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
    );

    IBFactory private constant BalancerFactory = IBFactory(
        0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd
    );

    address private constant renBTCCurveSwapContract = address(
        0x93054188d876f558f4a66B2EF1d97d16eDf0895B
    );

    address private constant sBTCCurveSwapContract = address(
        0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714
    );

    IWETH private constant wethContract = IWETH(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );

    address private constant ETHAddress = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    uint256
        private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;

    mapping(address => address) public cToken;
    mapping(address => address) public yToken;
    mapping(address => address) public aToken;

    bool public stopped = false;

    constructor() public {
        cToken[address(
            0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5
        )] = ETHAddress;
    }

    function addCToken(address[] memory _cToken) public onlyOwner {

        for (uint256 i = 0; i < _cToken.length; i++) {
            cToken[_cToken[i]] = ICompound(_cToken[i]).underlying();
        }
    }

    function addYToken(address[] memory _yToken) public onlyOwner {

        for (uint256 i = 0; i < _yToken.length; i++) {
            yToken[_yToken[i]] = IIearn(_yToken[i]).token();
        }
    }

    function addAToken(address[] memory _aToken) public onlyOwner {

        for (uint256 i = 0; i < _aToken.length; i++) {
            aToken[_aToken[i]] = IAToken(_aToken[i]).underlyingAssetAddress();
        }
    }

    function MultiExchangeSwap(
        address payable toWhomToIssue,
        address[] calldata path,
        uint256 amountIn,
        uint256 minTokenOut,
        uint8[] calldata starts,
        uint8[] calldata withPool,
        address[] calldata poolData
    )
        external
        payable
        nonReentrant
        stopInEmergency
        returns (uint256 tokensBought)
    {

        require(toWhomToIssue != address(0), "Invalid receiver address");
        require(path[0] != path[path.length - 1], "Cannot swap same tokens");

        tokensBought = _swap(
            path,
            _getTokens(path[0], amountIn),
            starts,
            withPool,
            poolData
        );

        require(tokensBought >= minTokenOut, "High Slippage");
        _sendTokens(toWhomToIssue, path[path.length - 1], tokensBought);
    }

    function _swap(
        address[] memory path,
        uint256 tokensToSwap,
        uint8[] memory starts,
        uint8[] memory withPool,
        address[] memory poolData
    ) internal returns (uint256) {

        address _to;
        uint8 poolIndex = 0;
        address[] memory _poolData;
        address _from = path[starts[0]];

        for (uint256 index = 0; index < withPool.length; index++) {
            uint256 endIndex = index == withPool.length.sub(1)
                ? path.length - 1
                : starts[index + 1];

            _to = path[endIndex];

            {
                if (withPool[index] == 2) {
                    _poolData = _getPath(path, starts[index], endIndex + 1);
                } else {
                    _poolData = new address[](1);
                    _poolData[0] = poolData[poolIndex++];
                }
            }

            tokensToSwap = _swapFromPool(
                _from,
                _to,
                tokensToSwap,
                withPool[index],
                _poolData
            );

            _from = _to;
        }
        return tokensToSwap;
    }

    function _swapFromPool(
        address fromToken,
        address toToken,
        uint256 amountIn,
        uint256 withPool,
        address[] memory poolData
    ) internal returns (uint256) {

        require(fromToken != toToken, "Cannot swap same tokens");
        require(withPool <= 3, "Invalid Exchange");

        if (withPool == 1) {
            return
                _swapWithBalancer(poolData[0], fromToken, toToken, amountIn, 1);
        } else if (withPool == 2) {
            return
                _swapWithUniswapV2(fromToken, toToken, poolData, amountIn, 1);
        } else if (withPool == 3) {
            return _swapWithCurve(poolData[0], fromToken, toToken, amountIn, 1);
        }
    }

    function _getPath(
        address[] memory addresses,
        uint256 _start,
        uint256 _end
    ) internal pure returns (address[] memory addressArray) {

        uint256 len = _end.sub(_start);
        require(len > 1, "ERR_UNIV2_PATH");
        addressArray = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            if (
                addresses[_start + i] == address(0) ||
                addresses[_start + i] == ETHAddress
            ) {
                addressArray[i] = address(wethContract);
            } else {
                addressArray[i] = addresses[_start + i];
            }
        }
    }

    function _sendTokens(
        address payable toWhomToIssue,
        address token,
        uint256 amount
    ) internal {

        if (token == ETHAddress || token == address(0)) {
            toWhomToIssue.transfer(amount);
        } else {
            IERC20(token).safeTransfer(toWhomToIssue, amount);
        }
    }

    function _swapWithBalancer(
        address bpoolAddress,
        address fromToken,
        address toToken,
        uint256 amountIn,
        uint256 minTokenOut
    ) internal returns (uint256 tokenBought) {

        require(BalancerFactory.isBPool(bpoolAddress), "Invalid balancer pool");

        IBpool bpool = IBpool(bpoolAddress);
        require(bpool.isPublicSwap(), "Swap not allowed for this pool");

        address _to = toToken;
        if (fromToken == address(0)) {
            wethContract.deposit.value(amountIn)();
            fromToken = address(wethContract);
        } else if (toToken == address(0)) {
            _to = address(wethContract);
        }
        require(bpool.isBound(fromToken), "From Token not bound");
        require(bpool.isBound(_to), "To Token not bound");

        IERC20(fromToken).safeApprove(bpoolAddress, amountIn);

        (tokenBought, ) = bpool.swapExactAmountIn(
            fromToken,
            amountIn,
            _to,
            minTokenOut,
            uint256(-1)
        );

        if (toToken == address(0)) {
            wethContract.withdraw(tokenBought);
        }
    }

    function _swapWithUniswapV2(
        address fromToken,
        address toToken,
        address[] memory path,
        uint256 amountIn,
        uint256 minTokenOut
    ) internal returns (uint256 tokenBought) {

        uint256 tokensUnwrapped = amountIn;
        address _fromToken = fromToken;
        if (fromToken != address(0)) {
            (tokensUnwrapped, _fromToken) = _unwrap(fromToken, amountIn);
            IERC20(_fromToken).safeApprove(
                address(uniswapRouter),
                tokensUnwrapped
            );
        }

        if (fromToken == address(0)) {
            tokenBought = uniswapRouter.swapExactETHForTokens.value(
                tokensUnwrapped
            )(minTokenOut, path, address(this), deadline)[path.length - 1];
        } else if (toToken == address(0)) {
            tokenBought = uniswapRouter.swapExactTokensForETH(
                tokensUnwrapped,
                minTokenOut,
                path,
                address(this),
                deadline
            )[path.length - 1];
        } else {
            tokenBought = uniswapRouter.swapExactTokensForTokens(
                tokensUnwrapped,
                minTokenOut,
                path,
                address(this),
                deadline
            )[path.length - 1];
        }
    }

    function _swapWithCurve(
        address curveExchangeAddress,
        address fromToken,
        address toToken,
        uint256 amountIn,
        uint256 minTokenOut
    ) internal returns (uint256 tokenBought) {

        require(
            curveExchangeAddress != address(0),
            "ERR_Invaid_curve_exchange"
        );
        ICurve curveExchange = ICurve(curveExchangeAddress);

        (uint256 tokensUnwrapped, address _fromToken) = _unwrap(
            fromToken,
            amountIn
        );

        IERC20(_fromToken).safeApprove(curveExchangeAddress, tokensUnwrapped);

        int128 i;
        int128 j;

        if (
            curveExchangeAddress == renBTCCurveSwapContract ||
            curveExchangeAddress == sBTCCurveSwapContract
        ) {
            int128 length = (curveExchangeAddress == renBTCCurveSwapContract)
                ? 2
                : 3;

            for (int128 index = 0; index < length; index++) {
                if (curveExchange.coins(index) == _fromToken) {
                    i = index;
                } else if (curveExchange.coins(index) == toToken) {
                    j = index;
                }
            }

            curveExchange.exchange(i, j, tokensUnwrapped, minTokenOut);
        } else {
            address compCurveSwapContract = address(
                0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56
            );
            address usdtCurveSwapContract = address(
                0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C
            );

            int128 length = 4;
            if (curveExchangeAddress == compCurveSwapContract) {
                length = 2;
            } else if (curveExchangeAddress == usdtCurveSwapContract) {
                length = 3;
            }

            for (int128 index = 0; index < length; index++) {
                if (curveExchange.underlying_coins(index) == _fromToken) {
                    i = index;
                } else if (curveExchange.underlying_coins(index) == toToken) {
                    j = index;
                }
            }

            curveExchange.exchange_underlying(
                i,
                j,
                tokensUnwrapped,
                minTokenOut
            );
        }

        if (toToken == ETHAddress || toToken == address(0)) {
            tokenBought = address(this).balance;
        } else {
            tokenBought = IERC20(toToken).balanceOf(address(this));
        }
    }

    function unwrapWeth(
        address payable _toWhomToIssue,
        address _FromTokenContractAddress,
        uint256 tokens2Trade,
        uint256 minTokens
    )
        public
        stopInEmergency
        returns (uint256 tokensUnwrapped, address toToken)
    {

        require(_toWhomToIssue != address(0), "Invalid receiver address");
        require(
            _FromTokenContractAddress == address(wethContract),
            "Only unwraps WETH, use unwrap() for other tokens"
        );

        uint256 initialEthbalance = address(this).balance;

        uint256 tokensToSwap = _getTokens(
            _FromTokenContractAddress,
            tokens2Trade
        );

        wethContract.withdraw(tokensToSwap);
        tokensUnwrapped = address(this).balance.sub(initialEthbalance);
        toToken = address(0);

        require(tokensUnwrapped >= minTokens, "High Slippage");

        _sendTokens(_toWhomToIssue, toToken, tokensUnwrapped);
    }

    function unwrap(
        address payable _toWhomToIssue,
        address _FromTokenContractAddress,
        uint256 tokens2Trade,
        uint256 minTokens
    )
        public
        stopInEmergency
        returns (uint256 tokensUnwrapped, address toToken)
    {

        require(_toWhomToIssue != address(0), "Invalid receiver address");
        uint256 tokensToSwap = _getTokens(
            _FromTokenContractAddress,
            tokens2Trade
        );

        (tokensUnwrapped, toToken) = _unwrap(
            _FromTokenContractAddress,
            tokensToSwap
        );

        require(tokensUnwrapped >= minTokens, "High Slippage");

        _sendTokens(_toWhomToIssue, toToken, tokensUnwrapped);
    }

    function _unwrap(address _FromTokenContractAddress, uint256 tokens2Trade)
        internal
        returns (uint256 tokensUnwrapped, address toToken)
    {

        uint256 initialEthbalance = address(this).balance;

        if (cToken[_FromTokenContractAddress] != address(0)) {
            require(
                ICompoundToken(_FromTokenContractAddress).redeem(
                    tokens2Trade
                ) == 0,
                "Error in unwrapping"
            );
            toToken = cToken[_FromTokenContractAddress];
            if (toToken == ETHAddress) {
                tokensUnwrapped = address(this).balance;
                tokensUnwrapped = tokensUnwrapped.sub(initialEthbalance);
            } else {
                tokensUnwrapped = IERC20(toToken).balanceOf(address(this));
            }
        } else if (yToken[_FromTokenContractAddress] != address(0)) {
            IIearn(_FromTokenContractAddress).withdraw(tokens2Trade);
            toToken = IIearn(_FromTokenContractAddress).token();
            tokensUnwrapped = IERC20(toToken).balanceOf(address(this));
        } else if (aToken[_FromTokenContractAddress] != address(0)) {
            IAToken(_FromTokenContractAddress).redeem(tokens2Trade);
            toToken = IAToken(_FromTokenContractAddress)
                .underlyingAssetAddress();
            if (toToken == ETHAddress) {
                tokensUnwrapped = address(this).balance;
                tokensUnwrapped = tokensUnwrapped.sub(initialEthbalance);
            } else {
                tokensUnwrapped = IERC20(toToken).balanceOf(address(this));
            }
        } else {
            toToken = _FromTokenContractAddress;
            tokensUnwrapped = tokens2Trade;
        }
    }

    function wrap(
        address payable _toWhomToIssue,
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade,
        uint256 minTokens,
        uint256 _wrapInto
    ) public payable stopInEmergency returns (uint256 tokensWrapped) {

        require(_toWhomToIssue != address(0), "Invalid receiver address");
        require(_wrapInto <= 3, "Invalid to Token");
        uint256 tokensToSwap = _getTokens(
            _FromTokenContractAddress,
            tokens2Trade
        );

        tokensWrapped = _wrap(
            _FromTokenContractAddress,
            _ToTokenContractAddress,
            tokensToSwap,
            _wrapInto
        );

        require(tokensWrapped >= minTokens, "High Slippage");

        _sendTokens(_toWhomToIssue, _ToTokenContractAddress, tokensWrapped);
    }

    function _wrap(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade,
        uint256 _wrapInto
    ) internal returns (uint256 tokensWrapped) {

        if (_wrapInto == 0) {
            require(
                _FromTokenContractAddress == address(0),
                "Cannot wrap into WETH"
            );
            require(
                _ToTokenContractAddress == address(wethContract),
                "Invalid toToken"
            );

            wethContract.deposit.value(tokens2Trade)();
            return tokens2Trade;
        } else if (_wrapInto == 1) {
            if (_FromTokenContractAddress == address(0)) {
                ICompoundEther(_ToTokenContractAddress).mint.value(
                    tokens2Trade
                )();
            } else {
                IERC20(_FromTokenContractAddress).safeApprove(
                    address(_ToTokenContractAddress),
                    tokens2Trade
                );
                ICompoundToken(_ToTokenContractAddress).mint(tokens2Trade);
            }
        } else if (_wrapInto == 2) {
            IERC20(_FromTokenContractAddress).safeApprove(
                address(_ToTokenContractAddress),
                tokens2Trade
            );
            IIearn(_ToTokenContractAddress).deposit(tokens2Trade);
        } else {
            if (_FromTokenContractAddress == address(0)) {
                IAaveLendingPool(lendingPoolAddressProvider.getLendingPool())
                    .deposit
                    .value(tokens2Trade)(ETHAddress, tokens2Trade, 0);
            } else {
                IERC20(_FromTokenContractAddress).safeApprove(
                    address(lendingPoolAddressProvider.getLendingPoolCore()),
                    tokens2Trade
                );

                IAaveLendingPool(lendingPoolAddressProvider.getLendingPool())
                    .deposit(_FromTokenContractAddress, tokens2Trade, 0);
            }
        }
        tokensWrapped = IERC20(_ToTokenContractAddress).balanceOf(
            address(this)
        );
    }

    function _getTokens(address token, uint256 amount)
        internal
        returns (uint256)
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

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {

        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.safeTransfer(owner(), qty);
    }

    function toggleContractActive() public onlyOwner {

        stopped = !stopped;
    }

    modifier stopInEmergency {

        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}