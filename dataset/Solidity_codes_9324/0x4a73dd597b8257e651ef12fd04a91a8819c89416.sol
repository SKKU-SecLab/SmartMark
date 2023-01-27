
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
}pragma solidity >=0.6.2;

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
}pragma solidity ^0.7.4;


interface ILPPool {

    function balanceOf(address account) external view returns (uint256);


    function startTime() external view returns (uint256);


    function totalReward() external view returns (uint256);


    function earned(address account) external view returns (uint256);



    function stake(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function exit() external;


    function getReward() external;

}// MIT
pragma solidity >=0.4.22 <0.8.0;

interface ICurveFi {


  function get_virtual_price() external view returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);


  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);


  function coins(int128 arg0) external view returns (address);


  function underlying_coins(int128 arg0) external view returns (address);


  function balances(int128 arg0) external view returns (uint256);


  function add_liquidity(
    uint256[2] calldata amounts,
    uint256 deadline
  ) external;


  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);


  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);


  function remove_liquidity(
    uint256 _amount,
    uint256 deadline,
    uint256[2] calldata min_amounts
  ) external;


  function remove_liquidity_imbalance(
    uint256[2] calldata amounts,
    uint256 deadline
  ) external;

}pragma solidity 0.7.6;

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

}interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}//MIT" 
pragma solidity 0.7.6;


contract FAANGStrategy is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    struct Asset {
        uint256 weight;
        IERC20 mAssetToken;
        ILPPool lpPool;
        IERC20 lpToken;
        uint amountOfATotal;
        uint amountOfBTotal;
    }

    IERC20 public constant ust = IERC20(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD);
    IERC20 public constant mir = IERC20(0x09a3EcAFa817268f77BE1283176B946C4ff2E608);
    ICurveFi public constant curveFi = ICurveFi(0x890f4e345B1dAED0367A877a1612f86A1f86985f); 
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public constant factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    
    address public vault;
    address public treasuryWallet;
    address public communityWallet;
    address public strategist;
    
    address public constant DAIToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant mirUstPooltoken = 0x87dA823B6fC8EB8575a235A824690fda94674c88;
    ILPPool mirustPool;

    mapping(address => int128) curveIds;
    mapping(IERC20 => uint256) public userTotalLPToken;
    Asset[] public mAssets;

    uint reInvestedMirUstPooltoken;

    event HarvestedMIR(uint _mirHarvested);

    modifier onlyVault {

        require(msg.sender == vault, "only vault");
        _;
    }    

    constructor(
        address _treasuryWallet,
        address _communityWallet, 
        address _strategist,  
        address _mirustPool,
        uint[] memory weights,
        IERC20[] memory mAssetsTokens,
        ILPPool[] memory lpPools,
        IERC20[] memory lpTokens

        ) {
        
        
        curveIds[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = 2;
        curveIds[0xdAC17F958D2ee523a2206206994597C13D831ec7] = 3;
        curveIds[0x6B175474E89094C44Da98b954EedeAC495271d0F] = 1;

        treasuryWallet = _treasuryWallet;
        communityWallet = _communityWallet;
        strategist = _strategist;
        mirustPool = ILPPool(_mirustPool);

        IERC20(0x87dA823B6fC8EB8575a235A824690fda94674c88).approve(_mirustPool, type(uint).max); //approve mirUST uniswap LP token to stake on mirror
        ust.approve(address(router), type(uint256).max);
        ust.approve(address(curveFi), type(uint256).max);
        mir.approve(address(router), type(uint256).max);
        IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F).approve(address(router), type(uint256).max);
        IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F).approve(address(curveFi), type(uint256).max);
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).approve((address(router)), type(uint).max);
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).approve((address(curveFi)), type(uint).max);
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).safeApprove(address(router), type(uint).max);
        IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).safeApprove((address(curveFi)), type(uint).max);

        for(uint i=0; i<weights.length; i++) {
            mAssets.push(Asset({
                weight: weights[i],
                mAssetToken : mAssetsTokens[i],
                lpPool:lpPools[i],
                lpToken:lpTokens[i],
                amountOfATotal: 0,
                amountOfBTotal: 0
            }));

            mAssetsTokens[i].approve(address(router), type(uint).max);
            lpTokens[i].approve(_mirustPool, type(uint).max);
            lpTokens[i].approve(address(lpPools[i]), type(uint).max);
            lpTokens[i].approve(address(router), type(uint).max);
            IERC20(mirUstPooltoken).approve(address(router), type(uint).max);
        }



    }
    function deposit(uint256 _amount, IERC20 _token) external onlyVault {

        require(_amount > 0, 'Invalid amount');

        _token.safeTransferFrom(address(vault), address(this), _amount);

        
        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = address(ust);

        uint256 ustAmount = curveFi.exchange_underlying(curveIds[address(_token)], 0, _amount, 0);
        
        uint256[] memory amounts;        

        for (uint256 i = 0; i < mAssets.length; i++) {
            address addr_ = address(mAssets[i].mAssetToken);
            path[0] = address(ust);
            path[1] = addr_;
            uint _ustAmount = ustAmount.mul(mAssets[i].weight).div(10000);
            amounts = router.swapExactTokensForTokens(
                _ustAmount,
                0,
                path,
                address(this),
                block.timestamp
            );

            (, , uint256 poolTokenAmount) = router.addLiquidity(addr_,  address(ust), amounts[1], _ustAmount, 0, 0, address(this), block.timestamp);

            if(address(mAssets[i].lpPool) != address(0)) {  
                mAssets[i].lpPool.stake(poolTokenAmount);
            }


            userTotalLPToken[mAssets[i].lpToken] = userTotalLPToken[mAssets[i].lpToken].add(poolTokenAmount);


            (uint mAssetAmount, uint ustAmountFromPool) = updatelpTokenValue(address(mAssets[i].lpToken), userTotalLPToken[mAssets[i].lpToken]);   
            mAssets[i].amountOfATotal = mAssetAmount;
            mAssets[i].amountOfBTotal = ustAmountFromPool; 
            
        }

        
    }

    function withdraw(uint256 _amount, IERC20 _token) external onlyVault {

        require(_amount > 0, "Invalid Amount");
        require(_amount <= getTotalValueInPool(), "Amount cannot be greater than total");
        address[] memory path = new address[](2);
        path[0] = address(mir);
        path[1] = address(ust);

        uint valueInPool = getTotalValueInPool();
        
        for (uint256 i = 0; i < mAssets.length; i++) {
            uint amountOfLpTokenToRemove = getDataFromLPPool(address(mAssets[i].lpToken), _amount, valueInPool);
            
            if(address(mAssets[i].lpPool) != address(0)) {
                mAssets[i].lpPool.withdraw(amountOfLpTokenToRemove);
            } 

            (uint256 mAssetAmount, uint256 ustAmount) =
                router.removeLiquidity(
                    address(mAssets[i].mAssetToken),
                    address(ust),
                    amountOfLpTokenToRemove, 
                    0,
                    0,
                    address(this),
                    block.timestamp
                );

            path[0] = address(mAssets[i].mAssetToken);
            path[1] = address(ust);
            uint256[] memory amounts =
                router.swapExactTokensForTokens(
                    mAssetAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
            curveFi.exchange_underlying(0, curveIds[address(_token)], amounts[1].add(ustAmount), 0);

            userTotalLPToken[mAssets[i].lpToken] = userTotalLPToken[mAssets[i].lpToken].sub(amountOfLpTokenToRemove);
            

            (uint _mAssetAmount, uint _ustAmountFromPool) = updatelpTokenValue(address(mAssets[i].lpToken), userTotalLPToken[mAssets[i].lpToken]);   
            mAssets[i].amountOfATotal = _mAssetAmount;
            mAssets[i].amountOfBTotal = _ustAmountFromPool; 

            
        }

        withdrawFromMirUstPool(_amount, valueInPool, false);
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    }

    function withdrawFromMirUstPool(uint _amount, uint _valueInPool, bool _withdrawAll) internal {

        
        if(reInvestedMirUstPooltoken != 0) {  
    
            address[] memory path = new address[](2);
            uint amountToWithdraw;
            path[0] = address(mir);
            path[1] = address(ust);
 
           
            if(_withdrawAll == true) {
                amountToWithdraw = reInvestedMirUstPooltoken;
                mirustPool.getReward();
            } else {
                amountToWithdraw = reInvestedMirUstPooltoken.mul(_amount).div(_valueInPool);
                amountToWithdraw = amountToWithdraw > reInvestedMirUstPooltoken ? reInvestedMirUstPooltoken : amountToWithdraw;
            }           
            
            mirustPool.withdraw(amountToWithdraw);
            
                    router.removeLiquidity(
                        address(mir),
                        address(ust),
                        amountToWithdraw, 
                        0,
                        0,
                        address(this),
                        block.timestamp
                    );

            router.swapExactTokensForTokens(
                        mir.balanceOf(address(this)),
                        0,
                        path,
                        address(this),
                        block.timestamp
                    );

            reInvestedMirUstPooltoken = reInvestedMirUstPooltoken.sub(amountToWithdraw);
        }



    }

    function yield() external onlyVault{

        uint256 totalEarnedMIR;
        address[] memory path = new address[](2);
        for (uint256 i = 0; i < mAssets.length; i++) {        
            
            if(address(mAssets[i].lpPool) != address(0)) {
                uint earnedMIR = mAssets[i].lpPool.earned(address(this));
                if(earnedMIR != 0) {
                    path[0] = address(mir);
                    path[1] = address(ust);
                    mAssets[i].lpPool.getReward();

                    totalEarnedMIR = totalEarnedMIR.add(earnedMIR);


                    uint[] memory amounts = router.swapExactTokensForTokens(earnedMIR.mul(450).div(1000), 0, path, address(this), block.timestamp);
                    uint _ustAmount = amounts[1].div(2);
                    path[1] = address(mAssets[i].mAssetToken);

                    uint _mirAmount = earnedMIR.mul(2250).div(10000);

                    if(factory.getPair(address(mir), address(mAssets[i].mAssetToken)) == address(0)) {
                        address[] memory pathTemp = new address[](3);
                        uint[] memory amountsTemp ; 
                        pathTemp[0] = address(mir);
                        pathTemp[1] = address(ust);
                        pathTemp[2] = address(mAssets[i].mAssetToken);
                        amountsTemp = router.swapExactTokensForTokens(_mirAmount, 0, pathTemp, address(this), block.timestamp);  
                        amounts[1] = amountsTemp[2];
                    } else {
                        amounts = router.swapExactTokensForTokens(_mirAmount, 0, path, address(this), block.timestamp);
                    }
                    

                    (,,uint poolTokenAmount) = router.addLiquidity(address(mAssets[i].mAssetToken), address(ust), amounts[1], _ustAmount, 0, 0, address(this), block.timestamp);
                    mAssets[i].lpPool.stake(poolTokenAmount);

                    userTotalLPToken[mAssets[i].lpToken] = userTotalLPToken[mAssets[i].lpToken].add(poolTokenAmount);
                }
            }

            (uint mAssetAmount, uint ustAmount) = updatelpTokenValue(address(mAssets[i].lpToken), userTotalLPToken[mAssets[i].lpToken]);
            mAssets[i].amountOfATotal = mAssetAmount;
            mAssets[i].amountOfBTotal = ustAmount; 
        }

        totalEarnedMIR = totalEarnedMIR.add(mirustPool.earned(address(this)));
        mirustPool.getReward();
        
        emit HarvestedMIR(totalEarnedMIR);

        if(totalEarnedMIR > 0) {
            uint _yieldFee = totalEarnedMIR.div(10); //10%
            uint _splitFee = _yieldFee.mul(2).div(5);
            mir.safeTransfer(treasuryWallet, _splitFee);//4 % 
            mir.safeTransfer(communityWallet, _splitFee);//4 % 
            mir.safeTransfer(strategist, _yieldFee.sub(_splitFee).sub(_splitFee));//2 % 
                
            (,, uint poolTokenAmount) = router.addLiquidity(address(mir), address(ust), mir.balanceOf(address(this)), ust.balanceOf(address(this)), 0, 0, address(this), block.timestamp);
            mirustPool.stake(poolTokenAmount);

            reInvestedMirUstPooltoken = reInvestedMirUstPooltoken.add(poolTokenAmount);
        }

        
    }

    function reBalance(uint[] memory weights) external onlyOwner{

        require(weights.length == mAssets.length, "Weight length mismatch");
        uint _weightsSum;
        for(uint i=0; i<weights.length; i++) {
            Asset memory _masset = mAssets[i];
            _masset.weight = weights[i];
            mAssets[i] = _masset;      
            _weightsSum = _weightsSum.add(weights[i]);
        }

        require(_weightsSum == 5000, "Invalid weights percentages"); //50% mAssets 50% UST

        _rebalance(); // rebalance based n new weights
    }

    function withdrawAllFunds(IERC20 _tokenToConvert) external onlyVault {


        address[] memory path = new address[](2);
        path[1] = address(ust);
        for(uint i=0; i<mAssets.length; i++) {


            if(address(mAssets[i].lpPool) != address(0)) {
                mAssets[i].lpPool.getReward(); //withdraw rewards
                uint amounOfLpTokensStacked = mAssets[i].lpPool.balanceOf(address(this));
                if(amounOfLpTokensStacked != 0) {
                    mAssets[i].lpPool.withdraw(amounOfLpTokensStacked);
                }
            }

            uint amountOfLpTokenToRemove = mAssets[i].lpToken.balanceOf(address(this));
            
            if(amountOfLpTokenToRemove != 0) {
                (uint256 mAssetAmount, ) = router.removeLiquidity(address(mAssets[i].mAssetToken), address(ust),amountOfLpTokenToRemove, 0, 0, address(this), block.timestamp);
                path[0] = address(mAssets[i].mAssetToken);
            
                router.swapExactTokensForTokens(
                    mAssetAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );    

                mAssets[i].amountOfATotal = 0;
                mAssets[i].amountOfBTotal = 0;
                userTotalLPToken[mAssets[i].lpToken] = 0;
            }
        
        }
        withdrawFromMirUstPool(0,0, true);

        uint mirWithdrawn = mir.balanceOf(address(this));
        if(mirWithdrawn > 0) {
            path[0] = address(mir);
            router.swapExactTokensForTokens(mirWithdrawn, 0, path, address(this), block.timestamp);
        }

        if(ust.balanceOf(address(this)) != 0) {
            curveFi.exchange_underlying(0, curveIds[address(_tokenToConvert)], ust.balanceOf(address(this)), 0);
            _tokenToConvert.safeTransfer(address(vault), _tokenToConvert.balanceOf(address(this)));
        }
        
    }

    function setVault (address _vault) external onlyOwner{
        require(vault == address(0), "Cannot set vault");
        vault = _vault;
    }


    function getTotalValueInPool() public view returns (uint256 value) {

        address[] memory path = new address[](2);
        for (uint256 i = 0; i < mAssets.length; i++) {
            
            path[0] = address(mAssets[i].mAssetToken);
            path[1] = address(ust);
            uint[] memory priceInUst = router.getAmountsOut(1e18, path);
            
            value = value.add((priceInUst[1].mul(mAssets[i].amountOfATotal)).div(1e18)).add(mAssets[i].amountOfBTotal);
            
        }
        
        (uint mirAmount, uint ustAmount) = calculateAmountWithdrawable(reInvestedMirUstPooltoken);
        
        if(mirAmount > 0) {
            path[0] = address(mir);
            path[1] = address(ust);
            value = value.add(router.getAmountsOut(mirAmount, path)[1]).add(ustAmount);
        }
        

    }


    function getDataFromLPPool(address _lpToken, uint _amount, uint _valueInPool) internal view returns (uint amountOfLpTokenToRemove){


        uint lpTokenBalance = userTotalLPToken[IERC20(_lpToken)];        

        amountOfLpTokenToRemove = lpTokenBalance.mul(_amount).div(_valueInPool);
        
    }

    function calculateAmountWithdrawable(uint _lpTokenAmount) internal view returns(uint amountMIR , uint amountUST) {

        (uint reserve0, uint reserve1,) = IUniswapV2Pair(mirUstPooltoken).getReserves();
        uint totalLpTOkenSupply = IUniswapV2Pair(mirUstPooltoken).totalSupply();
        
        amountMIR = _lpTokenAmount.mul(reserve0).div(totalLpTOkenSupply);
        amountUST = _lpTokenAmount.mul(reserve1).div(totalLpTOkenSupply);

    }

    function updatelpTokenValue(address _lpPairUniswap, uint _lpTokenAmount) internal view returns (uint _mAsset, uint _ust) {

        IUniswapV2Pair pair = IUniswapV2Pair(_lpPairUniswap);
        (uint reserve0, uint reserve1,) = pair.getReserves();
        uint totalLpTokenSupply = pair.totalSupply();
        
        _mAsset = pair.token0() == address(ust) ? _lpTokenAmount.mul(reserve1).div(totalLpTokenSupply) : _lpTokenAmount.mul(reserve0).div(totalLpTokenSupply);
        _ust = pair.token0() == address(ust) ? _lpTokenAmount.mul(reserve0).div(totalLpTokenSupply) : _lpTokenAmount.mul(reserve1).div(totalLpTokenSupply);
    }

    function _rebalance() internal {

        address[] memory path = new address[](2);
        path[1] = address(ust);

        for (uint256 i = 0; i < mAssets.length; i++) {


            if(address(mAssets[i].lpPool) != address(0)) {
                mAssets[i].lpPool.getReward(); //withdraw rewards
                uint amounOfLpTokensStacked = mAssets[i].lpPool.balanceOf(address(this));
                if(amounOfLpTokensStacked != 0) {
                    mAssets[i].lpPool.withdraw(amounOfLpTokensStacked);
                }
            }

            uint amountOfLpTokenToRemove = mAssets[i].lpToken.balanceOf(address(this));
            
            if(amountOfLpTokenToRemove != 0) {
                (uint256 mAssetAmount, ) = router.removeLiquidity(address(mAssets[i].mAssetToken), address(ust),amountOfLpTokenToRemove, 0, 0, address(this), block.timestamp);
                path[0] = address(mAssets[i].mAssetToken);
            
                router.swapExactTokensForTokens(
                    mAssetAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );    

                mAssets[i].amountOfATotal = 0;
                mAssets[i].amountOfBTotal = 0;
                userTotalLPToken[mAssets[i].lpToken] = 0;
            }
        }

        uint ustAmount = ust.balanceOf(address(this));
        for (uint256 i = 0; i < mAssets.length; i++) {
            address addr_ = address(mAssets[i].mAssetToken);
            path[0] = address(ust);
            path[1] = addr_;
            uint _ustAmount = ustAmount.mul(mAssets[i].weight).div(10000);
            uint[] memory amounts = router.swapExactTokensForTokens(
                _ustAmount,
                0,
                path,
                address(this),
                block.timestamp
            );

            (, , uint256 poolTokenAmount) = router.addLiquidity(addr_,  address(ust), amounts[1], _ustAmount, 0, 0, address(this), block.timestamp);

            if(address(mAssets[i].lpPool) != address(0)) {  
                mAssets[i].lpPool.stake(poolTokenAmount);
            }       

            userTotalLPToken[mAssets[i].lpToken] = userTotalLPToken[mAssets[i].lpToken].add(poolTokenAmount);

            (uint mAssetAmount, uint ustAmountFromPool) = updatelpTokenValue(address(mAssets[i].lpToken), userTotalLPToken[mAssets[i].lpToken]);   
            mAssets[i].amountOfATotal = mAssetAmount;
            mAssets[i].amountOfBTotal = ustAmountFromPool; 
            
        }
        
    }

    function setCommunityWallet(address _communityWallet) external onlyVault {

        communityWallet = _communityWallet;
    }

    function setTreasuryWallet(address _treasuryWallet) external onlyVault {

        treasuryWallet = _treasuryWallet;
    }

    function setStrategist(address _strategist) external onlyVault {

        strategist = _strategist;
    }

}