interface IOracleUsd {


    function assetToUsd(address asset, uint amount) external view returns (uint);

}interface IOracleEth {

    function assetToEth(address asset, uint amount) external view returns (uint);


    function ethToUsd(uint amount) external view returns (uint);


    function usdToEth(uint amount) external view returns (uint);

}// bsl-1.1

pragma solidity 0.7.6;


interface ERC20Like {

    function balanceOf(address) external view returns (uint);

    function decimals() external view returns (uint8);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

}// bsl-1.1

pragma solidity 0.7.6;


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: division by zero");
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}pragma abicoder v2;


interface IOracleRegistry {


    struct Oracle {
        uint oracleType;
        address oracleAddress;
    }

    function WETH (  ) external view returns ( address );
    function getKeydonixOracleTypes (  ) external view returns ( uint256[] memory );
    function getOracles (  ) external view returns ( Oracle[] memory foundOracles );
    function keydonixOracleTypes ( uint256 ) external view returns ( uint256 );
    function maxOracleType (  ) external view returns ( uint256 );
    function oracleByAsset ( address asset ) external view returns ( address );
    function oracleByType ( uint256 ) external view returns ( address );
    function oracleTypeByAsset ( address ) external view returns ( uint256 );
    function oracleTypeByOracle ( address ) external view returns ( uint256 );
    function setKeydonixOracleTypes ( uint256[] memory _keydonixOracleTypes ) external;
    function setOracle ( uint256 oracleType, address oracle ) external;
    function setOracleTypeForAsset ( address asset, uint256 oracleType ) external;
    function setOracleTypeForAssets ( address[] memory assets, uint256 oracleType ) external;
    function unsetOracle ( uint256 oracleType ) external;
    function unsetOracleForAsset ( address asset ) external;
    function unsetOracleForAssets ( address[] memory assets ) external;
    function vaultParameters (  ) external view returns ( address );
}interface ICurveProvider {
    function get_registry() external view returns (address);

}interface ICurveRegistry {
    function get_pool_from_lp_token(address) external view returns (address);

    function get_n_coins(address) external view returns (uint[2] memory);

}interface ICurvePool {
    function get_virtual_price() external view returns (uint);

    function coins(uint) external view returns (address);

}// bsl-1.1

pragma solidity 0.7.6;


contract CurveLPOracle is IOracleUsd {

    using SafeMath for uint;

    uint public constant Q112 = 2 ** 112;
    uint public constant PRECISION = 1e18;

    ICurveProvider public immutable curveProvider;
    IOracleRegistry public immutable oracleRegistry;

    constructor(address _curveProvider, address _oracleRegistry) {
        require(_curveProvider != address(0) && _oracleRegistry != address(0), "Unit Protocol: ZERO_ADDRESS");
        curveProvider = ICurveProvider(_curveProvider);
        oracleRegistry = IOracleRegistry(_oracleRegistry);
    }

    function assetToUsd(address asset, uint amount) public override view returns (uint) {

        if (amount == 0) return 0;
        ICurveRegistry cR = ICurveRegistry(curveProvider.get_registry());
        ICurvePool cP = ICurvePool(cR.get_pool_from_lp_token(asset));
        require(address(cP) != address(0), "Unit Protocol: NOT_A_CURVE_LP");
        require(ERC20Like(asset).decimals() == uint8(18), "Unit Protocol: INCORRECT_DECIMALS");

        uint coinsCount = cR.get_n_coins(address(cP))[0];
        require(coinsCount != 0, "Unit Protocol: CURVE_INCORRECT_COINS_COUNT");

        uint minCoinPrice_q112;

        for (uint i = 0; i < coinsCount; i++) {
            address _coin = cP.coins(i);
            address oracle = oracleRegistry.oracleByAsset(_coin);
            require(oracle != address(0), "Unit Protocol: ORACLE_NOT_FOUND");
            uint _coinPrice_q112 = IOracleUsd(oracle).assetToUsd(_coin, 10 ** ERC20Like(_coin).decimals()) / 1 ether;
            if (i == 0 || _coinPrice_q112 < minCoinPrice_q112) {
                minCoinPrice_q112 = _coinPrice_q112;
            }
        }

        uint price_q112 = cP.get_virtual_price().mul(minCoinPrice_q112).div(PRECISION);

        return amount.mul(price_q112);
    }

}