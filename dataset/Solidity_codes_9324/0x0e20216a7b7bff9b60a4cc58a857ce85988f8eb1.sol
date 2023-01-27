

pragma solidity 0.8.6;




interface IBetaInterestModel {

  function initialRate() external view returns (uint);


  function getNextInterestRate(
    uint prevRate,
    uint totalAvailable,
    uint totalLoan,
    uint timePast
  ) external view returns (uint);

}


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}


contract BetaInterestModelV1 is IBetaInterestModel {

  uint public immutable override initialRate;
  uint public immutable minRate;
  uint public immutable maxRate;
  uint public immutable adjustRate; // between 0 and 1e18, the higher the more aggressive

  constructor(
    uint _initialRate,
    uint _minRate,
    uint _maxRate,
    uint _adjustRate
  ) {
    require(_minRate < _maxRate, 'constructor/bad-min-max-rate');
    require(_adjustRate < 1e18, 'constructor/bad-adjust-rate');
    initialRate = _initialRate;
    minRate = _minRate;
    maxRate = _maxRate;
    adjustRate = _adjustRate;
  }

  function getNextInterestRate(
    uint prevRate,
    uint totalAvailable,
    uint totalLoan,
    uint timePassed
  ) external view override returns (uint) {

    uint totalLiquidity = totalAvailable + totalLoan;
    if (totalLiquidity == 0) {
      return prevRate;
    }
    uint utilRate = (totalLoan * 1e18) / totalLiquidity;
    uint cappedtimePassed = Math.min(timePassed, 1 days);
    uint multRate;
    if (utilRate < 0.5e18) {
      multRate = 1e18 - (adjustRate * cappedtimePassed) / 1 days;
    } else if (utilRate < 0.7e18) {
      uint downScale = (0.7e18 - utilRate) * 5; // *5 is equivalent to /0.2
      multRate = 1e18 - (adjustRate * downScale * cappedtimePassed) / 1 days / 1e18;
    } else if (utilRate < 0.8e18) {
      multRate = 1e18;
    } else {
      uint upScale = (utilRate - 0.8e18) * 5; // *5 is equivalent to /0.2
      uint upMaxRate = 1e36 / (1e18 - adjustRate) - 1e18;
      multRate = 1e18 + (upMaxRate * upScale * cappedtimePassed) / 1 days / 1e18;
    }
    uint targetRate = (prevRate * multRate) / 1e18;
    return Math.min(Math.max(targetRate, minRate), maxRate);
  }
}