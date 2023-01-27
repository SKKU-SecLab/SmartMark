


pragma solidity 0.5.16;

interface IBTokenScore {

    function start() external view returns (uint);

    function spin() external;


    function getDebtScore(address user, address cToken, uint256 time) external view returns (uint);

    function getCollScore(address user, address cToken, uint256 time) external view returns (uint);


    function getDebtGlobalScore(address cToken, uint256 time) external view returns (uint);

    function getCollGlobalScore(address cToken, uint256 time) external view returns (uint);


    function endDate() external view returns(uint);

}


pragma solidity 0.5.16;


contract JarConnector {


    IBTokenScore public score;
    address[] public cTokens;

    constructor(address[] memory _cTokens, address _score) public {
        score = IBTokenScore(_score);

        cTokens = _cTokens;
    }

    function getUserScore(address user) external view returns (uint) {

        return _getTotalUserScore(user, now);
    }

    function getUserScoreProgressPerSec(address user) external view returns (uint) {

        return _getTotalUserScore(user, now + 1) - _getTotalUserScore(user, now);
    }

    function getGlobalScore() external view returns (uint) {

        return _getTotalGlobalScore(now);
    }

    function _getTotalUserScore(address user, uint time) internal view returns (uint256) {

        uint totalScore = 0;
        for(uint i = 0; i < cTokens.length; i++) {
            uint debtScore = score.getDebtScore(user, cTokens[i], time);
            uint collScore = score.getCollScore(user, cTokens[i], time);
            totalScore = add_(add_(totalScore, debtScore), collScore);
        }
        return totalScore;
    }

    function _getTotalGlobalScore(uint time) internal view returns (uint256) {

        uint totalScore = 0;
        for(uint i = 0; i < cTokens.length; i++) {
            uint debtScore = score.getDebtGlobalScore(cTokens[i], time);
            uint collScore = score.getCollGlobalScore(cTokens[i], time);
            totalScore = add_(add_(totalScore, debtScore), collScore);
        }
        return totalScore;
    }

    function spin() external {

        require(score.endDate() < now, "too-early");
        score.spin();
    }

    function add_(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "overflow");
        return c;
    }
}