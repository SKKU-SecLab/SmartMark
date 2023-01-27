pragma solidity 0.8.6;

interface IUniswapV2Pair {

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}// GPL-3.0
pragma solidity 0.8.6;

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//MIT
pragma solidity 0.8.6;


contract TokenPriceHelper { 

    address weth9;
    address dai;
    IUniswapV2Factory factory;

    constructor(address _weth9, address _dai, address _factory) {
        weth9 = _weth9;
        dai = _dai;
        factory = IUniswapV2Factory(_factory);
    }

    function price(address token) public view returns (uint) {

        uint ethPrice = 0;
        IUniswapV2Pair ethPair = IUniswapV2Pair(factory.getPair(weth9, dai));
        (uint balance0, uint balance1,) = ethPair.getReserves();
        if (ethPair.token0() == weth9) {
            ethPrice = balance1 / balance0;
        } else {
            ethPrice = balance0 / balance1;
        }

        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(weth9, token));
        if (address(pair) == address(0)) {
            return 0;
        }

        (balance0, balance1,) = pair.getReserves();
        if (pair.token0() == weth9) {
            return balance1 * ethPrice / balance0;
        } else {
            return balance0 * ethPrice / balance1;
        }
    }
}