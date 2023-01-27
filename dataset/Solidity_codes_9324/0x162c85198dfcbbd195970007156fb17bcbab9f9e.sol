
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}


pragma solidity ^0.6.2;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint amount) external;

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


pragma solidity ^0.6.2;





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
}


pragma solidity ^0.6.2;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    function initReentrancyStatus() internal {

        _status = _NOT_ENTERED;
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


pragma solidity >=0.6.2;

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


pragma solidity >=0.6.2;



library UniswapV2Library {

    using SafeMath for uint256;

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
                    )
                )
            )
        );
    }

    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(
            pairFor(factory, tokenA, tokenB)
        )
            .getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(
            reserveA > 0 && reserveB > 0,
            'UniswapV2Library: INSUFFICIENT_LIQUIDITY'
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(
            reserveIn > 0 && reserveOut > 0,
            'UniswapV2Library: INSUFFICIENT_LIQUIDITY'
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(
            reserveIn > 0 && reserveOut > 0,
            'UniswapV2Library: INSUFFICIENT_LIQUIDITY'
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}


pragma solidity ^0.6.2;

pragma experimental ABIEncoderV2;









contract NFT1155MarketV2 is ReentrancyGuard {


    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bool private initialized; // Flag of initialize data
    
    address public _governance;

    mapping(address => bool) public _supportCurrency;

    IERC20 public _dandy = IERC20(0x0);
    bool public _isRewardSellerDandy = false;
    bool public _isRewardBuyerDandy = false;
    uint256 public _sellerRewardDandy = 1e15;
    uint256 public _buyerRewardDandy = 1e15;

    struct SalesObject {
        uint256 id;
        uint256 tokenId;
        uint256 unitPrice;
        uint8 status;
        address payable seller;
        IERC1155 nft;
        uint256 amount;
        uint256 initAmount;
        address currency;
        address[] buyers;
    }

    uint256 public _salesAmount = 0;

    SalesObject[] _salesObjects;

    mapping(address => bool) public _supportNft;

    uint256 public _tipsFeeRate = 20;
    uint256 public _baseRate = 1000;
    address payable _tipsFeeWallet;

    event eveSales(
        uint256 indexed id, 
        uint256 tokenId,
        address buyer, 
        uint256 price,
        uint256 tipsFee,
        uint256 sellAmount,
        uint256 surplusAmount
    );

    event eveNewSales(
        uint256 indexed id,
        uint256 tokenId, 
        address seller, 
        address nft,
        address buyer, 
        uint256 unitPrice,
        uint256 amount,
        address currency
    );

    event eveCancelSales(
        uint256 indexed id,
        uint256 tokenId
    );

    event eveNFTReceived(
        address operator, 
        address from, 
        uint256 tokenId, 
        uint256 value,
        bytes data
    );

    event eveSupportCurrency(
        address currency, 
        bool support
    );

    event eveSupportNft(
        address nft,
        bool support
    );

    event GovernanceTransferred(
        address indexed previousOwner, 
        address indexed newOwner
    );

    mapping(address => SupportBuyCurrency) public _supportBuyCurrency;

    mapping(uint256=>uint256) public deflationBaseRates;
    mapping(uint256=>address) public routers;
    
    struct SupportBuyCurrency {
        bool status;
        bool isDeflation;
        uint256 deflationRate;
    }
    
    event eveSupportBuyCurrency(
        address currency, 
        bool status,
        bool isDeflation,
        uint256 deflationRate
    );

    event eveDeflationBaseRate(
        uint256 deflationBaseRate
    );

    fallback() external {}
    receive() payable external {}

    function initialize(
        address payable tipsFeeWallet,
        uint256 minDurationTime,
        uint256 tipsFeeRate,
        uint256 baseRate,
        IERC20 dandy
    ) public {

        require(!initialized, "initialize: Already initialized!");
        _governance = msg.sender;
        _tipsFeeWallet = tipsFeeWallet;
        _tipsFeeRate = tipsFeeRate;
        _baseRate = baseRate;
        _dandy = dandy;
        _isRewardSellerDandy = false;
        _isRewardBuyerDandy = false;
        _sellerRewardDandy = 1e15;
        _buyerRewardDandy = 1e15;
        initReentrancyStatus();
        initialized = true;
    }

    modifier onlyGovernance {

        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {

        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


    modifier validAddress( address addr ) {

        require(addr != address(0x0));
        _;
    }

    modifier checkindex(uint index) {

        require(index <= _salesObjects.length, "overflow");
        _;
    }

    modifier checkSupportBuyCurrendy(address currency) {

        SupportBuyCurrency memory supportBuyCurrency = _supportBuyCurrency[currency];
        require(supportBuyCurrency.status == true, "not support currency");
        _;
    }

    modifier mustNotSellingOut(uint index) {

        require(index <= _salesObjects.length, "overflow");
        SalesObject storage obj = _salesObjects[index];
        require(obj.status == 0, "sry, selling out");
        _;
    }

    modifier onlySalesOwner(uint index) {

        require(index <= _salesObjects.length, "overflow");
        SalesObject storage obj = _salesObjects[index];
        require(obj.seller == msg.sender || msg.sender == _governance, "author & governance");
        _;
    }

    function seize(IERC20 asset) external onlyGovernance returns (uint256 balance) {

        balance = asset.balanceOf(address(this));
        asset.safeTransfer(_governance, balance);
    }

    function addSupportNft(address nft) public onlyGovernance validAddress(nft) {

        _supportNft[nft] = true;
        emit eveSupportNft(nft, true);
    }

    function removeSupportNft(address nft) public onlyGovernance validAddress(nft) {

        _supportNft[nft] = false;
        emit eveSupportNft(nft, false);
    }

    function addSupportCurrency(address erc20) public onlyGovernance {

        require(_supportCurrency[erc20] == false, "the currency have support");
        _supportCurrency[erc20] = true;
        emit eveSupportCurrency(erc20, true);
    }

    function removeSupportCurrency(address erc20) public onlyGovernance {

        require(_supportCurrency[erc20], "the currency can not remove");
        _supportCurrency[erc20] = false;
        emit eveSupportCurrency(erc20, false);
    }

    function setSupportBuyCurrency(address erc20,bool status,bool isDeflation,uint256 deflationRate ) public onlyGovernance {

        if (isDeflation) {
            require(deflationRate >0, "deflationRate 0");
        }
        _supportBuyCurrency[erc20] = SupportBuyCurrency(status,isDeflation,deflationRate);
        emit eveSupportBuyCurrency(erc20,status,isDeflation,deflationRate);
    }

    function setDeflationBaseRate(uint256 deflationRate_) public onlyGovernance {

        deflationBaseRates[0] = deflationRate_;
        emit eveDeflationBaseRate(deflationRate_);
    }

    function setIUniswapV2Router01(address router_) public onlyGovernance {

        routers[0] = router_;
    }


    function setTipsFeeWallet(address payable wallet) public onlyGovernance {

        _tipsFeeWallet = wallet;
    }

    function getSales(uint index) external view checkindex(index) returns(SalesObject memory) {

        return _salesObjects[index];
    }

    function getSalesBuyers(uint index) external view checkindex(index) returns(address[] memory) {

        SalesObject memory obj = _salesObjects[index];
        address[] memory saleBuyers = new address[](obj.buyers.length);
        saleBuyers = obj.buyers;
        return saleBuyers;
    }

    function getSalesPrice(uint index)
        external
        view
        checkindex(index)
        returns (uint256)
    {

        SalesObject storage obj = _salesObjects[index];
        return obj.unitPrice;
    }

    function setBaseRate(uint256 rate) external onlyGovernance {

        _baseRate = rate;
    }

    function setTipsFeeRate(uint256 rate) external onlyGovernance {

        _tipsFeeRate = rate;
    }

    
    function cancelSales(uint index) external checkindex(index) onlySalesOwner(index) mustNotSellingOut(index) nonReentrant {

        SalesObject storage obj = _salesObjects[index];
        obj.status = 2;
        obj.nft.safeTransferFrom(address(this), obj.seller, obj.tokenId, obj.amount, "");

        emit eveCancelSales(index, obj.tokenId);
    }

    function startSales(uint256 _tokenId,
                        uint256 _unitPrice,
                        address _nft,
                        uint256 _amount,
                        address _currency)
        external 
        nonReentrant
        validAddress(_nft)
        returns(uint)
    {

        uint256 tokenId = _tokenId;
        uint256 unitPrice = _unitPrice;
        address nft = _nft;
        uint256 amount = _amount;
        address currency = _currency;
        require(tokenId != 0, "invalid token");
        require(unitPrice >= 0, "invalid price");
        require(_supportNft[nft] == true, "cannot sales");
        require(_supportCurrency[currency] == true, "not support currency");

        IERC1155(nft).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        _salesAmount++;
        SalesObject memory obj;

        obj.id = _salesAmount;
        obj.tokenId = tokenId;
        obj.seller = msg.sender;
        obj.nft = IERC1155(nft);
        obj.unitPrice = unitPrice;
        obj.status = 0;
        obj.amount = amount;
        obj.initAmount = obj.amount;
        obj.currency = currency;
        
        if (_salesObjects.length == 0) {
            SalesObject memory zeroObj;
            zeroObj.tokenId = 0;
            zeroObj.seller = address(0x0);
            zeroObj.nft = IERC1155(0x0);
            zeroObj.unitPrice = unitPrice;
            zeroObj.status = 2;
            zeroObj.amount = 0;
            zeroObj.currency = address(0x0);
            _salesObjects.push(zeroObj);    
        }

        _salesObjects.push(obj);

        if(_isRewardSellerDandy) {
            _dandy.mint(msg.sender, _sellerRewardDandy);
        }

        emit eveNewSales(
            obj.id, 
            tokenId, 
            msg.sender, 
            nft, 
            address(0x0), 
            unitPrice,
            amount,
            currency
        );
        return _salesAmount;
    }

    function buy(uint index,uint256 _amount, address currency_)
        public
        nonReentrant
        mustNotSellingOut(index)
        checkSupportBuyCurrendy(currency_)
        payable 
    {

        uint256 amount = _amount;
        SalesObject storage obj = _salesObjects[index];
        require (obj.amount >= amount, "umm.....  It's too much");
        uint256 unitPrice = this.getSalesPrice(index);
        uint256 price = unitPrice.mul(amount);
        uint256 tipsFee = price.mul(_tipsFeeRate).div(_baseRate);
        uint256 purchase = price.sub(tipsFee);
        if (obj.currency == currency_){
            if (obj.currency == address(0x0)) { 
                require (msg.value >= this.getSalesPrice(index), "umm.....  your price is too low");
                uint256 returnBack = msg.value.sub(price);
                if(returnBack > 0) {
                    msg.sender.transfer(returnBack);
                }
                if(tipsFee > 0) {
                    _tipsFeeWallet.transfer(tipsFee);
                }
                obj.seller.transfer(purchase);
            } else {
                IERC20(obj.currency).safeTransferFrom(msg.sender, _tipsFeeWallet, tipsFee);
                IERC20(obj.currency).safeTransferFrom(msg.sender, obj.seller, purchase);
            }
        }else{
            if (obj.currency == address(0x0)){
                uint256 ethAmount = tokenToEth(currency_, price);
                require (ethAmount >= price, "umm.....  your price is too low");
                uint256 returnBack = ethAmount.sub(price).add(msg.value);
                if(returnBack > 0) {
                    msg.sender.transfer(returnBack);
                }
                if(tipsFee > 0) {
                    _tipsFeeWallet.transfer(tipsFee);
                }
                obj.seller.transfer(purchase);
            }else{
                require(false, "not support token");
            }
        }
        
        
        obj.nft.safeTransferFrom(address(this), msg.sender, obj.tokenId, amount, "");
        
        obj.buyers.push(msg.sender);
        obj.amount = obj.amount.sub(amount);

        if (obj.amount == 0) {
            obj.status = 1;    
        }

        if(_isRewardBuyerDandy) {
            _dandy.mint(msg.sender, _buyerRewardDandy);
        }
        emit eveSales(
            index, 
            obj.tokenId, 
            msg.sender, 
            price, 
            tipsFee, 
            amount, 
            obj.amount
        );
    }
    function setDandyAddress(address addr) external onlyGovernance validAddress(addr) {

        _dandy = IERC20(addr);
    }

    function setSellerRewardDandy(uint256 rewardDandy) public onlyGovernance {

        _sellerRewardDandy = rewardDandy;
    }

    function setBuyerRewardDandy(uint256 rewardDandy) public onlyGovernance {

        _buyerRewardDandy = rewardDandy;
    }

    function setIsRewardSellerDandy(bool isRewardSellerDandy) public onlyGovernance {

        _isRewardSellerDandy = isRewardSellerDandy;
    }

    function setIsRewardBuyerDandy(bool isRewardBuyerDandy) public onlyGovernance {

        _isRewardBuyerDandy = isRewardBuyerDandy;
    }


    function onERC1155Received(address operator, address from, uint256 tokenId, uint256 value, bytes calldata data) external returns (bytes4) {

        if(address(this) != operator) {
            return 0;
        }

        emit eveNFTReceived(operator, from, tokenId, value, data);
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }



        




       
        



    function tokenToEth(address erc20Token, uint256 amountOut) private returns(uint256) {

        address[] memory path = new address[](2);
        path[0] = erc20Token;
        path[1] = getRouter().WETH();
       
        uint256[] memory amounts = UniswapV2Library.getAmountsIn(getRouter().factory(), amountOut, path);
        uint256 amountIn = amounts[0];
        
        SupportBuyCurrency memory supportBuyCurrency = _supportBuyCurrency[erc20Token];
        if (supportBuyCurrency.isDeflation) {
            amountIn = amountIn.mul(getDeflationBaseRate()).div(supportBuyCurrency.deflationRate).mul(getDeflationBaseRate()).div(supportBuyCurrency.deflationRate);
        }

        uint256 balanceBefore = IERC20(erc20Token).balanceOf(address(this));
        IERC20(erc20Token).safeTransferFrom(msg.sender, address(this), amountIn);
        uint256 balanceAfter = IERC20(erc20Token).balanceOf(address(this));
        amountIn = balanceAfter.sub(balanceBefore);
        IERC20(erc20Token).approve(address(getRouter()), amountIn);
        
        uint256 ethBefore = address(this).balance;
        if (supportBuyCurrency.isDeflation) {
            getRouter().swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, 0, path, address(this), block.timestamp);
        } else {
            getRouter().swapTokensForExactETH(amountOut, amountIn, path, address(this), block.timestamp);
        }
        uint256 ethAfter = address(this).balance;

        uint256 balanceLast = IERC20(erc20Token).balanceOf(address(this));
        uint256 supAmount = balanceLast.sub(balanceBefore);
        if (supAmount>0){
            IERC20(erc20Token).safeTransfer(msg.sender, supAmount);
        }
        return ethAfter.sub(ethBefore);
    }

    function getDeflationBaseRate() public view returns(uint256) {

        return deflationBaseRates[0];
    }

    function getRouter() public view returns(IUniswapV2Router01) {

        return IUniswapV2Router01(routers[0]);
    }
}