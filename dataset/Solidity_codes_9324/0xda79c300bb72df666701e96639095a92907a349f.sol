

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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

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


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
}


pragma solidity 0.6.12;







contract TimeLockLPTokenStaking {

    using SafeMath for uint256;
    using Address for address;

    struct UserInfo {
        uint256 amount; // How many  tokens the user currently has.
        uint256 rewardAllocPoint; //this is used for computing user rewards, depending on the staked amount and locked time
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardLocked;
        uint256 releaseTime;

        uint256 lpReleaseTime;
        uint256 lockedPeriod;
    }

    struct PoolInfo {
        uint256 allocPoint; // How many allocation points assigned to this pool. TROPs to distribute per block.
        uint256 accTROPPerRAP; // Accumulated TROPs per rewardAllocPoint RAP, times 1e18. See below.
        uint256 totalRewardAllocPoint;
        mapping(address => mapping(address => uint256)) allowance;
        bool emergencyWithdrawable;
        uint256 rewardsInThisEpoch;
        uint256 cumulativeRewardsSinceStart;
        uint256 startBlock;
        uint256 startTime;
        uint256 totalStake;
        mapping(uint256 => uint256) epochRewards;
        uint256 epochCalculationStartBlock;
    }

    PoolInfo public poolInfo;
    mapping(address => UserInfo) public userInfo;

    IERC20 public trop;

    function computeReleasableLP(address _addr) public view returns (uint256) {

        if (block.timestamp < userInfo[_addr].lpReleaseTime) {
            return 0;
        }

        return userInfo[_addr].amount;
    }
}

contract TROPStakingFixed is OwnableUpgradeSafe, TimeLockLPTokenStaking {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public devaddr;

    uint256 public totalAllocPoint;

    uint256 public pendingRewards;

    uint256 public epoch;

    uint256 public constant REWARD_LOCKED_PERIOD = 14 days;
    uint256 public constant REWARD_RELEASE_PERCENTAGE = 40;
    uint256 public contractStartBlock;

    uint256 private tropBalance;

    uint16 DEV_FEE;

    uint256 public pending_DEV_rewards;

    function averageFeesPerBlockSinceStart()
        external
        view
        returns (uint256 averagePerBlock)
    {

        averagePerBlock = poolInfo
            .cumulativeRewardsSinceStart
            .add(poolInfo.rewardsInThisEpoch)
            .add(pendingRewards)
            .div(block.number.sub(poolInfo.startBlock));
    }

    function averageFeesPerBlockEpoch()
        external
        view
        returns (uint256 averagePerBlock)
    {

        averagePerBlock = poolInfo.rewardsInThisEpoch.add(pendingRewards).div(
            block.number.sub(poolInfo.epochCalculationStartBlock)
        );
    }

    function getEpochReward(uint256 _epoch) public view returns (uint256) {

        return poolInfo.epochRewards[_epoch];
    }

    function startNewEpoch() public {

        require(
            poolInfo.epochCalculationStartBlock + 50000 < block.number,
            "New epoch not ready yet"
        ); // About a week
        poolInfo.epochRewards[epoch] = poolInfo.rewardsInThisEpoch;
        poolInfo.cumulativeRewardsSinceStart = poolInfo
            .cumulativeRewardsSinceStart
            .add(poolInfo.rewardsInThisEpoch);
        poolInfo.rewardsInThisEpoch = 0;
        poolInfo.epochCalculationStartBlock = block.number;
        ++epoch;
    }

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function initialize(address _devFundAddress) public initializer {

        OwnableUpgradeSafe.__Ownable_init();
        DEV_FEE = 1000; //10%
        trop = IERC20(0x2eC75589856562646afE393455986CaD26c4Cc5f);
        devaddr = _devFundAddress;
        contractStartBlock = block.number;
        poolInfo.startBlock = block.number;
        poolInfo.startTime = block.timestamp;
        poolInfo.epochCalculationStartBlock = block.number;
    }

    modifier validLockTime(uint256 _time) {

        require(
            _time == 10 days ||
                _time == 20 days ||
                _time == 25 days ||
                _time == 50 days ||
                _time == 75 days ||
                _time == 100 days,
            "Lock time is not valid"
        );
        _;
    }

    function checkLockTiming(address _user, uint256 _time) internal {

        uint256 lpReleaseTime = userInfo[_user].lpReleaseTime;
        require(lpReleaseTime <= block.timestamp.add(_time), "timing invalid");
    }

    function setEmergencyWithdrawable(bool _withdrawable) public onlyOwner {

        poolInfo.emergencyWithdrawable = _withdrawable;
    }

    function setDevFee(uint16 _DEV_FEE) public onlyOwner {

        require(_DEV_FEE <= 1000, "Dev fee clamped at 10%");
        DEV_FEE = _DEV_FEE;
    }

    function pendingTROP(address _user) public view returns (uint256) {

        UserInfo storage user = userInfo[_user];
        uint256 accTROPPerRAP = poolInfo.accTROPPerRAP;
        uint256 rewardAllocPoint = user.rewardAllocPoint;

        uint256 totalRAP = poolInfo.totalRewardAllocPoint;

        if (totalRAP == 0) return 0;

        uint256 rewardWhole = pendingRewards;
        uint256 rewardFee = rewardWhole.mul(DEV_FEE).div(10000);
        uint256 rewardToDistribute = rewardWhole.sub(rewardFee);
        uint256 inc = rewardToDistribute.mul(1e18).div(totalRAP);
        accTROPPerRAP = accTROPPerRAP.add(inc);

        return
            rewardAllocPoint.mul(accTROPPerRAP).div(1e18).sub(user.rewardDebt);
    }

    function getLockedReward(address _user) public view returns (uint256) {

        return userInfo[_user].rewardLocked;
    }

    function massUpdatePools() public {

        updatePool();

        pendingRewards = 0;
    }

    function updatePendingRewards() public {

        uint256 newRewards = trop.balanceOf(address(this)).sub(tropBalance).sub(
            poolInfo.totalStake
        );

        if (newRewards > 0) {
            tropBalance = trop.balanceOf(address(this)).sub(
                poolInfo.totalStake
            ); // If there is no change the balance didn't change
            pendingRewards = pendingRewards.add(newRewards);
        }
    }

    function updatePool() internal returns (uint256 tropRewardWhole) {

        uint256 totalRAP = poolInfo.totalRewardAllocPoint;

        if (totalRAP == 0) {
            return 0;
        }
        tropRewardWhole = pendingRewards;

        uint256 rewardFee = tropRewardWhole.mul(DEV_FEE).div(10000);
        uint256 rewardToDistribute = tropRewardWhole.sub(rewardFee);

        uint256 inc = rewardToDistribute.mul(1e18).div(totalRAP);
        pending_DEV_rewards = pending_DEV_rewards.add(rewardFee);

        poolInfo.accTROPPerRAP = poolInfo.accTROPPerRAP.add(inc);
        poolInfo.rewardsInThisEpoch = poolInfo.rewardsInThisEpoch.add(
            rewardToDistribute
        );
    }

    function withdrawReward() public {

        withdraw(0);
    }

    function deposit(uint256 _amount, uint256 _lockTime)
        public
        validLockTime(_lockTime)
    {

        checkLockTiming(msg.sender, _lockTime);
        UserInfo storage user = userInfo[msg.sender];

        massUpdatePools();

        updateAndPayOutPending(msg.sender);

        if (_amount > 0) {
            uint256 balBefore = trop.balanceOf(address(this));
            trop.safeTransferFrom(address(msg.sender), address(this), _amount);
            require(
                trop.balanceOf(address(this)).sub(balBefore) == _amount,
                "stake should not have fee"
            );
            updateRewardAllocPoint(msg.sender, _amount, _lockTime);
            user.amount = user.amount.add(_amount);
            poolInfo.totalStake += _amount;
        }

        user.rewardDebt = user.rewardAllocPoint.mul(poolInfo.accTROPPerRAP).div(
            1e18
        );
        emit Deposit(msg.sender, _amount);
    }

    function updateRewardAllocPoint(
        address _addr,
        uint256 _depositAmount,
        uint256 _lockTime
    ) internal {

        UserInfo storage user = userInfo[_addr];
        PoolInfo storage pool = poolInfo;
        if (user.amount == 0) {
            user.rewardAllocPoint = _depositAmount.mul(_lockTime);
            pool.totalRewardAllocPoint = pool.totalRewardAllocPoint.add(
                user.rewardAllocPoint
            );
            user.lockedPeriod = _lockTime;
            user.lpReleaseTime = block.timestamp.add(_lockTime);
        } else {
            user.lockedPeriod = _lockTime;
            user.lpReleaseTime = block.timestamp.add(_lockTime);

            uint256 pointMinus = user.rewardAllocPoint;
            uint256 amountAfterDeposit = user.amount.add(_depositAmount);
            user.rewardAllocPoint = amountAfterDeposit.mul(_lockTime);
            pool.totalRewardAllocPoint = pool
                .totalRewardAllocPoint
                .add(user.rewardAllocPoint)
                .sub(pointMinus);
        }
    }

    function depositFor(
        address _depositFor,
        uint256 _amount,
        uint256 _lockTime
    ) public validLockTime(_lockTime) {

        checkLockTiming(_depositFor, _lockTime);
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[_depositFor];

        massUpdatePools();

        updateAndPayOutPending(_depositFor); // Update the balances of person that amount is being deposited for

        if (_amount > 0) {
            uint256 balBefore = trop.balanceOf(address(this));
            trop.safeTransferFrom(address(msg.sender), address(this), _amount);
            require(
                trop.balanceOf(address(this)).sub(balBefore) == _amount,
                "stake should not have fee"
            );
            updateRewardAllocPoint(_depositFor, _amount, _lockTime);
            user.amount = user.amount.add(_amount); // This is depositedFor address
            poolInfo.totalStake += _amount;
        }

        user.rewardDebt = user.rewardAllocPoint.mul(pool.accTROPPerRAP).div(
            1e18
        ); /// This is deposited for address
        emit Deposit(_depositFor, _amount);
    }

    function setAllowanceForPoolToken(address spender, uint256 value) public {

        PoolInfo storage pool = poolInfo;
        pool.allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function quitPool() public {

        require(
            block.timestamp > userInfo[msg.sender].lpReleaseTime,
            "cannot withdraw all lp tokens before"
        );

        uint256 withdrawnableAmount = computeReleasableLP(msg.sender);
        withdraw(withdrawnableAmount);
    }

    function withdrawFrom(address owner, uint256 _amount) public {

        PoolInfo storage pool = poolInfo;
        require(
            pool.allowance[owner][msg.sender] >= _amount,
            "withdraw: insufficient allowance"
        );
        pool.allowance[owner][msg.sender] = pool.allowance[owner][msg.sender]
            .sub(_amount);
        _withdraw(_amount, owner, msg.sender);
    }

    function withdraw(uint256 _amount) public {

        _withdraw(_amount, msg.sender, msg.sender);
    }

    function _withdraw(
        uint256 _amount,
        address from,
        address to
    ) internal {

        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[from];

        uint256 withdrawnableAmount = computeReleasableLP(from);
        require(withdrawnableAmount >= _amount, "withdraw: not good");

        massUpdatePools();
        updateAndPayOutPending(from); // Update balances of from this is not withdrawal but claiming TROP farmed

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            user.rewardAllocPoint = user.amount.mul(user.lockedPeriod);
            pool.totalRewardAllocPoint = pool.totalRewardAllocPoint.sub(
                _amount.mul(user.lockedPeriod)
            );
            trop.safeTransfer(address(to), _amount);
            if (user.amount == 0) {
                user.lockedPeriod = 0;
                user.lpReleaseTime = 0;
            }
            pool.totalStake -= _amount;
        }
        user.rewardDebt = user.rewardAllocPoint.mul(pool.accTROPPerRAP).div(
            1e18
        );
        emit Withdraw(to, _amount);
    }

    function updateAndPayOutPending(address from) internal {

        UserInfo storage user = userInfo[from];
        if (user.releaseTime == 0) {
            user.releaseTime = block.timestamp.add(REWARD_LOCKED_PERIOD);
        }
        if (block.timestamp > user.releaseTime) {
            uint256 lockedAmount = user.rewardLocked;
            user.rewardLocked = 0;
            safeTROPTransfer(from, lockedAmount);
            user.releaseTime = block.timestamp.add(REWARD_LOCKED_PERIOD);
        }

        uint256 pending = pendingTROP(from);
        uint256 paid = pending.mul(REWARD_RELEASE_PERCENTAGE).div(100);
        uint256 _lockedReward = pending.sub(paid);
        if (_lockedReward > 0) {
            user.rewardLocked = user.rewardLocked.add(_lockedReward);
        }

        if (paid > 0) {
            safeTROPTransfer(from, paid);
        }
    }

    function emergencyWithdraw() public {

        PoolInfo storage pool = poolInfo;
        require(
            pool.emergencyWithdrawable,
            "Withdrawing from this pool is disabled"
        );
        UserInfo storage user = userInfo[msg.sender];
        trop.safeTransfer(address(msg.sender), user.amount);
        if (pool.totalStake >= user.amount) {
            pool.totalStake -= user.amount;
        }
        emit EmergencyWithdraw(msg.sender, user.amount);
        if (
            user.amount.mul(user.rewardAllocPoint) <= pool.totalRewardAllocPoint
        ) {
            pool.totalRewardAllocPoint = pool.totalRewardAllocPoint.sub(
                user.amount.mul(user.rewardAllocPoint)
            );
        }
        user.rewardAllocPoint = 0;
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeTROPTransfer(address _to, uint256 _amount) internal {

        uint256 tropBal = trop.balanceOf(address(this));

        if (_amount > tropBal) {
            trop.transfer(_to, tropBal);
            tropBalance = trop.balanceOf(address(this)).sub(
                poolInfo.totalStake
            );
        } else {
            trop.transfer(_to, _amount);
            tropBalance = trop.balanceOf(address(this)).sub(
                poolInfo.totalStake
            );
        }
        transferDevFee();
    }

    function transferDevFee() public {

        if (pending_DEV_rewards == 0) return;

        uint256 tropBal = trop.balanceOf(address(this));
        if (pending_DEV_rewards > tropBal) {
            trop.transfer(devaddr, tropBal);
            tropBalance = trop.balanceOf(address(this)).sub(
                poolInfo.totalStake
            );
        } else {
            trop.transfer(devaddr, pending_DEV_rewards);
            tropBalance = trop.balanceOf(address(this)).sub(
                poolInfo.totalStake
            );
        }

        pending_DEV_rewards = 0;
    }

    function setDevFeeReciever(address _devaddr) public {

        require(devaddr == msg.sender, "only dev can change");
        devaddr = _devaddr;
    }

    event Restake(address indexed user, uint256 amount);

    function claimAndRestake() public {

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount > 0);
        massUpdatePools();

        if (user.releaseTime == 0) {
            user.releaseTime = block.timestamp.add(REWARD_LOCKED_PERIOD);
        }
        uint256 _rewards = 0;
        if (block.timestamp > user.releaseTime) {
            uint256 lockedAmount = user.rewardLocked;
            user.rewardLocked = 0;
            user.releaseTime = block.timestamp.add(REWARD_LOCKED_PERIOD);
            _rewards = _rewards.add(lockedAmount);
        }

        uint256 pending = pendingTROP(msg.sender);
        uint256 paid = pending.mul(REWARD_RELEASE_PERCENTAGE).div(100);
        uint256 _lockedReward = pending.sub(paid);
        if (_lockedReward > 0) {
            user.rewardLocked = user.rewardLocked.add(_lockedReward);
        }

        _rewards = _rewards.add(paid);

        user.lpReleaseTime = user.lpReleaseTime.add(1 days);

        uint256 pointMinus = user.rewardAllocPoint;
        uint256 amountAfterDeposit = user.amount.add(_rewards);
        user.rewardAllocPoint = amountAfterDeposit.mul(user.lockedPeriod);
        poolInfo.totalRewardAllocPoint = poolInfo
            .totalRewardAllocPoint
            .add(user.rewardAllocPoint)
            .sub(pointMinus);
        user.amount = amountAfterDeposit; // This is depositedFor address
        user.rewardDebt = user.rewardAllocPoint.mul(poolInfo.accTROPPerRAP).div(
            1e18
        );
        poolInfo.totalStake += _rewards;
        transferDevFee();
        emit Restake(msg.sender, _rewards);
    }
}