

pragma solidity ^0.6.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract Staker is Ownable {

    using SafeMath for uint256;

    string public name = "High Stakes Staking Game";

    uint256 public constant maxWaitTime = 6 days;
    uint256 public constant minimalWaitTime = 3 days;
    uint256 public constant contractCoolDownTime = 1 days;
    uint256 public constant referralLockBonus = 1 days;

    uint256 public totalRisk = 0;
    uint256 public totalETH = 0;

    mapping(address => uint256) public stakerRisk;
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public referralStake;

    mapping(address => uint256) public timeLocked;

    uint256 public contractLaunchTime = now + contractCoolDownTime;

    uint256 private devETH;
    uint256 public constant devFeesPercent = 5;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function sqrt(uint y) internal pure returns (uint) {

        uint z = 0;
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        return z;
    }

    function randWaitTime() private view returns(uint256) {

        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
            block.gaslimit +
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
            block.number
        )));

        return minimalWaitTime + referralLockBonus + (seed - ((seed / maxWaitTime) * maxWaitTime)) * 1 seconds;
    }

    function getRisk(uint256 secondsPassed, uint256 ethAdded) private view returns(uint256) {

        uint256 timeLeft = (maxWaitTime - secondsPassed) * 3;
        if (secondsPassed > maxWaitTime) {
            timeLeft = 0;
        }
        timeLeft += maxWaitTime;
        return timeLeft * ethAdded;
    }


    modifier checkStart() {

        require(contractLaunchTime <= now, "Contract staking hasn't started yet.");
        _;
    }

    function stake(address referral) public payable checkStart returns (bool success) {

        require(msg.value >= 10000000000000000, "Cannot stake less than 0.01 ETH.");
        require(referral != msg.sender, "You can't refer yourself.");

        referralStake[referral] += msg.value;

        uint256 risk = getRisk(now - (contractLaunchTime), msg.value);

        stakerRisk[msg.sender] += risk;
        totalRisk += risk;

        timeLocked[msg.sender] = randWaitTime();

        uint256 valueMinusFees = msg.value * (100 - devFeesPercent) / 100;
        stakingBalance[msg.sender] += msg.value;
        totalETH += valueMinusFees;
        devETH += msg.value - valueMinusFees;
        emit Staked(msg.sender, msg.value);
        return true;
    }

    function unstakeTokens() public returns (bool success) {

        uint256 balance = stakingBalance[msg.sender];
        require(getUserUnlockTime(msg.sender) <= now, "Your lock period has not yet ended");
        require(balance > 0, "Can't unstake 0 ETH.");

        uint256 risk = stakerRisk[msg.sender];
        uint256 exitValue = getCurrentUserExitValue(msg.sender);

        stakingBalance[msg.sender] = 0;
        stakerRisk[msg.sender] = 0;
        totalETH -= exitValue;
        totalRisk -= risk;
        if (!msg.sender.send(exitValue)) {
            stakingBalance[msg.sender] = balance;
            totalETH += exitValue;

            stakerRisk[msg.sender] = risk;
            totalRisk += risk;
            return false;
        }
        emit Withdrawn(msg.sender, exitValue);
        return true;
    }

    function getUserUnlockTime(address user) public view returns (uint256) {

        uint256 senderLock = timeLocked[user];
        uint256 referredETH = referralStake[user];

        senderLock -= referredETH * 36 seconds / 10000000000000000;
        if (senderLock < minimalWaitTime) {
            senderLock = minimalWaitTime;
        }
        return contractLaunchTime + senderLock;
    }

    function getCurrentUserExitValue(address user) public view returns (uint256) {

        if (totalRisk > 0) {
            if (stakerRisk[user] / sqrt(totalRisk) > 1) {
                return totalETH;
            }
            return totalETH * stakerRisk[user] / sqrt(totalRisk);
        }
        return 0;
    }

    function getUserEthStaked(address user) public view returns (uint256) {

        return stakingBalance[user];
    }

    function getCurrentPotential() public view returns (uint256) {

        uint256 currentRisk = getRisk(now - (contractLaunchTime), 1000000000000000000);
        if (totalRisk > 0) {
            uint256 potentialGains = totalETH * currentRisk / sqrt(totalRisk);
            if (potentialGains > totalETH) {
                potentialGains = totalETH;
            }
            return potentialGains;
        }
        return 0;
    }

    function withdrawDevFund() public payable onlyOwner returns (bool success) {

        require(contractLaunchTime + maxWaitTime * 1 seconds <= now, "Contract hasn't ended yet.");
        devETH += totalETH;
        totalETH = 0;

        uint256 balance = devETH;
        devETH = 0;

        if (!msg.sender.send(balance)) {
            devETH = balance;
            return false;
        }
        return true;
    }
}