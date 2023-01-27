

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


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}


pragma solidity 0.5.16;




contract IUniswapRouterV2 {

  function getAmountsOut(uint256 amountIn, address[] memory path) public view returns (uint256[] memory amounts);

}

interface IUniswapV2Pair {

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function totalSupply() external view returns (uint256);

}

contract ApyOracle {


  address public constant oracle = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  constructor () public {
  }

  function getApy(
    address stakeToken,
    bool isUni,
    address ausc,
    uint256 incentive,
    uint256 howManyWeeks,
    address pool) public view returns (uint256) {

    address[] memory p = new address[](3);
    p[1] = weth;
    p[2] = usdc;
    p[0] = ausc;
    uint256[] memory auscPriceAmounts = IUniswapRouterV2(oracle).getAmountsOut(1e18, p);
    uint256 poolBalance = IERC20(stakeToken).balanceOf(pool);
    uint256 stakeTokenPrice = 1000000;
    p[0] = stakeToken;
    if (stakeToken != usdc) {
      if (isUni) {
        stakeTokenPrice = getUniPrice(IUniswapV2Pair(stakeToken));
      } else {
        uint256 unit = 10 ** uint256(ERC20Detailed(stakeToken).decimals());
        uint256[] memory stakePriceAmounts = IUniswapRouterV2(oracle).getAmountsOut(unit, p);
        stakeTokenPrice = stakePriceAmounts[2];
      }
    }
    uint256 temp = (
      1e8 * auscPriceAmounts[2] * incentive * (52 / howManyWeeks)
    ) / (poolBalance * stakeTokenPrice);
    if (ERC20Detailed(stakeToken).decimals() == uint8(18)) {
      return temp;
    } else {
      uint256 divideBy = 10 ** uint256(18 - ERC20Detailed(stakeToken).decimals());
      return temp / divideBy;
    }
  }

  function getUniPrice(IUniswapV2Pair unipair) public view returns (uint256) {

    (uint112 r0, uint112 r1, ) = unipair.getReserves();
    uint256 total = 0;
    if (unipair.token0() == weth) {
      total = uint256(r0) * 2;
    } else {
      total = uint256(r1) * 2;
    }
    uint256 singlePriceInWeth = 1e18 * total / unipair.totalSupply();
    address[] memory p = new address[](2);
    p[0] = weth;
    p[1] = usdc;
    uint256[] memory prices = IUniswapRouterV2(oracle).getAmountsOut(1e18, p);
    return prices[1] * singlePriceInWeth / 1e18; // price of single token in USDC
  }

  function getTvl(address pool, address token, bool isUniswap) public view returns (uint256) {

    uint256 balance = IERC20(token).balanceOf(pool);
    uint256 decimals = ERC20Detailed(token).decimals();
    if (balance == 0) {
      return 0;
    }
    if (!isUniswap) {
      address[] memory p = new address[](3);
      p[1] = weth;
      p[2] = usdc;
      p[0] = token;
      uint256 one = 10 ** decimals;
      uint256[] memory amounts = IUniswapRouterV2(oracle).getAmountsOut(one, p);
      return amounts[2] * balance / decimals;
    } else {
      uint256 price = getUniPrice(IUniswapV2Pair(token));
      return price * balance / decimals;
    }
  }
}