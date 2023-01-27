
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
pragma solidity 0.8.3;


interface IERC20Decimals is IERC20 {


    function decimals() external view returns (uint8);

}// MIT

pragma solidity 0.8.3;


contract TokenLockup {

    using SafeERC20 for IERC20Decimals;

    IERC20Decimals immutable public token;
    string private _name;
    string private _symbol;

    struct ReleaseSchedule {
        uint releaseCount;
        uint delayUntilFirstReleaseInSeconds;
        uint initialReleasePortionInBips;
        uint periodBetweenReleasesInSeconds;
    }

    struct Timelock {
        uint scheduleId;
        uint commencementTimestamp;
        uint tokensTransferred;
        uint totalAmount;
        address[] cancelableBy; // not cancelable unless set at the time of funding
    }

    ReleaseSchedule[] public releaseSchedules;
    uint immutable public minTimelockAmount;
    uint immutable public maxReleaseDelay;
    uint private constant BIPS_PRECISION = 10000;

    mapping(address => Timelock[]) public timelocks;
    mapping(address => uint) internal _totalTokensUnlocked;
    mapping(address => mapping(address => uint)) internal _allowances;

    event Approval(address indexed from, address indexed spender, uint amount);
    event ScheduleCreated(address indexed from, uint indexed scheduleId);

    event ScheduleFunded(
        address indexed from,
        address indexed to,
        uint indexed scheduleId,
        uint amount,
        uint commencementTimestamp,
        uint timelockId,
        address[] cancelableBy
    );

    event TimelockCanceled(
        address indexed canceledBy,
        address indexed target,
        uint indexed timelockIndex,
        address relaimTokenTo,
        uint canceledAmount,
        uint paidAmount
    );

    constructor (
        address _token,
        string memory name_,
        string memory symbol_,
        uint _minTimelockAmount,
        uint _maxReleaseDelay
    ) {
        _name = name_;
        _symbol = symbol_;
        token = IERC20Decimals(_token);

        require(_minTimelockAmount > 0, "Min timelock amount > 0");
        minTimelockAmount = _minTimelockAmount;
        maxReleaseDelay = _maxReleaseDelay;
    }

    function createReleaseSchedule(
        uint releaseCount,
        uint delayUntilFirstReleaseInSeconds,
        uint initialReleasePortionInBips,
        uint periodBetweenReleasesInSeconds
    ) external returns (uint unlockScheduleId) {

        require(delayUntilFirstReleaseInSeconds <= maxReleaseDelay, "first release > max");
        require(releaseCount >= 1, "< 1 release");
        require(initialReleasePortionInBips <= BIPS_PRECISION, "release > 100%");

        if (releaseCount > 1) {
            require(periodBetweenReleasesInSeconds > 0, "period = 0");
        } else if (releaseCount == 1) {
            require(initialReleasePortionInBips == BIPS_PRECISION, "released < 100%");
        }

        releaseSchedules.push(ReleaseSchedule(
            releaseCount,
            delayUntilFirstReleaseInSeconds,
            initialReleasePortionInBips,
            periodBetweenReleasesInSeconds
        ));

        unlockScheduleId = releaseSchedules.length - 1;
        emit ScheduleCreated(msg.sender, unlockScheduleId);

        return unlockScheduleId;
    }

    function fundReleaseSchedule(
        address to,
        uint amount,
        uint commencementTimestamp, // unix timestamp
        uint scheduleId,
        address[] memory cancelableBy
    ) public returns (bool success) {

        require(cancelableBy.length <= 10, "max 10 cancelableBy addressees");

        uint timelockId = _fund(to, amount, commencementTimestamp, scheduleId);

        if (cancelableBy.length > 0) {
            timelocks[to][timelockId].cancelableBy = cancelableBy;
        }

        emit ScheduleFunded(msg.sender, to, scheduleId, amount, commencementTimestamp, timelockId, cancelableBy);
        return true;
    }

    function _fund(
        address to,
        uint amount,
        uint commencementTimestamp, // unix timestamp
        uint scheduleId)
    internal returns (uint) {

        require(amount >= minTimelockAmount, "amount < min funding");
        require(to != address(0), "to 0 address");
        require(scheduleId < releaseSchedules.length, "bad scheduleId");
        require(amount >= releaseSchedules[scheduleId].releaseCount, "< 1 token per release");
        token.safeTransferFrom(msg.sender, address(this), amount);

        require(
            commencementTimestamp + releaseSchedules[scheduleId].delayUntilFirstReleaseInSeconds <=
            block.timestamp + maxReleaseDelay
        , "initial release out of range");

        Timelock memory timelock;
        timelock.scheduleId = scheduleId;
        timelock.commencementTimestamp = commencementTimestamp;
        timelock.totalAmount = amount;

        timelocks[to].push(timelock);
        return timelockCountOf(to) - 1;
    }

    function cancelTimelock(
        address target,
        uint timelockIndex,
        uint scheduleId,
        uint commencementTimestamp,
        uint totalAmount,
        address reclaimTokenTo
    ) public returns (bool success) {

        require(timelockCountOf(target) > timelockIndex, "invalid timelock");
        require(reclaimTokenTo != address(0), "Invalid reclaimTokenTo");

        Timelock storage timelock = timelocks[target][timelockIndex];

        require(_canBeCanceled(timelock), "You are not allowed to cancel this timelock");
        require(timelock.scheduleId == scheduleId, "Expected scheduleId does not match");
        require(timelock.commencementTimestamp == commencementTimestamp, "Expected commencementTimestamp does not match");
        require(timelock.totalAmount == totalAmount, "Expected totalAmount does not match");

        uint canceledAmount = lockedBalanceOfTimelock(target, timelockIndex);

        require(canceledAmount > 0, "Timelock has no value left");

        uint paidAmount = unlockedBalanceOfTimelock(target, timelockIndex);

        token.safeTransfer(reclaimTokenTo, canceledAmount);
        token.safeTransfer(target, paidAmount);

        emit TimelockCanceled(msg.sender, target, timelockIndex, reclaimTokenTo, canceledAmount, paidAmount);

        timelock.tokensTransferred = timelock.totalAmount;
        return true;
    }

    function _canBeCanceled(Timelock storage timelock) view private returns (bool){

        for (uint i = 0; i < timelock.cancelableBy.length; i++) {
            if (msg.sender == timelock.cancelableBy[i]) {
                return true;
            }
        }
        return false;
    }

    function batchFundReleaseSchedule(
        address[] calldata to,
        uint[] calldata amounts,
        uint[] calldata commencementTimestamps,
        uint[] calldata scheduleIds,
        address[] calldata cancelableBy
    ) external returns (bool success) {

        require(to.length == amounts.length, "mismatched array length");
        require(to.length == commencementTimestamps.length, "mismatched array length");
        require(to.length == scheduleIds.length, "mismatched array length");

        for (uint i = 0; i < to.length; i++) {
            require(fundReleaseSchedule(
                to[i],
                amounts[i],
                commencementTimestamps[i],
                scheduleIds[i],
                cancelableBy
            ));
        }

        return true;
    }

    function lockedBalanceOf(address who) public view returns (uint amount) {

        for (uint i = 0; i < timelockCountOf(who); i++) {
            amount += lockedBalanceOfTimelock(who, i);
        }
        return amount;
    }
    function unlockedBalanceOf(address who) public view returns (uint amount) {

        for (uint i = 0; i < timelockCountOf(who); i++) {
            amount += unlockedBalanceOfTimelock(who, i);
        }
        return amount;
    }

    function lockedBalanceOfTimelock(address who, uint timelockIndex) public view returns (uint locked) {

        Timelock memory timelock = timelockOf(who, timelockIndex);
        if (timelock.totalAmount <= timelock.tokensTransferred) {
            return 0;
        } else {
            return timelock.totalAmount - totalUnlockedToDateOfTimelock(who, timelockIndex);
        }
    }

    function unlockedBalanceOfTimelock(address who, uint timelockIndex) public view returns (uint unlocked) {

        Timelock memory timelock = timelockOf(who, timelockIndex);
        if (timelock.totalAmount <= timelock.tokensTransferred) {
            return 0;
        } else {
            return totalUnlockedToDateOfTimelock(who, timelockIndex) - timelock.tokensTransferred;
        }
    }

    function balanceOfTimelock(address who, uint timelockIndex) external view returns (uint) {

        Timelock memory timelock = timelockOf(who, timelockIndex);
        if (timelock.totalAmount <= timelock.tokensTransferred) {
            return 0;
        } else {
            return timelock.totalAmount - timelock.tokensTransferred;
        }
    }

    function totalUnlockedToDateOfTimelock(address who, uint timelockIndex) public view returns (uint total) {

        Timelock memory _timelock = timelockOf(who, timelockIndex);

        return calculateUnlocked(
            _timelock.commencementTimestamp,
            block.timestamp,
            _timelock.totalAmount,
            _timelock.scheduleId
        );
    }

    function balanceOf(address who) external view returns (uint) {

        return unlockedBalanceOf(who) + lockedBalanceOf(who);
    }

    function transfer(address to, uint value) external returns (bool) {

        return _transfer(msg.sender, to, value);
    }
    function transferFrom(address from, address to, uint value) external returns (bool) {

        require(_allowances[from][msg.sender] >= value, "value > allowance");
        _allowances[from][msg.sender] -= value;
        return _transfer(from, to, value);
    }

    function approve(address spender, uint amount) external returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint addedValue) external returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {

        uint currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "decrease > allowance");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
    function decimals() public view returns (uint8) {

        return token.decimals();
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }
    function totalSupply() external view returns (uint) {

        return token.balanceOf(address(this));
    }

    function _transfer(address from, address to, uint value) internal returns (bool) {

        require(unlockedBalanceOf(from) >= value, "amount > unlocked");

        uint remainingTransfer = value;

        for (uint i = 0; i < timelockCountOf(from); i++) {
            if (timelocks[from][i].tokensTransferred == timelocks[from][i].totalAmount) {
                continue;
            } else if (remainingTransfer > unlockedBalanceOfTimelock(from, i)) {
                remainingTransfer -= unlockedBalanceOfTimelock(from, i);
                timelocks[from][i].tokensTransferred += unlockedBalanceOfTimelock(from, i);
            } else {
                timelocks[from][i].tokensTransferred += remainingTransfer;
                remainingTransfer = 0;
                break;
            }
        }

        require(remainingTransfer == 0, "bad transfer");

        token.safeTransfer(to, value);
        return true;
    }

    function transferTimelock(address to, uint value, uint timelockId) public returns (bool) {

        require(unlockedBalanceOfTimelock(msg.sender, timelockId) >= value, "amount > unlocked");
        timelocks[msg.sender][timelockId].tokensTransferred += value;
        token.safeTransfer(to, value);
        return true;
    }

    function calculateUnlocked(
        uint commencedTimestamp,
        uint currentTimestamp,
        uint amount,
        uint scheduleId
    ) public view returns (uint unlocked) {

        return calculateUnlocked(commencedTimestamp, currentTimestamp, amount, releaseSchedules[scheduleId]);
    }

    function _approve(address owner, address spender, uint amount) internal {

        require(owner != address(0), "owner is 0 address");
        require(spender != address(0), "spender is 0 address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function scheduleCount() external view returns (uint count) {

        return releaseSchedules.length;
    }

    function timelockOf(address who, uint index) public view returns (Timelock memory timelock) {

        return timelocks[who][index];
    }

    function timelockCountOf(address who) public view returns (uint) {

        return timelocks[who].length;
    }

    function calculateUnlocked(
        uint commencedTimestamp,
        uint currentTimestamp,
        uint amount,
        ReleaseSchedule memory releaseSchedule)
    public pure returns (uint unlocked) {

        return calculateUnlocked(
            commencedTimestamp,
            currentTimestamp,
            amount,
            releaseSchedule.releaseCount,
            releaseSchedule.delayUntilFirstReleaseInSeconds,
            releaseSchedule.initialReleasePortionInBips,
            releaseSchedule.periodBetweenReleasesInSeconds
        );
    }

    function calculateUnlocked(
        uint commencedTimestamp,
        uint currentTimestamp,
        uint amount,
        uint releaseCount,
        uint delayUntilFirstReleaseInSeconds,
        uint initialReleasePortionInBips,
        uint periodBetweenReleasesInSeconds
    ) public pure returns (uint unlocked) {

        if (commencedTimestamp > currentTimestamp) {
            return 0;
        }
        uint secondsElapsed = currentTimestamp - commencedTimestamp;

        if (
            secondsElapsed >= delayUntilFirstReleaseInSeconds +
            (periodBetweenReleasesInSeconds * (releaseCount - 1))
        ) {
            return amount;
        }

        if (secondsElapsed >= delayUntilFirstReleaseInSeconds) {
            unlocked = (amount * initialReleasePortionInBips) / BIPS_PRECISION;

            if (secondsElapsed - delayUntilFirstReleaseInSeconds >= periodBetweenReleasesInSeconds) {

                uint additionalUnlockedPeriods = (secondsElapsed - delayUntilFirstReleaseInSeconds) / periodBetweenReleasesInSeconds;

                unlocked += ((amount - unlocked) * additionalUnlockedPeriods) / (releaseCount - 1);
            }
        }

        return unlocked;
    }
}