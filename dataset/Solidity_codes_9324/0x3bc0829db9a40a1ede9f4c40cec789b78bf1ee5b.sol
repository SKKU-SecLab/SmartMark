
pragma solidity 0.4.25;


interface IPriceBandCalculator {

    function buy(uint256 _sdrAmount, uint256 _sgrTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);


    function sell(uint256 _sdrAmount, uint256 _sgrTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);

}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}



contract PriceBandCalculator is IPriceBandCalculator {

    string public constant VERSION = "1.0.1";

    using SafeMath for uint256;

    uint256 public constant ONE = 1000000000;
    uint256 public constant GAMMA = 165000000000000000000000000000000000000000;
    uint256 public constant DELTA = 15000000;

    function buy(uint256 _sdrAmount, uint256 _sgrTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256) {

        uint256 reserveRatio = calcReserveRatio(_alpha, _beta, _sgrTotal);
        return  (_sdrAmount.mul(reserveRatio).mul(ONE)).div((reserveRatio.mul(ONE.sub(DELTA))).add(GAMMA));
    }

    function sell(uint256 _sdrAmount, uint256 _sgrTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256) {

        uint256 reserveRatio = calcReserveRatio(_alpha, _beta, _sgrTotal);
        return (_sdrAmount.mul((reserveRatio.mul(ONE.add(DELTA))).sub(GAMMA))).div(reserveRatio.mul(ONE));
    }

    function calcReserveRatio(uint256 _alpha, uint256 _beta, uint256 _sgrTotal) public pure returns (uint256){

        return _alpha.sub(_beta.mul(_sgrTotal));
    }
}