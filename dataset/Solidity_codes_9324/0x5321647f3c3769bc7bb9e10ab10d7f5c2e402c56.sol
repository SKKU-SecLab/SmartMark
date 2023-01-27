
pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.7.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity ^0.7.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity ^0.7.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}// MIT

pragma solidity ^0.7.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//GPL-3.0-only
pragma solidity ^0.7.0;

interface ISwap {

    struct Swap {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount; // tokenInAmount / tokenOutAmount
        uint256 limitReturnAmount; // minAmountOut / maxAmountIn
        uint256 maxPrice;
    }
}//GPL-3.0-only
pragma solidity ^0.7.0;


interface IXToken is IERC20 {

    function pause() external;


    function unpause() external;


    function setAuthorization(address authorization_) external;


    function setOperationsRegistry(address operationsRegistry_) external;


    function setKya(string memory kya_) external;


    function mint(address account, uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;

}//GPL-3.0-only
pragma solidity ^0.7.0;


interface IXTokenWrapper is IERC1155Receiver {

    function tokenToXToken(address _token) external view returns (address);


    function xTokenToToken(address _xToken) external view returns (address);


    function wrap(address _token, uint256 _amount) external payable returns (bool);


    function unwrap(address _xToken, uint256 _amount) external returns (bool);

}//GPL-3.0-only
pragma solidity ^0.7.0;

interface IBPool {

    function isPublicSwap() external view returns (bool);


    function isFinalized() external view returns (bool);


    function isBound(address t) external view returns (bool);


    function getNumTokens() external view returns (uint256);


    function getCurrentTokens() external view returns (address[] memory tokens);


    function getFinalTokens() external view returns (address[] memory tokens);


    function getDenormalizedWeight(address token) external view returns (uint256);


    function getTotalDenormalizedWeight() external view returns (uint256);


    function getNormalizedWeight(address token) external view returns (uint256);


    function getBalance(address token) external view returns (uint256);


    function getSwapFee() external view returns (uint256);


    function getController() external view returns (address);


    function setSwapFee(uint256 swapFee) external;


    function setController(address manager) external;


    function setPublicSwap(bool public_) external;


    function finalize() external;


    function bind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function rebind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function unbind(address token) external;


    function gulp(address token) external;


    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);


    function getSpotPriceSansFee(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);


    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


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


    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);


    function joinswapPoolAmountOut(
        address tokenIn,
        uint256 poolAmountOut,
        uint256 maxAmountIn
    ) external returns (uint256 tokenAmountIn);


    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);


    function exitswapExternAmountOut(
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);


    function totalSupply() external view returns (uint256);


    function balanceOf(address whom) external view returns (uint256);


    function allowance(address src, address dst) external view returns (uint256);


    function approve(address dst, uint256 amt) external returns (bool);


    function transfer(address dst, uint256 amt) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amt
    ) external returns (bool);


    function calcSpotPrice(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 swapFee
    ) external pure returns (uint256 spotPrice);


    function calcOutGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);


    function calcInGivenOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountIn);


    function calcPoolOutGivenSingleIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 poolAmountOut);


    function calcSingleInGivenPoolOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountIn);


    function calcSingleOutGivenPoolIn(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);


    function calcPoolInGivenSingleOut(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 poolAmountIn);

}//GPL-3.0-only
pragma solidity ^0.7.0;


interface IBRegistry {

    function getBestPoolsWithLimit(
        address,
        address,
        uint256
    ) external view returns (address[] memory);

}//GPL-3.0-only
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


interface IProtocolFee is ISwap {

    function batchFee(Swap[] memory swaps, uint256 amountIn) external view returns (uint256);


    function multihopBatch(Swap[][] memory swapSequences, uint256 amountIn) external view returns (uint256);

}//GPL-3.0-only
pragma solidity ^0.7.0;

interface IUTokenPriceFeed {

    function getPrice(address _asset) external returns (uint256);


    function calculateAmount(address _asset, uint256 _amount) external view returns (uint256);

}//GPL-3.0-only
pragma solidity ^0.7.0;


contract BPoolProxy is Ownable, ISwap, ERC1155Holder {

    using SafeMath for uint256;

    struct Pool {
        address pool;
        uint256 tokenBalanceIn;
        uint256 tokenWeightIn;
        uint256 tokenBalanceOut;
        uint256 tokenWeightOut;
        uint256 swapFee;
        uint256 effectiveLiquidity;
    }

    uint256 private constant BONE = 10**18;

    IBRegistry public registry;
    IProtocolFee public protocolFee;
    IXTokenWrapper public xTokenWrapper;
    IUTokenPriceFeed public utilityTokenFeed;
    address public feeReceiver;
    address public utilityToken;

    event JoinPool(address liquidityProvider, address bpool, uint256 shares);

    event ExitPool(address iquidityProvider, address bpool, uint256 shares);

    event RegistrySet(address registry);

    event ProtocolFeeSet(address protocolFee);

    event FeeReceiverSet(address feeReceiver);

    event XTokenWrapperSet(address xTokenWrapper);

    event UtilityTokenSet(address utilityToken);

    event UtilityTokenFeedSet(address utilityTokenFeed);

    constructor(
        address _registry,
        address _protocolFee,
        address _feeReceiver,
        address _xTokenWrapper,
        address _utilityToken,
        address _utilityTokenFeed
    ) {
        _setRegistry(_registry);
        _setProtocolFee(_protocolFee);
        _setFeeReceiver(_feeReceiver);
        _setXTokenWrapper(_xTokenWrapper);
        _setUtilityToken(_utilityToken);
        _setUtilityTokenFeed(_utilityTokenFeed);
    }

    function setRegistry(address _registry) external onlyOwner {

        _setRegistry(_registry);
    }

    function setProtocolFee(address _protocolFee) external onlyOwner {

        _setProtocolFee(_protocolFee);
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {

        _setFeeReceiver(_feeReceiver);
    }

    function setXTokenWrapper(address _xTokenWrapper) external onlyOwner {

        _setXTokenWrapper(_xTokenWrapper);
    }

    function setUtilityToken(address _utilityToken) external onlyOwner {

        _setUtilityToken(_utilityToken);
    }

    function setUtilityTokenFeed(address _utilityTokenFeed) external onlyOwner {

        _setUtilityTokenFeed(_utilityTokenFeed);
    }

    function _setRegistry(address _registry) internal {

        require(_registry != address(0), "registry is the zero address");
        emit RegistrySet(_registry);
        registry = IBRegistry(_registry);
    }

    function _setProtocolFee(address _protocolFee) internal {

        require(_protocolFee != address(0), "protocolFee is the zero address");
        emit ProtocolFeeSet(_protocolFee);
        protocolFee = IProtocolFee(_protocolFee);
    }

    function _setFeeReceiver(address _feeReceiver) internal {

        require(_feeReceiver != address(0), "feeReceiver is the zero address");
        emit FeeReceiverSet(_feeReceiver);
        feeReceiver = _feeReceiver;
    }

    function _setXTokenWrapper(address _xTokenWrapper) internal {

        require(_xTokenWrapper != address(0), "xTokenWrapper is the zero address");
        emit XTokenWrapperSet(_xTokenWrapper);
        xTokenWrapper = IXTokenWrapper(_xTokenWrapper);
    }

    function _setUtilityToken(address _utilityToken) internal {

        emit UtilityTokenSet(_utilityToken);
        utilityToken = _utilityToken;
    }

    function _setUtilityTokenFeed(address _utilityTokenFeed) internal {

        emit UtilityTokenFeedSet(_utilityTokenFeed);
        utilityTokenFeed = IUTokenPriceFeed(_utilityTokenFeed);
    }

    function batchSwapExactIn(
        Swap[] memory swaps,
        IXToken tokenIn,
        IXToken tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut,
        bool useUtilityToken
    ) public returns (uint256 totalAmountOut) {

        transferFrom(tokenIn, totalAmountIn);

        for (uint256 i = 0; i < swaps.length; i++) {
            Swap memory swap = swaps[i];
            IXToken swapTokenIn = IXToken(swap.tokenIn);
            IBPool pool = IBPool(swap.pool);

            if (swapTokenIn.allowance(address(this), swap.pool) > 0) {
                swapTokenIn.approve(swap.pool, 0);
            }
            swapTokenIn.approve(swap.pool, swap.swapAmount);

            (uint256 tokenAmountOut, ) =
                pool.swapExactAmountIn(
                    swap.tokenIn,
                    swap.swapAmount,
                    swap.tokenOut,
                    swap.limitReturnAmount,
                    swap.maxPrice
                );
            totalAmountOut = tokenAmountOut.add(totalAmountOut);
        }

        require(totalAmountOut >= minTotalAmountOut, "ERR_LIMIT_OUT");

        transferFeeFrom(tokenIn, protocolFee.batchFee(swaps, totalAmountIn), useUtilityToken);

        transfer(tokenOut, totalAmountOut);
        transfer(tokenIn, getBalance(tokenIn));
    }

    function batchSwapExactOut(
        Swap[] memory swaps,
        IXToken tokenIn,
        IXToken tokenOut,
        uint256 maxTotalAmountIn,
        bool useUtilityToken
    ) public returns (uint256 totalAmountIn) {

        transferFrom(tokenIn, maxTotalAmountIn);

        for (uint256 i = 0; i < swaps.length; i++) {
            Swap memory swap = swaps[i];
            IXToken swapTokenIn = IXToken(swap.tokenIn);
            IBPool pool = IBPool(swap.pool);

            if (swapTokenIn.allowance(address(this), swap.pool) > 0) {
                swapTokenIn.approve(swap.pool, 0);
            }
            swapTokenIn.approve(swap.pool, swap.limitReturnAmount);

            (uint256 tokenAmountIn, ) =
                pool.swapExactAmountOut(
                    swap.tokenIn,
                    swap.limitReturnAmount,
                    swap.tokenOut,
                    swap.swapAmount,
                    swap.maxPrice
                );
            totalAmountIn = tokenAmountIn.add(totalAmountIn);
        }
        require(totalAmountIn <= maxTotalAmountIn, "ERR_LIMIT_IN");

        transferFeeFrom(tokenIn, protocolFee.batchFee(swaps, totalAmountIn), useUtilityToken);

        transfer(tokenOut, getBalance(tokenOut));
        transfer(tokenIn, getBalance(tokenIn));
    }

    function multihopBatchSwapExactIn(
        Swap[][] memory swapSequences,
        IXToken tokenIn,
        IXToken tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut,
        bool useUtilityToken
    ) external returns (uint256 totalAmountOut) {

        transferFrom(tokenIn, totalAmountIn);

        for (uint256 i = 0; i < swapSequences.length; i++) {
            uint256 tokenAmountOut;
            for (uint256 k = 0; k < swapSequences[i].length; k++) {
                Swap memory swap = swapSequences[i][k];
                IXToken swapTokenIn = IXToken(swap.tokenIn);
                if (k == 1) {
                    swap.swapAmount = tokenAmountOut;
                }

                IBPool pool = IBPool(swap.pool);
                if (swapTokenIn.allowance(address(this), swap.pool) > 0) {
                    swapTokenIn.approve(swap.pool, 0);
                }
                swapTokenIn.approve(swap.pool, swap.swapAmount);
                (tokenAmountOut, ) = pool.swapExactAmountIn(
                    swap.tokenIn,
                    swap.swapAmount,
                    swap.tokenOut,
                    swap.limitReturnAmount,
                    swap.maxPrice
                );
            }
            totalAmountOut = tokenAmountOut.add(totalAmountOut);
        }

        require(totalAmountOut >= minTotalAmountOut, "ERR_LIMIT_OUT");

        transferFeeFrom(tokenIn, protocolFee.multihopBatch(swapSequences, totalAmountIn), useUtilityToken);

        transfer(tokenOut, totalAmountOut);
        transfer(tokenIn, getBalance(tokenIn));
    }

    function multihopBatchSwapExactOut(
        Swap[][] memory swapSequences,
        IXToken tokenIn,
        IXToken tokenOut,
        uint256 maxTotalAmountIn,
        bool useUtilityToken
    ) external returns (uint256 totalAmountIn) {

        transferFrom(tokenIn, maxTotalAmountIn);

        for (uint256 i = 0; i < swapSequences.length; i++) {
            uint256 tokenAmountInFirstSwap;
            if (swapSequences[i].length == 1) {
                Swap memory swap = swapSequences[i][0];
                IXToken swapTokenIn = IXToken(swap.tokenIn);

                IBPool pool = IBPool(swap.pool);
                if (swapTokenIn.allowance(address(this), swap.pool) > 0) {
                    swapTokenIn.approve(swap.pool, 0);
                }
                swapTokenIn.approve(swap.pool, swap.limitReturnAmount);

                (tokenAmountInFirstSwap, ) = pool.swapExactAmountOut(
                    swap.tokenIn,
                    swap.limitReturnAmount,
                    swap.tokenOut,
                    swap.swapAmount,
                    swap.maxPrice
                );
            } else {
                uint256 intermediateTokenAmount; // This would be token B as described above
                Swap memory secondSwap = swapSequences[i][1];
                IBPool poolSecondSwap = IBPool(secondSwap.pool);
                intermediateTokenAmount = poolSecondSwap.calcInGivenOut(
                    poolSecondSwap.getBalance(secondSwap.tokenIn),
                    poolSecondSwap.getDenormalizedWeight(secondSwap.tokenIn),
                    poolSecondSwap.getBalance(secondSwap.tokenOut),
                    poolSecondSwap.getDenormalizedWeight(secondSwap.tokenOut),
                    secondSwap.swapAmount,
                    poolSecondSwap.getSwapFee()
                );

                Swap memory firstSwap = swapSequences[i][0];
                IXToken firstswapTokenIn = IXToken(firstSwap.tokenIn);
                IBPool poolFirstSwap = IBPool(firstSwap.pool);
                if (firstswapTokenIn.allowance(address(this), firstSwap.pool) < uint256(-1)) {
                    firstswapTokenIn.approve(firstSwap.pool, uint256(-1));
                }

                (tokenAmountInFirstSwap, ) = poolFirstSwap.swapExactAmountOut(
                    firstSwap.tokenIn,
                    firstSwap.limitReturnAmount,
                    firstSwap.tokenOut,
                    intermediateTokenAmount, // This is the amount of token B we need
                    firstSwap.maxPrice
                );

                IXToken secondswapTokenIn = IXToken(secondSwap.tokenIn);
                if (secondswapTokenIn.allowance(address(this), secondSwap.pool) < uint256(-1)) {
                    secondswapTokenIn.approve(secondSwap.pool, uint256(-1));
                }

                poolSecondSwap.swapExactAmountOut(
                    secondSwap.tokenIn,
                    secondSwap.limitReturnAmount,
                    secondSwap.tokenOut,
                    secondSwap.swapAmount,
                    secondSwap.maxPrice
                );
            }
            totalAmountIn = tokenAmountInFirstSwap.add(totalAmountIn);
        }

        require(totalAmountIn <= maxTotalAmountIn, "ERR_LIMIT_IN");

        transferFeeFrom(tokenIn, protocolFee.multihopBatch(swapSequences, totalAmountIn), useUtilityToken);

        transfer(tokenOut, getBalance(tokenOut));
        transfer(tokenIn, getBalance(tokenIn));
    }

    function smartSwapExactIn(
        IXToken tokenIn,
        IXToken tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut,
        uint256 nPools,
        bool useUtilityToken
    ) external returns (uint256 totalAmountOut) {

        Swap[] memory swaps;
        uint256 totalOutput;
        (swaps, totalOutput) = viewSplitExactIn(address(tokenIn), address(tokenOut), totalAmountIn, nPools);

        require(totalOutput >= minTotalAmountOut, "ERR_LIMIT_OUT");

        totalAmountOut = batchSwapExactIn(swaps, tokenIn, tokenOut, totalAmountIn, minTotalAmountOut, useUtilityToken);
    }

    function smartSwapExactOut(
        IXToken tokenIn,
        IXToken tokenOut,
        uint256 totalAmountOut,
        uint256 maxTotalAmountIn,
        uint256 nPools,
        bool useUtilityToken
    ) external returns (uint256 totalAmountIn) {

        Swap[] memory swaps;
        uint256 totalInput;
        (swaps, totalInput) = viewSplitExactOut(address(tokenIn), address(tokenOut), totalAmountOut, nPools);

        require(totalInput <= maxTotalAmountIn, "ERR_LIMIT_IN");

        totalAmountIn = batchSwapExactOut(swaps, tokenIn, tokenOut, maxTotalAmountIn, useUtilityToken);
    }

    function joinPool(
        address pool,
        uint256 poolAmountOut,
        uint256[] calldata maxAmountsIn
    ) external {

        address[] memory tokens = IBPool(pool).getCurrentTokens();

        for (uint256 i = 0; i < tokens.length; i++) {
            transferFrom(IXToken(tokens[i]), maxAmountsIn[i]);
            IXToken(tokens[i]).approve(pool, maxAmountsIn[i]);
        }

        IBPool(pool).joinPool(poolAmountOut, maxAmountsIn);

        for (uint256 i = 0; i < tokens.length; i++) {
            transfer(IXToken(tokens[i]), getBalance(IXToken(tokens[i])));
        }

        IBPool(pool).approve(address(xTokenWrapper), poolAmountOut);
        require(xTokenWrapper.wrap(pool, poolAmountOut), "ERR_WRAP_POOL");

        transfer(IXToken(xTokenWrapper.tokenToXToken(pool)), poolAmountOut);

        emit JoinPool(msg.sender, pool,  poolAmountOut);
    }

    function exitPool(
        address pool,
        uint256 poolAmountIn,
        uint256[] calldata minAmountsOut
    ) external {

        address wrappedLPT = xTokenWrapper.tokenToXToken(pool);

        transferFrom(IXToken(wrappedLPT), poolAmountIn);

        require(xTokenWrapper.unwrap(wrappedLPT, poolAmountIn), "ERR_UNWRAP_POOL");

        IBPool(pool).exitPool(poolAmountIn, minAmountsOut);

        address[] memory tokens = IBPool(pool).getCurrentTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            transfer(IXToken(tokens[i]), getBalance(IXToken(tokens[i])));
        }

        emit ExitPool(msg.sender, pool, poolAmountIn); 
    }

    function joinswapExternAmountIn(
        address pool,
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut) {

        transferFrom(IXToken(tokenIn), tokenAmountIn);
        IXToken(tokenIn).approve(pool, tokenAmountIn);

        poolAmountOut = IBPool(pool).joinswapExternAmountIn(tokenIn, tokenAmountIn, minPoolAmountOut);

        IBPool(pool).approve(address(xTokenWrapper), poolAmountOut);
        require(xTokenWrapper.wrap(pool, poolAmountOut), "ERR_WRAP_POOL");

        transfer(IXToken(xTokenWrapper.tokenToXToken(pool)), poolAmountOut);

        emit JoinPool(msg.sender, pool,  poolAmountOut);
    }

    function joinswapPoolAmountOut(
        address pool,
        address tokenIn,
        uint256 poolAmountOut,
        uint256 maxAmountIn
    ) external returns (uint256 tokenAmountIn) {

        transferFrom(IXToken(tokenIn), maxAmountIn);
        IXToken(tokenIn).approve(pool, maxAmountIn);

        tokenAmountIn = IBPool(pool).joinswapPoolAmountOut(tokenIn, poolAmountOut, maxAmountIn);

        transfer(IXToken(tokenIn), getBalance(IXToken(tokenIn)));

        IBPool(pool).approve(address(xTokenWrapper), poolAmountOut);
        require(xTokenWrapper.wrap(pool, poolAmountOut), "ERR_WRAP_POOL");

        transfer(IXToken(xTokenWrapper.tokenToXToken(pool)), poolAmountOut);

        emit JoinPool(msg.sender, pool,  poolAmountOut);
    }

    function exitswapPoolAmountIn(
        address pool,
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut) {

        address wrappedLPT = xTokenWrapper.tokenToXToken(pool);

        transferFrom(IXToken(wrappedLPT), poolAmountIn);

        require(xTokenWrapper.unwrap(wrappedLPT, poolAmountIn), "ERR_UNWRAP_POOL");

        tokenAmountOut = IBPool(pool).exitswapPoolAmountIn(tokenOut, poolAmountIn, minAmountOut);

        transfer(IXToken(tokenOut), tokenAmountOut);

        emit ExitPool(msg.sender, pool, poolAmountIn);
    }

    function exitswapExternAmountOut(
        address pool,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPoolAmountIn
    ) external returns (uint256 poolAmountIn) {

        address wrappedLPT = xTokenWrapper.tokenToXToken(pool);

        transferFrom(IXToken(wrappedLPT), maxPoolAmountIn);

        require(xTokenWrapper.unwrap(wrappedLPT, maxPoolAmountIn), "ERR_UNWRAP_POOL");

        poolAmountIn = IBPool(pool).exitswapExternAmountOut(tokenOut, tokenAmountOut, maxPoolAmountIn);

        transfer(IXToken(tokenOut), tokenAmountOut);

        uint256 remainingLPT = maxPoolAmountIn.sub(poolAmountIn);
        if (remainingLPT > 0) {
            IBPool(pool).approve(address(xTokenWrapper), remainingLPT);
            require(xTokenWrapper.wrap(pool, remainingLPT), "ERR_WRAP_POOL");

            transfer(IXToken(wrappedLPT), remainingLPT);
        }

        emit ExitPool(msg.sender, pool, poolAmountIn);
    }

    function viewSplitExactIn(
        address tokenIn,
        address tokenOut,
        uint256 swapAmount,
        uint256 nPools
    ) public view returns (Swap[] memory swaps, uint256 totalOutput) {

        address[] memory poolAddresses = registry.getBestPoolsWithLimit(tokenIn, tokenOut, nPools);

        Pool[] memory pools = new Pool[](poolAddresses.length);
        uint256 sumEffectiveLiquidity;
        for (uint256 i = 0; i < poolAddresses.length; i++) {
            pools[i] = getPoolData(tokenIn, tokenOut, poolAddresses[i]);
            sumEffectiveLiquidity = sumEffectiveLiquidity.add(pools[i].effectiveLiquidity);
        }

        uint256[] memory bestInputAmounts = new uint256[](pools.length);
        uint256 totalInputAmount;
        for (uint256 i = 0; i < pools.length; i++) {
            bestInputAmounts[i] = swapAmount.mul(pools[i].effectiveLiquidity).div(sumEffectiveLiquidity);
            totalInputAmount = totalInputAmount.add(bestInputAmounts[i]);
        }

        if (totalInputAmount < swapAmount) {
            bestInputAmounts[0] = bestInputAmounts[0].add(swapAmount.sub(totalInputAmount));
        } else {
            bestInputAmounts[0] = bestInputAmounts[0].sub(totalInputAmount.sub(swapAmount));
        }

        swaps = new Swap[](pools.length);

        for (uint256 i = 0; i < pools.length; i++) {
            swaps[i] = Swap({
                pool: pools[i].pool,
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                swapAmount: bestInputAmounts[i],
                limitReturnAmount: 0,
                maxPrice: uint256(-1)
            });
        }

        totalOutput = calcTotalOutExactIn(bestInputAmounts, pools);

        return (swaps, totalOutput);
    }

    function viewSplitExactOut(
        address tokenIn,
        address tokenOut,
        uint256 swapAmount,
        uint256 nPools
    ) public view returns (Swap[] memory swaps, uint256 totalInput) {

        address[] memory poolAddresses = registry.getBestPoolsWithLimit(tokenIn, tokenOut, nPools);

        Pool[] memory pools = new Pool[](poolAddresses.length);
        uint256 sumEffectiveLiquidity;
        for (uint256 i = 0; i < poolAddresses.length; i++) {
            pools[i] = getPoolData(tokenIn, tokenOut, poolAddresses[i]);
            sumEffectiveLiquidity = sumEffectiveLiquidity.add(pools[i].effectiveLiquidity);
        }

        uint256[] memory bestInputAmounts = new uint256[](pools.length);
        uint256 totalInputAmount;
        for (uint256 i = 0; i < pools.length; i++) {
            bestInputAmounts[i] = swapAmount.mul(pools[i].effectiveLiquidity).div(sumEffectiveLiquidity);
            totalInputAmount = totalInputAmount.add(bestInputAmounts[i]);
        }

        if (totalInputAmount < swapAmount) {
            bestInputAmounts[0] = bestInputAmounts[0].add(swapAmount.sub(totalInputAmount));
        } else {
            bestInputAmounts[0] = bestInputAmounts[0].sub(totalInputAmount.sub(swapAmount));
        }

        swaps = new Swap[](pools.length);

        for (uint256 i = 0; i < pools.length; i++) {
            swaps[i] = Swap({
                pool: pools[i].pool,
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                swapAmount: bestInputAmounts[i],
                limitReturnAmount: uint256(-1),
                maxPrice: uint256(-1)
            });
        }

        totalInput = calcTotalOutExactOut(bestInputAmounts, pools);

        return (swaps, totalInput);
    }

    function getPoolData(
        address tokenIn,
        address tokenOut,
        address poolAddress
    ) internal view returns (Pool memory) {

        IBPool pool = IBPool(poolAddress);
        uint256 tokenBalanceIn = pool.getBalance(tokenIn);
        uint256 tokenBalanceOut = pool.getBalance(tokenOut);
        uint256 tokenWeightIn = pool.getDenormalizedWeight(tokenIn);
        uint256 tokenWeightOut = pool.getDenormalizedWeight(tokenOut);
        uint256 swapFee = pool.getSwapFee();

        uint256 effectiveLiquidity = calcEffectiveLiquidity(tokenWeightIn, tokenBalanceOut, tokenWeightOut);
        Pool memory returnPool =
            Pool({
                pool: poolAddress,
                tokenBalanceIn: tokenBalanceIn,
                tokenWeightIn: tokenWeightIn,
                tokenBalanceOut: tokenBalanceOut,
                tokenWeightOut: tokenWeightOut,
                swapFee: swapFee,
                effectiveLiquidity: effectiveLiquidity
            });

        return returnPool;
    }

    function calcEffectiveLiquidity(
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut
    ) internal pure returns (uint256 effectiveLiquidity) {

        effectiveLiquidity = tokenWeightIn.mul(BONE).div(tokenWeightOut.add(tokenWeightIn)).mul(tokenBalanceOut).div(
            BONE
        );

        return effectiveLiquidity;
    }

    function calcTotalOutExactIn(uint256[] memory bestInputAmounts, Pool[] memory bestPools)
        internal
        pure
        returns (uint256 totalOutput)
    {

        totalOutput = 0;
        for (uint256 i = 0; i < bestInputAmounts.length; i++) {
            uint256 output =
                IBPool(bestPools[i].pool).calcOutGivenIn(
                    bestPools[i].tokenBalanceIn,
                    bestPools[i].tokenWeightIn,
                    bestPools[i].tokenBalanceOut,
                    bestPools[i].tokenWeightOut,
                    bestInputAmounts[i],
                    bestPools[i].swapFee
                );

            totalOutput = totalOutput.add(output);
        }
        return totalOutput;
    }

    function calcTotalOutExactOut(uint256[] memory bestInputAmounts, Pool[] memory bestPools)
        internal
        pure
        returns (uint256 totalOutput)
    {

        totalOutput = 0;
        for (uint256 i = 0; i < bestInputAmounts.length; i++) {
            uint256 output =
                IBPool(bestPools[i].pool).calcInGivenOut(
                    bestPools[i].tokenBalanceIn,
                    bestPools[i].tokenWeightIn,
                    bestPools[i].tokenBalanceOut,
                    bestPools[i].tokenWeightOut,
                    bestInputAmounts[i],
                    bestPools[i].swapFee
                );

            totalOutput = totalOutput.add(output);
        }
        return totalOutput;
    }

    function transferFrom(IXToken token, uint256 amount) internal {

        require(token.transferFrom(msg.sender, address(this), amount), "ERR_TRANSFER_FAILED");
    }

    function transferFeeFrom(
        IXToken token,
        uint256 amount,
        bool useUtitlityToken
    ) internal {

        if (useUtitlityToken && utilityToken != address(0) && address(utilityTokenFeed) != address(0)) {
            uint256 discountedFee = utilityTokenFeed.calculateAmount(address(token), amount.div(2));

            if (discountedFee > 0) {
                require(
                    IERC20(utilityToken).transferFrom(msg.sender, feeReceiver, discountedFee),
                    "ERR_FEE_UTILITY_TRANSFER_FAILED"
                );
            } else {
                require(token.transferFrom(msg.sender, feeReceiver, amount), "ERR_FEE_TRANSFER_FAILED");
            }
        } else {
            require(token.transferFrom(msg.sender, feeReceiver, amount), "ERR_FEE_TRANSFER_FAILED");
        }
    }

    function getBalance(IXToken token) internal view returns (uint256) {

        return token.balanceOf(address(this));
    }

    function transfer(IXToken token, uint256 amount) internal {

        require(token.transfer(msg.sender, amount), "ERR_TRANSFER_FAILED");
    }
}