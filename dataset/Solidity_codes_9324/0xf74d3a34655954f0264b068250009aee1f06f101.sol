
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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
}// MIT

pragma solidity 0.8.9;
pragma abicoder v1;



interface IOracle {

    function getRate(IERC20 srcToken, IERC20 dstToken, IERC20 connector) external view returns (uint256 rate, uint256 weight);

}// MIT

pragma solidity 0.8.9;



interface IKyberDmmFactory {

    function getPools(IERC20 token0, IERC20 token1) external view returns (address[] memory _tokenPools);

}// MIT

pragma solidity 0.8.9;


interface IKyberDmmPool {

    function getTradeInfo() external view returns (uint112 reserve0, uint112 reserve1, uint112 _vReserve0, uint112 _vReserve1, uint256 feeInPrecision);

}// MIT

pragma solidity 0.8.9;


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

pragma solidity 0.8.9;



contract KyberDmmOracle is IOracle {

    using SafeMath for uint256;
    using Sqrt for uint256;

    IKyberDmmFactory public immutable factory;

    constructor(IKyberDmmFactory _factory) {
        factory = _factory;
    }

    IERC20 private constant _NONE = IERC20(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);

    function getRate(IERC20 srcToken, IERC20 dstToken, IERC20 connector) external override view returns (uint256 rate, uint256 weight) {

        unchecked {
            if (connector == _NONE) {
                address[] memory pools = factory.getPools(srcToken, dstToken);

                require(pools.length > 0, "KO: no pools");

                for (uint256 i = 0; i < pools.length; i++) {
                    (uint256 b0, uint256 b1) = _getBalances(srcToken, dstToken, pools[i]);

                    uint256 w = b0.mul(b1);
                    rate = rate.add(b1.mul(1e18).div(b0).mul(w));
                    weight = weight.add(w);
                }
            } else {
                address[] memory pools0 = factory.getPools(srcToken, connector);
                address[] memory pools1 = factory.getPools(connector, dstToken);

                require(pools0.length > 0 && pools1.length > 0, "KO: no pools with connector");

                for (uint256 i = 0; i < pools0.length; i++) {
                    for (uint256 j = 0; j < pools1.length; j++) {
                        (uint256 b0, uint256 bc0) = _getBalances(srcToken, connector, pools0[i]);
                        (uint256 bc1, uint256 b1) = _getBalances(connector, dstToken, pools1[j]);

                        if (bc0 > bc1) {
                            b0 = b0.mul(bc1).div(bc0);
                        } else {
                            b1 = b1.mul(bc0).div(bc1);
                        }

                        uint256 w = b0.mul(b1);
                        rate = rate.add(b1.mul(1e18).div(b0).mul(w));
                        weight = weight.add(w);
                    }
                }
            }
        }

        if (weight > 0) {
            rate = rate / weight;
            weight = weight.sqrt();
        }
    }

    function _getBalances(IERC20 srcToken, IERC20 dstToken, address pool) private view returns (uint256 srcBalance, uint256 dstBalance) {

        (, , srcBalance, dstBalance,) = IKyberDmmPool(pool).getTradeInfo();
        if (srcToken > dstToken) {
            (srcBalance, dstBalance) = (dstBalance, srcBalance);
        }
    }
}