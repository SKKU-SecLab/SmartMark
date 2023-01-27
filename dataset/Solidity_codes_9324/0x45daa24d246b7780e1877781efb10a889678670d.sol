
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
}// MIT

pragma solidity 0.8.11;
pragma abicoder v1;



interface IOracle {

    function getRate(IERC20 srcToken, IERC20 dstToken, IERC20 connector) external view returns (uint256 rate, uint256 weight);

}// MIT

pragma solidity 0.8.11;


library Sqrt {

    function sqrt(uint y) internal pure returns (uint z) {

        unchecked {
            if (y > 3) {
                z = y;
                uint x = y / 2 + 1;
                while (x < z) {
                    z = x;
                    x = (y / x + x) / 2;
                }
            } else if (y != 0) {
                z = 1;
            }
        }
    }
}// MIT

pragma solidity 0.8.11;



abstract contract OracleBase is IOracle {
    using Sqrt for uint256;

    IERC20 private constant _NONE = IERC20(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);

    function getRate(IERC20 srcToken, IERC20 dstToken, IERC20 connector) external view override returns (uint256 rate, uint256 weight) {
        uint256 balance0;
        uint256 balance1;
        if (connector == _NONE) {
            (balance0, balance1) = _getBalances(srcToken, dstToken);
        } else {
            uint256 balanceConnector0;
            uint256 balanceConnector1;
            (balance0, balanceConnector0) = _getBalances(srcToken, connector);
            (balanceConnector1, balance1) = _getBalances(connector, dstToken);
            if (balanceConnector0 > balanceConnector1) {
                balance0 = balance0 * balanceConnector1 / balanceConnector0;
            } else {
                balance1 = balance1 * balanceConnector0 / balanceConnector1;
            }
        }

        rate = balance1 * 1e18 / balance0;
        weight = (balance0 * balance1).sqrt();
    }

    function _getBalances(IERC20 srcToken, IERC20 dstToken) internal view virtual returns (uint256 srcBalance, uint256 dstBalance);
}// UNLICENSED

pragma solidity 0.8.11;


interface IUniswapV2Pair {

    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

}// MIT

pragma solidity 0.8.11;



contract UniswapV2LikeOracle is OracleBase {

    address public immutable factory;
    bytes32 public immutable initcodeHash;

    constructor(address _factory, bytes32 _initcodeHash) {
        factory = _factory;
        initcodeHash = _initcodeHash;
    }

    function _pairFor(IERC20 tokenA, IERC20 tokenB) private view returns (address pair) {

        pair = address(uint160(uint256(keccak256(abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encodePacked(tokenA, tokenB)),
                initcodeHash
            )))));
    }

    function _getBalances(IERC20 srcToken, IERC20 dstToken) internal view override returns (uint256 srcBalance, uint256 dstBalance) {

        (IERC20 token0, IERC20 token1) = srcToken < dstToken ? (srcToken, dstToken) : (dstToken, srcToken);
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(_pairFor(token0, token1)).getReserves();
        (srcBalance, dstBalance) = srcToken == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
}