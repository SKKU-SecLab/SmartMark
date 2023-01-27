
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

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
}// MIT
pragma solidity ^0.8.10;



contract Owner is Ownable {

    address public pendingOwner;

    event NewPendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);

    error CannotBeOwner();
    error CallerNotPendingOwner();
    error ZeroAddress();

    function transferOwnership(address newOwner) public override virtual onlyOwner {
        if(newOwner == address(0)) revert ZeroAddress();
        if(newOwner == owner()) revert CannotBeOwner();
        address oldPendingOwner = pendingOwner;

        pendingOwner = newOwner;

        emit NewPendingOwner(oldPendingOwner, newOwner);
    }

    function acceptOwnership() public virtual {
        if(pendingOwner == address(0)) revert ZeroAddress();
        if(msg.sender != pendingOwner) revert CallerNotPendingOwner();
        address newOwner = pendingOwner;
        _transferOwnership(pendingOwner);
        pendingOwner = address(0);

        emit NewPendingOwner(newOwner, address(0));
    }

}// MIT
pragma solidity ^0.8.10;


interface SmartWalletChecker {
    function check(address) external view returns (bool);
}// MIT
pragma solidity ^0.8.10;


contract HolyPaladinToken is ERC20("Holy Paladin Token", "hPAL"), Owner {
    using SafeERC20 for IERC20;


    uint256 public constant WEEK = 604800;
    uint256 public constant MONTH = 2628000;
    uint256 public constant UNIT = 1e18;
    uint256 public constant MAX_BPS = 10000;
    uint256 public constant ONE_YEAR = 31536000;

    uint256 public constant COOLDOWN_PERIOD = 864000; // 10 days
    uint256 public constant UNSTAKE_PERIOD = 172800; // 2 days

    uint256 public constant UNLOCK_DELAY = 1209600; // 2 weeks

    uint256 public constant MIN_LOCK_DURATION = 7884000; // 3 months
    uint256 public constant MAX_LOCK_DURATION = 63072000; // 2 years

    IERC20 public immutable pal;

    struct UserLock {
        uint128 amount; // safe because PAL max supply is 10M tokens
        uint48 startTimestamp;
        uint48 duration;
        uint32 fromBlock; // because we want to search by block number
    }

    mapping(address => UserLock[]) public userLocks;

    struct TotalLock {
        uint224 total;
        uint32 fromBlock;
    }

    uint256 public currentTotalLocked;
    TotalLock[] public totalLocks;

    mapping(address => uint256) public cooldowns;

    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    struct DelegateCheckpoint {
        uint32 fromBlock;
        address delegate;
    }

    mapping(address => address) public delegates;

    mapping(address => Checkpoint[]) public checkpoints;

    mapping(address => DelegateCheckpoint[]) public delegateCheckpoints;

    uint256 public kickRatioPerWeek = 100;

    uint256 public constant bonusLockVoteRatio = 0.5e18;

    bool public emergency = false;

    address public immutable rewardsVault;

    struct RewardState {
        uint128 index;
        uint128 lastUpdate;
    }

    RewardState public globalRewards;

    uint256 public immutable startDropPerSecond;
    uint256 public endDropPerSecond;
    uint256 public currentDropPerSecond;
    uint256 public lastDropUpdate;
    uint256 public immutable dropDecreaseDuration;
    uint256 public immutable startDropTimestamp;

    mapping(address => RewardState) public userRewardStates;
    mapping(address => uint256) public claimableRewards;

    uint256 public immutable baseLockBonusRatio;
    uint256 public immutable minLockBonusRatio;
    uint256 public immutable maxLockBonusRatio;

    mapping(address => uint256) public userCurrentBonusRatio;
    mapping(address => uint256) public userBonusRatioDecrease;
    
    address public smartWalletChecker;
    address public futureSmartWalletChecker;

    error NoBalance();
    error NullAmount();
    error IncorrectAmount();
    error AddressZero();
    error AvailableBalanceTooLow();
    error NoLock();
    error EmptyLock();
    error InvalidBlockNumber();
    error InsufficientCooldown();
    error UnstakePeriodExpired();
    error AmountExceedBalance();
    error DurationOverMax();
    error DurationUnderMin();
    error SmallerAmount();
    error SmallerDuration();
    error LockNotExpired();
    error LockNotKickable();
    error CannotSelfKick();
    error NotEmergency();
    error EmergencyBlock();
    error ContractNotAllowed(); 


    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event Cooldown(address indexed user);
    event Lock(address indexed user, uint256 amount, uint256 indexed startTimestamp, uint256 indexed duration, uint256 totalLocked);
    event Unlock(address indexed user, uint256 amount, uint256 totalLocked);
    event Kick(address indexed user, address indexed kicker, uint256 amount, uint256 penalty, uint256 totalLocked);
    event ClaimRewards(address indexed user, uint256 amount);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
    event EmergencyUnstake(address indexed user, uint256 amount);

    constructor(
        address _palToken,
        address _admin,
        address _rewardsVault,
        address _smartWalletChecker,
        uint256 _startDropPerSecond,
        uint256 _endDropPerSecond,
        uint256 _dropDecreaseDuration,
        uint256 _baseLockBonusRatio,
        uint256 _minLockBonusRatio,
        uint256 _maxLockBonusRatio
    ){
        require(_palToken != address(0));
        require(_admin != address(0));
        require(_rewardsVault != address(0));

        pal = IERC20(_palToken);

        _transferOwnership(_admin);

        smartWalletChecker = _smartWalletChecker;

        totalLocks.push(TotalLock(
            0,
            safe32(block.number)
        ));
        rewardsVault = _rewardsVault;

        require(_startDropPerSecond >= endDropPerSecond);

        startDropPerSecond = _startDropPerSecond;
        endDropPerSecond = _endDropPerSecond;

        currentDropPerSecond = _startDropPerSecond;

        dropDecreaseDuration = _dropDecreaseDuration;

        require(_baseLockBonusRatio != 0);
        require(_minLockBonusRatio >= _baseLockBonusRatio);
        require(_maxLockBonusRatio >= _minLockBonusRatio);
        baseLockBonusRatio = _baseLockBonusRatio;
        minLockBonusRatio = _minLockBonusRatio;
        maxLockBonusRatio = _maxLockBonusRatio;

        globalRewards.lastUpdate = safe128(block.timestamp);
        lastDropUpdate = block.timestamp;
        startDropTimestamp = block.timestamp;
    }


    function stake(uint256 amount) external returns(uint256) {
        if(emergency) revert EmergencyBlock();
        return _stake(msg.sender, amount);
    }

    function cooldown() external {
        if(emergency) revert EmergencyBlock();
        if(balanceOf(msg.sender) == 0) revert NoBalance();

        cooldowns[msg.sender] = block.timestamp;

        emit Cooldown(msg.sender);
    }

    function unstake(uint256 amount, address receiver) external returns(uint256) {
        if(emergency) revert EmergencyBlock();
        return _unstake(msg.sender, amount, receiver);
    }

    function lock(uint256 amount, uint256 duration) external {
        if(emergency) revert EmergencyBlock();
        _assertNotContract(msg.sender);
        _updateUserRewards(msg.sender);
        if(delegates[msg.sender] == address(0)){
            _delegate(msg.sender, msg.sender);
        }
        _lock(msg.sender, amount, duration, LockAction.LOCK);
    }

    function increaseLockDuration(uint256 duration) external {
        if(emergency) revert EmergencyBlock();
        _assertNotContract(msg.sender);
        if(userLocks[msg.sender].length == 0) revert NoLock();
        UserLock storage currentUserLock = userLocks[msg.sender][userLocks[msg.sender].length - 1];
        if(currentUserLock.amount == 0) revert EmptyLock();
        _updateUserRewards(msg.sender);
        _lock(msg.sender, currentUserLock.amount, duration, LockAction.INCREASE_DURATION);
    }

    function increaseLock(uint256 amount) external {
        if(emergency) revert EmergencyBlock();
        _assertNotContract(msg.sender);
        if(userLocks[msg.sender].length == 0) revert NoLock();
        UserLock storage currentUserLock = userLocks[msg.sender][userLocks[msg.sender].length - 1];
        if(currentUserLock.amount == 0) revert EmptyLock();
        _updateUserRewards(msg.sender);
        _lock(msg.sender, amount, currentUserLock.duration, LockAction.INCREASE_AMOUNT);
    }

    function unlock() external {
        if(emergency) revert EmergencyBlock();
        if(userLocks[msg.sender].length == 0) revert NoLock();
        _updateUserRewards(msg.sender);
        _unlock(msg.sender);
    }

    function kick(address user) external {
        if(emergency) revert EmergencyBlock();
        if(msg.sender == user) revert CannotSelfKick();
        _updateUserRewards(user);
        _updateUserRewards(msg.sender);
        _kick(user, msg.sender);
    }

    function stakeAndLock(uint256 amount, uint256 duration) external returns(uint256) {
        if(emergency) revert EmergencyBlock();
        _assertNotContract(msg.sender);
        uint256 stakedAmount = _stake(msg.sender, amount);
        if(delegates[msg.sender] == address(0)){
            _delegate(msg.sender, msg.sender);
        }
        _lock(msg.sender, amount, duration, LockAction.LOCK);
        return stakedAmount;
    }

    function stakeAndIncreaseLock(uint256 amount, uint256 duration) external returns(uint256) {
        if(emergency) revert EmergencyBlock();
        _assertNotContract(msg.sender);
        if(userLocks[msg.sender].length == 0) revert NoLock();
        uint256 currentUserLockIndex = userLocks[msg.sender].length - 1;
        uint256 previousLockAmount = userLocks[msg.sender][currentUserLockIndex].amount;
        if(previousLockAmount == 0) revert EmptyLock();
        uint256 stakedAmount = _stake(msg.sender, amount);
        if(delegates[msg.sender] == address(0)){
            _delegate(msg.sender, msg.sender);
        }
        if(duration == userLocks[msg.sender][currentUserLockIndex].duration) {
            _lock(msg.sender, previousLockAmount + amount, duration, LockAction.INCREASE_AMOUNT);
        } else {
            _lock(msg.sender, previousLockAmount + amount, duration, LockAction.LOCK);
        }
        return stakedAmount;
    }

    function delegate(address delegatee) external virtual {
        if(emergency) revert EmergencyBlock();
        return _delegate(msg.sender, delegatee);
    }

    function claim(uint256 amount) external {
        if(emergency) revert EmergencyBlock();
        _updateUserRewards(msg.sender);

        if(amount == 0) revert IncorrectAmount();

        uint256 claimAmount = amount < claimableRewards[msg.sender] ? amount : claimableRewards[msg.sender];

        if(claimAmount == 0) return;

        unchecked{ claimableRewards[msg.sender] -= claimAmount; }

        pal.safeTransferFrom(rewardsVault, msg.sender, claimAmount);

        emit ClaimRewards(msg.sender, claimAmount);
    }

    function updateRewardState() external {
        if(emergency) revert EmergencyBlock();
        _updateRewardState();
    }

    function updateUserRewardState(address user) external {
        if(emergency) revert EmergencyBlock();
        _updateUserRewards(user);
    }


    function getNewReceiverCooldown(address sender, address receiver, uint256 amount) external view returns(uint256) {
        return _getNewReceiverCooldown(
            cooldowns[sender],
            amount,
            receiver,
            balanceOf(receiver)
        );
    }

    function getUserLockCount(address user) external view returns(uint256) {
        return userLocks[user].length;
    }

    function getUserLock(address user) external view returns(UserLock memory) {
        if(emergency || userLocks[user].length == 0) return UserLock(0, 0, 0, 0);
        return userLocks[user][userLocks[user].length - 1];
    }

    function getUserPastLock(address user, uint256 blockNumber) external view returns(UserLock memory) {
        if(emergency) return UserLock(0, 0, 0, 0);
        return _getPastLock(user, blockNumber);
    }

    function getTotalLockLength() external view returns(uint256){
        return totalLocks.length;
    }

    function getCurrentTotalLock() external view returns(TotalLock memory){
        if(emergency) return TotalLock(0, 0); //If the contract is blocked (emergency mode), return an empty totalLocked
        return totalLocks[totalLocks.length - 1];
    }

    function getPastTotalLock(uint256 blockNumber) external view returns(TotalLock memory) {
        if(blockNumber >= block.number) revert InvalidBlockNumber();

        TotalLock memory emptyLock = TotalLock(
            0,
            0
        );

        uint256 nbCheckpoints = totalLocks.length;

        if (totalLocks[nbCheckpoints - 1].fromBlock <= blockNumber) {
            return totalLocks[nbCheckpoints - 1];
        }

        if (totalLocks[0].fromBlock > blockNumber) {
            return emptyLock;
        }

        uint256 high = nbCheckpoints - 1; // last checkpoint already checked
        uint256 low;
        uint256 mid;
        while (low < high) {
            mid = Math.average(low, high);
            if (totalLocks[mid].fromBlock == blockNumber) {
                return totalLocks[mid];
            }
            if (totalLocks[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high == 0 ? emptyLock : totalLocks[high - 1];
    }

    function availableBalanceOf(address user) external view returns(uint256) {
        return _availableBalanceOf(user);
    }

    function allBalancesOf(address user) external view returns(
        uint256 staked,
        uint256 locked,
        uint256 available
    ) {
        uint256 userBalance = balanceOf(user);
        if(emergency || userLocks[user].length == 0) {
            return(
                userBalance,
                0,
                userBalance
            );
        }
        uint256 lastUserLockIndex = userLocks[user].length - 1;
        return(
            userBalance,
            uint256(userLocks[user][lastUserLockIndex].amount),
            userBalance - uint256(userLocks[user][lastUserLockIndex].amount)
        );
    }

    function estimateClaimableRewards(address user) external view returns(uint256) {
        if(emergency || user == address(0)) return 0;
        RewardState memory currentUserRewardState = userRewardStates[user];
        if(currentUserRewardState.lastUpdate == block.timestamp) return claimableRewards[user];

        uint256 estimatedClaimableRewards = claimableRewards[user];
        uint256 currentRewardIndex = currentUserRewardState.index;

        if(currentUserRewardState.lastUpdate < block.timestamp){
            currentRewardIndex = _getNewIndex(currentDropPerSecond);
        }

        (uint256 accruedRewards,) = _getUserAccruedRewards(user, currentUserRewardState, currentRewardIndex);

        estimatedClaimableRewards += accruedRewards;

        return estimatedClaimableRewards;
    }

    function rewardIndex() external view returns (uint256) {
        return globalRewards.index;
    }

    function lastRewardUpdate() external view returns (uint256) {
        return globalRewards.lastUpdate;
    }

    function userRewardIndex(address user) external view returns (uint256) {
        return userRewardStates[user].index;
    }

    function rewardsLastUpdate(address user) external view returns (uint256) {
        return userRewardStates[user].lastUpdate;
    }

    function numCheckpoints(address account) external view virtual returns (uint256){
        return checkpoints[account].length;
    }

    function getCurrentVotes(address user) external view returns (uint256) {
        if(emergency) return 0; //If emergency mode, do not show voting power

        uint256 nbCheckpoints = checkpoints[user].length;
        uint256 currentVotes = nbCheckpoints == 0 ? 0 : checkpoints[user][nbCheckpoints - 1].votes;

        uint256 nbLocks = userLocks[user].length;

        if(nbLocks == 0) return currentVotes;

        uint256 lockAmount = userLocks[user][nbLocks - 1].amount;
        uint256 bonusVotes = delegates[user] == user && userLocks[user][nbLocks - 1].duration >= ONE_YEAR ? (lockAmount * bonusLockVoteRatio) / UNIT : 0;

        return currentVotes + bonusVotes;
    }

    function getPastVotes(address user, uint256 blockNumber) external view returns(uint256) {
        uint256 votes = _getPastVotes(user, blockNumber);


        UserLock memory pastLock = _getPastLock(user, blockNumber);
        uint256 bonusVotes = getPastDelegate(user, blockNumber) == user && pastLock.duration >= ONE_YEAR ? (pastLock.amount * bonusLockVoteRatio) / UNIT : 0;

        return votes + bonusVotes;
    }

    function getPastDelegate(address account, uint256 blockNumber)
        public
        view
        returns (address)
    {
        if(blockNumber >= block.number) revert InvalidBlockNumber();

        uint256 nbCheckpoints = delegateCheckpoints[account].length;
        if (nbCheckpoints == 0) return address(0);

        if (delegateCheckpoints[account][nbCheckpoints - 1].fromBlock <= blockNumber) {
            return delegateCheckpoints[account][nbCheckpoints - 1].delegate;
        }

        if (delegateCheckpoints[account][0].fromBlock > blockNumber) {
            return address(0);
        }

        uint256 high = nbCheckpoints - 1; // last checkpoint already checked
        uint256 low;
        uint256 mid;
        while (low < high) {
            mid = Math.average(low, high);
            if (delegateCheckpoints[account][mid].fromBlock == blockNumber) {
                return delegateCheckpoints[account][mid].delegate;
            }
            if (delegateCheckpoints[account][mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high == 0 ? address(0) : delegateCheckpoints[account][high - 1].delegate;
    }


    function _assertNotContract(address addr) internal {
        if(addr != tx.origin){
            address checker = smartWalletChecker;
            if(checker != address(0)){
                if(SmartWalletChecker(checker).check(addr)){
                    return;
                }
                revert ContractNotAllowed();
            }
        }
    }

    function _availableBalanceOf(address user) internal view returns(uint256) {
        if(userLocks[user].length == 0) return balanceOf(user);
        return balanceOf(user) - uint256(userLocks[user][userLocks[user].length - 1].amount);
    }

    function _updateDropPerSecond() internal returns (uint256){
        if(block.timestamp > startDropTimestamp + dropDecreaseDuration) {
            if(currentDropPerSecond != endDropPerSecond) {
                currentDropPerSecond = endDropPerSecond;
                lastDropUpdate = block.timestamp;
            }

            return endDropPerSecond;
        }

        if(block.timestamp < lastDropUpdate + MONTH) return currentDropPerSecond; // Update it once a month

        uint256 dropDecreasePerMonth = ((startDropPerSecond - endDropPerSecond) * MONTH) / (dropDecreaseDuration);
        uint256 nbMonthEllapsed = (block.timestamp - lastDropUpdate) / MONTH;

        uint256 dropPerSecondDecrease = dropDecreasePerMonth * nbMonthEllapsed;

        uint256 newDropPerSecond = currentDropPerSecond - dropPerSecondDecrease > endDropPerSecond ? currentDropPerSecond - dropPerSecondDecrease : endDropPerSecond;
    
        currentDropPerSecond = newDropPerSecond;
        lastDropUpdate = lastDropUpdate + (nbMonthEllapsed * MONTH);

        return newDropPerSecond;
    }

    function _getNewIndex(uint256 _currentDropPerSecond) internal view returns (uint256){
        uint256 currentTotalSupply = totalSupply();
        RewardState memory currentRewardState = globalRewards;

        uint256 baseDropPerSecond = (_currentDropPerSecond * UNIT) / maxLockBonusRatio;

        uint256 accruedBaseAmount = (block.timestamp - currentRewardState.lastUpdate) * baseDropPerSecond;

        uint256 ratio = currentTotalSupply > 0 ? (accruedBaseAmount * UNIT) / currentTotalSupply : 0;

        return currentRewardState.index + ratio;
    }

    function _updateRewardState() internal returns (uint256){
        RewardState storage globalRewardState = globalRewards;
        if(globalRewardState.lastUpdate == block.timestamp) return globalRewardState.index; // Already updated for this block

        uint256 _currentDropPerSecond = _updateDropPerSecond();

        uint256 newIndex = _getNewIndex(_currentDropPerSecond);
        globalRewardState.index = safe128(newIndex);
        globalRewardState.lastUpdate = safe128(block.timestamp);

        return newIndex;
    }

    function _getUserAccruedRewards(
        address user,
        RewardState memory userRewardState,
        uint256 currentRewardsIndex
    ) internal view returns(
        uint256 accruedRewards,
        uint256 newBonusRatio
    ) {
        uint256 userLastIndex = userRewardState.index;
        uint256 userStakedBalance = _availableBalanceOf(user);
        uint256 userLockedBalance;

        if(userLastIndex != currentRewardsIndex){

            if(balanceOf(user) != 0){
                uint256 indexDiff = currentRewardsIndex - userLastIndex;

                uint256 lockingRewards;

                if(userLocks[user].length != 0){

                    uint256 lastUserLockIndex = userLocks[user].length - 1;

                    userLockedBalance = uint256(userLocks[user][lastUserLockIndex].amount);

                    if(userLockedBalance != 0 && userLocks[user][lastUserLockIndex].duration != 0){
                        uint256 previousBonusRatio = userCurrentBonusRatio[user];

                        if(previousBonusRatio > 0){
                            uint256 userRatioDecrease = userBonusRatioDecrease[user];
                            uint256 bonusRatioDecrease = (block.timestamp - userRewardState.lastUpdate) * userRatioDecrease;
                            
                            newBonusRatio = bonusRatioDecrease >= previousBonusRatio ? 0 : previousBonusRatio - bonusRatioDecrease;

                            if(bonusRatioDecrease >= previousBonusRatio){
                                bonusRatioDecrease = previousBonusRatio;
                            }

                            uint256 periodBonusRatio = newBonusRatio + ((userRatioDecrease + bonusRatioDecrease) / 2);
                            lockingRewards = ((userLockedBalance * (indexDiff * periodBonusRatio)) / UNIT) / UNIT;
                        }
                    }

                }
                accruedRewards = ((userStakedBalance * indexDiff) / UNIT) + lockingRewards;
            }
        }
    }

    function _updateUserRewards(address user) internal {
        if(emergency) return();

        uint256 newIndex = _updateRewardState();

        if(user == address(0)) return;

        RewardState storage userRewardState = userRewardStates[user];

        if(userRewardState.lastUpdate == block.timestamp) return; // Already updated for this block

        (uint256 accruedRewards, uint256 newBonusRatio) = _getUserAccruedRewards(user, userRewardState, newIndex);
        claimableRewards[user] += accruedRewards;
        userCurrentBonusRatio[user] = newBonusRatio;
        
        userRewardState.lastUpdate = safe128(block.timestamp);
        userRewardState.index = safe128(newIndex);

    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if(from != address(0)) { //check must be skipped on minting
            if(amount > _availableBalanceOf(from)) revert AvailableBalanceTooLow();
        }

        _updateUserRewards(from);

        uint256 fromCooldown = cooldowns[from]; //If from is address 0x00...0, cooldown is always 0 
        
        if(from != to) {
            _updateUserRewards(to);

            cooldowns[to] = _getNewReceiverCooldown(fromCooldown, amount, to, balanceOf(to));

            if(balanceOf(from) == amount && fromCooldown != 0) {
                cooldowns[from] = 0;
            }
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        _moveDelegates(delegates[from], delegates[to], amount);
    }

    function _getPastLock(address account, uint256 blockNumber) internal view returns(UserLock memory) {
        if(blockNumber >= block.number) revert InvalidBlockNumber();

        UserLock memory emptyLock = UserLock(
            0,
            0,
            0,
            0
        );

        uint256 nbCheckpoints = userLocks[account].length;
        if (nbCheckpoints == 0) return emptyLock;

        if (userLocks[account][nbCheckpoints - 1].fromBlock <= blockNumber) {
            return userLocks[account][nbCheckpoints - 1];
        }

        if (userLocks[account][0].fromBlock > blockNumber) {
            return emptyLock;
        }

        uint256 high = nbCheckpoints - 1; // last checkpoint already checked
        uint256 low;
        uint256 mid;
        while (low < high) {
            mid = Math.average(low, high);
            if (userLocks[account][mid].fromBlock == blockNumber) {
                return userLocks[account][mid];
            }
            if (userLocks[account][mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high == 0 ? emptyLock : userLocks[account][high - 1];
    }

    function _getPastVotes(address account, uint256 blockNumber) internal view returns (uint256){
        if(blockNumber >= block.number) revert InvalidBlockNumber();

        uint256 nbCheckpoints = checkpoints[account].length;
        if (nbCheckpoints == 0) return 0;

        if (checkpoints[account][nbCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nbCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) return 0;

        uint256 high = nbCheckpoints - 1; // last checkpoint already checked
        uint256 low;
        uint256 mid;
        while (low < high) {
            mid = Math.average(low, high);
            if (checkpoints[account][mid].fromBlock == blockNumber) {
                return checkpoints[account][mid].votes;
            }
            if (checkpoints[account][mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high == 0 ? 0 : checkpoints[account][high - 1].votes;
    }

    function _moveDelegates(address from, address to, uint256 amount) internal {
        if (from != to && amount != 0) {
            if (from != address(0)) {
                uint256 nbCheckpoints = checkpoints[from].length;
                uint256 oldVotes = nbCheckpoints == 0 ? 0 : checkpoints[from][nbCheckpoints - 1].votes;
                uint256 newVotes = oldVotes - amount;
                _writeCheckpoint(from, newVotes);
                emit DelegateVotesChanged(from, oldVotes, newVotes);
            }

            if (to != address(0)) {
                uint256 nbCheckpoints = checkpoints[to].length;
                uint256 oldVotes = nbCheckpoints == 0 ? 0 : checkpoints[to][nbCheckpoints - 1].votes;
                uint256 newVotes = oldVotes + amount;
                _writeCheckpoint(to, newVotes);
                emit DelegateVotesChanged(to, oldVotes, newVotes);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint256 newVotes) internal {
        uint pos = checkpoints[delegatee].length;

        if (pos > 0 && checkpoints[delegatee][pos - 1].fromBlock == block.number) {
            checkpoints[delegatee][pos - 1].votes = safe224(newVotes);
        } else {
            uint32 blockNumber = safe32(block.number);
            checkpoints[delegatee].push(Checkpoint(blockNumber, safe224(newVotes)));
        }
    }

    function _writeUserLock(
        address user,
        uint256 amount,
        uint256 startTimestamp,
        uint256 duration
    ) internal {
        uint256 pos = userLocks[user].length;
        if (pos > 0 && userLocks[user][pos - 1].fromBlock == block.number) {
            UserLock storage currentUserLock = userLocks[user][pos - 1];
            currentUserLock.amount = safe128(amount);
            currentUserLock.duration = safe48(duration);
            currentUserLock.startTimestamp = safe48(startTimestamp);
        } else {
            userLocks[user].push(
                UserLock(
                    safe128(amount),
                    safe48(startTimestamp),
                    safe48(duration),
                    safe32(block.number)
                )
            );
        }
    }

    function _writeTotalLocked(uint256 newTotalLocked) internal {
        uint256 pos = totalLocks.length;
        if (pos > 0 && totalLocks[pos - 1].fromBlock == block.number) {
            totalLocks[pos - 1].total = safe224(newTotalLocked);
        } else {
            totalLocks.push(TotalLock(
                safe224(newTotalLocked),
                safe32(block.number)
            ));
        }
    }


    function _stake(address user, uint256 amount) internal returns(uint256) {
        if(amount == 0) revert NullAmount();


        _mint(user, amount); //We mint hPAL 1:1 with PAL

        pal.safeTransferFrom(user, address(this), amount);

        emit Stake(user, amount);

        return amount;
    }

    function _unstake(address user, uint256 amount, address receiver) internal returns(uint256) {
        if(amount == 0) revert NullAmount();
        if(receiver == address(0)) revert AddressZero();

        uint256 userCooldown = cooldowns[user];
        if(block.timestamp <= (userCooldown + COOLDOWN_PERIOD)) revert InsufficientCooldown();
        if(block.timestamp - (userCooldown + COOLDOWN_PERIOD) > UNSTAKE_PERIOD) revert UnstakePeriodExpired();


        uint256 userAvailableBalance = _availableBalanceOf(user);
        uint256 burnAmount = amount > userAvailableBalance ? userAvailableBalance : amount;

        if(burnAmount == 0) revert AvailableBalanceTooLow();

        _burn(user, burnAmount);


        pal.safeTransfer(receiver, burnAmount);

        emit Unstake(user, burnAmount);

        return burnAmount;
    }

    function _getNewReceiverCooldown(
        uint256 senderCooldown,
        uint256 amount,
        address receiver,
        uint256 receiverBalance
    ) internal view returns(uint256) {
        uint256 receiverCooldown = cooldowns[receiver];

        if(amount == 0) return receiverCooldown;

        if(receiverCooldown == 0) return 0;

        uint256 minValidCooldown = block.timestamp - (COOLDOWN_PERIOD + UNSTAKE_PERIOD);

        if(receiverCooldown < minValidCooldown) return 0;

        uint256 _senderCooldown = senderCooldown < minValidCooldown ? block.timestamp : senderCooldown;

        if(_senderCooldown < receiverCooldown) return receiverCooldown;

        return ((amount * _senderCooldown) + (receiverBalance * receiverCooldown)) / (amount + receiverBalance);

    }

    enum LockAction { LOCK, INCREASE_AMOUNT, INCREASE_DURATION }

    function _lock(address user, uint256 amount, uint256 duration, LockAction action) internal {
        require(user != address(0)); //Never supposed to happen, but security check
        if(amount == 0) revert NullAmount();
        uint256 userBalance = balanceOf(user);
        if(amount > userBalance) revert AmountExceedBalance();
        if(duration < MIN_LOCK_DURATION) revert DurationUnderMin();
        if(duration > MAX_LOCK_DURATION) revert DurationOverMax();

        if(userLocks[user].length == 0){

            userLocks[user].push(UserLock(
                safe128(amount),
                safe48(block.timestamp),
                safe48(duration),
                safe32(block.number)
            ));

            uint256 durationRatio = ((duration - MIN_LOCK_DURATION) * UNIT) / (MAX_LOCK_DURATION - MIN_LOCK_DURATION);
            uint256 userLockBonusRatio = minLockBonusRatio + (((maxLockBonusRatio - minLockBonusRatio) * durationRatio) / UNIT);

            userCurrentBonusRatio[user] = userLockBonusRatio;
            userBonusRatioDecrease[user] = (userLockBonusRatio - baseLockBonusRatio) / duration;

            currentTotalLocked += amount;
            _writeTotalLocked(currentTotalLocked);

            emit Lock(user, amount, block.timestamp, duration, currentTotalLocked);
        } 
        else {
            UserLock memory currentUserLock = userLocks[user][userLocks[user].length - 1];
            uint256 userCurrentLockEnd = currentUserLock.startTimestamp + currentUserLock.duration;

            uint256 startTimestamp = block.timestamp;

            if(currentUserLock.amount == 0 || userCurrentLockEnd < block.timestamp) { 

                _writeUserLock(user, amount, startTimestamp, duration);
            }
            else {
                if(amount <  currentUserLock.amount) revert SmallerAmount();
                if(duration <  currentUserLock.duration) revert SmallerDuration();

                startTimestamp = action == LockAction.INCREASE_AMOUNT ? currentUserLock.startTimestamp : startTimestamp;
                _writeUserLock(user, amount, startTimestamp, duration);
            }

            if(action != LockAction.INCREASE_AMOUNT){
                uint256 durationRatio = ((duration - MIN_LOCK_DURATION) * UNIT) / (MAX_LOCK_DURATION - MIN_LOCK_DURATION);
                uint256 userLockBonusRatio = minLockBonusRatio + (((maxLockBonusRatio - minLockBonusRatio) * durationRatio) / UNIT);

                userCurrentBonusRatio[user] = userLockBonusRatio;
                userBonusRatioDecrease[user] = (userLockBonusRatio - baseLockBonusRatio) / duration;
            }
            
            if(amount != currentUserLock.amount){

                if(currentUserLock.amount != 0) currentTotalLocked -= currentUserLock.amount;
                
                currentTotalLocked += amount;
                _writeTotalLocked(currentTotalLocked);
            }

            emit Lock(user, amount, startTimestamp, duration, currentTotalLocked);
        }
    }

    function _unlock(address user) internal {
        require(user != address(0)); //Never supposed to happen, but security check
        if(userLocks[user].length == 0) revert NoLock();

        UserLock memory currentUserLock = userLocks[user][userLocks[user].length - 1];
        uint256 userCurrentLockEnd = currentUserLock.startTimestamp + currentUserLock.duration;

        if(block.timestamp <= userCurrentLockEnd) revert LockNotExpired();
        if(currentUserLock.amount == 0) revert EmptyLock();

        currentTotalLocked -= currentUserLock.amount;
        _writeTotalLocked(currentTotalLocked);

        userCurrentBonusRatio[user] = 0;
        userBonusRatioDecrease[user] = 0;

        _writeUserLock(user, 0, block.timestamp, 0);

        emit Unlock(user, currentUserLock.amount, currentTotalLocked);
    }

    function _kick(address user, address kicker) internal {
        if(user == address(0) || kicker == address(0)) revert AddressZero();
        if(userLocks[user].length == 0) revert NoLock();

        UserLock memory currentUserLock = userLocks[user][userLocks[user].length - 1];
        uint256 userCurrentLockEnd = currentUserLock.startTimestamp + currentUserLock.duration;

        if(block.timestamp <= userCurrentLockEnd) revert LockNotExpired();
        if(currentUserLock.amount == 0) revert EmptyLock();

        if(block.timestamp <= userCurrentLockEnd + UNLOCK_DELAY) revert LockNotKickable();

        currentTotalLocked -= currentUserLock.amount;
        _writeTotalLocked(currentTotalLocked);

        _writeUserLock(user, 0, block.timestamp, 0);

        userCurrentBonusRatio[user] = 0;
        userBonusRatioDecrease[user] = 0;

        uint256 nbWeeksOverLockTime = (block.timestamp - userCurrentLockEnd) / WEEK;
        uint256 penaltyPercent = nbWeeksOverLockTime * kickRatioPerWeek;
        uint256 penaltyAmount = penaltyPercent >= MAX_BPS ? 
            currentUserLock.amount : 
            (currentUserLock.amount * penaltyPercent) / MAX_BPS;

        _transfer(user, kicker, penaltyAmount);

        emit Kick(user, kicker, currentUserLock.amount, penaltyAmount, currentTotalLocked);
    }

    function _delegate(address delegator, address delegatee) internal {
        address oldDelegatee = delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
        delegates[delegator] = delegatee;

        uint pos = delegateCheckpoints[delegator].length;

        if (pos > 0 && delegateCheckpoints[delegator][pos - 1].fromBlock == block.number) {
            delegateCheckpoints[delegator][pos - 1].delegate = delegatee;
        } else {
            delegateCheckpoints[delegator].push(DelegateCheckpoint(safe32(block.number), delegatee));
        }

        emit DelegateChanged(delegator, oldDelegatee, delegatee);

        _moveDelegates(oldDelegatee, delegatee, delegatorBalance);
    }

    function emergencyWithdraw(uint256 amount, address receiver) external returns(uint256) {

        if(!emergency) revert NotEmergency();

        if(amount == 0) revert NullAmount();
        if(receiver == address(0)) revert AddressZero();

        if(userLocks[msg.sender].length != 0){
            UserLock storage currentUserLock = userLocks[msg.sender][userLocks[msg.sender].length - 1];

            if(currentUserLock.amount != 0 && currentUserLock.duration > 0){
                currentTotalLocked -= currentUserLock.amount;
                totalLocks.push(TotalLock(
                    safe224(currentTotalLocked),
                    safe32(block.number)
                ));

                userLocks[msg.sender].push(UserLock(
                    safe128(0),
                    safe48(block.timestamp),
                    safe48(0),
                    safe32(block.number)
                    ));

                userCurrentBonusRatio[msg.sender] = 0;
                userBonusRatioDecrease[msg.sender] = 0;
            }
        }

        uint256 userAvailableBalance = balanceOf(msg.sender);
        uint256 burnAmount = amount > userAvailableBalance ? userAvailableBalance : amount;

        _burn(msg.sender, burnAmount);

        pal.safeTransfer(receiver, burnAmount);

        emit EmergencyUnstake(msg.sender, burnAmount);

        return burnAmount;

    }


    error Exceed224Bits(); 
    error Exceed128Bits(); 
    error Exceed48Bits(); 
    error Exceed32Bits(); 

    function safe32(uint n) internal pure returns (uint32) {
        if(n > type(uint32).max) revert Exceed32Bits();
        return uint32(n);
    }

    function safe48(uint n) internal pure returns (uint48) {
        if(n > type(uint48).max) revert Exceed48Bits();
        return uint48(n);
    }

    function safe128(uint n) internal pure returns (uint128) {
        if(n > type(uint128).max) revert Exceed128Bits();
        return uint128(n);
    }

    function safe224(uint n) internal pure returns (uint224) {
        if(n > type(uint224).max) revert Exceed224Bits();
        return uint224(n);
    }


    error IncorrectParameters();
    error DecreaseDurationNotOver();

    function setKickRatio(uint256 newKickRatioPerWeek) external onlyOwner {
        if(newKickRatioPerWeek == 0 || newKickRatioPerWeek > 5000) revert IncorrectParameters();
        kickRatioPerWeek = newKickRatioPerWeek;
    }

    function triggerEmergencyWithdraw(bool trigger) external onlyOwner {
        emergency = trigger;
    }

    function setEndDropPerSecond(uint256 newEndDropPerSecond) external onlyOwner {
        if(block.timestamp < startDropTimestamp + dropDecreaseDuration) revert DecreaseDurationNotOver();
        endDropPerSecond = newEndDropPerSecond;
    }


    function commitSmartWalletChecker(address newSmartWalletChecker) external onlyOwner {
        futureSmartWalletChecker = newSmartWalletChecker;
    }


    function applySmartWalletChecker() external onlyOwner {
        smartWalletChecker = futureSmartWalletChecker;
    }
}