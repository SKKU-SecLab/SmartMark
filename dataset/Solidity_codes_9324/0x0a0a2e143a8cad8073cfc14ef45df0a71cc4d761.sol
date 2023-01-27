
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


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
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface ILiquidityMining {

    struct UnlockInfo {
        uint256 block;
        uint256 quota;
    }
    function getAllUnlocks() external view returns (UnlockInfo[] memory);

    function unlocksTotalQuotation() external view returns(uint256);


    struct PoolInfo {
        address token;
        uint256 accRewardPerShare;
        uint256 allocPoint;
        uint256 lastRewardBlock;
    }
    function getAllPools() external view returns (PoolInfo[] memory);

    function totalAllocPoint() external returns(uint256);


    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function claim() external;

    function getPendingReward(uint256 _pid, address _user)
    external view
    returns(uint256 total, uint256 available);


    function rewardToken() external view returns(address);

    function reservoir() external view returns(address);

    function rewardPerBlock() external view returns(uint256);

    function startBlock() external view returns(uint256);

    function endBlock() external view returns(uint256);


    function rewards(address) external view returns(uint256);

    function claimedRewards(address) external view returns(uint256);

    function poolPidByAddress(address) external view returns(uint256);

    function isTokenAdded(address _token) external view returns (bool);

    function calcUnlocked(uint256 reward) external view returns(uint256 claimable);


    struct UserPoolInfo {
        uint256 amount;
        uint256 accruedReward;
    }
    function userPoolInfo(uint256, address) external view returns(UserPoolInfo memory);

}// MIT

pragma solidity 0.7.6;


interface IMigrator {

    function migrate(IERC20 token) external returns (IERC20);

}// MIT

pragma solidity 0.7.6;


contract LiquidityMining is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserPoolInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 accruedReward; // Reward accrued.
    }

    struct PoolInfo {
        IERC20 token; // Address of token contract.
        uint256 accRewardPerShare; // Accumulated reward token per share, times 1e12. See below.
        uint256 allocPoint; // How many allocation points assigned to this pool.
        uint256 lastRewardBlock; // Last block number that reward token distribution occurs.
    }

    struct UnlockInfo {
        uint256 block;
        uint256 quota;
    }

    IERC20 public rewardToken;
    address public reservoir;
    uint256 public rewardPerBlock;

    IMigrator public migrator;

    UnlockInfo[] public unlocks;
    uint256 public unlocksTotalQuotation;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public claimedRewards;

    PoolInfo[] public poolInfo;
    mapping(address => uint256) public poolPidByAddress;
    mapping(uint256 => mapping(address => UserPoolInfo)) public userPoolInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public endBlock;

    event TokenAdded(
        address indexed token,
        uint256 indexed pid,
        uint256 allocPoint
    );
    event Claimed(address indexed user, uint256 amount);
    event Deposited(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdrawn(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event TokenMigrated(
        address indexed oldtoken,
        address indexed newToken,
        uint256 indexed pid
    );
    event RewardPerBlockSet(uint256 rewardPerBlock);
    event TokenSet(
        address indexed token,
        uint256 indexed pid,
        uint256 allocPoint
    );
    event MigratorSet(address indexed migrator);
    event Withdrawn(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IERC20 _rewardToken,
        address _reservoir,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _endBlock
    ) {
        rewardToken = _rewardToken;
        reservoir = _reservoir;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;

        emit RewardPerBlockSet(_rewardPerBlock);
    }

    function add(
        uint256 _allocPoint,
        IERC20 _token,
        bool _withUpdate
    ) external onlyOwner {

        require(!isTokenAdded(_token), "add: token already added");

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        uint256 pid = poolInfo.length;
        poolInfo.push(
            PoolInfo({
                token: _token,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0
            })
        );
        poolPidByAddress[address(_token)] = pid;

        emit TokenAdded(address(_token), pid, _allocPoint);
    }

    function accrueReward(uint256 _pid) internal {

        UserPoolInfo memory userPool = userPoolInfo[_pid][msg.sender];
        if (userPool.amount == 0) {
            return;
        }
        rewards[msg.sender] = rewards[msg.sender].add(
            calcReward(poolInfo[_pid], userPool).sub(userPool.accruedReward)
        );
    }

    function calcReward(PoolInfo memory pool, UserPoolInfo memory userPool) internal returns(uint256){

        return userPool.amount.mul(pool.accRewardPerShare).div(1e12);
    }

    function getPendingReward(uint256 _pid, address _user)
        external view
        returns(uint256 total, uint256 unlocked) {


        PoolInfo memory pool = poolInfo[_pid];

        uint256 currentBlock = block.number;
        if (currentBlock < startBlock) {
            return (0, 0);
        }
        if (currentBlock > endBlock) {
            currentBlock = endBlock;
        }

        uint256 lpSupply = pool.token.balanceOf(address(this));
        if (lpSupply == 0) {
            return (0, 0);
        }
        uint256 blockLasted = currentBlock.sub(pool.lastRewardBlock);
        uint256 reward = blockLasted.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        uint256 accRewardPerShare = pool.accRewardPerShare.add(
            reward.mul(1e12).div(lpSupply)
        );

        UserPoolInfo memory userPool = userPoolInfo[_pid][_user];
        total = userPool.amount
            .mul(accRewardPerShare)
            .div(1e12)
            .sub(userPool.accruedReward);

        unlocked = calcUnlocked(total);
    }

    function calcUnlocked(uint256 reward) public view returns(uint256 claimable) {

        uint256 i;
        for (i = 0; i < unlocks.length; ++i) {
            if (block.number < unlocks[i].block) {
                continue;
            }
            claimable = claimable.add(
                reward.mul(unlocks[i].quota)
                .div(unlocksTotalQuotation)
            );
        }
    }

    function claim() external{

        uint256 i;
        for (i = 0; i < poolInfo.length; ++i) {
            updatePool(i);
            accrueReward(i);
            UserPoolInfo storage userPool = userPoolInfo[i][msg.sender];
            userPool.accruedReward = calcReward(poolInfo[i], userPool);
        }
        uint256 unlocked = calcUnlocked(rewards[msg.sender]).sub(claimedRewards[msg.sender]);
        if (unlocked > 0) {
            _safeRewardTransfer(msg.sender, unlocked);
        }
        claimedRewards[msg.sender] = claimedRewards[msg.sender].add(unlocked);
        emit Claimed(msg.sender, unlocked);
    }

    function deposit(uint256 _pid, uint256 _amount) external {

        require(block.number <= endBlock, "LP mining has ended.");
        updatePool(_pid);
        accrueReward(_pid);

        UserPoolInfo storage userPool = userPoolInfo[_pid][msg.sender];

        if (_amount > 0) {
            poolInfo[_pid].token.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );

            userPool.amount = userPool.amount.add(_amount);
        }

        userPool.accruedReward = calcReward(poolInfo[_pid], userPoolInfo[_pid][msg.sender]);
        emit Deposited(msg.sender, _pid, _amount);
    }

    function withdrawEmergency(uint256 _pid) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage userPool = userPoolInfo[_pid][msg.sender];
        pool.token.safeTransfer(address(msg.sender), userPool.amount);
        emit EmergencyWithdrawn(msg.sender, _pid, userPool.amount);
        userPool.amount = 0;
        userPool.accruedReward = 0;
    }

    function reallocatePool(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;

        emit TokenSet(address(poolInfo[_pid].token), _pid, _allocPoint);
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {

        rewardPerBlock = _rewardPerBlock;

        emit RewardPerBlockSet(_rewardPerBlock);
    }

    function setUnlocks(uint256[] calldata _blocks, uint256[] calldata _quotas) external onlyOwner {

        require(_blocks.length == _quotas.length, "Should be same length");
        for (uint256 i = 0; i < _blocks.length; ++i) {
            unlocks.push(UnlockInfo(_blocks[i], _quotas[i]));
            unlocksTotalQuotation = unlocksTotalQuotation.add(_quotas[i]);
        }
    }

    function withdraw(uint256 _pid, uint256 _amount) external {

        require(userPoolInfo[_pid][msg.sender].amount >= _amount, "withdraw: not enough amount");
        updatePool(_pid);
        accrueReward(_pid);
        UserPoolInfo storage userPool = userPoolInfo[_pid][msg.sender];
        if (_amount > 0) {
            userPool.amount = userPool.amount.sub(_amount);
            poolInfo[_pid].token.safeTransfer(address(msg.sender), _amount);
        }

        userPool.accruedReward = calcReward(poolInfo[_pid], userPoolInfo[_pid][msg.sender]);
        emit Withdrawn(msg.sender, _pid, _amount);
    }

    function poolCount() external view returns (uint256) {

        return poolInfo.length;
    }

    function unlockCount() external view returns (uint256) {

        return unlocks.length;
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 currentBlock = block.number;
        if (currentBlock > endBlock) {
            currentBlock = endBlock;
        }
        if (currentBlock <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.token.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = currentBlock;
            return;
        }

        uint256 blockLasted = currentBlock.sub(pool.lastRewardBlock);
        uint256 reward =
            blockLasted.mul(rewardPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        rewardToken.transferFrom(reservoir, address(this), reward);
        pool.accRewardPerShare = pool.accRewardPerShare.add(
            reward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = currentBlock;
    }

    function isTokenAdded(IERC20 _token) public view returns (bool) {

        uint256 pid = poolPidByAddress[address(_token)];
        return
            poolInfo.length > pid &&
            address(poolInfo[pid].token) == address(_token);
    }

    function _safeRewardTransfer(address _to, uint256 _amount) internal {

        uint256 balance = rewardToken.balanceOf(address(this));
        if (_amount > balance) {
            rewardToken.transfer(_to, balance);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }

    function setMigrator(IMigrator _migrator) external onlyOwner {

        migrator = _migrator;
        emit MigratorSet(address(_migrator));
    }

    function migrate(uint256 _pid) external {

        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 token = pool.token;
        uint256 bal = token.balanceOf(address(this));
        token.safeApprove(address(migrator), bal);
        IERC20 newToken = migrator.migrate(token);
        require(bal == newToken.balanceOf(address(this)), "migrate: bad");
        pool.token = newToken;

        delete poolPidByAddress[address(token)];
        poolPidByAddress[address(newToken)] = _pid;

        emit TokenMigrated(address(token), address(newToken), _pid);
    }

    function getAllPools() external view returns (PoolInfo[] memory) {

        return poolInfo;
    }

    function getAllUnlocks() external view returns (UnlockInfo[] memory) {

        return unlocks;
    }
}