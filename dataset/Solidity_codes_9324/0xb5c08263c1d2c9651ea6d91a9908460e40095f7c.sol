
pragma solidity 0.7.6;
pragma abicoder v2;

interface ITwapReader {

    function getPairParameters(address pair)
        external
        view
        returns (
            bool exists,
            uint112 reserve0,
            uint112 reserve1,
            uint256 price,
            uint256 mintFee,
            uint256 burnFee,
            uint256 swapFee
        );

}// GPL-3.0-or-later

pragma solidity 0.7.6;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}// GPL-3.0-or-later

pragma solidity 0.7.6;


interface ITwapERC20 is IERC20 {

    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}// GPL-3.0-or-later

pragma solidity 0.7.6;

interface IReserves {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1);


    function getFees() external view returns (uint256 fee0, uint256 fee1);

}// GPL-3.0-or-later

pragma solidity 0.7.6;


interface ITwapPair is ITwapERC20, IReserves {

    event Mint(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 liquidityOut, address indexed to);
    event Burn(address indexed sender, uint256 amount0Out, uint256 amount1Out, uint256 liquidityIn, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event SetMintFee(uint256 fee);
    event SetBurnFee(uint256 fee);
    event SetSwapFee(uint256 fee);
    event SetOracle(address account);
    event SetTrader(address trader);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function oracle() external view returns (address);


    function trader() external view returns (address);


    function mintFee() external view returns (uint256);


    function setMintFee(uint256 fee) external;


    function mint(address to) external returns (uint256 liquidity);


    function burnFee() external view returns (uint256);


    function setBurnFee(uint256 fee) external;


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swapFee() external view returns (uint256);


    function setSwapFee(uint256 fee) external;


    function setOracle(address account) external;


    function setTrader(address account) external;


    function collect(address to) external;


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function sync() external;


    function initialize(
        address _token0,
        address _token1,
        address _oracle,
        address _trader
    ) external;


    function getSwapAmount0In(uint256 amount1Out, bytes calldata data) external view returns (uint256 swapAmount0In);


    function getSwapAmount1In(uint256 amount0Out, bytes calldata data) external view returns (uint256 swapAmount1In);


    function getSwapAmount0Out(uint256 amount1In, bytes calldata data) external view returns (uint256 swapAmount0Out);


    function getSwapAmount1Out(uint256 amount0In, bytes calldata data) external view returns (uint256 swapAmount1Out);


    function getDepositAmount0In(uint256 amount0, bytes calldata data) external view returns (uint256 depositAmount0In);


    function getDepositAmount1In(uint256 amount1, bytes calldata data) external view returns (uint256 depositAmount1In);

}// GPL-3.0-or-later

pragma solidity 0.7.6;

interface ITwapOracle {

    event OwnerSet(address owner);
    event UniswapPairSet(address uniswapPair);

    function decimalsConverter() external view returns (int256);


    function xDecimals() external view returns (uint8);


    function yDecimals() external view returns (uint8);


    function owner() external view returns (address);


    function uniswapPair() external view returns (address);


    function getPriceInfo() external view returns (uint256 priceAccumulator, uint32 priceTimestamp);


    function getSpotPrice() external view returns (uint256);


    function getAveragePrice(uint256 priceAccumulator, uint32 priceTimestamp) external view returns (uint256);


    function setOwner(address _owner) external;


    function setUniswapPair(address _uniswapPair) external;


    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore,
        bytes calldata data
    ) external view returns (uint256 yAfter);


    function tradeY(
        uint256 yAfter,
        uint256 yBefore,
        uint256 xBefore,
        bytes calldata data
    ) external view returns (uint256 xAfter);


    function depositTradeXIn(
        uint256 xLeft,
        uint256 xBefore,
        uint256 yBefore,
        bytes calldata data
    ) external view returns (uint256 xIn);


    function depositTradeYIn(
        uint256 yLeft,
        uint256 yBefore,
        uint256 xBefore,
        bytes calldata data
    ) external view returns (uint256 yIn);

}// GPL-3.0-or-later

pragma solidity 0.7.6;


contract TwapReader is ITwapReader {

    function isContract(address addressToCheck) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(addressToCheck)
        }
        return size > 0;
    }

    function getPairParameters(address pairAddress)
        external
        view
        override
        returns (
            bool exists,
            uint112 reserve0,
            uint112 reserve1,
            uint256 price,
            uint256 mintFee,
            uint256 burnFee,
            uint256 swapFee
        )
    {

        exists = isContract(pairAddress);
        if (exists) {
            ITwapPair pair = ITwapPair(pairAddress);
            (reserve0, reserve1) = pair.getReserves();
            price = ITwapOracle(pair.oracle()).getSpotPrice();
            mintFee = pair.mintFee();
            burnFee = pair.burnFee();
            swapFee = pair.swapFee();
        }
    }
}