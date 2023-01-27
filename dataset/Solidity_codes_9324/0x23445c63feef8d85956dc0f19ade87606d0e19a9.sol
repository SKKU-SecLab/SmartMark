



pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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




pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}




pragma solidity ^0.8.0;


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}




pragma solidity ^0.8.0;



abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}




pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;



library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.8.3;





contract CHNStaking is OwnableUpgradeable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingTokenReward;
    }
    struct PoolInfo {
        IERC20 stakeToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accCHNPerShare;
        uint256 totalAmountStake;
    }

    event Add(address indexed stakToken, uint256 indexed allocPoint);
    event Set(uint256 indexed pid, uint256 indexed allocPoint);
    event Stake(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 reward);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event ClaimRewardFromVault(address indexed userAddress, uint256 indexed pid);
    
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
    
    IERC20 public rewardToken;
    uint256 public rewardPerBlock;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) public poolTokens;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public bonusEndBlock;
    uint256 public BONUS_MULTIPLIER;
    address public rewardVault;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (uint256 => mapping (address => mapping (uint32 => Checkpoint))) public checkpoints;

    mapping (uint256 => mapping (address => uint32)) public numCheckpoints;

    modifier validatePoolByPid(uint256 _pid) {

        require(_pid < poolInfo.length, "Pool does not exist");
        _;
    }

    function initialize(
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _multiplier,
        address _rewardVault
    ) public initializer {

        require(_rewardVault != address(0) && address(_rewardToken) != address(0), "Zero address validation");
        require(_startBlock < _bonusEndBlock, "Start block lower than bonus end block");
        require(_rewardPerBlock < _rewardToken.totalSupply(), "Reward per block bigger than reward token total supply");
        require(BONUS_MULTIPLIER < 100, "Bonus multipler bigger than 100x reward bonus");
        __Ownable_init();
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        BONUS_MULTIPLIER = _multiplier;
        rewardVault = _rewardVault;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function getStakingAmount(uint256 pid, address user) public view returns (uint256) {

        UserInfo memory info = userInfo[pid][user];
        return info.amount;
    }

    function add(
        uint256 _allocPoint,
        IERC20 _stakeToken
    ) public onlyOwner {

        require(!poolTokens[address(_stakeToken)], "Stake token already exist");
        massUpdatePools();
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolTokens[address(_stakeToken)] = true;
        poolInfo.push(
            PoolInfo({
                stakeToken: _stakeToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accCHNPerShare: 0,
                totalAmountStake: 0
            })
        );
        emit Add(address(_stakeToken), _allocPoint);
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint
    ) public onlyOwner validatePoolByPid(_pid) {

        massUpdatePools();
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        emit Set(_pid, _allocPoint);
    }

    function setRewardPerblock(uint256 speed)
        public
        onlyOwner {

            rewardPerBlock = speed;
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        require(_from >= startBlock, "from block number bigger than start block");
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _to.sub(bonusEndBlock)
                );
        }
    }

    function pendingReward(uint256 _pid, address _user)
        external
        view
        validatePoolByPid(_pid)
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCHNPerShare = pool.accCHNPerShare;
        uint256 supply = pool.totalAmountStake;
        if (block.number > pool.lastRewardBlock && supply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward =
                multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accCHNPerShare = accCHNPerShare.add(
                reward.mul(1e12).div(supply)
            );
        }
        return user.amount.mul(accCHNPerShare).div(1e12).add(user.pendingTokenReward).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public validatePoolByPid(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 supply = pool.totalAmountStake;
        if (supply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward =
            multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        pool.accCHNPerShare = pool.accCHNPerShare.add(
            reward.mul(1e12).div(supply)
        );
        pool.lastRewardBlock = block.number;
    }

    function _moveDelegates(uint256 _pid, address dstRep, uint256 amount, bool stake) internal {

        if (amount > 0) {
            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[_pid][dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[_pid][dstRep][dstRepNum - 1].votes : 0;
                if (stake) {
                    uint256 dstRepNew = dstRepOld.add(amount);
                    _writeCheckpoint(_pid, dstRep, dstRepNum, dstRepOld, dstRepNew);
                } else {
                    uint256 dstRepNew = dstRepOld.sub(amount);
                    _writeCheckpoint(_pid, dstRep, dstRepNum, dstRepOld, dstRepNew);
                }
            }
        }
    }

    function stake(uint256 _pid, uint256 _amount) public validatePoolByPid(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accCHNPerShare).div(1e12).sub(
                    user.rewardDebt
                );
            user.pendingTokenReward = user.pendingTokenReward.add(pending);
        }
        pool.totalAmountStake = pool.totalAmountStake.add(_amount);
        pool.stakeToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accCHNPerShare).div(1e12);

        _moveDelegates(_pid, msg.sender, _amount, true);
        emit Stake(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public validatePoolByPid(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accCHNPerShare).div(1e12).sub(
                user.rewardDebt
            );
        user.pendingTokenReward = user.pendingTokenReward + pending;
        user.amount = user.amount.sub(_amount);
        pool.totalAmountStake = pool.totalAmountStake.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accCHNPerShare).div(1e12);
        pool.stakeToken.safeTransfer(address(msg.sender), _amount);

        _moveDelegates(_pid, msg.sender, _amount, false);
        emit Withdraw(msg.sender, _pid, _amount, 0);
    }

    function emergencyWithdraw(uint256 _pid) public validatePoolByPid(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 userAmount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.pendingTokenReward = 0;
        pool.totalAmountStake = pool.totalAmountStake.sub(userAmount);
        pool.stakeToken.safeTransfer(address(msg.sender), userAmount);
        _moveDelegates(_pid, msg.sender, userAmount, false);
        emit EmergencyWithdraw(msg.sender, _pid, userAmount);
    }

    function claimRewardFromVault(address userAddress, uint256 pid) public validatePoolByPid(pid) returns (uint256) {

        require(msg.sender == rewardVault, "Ownable: only reward vault");
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][userAddress];
        updatePool(pid);
        uint256 pending =
            user.amount.mul(pool.accCHNPerShare).div(1e12).sub(
                user.rewardDebt
            );
        pending = pending + user.pendingTokenReward;
        user.pendingTokenReward = 0;
        user.rewardDebt = user.amount.mul(pool.accCHNPerShare).div(1e12);
        emit ClaimRewardFromVault(userAddress, pid);
        return pending;
    }

    function getPriorVotes(uint256 _pid, address account, uint blockNumber) public view returns (uint256) {

        require(blockNumber < block.number, "Comp::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[_pid][account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[_pid][account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[_pid][account][nCheckpoints - 1].votes;
        }

        if (checkpoints[_pid][account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[_pid][account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[_pid][account][lower].votes;
    }

    function _writeCheckpoint(uint256 _pid, address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {

      uint32 blockNumber = safe32(block.number, "Comp::_writeCheckpoint: block number exceeds 32 bits");

      if (nCheckpoints > 0 && checkpoints[_pid][delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[_pid][delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[_pid][delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[_pid][delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
    
    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }
}