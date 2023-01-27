
pragma solidity ^0.4.24;

interface ConflictResolutionInterface {

    function minHouseStake(uint activeGames) external pure returns(uint);


    function maxBalance() external pure returns(int);


    function conflictEndFine() external pure returns(int);


    function isValidBet(uint8 _gameType, uint _betNum, uint _betValue) external pure returns(bool);


    function endGameConflict(
        uint8 _gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint _stake,
        bytes32 _serverSeed,
        bytes32 _userSeed
    )
        external
        view
        returns(int);


    function serverForceGameEnd(
        uint8 gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint _stake,
        uint _endInitiatedTime
    )
        external
        view
        returns(int);


    function userForceGameEnd(
        uint8 _gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint _stake,
        uint _endInitiatedTime
    )
        external
        view
        returns(int);

}

contract ConflictResolution is ConflictResolutionInterface {

    using SafeCast for int;
    using SafeCast for uint;
    using SafeMath for int;
    using SafeMath for uint;

    uint public constant DICE_RANGE = 100;
    uint public constant HOUSE_EDGE = 150;
    uint public constant HOUSE_EDGE_DIVISOR = 10000;

    uint public constant SERVER_TIMEOUT = 6 hours;
    uint public constant USER_TIMEOUT = 6 hours;

    uint8 public constant DICE_LOWER = 1; ///< @dev dice game lower number wins
    uint8 public constant DICE_HIGHER = 2; ///< @dev dice game higher number wins

    uint public constant MIN_BET_VALUE = 1e13; /// min 0.00001 ether bet
    uint public constant MIN_BANKROLL = 15e18;

    int public constant NOT_ENDED_FINE = 1e15; /// 0.001 ether

    int public constant CONFLICT_END_FINE = 1e15; /// 0.001 ether

    uint public constant PROBABILITY_DIVISOR = 10000;

    int public constant MAX_BALANCE = int(MIN_BANKROLL / 2);

    modifier onlyValidBet(uint8 _gameType, uint _betNum, uint _betValue) {

        require(isValidBet(_gameType, _betNum, _betValue), "inv bet");
        _;
    }

    modifier onlyValidBalance(int _balance, uint _gameStake) {

        require(-_gameStake.castToInt() <= _balance && _balance <= MAX_BALANCE, "inv balance");
        _;
    }

    function maxBet(uint _winProbability) public pure returns(uint) {

        assert(0 < _winProbability && _winProbability < PROBABILITY_DIVISOR);

        uint tmp1 = PROBABILITY_DIVISOR.mul(HOUSE_EDGE_DIVISOR).div(_winProbability);
        uint tmp2 = PROBABILITY_DIVISOR.mul(HOUSE_EDGE).div(_winProbability);

        uint enumerator = HOUSE_EDGE.mul(MIN_BANKROLL);
        uint denominator = tmp1.sub(tmp2).sub(HOUSE_EDGE_DIVISOR);
        uint maxBetVal = enumerator.div(denominator);

        return maxBetVal.add(5e14).div(1e15).mul(1e15); // round to multiple of 0.001 Ether
    }

    function isValidBet(uint8 _gameType, uint _betNum, uint _betValue) public pure returns(bool) {

        bool validMinBetValue = MIN_BET_VALUE <= _betValue;
        bool validGame = false;

        if (_gameType == DICE_LOWER) {
            validGame = _betNum > 0 && _betNum < DICE_RANGE - 1;
            validGame = validGame && _betValue <= maxBet(_betNum * PROBABILITY_DIVISOR / DICE_RANGE);
        } else if (_gameType == DICE_HIGHER) {
            validGame = _betNum > 0 && _betNum < DICE_RANGE - 1;
            validGame = validGame && _betValue <= maxBet((DICE_RANGE - _betNum - 1) * PROBABILITY_DIVISOR / DICE_RANGE);
        } else {
            validGame = false;
        }

        return validMinBetValue && validGame;
    }

    function conflictEndFine() public pure returns(int) {

        return CONFLICT_END_FINE;
    }

    function maxBalance() public pure returns(int) {

        return MAX_BALANCE;
    }

    function minHouseStake(uint activeGames) public pure returns(uint) {

        return  MathUtil.min(activeGames, 1) * MIN_BANKROLL;
    }

    function endGameConflict(
        uint8 _gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint _stake,
        bytes32 _serverSeed,
        bytes32 _userSeed
    )
        public
        view
        onlyValidBet(_gameType, _betNum, _betValue)
        onlyValidBalance(_balance, _stake)
        returns(int)
    {

        require(_serverSeed != 0 && _userSeed != 0, "inv seeds");

        int newBalance =  processBet(_gameType, _betNum, _betValue, _balance, _serverSeed, _userSeed);

        newBalance = newBalance.sub(CONFLICT_END_FINE);

        int stake = _stake.castToInt();
        if (newBalance < -stake) {
            newBalance = -stake;
        }

        return newBalance;
    }

    function serverForceGameEnd(
        uint8 _gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint _stake,
        uint _endInitiatedTime
    )
        public
        view
        onlyValidBalance(_balance, _stake)
        returns(int)
    {

        require(_endInitiatedTime + SERVER_TIMEOUT <= block.timestamp, "too low timeout");
        require(isValidBet(_gameType, _betNum, _betValue)
                || (_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0), "inv bet");


        int newBalance = _balance.sub(_betValue.castToInt());

        newBalance = newBalance.sub(NOT_ENDED_FINE);

        int stake = _stake.castToInt();
        if (newBalance < -stake) {
            newBalance = -stake;
        }

        return newBalance;
    }

    function userForceGameEnd(
        uint8 _gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint  _stake,
        uint _endInitiatedTime
    )
        public
        view
        onlyValidBalance(_balance, _stake)
        returns(int)
    {

        require(_endInitiatedTime + USER_TIMEOUT <= block.timestamp, "too low timeout");
        require(isValidBet(_gameType, _betNum, _betValue)
            || (_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0), "inv bet");

        int profit = 0;
        if (_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0) {
            profit = 0;
        } else {
            profit = calculateProfit(_gameType, _betNum, _betValue); // safe to cast as ranges are limited
        }

        profit = profit.add(NOT_ENDED_FINE);

        return _balance.add(profit);
    }

    function processBet(
        uint8 _gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        bytes32 _serverSeed,
        bytes32 _userSeed
    )
        public
        pure
        returns (int)
    {

        bool won = hasUserWon(_gameType, _betNum, _serverSeed, _userSeed);
        if (!won) {
            return _balance.sub(_betValue.castToInt());
        } else {
            int profit = calculateProfit(_gameType, _betNum, _betValue);
            return _balance.add(profit);
        }
    }

    function calculateProfit(uint8 _gameType, uint _betNum, uint _betValue) private pure returns(int) {

        uint betValueInGwei = _betValue / 1e9; // convert to gwei
        int res = 0;

        if (_gameType == DICE_LOWER) {
            res = calculateProfitGameType1(_betNum, betValueInGwei);
        } else if (_gameType == DICE_HIGHER) {
            res = calculateProfitGameType2(_betNum, betValueInGwei);
        } else {
            assert(false);
        }
        return res.mul(1e9); // convert to wei
    }

    function calcProfitFromTotalWon(uint _totalWon, uint _betValue) private pure returns(int) {

        uint houseEdgeValue = _totalWon.mul(HOUSE_EDGE).div(HOUSE_EDGE_DIVISOR);

        return _totalWon.castToInt().sub(houseEdgeValue.castToInt()).sub(_betValue.castToInt());
    }

    function calculateProfitGameType1(uint _betNum, uint _betValue) private pure returns(int) {

        assert(_betNum > 0 && _betNum < DICE_RANGE);

        uint totalWon = _betValue.mul(DICE_RANGE).div(_betNum);
        return calcProfitFromTotalWon(totalWon, _betValue);
    }

    function calculateProfitGameType2(uint _betNum, uint _betValue) private pure returns(int) {

        assert(_betNum >= 0 && _betNum < DICE_RANGE - 1);

        uint totalWon = _betValue.mul(DICE_RANGE).div(DICE_RANGE.sub(_betNum).sub(1));
        return calcProfitFromTotalWon(totalWon, _betValue);
    }

    function hasUserWon(
        uint8 _gameType,
        uint _betNum,
        bytes32 _serverSeed,
        bytes32 _userSeed
    )
        public
        pure
        returns(bool)
    {

        bytes32 combinedHash = keccak256(abi.encodePacked(_serverSeed, _userSeed));
        uint randNum = uint(combinedHash);

        if (_gameType == 1) {
            return calculateWinnerGameType1(randNum, _betNum);
        } else if (_gameType == 2) {
            return calculateWinnerGameType2(randNum, _betNum);
        } else {
            assert(false);
        }
    }

    function calculateWinnerGameType1(uint _randomNum, uint _betNum) private pure returns(bool) {

        assert(_betNum > 0 && _betNum < DICE_RANGE);

        uint resultNum = _randomNum % DICE_RANGE; // bias is negligible
        return resultNum < _betNum;
    }

    function calculateWinnerGameType2(uint _randomNum, uint _betNum) private pure returns(bool) {

        assert(_betNum >= 0 && _betNum < DICE_RANGE - 1);

        uint resultNum = _randomNum % DICE_RANGE; // bias is negligible
        return resultNum > _betNum;
    }
}

library MathUtil {

    function abs(int _val) internal pure returns(uint) {

        if (_val < 0) {
            return uint(-_val);
        } else {
            return uint(_val);
        }
    }

    function max(uint _val1, uint _val2) internal pure returns(uint) {

        return _val1 >= _val2 ? _val1 : _val2;
    }

    function min(uint _val1, uint _val2) internal pure returns(uint) {

        return _val1 <= _val2 ? _val1 : _val2;
    }
}

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