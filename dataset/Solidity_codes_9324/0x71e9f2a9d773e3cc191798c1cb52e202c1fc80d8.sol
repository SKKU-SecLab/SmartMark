pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.0;




contract IOneSplitConsts {

    uint256 internal constant FLAG_DISABLE_UNISWAP = 0x01;
    uint256 internal constant DEPRECATED_FLAG_DISABLE_KYBER = 0x02; // Deprecated
    uint256 internal constant FLAG_DISABLE_BANCOR = 0x04;
    uint256 internal constant FLAG_DISABLE_OASIS = 0x08;
    uint256 internal constant FLAG_DISABLE_COMPOUND = 0x10;
    uint256 internal constant FLAG_DISABLE_FULCRUM = 0x20;
    uint256 internal constant FLAG_DISABLE_CHAI = 0x40;
    uint256 internal constant FLAG_DISABLE_AAVE = 0x80;
    uint256 internal constant FLAG_DISABLE_SMART_TOKEN = 0x100;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_ETH = 0x200; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_BDAI = 0x400;
    uint256 internal constant FLAG_DISABLE_IEARN = 0x400000000000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_COMPOUND = 0x1000;
    uint256 internal constant FLAG_DISABLE_CURVE_USDT = 0x2000;
    uint256 internal constant FLAG_DISABLE_CURVE_Y = 0x4000;
    uint256 internal constant FLAG_DISABLE_CURVE_BINANCE = 0x8000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_DAI = 0x10000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_USDC = 0x20000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_CURVE_SYNTHETIX = 0x40000;
    uint256 internal constant FLAG_DISABLE_WETH = 0x80000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_COMPOUND = 0x100000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_CHAI = 0x200000; // Works only when ETH<>DAI or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_AAVE = 0x400000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_IDLE = 0x800000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP = 0x1000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2 = 0x2000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ETH = 0x4000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_DAI = 0x8000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_USDC = 0x10000000;
    uint256 internal constant FLAG_DISABLE_ALL_SPLIT_SOURCES = 0x20000000;
    uint256 internal constant FLAG_DISABLE_ALL_WRAP_SOURCES = 0x40000000;
    uint256 internal constant FLAG_DISABLE_CURVE_PAX = 0x80000000;
    uint256 internal constant FLAG_DISABLE_CURVE_RENBTC = 0x100000000;
    uint256 internal constant FLAG_DISABLE_CURVE_TBTC = 0x200000000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_USDT = 0x400000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_WBTC = 0x800000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_TBTC = 0x1000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_RENBTC = 0x2000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_DFORCE_SWAP = 0x4000000000;
    uint256 internal constant FLAG_DISABLE_SHELL = 0x8000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN = 0x10000000000;
    uint256 internal constant FLAG_DISABLE_MSTABLE_MUSD = 0x20000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_SBTC = 0x40000000000;
    uint256 internal constant FLAG_DISABLE_DMM = 0x80000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_ALL = 0x100000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_ALL = 0x200000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ALL = 0x400000000000;
    uint256 internal constant FLAG_DISABLE_SPLIT_RECALCULATION = 0x800000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_ALL = 0x1000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_1 = 0x2000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_2 = 0x4000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_3 = 0x8000000000000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_UNISWAP_RESERVE = 0x10000000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_OASIS_RESERVE = 0x20000000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_BANCOR_RESERVE = 0x40000000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_ENABLE_REFERRAL_GAS_SPONSORSHIP = 0x80000000000000; // Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_COMP = 0x100000000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_KYBER_ALL = 0x200000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_1 = 0x400000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_2 = 0x800000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_3 = 0x1000000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_4 = 0x2000000000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN_BY_ORIGIN = 0x4000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_ALL = 0x8000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_ETH = 0x10000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_DAI = 0x20000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_USDC = 0x40000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_POOL_TOKEN = 0x80000000000000000;
    uint256 internal constant FLAG_DISABLE_DFYN= 0x800; //0x400000000000000000
}


contract IOneSplit is IOneSplitConsts {

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        );


    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );


    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags,
        bool isWrapper
    )
        public
        payable
        returns(uint256 returnAmount);

    
    function swapMulti(
        IERC20[] memory tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256[] memory flags,
        bool isWrapper
    )
        public
        payable
        returns(uint256 returnAmount);

}


contract IOneSplitMulti is IOneSplit {

    function getExpectedReturnWithGasMulti(
        IERC20[] memory tokens,
        uint256 amount,
        uint256[] memory parts,
        uint256[] memory flags,
        uint256[] memory destTokenEthPriceTimesGasPrices
    )
        public
        view
        returns(
            uint256[] memory returnAmounts,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );


}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;



interface IUniswapExchange {

    function getEthToTokenInputPrice(uint256 ethSold) external view returns (uint256 tokensBought);


    function getTokenToEthInputPrice(uint256 tokensSold) external view returns (uint256 ethBought);


    function ethToTokenSwapInput(uint256 minTokens, uint256 deadline)
        external
        payable
        returns (uint256 tokensBought);


    function tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint256 deadline)
        external
        returns (uint256 ethBought);


    function tokenToTokenSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint256 deadline,
        address tokenAddr
    ) external returns (uint256 tokensBought);

}pragma solidity ^0.5.0;



interface IUniswapFactory {

    function getExchange(IERC20 token) external view returns (IUniswapExchange exchange);

}pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity ^0.5.5;

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
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// GPL-3.0-or-later

pragma solidity >=0.5.16;

library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
}pragma solidity ^0.5.0;


library UniversalERC20 {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IERC20 token, address to, uint256 amount) internal returns(bool) {

        if (amount == 0) {
            return true;
        }

        if (isETH(token)) {
            address(uint160(to)).transfer(amount);
        } else {
            TransferHelper.safeTransfer(address(token), to, amount);
            return true;
        }
    }

    function universalTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {

        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            require(from == msg.sender && msg.value >= amount, "Wrong usage of ETH.universalTransferFrom()");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(msg.value.sub(amount));
            }
        } else {
            TransferHelper.safeTransferFrom(address(token), from, to, amount);
        }
    }

    function universalTransferFromSenderToThis(IERC20 token, uint256 amount) internal {

        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            if (msg.value > amount) {
                msg.sender.transfer(msg.value.sub(amount));
            }
        } else {
            TransferHelper.safeTransferFrom(address(token),msg.sender, address(this), amount);
        }
    }

    function universalApprove(IERC20 token, address to, uint256 amount) internal {

        if (!isETH(token)) {
            if (amount == 0) {
                TransferHelper.safeApprove(address(token), to, 0);
                return;
            }

            uint256 allowance = token.allowance(address(this), to);
            if (allowance < amount) {
                if (allowance > 0) {
                    TransferHelper.safeApprove(address(token), to, 0);
                }
               TransferHelper.safeApprove(address(token), to, amount);
            }
        }
    }

    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {

        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function universalDecimals(IERC20 token) internal view returns (uint256) {


        if (isETH(token)) {
            return 18;
        }

        (bool success, bytes memory data) = address(token).staticcall.gas(10000)(
            abi.encodeWithSignature("decimals()")
        );
        if (!success || data.length == 0) {
            (success, data) = address(token).staticcall.gas(10000)(
                abi.encodeWithSignature("DECIMALS()")
            );
        }

        return (success && data.length > 0) ? abi.decode(data, (uint256)) : 18;
    }

    function isETH(IERC20 token) internal pure returns(bool) {

        return (address(token) == address(ZERO_ADDRESS) || address(token) == address(ETH_ADDRESS));
    }

    function eq(IERC20 a, IERC20 b) internal pure returns(bool) {

        return a == b || (isETH(a) && isETH(b));
    }

    function notExist(IERC20 token) internal pure returns(bool) {

        return (address(token) == address(-1));
    }
}pragma solidity ^0.5.0;



interface IUniswapV2Exchange {

    function getReserves() external view returns(uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

}


library UniswapV2ExchangeLib {

    using Math for uint256;
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    function getReturn(
        IUniswapV2Exchange exchange,
        IERC20 fromToken,
        IERC20 destToken,
        uint amountIn
    ) internal view returns (uint256 result, bool needSync, bool needSkim) {

        uint256 reserveIn = fromToken.universalBalanceOf(address(exchange));
        uint256 reserveOut = destToken.universalBalanceOf(address(exchange));
        (uint112 reserve0, uint112 reserve1,) = exchange.getReserves();
        if (fromToken > destToken) {
            (reserve0, reserve1) = (reserve1, reserve0);
        }
        needSync = (reserveIn < reserve0 || reserveOut < reserve1);
        needSkim = !needSync && (reserveIn > reserve0 || reserveOut > reserve1);

        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(Math.min(reserveOut, reserve1));
        uint256 denominator = Math.min(reserveIn, reserve0).mul(1000).add(amountInWithFee);
        result = (denominator == 0) ? 0 : numerator.div(denominator);
    }
}pragma solidity ^0.5.0;



interface IUniswapV2Factory {

    function getPair(IERC20 tokenA, IERC20 tokenB) external view returns (IUniswapV2Exchange pair);

}pragma solidity ^0.5.0;



contract IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 amount) external;

}pragma solidity ^0.5.0;


contract IOneSplitView is IOneSplitConsts {

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) public view returns (uint256 returnAmount, uint256[] memory distribution);


    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        returns (
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );

}

library DisableFlags {

    function check(uint256 flags, uint256 flag) internal pure returns (bool) {

        return (flags & flag) != 0;
    }
}

contract OneSplitRoot is IOneSplitView {

    using SafeMath for uint256;
    using DisableFlags for uint256;

    using UniversalERC20 for IERC20;
    using UniversalERC20 for IWETH;
    using UniswapV2ExchangeLib for IUniswapV2Exchange;

    uint256 internal constant DEXES_COUNT = 3;
    IERC20 internal constant ETH_ADDRESS =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 internal constant ZERO_ADDRESS = IERC20(0);
    IWETH internal constant weth =
        IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    IUniswapFactory internal constant uniswapFactory =
        IUniswapFactory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    IUniswapV2Factory internal constant uniswapV2 =
        IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f); //Ganache: 0x88b50446977d217Eda84F28edFC514E0e17Bf351
    IUniswapV2Factory internal constant dfynExchange =
        IUniswapV2Factory(0xE7Fb3e833eFE5F9c441105EB65Ef8b261266423B);

    int256 internal constant VERY_NEGATIVE_VALUE = -1e72;

    function _findBestDistribution(
        uint256 s, // parts
        int256[][] memory amounts // exchangesReturns
    )
        internal
        pure
        returns (int256 returnAmount, uint256[] memory distribution)
    {

        uint256 n = amounts.length;

        int256[][] memory answer = new int256[][](n); // int[n][s+1]
        uint256[][] memory parent = new uint256[][](n); // int[n][s+1]

        for (uint256 i = 0; i < n; i++) {
            answer[i] = new int256[](s + 1);
            parent[i] = new uint256[](s + 1);
        }

        for (uint256 j = 0; j <= s; j++) {
            answer[0][j] = amounts[0][j];
            for (uint256 i = 1; i < n; i++) {
                answer[i][j] = -1e72;
            }
            parent[0][j] = 0;
        }

        for (uint256 i = 1; i < n; i++) {
            for (uint256 j = 0; j <= s; j++) {
                answer[i][j] = answer[i - 1][j];
                parent[i][j] = j;

                for (uint256 k = 1; k <= j; k++) {
                    if (answer[i - 1][j - k] + amounts[i][k] > answer[i][j]) {
                        answer[i][j] = answer[i - 1][j - k] + amounts[i][k];
                        parent[i][j] = j - k;
                    }
                }
            }
        }

        distribution = new uint256[](DEXES_COUNT);

        uint256 partsLeft = s;
        for (uint256 curExchange = n - 1; partsLeft > 0; curExchange--) {
            distribution[curExchange] =
                partsLeft -
                parent[curExchange][partsLeft];
            partsLeft = parent[curExchange][partsLeft];
        }

        returnAmount = (answer[n - 1][s] == VERY_NEGATIVE_VALUE)
            ? 0
            : answer[n - 1][s];
    }

    function _linearInterpolation(uint256 value, uint256 parts)
        internal
        pure
        returns (uint256[] memory rets)
    {

        rets = new uint256[](parts);
        for (uint256 i = 0; i < parts; i++) {
            rets[i] = value.mul(i + 1).div(parts);
        }
    }

    function _tokensEqual(IERC20 tokenA, IERC20 tokenB)
        internal
        pure
        returns (bool)
    {

        return ((tokenA.isETH() && tokenB.isETH()) || tokenA == tokenB);
    }
}

contract OneSplitViewWrapBase is IOneSplitView, OneSplitRoot {

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        public
        view
        returns (uint256 returnAmount, uint256[] memory distribution)
    {

        (returnAmount, , distribution) = this.getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            0
        );
    }

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        returns (
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        )
    {

        return
            _getExpectedReturnRespectingGasFloor(
                fromToken,
                destToken,
                amount,
                parts,
                flags,
                destTokenEthPriceTimesGasPrice
            );
    }

    function _getExpectedReturnRespectingGasFloor(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
        internal
        view
        returns (
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );

}

contract OneSplitView is IOneSplitView, OneSplitRoot {

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        public
        view
        returns (uint256 returnAmount, uint256[] memory distribution)
    {

        (returnAmount, , distribution) = getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            0
        );
    }

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        returns (
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        )
    {

        distribution = new uint256[](DEXES_COUNT);

        if (fromToken == destToken) {
            return (amount, 0, distribution);
        }


            function(IERC20, IERC20, uint256, uint256, uint256)
                view
                returns (uint256[] memory, uint256)[DEXES_COUNT]
                memory reserves
         = _getAllReserves(flags);

        int256[][] memory matrix = new int256[][](DEXES_COUNT);
        uint256[DEXES_COUNT] memory gases;
        bool atLeastOnePositive = false;
        for (uint256 i = 0; i < DEXES_COUNT; i++) {
            uint256[] memory rets;
            (rets, gases[i]) = reserves[i](
                fromToken,
                destToken,
                amount,
                parts,
                flags
            );

            int256 gas = int256(
                gases[i].mul(destTokenEthPriceTimesGasPrice).div(1e18)
            );
            matrix[i] = new int256[](parts + 1);
            for (uint256 j = 0; j < rets.length; j++) {
                matrix[i][j + 1] = int256(rets[j]) - gas;
                atLeastOnePositive =
                    atLeastOnePositive ||
                    (matrix[i][j + 1] > 0);
            }
        }

        if (!atLeastOnePositive) {
            for (uint256 i = 0; i < DEXES_COUNT; i++) {
                for (uint256 j = 1; j < parts + 1; j++) {
                    if (matrix[i][j] == 0) {
                        matrix[i][j] = VERY_NEGATIVE_VALUE;
                    }
                }
            }
        }

        (, distribution) = _findBestDistribution(parts, matrix);

        (returnAmount, estimateGasAmount) = _getReturnAndGasByDistribution(
            Args({
                fromToken: fromToken,
                destToken: destToken,
                amount: amount,
                parts: parts,
                flags: flags,
                destTokenEthPriceTimesGasPrice: destTokenEthPriceTimesGasPrice,
                distribution: distribution,
                matrix: matrix,
                gases: gases,
                reserves: reserves
            })
        );
        return (returnAmount, estimateGasAmount, distribution);
    }
 
    struct Args {
        IERC20 fromToken;
        IERC20 destToken;
        uint256 amount;
        uint256 parts;
        uint256 flags;
        uint256 destTokenEthPriceTimesGasPrice;
        uint256[] distribution;
        int256[][] matrix;
        uint256[DEXES_COUNT] gases;
        function(IERC20, IERC20, uint256, uint256, uint256)
            view
            returns (uint256[] memory, uint256)[DEXES_COUNT] reserves;
    }

    function _getReturnAndGasByDistribution(Args memory args)
        internal
        view
        returns (uint256 returnAmount, uint256 estimateGasAmount)
    {

        bool[DEXES_COUNT] memory exact = [
            true, // "Uniswap",
            true, // "Uniswap V2",
            true //DFYN
        ];

        for (uint256 i = 0; i < DEXES_COUNT; i++) {
            if (args.distribution[i] > 0) {
                if (
                    args.distribution[i] == args.parts ||
                    exact[i] ||
                    args.flags.check(FLAG_DISABLE_SPLIT_RECALCULATION)
                ) {
                    estimateGasAmount = estimateGasAmount.add(args.gases[i]);
                    int256 value = args.matrix[i][args.distribution[i]];
                    returnAmount = returnAmount.add(
                        uint256(
                            (value == VERY_NEGATIVE_VALUE ? 0 : value) +
                                int256(
                                    args
                                    .gases[i]
                                    .mul(args.destTokenEthPriceTimesGasPrice)
                                    .div(1e18)
                                )
                        )
                    );
                } else {
                    (uint256[] memory rets, uint256 gas) = args.reserves[i](
                        args.fromToken,
                        args.destToken,
                        args.amount.mul(args.distribution[i]).div(args.parts),
                        1,
                        args.flags
                    );
                    estimateGasAmount = estimateGasAmount.add(gas);
                    returnAmount = returnAmount.add(rets[0]);
                }
            }
        }
    }

    function _getAllReserves(uint256 flags)
        internal
        pure
        returns (
            function(IERC20, IERC20, uint256, uint256, uint256)
                view
                returns (uint256[] memory, uint256)[DEXES_COUNT]
                memory
        )
    {

        bool invert = flags.check(FLAG_DISABLE_ALL_SPLIT_SOURCES);
        return [
            invert !=
                flags.check(FLAG_DISABLE_UNISWAP_ALL | FLAG_DISABLE_UNISWAP)
                ? _calculateNoReturn
                : calculateUniswap,
            invert !=
                flags.check(
                    FLAG_DISABLE_UNISWAP_V2_ALL | FLAG_DISABLE_UNISWAP_V2
                )
                ? _calculateNoReturn
                : calculateUniswapV2,
            invert != flags.check(FLAG_DISABLE_DFYN)
                ? _calculateNoReturn
                : calculateDfyn
        ];
    }

    function _calculateUniswapFormula(
        uint256 fromBalance,
        uint256 toBalance,
        uint256 amount
    ) internal pure returns (uint256) {

        if (amount == 0) {
            return 0;
        }
        return
            amount.mul(toBalance).mul(997).div(
                fromBalance.mul(1000).add(amount.mul(997))
            );
    }

    function _calculateUniswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {

        rets = amounts;

        if (!fromToken.isETH()) {
            IUniswapExchange fromExchange = uniswapFactory.getExchange(
                fromToken
            );
            if (fromExchange == IUniswapExchange(0)) {
                return (new uint256[](rets.length), 0);
            }

            uint256 fromTokenBalance = fromToken.universalBalanceOf(
                address(fromExchange)
            );
            uint256 fromEtherBalance = address(fromExchange).balance;

            for (uint256 i = 0; i < rets.length; i++) {
                rets[i] = _calculateUniswapFormula(
                    fromTokenBalance,
                    fromEtherBalance,
                    rets[i]
                );
            }
        }

        if (!destToken.isETH()) {
            IUniswapExchange toExchange = uniswapFactory.getExchange(destToken);
            if (toExchange == IUniswapExchange(0)) {
                return (new uint256[](rets.length), 0);
            }

            uint256 toEtherBalance = address(toExchange).balance;
            uint256 toTokenBalance = destToken.universalBalanceOf(
                address(toExchange)
            );

            for (uint256 i = 0; i < rets.length; i++) {
                rets[i] = _calculateUniswapFormula(
                    toEtherBalance,
                    toTokenBalance,
                    rets[i]
                );
            }
        }

        return (
            rets,
            fromToken.isETH() || destToken.isETH() ? 60_000 : 100_000
        );
    }

    function calculateUniswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {

        return
            _calculateUniswap(
                fromToken,
                destToken,
                _linearInterpolation(amount, parts),
                flags
            );
    }

    function calculateDfyn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {

        return
            _calculateDfynswap(
                fromToken,
                destToken,
                _linearInterpolation(amount, parts),
                flags
            );
    }

    function calculateUniswapV2(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns (uint256[] memory rets, uint256 gas) {

        return
            _calculateUniswapV2(
                fromToken,
                destToken,
                _linearInterpolation(amount, parts),
                flags
            );
    }

    function _calculateDfynswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {

        rets = new uint256[](amounts.length);

        IERC20 fromTokenReal = fromToken.isETH() ? weth : fromToken;
        IERC20 destTokenReal = destToken.isETH() ? weth : destToken;
        IUniswapV2Exchange exchange = dfynExchange.getPair(
            fromTokenReal,
            destTokenReal
        );
        if (exchange != IUniswapV2Exchange(0)) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(
                address(exchange)
            );
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(
                address(exchange)
            );
            for (uint256 i = 0; i < amounts.length; i++) {
                rets[i] = _calculateUniswapFormula(
                    fromTokenBalance,
                    destTokenBalance,
                    amounts[i]
                );
            }
            return (rets, 50_000);
        }
    }

    function _calculateUniswapV2(
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {

        rets = new uint256[](amounts.length);

        IERC20 fromTokenReal = fromToken.isETH() ? weth : fromToken;
        IERC20 destTokenReal = destToken.isETH() ? weth : destToken;
        IUniswapV2Exchange exchange = uniswapV2.getPair(
            fromTokenReal,
            destTokenReal
        );
        if (exchange != IUniswapV2Exchange(0)) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(
                address(exchange)
            );
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(
                address(exchange)
            );
            for (uint256 i = 0; i < amounts.length; i++) {
                rets[i] = _calculateUniswapFormula(
                    fromTokenBalance,
                    destTokenBalance,
                    amounts[i]
                );
            }
            return (rets, 50_000);
        }
    }

    function _calculateNoReturn(
        IERC20, /*fromToken*/
        IERC20, /*destToken*/
        uint256, /*amount*/
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns (uint256[] memory rets, uint256 gas) {

        this;
        return (new uint256[](parts), 0);
    }
}

contract OneSplitBaseWrap is IOneSplit, OneSplitRoot {

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags // See constants in IOneSplit.sol
    ) internal {

        if (fromToken == destToken) {
            return;
        }

    }

    function _swapFloor(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256, /*flags*/ // See constants in IOneSplit.sol,
        bool isWrapper
    ) internal;

}

contract OneSplit is IOneSplit, OneSplitRoot {

    IOneSplitView public oneSplitView;

    constructor(IOneSplitView _oneSplitView) public {
        oneSplitView = _oneSplitView;
    }

    function() external payable {
        require(msg.sender != tx.origin);
    }

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns (uint256 returnAmount, uint256[] memory distribution)
    {

        (returnAmount, , distribution) = getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            0
        );
    }

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        returns (
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        )
    {

        return
            oneSplitView.getExpectedReturnWithGas(
                fromToken,
                destToken,
                amount,
                parts,
                flags,
                destTokenEthPriceTimesGasPrice
            );
    }
    
    function getExpectedReturnWithGasMulti(
        IERC20[] memory tokens,
        uint256 amount,
        uint256[] memory parts,
        uint256[] memory flags,
        uint256[] memory destTokenEthPriceTimesGasPrices
    )
        public
        view
        returns(
            uint256[] memory returnAmounts,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        )
    {

        uint256[] memory dist;

        returnAmounts = new uint256[](tokens.length - 1);
        for (uint i = 1; i < tokens.length; i++) {
            if (tokens[i - 1] == tokens[i]) {
                returnAmounts[i - 1] = (i == 1) ? amount : returnAmounts[i - 2];
                continue;
            }

            IERC20[] memory _tokens = tokens;

            (
                returnAmounts[i - 1],
                amount,
                dist
            ) = getExpectedReturnWithGas(
                _tokens[i - 1],
                _tokens[i],
                (i == 1) ? amount : returnAmounts[i - 2],
                parts[i - 1],
                flags[i - 1],
                destTokenEthPriceTimesGasPrices[i - 1]
            );
            estimateGasAmount = estimateGasAmount.add(amount);

            if (distribution.length == 0) {
                distribution = new uint256[](dist.length);
            }

            for (uint j = 0; j < distribution.length; j++) {
                distribution[j] = distribution[j].add(dist[j] << (8 * (i - 1)));
            }
        }
    }
    
    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags,
        bool isWrapper
    ) public payable returns (uint256 returnAmount) {

        if (!isWrapper) {
            fromToken.universalTransferFrom(msg.sender, address(this), amount);
        }

        uint256 confirmed = fromToken.universalBalanceOf(address(this));

        _swapFloor(
            fromToken,
            destToken,
            confirmed,
            distribution,
            flags,
            isWrapper
        );
        returnAmount = destToken.universalBalanceOf(address(this));
        require(
            returnAmount >= minReturn,
            "OneSplit: actual return amount is less than minReturn"
        );
        destToken.universalTransfer(msg.sender, returnAmount);
        fromToken.universalTransfer(
            msg.sender,
            fromToken.universalBalanceOf(address(this))
        );
        return returnAmount;
    }

    function swapMulti(
        IERC20[] memory tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256[] memory flags,
        bool isWrapper
    ) public payable returns (uint256 returnAmount) {

        if (!isWrapper) {
            tokens[0].universalTransferFrom(msg.sender, address(this), amount);
        }

        returnAmount = tokens[0].universalBalanceOf(address(this));
        for (uint256 i = 1; i < tokens.length; i++) {
            if (tokens[i - 1] == tokens[i]) {
                continue;
            }

            uint256[] memory dist = new uint256[](distribution.length);
            for (uint256 j = 0; j < distribution.length; j++) {
                dist[j] = distribution[j]; //>> (8 * (i - 1))) & 0xFF;
            }

            _swapFloor(
                tokens[i - 1],
                tokens[i],
                returnAmount,
                dist,
                flags[i - 1],
                isWrapper
            );
            returnAmount = tokens[i].universalBalanceOf(address(this));
            tokens[i - 1].universalTransfer(
                msg.sender,
                tokens[i - 1].universalBalanceOf(address(this))
            );
        }

        require(
            returnAmount >= minReturn,
            "OneSplit: actual return amount is less than minReturn"
        );
        tokens[tokens.length - 1].universalTransfer(msg.sender, returnAmount);
    }

    function _swapFloor(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags,
        bool isWrapper
    ) internal {


        _swap(fromToken, destToken, amount, 0, distribution, flags, isWrapper);
    }

    function _swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags, // See constants in IOneSplit.sol
        bool isWrapper
    ) internal returns (uint256 returnAmount) {

        if (fromToken == destToken) {
            return amount;
        }


        function(IERC20, IERC20, uint256, uint256)[DEXES_COUNT]
            memory reserves
        = [_swapOnUniswap, _swapOnUniswapV2, _swapOnDfyn];

        require(
            distribution.length <= reserves.length,
            "OneSplit: Distribution array should not exceed reserves array size"
        );

        uint256 parts = 0;
        uint256 lastNonZeroIndex = 0;
        for (uint256 i = 0; i < distribution.length; i++) {
            if (distribution[i] > 0) {
                parts = parts.add(distribution[i]);
                lastNonZeroIndex = i;
            }
        }

        if (parts == 0) {
            if (fromToken.isETH()) {
                msg.sender.transfer(msg.value);
                return msg.value;
            }
            return amount;
        }

        uint256 remainingAmount = fromToken.universalBalanceOf(address(this));

        for (uint256 i = 0; i < distribution.length; i++) {
            if (distribution[i] == 0) {
                continue;
            }

            uint256 swapAmount = amount.mul(distribution[i]).div(parts);
            if (i == lastNonZeroIndex) {
                swapAmount = remainingAmount;
            }
            remainingAmount -= swapAmount;
            reserves[i](fromToken, destToken, swapAmount, flags);
        }

        returnAmount = destToken.universalBalanceOf(address(this));
        require(
            returnAmount >= minReturn,
            "OneSplit: Return amount was not enough"
        );
        destToken.universalTransfer(msg.sender, returnAmount);
        fromToken.universalTransfer(
            msg.sender,
            fromToken.universalBalanceOf(address(this))
        );
    }

    function _swapOnUniswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal {

        uint256 returnAmount = amount;

        if (!fromToken.isETH()) {
            IUniswapExchange fromExchange = uniswapFactory.getExchange(
                fromToken
            );
            if (fromExchange != IUniswapExchange(0)) {
                fromToken.universalApprove(address(fromExchange), returnAmount);
                returnAmount = fromExchange.tokenToEthSwapInput(
                    returnAmount,
                    1,
                    now
                );
            }
        }

        if (!destToken.isETH()) {
            IUniswapExchange toExchange = uniswapFactory.getExchange(destToken);
            if (toExchange != IUniswapExchange(0)) {
                returnAmount = toExchange.ethToTokenSwapInput.value(
                    returnAmount
                )(1, now);
            }
        }
    }

    function _swapOnDfynInternal(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal returns (uint256 returnAmount) {

        if (fromToken.isETH()) {
            weth.deposit.value(amount)();
        }

        IERC20 fromTokenReal = fromToken.isETH() ? weth : fromToken;
        IERC20 toTokenReal = destToken.isETH() ? weth : destToken;
        IUniswapV2Exchange exchange = dfynExchange.getPair(
            fromTokenReal,
            toTokenReal
        );
        bool needSync;
        bool needSkim;
        (returnAmount, needSync, needSkim) = exchange.getReturn(
            fromTokenReal,
            toTokenReal,
            amount
        );
        if (needSync) {
            exchange.sync();
        } else if (needSkim) {
            exchange.skim(0x68a17B587CAF4f9329f0e372e3A78D23A46De6b5);
        }

        fromTokenReal.universalTransfer(address(exchange), amount);
        if (uint256(address(fromTokenReal)) < uint256(address(toTokenReal))) {
            exchange.swap(0, returnAmount, address(this), "");
        } else {
            exchange.swap(returnAmount, 0, address(this), "");
        }

        if (destToken.isETH()) {
            weth.withdraw(weth.balanceOf(address(this)));
        }
    }

    function _swapOnUniswapV2Internal(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 /*flags*/
    ) internal returns (uint256 returnAmount) {

        if (fromToken.isETH()) {
            weth.deposit.value(amount)();
        }

        IERC20 fromTokenReal = fromToken.isETH() ? weth : fromToken;
        IERC20 toTokenReal = destToken.isETH() ? weth : destToken;
        IUniswapV2Exchange exchange = uniswapV2.getPair(
            fromTokenReal,
            toTokenReal
        );
        bool needSync;
        bool needSkim;
        (returnAmount, needSync, needSkim) = exchange.getReturn(
            fromTokenReal,
            toTokenReal,
            amount
        );
        if (needSync) {
            exchange.sync();
        } else if (needSkim) {
            exchange.skim(0x68a17B587CAF4f9329f0e372e3A78D23A46De6b5);
        }

        fromTokenReal.universalTransfer(address(exchange), amount);
        if (uint256(address(fromTokenReal)) < uint256(address(toTokenReal))) {
            exchange.swap(0, returnAmount, address(this), "");
        } else {
            exchange.swap(returnAmount, 0, address(this), "");
        }

        if (destToken.isETH()) {
            weth.withdraw(weth.balanceOf(address(this)));
        }
    }

    function _swapOnUniswapV2(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {

        _swapOnUniswapV2Internal(fromToken, destToken, amount, flags);
    }

    function _swapOnDfyn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 flags
    ) internal {

        _swapOnDfynInternal(fromToken, destToken, amount, flags);
    }
}