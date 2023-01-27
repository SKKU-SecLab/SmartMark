


pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

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
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}


pragma solidity 0.6.6;

interface PriceOracleInterface {

    function isWorking() external returns (bool);


    function latestId() external returns (uint256);


    function latestPrice() external returns (uint256);


    function latestTimestamp() external returns (uint256);


    function getPrice(uint256 id) external returns (uint256);


    function getTimestamp(uint256 id) external returns (uint256);

}


pragma solidity 0.6.6;

interface AggregatorInterfaceV2 {

    function latestAnswer() external view returns (int256);


    function latestTimestamp() external view returns (uint256);


    function latestRound() external view returns (uint256);


    function getAnswer(uint256 roundId) external view returns (int256);


    function getTimestamp(uint256 roundId) external view returns (uint256);


    function decimals() external view returns (uint8);


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

}


pragma solidity 0.6.6;





contract ChainlinkPriceOracleV2 is PriceOracleInterface {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 private constant SECONDS_IN_DAY = 60 * 60 * 24;
    uint8 private constant DECIMALS = 8;
    int256 private constant FLUCTUATION_THRESHOLD = 8; // 800%

    AggregatorInterfaceV2 public immutable aggregator;
    bool public healthFlag = true;

    event HealthCheck(bool indexed success);

    constructor(AggregatorInterfaceV2 aggregatorAddress) public {
        aggregator = aggregatorAddress;
    }

    function isWorking() external override returns (bool) {

        return
            healthFlag &&
            _isNotDestructed() &&
            _isLatestAnswerProper() &&
            _isDecimalNotChanged();
    }

    function latestId() external override returns (uint256) {

        return aggregator.latestRound();
    }

    function latestPrice() external override returns (uint256) {

        int256 price = aggregator.latestAnswer();
        return uint256(price);
    }

    function latestTimestamp() external override returns (uint256) {

        return aggregator.latestTimestamp();
    }

    function getPrice(uint256 id) public override returns (uint256) {

        int256 price = aggregator.getAnswer(id);
        if (price == 0) {
            return getPrice(id.sub(1));
        }
        return uint256(price);
    }

    function getTimestamp(uint256 id) public override returns (uint256) {

        uint256 timestamp = aggregator.getTimestamp(id);
        if (timestamp == 0) {
            return getTimestamp(id.sub(1));
        }
        return timestamp;
    }

    function healthCheck() external returns (bool r) {

        r = isHealth();
        if (!r) {
            healthFlag = false;
        }
        emit HealthCheck(r);
        return r;
    }

    function isHealth() public view returns (bool r) {

        try aggregator.latestRound() returns (uint256 latestRound) {
            if (latestRound < 25) {
                return r;
            }
            for (uint256 id = latestRound - 23; id <= latestRound; id++) {
                if (!areAnswersProperAt(uint80(id))) {
                    return r;
                }
            }
            if (!areAnswersProperThoroughly(uint80(latestRound))) {
                return r;
            }
            r = true;
        } catch {}
    }

    function areAnswersProperThoroughly(uint80 startId)
        public
        view
        returns (bool)
    {
        (, int256 checkAnswer, , uint256 checkTimestamp, ) = aggregator
            .getRoundData(uint80(startId - 24));
        int256 answer;
        uint256 timestamp;
        bool areAnswersSame = true;
        bool areTimestampsSame = true;
        for (uint256 id = startId - 23; id < startId; id++) {
            (, answer, , timestamp, ) = aggregator.getRoundData(uint80(id));
            if (areAnswersSame && answer != checkAnswer) {
                areAnswersSame = false;
            }
            if (areTimestampsSame && timestamp != checkTimestamp) {
                areTimestampsSame = false;
            }
        }
        return !(areAnswersSame || areTimestampsSame);
    }

    function areAnswersProperAt(uint80 id) public view returns (bool r) {
        uint80 prev = id - 1;
        try aggregator.getRoundData(uint80(id)) returns (
            uint80,
            int256 firstAnswer,
            uint256,
            uint256 firstTimestamp,
            uint80
        ) {
            try aggregator.getRoundData(prev) returns (
                uint80,
                int256 secondAnswer,
                uint256,
                uint256 secondTimestamp,
                uint80
            ) {
                return (_isProperAnswers(firstAnswer, secondAnswer) &&
                    _isProperTimestamps(firstTimestamp, secondTimestamp));
            } catch {}
        } catch {}
    }

    function _isNotDestructed() private view returns (bool) {
        address aggregatorAddr = address(aggregator);
        uint256 size;
        assembly {
            size := extcodesize(aggregatorAddr)
        }
        return size != 0;
    }

    function _isLatestAnswerProper() private view returns (bool r) {
        try aggregator.latestRoundData() returns (
            uint80 latestRound,
            int256 latestAnswer,
            uint256,
            uint256 updatedAt,
            uint80
        ) {
            if (latestRound == 0) {
                return r;
            }
            try aggregator.getAnswer(latestRound - 1) returns (
                int256 previousAnswer
            ) {
                return (_isProperAnswers(latestAnswer, previousAnswer) &&
                    _isProperTimestamps(now, updatedAt));
            } catch {}
        } catch {}
    }

    function _isDecimalNotChanged() private view returns (bool) {
        try aggregator.decimals() returns (uint8 d) {
            return d == DECIMALS;
        } catch {
            return false;
        }
    }

    function _isProperAnswers(int256 firstAnswer, int256 secondAnswer)
        private
        pure
        returns (bool r)
    {
        if (firstAnswer <= 0) {
            return r;
        }
        if (firstAnswer > secondAnswer.mul(FLUCTUATION_THRESHOLD)) {
            return r;
        }
        if (firstAnswer.mul(FLUCTUATION_THRESHOLD) < secondAnswer) {
            return r;
        }
        return true;
    }

    function _isProperTimestamps(
        uint256 firstTimestamp,
        uint256 secondTimestamp
    ) private pure returns (bool) {
        return firstTimestamp.sub(secondTimestamp) <= SECONDS_IN_DAY;
    }
}