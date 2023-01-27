


pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

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

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}



pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;



interface IOneRouterView {

    struct Swap {
        IERC20 destToken;
        uint256 flags;
        uint256 destTokenEthPriceTimesGasPrice;
        address[] disabledDexes;
    }

    struct Path {
        Swap[] swaps;
    }

    struct SwapResult {
        uint256[] returnAmounts;
        uint256[] estimateGasAmounts;
        uint256[][] distributions;
        address[][] dexes;
    }

    struct PathResult {
        SwapResult[] swaps;
    }

    function getReturn(
        IERC20 fromToken,
        uint256[] calldata amounts,
        Swap calldata swap
    )
        external
        view
        returns(
            Path[] memory paths,
            PathResult[] memory pathResults,
            SwapResult memory splitResult
        );


    function getSwapReturn(
        IERC20 fromToken,
        uint256[] calldata amounts,
        Swap calldata swap
    )
        external
        view
        returns(SwapResult memory result);


    function getPathReturn(
        IERC20 fromToken,
        uint256[] calldata amounts,
        Path calldata path
    )
        external
        view
        returns(PathResult memory result);


    function getMultiPathReturn(
        IERC20 fromToken,
        uint256[] calldata amounts,
        Path[] calldata paths
    )
        external
        view
        returns(
            PathResult[] memory pathResults,
            SwapResult memory splitResult
        );

}


abstract contract IOneRouter is IOneRouterView {
    struct Referral {
        address payable ref;
        uint256 fee;
    }

    struct SwapInput {
        IERC20 fromToken;
        IERC20 destToken;
        uint256 amount;
        uint256 minReturn;
        Referral referral;
    }

    struct SwapDistribution {
        uint256[] weights;
    }

    struct PathDistribution {
        SwapDistribution[] swapDistributions;
    }

    function makeSwap(
        SwapInput calldata input,
        Swap calldata swap,
        SwapDistribution calldata swapDistribution
    )
        external
        payable
        virtual
        returns(uint256 returnAmount);

    function makePathSwap(
        SwapInput calldata input,
        Path calldata path,
        PathDistribution calldata pathDistribution
    )
        external
        payable
        virtual
        returns(uint256 returnAmount);

    function makeMultiPathSwap(
        SwapInput calldata input,
        Path[] calldata paths,
        PathDistribution[] calldata pathDistributions,
        SwapDistribution calldata interPathsDistribution
    )
        external
        payable
        virtual
        returns(uint256 returnAmount);
}



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.6.0;




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
}



pragma solidity ^0.6.0;





library UniERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 public constant ZERO_ADDRESS = IERC20(0);

    function isETH(IERC20 token) internal pure returns(bool) {

        return (token == ZERO_ADDRESS || token == ETH_ADDRESS);
    }

    function uniBalanceOf(IERC20 token, address account) internal view returns (uint256) {

        if (isETH(token)) {
            return account.balance;
        } else {
            return token.balanceOf(account);
        }
    }

    function uniTransfer(IERC20 token, address payable to, uint256 amount) internal {

        if (amount > 0) {
            if (isETH(token)) {
                to.transfer(amount);
            } else {
                token.safeTransfer(to, amount);
            }
        }
    }

    function uniTransferFromSender(IERC20 token, address payable target, uint256 amount) internal {

        if (amount > 0) {
            if (isETH(token)) {
                require(msg.value >= amount, "UniERC20: not enough value");
                target.transfer(amount);
                if (msg.value > amount) {
                    msg.sender.transfer(msg.value.sub(amount));
                }
            } else {
                token.safeTransferFrom(msg.sender, target, amount);
            }
        }
    }

    function uniApprove(IERC20 token, address to, uint256 amount) internal {

        if (!isETH(token)) {
            if (amount == 0) {
                token.safeApprove(to, 0);
                return;
            }

            uint256 allowance = token.allowance(address(this), to);
            if (allowance < amount) {
                if (allowance > 0) {
                    token.safeApprove(to, 0);
                }
                token.safeApprove(to, amount);
            }
        }
    }

    function uniDecimals(IERC20 token) internal view returns (uint256) {

        if (isETH(token)) {
            return 18;
        }

        (bool success, bytes memory data) = address(token).staticcall{ gas: 20000 }(
            abi.encodeWithSignature("decimals()")
        );
        if (!success) {
            (success, data) = address(token).staticcall{ gas: 20000 }(
                abi.encodeWithSignature("DECIMALS()")
            );
        }

        return success ? abi.decode(data, (uint8)) : 18;
    }

    function uniSymbol(IERC20 token) internal view returns(string memory) {

        if (isETH(token)) {
            return "ETH";
        }

        (bool success, bytes memory data) = address(token).staticcall{ gas: 20000 }(
            abi.encodeWithSignature("symbol()")
        );
        if (!success) {
            (success, data) = address(token).staticcall{ gas: 20000 }(
                abi.encodeWithSignature("SYMBOL()")
            );
        }

        if (success && data.length >= 96) {
            (uint256 offset, uint256 len) = abi.decode(data, (uint256, uint256));
            if (offset == 0x20 && len > 0 && len <= 256) {
                return string(abi.decode(data, (bytes)));
            }
        }

        if (success && data.length == 32) {
            uint len = 0;
            while (len < data.length && data[len] >= 0x20 && data[len] <= 0x7E) {
                len++;
            }

            if (len > 0) {
                bytes memory result = new bytes(len);
                for (uint i = 0; i < len; i++) {
                    result[i] = data[i];
                }
                return string(result);
            }
        }

        return _toHex(address(token));
    }

    function _toHex(address account) private pure returns(string memory) {

        return _toHex(abi.encodePacked(account));
    }

    function _toHex(bytes memory data) private pure returns(string memory) {

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        uint j = 2;
        for (uint i = 0; i < data.length; i++) {
            uint a = uint8(data[i]) >> 4;
            uint b = uint8(data[i]) & 0x0f;
            str[j++] = byte(uint8(a + 48 + (a/10)*39));
            str[j++] = byte(uint8(b + 48 + (b/10)*39));
        }

        return string(str);
    }
}



pragma solidity ^0.6.0;



interface IMooniswapRegistry {

    function pools(IERC20 token1, IERC20 token2) external view returns(IMooniswap);

    function isPool(address addr) external view returns(bool);

}


interface IMooniswap {

    function fee() external view returns (uint256);

    function tokens(uint256 i) external view returns (IERC20);

    function getBalanceForAddition(IERC20 token) external view returns(uint256);

    function getBalanceForRemoval(IERC20 token) external view returns(uint256);

    function getReturn(IERC20 fromToken, IERC20 destToken, uint256 amount) external view returns(uint256 returnAmount);


    function deposit(uint256[] calldata amounts, uint256[] calldata minAmounts) external payable returns(uint256 fairSupply);

    function withdraw(uint256 amount, uint256[] calldata minReturns) external;

    function swap(IERC20 fromToken, IERC20 destToken, uint256 amount, uint256 minReturn, address referral) external payable returns(uint256 returnAmount);

}



pragma solidity ^0.6.0;



interface ISource {

    function calculate(IERC20 fromToken, uint256[] calldata amounts, IOneRouterView.Swap calldata swap)
        external view returns(uint256[] memory rets, address dex, uint256 gas);


    function swap(IERC20 fromToken, IERC20 destToken, uint256 amount, uint256 flags) external;

}



pragma solidity ^0.6.0;







library MooniswapHelper {

    using SafeMath for uint256;
    using UniERC20 for IERC20;

    IMooniswapRegistry constant public REGISTRY = IMooniswapRegistry(0x71CD6666064C3A1354a3B4dca5fA1E2D3ee7D303);

    function getReturn(
        IMooniswap mooniswap,
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal view returns(uint256 ret) {

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        uint256[] memory rets = getReturns(mooniswap, fromToken, destToken, amounts);
        if (rets.length > 0) {
            return rets[0];
        }
    }

    function getReturns(
        IMooniswap mooniswap,
        IERC20 fromToken,
        IERC20 destToken,
        uint256[] memory amounts
    ) internal view returns(uint256[] memory rets) {

        rets = new uint256[](amounts.length);

        uint256 fee = mooniswap.fee();
        uint256 fromBalance = mooniswap.getBalanceForAddition(fromToken.isETH() ? UniERC20.ZERO_ADDRESS : fromToken);
        uint256 destBalance = mooniswap.getBalanceForRemoval(destToken.isETH() ? UniERC20.ZERO_ADDRESS : destToken);
        if (fromBalance > 0 && destBalance > 0) {
            for (uint i = 0; i < amounts.length; i++) {
                uint256 amount = amounts[i].sub(amounts[i].mul(fee).div(1e18));
                rets[i] = amount.mul(destBalance).div(
                    fromBalance.add(amount)
                );
            }
        }
    }
}


contract MooniswapSourceView {

    using SafeMath for uint256;
    using UniERC20 for IERC20;
    using MooniswapHelper for IMooniswap;

    function _calculateMooniswap(IERC20 fromToken, uint256[] memory amounts, IOneRouterView.Swap memory swap) internal view returns(uint256[] memory rets, address dex, uint256 gas) {

        IMooniswap mooniswap = MooniswapHelper.REGISTRY.pools(
            fromToken.isETH() ? UniERC20.ZERO_ADDRESS : fromToken,
            swap.destToken.isETH() ? UniERC20.ZERO_ADDRESS : swap.destToken
        );
        if (mooniswap == IMooniswap(0)) {
            return (new uint256[](0), address(0), 0);
        }

        for (uint t = 0; t < swap.disabledDexes.length; t++) {
            if (swap.disabledDexes[t] == address(mooniswap)) {
                return (new uint256[](0), address(0), 0);
            }
        }

        rets = mooniswap.getReturns(fromToken, swap.destToken, amounts);
        if (rets.length == 0 || rets[0] == 0) {
            return (new uint256[](0), address(0), 0);
        }

        return (rets, address(mooniswap), (fromToken.isETH() || swap.destToken.isETH()) ? 80_000 : 110_000);
    }
}


contract MooniswapSourceSwap {

    using UniERC20 for IERC20;

    function _swapOnMooniswap(IERC20 fromToken, IERC20 destToken, uint256 amount, uint256 /*flags*/) internal {

        IMooniswap mooniswap = MooniswapHelper.REGISTRY.pools(
            fromToken.isETH() ? UniERC20.ZERO_ADDRESS : fromToken,
            destToken.isETH() ? UniERC20.ZERO_ADDRESS : destToken
        );

        fromToken.uniApprove(address(mooniswap), amount);
        mooniswap.swap{ value: fromToken.isETH() ? amount : 0 }(
            fromToken.isETH() ? UniERC20.ZERO_ADDRESS : fromToken,
            destToken.isETH() ? UniERC20.ZERO_ADDRESS : destToken,
            amount,
            0,
            0x68a17B587CAF4f9329f0e372e3A78D23A46De6b5
        );
    }
}


contract MooniswapSourcePublic is ISource, MooniswapSourceView, MooniswapSourceSwap {

    receive() external payable {
        require(msg.sender != tx.origin, "ETH deposit rejected");
    }

    function calculate(IERC20 fromToken, uint256[] memory amounts, IOneRouterView.Swap memory swap) public view override returns(uint256[] memory rets, address dex, uint256 gas) {

        return _calculateMooniswap(fromToken, amounts, swap);
    }

    function swap(IERC20 fromToken, IERC20 destToken, uint256 amount, uint256 flags) public override {

        return _swapOnMooniswap(fromToken, destToken, amount, flags);
    }
}



pragma solidity ^0.6.0;



contract OneRouterConstants {

    uint256 constant internal _FLAG_DISABLE_ALL_SOURCES          = 0x100000000000000000000000000000000;
    uint256 constant internal _FLAG_DISABLE_RECALCULATION        = 0x200000000000000000000000000000000;
    uint256 constant internal _FLAG_ENABLE_CHI_BURN              = 0x400000000000000000000000000000000;
    uint256 constant internal _FLAG_ENABLE_CHI_BURN_ORIGIN       = 0x800000000000000000000000000000000;
    uint256 constant internal _FLAG_ENABLE_REFERRAL_GAS_DISCOUNT = 0x1000000000000000000000000000000000;


    uint256 constant internal _FLAG_DISABLE_KYBER_ALL =
        _FLAG_DISABLE_KYBER_1 +
        _FLAG_DISABLE_KYBER_2 +
        _FLAG_DISABLE_KYBER_3 +
        _FLAG_DISABLE_KYBER_4;
    uint256 constant internal _FLAG_DISABLE_CURVE_ALL =
        _FLAG_DISABLE_CURVE_COMPOUND +
        _FLAG_DISABLE_CURVE_USDT +
        _FLAG_DISABLE_CURVE_Y +
        _FLAG_DISABLE_CURVE_BINANCE +
        _FLAG_DISABLE_CURVE_SYNTHETIX +
        _FLAG_DISABLE_CURVE_PAX +
        _FLAG_DISABLE_CURVE_RENBTC +
        _FLAG_DISABLE_CURVE_TBTC +
        _FLAG_DISABLE_CURVE_SBTC;
    uint256 constant internal _FLAG_DISABLE_BALANCER_ALL =
        _FLAG_DISABLE_BALANCER_1 +
        _FLAG_DISABLE_BALANCER_2 +
        _FLAG_DISABLE_BALANCER_3;
    uint256 constant internal _FLAG_DISABLE_BANCOR_ALL =
        _FLAG_DISABLE_BANCOR_1 +
        _FLAG_DISABLE_BANCOR_2 +
        _FLAG_DISABLE_BANCOR_3;

    uint256 constant internal _FLAG_DISABLE_UNISWAP_V1      = 0x1;
    uint256 constant internal _FLAG_DISABLE_UNISWAP_V2      = 0x2;
    uint256 constant internal _FLAG_DISABLE_MOONISWAP       = 0x4;
    uint256 constant internal _FLAG_DISABLE_KYBER_1         = 0x8;
    uint256 constant internal _FLAG_DISABLE_KYBER_2         = 0x10;
    uint256 constant internal _FLAG_DISABLE_KYBER_3         = 0x20;
    uint256 constant internal _FLAG_DISABLE_KYBER_4         = 0x40;
    uint256 constant internal _FLAG_DISABLE_CURVE_COMPOUND  = 0x80;
    uint256 constant internal _FLAG_DISABLE_CURVE_USDT      = 0x100;
    uint256 constant internal _FLAG_DISABLE_CURVE_Y         = 0x200;
    uint256 constant internal _FLAG_DISABLE_CURVE_BINANCE   = 0x400;
    uint256 constant internal _FLAG_DISABLE_CURVE_SYNTHETIX = 0x800;
    uint256 constant internal _FLAG_DISABLE_CURVE_PAX       = 0x1000;
    uint256 constant internal _FLAG_DISABLE_CURVE_RENBTC    = 0x2000;
    uint256 constant internal _FLAG_DISABLE_CURVE_TBTC      = 0x4000;
    uint256 constant internal _FLAG_DISABLE_CURVE_SBTC      = 0x8000;
    uint256 constant internal _FLAG_DISABLE_BALANCER_1      = 0x10000;
    uint256 constant internal _FLAG_DISABLE_BALANCER_2      = 0x20000;
    uint256 constant internal _FLAG_DISABLE_BALANCER_3      = 0x40000;
    uint256 constant internal _FLAG_DISABLE_BANCOR_1        = 0x80000;
    uint256 constant internal _FLAG_DISABLE_BANCOR_2        = 0x100000;
    uint256 constant internal _FLAG_DISABLE_BANCOR_3        = 0x200000;
    uint256 constant internal _FLAG_DISABLE_OASIS           = 0x400000;
    uint256 constant internal _FLAG_DISABLE_DFORCE_SWAP     = 0x800000;
    uint256 constant internal _FLAG_DISABLE_SHELL           = 0x1000000;
    uint256 constant internal _FLAG_DISABLE_MSTABLE_MUSD    = 0x2000000;
    uint256 constant internal _FLAG_DISABLE_BLACK_HOLE_SWAP = 0x4000000;

    IERC20 constant internal _DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 constant internal _USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 constant internal _USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant internal _TUSD = IERC20(0x0000000000085d4780B73119b644AE5ecd22b376);
    IERC20 constant internal _BUSD = IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
    IERC20 constant internal _SUSD = IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);
    IERC20 constant internal _PAX = IERC20(0x8E870D67F660D95d5be530380D0eC0bd388289E1);
    IERC20 constant internal _RENBTC = IERC20(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
    IERC20 constant internal _WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 constant internal _SBTC = IERC20(0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6);
    IERC20 constant internal _CHI = IERC20(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
}



pragma solidity ^0.6.0;









interface IReferralGasSponsor {

    function makeGasDiscount(
        uint256 gasSpent,
        uint256 returnAmount,
        bytes calldata msgSenderCalldata
    ) external;

}


interface IFreeFromUpTo {

    function freeFromUpTo(address from, uint256 value) external returns(uint256 freed);

}


contract OneRouterAudit is IOneRouter, OneRouterConstants, Ownable {

    using UniERC20 for IERC20;
    using SafeMath for uint256;

    IOneRouter public oneRouterImpl;

    modifier validateInput(SwapInput memory input) {

        require(input.referral.fee <= 0.03e18, "OneRouter: fee out of range");
        require(input.fromToken == input.destToken, "OneRouter: invalid input");
        _;
    }

    constructor(IOneRouter oneRouter) public {
        oneRouterImpl = oneRouter;
    }

    function setOneRouterImpl(IOneRouter oneRouter) public onlyOwner {

        oneRouterImpl = oneRouter;
    }

    receive() external payable {
        require(msg.sender != tx.origin, "OneRouter: ETH deposit rejected");
    }


    function getReturn(IERC20 fromToken, uint256[] memory amounts, Swap memory swap)
        public
        view
        override
        returns(
            Path[] memory paths,
            PathResult[] memory pathResults,
            SwapResult memory splitResult
        )
    {

        return oneRouterImpl.getReturn(fromToken, amounts, swap);
    }

    function getSwapReturn(IERC20 fromToken, uint256[] memory amounts, Swap memory swap)
        public
        view
        override
        returns(SwapResult memory result)
    {

        return oneRouterImpl.getSwapReturn(fromToken, amounts, swap);
    }

    function getPathReturn(IERC20 fromToken, uint256[] memory amounts, Path memory path)
        public
        view
        override
        returns(PathResult memory result)
    {

        return oneRouterImpl.getPathReturn(fromToken, amounts, path);
    }

    function getMultiPathReturn(IERC20 fromToken, uint256[] memory amounts, Path[] memory paths)
        public
        view
        override
        returns(
            PathResult[] memory pathResults,
            SwapResult memory splitResult
        )
    {

        return oneRouterImpl.getMultiPathReturn(fromToken, amounts, paths);
    }


    function makeSwap(
        SwapInput memory input,
        Swap memory swap,
        SwapDistribution memory swapDistribution
    )
        public
        payable
        override
        validateInput(input)
        returns(uint256 returnAmount)
    {

        uint256 gasStart = gasleft();
        _claimInput(input);
        input.fromToken.uniApprove(address(oneRouterImpl), input.amount);
        oneRouterImpl.makeSwap{ value: input.fromToken.isETH() ? input.amount : 0 }(input, swap, swapDistribution);
        return _checkMinReturn(gasStart, input, swap.flags);
    }

    function makePathSwap(
        SwapInput memory input,
        Path memory path,
        PathDistribution memory pathDistribution
    )
        public
        payable
        override
        validateInput(input)
        returns(uint256 returnAmount)
    {

        uint256 gasStart = gasleft();
        _claimInput(input);
        input.fromToken.uniApprove(address(oneRouterImpl), input.amount);
        oneRouterImpl.makePathSwap{ value: input.fromToken.isETH() ? input.amount : 0 }(input, path, pathDistribution);
        return _checkMinReturn(gasStart, input, path.swaps[0].flags);
    }

    function makeMultiPathSwap(
        SwapInput memory input,
        Path[] memory paths,
        PathDistribution[] memory pathDistributions,
        SwapDistribution memory interPathsDistribution
    )
        public
        payable
        override
        validateInput(input)
        returns(uint256 returnAmount)
    {

        uint256 gasStart = gasleft();
        _claimInput(input);
        input.fromToken.uniApprove(address(oneRouterImpl), input.amount);
        oneRouterImpl.makeMultiPathSwap{ value: input.fromToken.isETH() ? input.amount : 0 }(input, paths, pathDistributions, interPathsDistribution);
        return _checkMinReturn(gasStart, input, paths[0].swaps[0].flags);
    }


    function _claimInput(SwapInput memory input) internal {

        input.fromToken.uniTransferFromSender(address(this), input.amount);
        input.amount = input.fromToken.uniBalanceOf(address(this));
    }

    function _checkMinReturn(uint256 gasStart, SwapInput memory input, uint256 flags) internal returns(uint256 returnAmount) {

        uint256 remaining = input.fromToken.uniBalanceOf(address(this));
        returnAmount = input.destToken.uniBalanceOf(address(this));
        require(returnAmount >= input.minReturn, "OneRouter: less than minReturn");
        input.fromToken.uniTransfer(msg.sender, remaining);
        input.destToken.uniTransfer(input.referral.ref, returnAmount.mul(input.referral.fee).div(1e18));
        input.destToken.uniTransfer(msg.sender, returnAmount.sub(returnAmount.mul(input.referral.fee).div(1e18)));

        if ((flags & (_FLAG_ENABLE_CHI_BURN | _FLAG_ENABLE_CHI_BURN_ORIGIN)) > 0) {
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            _chiBurnOrSell(
                ((flags & _FLAG_ENABLE_CHI_BURN_ORIGIN) > 0) ? tx.origin : msg.sender, // solhint-disable-line avoid-tx-origin
                (gasSpent + 14154) / 41947
            );
        }
        else if ((flags & _FLAG_ENABLE_REFERRAL_GAS_DISCOUNT) > 0) {
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            IReferralGasSponsor(input.referral.ref).makeGasDiscount(gasSpent, returnAmount, msg.data);
        }
    }

    function _chiBurnOrSell(address payable sponsor, uint256 amount) internal {

        IMooniswap exchange = IMooniswap(0x5B1fC2435B1f7C16c206e7968C0e8524eC29b786);
        uint256 sellRefund = MooniswapHelper.getReturn(exchange, _CHI, UniERC20.ZERO_ADDRESS, amount);
        uint256 burnRefund = amount.mul(18_000).mul(tx.gasprice);

        if (sellRefund < burnRefund.add(tx.gasprice.mul(36_000))) {
            IFreeFromUpTo(address(_CHI)).freeFromUpTo(sponsor, amount);
        }
        else {
            _CHI.transferFrom(sponsor, address(exchange), amount);
            exchange.swap(_CHI, UniERC20.ZERO_ADDRESS, amount, 0, 0x68a17B587CAF4f9329f0e372e3A78D23A46De6b5);
            sponsor.transfer(address(this).balance);
        }
    }
}