
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
}


pragma solidity ^0.5.0;
interface IUnifiFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);



    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external returns(address);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    
    function feeController() external view returns (address);

    function router() external view returns (address);

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
pragma solidity ^0.5.0;
interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

    
    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

}

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

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
}


pragma solidity ^0.5.0;




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







interface UnifiRouter {

  function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

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

     function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);   

  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}

contract SingleAsssetAddLiquidity {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using Math for uint256;
    address  public  owner ;
    address public  router ;
    address public wETH ;
    address payable owners;
    address public pancakeRouter ;
    address public unifiRouter;
    IUnifiFactory public otherFactory;

    constructor(address _pancakeRouter,address _unifiRouter,address _routerAdd, address _weth, address _otherFactory) public {
        owner = msg.sender;
        router = _routerAdd;
        pancakeRouter = _pancakeRouter;
        unifiRouter = _unifiRouter;
        wETH = _weth;
  
        otherFactory = IUnifiFactory(_otherFactory);
    }
    function updateRouter (address _newRouter) public {
        require(msg.sender == owner);
        router = _newRouter;
    }
    
    function updatePancakeRouter (address _tradeRouter) public {
        require(msg.sender == owner);
        pancakeRouter = _tradeRouter;
    }

    function updateOtherFactory (address _factory) public {
        require(msg.sender == owner);
        otherFactory = IUnifiFactory(_factory);
    }
    function updateUnifiRouter (address _tradeRouter) public {
        require(msg.sender == owner);
        unifiRouter = _tradeRouter;
    }
    function updateWETH (address _newWETH) public {
        require(msg.sender ==  owner);
        wETH = _newWETH;
    }
    function getName() external pure returns (string memory) {

        return "singleAssetDepositor";
    }
    
 function withdrawSupplyAsSingleAsset( address receiveToken , address liquidityToken ,address tokenA,address tokenB, address payable to,uint amount, bool toReceiveWNative,uint minOut) external {

      IERC20(liquidityToken).safeTransferFrom(msg.sender,address(this), amount);
      IERC20(liquidityToken).safeApprove(router, 0);    
      IERC20(liquidityToken).safeApprove(router, amount);      
      UnifiRouter(router).removeLiquidity(
          tokenA, 
          tokenB, 
          amount, 
          1, 
          1, 
          address(this), 
          now.add(1800)
        );
        if(address(tokenA) == address(receiveToken)){
            uint tokenBBalance = IERC20(tokenB).balanceOf(address(this));
             _convertToken(tokenBBalance, tokenB, receiveToken, minOut) ;
        }else if (address(tokenB) == address(receiveToken)){
            uint tokenABalance = IERC20(tokenA).balanceOf(address(this));
             _convertToken(tokenABalance, tokenA,receiveToken , minOut) ;
        }
        uint receivingTokenBalance = IERC20(receiveToken).balanceOf(address(this));
        if(toReceiveWNative){
            IERC20(wETH).safeApprove(router, 0); 
            IERC20(wETH).safeApprove(router,receivingTokenBalance );
            IWETH(wETH).withdraw(receivingTokenBalance);
            address(to).transfer(receivingTokenBalance);                  
        }else{
            IERC20(receiveToken).safeTransfer(to,receivingTokenBalance);
        }
     
     
    }


function withdrawSupplyAsOtherSingleAsset( address receiveToken , address liquidityToken ,address tokenA,address tokenB, address payable to,uint amount, address[] calldata path1, address[] calldata path2, bool toReceiveWNative,uint minOut) external {

      require(path1[path1.length - 1] == path2[path2.length -1] , 'Needs to be same token ');
      IERC20(liquidityToken).safeTransferFrom(msg.sender,address(this), amount);
      IERC20(liquidityToken).safeApprove(router, 0);  
      IERC20(liquidityToken).safeApprove(router, amount);      
      UnifiRouter(router).removeLiquidity(
          tokenA, 
          tokenB, 
          amount, 
          1, 
          1, 
          address(this), 
          now.add(1800)
        );
        _convertOtherToken(IERC20(tokenA).balanceOf(address(this)),path1, minOut);
        _convertOtherToken(IERC20(tokenB).balanceOf(address(this)),path2, minOut);           

        uint receivingTokenBalance = IERC20(receiveToken).balanceOf(address(this));
        if(address(receiveToken) == address(wETH) && toReceiveWNative == true){
            IERC20(wETH).safeApprove(router,0 );
            IERC20(wETH).safeApprove(router,receivingTokenBalance );
              IWETH(wETH).withdraw(receivingTokenBalance);
                address(to).transfer(receivingTokenBalance);              
        }else{
            
        }
        IERC20(receiveToken).safeTransfer(address(to),receivingTokenBalance);       
     
    }
  function convertSingleAssetToLiquidityEth( address requireToken , address to,uint minOut)payable external {

      require(msg.value > 0);
      IWETH(wETH).deposit.value( msg.value)();
      uint256 tokenABalance = IERC20(wETH).balanceOf(address(this));
      if(tokenABalance > 0 ) {
        _convertToken(tokenABalance.div(2),wETH,requireToken,minOut);
        
        uint256 tokenBBalance = IERC20(requireToken).balanceOf(address(this));

        tokenABalance = IERC20(wETH).balanceOf(address(this));
        IERC20(wETH).safeApprove(router,0 );
        IERC20(wETH).safeApprove(router,tokenABalance );
        IERC20(requireToken).safeApprove(router, 0);
        IERC20(requireToken).safeApprove(router, tokenBBalance);

        UnifiRouter(router).addLiquidity(
          wETH, 
          requireToken, 
          tokenABalance, 
          tokenBBalance, 
          0, 
          0, 
          to, 
          now.add(1800)
        );
      }
      
        tokenABalance = IERC20(wETH).balanceOf(address(this));
       uint256 requireTokenBalance = IERC20(requireToken).balanceOf(address(this));

      if(tokenABalance > 0 ){
        IERC20(wETH).safeTransfer(to,tokenABalance);
      }
      if(requireTokenBalance > 0 ){
        IERC20(requireToken).safeTransfer(to,requireTokenBalance);
      }
    }

    function convertSingleAssetToLiquidity(address tokenA, address requireToken , uint amount , address to,uint minOut) external {

      IERC20(tokenA).safeTransferFrom(msg.sender,address(this), amount);
      uint256 tokenABalance = IERC20(tokenA).balanceOf(address(this));
      if(tokenABalance > 0 ) {
        _convertToken(tokenABalance.div(2),tokenA,requireToken,minOut);
        
        uint256 tokenBBalance = IERC20(requireToken).balanceOf(address(this));

        tokenABalance = IERC20(tokenA).balanceOf(address(this));

        IERC20(tokenA).safeApprove(router,0 );
        IERC20(requireToken).safeApprove(router, 0);

        IERC20(tokenA).safeApprove(router,tokenABalance );
        IERC20(requireToken).safeApprove(router, tokenBBalance);

        UnifiRouter(router).addLiquidity(
          tokenA, 
          requireToken,
          tokenABalance,
          tokenBBalance, 
          0, 
          0, 
          to, 
          now.add(1800)
        );
      }
       tokenABalance = IERC20(tokenA).balanceOf(address(this));
       uint256 requireTokenBalance = IERC20(requireToken).balanceOf(address(this));

      if(tokenABalance > 0 ){
        IERC20(tokenA).safeTransfer(to,tokenABalance);
      }
      if(requireTokenBalance > 0 ){
        IERC20(requireToken).safeTransfer(to,requireTokenBalance);
      }

    }

    function convertSingleAssetToOtherLiquidity(address depositToken, address requireTokenA,address requireTokenB , uint amount , address to, address[] calldata path1, address[] calldata path2,uint minOut) external {

      IERC20(depositToken).safeTransferFrom(msg.sender,address(this), amount);
           uint256 tokenABalance = 0 ;
           uint256 tokenBBalance = 0 ;
      if(amount > 0 ) {
        _convertOtherToken(amount.div(2),path1,minOut);
        _convertOtherToken(amount.div(2),path2,minOut);    
         tokenABalance = IERC20(requireTokenA).balanceOf(address(this));
         tokenBBalance = IERC20(requireTokenB).balanceOf(address(this));

        IERC20(requireTokenA).safeApprove(router,0 );
        IERC20(requireTokenB).safeApprove(router,0 );
        IERC20(requireTokenA).safeApprove(router,tokenABalance );
        IERC20(requireTokenB).safeApprove(router,tokenBBalance );
        UnifiRouter(router).addLiquidity(
          requireTokenA, 
          requireTokenB, 
          tokenABalance, 
          tokenBBalance, 
          0, 
          0, 
          to, 
          now.add(1800)
        );
      }
        tokenABalance = IERC20(requireTokenA).balanceOf(address(this));
        tokenBBalance = IERC20(requireTokenB).balanceOf(address(this));
       uint256 baseBalance = IERC20(depositToken).balanceOf(address(this));  
      if(tokenABalance > 0 ){
        IERC20(requireTokenA).safeTransfer(to,tokenABalance);
      }
      if(tokenBBalance > 0 ){
        IERC20(requireTokenB).safeTransfer(to,tokenBBalance);
      }
      if(baseBalance > 0 ){
        IERC20(depositToken).safeTransfer(to,baseBalance);
      }
    }

   
    function convertSingleAssetToOtherLiquidityETH( address requireTokenA,address requireTokenB  , address to, address[] calldata path1, address[] calldata path2,uint minOut) payable external {

      require(msg.value > 0);
      IWETH(wETH).deposit.value( msg.value)();
       uint256 tokenABalance = 0;
       uint256 tokenBBalance = 0;
      if( msg.value > 0 ) {
        _convertOtherToken( msg.value.div(2),path1,minOut);
        _convertOtherToken( msg.value.div(2),path2,minOut);    
         tokenABalance = IERC20(requireTokenA).balanceOf(address(this));
         tokenBBalance = IERC20(requireTokenB).balanceOf(address(this));

        IERC20(requireTokenA).safeApprove(router,0 );
        IERC20(requireTokenB).safeApprove(router,0 );
        IERC20(requireTokenA).safeApprove(router,tokenABalance );
        IERC20(requireTokenB).safeApprove(router,tokenBBalance );
        UnifiRouter(router).addLiquidity(
          requireTokenA, 
          requireTokenB,
          tokenABalance,
          tokenBBalance, 
          0,
          0, 
          to, 
          now.add(10000)
        );
      }
        tokenABalance = IERC20(requireTokenA).balanceOf(address(this));
        tokenBBalance = IERC20(requireTokenB).balanceOf(address(this));
       uint256 baseBalance = IERC20(wETH).balanceOf(address(this));  
      if(tokenABalance > 0 ){
        IERC20(requireTokenA).safeTransfer(to,tokenABalance);
      }
      if(tokenBBalance > 0 ){
        IERC20(requireTokenB).safeTransfer(to,tokenBBalance);
      }
      if(baseBalance > 0 ){
        IERC20(wETH).safeTransfer(to,baseBalance);
      }
    }
    function _convertToken(uint _amount, address _tokenIn, address _tokenOut,uint minOut) internal {

        
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        if(otherFactory.getPair(_tokenIn,_tokenOut) == address(0)){
                IERC20(_tokenIn).safeApprove(unifiRouter, 0);
                IERC20(_tokenIn).safeApprove(unifiRouter, _amount);
                UnifiRouter(unifiRouter).swapExactTokensForTokens(_amount, uint256(minOut), path, address(this), now.add(10000));                      
        }else{
            uint[] memory  pancakeOutput = UnifiRouter(pancakeRouter).getAmountsOut(_amount, path);
            uint[] memory  unifiOutput = UnifiRouter(unifiRouter).getAmountsOut(_amount, path);
            if(pancakeOutput[pancakeOutput.length -1 ] > unifiOutput[unifiOutput.length - 1] ){
       
                IERC20(_tokenIn).safeApprove(pancakeRouter, 0);
                IERC20(_tokenIn).safeApprove(pancakeRouter, _amount);
                UnifiRouter(pancakeRouter).swapExactTokensForTokens(_amount, uint256(minOut), path, address(this), now.add(10000));         
            }else{
          
                IERC20(_tokenIn).safeApprove(unifiRouter, 0);
                IERC20(_tokenIn).safeApprove(unifiRouter, _amount);
                UnifiRouter(unifiRouter).swapExactTokensForTokens(_amount, uint256(minOut), path, address(this), now.add(10000));               
            }
        }


    }

    function _convertOtherToken(uint _amount, address [] memory path,uint minOut) internal {

         uint[]memory pancakeOutput = UnifiRouter(pancakeRouter).getAmountsOut(_amount, path);
         uint[]memory unifiOutput = UnifiRouter(unifiRouter).getAmountsOut(_amount, path);
         
        if(otherFactory.getPair(path[0],path[1]) == address(0)){
            IERC20(path[0]).safeApprove(unifiRouter, 0);
            IERC20(path[0]).safeApprove(unifiRouter, _amount);
            UnifiRouter(unifiRouter).swapExactTokensForTokens(_amount, uint256(minOut), path, address(this), now.add(10000));               
        }else{
         if(pancakeOutput[pancakeOutput.length -1 ] > unifiOutput[unifiOutput.length - 1] ){
                IERC20(path[0]).safeApprove(pancakeRouter, 0);
                IERC20(path[0]).safeApprove(pancakeRouter, _amount);
                UnifiRouter(pancakeRouter).swapExactTokensForTokens(_amount, uint256(minOut), path, address(this), now.add(10000));         
            }else{
                IERC20(path[0]).safeApprove(unifiRouter, 0);
                IERC20(path[0]).safeApprove(unifiRouter, _amount);
                UnifiRouter(unifiRouter).swapExactTokensForTokens(_amount, uint256(minOut), path, address(this), now.add(10000));               
            }           
        }

    }
    
    function pancakeOutput(uint _amount, address[] memory path) public view returns (uint){

        uint[] memory estimated =    UnifiRouter(pancakeRouter).getAmountsOut(_amount, path) ;
              return estimated[estimated.length-1];
        
    }
    
    function unifiOutput(uint _amount, address[] memory path) public view returns (uint){

        uint[] memory estimated =    UnifiRouter(unifiRouter).getAmountsOut(_amount, path) ;
        return estimated[estimated.length-1];
    }


    
    function transferAccidentalTokens(IERC20 token ) external {


        require(owner != address(0),"UnifiRouter: Not found");
        uint balance = IERC20(token).balanceOf(address(this));
        if(balance > 0 ){
            IERC20(token).transfer(owner ,balance);
        }
    }

}