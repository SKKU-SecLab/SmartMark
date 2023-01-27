


pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

contract OwnableData {

    address public owner;
    address public pendingOwner;
}

abstract contract Ownable is OwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        owner = 0x4e5b3043FEB9f939448e2F791a66C4EA65A315a8;
        emit OwnershipTransferred(address(0), owner);
    }

    function transferOwnership(address newOwner, bool direct, bool renounce) public onlyOwner {
        if (direct) {

            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract YELStaking is Ownable {

    using SafeERC20 for IERC20;
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 remainingYelTokenReward;  // YEL Tokens that weren't distributed for user per pool.
    }
    struct PoolInfo {
        IERC20 stakingToken; // Contract address of staked token
        uint256 stakingTokenTotalAmount; //Total amount of deposited tokens
        uint256 accYelPerShare; // Accumulated YEL per share, times 1e12. See below.
        uint32 lastRewardTime; // Last timestamp number that YEL distribution occurs.
        uint16 allocPoint; // How many allocation points assigned to this pool. YEL to distribute per second.
    }
    
    IERC20 immutable public yel; // The YEL token
    
    uint256 public yelPerSecond; // YEL tokens vested per second.
    
    PoolInfo[] public poolInfo; // Info of each pool.
    
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // Info of each user that stakes tokens.
    
    uint256 public totalAllocPoint = 0; // Total allocation points. Must be the sum of all allocation points in all pools.
    
    uint32 immutable public startTime; // The timestamp when YEL farming starts.
    
    uint32 public endTime; // Time on which the reward calculation should end

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IERC20 _yel,
        uint256 _yelPerSecond,
        uint32 _startTime
    ) {
        yel = _yel;

        yelPerSecond = _yelPerSecond;
        startTime = _startTime;
        endTime = _startTime + 7 days;
    }
    
    function changeEndTime(uint32 addSeconds) external onlyOwner {

        endTime += addSeconds;
    }
    
    function setYelPerSecond(uint256 _yelPerSecond,  bool _withUpdate) external onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        yelPerSecond= _yelPerSecond;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(
        uint16 _allocPoint,
        IERC20 _stakingToken,
        bool _withUpdate
    ) external onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTime =
            block.timestamp > startTime ? block.timestamp : startTime;
        totalAllocPoint +=_allocPoint;
        poolInfo.push(
            PoolInfo({
                stakingToken: _stakingToken,
                stakingTokenTotalAmount: 0,
                allocPoint: _allocPoint,
                lastRewardTime: uint32(lastRewardTime),
                accYelPerShare: 0
            })
        );
    }

    function set(
        uint256 _pid,
        uint16 _allocPoint,
        bool _withUpdate
    ) external onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        _from = _from > startTime ? _from : startTime;
        if (_from > endTime || _to < startTime) {
            return 0;
        }
        if (_to > endTime) {
            return endTime - _from;
        }
        return _to - _from;
    }

    function pendingYel(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accYelPerShare = pool.accYelPerShare;
       
        if (block.timestamp > pool.lastRewardTime && pool.stakingTokenTotalAmount != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardTime, block.timestamp);
            uint256 yelReward =
                multiplier * yelPerSecond * pool.allocPoint / totalAllocPoint;
            accYelPerShare += yelReward * 1e12 / pool.stakingTokenTotalAmount;
        }
        return user.amount * accYelPerShare / 1e12 - user.rewardDebt + user.remainingYelTokenReward;
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }

        if (pool.stakingTokenTotalAmount == 0) {
            pool.lastRewardTime = uint32(block.timestamp);
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
        uint256 yelReward =
            multiplier * yelPerSecond * pool.allocPoint / totalAllocPoint;
        pool.accYelPerShare += yelReward * 1e12 / pool.stakingTokenTotalAmount;
        pool.lastRewardTime = uint32(block.timestamp);
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending =
                user.amount * pool.accYelPerShare / 1e12 - user.rewardDebt + user.remainingYelTokenReward;
            user.remainingYelTokenReward = safeRewardTransfer(msg.sender, pending);
        }
        pool.stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount += _amount;
        pool.stakingTokenTotalAmount += _amount;
        user.rewardDebt = user.amount * pool.accYelPerShare / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "YELStaking: you do not have enough tokens to complete this operation");
        updatePool(_pid);
        uint256 pending =
            user.amount * pool.accYelPerShare / 1e12 - user.rewardDebt + user.remainingYelTokenReward;
        user.remainingYelTokenReward = safeRewardTransfer(msg.sender, pending);
        user.amount -= _amount;
        pool.stakingTokenTotalAmount -= _amount;
        user.rewardDebt = user.amount * pool.accYelPerShare / 1e12;
        pool.stakingToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }
    
    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 userAmount = user.amount;
        pool.stakingTokenTotalAmount -= userAmount;
        delete userInfo[_pid][msg.sender];
        pool.stakingToken.safeTransfer(address(msg.sender), userAmount);
        emit EmergencyWithdraw(msg.sender, _pid, userAmount);
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal returns(uint256) {

        uint256 yelTokenBalance = yel.balanceOf(address(this));
        if (yelTokenBalance == 0) { //save some gas fee
            return _amount;
        }
        if (_amount > yelTokenBalance) { //save some gas fee
            yel.safeTransfer(_to, yelTokenBalance);
            return _amount - yelTokenBalance;
        }
        yel.safeTransfer(_to, _amount);
        return 0;
    }
}