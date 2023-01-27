pragma solidity 0.8.10;

interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

}// Unlicense
pragma solidity >=0.4.26;

interface IGatherToken {

  function unpauseTransfer() external;

  function pauseTransfer() external;

  function transferPaused() external returns (bool);


  function owner() external returns (address);

  function transferOwnership(address newOwner) external;


  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

}// Unlicense
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

}// Unlicense
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

}// Unlicense
pragma solidity 0.8.10;


contract WithdrawLP {

  IUniswapV2Router02 public constant uniswapRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  IERC20 public constant lpToken = IERC20(0xb38bE7fD90669abCDfb314dBDDF6143AA88D3110);
  IGatherToken public constant gatherToken = IGatherToken(0xc3771d47E2Ab5A519E2917E61e23078d0C05Ed7f);
  address public constant gatherTokenController = 0x3b0C627f65ca4EEDf6f84FD6802506E710ddbe8B;
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "Caller is not the owner");
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    owner = newOwner;
  }

  function transferOwnershipOfGatherToken(address to) public onlyOwner {

    require(to != address(0));
    gatherToken.transferOwnership(to);
    require(gatherToken.owner() == to, "Failed in transferring ownership of gather token");
  }

  function withdrawToken(address tokenAddress, address to, uint256 amount) public onlyOwner returns (bool) {

    require(to != address(0));
    require(amount != 0);
    IERC20 token = IERC20(tokenAddress);
    return token.transfer(to, amount);
  }

  function withdrawLP(uint256 amount, address to) public onlyOwner returns (uint256 amountA, uint256 amountB) {

    require(to != address(0));
    require(amount != 0);
    
    uint256 lpBalance = lpToken.balanceOf(address(this));
    require(lpBalance >= amount, "Insufficient balance of LP token");

    lpToken.approve(address(uniswapRouterV2), amount);

    gatherToken.unpauseTransfer();

    address GTH = address(gatherToken);
    address WETH = uniswapRouterV2.WETH();
    (amountA, amountB) = uniswapRouterV2.removeLiquidity(
      GTH,
      WETH,
      amount,
      0,
      0,
      to,
      block.timestamp
    );

    gatherToken.pauseTransfer();

    transferOwnershipOfGatherToken(gatherTokenController);
  }
}
