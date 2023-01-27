





pragma solidity ^0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

    function floorDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        return a / b - (a % b == 0 ? 1 : 0);
    }
}

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

contract AngoraStaker is Ownable {

    using SafeERC20 for IERC20;

    IERC20 public stakingToken; // Staking token

    uint256 private _totalSupply; // Total staked amount
    uint256 private _totalRewards;  // Total amount for rewards
    uint256 private _stakeRequired = 100e18; // Minimum stake amount

    ContractData private _data = ContractData({
        isActive: 0,
        reentrant: 1,
        timeFinished: 0,
        baseMultiplier: 1e18
    });

    mapping (address => UserDeposit) private _deposits; // Track all user deposits
    mapping (address => uint256) private _userRewardPaid; // Track all user claims

    struct ContractData {
        uint8 isActive;
        uint8 reentrant;
        uint64 timeFinished;
        uint64 baseMultiplier;
    }

    struct UserDeposit {
        uint8 lock; // 1 = 1 7 days; 2 = 30 days; 3 = 90 days
        uint64 timestamp;
        uint256 staked;
    }

    constructor(IERC20 ) {
        stakingToken = IERC20(0x60a5C1c2f75f61B1B8aDFD66B04dcE40d29fEecE);
    }


    modifier nonReentrant()
    {

        require(_data.reentrant == 1, "Reentrancy not allowed");
        _data.reentrant = 2;
        _;
        _data.reentrant = 1;
    }


   


    function totalSupply() external view returns (uint256)
    {

        return _totalSupply;
    }

    function totalRewards() external view returns (uint256)
    {

        return _totalRewards;
    }

    function baseMultiplier() external view returns (uint256)
    {

        return _data.baseMultiplier;
    }

    function balanceOf(address account) external view returns (uint256)
    {

        return _deposits[account].staked;
    }

    function getDeposit(address account) external view returns (UserDeposit memory)
    {

        return _deposits[account];
    }

    function isActive() external view returns (bool)
    {

        return _data.isActive == 1;
    }

    function getMinimumStake() external view returns (uint256)
    {

        return _stakeRequired;
    }

    function timeEnded() external view returns (uint256)
    {

        return _data.timeFinished;
    }

    function pendingReward(address account) public view returns (uint256)
    {

        if (_data.timeFinished > 0) {
            return 0;
        }

        UserDeposit memory userDeposit = _deposits[account];

        if (userDeposit.staked == 0) {
            return 0;
        }

        uint256 timePassed = block.timestamp - userDeposit.timestamp;
        uint256 daysPassed = timePassed > 0 ? Math.floorDiv(timePassed, 86400) : 0;
        uint256 interimTime = timePassed - (daysPassed * 86400);

        uint256 pending = userDeposit.staked * (_data.baseMultiplier * uint256(userDeposit.lock)) / 1e18 * interimTime / 2628000;
        return pending;
    }

    function earned(address account) public view returns (uint256)
    {

        UserDeposit memory userDeposit = _deposits[account];
        
        uint256 rewardPaid = _userRewardPaid[account];

        uint256 endTime = _data.timeFinished == 0 ? block.timestamp : _data.timeFinished;
        uint256 daysPassed = Math.floorDiv(endTime - userDeposit.timestamp, 86400);

        if (daysPassed == 0) return 0;

        uint256 totalReward = userDeposit.staked * ((_data.baseMultiplier * userDeposit.lock) * daysPassed) / 1e18 - rewardPaid;
        
        return totalReward;
    }

    function withdrawable(address account) public view returns (bool)
    {

        UserDeposit memory userDeposit = _deposits[account];
        uint256 unlockTime = _getUnlockTime(userDeposit.timestamp, userDeposit.lock);
        
        if (block.timestamp < unlockTime) {
            return false;
        } else {
            return true;
        }
    }

    function _getUnlockTime(uint64 timestamp, uint8 lock) private pure returns (uint256)
    {

        if (lock == 1) {
            return timestamp + (86400 * 7);
        } else if (lock == 2) {
            return timestamp + (86400 * 30);            
        } else {
            return timestamp + (86400 * 90);
        }
    }


    function deposit(uint256 amount, uint8 lock) external payable nonReentrant
    {

        require(_data.isActive != 0, "Staking inactive");
        require(lock > 0 && lock < 4, "Lock must be 1, 2, or 3");
        require(amount > 0, "Amount cannot be 0");

        UserDeposit storage userDeposit = _deposits[msg.sender];

        require(userDeposit.staked + amount >= _stakeRequired, "Need to meet minimum stake");

        stakingToken.transferFrom(msg.sender, address(this), amount);

        if (userDeposit.staked > 0) {
            uint256 earnedAmount = earned(msg.sender);
            uint256 pendingAmount = pendingReward(msg.sender);
            uint256 combinedAmount = earnedAmount + pendingAmount;

            _userRewardPaid[msg.sender] += combinedAmount;

            _totalRewards -= combinedAmount;

            _totalSupply += amount + combinedAmount;

            userDeposit.staked += amount + combinedAmount;
            userDeposit.timestamp = uint64(block.timestamp);

            if (lock > userDeposit.lock || block.timestamp > _getUnlockTime(userDeposit.timestamp, userDeposit.lock)) {
                userDeposit.lock = lock;
            }
        } else {
            userDeposit.lock = lock;
            userDeposit.timestamp = uint64(block.timestamp);
            userDeposit.staked = amount;

            _totalSupply += amount;
        }

        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external payable nonReentrant
    {

        UserDeposit storage userDeposit = _deposits[msg.sender];

        require(userDeposit.staked > 0, "User has no stake");
        require(withdrawable(msg.sender), "Lock still active");
        require(amount <= userDeposit.staked, "Withdraw amount too high");

        uint256 earnedRewards = earned(msg.sender);

        uint256 amountToWithdraw = amount + earnedRewards;

        if (userDeposit.staked == amount) {
            _userRewardPaid[msg.sender] = 0;
            userDeposit.staked = 0;
        } else {
            uint256 daysForStaking;
            if (userDeposit.lock == 1) {
                daysForStaking = 7;
            } else if (userDeposit.lock == 2) {
                daysForStaking = 30;
            } else if (userDeposit.lock == 3) {
                daysForStaking = 90;
            }
            userDeposit.staked -= amount;
            _userRewardPaid[msg.sender] = 0;
            userDeposit.timestamp = uint64(block.timestamp - (86400 * daysForStaking));
            _userRewardPaid[msg.sender] = earned(msg.sender);
        }

        _totalSupply -= amount;
        _totalRewards -= earnedRewards;

        stakingToken.safeTransfer(msg.sender, amountToWithdraw);

        emit Withdrawal(msg.sender, amount);
    }

    function emergencyWithdrawal() external payable
    {

        require(_data.isActive == 0, "Staking must be closed");
        require(_data.timeFinished > 0, "Staking must be closed");
        require(_totalRewards == 0, "Use normal withdraw");

        uint256 amountToWithdraw = _deposits[msg.sender].staked;
        require(amountToWithdraw > 0, "No stake to withdraw");

        _userRewardPaid[msg.sender] = 0;
        _deposits[msg.sender].staked = 0;

        _totalSupply -= amountToWithdraw;

        stakingToken.safeTransfer(msg.sender, amountToWithdraw);

        emit Withdrawal(msg.sender, amountToWithdraw);
    }

    function claimRewards() external payable nonReentrant
    {

        uint256 amountToWithdraw = earned(msg.sender);
        
        require(amountToWithdraw > 0, "No rewards to withdraw");
        require(amountToWithdraw <= _totalRewards, "Not enough rewards in contract");

        _userRewardPaid[msg.sender] += amountToWithdraw;

        _totalRewards -= amountToWithdraw;

        stakingToken.safeTransfer(msg.sender, amountToWithdraw);

        emit RewardsClaimed(amountToWithdraw);
    }

    function updateMinimum(uint256 minimum) external payable onlyOwner
    {

        _stakeRequired = minimum;
        
        emit MinimumUpdated(minimum);
    }

  function updateMultiplier(uint64 multiplier) external payable onlyOwner
    {

        _data.baseMultiplier = multiplier;
        
        emit MultiplierUpdated(multiplier);
    }
    function fundStaking(uint256 amount) external payable onlyOwner
    {

        require(amount > 0, "Amount cannot be 0");

        _totalRewards += amount;

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit StakingFunded(amount);
    }

    function withdrawRewardTokens() external payable onlyOwner
    {

        require(_data.timeFinished > 0, "Staking must be complete");

        uint256 amountToWithdraw = _totalRewards;
        _totalRewards = 0;

        stakingToken.safeTransfer(owner(), amountToWithdraw);
    }

    function closeRewards() external payable onlyOwner
    {

        require(_data.isActive == 1, "Contract already inactive");
        _data.isActive = 0;
        _data.timeFinished = uint64(block.timestamp);
        
        emit StakingEnded(block.timestamp);
    }

    function enableStaking() external payable onlyOwner
    {

        require(_data.isActive == 0, "Staking already active");
        _data.isActive = 1;

        emit StakingEnabled();
    }


    event StakingFunded(uint256 amount);
    event StakingEnabled();
    event StakingEnded(uint256 timestamp);
    event RewardsClaimed(uint256 amount);
    event Deposited(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);
    event MinimumUpdated(uint256 newMinimum);
    event MultiplierUpdated(uint256 newMultiplier);
}