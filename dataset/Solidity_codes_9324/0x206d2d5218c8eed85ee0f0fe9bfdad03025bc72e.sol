
pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.6.12;


interface IveDF is IERC20Upgradeable {

    function create(
        address _recipient,
        uint256 _amount,
        uint256 _duration
    ) external returns (uint96);


    function refresh(
        address _recipient,
        uint256 _amount,
        uint256 _duration
    ) external returns (uint96, uint256);


    function refresh2(
        address _recipient,
        uint256 _amount,
        uint256 _duration
    ) external returns (uint96);


    function refill(address _recipient, uint256 _amount)
        external
        returns (uint96);


    function extend(address _recipient, uint256 _duration)
        external
        returns (uint96);


    function withdraw(address _from) external returns (uint96);


    function withdraw2(address _from) external returns (uint96);


    function getLocker(address _lockerAddress)
        external
        view
        returns (
            uint32,
            uint32,
            uint96
        );


    function calcBalanceReceived(
        address _lockerAddress,
        uint256 _amount,
        uint256 _duration
    ) external view returns (uint256);


    function getAnnualInterestRate(
        address _lockerAddress,
        uint256 _amount,
        uint256 _duration
    ) external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}//MIT
pragma solidity 0.6.12;


contract LPTokenWrapper {

    using SafeMathUpgradeable for uint256;

    IveDF public veDF;

    uint256 public totalSupply;

    mapping(address => uint256) internal balances;

    function balanceOf(address account) public view returns (uint256) {

        return balances[account];
    }
}// MIT
pragma solidity 0.6.12;


interface IStakedDF is IERC20Upgradeable {

    function stake(address _recipient, uint256 _rawUnderlyingAmount)
        external
        returns (uint256 _tokenAmount);


    function unstake(address _recipient, uint256 _rawTokenAmount)
        external
        returns (uint256 _tokenAmount);


    function getCurrentExchangeRate()
        external
        view
        returns (uint256 _exchangeRate);


    function DF() external view returns (address);

}// MIT
pragma solidity 0.6.12;

interface IRewardDistributor {


    function addRecipient(address _recipient) external;

    function removeRecipient(address _recipient) external;


    function setRecipientRewardRate(address _recipient, uint256 _rewardRate) external;

    function addRecipientAndSetRewardRate(address _recipient, uint256 _rewardRate) external;


    function rescueStakingPoolTokens(
        address _stakingPool,
        address _token,
        uint256 _amount,
        address _to
    ) external;


    function rewardToken() external view returns (address);


    function getAllRecipients() external view returns (address[] memory _allRecipients);

}// MIT
pragma solidity 0.6.12;


library SafeRatioMath {

    using SafeMathUpgradeable for uint256;

    uint256 private constant BASE = 10**18;

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(BASE).div(b);
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(b).div(BASE);
    }

    function rdivup(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(BASE).add(b.sub(1)).div(b);
    }

}// MIT
pragma solidity 0.6.12;

contract Ownable {

    address payable public owner;

    address payable public pendingOwner;

    event NewOwner(address indexed previousOwner, address indexed newOwner);
    event NewPendingOwner(
        address indexed oldPendingOwner,
        address indexed newPendingOwner
    );

    modifier onlyOwner() {

        require(owner == msg.sender, "onlyOwner: caller is not the owner");
        _;
    }

    function __Ownable_init() internal {

        owner = msg.sender;
        emit NewOwner(address(0), msg.sender);
    }

    function _setPendingOwner(address payable newPendingOwner)
        external
        onlyOwner
    {

        require(
            newPendingOwner != address(0) && newPendingOwner != pendingOwner,
            "_setPendingOwner: New owenr can not be zero address and owner has been set!"
        );

        address oldPendingOwner = pendingOwner;

        pendingOwner = newPendingOwner;

        emit NewPendingOwner(oldPendingOwner, newPendingOwner);
    }

    function _acceptOwner() external {

        require(
            msg.sender == pendingOwner,
            "_acceptOwner: Only for pending owner!"
        );

        address oldOwner = owner;
        address oldPendingOwner = pendingOwner;

        owner = pendingOwner;

        pendingOwner = address(0);

        emit NewOwner(oldOwner, owner);
        emit NewPendingOwner(oldPendingOwner, pendingOwner);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}//MIT
pragma solidity 0.6.12;


contract veDFCore is
    Ownable,
    Initializable,
    ReentrancyGuardUpgradeable,
    LPTokenWrapper
{

    using SafeRatioMath for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for IStakedDF;

    uint256 internal constant MIN_STEP = 1 weeks;

    IERC20Upgradeable public rewardToken;
    IStakedDF public sDF;
    address public rewardDistributor;

    uint256 public rewardRate = 0;

    uint256 public startTime;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public lastRateUpdateTime;
    uint256 public rewardDistributedStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public lastSettledTime;
    uint256 public accSettledBalance;

    struct SettleLocalVars {
        uint256 lastUpdateTime;
        uint256 lastSettledTime;
        uint256 accSettledBalance;
        uint256 rewardPerToken;
        uint256 rewardRate;
        uint256 totalSupply;
    }

    struct Node {
        uint256 rewardPerTokenSettled;
        uint256 balance;
    }

    mapping(uint256 => Node) internal nodes;

    event RewardRateUpdated(uint256 oldRewardRate, uint256 newRewardRate);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    event Create(
        address recipient,
        uint256 sDFLocked,
        uint256 duration,
        uint256 veDFReceived
    );

    event Refill(address recipient, uint256 sDFRefilled, uint256 veDFReceived);

    event Extend(
        address recipient,
        uint256 preDueTime,
        uint256 newDueTime,
        uint256 duration,
        uint256 veDFReceived
    );

    event Refresh(
        address recipient,
        uint256 presDFLocked,
        uint256 newsDFLocked,
        uint256 duration,
        uint256 preveDFBalance,
        uint256 newveDFBalance
    );

    event Withdraw(address recipient, uint256 veDFBurned, uint256 sDFRefunded);

    function initialize(
        IveDF _veDF,
        IStakedDF _sDF,
        IERC20Upgradeable _rewardToken,
        uint256 _startTime,
        address _rewardDistributor
    ) public virtual initializer {

        require(
            _startTime > block.timestamp,
            "veDFManager: Start time must be greater than the block timestamp"
        );

        __Ownable_init();
        __ReentrancyGuard_init();

        veDF = _veDF;
        sDF = _sDF;
        rewardToken = _rewardToken;
        startTime = _startTime;
        lastSettledTime = _startTime;
        lastUpdateTime = _startTime;
        rewardDistributor = _rewardDistributor;

        sDF.safeApprove(address(veDF), uint256(-1));
    }

    modifier updateReward(address _account) {

        if (startTime <= block.timestamp) {
            _settleNode(block.timestamp);
            if (_account != address(0)) {
                _updateUserReward(_account);
            }
        }
        _;
    }

    modifier updateRewardDistributed() {

        rewardDistributedStored = rewardDistributed();
        lastRateUpdateTime = block.timestamp;
        _;
    }

    modifier sanityCheck(uint256 _amount) {

        require(_amount != 0, "veDFManager: Stake amount can not be zero!");
        _;
    }

    modifier isDueTimeValid(uint256 _dueTime) {

        require(
            _dueTime > block.timestamp,
            "veDFManager: Due time must be greater than the current time"
        );
        require(
            _dueTime.sub(startTime).mod(MIN_STEP) == 0,
            "veDFManager: The minimum step size must be `MIN_STEP`"
        );
        _;
    }

    modifier onlyRewardDistributor() {

        require(
            rewardDistributor == msg.sender,
            "veDFManager: caller is not the rewardDistributor"
        );
        _;
    }


    function setRewardRate(uint256 _rewardRate)
        external
        onlyRewardDistributor
        updateRewardDistributed
        updateReward(address(0))
    {

        uint256 _oldRewardRate = rewardRate;
        rewardRate = _rewardRate;

        emit RewardRateUpdated(_oldRewardRate, _rewardRate);
    }

    function rescueTokens(
        IERC20Upgradeable _token,
        uint256 _amount,
        address _to
    ) external onlyRewardDistributor {

        _token.safeTransfer(_to, _amount);
    }


    function _settleNode(uint256 _now) private {

        SettleLocalVars memory _var;
        _var.lastUpdateTime = lastUpdateTime;
        _var.lastSettledTime = lastSettledTime;
        _var.accSettledBalance = accSettledBalance;
        _var.rewardPerToken = rewardPerTokenStored;
        _var.rewardRate = rewardRate;
        _var.totalSupply = totalSupply;

        while (_var.lastSettledTime < _now) {
            Node storage _node = nodes[_var.lastSettledTime];
            if (_node.balance > 0) {
                _var.rewardPerToken = _var.rewardPerToken.add(
                    _var
                        .lastSettledTime
                        .sub(_var.lastUpdateTime)
                        .mul(_var.rewardRate)
                        .rdiv(_var.totalSupply.sub(_var.accSettledBalance))
                );

                _var.accSettledBalance = _var.accSettledBalance.add(
                    _node.balance
                );

                _node.rewardPerTokenSettled = _var.rewardPerToken;
                _var.lastUpdateTime = _var.lastSettledTime;
            }

            if (_var.accSettledBalance == _var.totalSupply) {
                _var.lastSettledTime = MIN_STEP
                    .sub(_now.sub(_var.lastSettledTime).mod(MIN_STEP))
                    .add(_now);
                break;
            }

            _var.lastSettledTime += MIN_STEP;
        }

        accSettledBalance = _var.accSettledBalance;
        lastSettledTime = _var.lastSettledTime;

        rewardPerTokenStored = _var.totalSupply == _var.accSettledBalance
            ? _var.rewardPerToken
            : _var.rewardPerToken.add(
                _now.sub(_var.lastUpdateTime).mul(_var.rewardRate).rdiv(
                    _var.totalSupply.sub(_var.accSettledBalance)
                )
            );
        lastUpdateTime = _now;
    }

    function _updateUserReward(address _account) private {

        (uint32 _dueTime, , ) = veDF.getLocker(_account);
        uint256 _rewardPerTokenStored = rewardPerTokenStored;

        if (_dueTime > 0) {
            if (_dueTime < block.timestamp) {
                _rewardPerTokenStored = nodes[_dueTime].rewardPerTokenSettled;
            }

            rewards[_account] = balances[_account]
                .rmul(
                    _rewardPerTokenStored.sub(userRewardPerTokenPaid[_account])
                )
                .add(rewards[_account]);
        }

        userRewardPerTokenPaid[_account] = _rewardPerTokenStored;
    }


    function create(uint256 _amount, uint256 _dueTime)
        public
        sanityCheck(_amount)
        isDueTimeValid(_dueTime)
        updateReward(msg.sender)
    {

        uint256 _duration = _dueTime.sub(block.timestamp);
        sDF.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _veDFAmount = veDF.create(msg.sender, _amount, _duration);

        totalSupply = totalSupply.add(_veDFAmount);
        balances[msg.sender] = balances[msg.sender].add(_veDFAmount);
        nodes[_dueTime].balance = nodes[_dueTime].balance.add(_veDFAmount);

        emit Create(msg.sender, _amount, _duration, _veDFAmount);
    }

    function refill(uint256 _amount)
        external
        sanityCheck(_amount)
        updateReward(msg.sender)
    {

        sDF.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _veDFAmount = veDF.refill(msg.sender, _amount);

        (uint32 _dueTime, , ) = veDF.getLocker(msg.sender);

        totalSupply = totalSupply.add(_veDFAmount);
        balances[msg.sender] = balances[msg.sender].add(_veDFAmount);
        nodes[_dueTime].balance = nodes[_dueTime].balance.add(_veDFAmount);

        emit Refill(msg.sender, _amount, _veDFAmount);
    }

    function extend(uint256 _dueTime)
        external
        isDueTimeValid(_dueTime)
        updateReward(msg.sender)
    {

        (uint32 _oldDueTime, , ) = veDF.getLocker(msg.sender);
        uint256 _oldBalance = balances[msg.sender];

        nodes[_oldDueTime].balance = nodes[_oldDueTime].balance.sub(
            _oldBalance
        );

        uint256 _duration = _dueTime.sub(_oldDueTime);
        uint256 _veDFAmount = veDF.extend(msg.sender, _duration);

        totalSupply = totalSupply.add(_veDFAmount);
        balances[msg.sender] = balances[msg.sender].add(_veDFAmount);

        nodes[_dueTime].balance = nodes[_dueTime].balance.add(_veDFAmount).add(
            _oldBalance
        );

        emit Extend(msg.sender, _oldDueTime, _dueTime, _duration, _veDFAmount);
    }

    function refresh(uint256 _amount, uint256 _dueTime)
        external
        sanityCheck(_amount)
        isDueTimeValid(_dueTime)
        nonReentrant
        updateReward(msg.sender)
    {

        (, , uint256 _lockedSDF) = veDF.getLocker(msg.sender);
        if (_amount > _lockedSDF) {
            sDF.safeTransferFrom(
                msg.sender,
                address(this),
                _amount.sub(_lockedSDF)
            );
        }

        uint256 _duration = _dueTime.sub(block.timestamp);
        uint256 _oldVEDFAmount = balances[msg.sender];
        uint256 _newVEDFAmount = veDF.refresh2(msg.sender, _amount, _duration);

        balances[msg.sender] = _newVEDFAmount;
        userRewardPerTokenPaid[msg.sender] = rewardPerTokenStored;

        totalSupply = totalSupply.add(_newVEDFAmount).sub(_oldVEDFAmount);
        nodes[_dueTime].balance = nodes[_dueTime].balance.add(_newVEDFAmount);
        accSettledBalance = accSettledBalance.sub(_oldVEDFAmount);

        emit Refresh(
            msg.sender,
            _lockedSDF,
            _amount,
            _duration,
            _oldVEDFAmount,
            _newVEDFAmount
        );
    }

    function _withdraw2() internal {

        uint256 _burnVEDF = veDF.withdraw2(msg.sender);
        uint256 _oldBalance = balances[msg.sender];

        totalSupply = totalSupply.sub(_oldBalance);
        balances[msg.sender] = balances[msg.sender].sub(_oldBalance);

        accSettledBalance = accSettledBalance.sub(_oldBalance);

        emit Withdraw(msg.sender, _burnVEDF, _oldBalance);
    }

    function getReward() public virtual updateReward(msg.sender) {

        uint256 _reward = rewards[msg.sender];
        if (_reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.safeTransferFrom(
                rewardDistributor,
                msg.sender,
                _reward
            );
            emit RewardPaid(msg.sender, _reward);
        }
    }

    function exit() external {

        getReward();
        _withdraw2();
    }


    function rewardPerToken()
        external
        updateReward(address(0))
        returns (uint256)
    {

        return rewardPerTokenStored;
    }

    function rewardDistributed() public view returns (uint256) {

        if (block.timestamp < startTime) {
            return rewardDistributedStored;
        }

        return
            rewardDistributedStored.add(
                block
                    .timestamp
                    .sub(MathUpgradeable.max(startTime, lastRateUpdateTime))
                    .mul(rewardRate)
            );
    }

    function earned(address _account)
        public
        updateReward(_account)
        returns (uint256)
    {

        return rewards[_account];
    }

    function getLocker(address _lockerAddress)
        external
        view
        returns (
            uint32,
            uint32,
            uint96
        )
    {

        return veDF.getLocker(_lockerAddress);
    }

    function getLockerInfo(address _lockerAddress)
        external
        returns (
            uint32 _startTime,
            uint32 _dueTime,
            uint32 _duration,
            uint96 _sDFAmount,
            uint256 _veDFAmount,
            uint256 _stakedveDF,
            uint256 _rewardAmount,
            uint256 _lockedStatus
        )
    {

        (_dueTime, _duration, _sDFAmount) = veDF.getLocker(_lockerAddress);
        _startTime = _dueTime > _duration ? _dueTime - _duration : 0;

        _veDFAmount = veDF.balanceOf(_lockerAddress);

        _rewardAmount = earned(_lockerAddress);

        _lockedStatus = 2;
        if (_dueTime > block.timestamp) {
            _lockedStatus = 1;
            _stakedveDF = _veDFAmount;
        }
        if (_dueTime == 0) _lockedStatus = 0;
    }

    function calcBalanceReceived(
        address _lockerAddress,
        uint256 _amount,
        uint256 _duration
    ) external view returns (uint256) {

        return veDF.calcBalanceReceived(_lockerAddress, _amount, _duration);
    }

    function estimateLockerAPY(
        address _lockerAddress,
        uint256 _amount,
        uint256 _duration
    ) external view returns (uint256) {

        uint256 _veDFExpectedAmount = veDF.calcBalanceReceived(
            _lockerAddress,
            _amount,
            _duration
        );
        uint256 _totalSupply = totalSupply.add(_veDFExpectedAmount);
        if (_totalSupply == 0) return 0;

        uint256 _annualInterest = rewardRate
            .mul(balances[_lockerAddress].add(_veDFExpectedAmount))
            .mul(365 days)
            .div(_totalSupply);

        (, , uint96 _sDFAmount) = veDF.getLocker(_lockerAddress);
        uint256 _principal = uint256(_sDFAmount).add(_amount).rmul(
            sDF.getCurrentExchangeRate()
        );
        if (_principal == 0) return 0;

        return _annualInterest.rdiv(_principal);
    }

    function getLockersInfo()
        external
        updateReward(address(0))
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        return (
            veDF.totalSupply(),
            sDF.balanceOf(address(veDF)),
            accSettledBalance,
            rewardRate
        );
    }
}//MIT
pragma solidity 0.6.12;

contract veDFManager is veDFCore {

    IERC20Upgradeable public DF;

    event SupplySDF(uint256 amount);

    constructor(
        IveDF _veDF,
        IStakedDF _sDF,
        IERC20Upgradeable _rewardToken,
        uint256 _startTime,
        address _rewardDistributor
    ) public {
        initialize(_veDF, _sDF, _rewardToken, _startTime, _rewardDistributor);
    }

    function initialize(
        IveDF _veDF,
        IStakedDF _sDF,
        IERC20Upgradeable _rewardToken,
        uint256 _startTime,
        address _rewardDistributor
    ) public override {

        require(
            _sDF.DF() == IRewardDistributor(_rewardDistributor).rewardToken(),
            "veDFManager: vault distribution token error"
        );

        require(
            address(_sDF) == address(_rewardToken),
            "veDFManager: Distributed as SDF"
        );

        super.initialize(_veDF, _sDF, _rewardToken, _startTime, _rewardDistributor);
        DF = IERC20Upgradeable(_sDF.DF());
        DF.safeApprove(address(sDF), uint256(-1));
    }

    function supplySDFUnderlying(uint256 _amount) public onlyOwner {

        require(
            _amount > 0,
            "veDFManager: supply SDF Underlying amount must greater than 0"
        );
        DF.safeTransferFrom(rewardDistributor, address(this), _amount);
        sDF.stake(address(this), _amount);
        emit SupplySDF(_amount);
    }

    function supplySDF(uint256 _amount) external onlyOwner {

        require(_amount > 0, "veDFManager: supply SDF amount must greater than 0");

        uint256 _exchangeRate = sDF.getCurrentExchangeRate();
        uint256 _underlyingAmount = _amount.rmul(_exchangeRate);
        supplySDFUnderlying(_underlyingAmount);
    }

    function createInOne(uint256 _amount, uint256 _dueTime)
        external
        sanityCheck(_amount)
        isDueTimeValid(_dueTime)
        updateReward(msg.sender)
    {

        DF.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 _sDFAmount = sDF.stake(address(this), _amount);

        uint256 _duration = _dueTime.sub(block.timestamp);
        uint256 _veDFAmount = veDF.create(msg.sender, _sDFAmount, _duration);

        totalSupply = totalSupply.add(_veDFAmount);
        balances[msg.sender] = balances[msg.sender].add(_veDFAmount);
        nodes[_dueTime].balance = nodes[_dueTime].balance.add(_veDFAmount);

        emit Create(msg.sender, _sDFAmount, _duration, _veDFAmount);
    }

    function refillInOne(uint256 _amount)
        external
        sanityCheck(_amount)
        updateReward(msg.sender)
    {

        DF.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _sDFAmount = sDF.stake(address(this), _amount);

        uint256 _veDFAmount = veDF.refill(msg.sender, _sDFAmount);

        (uint32 _dueTime, , ) = veDF.getLocker(msg.sender);

        totalSupply = totalSupply.add(_veDFAmount);
        balances[msg.sender] = balances[msg.sender].add(_veDFAmount);
        nodes[_dueTime].balance = nodes[_dueTime].balance.add(_veDFAmount);

        emit Refill(msg.sender, _sDFAmount, _veDFAmount);
    }

    function refreshInOne(uint256 _increment, uint256 _dueTime)
        external
        isDueTimeValid(_dueTime)
        nonReentrant
        updateReward(msg.sender)
    {

        (, , uint256 _lockedSDF) = veDF.getLocker(msg.sender);
        uint256 _newSDF = _lockedSDF;

        if (_increment > 0) {
            DF.safeTransferFrom(msg.sender, address(this), _increment);
            uint256 _incrementSDF = sDF.stake(address(this), _increment);
            _newSDF = _newSDF.add(_incrementSDF);
        }

        uint256 _duration = _dueTime.sub(block.timestamp);
        uint256 _oldVEDFAmount = balances[msg.sender];
        (uint256 _newVEDFAmount, ) = veDF.refresh(msg.sender, _newSDF, _duration);

        balances[msg.sender] = _newVEDFAmount;
        userRewardPerTokenPaid[msg.sender] = rewardPerTokenStored;

        totalSupply = totalSupply.add(_newVEDFAmount).sub(_oldVEDFAmount);
        nodes[_dueTime].balance = nodes[_dueTime].balance.add(_newVEDFAmount);
        accSettledBalance = accSettledBalance.sub(_oldVEDFAmount);

        emit Refresh(
            msg.sender,
            _lockedSDF,
            _newSDF,
            _duration,
            _oldVEDFAmount,
            _newVEDFAmount
        );
    }

    function _withdraw() internal {

        (, , uint96 _lockedSDF) = veDF.getLocker(msg.sender);
        uint256 _burnVEDF = veDF.withdraw(msg.sender);
        uint256 _oldBalance = balances[msg.sender];

        totalSupply = totalSupply.sub(_oldBalance);
        balances[msg.sender] = balances[msg.sender].sub(_oldBalance);

        accSettledBalance = accSettledBalance.sub(_oldBalance);

        uint256 _DFAmount = sDF.unstake(address(this), _lockedSDF);
        DF.safeTransfer(msg.sender, _DFAmount);

        emit Withdraw(msg.sender, _burnVEDF, _oldBalance);
    }

    function getReward() public override updateReward(msg.sender) {

        uint256 _reward = rewards[msg.sender];
        if (_reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.safeTransfer(msg.sender, _reward);
            emit RewardPaid(msg.sender, _reward);
        }
    }

    function getRewardInOne() public updateReward(msg.sender) {

        uint256 _reward = rewards[msg.sender];
        if (_reward > 0) {
            rewards[msg.sender] = 0;
            uint256 _DFAmount = sDF.unstake(address(this), _reward);
            DF.safeTransfer(msg.sender, _DFAmount);
            emit RewardPaid(msg.sender, _reward);
        }
    }

    function exit2() external {

        getReward();
        _withdraw();
    }

    function exitInOne() external {

        getRewardInOne();
        _withdraw();
    }

    function earnedInOne(address _account)
        public
        updateReward(_account)
        returns (uint256 _reward)
    {

        _reward = rewards[_account];
        if (_reward > 0) {
            uint256 _exchangeRate = sDF.getCurrentExchangeRate();
            _reward = _reward.rmul(_exchangeRate);
        }
    }
}