
pragma solidity >=0.6.0 <0.8.0;

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
pragma solidity >=0.6.0;

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// "GPL-3.0-or-later"

pragma solidity 0.7.6;

interface IOracleIterator {

    function isOracleIterator() external pure returns (bool);


    function symbol() external pure returns (string memory);


    function getUnderlyingValue(
        address _oracle,
        uint256 _timestamp,
        uint256[] calldata _roundHints
    ) external view returns (int256);

}// "GPL-3.0-or-later"

pragma solidity 0.7.6;


contract ChainlinkOracleIterator is IOracleIterator {

    using SafeMath for uint256;

    uint256 private constant PHASE_OFFSET = 64;
    int256 public constant NEGATIVE_INFINITY = type(int256).min;
    uint256 private constant MAX_ITERATION = 24;

    function isOracleIterator() external pure override returns (bool) {

        return true;
    }

    function symbol() external pure override returns (string memory) {

        return "ChainlinkIterator";
    }

    function getUnderlyingValue(
        address _oracle,
        uint256 _timestamp,
        uint256[] calldata _roundHints
    ) external view override returns (int256) {

        require(_timestamp > 0, "Zero timestamp");
        require(_oracle != address(0), "Zero oracle");
        require(_roundHints.length == 1, "Wrong number of hints");
        AggregatorV3Interface oracle = AggregatorV3Interface(_oracle);

        uint80 latestRoundId;
        (latestRoundId, , , , ) = oracle.latestRoundData();

        uint80 roundHint = uint80(_roundHints[0]);
        if (roundHint == 0) {
            return getIteratedAnswer(oracle, _timestamp, latestRoundId);
        }

        uint256 phaseId;
        (phaseId, ) = parseIds(latestRoundId);

        if (checkSamePhase(roundHint, phaseId)) {
            return
                getHintedAnswer(oracle, _timestamp, roundHint, latestRoundId);
        }

        int256 answer = getIteratedAnswer(oracle, _timestamp, latestRoundId);
        if (answer == NEGATIVE_INFINITY) {
            return
                getHintedAnswer(oracle, _timestamp, roundHint, latestRoundId);
        }
        return answer;
    }

    function getHintedAnswer(
        AggregatorV3Interface _oracle,
        uint256 _timestamp,
        uint80 _roundHint,
        uint256 _latestRoundId
    ) internal view returns (int256) {

        int256 hintAnswer;
        uint256 hintTimestamp;
        (, hintAnswer, , hintTimestamp, ) = _oracle.getRoundData(_roundHint);

        require(
            hintTimestamp > 0 && hintTimestamp <= _timestamp,
            "Incorrect hint"
        );

        if (_roundHint + 1 > _latestRoundId) {
            return hintAnswer;
        }

        uint256 timestampNext;
        (, , , timestampNext, ) = _oracle.getRoundData(_roundHint + 1);
        if (timestampNext == 0 || timestampNext > _timestamp) {
            return hintAnswer;
        }

        return NEGATIVE_INFINITY;
    }

    function getIteratedAnswer(
        AggregatorV3Interface _oracle,
        uint256 _timestamp,
        uint80 _latestRoundId
    ) internal view returns (int256) {

        uint256 roundTimestamp = 0;
        int256 roundAnswer = 0;
        uint80 roundId = _latestRoundId;

        for (uint256 i = 0; i < MAX_ITERATION; i++) {
            (, roundAnswer, , roundTimestamp, ) = _oracle.getRoundData(roundId);
            roundId = roundId - 1;
            if (roundTimestamp <= _timestamp) {
                return roundAnswer;
            }
            if (roundId == 0) {
                return NEGATIVE_INFINITY;
            }
        }

        return NEGATIVE_INFINITY;
    }

    function checkSamePhase(uint80 _roundHint, uint256 _phase)
        internal
        pure
        returns (bool)
    {

        uint256 currentPhaseId;
        (currentPhaseId, ) = parseIds(_roundHint);
        return currentPhaseId == _phase;
    }

    function parseIds(uint256 _roundId) internal pure returns (uint16, uint64) {

        uint16 phaseId = uint16(_roundId >> PHASE_OFFSET);
        uint64 aggregatorRoundId = uint64(_roundId);

        return (phaseId, aggregatorRoundId);
    }
}