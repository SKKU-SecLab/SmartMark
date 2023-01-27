



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


pragma solidity 0.7.5;



interface IExchange {


    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload) external payable returns (uint256);


    function buy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload) external payable returns (uint256);


    function onChainSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) external payable returns (uint256);

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


    function freeGSTTokens(uint256 tokensToFree) external;

}


pragma solidity 0.7.5;







library Utils {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    uint256 constant MAX_UINT = 2 ** 256 - 1;

    struct SellData {
        IERC20 fromToken;
        IERC20 toToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        string referrer;
        Utils.Path[] path;

    }

    struct BuyData {
        IERC20 fromToken;
        IERC20 toToken;
        uint256 fromAmount;
        uint256 toAmount;
        address payable beneficiary;
        string referrer;
        Utils.BuyRoute[] route;
    }

    struct Route {
        address payable exchange;
        address targetExchange;
        uint percent;
        bytes payload;
        uint256 networkFee;//Network fee is associated with 0xv3 trades
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
                destination.call{value: amount}("");
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
        address tokenProxy,
        uint256 initialGas,
        uint256 mintPrice
    )
        internal
    {


        uint256 mintBase = 32254;
        uint256 mintToken = 36543;
        uint256 freeBase = 14154;
        uint256 freeToken = 6870;
        uint256 reimburse = 24000;

        uint256 tokens = initialGas.sub(
            gasleft()).add(freeBase).div(reimburse.mul(2).sub(freeToken)
        );

        uint256 mintCost = mintBase.add(tokens.mul(mintToken));
        uint256 freeCost = freeBase.add(tokens.mul(freeToken));
        uint256 maxreimburse = tokens.mul(reimburse);

        uint256 efficiency = maxreimburse.mul(tx.gasprice).mul(100).div(
            mintCost.mul(mintPrice).add(freeCost.mul(tx.gasprice))
        );

        if (efficiency > 100) {
            freeGasTokens(tokenProxy, tokens);
        }
    }

    function freeGasTokens(address tokenProxy, uint256 tokens) internal {


        uint256 tokensToFree = tokens;
        uint256 safeNumTokens = 0;
        uint256 gas = gasleft();

        if (gas >= 27710) {
            safeNumTokens = gas.sub(27710).div(1148 + 5722 + 150);
        }

        if (tokensToFree > safeNumTokens) {
            tokensToFree = safeNumTokens;
        }

        ITokenTransferProxy(tokenProxy).freeGSTTokens(tokensToFree);

    }
}


pragma solidity 0.7.5;


interface IUniswapRouter {


    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint[] memory amounts);


    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        returns (uint[] memory amounts);


    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
     )
        external
        payable
        returns (uint[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    )
      external
      returns (uint[] memory amounts);


    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    )
      external
      returns (uint[] memory amounts);


}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
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


pragma solidity 0.7.5;




contract TokenFetcher is Ownable {


    function transferTokens(
        address token,
        address payable destination,
        uint256 amount
    )
        external
        onlyOwner
    {

        Utils.transferTokens(token, destination, amount);
    }
}


pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;








contract UniswapV2 is IExchange, TokenFetcher {

    using SafeMath for uint256;
    using Address for address;

    struct UniswapV2Data {
        address[] path;
    }

    address public weth;

    address public uinswapV2Router;

    constructor(address _weth, address uinswapV2Router_) public {
        weth = _weth;
        uinswapV2Router = uinswapV2Router_;
    }

    receive() external payable {
    }

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload
    )
        external
        override
        payable
        returns (uint256)
    {


        UniswapV2Data memory data = abi.decode(payload, (UniswapV2Data));
        return _swap(
            fromToken,
            toToken,
            fromAmount,
            toAmount,
            exchange,
            data.path
        );

    }

    function buy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload
    )
        external
        override
        payable
        returns (uint256)
    {


        UniswapV2Data memory data = abi.decode(payload, (UniswapV2Data));

        Utils.approve(address(exchange), address(fromToken), fromAmount);

        if (address(fromToken) == Utils.ethAddress()) {
            require(
                data.path[0] == weth,
                "First element in path must be WETH"
            );

            require(
                data.path[data.path.length - 1] == address(toToken),
                "last element in path must be toToken"
            );

            IUniswapRouter(exchange).swapETHForExactTokens{value: fromAmount}(
                toAmount,
                data.path,
                address(this),
                block.timestamp
            );
        }
        else if (address(toToken) == Utils.ethAddress()) {
            require(
                data.path[0] == address(fromToken),
                "First element in path must be fromToken"
            );

            require(
                data.path[data.path.length - 1] == weth,
                "last element in path must be weth"
            );
            IUniswapRouter(exchange).swapTokensForExactETH(
                toAmount,
                fromAmount,
                data.path,
                address(this),
                block.timestamp
            );
        }
        else {
            require(
                data.path[0] == address(fromToken),
                "First element in path must be fromToken"
            );

            require(
                data.path[data.path.length - 1] == address(toToken),
                "last element in path must be toToken"
            );
            IUniswapRouter(exchange).swapTokensForExactTokens(
                toAmount,
                fromAmount,
                data.path,
                address(this),
                block.timestamp
            );
        }

        uint256 remainingAmount = Utils.tokenBalance(
          address(fromToken),
          address(this)
        );
        uint256 receivedAmount = Utils.tokenBalance(
          address(toToken),
          address(this)
        );

        Utils.transferTokens(address(toToken), msg.sender, receivedAmount);
        Utils.transferTokens(address(fromToken), msg.sender, remainingAmount);

        return receivedAmount;
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


        address[] memory path = new address[](2);

        path[0] = address(fromToken) == Utils.ethAddress() ? weth : address(fromToken);
        path[1] = address(toToken) == Utils.ethAddress() ? weth : address(toToken);
        return _swap(
            fromToken,
            toToken,
            fromAmount,
            toAmount,
            uinswapV2Router,
            path
        );


    }

    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        address[] memory path
    )
        private
        returns(uint256)
    {

        Utils.approve(address(exchange), address(fromToken), fromAmount);

        if (address(fromToken) == Utils.ethAddress()) {
            require(
                path[0] == weth,
                "First element in path must be WETH"
            );

            require(
                path[path.length - 1] == address(toToken),
                "last element in path must be toToken"
            );

            IUniswapRouter(exchange).swapExactETHForTokens{value: fromAmount}(
                toAmount,
                path,
                address(this),
                block.timestamp
            );
        }
        else if (address(toToken) == Utils.ethAddress()) {
            require(
                path[0] == address(fromToken),
                "First element in path must be fromToken"
            );

            require(
                path[path.length - 1] == weth,
                "last element in path must be weth"
            );
            IUniswapRouter(exchange).swapExactTokensForETH(
                fromAmount,
                toAmount,
                path,
                address(this),
                block.timestamp
            );
        }
        else {
            require(
                path[0] == address(fromToken),
                "First element in path must be fromToken"
            );

            require(
                path[path.length - 1] == address(toToken),
                "last element in path must be toToken"
            );
            IUniswapRouter(exchange).swapExactTokensForTokens(
                fromAmount,
                toAmount,
                path,
                address(this),
                block.timestamp
            );
        }

        uint256 receivedAmount = Utils.tokenBalance(
          address(toToken),
          address(this)
        );

        Utils.transferTokens(address(toToken), msg.sender, receivedAmount);

        return receivedAmount;
    }
}