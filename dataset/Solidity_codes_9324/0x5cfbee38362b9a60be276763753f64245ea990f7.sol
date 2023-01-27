
pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
}// GPL-3.0

pragma solidity 0.8.6;

library ExtendedSafeCastLib {

    function toUint104(uint256 _value) internal pure returns (uint104) {
        require(_value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(_value);
    }

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

contract Delegation {
  struct Call {
    address to;
    bytes data;
  }

  address private _owner;

  uint96 public lockUntil;

  function initialize(uint96 _lockUntil) external {
    require(_owner == address(0), "Delegation/already-init");
    _owner = msg.sender;
    lockUntil = _lockUntil;
  }

  function executeCalls(Call[] calldata calls) external onlyOwner returns (bytes[] memory) {
    uint256 _callsLength = calls.length;
    bytes[] memory response = new bytes[](_callsLength);
    Call memory call;

    for (uint256 i; i < _callsLength; i++) {
      call = calls[i];
      response[i] = _executeCall(call.to, call.data);
    }

    return response;
  }

  function setLockUntil(uint96 _lockUntil) external onlyOwner {
    lockUntil = _lockUntil;
  }

  function _executeCall(address to, bytes memory data) internal returns (bytes memory) {
    (bool succeeded, bytes memory returnValue) = to.call{ value: 0 }(data);
    require(succeeded, string(returnValue));
    return returnValue;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, "Delegation/only-owner");
    _;
  }
}// GPL-3.0

pragma solidity 0.8.6;



contract LowLevelDelegator {
  using Clones for address;

  Delegation public delegationInstance;

  constructor() {
    delegationInstance = new Delegation();
    delegationInstance.initialize(uint96(0));
  }

  function _createDelegation(bytes32 _salt, uint96 _lockUntil) internal returns (Delegation) {
    Delegation _delegation = Delegation(address(delegationInstance).cloneDeterministic(_salt));
    _delegation.initialize(_lockUntil);
    return _delegation;
  }

  function _computeAddress(bytes32 _salt) internal view returns (address) {
    return address(delegationInstance).predictDeterministicAddress(_salt, address(this));
  }

  function _computeSalt(address _delegator, bytes32 _slot) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_delegator, _slot));
  }
}// GPL-3.0

pragma solidity 0.8.6;


contract PermitAndMulticall {
  struct Signature {
    uint256 deadline;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  function _multicall(bytes[] calldata _data) internal virtual returns (bytes[] memory) {
    uint256 _dataLength = _data.length;
    bytes[] memory results = new bytes[](_dataLength);

    for (uint256 i; i < _dataLength; i++) {
      results[i] = Address.functionDelegateCall(address(this), _data[i]);
    }

    return results;
  }

  function _permitAndMulticall(
    IERC20Permit _permitToken,
    uint256 _amount,
    Signature calldata _permitSignature,
    bytes[] calldata _data
  ) internal {
    _permitToken.permit(
      msg.sender,
      address(this),
      _amount,
      _permitSignature.deadline,
      _permitSignature.v,
      _permitSignature.r,
      _permitSignature.s
    );

    _multicall(_data);
  }
}// GPL-3.0

pragma solidity 0.8.6;



contract TWABDelegator is ERC20, LowLevelDelegator, PermitAndMulticall {
  using Address for address;
  using Clones for address;
  using SafeERC20 for IERC20;


  event TicketSet(ITicket indexed ticket);

  event TicketsStaked(address indexed delegator, uint256 amount);

  event TicketsUnstaked(address indexed delegator, address indexed recipient, uint256 amount);

  event DelegationCreated(
    address indexed delegator,
    uint256 indexed slot,
    uint96 lockUntil,
    address indexed delegatee,
    Delegation delegation,
    address user
  );

  event DelegateeUpdated(
    address indexed delegator,
    uint256 indexed slot,
    address indexed delegatee,
    uint96 lockUntil,
    address user
  );

  event DelegationFunded(
    address indexed delegator,
    uint256 indexed slot,
    uint256 amount,
    address indexed user
  );

  event DelegationFundedFromStake(
    address indexed delegator,
    uint256 indexed slot,
    uint256 amount,
    address indexed user
  );

  event WithdrewDelegationToStake(
    address indexed delegator,
    uint256 indexed slot,
    uint256 amount,
    address indexed user
  );

  event TransferredDelegation(
    address indexed delegator,
    uint256 indexed slot,
    uint256 amount,
    address indexed to
  );

  event RepresentativeSet(address indexed delegator, address indexed representative, bool set);


  ITicket public immutable ticket;

  uint256 public constant MAX_LOCK = 180 days;

  mapping(address => mapping(address => bool)) internal representatives;


  constructor(
    string memory name_,
    string memory symbol_,
    ITicket _ticket
  ) LowLevelDelegator() ERC20(name_, symbol_) {
    require(address(_ticket) != address(0), "TWABDelegator/tick-not-zero-addr");
    ticket = _ticket;

    emit TicketSet(_ticket);
  }


  function stake(address _to, uint256 _amount) external {
    _requireAmountGtZero(_amount);

    IERC20(ticket).safeTransferFrom(msg.sender, address(this), _amount);
    _mint(_to, _amount);

    emit TicketsStaked(_to, _amount);
  }

  function unstake(address _to, uint256 _amount) external {
    _requireRecipientNotZeroAddress(_to);
    _requireAmountGtZero(_amount);

    _burn(msg.sender, _amount);

    IERC20(ticket).safeTransfer(_to, _amount);

    emit TicketsUnstaked(msg.sender, _to, _amount);
  }

  function createDelegation(
    address _delegator,
    uint256 _slot,
    address _delegatee,
    uint96 _lockDuration
  ) external returns (Delegation) {
    _requireDelegatorOrRepresentative(_delegator);
    _requireDelegateeNotZeroAddress(_delegatee);
    _requireLockDuration(_lockDuration);

    uint96 _lockUntil = _computeLockUntil(_lockDuration);

    Delegation _delegation = _createDelegation(
      _computeSalt(_delegator, bytes32(_slot)),
      _lockUntil
    );

    _setDelegateeCall(_delegation, _delegatee);

    emit DelegationCreated(_delegator, _slot, _lockUntil, _delegatee, _delegation, msg.sender);

    return _delegation;
  }

  function updateDelegatee(
    address _delegator,
    uint256 _slot,
    address _delegatee,
    uint96 _lockDuration
  ) external returns (Delegation) {
    _requireDelegatorOrRepresentative(_delegator);
    _requireDelegateeNotZeroAddress(_delegatee);
    _requireLockDuration(_lockDuration);

    Delegation _delegation = Delegation(_computeAddress(_delegator, _slot));
    _requireDelegationUnlocked(_delegation);

    uint96 _lockUntil = _computeLockUntil(_lockDuration);

    if (_lockDuration > 0) {
      _delegation.setLockUntil(_lockUntil);
    }

    _setDelegateeCall(_delegation, _delegatee);

    emit DelegateeUpdated(_delegator, _slot, _delegatee, _lockUntil, msg.sender);

    return _delegation;
  }

  function fundDelegation(
    address _delegator,
    uint256 _slot,
    uint256 _amount
  ) external returns (Delegation) {
    require(_delegator != address(0), "TWABDelegator/dlgtr-not-zero-adr");
    _requireAmountGtZero(_amount);

    Delegation _delegation = Delegation(_computeAddress(_delegator, _slot));
    IERC20(ticket).safeTransferFrom(msg.sender, address(_delegation), _amount);

    emit DelegationFunded(_delegator, _slot, _amount, msg.sender);

    return _delegation;
  }

  function fundDelegationFromStake(
    address _delegator,
    uint256 _slot,
    uint256 _amount
  ) external returns (Delegation) {
    _requireDelegatorOrRepresentative(_delegator);
    _requireAmountGtZero(_amount);

    Delegation _delegation = Delegation(_computeAddress(_delegator, _slot));

    _burn(_delegator, _amount);

    IERC20(ticket).safeTransfer(address(_delegation), _amount);

    emit DelegationFundedFromStake(_delegator, _slot, _amount, msg.sender);

    return _delegation;
  }

  function withdrawDelegationToStake(
    address _delegator,
    uint256 _slot,
    uint256 _amount
  ) external returns (Delegation) {
    _requireDelegatorOrRepresentative(_delegator);

    Delegation _delegation = Delegation(_computeAddress(_delegator, _slot));

    _transfer(_delegation, address(this), _amount);

    _mint(_delegator, _amount);

    emit WithdrewDelegationToStake(_delegator, _slot, _amount, msg.sender);

    return _delegation;
  }

  function transferDelegationTo(
    uint256 _slot,
    uint256 _amount,
    address _to
  ) external returns (Delegation) {
    _requireRecipientNotZeroAddress(_to);

    Delegation _delegation = Delegation(_computeAddress(msg.sender, _slot));
    _transfer(_delegation, _to, _amount);

    emit TransferredDelegation(msg.sender, _slot, _amount, _to);

    return _delegation;
  }

  function setRepresentative(address _representative, bool _set) external {
    require(_representative != address(0), "TWABDelegator/rep-not-zero-addr");

    representatives[msg.sender][_representative] = _set;

    emit RepresentativeSet(msg.sender, _representative, _set);
  }

  function isRepresentativeOf(address _delegator, address _representative)
    external
    view
    returns (bool)
  {
    return representatives[_delegator][_representative];
  }

  function multicall(bytes[] calldata _data) external returns (bytes[] memory) {
    return _multicall(_data);
  }

  function permitAndMulticall(
    uint256 _amount,
    Signature calldata _permitSignature,
    bytes[] calldata _data
  ) external {
    _permitAndMulticall(IERC20Permit(address(ticket)), _amount, _permitSignature, _data);
  }

  function getDelegation(address _delegator, uint256 _slot)
    external
    view
    returns (
      Delegation delegation,
      address delegatee,
      uint256 balance,
      uint256 lockUntil,
      bool wasCreated
    )
  {
    delegation = Delegation(_computeAddress(_delegator, _slot));
    wasCreated = address(delegation).isContract();
    delegatee = ticket.delegateOf(address(delegation));
    balance = ticket.balanceOf(address(delegation));

    if (wasCreated) {
      lockUntil = delegation.lockUntil();
    }
  }

  function computeDelegationAddress(address _delegator, uint256 _slot)
    external
    view
    returns (address)
  {
    return _computeAddress(_delegator, _slot);
  }

  function decimals() public view virtual override returns (uint8) {
    return ERC20(address(ticket)).decimals();
  }


  function _computeAddress(address _delegator, uint256 _slot) internal view returns (address) {
    return _computeAddress(_computeSalt(_delegator, bytes32(_slot)));
  }

  function _computeLockUntil(uint96 _lockDuration) internal view returns (uint96) {
    unchecked {
      return uint96(block.timestamp) + _lockDuration;
    }
  }

  function _setDelegateeCall(Delegation _delegation, address _delegatee) internal {
    bytes4 _selector = ticket.delegate.selector;
    bytes memory _data = abi.encodeWithSelector(_selector, _delegatee);

    _executeCall(_delegation, _data);
  }

  function _transferCall(
    Delegation _delegation,
    address _to,
    uint256 _amount
  ) internal {
    bytes4 _selector = ticket.transfer.selector;
    bytes memory _data = abi.encodeWithSelector(_selector, _to, _amount);

    _executeCall(_delegation, _data);
  }

  function _executeCall(Delegation _delegation, bytes memory _data)
    internal
    returns (bytes[] memory)
  {
    Delegation.Call[] memory _calls = new Delegation.Call[](1);
    _calls[0] = Delegation.Call({ to: address(ticket), data: _data });

    return _delegation.executeCalls(_calls);
  }

  function _transfer(
    Delegation _delegation,
    address _to,
    uint256 _amount
  ) internal {
    _requireAmountGtZero(_amount);
    _requireDelegationUnlocked(_delegation);

    _transferCall(_delegation, _to, _amount);
  }


  function _requireDelegatorOrRepresentative(address _delegator) internal view {
    require(
      _delegator == msg.sender || representatives[_delegator][msg.sender],
      "TWABDelegator/not-dlgtr-or-rep"
    );
  }

  function _requireDelegateeNotZeroAddress(address _delegatee) internal pure {
    require(_delegatee != address(0), "TWABDelegator/dlgt-not-zero-addr");
  }

  function _requireAmountGtZero(uint256 _amount) internal pure {
    require(_amount > 0, "TWABDelegator/amount-gt-zero");
  }

  function _requireRecipientNotZeroAddress(address _to) internal pure {
    require(_to != address(0), "TWABDelegator/to-not-zero-addr");
  }

  function _requireDelegationUnlocked(Delegation _delegation) internal view {
    require(block.timestamp >= _delegation.lockUntil(), "TWABDelegator/delegation-locked");
  }

  function _requireLockDuration(uint256 _lockDuration) internal pure {
    require(_lockDuration <= MAX_LOCK, "TWABDelegator/lock-too-long");
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}