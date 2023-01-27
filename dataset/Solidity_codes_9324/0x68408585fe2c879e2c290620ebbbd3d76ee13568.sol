
pragma solidity 0.5.17;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library SignedSafeMath {

    int256 private constant _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(
            !(a == -1 && b == _INT256_MIN),
            "SignedSafeMath: multiplication overflow"
        );

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require(
            (b >= 0 && c <= a) || (b < 0 && c > a),
            "SignedSafeMath: subtraction overflow"
        );

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require(
            (b >= 0 && c >= a) || (b < 0 && c < a),
            "SignedSafeMath: addition overflow"
        );

        return c;
    }
}

interface AggregatorInterface {

  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface PairAggregatorInterface {

    function getLatestAnswer() external view returns (int256);


    function getLatestTimestamp() external view returns (uint256);


    function getPreviousAnswer(uint256 roundsBack) external view returns (int256);


    function getPreviousTimestamp(uint256 roundsBack) external view returns (uint256);


    function getLatestRound() external view returns (uint256);

}

contract ChainlinkPairAggregator is PairAggregatorInterface {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 internal constant TEN = 10;
    uint256 internal constant MAX_POWER_VALUE = 50;

    AggregatorInterface public aggregator;
    uint8 public responseDecimals;
    uint8 public collateralDecimals;
    uint8 public pendingDecimals;

    constructor(
        address aggregatorAddress,
        uint8 responseDecimalsValue,
        uint8 collateralDecimalsValue
    ) public {
        require(aggregatorAddress != address(0x0), "PROVIDE_AGGREGATOR_ADDRESS");
        aggregator = AggregatorInterface(aggregatorAddress);
        responseDecimals = responseDecimalsValue;
        collateralDecimals = collateralDecimalsValue;

        if (collateralDecimals >= responseDecimals) {
            pendingDecimals = collateralDecimals - responseDecimals;
        } else {
            pendingDecimals = responseDecimals - collateralDecimals;
        }
        require(pendingDecimals <= MAX_POWER_VALUE, "MAX_PENDING_DECIMALS_EXCEEDED");
    }


    function getLatestAnswer() external view returns (int256) {

        int256 latestAnswerInverted = aggregator.latestAnswer();
        return _normalizeResponse(latestAnswerInverted);
    }

    function getPreviousAnswer(uint256 roundsBack) external view returns (int256) {

        int256 answer = _getPreviousAnswer(roundsBack);
        return _normalizeResponse(answer);
    }

    function getLatestTimestamp() external view returns (uint256) {

        return aggregator.latestTimestamp();
    }

    function getLatestRound() external view returns (uint256) {

        return aggregator.latestRound();
    }

    function getPreviousTimestamp(uint256 roundsBack) external view returns (uint256) {

        uint256 latest = aggregator.latestRound();
        require(roundsBack <= latest, "NOT_ENOUGH_HISTORY");
        return aggregator.getTimestamp(latest - roundsBack);
    }


    function _getPreviousAnswer(uint256 roundsBack) internal view returns (int256) {

        uint256 latest = aggregator.latestRound();
        require(roundsBack <= latest, "NOT_ENOUGH_HISTORY");
        return aggregator.getAnswer(latest - roundsBack);
    }

    function _normalizeResponse(int256 value) internal view returns (int256) {

        if (collateralDecimals >= responseDecimals) {
            return value.mul(int256(TEN**pendingDecimals));
        } else {
            return value.div(int256(TEN**pendingDecimals));
        }
    }
}