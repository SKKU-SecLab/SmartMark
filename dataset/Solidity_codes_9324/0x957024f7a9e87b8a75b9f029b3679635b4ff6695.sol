
pragma solidity 0.4.25;


interface IPriceBandCalculator {

    function buy(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);


    function sell(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);

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

    string public constant VERSION = "1.0.0";

    using SafeMath for uint256;

    uint256 public constant ONE     = 1000000000;
    uint256 public constant MIN_RR  = 1000000000000000000000000000000000;
    uint256 public constant MAX_RR  = 10000000000000000000000000000000000;
    uint256 public constant GAMMA   = 179437500000000000000000000000000000000000;
    uint256 public constant DELTA   = 29437500;
    uint256 public constant BUY_N   = 2000;
    uint256 public constant BUY_D   = 2003;
    uint256 public constant SELL_N  = 1997;
    uint256 public constant SELL_D  = 2000;
    uint256 public constant MAX_SDR = 500786938745138896681892746900;

    function buy(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256) {

        assert(_sdrAmount <= MAX_SDR);
        uint256 reserveRatio = _alpha.sub(_beta.mul(_sgaTotal));
        assert(MIN_RR <= reserveRatio && reserveRatio <= MAX_RR);
        uint256 variableFix = _sdrAmount * (reserveRatio * ONE) / (reserveRatio * (ONE - DELTA) + GAMMA);
        uint256 constantFix = _sdrAmount * BUY_N / BUY_D;
        return constantFix <= variableFix ? constantFix : variableFix;
    }

    function sell(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256) {

        assert(_sdrAmount <= MAX_SDR);
        uint256 reserveRatio = _alpha.sub(_beta.mul(_sgaTotal));
        assert(MIN_RR <= reserveRatio && reserveRatio <= MAX_RR);
        uint256 variableFix = _sdrAmount * (reserveRatio * (ONE + DELTA) - GAMMA) / (reserveRatio * ONE);
        uint256 constantFix = _sdrAmount * SELL_N / SELL_D;
        return constantFix <= variableFix ? constantFix : variableFix;
    }
}