
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

contract Keno is GameInterface, Utilities {

    using SafeCast for uint;
    using SafeMath for uint;

    uint public constant DIVIDER = 1000;

    uint public constant SELECTABLE_FIELDS = 10;

    uint public constant FIELDS = 40;

    uint16[11] public MAX_BET = [0, 5, 10, 7, 5, 4, 4, 2, 2, 2, 1];

    uint24[][11] public PAY_OUT;

    event LogGameCreated(uint num);

    constructor() public {
        PAY_OUT[0]  = [0];
        PAY_OUT[1]  = [0, 3940];
        PAY_OUT[2]  = [0, 2000, 3740];
        PAY_OUT[3]  = [0, 1000, 3150, 9400];
        PAY_OUT[4]  = [0, 800, 1700, 5300, 24500];
        PAY_OUT[5]  = [0, 250, 1400, 4000, 16600, 42000];
        PAY_OUT[6]  = [0, 0, 1000, 3650, 7000, 16000, 46000];
        PAY_OUT[7]  = [0, 0, 460, 3000, 4400, 14000, 39000, 80000];
        PAY_OUT[8]  = [0, 0, 0, 2250, 4000, 11000, 30000, 67000, 90000];
        PAY_OUT[9]  = [0, 0, 0, 1550, 3000, 8000, 14000, 37000, 65000, 100000];
        PAY_OUT[10] = [0, 0, 0, 1400, 2200, 4400, 8000, 28000, 60000, 120000, 200000];
    }

    modifier onlyValidNum(uint _betNum) {

        require(_betNum > 0 && _betNum < (1 << FIELDS) && getSelectedBits(_betNum) <= SELECTABLE_FIELDS, "Invalid num");
        _;
    }

    modifier onlyValidResultNum(uint _resultNum) {

        require(_resultNum < (1 << FIELDS) && getSelectedBits(_resultNum) == SELECTABLE_FIELDS);
        _;
    }

    function maxBet(uint _betNum, uint _bankRoll) external onlyValidNum(_betNum) view returns(uint) {

        uint fields = getSelectedBits(_betNum);
        return uint(MAX_BET[fields]).mul(_bankRoll).div(DIVIDER);
    }

    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _betNum) external onlyValidNum(_betNum) view returns(uint) {

        uint resultNum = 0;
        bytes32 seed = keccak256(abi.encodePacked(_serverSeed, _userSeed));

        for (uint i = 0; i < SELECTABLE_FIELDS; i++) {
            uint randNum = uint(seed) % (FIELDS - i);

            uint pos = 0;
            uint resultPos = 0;
            for (;;) {
                if (resultNum & (1 << resultPos) == 0) {
                    if (pos == randNum) {
                        break;
                    }
                    pos++;
                }
                resultPos++;
            }
            resultNum |= 1 << resultPos;

            seed = keccak256(abi.encodePacked(seed));
        }

        return resultNum;
    }

    function userProfit(uint _betNum, uint _betValue, uint _resultNum)
        external
        onlyValidNum(_betNum)
        onlyValidResultNum(_resultNum)
        view
        returns(int)
    {

        uint hits = getSelectedBits(_betNum & _resultNum);
        uint selected = getSelectedBits(_betNum);

        return calcProfit(_betValue, selected, hits);
    }

    function maxUserProfit(uint _betNum, uint _betValue) external onlyValidNum(_betNum) view returns(int) {

        uint selected = getSelectedBits(_betNum);

        return calcProfit(_betValue, selected, selected);
    }

    function calcProfit(uint _betValue, uint _selected, uint _hits) private view returns(int) {

        assert(_hits <= _selected);
        assert(_selected <= SELECTABLE_FIELDS);

        uint payoutMultiplier = PAY_OUT[_selected][_hits];
        uint payout = _betValue.mul(payoutMultiplier).div(DIVIDER);
        return payout.castToInt().sub(_betValue.castToInt());
    }

    function getSelectedBits(uint _num) private pure returns(uint) {

        uint selectedBits = 0;
        for (uint i = 0; i < FIELDS; i++) {
            if (_num & (1 << i) > 0) {
                selectedBits += 1;
            }
        }
        return selectedBits;
    }
}