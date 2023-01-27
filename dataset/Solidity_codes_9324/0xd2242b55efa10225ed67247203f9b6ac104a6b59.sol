
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

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT
pragma solidity ^0.8.7;

struct Set {
    uint256[] _values;
    mapping(uint256 => uint256) _indexes;
}

library UintSet {

    function add(Set storage set, uint256 value) internal returns (bool) {

        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(Set storage set, uint256 value) internal returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                uint256 lastvalue = set._values[lastIndex];

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

    function contains(Set storage set, uint256 value)
        internal
        view
        returns (bool)
    {

        return set._indexes[value] != 0;
    }

    function length(Set storage set) internal view returns (uint256) {

        return set._values.length;
    }

    function at(Set storage set, uint256 index)
        internal
        view
        returns (uint256)
    {

        return set._values[index];
    }

    function getArray(Set storage set)
        internal
        view
        returns (uint256[] memory)
    {

        return set._values;
    }
}// MIT
pragma solidity ^0.8.7;


contract FixStaking is AccessControl, Pausable {

    using UintSet for Set;

    event RemovePool(uint256 poolIndex);
    event SetMinMax(uint256 minStake, uint256 maxStake);
    event SetPenDay(uint256 penaltyDuration);
    event PoolFunded(uint256 poolIndex, uint256 fundAmount);
    event ReserveWithdrawed(uint256 poolIndex);
    event Claimed(
        address user,
        uint256 depositAmountIncludePen,
        uint256 reward,
        uint256 stakerIndex,
        uint256 poolIndex
    );
    event Deposit(
        address indexed staker,
        uint256 amount,
        uint256 startTime,
        uint256 closedTime,
        uint256 indexed poolIndex,
        uint256 indexed stakerIndex
    );

    event Restake(
        address indexed staker,
        uint256 amount,
        uint256 indexed poolIndex,
        uint256 indexed stakerIndex
    );

    event Withdraw(
        address indexed staker,
        uint256 withdrawAmount,
        uint256 reward,
        uint256 mainPenaltyAmount,
        uint256 subPenaltyAmount,
        uint256 indexed poolIndex,
        uint256 indexed stakerIndex
    );

    event EmergencyWithdraw(
        address indexed staker,
        uint256 withdrawAmount,
        uint256 reward,
        uint256 mainPenaltyAmount,
        uint256 subPenaltyAmount,
        uint256 indexed poolIndex,
        uint256 indexed stakerIndex
    );
    event NewPool(
        uint256 indexed poolIndex,
        uint256 startTime,
        uint256 duration,
        uint256 apy,
        uint256 mainPenaltyRate,
        uint256 subPenaltyRate,
        uint256 lockedLimit,
        uint256 promisedReward,
        bool nftReward
    );

    struct PoolInfo {
        uint256 startTime;
        uint256 duration;
        uint256 apy;
        uint256 mainPenaltyRate;
        uint256 subPenaltyRate;
        uint256 lockedLimit;
        uint256 stakedAmount;
        uint256 reserve;
        uint256 promisedReward;
        bool nftReward;
    }

    struct StakerInfo {
        uint256 poolIndex;
        uint256 startTime;
        uint256 amount;
        uint256 lastIndex;
        uint256 pendingStart;
        uint256 reward;
        bool isFinished;
        bool pendingRequest;
    }

    mapping(address => mapping(uint256 => StakerInfo)) public stakers;
    mapping(address => uint256) public currentStakerIndex;

    mapping(address => mapping(uint256 => uint256)) public amountByPool;

    uint256 public minStake;

    uint256 public maxStake;

    uint256 public penaltyDuration;
    PoolInfo[] public pools;

    IERC20 public token;
    uint256 private unlocked = 1;

    modifier isPoolExist(uint256 _poolIndex) {

        require(
            pools[_poolIndex].startTime > 0,
            "isPoolExist: This pool not exist"
        );
        _;
    }

    modifier isFinished(address _user, uint256 _stakerIndex) {

        StakerInfo memory staker = stakers[_user][_stakerIndex];
        require(
            staker.isFinished == false,
            "isFinished: This index already finished."
        );
        _;
    }

    modifier isValid(
        uint256 _startTime,
        uint256 _duration,
        uint256 _apy
    ) {

        require(
            _startTime >= block.timestamp,
            "isValid: Start time must be greater than current time"
        );
        require(_duration != 0, "isValid: duration can not be ZERO.");
        require(_apy != 0, "isValid: Apy can not be ZERO.");

        _;
    }

    modifier lock() {

        require(unlocked == 1, "FixStaking: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(address _token) {
        require(_token != address(0), "FixStaking: token can not be ZERO.");
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        token = IERC20(_token);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {

        _pause();
    }

    function unPause() external onlyRole(DEFAULT_ADMIN_ROLE) {

        _unpause();
    }

    function setMinMaxStake(uint256 _minStake, uint256 _maxStake)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(
            _minStake >= 0,
            "setMinMaxStake: minumum amount cannot be ZERO"
        );
        require(
            _maxStake > _minStake,
            "setMinMaxStake: maximum amount cannot be lower than minimum amount"
        );

        minStake = _minStake;
        maxStake = _maxStake;
        emit SetMinMax(_minStake, _maxStake);
    }

    function setPenaltyDuration(uint256 _duration)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(
            _duration <= 5 days,
            "setPenaltyDuration: duration must be less than 5 days"
        );
        penaltyDuration = _duration;

        emit SetPenDay(_duration);
    }

    function fundPool(uint256 _poolIndex, uint256 _fundingAmount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        isPoolExist(_poolIndex)
    {

        require(
            token.transferFrom(msg.sender, address(this), _fundingAmount),
            "fundPool: token transfer failed."
        );

        pools[_poolIndex].reserve += _fundingAmount;

        emit PoolFunded(_poolIndex, _fundingAmount);
    }

    function withdrawERC20(address _token, uint256 _amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(
            _token != address(token),
            "withdrawERC20: token can not be Reward Token."
        );
        require(
            IERC20(_token).transfer(msg.sender, _amount),
            "withdrawERC20: Transfer failed"
        );
    }

    function withdrawFunds(uint256 _poolIndex, uint256 _amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        PoolInfo memory pool = pools[_poolIndex];
        require(
            pool.reserve - pool.promisedReward >= _amount,
            "withdrawFunds: Amount should be lower that promised rewards."
        );

        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "withdrawFunds: token transfer failed."
        );
    }

    function createPool(
        uint256 _startTime,
        uint256 _duration,
        uint256 _apy,
        uint256 _mainPenaltyRate,
        uint256 _subPenaltyRate,
        uint256 _lockedLimit,
        bool _nftReward
    )
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        isValid(_startTime, _duration, _apy)
    {

        PoolInfo memory pool = PoolInfo(
            _startTime,
            _duration,
            _apy,
            _mainPenaltyRate,
            _subPenaltyRate,
            _lockedLimit,
            0,
            0,
            0,
            _nftReward
        );

        pools.push(pool);

        uint256 poolIndex = pools.length - 1;

        emit NewPool(
            poolIndex,
            _startTime,
            _duration,
            _apy,
            _mainPenaltyRate,
            _subPenaltyRate,
            _lockedLimit,
            pool.promisedReward,
            _nftReward
        );
    }

    function editPool(
        uint256 _poolIndex,
        uint256 _startTime,
        uint256 _duration,
        uint256 _apy,
        uint256 _mainPenaltyRate,
        uint256 _subPenaltyRate,
        uint256 _lockedLimit,
        bool _nftReward
    )
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        isPoolExist(_poolIndex)
        isValid(_startTime, _duration, _apy)
    {

        require(
            _mainPenaltyRate == 0,
            "editPool: main penalty rate must be equal to 0"
        );
        PoolInfo storage pool = pools[_poolIndex];

        pool.startTime = _startTime;
        pool.duration = _duration;
        pool.apy = _apy;
        pool.mainPenaltyRate = _mainPenaltyRate;
        pool.subPenaltyRate = _subPenaltyRate;
        pool.lockedLimit = _lockedLimit;
        pool.nftReward = _nftReward;

        emit NewPool(
            _poolIndex,
            _startTime,
            _duration,
            _apy,
            _mainPenaltyRate,
            _subPenaltyRate,
            _lockedLimit,
            pool.promisedReward,
            _nftReward
        );
    }

    function removePool(uint256 _poolIndex)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        isPoolExist(_poolIndex)
    {

        if (pools[_poolIndex].reserve > 0) {
            require(
                token.transfer(msg.sender, pools[_poolIndex].reserve),
                "removePool: transfer failed."
            );
        }

        delete pools[_poolIndex];

        emit RemovePool(_poolIndex);
    }

    function deposit(uint256 _amount, uint256 _poolIndex)
        external
        whenNotPaused
        lock
        isPoolExist(_poolIndex)
    {

        uint256 index = currentStakerIndex[msg.sender];
        StakerInfo storage staker = stakers[msg.sender][index];
        PoolInfo storage pool = pools[_poolIndex];
        uint256 reward = calculateRew(_amount, pool.apy, pool.duration);
        uint256 totStakedAmount = pool.stakedAmount + _amount;
        pool.promisedReward += reward;
        require(
            _amount >= minStake,
            "deposit: You cannot deposit below the minimum amount."
        );

        require(
            (amountByPool[msg.sender][_poolIndex] + _amount) <= maxStake,
            "deposit: You cannot deposit, have reached the maximum deposit amount."
        );
        require(
            pool.reserve >= reward,
            "deposit: This pool has no enough reward reserve"
        );
        require(
            pool.lockedLimit >= totStakedAmount,
            "deposit: The pool has reached its maximum capacity."
        );

        require(
            block.timestamp >= pool.startTime,
            "deposit: This pool hasn't started yet."
        );

        uint256 duration = pool.duration;
        uint256 timestamp = block.timestamp;

        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "deposit: Token transfer failed."
        );

        staker.startTime = timestamp;
        staker.amount = _amount;
        staker.poolIndex = _poolIndex;
        pool.stakedAmount += _amount;

        currentStakerIndex[msg.sender] += 1;
        amountByPool[msg.sender][_poolIndex] += _amount;

        emit Deposit(
            msg.sender,
            _amount,
            timestamp,
            (timestamp + duration),
            _poolIndex,
            index
        );
    }

    function withdraw(uint256 _stakerIndex)
        external
        whenNotPaused
        lock
        isFinished(msg.sender, _stakerIndex)
    {

        StakerInfo storage staker = stakers[msg.sender][_stakerIndex];
        PoolInfo storage pool = pools[staker.poolIndex];

        require(
            staker.pendingRequest == false,
            "withdraw: you have already requested claim."
        );
        require(staker.amount > 0, "withdraw: Insufficient amount.");

        uint256 closedTime = getClosedTime(msg.sender, _stakerIndex);
        uint256 duration = _getStakerDuration(closedTime, staker.startTime);
        uint256 reward = calculateRew(staker.amount, pool.apy, duration);
        (uint256 mainPen, uint256 subPen) = getPenalty(
            msg.sender,
            _stakerIndex
        );
        uint256 totalReward = (reward - subPen);
        uint256 totalWithdraw = (staker.amount + totalReward);

        staker.reward = totalReward;
        pool.reserve -= staker.reward;
        pool.promisedReward = pool.promisedReward <= totalReward
            ? 0
            : pool.promisedReward - totalReward;

        pool.stakedAmount -= staker.amount;
        amountByPool[msg.sender][staker.poolIndex] -= staker.amount;

        if (closedTime <= block.timestamp) {
            _transferAndRemove(msg.sender, totalWithdraw, _stakerIndex);
        } else {
            staker.pendingStart = block.timestamp;
            staker.pendingRequest = true;
        }

        emit Withdraw(
            msg.sender,
            totalReward,
            totalWithdraw,
            mainPen,
            subPen,
            staker.poolIndex,
            _stakerIndex
        );
    }

    function restake(uint256 _stakerIndex)
        external
        whenNotPaused
        lock
        isFinished(msg.sender, _stakerIndex)
    {

        StakerInfo storage staker = stakers[msg.sender][_stakerIndex];
        PoolInfo storage pool = pools[staker.poolIndex];

        uint256 poolIndex = staker.poolIndex;
        uint256 closedTime = getClosedTime(msg.sender, _stakerIndex);

        require(staker.amount > 0, "restake: Insufficient amount.");
        require(
            staker.pendingRequest == false,
            "restake: You have already requested claim."
        );
        require(
            block.timestamp >= closedTime,
            "restake: Time has not expired."
        );

        uint256 duration = _getStakerDuration(closedTime, staker.startTime);
        uint256 reward = calculateRew(staker.amount, pool.apy, duration);
        uint256 totalDeposit = staker.amount + reward;
        uint256 promisedReward = calculateRew(
            totalDeposit,
            pool.apy,
            pool.duration
        );
        pool.promisedReward += promisedReward;
        require(
            pool.reserve >=
                calculateRew(
                    pool.stakedAmount + reward,
                    pool.apy,
                    pool.duration
                ),
            "restake: This pool has no enough reward reserve"
        );

        require(
            (amountByPool[msg.sender][poolIndex] + reward) <= maxStake,
            "restake: You cannot deposit, have reached the maximum deposit amount."
        );

        pool.stakedAmount += reward;
        staker.startTime = block.timestamp;
        staker.amount = totalDeposit;
        amountByPool[msg.sender][poolIndex] += reward;

        emit Restake(msg.sender, totalDeposit, poolIndex, _stakerIndex);
    }

    function emergencyWithdraw(uint256 _stakerIndex)
        external
        whenPaused
        isFinished(msg.sender, _stakerIndex)
    {

        StakerInfo memory staker = stakers[msg.sender][_stakerIndex];
        PoolInfo storage pool = pools[staker.poolIndex];

        require(staker.amount > 0, "withdraw: Insufficient amount.");

        uint256 withdrawAmount = staker.amount;
        pool.stakedAmount -= withdrawAmount;
        pool.promisedReward -= calculateRew(
            withdrawAmount,
            pool.apy,
            pool.duration
        );
        amountByPool[msg.sender][staker.poolIndex] -= withdrawAmount;
        _transferAndRemove(msg.sender, withdrawAmount, _stakerIndex);
        emit EmergencyWithdraw(
            msg.sender,
            withdrawAmount,
            staker.reward,
            pool.mainPenaltyRate,
            pool.subPenaltyRate,
            staker.poolIndex,
            _stakerIndex
        );
    }

    function claimPending(uint256 _stakerIndex)
        external
        whenNotPaused
        lock
        isFinished(msg.sender, _stakerIndex)
    {

        StakerInfo storage staker = stakers[msg.sender][_stakerIndex];
        PoolInfo memory pool = pools[staker.poolIndex];

        require(staker.amount > 0, "claim: You do not have a pending amount.");

        require(
            block.timestamp >= staker.pendingStart + penaltyDuration,
            "claim: Please wait your time has not been up."
        );

        uint256 mainAmount = staker.amount;
        if (pool.mainPenaltyRate > 0) {
            (uint256 mainPen, ) = getPenalty(msg.sender, _stakerIndex);
            mainAmount = mainAmount - mainPen;
            pool.reserve += mainPen;
        }

        staker.pendingRequest = false;

        uint256 totalPending = mainAmount + staker.reward;
        pool.promisedReward -= staker.reward;

        _transferAndRemove(msg.sender, totalPending, _stakerIndex);

        emit Claimed(
            msg.sender,
            mainAmount,
            staker.reward,
            _stakerIndex,
            staker.poolIndex
        );
    }

    function getPenalty(address _staker, uint256 _stakerIndex)
        public
        view
        returns (uint256 mainPenalty, uint256 subPenalty)
    {

        StakerInfo memory staker = stakers[_staker][_stakerIndex];
        PoolInfo memory pool = pools[staker.poolIndex];

        uint256 closedTime = getClosedTime(_staker, _stakerIndex);
        if (closedTime > block.timestamp) {
            uint256 duration = block.timestamp - staker.startTime;
            uint256 reward = calculateRew(staker.amount, pool.apy, duration);
            uint256 amountPen = (staker.amount * pool.mainPenaltyRate) / 1e18;
            uint256 rewardPen = (reward * pool.subPenaltyRate) / 1e18;

            return (amountPen, rewardPen);
        }
        return (0, 0);
    }

    function calculateRew(
        uint256 _amount,
        uint256 _apy,
        uint256 _duration
    ) public pure returns (uint256) {

        uint256 rateToSec = (_apy * 1e36) / 30 days;
        uint256 percent = (rateToSec * _duration) / 1e18;
        return (_amount * percent) / 1e36;
    }

    function stakerInfo(address _staker, uint256 _stakerIndex)
        external
        view
        returns (
            uint256 reward,
            uint256 mainPenalty,
            uint256 subPenalty,
            uint256 closedTime,
            uint256 futureReward,
            StakerInfo memory stakerInf
        )
    {

        StakerInfo memory staker = stakers[_staker][_stakerIndex];
        PoolInfo memory pool = pools[staker.poolIndex];

        closedTime = getClosedTime(_staker, _stakerIndex);
        uint256 duration = _getStakerDuration(closedTime, staker.startTime);
        reward = calculateRew(staker.amount, pool.apy, duration);
        (mainPenalty, subPenalty) = getPenalty(_staker, _stakerIndex);
        futureReward = calculateRew(staker.amount, pool.apy, pool.duration);

        return (
            reward,
            mainPenalty,
            subPenalty,
            closedTime,
            futureReward,
            staker
        );
    }

    function getClosedTime(address _staker, uint256 _stakerIndex)
        public
        view
        returns (uint256)
    {

        StakerInfo memory staker = stakers[_staker][_stakerIndex];
        PoolInfo memory pool = pools[staker.poolIndex];

        uint256 closedTime = staker.startTime + pool.duration;

        return closedTime;
    }

    function getAvaliableAllocation(uint256 _poolIndex)
        external
        view
        returns (uint256)
    {

        PoolInfo memory pool = pools[_poolIndex];

        return pool.lockedLimit - pool.stakedAmount;
    }

    function getPoolList() external view returns (PoolInfo[] memory) {

        return pools;
    }

    function getTotStakedAndAlloc()
        external
        view
        returns (uint256 totStakedAmount, uint256 totAlloc)
    {

        for (uint256 i = 0; i < pools.length; i++) {
            PoolInfo memory pool = pools[i];

            totStakedAmount += pool.stakedAmount;
            totAlloc += pool.lockedLimit - pool.stakedAmount;
        }

        return (totStakedAmount, totAlloc);
    }

    function _getStakerDuration(uint256 _closedTime, uint256 _startTime)
        private
        view
        returns (uint256)
    {

        uint256 endTime = block.timestamp > _closedTime
            ? _closedTime
            : block.timestamp;
        uint256 duration = endTime - _startTime;

        return duration;
    }

    function _transferAndRemove(
        address _user,
        uint256 _transferAmount,
        uint256 _stakerIndex
    ) private {

        StakerInfo storage staker = stakers[_user][_stakerIndex];
        require(
            token.transfer(_user, _transferAmount),
            "_transferAndRemove: transfer failed."
        );

        staker.isFinished = true;
    }
}