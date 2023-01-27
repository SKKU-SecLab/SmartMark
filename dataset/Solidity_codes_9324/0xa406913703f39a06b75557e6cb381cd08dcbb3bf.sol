

pragma solidity =0.6.12;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
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

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

contract Ownable is Context, Initializable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function init(address sender) internal virtual initializer {

        _owner = sender;
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

contract MasterChefLP is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardLPDebt; // Reward debt in LP.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. VEMPs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that VEMPs distribution occurs.
        uint256 accVEMPPerShare; // Accumulated VEMPs per share, times 1e12. See below.
        uint256 accLPPerShare; // Accumulated LPs per share, times 1e12. See below.
        uint256 lastTotalLPReward; // last total rewards
        uint256 lastLPRewardBalance; // last LP rewards tokens
        uint256 totalLPReward; // total LP rewards tokens
    }

    struct UserLockInfo {
        uint256 amount;     // How many LP tokens the user has withdraw.
        uint256 lockTime; // lockTime of VEMP
    }

    IERC20 public VEMP;
    address public adminaddr;
    uint256 public VEMPPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 1;

    PoolInfo public poolInfo;
    mapping (address => UserInfo) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public totalLPStaked;
    uint256 public totalLPUsedForPurchase = 0;
    bool public withdrawStatus;
    bool public rewardEndStatus;
    uint256 public rewardEndBlock;

    uint256 public vempBurnPercent;
    uint256 public xVempHoldPercent;
    uint256 public vempLockPercent;
    uint256 public lockPeriod;
    IERC20 public xVEMP;
    uint256 public totalVempLock;
    mapping (address => UserLockInfo) public userLockInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Set(uint256 allocPoint, bool overwrite);
    event RewardEndStatus(bool rewardStatus, uint256 rewardEndBlock);
    event RewardPerBlock(uint256 oldRewardPerBlock, uint256 newRewardPerBlock);
    event AccessLPToken(address indexed user, uint256 amount, uint256 totalLPUsedForPurchase);
    event AddLPTokensInPool(uint256 amount, uint256 totalLPUsedForPurchase);

    constructor() public {}

    function initialize(
        IERC20 _VEMP,
        IERC20 _lpToken,
        address _xvemp,
        address _adminaddr,
        uint256 _VEMPPerBlock,
        uint256 _startBlock,
        uint256 _vempBurnPercent,
        uint256 _xVempHoldPercent,
        uint256 _lockPeriod,
        uint256 _vempLockPercent
    ) public initializer {

        require(address(_VEMP) != address(0), "Invalid VEMP address");
        require(address(_lpToken) != address(0), "Invalid lpToken address");
        require(address(_adminaddr) != address(0), "Invalid admin address");
        require(_xvemp != address(0), "Invalid xvemp address");

        Ownable.init(_adminaddr);
        VEMP = _VEMP;
        adminaddr = _adminaddr;
        xVEMP = IERC20(_xvemp);
        VEMPPerBlock = _VEMPPerBlock;
        startBlock = _startBlock;
        withdrawStatus = false;
        rewardEndStatus = false;
        rewardEndBlock = 0;

        vempBurnPercent = _vempBurnPercent;
        xVempHoldPercent = _xVempHoldPercent;
        lockPeriod = _lockPeriod;
        vempLockPercent = _vempLockPercent;
        
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(100);
        poolInfo.lpToken = _lpToken;
        poolInfo.allocPoint = 100;
        poolInfo.lastRewardBlock = lastRewardBlock;
        poolInfo.accVEMPPerShare = 0;
        poolInfo.accLPPerShare = 0;
        poolInfo.lastTotalLPReward = 0;
        poolInfo.lastLPRewardBalance = 0;
        poolInfo.totalLPReward = 0;
    }

    function updateVempBurnPercent(uint256 _vempBurnPercent) public onlyOwner {

        vempBurnPercent = _vempBurnPercent;
    }

    function updatexVempHoldPercent(uint256 _xVempHoldPercent) public onlyOwner {

        xVempHoldPercent = _xVempHoldPercent;
    }

    function updateVempLockPercent(uint256 _vempLockPercent) public onlyOwner {

        vempLockPercent = _vempLockPercent;
    }

    function updateLockPeriod(uint256 _lockPeriod) public onlyOwner {

        lockPeriod = _lockPeriod;
    }

    function lock(uint256 _amount) public {

        UserLockInfo storage user = userLockInfo[msg.sender];
        
        VEMP.transferFrom(msg.sender, address(this), _amount);
        user.amount = user.amount.add(_amount);
        totalVempLock = totalVempLock.add(_amount);
        if(user.lockTime <= 0)
        user.lockTime = block.timestamp;
    }
    
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {

        if (_to >= _from) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else {
            return _from.sub(_to);
        }
    }

    function pendingVEMP(address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[_user];
        uint256 accVEMPPerShare = pool.accVEMPPerShare;
        uint256 rewardBlockNumber = block.number;
        if(rewardEndStatus != false) {
           rewardBlockNumber = rewardEndBlock;
        }
        uint256 lpSupply = totalLPStaked;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, rewardBlockNumber);
            uint256 VEMPReward = multiplier.mul(VEMPPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accVEMPPerShare = accVEMPPerShare.add(VEMPReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accVEMPPerShare).div(1e12).sub(user.rewardDebt);
    }
    
    function pendingLP(address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[_user];
        uint256 accLPPerShare = pool.accLPPerShare;
        uint256 lpSupply = totalLPStaked;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 rewardBalance = pool.lpToken.balanceOf(address(this)).sub(totalLPStaked.sub(totalLPUsedForPurchase));
            uint256 _totalReward = rewardBalance.sub(pool.lastLPRewardBalance);
            accLPPerShare = accLPPerShare.add(_totalReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accLPPerShare).div(1e12).sub(user.rewardLPDebt);
    }

    function updatePool() internal {

        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 rewardBlockNumber = block.number;
        if(rewardEndStatus != false) {
           rewardBlockNumber = rewardEndBlock;
        }
        uint256 rewardBalance = pool.lpToken.balanceOf(address(this)).sub(totalLPStaked.sub(totalLPUsedForPurchase));
        uint256 _totalReward = pool.totalLPReward.add(rewardBalance.sub(pool.lastLPRewardBalance));
        pool.lastLPRewardBalance = rewardBalance;
        pool.totalLPReward = _totalReward;
        
        uint256 lpSupply = totalLPStaked;
        if (lpSupply == 0) {
            pool.lastRewardBlock = rewardBlockNumber;
            pool.accLPPerShare = 0;
            pool.lastTotalLPReward = 0;
            user.rewardLPDebt = 0;
            pool.lastLPRewardBalance = 0;
            pool.totalLPReward = 0;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, rewardBlockNumber);
        uint256 VEMPReward = multiplier.mul(VEMPPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accVEMPPerShare = pool.accVEMPPerShare.add(VEMPReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = rewardBlockNumber;
        
        uint256 reward = _totalReward.sub(pool.lastTotalLPReward);
        pool.accLPPerShare = pool.accLPPerShare.add(reward.mul(1e12).div(lpSupply));
        pool.lastTotalLPReward = _totalReward;
    }

    function deposit(address _user, uint256 _amount) public {

        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[_user];
        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accVEMPPerShare).div(1e12).sub(user.rewardDebt);
            safeVEMPTransfer(_user, pending);
            
            uint256 LPReward = user.amount.mul(pool.accLPPerShare).div(1e12).sub(user.rewardLPDebt);
            pool.lpToken.safeTransfer(_user, LPReward);
            pool.lastLPRewardBalance = pool.lpToken.balanceOf(address(this)).sub(totalLPStaked.sub(totalLPUsedForPurchase));
        }
        pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        totalLPStaked = totalLPStaked.add(_amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accVEMPPerShare).div(1e12);
        user.rewardLPDebt = user.amount.mul(pool.accLPPerShare).div(1e12);

        emit Deposit(_user, _amount);
    }

    function withdraw(uint256 _amount, bool _directStatus) public {

        require(withdrawStatus != true, "Withdraw not allowed");
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accVEMPPerShare).div(1e12).sub(user.rewardDebt);
            safeVEMPTransfer(msg.sender, pending);
            
            uint256 LPReward = user.amount.mul(pool.accLPPerShare).div(1e12).sub(user.rewardLPDebt);
            pool.lpToken.safeTransfer(msg.sender, LPReward);
            pool.lastLPRewardBalance = pool.lpToken.balanceOf(address(this)).sub(totalLPStaked.sub(totalLPUsedForPurchase));
        }
        UserLockInfo storage userLock = userLockInfo[msg.sender];

        if(_directStatus) {
            uint256 vempAmount = VEMP.balanceOf(msg.sender);
            uint256 burnAmount = _amount.mul(vempBurnPercent).div(1000);
            if(userLock.amount > 0 && userLock.lockTime.add(lockPeriod) <= block.timestamp) {
                burnAmount = 0;
                VEMP.transfer(msg.sender, userLock.amount.sub(burnAmount));
            } else if(userLock.amount > 0 && userLock.lockTime.add(lockPeriod.div(2)) <= block.timestamp) {
                burnAmount = burnAmount.div(2);
                require(burnAmount <= userLock.amount, "Insufficient VEMP Burn Amount");
                VEMP.transfer(address(0x000000000000000000000000000000000000dEaD), burnAmount);
                VEMP.transfer(msg.sender, userLock.amount.sub(burnAmount));
            } else if(userLock.amount == 0) {
                require(burnAmount <= vempAmount, "Insufficient VEMP Burn Amount");
                VEMP.transferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), burnAmount);
            }            
        } else {
            uint256 xVempAmount = xVEMP.balanceOf(msg.sender);
            require(_amount.mul(xVempHoldPercent).div(1000) <= xVempAmount, "Insufficient xVEMP Hold Amount");
            require(_amount.mul(vempLockPercent).div(1000) <= userLock.amount, "Insufficient VEMP Locked");
            require(userLock.lockTime.add(lockPeriod) <= block.timestamp, "Lock period not complete.");
            VEMP.transfer(msg.sender, userLock.amount);
        }
        totalVempLock = totalVempLock.sub(userLock.amount);
        userLock.amount = 0;
        userLock.lockTime = 0;

        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accVEMPPerShare).div(1e12);
        user.rewardLPDebt = user.amount.mul(pool.accLPPerShare).div(1e12);
        totalLPStaked = totalLPStaked.sub(_amount);
        pool.lpToken.safeTransfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() public {

        require(withdrawStatus != true, "Withdraw not allowed");
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        pool.lpToken.safeTransfer(msg.sender, user.amount);
        totalLPStaked = totalLPStaked.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLPDebt = 0;
        emit EmergencyWithdraw(msg.sender, user.amount);
    }
    
    function safeVEMPTransfer(address _to, uint256 _amount) internal {

        uint256 VEMPBal = VEMP.balanceOf(address(this)).sub(totalVempLock);
        if (_amount > VEMPBal) {
            VEMP.transfer(_to, VEMPBal);
        } else {
            VEMP.transfer(_to, _amount);
        }
    }
    
    function claimLP() public {

        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        
        uint256 LPReward = user.amount.mul(pool.accLPPerShare).div(1e12).sub(user.rewardLPDebt);
        pool.lpToken.safeTransfer(msg.sender, LPReward);
        pool.lastLPRewardBalance = pool.lpToken.balanceOf(address(this)).sub(totalLPStaked.sub(totalLPUsedForPurchase));
        
        user.rewardLPDebt = user.amount.mul(pool.accLPPerShare).div(1e12);
    }
    
    function accessLPTokens(address _to, uint256 _amount) public {

        require(_to != address(0), "Invalid to address");
        require(msg.sender == adminaddr, "sender must be admin address");
        require(totalLPStaked.sub(totalLPUsedForPurchase) >= _amount, "Amount must be less than staked LP amount");
        PoolInfo storage pool = poolInfo;
        uint256 LPBal = pool.lpToken.balanceOf(address(this));
        if (_amount > LPBal) {
            pool.lpToken.safeTransfer(_to, LPBal);
            totalLPUsedForPurchase = totalLPUsedForPurchase.add(LPBal);
        } else {
            pool.lpToken.safeTransfer(_to, _amount);
            totalLPUsedForPurchase = totalLPUsedForPurchase.add(_amount);
        }
        emit AccessLPToken(_to, _amount, totalLPUsedForPurchase);
    }

     function addLPTokensInPool(uint256 _amount) public {

        require(_amount > 0, "LP amount must be greater than 0");
        require(msg.sender == adminaddr, "sender must be admin address");
        require(_amount.add(totalLPStaked.sub(totalLPUsedForPurchase)) <= totalLPStaked, "Amount must be less than staked LP amount");
        PoolInfo storage pool = poolInfo;
        totalLPUsedForPurchase = totalLPUsedForPurchase.sub(_amount);
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        emit AddLPTokensInPool(_amount, totalLPUsedForPurchase);
    }

    function updateRewardPerBlock(uint256 _newRewardPerBlock) public onlyOwner {

        updatePool();
        emit RewardPerBlock(VEMPPerBlock, _newRewardPerBlock);
        VEMPPerBlock = _newRewardPerBlock;
    }

    function updateWithdrawStatus(bool _status) public onlyOwner {

        require(withdrawStatus != _status, "Already same status");
        withdrawStatus = _status;
    }

    function updateRewardEndStatus(bool _status, uint256 _rewardEndBlock) public onlyOwner {

        require(rewardEndStatus != _status, "Already same status");
        rewardEndBlock = _rewardEndBlock;
        rewardEndStatus = _status;
        emit RewardEndStatus(_status, _rewardEndBlock);
    }

    function admin(address _adminaddr) public {

        require(_adminaddr != address(0), "Invalid admin address");
        require(msg.sender == adminaddr, "admin: wut?");
        adminaddr = _adminaddr;
    }

    function emergencyWithdrawRewardTokens(address _to, uint256 _amount) public {

        require(_to != address(0), "Invalid to address");
        require(msg.sender == adminaddr, "sender must be admin address");
        safeVEMPTransfer(_to, _amount);
    }
}