
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
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

pragma solidity 0.8.6;


interface ICompLike is IERC20 {

    function getCurrentVotes(address account) external view returns (uint96);


    function delegate(address delegate) external;

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


interface IPrizePool {

    event ControlledTokenAdded(ITicket indexed token);

    event AwardCaptured(uint256 amount);

    event Deposited(
        address indexed operator,
        address indexed to,
        ITicket indexed token,
        uint256 amount
    );

    event Awarded(address indexed winner, ITicket indexed token, uint256 amount);

    event AwardedExternalERC20(address indexed winner, address indexed token, uint256 amount);

    event TransferredExternalERC20(address indexed to, address indexed token, uint256 amount);

    event AwardedExternalERC721(address indexed winner, address indexed token, uint256[] tokenIds);

    event Withdrawal(
        address indexed operator,
        address indexed from,
        ITicket indexed token,
        uint256 amount,
        uint256 redeemed
    );

    event BalanceCapSet(uint256 balanceCap);

    event LiquidityCapSet(uint256 liquidityCap);

    event PrizeStrategySet(address indexed prizeStrategy);

    event TicketSet(ITicket indexed ticket);

    event ErrorAwardingExternalERC721(bytes error);

    function depositTo(address to, uint256 amount) external;


    function depositToAndDelegate(address to, uint256 amount, address delegate) external;


    function withdrawFrom(address from, uint256 amount) external returns (uint256);


    function award(address to, uint256 amount) external;


    function awardBalance() external view returns (uint256);


    function captureAwardBalance() external returns (uint256);


    function canAwardExternal(address externalToken) external view returns (bool);


    function balance() external returns (uint256);


    function getAccountedBalance() external view returns (uint256);


    function getBalanceCap() external view returns (uint256);


    function getLiquidityCap() external view returns (uint256);


    function getTicket() external view returns (ITicket);


    function getToken() external view returns (address);


    function getPrizeStrategy() external view returns (address);


    function isControlled(ITicket controlledToken) external view returns (bool);


    function transferExternalERC20(
        address to,
        address externalToken,
        uint256 amount
    ) external;


    function awardExternalERC20(
        address to,
        address externalToken,
        uint256 amount
    ) external;


    function awardExternalERC721(
        address to,
        address externalToken,
        uint256[] calldata tokenIds
    ) external;


    function setBalanceCap(uint256 balanceCap) external returns (bool);


    function setLiquidityCap(uint256 liquidityCap) external;


    function setPrizeStrategy(address _prizeStrategy) external;


    function setTicket(ITicket ticket) external returns (bool);


    function compLikeDelegate(ICompLike compLike, address to) external;

}// GPL-3.0

pragma solidity 0.8.6;



abstract contract PrizePool is IPrizePool, Ownable, ReentrancyGuard, IERC721Receiver {
    using SafeCast for uint256;
    using SafeERC20 for IERC20;
    using ERC165Checker for address;

    string public constant VERSION = "4.0.0";

    ITicket internal ticket;

    address internal prizeStrategy;

    uint256 internal balanceCap;

    uint256 internal liquidityCap;

    uint256 internal _currentAwardBalance;


    modifier onlyPrizeStrategy() {
        require(msg.sender == prizeStrategy, "PrizePool/only-prizeStrategy");
        _;
    }

    modifier canAddLiquidity(uint256 _amount) {
        require(_canAddLiquidity(_amount), "PrizePool/exceeds-liquidity-cap");
        _;
    }


    constructor(address _owner) Ownable(_owner) ReentrancyGuard() {
        _setLiquidityCap(type(uint256).max);
    }


    function balance() external override returns (uint256) {
        return _balance();
    }

    function awardBalance() external view override returns (uint256) {
        return _currentAwardBalance;
    }

    function canAwardExternal(address _externalToken) external view override returns (bool) {
        return _canAwardExternal(_externalToken);
    }

    function isControlled(ITicket _controlledToken) external view override returns (bool) {
        return _isControlled(_controlledToken);
    }

    function getAccountedBalance() external view override returns (uint256) {
        return _ticketTotalSupply();
    }

    function getBalanceCap() external view override returns (uint256) {
        return balanceCap;
    }

    function getLiquidityCap() external view override returns (uint256) {
        return liquidityCap;
    }

    function getTicket() external view override returns (ITicket) {
        return ticket;
    }

    function getPrizeStrategy() external view override returns (address) {
        return prizeStrategy;
    }

    function getToken() external view override returns (address) {
        return address(_token());
    }

    function captureAwardBalance() external override nonReentrant returns (uint256) {
        uint256 ticketTotalSupply = _ticketTotalSupply();
        uint256 currentAwardBalance = _currentAwardBalance;

        uint256 currentBalance = _balance();
        uint256 totalInterest = (currentBalance > ticketTotalSupply)
            ? currentBalance - ticketTotalSupply
            : 0;

        uint256 unaccountedPrizeBalance = (totalInterest > currentAwardBalance)
            ? totalInterest - currentAwardBalance
            : 0;

        if (unaccountedPrizeBalance > 0) {
            currentAwardBalance = totalInterest;
            _currentAwardBalance = currentAwardBalance;

            emit AwardCaptured(unaccountedPrizeBalance);
        }

        return currentAwardBalance;
    }

    function depositTo(address _to, uint256 _amount)
        external
        override
        nonReentrant
        canAddLiquidity(_amount)
    {
        _depositTo(msg.sender, _to, _amount);
    }

    function depositToAndDelegate(address _to, uint256 _amount, address _delegate)
        external
        override
        nonReentrant
        canAddLiquidity(_amount)
    {
        _depositTo(msg.sender, _to, _amount);
        ticket.controllerDelegateFor(msg.sender, _delegate);
    }

    function _depositTo(address _operator, address _to, uint256 _amount) internal
    {
        require(_canDeposit(_to, _amount), "PrizePool/exceeds-balance-cap");

        ITicket _ticket = ticket;

        _token().safeTransferFrom(_operator, address(this), _amount);

        _mint(_to, _amount, _ticket);
        _supply(_amount);

        emit Deposited(_operator, _to, _ticket, _amount);
    }

    function withdrawFrom(address _from, uint256 _amount)
        external
        override
        nonReentrant
        returns (uint256)
    {
        ITicket _ticket = ticket;

        _ticket.controllerBurnFrom(msg.sender, _from, _amount);

        uint256 _redeemed = _redeem(_amount);

        _token().safeTransfer(_from, _redeemed);

        emit Withdrawal(msg.sender, _from, _ticket, _amount, _redeemed);

        return _redeemed;
    }

    function award(address _to, uint256 _amount) external override onlyPrizeStrategy {
        if (_amount == 0) {
            return;
        }

        uint256 currentAwardBalance = _currentAwardBalance;

        require(_amount <= currentAwardBalance, "PrizePool/award-exceeds-avail");

        unchecked {
            _currentAwardBalance = currentAwardBalance - _amount;
        }

        ITicket _ticket = ticket;

        _mint(_to, _amount, _ticket);

        emit Awarded(_to, _ticket, _amount);
    }

    function transferExternalERC20(
        address _to,
        address _externalToken,
        uint256 _amount
    ) external override onlyPrizeStrategy {
        if (_transferOut(_to, _externalToken, _amount)) {
            emit TransferredExternalERC20(_to, _externalToken, _amount);
        }
    }

    function awardExternalERC20(
        address _to,
        address _externalToken,
        uint256 _amount
    ) external override onlyPrizeStrategy {
        if (_transferOut(_to, _externalToken, _amount)) {
            emit AwardedExternalERC20(_to, _externalToken, _amount);
        }
    }

    function awardExternalERC721(
        address _to,
        address _externalToken,
        uint256[] calldata _tokenIds
    ) external override onlyPrizeStrategy {
        require(_canAwardExternal(_externalToken), "PrizePool/invalid-external-token");

        if (_tokenIds.length == 0) {
            return;
        }

        uint256[] memory _awardedTokenIds = new uint256[](_tokenIds.length); 
        bool hasAwardedTokenIds;

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            try IERC721(_externalToken).safeTransferFrom(address(this), _to, _tokenIds[i]) {
                hasAwardedTokenIds = true;
                _awardedTokenIds[i] = _tokenIds[i];
            } catch (
                bytes memory error
            ) {
                emit ErrorAwardingExternalERC721(error);
            }
        }
        if (hasAwardedTokenIds) { 
            emit AwardedExternalERC721(_to, _externalToken, _awardedTokenIds);
        }
    }

    function setBalanceCap(uint256 _balanceCap) external override onlyOwner returns (bool) {
        _setBalanceCap(_balanceCap);
        return true;
    }

    function setLiquidityCap(uint256 _liquidityCap) external override onlyOwner {
        _setLiquidityCap(_liquidityCap);
    }

    function setTicket(ITicket _ticket) external override onlyOwner returns (bool) {
        require(address(_ticket) != address(0), "PrizePool/ticket-not-zero-address");
        require(address(ticket) == address(0), "PrizePool/ticket-already-set");

        ticket = _ticket;

        emit TicketSet(_ticket);

        _setBalanceCap(type(uint256).max);

        return true;
    }

    function setPrizeStrategy(address _prizeStrategy) external override onlyOwner {
        _setPrizeStrategy(_prizeStrategy);
    }

    function compLikeDelegate(ICompLike _compLike, address _to) external override onlyOwner {
        if (_compLike.balanceOf(address(this)) > 0) {
            _compLike.delegate(_to);
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }


    function _transferOut(
        address _to,
        address _externalToken,
        uint256 _amount
    ) internal returns (bool) {
        require(_canAwardExternal(_externalToken), "PrizePool/invalid-external-token");

        if (_amount == 0) {
            return false;
        }

        IERC20(_externalToken).safeTransfer(_to, _amount);

        return true;
    }

    function _mint(
        address _to,
        uint256 _amount,
        ITicket _controlledToken
    ) internal {
        _controlledToken.controllerMint(_to, _amount);
    }

    function _canDeposit(address _user, uint256 _amount) internal view returns (bool) {
        uint256 _balanceCap = balanceCap;

        if (_balanceCap == type(uint256).max) return true;

        return (ticket.balanceOf(_user) + _amount <= _balanceCap);
    }

    function _canAddLiquidity(uint256 _amount) internal view returns (bool) {
        uint256 _liquidityCap = liquidityCap;
        if (_liquidityCap == type(uint256).max) return true;
        return (_ticketTotalSupply() + _amount <= _liquidityCap);
    }

    function _isControlled(ITicket _controlledToken) internal view returns (bool) {
        return (ticket == _controlledToken);
    }

    function _setBalanceCap(uint256 _balanceCap) internal {
        balanceCap = _balanceCap;
        emit BalanceCapSet(_balanceCap);
    }

    function _setLiquidityCap(uint256 _liquidityCap) internal {
        liquidityCap = _liquidityCap;
        emit LiquidityCapSet(_liquidityCap);
    }

    function _setPrizeStrategy(address _prizeStrategy) internal {
        require(_prizeStrategy != address(0), "PrizePool/prizeStrategy-not-zero");

        prizeStrategy = _prizeStrategy;

        emit PrizeStrategySet(_prizeStrategy);
    }

    function _ticketTotalSupply() internal view returns (uint256) {
        return ticket.totalSupply();
    }

    function _currentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }


    function _canAwardExternal(address _externalToken) internal view virtual returns (bool);

    function _token() internal view virtual returns (IERC20);

    function _balance() internal virtual returns (uint256);

    function _supply(uint256 _mintAmount) internal virtual;

    function _redeem(uint256 _redeemAmount) internal virtual returns (uint256);
}// GPL-3.0

pragma solidity >=0.6.0;

interface IYieldSource {

    function depositToken() external view returns (address);


    function balanceOfToken(address addr) external returns (uint256);


    function supplyTokenTo(uint256 amount, address to) external;


    function redeemToken(uint256 amount) external returns (uint256);

}// GPL-3.0

pragma solidity 0.8.6;



contract YieldSourcePrizePool is PrizePool {

    using SafeERC20 for IERC20;
    using Address for address;

    IYieldSource public immutable yieldSource;

    event Deployed(address indexed yieldSource);

    event Swept(uint256 amount);

    constructor(address _owner, IYieldSource _yieldSource) PrizePool(_owner) {
        require(
            address(_yieldSource) != address(0),
            "YieldSourcePrizePool/yield-source-not-zero-address"
        );

        yieldSource = _yieldSource;

        (bool succeeded, bytes memory data) = address(_yieldSource).staticcall(
            abi.encodePacked(_yieldSource.depositToken.selector)
        );
        address resultingAddress;
        if (data.length > 0) {
            resultingAddress = abi.decode(data, (address));
        }
        require(succeeded && resultingAddress != address(0), "YieldSourcePrizePool/invalid-yield-source");

        emit Deployed(address(_yieldSource));
    }

    function sweep() external nonReentrant onlyOwner {

        uint256 balance = _token().balanceOf(address(this));
        _supply(balance);

        emit Swept(balance);
    }

    function _canAwardExternal(address _externalToken) internal view override returns (bool) {

        IYieldSource _yieldSource = yieldSource;
        return (
            _externalToken != address(_yieldSource) &&
            _externalToken != _yieldSource.depositToken()
        );
    }

    function _balance() internal override returns (uint256) {

        return yieldSource.balanceOfToken(address(this));
    }

    function _token() internal view override returns (IERC20) {

        return IERC20(yieldSource.depositToken());
    }

    function _supply(uint256 _mintAmount) internal override {

        _token().safeIncreaseAllowance(address(yieldSource), _mintAmount);
        yieldSource.supplyTokenTo(_mintAmount, address(this));
    }

    function _redeem(uint256 _redeemAmount) internal override returns (uint256) {

        return yieldSource.redeemToken(_redeemAmount);
    }
}