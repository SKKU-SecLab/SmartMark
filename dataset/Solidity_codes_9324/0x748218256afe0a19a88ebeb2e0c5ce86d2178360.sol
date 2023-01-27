
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
}// AGPLv3
pragma solidity 0.8.4;


interface IMintable {

    function mint(address _receiver, uint256 _amount) external;

}

interface IHodler {

    function add(uint256 amount) external;

}

struct AccountInfo {
    uint256 total;
    uint256 startTime;
}

interface IVesting {

    function initUnlockedPercent() external view returns (uint256);


    function totalLockedAmount() external view returns (uint256);


    function hodlerClaims() external view returns (address);


    function globalStartTime() external view returns (uint256);


    function accountInfos(address account) external view returns (AccountInfo memory);


    function withdrawals(address account) external view returns (uint256);

}

contract GROVesting is Ownable {

    using SafeERC20 for IERC20;

    uint256 internal constant ONE_YEAR_SECONDS = 31556952; // average year (including leap years) in seconds
    uint256 private constant DEFAULT_MAX_LOCK_PERIOD = ONE_YEAR_SECONDS * 1; // 1 years period
    uint256 public constant PERCENTAGE_DECIMAL_FACTOR = 10000; // BP
    uint256 internal constant TWO_WEEKS = 604800; // two weeks in seconds
    uint256 public lockPeriodFactor = PERCENTAGE_DECIMAL_FACTOR;

    IMintable public distributer;
    uint256 public initUnlockedPercent = 0;
    uint256 public instantUnlockPercent = 3000;
    mapping(address => bool) public vesters;

    uint256 public totalLockedAmount;
    uint256 constant CREATE = 0;
    uint256 constant ADD = 1;
    uint256 constant EXIT = 2;
    uint256 constant EXTEND = 3;

    address public hodlerClaims;

    mapping(address => AccountInfo) public accountInfos;
    mapping(address => uint256) public withdrawals;
    uint256 public globalStartTime;

    IVesting public oldVesting;

    mapping(address => bool) public userMigrated;

    bool public paused = true;
    bool public initialized = false;

    address public immutable TIME_LOCK;

    event LogVester(address vester, bool status);
    event LogMaxLockPeriod(uint256 newMaxPeriod);
    event LogNewMigrator(address newMigrator);
    event LogNewDistributer(address newDistributer);
    event LogNewBonusContract(address bonusContract);
    event LogNewInitUnlockedPercent(uint256 initUnlockedPercent);
    event LogNewInstantUnlockedPercent(uint256 instantUnlockPercent);

    event LogVest(address indexed user, uint256 totalLockedAmount, uint256 amount, AccountInfo vesting);
    event LogExit(address indexed user, uint256 totalLockedAmount, uint256 amount, uint256 unlocked, uint256 penalty);
    event LogInstantExit(address indexed user, uint256 mintingAmount, uint256 penalty);
    event LogExtend(address indexed user, uint256 newPeriod, AccountInfo newVesting);
    event LogMigrate(address indexed user, AccountInfo vesting);
    event LogSetStatus(bool pause);

    modifier onlyTimelock() {

        require(msg.sender == TIME_LOCK, "msg.sender != timelock");
        _;
    }

    constructor(IVesting _oldVesting, address timeLock) {
        if (address(_oldVesting) == address(0)) {
            globalStartTime = block.timestamp;
        } else {
            oldVesting = _oldVesting;
            totalLockedAmount = _oldVesting.totalLockedAmount();
            globalStartTime = _oldVesting.globalStartTime();
        }

        TIME_LOCK = timeLock;
    }

    function setInitUnlockedPercent(uint256 _initUnlockedPercent) external onlyOwner {

        require(
            instantUnlockPercent <= PERCENTAGE_DECIMAL_FACTOR,
            "setInstantUnlockedPercent: _instantUnlockPercent > 100%"
        );
        initUnlockedPercent = _initUnlockedPercent;
        emit LogNewInstantUnlockedPercent(_initUnlockedPercent);
    }

    function setInstantUnlockedPercent(uint256 _instantUnlockPercent) external onlyOwner {

        require(
            instantUnlockPercent <= PERCENTAGE_DECIMAL_FACTOR,
            "setInstantUnlockedPercent: _instantUnlockPercent > 100%"
        );
        instantUnlockPercent = _instantUnlockPercent;
        emit LogNewInstantUnlockedPercent(instantUnlockPercent);
    }

    function setDistributer(address _distributer) external onlyOwner {

        distributer = IMintable(_distributer);
        emit LogNewDistributer(_distributer);
    }

    function setStatus(bool pause) external onlyTimelock {

        paused = pause;
        emit LogSetStatus(pause);
    }

    function initialize() external onlyOwner {

        require(initialized == false, "initialized: Contract already initialized");
        paused = false;
        initialized = true;
        emit LogSetStatus(false);
    }

    function totalGroove() external view returns (uint256) {

        uint256 _maxLock = maxLockPeriod();
        uint256 _globalEndTime = (globalStartTime + _maxLock);
        uint256 _now = block.timestamp;
        if (_now >= _globalEndTime) {
            return 0;
        }

        uint256 total = totalLockedAmount;

        return
            ((total * ((PERCENTAGE_DECIMAL_FACTOR - initUnlockedPercent) * (_globalEndTime - _now))) / _maxLock) /
            PERCENTAGE_DECIMAL_FACTOR;
    }

    function updateGlobalTime(
        uint256 amount,
        uint256 startTime,
        uint256 userTotal,
        uint256 newStartTime,
        uint256 action
    ) internal {

        uint256 _totalLockedAmount = totalLockedAmount;
        if (action == CREATE) {
            _totalLockedAmount = _totalLockedAmount + amount;
        } else if (action == EXIT) {
            _totalLockedAmount = _totalLockedAmount - amount;
        } else if (_totalLockedAmount == userTotal) {
            globalStartTime = startTime;
            return;
        }
        uint256 _globalStartTime = globalStartTime;

        if (_totalLockedAmount == 0) {
            return;
        }

        if (action == ADD) {
            uint256 newWeightedTimeSum = (_globalStartTime * _totalLockedAmount + newStartTime * (userTotal + amount)) -
                startTime *
                userTotal;
            globalStartTime = newWeightedTimeSum / (_totalLockedAmount + amount);
        } else if (action == EXIT) {
            globalStartTime = uint256(
                int256(_globalStartTime) +
                    ((int256(_globalStartTime) - int256(startTime)) * int256(amount)) /
                    int256(_totalLockedAmount)
            );
        } else if (action == EXTEND) {
            globalStartTime = _globalStartTime + (userTotal * (newStartTime - startTime)) / _totalLockedAmount;
        } else {
            globalStartTime =
                (_globalStartTime * (_totalLockedAmount - amount)) /
                _totalLockedAmount +
                (startTime * amount) /
                _totalLockedAmount;
        }
    }

    function setHodlerClaims(address _hodlerClaims) external onlyOwner {

        hodlerClaims = _hodlerClaims;
        emit LogNewBonusContract(_hodlerClaims);
    }

    function maxLockPeriod() public view returns (uint256) {

        return (DEFAULT_MAX_LOCK_PERIOD * lockPeriodFactor) / PERCENTAGE_DECIMAL_FACTOR;
    }

    function setVester(address vester, bool status) public onlyOwner {

        vesters[vester] = status;
        emit LogVester(vester, status);
    }

    function setMaxLockPeriod(uint256 maxPeriodFactor) external onlyOwner {

        require(maxPeriodFactor <= 20000, "adjustLockPeriod: newFactor > 20000");
        require(
            (maxPeriodFactor * DEFAULT_MAX_LOCK_PERIOD) / PERCENTAGE_DECIMAL_FACTOR > TWO_WEEKS * 2,
            "adjustLockPeriod: newFactor to small"
        );
        lockPeriodFactor = maxPeriodFactor;
        emit LogMaxLockPeriod(maxLockPeriod());
    }

    function vest(
        bool vest,
        address account,
        uint256 amount
    ) external {

        require(!paused, "vest: paused");

        require(vesters[msg.sender], "vest: !vester");
        require(account != address(0), "vest: !account");
        require(amount > 0, "vest: !amount");
        if (!vest) {
            _instantExit(account, amount);
            return;
        }

        (AccountInfo memory ai, bool fromOld) = getAccountInfo(account);
        uint256 _maxLock = maxLockPeriod();

        if (ai.startTime == 0) {
            ai.startTime = block.timestamp;
            updateGlobalTime(amount, ai.startTime, 0, 0, CREATE);
        } else {
            uint256 newStartTime = (ai.startTime * ai.total + block.timestamp * amount) / (ai.total + amount);
            if (newStartTime + _maxLock <= block.timestamp) {
                newStartTime = block.timestamp - (_maxLock) + TWO_WEEKS;
            }
            updateGlobalTime(amount, ai.startTime, ai.total, newStartTime, ADD);
            ai.startTime = newStartTime;
        }

        ai.total += amount;
        accountInfos[account] = ai;
        if (fromOld) {
            userMigrated[account] = true;
        }
        totalLockedAmount += amount;

        emit LogVest(account, totalLockedAmount, amount, ai);
    }

    function extend(uint256 extension) external {

        require(!paused, "extend: paused");

        require(extension <= PERCENTAGE_DECIMAL_FACTOR, "extend: extension > 100%");
        (AccountInfo memory ai, bool fromOld) = getAccountInfo(msg.sender);

        uint256 total = ai.total;
        require(total > 0, "extend: no vesting");

        uint256 _maxLock = maxLockPeriod();
        uint256 startTime = ai.startTime;
        uint256 newPeriod;
        uint256 newStartTime;

        if (startTime + _maxLock < block.timestamp) {
            newPeriod = _maxLock - ((_maxLock * extension) / PERCENTAGE_DECIMAL_FACTOR);
            newStartTime = block.timestamp - newPeriod;
        } else {
            newPeriod = (_maxLock * extension) / PERCENTAGE_DECIMAL_FACTOR;
            if (startTime + newPeriod >= block.timestamp) {
                newStartTime = block.timestamp;
            } else {
                newStartTime = startTime + newPeriod;
            }
        }

        accountInfos[msg.sender].startTime = newStartTime;
        if (fromOld) {
            userMigrated[msg.sender] = true;
            accountInfos[msg.sender].total = total;
        }
        updateGlobalTime(0, startTime, total, newStartTime, EXTEND);

        emit LogExtend(msg.sender, newStartTime, ai);
    }

    function _instantExit(address user, uint256 amount) private {

        uint256 mintingAmount = (amount * instantUnlockPercent) / PERCENTAGE_DECIMAL_FACTOR;
        uint256 penalty = amount - mintingAmount;

        withdrawals[user] = getWithdrawal(user) + mintingAmount;

        IHodler(hodlerClaims).add(penalty);

        distributer.mint(user, mintingAmount);

        emit LogInstantExit(user, mintingAmount, penalty);
    }

    function exit(uint256 amount) external {

        require(!paused, "exit: paused");

        require(amount > 0, "exit: !amount");
        (uint256 total, uint256 unlocked, uint256 startTime, , bool fromOld) = unlockedBalance(msg.sender);
        require(total > 0, "exit: no vesting");
        if (amount >= total) {
            amount = total;
            delete accountInfos[msg.sender];
            if (fromOld) {
                userMigrated[msg.sender] = true;
            }
        } else {
            unlocked = (unlocked * amount) / total;
            accountInfos[msg.sender].total = total - amount;
            if (fromOld) {
                userMigrated[msg.sender] = true;
                accountInfos[msg.sender].startTime = startTime;
            }
        }
        uint256 penalty = amount - unlocked;

        withdrawals[msg.sender] = getWithdrawal(msg.sender) + unlocked;
        updateGlobalTime(amount, startTime, 0, 0, EXIT);
        totalLockedAmount -= amount;

        if (penalty > 0) {
            IHodler(hodlerClaims).add(penalty);
        }
        distributer.mint(msg.sender, unlocked);

        emit LogExit(msg.sender, totalLockedAmount, amount, unlocked, penalty);
    }

    function unlockedBalance(address account)
        private
        view
        returns (
            uint256 total,
            uint256 unlocked,
            uint256 startTime,
            uint256 _endTime,
            bool fromOld
        )
    {

        (AccountInfo memory ai, bool old) = getAccountInfo(account);
        fromOld = old;
        startTime = ai.startTime;
        total = ai.total;
        if (startTime > 0) {
            _endTime = startTime + maxLockPeriod();
            if (_endTime > block.timestamp) {
                unlocked = (total * initUnlockedPercent) / PERCENTAGE_DECIMAL_FACTOR;
                unlocked = unlocked + ((total - unlocked) * (block.timestamp - startTime)) / (_endTime - startTime);
            } else {
                unlocked = ai.total;
            }
        }
    }

    function totalBalance(address account) public view returns (uint256 unvested) {

        (AccountInfo memory ai, ) = getAccountInfo(account);
        unvested = ai.total;
    }

    function vestedBalance(address account) external view returns (uint256 unvested) {

        (, uint256 unlocked, , , ) = unlockedBalance(account);
        return unlocked;
    }

    function vestingBalance(address account) external view returns (uint256) {

        (uint256 total, uint256 unlocked, , , ) = unlockedBalance(account);
        return total - unlocked;
    }

    function totalWithdrawn(address account) external view returns (uint256) {

        return getWithdrawal(account);
    }

    function getVestingDates(address account) external view returns (uint256, uint256) {

        (AccountInfo memory ai, ) = getAccountInfo(account);
        uint256 _startDate = ai.startTime;
        require(_startDate > 0, "getVestingDates: No active position");
        uint256 _endDate = _startDate + maxLockPeriod();

        return (_startDate, _endDate);
    }

    function calcPartialExit(address account, uint256 amount) external view returns (uint256, uint256) {

        (uint256 total, uint256 unlocked, , , ) = unlockedBalance(account);
        if (amount >= total) {
            amount = total;
        } else {
            unlocked = (unlocked * amount) / total;
        }
        return (unlocked, amount - unlocked);
    }

    function getAccountInfo(address account) private view returns (AccountInfo memory ai, bool fromOld) {

        ai = accountInfos[account];
        if (ai.startTime == 0 && address(oldVesting) != address(0) && !userMigrated[account]) {
            ai = oldVesting.accountInfos(account);
            fromOld = true;
        }
    }

    function getWithdrawal(address account) private view returns (uint256 withdrawal) {

        withdrawal = withdrawals[account];
        if (withdrawal == 0 && address(oldVesting) != address(0)) {
            withdrawal = oldVesting.withdrawals(account);
        }
    }
}