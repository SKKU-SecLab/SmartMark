

pragma solidity ^0.8.9;






abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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






library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}






library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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




pragma solidity ^0.8.9;






contract Gabriel is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
    }
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 lastRewardBlock; // Last block number that ARCHAs distribution occurs.
        uint256 totalStaked; // Total Archa Staked in the Gabriel Staking Pool Before any emergengyWithdraw or before people start to unstake.
        uint256 totalValLocked; // This is the total amount of staked archa locked up in the pool and will become zero once everybody has unstaked.
        uint256 emergencyUnstaked; // To keep track of when a user left the pool using emergencyWithdraw
        uint256 rewardsInPool; // The amount of reward that is in the pool. Decreases each time a user harvests their pending reward.
    }
    bool public canStake = false;
    bool public inWaitPeriod = false;
    bool public canUnstake = false; // use emergencyWithdraw if its urgent.
    IERC20 public archa;
    address public devaddr;
    address public growthFundAddr;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalRewards;
    uint256 public openTime;
    uint256 public waitPeriod;
    uint256 public lockTime;
    uint256 public lockDuration;
    uint256 public unlockTime;
    event Stake(address indexed user, uint256 indexed pid, uint256 amount);
    event Unstake(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        IERC20 _archa,
        address _devaddr,
        address _growthFundAddr,
        uint256 _openTime,
        uint256 _waitPeriod,
        uint256 _lockDuration,
        bool _updateLockTime,
        uint256 _poolReward
    ) {
        archa = _archa;
        devaddr = _devaddr;
        growthFundAddr = _growthFundAddr;
        setTimeValues(_openTime, _waitPeriod, _lockDuration, _updateLockTime);
        add(archa);
        setPoolReward(_poolReward);
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(IERC20 _lpToken) public onlyOwner {

        require(lockTime > 0, "Set Time Values First");
        uint256 lastRewardBlock = lockTime;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                lastRewardBlock: lastRewardBlock,
                totalStaked: 0,
                totalValLocked: 0,
                emergencyUnstaked: 0,
                rewardsInPool: 0
            })
        );
    }

    function setTimeValues(
        uint256 _openTime,
        uint256 _waitPeriod,
        uint256 _lockDuration,
        bool _updateLockTime
    ) public onlyOwner {

        require(
            _openTime > block.timestamp,
            "Start Time must be a future time"
        );
        openTime = _openTime;

        require(_waitPeriod > 0);
        waitPeriod = _waitPeriod;

        lockTime = openTime.add(waitPeriod);

        require(_lockDuration > 0);
        lockDuration = _lockDuration;

        require(
            lockTime > block.timestamp && lockTime + lockDuration > lockTime,
            "End Time must be greater than Start Time"
        );
        unlockTime = lockTime.add(lockDuration);

        if (_updateLockTime) {
            PoolInfo storage pool = poolInfo[0];
            pool.lastRewardBlock = lockTime;
        }
    }

    function withdraw(uint256 _pid) public onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];
        require(
            block.timestamp > unlockTime && pool.totalValLocked == 0,
            "You cannot withdraw LOR and ForfeitedRwds till all users have unstaked"
        );
        uint256 tStaked = pool.totalValLocked;
        uint256 forfeitedRwds = (pool.emergencyUnstaked *
            lockDuration *
            totalRewards) / (pool.totalStaked * lockDuration);
        if (tStaked == 0) {
            uint256 poolBal = pool.lpToken.balanceOf(address(this));
            uint256 min = tStaked + forfeitedRwds;
            if (poolBal > min) {
                uint256 LOR = poolBal.sub(min);
                if (LOR > 0) {
                    uint256 half = LOR.div(2);
                    uint256 otherHalf = LOR.sub(half);
                    pool.lpToken.safeTransfer(devaddr, half);
                    pool.lpToken.safeTransfer(growthFundAddr, otherHalf);
                }
            }
            if (forfeitedRwds > 0) {
                poolBal = archa.balanceOf(address(this));
                if (forfeitedRwds > poolBal) {
                    archa.safeTransfer(growthFundAddr, poolBal);
                } else {
                    archa.safeTransfer(growthFundAddr, forfeitedRwds);
                }
            }
            pool.lastRewardBlock = block.timestamp;
            pool.totalStaked = 0;
            pool.emergencyUnstaked = 0;
            pool.rewardsInPool = 0;
        }
    }

    function setPoolReward(uint256 _value) public onlyOwner {

        require(poolInfo.length > 0, "You need to create a pool first");
        require(_value > 0, "pool reward cannot be zero");
        PoolInfo storage pool = poolInfo[0];
        totalRewards = _value * 10**9;
        pool.rewardsInPool = _value * 10**9;
    }

    function pendingArcha(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        if (block.timestamp > lockTime && block.timestamp < unlockTime) {
            PoolInfo storage pool = poolInfo[_pid];
            UserInfo storage user = userInfo[_pid][_user];
            uint256 supply = pool.totalStaked;
            if (block.timestamp > pool.lastRewardBlock && supply != 0) {
                uint256 blocks = block.timestamp.sub(pool.lastRewardBlock);
                uint256 reward = blocks * user.amount * totalRewards;
                uint256 lpSupply = supply * lockDuration;
                return reward.div(lpSupply);
            }
        }
        if (block.timestamp > unlockTime) {
            PoolInfo storage pool = poolInfo[_pid];
            UserInfo storage user = userInfo[_pid][_user];
            uint256 supply = pool.totalStaked;
            uint256 reward = lockDuration * user.amount * totalRewards;
            uint256 lpSupply = supply * lockDuration;
            return reward.div(lpSupply);
        }
        return 0;
    }

    function updatePool() public {

        if (block.timestamp <= openTime) {
            return;
        }
        if (block.timestamp > lockTime && block.timestamp < unlockTime) {
            canStake = false;
            inWaitPeriod = false;
            canUnstake = false;
        }
        if (
            block.timestamp > openTime &&
            block.timestamp < lockTime &&
            block.timestamp < unlockTime
        ) {
            canStake = true;
            inWaitPeriod = true;
            canUnstake = false;
        }
        if (block.timestamp > unlockTime && unlockTime > 0) {
            canUnstake = true;
            canStake = false;
            inWaitPeriod = false;
        }
    }

    function stake(uint256 _pid, uint256 _amount) public {

        if (block.timestamp > lockTime && canStake == true) {
            canStake = false;
        }
        if (block.timestamp < lockTime && canStake == false) {
            canStake = true;
        }
        require(
            canStake == true,
            "Waiting Period has ended, pool is now locked"
        );
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool();
        if (_amount <= 0) {
            return;
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        pool.totalStaked = pool.totalStaked.add(_amount);
        pool.totalValLocked = pool.totalValLocked.add(_amount);
        emit Stake(msg.sender, _pid, _amount);
    }

    function unstake(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (block.timestamp > unlockTime && canUnstake == false) {
            canUnstake = true;
        }
        require(canUnstake == true, "Pool is still locked");
        require(user.amount > 0, "withdraw: not good");
        updatePool();
        uint256 reward = lockDuration * user.amount * totalRewards;
        uint256 lpSupply = pool.totalStaked * lockDuration;
        uint256 pending = reward.div(lpSupply);
        if (pending > 0) {
            safeArchaTransfer(msg.sender, pending);
            pool.rewardsInPool = pool.rewardsInPool.sub(pending);
        }
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        pool.totalValLocked = pool.totalValLocked.sub(user.amount);
        emit Unstake(msg.sender, _pid, user.amount);
        user.amount = 0;
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        pool.emergencyUnstaked = pool.emergencyUnstaked.add(user.amount); // will be used to calculate total forfeited rewards
        pool.totalValLocked = pool.totalValLocked.sub(user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
    }

    function safeArchaTransfer(address _to, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[0];
        uint256 forfeitedRwds = (pool.emergencyUnstaked *
            lockDuration *
            totalRewards) / (pool.totalStaked * lockDuration);
        uint256 archaBal = pool.rewardsInPool.sub(forfeitedRwds);
        if (_amount > archaBal) {
            archa.safeTransfer(_to, archaBal);
        } else {
            archa.safeTransfer(_to, _amount);
        }
    }

    function dev(address _devaddr) public {

        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function growthFund(address _growthFundAddr) public onlyOwner {

        growthFundAddr = _growthFundAddr;
    }

    function release(address tokenAddress) external onlyOwner {

        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, balance);
    }
}