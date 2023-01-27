
pragma solidity ^0.6.0;

contract LiquidityLock {


    IERC20 public uni;
    IERC20 public flap;
    uint256 public duration;
    uint256 public ratio;
    uint256 public totalLocked;
    address internal _owner;
    
    mapping(address => uint256) locked;
    mapping(address => uint256) time;

    event Locked (address indexed user, uint256 amount);
    event Unlocked (address indexed user, uint256 amount);

    constructor (IERC20 _uni, IERC20 _flap) public {
        uni = _uni;
        flap = _flap;
        duration = 1814400;
        ratio = 5000;
        _owner = msg.sender;
        
    }
    
    modifier onlyOwner() {

    require(msg.sender == _owner);
    _;
    }
    
    function setRatio(uint256 flapsxuni) public onlyOwner {

        ratio = flapsxuni;
    }
    
    function lock(uint256 amount) public {

        
        uint256 flaps = amount*ratio;
        require(flaps <= flap.balanceOf(address(this)), "This contract has run out of flapp rewards, wait for replenishment or try a different contract");
        require(uni.transferFrom(msg.sender, address(this), amount), "You need to approve UNI tokens to be transferred to this contract before locking");
        locked[msg.sender] = locked[msg.sender] + amount;
        totalLocked = totalLocked + amount;
        time[msg.sender] = now;
        flap.transfer(msg.sender, flaps);
        emit Locked(msg.sender, amount);
    }

     function unlock() public {


        require(now >= time[msg.sender] + duration, "You can't unlock yet, wait for the lock to end");
        uint256 amount = locked[msg.sender];
        require(amount > 0, "You have no tokens to unlock");
        locked[msg.sender] = locked[msg.sender] - amount;
        totalLocked = totalLocked - amount;
        uni.transfer(msg.sender, amount);
        emit Unlocked(msg.sender, amount);
    }

    function getLockedAmount(address user) public view returns (uint256) {

        return locked[user];
    }

    function getUnlockTime(address user) public view returns (uint256) {

        return (time[user] + duration);
    }

    function getMyStatus() public view returns (uint256, uint256) {

        uint256 lockedAmount = getLockedAmount(msg.sender);
        uint256 unlockTime = getUnlockTime(msg.sender);
        return (lockedAmount, unlockTime);
    }

    function getTotalLocked() public view returns (uint256) {

        return totalLocked;
    }

    
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}