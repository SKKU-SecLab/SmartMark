
pragma solidity ^0.4.24;

library SafeCast {

    function castToInt(uint a) internal pure returns(int) {

        assert(a < (1 << 255));
        return int(a);
    }

    function castToUint(int a) internal pure returns(uint) {

        assert(a >= 0);
        return uint(a);
    }
}

library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }
        int256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        int256 INT256_MIN = int256((uint256(1) << 255));
        assert(a != INT256_MIN || b != - 1);
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        assert((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        assert((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }
}

interface GameInterface {

    function maxBet(uint _num, uint _bankRoll) external view returns(uint);


    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _num) external view returns(uint);


    function userProfit(uint _num, uint _betValue, uint _resultNum) external view returns(int);


    function maxUserProfit(uint _num, uint _betValue) external view returns(int);

}

contract Utilities {

    using SafeCast for int;
    using SafeCast for uint;
    using SafeMath for int;
    using SafeMath for uint;

    uint constant public PROBABILITY_DIVISOR = 10000;
    uint constant public HOUSE_EDGE = 150;
    uint constant public HOUSE_EDGE_DIVISOR = 10000;

    function maxBetFromProbability(uint _winProbability, uint _bankRoll) public pure returns(uint) {

        assert(0 < _winProbability && _winProbability < PROBABILITY_DIVISOR);

        uint tmp1 = PROBABILITY_DIVISOR.mul(HOUSE_EDGE_DIVISOR).div(_winProbability);
        uint tmp2 = PROBABILITY_DIVISOR.mul(HOUSE_EDGE).div(_winProbability);

        uint enumerator = HOUSE_EDGE.mul(_bankRoll);
        uint denominator = tmp1.sub(tmp2).sub(HOUSE_EDGE_DIVISOR);
        return enumerator.div(denominator);
    }

    function calcProfitFromTotalWon(uint _totalWon, uint _betValue) public pure returns(int) {

        uint houseEdgeValue = _totalWon.mul(HOUSE_EDGE).div(HOUSE_EDGE_DIVISOR);

        return _totalWon.castToInt().sub(houseEdgeValue.castToInt()).sub(_betValue.castToInt());
    }

    function generateRandomNumber(bytes32 _serverSeed, bytes32 _userSeed) public pure returns(uint) {

        bytes32 combinedHash = keccak256(abi.encodePacked(_serverSeed, _userSeed));
        return uint(combinedHash);
    }
}

contract ChooseFrom12 is GameInterface, Utilities {

    using SafeCast for uint;
    using SafeMath for uint;

    uint private constant NUMBERS = 12;

    modifier onlyValidNum(uint _betNum) {

        require(_betNum > 0 && _betNum < ((1 << NUMBERS) - 1), "Invalid num");
        _;
    }

    modifier onlyValidResultNum(uint _resultNum) {

         require(_resultNum >= 0 &&  _resultNum < NUMBERS);
        _;
    }

    function maxBet(uint _betNum, uint _bankRoll) external onlyValidNum(_betNum) view returns(uint) {

        uint probability = getSelectedBits(_betNum).mul(Utilities.PROBABILITY_DIVISOR) / NUMBERS;
        return Utilities.maxBetFromProbability(probability, _bankRoll);
    }

    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _betNum) external onlyValidNum(_betNum) view returns(uint) {

        uint randNum = Utilities.generateRandomNumber(_serverSeed, _userSeed);
        return randNum % NUMBERS;
    }

    function userProfit(uint _betNum, uint _betValue, uint _resultNum)
        external
        onlyValidNum(_betNum)
        onlyValidResultNum(_resultNum)
        view
        returns(int)
    {

        bool won = (_betNum & (1 <<_resultNum)) > 0;
        if (won) {
            uint totalWon = _betValue.mul(NUMBERS).div(getSelectedBits(_betNum));
            return Utilities.calcProfitFromTotalWon(totalWon, _betValue);
        } else {
            return -_betValue.castToInt();
        }
    }

    function maxUserProfit(uint _betNum, uint _betValue) external onlyValidNum(_betNum) view returns(int) {

        uint totalWon = _betValue.mul(NUMBERS) / getSelectedBits(_betNum);
        return Utilities.calcProfitFromTotalWon(totalWon, _betValue);
    }

    function getSelectedBits(uint _num) private pure returns(uint) {

        uint selectedBits = 0;
        for (uint i = 0; i < NUMBERS; i++) {
            if (_num & (1 << i) > 0) {
                selectedBits += 1;
            }
        }
        return selectedBits;
    }
}