

pragma solidity ^0.4.24;

contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {

    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Sender is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "New owner address is invalid");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract AINStake is Ownable {

    using SafeMath for uint256;

    ERC20 public token;
    uint256 public closingTime;
    uint256 public interestRate = 1020000; // 1.02 (2%, monthly)
    uint256 public divider = 1000000;
    uint256 public maxStakingAmountPerUser = 20000 ether; // 20,000 AIN (~1,000,000 KRW)
    uint256 public maxUnstakingAmountPerUser = 40000 ether; // 40,000 AIN
    uint256 public maxStakingAmountPerContract = 2000000 ether; // 2,000,000 AIN (~100,000,000 KRW)
    uint256 constant public MONTH = 30 days; // ~1 month in seconds

    bool public stakingClosed = false;
    bool public contractClosed = false;
    bool public reEntrancyMutex = false;

    mapping(address => UserStake) public userStakeMap; // userAddress => { index, [{ amount, startTime }, ...] }
    mapping(address => uint256) public singleStakeSum; // userAddress => sum
    uint256 public contractSingleStakeSum;
    address[] public userList;

    struct StakeItem {
        uint256 amount; // amount of tokens staked
        uint256 startTime; // timestamp when tokens are staked
    }

    struct UserStake {
        uint256 index; // index of the user within userList
        StakeItem[] stakes; // stakes from the user
    }

    event MultiStake(address[] users, uint256[] amounts, uint256 startTime);
    event Stake(address user, uint256 amount, uint256 startTime);
    event Unstake(address user, uint256 amount);

    constructor(ERC20 _token, uint256 _closingTime) public {
        token = _token;
        closingTime = _closingTime;
    }

    function userExists(address user) public view returns (bool) {

        return userStakeMap[user].index > 0 || (userList.length > 0 && userList[0] == user);
    }

    function getUserListLength() public view returns (uint256) {

        return userList.length;
    }

    function getUserStakeCount(address user) public view returns (uint256) {

        return userStakeMap[user].stakes.length;
    }

    function getUserStake(address user, uint256 index) public view returns (uint256, uint256) {

        if (index >= getUserStakeCount(user)) {
            return (0, 0);
        }
        StakeItem memory item = userStakeMap[user].stakes[index];
        return (item.amount, item.startTime);
    }

    function closeContract() onlyOwner public returns (bool) {

        require(contractClosed == false, "contract is closed");

        while (userList.length > 0) {
            _unstake(userList[0]);
        }

        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) {
            require(token.transfer(owner, balance), "token transfer to owner failed");
        }
        stakingClosed = true;
        contractClosed = true;
        return true;
    }

    function openStaking() onlyOwner public returns (bool) {

        require(stakingClosed == true, "staking is open");
        require(contractClosed == false, "contract is closed");
        stakingClosed = false;
        return true;
    }

    function closeStaking() onlyOwner public returns (bool) {

        require(stakingClosed == false, "staking is closed");
        stakingClosed = true;
        return true;
    }

    function setMaxStakingAmountPerUser(uint256 max) onlyOwner public {

        maxStakingAmountPerUser = max;
    }

    function setMaxUnstakingAmountPerUser(uint256 max) onlyOwner public {

        maxUnstakingAmountPerUser = max;
    }

    function setMaxStakingAmountPerContract(uint256 max) onlyOwner public {

        maxStakingAmountPerContract = max;
    }

    function extendContract(uint256 rate, uint256 time) onlyOwner public {

        require(contractClosed == false, "contract is closed");
        require(block.timestamp >= closingTime,
            "cannot extend contract before the current closingTime");
        if (interestRate != rate) {
            for (uint256 i = 0; i < userList.length; i++) {
                address user = userList[i];
                uint256 total = calcUserStakeAndInterest(user, closingTime);
                deleteUser(user);
                addUser(user);
                _stake(user, total, block.timestamp);
            }
            interestRate = rate;
        }
        closingTime = time;
    }

    function getUserTotalStakeSum(address user) public view returns (uint256) {

        uint256 sum = 0;
        StakeItem[] memory stakes = userStakeMap[user].stakes;
        for (uint256 i = 0; i < stakes.length; i++) {
            sum = sum.add(stakes[i].amount);
        }
        return sum;
    }

    function min(uint256 a, uint256 b) public pure returns (uint256) {

        return a < b ? a : b;
    }

    function calcUserStakeAndInterest(address user, uint256 _endTime) public view returns (uint256) {

        uint256 endTime = min(_endTime, closingTime);
        uint256 total = 0;
        uint256 multiplier = 1000000;
        uint256 currentMonthsPassed = 0;
        uint256 currentMonthSum = 0;
        StakeItem[] memory stakes = userStakeMap[user].stakes;
        for (uint256 i = stakes.length; i > 0; i--) { // start with the most recent stakes
            uint256 amount = stakes[i.sub(1)].amount;
            uint256 startTime = stakes[i.sub(1)].startTime;
            if (startTime > endTime) { // should not happen
                total = total.add(amount);
            } else {
                uint256 monthsPassed = (endTime.sub(startTime)).div(MONTH);
                if (monthsPassed == currentMonthsPassed) {
                    currentMonthSum = currentMonthSum.add(amount);
                } else {
                    total = total.add(currentMonthSum.mul(multiplier).div(divider));
                    currentMonthSum = amount;
                    while (currentMonthsPassed < monthsPassed) {
                        multiplier = multiplier.mul(interestRate).div(divider);
                        currentMonthsPassed = currentMonthsPassed.add(1);
                    }
                }
            }
        }
        total = total.add(currentMonthSum.mul(multiplier).div(divider));
        require(total <= maxUnstakingAmountPerUser, "maxUnstakingAmountPerUser exceeded");
        return total;
    }

    function calcContractStakeAndInterest(uint256 endTime) public view returns (uint256) {

        uint256 total = 0;
        for (uint256 i = 0; i < userList.length; i++) {
            total = total.add(calcUserStakeAndInterest(userList[i], endTime));
        }
        return total;
    }

    function addUser(address user) private {

        userList.push(user);
        userStakeMap[user].index = userList.length.sub(1);
    }

    function deleteUser(address user) private {

        uint256 index = userStakeMap[user].index;
        uint256 len = userList.length;
        require(index < len, "invalid array index");
        require(len > 0, "userList empty");
        if (index != len.sub(1)) {
            userList[index] = userList[len.sub(1)];
            userStakeMap[userList[len.sub(1)]].index = index;
        }
        userList.length = len.sub(1);
        delete userStakeMap[user];
        contractSingleStakeSum = contractSingleStakeSum.sub(singleStakeSum[user]);
        delete singleStakeSum[user];
    }

    function addMultiStakeWhitelist(address[] users) onlyOwner public {

        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            if (!userExists(user)) {
                addUser(user);
            }
        }
    }

    function _stake(address user, uint256 amount, uint256 startTime) private {

        userStakeMap[user].stakes.push(StakeItem(amount, startTime));
    }

    function multiStake(address[] users, uint256[] amounts) onlyOwner public returns (bool) {

        require(contractClosed == false, "contract closed");
        require(users.length == amounts.length, "array length mismatch");

        address emptyAddr = address(0);
        uint256 amountTotal = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(users[i] != emptyAddr, "invalid address");
            amountTotal = amountTotal.add(amounts[i]);
        }
        require(token.transferFrom(msg.sender, address(this), amountTotal), "transferFrom failed");

        uint256 startTime = block.timestamp;
        for (uint256 j = 0; j < users.length; j++) {
            _stake(users[j], amounts[j], startTime);
        }

        emit MultiStake(users, amounts, startTime);

        return true;
    }

    function stake(uint256 amount) public returns (bool) {

        require(!reEntrancyMutex, "re-entrancy occurred");
        require(stakingClosed == false, "staking closed");
        require(contractClosed == false, "contract closed");
        require(block.timestamp < closingTime, "past closing time");
        require(amount > 0, "invalid amount");
        require(amount.add(singleStakeSum[msg.sender]) <= maxStakingAmountPerUser,
            "max user staking amount exceeded");
        require(amount.add(contractSingleStakeSum) <= maxStakingAmountPerContract,
            "max contract staking amount exceeded");
        
        reEntrancyMutex = true;
        require(token.transferFrom(msg.sender, address(this), amount), "transferFrom failed");

        if (!userExists(msg.sender)) {
            addUser(msg.sender);
        }
        
        _stake(msg.sender, amount, block.timestamp);
        singleStakeSum[msg.sender] = singleStakeSum[msg.sender].add(amount);
        contractSingleStakeSum = contractSingleStakeSum.add(amount);
        reEntrancyMutex = false;

        emit Stake(msg.sender, amount, block.timestamp);

        return true;
    }

    function _unstake(address user) private returns (uint256) {

        require(!reEntrancyMutex, "re-entrancy occurred");
        reEntrancyMutex = true;
        uint256 amount = calcUserStakeAndInterest(user, block.timestamp);
        require(amount > 0 && amount <= maxUnstakingAmountPerUser, "invalid unstaking amount");
        deleteUser(user);
        require(token.transfer(user, amount), "transfer failed");
        reEntrancyMutex = false;
        return amount;
    }

    function unstake() public returns (bool) {

        require(contractClosed == false, "contract closed");
        uint256 amount = _unstake(msg.sender);
        emit Unstake(msg.sender, amount);
        return true;
    }
}