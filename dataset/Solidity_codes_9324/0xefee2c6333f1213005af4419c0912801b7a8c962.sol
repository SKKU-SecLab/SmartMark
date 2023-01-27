
pragma solidity ^0.5.0;


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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

contract OneOAKGovernance {

    using SafeMath for uint256;
    
    modifier onlyOwner() {

        require(msg.sender == owner, "Owner required");
        _;
    }
    
    modifier unlocked(uint256 index) {

        require(!isTimelockActivated || block.number > unlockTimes[index], "Locked");
        _;
    }    

    modifier timelockUnlocked() {

        require(!isTimelockActivated || block.number > timelockLengthUnlockTime, "Timelock variable Locked");
        _;
    }

    address public owner;

    uint256 constant DEFAULT_TIMELOCK_LENGTH = 44800; // length in blocks ~7 days;

    mapping(uint256 => address) public pendingValues;
    mapping(uint256 => uint256) public unlockTimes;

    uint256 public timelockLengthUnlockTime = 0;
    uint256 public timelockLength = DEFAULT_TIMELOCK_LENGTH;
    uint256 public nextTimelockLength = DEFAULT_TIMELOCK_LENGTH;

    bool public isTimelockActivated = false;

    mapping(uint256 => address) public governanceContracts;

    constructor () public {    
        owner = msg.sender;
    }

    function activateTimelock() external onlyOwner {

        isTimelockActivated = true;
    }

    function setPendingValue(uint256 index, address value) external onlyOwner {

        pendingValues[index] = value;
        unlockTimes[index] = timelockLength.add(block.number);
    }

    function certifyPendingValue(uint256 index) external onlyOwner unlocked(index) {

        governanceContracts[index] = pendingValues[index];
        unlockTimes[index] = 0;
    }

    function proposeNextTimelockLength(uint256 value) public onlyOwner {

        nextTimelockLength = value;
        timelockLengthUnlockTime = block.number.add(timelockLength);
    }

    function certifyNextTimelockLength() public onlyOwner timelockUnlocked() {

        timelockLength = nextTimelockLength;
        timelockLengthUnlockTime = 0;
    }

    function getGovernanceContract(uint _type) public view returns (address) {

        return governanceContracts[_type];
    }
}