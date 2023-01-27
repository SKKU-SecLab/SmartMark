



pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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


pragma solidity ^0.6.0;




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


pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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


pragma solidity 0.6.12;



interface IMigrator {

    function migrate(IERC20 token, uint8 poolType) external returns (IERC20);

}


pragma solidity 0.6.12;

contract Checkpoints {

    mapping (address => uint96) internal balances;

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    event CheckpointBalanceChanged(address indexed delegate, uint previousBalance, uint newBalance);

    constructor() public {

    }

    function balanceOf(address account) external view returns (uint) {

        return balances[account];
    }

    function getCurrentVotes(address account) external view returns (uint96) {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {

        require(blockNumber < block.number, "Checkpoints::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _writeBalance(address account, uint96 balance) internal {

        uint32 srcRepNum = numCheckpoints[account];
        uint96 srcRepOld = srcRepNum > 0 ? checkpoints[account][srcRepNum - 1].votes : 0;
        uint96 srcRepNew = safe96(balance, "Checkpoints::_writeBalance: vote amount overflow");
        _writeCheckpoint(account, srcRepNum, srcRepOld, srcRepNew);
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {

      uint32 blockNumber = safe32(block.number, "Checkpoints::_writeCheckpoint: block number exceeds 32 bits");

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit CheckpointBalanceChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }
}


pragma solidity 0.6.12;









contract LPMining is Ownable, Checkpoints {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. CVPs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that CVPs distribution occurs.
        uint256 accCvpPerShare;   // Accumulated CVPs per share, times 1e12. See below.
        bool votesEnabled;        // Pool enabled to write votes
        uint8 poolType;           // Pool type (1 For Uniswap, 2 for Balancer)
    }

    IERC20 public cvp;
    address public reservoir;
    uint256 public cvpPerBlock;
    IMigrator public migrator;

    PoolInfo[] public poolInfo;
    mapping(address => uint256) public poolPidByAddress;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event AddLpToken(address indexed lpToken, uint256 indexed pid, uint256 allocPoint);
    event SetLpToken(address indexed lpToken, uint256 indexed pid, uint256 allocPoint);
    event SetMigrator(address indexed migrator);
    event SetCvpPerBlock(uint256 cvpPerBlock);
    event MigrateLpToken(address indexed oldLpToken, address indexed newLpToken, uint256 indexed pid);

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event CheckpointPoolVotes(address indexed user, uint256 indexed pid, uint256 votes, uint256 price);
    event CheckpointTotalVotes(address indexed user, uint256 votes);

    constructor(
        IERC20 _cvp,
        address _reservoir,
        uint256 _cvpPerBlock,
        uint256 _startBlock
    ) public {
        cvp = _cvp;
        reservoir = _reservoir;
        cvpPerBlock = _cvpPerBlock;
        startBlock = _startBlock;

        emit SetCvpPerBlock(_cvpPerBlock);
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, uint8 _poolType, bool _votesEnabled, bool _withUpdate) public onlyOwner {

        require(!isLpTokenAdded(_lpToken), "add: Lp token already added");

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        uint256 pid = poolInfo.length;
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accCvpPerShare: 0,
            votesEnabled: _votesEnabled,
            poolType: _poolType
        }));
        poolPidByAddress[address(_lpToken)] = pid;

        emit AddLpToken(address(_lpToken), pid, _allocPoint);
    }

    function set(uint256 _pid, uint256 _allocPoint, uint8 _poolType, bool _votesEnabled, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].votesEnabled = _votesEnabled;
        poolInfo[_pid].poolType = _poolType;

        emit SetLpToken(address(poolInfo[_pid].lpToken), _pid, _allocPoint);
    }

    function setMigrator(IMigrator _migrator) public onlyOwner {

        migrator = _migrator;

        emit SetMigrator(address(_migrator));
    }

    function setCvpPerBlock(uint256 _cvpPerBlock) public onlyOwner {

        cvpPerBlock = _cvpPerBlock;

        emit SetCvpPerBlock(_cvpPerBlock);
    }

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken, pool.poolType);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;

        delete poolPidByAddress[address(lpToken)];
        poolPidByAddress[address(newLpToken)] = _pid;

        emit MigrateLpToken(address(lpToken), address(newLpToken), _pid);
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        return _to.sub(_from);
    }

    function pendingCvp(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCvpPerShare = pool.accCvpPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cvpReward = multiplier.mul(cvpPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accCvpPerShare = accCvpPerShare.add(cvpReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCvpPerShare).div(1e12).sub(user.rewardDebt);
    }

    function isLpTokenAdded(IERC20 _lpToken) public view returns (bool) {

        uint256 pid = poolPidByAddress[address(_lpToken)];
        return poolInfo.length > pid && address(poolInfo[pid].lpToken) == address(_lpToken);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 cvpReward = multiplier.mul(cvpPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        cvp.transferFrom(reservoir, address(this), cvpReward);
        pool.accCvpPerShare = pool.accCvpPerShare.add(cvpReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCvpPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeCvpTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCvpPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);

        checkpointVotes(msg.sender);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCvpPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeCvpTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCvpPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);

        checkpointVotes(msg.sender);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;

        checkpointVotes(msg.sender);
    }

    function checkpointVotes(address _user) public {

        uint256 length = poolInfo.length;

        uint256 totalVotesBalance = 0;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];

            uint256 userLpTokenBalance = userInfo[pid][_user].amount;
            if (userLpTokenBalance == 0 || !pool.votesEnabled) {
                continue;
            }
            uint256 lpTokenTotalSupply = pool.lpToken.totalSupply();
            if (lpTokenTotalSupply == 0) {
                continue;
            }

            uint256 lpCvpBalance = cvp.balanceOf(address(pool.lpToken));
            uint256 lpCvpPrice = lpCvpBalance.mul(1e12).div(lpTokenTotalSupply);
            uint256 lpVotesBalance = userLpTokenBalance.mul(lpCvpPrice).div(1e12);

            totalVotesBalance = totalVotesBalance.add(lpVotesBalance);
            emit CheckpointPoolVotes(_user, pid, lpVotesBalance, lpCvpPrice);
        }

        emit CheckpointTotalVotes(_user, totalVotesBalance);

        _writeBalance(_user, safe96(totalVotesBalance, "LPMining::checkpointVotes: Amount overflow"));
    }

    function safeCvpTransfer(address _to, uint256 _amount) internal {

        uint256 cvpBal = cvp.balanceOf(address(this));
        if (_amount > cvpBal) {
            cvp.transfer(_to, cvpBal);
        } else {
            cvp.transfer(_to, _amount);
        }
    }
}