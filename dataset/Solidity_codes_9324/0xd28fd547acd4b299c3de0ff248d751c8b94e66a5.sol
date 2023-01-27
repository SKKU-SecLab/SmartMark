



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

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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






contract AnimeVerseTokenStaking is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardLockedUp; // Reward locked up.
        uint256 nextHarvestUntil; // When can the user harvest again.
        uint256 lastInteraction; // Last time when user deposited or claimed rewards, renewing the lock
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract
        uint256 allocPoint; // How many allocation points assigned to this pool. ANIME to distribute per block.
        uint256 lastRewardBlock; // Last block number that ANIME distribution occurs.
        uint256 accAnimePerShare; // Accumulated ANIME per share, times 1e12. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint16 withdrawFeeBP; // Withdraw fee in basis points
        uint256 harvestInterval; // Harvest interval in seconds
        uint256 totalLp; // Total token in Pool
        uint256 lockupDuration; // Amount of time the participant will be locked in the pool after depositing or claiming rewards
    }

    IERC20 public immutable animeToken;

    address public feeAddress;

    address private BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint256 public animePerBlock;

    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 30 days;

    uint256 public constant MAXIMUM_LOCK_DURATION = 30 days;

    uint16 public constant MAXIMUM_DEPOSIT_FEE_RATE = 1000;

    uint16 public constant MAXIMUM_WITHDRAW_FEE_RATE = 1000;


    PoolInfo[] public poolInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint = 0;

    uint256 public startBlock;

    uint256 public totalLockedUpRewards;

    uint256 public totalAnimeInPools = 0;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event EmissionRateUpdated(
        address indexed caller,
        uint256 previousAmount,
        uint256 newAmount
    );
    event RewardLockedUp(
        address indexed user,
        uint256 indexed pid,
        uint256 amountLockedUp
    );
    event FeeAddressChanged(
        address indexed caller,
        address oldAddress,
        address newAddress
    );

    constructor(
        address _animeToken,
        address _feeAddress,
        uint256 _animePerBlock
    ) {
        require(_feeAddress != address(0), "Invalid fee address");
        require(_animePerBlock > 0, "Invalid anime per block");

        startBlock = block.number.add(3650 days);

        animeToken = IERC20(_animeToken);
        animePerBlock = _animePerBlock;

        feeAddress = _feeAddress;
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {

        return _to.sub(_from);
    }

    function startFarming() public onlyOwner {

        require(block.number < startBlock, "Error: farm started already");

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            pool.lastRewardBlock = block.number;
        }

        startBlock = block.number;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        uint16 _depositFeeBP,
        uint16 _withdrawFeeBP,
        uint256 _harvestInterval,
        uint256 _lockupDuration,
        bool _withUpdate
    ) external onlyOwner {

        require(
            _depositFeeBP <= MAXIMUM_DEPOSIT_FEE_RATE,
            "Deposit fee too high"
        );
        require(
            _withdrawFeeBP <= MAXIMUM_WITHDRAW_FEE_RATE,
            "Withdraw fee too high"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "Harvest interval too long"
        );
        require(
            _lockupDuration <= MAXIMUM_LOCK_DURATION,
            "Lockup duration too long"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accAnimePerShare: 0,
                depositFeeBP: _depositFeeBP,
                withdrawFeeBP: _withdrawFeeBP,
                harvestInterval: _harvestInterval,
                totalLp: 0,
                lockupDuration: _lockupDuration
            })
        );
    }

    function updatePoolConfiguration(
        uint256 _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        uint16 _withdrawFeeBP,
        uint256 _harvestInterval,
        uint256 _lockupDuration,
        bool _withUpdate
    ) external onlyOwner {

        require(
            _depositFeeBP <= MAXIMUM_DEPOSIT_FEE_RATE,
            "Deposit fee too high"
        );
        require(
            _withdrawFeeBP <= MAXIMUM_WITHDRAW_FEE_RATE,
            "Withdraw fee too high"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "Harvest interval too long"
        );
        require(
            _lockupDuration <= MAXIMUM_LOCK_DURATION,
            "Lockup duration too long"
        );
        if (_withUpdate) {
            massUpdatePools();
        }

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].withdrawFeeBP = _withdrawFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval;
        poolInfo[_pid].lockupDuration = _lockupDuration;
    }

    function pendingAnime(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accAnimePerShare = pool.accAnimePerShare;
        uint256 lpSupply = pool.totalLp;

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 animeReward = multiplier
                .mul(animePerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accAnimePerShare = accAnimePerShare.add(
                animeReward.mul(1e12).div(lpSupply)
            );
        }

        uint256 pending = user.amount.mul(accAnimePerShare).div(1e12).sub(
            user.rewardDebt
        );
        return pending.add(user.rewardLockedUp);
    }

    function userLockedUntil(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        UserInfo storage user = userInfo[_pid][_user];
        PoolInfo storage pool = poolInfo[_pid];

        return user.lastInteraction.add(pool.lockupDuration);
    }

    function canHarvest(uint256 _pid, address _user)
        public
        view
        returns (bool)
    {

        UserInfo storage user = userInfo[_pid][_user];
        return
            block.number >= startBlock &&
            block.timestamp >= user.nextHarvestUntil;
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

        uint256 lpSupply = pool.totalLp;
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 animeReward = multiplier
            .mul(animePerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);

        pool.accAnimePerShare = pool.accAnimePerShare.add(
            animeReward.mul(1e12).div(pool.totalLp)
        );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) external nonReentrant {

        require(
            block.number >= startBlock,
            "Cannot deposit before farming start"
        );

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        updatePool(_pid);
        payOrLockupPendingAnime(_pid);

        if (_amount > 0) {
            uint256 beforeDeposit = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(_msgSender(), address(this), _amount);
            uint256 afterDeposit = pool.lpToken.balanceOf(address(this));

            _amount = afterDeposit.sub(beforeDeposit);

            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                if (depositFee > 0) {
                    pool.lpToken.safeTransfer(feeAddress, depositFee);
                    _amount = _amount.sub(depositFee);
                }
            }

            user.amount = user.amount.add(_amount);
            pool.totalLp = pool.totalLp.add(_amount);

            if (address(pool.lpToken) == address(animeToken)) {
                totalAnimeInPools = totalAnimeInPools.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accAnimePerShare).div(1e12);
        user.lastInteraction = block.timestamp;
        emit Deposit(_msgSender(), _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        require(user.amount >= _amount, "Withdraw: user amount is not enough");

        require(pool.totalLp >= _amount, "Withdraw: pool total is not enough");

        updatePool(_pid);
        payOrLockupPendingAnime(_pid);

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalLp = pool.totalLp.sub(_amount);
            if (address(pool.lpToken) == address(animeToken)) {
                totalAnimeInPools = totalAnimeInPools.sub(_amount);
            }

            if (
                block.timestamp < user.lastInteraction.add(pool.lockupDuration)
            ) {
                uint256 withdrawFee = _amount.mul(pool.withdrawFeeBP).div(
                    10000
                );
                if (withdrawFee > 0) {
                    pool.lpToken.safeTransfer(feeAddress, withdrawFee);
                    _amount = _amount.sub(withdrawFee);
                }
            }

            if (_amount > 0) {
                pool.lpToken.safeTransfer(_msgSender(), _amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accAnimePerShare).div(1e12);
        user.lastInteraction = block.timestamp;
        emit Withdraw(_msgSender(), _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        uint256 amount = user.amount;

        require(
            pool.totalLp >= amount,
            "emergency withdraw: pool total not enough"
        );

        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        pool.totalLp -= amount;

        if (address(pool.lpToken) == address(animeToken)) {
            totalAnimeInPools = totalAnimeInPools.sub(amount);
        }

        if (block.timestamp < user.lastInteraction.add(pool.lockupDuration)) {
            uint256 withdrawFee = amount.mul(pool.withdrawFeeBP).div(10000);
            if (withdrawFee > 0) {
                pool.lpToken.safeTransfer(feeAddress, withdrawFee);
                amount = amount.sub(withdrawFee);
            }
        }

        pool.lpToken.safeTransfer(_msgSender(), amount);

        emit EmergencyWithdraw(_msgSender(), _pid, amount);
    }

    function payOrLockupPendingAnime(uint256 _pid) private {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        if (user.nextHarvestUntil == 0 && block.number >= startBlock) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
        }

        uint256 pending = user.amount.mul(pool.accAnimePerShare).div(1e12).sub(
            user.rewardDebt
        );
        if (canHarvest(_pid, _msgSender())) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);
                uint256 rewardsTransferred = safeAnimeTransfer(
                    _msgSender(),
                    totalRewards
                );
                uint256 rewardsUnTransferred = totalRewards.sub(
                    rewardsTransferred
                );

                totalLockedUpRewards = totalLockedUpRewards
                    .sub(user.rewardLockedUp)
                    .add(rewardsUnTransferred);
                user.rewardLockedUp = rewardsUnTransferred;
                user.nextHarvestUntil = block.timestamp.add(
                    pool.harvestInterval
                );
            }
        } else if (pending > 0) {
            user.rewardLockedUp = user.rewardLockedUp.add(pending);
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLockedUp(_msgSender(), _pid, pending);
        }
    }

    function safeAnimeTransfer(address _to, uint256 _amount)
        private
        returns (uint256)
    {

        uint256 totalAnimeInContract = animeToken.balanceOf(address(this));
        if (_amount > 0 && totalAnimeInContract > totalAnimeInPools) {
            uint256 animeBal = totalAnimeInContract.sub(totalAnimeInPools);
            if (_amount >= animeBal) {
                _amount = animeBal;
            }

            animeToken.safeTransfer(_to, _amount);
            return _amount;
        }
        return 0;
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {

        require(_feeAddress != address(0), "Invalid fee address");

        emit FeeAddressChanged(_msgSender(), feeAddress, _feeAddress);

        feeAddress = _feeAddress;
    }

    function updateEmissionRate(uint256 _animePerBlock) external onlyOwner {

        massUpdatePools();

        emit EmissionRateUpdated(_msgSender(), animePerBlock, _animePerBlock);
        animePerBlock = _animePerBlock;
    }

    receive() external payable {}
}