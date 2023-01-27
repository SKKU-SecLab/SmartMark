





pragma solidity ^0.5.0;

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


pragma solidity ^0.5.0;

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


pragma solidity 0.5.16;

contract OracleAggregatorErrors {

    string constant internal ERROR_ORACLE_AGGREGATOR_NOT_ENOUGH_ETHER = "ORACLE_AGGREGATOR:NOT_ENOUGH_ETHER";

    string constant internal ERROR_ORACLE_AGGREGATOR_QUERY_WAS_ALREADY_MADE = "ORACLE_AGGREGATOR:QUERY_WAS_ALREADY_MADE";

    string constant internal ERROR_ORACLE_AGGREGATOR_DATA_DOESNT_EXIST = "ORACLE_AGGREGATOR:DATA_DOESNT_EXIST";

    string constant internal ERROR_ORACLE_AGGREGATOR_DATA_ALREADY_EXIST = "ORACLE_AGGREGATOR:DATA_ALREADY_EXIST";
}


pragma solidity 0.5.16;

interface IOracleId {

    function fetchData(uint256 timestamp) external payable;


    function recursivelyFetchData(uint256 timestamp, uint256 period, uint256 times) external payable;


    function calculateFetchPrice() external returns (uint256 fetchPrice);


    event MetadataSet(string metadata);
}


pragma solidity 0.5.16;





contract OracleAggregator is OracleAggregatorErrors, ReentrancyGuard {

    using SafeMath for uint256;

    mapping (address => mapping(uint256 => uint256)) public dataCache;

    mapping (address => mapping(uint256 => bool)) public dataExist;

    mapping (address => mapping(uint256 => bool)) public dataRequested;


    modifier enoughEtherProvided(address oracleId, uint256 times) {

        uint256 oneTimePrice = calculateFetchPrice(oracleId);

        require(msg.value >= oneTimePrice.mul(times), ERROR_ORACLE_AGGREGATOR_NOT_ENOUGH_ETHER);
        _;
    }


    function fetchData(address oracleId, uint256 timestamp) public payable nonReentrant enoughEtherProvided(oracleId, 1) {

        _registerQuery(oracleId, timestamp);

        IOracleId(oracleId).fetchData.value(msg.value)(timestamp);
    }

    function recursivelyFetchData(address oracleId, uint256 timestamp, uint256 period, uint256 times) public payable nonReentrant enoughEtherProvided(oracleId, times) {

        for (uint256 i = 0; i < times; i++) {
            _registerQuery(oracleId, timestamp + period * i);
        }

        IOracleId(oracleId).recursivelyFetchData.value(msg.value)(timestamp, period, times);
    }

    function __callback(uint256 timestamp, uint256 data) public {

        require(!dataExist[msg.sender][timestamp], ERROR_ORACLE_AGGREGATOR_DATA_ALREADY_EXIST);

        dataCache[msg.sender][timestamp] = data;

        dataExist[msg.sender][timestamp] = true;
    }

    function calculateFetchPrice(address oracleId) public returns(uint256 fetchPrice) {

        fetchPrice = IOracleId(oracleId).calculateFetchPrice();
    }


    function _registerQuery(address oracleId, uint256 timestamp) private {

        require(!dataRequested[oracleId][timestamp] && !dataExist[oracleId][timestamp], ERROR_ORACLE_AGGREGATOR_QUERY_WAS_ALREADY_MADE);

        dataRequested[oracleId][timestamp] = true;
    }


    function getData(address oracleId, uint256 timestamp) public view returns(uint256 dataResult) {

        require(hasData(oracleId, timestamp), ERROR_ORACLE_AGGREGATOR_DATA_DOESNT_EXIST);

        dataResult = dataCache[oracleId][timestamp];
    }

    function hasData(address oracleId, uint256 timestamp) public view returns(bool result) {

        return dataExist[oracleId][timestamp];
    }
}