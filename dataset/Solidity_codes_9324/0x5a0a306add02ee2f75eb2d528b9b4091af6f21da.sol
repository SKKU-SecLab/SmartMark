

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

contract ApyOracle {


  address public constant oracle = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  constructor () public {
  }

  function getPrice(address stakeToken, address ausc, uint256 incentive, uint256 weekPeriod, address pool) public view returns (uint256) {

    address[] memory p = new address[](3);
    p[0] = stakeToken;
    p[1] = weth;
    p[2] = usdc;
    uint256[] memory stakePriceAmounts = IUniswapRouterV2(oracle).getAmountsOut(1e18, p);
    p[0] = ausc;
    uint256[] memory auscPriceAmounts = IUniswapRouterV2(oracle).getAmountsOut(1e18, p);
    uint256 poolBalance = IERC20(stakeToken).balanceOf(pool);
    uint256 decimals = uint256(ERC20Detailed(stakeToken).decimals());
    return ((10 ** decimals) * auscPriceAmounts[2] * incentive * (52 / weekPeriod) / stakePriceAmounts[2]) * (10 ** decimals) * 1e10 / poolBalance;
  }
}