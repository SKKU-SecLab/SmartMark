
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


contract LinearPool is Operators, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    uint64 private constant ONE_YEAR_IN_SECONDS = 365 days;

    uint64 public constant LINEAR_MAXIMUM_DELAY_DURATION = 35 days;

    IERC20 public linearAcceptedToken;

    address public linearRewardDistributor;

    LinearPoolInfo[] public linearPoolInfo;

    mapping(uint256 => mapping(address => LinearStakingData))
        public linearStakingData;

    mapping(uint256 => mapping(address => LinearPendingWithdrawal))
        public linearPendingWithdrawals;

    uint256 public linearFlexLockDuration;

    bool public linearAllowEmergencyWithdraw;

    event LinearPoolCreated(uint256 indexed poolId, uint256 APR);
    event LinearDeposit(
        uint256 indexed poolId,
        address indexed account,
        uint256 amount
    );
    event LinearWithdraw(
        uint256 indexed poolId,
        address indexed account,
        uint256 amount
    );
    event LinearRewardsHarvested(
        uint256 indexed poolId,
        address indexed account,
        uint256 reward
    );
    event LinearPendingWithdraw(
        uint256 indexed poolId,
        address indexed account,
        uint256 amount
    );
    event LinearEmergencyWithdraw(
        uint256 indexed poolId,
        address indexed account,
        uint256 amount
    );

    struct LinearPoolInfo {
        uint256 cap;
        uint256 totalStaked;
        uint256 minInvestment;
        uint256 maxInvestment;
        uint256 APR;
        uint256 lockDuration;
        uint256 delayDuration;
        uint64 startJoinTime;
        uint64 endJoinTime;
    }

    struct LinearStakingData {
        uint256 balance;
        uint256 joinTime;
        uint256 updatedTime;
        uint256 reward;
    }

    struct LinearPendingWithdrawal {
        uint256 amount;
        uint256 applicableAt;
    }

    constructor(IERC20 _acceptedToken) Ownable() {
        linearAcceptedToken = _acceptedToken;
    }

    modifier linearValidatePoolById(uint256 _poolId) {

        require(
            _poolId < linearPoolInfo.length,
            "LinearStakingPool: Pool are not exist"
        );
        _;
    }

    function linearPoolLength() external view returns (uint256) {

        return linearPoolInfo.length;
    }

    function linearTotalStaked(uint256 _poolId)
        external
        view
        linearValidatePoolById(_poolId)
        returns (uint256)
    {

        return linearPoolInfo[_poolId].totalStaked;
    }

    function linearAddPool(
        uint256 _cap,
        uint256 _minInvestment,
        uint256 _maxInvestment,
        uint256 _APR,
        uint256 _lockDuration,
        uint256 _delayDuration,
        uint64 _startJoinTime,
        uint64 _endJoinTime
    ) external onlyOperator {

        require(
            _endJoinTime >= block.timestamp && _endJoinTime > _startJoinTime,
            "LinearStakingPool: invalid end join time"
        );
        require(
            _delayDuration <= LINEAR_MAXIMUM_DELAY_DURATION,
            "LinearStakingPool: delay duration is too long"
        );

        linearPoolInfo.push(
            LinearPoolInfo({
                cap: _cap,
                totalStaked: 0,
                minInvestment: _minInvestment,
                maxInvestment: _maxInvestment,
                APR: _APR,
                lockDuration: _lockDuration,
                delayDuration: _delayDuration,
                startJoinTime: _startJoinTime,
                endJoinTime: _endJoinTime
            })
        );
        emit LinearPoolCreated(linearPoolInfo.length - 1, _APR);
    }

    function linearSetPool(
        uint256 _poolId,
        uint256 _cap,
        uint256 _minInvestment,
        uint256 _maxInvestment,
        uint256 _APR,
        uint64 _endJoinTime
    ) external onlyOperator linearValidatePoolById(_poolId) {

        LinearPoolInfo storage pool = linearPoolInfo[_poolId];

        require(
            _endJoinTime >= block.timestamp &&
                _endJoinTime > pool.startJoinTime,
            "LinearStakingPool: invalid end join time"
        );

        linearPoolInfo[_poolId].cap = _cap;
        linearPoolInfo[_poolId].minInvestment = _minInvestment;
        linearPoolInfo[_poolId].maxInvestment = _maxInvestment;
        linearPoolInfo[_poolId].APR = _APR;
        linearPoolInfo[_poolId].endJoinTime = _endJoinTime;
    }

    function linearSetFlexLockDuration(uint256 _flexLockDuration)
        external
        onlyOperator
    {

        require(
            _flexLockDuration <= LINEAR_MAXIMUM_DELAY_DURATION,
            "LinearStakingPool: flexible lock duration is too long"
        );
        linearFlexLockDuration = _flexLockDuration;
    }

    function linearSetRewardDistributor(address _linearRewardDistributor)
        external
        onlyOwner
    {

        require(
            _linearRewardDistributor != address(0),
            "LinearStakingPool: invalid reward distributor"
        );
        linearRewardDistributor = _linearRewardDistributor;
    }

    function linearApproveSelfDistributor(uint256 _amount) external onlyOwner {

        require(
            linearRewardDistributor == address(this),
            "LinearStakingPool: distributor is difference pool"
        );
        linearAcceptedToken.safeApprove(linearRewardDistributor, _amount);
    }

    function linearDeposit(uint256 _poolId, uint256 _amount)
        external
        nonReentrant
        linearValidatePoolById(_poolId)
    {

        address account = msg.sender;
        _linearDeposit(_poolId, _amount, account);

        linearAcceptedToken.safeTransferFrom(account, address(this), _amount);
        emit LinearDeposit(_poolId, account, _amount);
    }

    function linearClaimPendingWithdraw(uint256 _poolId)
        external
        nonReentrant
        linearValidatePoolById(_poolId)
    {

        address account = msg.sender;
        LinearPendingWithdrawal storage pending = linearPendingWithdrawals[
            _poolId
        ][account];
        uint256 amount = pending.amount;
        require(amount > 0, "LinearStakingPool: nothing is currently pending");
        require(
            pending.applicableAt <= block.timestamp,
            "LinearStakingPool: not released yet"
        );
        delete linearPendingWithdrawals[_poolId][account];
        linearAcceptedToken.safeTransfer(account, amount);
        emit LinearWithdraw(_poolId, account, amount);
    }

    function linearWithdraw(uint256 _poolId, uint256 _amount)
        external
        nonReentrant
        linearValidatePoolById(_poolId)
    {

        address account = msg.sender;
        LinearPoolInfo storage pool = linearPoolInfo[_poolId];
        LinearStakingData storage stakingData = linearStakingData[_poolId][
            account
        ];

        uint256 lockDuration = pool.lockDuration > 0
            ? pool.lockDuration
            : linearFlexLockDuration;

        require(
            block.timestamp >= stakingData.joinTime + lockDuration,
            "LinearStakingPool: still locked"
        );

        require(
            stakingData.balance >= _amount,
            "LinearStakingPool: invalid withdraw amount"
        );

        _linearClaimReward(_poolId);

        stakingData.balance -= _amount;
        pool.totalStaked -= _amount;

        if (pool.delayDuration == 0) {
            linearAcceptedToken.safeTransfer(account, _amount);
            emit LinearWithdraw(_poolId, account, _amount);
            return;
        }

        LinearPendingWithdrawal storage pending = linearPendingWithdrawals[
            _poolId
        ][account];

        pending.amount += _amount;
        pending.applicableAt = block.timestamp + pool.delayDuration;
    }

    function linearClaimReward(uint256 _poolId)
        external
        nonReentrant
        linearValidatePoolById(_poolId)
    {

        _linearClaimReward(_poolId);
    }

    function linearPendingReward(uint256 _poolId, address _account)
        public
        view
        linearValidatePoolById(_poolId)
        returns (uint256 reward)
    {

        LinearPoolInfo storage pool = linearPoolInfo[_poolId];
        LinearStakingData storage stakingData = linearStakingData[_poolId][
            _account
        ];

        uint256 startTime = stakingData.updatedTime > 0
            ? stakingData.updatedTime
            : block.timestamp;

        uint256 endTime = block.timestamp;


        uint256 stakedTimeInSeconds = endTime > startTime
            ? endTime - startTime
            : 0;
        uint256 pendingReward = ((stakingData.balance *
            stakedTimeInSeconds *
            pool.APR) / ONE_YEAR_IN_SECONDS) / 100;

        reward = stakingData.reward + pendingReward;
    }

    function linearBalanceOf(uint256 _poolId, address _account)
        external
        view
        linearValidatePoolById(_poolId)
        returns (uint256)
    {

        return linearStakingData[_poolId][_account].balance;
    }

    function linearSetAllowEmergencyWithdraw(bool _shouldAllow)
        external
        onlyOperator
    {

        linearAllowEmergencyWithdraw = _shouldAllow;
    }

    function linearEmergencyWithdraw(uint256 _poolId)
        external
        nonReentrant
        linearValidatePoolById(_poolId)
    {

        require(
            linearAllowEmergencyWithdraw,
            "LinearStakingPool: emergency withdrawal is not allowed yet"
        );

        address account = msg.sender;
        LinearStakingData storage stakingData = linearStakingData[_poolId][
            account
        ];

        require(
            stakingData.balance > 0,
            "LinearStakingPool: nothing to withdraw"
        );

        uint256 amount = stakingData.balance;

        stakingData.balance = 0;
        stakingData.reward = 0;
        stakingData.updatedTime = block.timestamp;

        linearAcceptedToken.safeTransfer(account, amount);
        emit LinearEmergencyWithdraw(_poolId, account, amount);
    }

    function _linearDeposit(
        uint256 _poolId,
        uint256 _amount,
        address account
    ) internal {

        LinearPoolInfo storage pool = linearPoolInfo[_poolId];
        LinearStakingData storage stakingData = linearStakingData[_poolId][
            account
        ];

        require(
            block.timestamp >= pool.startJoinTime,
            "LinearStakingPool: pool is not started yet"
        );

        require(
            block.timestamp <= pool.endJoinTime,
            "LinearStakingPool: pool is already closed"
        );

        require(
            stakingData.balance + _amount >= pool.minInvestment,
            "LinearStakingPool: insufficient amount"
        );

        if (pool.maxInvestment > 0) {
            require(
                stakingData.balance + _amount <= pool.maxInvestment,
                "LinearStakingPool: too large amount"
            );
        }

        if (pool.cap > 0) {
            require(
                pool.totalStaked + _amount <= pool.cap,
                "LinearStakingPool: pool is full"
            );
        }

        _linearHarvest(_poolId, account);

        stakingData.balance += _amount;
        stakingData.joinTime = block.timestamp;

        pool.totalStaked += _amount;
    }

    function _linearClaimReward(uint256 _poolId) internal {

        address account = msg.sender;
        LinearStakingData storage stakingData = linearStakingData[_poolId][
            account
        ];

        _linearHarvest(_poolId, account);

        if (stakingData.reward > 0) {
            require(
                linearRewardDistributor != address(0),
                "LinearStakingPool: invalid reward distributor"
            );
            uint256 reward = stakingData.reward;
            stakingData.reward = 0;
            linearAcceptedToken.safeTransferFrom(
                linearRewardDistributor,
                account,
                reward
            );
            emit LinearRewardsHarvested(_poolId, account, reward);
        }
    }

    function _linearHarvest(uint256 _poolId, address _account) private {

        LinearStakingData storage stakingData = linearStakingData[_poolId][
            _account
        ];

        stakingData.reward = linearPendingReward(_poolId, _account);
        stakingData.updatedTime = block.timestamp;
    }
}