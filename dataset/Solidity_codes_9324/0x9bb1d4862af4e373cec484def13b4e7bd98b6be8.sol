



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





pragma solidity ^0.8.0;

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





pragma solidity ^0.8.0;

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





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





pragma solidity ^0.8.0;

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





pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}





pragma solidity ^0.8.0;
contract BetDaoStaking is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 rewardLockedUp;  // Reward locked up.
        uint256 nextHarvestUntil; // When can the user harvest again.
    }

    struct PoolInfo {
        IERC20 token;           // Address of token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. BCHIEFs to distribute per block.
        uint256 lastRewardTimestamp;  // Last block number that BCHIEFs distribution occurs.
        uint256 accBChiefPerShare;   // Accumulated BCHIEFs per share, times 1e12. See below.
        uint256 harvestInterval;  // Harvest interval in seconds
        uint256 tvl;
        uint16 depositFeeBP;
    }

    IERC20 public bChief;
    uint256 public bChiefPerSec;
    uint256 public constant BONUS_MULTIPLIER = 1;
    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 14 days;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startTimestamp;
    uint256 public totalLockedUpRewards;

    bool public shouldUpdatePoolsByUser;

    address public feeRecipient;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmissionRateUpdated(address indexed caller, uint256 previousAmount, uint256 newAmount);
    event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);

    constructor(
        IERC20 _bChief,
        uint256 _startTimestamp,
        uint256 _bChiefPerSec
    ) public {
        bChief = _bChief;
        startTimestamp = _startTimestamp;
        bChiefPerSec = _bChiefPerSec;
        feeRecipient = msg.sender;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _token, uint256 _harvestInterval, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner {

        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "add: invalid harvest interval");
        require(_depositFeeBP < 10000, 'invalid deposit fee');
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTimestamp = block.timestamp > startTimestamp ? block.timestamp : startTimestamp;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            token: _token,
            allocPoint: _allocPoint,
            lastRewardTimestamp: lastRewardTimestamp,
            accBChiefPerShare: 0,
            harvestInterval: _harvestInterval,
            tvl: 0,
            depositFeeBP: _depositFeeBP
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, uint256 _harvestInterval, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner {

        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "set: invalid harvest interval");
        require(_depositFeeBP < 10000, 'invalid deposit fee');
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].harvestInterval = _harvestInterval;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {

        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    function pendingBChief(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accBChiefPerShare = pool.accBChiefPerShare;
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (block.timestamp > pool.lastRewardTimestamp && tokenSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardTimestamp, block.timestamp);
            uint256 bChiefReward = multiplier.mul(bChiefPerSec).mul(pool.allocPoint).div(totalAllocPoint);
            accBChiefPerShare = accBChiefPerShare.add(bChiefReward.mul(1e12).div(tokenSupply));
        }
        uint256 pending = user.amount.mul(accBChiefPerShare).div(1e12).sub(user.rewardDebt);
        return pending.add(user.rewardLockedUp);
    }

    function canHarvest(uint256 _pid, address _user) public view returns (bool) {

        UserInfo storage user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    function tvl(uint256 _pid) public view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        return pool.tvl;
    }

    function apr(uint256 _pid) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];

        uint256 reward = uint256(86400).mul(365).mul(bChiefPerSec).mul(pool.allocPoint).div(totalAllocPoint);
        if (reward > 0) {
            return tvl(_pid) > 0 ? reward.mul(1e12).div(tvl(_pid)) : 0;
        }
        return 0;
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTimestamp) {
            return;
        }
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardTimestamp, block.timestamp);
        uint256 bChiefReward = multiplier.mul(bChiefPerSec).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accBChiefPerShare = pool.accBChiefPerShare.add(bChiefReward.mul(1e12).div(tokenSupply));
        pool.lastRewardTimestamp = block.timestamp;
    }

    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (shouldUpdatePoolsByUser) {
          updatePool(_pid);
        }
        payOrLockupPendingBChief(_pid);
        if (_amount > 0) {
            uint transferredAmount = deflationaryTokenTransfer(IERC20(pool.token), address(msg.sender), address(this), _amount);
            if (pool.depositFeeBP > 0) {
                uint256 feeAmount = transferredAmount.mul(pool.depositFeeBP).div(10000);
                pool.token.safeTransfer(feeRecipient, feeAmount);
                transferredAmount = transferredAmount.sub(feeAmount);
            }
            user.amount = user.amount.add(transferredAmount);
            pool.tvl = pool.tvl.add(transferredAmount);
        }
        user.rewardDebt = user.amount.mul(pool.accBChiefPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        payOrLockupPendingBChief(_pid);
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.token.safeTransfer(address(msg.sender), _amount);
            pool.tvl = pool.tvl.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accBChiefPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        pool.token.safeTransfer(address(msg.sender), amount);
        pool.tvl = pool.tvl.sub(amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function payOrLockupPendingBChief(uint256 _pid) internal {

      PoolInfo storage pool = poolInfo[_pid];
      UserInfo storage user = userInfo[_pid][msg.sender];

      if (user.nextHarvestUntil == 0) {
        user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
      }

      uint256 pending = user.amount.mul(pool.accBChiefPerShare).div(1e12).sub(user.rewardDebt);
      if (canHarvest(_pid, msg.sender)) {
        if (pending > 0 || user.rewardLockedUp > 0) {
          uint256 totalRewards = pending.add(user.rewardLockedUp);

          totalLockedUpRewards = totalLockedUpRewards.sub(user.rewardLockedUp);
          user.rewardLockedUp = 0;
          user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);

          safeBChiefTransfer(msg.sender, totalRewards);
        }
      } else if (pending > 0) {
        user.rewardLockedUp = user.rewardLockedUp.add(pending);
        totalLockedUpRewards = totalLockedUpRewards.add(pending);
        emit RewardLockedUp(msg.sender, _pid, pending);
      }
    }

    function safeBChiefTransfer(address _to, uint256 _amount) internal {

        uint256 bChiefBal = bChief.balanceOf(address(this));
        if (_amount > bChiefBal) {
            bChief.transfer(_to, bChiefBal);
        } else {
            bChief.transfer(_to, _amount);
        }
    }

    function deflationaryTokenTransfer(IERC20 _token, address _from, address _to, uint256 _amount) internal returns (uint256) {

        uint256 beforeBal = _token.balanceOf(_to);
        _token.safeTransferFrom(_from, _to, _amount);
        uint256 afterBal = _token.balanceOf(_to);
        if (afterBal > beforeBal) {
          return afterBal.sub(beforeBal);
        }
        return 0;
    }

    function updateEmissionRate(uint256 _bChiefPerSec) public onlyOwner {

      massUpdatePools();
      emit EmissionRateUpdated(msg.sender, bChiefPerSec, _bChiefPerSec);
      bChiefPerSec = _bChiefPerSec;
    }

    function setShouldUpdatePoolsByUser(bool _yesOrNo) external onlyOwner {

      shouldUpdatePoolsByUser = _yesOrNo;
    }
}