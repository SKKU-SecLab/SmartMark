pragma solidity >=0.6.2;

abstract contract IERC20 {
  function approve(address spender, uint256 value) public virtual returns (bool);
  function balanceOf(address account) public virtual view returns (uint256);
  function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool);
  function transfer(address _to, uint256 _value) public virtual returns (bool);
}pragma solidity >=0.6.2;

abstract contract ICERC20 {
  function approve(address spender, uint256 value) public virtual returns (bool);
  function balanceOf(address account) public virtual view returns (uint256);
  function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool);
  function transfer(address _to, uint256 _value) public virtual returns (bool);
  function mint(uint256) external virtual returns (uint256);
  function redeem(uint256 redeemTokens) external virtual returns (uint256);
  function repayBorrow(uint256 repayAmount) external virtual returns (uint256);
  function exchangeRateCurrent() external virtual view returns (uint256);
  function borrowBalanceCurrent(address account) external virtual view returns (uint256);
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

}pragma solidity >=0.6.2;


contract Compounder {

  IUniswapV2Router02 constant router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  function swapTokenForCToken(
    IERC20 sellToken,
    IERC20 buyToken,
    ICERC20 buyCToken,
    uint256 sellAmount,
    uint256 minBuyToken
  ) public {

    require(
      sellToken.transferFrom(msg.sender, address(this), sellAmount),
      "Transfer failed"
    );
    require(
      sellToken.approve(address(router), sellAmount),
      "Failed to approve router."
    );
    address[] memory path = new address[](2);
    path[0] = address(sellToken);
    path[1] = address(buyToken);

    uint[] memory amounts = router.swapExactTokensForTokens(
      sellAmount,
      minBuyToken,
      path,
      address(this),
      block.timestamp + 1
    );

    uint256 minted = buyCToken.mint(amounts[1]);

    require(
      buyCToken.transfer(msg.sender, minted),
      "Failed to transfer token."
    );
  }

  function swapCTokenForToken(
    IERC20 sellToken,
    ICERC20 sellCToken,
    IERC20 buyToken,
    uint256 redeemAmount,
    uint256 minBuyToken
  ) public {

    require(
      sellCToken.transferFrom(msg.sender, address(this), redeemAmount),
      "Transfer failed"
    );
    uint256 redeemed = sellCToken.redeem(redeemAmount);
    address[] memory path = new address[](2);
    path[0] = address(sellToken);
    path[1] = address(buyToken);
    require(
      sellToken.approve(address(router), redeemed),
      "Failed to approve router."
    );
    uint[] memory amounts = router.swapExactTokensForTokens(
      redeemed,
      minBuyToken,
      path,
      address(this),
      block.timestamp + 1
    );
    require(
      buyToken.transfer(msg.sender, amounts[1]),
      "Failed to transfer token."
    );
  }

  function swapCTokenForCToken(
    IERC20 sellToken,
    ICERC20 sellCToken,
    IERC20 buyToken,
    ICERC20 buyCToken,
    uint256 redeemAmount,
    uint256 minBuyToken
  ) public {

    require(
      sellCToken.transferFrom(msg.sender, address(this), redeemAmount),
      "Transfer failed"
    );
    uint256 redeemed = sellCToken.redeem(redeemAmount);
    address[] memory path = new address[](2);
    path[0] = address(sellToken);
    path[1] = address(buyToken);
    require(
      sellToken.approve(address(router), redeemed),
      "Failed to approve router."
    );
    uint[] memory amounts = router.swapExactTokensForTokens(
      redeemed,
      minBuyToken,
      path,
      address(this),
      block.timestamp + 1
    );
    require(
      sellToken.approve(address(buyCToken), amounts[1]),
      "Failed to approve compound."
    );
    uint256 minted = buyCToken.mint(amounts[1]);
    require(
      buyCToken.transfer(msg.sender, minted),
      "Failed to transfer cToken."
    );
  }
}