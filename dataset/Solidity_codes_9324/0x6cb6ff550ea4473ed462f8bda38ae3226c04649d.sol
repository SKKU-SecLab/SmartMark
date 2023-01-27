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
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}pragma solidity 0.5.15;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initalOwner) internal {
        _owner = initalOwner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Only owner can call");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Owner should not be 0 address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity 0.5.15;




contract BellaStaking is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 constant NUM_TYPES = 4;

    struct UserInfo {
        uint256 amount;     // How many btokens the user has provided.
        uint256 effectiveAmount; // amount*boost
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 earnedBella; // unclaimed bella
    }

    struct ClaimingBella {
        uint256 amount;
        uint256 unlockTime;
    }

    struct PoolInfo {
        IERC20 underlyingToken;   // Address of underlying token.
        uint256 allocPoint;       // How many allocation points assigned to this pool.
        uint256 lastRewardTime;  // Last block number that BELLAs distribution occurs.
        uint256 accBellaPerShare; // Accumulated BELLAs per share, times 1e12. See below.
        uint256 totalEffectiveAmount; // Sum of user's amount*boost
    }

    IERC20 public bella;

    PoolInfo[] public poolInfo;

    mapping (uint256 => uint256[3]) public boostInfo;  

    mapping (uint256 => mapping (address => UserInfo[NUM_TYPES])) public userInfos;

    mapping (address => ClaimingBella[]) public claimingBellas;

    uint256 public totalAllocPoint = 0;
    uint256 public startTime;
    uint256 public currentUnlockCycle;
    uint256 public bellaPerSecond;
    uint256 public unlockEndTimestamp;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    modifier validPool(uint256 _pid) {

        require(_pid < poolInfo.length, "invalid pool id");
        _;
    }

    constructor(
        IERC20 _bella,
        uint256 _startTime,
        address governance
    ) public Ownable(governance) {
        bella = _bella;
        startTime = _startTime;
    }

    function poolLength() public view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _underlyingToken, uint256[3] memory boost, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }

        for (uint256 i=0; i<3; i++) {
            require((boost[i]>=100 && boost[i]<=200), "invalid boost");
        }

        uint256 lastRewardTime = now > startTime ? now : startTime;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        boostInfo[poolLength()] = boost;

        poolInfo.push(PoolInfo({
            underlyingToken: _underlyingToken,
            allocPoint: _allocPoint,
            lastRewardTime: lastRewardTime,
            accBellaPerShare: 0,
            totalEffectiveAmount: 0
        }));

    }

    function set(uint256 _pid, uint256 _allocPoint) public validPool(_pid) onlyOwner {

        massUpdatePools();
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function lock(uint256 amount, uint256 nextUnlockCycle) external onlyOwner {

        massUpdatePools();

        currentUnlockCycle = nextUnlockCycle * 1 days;
        unlockEndTimestamp = now.add(currentUnlockCycle);
        bellaPerSecond = bella.balanceOf(address(this)).add(amount).div(currentUnlockCycle);
            
        require(
            bella.transferFrom(msg.sender, address(this), amount),
            "Additional bella transfer failed"
        );
    }

    function earnedBellaAllPool(address _user) external view returns  (uint256) {

        uint256 sum = 0;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            sum = sum.add(earnedBellaAll(i, _user));
        }
        return sum;
    }

    function earnedBellaAll(uint256 _pid, address _user) public view validPool(_pid) returns  (uint256) {

        uint256 sum = 0;
        for (uint256 i = 0; i < NUM_TYPES; i++) {
            sum = sum.add(earnedBella(_pid, _user, i));
        }
        return sum;
    }

    function earnedBella(uint256 _pid, address _user, uint256 savingType) public view validPool(_pid) returns (uint256) {

        require(savingType < NUM_TYPES, "invalid savingType");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfos[_pid][_user][savingType];
        uint256 accBellaPerShare = pool.accBellaPerShare;
        if (now > pool.lastRewardTime && pool.totalEffectiveAmount != 0 && pool.lastRewardTime != unlockEndTimestamp) {
            uint256 delta = now > unlockEndTimestamp ? unlockEndTimestamp.sub(pool.lastRewardTime) : now.sub(pool.lastRewardTime);
            uint256 bellaReward = bellaPerSecond.mul(delta).mul(pool.allocPoint).div(totalAllocPoint);
            accBellaPerShare = accBellaPerShare.add(bellaReward.mul(1e12).div(pool.totalEffectiveAmount));
        }
        return user.effectiveAmount.mul(accBellaPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public validPool(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        if (now <= pool.lastRewardTime || unlockEndTimestamp == pool.lastRewardTime) {
            return;
        }
        if (pool.totalEffectiveAmount == 0) {
            pool.lastRewardTime = now;
            return;
        }
        uint256 accBellaPerShare = pool.accBellaPerShare;

        if (now > unlockEndTimestamp) {
            uint256 delta = unlockEndTimestamp.sub(pool.lastRewardTime);
            uint256 bellaReward = bellaPerSecond.mul(delta).mul(pool.allocPoint).div(totalAllocPoint);
            pool.accBellaPerShare = accBellaPerShare.add(bellaReward.mul(1e12).div(pool.totalEffectiveAmount));

            pool.lastRewardTime = unlockEndTimestamp;
        } else {
            uint256 delta = now.sub(pool.lastRewardTime);
            uint256 bellaReward = bellaPerSecond.mul(delta).mul(pool.allocPoint).div(totalAllocPoint);
            pool.accBellaPerShare = accBellaPerShare.add(bellaReward.mul(1e12).div(pool.totalEffectiveAmount));

            pool.lastRewardTime = now;
        }

    }

    function deposit(uint256 _pid, uint256 _amount, uint256 savingType) public validPool(_pid) nonReentrant {

        require(savingType < NUM_TYPES, "invalid savingType");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfos[_pid][msg.sender][savingType];
        updatePool(_pid);
        if (user.effectiveAmount > 0) {
            uint256 pending = user.effectiveAmount.mul(pool.accBellaPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                user.earnedBella = user.earnedBella.add(pending);
            }
        }
        if(_amount > 0) {
            pool.underlyingToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            uint256 effectiveAmount = toEffectiveAmount(_pid, _amount, savingType);
            user.effectiveAmount = user.effectiveAmount.add(effectiveAmount);
            pool.totalEffectiveAmount = pool.totalEffectiveAmount.add(effectiveAmount);
        }
        user.rewardDebt = user.effectiveAmount.mul(pool.accBellaPerShare).div(1e12); /// 初始的奖励为0
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount, uint256 savingType) public validPool(_pid) nonReentrant {

        require(savingType < NUM_TYPES, "invalid savingType");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfos[_pid][msg.sender][savingType];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.effectiveAmount.mul(pool.accBellaPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            user.earnedBella = user.earnedBella.add(pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            uint256 effectiveAmount = toEffectiveAmount(_pid, _amount, savingType);

            pool.totalEffectiveAmount = pool.totalEffectiveAmount.sub(effectiveAmount);
            user.effectiveAmount = toEffectiveAmount(_pid, user.amount, savingType);

            pool.underlyingToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.effectiveAmount.mul(pool.accBellaPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function withdrawAll(uint256 _pid) public validPool(_pid) {

        for (uint256 i=0; i<NUM_TYPES; i++) {
            uint256 amount = userInfos[_pid][msg.sender][i].amount;
            if (amount != 0) {
                withdraw(_pid, amount, i);
            }
        }
    }

    function emergencyWithdraw(uint256 _pid, uint256 savingType) public validPool(_pid) nonReentrant {

        require(savingType < NUM_TYPES, "invalid savingType");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfos[_pid][msg.sender][savingType];
        uint256 amount = user.amount;

        pool.totalEffectiveAmount = pool.totalEffectiveAmount.sub(user.effectiveAmount);
        user.amount = 0;
        user.effectiveAmount = 0;
        user.rewardDebt = 0;
        user.earnedBella = 0;

        pool.underlyingToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);

    }

    function claimBella(uint256 _pid, uint256 savingType) public {

        require(savingType < NUM_TYPES, "invalid savingType");
        UserInfo storage user = userInfos[_pid][msg.sender][savingType];

        updatePool(_pid);
        PoolInfo memory pool = poolInfo[_pid];

        uint256 pending = user.effectiveAmount.mul(pool.accBellaPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            user.earnedBella = user.earnedBella.add(pending);
        }
        user.rewardDebt = user.effectiveAmount.mul(pool.accBellaPerShare).div(1e12);

        uint256 delay = getDelayFromType(savingType);

        if (delay == 0) {
            uint256 amount = user.earnedBella;
            user.earnedBella = 0;
            safeBellaTransfer(msg.sender, amount);
        } else {
            uint256 amount = user.earnedBella;
            user.earnedBella = 0;
            ClaimingBella[] storage claimingBella = claimingBellas[msg.sender];
            claimingBella.push(ClaimingBella({amount: amount, unlockTime: now.add(delay * 1 days)}));       
        }
    }

    function claimAllBella(uint256 _pid) public validPool(_pid) {

        for (uint256 i=0; i<NUM_TYPES; i++) {
            claimBella(_pid, i);
        }
    }

    function collectBella() public {

        uint256 sum = 0;
        ClaimingBella[] storage claimingBella = claimingBellas[msg.sender];
        for (uint256 i = 0; i < claimingBella.length; i++) {
            ClaimingBella storage claim = claimingBella[i];
            if (claimingBella[i].amount !=0 && claimingBella[i].unlockTime <= now) {
                sum = sum.add(claim.amount);
                delete claimingBella[i];
            }
        }
        safeBellaTransfer(msg.sender, sum);

        if (claimingBella.length > 15) {
            uint256 zeros = 0;
            for (uint256 i=0; i < claimingBella.length; i++) {
                if (claimingBella[i].amount == 0) {
                    zeros++;
                }
            }
            if (zeros < 5)
                return;

            uint256 i = 0;
            while (i < claimingBella.length) {
                if (claimingBella[i].amount == 0) {
                    claimingBella[i].amount = claimingBella[claimingBella.length-1].amount;
                    claimingBella[i].unlockTime = claimingBella[claimingBella.length-1].unlockTime;
                    claimingBella.pop();
                } else {
                    i++;
                }
            }         
        }
    }

    function getBtokenStaked(uint256 _pid, address user) external view validPool(_pid) returns (uint256) {

        uint256 sum = 0;
        for (uint256 i=0; i<NUM_TYPES; i++) {
           sum = sum.add(userInfos[_pid][user][i].amount);
        }
        return sum;
    }

    function collectiableBella() external view returns (uint256) {

        uint256 sum = 0;
        ClaimingBella[] memory claimingBella = claimingBellas[msg.sender];
        for (uint256 i = 0; i < claimingBella.length; i++) {
            ClaimingBella memory claim = claimingBella[i];
            if (claim.amount !=0 && claim.unlockTime <= now) {
                sum = sum.add(claim.amount);
            }
        }
        return sum;
    }

    function delayedBella() external view returns (uint256) {

        uint256 sum = 0;
        ClaimingBella[] memory claimingBella = claimingBellas[msg.sender];
        for (uint256 i = 0; i < claimingBella.length; i++) {
            ClaimingBella memory claim = claimingBella[i];
            if (claim.amount !=0 && claim.unlockTime > now) {
                sum = sum.add(claim.amount);
            }
        }
        return sum;
    }

    function toEffectiveAmount(uint256 pid, uint256 amount, uint256 savingType) internal view returns (uint256) {


        if (savingType == 0) {
            return amount;
        } else if (savingType == 1) {
            return amount * boostInfo[pid][0] / 100;
        } else if (savingType == 2) {
            return amount * boostInfo[pid][1] / 100;
        } else if (savingType == 3) {
            return amount * boostInfo[pid][2] / 100;
        } else {
            revert("toEffectiveAmount: invalid savingType");
        }
    }

    function getDelayFromType(uint256 savingType) internal pure returns (uint256) {

        if (savingType == 0) {
            return 0;
        } else if (savingType == 1) {
            return 7;
        } else if (savingType == 2) {
            return 15;
        } else if (savingType == 3) {
            return 30;
        } else {
            revert("getDelayFromType: invalid savingType");
        }
    }

    function safeBellaTransfer(address _to, uint256 _amount) internal {

        uint256 bellaBal = bella.balanceOf(address(this));
        if (_amount > bellaBal) {
            bella.transfer(_to, bellaBal);
        } else {
            bella.transfer(_to, _amount);
        }
    }

}