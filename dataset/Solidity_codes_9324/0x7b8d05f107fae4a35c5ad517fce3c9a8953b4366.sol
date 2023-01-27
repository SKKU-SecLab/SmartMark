


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract MunchSAStaking is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Pool {
        uint256 remainingBalance;   // Funds available for new stakers
        uint256 attributed;         // Funds taken from balance for stakers
        uint256 paidOut;            // Rewards claimed, therefore paidOut <= attributed
        uint256 minStake;
        uint256 maxStake;
        uint stakingDuration;
        uint minPercentToCharity;   // minimum % of rewards being given to charity - 50% is stored as 50
        uint apy;                   // integer percentage - 50% is stored as 50
    }

    struct UserInfo {
        uint256 amountDeposited;
        uint256 remainingRewards;   // Amount not claimed yet
        uint256 rewardsDonated;     // Out of claimed rewards, amount sent to charity
        uint stakingStartTime;      // Timestamp when user started staking
        uint lastRewardTime;        // Last time rewards were claimed
        uint256 rewardDebt;         // Rewards to ignore in redis computation based on when user joined pool
        uint percentToCharity;      // as an int: 50% is stored as 50
    }

    IERC20 _munchToken;
    address _charityAddress;

    uint256 _accRedisTokensPerShare;
    uint256 _lastRedisTotal;
    uint256 _stakedAndFunds; // Sum of all MUNCH tokens staked or funded for pools
    uint256 _staked; // Sum of all MUNCH tokens staked - used to get redis share of a user

    Pool[] public pools;

    mapping(uint => mapping(address => UserInfo)) public userInfo;

    event Deposit(uint poolIdx, address indexed user, uint256 amount);
    event Withdraw(uint poolIdx, address indexed user, uint256 amount);

    constructor(address munchToken) {
        _munchToken = IERC20(munchToken);
        _charityAddress = address(_munchToken);
    }

    function addPool(uint stakingDurationInDays, uint256 minStake, uint maxStake, uint apy) public onlyOwner {

        pools.push(Pool({
            remainingBalance: 0,
            attributed: 0,
            paidOut: 0,
            minStake: minStake,
            maxStake: maxStake,
            stakingDuration: stakingDurationInDays * 1 days,
            minPercentToCharity: 50,
            apy: apy
        }));
    }

    function fund(uint poolIdx, uint256 amount) public onlyOwner {

        Pool storage pool = pools[poolIdx];
        _munchToken.safeTransferFrom(address(msg.sender), address(this), amount);
        pool.remainingBalance = pool.remainingBalance.add(amount);
        _stakedAndFunds = _stakedAndFunds.add(amount);
    }

    function unlockPool(uint poolIdx) public onlyOwner {

        pools[poolIdx].stakingDuration = 0;
    }

    function setMinPercentToCharity(uint poolIdx, uint minPercentToCharity) public onlyOwner {

        Pool storage pool = pools[poolIdx];
        pool.minPercentToCharity = minPercentToCharity;
    }

    function setCharityAddress(address addy) public onlyOwner {

        _charityAddress = addy;
    }

    function totalRewards(uint poolIdx, address wallet) external view returns (uint256) {

        UserInfo storage user = userInfo[poolIdx][wallet];
        Pool storage pool = pools[poolIdx];
        return user.amountDeposited.mul(pool.apy).mul(pool.stakingDuration).div(365 days).div(100);
    }

    function pending(uint poolIdx, address wallet) public view returns (uint256) {

        UserInfo storage user = userInfo[poolIdx][wallet];
        Pool storage pool = pools[poolIdx];

        uint timeSinceLastReward = block.timestamp - user.lastRewardTime;
        uint timeFromLastRewardToEnd = user.stakingStartTime + pool.stakingDuration - user.lastRewardTime;
        uint256 pendingReward = user.remainingRewards.mul(timeSinceLastReward).div(timeFromLastRewardToEnd);
        return pendingReward > user.remainingRewards ? user.remainingRewards : pendingReward;
    }

    function redisCount(uint poolIdx, address wallet) public view returns (uint256) {

        if (_accRedisTokensPerShare == 0 || _staked == 0) {
            return 0;
        }
        UserInfo storage user = userInfo[poolIdx][wallet];
        return user.amountDeposited.mul(_accRedisTokensPerShare).div(1e36).sub(user.rewardDebt);
    }

    function updateRedisCount() internal {

        uint256 munchBal = _munchToken.balanceOf(address(this));
        if (munchBal == 0 || _staked == 0) {
            return;
        }

        uint256 totalRedis = munchBal.sub(_stakedAndFunds);
        uint256 toAccountFor = totalRedis.sub(_lastRedisTotal);
        _lastRedisTotal = totalRedis;

        _accRedisTokensPerShare = _accRedisTokensPerShare.add(toAccountFor.mul(1e36).div(_staked));
    }

    function deposit(uint poolIdx, uint256 amount, uint percentToCharity) public {

        UserInfo storage user = userInfo[poolIdx][msg.sender];
        Pool storage pool = pools[poolIdx];
        require(percentToCharity >= pool.minPercentToCharity && percentToCharity <= 100, "Invalid percentage to give to charity");
        uint256 totalDeposit = user.amountDeposited.add(amount);
        require(pool.minStake <= totalDeposit && pool.maxStake >= totalDeposit, "Unauthorized amount");

        if (user.amountDeposited > 0) {
            transferMunchRewards(poolIdx); // this calls updateRedisCount()
        } else {
            updateRedisCount();
        }

        if (amount > 0) {
            uint256 newRewards = amount.mul(pool.apy).mul(pool.stakingDuration).div(365 days).div(100);
            require(pool.remainingBalance >= newRewards, "Pool is full");

            userInfo[poolIdx][msg.sender] = UserInfo({
                amountDeposited: totalDeposit,
                remainingRewards: user.remainingRewards.add(newRewards),
                rewardsDonated: user.rewardsDonated,
                lastRewardTime: block.timestamp,
                stakingStartTime: block.timestamp,
                percentToCharity: percentToCharity,
                rewardDebt: totalDeposit.mul(_accRedisTokensPerShare).div(1e36)
            });
            pool.remainingBalance = pool.remainingBalance.sub(newRewards);
            pool.attributed = pool.attributed.add(newRewards);

            _stakedAndFunds = _stakedAndFunds.add(amount);
            _staked = _staked.add(amount);

            _munchToken.safeTransferFrom(address(msg.sender), address(this), amount);

            emit Deposit(poolIdx, msg.sender, amount);
        } else {
            user.percentToCharity = percentToCharity;
        }
    }

    function withdraw(uint poolIdx) public {

        UserInfo storage user = userInfo[poolIdx][msg.sender];
        Pool storage pool = pools[poolIdx];

        require(block.timestamp - user.stakingStartTime > pool.stakingDuration, "Lock period not over");

        transferMunchRewards(poolIdx); // this calls updateRedisCount()

        _stakedAndFunds = _stakedAndFunds.sub(user.amountDeposited);
        _staked = _staked.sub(user.amountDeposited);
        user.remainingRewards = 0;
        uint256 amountToWithdraw = user.amountDeposited;
        user.amountDeposited = 0;

        _munchToken.safeTransfer(address(msg.sender), amountToWithdraw);
        emit Withdraw(poolIdx, msg.sender, amountToWithdraw);
    }

    function transferMunchRewards(uint poolIdx) public {

        UserInfo storage user = userInfo[poolIdx][msg.sender];
        Pool storage pool = pools[poolIdx];
        uint256 pendingRewards = pending(poolIdx, msg.sender);

        updateRedisCount();

        if(pendingRewards > 0) {
            uint256 redis = redisCount(poolIdx, msg.sender);
            uint256 pendingAmount = pendingRewards.add(redis);

            uint256 toCharity = pendingAmount.mul(user.percentToCharity).div(100);
            uint256 toHolder = pendingAmount.sub(toCharity);

            if (toCharity > 0) {
                _munchToken.transfer(_charityAddress, toCharity);
            }

            if (toHolder > 0) {
                _munchToken.transfer(msg.sender, toHolder);
            }

            _stakedAndFunds = _stakedAndFunds.sub(pendingRewards);
            _lastRedisTotal = _lastRedisTotal.sub(redis);
            pool.paidOut = pool.paidOut.add(pendingRewards);
            user.remainingRewards = user.remainingRewards.sub(pendingRewards);
            user.rewardsDonated = user.rewardsDonated.add(toCharity); // includes redis
            user.lastRewardTime = block.timestamp;
        }
    }

    function fundWithdraw(uint poolIdx, uint256 amount) onlyOwner public {

        Pool storage pool = pools[poolIdx];
        require(pool.remainingBalance >= amount, "Cannot withdraw more than remaining pool balance");
        updateRedisCount();
        _munchToken.transfer(msg.sender, amount);
        _stakedAndFunds = _stakedAndFunds.sub(amount);
    }

    function ethWithdraw() onlyOwner public {

        uint256 balance = address(this).balance;
        require(balance > 0, "Balance is zero.");
        payable(msg.sender).transfer(balance);
    }
}