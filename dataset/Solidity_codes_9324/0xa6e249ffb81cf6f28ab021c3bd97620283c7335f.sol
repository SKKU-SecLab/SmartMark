
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
pragma solidity ^0.8.0;

interface IBoringERC20 {

    function mint(address to, uint256 amount) external;


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender)
    external
    view
    returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// MIT
pragma solidity ^0.8.0;


library BoringERC20 {

    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    function returnDataToString(bytes memory data)
    internal
    pure
    returns (string memory)
    {

        if (data.length >= 64) {
            return abi.decode(data, (string));
        } else if (data.length == 32) {
            uint8 i = 0;
            while (i < 32 && data[i] != 0) {
                i++;
            }
            bytes memory bytesArray = new bytes(i);
            for (i = 0; i < 32 && data[i] != 0; i++) {
                bytesArray[i] = data[i];
            }
            return string(bytesArray);
        } else {
            return "???";
        }
    }

    function safeSymbol(IBoringERC20 token)
    internal
    view
    returns (string memory)
    {

        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(SIG_SYMBOL)
        );
        return success ? returnDataToString(data) : "???";
    }

    function safeName(IBoringERC20 token)
    internal
    view
    returns (string memory)
    {

        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(SIG_NAME)
        );
        return success ? returnDataToString(data) : "???";
    }


    function safeDecimals(IBoringERC20 token) internal view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(SIG_DECIMALS)
        );
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(
        IBoringERC20 token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(SIG_TRANSFER, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "BoringERC20: Transfer failed"
        );
    }

    function safeTransferFrom(
        IBoringERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "BoringERC20: TransferFrom failed"
        );
    }
}// MIT
pragma solidity ^0.8.7;


contract TokenFarm is Ownable, ReentrancyGuard {

    using BoringERC20 for IBoringERC20;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount; // How many Staking tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IBoringERC20 stakingToken; // Address of Staking token contract.
        IBoringERC20 rewardToken; // Address of Reward token contract
        uint256 precision; //reward token precision
        uint256 startTimestamp; // start timestamp of the pool
        uint256 lastRewardTimestamp; // Last timestamp that Reward Token distribution occurs.
        uint256 accRewardPerShare; // Accumulated Reward Token per share. See below.
        uint256 totalStaked; // total staked amount each pool's stake token, typically, each pool has the same stake token, so need to track it separatedly
        uint256 totalRewards;
    }

    struct RewardInfo {
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 rewardPerSec;
    }

    PoolInfo[] public poolInfo;

    mapping(uint256 => RewardInfo[]) public poolRewardInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public rewardInfoLimit;

    event Deposit(address indexed user, uint256 amount, uint256 pool, uint256 accRewardPerShare, uint256 rewardDebit);
    event Withdraw(address indexed user, uint256 amount, uint256 pool, uint256 accRewardPerShare, uint256 rewardDebit);
    event EmergencyWithdraw(
        address indexed user,
        uint256 amount,
        uint256 pool
    );
    event AddPoolInfo(
        uint256 indexed poolID,
        IBoringERC20 stakingToken,
        IBoringERC20 rewardToken,
        uint256 startTimestamp,
        uint256 precision
    );

    event AddRewardInfo(
        uint256 indexed poolID,
        uint256 indexed phase,
        uint256 endTimestamp,
        uint256 rewardPerTimestamp
    );
    event UpdatePoolInfo(uint256 indexed poolID, uint256 indexed lastRewardTimestamp);
    event SetRewardInfoLimit(uint256 rewardInfoLimit);

    constructor() {
        rewardInfoLimit = 53;
    }

    function setRewardInfoLimit(uint256 _updatedRewardInfoLimit)
    external
    onlyOwner
    {

        rewardInfoLimit = _updatedRewardInfoLimit;
        emit SetRewardInfoLimit(rewardInfoLimit);
    }

    function addPoolInfo(
        IBoringERC20 _stakingToken,
        IBoringERC20 _rewardToken
    ) external onlyOwner {

        uint256 decimalsRewardToken = uint256(_rewardToken.safeDecimals());

        require(
            decimalsRewardToken < 30,
            "constructor: reward token decimals must be inferior to 30"
        );

        uint256 precision = uint256(10**(uint256(30) - (decimalsRewardToken)));

        poolInfo.push(
            PoolInfo({
                stakingToken: _stakingToken,
                rewardToken: _rewardToken,
                precision: precision,
                startTimestamp: block.timestamp,
                lastRewardTimestamp: block.timestamp,
                accRewardPerShare: 0,
                totalStaked: 0,
                totalRewards: 0
            })
        );
        emit AddPoolInfo(
            poolInfo.length - 1,
            _stakingToken,
            _rewardToken,
            block.timestamp,
            precision
        );
    }

    function addRewardInfo(
        uint256 _pid,
        uint256 _endTimestamp,
        uint256 _rewardPerSec
    ) external onlyOwner {

        RewardInfo[] storage rewardInfo = poolRewardInfo[_pid];
        PoolInfo storage pool = poolInfo[_pid];
        require(
            rewardInfo.length < rewardInfoLimit,
            "addRewardInfo::reward info length exceeds the limit"
        );
        require(
            rewardInfo.length == 0 ||
            rewardInfo[rewardInfo.length - 1].endTimestamp >=
            block.timestamp,
            "addRewardInfo::reward period ended"
        );
        require(
            rewardInfo.length == 0 ||
            rewardInfo[rewardInfo.length - 1].endTimestamp < _endTimestamp,
            "addRewardInfo::bad new endTimestamp"
        );
        uint256 startTimestamp = rewardInfo.length == 0
        ? pool.startTimestamp
        : rewardInfo[rewardInfo.length - 1].endTimestamp;

        uint256 timeRange = _endTimestamp.sub(startTimestamp);

        uint256 totalRewards = timeRange.mul(_rewardPerSec);
        pool.rewardToken.safeTransferFrom(
            msg.sender,
            address(this),
            totalRewards
        );
        pool.totalRewards = pool.totalRewards.add(totalRewards);

        rewardInfo.push(
            RewardInfo({
                startTimestamp: startTimestamp,
                endTimestamp: _endTimestamp,
                rewardPerSec: _rewardPerSec
            })
        );

        emit AddRewardInfo(
            _pid,
            rewardInfo.length - 1,
            _endTimestamp,
            _rewardPerSec
        );
    }

    function rewardInfoLen(uint256 _pid)
    external
    view
    returns (uint256)
    {

        return poolRewardInfo[_pid].length;
    }

    function poolInfoLen() external view returns (uint256) {

        return poolInfo.length;
    }

    function currentEndTimestamp(uint256 _pid)
    external
    view
    returns (uint256)
    {

        return _endTimestampOf(_pid, block.timestamp);
    }

    function _endTimestampOf(uint256 _pid, uint256 _timestamp)
    internal
    view
    returns (uint256)
    {

        RewardInfo[] memory rewardInfo = poolRewardInfo[_pid];
        uint256 len = rewardInfo.length;
        if (len == 0) {
            return 0;
        }
        for (uint256 i = 0; i < len; ++i) {
            if (_timestamp <= rewardInfo[i].endTimestamp)
                return rewardInfo[i].endTimestamp;
        }

        return rewardInfo[len - 1].endTimestamp;
    }

    function currentRewardPerSec(uint256 _pid)
    external
    view
    returns (uint256)
    {

        return _rewardPerSecOf(_pid, block.timestamp);
    }

    function _rewardPerSecOf(uint256 _pid, uint256 _blockTimestamp)
    internal
    view
    returns (uint256)
    {

        RewardInfo[] memory rewardInfo = poolRewardInfo[_pid];
        uint256 len = rewardInfo.length;
        if (len == 0) {
            return 0;
        }
        for (uint256 i = 0; i < len; ++i) {
            if (_blockTimestamp <= rewardInfo[i].endTimestamp)
                return rewardInfo[i].rewardPerSec;
        }
        return 0;
    }

    function getMultiplier(
        uint256 _from,
        uint256 _to,
        uint256 _endTimestamp
    ) public pure returns (uint256) {

        if ((_from >= _endTimestamp) || (_from > _to)) {
            return 0;
        }
        if (_to <= _endTimestamp) {
            return _to - _from;
        }
        return _endTimestamp - _from;
    }

    function pendingReward(uint256 _pid, address _user)
    external
    view
    returns (uint256)
    {

        return
        _pendingReward(
            _pid,
            userInfo[_pid][_user].amount,
            userInfo[_pid][_user].rewardDebt
        );
    }


    function _pendingReward(
        uint256 _pid,
        uint256 _amount,
        uint256 _rewardDebt
    ) internal view returns (uint256) {

        PoolInfo memory pool = poolInfo[_pid];
        RewardInfo[] memory rewardInfo = poolRewardInfo[_pid];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        if (
            block.timestamp > pool.lastRewardTimestamp &&
            pool.totalStaked != 0
        ) {
            uint256 cursor = pool.lastRewardTimestamp;
            for (uint256 i = 0; i < rewardInfo.length; ++i) {
                uint256 multiplier = getMultiplier(
                    cursor,
                    block.timestamp,
                    rewardInfo[i].endTimestamp
                );
                if (multiplier == 0) continue;
                cursor = rewardInfo[i].endTimestamp;
                uint256 tokenReward = multiplier.mul(rewardInfo[i].rewardPerSec);
                accRewardPerShare = accRewardPerShare.add(tokenReward.mul(pool.precision).div(pool.totalStaked));
            }
        }

        return uint256(_amount.mul(accRewardPerShare).div(pool.precision)).sub(_rewardDebt);
    }

    function updatePool(uint256 _pid) external nonReentrant {

        _updatePool(_pid);
    }

    function _updatePool(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        RewardInfo[] memory rewardInfo = poolRewardInfo[_pid];
        if (block.timestamp <= pool.lastRewardTimestamp) {
            return;
        }
        if (pool.totalStaked == 0) {
            if (
                block.timestamp > _endTimestampOf(_pid, block.timestamp)
            ) {
                pool.lastRewardTimestamp = block.timestamp;
            }
            return;
        }
        for (uint256 i = 0; i < rewardInfo.length; ++i) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardTimestamp,
                block.timestamp,
                rewardInfo[i].endTimestamp
            );
            if (multiplier == 0) continue;
            if (block.timestamp > rewardInfo[i].endTimestamp) {
                pool.lastRewardTimestamp = rewardInfo[i].endTimestamp;
            } else {
                pool.lastRewardTimestamp = block.timestamp;
            }
            uint256 tokenReward = multiplier.mul(rewardInfo[i].rewardPerSec);
            pool.accRewardPerShare = pool.accRewardPerShare.add(tokenReward.mul(pool.precision).div(pool.totalStaked));
        }
        emit UpdatePoolInfo(_pid, pool.lastRewardTimestamp);
    }

    function massUpdateCampaigns() external nonReentrant {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    function deposit(uint256 _pid, uint256 _amount)
    external
    nonReentrant
    {

        _deposit(_pid, _amount);
    }

    function _deposit(uint256 _pid, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        _updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = uint256(user.amount.mul(pool.accRewardPerShare).div(pool.precision)).sub(user.rewardDebt);
            if (pending > 0) {
                pool.rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }
        if (_amount > 0) {
            pool.stakingToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            pool.totalStaked = pool.totalStaked.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(pool.precision);
        emit Deposit(msg.sender, _amount, _pid, pool.accRewardPerShare, user.rewardDebt);
    }

    function withdraw(uint256 _pid, uint256 _amount)
    external
    nonReentrant
    {

        _withdraw(_pid, _amount);
    }

    function _withdraw(uint256 _pid, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw::bad withdraw amount");
        _updatePool(_pid);
        uint256 pending = uint256(user.amount.mul(pool.accRewardPerShare).div(pool.precision)).sub(user.rewardDebt);
        if (pending > 0) {
            pool.rewardToken.safeTransfer(address(msg.sender), pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.stakingToken.safeTransfer(address(msg.sender), _amount);
            pool.totalStaked = pool.totalStaked.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(pool.precision);

        emit Withdraw(msg.sender, _amount, _pid, pool.accRewardPerShare, user.rewardDebt);
    }

    function harvest(uint256 _pid) external nonReentrant {

        _withdraw(_pid, 0);
    }

    function emergencyWithdraw(uint256 _pid) external nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        pool.totalStaked = pool.totalStaked.sub(_amount);
        user.amount = 0;
        user.rewardDebt = 0;
        pool.stakingToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _amount, _pid);
    }

    function rescueFunds(uint256 _pid, address _beneficiary) external onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 amount = pool.rewardToken.balanceOf(address(this));
        pool.rewardToken.safeTransfer(_beneficiary, amount);
    }
}