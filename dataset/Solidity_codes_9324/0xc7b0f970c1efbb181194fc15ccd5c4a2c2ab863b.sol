

pragma solidity 0.6.12;

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


contract TwoWeeksNotice {

    
    struct StakeState {
        uint64 balance;
        uint64 unlockPeriod; // time it takes from requesting withdraw to being able to withdraw
        uint64 lockedUntil; // 0 if withdraw is not requested
        uint64 since;
        uint128 accumulated; // token-days staked
        uint128 accumulatedStrict; // token-days staked sans withdraw periods
    }
    
    event StakeUpdate(address indexed from, uint64 balance);
    event WithdrawRequest(address indexed from, uint64 until);
    
    mapping(address => StakeState) private _states;
    
    IERC20 private token;
    
    constructor (IERC20 _token) public {
        token = _token;
    }

    function getStakeState(address account) external view returns (uint64, uint64, uint64, uint64) {

        StakeState storage ss = _states[account];
        return (ss.balance, ss.unlockPeriod, ss.lockedUntil, ss.since);
    }
    
    function getAccumulated(address account) external view returns (uint128, uint128) {

        StakeState storage ss = _states[account];
        return (ss.accumulated, ss.accumulatedStrict);
    }

    function estimateAccumulated(address account) external view returns (uint128, uint128) {

        StakeState storage ss = _states[account];
        uint128 sum = ss.accumulated;
        uint128 sumStrict = ss.accumulatedStrict;
        if (ss.balance > 0) {
            uint256 until = block.timestamp;
            if (ss.lockedUntil > 0 && ss.lockedUntil < block.timestamp) {
                until = ss.lockedUntil;
            }
            if (until > ss.since) {
                uint128 delta = uint128( (uint256(ss.balance) * (until - ss.since))/86400 );
                sum += delta;
                if (ss.lockedUntil == 0) {
                    sumStrict += delta;
                }
            }
        }
        return (sum, sumStrict);
    }
    
    
    function updateAccumulated(StakeState storage ss) private {

        if (ss.balance > 0) {
            uint256 until = block.timestamp;
            if (ss.lockedUntil > 0 && ss.lockedUntil < block.timestamp) {
                until = ss.lockedUntil;
            }
            if (until > ss.since) {
                uint128 delta = uint128( (uint256(ss.balance) * (until - ss.since))/86400 );
                ss.accumulated += delta;
                if (ss.lockedUntil == 0) {
                    ss.accumulatedStrict += delta;
                }
            }
        }
    }

    function stake(uint64 amount, uint64 unlockPeriod) external {

        StakeState storage ss = _states[msg.sender];
        require(amount > 0, "amount must be positive");
        require(ss.balance <= amount, "cannot decrease balance");
        require(unlockPeriod <= 1000 days, "unlockPeriod cannot be higher than 1000 days");
        require(ss.unlockPeriod <= unlockPeriod, "cannot decrease unlock period");
        require(unlockPeriod >= 2 weeks, "unlock period can't be less than 2 weeks");
        
        updateAccumulated(ss);
        
        uint128 delta = amount - ss.balance;
        if (delta > 0) {
            require(token.transferFrom(msg.sender, address(this), delta), "transfer unsuccessful");
        }

        ss.balance = amount;
        ss.unlockPeriod = unlockPeriod;
        ss.lockedUntil = 0;
        ss.since = uint64(block.timestamp);
        emit StakeUpdate(msg.sender, amount);
    }
    
    function requestWithdraw() external {

         StakeState storage ss = _states[msg.sender];
         require(ss.balance > 0);
         updateAccumulated(ss);
         ss.since = uint64(block.timestamp);
         ss.lockedUntil = uint64(block.timestamp + ss.unlockPeriod);
    }

    function withdraw(address to) external {

        StakeState storage ss = _states[msg.sender];
        require(ss.balance > 0, "must have tokens to withdraw");
        require(ss.lockedUntil != 0, "unlock not requested");
        require(ss.lockedUntil < block.timestamp, "still locked");
        updateAccumulated(ss);
        uint128 balance = ss.balance;
        ss.balance = 0;
        ss.unlockPeriod = 0;
        ss.lockedUntil = 0;
        ss.since = 0;
        require(token.transfer(to, balance), "transfer unsuccessful");
        emit StakeUpdate(msg.sender, 0);
    }
}