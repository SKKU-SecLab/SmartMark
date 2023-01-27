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

}pragma solidity >=0.6.2;


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

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IPoolInitializer {

    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;


interface IERC721Permit is IERC721 {

    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

}// GPL-2.0-or-later
pragma solidity >=0.7.5;

interface IPeripheryPayments {

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;


    function refundETH() external payable;


    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IPeripheryImmutableState {

    function factory() external view returns (address);


    function WETH9() external view returns (address);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library PoolAddress {

    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {

        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {

        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}// GPL-2.0-or-later
pragma solidity >=0.7.5;



interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{

    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );


    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );


    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);


    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);


    function burn(uint256 tokenId) external payable;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}// GPL-2.0-or-later
pragma solidity >=0.7.5;


interface ISwapRouter is IUniswapV3SwapCallback {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

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
}pragma solidity >=0.7.6;
interface PoolInterface {

    function swapExactAmountIn(address, uint, address, uint, uint) external returns (uint, uint);

    function swapExactAmountOut(address, uint, address, uint, uint) external returns (uint, uint);

}

interface IWeth{

    function deposit() external payable;

    function withdraw(uint wad) external;

    function approve(address guy, uint wad) external returns (bool);

    function balanceOf(address owner) external view returns(uint);

}


contract Ownable {

    address payable public _OWNER_;
    address payable public _NEW_OWNER_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    constructor() {
        _OWNER_ = msg.sender;
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    function transferOwnership(address payable newOwner) external onlyOwner {

        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() external {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

contract Tradable is Ownable{

    mapping(address=>bool) _ALLOWEDTRADERS_;
    
    modifier onlyTraders(){

        require(_ALLOWEDTRADERS_[msg.sender],"NOT_TRADER");
        _;
    }
    
    function approveTraderAddress (address trader) external onlyOwner {
        _ALLOWEDTRADERS_[trader] = true;
    }
    
    function removeTraderAddress (address trader) external onlyOwner {
        require(_ALLOWEDTRADERS_[trader],"TRADER_NOT_IN_LIST");
        _ALLOWEDTRADERS_[trader] = false;
    }
    
}

contract Trader is Ownable,Tradable {

  address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address internal constant NFT_ADDRESS = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
  address internal constant UNISWAPV3_ROUTER_ADDRESS = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
  IUniswapV2Router02 public uniswapRouter;
  ISwapRouter public UniswapV3Router;
  INonfungiblePositionManager public NftPositionManager;
    
 constructor() {
    uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    UniswapV3Router = ISwapRouter(UNISWAPV3_ROUTER_ADDRESS);
    NftPositionManager = INonfungiblePositionManager(NFT_ADDRESS);
  }
function setUniSwapRouter(address uniswap_router_addr)external onlyOwner
{

  uniswapRouter = IUniswapV2Router02(uniswap_router_addr);
}

function balanceOfToken(address token_address) external view returns(uint){

    IERC20 token = IERC20(token_address);
    return token.balanceOf(address(this));
}

function balanceOfThis() external view returns(uint) {

    return address(this).balance;
}

  
function withdrawAllFunds() external onlyOwner {

    msg.sender.transfer(address(this).balance);
}

function withdrawFunds(uint withdrawAmount) external onlyOwner {

    require(withdrawAmount <= address(this).balance);
    msg.sender.transfer(withdrawAmount);
}

function withdrawToken(uint withdrawAmount, address token_address) external onlyOwner {

    IERC20 token = IERC20(token_address);
    uint token_balance = token.balanceOf(address(this));
    require(withdrawAmount <= token_balance);
    SafeERC20.safeTransfer(token, msg.sender,withdrawAmount);
}

function withdrawAllToken(address token_address) external onlyOwner {

    IERC20 token = IERC20(token_address);
    SafeERC20.safeTransfer(token, msg.sender,token.balanceOf(address(this)));
}

function withdrawAllFundsToOwner() external onlyTraders {

    _OWNER_.transfer(address(this).balance);
}

function withdrawTokensToOnwer(uint withdrawAmount, address token_address) external onlyTraders {

    IERC20 token = IERC20(token_address);
    uint token_balance = token.balanceOf(address(this));
    require(withdrawAmount <= token_balance);
    SafeERC20.safeTransfer(token, _OWNER_, withdrawAmount);
}

function withdrawAllTokenToOwner(address token_address) external onlyTraders {

    IERC20 token = IERC20(token_address);
    SafeERC20.safeTransfer(token, _OWNER_,token.balanceOf(address(this)));
}


function swapETHtoWETH(uint amounts) external onlyTraders {

    IWeth weth = IWeth(uniswapRouter.WETH());
    weth.deposit{value:amounts}();
}

function swapWETHtoETH(uint amounts) external onlyTraders {

    IWeth weth = IWeth(uniswapRouter.WETH());
    weth.withdraw(amounts);
}

function provideLiquidity(address token0,
    address token1,
    uint24 fee,
    int24 tickLower,
    int24 tickUpper,
    uint256 amount0Desired,
    uint256 amount1Desired,
    uint256 amount0Min,
    uint256 amount1Min) external onlyTraders {

        
    uint256 deadline = block.timestamp + 15;
    IERC20 Itoken0 = IERC20(token0);
    IERC20 Itoken1 = IERC20(token1);
    INonfungiblePositionManager.MintParams memory mintparam = INonfungiblePositionManager.MintParams(token0,token1,fee,tickLower,tickUpper,amount0Desired,amount1Desired,amount0Min,amount1Min,address(this),deadline);
    NftPositionManager.mint(mintparam);
    
}
function approveToken(address token_address, address swap_address) external onlyTraders
  {

      IERC20 token = IERC20(token_address);
      SafeERC20.safeApprove(token,swap_address,type(uint).max);
  }
function removeLiquidity(uint256 tokenId, 
    uint128 liquidity, 
    uint128 amount0Max, 
    uint128 amount1Max,
    uint256 amount0Min,
    uint256 amount1Min) external onlyTraders {

        
    uint256 deadline = block.timestamp + 15;
    INonfungiblePositionManager.DecreaseLiquidityParams memory DecLiqParams = INonfungiblePositionManager.DecreaseLiquidityParams(tokenId, liquidity, amount0Min, amount1Min,deadline);
    INonfungiblePositionManager.CollectParams memory CollLiqParams = INonfungiblePositionManager.CollectParams(tokenId, address(this), amount0Max, amount1Max);
    NftPositionManager.decreaseLiquidity(DecLiqParams);
    NftPositionManager.collect(CollLiqParams);
}

function removeLiquidityFromPool(uint256 tokenId,
    uint128 amount0Max, 
    uint128 amount1Max) external onlyTraders {

        INonfungiblePositionManager.CollectParams memory CollLiqParams = INonfungiblePositionManager.CollectParams(tokenId, address(this), amount0Max, amount1Max);
        NftPositionManager.collect(CollLiqParams);
}

event InsertOrderV3(uint amountIn, uint amountOut, address inAddress, address outAddress);

function insertOrderV3Buy(uint amount, uint maxin, address[] memory paths, uint24[] memory fees) external onlyTraders {

    require(paths.length == 2);
    uint deadline = block.timestamp + 15;
    uint amounts = amount;
    uint amountInMaximum = type(uint).max;
    ISwapRouter.ExactOutputSingleParams memory ExactOutputParams;

    ExactOutputParams = ISwapRouter.ExactOutputSingleParams(
        paths[0],
        paths[1],
        fees[0],
        address(this),
        deadline,
        amounts,
        amountInMaximum,
        0
    );

    amounts = UniswapV3Router.exactOutputSingle(ExactOutputParams);
    emit InsertOrderV3(amounts,amount,paths[0],paths[paths.length-1]);
}

function insertOrderV3Sell(uint amount, uint minout, address[] memory paths, uint24[] memory fees) external onlyTraders{

    uint deadline = block.timestamp + 15;
    uint amounts = amount;
    uint amountOutMinimum = 0;
    ISwapRouter.ExactInputSingleParams memory ExactInputParam;
        
    for(uint i = 0;i<paths.length-1;i++)
    {
        if(i == paths.length-2)
        {
            amountOutMinimum = minout;
        }

        ExactInputParam = ISwapRouter.ExactInputSingleParams(
            paths[i],
            paths[i+1],
            fees[i],
            address(this),
            deadline,
            amounts,
            amountOutMinimum,
            0
        );
        amounts = UniswapV3Router.exactInputSingle(ExactInputParam);
    }
    emit InsertOrderV3(amount, amounts,paths[0],paths[paths.length-1]);
}

function insertOrder(uint amount, address[] memory paths) external onlyTraders returns(uint){

    uint deadline = block.timestamp + 15;
    uint amounts = amount;
    
    for(uint i = 0;i<paths.length-1;i++)
    {
        IERC20 token = IERC20(paths[i]);
        SafeERC20.safeApprove(token,UNISWAP_ROUTER_ADDRESS,amounts);
        amounts = uniswapRouter.swapExactTokensForTokens(amounts, 1, getPathBetween(paths[i],paths[i+1]), address(this), deadline)[1];
        
    }

  return amounts;
}
  
function insertOrder(uint amount, address[] memory paths, uint expect_out) external onlyTraders returns(uint){

    uint deadline = block.timestamp + 15;
    uint amounts = amount;
    uint amounts_check = amount;
    for(uint i = 0;i<paths.length-1;i++)
    {
        amounts_check = uniswapRouter.getAmountsOut(amounts_check, getPathBetween(paths[i],paths[i+1]))[1];
    }
    require(amounts_check > expect_out,"INSERT CANCELLED");
    
    for(uint i = 0;i<paths.length-1;i++)
    {
        IERC20 token = IERC20(paths[i]);
        SafeERC20.safeApprove(token,UNISWAP_ROUTER_ADDRESS,amounts);
        amounts = uniswapRouter.swapExactTokensForTokens(amounts, 1, getPathBetween(paths[i],paths[i+1]), address(this), deadline)[1];
        
    }
    
  return amounts;
}
  
  function getPathBetween(address p1, address p2) private returns (address[] memory)
  {

      address[] memory path = new address[](2);
      path[0] = p1;
      path[1] = p2;
      return path;
  }

  receive() payable external {}
}