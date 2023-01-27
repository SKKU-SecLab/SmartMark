

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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


pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


pragma solidity >=0.4.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function getOwner() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address _owner, address spender)
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


pragma solidity >=0.6.2 <0.8.0;

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

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
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


pragma solidity ^0.6.0;

library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
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

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
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


pragma solidity 0.6.12;

contract StakingInitializable is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public STAKING_FACTORY;

    bool public hasUserLimit;

    bool public isInitialized;

    uint256 public accTokenPerShare;

    uint256 public endBlock;

    uint256 public startBlock;

    uint256 public lastRewardBlock;

    uint16 public depositFee;

    uint16 public withdrawFee;

    uint256 public lockPeriod;

    address payable public feeAddress;

    uint256 public poolLimitPerUser;

    uint256 public rewardPerBlock;

    uint16 public constant MAX_DEPOSIT_FEE = 2000;
    uint16 public constant MAX_WITHDRAW_FEE = 2000;
    uint256 public constant MAX_LOCK_PERIOD = 30 days;
    uint256 public constant MAX_EMISSION_RATE = 10**7;

    uint256 public PRECISION_FACTOR;

    IERC20 public rewardToken;

    IERC20 public stakedToken;

    uint256 public stakedSupply;

    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
        uint256 lastDepositedAt; // Last deposited time
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event UserDeposited(address indexed user, uint256 amount);
    event EmergencyWithdrawn(address indexed user, uint256 amount);
    event EmergencyRewardWithdrawn(uint256 amount);
    event StartAndEndBlocksUpdated(uint256 startBlock, uint256 endBlock);
    event RewardPerBlockUpdated(uint256 oldValue, uint256 newValue);
    event DepositFeeUpdated(uint16 oldValue, uint16 newValue);
    event WithdrawFeeUpdated(uint16 oldValue, uint16 newValue);
    event LockPeriodUpdated(uint256 oldValue, uint256 newValue);
    event FeeAddressUpdated(address oldAddress, address newAddress);
    event PoolLimitUpdated(uint256 oldValue, uint256 newValue);
    event RewardsStopped(uint256 blockNumber);
    event UserWithdrawn(address indexed user, uint256 amount);

    constructor() public {
        STAKING_FACTORY = msg.sender;
    }

    function initialize(
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _poolLimitPerUser,
        uint16 _depositFee,
        uint16 _withdrawFee,
        uint256 _lockPeriod,
        address payable _feeAddress,
        address _admin
    ) external {

        require(!isInitialized, "Already initialized");
        require(msg.sender == STAKING_FACTORY, "Not factory");
        require(_stakedToken.totalSupply() >= 0, "Invalid stake token");
        require(_rewardToken.totalSupply() >= 0, "Invalid reward token");
        require(_feeAddress != address(0), "Invalid zero address");

        _stakedToken.balanceOf(address(this));
        _rewardToken.balanceOf(address(this));
        require(_startBlock > block.number, "startBlock cannot be in the past");
        require(
            _startBlock < _endBlock,
            "startBlock must be lower than endBlock"
        );

        isInitialized = true;

        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
        require(_depositFee <= MAX_DEPOSIT_FEE, "Invalid deposit fee");
        depositFee = _depositFee;
        require(_withdrawFee <= MAX_WITHDRAW_FEE, "Invalid withdraw fee");
        withdrawFee = _withdrawFee;
        require(_lockPeriod <= MAX_LOCK_PERIOD, "Invalid lock period");
        lockPeriod = _lockPeriod;

        feeAddress = _feeAddress;

        if (_poolLimitPerUser > 0) {
            hasUserLimit = true;
            poolLimitPerUser = _poolLimitPerUser;
        }

        uint256 decimalsRewardToken = uint256(rewardToken.decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");

        PRECISION_FACTOR = uint256(10**(uint256(30).sub(decimalsRewardToken)));

        lastRewardBlock = startBlock;

        transferOwnership(_admin);
    }

    function deposit(uint256 _amount) external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];

        if (hasUserLimit) {
            require(
                _amount.add(user.amount) <= poolLimitPerUser,
                "User amount above limit"
            );
        }

        _updatePool();

        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(accTokenPerShare)
                .div(PRECISION_FACTOR)
                .sub(user.rewardDebt);
            if (pending > 0) {
                safeRewardTransfer(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            uint256 balanceBefore = stakedToken.balanceOf(address(this));
            stakedToken.safeTransferFrom(msg.sender, address(this), _amount);
            _amount = stakedToken.balanceOf(address(this)).sub(balanceBefore);
            uint256 feeAmount = 0;

            if (depositFee > 0) {
                feeAmount = _amount.mul(depositFee).div(10000);
                if (feeAmount > 0) {
                    stakedToken.safeTransfer(feeAddress, feeAmount);
                }
            }

            user.amount = user.amount.add(_amount).sub(feeAmount);
            user.lastDepositedAt = block.timestamp;
            stakedSupply = stakedSupply.add(_amount).sub(feeAmount);
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(
            PRECISION_FACTOR
        );

        emit UserDeposited(msg.sender, _amount);
    }


    function withdraw(uint256 _amount) external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        require(
            stakedSupply >= _amount && user.amount >= _amount,
            "Amount to withdraw too high"
        );

        _updatePool();

        uint256 pending = user
            .amount
            .mul(accTokenPerShare)
            .div(PRECISION_FACTOR)
            .sub(user.rewardDebt); 

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            stakedSupply = stakedSupply.sub(_amount);
            if (user.lastDepositedAt.add(lockPeriod) > block.timestamp) {
                uint256 feeAmount = _amount.mul(withdrawFee).div(10000);
                if (feeAmount > 0) {
                    _amount = _amount.sub(feeAmount);
                    stakedToken.safeTransfer(feeAddress, feeAmount);
                }
            }
            if (_amount > 0) {
                stakedToken.safeTransfer(msg.sender, _amount);
            }
        }

        if (pending > 0) {
            safeRewardTransfer(msg.sender, pending);
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(
            PRECISION_FACTOR
        );

        emit UserWithdrawn(msg.sender, _amount);
    }

    function safeRewardTransfer(address _to, uint256 _amount)
        internal
        returns (uint256 realAmount)
    {

        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        if (_amount > 0 && rewardBalance > 0) {
            realAmount = _amount;
            if (realAmount > rewardBalance) {
                realAmount = rewardBalance;
            }

            if (
                address(stakedToken) != address(rewardToken) ||
                stakedSupply.add(realAmount) <= rewardBalance
            ) {
                rewardToken.safeTransfer(_to, realAmount);
            } else if (stakedSupply < rewardBalance) {
                realAmount = rewardBalance.sub(stakedSupply);
                rewardToken.safeTransfer(_to, realAmount);
            } else {
                realAmount = 0;
            }
        } else {
            realAmount = 0;
        }

        return realAmount;
    }

    function emergencyWithdraw() external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        stakedSupply = stakedSupply.sub(amountToTransfer);

        if (amountToTransfer > 0) {
            stakedToken.safeTransfer(msg.sender, amountToTransfer);
        }

        emit EmergencyWithdrawn(msg.sender, amountToTransfer);
    }

    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {

        require(
            startBlock > block.number || endBlock < block.number,
            "Not allowed to remove reward tokens while pool is live"
        );
        safeRewardTransfer(msg.sender, _amount);

        emit EmergencyRewardWithdrawn(_amount);
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {

        require(
            _tokenAddress != address(stakedToken),
            "Cannot be staked token"
        );
        require(
            _tokenAddress != address(rewardToken),
            "Cannot be reward token"
        );

        IERC20(_tokenAddress).safeTransfer(msg.sender, _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    function stopReward() external onlyOwner {

        require(startBlock < block.number, "Pool has not started");
        require(block.number <= endBlock, "Pool has ended");
        endBlock = block.number;

        emit RewardsStopped(block.number);
    }

    function updatePoolLimitPerUser(
        bool _hasUserLimit,
        uint256 _poolLimitPerUser
    ) external onlyOwner {

        require(hasUserLimit, "Must be set");
        uint256 oldValue = poolLimitPerUser;
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            hasUserLimit = _hasUserLimit;
            poolLimitPerUser = 0;
        }
        emit PoolLimitUpdated(oldValue, _poolLimitPerUser);
    }

    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {

        require(rewardPerBlock != _rewardPerBlock, "Same value alrady set");
        uint256 rewardDecimals = uint256(rewardToken.decimals());
        require(
            _rewardPerBlock <= MAX_EMISSION_RATE.mul(10**rewardDecimals),
            "Out of maximum emission rate"
        );
        _updatePool();
        emit RewardPerBlockUpdated(rewardPerBlock, _rewardPerBlock);
        rewardPerBlock = _rewardPerBlock;
    }

    function updateDepositFee(uint16 _depositFee) external onlyOwner {

        require(depositFee != _depositFee, "Same vaue already set");
        require(_depositFee <= MAX_DEPOSIT_FEE, "Invalid deposit fee");
        emit DepositFeeUpdated(depositFee, _depositFee);
        depositFee = _depositFee;
    }

    function updateWithdrawFee(uint16 _withdrawFee) external onlyOwner {

        require(withdrawFee != _withdrawFee, "Same value already set");
        require(_withdrawFee <= MAX_WITHDRAW_FEE, "Invalid withdraw fee");
        emit WithdrawFeeUpdated(withdrawFee, _withdrawFee);
        withdrawFee = _withdrawFee;
    }

    function updateLockPeriod(uint256 _lockPeriod) external onlyOwner {

        require(lockPeriod != _lockPeriod, "Same value already set");
        require(_lockPeriod <= MAX_LOCK_PERIOD, "Exceeds max lock period");
        emit LockPeriodUpdated(lockPeriod, _lockPeriod);
        lockPeriod = _lockPeriod;
    }

    function updateFeeAddress(address _feeAddress) external onlyOwner {

        require(_feeAddress != address(0), "Invalid zero address");
        require(feeAddress != _feeAddress, "Same value already set");
        require(feeAddress != _feeAddress, "Same fee address already set");
        emit FeeAddressUpdated(feeAddress, _feeAddress);
        feeAddress = payable(_feeAddress);
    }

    function updateStartAndEndBlocks(uint256 _startBlock, uint256 _endBlock)
        external
        onlyOwner
    {

        require(block.number < startBlock, "Pool has started");
        require(
            _startBlock < _endBlock,
            "New startBlock must be lower than new endBlock"
        );
        require(
            block.number < _startBlock,
            "New startBlock must be higher than current block"
        );

        startBlock = _startBlock;
        endBlock = _endBlock;

        lastRewardBlock = startBlock;

        emit StartAndEndBlocksUpdated(_startBlock, _endBlock);
    }

    function pendingReward(address _user) external view returns (uint256) {

        UserInfo storage user = userInfo[_user];
        if (block.number > lastRewardBlock && stakedSupply != 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 rewardAmount = multiplier.mul(rewardPerBlock);
            uint256 adjustedTokenPerShare = accTokenPerShare.add(
                rewardAmount.mul(PRECISION_FACTOR).div(stakedSupply)
            );
            return
                user
                    .amount
                    .mul(adjustedTokenPerShare)
                    .div(PRECISION_FACTOR)
                    .sub(user.rewardDebt);
        } else {
            return
                user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(
                    user.rewardDebt
                );
        }
    }

    function _updatePool() internal {

        if (block.number <= lastRewardBlock) {
            return;
        }

        if (stakedSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 rewardAmount = multiplier.mul(rewardPerBlock);
        accTokenPerShare = accTokenPerShare.add(
            rewardAmount.mul(PRECISION_FACTOR).div(stakedSupply)
        );
        lastRewardBlock = block.number;
    }

    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {

        if (_to <= endBlock) {
            return _to.sub(_from);
        } else if (_from >= endBlock) {
            return 0;
        } else {
            return endBlock.sub(_from);
        }
    }
}