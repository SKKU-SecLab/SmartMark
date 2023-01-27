
pragma solidity ^0.5.0;

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

contract Wheel is GameInterface, Utilities {

    using SafeCast for uint;
    using SafeMath for uint;

    uint public constant MAX_BET_DIVIDER = 10000;

    uint public constant PAYOUT_DIVIDER = 100;

    uint public constant RESULT_RANGE = 600;

    mapping (uint => mapping(uint => uint16)) public MAX_BET;

    mapping (uint => mapping(uint => uint16[])) public PAYOUT;

    constructor() public {
        MAX_BET[1][10] = 632;
        MAX_BET[1][20] = 386;
        MAX_BET[2][10] = 134;
        MAX_BET[2][20] = 134;
        MAX_BET[3][10] = 17;
        MAX_BET[3][20] = 8;

        PAYOUT[1][10] = [0, 120, 120, 0, 120, 120, 145, 120, 120, 120];
        PAYOUT[1][20] = [0, 120, 120, 0, 120, 120, 145, 120, 0, 120, 240, 120, 0, 120, 120, 145, 120, 0, 120, 120];
        PAYOUT[2][10] = [0, 165, 0, 160, 0, 300, 0, 160, 0, 200];
        PAYOUT[2][20] = [0, 165, 0, 160, 0, 300, 0, 160, 0, 200, 0, 165, 0, 160, 0, 300, 0, 160, 0, 200];
        PAYOUT[3][10] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 985];
        PAYOUT[3][20] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1970];
    }

    modifier onlyValidNum(uint _betNum) {

        uint risk = getRisk(_betNum);
        uint segments = getSegments(_betNum);

        require(risk >= 1 && risk <= 3 && segments >= 10 && segments <= 20 && segments % 10 == 0, "Invalid num");
        _;
    }

    modifier onlyValidResultNum(uint _resultNum) {

        require(_resultNum >= 0 && _resultNum < RESULT_RANGE);
        _;
    }

    function maxBet(uint _betNum, uint _bankRoll) external onlyValidNum(_betNum) view returns(uint) {

        uint risk = getRisk(_betNum);
        uint segments = getSegments(_betNum);
        uint maxBetValue = MAX_BET[risk][segments];

        return _bankRoll.mul(maxBetValue).div(MAX_BET_DIVIDER);
    }

    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _betNum) external onlyValidNum(_betNum) view returns(uint) {

        uint randNum = Utilities.generateRandomNumber(_serverSeed, _userSeed);
        return randNum % RESULT_RANGE;
    }

    function userProfit(uint _betNum, uint _betValue, uint _resultNum)
        external
        onlyValidNum(_betNum)
        onlyValidResultNum(_resultNum)
        view
        returns(int)
    {

        uint risk = getRisk(_betNum);
        uint segments = getSegments(_betNum);
        uint16[] storage payout = PAYOUT[risk][segments];
        uint16 payoutValue = payout[_resultNum.mul(payout.length).div(RESULT_RANGE)];

        return calculateProfit(payoutValue, _betValue);
    }


    function maxUserProfit(uint _betNum, uint _betValue) external onlyValidNum(_betNum) view returns(int) {

        uint risk = getRisk(_betNum);
        uint segments = getSegments(_betNum);

        uint16[] storage payout = PAYOUT[risk][segments];
        uint maxPayout = 0;
        for (uint i = 0; i < payout.length; i++) {
            if (payout[i] > maxPayout) {
                maxPayout = payout[i];
            }
        }

        return calculateProfit(maxPayout, _betValue);
    }

    function calculateProfit(uint _payout, uint _betValue) private pure returns(int) {

        return _betValue.mul(_payout).div(PAYOUT_DIVIDER).castToInt().sub(_betValue.castToInt());
    }

    function getRisk(uint _num) private pure returns(uint) {

        return (_num / 100) % 10;
    }

    function getSegments(uint _num) private pure returns(uint) {

        return _num % 100;
    }
}