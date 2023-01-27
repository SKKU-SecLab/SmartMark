
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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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
pragma solidity 0.8.10;

interface IAbstractRewards {
    function withdrawableRewardsOf(address account)
        external
        view
        returns (uint256);

    function withdrawnRewardsOf(address account)
        external
        view
        returns (uint256);

    function cumulativeRewardsOf(address account)
        external
        view
        returns (uint256);

    event RewardsDistributed(address indexed by, uint256 rewardsDistributed);

    event RewardsWithdrawn(address indexed by, uint256 fundsWithdrawn);
}// MIT
pragma solidity 0.8.10;


abstract contract AbstractRewards is IAbstractRewards {
    using SafeCast for uint128;
    using SafeCast for uint256;
    using SafeCast for int256;

    uint128 public constant POINTS_MULTIPLIER = type(uint128).max;

    function(address) view returns (uint256) private immutable getSharesOf;
    function() view returns (uint256) private immutable getTotalShares;

    uint256 public pointsPerShare;
    mapping(address => int256) public pointsCorrection;
    mapping(address => uint256) public withdrawnRewards;

    constructor(
        function(address) view returns (uint256) getSharesOf_,
        function() view returns (uint256) getTotalShares_
    ) {
        getSharesOf = getSharesOf_;
        getTotalShares = getTotalShares_;
    }

    function withdrawableRewardsOf(address account)
        public
        view
        override
        returns (uint256)
    {
        return cumulativeRewardsOf(account) - withdrawnRewards[account];
    }

    function withdrawnRewardsOf(address account)
        public
        view
        override
        returns (uint256)
    {
        return withdrawnRewards[account];
    }

    function cumulativeRewardsOf(address account)
        public
        view
        override
        returns (uint256)
    {
        return
            ((pointsPerShare * getSharesOf(account)).toInt256() +
                pointsCorrection[account]).toUint256() / POINTS_MULTIPLIER;
    }


    function _distributeRewards(uint256 amount) internal {
        uint256 shares = getTotalShares();
        require(
            shares > 0,
            "AbstractRewards._distributeRewards: total share supply is zero"
        );

        if (amount > 0) {
            pointsPerShare =
                pointsPerShare +
                ((amount * POINTS_MULTIPLIER) / shares);
            emit RewardsDistributed(msg.sender, amount);
        }
    }

    function _prepareCollect(address account) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableRewardsOf(account);
        if (_withdrawableDividend > 0) {
            withdrawnRewards[account] =
                withdrawnRewards[account] +
                _withdrawableDividend;
            emit RewardsWithdrawn(account, _withdrawableDividend);
        }
        return _withdrawableDividend;
    }

    function _correctPointsForTransfer(
        address from,
        address to,
        uint256 shares
    ) internal {
        int256 _magCorrection = (pointsPerShare * shares).toInt256();
        pointsCorrection[from] = pointsCorrection[from] + _magCorrection;
        pointsCorrection[to] = pointsCorrection[to] - _magCorrection;
    }

    function _correctPoints(address account, int256 shares) internal {
        pointsCorrection[account] =
            pointsCorrection[account] +
            (shares * (int256(pointsPerShare)));
    }
}// MIT
pragma solidity 0.8.10;



abstract contract BasePool is ERC20, AbstractRewards {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    using SafeCast for int256;

    address public stakingToken;

    event RewardsClaimed(
        address indexed _from,
        address indexed _receiver,
        uint256 indexed rewardAmount
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _stakingToken
    ) ERC20(_name, _symbol) AbstractRewards(balanceOf, totalSupply) {
        require(
            _stakingToken != address(0),
            "BasePool.constructor: staking token is not set"
        );

        stakingToken = _stakingToken;
    }

    function _mint(address _account, uint256 _amount)
        internal
        virtual
        override
    {
        super._mint(_account, _amount);
        _correctPoints(_account, -(_amount.toInt256()));
    }

    function _burn(address _account, uint256 _amount)
        internal
        virtual
        override
    {
        super._burn(_account, _amount);
        _correctPoints(_account, _amount.toInt256());
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal virtual override {
        super._transfer(_from, _to, _value);
        _correctPointsForTransfer(_from, _to, _value);
    }
}// MIT
pragma solidity 0.8.10;


contract Staking is BasePool {
    using Math for uint256;
    using SafeCast for uint256;
    using SafeCast for int256;
    using SafeERC20 for IERC20;

    event Deposited(
        address indexed staker,
        uint256 indexed amount,
        uint256 indexed duration,
        uint256 start
    );

    event Withdrawn(
        uint256 indexed depositId,
        address indexed receiver,
        address indexed from,
        uint256 amount
    );

    uint256 public MAX_REWARD;
    uint256 public MAX_LOCK_DURATION = 360 days;
    uint256 public MIN_LOCK_DURATION = 90 days;

    uint256 public rewardReleased;
    uint256 public rewardPerSecond;
    uint256 public lastRewardTime;
    uint256 public totalStaked;

    struct Deposit {
        uint256 amount;
        uint64 start;
        uint64 end;
    }

    mapping(address => Deposit[]) public depositsOf;
    mapping(address => uint256) public totalDepositOf;
    mapping(address => uint256) public claimableTime;

    uint256 public start;
    uint256 public end;

    modifier allowed2Stake(uint256 duration) {
        require(
            block.timestamp >= start,
            "Staking.allowed2Stake: staking has not started"
        );
        require(
            block.timestamp <= end,
            "Staking.allowed2Stake: staking has finished"
        );
        require(
            end - block.timestamp >= duration,
            "Staking.allowed2Stake: staking duration is too long"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _stakingToken,
        uint256 _maxReward,
        uint256 _start
    ) BasePool(_name, _symbol, _stakingToken) {
        MAX_REWARD = _maxReward;
        rewardPerSecond = _maxReward / (365 days);

        start = Math.max(_start, block.timestamp);
        end = start + 365 days;

        lastRewardTime = start;
    }

    function stakeWith90Days(uint256 amount) external allowed2Stake(90 days) {
        _stakeWithDuration(msg.sender, amount, 90 days);
    }

    function stakeWith180Days(uint256 amount) external allowed2Stake(180 days) {
        _stakeWithDuration(msg.sender, amount, 180 days);
    }

    function stakeWith270Days(uint256 amount) external allowed2Stake(270 days) {
        _stakeWithDuration(msg.sender, amount, 270 days);
    }

    function stakeWith360Days(uint256 amount) external allowed2Stake(360 days) {
        _stakeWithDuration(msg.sender, amount, 360 days);
    }

    function distributeRewards() public {
        if (rewardReleased >= MAX_REWARD || lastRewardTime >= end) {
            return;
        }

        if (block.timestamp <= lastRewardTime) {
            return;
        }

        if (totalSupply() == 0) {
            lastRewardTime = block.timestamp;
            return;
        }
        uint256 latestTime = end.min(block.timestamp);
        uint256 reward = rewardPerSecond * (latestTime - lastRewardTime);
        rewardReleased += reward;
        _distributeRewards(reward);

        lastRewardTime = latestTime;
    }

    function withdraw(uint256 depositId, address receiver) external {
        require(
            depositId < depositsOf[receiver].length,
            "Staking.withdraw: depositId is not existed"
        );
        Deposit memory userDeposit = depositsOf[receiver][depositId];
        require(
            block.timestamp >= userDeposit.end,
            "Staking.withdraw: staking has not released"
        );

        distributeRewards();

        totalDepositOf[receiver] -= userDeposit.amount;
        depositsOf[receiver][depositId] = depositsOf[receiver][
            depositsOf[receiver].length - 1
        ];
        depositsOf[receiver].pop();

        totalStaked -= userDeposit.amount;

        uint256 sharesAmount = _getSharesAmount(
            userDeposit.amount,
            uint256(userDeposit.end - userDeposit.start)
        );
        _burn(receiver, sharesAmount);

        IERC20(stakingToken).safeTransfer(receiver, userDeposit.amount);

        emit Withdrawn(depositId, receiver, msg.sender, userDeposit.amount);
    }

    function claimRewards(address _receiver) external virtual {
        require(
            block.timestamp >= claimableTime[_receiver],
            "Staking.claimRewards: rewards are not released"
        );

        distributeRewards();

        uint256 rewardAmount = _prepareCollect(_receiver);

        if (rewardAmount > 0) {
            IERC20(stakingToken).safeTransfer(_receiver, rewardAmount);
        }

        emit RewardsClaimed(msg.sender, _receiver, rewardAmount);
    }

    function getDepositsOf(
        address account,
        uint256 offset,
        uint256 limit
    ) external view returns (Deposit[] memory _depositsOf) {
        uint256 depositsOfLength = depositsOf[account].length;
        uint256 dl = (depositsOfLength - offset).min(limit);
        _depositsOf = new Deposit[](dl);

        if (offset >= depositsOfLength) return _depositsOf;

        for (uint256 i = offset; i < dl; i++) {
            _depositsOf[i - offset] = depositsOf[account][i];
        }
    }

    function getDepositsOfLength(address account)
        external
        view
        returns (uint256)
    {
        return depositsOf[account].length;
    }

    function pendingRewards(address account) external view returns (uint256) {
        uint256 shares = totalSupply();
        if (shares == 0) {
            return withdrawableRewardsOf(account);
        }

        uint256 reward = rewardPerSecond *
            (end.min(block.timestamp) - lastRewardTime);
        uint256 pointsPerShare_ = pointsPerShare +
            ((reward * POINTS_MULTIPLIER) / shares);

        uint256 cumulativeRewards = ((pointsPerShare_ * balanceOf(account))
            .toInt256() + pointsCorrection[account]).toUint256() /
            POINTS_MULTIPLIER;

        return cumulativeRewards - withdrawnRewards[account];
    }

    function getInfo()
        external
        view
        returns (
            uint256 startTime,
            uint256 endTime,
            uint256 totalStaked_,
            uint256 rewardReleased_,
            uint256 apr
        )
    {
        startTime = start;
        endTime = end;
        totalStaked_ = totalStaked;
        rewardReleased_ = rewardReleased;

        if (totalStaked == 0) {
            apr = 0;
        } else {
            apr = (MAX_REWARD * 100) / totalStaked;
        }
    }

    function _getSharesAmount(uint256 amount, uint256 duration)
        internal
        view
        returns (uint256)
    {
        return (duration / MIN_LOCK_DURATION) * amount;
    }

    function _stakeWithDuration(
        address staker,
        uint256 amount,
        uint256 duration
    ) internal {
        require(amount > 0, "Staking._stakeWithDuration: amount is zero");
        require(
            duration >= MIN_LOCK_DURATION && duration <= MAX_LOCK_DURATION,
            "Staking._stakeWithDuration: duration is invalid"
        );

        if (claimableTime[staker] == 0) {
            claimableTime[staker] = block.timestamp + (90 days);
        }

        distributeRewards();

        IERC20(stakingToken).safeTransferFrom(staker, address(this), amount);

        depositsOf[staker].push(
            Deposit({
                amount: amount,
                start: uint64(block.timestamp),
                end: uint64(block.timestamp) + uint64(duration)
            })
        );
        totalDepositOf[staker] += amount;

        totalStaked += amount;

        uint256 sharesAmount = _getSharesAmount(amount, duration);
        _mint(staker, sharesAmount);

        emit Deposited(staker, amount, duration, block.timestamp);
    }

    function _transfer(
        address, /* _from */
        address, /* _to */
        uint256 /* _amount */
    ) internal pure override {
        revert("non-transferable");
    }
}