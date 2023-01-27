
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity 0.7.6;



interface IOracle {

    function getRate(IERC20 srcToken, IERC20 dstToken, IERC20 connector) external view returns (uint256 rate, uint256 weight);

}// MIT

pragma solidity ^0.7.6;



interface IUniswapV3Pool {

    function slot0() external view returns (uint160 sqrtPriceX96, int24, uint16, uint16, uint16, uint8, bool);

    function token0() external view returns (IERC20 token);

}// MIT

pragma solidity ^0.7.6;



interface IUniswapV3Factory {

    function getPool(IERC20 tokenA, IERC20 tokenB, uint24 fee) external view returns (IUniswapV3Pool pool);

}// MIT

pragma solidity 0.7.6;


library Sqrt {

    function sqrt(uint y) internal pure returns (uint z) {

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
}// MIT

pragma solidity 0.7.6;



contract UniswapV3Oracle is IOracle {

    using SafeMath for uint256;
    using Sqrt for uint256;

    IUniswapV3Factory public immutable factory;
    IERC20 private constant _NONE = IERC20(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
    uint24[] private _defaultFees;

    constructor(IUniswapV3Factory _factory, uint24[] memory defaultFees) {
        factory = _factory;
        _defaultFees = defaultFees;
    }

    function getRate(IERC20 srcToken, IERC20 dstToken, IERC20 connector) external override view returns (uint256 rate, uint256 weight) {

        for (uint256 i = 0; i < _defaultFees.length; i++) {
            (uint256 rateForFee, uint256 weightForFee) = getRateForFee(srcToken, dstToken, connector, _defaultFees[i]);
            rate = rate.add(rateForFee.mul(weightForFee));
            weight = weight.add(weightForFee);
        }
        if (weight > 0) {
            rate = rate.div(weight);
        }
    }

    function getRateForFee(IERC20 srcToken, IERC20 dstToken, IERC20 connector, uint24 fee) public view returns (uint256 rate, uint256 weight) {

        uint256 balance0;
        uint256 balance1;
        if (connector == _NONE) {
            (rate, balance0, balance1) = _getRate(srcToken, dstToken, fee);
        } else {
            uint256 balanceConnector0;
            uint256 balanceConnector1;
            uint256 rate0;
            uint256 rate1;
            (rate0, balance0, balanceConnector0) = _getRate(srcToken, connector, fee);
            (rate1, balanceConnector1, balance1) = _getRate(connector, dstToken, fee);
            if (balance0 == 0 || balanceConnector0 == 0 || balanceConnector1 == 0 || balance1 == 0) {
                return (0, 0);
            }

            if (balanceConnector0 > balanceConnector1) {
                balance0 = balance0.mul(balanceConnector1).div(balanceConnector0);
            } else {
                balance1 = balance1.mul(balanceConnector0).div(balanceConnector1);
            }

            rate = rate0.mul(rate1).div(1e18);
        }

        weight = balance0.mul(balance1).sqrt();
    }

    function _getRate(IERC20 srcToken, IERC20 dstToken, uint24 fee) internal view returns (uint256 rate, uint256 srcBalance, uint256 dstBalance) {

        IUniswapV3Pool pool = factory.getPool(srcToken, dstToken, fee);
        if (pool == IUniswapV3Pool(0)) {
            return (0, 0, 0);
        }
        (uint256 sqrtPriceX96,,,,,,) = pool.slot0();
        if (srcToken == pool.token0()) {
            rate = (uint256(1e18).mul(sqrtPriceX96) >> 96).mul(sqrtPriceX96) >> 96;
        } else {
            rate = uint256(1e18 << 192).div(sqrtPriceX96).div(sqrtPriceX96);
        }
        srcBalance = srcToken.balanceOf(address(pool));
        dstBalance = dstToken.balanceOf(address(pool));
    }
}