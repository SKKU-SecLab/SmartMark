pragma solidity ^0.5.0;


interface ConflictResolutionInterface {

    function minHouseStake(uint activeGames) external view returns(uint);


    function maxBalance() external view returns(int);


    function conflictEndFine() external pure returns(int);


    function isValidBet(uint8 _gameType, uint _betNum, uint _betValue) external view returns(bool);


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
        bytes32 _serverSeed,
        bytes32 _userSeed,
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
pragma solidity ^0.5.0;


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

interface GameInterface {

    function maxBet(uint _num, uint _bankRoll) external view returns(uint);


    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _num) external view returns(uint);


    function userProfit(uint _num, uint _betValue, uint _resultNum) external view returns(int);


    function maxUserProfit(uint _num, uint _betValue) external view returns(int);

}
pragma solidity ^0.5.0;



contract Games {

    using SafeMath for int;
    using SafeMath for uint;

    mapping (uint => GameInterface) public games;

    constructor(address[] memory gameContracts) public {
        for (uint i = 0; i < gameContracts.length; i++) {
            games[i + 1] = GameInterface(gameContracts[i]);
        }
    }

    function maxBet(uint8 _gameType, uint _num, uint _bankRoll) public view returns(uint) {

        uint maxBetVal = getGameImplementation(_gameType).maxBet(_num, _bankRoll);
        return maxBetVal.add(5e14).div(1e15).mul(1e15); // round to multiple of 0.001 Ether
    }

    function resultNumber(uint8 _gameType, bytes32 _serverSeed, bytes32 _userSeed, uint _num) public view returns(uint) {

        return getGameImplementation(_gameType).resultNumber(_serverSeed, _userSeed, _num);
    }

    function userProfit(uint8 _gameType, uint _num, uint _betValue, uint _resultNum) public view returns(int) {

        uint betValue = _betValue / 1e9; // convert to gwei

        int res = getGameImplementation(_gameType).userProfit(_num, betValue, _resultNum);

        return res.mul(1e9); // convert to wei
    }

    function maxUserProfit(uint8 _gameType, uint _num, uint _betValue) public view returns(int) {

        uint betValue = _betValue / 1e9; // convert to gwei

        int res = getGameImplementation(_gameType).maxUserProfit(_num, betValue);

        return res.mul(1e9); // convert to wei
    }

    function getGameImplementation(uint8 _gameType) private view returns(GameInterface) {

        require(games[_gameType] != GameInterface(0), "Invalid game type");
        return games[_gameType];

    }
}
pragma solidity ^0.5.0;



contract ConflictResolution is ConflictResolutionInterface, Games {

    using SafeCast for int;
    using SafeCast for uint;
    using SafeMath for int;
    using SafeMath for uint;

    uint public constant SERVER_TIMEOUT = 6 hours;
    uint public constant USER_TIMEOUT = 6 hours;

    uint public constant MIN_BET_VALUE = 1e13; /// min 0.00001 ether bet
    uint public constant MIN_BANKROLL = 50e18;

    int public constant NOT_ENDED_FINE = 1e16; /// 0.01 ether

    int public constant CONFLICT_END_FINE = 5e15; /// 0.005 ether

    int public constant MAX_BALANCE = int(MIN_BANKROLL / 2);

    modifier onlyValidBet(uint8 _gameType, uint _betNum, uint _betValue) {

        require(isValidBet(_gameType, _betNum, _betValue), "inv bet");
        _;
    }

    modifier onlyValidBalance(int _balance, uint _gameStake) {

        require(-_gameStake.castToInt() <= _balance && _balance <= MAX_BALANCE, "inv balance");
        _;
    }

    constructor(address[] memory games) Games(games) public {
    }

    function conflictEndFine() public pure returns(int) {

        return CONFLICT_END_FINE;
    }

    function maxBalance() public view returns(int) {

        return MAX_BALANCE;
    }

    function minHouseStake(uint activeGames) public view returns(uint) {

        return  MathUtil.min(activeGames, 1) * MIN_BANKROLL;
    }

    function isValidBet(uint8 _gameType, uint _betNum, uint _betValue) public view returns(bool) {

        bool validMinBetValue = MIN_BET_VALUE <= _betValue;
        bool validMaxBetValue = _betValue <= Games.maxBet(_gameType, _betNum, MIN_BANKROLL);
        return validMinBetValue && validMaxBetValue;
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
        bytes32 _serverSeed,
        bytes32 _userSeed,
        uint _endInitiatedTime
    )
        public
        view
        onlyValidBalance(_balance, _stake)
        returns(int)
    {

        require(_endInitiatedTime + SERVER_TIMEOUT <= block.timestamp, "too low timeout");
        require((_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0)
                || isValidBet(_gameType, _betNum, _betValue), "inv bet");


        int newBalance = 0;

        if (_gameType != 0) {
            newBalance = processBet(_gameType, _betNum, _betValue, _balance, _serverSeed, _userSeed);
        }

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
        require((_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0)
                || isValidBet(_gameType, _betNum, _betValue), "inv bet");

        int profit = 0;
        if (_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0) {
            profit = 0;
        } else {
            profit = Games.maxUserProfit(_gameType, _betNum, _betValue);
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
        view
        returns (int)
    {

        uint resNum = Games.resultNumber(_gameType, _serverSeed, _userSeed, _betNum);
        int profit = Games.userProfit(_gameType, _betNum, _betValue, resNum);
        return _balance.add(profit);
    }
}
