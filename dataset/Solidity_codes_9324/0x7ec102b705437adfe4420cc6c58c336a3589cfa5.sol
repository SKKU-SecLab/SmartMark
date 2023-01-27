pragma solidity ^0.5.0;

interface GameInterface {

    function maxBet(uint _num, uint _bankRoll) external view returns(uint);


    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _num) external view returns(uint);


    function userProfit(uint _num, uint _betValue, uint _resultNum) external view returns(int);


    function maxUserProfit(uint _num, uint _betValue) external view returns(int);

}
pragma solidity ^0.5.0;


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
pragma solidity ^0.5.0;



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
pragma solidity ^0.5.0;



contract Plinko is GameInterface, Utilities {

    using SafeCast for uint;
    using SafeMath for uint;

    uint public constant MAX_BET_DIVIDER = 10000;

    uint public constant PAYOUT_DIVIDER = 10;

    mapping (uint => mapping(uint => uint16)) public MAX_BET;

    mapping (uint => mapping(uint => uint16[])) public PAYOUT;

    constructor() public {
        MAX_BET[1][8] = 264;
        MAX_BET[1][12] = 607;
        MAX_BET[1][16] = 758;
        MAX_BET[2][8] = 55;
        MAX_BET[2][12] = 175;
        MAX_BET[2][16] = 208;
        MAX_BET[3][8] = 24;
        MAX_BET[3][12] = 77;
        MAX_BET[3][16] = 68;

        PAYOUT[1][8] = [4, 9, 14, 19, 73];
        PAYOUT[1][12] = [4, 10, 11, 15, 18, 31, 100];
        PAYOUT[1][16] = [4, 10, 11, 12, 16, 17, 18, 75, 130];
        PAYOUT[2][8] = [3, 5, 15, 37, 160];
        PAYOUT[2][12] = [3, 6, 14, 20, 30, 42, 220];
        PAYOUT[2][16] = [2, 5, 14, 17, 19, 40, 63, 96, 250];
        PAYOUT[3][8] = [1, 3, 10, 71, 210];
        PAYOUT[3][12] = [1, 4, 11, 31, 46, 81, 270];
        PAYOUT[3][16] = [1, 3, 11, 20, 32, 56, 100, 260, 800];
    }

    modifier onlyValidNum(uint _betNum) {

        uint risk = getRisk(_betNum);
        uint rows = getRows(_betNum);

        require(risk >= 1 && risk <= 3 && (rows == 8 || rows == 12 || rows == 16) , "Invalid num");
        _;
    }

    modifier onlyValidResultNum(uint _betNum, uint _resultNum) {

        uint rows = getRows(_betNum);
        require(_resultNum >= 0 && _resultNum < (1 << rows));
        _;
    }

    function maxBet(uint _betNum, uint _bankRoll) external onlyValidNum(_betNum) view returns(uint) {

        uint risk = getRisk(_betNum);
        uint rows = getRows(_betNum);

        uint maxBetValue = MAX_BET[risk][rows];

        return _bankRoll.mul(maxBetValue).div(MAX_BET_DIVIDER);
    }

    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _betNum) external onlyValidNum(_betNum) view returns(uint) {

        uint randNum = Utilities.generateRandomNumber(_serverSeed, _userSeed);
        uint rows = getRows(_betNum);
        return randNum & ((1 << rows) - 1);
    }

    function userProfit(uint _betNum, uint _betValue, uint _resultNum)
        external
        onlyValidNum(_betNum)
        onlyValidResultNum(_betNum, _resultNum)
        view
        returns(int)
    {

        uint risk = getRisk(_betNum);
        uint rows = getRows(_betNum);

        uint result = countBits(_resultNum, rows);
        uint resultIndex = calculateResultIndex(result, rows);
        uint16 payoutValue = PAYOUT[risk][rows][resultIndex];

        return calculateProfit(payoutValue, _betValue);
    }


    function maxUserProfit(uint _betNum, uint _betValue) external onlyValidNum(_betNum) view returns(int) {

        uint risk = getRisk(_betNum);
        uint rows = getRows(_betNum);

        uint16[] storage payout = PAYOUT[risk][rows];
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

    function calculateResultIndex(uint _result, uint _rows) private pure returns(uint) {

        uint halfRows = _rows / 2;
        return _result < halfRows ? halfRows - _result : _result - halfRows;
    }

    function getRisk(uint _num) private pure returns(uint) {

        return (_num / 100) % 10;
    }

    function getRows(uint _num) private pure returns(uint) {

        return _num % 100;
    }

    function countBits(uint _num, uint _rows) private pure returns(uint) {

        uint selectedBits = 0;
        for (uint i = 0; i < _rows; i++) {
            if (_num & (1 << i) > 0) {
                selectedBits += 1;
            }
        }
        return selectedBits;
    }
}
