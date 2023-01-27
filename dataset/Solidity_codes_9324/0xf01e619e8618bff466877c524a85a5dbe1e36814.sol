
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
}// MIT

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
pragma solidity 0.8.10;

interface IPool {

    struct Deposit {
        uint256 tokenAmount;
        uint256 weight;
        uint64 lockedFrom;
        uint64 lockedUntil;
        bool isYield;
    }

    function HIGH() external view returns (address);


    function poolToken() external view returns (address);


    function isFlashPool() external view returns (bool);


    function weight() external view returns (uint256);


    function lastYieldDistribution() external view returns (uint256);


    function yieldRewardsPerWeight() external view returns (uint256);


    function usersLockingWeight() external view returns (uint256);


    function pendingYieldRewards(address _user) external view returns (uint256);


    function balanceOf(address _user) external view returns (uint256);


    function getDeposit(address _user, uint256 _depositId) external view returns (Deposit memory);


    function getDepositsLength(address _user) external view returns (uint256);


    function stake(
        uint256 _amount,
        uint64 _lockedUntil
    ) external;


    function unstake(
        uint256 _depositId,
        uint256 _amount
    ) external;


    function sync() external;


    function processRewards() external;


    function setWeight(uint256 _weight) external;

}// MIT

pragma solidity 0.8.10;


interface ICorePool is IPool {

    function vaultRewardsPerToken() external view returns (uint256);


    function poolTokenReserve() external view returns (uint256);


    function stakeAsPool(address _staker, uint256 _amount) external;


    function receiveVaultRewards(uint256 _amount) external;

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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity 0.8.10;


contract HighStreetPoolFactory is Ownable {

    uint256 public constant FACTORY_UID = 0x484a992416a6637667452c709058dccce100b22b278536f5a6d25a14b6a1acdb;

    address public immutable HIGH;

    struct PoolData {
        address poolToken;
        address poolAddress;
        uint256 weight;
        bool isFlashPool;
    }

    uint256 public highPerBlock;

    uint256 public totalWeight;

    uint256 public immutable blocksPerUpdate;

    uint256 public endBlock;

    uint256 public lastRatioUpdate;

    mapping(address => address) public pools;

    mapping(address => bool) public poolExists;

    event PoolRegistered(
        address indexed _by,
        address indexed poolToken,
        address indexed poolAddress,
        uint256 weight,
        bool isFlashPool
    );

    event WeightUpdated(address indexed _by, address indexed poolAddress, uint256 weight);

    event HighRatioUpdated(address indexed _by, uint256 newHighPerBlock);

    event MintYield(address indexed _to, uint256 amount);

    constructor(
        address _high,
        uint256 _highPerBlock,
        uint256 _blocksPerUpdate,
        uint256 _initBlock,
        uint256 _endBlock
    ) {
        require(_high != address(0) , "HIGH is invalid");
        require(_highPerBlock > 0, "HIGH/block not set");
        require(_blocksPerUpdate > 0, "blocks/update not set");
        require(_initBlock > 0, "init block not set");
        require(_endBlock > _initBlock, "invalid end block: must be greater than init block");

        HIGH = _high;
        highPerBlock = _highPerBlock;
        blocksPerUpdate = _blocksPerUpdate;
        lastRatioUpdate = _initBlock;
        endBlock = _endBlock;
    }

    function getPoolAddress(address poolToken) external view returns (address) {

        return pools[poolToken];
    }

    function getPoolData(address _poolToken) external view returns (PoolData memory) {

        address poolAddr = pools[_poolToken];

        require(poolAddr != address(0), "pool not found");

        bool isFlashPool = IPool(poolAddr).isFlashPool();
        uint256 weight = IPool(poolAddr).weight();

        return PoolData({ poolToken: _poolToken, poolAddress: poolAddr, weight: weight, isFlashPool: isFlashPool });
    }

    function shouldUpdateRatio() public view returns (bool) {

        if (blockNumber() > endBlock) {
            return false;
        }

        return blockNumber() >= lastRatioUpdate + blocksPerUpdate;
    }

    function registerPool(address poolAddr) external onlyOwner {

        address poolToken = IPool(poolAddr).poolToken();
        bool isFlashPool = IPool(poolAddr).isFlashPool();
        uint256 weight = IPool(poolAddr).weight();

        require(pools[poolToken] == address(0), "this pool is already registered");

        pools[poolToken] = poolAddr;
        poolExists[poolAddr] = true;
        totalWeight += weight;

        emit PoolRegistered(msg.sender, poolToken, poolAddr, weight, isFlashPool);
    }

    function updateHighPerBlock() external {

        require(shouldUpdateRatio(), "too frequent");

        highPerBlock = (highPerBlock * 97) / 100;

        lastRatioUpdate = blockNumber();

        emit HighRatioUpdated(msg.sender, highPerBlock);
    }

    function mintYieldTo(address _to, uint256 _amount) external {

        require(poolExists[msg.sender], "access denied");

        transferHighToken(_to, _amount);

        emit MintYield(_to, _amount);
    }

    function changePoolWeight(address poolAddr, uint256 weight) external {

        require(msg.sender == owner() || poolExists[msg.sender]);

        totalWeight = totalWeight + weight - IPool(poolAddr).weight();

        IPool(poolAddr).setWeight(weight);

        emit WeightUpdated(msg.sender, poolAddr, weight);
    }

    function blockNumber() public view virtual returns (uint256) {

        return block.number;
    }

    function transferHighToken(address _to, uint256 _value) internal {

        SafeERC20.safeTransfer(IERC20(HIGH), _to, _value);
    }

}// MIT
pragma solidity 0.8.10;


abstract contract HighStreetPoolBase is IPool, ReentrancyGuard {
    struct User {
        uint256 tokenAmount;
        uint256 rewardAmount;
        uint256 totalWeight;
        uint256 subYieldRewards;
        uint256 subVaultRewards;
        Deposit[] deposits;
    }

    address public immutable override HIGH;

    mapping(address => User) public users;

    HighStreetPoolFactory public immutable factory;

    address public immutable override poolToken;

    uint256 public override weight;

    uint256 public override lastYieldDistribution;

    uint256 public override yieldRewardsPerWeight;

    uint256 public override usersLockingWeight;

    uint256 internal constant WEIGHT_MULTIPLIER = 1e24;

    uint256 internal constant YEAR_STAKE_WEIGHT_MULTIPLIER = 2 * WEIGHT_MULTIPLIER;

    uint256 internal constant REWARD_PER_WEIGHT_MULTIPLIER = 1e48;

    uint256 internal constant DEPOSIT_BATCH_SIZE  = 20;

    event Staked(address indexed _by, address indexed _from, uint256 amount);

    event StakeLockUpdated(address indexed _by, uint256 depositId, uint64 lockedFrom, uint64 lockedUntil);

    event Unstaked(address indexed _by, address indexed _to, uint256 amount);

    event Synchronized(address indexed _by, uint256 yieldRewardsPerWeight, uint256 lastYieldDistribution);

    event YieldClaimed(address indexed _by, address indexed _to, uint256 amount);

    event PoolWeightUpdated(uint256 _fromVal, uint256 _toVal);

    event EmergencyWithdraw(address indexed _by, uint256 amount);

    constructor(
        address _high,
        HighStreetPoolFactory _factory,
        address _poolToken,
        uint256 _initBlock,
        uint256 _weight
    ) {
        require(_high != address(0), "high token address not set");
        require(address(_factory) != address(0), "HIGH Pool fct address not set");
        require(_poolToken != address(0), "pool token address not set");
        require(_initBlock >= blockNumber(), "Invalid init block");
        require(_weight > 0, "pool weight not set");

        require(
            _factory.FACTORY_UID() == 0x484a992416a6637667452c709058dccce100b22b278536f5a6d25a14b6a1acdb,
            "unexpected FACTORY_UID"
        );

        HIGH = _high;
        factory = _factory;
        poolToken = _poolToken;
        weight = _weight;

        lastYieldDistribution = _initBlock;
    }

    function pendingYieldRewards(address _staker) external view override returns (uint256) {
        uint256 newYieldRewardsPerWeight;

        if (blockNumber() > lastYieldDistribution && usersLockingWeight != 0) {
            uint256 endBlock = factory.endBlock();
            uint256 multiplier =
                blockNumber() > endBlock ? endBlock - lastYieldDistribution : blockNumber() - lastYieldDistribution;
            uint256 highRewards = (multiplier * weight * factory.highPerBlock()) / factory.totalWeight();

            newYieldRewardsPerWeight = rewardToWeight(highRewards, usersLockingWeight) + yieldRewardsPerWeight;
        } else {
            newYieldRewardsPerWeight = yieldRewardsPerWeight;
        }

        User memory user = users[_staker];
        uint256 pending = weightToReward(user.totalWeight, newYieldRewardsPerWeight) - user.subYieldRewards;

        return pending;
    }

    function balanceOf(address _user) external view override returns (uint256) {
        return users[_user].tokenAmount;
    }

    function getDeposit(address _user, uint256 _depositId) external view override returns (Deposit memory) {
        return users[_user].deposits[_depositId];
    }

    function getDepositsBatch(address _user, uint256 _pageId) external view returns (Deposit[] memory) {
        uint256 pageStart = _pageId * DEPOSIT_BATCH_SIZE;
        uint256 pageEnd = (_pageId + 1) * DEPOSIT_BATCH_SIZE;
        uint256 pageLength = DEPOSIT_BATCH_SIZE;

        if(pageEnd > (users[_user].deposits.length - pageStart)) {
            pageEnd = users[_user].deposits.length;
            pageLength = pageEnd - pageStart;
        }

        Deposit[] memory deposits = new Deposit[](pageLength);
        for(uint256 i = pageStart; i < pageEnd; i++) {
            deposits[i-pageStart] = users[_user].deposits[i];
        }
        return deposits;
    }

    function getDepositsBatchLength(address _user) external view returns (uint256) {
        if(users[_user].deposits.length == 0) {
            return 0;
        }
        return 1 + (users[_user].deposits.length - 1) / DEPOSIT_BATCH_SIZE;
    }

    function getDepositsLength(address _user) external view override returns (uint256) {
        return users[_user].deposits.length;
    }

    function stake (
        uint256 _amount,
        uint64 _lockUntil
    ) external override nonReentrant {
        _stake(msg.sender, _amount, _lockUntil);
    }

    function unstake(
        uint256 _depositId,
        uint256 _amount
    ) external override nonReentrant {
        _unstake(msg.sender, _depositId, _amount);
    }

    function updateStakeLock(
        uint256 depositId,
        uint64 lockedUntil
    ) external nonReentrant {
        require(users[msg.sender].deposits[depositId].tokenAmount > 0, "Invalid amount");

        _sync();
        _processRewards(msg.sender, false);
        _updateStakeLock(msg.sender, depositId, lockedUntil);
    }

    function sync() external override {
        _sync();
    }

    function processRewards() external virtual override nonReentrant {
        _processRewards(msg.sender, true);
    }

    function setWeight(uint256 _weight) external override {
        require(msg.sender == address(factory), "access denied");

        emit PoolWeightUpdated(weight, _weight);

        weight = _weight;
    }

    function _pendingYieldRewards(address _staker) internal view returns (uint256 pending) {
        User memory user = users[_staker];

        return weightToReward(user.totalWeight, yieldRewardsPerWeight) - user.subYieldRewards;
    }

    function _stake(
        address _staker,
        uint256 _amount,
        uint64 _lockUntil
    ) internal virtual {
        require(_amount > 0, "zero amount");
        require(
            _lockUntil == 0 || (_lockUntil > now256() && _lockUntil - now256() <= 365 days),
            "invalid lock interval"
        );

        _sync();

        User storage user = users[_staker];
        if (user.tokenAmount > 0) {
            _processRewards(_staker, false);
        }


        uint256 previousBalance = IERC20(poolToken).balanceOf(address(this));
        transferPoolTokenFrom(msg.sender, address(this), _amount);
        uint256 newBalance = IERC20(poolToken).balanceOf(address(this));
        uint256 addedAmount = newBalance - previousBalance;

        uint64 lockFrom = _lockUntil > 0 ? uint64(now256()) : 0;
        uint64 lockUntil = _lockUntil;

        uint256 stakeWeight =
            (((lockUntil - lockFrom) * WEIGHT_MULTIPLIER) / 365 days + WEIGHT_MULTIPLIER) * addedAmount;

        require(stakeWeight > 0, "invalid stakeWeight");

        Deposit memory deposit =
            Deposit({
                tokenAmount: addedAmount,
                weight: stakeWeight,
                lockedFrom: lockFrom,
                lockedUntil: lockUntil,
                isYield: false
            });
        user.deposits.push(deposit);

        user.tokenAmount += addedAmount;
        user.totalWeight += stakeWeight;
        user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

        usersLockingWeight += stakeWeight;

        emit Staked(msg.sender, _staker, addedAmount);
    }

    function _unstake(
        address _staker,
        uint256 _depositId,
        uint256 _amount
    ) internal virtual {
        require(_amount > 0, "zero amount");

        User storage user = users[_staker];
        Deposit storage stakeDeposit = user.deposits[_depositId];
        bool isYield = stakeDeposit.isYield;

        require(stakeDeposit.tokenAmount >= _amount, "amount exceeds stake");

        _sync();
        _processRewards(_staker, false);

        uint256 previousWeight = stakeDeposit.weight;
        uint256 newWeight =
            (((stakeDeposit.lockedUntil - stakeDeposit.lockedFrom) * WEIGHT_MULTIPLIER) /
                365 days +
                WEIGHT_MULTIPLIER) * (stakeDeposit.tokenAmount - _amount);

        if (stakeDeposit.tokenAmount - _amount == 0) {
            delete user.deposits[_depositId];
        } else {
            stakeDeposit.tokenAmount -= _amount;
            stakeDeposit.weight = newWeight;
        }

        user.tokenAmount -= _amount;
        user.totalWeight = user.totalWeight - previousWeight + newWeight;
        user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

        usersLockingWeight = usersLockingWeight - previousWeight + newWeight;

        if (isYield) {
            user.rewardAmount -= _amount;
            factory.mintYieldTo(msg.sender, _amount);
        } else {
            transferPoolToken(msg.sender, _amount);
        }

        emit Unstaked(msg.sender, _staker, _amount);
    }

    function emergencyWithdraw() external nonReentrant {
        require(factory.totalWeight() == 0, "totalWeight != 0");

        _emergencyWithdraw(msg.sender);
    }

    function _emergencyWithdraw(
        address _staker
    ) internal virtual {
        User storage user = users[_staker];

        uint256 totalWeight = user.totalWeight ;
        uint256 amount = user.tokenAmount;
        uint256 reward = user.rewardAmount;

        user.tokenAmount = 0;
        user.rewardAmount = 0;
        user.totalWeight = 0;
        user.subYieldRewards = 0;

        delete user.deposits;

        usersLockingWeight = usersLockingWeight - totalWeight;

        transferPoolToken(msg.sender, amount - reward);
        factory.mintYieldTo(msg.sender, reward);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function _sync() internal virtual {
        if (factory.shouldUpdateRatio()) {
            factory.updateHighPerBlock();
        }

        uint256 endBlock = factory.endBlock();
        if (lastYieldDistribution >= endBlock) {
            return;
        }
        if (blockNumber() <= lastYieldDistribution) {
            return;
        }
        if (usersLockingWeight == 0) {
            lastYieldDistribution = blockNumber();
            return;
        }

        uint256 currentBlock = blockNumber() > endBlock ? endBlock : blockNumber();
        uint256 blocksPassed = currentBlock - lastYieldDistribution;
        uint256 highPerBlock = factory.highPerBlock();

        uint256 highReward = (blocksPassed * highPerBlock * weight) / factory.totalWeight();

        yieldRewardsPerWeight += rewardToWeight(highReward, usersLockingWeight);
        lastYieldDistribution = currentBlock;

        emit Synchronized(msg.sender, yieldRewardsPerWeight, lastYieldDistribution);
    }

    function _processRewards(
        address _staker,
        bool _withUpdate
    ) internal virtual returns (uint256 pendingYield) {
        if (_withUpdate) {
            _sync();
        }

        pendingYield = _pendingYieldRewards(_staker);

        if (pendingYield == 0) return 0;

        User storage user = users[_staker];

        if (poolToken == HIGH) {
            uint256 depositWeight = pendingYield * YEAR_STAKE_WEIGHT_MULTIPLIER;

            Deposit memory newDeposit =
                Deposit({
                    tokenAmount: pendingYield,
                    lockedFrom: uint64(now256()),
                    lockedUntil: uint64(now256() + 365 days), // staking yield for 1 year
                    weight: depositWeight,
                    isYield: true
                });
            user.deposits.push(newDeposit);

            user.tokenAmount += pendingYield;
            user.rewardAmount += pendingYield;
            user.totalWeight += depositWeight;

            usersLockingWeight += depositWeight;
        } else {
            address highPool = factory.getPoolAddress(HIGH);
            require(highPool != address(0),"invalid high pool address");
            ICorePool(highPool).stakeAsPool(_staker, pendingYield);
        }

        if (_withUpdate) {
            user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);
        }

        emit YieldClaimed(msg.sender, _staker, pendingYield);
    }

    function _updateStakeLock(
        address _staker,
        uint256 _depositId,
        uint64 _lockedUntil
    ) internal {
        require(_lockedUntil > now256(), "lock should be in the future");

        User storage user = users[_staker];
        Deposit storage stakeDeposit = user.deposits[_depositId];

        require(_lockedUntil > stakeDeposit.lockedUntil, "invalid new lock");

        if (stakeDeposit.lockedFrom == 0) {
            require(_lockedUntil - now256() <= 365 days, "max lock period is 365 days");
            stakeDeposit.lockedFrom = uint64(now256());
        } else {
            require(_lockedUntil - stakeDeposit.lockedFrom <= 365 days, "max lock period is 365 days");
        }

        stakeDeposit.lockedUntil = _lockedUntil;
        uint256 newWeight =
            (((stakeDeposit.lockedUntil - stakeDeposit.lockedFrom) * WEIGHT_MULTIPLIER) /
                365 days +
                WEIGHT_MULTIPLIER) * stakeDeposit.tokenAmount;

        uint256 previousWeight = stakeDeposit.weight;
        stakeDeposit.weight = newWeight;

        user.totalWeight = user.totalWeight - previousWeight + newWeight;
        usersLockingWeight = usersLockingWeight - previousWeight + newWeight;

        emit StakeLockUpdated(_staker, _depositId, stakeDeposit.lockedFrom, _lockedUntil);
    }

    function weightToReward(uint256 _weight, uint256 rewardPerWeight) public pure returns (uint256) {
        return (_weight * rewardPerWeight) / REWARD_PER_WEIGHT_MULTIPLIER;
    }

    function rewardToWeight(uint256 reward, uint256 rewardPerWeight) public pure returns (uint256) {
        return (reward * REWARD_PER_WEIGHT_MULTIPLIER) / rewardPerWeight;
    }

    function blockNumber() public view virtual returns (uint256) {
        return block.number;
    }

    function now256() public view virtual returns (uint256) {
        return block.timestamp;
    }

    function transferPoolToken(address _to, uint256 _value) internal {
        SafeERC20.safeTransfer(IERC20(poolToken), _to, _value);
    }

    function transferPoolTokenFrom(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        SafeERC20.safeTransferFrom(IERC20(poolToken), _from, _to, _value);
    }
}// MIT

pragma solidity 0.8.10;


contract HighStreetCorePool is HighStreetPoolBase {

    bool public constant override isFlashPool = false;

    address public vault;

    uint256 public vaultRewardsPerWeight;

    uint256 public poolTokenReserve;

    event VaultRewardsReceived(address indexed _by, uint256 amount);

    event VaultRewardsClaimed(address indexed _by, address indexed _to, uint256 amount);

    event VaultUpdated(address indexed _by, address _fromVal, address _toVal);

    constructor(
        address _high,
        HighStreetPoolFactory _factory,
        address _poolToken,
        uint256 _initBlock,
        uint256 _weight
    ) HighStreetPoolBase(_high, _factory, _poolToken, _initBlock, _weight) {}

    function pendingVaultRewards(address _staker) public view returns (uint256 pending) {

        User memory user = users[_staker];

        return weightToReward(user.totalWeight, vaultRewardsPerWeight) - user.subVaultRewards;
    }

    function setVault(address _vault) external {

        require(factory.owner() == msg.sender, "access denied");

        require(_vault != address(0), "zero input");

        emit VaultUpdated(msg.sender, vault, _vault);

        vault = _vault;
    }

    function receiveVaultRewards(uint256 _rewardsAmount) external {

        require(msg.sender == vault, "access denied");
        if (_rewardsAmount == 0) {
            return;
        }
        require(usersLockingWeight > 0, "zero locking weight");

        transferHighTokenFrom(msg.sender, address(this), _rewardsAmount);

        vaultRewardsPerWeight += rewardToWeight(_rewardsAmount, usersLockingWeight);

        if (poolToken == HIGH) {
            poolTokenReserve += _rewardsAmount;
        }

        emit VaultRewardsReceived(msg.sender, _rewardsAmount);
    }

    function processRewards() external override nonReentrant{

        _processRewards(msg.sender, true);
        User storage user = users[msg.sender];
        user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);
    }

    function stakeAsPool(address _staker, uint256 _amount) external {

        require(factory.poolExists(msg.sender), "access denied");
        require(poolToken == HIGH, "not HIGH token pool");

        _sync();
        User storage user = users[_staker];
        if (user.tokenAmount > 0) {
            _processRewards(_staker, false);
        }
        uint256 depositWeight = _amount * YEAR_STAKE_WEIGHT_MULTIPLIER;
        Deposit memory newDeposit =
            Deposit({
                tokenAmount: _amount,
                lockedFrom: uint64(now256()),
                lockedUntil: uint64(now256() + 365 days),
                weight: depositWeight,
                isYield: true
            });
        user.tokenAmount += _amount;
        user.rewardAmount += _amount;
        user.totalWeight += depositWeight;
        user.deposits.push(newDeposit);

        usersLockingWeight += depositWeight;

        user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);
        user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);

        poolTokenReserve += _amount;
    }

    function _stake(
        address _staker,
        uint256 _amount,
        uint64 _lockedUntil
    ) internal override {

        super._stake(_staker, _amount, _lockedUntil);
        User storage user = users[_staker];
        user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);

        poolTokenReserve += _amount;
    }

    function _unstake(
        address _staker,
        uint256 _depositId,
        uint256 _amount
    ) internal override {

        User storage user = users[_staker];
        Deposit memory stakeDeposit = user.deposits[_depositId];
        require(stakeDeposit.lockedFrom == 0 || now256() > stakeDeposit.lockedUntil, "deposit not yet unlocked");
        poolTokenReserve -= _amount;
        super._unstake(_staker, _depositId, _amount);
        user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);
    }

    function _emergencyWithdraw(
        address _staker
    ) internal override {

        User storage user = users[_staker];
        uint256 amount = user.tokenAmount;

        poolTokenReserve -= amount;
        super._emergencyWithdraw(_staker);
        user.subVaultRewards = 0;
    }

    function _processRewards(
        address _staker,
        bool _withUpdate
    ) internal override returns (uint256 pendingYield) {

        _processVaultRewards(_staker);
        pendingYield = super._processRewards(_staker, _withUpdate);

        if (poolToken == HIGH) {
            poolTokenReserve += pendingYield;
        }
    }

    function _processVaultRewards(address _staker) private {

        User storage user = users[_staker];
        uint256 pendingVaultClaim = pendingVaultRewards(_staker);
        if (pendingVaultClaim == 0) return;
        uint256 highBalance = IERC20(HIGH).balanceOf(address(this));
        require(highBalance >= pendingVaultClaim, "contract HIGH balance too low");

        if (poolToken == HIGH) {
            poolTokenReserve -= pendingVaultClaim > poolTokenReserve ? poolTokenReserve : pendingVaultClaim;
        }

        user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);

        transferHighToken(_staker, pendingVaultClaim);

        emit VaultRewardsClaimed(msg.sender, _staker, pendingVaultClaim);
    }

    function transferHighToken(address _to, uint256 _value) internal {

        SafeERC20.safeTransfer(IERC20(HIGH), _to, _value);
    }

    function transferHighTokenFrom(
        address _from,
        address _to,
        uint256 _value
    ) internal {

        SafeERC20.safeTransferFrom(IERC20(HIGH), _from, _to, _value);
    }
}