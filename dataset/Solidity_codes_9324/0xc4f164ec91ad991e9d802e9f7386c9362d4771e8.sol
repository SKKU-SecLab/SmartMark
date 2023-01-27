
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
pragma solidity ^0.7.0;


contract Ownable is Context {


    address private _owner;
    address private proposedOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        proposedOwner = address(0);
    }

    function proposeOwner(address _proposedOwner) public onlyOwner {

        require(msg.sender != _proposedOwner, "ERROR_CALLER_ALREADY_OWNER");
        proposedOwner = _proposedOwner;
    }

    function claimOwnership() public {

        require(msg.sender == proposedOwner, "ERROR_NOT_PROPOSED_OWNER");
        emit OwnershipTransferred(_owner, proposedOwner);
        _owner = proposedOwner;
        proposedOwner = address(0);
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

    function burn(uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

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
}

pragma solidity ^0.7.0;

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
}

pragma solidity ^0.7.0;


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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


contract Shop is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct Sale {
        uint256 product;
        address token;
        uint256 tokenPrice;
        uint256 wethPrice;
        uint256 productPrice;
        uint256 time;
    }

    struct Product {
        uint256 id;
        string image;
        uint256 price;
        bool available;
    }


    mapping(address => bytes32) public users;

    mapping(address => Sale[]) history;

    mapping(uint256 => Product) products;
    uint256[] productsList;


    address public immutable router;
    IUniswapV2Factory public immutable factory;

    address public immutable chargeToken;
    address public immutable prefToken;
    address public immutable WETH;

    uint256 public fee;
    uint256 public feeForPrefToken;

    bool public initialized;
    bool public buyBackAndBurn;

    event Purchase(address addr, uint256 product);
    event PurchaseCustomOrder(address addr, uint256 orderId, uint256 payed_price);

    constructor(address _router, address _factory, address _receiveToken, address _prefToken, address _weth) {
        router = _router;
        factory = IUniswapV2Factory(_factory);
        chargeToken = _receiveToken;
        prefToken = _prefToken;
        WETH = _weth;

        initialized = false;
        buyBackAndBurn = false;
        fee = 4;
        feeForPrefToken = 3;
    }

    function getUserHash(address _user) public view returns (bytes32) {

        return users[_user];
    }

    function getEmailHash(string calldata email) public pure returns (bytes32) {

        return keccak256(abi.encode(email));
    }

    function getProduct(uint256 _id) public view returns(Product memory) {

        return products[_id];
    }

    function getProductsList() public view returns(uint256[] memory) {

        return productsList;
    }

    function getUserHistory() public view returns (Sale[] memory) {

        return history[msg.sender];
    }

    function getProductPrice(uint256 _id) public view returns (uint256) {

        return products[_id].price;
    }

    function getProductPricesOnSpecificTokenForCustomOrder(uint256 _price, address _token, uint256 slippage) public view returns (uint256, uint256) {

        uint256 saleFee;
        if (_token == prefToken) {
            saleFee = feeForPrefToken;
        } else {
            saleFee = fee;
        }

        require(_price != 0, "POS: getProductPricesOnSpecificTokenForCustomOrder specific order price cannot be 0");

        uint256 finalPrice = _price.add(_price.mul(saleFee).div(100));

        if (_token == chargeToken) {
            return (finalPrice, 0);
        }

        uint256 wethPrice = calcWethPrice(finalPrice, slippage);

        if (_token == WETH) {
            return (finalPrice, wethPrice);
        }

        uint256 tokenPrice = calcTokenPrice(_token, wethPrice, slippage);

        return (finalPrice, tokenPrice);
    }

    function getProductPricesOnSpecificToken(uint256 _id, address _token, uint256 slippage) public view returns (uint256, uint256, uint256) {


        uint256 saleFee;
        if (_token == prefToken) {
            saleFee = feeForPrefToken;
        } else {
            saleFee = fee;
        }

        require(products[_id].price != 0, "POS: getProductPricesOnSpecificToken product doesn't exist");

        uint256 finalPrice = products[_id].price.add(products[_id].price.mul(saleFee).div(100));

        if (_token == chargeToken) {
            return (finalPrice,0,0);
        }

        uint256 wethPrice = calcWethPrice(finalPrice, slippage);

        if (_token == WETH) {
            return (finalPrice, wethPrice, 0);
        }

        uint256 tokenPrice = calcTokenPrice(_token, wethPrice, slippage);

        return (finalPrice, wethPrice, tokenPrice);
    }

    function calcWethPrice(uint256 chargePrice, uint256 slippage) internal view returns (uint256) {

        (uint112 chargeTokenReserves, uint112 wethReserves,) = IUniswapV2Pair(factory.getPair(chargeToken, WETH)).getReserves();
        uint256 wethPrice = chargePrice.mul(wethReserves).div(chargeTokenReserves);

        return wethPrice.add(wethPrice.mul(slippage).div(100));
    }

    function calcTokenPrice(address _token, uint256 wethPrice, uint256 slippage) internal view returns (uint256) {

        address tokenSalePair = factory.getPair(_token, WETH);
        require(tokenSalePair != address(0), "POS: getProductPriceOnSpecificToken pair doesn't exist for this token");

        (uint112 tokenReserves, uint112 wethTokenReserves,) = IUniswapV2Pair(tokenSalePair).getReserves();
        uint256 tokenPrice = wethPrice.mul(tokenReserves).div(wethTokenReserves);

        return tokenPrice.add(tokenPrice.mul(slippage).div(100));
    }


    function setInitialize(bool _init) public onlyOwner {

        initialized = _init;
    }

    function setBuyBackAndBurn(bool _set) public onlyOwner {

        buyBackAndBurn = _set;
    }

    function buyCustomOrder(uint256 _orderID, address _token, uint256 slippage, uint256 _orderPrice) public {

        require(initialized, "POS: Shop is closed, please try again later");

        (uint256 finalPrice, uint256 tokenPrice) = getProductPricesOnSpecificTokenForCustomOrder(_orderPrice, _token, slippage);

        if (_token == chargeToken) {
            IERC20(chargeToken).safeTransferFrom(msg.sender, address(this), finalPrice);

            if (buyBackAndBurn) {
                buyBackAndBurnTokens(finalPrice);
            }

            emit PurchaseCustomOrder(msg.sender, _orderID, finalPrice);

        } else if (_token == WETH) {

            IERC20(WETH).safeTransferFrom(msg.sender, address(this), tokenPrice);

            swapWETHToChargeToken(finalPrice, tokenPrice);

            emit PurchaseCustomOrder(msg.sender, _orderID, finalPrice);

        } else {

            IERC20(_token).safeTransferFrom(msg.sender, address(this), tokenPrice);

            swapTokenToChargeToken(_token, finalPrice, tokenPrice);

            emit PurchaseCustomOrder(msg.sender, _orderID, finalPrice);

        }

    }

    function buy(uint256 _id, address _token, uint256 slippage) public {

        require(initialized, "POS: Shop is closed, please try again later");

        require(users[msg.sender] != "", "POS: buy user is not registered on-chain");

        (uint256 chargePrice, uint256 wethPrice, uint256 tokenPrice) = getProductPricesOnSpecificToken(_id, _token, slippage);

        if (_token == chargeToken) {
            IERC20(chargeToken).safeTransferFrom(msg.sender, address(this), chargePrice);

            if (buyBackAndBurn) {
                buyBackAndBurnTokens(chargePrice);
            }

            addSaleToUserHistory(_id, _token, tokenPrice, wethPrice, chargePrice);
            emit Purchase(msg.sender, _id);

        } else if (_token == WETH) {

            IERC20(WETH).safeTransferFrom(msg.sender, address(this), wethPrice);

            swapWETHToChargeToken(chargePrice, wethPrice);

            addSaleToUserHistory(_id, _token, tokenPrice, wethPrice, chargePrice);
            emit Purchase(msg.sender, _id);

        } else {

            IERC20(_token).safeTransferFrom(msg.sender, address(this), tokenPrice);

            swapTokenToChargeToken(_token, chargePrice, tokenPrice);

            addSaleToUserHistory(_id, _token, tokenPrice, wethPrice, chargePrice);
            emit Purchase(msg.sender, _id);

        }

    }

    function buyBackAndBurnTokens(uint256 chargePrice) internal {


        uint256 amountBuy = chargePrice.div(100);
        address[] memory path = new address[](3);
        path[0] = chargeToken;
        path[1] = WETH;
        path[2] = prefToken;


        uint256 allowance = IERC20(chargeToken).allowance(address(this), router);
        if (allowance < amountBuy) {
            IERC20(chargeToken).approve(router, uint256(-1));
        }

        IUniswapV2Router02(router).swapExactTokensForTokens(amountBuy, 0, path, address(this), block.timestamp + 2000);

        IERC20(prefToken).transfer(address(0xdeAD00000000000000000000000000000000dEAd), IERC20(prefToken).balanceOf(address(this)));
    }

    function swapWETHToChargeToken(uint256 chargePrice, uint256 wethPrice) internal {


        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = chargeToken;

        uint256 allowance = IERC20(WETH).allowance(address(this), router);
        if (allowance < wethPrice) {
            IERC20(WETH).approve(router, uint256(-1));
        }

        IUniswapV2Router02(router).swapExactTokensForTokens(wethPrice, chargePrice, path, address(this), block.timestamp + 200);

        if (buyBackAndBurn) {
            buyBackAndBurnTokens(chargePrice);
        }

    }

    function swapTokenToChargeToken(address _token, uint256 chargePrice, uint256 tokenAmount) internal {


        address[] memory path = new address[](3);
        path[0] = _token;
        path[1] = WETH;
        path[2] = chargeToken;

        uint256 allowance = IERC20(_token).allowance(address(this), router);
        if (allowance < tokenAmount) {
            IERC20(_token).approve(router, uint256(-1));
        }

        IUniswapV2Router02(router).swapExactTokensForTokens(tokenAmount, chargePrice, path, address(this), block.timestamp + 200);

        if (buyBackAndBurn) {
            buyBackAndBurnTokens(chargePrice);
        }

    }

    function addSaleToUserHistory(uint256 _id, address _token, uint256 tokenPrice, uint256 wethPrice, uint256 chargePrice) internal {

        Sale memory sale = Sale(_id, _token, tokenPrice, wethPrice, chargePrice, block.timestamp);
        history[msg.sender].push(sale);
    }


    function register(string calldata email) public {

        users[msg.sender] = getEmailHash(email);
    }

    function setFee(uint256 newFee) public onlyOwner {

        fee = newFee;
    }

    function setFeeForPrefToken(uint256 newFee) public onlyOwner {

        feeForPrefToken = newFee;
    }

    function claim() public onlyOwner {

        uint256 balance = IERC20(chargeToken).balanceOf(address(this));
        IERC20(chargeToken).safeTransfer(owner(), balance);
    }

    function addBulkProducts(Product[] memory _products) public onlyOwner {

        uint256 length = _products.length;
        require(length < 200, "POS: addBulkProducts can only add a maximum of 200 products");
        for (uint256 i = 0; i < length; i++) {
            addProduct(_products[i]);
        }
    }

    function addProduct(Product memory _product) public onlyOwner {

        if (products[_product.id].id == 0 && products[_product.id].price == 0) {
            productsList.push(_product.id);
        }
        products[_product.id] = _product;
    }
}
