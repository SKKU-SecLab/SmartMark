


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

interface AggregatorInterface {

    function latestAnswer() external view returns (int256);


    function latestTimestamp() external view returns (uint256);


    function latestRound() external view returns (uint256);


    function getAnswer(uint256 roundId) external view returns (int256);


    function getTimestamp(uint256 roundId) external view returns (uint256);


    function decimals() external view returns (uint8);


    function latestRoundData()
        external
        view
        returns (
            uint256 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint256 answeredInRound
        );

}


pragma solidity 0.6.6;





contract ChainlinkPriceOracle is PriceOracleInterface {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 private constant SECONDS_IN_DAY = 60 * 60 * 24;
    uint8 private constant DECIMALS = 8;
    int256 private constant FLUCTUATION_THRESHOLD = 8; // 800%

    AggregatorInterface public immutable aggregator;

    constructor(AggregatorInterface aggregatorAddress) public {
        aggregator = aggregatorAddress;
    }

    function isWorking() external override returns (bool) {

        return
            _isNotDestructed() &&
            _isLatestPriceProper() &&
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

    function getPrice(uint256 id) external override returns (uint256) {

        int256 price = aggregator.getAnswer(id);
        return uint256(price);
    }

    function getTimestamp(uint256 id) external override returns (uint256) {

        return aggregator.getTimestamp(id);
    }

    function _isNotDestructed() private view returns (bool) {

        address aggregatorAddr = address(aggregator);
        uint256 size;
        assembly {
            size := extcodesize(aggregatorAddr)
        }
        return size != 0;
    }

    function _isLatestPriceProper() private view returns (bool r) {

        try aggregator.latestRoundData() returns (
            uint256 latestRound,
            int256 latestAnswer,
            uint256,
            uint256 updatedAt,
            uint256
        ) {
            if (latestRound == 0) {
                return r;
            }
            try aggregator.getAnswer(latestRound - 1) returns (
                int256 previousAnswer
            ) {
                if (now.sub(updatedAt) > SECONDS_IN_DAY) {
                    return r;
                }
                if (latestAnswer <= 0) {
                    return r;
                }
                if (latestAnswer > previousAnswer.mul(FLUCTUATION_THRESHOLD)) {
                    return r;
                }
                if (latestAnswer.mul(FLUCTUATION_THRESHOLD) < previousAnswer) {
                    return r;
                }
                r = true;
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
}