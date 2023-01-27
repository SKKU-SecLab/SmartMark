pragma solidity ^0.7.0;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


interface IMasterChef {

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that SUSHIs distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHIs per share, times 1e12.
    }
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function poolInfo(uint256 _pid) external view returns (PoolInfo memory);

    function pendingSushi(uint256 _pid, address _user) external view returns (uint256);

    function updatePool(uint256 _pid) external;

    function sushiPerBlock() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);

}// MIT
pragma solidity ^0.7.0;

interface IVault {

    
    struct Lock {
        address token;
        address receiver;
        uint48 startTime;
        uint16 vestingDurationInDays;
        uint16 cliffDurationInDays;
        uint256 amount;
        uint256 amountClaimed;
        uint256 votingPower;
    }

    struct LockBalance {
        uint256 id;
        uint256 claimableAmount;
        Lock lock;
    }

    struct TokenBalance {
        uint256 totalAmount;
        uint256 claimableAmount;
        uint256 claimedAmount;
        uint256 votingPower;
    }

    function lockTokens(address token, address locker, address receiver, uint48 startTime, uint256 amount, uint16 lockDurationInDays, uint16 cliffDurationInDays, bool grantVotingPower) external;

    function lockTokensWithPermit(address token, address locker, address receiver, uint48 startTime, uint256 amount, uint16 lockDurationInDays, uint16 cliffDurationInDays, bool grantVotingPower, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function claimUnlockedTokenAmounts(uint256[] memory lockIds, uint256[] memory amounts) external;

    function claimAllUnlockedTokens(uint256[] memory lockIds) external;

    function tokenLocks(uint256 lockId) external view returns(Lock memory);

    function allActiveLockIds() external view returns(uint256[] memory);

    function allActiveLocks() external view returns(Lock[] memory);

    function allActiveLockBalances() external view returns(LockBalance[] memory);

    function activeLockIds(address receiver) external view returns(uint256[] memory);

    function allLocks(address receiver) external view returns(Lock[] memory);

    function activeLocks(address receiver) external view returns(Lock[] memory);

    function activeLockBalances(address receiver) external view returns(LockBalance[] memory);

    function totalTokenBalance(address token) external view returns(TokenBalance memory balance);

    function tokenBalance(address token, address receiver) external view returns(TokenBalance memory balance);

    function lockBalance(uint256 lockId) external view returns (LockBalance memory);

    function claimableBalance(uint256 lockId) external view returns (uint256);

    function extendLock(uint256 lockId, uint16 vestingDaysToAdd, uint16 cliffDaysToAdd) external;

}// MIT
pragma solidity ^0.7.0;

interface ILockManager {

    struct LockedStake {
        uint256 amount;
        uint256 votingPower;
    }

    function getAmountStaked(address staker, address stakedToken) external view returns (uint256);

    function getStake(address staker, address stakedToken) external view returns (LockedStake memory);

    function calculateVotingPower(address token, uint256 amount) external view returns (uint256);

    function grantVotingPower(address receiver, address token, uint256 tokenAmount) external returns (uint256 votingPowerGranted);

    function removeVotingPower(address receiver, address token, uint256 tokenAmount) external returns (uint256 votingPowerRemoved);

}// MIT
pragma solidity ^0.7.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
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

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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
}// MIT
pragma solidity ^0.7.0;

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
}// MIT
pragma solidity ^0.7.0;


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
}// MIT

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity ^0.7.0;


contract RewardsManager is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public owner;

    struct UserInfo {
        uint256 amount;          // How many tokens the user has provided.
        uint256 rewardTokenDebt; // Reward debt for reward token. See explanation below.
        uint256 sushiRewardDebt; // Reward debt for Sushi rewards. See explanation below.
    }

    struct PoolInfo {
        IERC20 token;               // Address of token contract.
        uint256 allocPoint;         // How many allocation points assigned to this pool. Reward tokens to distribute per block.
        uint256 lastRewardBlock;    // Last block number where reward tokens were distributed.
        uint256 accRewardsPerShare; // Accumulated reward tokens per share, times 1e12. See below.
        uint32 vestingPercent;      // Percentage of rewards that vest (measured in bips: 500,000 bips = 50% of rewards)
        uint16 vestingPeriod;       // Vesting period in days for vesting rewards
        uint16 vestingCliff;        // Vesting cliff in days for vesting rewards
        uint256 totalStaked;        // Total amount of token staked via Rewards Manager
        bool vpForDeposit;          // Do users get voting power for deposits of this token?
        bool vpForVesting;          // Do users get voting power for vesting balances?
    }

    IERC20 public rewardToken;

    IERC20 public sushiToken;

    IMasterChef public masterChef;

    IVault public vault;

    ILockManager public lockManager;

    uint256 public rewardTokensPerBlock;

    PoolInfo[] public poolInfo;
    
    mapping (address => uint256) public sushiPools;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    
    uint256 public totalAllocPoint;

    uint256 public startBlock;

    uint256 public endBlock;

    modifier onlyOwner {

        require(msg.sender == owner, "not owner");
        _;
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);

    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event PoolAdded(uint256 indexed pid, address indexed token, uint256 allocPoints, uint256 totalAllocPoints, uint256 rewardStartBlock, uint256 sushiPid, bool vpForDeposit, bool vpForVesting);
    
    event PoolUpdated(uint256 indexed pid, uint256 oldAllocPoints, uint256 newAllocPoints, uint256 newTotalAllocPoints);

    event ChangedOwner(address indexed oldOwner, address indexed newOwner);

    event ChangedRewardTokensPerBlock(uint256 indexed oldRewardTokensPerBlock, uint256 indexed newRewardTokensPerBlock);

    event SetRewardsStartBlock(uint256 indexed startBlock);

    event ChangedRewardsEndBlock(uint256 indexed oldEndBlock, uint256 indexed newEndBlock);

    event ChangedAddress(string indexed addressType, address indexed oldAddress, address indexed newAddress);

    constructor(
        address _owner, 
        address _lockManager,
        address _vault,
        address _rewardToken,
        address _sushiToken,
        address _masterChef,
        uint256 _startBlock,
        uint256 _rewardTokensPerBlock
    ) {
        owner = _owner;
        emit ChangedOwner(address(0), _owner);

        lockManager = ILockManager(_lockManager);
        emit ChangedAddress("LOCK_MANAGER", address(0), _lockManager);

        vault = IVault(_vault);
        emit ChangedAddress("VAULT", address(0), _vault);

        rewardToken = IERC20(_rewardToken);
        emit ChangedAddress("REWARD_TOKEN", address(0), _rewardToken);

        sushiToken = IERC20(_sushiToken);
        emit ChangedAddress("SUSHI_TOKEN", address(0), _sushiToken);

        masterChef = IMasterChef(_masterChef);
        emit ChangedAddress("MASTER_CHEF", address(0), _masterChef);

        startBlock = _startBlock == 0 ? block.number : _startBlock;
        emit SetRewardsStartBlock(startBlock);

        rewardTokensPerBlock = _rewardTokensPerBlock;
        emit ChangedRewardTokensPerBlock(0, _rewardTokensPerBlock);

        rewardToken.safeIncreaseAllowance(address(vault), uint256(-1));
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(
        uint256 allocPoint, 
        address token,
        uint32 vestingPercent,
        uint16 vestingPeriod,
        uint16 vestingCliff,
        bool withUpdate,
        uint256 sushiPid,
        bool vpForDeposit,
        bool vpForVesting
    ) external onlyOwner {

        if (withUpdate) {
            massUpdatePools();
        }
        uint256 rewardStartBlock = block.number > startBlock ? block.number : startBlock;
        if (totalAllocPoint == 0) {
            _setRewardsEndBlock();
        }
        totalAllocPoint = totalAllocPoint.add(allocPoint);
        poolInfo.push(PoolInfo({
            token: IERC20(token),
            allocPoint: allocPoint,
            lastRewardBlock: rewardStartBlock,
            accRewardsPerShare: 0,
            vestingPercent: vestingPercent,
            vestingPeriod: vestingPeriod,
            vestingCliff: vestingCliff,
            totalStaked: 0,
            vpForDeposit: vpForDeposit,
            vpForVesting: vpForVesting
        }));
        if (sushiPid != uint256(0)) {
            sushiPools[token] = sushiPid;
            IERC20(token).safeIncreaseAllowance(address(masterChef), uint256(-1));
        }
        IERC20(token).safeIncreaseAllowance(address(vault), uint256(-1));
        emit PoolAdded(poolInfo.length - 1, token, allocPoint, totalAllocPoint, rewardStartBlock, sushiPid, vpForDeposit, vpForVesting);
    }

    function set(
        uint256 pid, 
        uint256 allocPoint, 
        bool withUpdate
    ) external onlyOwner {

        if (withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[pid].allocPoint).add(allocPoint);
        emit PoolUpdated(pid, poolInfo[pid].allocPoint, allocPoint, totalAllocPoint);
        poolInfo[pid].allocPoint = allocPoint;
    }

    function rewardsActive() public view returns (bool) {

        return block.number >= startBlock && block.number <= endBlock && totalAllocPoint > 0 ? true : false;
    }

    function getMultiplier(uint256 from, uint256 to) public view returns (uint256) {

        uint256 toBlock = to > endBlock ? endBlock : to;
        return toBlock > from ? toBlock.sub(from) : 0;
    }

    function pendingRewardTokens(uint256 pid, address account) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][account];
        uint256 accRewardsPerShare = pool.accRewardsPerShare;
        uint256 tokenSupply = pool.totalStaked;
        if (block.number > pool.lastRewardBlock && tokenSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 totalReward = multiplier.mul(rewardTokensPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accRewardsPerShare = accRewardsPerShare.add(totalReward.mul(1e12).div(tokenSupply));
        }

        uint256 accumulatedRewards = user.amount.mul(accRewardsPerShare).div(1e12);
        
        if (accumulatedRewards < user.rewardTokenDebt) {
            return 0;
        }

        return accumulatedRewards.sub(user.rewardTokenDebt);
    }

    function pendingSushi(uint256 pid, address account) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][account];
        uint256 sushiPid = sushiPools[address(pool.token)];
        if (sushiPid == uint256(0)) {
            return 0;
        }
        IMasterChef.PoolInfo memory sushiPool = masterChef.poolInfo(sushiPid);
        uint256 sushiPerBlock = masterChef.sushiPerBlock();
        uint256 totalSushiAllocPoint = masterChef.totalAllocPoint();
        uint256 accSushiPerShare = sushiPool.accSushiPerShare;
        uint256 lpSupply = sushiPool.lpToken.balanceOf(address(masterChef));
        if (block.number > sushiPool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = masterChef.getMultiplier(sushiPool.lastRewardBlock, block.number);
            uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(sushiPool.allocPoint).div(totalSushiAllocPoint);
            accSushiPerShare = accSushiPerShare.add(sushiReward.mul(1e12).div(lpSupply));
        }
        
        uint256 accumulatedSushi = user.amount.mul(accSushiPerShare).div(1e12);
        
        if (accumulatedSushi < user.sushiRewardDebt) {
            return 0;
        }

        return accumulatedSushi.sub(user.sushiRewardDebt);
        
    }

    function massUpdatePools() public {

        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 pid) public {

        PoolInfo storage pool = poolInfo[pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 tokenSupply = pool.totalStaked;
        if (tokenSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 totalReward = multiplier.mul(rewardTokensPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accRewardsPerShare = pool.accRewardsPerShare.add(totalReward.mul(1e12).div(tokenSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 pid, uint256 amount) external nonReentrant {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        _deposit(pid, amount, pool, user);
    }

    function depositWithPermit(
        uint256 pid, 
        uint256 amount,
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external nonReentrant {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        pool.token.permit(msg.sender, address(this), amount, deadline, v, r, s);
        _deposit(pid, amount, pool, user);
    }

    function withdraw(uint256 pid, uint256 amount) external nonReentrant {

        require(amount > 0, "RM::withdraw: amount must be > 0");
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        _withdraw(pid, amount, pool, user);
    }

    function emergencyWithdraw(uint256 pid) external nonReentrant {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        if (user.amount > 0) {
            uint256 sushiPid = sushiPools[address(pool.token)];
            if (sushiPid != uint256(0)) {
                masterChef.withdraw(sushiPid, user.amount);
            }

            if (pool.vpForDeposit) {
                lockManager.removeVotingPower(msg.sender, address(pool.token), user.amount);
            }

            pool.totalStaked = pool.totalStaked.sub(user.amount);
            pool.token.safeTransfer(msg.sender, user.amount);

            emit EmergencyWithdraw(msg.sender, pid, user.amount);

            user.amount = 0;
            user.rewardTokenDebt = 0;
            user.sushiRewardDebt = 0;
        }
    }

    function tokenAllow(
        address[] memory tokensToApprove, 
        uint256[] memory approvalAmounts, 
        address spender
    ) external onlyOwner {

        require(tokensToApprove.length == approvalAmounts.length, "RM::tokenAllow: not same length");
        for(uint i = 0; i < tokensToApprove.length; i++) {
            IERC20 token = IERC20(tokensToApprove[i]);
            if (token.allowance(address(this), spender) != uint256(-1)) {
                token.safeApprove(spender, approvalAmounts[i]);
            }
        }
    }

    function rescueTokens(
        address[] calldata tokens, 
        uint256[] calldata amounts, 
        address receiver,
        bool updateRewardsEndBlock
    ) external onlyOwner {

        require(tokens.length == amounts.length, "RM::rescueTokens: not same length");
        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 withdrawalAmount;
            uint256 tokenBalance = token.balanceOf(address(this));
            uint256 tokenAllowance = token.allowance(address(this), receiver);
            if (amounts[i] == 0) {
                if (tokenBalance > tokenAllowance) {
                    withdrawalAmount = tokenAllowance;
                } else {
                    withdrawalAmount = tokenBalance;
                }
            } else {
                require(tokenBalance >= amounts[i], "RM::rescueTokens: contract balance too low");
                require(tokenAllowance >= amounts[i], "RM::rescueTokens: increase token allowance");
                withdrawalAmount = amounts[i];
            }
            token.safeTransferFrom(address(this), receiver, withdrawalAmount);
        }

        if (updateRewardsEndBlock) {
            _setRewardsEndBlock();
        }
    }

    function setRewardsPerBlock(uint256 newRewardTokensPerBlock) external onlyOwner {

        emit ChangedRewardTokensPerBlock(rewardTokensPerBlock, newRewardTokensPerBlock);
        rewardTokensPerBlock = newRewardTokensPerBlock;
        _setRewardsEndBlock();
    }

    function setRewardToken(address newToken, uint256 newRewardTokensPerBlock) external onlyOwner {

        emit ChangedAddress("REWARD_TOKEN", address(rewardToken), newToken);
        rewardToken = IERC20(newToken);
        rewardTokensPerBlock = newRewardTokensPerBlock;
        _setRewardsEndBlock();
    }

    function setSushiToken(address newToken) external onlyOwner {

        emit ChangedAddress("SUSHI_TOKEN", address(sushiToken), newToken);
        sushiToken = IERC20(newToken);
    }

    function setMasterChef(address newAddress) external onlyOwner {

        emit ChangedAddress("MASTER_CHEF", address(masterChef), newAddress);
        masterChef = IMasterChef(newAddress);
    }
        
    function setVault(address newAddress) external onlyOwner {

        emit ChangedAddress("VAULT", address(vault), newAddress);
        vault = IVault(newAddress);
    }

    function setLockManager(address newAddress) external onlyOwner {

        emit ChangedAddress("LOCK_MANAGER", address(lockManager), newAddress);
        lockManager = ILockManager(newAddress);
    }

    function addRewardsBalance(uint256 amount) external onlyOwner {

        rewardToken.safeTransferFrom(msg.sender, address(this), amount);
        _setRewardsEndBlock();
    }

    function resetRewardsEndBlock() external onlyOwner {

        _setRewardsEndBlock();
    }

    function changeOwner(address newOwner) external onlyOwner {

        require(newOwner != address(0) && newOwner != address(this), "RM::changeOwner: not valid address");
        emit ChangedOwner(owner, newOwner);
        owner = newOwner;
    }

    function _deposit(
        uint256 pid, 
        uint256 amount, 
        PoolInfo storage pool, 
        UserInfo storage user
    ) internal {

        updatePool(pid);

        uint256 sushiPid = sushiPools[address(pool.token)];
        uint256 pendingSushiTokens = 0;

        if (user.amount > 0) {
            uint256 pendingRewards = user.amount.mul(pool.accRewardsPerShare).div(1e12).sub(user.rewardTokenDebt);

            if (pendingRewards > 0) {
                _distributeRewards(msg.sender, pendingRewards, pool.vestingPercent, pool.vestingPeriod, pool.vestingCliff, pool.vpForVesting);
            }

            if (sushiPid != uint256(0)) {
                masterChef.updatePool(sushiPid);
                pendingSushiTokens = user.amount.mul(masterChef.poolInfo(sushiPid).accSushiPerShare).div(1e12).sub(user.sushiRewardDebt);
            }
        }
       
        pool.token.safeTransferFrom(msg.sender, address(this), amount);
        pool.totalStaked = pool.totalStaked.add(amount);
        user.amount = user.amount.add(amount);
        user.rewardTokenDebt = user.amount.mul(pool.accRewardsPerShare).div(1e12);

        if (sushiPid != uint256(0)) {
            masterChef.updatePool(sushiPid);
            user.sushiRewardDebt = user.amount.mul(masterChef.poolInfo(sushiPid).accSushiPerShare).div(1e12);
            masterChef.deposit(sushiPid, amount);
        }

        if (amount > 0 && pool.vpForDeposit) {
            lockManager.grantVotingPower(msg.sender, address(pool.token), amount);
        }

        if (pendingSushiTokens > 0) {
            _safeSushiTransfer(msg.sender, pendingSushiTokens);
        }

        emit Deposit(msg.sender, pid, amount);
    }

    function _withdraw(
        uint256 pid, 
        uint256 amount,
        PoolInfo storage pool, 
        UserInfo storage user
    ) internal {

        require(user.amount >= amount, "RM::_withdraw: amount > user balance");

        updatePool(pid);

        uint256 sushiPid = sushiPools[address(pool.token)];

        if (sushiPid != uint256(0)) {
            masterChef.updatePool(sushiPid);
            uint256 pendingSushiTokens = user.amount.mul(masterChef.poolInfo(sushiPid).accSushiPerShare).div(1e12).sub(user.sushiRewardDebt);
            masterChef.withdraw(sushiPid, amount);
            user.sushiRewardDebt = user.amount.sub(amount).mul(masterChef.poolInfo(sushiPid).accSushiPerShare).div(1e12);
            if (pendingSushiTokens > 0) {
                _safeSushiTransfer(msg.sender, pendingSushiTokens);
            }
        }

        uint256 pendingRewards = user.amount.mul(pool.accRewardsPerShare).div(1e12).sub(user.rewardTokenDebt);
        user.amount = user.amount.sub(amount);
        user.rewardTokenDebt = user.amount.mul(pool.accRewardsPerShare).div(1e12);

        if (pendingRewards > 0) {
            _distributeRewards(msg.sender, pendingRewards, pool.vestingPercent, pool.vestingPeriod, pool.vestingCliff, pool.vpForVesting);
        }
        
        if (pool.vpForDeposit) {
            lockManager.removeVotingPower(msg.sender, address(pool.token), amount);
        }

        pool.totalStaked = pool.totalStaked.sub(amount);
        pool.token.safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, pid, amount);
    }

    function _distributeRewards(
        address account, 
        uint256 amount, 
        uint32 vestingPercent, 
        uint16 vestingPeriod, 
        uint16 vestingCliff,
        bool vestingVotingPower
    ) internal {

        uint256 rewardAmount = amount > rewardToken.balanceOf(address(this)) ? rewardToken.balanceOf(address(this)) : amount;
        uint256 vestingRewards = rewardAmount.mul(vestingPercent).div(1000000);
        vault.lockTokens(address(rewardToken), address(this), account, 0, vestingRewards, vestingPeriod, vestingCliff, vestingVotingPower);
        _safeRewardsTransfer(msg.sender, rewardAmount.sub(vestingRewards));
    }

    function _safeRewardsTransfer(address to, uint256 amount) internal {

        uint256 rewardTokenBalance = rewardToken.balanceOf(address(this));
        if (amount > rewardTokenBalance) {
            rewardToken.safeTransfer(to, rewardTokenBalance);
        } else {
            rewardToken.safeTransfer(to, amount);
        }
    }

    function _safeSushiTransfer(address to, uint256 amount) internal {

        uint256 sushiBalance = sushiToken.balanceOf(address(this));
        if (amount > sushiBalance) {
            sushiToken.safeTransfer(to, sushiBalance);
        } else {
            sushiToken.safeTransfer(to, amount);
        }
    }

    function _setRewardsEndBlock() internal {

        if(rewardTokensPerBlock > 0) {
            uint256 rewardFromBlock = block.number >= startBlock ? block.number : startBlock;
            uint256 newEndBlock = rewardFromBlock.add(rewardToken.balanceOf(address(this)).div(rewardTokensPerBlock));
            if(newEndBlock > rewardFromBlock && newEndBlock != endBlock) {
                emit ChangedRewardsEndBlock(endBlock, newEndBlock);
                endBlock = newEndBlock;
            }
        }
    }
}