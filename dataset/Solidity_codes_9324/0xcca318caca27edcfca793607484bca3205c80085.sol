
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) =
            target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
}

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

pragma solidity ^0.8.0;


library Arrays {

    function findUpperBound(uint256[] storage array, uint256 element)
        internal
        view
        returns (uint256)
    {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}

pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}
pragma solidity ^0.8.0;


contract BasePool {

    using SafeMath for uint256;

    uint256 internal _totalSupply;

    mapping(address => uint256) internal _balances;

    IERC20 public depositToken;

    IERC20 public rewardToken;

    constructor() {}

    function totalSupply() public view virtual returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {

        return _balances[account];
    }

    function usedAmount() public view returns (uint256) {

        uint256 balance = depositToken.balanceOf(address(this));
        if (_totalSupply > balance) {
            return _totalSupply.sub(balance);
        } else {
            return 0;
        }
    }
}

pragma solidity ^0.8.0;


abstract contract Snapshot is BasePool {

    using Arrays for uint256[];
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    mapping(address => mapping(uint256 => uint256))
        private _rewardReceivedSnapshots; // 账户每期获得奖励记录
    Snapshots private _totalSupplySnapshots;
    mapping(uint256 => uint256) internal _totalRewardSnapshots; // 奖励信息快照

    Counters.Counter private _currentSnapshotId;

    event SetSnapshot(uint256 id, uint256 reward);

    function _snapshot(uint256 reward) internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        _totalRewardSnapshots[currentId] = reward; // 快照奖励
        _updateTotalSupplySnapshot(); // 保存总额快照信息
        emit SetSnapshot(currentId, reward);
        return currentId;
    }

    function currentSnapshotId() public view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    function _setTotalReward(uint256 periodId, uint256 reward)
        internal
        virtual
    {
        _totalRewardSnapshots[periodId] = reward;
    }

    function _balanceOfAt(address account, uint256 snapshotId)
        internal
        view
        virtual
        returns (uint256)
    {
        (bool snapshotted, uint256 value) =
            _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function userInfoAt(address user, uint256 periodId)
        public
        view
        virtual
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 totalSupply, uint256 totalReward) = snapshotInfoAt(periodId);
        (uint256 balance, uint256 rewardReceived) = _userInfoAt(user, periodId);
        uint256 amount = balance.mul(totalReward).div(totalSupply);
        return (totalSupply, totalReward, balance, amount, rewardReceived);
    }

    function _userInfoAt(address account, uint256 snapshotId)
        internal
        view
        virtual
        returns (uint256, uint256)
    {
        uint256 balance = _balanceOfAt(account, snapshotId);
        uint256 rewardReceived = _rewardReceivedAt(account, snapshotId);
        return (balance, rewardReceived);
    }

    function snapshotInfoAt(uint256 snapshotId)
        public
        view
        virtual
        returns (uint256, uint256)
    {
        uint256 totalSupply = _totalSupplyAt(snapshotId);
        uint256 totalReward = _totalRewardSnapshots[snapshotId];
        return (totalSupply, totalReward);
    }

    function _rewardReceivedAt(address user, uint256 snapshotId)
        internal
        view
        virtual
        returns (uint256)
    {
        return _rewardReceivedSnapshots[user][snapshotId];
    }

    function _updateRewardReceivedAt(
        address user,
        uint256 snapshotId,
        uint256 reward
    ) internal virtual returns (uint256) {
        return _rewardReceivedSnapshots[user][snapshotId] = reward;
    }

    function _totalSupplyAt(uint256 snapshotId)
        internal
        view
        virtual
        returns (uint256)
    {
        (bool snapshotted, uint256 value) =
            _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _beforeUpdateUserBalance(address user) internal virtual {
        _updateAccountSnapshot(user);
        _updateTotalSupplySnapshot();
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private
        view
        returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(
            snapshotId <= _currentSnapshotId.current(),
            "ERC20Snapshot: nonexistent id"
        );


        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue)
        private
    {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids)
        private
        view
        returns (uint256)
    {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}
pragma solidity ^0.8.0;


contract PairFarmPool is BasePool, Snapshot, Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public status;

    event Deposit(address indexed user, uint256 amount); // 抵押本金
    event Withdaw(address indexed user, uint256 amount); // 提现本金
    event GetReward(address indexed user, uint256 periodId, uint256 amount); // 根据周期ID提取奖励
    event Deduction(address indexed user, IERC20 token, uint256 amount); // 强制退款时扣除手续费
    event SetStatus(uint256 indexed status); // 设置状态
    event WithdrawToken(IERC20 token, uint256 amount); // 管理员从合约提现代币

    constructor(IERC20 _depositToken, IERC20 _rewardToken) {
        depositToken = _depositToken;
        rewardToken = _rewardToken;
    }

    function setStatus(uint256 _status, uint256 reward)
        public
        virtual
        onlyOwner
    {

        status = _status;
        emit SetStatus(_status);

        if (_status == 0 && reward > 0) {
            _snapshot(reward);
        }
    }

    function setTotalReward(uint256 periodId, uint256 reward)
        public
        virtual
        onlyOwner
    {

        _setTotalReward(periodId, reward);
    }

    function withdrawToken(IERC20 token, uint256 amount) public onlyOwner {

        token.safeTransfer(msg.sender, amount);
        emit WithdrawToken(token, amount);
    }

    function forceWithdaw(
        address user, // 用户账户
        uint256 amount, // 总金额
        uint256[] memory periodIds, // 期数ID
        uint256 depositTokenDeduction, // 扣除的本金
        uint256 rewardTokenDeduction // 每期扣除的奖励代币
    ) public virtual onlyOwner {

        for (uint256 i = 0; i < periodIds.length; i++) {
            uint256 rewardReceived = _rewardReceivedAt(user, periodIds[i]);
            _updateRewardReceivedAt(
                user,
                periodIds[i],
                rewardReceived.add(rewardTokenDeduction)
            );
            _getReward(user, periodIds[i]);
            emit Deduction(user, rewardToken, rewardTokenDeduction);
        }
        if (amount > 0) {
            require(amount > depositTokenDeduction);
            _totalSupply = _totalSupply.sub(depositTokenDeduction);
            _balances[msg.sender] = _balances[msg.sender].sub(
                depositTokenDeduction
            );
            _withdaw(user, amount.sub(depositTokenDeduction));
            emit Deduction(user, depositToken, depositTokenDeduction);
        }
    }

    function deposit(uint256 amount) public virtual {

        require(status == 0, "PairFarmPool: Not in deposit status");
        _beforeUpdateUserBalance(msg.sender); // 先更新快照信息
        depositToken.safeTransferFrom(msg.sender, address(this), amount); // 将代币转入钱包
        _totalSupply = _totalSupply.add(amount); // 更新总余额
        _balances[msg.sender] = _balances[msg.sender].add(amount); // 更新用户余额
        emit Deposit(msg.sender, amount);
    }

    function withdaw(uint256 amount, uint256[] memory periodIds)
        public
        virtual
        nonReentrant
    {

        require(status == 0, "PairFarmPool: Not in withdrawal status");
        require(
            amount > 0 || periodIds.length > 0,
            "PairFarmPool: Withdrawal params is wrong"
        );
        if (periodIds.length > 0) {
            _getRewards(periodIds);
        }
        if (amount > 0) {
            _withdaw(msg.sender, amount);
        }
    }

    function _getRewards(uint256[] memory periodIds) private {

        for (uint256 i = 0; i < periodIds.length; i++) {
            _getReward(msg.sender, periodIds[i]);
        }
    }

    function _getReward(address user, uint256 periodId) private {

        require(
            periodId <= currentSnapshotId(),
            "PairFarmPool: The reward for the current period has not been settled yet"
        );
        (uint256 totalSupply, uint256 totalReward) = snapshotInfoAt(periodId);
        (uint256 balance, uint256 rewardReceived) = _userInfoAt(user, periodId);
        uint256 amount = balance.mul(totalReward).div(totalSupply);
        require(
            rewardReceived < amount,
            "PairFarmPool: The reward has been withdrawn"
        );
        uint256 rewardToBeReceived = amount.sub(rewardReceived); // 计算待领取奖励
        _updateRewardReceivedAt(user, periodId, amount); // 更新已提取奖励
        rewardToken.safeTransfer(user, rewardToBeReceived); // 发送代币
        emit GetReward(user, periodId, rewardToBeReceived);
    }

    function _withdaw(address user, uint256 amount) private {

        _beforeUpdateUserBalance(user); // 先更新快照信息
        depositToken.safeTransfer(user, amount);
        _totalSupply = _totalSupply.sub(amount); // 更新总余额
        _balances[user] = _balances[user].sub(amount); // 更新用户余额
        emit Withdaw(user, amount);
    }
}
