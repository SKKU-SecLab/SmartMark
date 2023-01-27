
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
}// GPL-3.0

pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;
    address private _pendingOwner;

    event OwnershipOffered(address indexed pendingOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor(address _initialOwner) {
        _setOwner(_initialOwner);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    function pendingOwner() external view virtual returns (address) {
        return _pendingOwner;
    }

    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Ownable/pendingOwner-not-zero-address");

        _pendingOwner = _newOwner;

        emit OwnershipOffered(_newOwner);
    }

    function claimOwnership() external onlyPendingOwner {
        _setOwner(_pendingOwner);
        _pendingOwner = address(0);
    }


    function _setOwner(address _newOwner) private {
        address _oldOwner = _owner;
        _owner = _newOwner;
        emit OwnershipTransferred(_oldOwner, _newOwner);
    }


    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable/caller-not-owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "Ownable/caller-not-pendingOwner");
        _;
    }
}// GPL-3.0

pragma solidity ^0.8.0;


abstract contract Manageable is Ownable {
    address private _manager;

    event ManagerTransferred(address indexed previousManager, address indexed newManager);


    function manager() public view virtual returns (address) {
        return _manager;
    }

    function setManager(address _newManager) external onlyOwner returns (bool) {
        return _setManager(_newManager);
    }


    function _setManager(address _newManager) private returns (bool) {
        address _previousManager = _manager;

        require(_newManager != _previousManager, "Manageable/existing-manager-address");

        _manager = _newManager;

        emit ManagerTransferred(_previousManager, _newManager);
        return true;
    }


    modifier onlyManager() {
        require(manager() == msg.sender, "Manageable/caller-not-manager");
        _;
    }

    modifier onlyManagerOrOwner() {
        require(manager() == msg.sender || owner() == msg.sender, "Manageable/caller-not-manager-or-owner");
        _;
    }
}// GPL-3.0

pragma solidity >=0.6.0;

interface RNGInterface {


  event RandomNumberRequested(uint32 indexed requestId, address indexed sender);

  event RandomNumberCompleted(uint32 indexed requestId, uint256 randomNumber);

  function getLastRequestId() external view returns (uint32 requestId);


  function getRequestFee() external view returns (address feeToken, uint256 requestFee);


  function requestRandomNumber() external returns (uint32 requestId, uint32 lockBlock);


  function isRequestComplete(uint32 requestId) external view returns (bool isCompleted);


  function randomNumber(uint32 requestId) external returns (uint256 randomNum);

}// GPL-3.0

pragma solidity 0.8.6;

library ExtendedSafeCastLib {

    function toUint208(uint256 _value) internal pure returns (uint208) {

        require(_value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(_value);
    }

    function toUint224(uint256 _value) internal pure returns (uint224) {

        require(_value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(_value);
    }
}// GPL-3.0

pragma solidity 0.8.6;

library OverflowSafeComparatorLib {

    function lt(
        uint32 _a,
        uint32 _b,
        uint32 _timestamp
    ) internal pure returns (bool) {

        if (_a <= _timestamp && _b <= _timestamp) return _a < _b;

        uint256 aAdjusted = _a > _timestamp ? _a : _a + 2**32;
        uint256 bAdjusted = _b > _timestamp ? _b : _b + 2**32;

        return aAdjusted < bAdjusted;
    }

    function lte(
        uint32 _a,
        uint32 _b,
        uint32 _timestamp
    ) internal pure returns (bool) {


        if (_a <= _timestamp && _b <= _timestamp) return _a <= _b;

        uint256 aAdjusted = _a > _timestamp ? _a : _a + 2**32;
        uint256 bAdjusted = _b > _timestamp ? _b : _b + 2**32;

        return aAdjusted <= bAdjusted;
    }

    function checkedSub(
        uint32 _a,
        uint32 _b,
        uint32 _timestamp
    ) internal pure returns (uint32) {


        if (_a <= _timestamp && _b <= _timestamp) return _a - _b;

        uint256 aAdjusted = _a > _timestamp ? _a : _a + 2**32;
        uint256 bAdjusted = _b > _timestamp ? _b : _b + 2**32;

        return uint32(aAdjusted - bAdjusted);
    }
}// GPL-3.0

pragma solidity 0.8.6;

library RingBufferLib {

    function wrap(uint256 _index, uint256 _cardinality) internal pure returns (uint256) {

        return _index % _cardinality;
    }

    function offset(
        uint256 _index,
        uint256 _amount,
        uint256 _cardinality
    ) internal pure returns (uint256) {

        return wrap(_index + _cardinality - _amount, _cardinality);
    }

    function newestIndex(uint256 _nextIndex, uint256 _cardinality)
        internal
        pure
        returns (uint256)
    {

        if (_cardinality == 0) {
            return 0;
        }

        return wrap(_nextIndex + _cardinality - 1, _cardinality);
    }

    function nextIndex(uint256 _index, uint256 _cardinality)
        internal
        pure
        returns (uint256)
    {

        return wrap(_index + 1, _cardinality);
    }
}// GPL-3.0

pragma solidity 0.8.6;



library ObservationLib {

    using OverflowSafeComparatorLib for uint32;
    using SafeCast for uint256;

    uint24 public constant MAX_CARDINALITY = 16777215; // 2**24

    struct Observation {
        uint224 amount;
        uint32 timestamp;
    }

    function binarySearch(
        Observation[MAX_CARDINALITY] storage _observations,
        uint24 _newestObservationIndex,
        uint24 _oldestObservationIndex,
        uint32 _target,
        uint24 _cardinality,
        uint32 _time
    ) internal view returns (Observation memory beforeOrAt, Observation memory atOrAfter) {

        uint256 leftSide = _oldestObservationIndex;
        uint256 rightSide = _newestObservationIndex < leftSide
            ? leftSide + _cardinality - 1
            : _newestObservationIndex;
        uint256 currentIndex;

        while (true) {
            currentIndex = (leftSide + rightSide) / 2;

            beforeOrAt = _observations[uint24(RingBufferLib.wrap(currentIndex, _cardinality))];
            uint32 beforeOrAtTimestamp = beforeOrAt.timestamp;

            if (beforeOrAtTimestamp == 0) {
                leftSide = currentIndex + 1;
                continue;
            }

            atOrAfter = _observations[uint24(RingBufferLib.nextIndex(currentIndex, _cardinality))];

            bool targetAtOrAfter = beforeOrAtTimestamp.lte(_target, _time);

            if (targetAtOrAfter && _target.lte(atOrAfter.timestamp, _time)) {
                break;
            }

            if (!targetAtOrAfter) {
                rightSide = currentIndex - 1;
            } else {
                leftSide = currentIndex + 1;
            }
        }
    }
}// GPL-3.0

pragma solidity 0.8.6;


library TwabLib {

    using OverflowSafeComparatorLib for uint32;
    using ExtendedSafeCastLib for uint256;

    uint24 public constant MAX_CARDINALITY = 16777215; // 2**24

    struct AccountDetails {
        uint208 balance;
        uint24 nextTwabIndex;
        uint24 cardinality;
    }

    struct Account {
        AccountDetails details;
        ObservationLib.Observation[MAX_CARDINALITY] twabs;
    }

    function increaseBalance(
        Account storage _account,
        uint208 _amount,
        uint32 _currentTime
    )
        internal
        returns (
            AccountDetails memory accountDetails,
            ObservationLib.Observation memory twab,
            bool isNew
        )
    {

        AccountDetails memory _accountDetails = _account.details;
        (accountDetails, twab, isNew) = _nextTwab(_account.twabs, _accountDetails, _currentTime);
        accountDetails.balance = _accountDetails.balance + _amount;
    }

    function decreaseBalance(
        Account storage _account,
        uint208 _amount,
        string memory _revertMessage,
        uint32 _currentTime
    )
        internal
        returns (
            AccountDetails memory accountDetails,
            ObservationLib.Observation memory twab,
            bool isNew
        )
    {

        AccountDetails memory _accountDetails = _account.details;

        require(_accountDetails.balance >= _amount, _revertMessage);

        (accountDetails, twab, isNew) = _nextTwab(_account.twabs, _accountDetails, _currentTime);
        unchecked {
            accountDetails.balance -= _amount;
        }
    }

    function getAverageBalanceBetween(
        ObservationLib.Observation[MAX_CARDINALITY] storage _twabs,
        AccountDetails memory _accountDetails,
        uint32 _startTime,
        uint32 _endTime,
        uint32 _currentTime
    ) internal view returns (uint256) {

        uint32 endTime = _endTime > _currentTime ? _currentTime : _endTime;

        return
            _getAverageBalanceBetween(_twabs, _accountDetails, _startTime, endTime, _currentTime);
    }

    function oldestTwab(
        ObservationLib.Observation[MAX_CARDINALITY] storage _twabs,
        AccountDetails memory _accountDetails
    ) internal view returns (uint24 index, ObservationLib.Observation memory twab) {

        index = _accountDetails.nextTwabIndex;
        twab = _twabs[index];

        if (twab.timestamp == 0) {
            index = 0;
            twab = _twabs[0];
        }
    }

    function newestTwab(
        ObservationLib.Observation[MAX_CARDINALITY] storage _twabs,
        AccountDetails memory _accountDetails
    ) internal view returns (uint24 index, ObservationLib.Observation memory twab) {

        index = uint24(RingBufferLib.newestIndex(_accountDetails.nextTwabIndex, MAX_CARDINALITY));
        twab = _twabs[index];
    }

    function getBalanceAt(
        ObservationLib.Observation[MAX_CARDINALITY] storage _twabs,
        AccountDetails memory _accountDetails,
        uint32 _targetTime,
        uint32 _currentTime
    ) internal view returns (uint256) {

        uint32 timeToTarget = _targetTime > _currentTime ? _currentTime : _targetTime;
        return _getBalanceAt(_twabs, _accountDetails, timeToTarget, _currentTime);
    }

    function _getAverageBalanceBetween(
        ObservationLib.Observation[MAX_CARDINALITY] storage _twabs,
        AccountDetails memory _accountDetails,
        uint32 _startTime,
        uint32 _endTime,
        uint32 _currentTime
    ) private view returns (uint256) {

        (uint24 oldestTwabIndex, ObservationLib.Observation memory oldTwab) = oldestTwab(
            _twabs,
            _accountDetails
        );

        (uint24 newestTwabIndex, ObservationLib.Observation memory newTwab) = newestTwab(
            _twabs,
            _accountDetails
        );

        ObservationLib.Observation memory startTwab = _calculateTwab(
            _twabs,
            _accountDetails,
            newTwab,
            oldTwab,
            newestTwabIndex,
            oldestTwabIndex,
            _startTime,
            _currentTime
        );

        ObservationLib.Observation memory endTwab = _calculateTwab(
            _twabs,
            _accountDetails,
            newTwab,
            oldTwab,
            newestTwabIndex,
            oldestTwabIndex,
            _endTime,
            _currentTime
        );

        return (endTwab.amount - startTwab.amount) / OverflowSafeComparatorLib.checkedSub(endTwab.timestamp, startTwab.timestamp, _currentTime);
    }

    function _getBalanceAt(
        ObservationLib.Observation[MAX_CARDINALITY] storage _twabs,
        AccountDetails memory _accountDetails,
        uint32 _targetTime,
        uint32 _currentTime
    ) private view returns (uint256) {

        uint24 newestTwabIndex;
        ObservationLib.Observation memory afterOrAt;
        ObservationLib.Observation memory beforeOrAt;
        (newestTwabIndex, beforeOrAt) = newestTwab(_twabs, _accountDetails);

        if (beforeOrAt.timestamp.lte(_targetTime, _currentTime)) {
            return _accountDetails.balance;
        }

        uint24 oldestTwabIndex;
        (oldestTwabIndex, beforeOrAt) = oldestTwab(_twabs, _accountDetails);

        if (_targetTime.lt(beforeOrAt.timestamp, _currentTime)) {
            return 0;
        }

        (beforeOrAt, afterOrAt) = ObservationLib.binarySearch(
            _twabs,
            newestTwabIndex,
            oldestTwabIndex,
            _targetTime,
            _accountDetails.cardinality,
            _currentTime
        );

        return
            (afterOrAt.amount - beforeOrAt.amount) / OverflowSafeComparatorLib.checkedSub(afterOrAt.timestamp, beforeOrAt.timestamp, _currentTime);
    }

    function _calculateTwab(
        ObservationLib.Observation[MAX_CARDINALITY] storage _twabs,
        AccountDetails memory _accountDetails,
        ObservationLib.Observation memory _newestTwab,
        ObservationLib.Observation memory _oldestTwab,
        uint24 _newestTwabIndex,
        uint24 _oldestTwabIndex,
        uint32 _targetTimestamp,
        uint32 _time
    ) private view returns (ObservationLib.Observation memory) {

        if (_newestTwab.timestamp.lt(_targetTimestamp, _time)) {
            return _computeNextTwab(_newestTwab, _accountDetails.balance, _targetTimestamp);
        }

        if (_newestTwab.timestamp == _targetTimestamp) {
            return _newestTwab;
        }

        if (_oldestTwab.timestamp == _targetTimestamp) {
            return _oldestTwab;
        }

        if (_targetTimestamp.lt(_oldestTwab.timestamp, _time)) {
            return ObservationLib.Observation({ amount: 0, timestamp: _targetTimestamp });
        }

        (
            ObservationLib.Observation memory beforeOrAtStart,
            ObservationLib.Observation memory afterOrAtStart
        ) = ObservationLib.binarySearch(
                _twabs,
                _newestTwabIndex,
                _oldestTwabIndex,
                _targetTimestamp,
                _accountDetails.cardinality,
                _time
            );

        uint224 heldBalance = (afterOrAtStart.amount - beforeOrAtStart.amount) /
            OverflowSafeComparatorLib.checkedSub(afterOrAtStart.timestamp, beforeOrAtStart.timestamp, _time);

        return _computeNextTwab(beforeOrAtStart, heldBalance, _targetTimestamp);
    }

    function _computeNextTwab(
        ObservationLib.Observation memory _currentTwab,
        uint224 _currentBalance,
        uint32 _time
    ) private pure returns (ObservationLib.Observation memory) {

        return
            ObservationLib.Observation({
                amount: _currentTwab.amount +
                    _currentBalance *
                    (_time.checkedSub(_currentTwab.timestamp, _time)),
                timestamp: _time
            });
    }

    function _nextTwab(
        ObservationLib.Observation[MAX_CARDINALITY] storage _twabs,
        AccountDetails memory _accountDetails,
        uint32 _currentTime
    )
        private
        returns (
            AccountDetails memory accountDetails,
            ObservationLib.Observation memory twab,
            bool isNew
        )
    {

        (, ObservationLib.Observation memory _newestTwab) = newestTwab(_twabs, _accountDetails);

        if (_newestTwab.timestamp == _currentTime) {
            return (_accountDetails, _newestTwab, false);
        }

        ObservationLib.Observation memory newTwab = _computeNextTwab(
            _newestTwab,
            _accountDetails.balance,
            _currentTime
        );

        _twabs[_accountDetails.nextTwabIndex] = newTwab;

        AccountDetails memory nextAccountDetails = push(_accountDetails);

        return (nextAccountDetails, newTwab, true);
    }

    function push(AccountDetails memory _accountDetails)
        internal
        pure
        returns (AccountDetails memory)
    {

        _accountDetails.nextTwabIndex = uint24(
            RingBufferLib.nextIndex(_accountDetails.nextTwabIndex, MAX_CARDINALITY)
        );

        if (_accountDetails.cardinality < MAX_CARDINALITY) {
            _accountDetails.cardinality += 1;
        }

        return _accountDetails;
    }
}// GPL-3.0

pragma solidity 0.8.6;


interface IControlledToken is IERC20 {


    function controller() external view returns (address);


    function controllerMint(address user, uint256 amount) external;


    function controllerBurn(address user, uint256 amount) external;


    function controllerBurnFrom(
        address operator,
        address user,
        uint256 amount
    ) external;

}// GPL-3.0

pragma solidity 0.8.6;


interface ITicket is IControlledToken {

    struct AccountDetails {
        uint224 balance;
        uint16 nextTwabIndex;
        uint16 cardinality;
    }

    struct Account {
        AccountDetails details;
        ObservationLib.Observation[65535] twabs;
    }

    event Delegated(address indexed delegator, address indexed delegate);

    event TicketInitialized(string name, string symbol, uint8 decimals, address indexed controller);

    event NewUserTwab(
        address indexed delegate,
        ObservationLib.Observation newTwab
    );

    event NewTotalSupplyTwab(ObservationLib.Observation newTotalSupplyTwab);

    function delegateOf(address user) external view returns (address);


    function delegate(address to) external;


    function controllerDelegateFor(address user, address delegate) external;


    function delegateWithSignature(
        address user,
        address delegate,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function getAccountDetails(address user) external view returns (TwabLib.AccountDetails memory);


    function getTwab(address user, uint16 index)
        external
        view
        returns (ObservationLib.Observation memory);


    function getBalanceAt(address user, uint64 timestamp) external view returns (uint256);


    function getBalancesAt(address user, uint64[] calldata timestamps)
        external
        view
        returns (uint256[] memory);


    function getAverageBalanceBetween(
        address user,
        uint64 startTime,
        uint64 endTime
    ) external view returns (uint256);


    function getAverageBalancesBetween(
        address user,
        uint64[] calldata startTimes,
        uint64[] calldata endTimes
    ) external view returns (uint256[] memory);


    function getTotalSupplyAt(uint64 timestamp) external view returns (uint256);


    function getTotalSuppliesAt(uint64[] calldata timestamps)
        external
        view
        returns (uint256[] memory);


    function getAverageTotalSuppliesBetween(
        uint64[] calldata startTimes,
        uint64[] calldata endTimes
    ) external view returns (uint256[] memory);

}// GPL-3.0

pragma solidity 0.8.6;


interface IDrawBeacon {


    struct Draw {
        uint256 winningRandomNumber;
        uint32 drawId;
        uint64 timestamp;
        uint64 beaconPeriodStartedAt;
        uint32 beaconPeriodSeconds;
    }

    event DrawBufferUpdated(IDrawBuffer indexed newDrawBuffer);

    event BeaconPeriodStarted(uint64 indexed startedAt);

    event DrawStarted(uint32 indexed rngRequestId, uint32 rngLockBlock);

    event DrawCancelled(uint32 indexed rngRequestId, uint32 rngLockBlock);

    event DrawCompleted(uint256 randomNumber);

    event RngServiceUpdated(RNGInterface indexed rngService);

    event RngTimeoutSet(uint32 rngTimeout);

    event BeaconPeriodSecondsUpdated(uint32 drawPeriodSeconds);

    function beaconPeriodRemainingSeconds() external view returns (uint64);


    function beaconPeriodEndAt() external view returns (uint64);


    function canStartDraw() external view returns (bool);


    function canCompleteDraw() external view returns (bool);


    function calculateNextBeaconPeriodStartTime(uint64 time) external view returns (uint64);


    function cancelDraw() external;


    function completeDraw() external;


    function getLastRngLockBlock() external view returns (uint32);


    function getLastRngRequestId() external view returns (uint32);


    function isBeaconPeriodOver() external view returns (bool);


    function isRngCompleted() external view returns (bool);


    function isRngRequested() external view returns (bool);


    function isRngTimedOut() external view returns (bool);


    function setBeaconPeriodSeconds(uint32 beaconPeriodSeconds) external;


    function setRngTimeout(uint32 rngTimeout) external;


    function setRngService(RNGInterface rngService) external;


    function startDraw() external;


    function setDrawBuffer(IDrawBuffer newDrawBuffer) external returns (IDrawBuffer);

}// GPL-3.0

pragma solidity 0.8.6;


interface IDrawBuffer {

    event DrawSet(uint32 indexed drawId, IDrawBeacon.Draw draw);

    function getBufferCardinality() external view returns (uint32);


    function getDraw(uint32 drawId) external view returns (IDrawBeacon.Draw memory);


    function getDraws(uint32[] calldata drawIds) external view returns (IDrawBeacon.Draw[] memory);


    function getDrawCount() external view returns (uint32);


    function getNewestDraw() external view returns (IDrawBeacon.Draw memory);


    function getOldestDraw() external view returns (IDrawBeacon.Draw memory);


    function pushDraw(IDrawBeacon.Draw calldata draw) external returns (uint32);


    function setDraw(IDrawBeacon.Draw calldata newDraw) external returns (uint32);

}// GPL-3.0

pragma solidity 0.8.6;


library DrawRingBufferLib {

    struct Buffer {
        uint32 lastDrawId;
        uint32 nextIndex;
        uint32 cardinality;
    }

    function isInitialized(Buffer memory _buffer) internal pure returns (bool) {

        return !(_buffer.nextIndex == 0 && _buffer.lastDrawId == 0);
    }

    function push(Buffer memory _buffer, uint32 _drawId) internal pure returns (Buffer memory) {

        require(!isInitialized(_buffer) || _drawId == _buffer.lastDrawId + 1, "DRB/must-be-contig");

        return
            Buffer({
                lastDrawId: _drawId,
                nextIndex: uint32(RingBufferLib.nextIndex(_buffer.nextIndex, _buffer.cardinality)),
                cardinality: _buffer.cardinality
            });
    }

    function getIndex(Buffer memory _buffer, uint32 _drawId) internal pure returns (uint32) {

        require(isInitialized(_buffer) && _drawId <= _buffer.lastDrawId, "DRB/future-draw");

        uint32 indexOffset = _buffer.lastDrawId - _drawId;
        require(indexOffset < _buffer.cardinality, "DRB/expired-draw");

        uint256 mostRecent = RingBufferLib.newestIndex(_buffer.nextIndex, _buffer.cardinality);

        return uint32(RingBufferLib.offset(uint32(mostRecent), indexOffset, _buffer.cardinality));
    }
}// GPL-3.0

pragma solidity 0.8.6;

interface IPrizeDistributionBuffer {


    struct PrizeDistribution {
        uint8 bitRangeSize;
        uint8 matchCardinality;
        uint32 startTimestampOffset;
        uint32 endTimestampOffset;
        uint32 maxPicksPerUser;
        uint32 expiryDuration;
        uint104 numberOfPicks;
        uint32[16] tiers;
        uint256 prize;
    }

    event PrizeDistributionSet(
        uint32 indexed drawId,
        IPrizeDistributionBuffer.PrizeDistribution prizeDistribution
    );

    function getBufferCardinality() external view returns (uint32);


    function getNewestPrizeDistribution()
        external
        view
        returns (IPrizeDistributionBuffer.PrizeDistribution memory prizeDistribution, uint32 drawId);


    function getOldestPrizeDistribution()
        external
        view
        returns (IPrizeDistributionBuffer.PrizeDistribution memory prizeDistribution, uint32 drawId);


    function getPrizeDistributions(uint32[] calldata drawIds)
        external
        view
        returns (IPrizeDistributionBuffer.PrizeDistribution[] memory);


    function getPrizeDistribution(uint32 drawId)
        external
        view
        returns (IPrizeDistributionBuffer.PrizeDistribution memory);


    function getPrizeDistributionCount() external view returns (uint32);


    function pushPrizeDistribution(
        uint32 drawId,
        IPrizeDistributionBuffer.PrizeDistribution calldata prizeDistribution
    ) external returns (bool);


    function setPrizeDistribution(uint32 drawId, IPrizeDistributionBuffer.PrizeDistribution calldata draw)
        external
        returns (uint32);

}// GPL-3.0

pragma solidity 0.8.6;



contract PrizeDistributionBuffer is IPrizeDistributionBuffer, Manageable {

    using DrawRingBufferLib for DrawRingBufferLib.Buffer;

    uint256 internal constant MAX_CARDINALITY = 256;

    uint256 internal constant TIERS_CEILING = 1e9;

    event Deployed(uint8 cardinality);

    IPrizeDistributionBuffer.PrizeDistribution[MAX_CARDINALITY]
        internal prizeDistributionRingBuffer;

    DrawRingBufferLib.Buffer internal bufferMetadata;


    constructor(address _owner, uint8 _cardinality) Ownable(_owner) {
        bufferMetadata.cardinality = _cardinality;
        emit Deployed(_cardinality);
    }


    function getBufferCardinality() external view override returns (uint32) {

        return bufferMetadata.cardinality;
    }

    function getPrizeDistribution(uint32 _drawId)
        external
        view
        override
        returns (IPrizeDistributionBuffer.PrizeDistribution memory)
    {

        return _getPrizeDistribution(bufferMetadata, _drawId);
    }

    function getPrizeDistributions(uint32[] calldata _drawIds)
        external
        view
        override
        returns (IPrizeDistributionBuffer.PrizeDistribution[] memory)
    {

        uint256 drawIdsLength = _drawIds.length;
        DrawRingBufferLib.Buffer memory buffer = bufferMetadata;
        IPrizeDistributionBuffer.PrizeDistribution[]
            memory _prizeDistributions = new IPrizeDistributionBuffer.PrizeDistribution[](
                drawIdsLength
            );

        for (uint256 i = 0; i < drawIdsLength; i++) {
            _prizeDistributions[i] = _getPrizeDistribution(buffer, _drawIds[i]);
        }

        return _prizeDistributions;
    }

    function getPrizeDistributionCount() external view override returns (uint32) {

        DrawRingBufferLib.Buffer memory buffer = bufferMetadata;

        if (buffer.lastDrawId == 0) {
            return 0;
        }

        uint32 bufferNextIndex = buffer.nextIndex;

        if (prizeDistributionRingBuffer[bufferNextIndex].matchCardinality != 0) {
            return buffer.cardinality;
        } else {
            return bufferNextIndex;
        }
    }

    function getNewestPrizeDistribution()
        external
        view
        override
        returns (IPrizeDistributionBuffer.PrizeDistribution memory prizeDistribution, uint32 drawId)
    {

        DrawRingBufferLib.Buffer memory buffer = bufferMetadata;

        return (prizeDistributionRingBuffer[buffer.getIndex(buffer.lastDrawId)], buffer.lastDrawId);
    }

    function getOldestPrizeDistribution()
        external
        view
        override
        returns (IPrizeDistributionBuffer.PrizeDistribution memory prizeDistribution, uint32 drawId)
    {

        DrawRingBufferLib.Buffer memory buffer = bufferMetadata;

        prizeDistribution = prizeDistributionRingBuffer[buffer.nextIndex];

        if (buffer.lastDrawId == 0) {
            drawId = 0; // return 0 to indicate no prizeDistribution ring buffer history
        } else if (prizeDistribution.bitRangeSize == 0) {
            prizeDistribution = prizeDistributionRingBuffer[0];
            drawId = (buffer.lastDrawId + 1) - buffer.nextIndex;
        } else {
            drawId = (buffer.lastDrawId + 1) - buffer.cardinality;
        }
    }

    function pushPrizeDistribution(
        uint32 _drawId,
        IPrizeDistributionBuffer.PrizeDistribution calldata _prizeDistribution
    ) external override onlyManagerOrOwner returns (bool) {

        return _pushPrizeDistribution(_drawId, _prizeDistribution);
    }

    function setPrizeDistribution(
        uint32 _drawId,
        IPrizeDistributionBuffer.PrizeDistribution calldata _prizeDistribution
    ) external override onlyOwner returns (uint32) {

        DrawRingBufferLib.Buffer memory buffer = bufferMetadata;
        uint32 index = buffer.getIndex(_drawId);
        prizeDistributionRingBuffer[index] = _prizeDistribution;

        emit PrizeDistributionSet(_drawId, _prizeDistribution);

        return _drawId;
    }


    function _getPrizeDistribution(DrawRingBufferLib.Buffer memory _buffer, uint32 _drawId)
        internal
        view
        returns (IPrizeDistributionBuffer.PrizeDistribution memory)
    {

        return prizeDistributionRingBuffer[_buffer.getIndex(_drawId)];
    }

    function _pushPrizeDistribution(
        uint32 _drawId,
        IPrizeDistributionBuffer.PrizeDistribution calldata _prizeDistribution
    ) internal returns (bool) {

        require(_drawId > 0, "DrawCalc/draw-id-gt-0");
        require(_prizeDistribution.matchCardinality > 0, "DrawCalc/matchCardinality-gt-0");
        require(
            _prizeDistribution.bitRangeSize <= 256 / _prizeDistribution.matchCardinality,
            "DrawCalc/bitRangeSize-too-large"
        );

        require(_prizeDistribution.bitRangeSize > 0, "DrawCalc/bitRangeSize-gt-0");
        require(_prizeDistribution.maxPicksPerUser > 0, "DrawCalc/maxPicksPerUser-gt-0");
        require(_prizeDistribution.expiryDuration > 0, "DrawCalc/expiryDuration-gt-0");

        uint256 sumTotalTiers = 0;
        uint256 tiersLength = _prizeDistribution.tiers.length;

        for (uint256 index = 0; index < tiersLength; index++) {
            uint256 tier = _prizeDistribution.tiers[index];
            sumTotalTiers += tier;
        }

        require(sumTotalTiers <= TIERS_CEILING, "DrawCalc/tiers-gt-100%");

        DrawRingBufferLib.Buffer memory buffer = bufferMetadata;

        prizeDistributionRingBuffer[buffer.nextIndex] = _prizeDistribution;

        bufferMetadata = buffer.push(_drawId);

        emit PrizeDistributionSet(_drawId, _prizeDistribution);

        return true;
    }
}// GPL-3.0
pragma solidity 0.8.6;



interface IPrizeDistributor {


    event ClaimedDraw(address indexed user, uint32 indexed drawId, uint256 payout);

    event DrawCalculatorSet(IDrawCalculator indexed calculator);

    event TokenSet(IERC20 indexed token);

    event ERC20Withdrawn(IERC20 indexed token, address indexed to, uint256 amount);

    function claim(
        address user,
        uint32[] calldata drawIds,
        bytes calldata data
    ) external returns (uint256);


    function getDrawCalculator() external view returns (IDrawCalculator);


    function getDrawPayoutBalanceOf(address user, uint32 drawId) external view returns (uint256);


    function getToken() external view returns (IERC20);


    function setDrawCalculator(IDrawCalculator newCalculator) external returns (IDrawCalculator);


    function withdrawERC20(
        IERC20 token,
        address to,
        uint256 amount
    ) external returns (bool);

}// GPL-3.0

pragma solidity 0.8.6;



contract PrizeDistributor is IPrizeDistributor, Ownable {

    using SafeERC20 for IERC20;


    IDrawCalculator internal drawCalculator;

    IERC20 internal immutable token;

    mapping(address => mapping(uint256 => uint256)) internal userDrawPayouts;


    constructor(
        address _owner,
        IERC20 _token,
        IDrawCalculator _drawCalculator
    ) Ownable(_owner) {
        _setDrawCalculator(_drawCalculator);
        require(address(_token) != address(0), "PrizeDistributor/token-not-zero-address");
        token = _token;
        emit TokenSet(_token);
    }


    function claim(
        address _user,
        uint32[] calldata _drawIds,
        bytes calldata _data
    ) external override returns (uint256) {

        
        uint256 totalPayout;
        
        (uint256[] memory drawPayouts, ) = drawCalculator.calculate(_user, _drawIds, _data); // neglect the prizeCounts since we are not interested in them here

        uint256 drawPayoutsLength = drawPayouts.length;
        for (uint256 payoutIndex = 0; payoutIndex < drawPayoutsLength; payoutIndex++) {
            uint32 drawId = _drawIds[payoutIndex];
            uint256 payout = drawPayouts[payoutIndex];
            uint256 oldPayout = _getDrawPayoutBalanceOf(_user, drawId);
            uint256 payoutDiff = 0;

            require(payout > oldPayout, "PrizeDistributor/zero-payout");

            unchecked {
                payoutDiff = payout - oldPayout;
            }

            _setDrawPayoutBalanceOf(_user, drawId, payout);

            totalPayout += payoutDiff;

            emit ClaimedDraw(_user, drawId, payoutDiff);
        }

        _awardPayout(_user, totalPayout);

        return totalPayout;
    }

    function withdrawERC20(
        IERC20 _erc20Token,
        address _to,
        uint256 _amount
    ) external override onlyOwner returns (bool) {

        require(_to != address(0), "PrizeDistributor/recipient-not-zero-address");
        require(address(_erc20Token) != address(0), "PrizeDistributor/ERC20-not-zero-address");

        _erc20Token.safeTransfer(_to, _amount);

        emit ERC20Withdrawn(_erc20Token, _to, _amount);

        return true;
    }

    function getDrawCalculator() external view override returns (IDrawCalculator) {

        return drawCalculator;
    }

    function getDrawPayoutBalanceOf(address _user, uint32 _drawId)
        external
        view
        override
        returns (uint256)
    {

        return _getDrawPayoutBalanceOf(_user, _drawId);
    }

    function getToken() external view override returns (IERC20) {

        return token;
    }

    function setDrawCalculator(IDrawCalculator _newCalculator)
        external
        override
        onlyOwner
        returns (IDrawCalculator)
    {

        _setDrawCalculator(_newCalculator);
        return _newCalculator;
    }


    function _getDrawPayoutBalanceOf(address _user, uint32 _drawId)
        internal
        view
        returns (uint256)
    {

        return userDrawPayouts[_user][_drawId];
    }

    function _setDrawPayoutBalanceOf(
        address _user,
        uint32 _drawId,
        uint256 _payout
    ) internal {

        userDrawPayouts[_user][_drawId] = _payout;
    }

    function _setDrawCalculator(IDrawCalculator _newCalculator) internal {

        require(address(_newCalculator) != address(0), "PrizeDistributor/calc-not-zero");
        drawCalculator = _newCalculator;

        emit DrawCalculatorSet(_newCalculator);
    }

    function _awardPayout(address _to, uint256 _amount) internal {

        token.safeTransfer(_to, _amount);
    }

}// GPL-3.0

pragma solidity 0.8.6;


interface IDrawCalculator {

    struct PickPrize {
        bool won;
        uint8 tierIndex;
    }

    event Deployed(
        ITicket indexed ticket,
        IDrawBuffer indexed drawBuffer,
        IPrizeDistributionBuffer indexed prizeDistributionBuffer
    );

    event PrizeDistributorSet(PrizeDistributor indexed prizeDistributor);

    function calculate(
        address user,
        uint32[] calldata drawIds,
        bytes calldata data
    ) external view returns (uint256[] memory, bytes memory);


    function getDrawBuffer() external view returns (IDrawBuffer);


    function getPrizeDistributionBuffer() external view returns (IPrizeDistributionBuffer);


    function getNormalizedBalancesForDrawIds(address user, uint32[] calldata drawIds)
        external
        view
        returns (uint256[] memory);


}// GPL-3.0

pragma solidity 0.8.6;


contract DrawCalculator is IDrawCalculator {


    IDrawBuffer public immutable drawBuffer;

    ITicket public immutable ticket;

    IPrizeDistributionBuffer public immutable prizeDistributionBuffer;

    uint8 public constant TIERS_LENGTH = 16;


    constructor(
        ITicket _ticket,
        IDrawBuffer _drawBuffer,
        IPrizeDistributionBuffer _prizeDistributionBuffer
    ) {
        require(address(_ticket) != address(0), "DrawCalc/ticket-not-zero");
        require(address(_prizeDistributionBuffer) != address(0), "DrawCalc/pdb-not-zero");
        require(address(_drawBuffer) != address(0), "DrawCalc/dh-not-zero");

        ticket = _ticket;
        drawBuffer = _drawBuffer;
        prizeDistributionBuffer = _prizeDistributionBuffer;

        emit Deployed(_ticket, _drawBuffer, _prizeDistributionBuffer);
    }


    function calculate(
        address _user,
        uint32[] calldata _drawIds,
        bytes calldata _pickIndicesForDraws
    ) external view override returns (uint256[] memory, bytes memory) {

        uint64[][] memory pickIndices = abi.decode(_pickIndicesForDraws, (uint64 [][]));
        require(pickIndices.length == _drawIds.length, "DrawCalc/invalid-pick-indices-length");

        IDrawBeacon.Draw[] memory draws = drawBuffer.getDraws(_drawIds);

        IPrizeDistributionBuffer.PrizeDistribution[] memory _prizeDistributions = prizeDistributionBuffer
            .getPrizeDistributions(_drawIds);

        uint256[] memory userBalances = _getNormalizedBalancesAt(_user, draws, _prizeDistributions);

        bytes32 _userRandomNumber = keccak256(abi.encodePacked(_user));

        return _calculatePrizesAwardable(
                userBalances,
                _userRandomNumber,
                draws,
                pickIndices,
                _prizeDistributions
            );
    }

    function getDrawBuffer() external view override returns (IDrawBuffer) {

        return drawBuffer;
    }

    function getPrizeDistributionBuffer()
        external
        view
        override
        returns (IPrizeDistributionBuffer)
    {

        return prizeDistributionBuffer;
    }

    function getNormalizedBalancesForDrawIds(address _user, uint32[] calldata _drawIds)
        external
        view
        override
        returns (uint256[] memory)
    {

        IDrawBeacon.Draw[] memory _draws = drawBuffer.getDraws(_drawIds);
        IPrizeDistributionBuffer.PrizeDistribution[] memory _prizeDistributions = prizeDistributionBuffer
            .getPrizeDistributions(_drawIds);

        return _getNormalizedBalancesAt(_user, _draws, _prizeDistributions);
    }


    function _calculatePrizesAwardable(
        uint256[] memory _normalizedUserBalances,
        bytes32 _userRandomNumber,
        IDrawBeacon.Draw[] memory _draws,
        uint64[][] memory _pickIndicesForDraws,
        IPrizeDistributionBuffer.PrizeDistribution[] memory _prizeDistributions
    ) internal view returns (uint256[] memory prizesAwardable, bytes memory prizeCounts) {

        
        uint256[] memory _prizesAwardable = new uint256[](_normalizedUserBalances.length);
        uint256[][] memory _prizeCounts = new uint256[][](_normalizedUserBalances.length);

        uint64 timeNow = uint64(block.timestamp);



        for (uint32 drawIndex = 0; drawIndex < _draws.length; drawIndex++) {

            require(timeNow < _draws[drawIndex].timestamp + _prizeDistributions[drawIndex].expiryDuration, "DrawCalc/draw-expired");

            uint64 totalUserPicks = _calculateNumberOfUserPicks(
                _prizeDistributions[drawIndex],
                _normalizedUserBalances[drawIndex]
            );

            (_prizesAwardable[drawIndex], _prizeCounts[drawIndex]) = _calculate(
                _draws[drawIndex].winningRandomNumber,
                totalUserPicks,
                _userRandomNumber,
                _pickIndicesForDraws[drawIndex],
                _prizeDistributions[drawIndex]
            );
        }
        prizeCounts = abi.encode(_prizeCounts);
        prizesAwardable = _prizesAwardable;
    }

    function _calculateNumberOfUserPicks(
        IPrizeDistributionBuffer.PrizeDistribution memory _prizeDistribution,
        uint256 _normalizedUserBalance
    ) internal pure returns (uint64) {

        return uint64((_normalizedUserBalance * _prizeDistribution.numberOfPicks) / 1 ether);
    }

    function _getNormalizedBalancesAt(
        address _user,
        IDrawBeacon.Draw[] memory _draws,
        IPrizeDistributionBuffer.PrizeDistribution[] memory _prizeDistributions
    ) internal view returns (uint256[] memory) {

        uint256 drawsLength = _draws.length;
        uint64[] memory _timestampsWithStartCutoffTimes = new uint64[](drawsLength);
        uint64[] memory _timestampsWithEndCutoffTimes = new uint64[](drawsLength);

        for (uint32 i = 0; i < drawsLength; i++) {
            unchecked {
                _timestampsWithStartCutoffTimes[i] =
                    _draws[i].timestamp - _prizeDistributions[i].startTimestampOffset;
                _timestampsWithEndCutoffTimes[i] =
                    _draws[i].timestamp - _prizeDistributions[i].endTimestampOffset;
            }
        }

        uint256[] memory balances = ticket.getAverageBalancesBetween(
            _user,
            _timestampsWithStartCutoffTimes,
            _timestampsWithEndCutoffTimes
        );

        uint256[] memory totalSupplies = ticket.getAverageTotalSuppliesBetween(
            _timestampsWithStartCutoffTimes,
            _timestampsWithEndCutoffTimes
        );

        uint256[] memory normalizedBalances = new uint256[](drawsLength);

        for (uint256 i = 0; i < drawsLength; i++) {
            if(totalSupplies[i] == 0){
                normalizedBalances[i] = 0;
            }
            else {
                normalizedBalances[i] = (balances[i] * 1 ether) / totalSupplies[i];
            }
        }

        return normalizedBalances;
    }

    function _calculate(
        uint256 _winningRandomNumber,
        uint256 _totalUserPicks,
        bytes32 _userRandomNumber,
        uint64[] memory _picks,
        IPrizeDistributionBuffer.PrizeDistribution memory _prizeDistribution
    ) internal pure returns (uint256 prize, uint256[] memory prizeCounts) {

        
        uint256[] memory masks = _createBitMasks(_prizeDistribution);
        uint32 picksLength = uint32(_picks.length);
        uint256[] memory _prizeCounts = new uint256[](_prizeDistribution.tiers.length);

        uint8 maxWinningTierIndex = 0;

        require(
            picksLength <= _prizeDistribution.maxPicksPerUser,
            "DrawCalc/exceeds-max-user-picks"
        );

        for (uint32 index = 0; index < picksLength; index++) {
            require(_picks[index] < _totalUserPicks, "DrawCalc/insufficient-user-picks");

            if (index > 0) {
                require(_picks[index] > _picks[index - 1], "DrawCalc/picks-ascending");
            }

            uint256 randomNumberThisPick = uint256(
                keccak256(abi.encode(_userRandomNumber, _picks[index]))
            );

            uint8 tiersIndex = _calculateTierIndex(
                randomNumberThisPick,
                _winningRandomNumber,
                masks
            );

            if (tiersIndex < TIERS_LENGTH) {
                if (tiersIndex > maxWinningTierIndex) {
                    maxWinningTierIndex = tiersIndex;
                }
                _prizeCounts[tiersIndex]++;
            }
        }

        uint256 prizeFraction = 0;
        uint256[] memory prizeTiersFractions = _calculatePrizeTierFractions(
            _prizeDistribution,
            maxWinningTierIndex
        );

        for (
            uint256 prizeCountIndex = 0;
            prizeCountIndex <= maxWinningTierIndex;
            prizeCountIndex++
        ) {
            if (_prizeCounts[prizeCountIndex] > 0) {
                prizeFraction +=
                    prizeTiersFractions[prizeCountIndex] *
                    _prizeCounts[prizeCountIndex];
            }
        }

        prize = (prizeFraction * _prizeDistribution.prize) / 1e9; 
        prizeCounts = _prizeCounts;
    }

    function _calculateTierIndex(
        uint256 _randomNumberThisPick,
        uint256 _winningRandomNumber,
        uint256[] memory _masks
    ) internal pure returns (uint8) {

        uint8 numberOfMatches = 0;
        uint8 masksLength = uint8(_masks.length);

        for (uint8 matchIndex = 0; matchIndex < masksLength; matchIndex++) {
            uint256 mask = _masks[matchIndex];

            if ((_randomNumberThisPick & mask) != (_winningRandomNumber & mask)) {
                if (masksLength == numberOfMatches) {
                    return 0;
                } else {
                    return masksLength - numberOfMatches;
                }
            }

            numberOfMatches++;
        }

        return masksLength - numberOfMatches;
    }

    function _createBitMasks(IPrizeDistributionBuffer.PrizeDistribution memory _prizeDistribution)
        internal
        pure
        returns (uint256[] memory)
    {

        uint256[] memory masks = new uint256[](_prizeDistribution.matchCardinality);
        masks[0] =  (2**_prizeDistribution.bitRangeSize) - 1;

        for (uint8 maskIndex = 1; maskIndex < _prizeDistribution.matchCardinality; maskIndex++) {
            masks[maskIndex] = masks[maskIndex - 1] << _prizeDistribution.bitRangeSize;
        }

        return masks;
    }

    function _calculatePrizeTierFraction(
        IPrizeDistributionBuffer.PrizeDistribution memory _prizeDistribution,
        uint256 _prizeTierIndex
    ) internal pure returns (uint256) {

        uint256 prizeFraction = _prizeDistribution.tiers[_prizeTierIndex];

        uint256 numberOfPrizesForIndex = _numberOfPrizesForIndex(
            _prizeDistribution.bitRangeSize,
            _prizeTierIndex
        );

        return prizeFraction / numberOfPrizesForIndex;
    }

    function _calculatePrizeTierFractions(
        IPrizeDistributionBuffer.PrizeDistribution memory _prizeDistribution,
        uint8 maxWinningTierIndex
    ) internal pure returns (uint256[] memory) {

        uint256[] memory prizeDistributionFractions = new uint256[](
            maxWinningTierIndex + 1
        );

        for (uint8 i = 0; i <= maxWinningTierIndex; i++) {
            prizeDistributionFractions[i] = _calculatePrizeTierFraction(
                _prizeDistribution,
                i
            );
        }

        return prizeDistributionFractions;
    }

    function _numberOfPrizesForIndex(uint8 _bitRangeSize, uint256 _prizeTierIndex)
        internal
        pure
        returns (uint256)
    {

        if (_prizeTierIndex > 0) {
            return ( 1 << _bitRangeSize * _prizeTierIndex ) - ( 1 << _bitRangeSize * (_prizeTierIndex - 1) );
        } else {
            return 1;
        }
    }
}