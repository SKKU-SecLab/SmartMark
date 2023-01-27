



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
}


pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;



interface IBalancerProxy {


  struct Swap {
        address pool;
        uint tokenInParam; // tokenInAmount / maxAmountIn / limitAmountIn
        uint tokenOutParam; // minAmountOut / tokenAmountOut / limitAmountOut
        uint maxPrice;
    }

    function batchSwapExactIn(
        Swap[] calldata swaps,
        address tokenIn,
        address tokenOut,
        uint totalAmountIn,
        uint minTotalAmountOut
    )
        external
        returns (uint totalAmountOut);


    function batchSwapExactOut(
        Swap[] calldata swaps,
        address tokenIn,
        address tokenOut,
        uint maxTotalAmountIn
    )
        external
        returns (uint totalAmountIn);


    function batchEthInSwapExactIn(
        Swap[] calldata swaps,
        address tokenOut,
        uint minTotalAmountOut
    )
        external
        payable
        returns (uint totalAmountOut);


    function batchEthOutSwapExactIn(
        Swap[] calldata swaps,
        address tokenIn,
        uint totalAmountIn,
        uint minTotalAmountOut
    )
        external
        returns (uint totalAmountOut);


    function batchEthInSwapExactOut(
        Swap[] calldata swaps,
        address tokenOut
    )
        external
        payable
        returns (uint totalAmountIn);


    function batchEthOutSwapExactOut(
        Swap[] calldata swaps,
        address tokenIn,
        uint maxTotalAmountIn
    )
        external
        returns (uint totalAmountIn);

}


pragma solidity 0.7.5;



interface IExchange {


    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload) external payable;


    function buy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload) external payable;


    function onChainSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) external payable returns (uint256);


    function initialize(bytes calldata data) external;


    function getKey() external pure returns(bytes32);

}




pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity 0.7.5;




library Address {


    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
}


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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.7.5;


interface ITokenTransferProxy {


    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        external;


    function freeReduxTokens(address user, uint256 tokensToFree) external;

}


pragma solidity 0.7.5;






library Utils {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    address constant WETH_ADDRESS = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );

    uint256 constant MAX_UINT = 2 ** 256 - 1;

    struct SellData {
        address fromToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        string referrer;
        bool useReduxToken;
        Utils.Path[] path;

    }

    struct MegaSwapSellData {
        address fromToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        string referrer;
        bool useReduxToken;
        Utils.MegaSwapPath[] path;
    }

    struct BuyData {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        address payable beneficiary;
        string referrer;
        bool useReduxToken;
        Utils.BuyRoute[] route;
    }

    struct Route {
        address payable exchange;
        address targetExchange;
        uint percent;
        bytes payload;
        uint256 networkFee;//Network fee is associated with 0xv3 trades
    }

    struct MegaSwapPath {
        uint256 fromAmountPercent;
        Path[] path;
    }

    struct Path {
        address to;
        uint256 totalNetworkFee;//Network fee is associated with 0xv3 trades
        Route[] routes;
    }

    struct BuyRoute {
        address payable exchange;
        address targetExchange;
        uint256 fromAmount;
        uint256 toAmount;
        bytes payload;
        uint256 networkFee;//Network fee is associated with 0xv3 trades
    }

    function ethAddress() internal pure returns (address) {return ETH_ADDRESS;}


    function wethAddress() internal pure returns (address) {return WETH_ADDRESS;}


    function maxUint() internal pure returns (uint256) {return MAX_UINT;}


    function approve(
        address addressToApprove,
        address token,
        uint256 amount
    ) internal {

        if (token != ETH_ADDRESS) {
            IERC20 _token = IERC20(token);

            uint allowance = _token.allowance(address(this), addressToApprove);

            if (allowance < amount) {
                _token.safeApprove(addressToApprove, 0);
                _token.safeIncreaseAllowance(addressToApprove, MAX_UINT);
            }
        }
    }

    function transferTokens(
        address token,
        address payable destination,
        uint256 amount
    )
    internal
    {

        if (amount > 0) {
            if (token == ETH_ADDRESS) {
                (bool result, ) = destination.call{value: amount, gas: 4000}("");
                require(result, "Failed to transfer Ether");
            }
            else {
                IERC20(token).safeTransfer(destination, amount);
            }
        }

    }

    function tokenBalance(
        address token,
        address account
    )
    internal
    view
    returns (uint256)
    {

        if (token == ETH_ADDRESS) {
            return account.balance;
        } else {
            return IERC20(token).balanceOf(account);
        }
    }

    function refundGas(
        address account,
        address tokenTransferProxy,
        uint256 initialGas
    )
        internal
    {

        uint256 freeBase = 14154;
        uint256 freeToken = 6870;
        uint256 reimburse = 24000;

        uint256 tokens = initialGas.sub(
            gasleft()).add(freeBase).div(reimburse.mul(2).sub(freeToken)
        );

        freeGasTokens(account, tokenTransferProxy, tokens);
    }

    function freeGasTokens(address account, address tokenTransferProxy, uint256 tokens) internal {


        uint256 tokensToFree = tokens;
        uint256 safeNumTokens = 0;
        uint256 gas = gasleft();

        if (gas >= 27710) {
            safeNumTokens = gas.sub(27710).div(1148 + 5722 + 150);
        }

        if (tokensToFree > safeNumTokens) {
            tokensToFree = safeNumTokens;
        }
        ITokenTransferProxy(tokenTransferProxy).freeReduxTokens(account, tokensToFree);
    }
}


pragma solidity 0.7.5;


interface IBalancerPool {

    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut,
        uint maxPrice
    )
        external
        returns (
            uint tokenAmountOut,
            uint spotPriceAfter
        );



    function swapExactAmountOut(
        address tokenIn,
        uint maxAmountIn,
        address tokenOut,
        uint tokenAmountOut,
        uint maxPrice
    )
        external
        returns (
            uint tokenAmountIn,
            uint spotPriceAfter
        );

}


pragma solidity 0.7.5;


interface IBalancerRegistry {


    function getPool(
        address tokenFrom,
        address tokenTo
    )
        external
        view
        returns (address);

}


pragma solidity 0.7.5;



abstract contract IWETH is IERC20 {
    function deposit() external virtual payable;
    function withdraw(uint256 amount) external virtual;
}


pragma solidity 0.7.5;



contract AdapterStorage {


    mapping (bytes32 => bool) internal adapterInitialized;
    mapping (bytes32 => bytes) internal adapterVsData;
    ITokenTransferProxy internal _tokenTransferProxy;

    function isInitialized(bytes32 key) public view returns(bool) {

        return adapterInitialized[key];
    }

    function getData(bytes32 key) public view returns(bytes memory) {

        return adapterVsData[key];
    }

    function getTokenTransferProxy() public view returns (address) {

        return address(_tokenTransferProxy);
    }
}


pragma solidity 0.7.5;










contract Balancer is IExchange, AdapterStorage {

    using SafeMath for uint256;

    struct BalancerData {
        IBalancerProxy.Swap[] swaps;
    }


    struct LocalData {
      address balancerRegistry;
    }

    function initialize(bytes calldata data) external override {

       bytes32 key = getKey();
       require(!adapterInitialized[key], "Adapter already initialized");
       abi.decode(data, (LocalData));
       adapterInitialized[key] = true;
       adapterVsData[key] = data;
    }

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchangeProxy,
        bytes calldata payload
    )
        external
        payable
        override
    {

        BalancerData memory data = abi.decode(payload, (BalancerData));

        address _fromToken = address(fromToken) == Utils.ethAddress()
            ? Utils.wethAddress() : address(fromToken);
        address _toToken = address(toToken) == Utils.ethAddress()
            ? Utils.wethAddress() : address(toToken);

        if (address(fromToken) == Utils.ethAddress()) {
             IWETH(Utils.wethAddress()).deposit{value: fromAmount}();
        }

        uint256 totalInParam;
        for (uint i = 0; i < data.swaps.length; ++i) {
            totalInParam = totalInParam.add(data.swaps[i].tokenInParam);
        }

        for (uint i = 0; i < data.swaps.length; ++i) {
            IBalancerProxy.Swap memory _swap = data.swaps[i];
            uint256 adjustedInParam =
                _swap.tokenInParam.mul(fromAmount).div(totalInParam);
            Utils.approve(
                _swap.pool,
                _fromToken,
                adjustedInParam
            );
            IBalancerPool(_swap.pool).swapExactAmountIn(
                _fromToken,
                adjustedInParam,
                _toToken,
                _swap.tokenOutParam,
                _swap.maxPrice
            );
        }

        if (address(toToken) == Utils.ethAddress()) {
            IWETH(Utils.wethAddress()).withdraw(
                IERC20(Utils.wethAddress()).balanceOf(address(this))
            );
        }
    }

    function buy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchangeProxy,
        bytes calldata payload
    )
        external
        payable
        override
    {

        BalancerData memory data = abi.decode(payload, (BalancerData));

        address _fromToken = address(fromToken) == Utils.ethAddress()
            ? Utils.wethAddress() : address(fromToken);
        address _toToken = address(toToken) == Utils.ethAddress()
            ? Utils.wethAddress() : address(toToken);

        if (address(fromToken) == Utils.ethAddress()) {
             IWETH(Utils.wethAddress()).deposit{value: fromAmount}();
        }

        uint256 totalInParam;
        for (uint i = 0; i < data.swaps.length; ++i) {
            totalInParam = totalInParam.add(data.swaps[i].tokenInParam);
        }

        for (uint i = 0; i < data.swaps.length; ++i) {
            IBalancerProxy.Swap memory _swap = data.swaps[i];
            uint256 adjustedInParam =
                _swap.tokenInParam.mul(fromAmount).div(totalInParam);
            Utils.approve(
                _swap.pool,
                _fromToken,
                adjustedInParam
            );
            IBalancerPool(_swap.pool).swapExactAmountOut(
                _fromToken,
                adjustedInParam,
                _toToken,
                _swap.tokenOutParam,
                _swap.maxPrice
            );
        }

        if (
            address(fromToken) == Utils.ethAddress() ||
            address(toToken) == Utils.ethAddress()
        ) {
            IWETH(Utils.wethAddress()).withdraw(
                IERC20(Utils.wethAddress()).balanceOf(address(this))
            );
        }
    }

    function onChainSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount
    )
        external
        override
        payable
        returns (uint256)
    {


        bytes32 key = getKey();
        bytes memory localData = adapterVsData[key];
        LocalData memory lData = abi.decode(localData, (LocalData));

        address pool = IBalancerRegistry(lData.balancerRegistry).getPool(
            address(fromToken) == Utils.ethAddress() ? Utils.wethAddress() : address(fromToken),
            address(toToken) == Utils.ethAddress() ? Utils.wethAddress() : address(toToken)
        );

        if (address(fromToken) == Utils.ethAddress()) {
             IWETH(Utils.wethAddress()).deposit{value: fromAmount}();
        }

        Utils.approve(
            pool,
            address(fromToken) == Utils.ethAddress() ? Utils.wethAddress() : address(fromToken),
            fromAmount
        );

        IBalancerPool(pool).swapExactAmountIn(
            address(fromToken) == Utils.ethAddress() ? Utils.wethAddress() : address(fromToken),
            fromAmount,
            address(toToken) == Utils.ethAddress() ? Utils.wethAddress() : address(toToken),
            1,
            uint256(-1)
        );

        uint256 receivedAmount = Utils.tokenBalance(
          address(toToken) == Utils.ethAddress() ? Utils.wethAddress() : address(toToken),
          address(this)
        );

        if (address(toToken) == Utils.ethAddress()) {
             IWETH(Utils.wethAddress()).withdraw(receivedAmount);
        }

        Utils.transferTokens(address(toToken), msg.sender, receivedAmount);

        return receivedAmount;
    }

    function getKey() public override pure returns(bytes32) {

      return keccak256(abi.encodePacked("Balancer", "1.1.0"));
    }

}