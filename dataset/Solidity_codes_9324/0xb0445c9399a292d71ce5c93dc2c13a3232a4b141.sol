
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}// MIT

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


contract Operators is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet operators;

    event OperatorsAdded(address[] _operators);
    event OperatorsRemoved(address[] _operators);

    constructor() {}

    modifier onlyOperator() {

        require(
            isOperator(_msgSender()) || (owner() == _msgSender()),
            "caller is not operator"
        );
        _;
    }

    function addOperators(address[] calldata _operators) public onlyOwner {

        for (uint256 i = 0; i < _operators.length; i++) {
            operators.add(_operators[i]);
        }
        emit OperatorsAdded(_operators);
    }

    function removeOperators(address[] calldata _operators) public onlyOwner {

        for (uint256 i = 0; i < _operators.length; i++) {
            operators.remove(_operators[i]);
        }
        emit OperatorsRemoved(_operators);
    }

    function isOperator(address _operator) public view returns (bool) {

        return operators.contains(_operator);
    }

    function numberOperators() public view returns (uint256) {

        return operators.length();
    }

    function operatorAt(uint256 i) public view returns (address) {

        return operators.at(i);
    }

    function getAllOperators()
        public
        view
        returns (address[] memory _operators)
    {

        _operators = new address[](operators.length());
        for (uint256 i = 0; i < _operators.length; i++) {
            _operators[i] = operators.at(i);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract AllocationPool is Operators, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    uint64 private constant ACCUMULATED_MULTIPLIER = 1e12;

    uint64 public constant ALLOC_MAXIMUM_DELAY_DURATION = 35 days; // maximum 35 days delay

    struct AllocUserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 pendingReward; // Reward but not harvest
        uint256 joinTime;
    }

    struct AllocPoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 lpSupply; // Total lp tokens deposited to this pool.
        uint64 allocPoint; // How many allocation points assigned to this pool. Rewards to distribute per block.
        uint256 lastRewardBlock; // Last block number that rewards distribution occurs.
        uint256 accRewardPerShare; // Accumulated rewards per share, times 1e12. See below.
        uint256 delayDuration; // The duration user need to wait when withdraw.
        uint256 lockDuration;
    }

    struct AllocPendingWithdrawal {
        uint256 amount;
        uint256 applicableAt;
    }

    IERC20 public allocRewardToken;

    uint256 public allocRewardPerBlock;

    address public allocRewardDistributor;

    bool public allocAllowEmergencyWithdraw;

    AllocPoolInfo[] public allocPoolInfo;

    mapping(IERC20 => bool) public allocIsAdded;

    mapping(uint256 => mapping(address => AllocUserInfo)) public allocUserInfo;

    uint64 public globalAllocPoint;

    uint256 public allocStartBlockNumber;

    uint64 public allocEndBlockNumber;

    mapping(uint256 => mapping(address => AllocPendingWithdrawal))
        public allocPendingWithdrawals;

    event AllocPoolCreated(
        uint256 indexed pid,
        address indexed token,
        uint256 allocPoint
    );
    event AllocDeposit(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AllocWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AllocPendingWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AllocEmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AllocRewardsHarvested(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint64 _globalAllocPoint
    ) Ownable() {
        require(
            address(_rewardToken) != address(0),
            "AllocStakingPool: invalid reward token address"
        );
        allocRewardToken = _rewardToken;
        allocRewardPerBlock = _rewardPerBlock;
        allocStartBlockNumber = _startBlock;

        globalAllocPoint = _globalAllocPoint;
    }

    modifier allocValidatePoolById(uint256 _pid) {

        require(
            _pid < allocPoolInfo.length,
            "AllocStakingPool: pool are not exist"
        );
        _;
    }

    function allocPoolLength() external view returns (uint256) {

        return allocPoolInfo.length;
    }

    function allocAddPool(
        uint64 _allocPoint,
        IERC20 _lpToken,
        uint256 _delayDuration,
        uint256 _lockDuration
    ) external onlyOperator {

        require(
            !allocIsAdded[_lpToken],
            "AllocStakingPool: pool already is added"
        );
        require(
            _delayDuration <= ALLOC_MAXIMUM_DELAY_DURATION,
            "AllocStakingPool: delay duration is too long"
        );
        allocMassUpdatePools();

        uint256 lastRewardBlock = block.number > allocStartBlockNumber
            ? block.number
            : allocStartBlockNumber;

        allocPoolInfo.push(
            AllocPoolInfo({
                lpToken: _lpToken,
                lpSupply: 0,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0,
                delayDuration: _delayDuration,
                lockDuration: _lockDuration
            })
        );
        allocIsAdded[_lpToken] = true;
        emit AllocPoolCreated(
            allocPoolInfo.length - 1,
            address(_lpToken),
            _allocPoint
        );
    }

    function allocSetPool(
        uint256 _pid,
        uint64 _allocPoint,
        uint256 _delayDuration,
        uint256 _lockDuration
    ) external onlyOperator allocValidatePoolById(_pid) {

        require(
            _delayDuration <= ALLOC_MAXIMUM_DELAY_DURATION,
            "AllocStakingPool: delay duration is too long"
        );
        allocMassUpdatePools();

        allocPoolInfo[_pid].allocPoint = _allocPoint;
        allocPoolInfo[_pid].delayDuration = _delayDuration;
        allocPoolInfo[_pid].lockDuration = _lockDuration;
    }

    function allocApproveSelfDistributor(uint256 _amount) external onlyOwner {

        require(
            allocRewardDistributor == address(this),
            "AllocStakingPool: distributor is difference pool"
        );
        allocRewardToken.safeApprove(allocRewardDistributor, _amount);
    }

    function allocSetRewardDistributor(address _allocRewardDistributor)
        external
        onlyOwner
    {

        require(
            _allocRewardDistributor != address(0),
            "AllocStakingPool: invalid reward distributor"
        );
        allocRewardDistributor = _allocRewardDistributor;
    }

    function allocSetEndBlock(uint64 _endBlockNumber) external onlyOperator {

        require(
            _endBlockNumber > block.number,
            "AllocStakingPool: invalid reward distributor"
        );
        allocEndBlockNumber = _endBlockNumber;
    }

    function allocSetGlobalAllocPoint(uint64 _globalAllocPoint)
        external
        onlyOperator
    {

        globalAllocPoint = _globalAllocPoint;
    }

    function allocTimeMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        if (allocEndBlockNumber > 0 && _to > allocEndBlockNumber) {
            return
                allocEndBlockNumber > _from ? allocEndBlockNumber - _from : 0;
        }
        return _to - _from;
    }

    function allocSetRewardPerBlock(uint256 _rewardPerBlock)
        external
        onlyOperator
    {

        allocMassUpdatePools();
        allocRewardPerBlock = _rewardPerBlock;
    }

    function allocPendingReward(uint256 _pid, address _user)
        public
        view
        allocValidatePoolById(_pid)
        returns (uint256)
    {

        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = pool.lpSupply;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = allocTimeMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 poolReward = (multiplier *
                allocRewardPerBlock *
                pool.allocPoint) / globalAllocPoint;
            accRewardPerShare =
                accRewardPerShare +
                ((poolReward * ACCUMULATED_MULTIPLIER) / lpSupply);
        }
        return
            user.pendingReward +
            (((user.amount * accRewardPerShare) / ACCUMULATED_MULTIPLIER) -
                user.rewardDebt);
    }

    function allocMassUpdatePools() public {

        uint256 length = allocPoolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            allocUpdatePool(pid);
        }
    }

    function allocUpdatePool(uint256 _pid) public allocValidatePoolById(_pid) {

        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = allocTimeMultiplier(
            pool.lastRewardBlock,
            block.number
        );
        uint256 poolReward = (multiplier *
            allocRewardPerBlock *
            pool.allocPoint) / globalAllocPoint;
        pool.accRewardPerShare = (pool.accRewardPerShare +
            ((poolReward * ACCUMULATED_MULTIPLIER) / lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function allocDeposit(uint256 _pid, uint256 _amount)
        external
        nonReentrant
        allocValidatePoolById(_pid)
    {

        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];
        allocUpdatePool(_pid);
        uint256 pending = ((user.amount * pool.accRewardPerShare) /
            ACCUMULATED_MULTIPLIER) - user.rewardDebt;
        user.joinTime = block.timestamp;
        user.pendingReward = user.pendingReward + pending;
        user.amount = user.amount + _amount;
        user.rewardDebt =
            (user.amount * pool.accRewardPerShare) /
            ACCUMULATED_MULTIPLIER;
        pool.lpSupply = pool.lpSupply + _amount;
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        emit AllocDeposit(msg.sender, _pid, _amount);
    }

    function allocWithdraw(
        uint256 _pid,
        uint256 _amount,
        bool _harvestReward
    ) external nonReentrant allocValidatePoolById(_pid) {

        _allocWithdraw(_pid, _amount, _harvestReward);

        AllocPoolInfo storage pool = allocPoolInfo[_pid];

        if (pool.delayDuration == 0) {
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            emit AllocWithdraw(msg.sender, _pid, _amount);
            return;
        }

        AllocPendingWithdrawal
            storage pendingWithdraw = allocPendingWithdrawals[_pid][msg.sender];
        pendingWithdraw.amount = pendingWithdraw.amount + _amount;
        pendingWithdraw.applicableAt = block.timestamp + pool.delayDuration;
    }

    function allocClaimPendingWithdraw(uint256 _pid)
        external
        nonReentrant
        allocValidatePoolById(_pid)
    {

        AllocPoolInfo storage pool = allocPoolInfo[_pid];

        AllocPendingWithdrawal
            storage pendingWithdraw = allocPendingWithdrawals[_pid][msg.sender];
        uint256 amount = pendingWithdraw.amount;
        require(amount > 0, "AllocStakingPool: nothing is currently pending");
        require(
            pendingWithdraw.applicableAt <= block.timestamp,
            "AllocStakingPool: not released yet"
        );
        delete allocPendingWithdrawals[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit AllocWithdraw(msg.sender, _pid, amount);
    }

    function allocSetAllowEmergencyWithdraw(bool _shouldAllow)
        external
        onlyOperator
    {

        allocAllowEmergencyWithdraw = _shouldAllow;
    }

    function allocEmergencyWithdraw(uint256 _pid)
        external
        nonReentrant
        allocValidatePoolById(_pid)
    {

        require(
            allocAllowEmergencyWithdraw,
            "AllocStakingPool: emergency withdrawal is not allowed yet"
        );
        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpSupply = pool.lpSupply - amount;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit AllocEmergencyWithdraw(msg.sender, _pid, amount);
    }

    function allocCompoundReward(uint256 _rewardPoolId)
        external
        nonReentrant
        allocValidatePoolById(_rewardPoolId)
    {

        AllocPoolInfo storage pool = allocPoolInfo[_rewardPoolId];
        AllocUserInfo storage user = allocUserInfo[_rewardPoolId][msg.sender];
        require(
            pool.lpToken == allocRewardToken,
            "AllocStakingPool: invalid reward pool"
        );

        uint256 totalPending = allocPendingReward(_rewardPoolId, msg.sender);

        require(totalPending > 0, "AllocStakingPool: invalid reward amount");

        user.pendingReward = 0;
        allocSafeRewardTransfer(address(this), totalPending);
        emit AllocRewardsHarvested(msg.sender, _rewardPoolId, totalPending);

        allocUpdatePool(_rewardPoolId);

        user.amount = user.amount + totalPending;
        user.rewardDebt =
            (user.amount * pool.accRewardPerShare) /
            ACCUMULATED_MULTIPLIER;
        pool.lpSupply = pool.lpSupply + totalPending;

        emit AllocDeposit(msg.sender, _rewardPoolId, totalPending);
    }

    function allocClaimReward(uint256 _pid)
        public
        nonReentrant
        allocValidatePoolById(_pid)
        returns (uint256)
    {

        return _allocClaimReward(_pid);
    }

    function allocClaimAll(uint256[] memory _pids) external nonReentrant {

        uint256 length = _pids.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _allocClaimReward(pid);
        }
    }

    function allocSafeRewardTransfer(address _to, uint256 _amount) internal {

        uint256 bal = allocRewardToken.balanceOf(allocRewardDistributor);

        require(_amount <= bal, "AllocStakingPool: not enough reward token");

        allocRewardToken.safeTransferFrom(allocRewardDistributor, _to, _amount);
    }

    function _allocWithdraw(
        uint256 _pid,
        uint256 _amount,
        bool _harvestReward
    ) internal {

        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];
        require(user.amount >= _amount, "AllocStakingPool: invalid amount");

        require(
            block.timestamp >= user.joinTime + pool.lockDuration,
            "LinearStakingPool: still locked"
        );

        if (_harvestReward || user.amount == _amount) {
            _allocClaimReward(_pid);
        } else {
            allocUpdatePool(_pid);
            uint256 pending = ((user.amount * pool.accRewardPerShare) /
                ACCUMULATED_MULTIPLIER) - user.rewardDebt;
            if (pending > 0) {
                user.pendingReward = user.pendingReward + pending;
            }
        }
        user.amount -= _amount;
        user.rewardDebt =
            (user.amount * pool.accRewardPerShare) /
            ACCUMULATED_MULTIPLIER;
        pool.lpSupply = pool.lpSupply - _amount;
    }

    function _allocClaimReward(uint256 _pid) internal returns (uint256) {

        allocUpdatePool(_pid);
        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];
        uint256 totalPending = allocPendingReward(_pid, msg.sender);

        user.pendingReward = 0;
        user.rewardDebt =
            (user.amount * pool.accRewardPerShare) /
            (ACCUMULATED_MULTIPLIER);
        if (totalPending > 0) {
            allocSafeRewardTransfer(msg.sender, totalPending);
        }
        emit AllocRewardsHarvested(msg.sender, _pid, totalPending);
        return totalPending;
    }
}