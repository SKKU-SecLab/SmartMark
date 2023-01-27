pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;




contract BaseBoringBatchable {

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function batch(bytes[] calldata calls, bool revertOnFail) external payable {

        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            if (!success && revertOnFail) {
                revert(_getRevertMsg(result));
            }
        }
    }
}

contract BoringBatchable is BaseBoringBatchable {

}// MIT
pragma solidity ^0.8.0;


library BoringERC20 {

    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_BALANCE_OF = 0x70a08231; // balanceOf(address)
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    function returnDataToString(bytes memory data) internal pure returns (string memory) {

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

    function safeSymbol(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_SYMBOL));
        return success ? returnDataToString(data) : "???";
    }

    function safeName(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_NAME));
        return success ? returnDataToString(data) : "???";
    }

    function safeDecimals(IERC20 token) internal view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_DECIMALS));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeBalanceOf(IERC20 token, address to) internal view returns (uint256 amount) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_BALANCE_OF, to));
        require(success && data.length >= 32, "BoringERC20: BalanceOf failed");
        amount = abi.decode(data, (uint256));
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
    }
}// MIT
pragma solidity ^0.8.0;


contract BoringOwnableData {

    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {

        if (direct) {
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {

        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}// MIT

pragma solidity ^0.8.0;

interface IRewarder {

    function onIOSTReward(uint256 pid, address user, address recipient, uint256 iostAmount, uint256 newLpAmount) external;

    function pendingTokens(uint256 pid, address user, uint256 iostAmount) external view returns (IERC20[] memory, uint256[] memory);

}// MIT

pragma solidity ^0.8.0;

library SafeMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {require((c = a + b) >= b, "SafeMath: Add Overflow");}

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {require((c = a - b) <= a, "SafeMath: Underflow");}

}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
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

library SignedSafeMath {

    function mul(int256 a, int256 b) internal pure returns (int256) {

        return a * b;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        return a + b;
    }
}// MIT

pragma solidity ^0.8.0;


interface IMigrator {

    function migrate(IERC20 token) external returns (IERC20);

}

contract IOSTFarmV1 is BoringOwnable, BoringBatchable {

    using SafeCast for uint256;
    using SafeMath for uint256;
    using SafeMath128 for uint128;
    using BoringERC20 for IERC20;
    using SignedSafeMath for int256;
    using SafeCast for int256;


    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    struct PoolInfo {
        uint128 accIOSTPerShare;
        uint64 lastRewardTime;
        uint64 allocPoint;
    }

    IERC20 public immutable IOST;
    IMigrator public migrator;

    PoolInfo[] public poolInfo;
    IERC20[] public lpToken;
    IRewarder[] public rewarder;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    mapping (address => bool) public addedTokens;

    uint256 public totalAllocPoint;

    uint256 public iostPerSecond;
    uint256 private constant ACC_IOST_PRECISION = 1e18;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, IERC20 indexed lpToken, IRewarder indexed rewarder);
    event LogSetPool(uint256 indexed pid, uint256 allocPoint, IRewarder indexed rewarder, bool overwrite);
    event LogUpdatePool(uint256 indexed pid, uint64 lastRewardTime, uint256 lpSupply, uint256 accIOSTPerShare);
    event LogIOSTPerSecond(uint256 iostPerSecond);

    constructor(IERC20 _IOST) {
        IOST = _IOST;
    }

    function poolLength() public view returns (uint256 pools) {

        pools = poolInfo.length;
    }

    function add(uint256 allocPoint, IERC20 _lpToken, IRewarder _rewarder) public onlyOwner {

        require(addedTokens[address(_lpToken)] == false, "Token already added");
        totalAllocPoint = totalAllocPoint.add(allocPoint);
        lpToken.push(_lpToken);
        rewarder.push(_rewarder);

        poolInfo.push(PoolInfo({
            allocPoint: allocPoint.toUint64(),
            lastRewardTime: block.timestamp.toUint64(),
            accIOSTPerShare: 0
        }));
        addedTokens[address(_lpToken)] = true;
        emit LogPoolAddition(lpToken.length.sub(1), allocPoint, _lpToken, _rewarder);
    }

    function set(uint256 _pid, uint256 _allocPoint, IRewarder _rewarder, bool overwrite) public onlyOwner {

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint.toUint64();
        if (overwrite) { rewarder[_pid] = _rewarder; }
        emit LogSetPool(_pid, _allocPoint, overwrite ? _rewarder : rewarder[_pid], overwrite);
    }

    function setIOSTPerSecond(uint256 _iostPerSecond) public onlyOwner {

        iostPerSecond = _iostPerSecond;
        emit LogIOSTPerSecond(_iostPerSecond);
    }

    function setMigrator(IMigrator _migrator) public onlyOwner {

        migrator = _migrator;
    }

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "IOSTFarmV1: no migrator set");
        IERC20 _lpToken = lpToken[_pid];
        uint256 bal = _lpToken.balanceOf(address(this));
        _lpToken.approve(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(_lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "IOSTFarmV1: migrated balance must match");
        require(addedTokens[address(newLpToken)] == false, "Token already added");
        addedTokens[address(newLpToken)] = true;
        addedTokens[address(_lpToken)] = false;
        lpToken[_pid] = newLpToken;
    }

    function pendingIOST(uint256 _pid, address _user) external view returns (uint256 pending) {

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accIOSTPerShare = pool.accIOSTPerShare;
        uint256 lpSupply = lpToken[_pid].balanceOf(address(this));
        if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            uint256 time = block.timestamp.sub(pool.lastRewardTime);
            uint256 IOSTReward = time.mul(iostPerSecond).mul(pool.allocPoint) / totalAllocPoint;
            accIOSTPerShare = accIOSTPerShare.add(IOSTReward.mul(ACC_IOST_PRECISION) / lpSupply);
        }
        pending = (user.amount.mul(accIOSTPerShare) / ACC_IOST_PRECISION).toInt256().sub(user.rewardDebt).toUint256();
    }

    function massUpdatePools(uint256[] calldata pids) external {

        uint256 len = pids.length;
        for (uint256 i = 0; i < len; ++i) {
            updatePool(pids[i]);
        }
    }

    function updatePool(uint256 pid) public returns (PoolInfo memory pool) {

        pool = poolInfo[pid];
        if (block.timestamp > pool.lastRewardTime) {
            uint256 lpSupply = lpToken[pid].balanceOf(address(this));
            if (lpSupply > 0) {
                uint256 time = block.timestamp.sub(pool.lastRewardTime);
                uint256 IOSTReward = time.mul(iostPerSecond).mul(pool.allocPoint) / totalAllocPoint;
                pool.accIOSTPerShare = pool.accIOSTPerShare.add((IOSTReward.mul(ACC_IOST_PRECISION) / lpSupply).toUint128());
            }
            pool.lastRewardTime = block.timestamp.toUint64();
            poolInfo[pid] = pool;
            emit LogUpdatePool(pid, pool.lastRewardTime, lpSupply, pool.accIOSTPerShare);
        }
    }

    function deposit(uint256 pid, uint256 amount, address to) public {

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][to];

        user.amount = user.amount.add(amount);
        user.rewardDebt = user.rewardDebt.add((amount.mul(pool.accIOSTPerShare) / ACC_IOST_PRECISION).toInt256());

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onIOSTReward(pid, to, to, 0, user.amount);
        }

        lpToken[pid].safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, pid, amount, to);
    }

    function withdraw(uint256 pid, uint256 amount, address to) public {

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];

        user.rewardDebt = user.rewardDebt.sub((amount.mul(pool.accIOSTPerShare) / ACC_IOST_PRECISION).toInt256());
        user.amount = user.amount.sub(amount);

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onIOSTReward(pid, msg.sender, to, 0, user.amount);
        }

        lpToken[pid].safeTransfer(to, amount);

        emit Withdraw(msg.sender, pid, amount, to);
    }

    function harvest(uint256 pid, address to) public {

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        int256 accumulatedIOST = int256(user.amount.mul(pool.accIOSTPerShare) / ACC_IOST_PRECISION);
        uint256 _pendingIOST = accumulatedIOST.sub(user.rewardDebt).toUint256();

        user.rewardDebt = accumulatedIOST;

        if (_pendingIOST != 0) {
            IOST.safeTransfer(to, _pendingIOST);
        }

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onIOSTReward( pid, msg.sender, to, _pendingIOST, user.amount);
        }

        emit Harvest(msg.sender, pid, _pendingIOST);
    }

    function withdrawAndHarvest(uint256 pid, uint256 amount, address to) public {

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        int256 accumulatedIOST = int256(user.amount.mul(pool.accIOSTPerShare) / ACC_IOST_PRECISION);
        uint256 _pendingIOST = accumulatedIOST.sub(user.rewardDebt).toUint256();

        user.rewardDebt = accumulatedIOST.sub(int256(amount.mul(pool.accIOSTPerShare) / ACC_IOST_PRECISION));
        user.amount = user.amount.sub(amount);

        IOST.safeTransfer(to, _pendingIOST);

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onIOSTReward(pid, msg.sender, to, _pendingIOST, user.amount);
        }

        lpToken[pid].safeTransfer(to, amount);

        emit Withdraw(msg.sender, pid, amount, to);
        emit Harvest(msg.sender, pid, _pendingIOST);
    }

    function emergencyWithdraw(uint256 pid, address to) public {

        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onIOSTReward(pid, msg.sender, to, 0, 0);
        }

        lpToken[pid].safeTransfer(to, amount);
        emit EmergencyWithdraw(msg.sender, pid, amount, to);
    }
}