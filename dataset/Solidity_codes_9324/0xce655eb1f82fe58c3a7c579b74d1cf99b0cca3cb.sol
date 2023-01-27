
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
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
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity 0.7.6;


abstract contract AdminControl is Initializable, ContextUpgradeable {

    event NewAdmin(address oldAdmin, address newAdmin);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    address public admin;
    address public pendingAdmin;

    modifier onlyAdmin() {
        require(_msgSender() == admin, "only admin");
        _;
    }

    function __AdminControl_init(address admin_) internal initializer {
        admin = admin_;
    }

    function setPendingAdmin(address newPendingAdmin_) external virtual onlyAdmin {
        emit NewPendingAdmin(pendingAdmin, newPendingAdmin_);
        pendingAdmin = newPendingAdmin_;        
    }

    function acceptAdmin() external virtual {
        require(_msgSender() == pendingAdmin, "only pending admin");
        emit NewAdmin(admin, pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

}// MIT

pragma solidity 0.7.6;

library Constants {

    enum ClaimType {
        LINEAR,
        ONE_TIME,
        STAGED
    }

    enum VoucherType {
        STANDARD_VESTING,
        FLEXIBLE_DATE_VESTING,
        BOUNDING
    }

    uint32 internal constant FULL_PERCENTAGE = 10000;
    address internal constant ETH_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
}// MIT

pragma solidity 0.7.6;

interface ERC20Interface {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

library ERC20TransferHelper {

    function doTransferIn(
        address underlying,
        address from,
        uint256 amount
    ) internal returns (uint256) {

        if (underlying == Constants.ETH_ADDRESS) {
            require(tx.origin == from || msg.sender == from, "sender mismatch");
            require(msg.value == amount, "value mismatch");

            return amount;
        } else {
            require(msg.value == 0, "don't support msg.value");
            uint256 balanceBefore = ERC20Interface(underlying).balanceOf(
                address(this)
            );
            (bool success, bytes memory data) = underlying.call(
                abi.encodeWithSelector(
                    ERC20Interface.transferFrom.selector,
                    from,
                    address(this),
                    amount
                )
            );
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "STF"
            );

            uint256 balanceAfter = ERC20Interface(underlying).balanceOf(
                address(this)
            );
            require(
                balanceAfter >= balanceBefore,
                "TOKEN_TRANSFER_IN_OVERFLOW"
            );
            return balanceAfter - balanceBefore; // underflow already checked above, just subtract
        }
    }

    function doTransferOut(
        address underlying,
        address payable to,
        uint256 amount
    ) internal {

        if (underlying == Constants.ETH_ADDRESS) {
            (bool success, ) = to.call{value: amount}(new bytes(0));
            require(success, "STE");
        } else {
            (bool success, bytes memory data) = underlying.call(
                abi.encodeWithSelector(
                    ERC20Interface.transfer.selector,
                    to,
                    amount
                )
            );
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "ST"
            );
        }
    }

    function getCashPrior(address underlying_) internal view returns (uint256) {

        if (underlying_ == Constants.ETH_ADDRESS) {
            uint256 startingBalance = sub(address(this).balance, msg.value);
            return startingBalance;
        } else {
            ERC20Interface token = ERC20Interface(underlying_);
            return token.balanceOf(address(this));
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
}// MIT

pragma solidity 0.7.6;

interface ERC721Interface {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}

interface VNFTInterface {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 units
    ) external returns (uint256 newTokenId);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 units,
        bytes calldata data
    ) external returns (uint256 newTokenId);


    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 units
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 units,
        bytes calldata data
    ) external;

}

library VNFTTransferHelper {

    function doTransferIn(
        address underlying,
        address from,
        uint256 tokenId
    ) internal {

        ERC721Interface token = ERC721Interface(underlying);
        token.transferFrom(from, address(this), tokenId);
    }

    function doTransferOut(
        address underlying,
        address to,
        uint256 tokenId
    ) internal {

        ERC721Interface token = ERC721Interface(underlying);
        token.transferFrom(address(this), to, tokenId);
    }

    function doTransferIn(
        address underlying,
        address from,
        uint256 tokenId,
        uint256 units
    ) internal {

        VNFTInterface token = VNFTInterface(underlying);
        token.safeTransferFrom(from, address(this), tokenId, units, "");
    }

    function doTransferOut(
        address underlying,
        address to,
        uint256 tokenId,
        uint256 units
    ) internal returns (uint256 newTokenId) {

        VNFTInterface token = VNFTInterface(underlying);
        newTokenId = token.safeTransferFrom(
            address(this),
            to,
            tokenId,
            units,
            ""
        );
    }

    function doTransferOut(
        address underlying,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 units
    ) internal {

        VNFTInterface token = VNFTInterface(underlying);
        token.safeTransferFrom(
            address(this),
            to,
            tokenId,
            targetTokenId,
            units,
            ""
        );
    }
}// MIT
pragma solidity >=0.6.0 <0.9.0;


library BokkyPooBahsDateTimeLibrary {


    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {

        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {

        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {

        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {

        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {

        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {

        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {

        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {

        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {

        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {

        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {

        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {

        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {

        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {

        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {

        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {

        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {

        require(fromTimestamp <= toTimestamp);
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {

        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {

        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {

        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {

        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {

        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}// MIT

pragma solidity 0.7.6;


library StringConvertor {


    using Strings for uint256;
    using SafeMath for uint256;

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }

    function uint2decimal(uint256 self, uint8 decimals) 
        internal
        pure
        returns (bytes memory)
    {

        uint256 base = 10 ** decimals;
        string memory round = self.div(base).toString();
        string memory fraction = self.mod(base).toString();
        uint256 fractionLength = bytes(fraction).length;

        bytes memory fullStr = abi.encodePacked(round, '.');
        if (fractionLength < decimals) {
            for (uint8 i = 0; i < decimals - fractionLength; i++) {
                fullStr = abi.encodePacked(fullStr, '0');
            }
        }

        return abi.encodePacked(fullStr, fraction);
    }

    function trim(bytes memory self, uint256 cutLength) 
        internal 
        pure
        returns (bytes memory newString)
    {

        newString = new bytes(self.length - cutLength);
        uint256 index = newString.length;
        while (index-- > 0) {
            newString[index] = self[index];
        }
    }

    function addThousandsSeparator(bytes memory self) 
        internal
        pure
        returns (bytes memory newString) 
    {

        uint256 roundLength = 0;
        for (uint256 i = 0; i < self.length; i++) {
            if (self[i] != '.') {
                roundLength++;
            } else {
                break;
            }
        }

        if (roundLength <= 3) {
            newString = self;
        } else {
            newString = new bytes(self.length + (roundLength - 1) / 3);
            uint256 newIndex = 0;
            for (uint256 oriIndex = 0; oriIndex < self.length; oriIndex++) {
                newString[newIndex++] = self[oriIndex];
                if (oriIndex < roundLength - 1 && (roundLength - oriIndex - 1) % 3 == 0) {
                    newString[newIndex++] = ',';
                }
            }
        }
    }

    function addressToString(address self) 
        internal 
        pure 
        returns (string memory) 
    {

        bytes32 value = bytes32(uint256(self));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function datetimeToString(uint256 timestamp) 
        internal
        pure
        returns (string memory)
    {

        (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
            = BokkyPooBahsDateTimeLibrary.timestampToDateTime(timestamp);
        return 
            string(
                abi.encodePacked(
                    year.toString(), '/', 
                    month < 10 ? '0' : '', month.toString(), '/', 
                    day < 10 ? '0' : '', day.toString(), ' ',
                    hour < 10 ? '0' : '', hour.toString(), ':', 
                    minute < 10 ? '0' : '', minute.toString(), ':',
                    second < 10 ? '0' : '',  second.toString()
                )
            );
    }

    function dateToString(uint256 timestamp)
        internal
        pure
        returns (string memory)
    {

        (uint256 year, uint256 month, uint256 day)
            = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        return 
            string(
                abi.encodePacked(
                    year.toString(), '/', 
                    month < 10 ? '0' : '', month.toString(), '/', 
                    day < 10 ? '0' : '', day.toString()
                )
            );
    }

    function uintArray2str(uint64[] memory array) 
        internal 
        pure 
        returns (string memory) 
    {

        bytes memory pack = abi.encodePacked('[');
        for (uint256 i = 0; i < array.length; i++) {
            if (i == array.length - 1) {
                pack = abi.encodePacked(pack, uint256(array[i]).toString());
            } else {
                pack = abi.encodePacked(pack, uint256(array[i]).toString(), ',');
            }
        }
        return string(abi.encodePacked(pack, ']'));
    }

    function percentArray2str(uint32[] memory array) 
        internal 
        pure 
        returns (string memory) 
    {

        bytes memory pack = abi.encodePacked('[');
        for (uint256 i = 0; i < array.length; i++) {
            bytes memory percent = abi.encodePacked('"', uint2decimal(array[i], 2), '%"');

            if (i == array.length - 1) {
                pack = abi.encodePacked(pack, percent);
            } else {
                pack = abi.encodePacked(pack, percent, ',');
            }
        }
        return string(abi.encodePacked(pack, ']'));
    }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

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

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableMapUpgradeable {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library StringsUpgradeable {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable, IERC721EnumerableUpgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.UintToAddressMap;
    using StringsUpgradeable for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSetUpgradeable.UintSet) private _holderTokens;

    EnumerableMapUpgradeable.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function baseURI() public view virtual returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721Upgradeable.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721Upgradeable.isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Upgradeable.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721ReceiverUpgradeable(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

    uint256[41] private __gap;
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

pragma solidity 0.7.6;

interface ISolver {


    event SetOperationPaused (
        address product,
        string operation,
        bool setPaused
    );


    function isSolver() external pure returns (bool);


    function setOperationPaused(address product_, string calldata operation_, bool setPaused_) external;


    function operationAllowed(string calldata operation_, bytes calldata data_) external returns (uint256);


    function operationVerify(string calldata operation_, bytes calldata data_) external returns (uint256);

    
}// MIT

pragma solidity 0.7.6;

interface IVNFT {

    event TransferUnits(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        uint256 targetTokenId,
        uint256 transferUnits
    );

    event Split(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 newTokenId,
        uint256 splitUnits
    );

    event Merge(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 indexed targetTokenId,
        uint256 mergeUnits
    );

    event ApprovalUnits(
        address indexed approval,
        uint256 indexed tokenId,
        uint256 allowance
    );

    function slotOf(uint256 tokenId) external view returns (uint256 slot);


    function unitDecimals() external view returns (uint8);


    function unitsInSlot(uint256 slot) external view returns (uint256);


    function tokensInSlot(uint256 slot)
        external
        view
        returns (uint256 tokenCount);


    function tokenOfSlotByIndex(uint256 slot, uint256 index)
        external
        view
        returns (uint256 tokenId);


    function unitsInToken(uint256 tokenId)
        external
        view
        returns (uint256 units);


    function approve(
        address to,
        uint256 tokenId,
        uint256 units
    ) external;


    function allowance(uint256 tokenId, address spender)
        external
        view
        returns (uint256 allowed);


    function split(uint256 tokenId, uint256[] calldata units)
        external
        returns (uint256[] memory newTokenIds);


    function merge(uint256[] calldata tokenIds, uint256 targetTokenId) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 units
    ) external returns (uint256 newTokenId);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 units,
        bytes calldata data
    ) external returns (uint256 newTokenId);


    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 units
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 units,
        bytes calldata data
    ) external;

}

interface IVNFTReceiver {

    function onVNFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        uint256 units,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity 0.7.6;

interface IVNFTMetadata /* is IERC721Metadata */ {

    function contractURI() external view returns (string memory);

    function slotURI(uint256 slot) external view returns (string memory);

}// MIT

pragma solidity 0.7.6;


abstract contract VNFTCoreV2 is IVNFT, IVNFTMetadata, ERC721Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    struct ApproveUnits {
        address[] approvals;
        mapping(address => uint256) allowances;
    }

    mapping(uint256 => uint256) internal _units;

    mapping(uint256 => ApproveUnits) private _tokenApprovalUnits;

    mapping(uint256 => EnumerableSetUpgradeable.UintSet) private _slotTokens;

    uint8 internal _unitDecimals;

    function _initialize(
        string memory name_,
        string memory symbol_,
        uint8 unitDecimals_
    ) internal virtual {
        ERC721Upgradeable.__ERC721_init(name_, symbol_);
        ERC165Upgradeable._registerInterface(type(IVNFT).interfaceId);
        _unitDecimals = unitDecimals_;
    }

    function _safeTransferUnitsFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 targetTokenId_,
        uint256 transferUnits_,
        bytes memory data_
    ) internal virtual {
        _transferUnitsFrom(
            from_,
            to_,
            tokenId_,
            targetTokenId_,
            transferUnits_
        );
        require(
            _checkOnVNFTReceived(
                from_,
                to_,
                targetTokenId_,
                transferUnits_,
                data_
            ),
            "to non VNFTReceiver implementer"
        );
    }

    function _transferUnitsFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 targetTokenId_,
        uint256 transferUnits_
    ) internal virtual {
        require(from_ == ownerOf(tokenId_), "source token owner mismatch");
        require(to_ != address(0), "transfer to the zero address");

        _beforeTransferUnits(
            from_,
            to_,
            tokenId_,
            targetTokenId_,
            transferUnits_
        );

        if (_msgSender() != from_ && !isApprovedForAll(from_, _msgSender())) {
            _tokenApprovalUnits[tokenId_].allowances[
                _msgSender()
            ] = _tokenApprovalUnits[tokenId_].allowances[_msgSender()].sub(
                transferUnits_,
                "transfer units exceeds allowance"
            );
        }

        _units[tokenId_] = _units[tokenId_].sub(
            transferUnits_,
            "transfer excess units"
        );

        if (!_exists(targetTokenId_)) {
            _mintUnits(to_, targetTokenId_, _slotOf(tokenId_), transferUnits_);
        } else {
            require(
                ownerOf(targetTokenId_) == to_,
                "target token owner mismatch"
            );
            require(
                _slotOf(tokenId_) == _slotOf(targetTokenId_),
                "slot mismatch"
            );
            _units[targetTokenId_] = _units[targetTokenId_].add(transferUnits_);
        }

        emit TransferUnits(
            from_,
            to_,
            tokenId_,
            targetTokenId_,
            transferUnits_
        );
    }

    function _merge(uint256 tokenId_, uint256 targetTokenId_) internal virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId_),
            "VNFT: not owner nor approved"
        );
        require(tokenId_ != targetTokenId_, "self merge not allowed");
        require(_slotOf(tokenId_) == _slotOf(targetTokenId_), "slot mismatch");

        address owner = ownerOf(tokenId_);
        require(owner == ownerOf(targetTokenId_), "not same owner");

        uint256 mergeUnits = _units[tokenId_];
        _units[targetTokenId_] = _units[tokenId_].add(_units[targetTokenId_]);
        _burn(tokenId_);

        emit Merge(owner, tokenId_, targetTokenId_, mergeUnits);
    }

    function _split(
        uint256 tokenId_,
        uint256 newTokenId_,
        uint256 splitUnits_
    ) internal virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId_),
            "VNFT: not owner nor approved"
        );
        require(!_exists(newTokenId_), "new token already exists");

        _units[tokenId_] = _units[tokenId_].sub(splitUnits_);

        address owner = ownerOf(tokenId_);
        _mintUnits(owner, newTokenId_, _slotOf(tokenId_), splitUnits_);

        emit Split(owner, tokenId_, newTokenId_, splitUnits_);
    }

    function _mintUnits(
        address minter_,
        uint256 tokenId_,
        uint256 slot_,
        uint256 units_
    ) internal virtual {
        if (!_exists(tokenId_)) {
            ERC721Upgradeable._mint(minter_, tokenId_);
            _slotTokens[slot_].add(tokenId_);
        }

        _units[tokenId_] = _units[tokenId_].add(units_);
        emit TransferUnits(address(0), minter_, 0, tokenId_, units_);
    }

    function _burn(uint256 tokenId_) internal virtual override {
        address owner = ownerOf(tokenId_);
        uint256 slot = _slotOf(tokenId_);
        uint256 burnUnits = _units[tokenId_];

        _slotTokens[slot].remove(tokenId_);
        delete _units[tokenId_];

        ERC721Upgradeable._burn(tokenId_);
        emit TransferUnits(owner, address(0), tokenId_, 0, burnUnits);
    }

    function _burnUnits(uint256 tokenId_, uint256 burnUnits_)
        internal
        virtual
        returns (uint256 balance)
    {
        address owner = ownerOf(tokenId_);
        _units[tokenId_] = _units[tokenId_].sub(
            burnUnits_,
            "burn excess units"
        );

        emit TransferUnits(owner, address(0), tokenId_, 0, burnUnits_);
        return _units[tokenId_];
    }

    function approve(
        address to_,
        uint256 tokenId_,
        uint256 allowance_
    ) public virtual override {
        require(_msgSender() == ownerOf(tokenId_), "VNFT: only owner");
        _approveUnits(to_, tokenId_, allowance_);
    }

    function allowance(uint256 tokenId_, address spender_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _tokenApprovalUnits[tokenId_].allowances[spender_];
    }

    function _approveUnits(
        address to_,
        uint256 tokenId_,
        uint256 allowance_
    ) internal virtual {
        if (_tokenApprovalUnits[tokenId_].allowances[to_] == 0) {
            _tokenApprovalUnits[tokenId_].approvals.push(to_);
        }
        _tokenApprovalUnits[tokenId_].allowances[to_] = allowance_;
        emit ApprovalUnits(to_, tokenId_, allowance_);
    }

    function _clearApproveUnits(uint256 tokenId_) internal virtual {
        ApproveUnits storage approveUnits = _tokenApprovalUnits[tokenId_];
        for (uint256 i = 0; i < approveUnits.approvals.length; i++) {
            delete approveUnits.allowances[approveUnits.approvals[i]];
            delete approveUnits.approvals[i];
        }
    }

    function unitDecimals() public view override returns (uint8) {
        return _unitDecimals;
    }

    function unitsInSlot(uint256 slot_)
        public
        view
        override
        returns (uint256 units_)
    {
        for (uint256 i = 0; i < tokensInSlot(slot_); i++) {
            units_ = units_.add(unitsInToken(tokenOfSlotByIndex(slot_, i)));
        }
    }

    function unitsInToken(uint256 tokenId_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _units[tokenId_];
    }

    function tokensInSlot(uint256 slot_)
        public
        view
        override
        returns (uint256)
    {
        return _slotTokens[slot_].length();
    }

    function tokenOfSlotByIndex(uint256 slot_, uint256 index_)
        public
        view
        override
        returns (uint256)
    {
        return _slotTokens[slot_].at(index_);
    }

    function slotOf(uint256 tokenId_) public view override returns (uint256) {
        return _slotOf(tokenId_);
    }

    function _slotOf(uint256 tokenId_) internal view virtual returns (uint256);

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal virtual override {
        if (from_ != address(0)) {
            _clearApproveUnits(tokenId_);
        }
    }

    function _beforeTransferUnits(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 targetTokenId_,
        uint256 transferUnits_
    ) internal virtual {}

    function _checkOnVNFTReceived(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 units_,
        bytes memory _data
    ) internal returns (bool) {
        if (!to_.isContract()) {
            return true;
        }
        bytes memory returndata = to_.functionCall(
            abi.encodeWithSelector(
                IVNFTReceiver(to_).onVNFTReceived.selector,
                _msgSender(),
                from_,
                tokenId_,
                units_,
                _data
            ),
            "non VNFTReceiver implementer"
        );
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == type(IVNFTReceiver).interfaceId);
    }
}// MIT

pragma solidity 0.7.6;

interface IUnderlyingContainer {

    function totalUnderlyingAmount() external view returns (uint256);

    function underlying() external view returns (address);

}// MIT

pragma solidity 0.7.6;


abstract contract VoucherCore is VNFTCoreV2, AdminControl {
    mapping(uint256 => uint256) public voucherSlotMapping;

    uint32 public nextTokenId;

    function _initialize(
        string memory name_,
        string memory symbol_,
        uint8 unitDecimals_
    ) internal override {
        AdminControl.__AdminControl_init(_msgSender());
        VNFTCoreV2._initialize(name_, symbol_, unitDecimals_);
        nextTokenId = 1;
    }

    function _generateTokenId() internal virtual returns (uint256) {
        return nextTokenId++;
    }

    function split(uint256 tokenId_, uint256[] calldata splitUnits_)
        public
        virtual
        override
        returns (uint256[] memory newTokenIds)
    {
        require(splitUnits_.length > 0, "empty splitUnits");
        newTokenIds = new uint256[](splitUnits_.length);

        for (uint256 i = 0; i < splitUnits_.length; i++) {
            uint256 newTokenId = _generateTokenId();
            newTokenIds[i] = newTokenId;
            VNFTCoreV2._split(tokenId_, newTokenId, splitUnits_[i]);
            voucherSlotMapping[newTokenId] = voucherSlotMapping[tokenId_];
        }
    }

    function merge(uint256[] calldata tokenIds_, uint256 targetTokenId_)
        public
        virtual
        override
    {
        require(tokenIds_.length > 0, "empty tokenIds");
        for (uint256 i = 0; i < tokenIds_.length; i++) {
            VNFTCoreV2._merge(tokenIds_[i], targetTokenId_);
            delete voucherSlotMapping[tokenIds_[i]];
        }
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 transferUnits_
    ) public virtual override returns (uint256 newTokenId) {
        newTokenId = _generateTokenId();
        _transferUnitsFrom(from_, to_, tokenId_, newTokenId, transferUnits_);
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 targetTokenId_,
        uint256 transferUnits_
    ) public virtual override {
        require(_exists(targetTokenId_), "target token not exists");
        _transferUnitsFrom(
            from_,
            to_,
            tokenId_,
            targetTokenId_,
            transferUnits_
        );
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 transferUnits_,
        bytes memory data_
    ) public virtual override returns (uint256 newTokenId) {
        newTokenId = transferFrom(from_, to_, tokenId_, transferUnits_);
        require(
            _checkOnVNFTReceived(from_, to_, newTokenId, transferUnits_, data_),
            "to non VNFTReceiver"
        );
        return newTokenId;
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 targetTokenId_,
        uint256 transferUnits_,
        bytes memory data_
    ) public virtual override {
        transferFrom(from_, to_, tokenId_, targetTokenId_, transferUnits_);
        require(
            _checkOnVNFTReceived(
                from_,
                to_,
                targetTokenId_,
                transferUnits_,
                data_
            ),
            "to non VNFTReceiver"
        );
    }

    function _transferUnitsFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 targetTokenId_,
        uint256 transferUnits_
    ) internal virtual override {
        VNFTCoreV2._transferUnitsFrom(
            from_,
            to_,
            tokenId_,
            targetTokenId_,
            transferUnits_
        );
        voucherSlotMapping[targetTokenId_] = voucherSlotMapping[tokenId_];
    }

    function _mint(
        address minter_,
        uint256 slot_,
        uint256 units_
    ) internal virtual returns (uint256 tokenId) {
        tokenId = _generateTokenId();
        voucherSlotMapping[tokenId] = slot_;
        VNFTCoreV2._mintUnits(minter_, tokenId, slot_, units_);
    }

    function burn(uint256 tokenId_) external virtual {
        require(_msgSender() == ownerOf(tokenId_), "only owner");
        _burnVoucher(tokenId_);
    }

    function _burnVoucher(uint256 tokenId_) internal virtual {
        delete voucherSlotMapping[tokenId_];
        VNFTCoreV2._burn(tokenId_);
    }

    function _slotOf(uint256 tokenId_)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return voucherSlotMapping[tokenId_];
    }

    function owner() external view virtual returns (address) {
        return admin;
    }

    function voucherType() external view virtual returns (Constants.VoucherType) {}

}// MIT

pragma solidity >=0.6.0;

library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}// MIT

pragma solidity 0.7.6;

interface IVNFTDescriptor {


    function contractURI() external view returns (string memory);

    function slotURI(uint256 slot) external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);


}// MIT

pragma solidity 0.7.6;

interface IVoucherSVG {


    function generateSVG(address voucher_, uint256 tokenId_) external view returns (string memory);


}// MIT

pragma solidity 0.7.6;
pragma abicoder v2;

interface IConvertiblePool {


    enum CollateralType {
        ERC20,
        VESTING_VOUCHER
    }

    struct SlotDetail {
        address issuer;
        address fundCurrency;
        uint256 totalValue;
        uint128 lowestPrice;
        uint128 highestPrice;
        uint128 settlePrice;
        uint64 effectiveTime;
        uint64 maturity;
        CollateralType collateralType;
        bool isIssuerRefunded;
        bool isIssuerWithdrawn;
        bool isClaimed;
        bool isValid;
    }

    event NewVoucher(address oldVoucher, address newVoucher);

    event SetFundCurrency(address indexed currency, bool enabled);

    event CreateSlot(
        uint256 indexed slot,
        address indexed issuer,
        address fundCurrency,
        uint128 lowestPrice,
        uint128 highestPrice,
        uint64 effectiveTime,
        uint64 maturity,
        CollateralType collateralType
    );

    event Mint(
        address indexed minter,
        uint256 indexed slot,
        uint256 totalValue
    );

    event Refund(uint256 indexed slot, address sender, uint256 refundAmount);

    event Withdraw(
        uint256 indexed slot,
        address sender,
        uint256 redeemCurrencyAmount,
        uint256 redeemUnderlyingTokenAmount
    );

    event SettlePrice(uint256 indexed slot, uint128 settlePrice);


    function mintWithUnderlyingToken(
        address minter_,
        uint256 slot_,
        uint256 tokenInAmount_
    ) external returns (uint256 totalValue);


    function refund(uint256 slot_) external;


    function withdraw(uint256 slot_) external returns (uint256, uint256);


    function claim(
        uint256 slot_,
        address to_,
        uint256 claimValue_
    ) external returns (uint256, uint256);


    function settleConvertiblePrice(uint256 slot_) external;


    function getSettlePrice(uint256 slot_) external view returns (uint128);

}// MIT

pragma solidity 0.7.6;

interface IPriceOracleManager {

    function getPriceOfTokenId(address voucher_, uint256 tokenId_)
        external
        view
        returns (int256 price_);


    function getPriceOfMaturity(address voucher_, uint64 maturity_)
        external
        view
        returns (int256 price_);

}// MIT

pragma solidity 0.7.6;

interface IICToken {


    function mint(
        uint64 term, 
        uint256 amount,
        uint64[] calldata maturities, 
        uint32[] calldata percentages,
        string memory originalInvestor
    ) 
        external 
        returns (uint256 slot, uint256 tokenId);

    
    function vestingPool() external view returns (address);


    function underlying() external view returns (address);


}// MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {

	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {

		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {

		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}// MIT

pragma solidity 0.7.6;


contract ConvertiblePool is
    IConvertiblePool,
    AdminControl,
    ReentrancyGuardUpgradeable
{

    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    mapping(uint256 => SlotDetail) internal _slotDetails;

    mapping(address => EnumerableSetUpgradeable.UintSet) internal _issuerSlots;

    mapping(address => bool) public fundCurrencies;

    mapping(uint256 => mapping(address => uint256)) public slotBalances;

    IPriceOracleManager public oracle;
    address public underlyingVestingVoucher;
    address public underlyingToken;

    uint8 public priceDecimals;
    uint8 public valueDecimals;

    address public voucher;

    modifier onlyVoucher() {

        require(_msgSender() == voucher, "only voucher");
        _;
    }

    function initialize(
        address underlyingToken_,
        address oracle_,
        uint8 priceDecimals_,
        uint8 valueDecimals_
    ) external initializer {

        AdminControl.__AdminControl_init(_msgSender());
        oracle = IPriceOracleManager(oracle_);
        underlyingToken = underlyingToken_;
        priceDecimals = priceDecimals_;
        valueDecimals = valueDecimals_;
    }

    function createSlot(
        address issuer_,
        address fundCurrency_,
        uint128 lowestPrice_,
        uint128 highestPrice_,
        uint64 effectiveTime_,
        uint64 maturity_,
        uint8 collateralType_
    ) external onlyVoucher returns (uint256 slot) {

        validateSlotParams(
            issuer_,
            fundCurrency_,
            lowestPrice_,
            highestPrice_,
            effectiveTime_,
            maturity_,
            collateralType_
        );

        slot = getSlot(
            issuer_,
            fundCurrency_,
            lowestPrice_,
            highestPrice_,
            effectiveTime_,
            maturity_,
            collateralType_
        );
        require(!_slotDetails[slot].isValid, "slot already existed");

        SlotDetail storage slotDetail = _slotDetails[slot];
        slotDetail.issuer = issuer_;
        slotDetail.fundCurrency = fundCurrency_;
        slotDetail.lowestPrice = lowestPrice_;
        slotDetail.highestPrice = highestPrice_;
        slotDetail.effectiveTime = effectiveTime_;
        slotDetail.maturity = maturity_;
        slotDetail.collateralType = CollateralType(collateralType_);
        slotDetail.isValid = true;

        _issuerSlots[issuer_].add(slot);

        emit CreateSlot(
            slot,
            issuer_,
            fundCurrency_,
            lowestPrice_,
            highestPrice_,
            effectiveTime_,
            maturity_,
            CollateralType(collateralType_)
        );
    }

    function validateSlotParams(
        address issuer_,
        address fundCurrency_,
        uint128 lowestPrice_,
        uint128 highestPrice_,
        uint64 effectiveTime_,
        uint64 maturity_,
        uint8 collateralType_
    ) public view {

        require(issuer_ != address(0), "issuer cannot be 0 address");
        require(fundCurrencies[fundCurrency_], "unsupported fund currency");
        require(collateralType_ < 2, "invalid collateral type");
        require(
            lowestPrice_ > 0 && lowestPrice_ < highestPrice_,
            "invalid price bounds"
        );
        require(
            effectiveTime_ > 0 && effectiveTime_ < maturity_, 
            "invalid time setting"
        );
    }

    function mintWithUnderlyingToken(
        address minter_,
        uint256 slot_,
        uint256 tokenInAmount_
    ) external override nonReentrant onlyVoucher returns (uint256 totalValue) {

        require(minter_ != address(0), "minter cannot be 0 address");
        require(tokenInAmount_ != 0, "tokenInAmount cannot be 0");
        SlotDetail storage slotDetail = _slotDetails[slot_];
        require(slotDetail.isValid, "invalid slot");
        require(
            !slotDetail.isIssuerRefunded && block.timestamp < slotDetail.maturity, 
            "non-mintable slot"
        );

        totalValue = tokenInAmount_.mul(slotDetail.lowestPrice);
        slotDetail.totalValue = slotDetail.totalValue.add(totalValue);
        slotBalances[slot_][underlyingToken] = slotBalances[slot_][
            underlyingToken
        ].add(tokenInAmount_);
        ERC20TransferHelper.doTransferIn(
            underlyingToken,
            minter_,
            tokenInAmount_
        );

        emit Mint(minter_, slot_, totalValue);
    }

    function refund(uint256 slot_) external override nonReentrant {

        require(_issuerSlots[_msgSender()].contains(slot_), "only issuer");

        SlotDetail storage slotDetail = _slotDetails[slot_];
        require(slotDetail.isValid, "invalid slot");
        require(!slotDetail.isIssuerRefunded, "already refunded");
        require(slotDetail.settlePrice == 0, "already settled");

        slotDetail.isIssuerRefunded = true;

        uint8 currencyDecimals = ERC20Upgradeable(slotDetail.fundCurrency)
            .decimals();
        uint256 currencyAmount = slotDetail
            .totalValue
            .mul(10**currencyDecimals)
            .div(10**valueDecimals);
        slotBalances[slot_][slotDetail.fundCurrency] = slotBalances[slot_][
            slotDetail.fundCurrency
        ].add(currencyAmount);
        ERC20TransferHelper.doTransferIn(
            slotDetail.fundCurrency,
            _msgSender(),
            currencyAmount
        );

        emit Refund(slot_, _msgSender(), currencyAmount);
    }

    function getWithdrawableAmount(uint256 slot_)
        public
        view
        returns (uint256 withdrawCurrencyAmount, uint256 withdrawTokenAmount)
    {

        SlotDetail storage slotDetail = _slotDetails[slot_];

        if (
            block.timestamp >= slotDetail.maturity &&
            !slotDetail.isIssuerWithdrawn
        ) {
            uint128 settlePrice = slotDetail.settlePrice;

            if (settlePrice == 0) {
                settlePrice = getSettlePrice(slot_);
                if (settlePrice == 0) {
                    return (0, 0);
                }
            }

            if (slotDetail.isIssuerRefunded && settlePrice > slotDetail.highestPrice) {
                uint8 currencyDecimals = ERC20Upgradeable(
                    slotDetail.fundCurrency
                ).decimals();
                uint256 reservedCurrencyAmount = slotBalances[slot_][
                    slotDetail.fundCurrency
                ];
                withdrawCurrencyAmount = slotDetail
                    .totalValue
                    .mul(10**currencyDecimals)
                    .div(10**valueDecimals);
                if (withdrawCurrencyAmount > reservedCurrencyAmount) {
                    withdrawCurrencyAmount = reservedCurrencyAmount;
                }
            }

            if (slotDetail.isIssuerRefunded && settlePrice <= slotDetail.highestPrice) {
                withdrawTokenAmount = slotDetail.totalValue.div(slotDetail.lowestPrice);
            } else if (settlePrice > slotDetail.lowestPrice) {
                if (settlePrice > slotDetail.highestPrice) {
                    settlePrice = slotDetail.highestPrice;
                }
                withdrawTokenAmount = slotDetail
                    .totalValue
                    .div(slotDetail.lowestPrice)
                    .sub(slotDetail.totalValue.div(settlePrice));
            }
            uint256 reservedTokenAmount = slotBalances[slot_][underlyingToken];
            if (withdrawTokenAmount > reservedTokenAmount) {
                withdrawTokenAmount = reservedTokenAmount;
            }
        }
    }

    function withdraw(uint256 slot_)
        external
        override
        nonReentrant
        returns (uint256 withdrawCurrencyAmount, uint256 withdrawTokenAmount)
    {

        require(_issuerSlots[_msgSender()].contains(slot_), "only issuer");

        SlotDetail storage slotDetail = _slotDetails[slot_];
        require(!slotDetail.isIssuerWithdrawn, "already withdrawn");

        uint128 settlePrice = slotDetail.settlePrice;
        if (settlePrice == 0) {
            settleConvertiblePrice(slot_);
            settlePrice = slotDetail.settlePrice;
            if (settlePrice == 0) {
                revert("price not settled");
            }
        }

        (withdrawCurrencyAmount, withdrawTokenAmount) = getWithdrawableAmount(
            slot_
        );

        slotDetail.isIssuerWithdrawn = true;

        if (withdrawCurrencyAmount > 0) {
            slotBalances[slot_][slotDetail.fundCurrency] = slotBalances[slot_][
                slotDetail.fundCurrency
            ].sub(withdrawCurrencyAmount);
            ERC20TransferHelper.doTransferOut(
                slotDetail.fundCurrency,
                _msgSender(),
                withdrawCurrencyAmount
            );
        }
        if (withdrawTokenAmount > 0) {
            slotBalances[slot_][underlyingToken] = slotBalances[slot_][
                underlyingToken
            ].sub(withdrawTokenAmount);
            ERC20TransferHelper.doTransferOut(
                underlyingToken,
                _msgSender(),
                withdrawTokenAmount
            );
        }

        emit Withdraw(
            slot_,
            _msgSender(),
            withdrawCurrencyAmount,
            withdrawTokenAmount
        );
    }

    function claim(
        uint256 slot_,
        address to_,
        uint256 claimValue_
    )
        external
        override
        onlyVoucher
        nonReentrant
        returns (uint256 claimCurrencyAmount, uint256 claimTokenAmount)
    {

        SlotDetail storage slotDetail = _slotDetails[slot_];
        require(slotDetail.isValid, "invalid slot");

        uint128 settlePrice = slotDetail.settlePrice;
        if (settlePrice == 0) {
            settleConvertiblePrice(slot_);
            settlePrice = slotDetail.settlePrice;
            if (settlePrice == 0) {
                revert("price not settled");
            }
        }

        if (!slotDetail.isClaimed) {
            slotDetail.isClaimed = true;
        }

        if (
            settlePrice <= slotDetail.highestPrice && slotDetail.isIssuerRefunded
        ) {
            uint256 reservedCurrencyAmount = slotBalances[slot_][
                slotDetail.fundCurrency
            ];
            claimCurrencyAmount = claimValue_
                .mul(10 ** ERC20Upgradeable(slotDetail.fundCurrency).decimals())
                .div(10 ** valueDecimals);

            if (claimCurrencyAmount > reservedCurrencyAmount) {
                claimCurrencyAmount = reservedCurrencyAmount;
            }
            slotBalances[slot_][
                slotDetail.fundCurrency
            ] = reservedCurrencyAmount.sub(claimCurrencyAmount);

            ERC20TransferHelper.doTransferOut(
                slotDetail.fundCurrency,
                payable(to_),
                claimCurrencyAmount
            );
        } else {
            if (settlePrice < slotDetail.lowestPrice) {
                settlePrice = slotDetail.lowestPrice;
            } else if (settlePrice > slotDetail.highestPrice) {
                settlePrice = slotDetail.highestPrice;
            }

            uint256 reservedTokenAmount = slotBalances[slot_][underlyingToken];
            claimTokenAmount = claimValue_.div(settlePrice);
            if (claimTokenAmount > reservedTokenAmount) {
                claimTokenAmount = reservedTokenAmount;
            }
            slotBalances[slot_][underlyingToken] = reservedTokenAmount.sub(
                claimTokenAmount
            );
            ERC20TransferHelper.doTransferOut(
                underlyingToken,
                payable(to_),
                claimTokenAmount
            );
        }
    }

    function settleConvertiblePrice(uint256 slot_) public override {

        SlotDetail storage slotDetail = _slotDetails[slot_];

        uint128 price = getSettlePrice(slot_);
        if (price > 0) {
            slotDetail.settlePrice = price;
            emit SettlePrice(slot_, slotDetail.settlePrice);
        }
    }

    function getSettlePrice(uint256 slot_)
        public
        view
        override
        returns (uint128)
    {

        SlotDetail storage slotDetail = _slotDetails[slot_];
        require(block.timestamp >= slotDetail.maturity, "premature");

        int256 iPrice = oracle.getPriceOfMaturity(
            voucher,
            slotDetail.maturity
        );
        if (iPrice < 0) {
            revert("negative price");
        }
        return uint128(iPrice);
    }

    function getSlot(
        address issuer_,
        address fundCurrency_,
        uint128 lowestPrice_,
        uint128 highestPrice_,
        uint64 effectiveTime_,
        uint64 maturity_,
        uint8 collateralType_
    ) public view returns (uint256) {

        return
            uint256(
                keccak256(
                    abi.encode(
                        underlyingToken,
                        underlyingVestingVoucher,
                        issuer_,
                        fundCurrency_,
                        lowestPrice_,
                        highestPrice_,
                        effectiveTime_,
                        maturity_,
                        collateralType_
                    )
                )
            );
    }

    function getSlotDetail(uint256 slot_)
        external
        view
        returns (SlotDetail memory)
    {

        return _slotDetails[slot_];
    }

    function getIssuerSlots(address issuer_)
        external
        view
        returns (uint256[] memory slots)
    {

        slots = new uint256[](_issuerSlots[issuer_].length());
        for (uint256 i = 0; i < slots.length; i++) {
            slots[i] = _issuerSlots[issuer_].at(i);
        }
    }

    function getIssuerSlotDetails(address issuer_)
        external
        view
        returns (SlotDetail[] memory slotDetails)
    {

        slotDetails = new SlotDetail[](_issuerSlots[issuer_].length());
        for (uint256 i = 0; i < slotDetails.length; i++) {
            slotDetails[i] = _slotDetails[_issuerSlots[issuer_].at(i)];
        }
    }

    function setUnderlyingVestingVoucher(address underlyingVestingVoucher_) 
        external 
        onlyAdmin 
    {

        underlyingVestingVoucher = underlyingVestingVoucher_;
    }

    function setFundCurrency(address fundCurrency_, bool enable_)
        external
        onlyAdmin
    {

        fundCurrencies[fundCurrency_] = enable_;
        emit SetFundCurrency(fundCurrency_, enable_);
    }

    function setVoucher(address newVoucher_) external onlyAdmin {

        require(newVoucher_ != address(0), "new voucher cannot be 0 address");
        emit NewVoucher(voucher, newVoucher_);
        voucher = newVoucher_;
    }
    
}// MIT

pragma solidity 0.7.6;


interface IConvertibleVoucher {


    struct ConvertibleVoucherSnapshot {
        IConvertiblePool.SlotDetail slotDetail;
        uint256 tokenId;
        uint256 parValue;
    }

    event SetDescriptor(address oldDescriptor, address newDescriptor);

    event SetSolver(address oldSolver, address newSolver);

    event Claim (
        uint256 indexed tokenId,
        address indexed to,
        uint256 claimUnits,
        uint256 claimCurrencyAmount, 
        uint256 claimTokenAmount
    );

    function mint(
        address issuer_,
        address fundCurrency_,
        uint128 lowestPrice_,
        uint128 highestPrice_,
        uint64 effectiveTime_,
        uint64 maturity_,
        uint256 tokenInAmount_
    ) 
        external 
        returns (uint256 slot, uint256 tokenId);


    function claimAll(uint256 tokenId_) external;

    
    function claim(uint256 tokenId_, uint256 claimUnits_) external;


    function claimTo(uint256 tokenId_, address to_, uint256 claimUnits_) external;


    function getSlot(
        address issuer_,
        address fundCurrency_,
        uint128 lowestPrice_,
        uint128 highestPrice_,
        uint64 effectiveTime_,
        uint64 maturity_,
        uint8 collateralType_
    ) 
        external
        view 
        returns (uint256 slot);


    function getSlotDetail(uint256 slot_) 
        external 
        view 
        returns (IConvertiblePool.SlotDetail memory);


    function getIssuerSlots(address issuer_) 
        external 
        view 
        returns (uint256[] memory slots);


    function getSnapshot(uint256 tokenId_)
        external
        view
        returns (ConvertibleVoucherSnapshot memory);


    function underlying() external view returns (address);


    function underlyingVestingVoucher() external view returns (address);


}// MIT

pragma solidity 0.7.6;


contract ConvertibleVoucher is IConvertibleVoucher, VoucherCore, ReentrancyGuardUpgradeable {

    using SafeMathUpgradeable for uint256;

    ConvertiblePool public convertiblePool;

    IVNFTDescriptor public voucherDescriptor;

    ISolver public solver;

    function initialize(
        address convertiblePool_,
        address voucherDescriptor_,
        address solver_,
        uint8 unitDecimals_,
        string calldata name_,
        string calldata symbol_
    )
        external
        initializer
    {

        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        VoucherCore._initialize(name_, symbol_, unitDecimals_);

        convertiblePool = ConvertiblePool(convertiblePool_);
        voucherDescriptor = IVNFTDescriptor(voucherDescriptor_);
        solver = ISolver(solver_);

        ERC165Upgradeable._registerInterface(type(IConvertibleVoucher).interfaceId);
    }

    function mint(
        address issuer_,
        address fundCurrency_,
        uint128 lowestPrice_,
        uint128 highestPrice_,
        uint64 effectiveTime_,
        uint64 maturity_,
        uint256 tokenInAmount_ // 最大偿付token数量 (at lowestPrice)
    ) 
        external 
        override
        nonReentrant
        returns (uint256 slot, uint256 tokenId) 
    {

        uint256 err = solver.operationAllowed(
            "mint", 
            abi.encode(
                _msgSender(),
                issuer_,
                fundCurrency_,
                lowestPrice_,
                highestPrice_,
                effectiveTime_, 
                maturity_,
                tokenInAmount_
            )
        );
        require(err == 0, "Solver: not allowed");

        slot = getSlot(
            issuer_, fundCurrency_, lowestPrice_, highestPrice_, 
            effectiveTime_, maturity_, 0
        );
        if (!getSlotDetail(slot).isValid) {
            convertiblePool.createSlot(
                issuer_, fundCurrency_, lowestPrice_, highestPrice_, 
                effectiveTime_, maturity_, 0
            );
        }

        uint256 units = convertiblePool.mintWithUnderlyingToken(_msgSender(), slot, tokenInAmount_);
        tokenId = VoucherCore._mint(_msgSender(), slot, units);

        solver.operationVerify(
            "mint", 
            abi.encode(_msgSender(), issuer_, slot, tokenId, units)
        );
    }

    function claimAll(uint256 tokenId_) external override {

        claim(tokenId_, unitsInToken(tokenId_));
    }
    
    function claim(uint256 tokenId_, uint256 claimUnits_) public override {

        claimTo(tokenId_, _msgSender(), claimUnits_);
    }

    function claimTo(uint256 tokenId_, address to_, uint256 claimUnits_) public override nonReentrant {

        require(_msgSender() == ownerOf(tokenId_), "only owner");
        require(claimUnits_ <= unitsInToken(tokenId_), "over claim");

        uint256 err = solver.operationAllowed(
            "claim",
            abi.encode(_msgSender(), tokenId_, to_, claimUnits_)
        );
        require(err == 0, "Solver: not allowed");

        (uint256 claimCurrencyAmount, uint256 claimTokenAmount) 
            = convertiblePool.claim(voucherSlotMapping[tokenId_], to_, claimUnits_);

        if (claimUnits_ == unitsInToken(tokenId_)) {
            _burnVoucher(tokenId_);
        } else {
            _burnUnits(tokenId_, claimUnits_);
        }

        solver.operationVerify(
            "claim",
            abi.encode(_msgSender(), tokenId_, to_, claimUnits_)
        );

        emit Claim(tokenId_, to_, claimUnits_, claimCurrencyAmount, claimTokenAmount);
    }

    function getSlot(
        address issuer_,
        address fundCurrency_,
        uint128 lowestPrice_,
        uint128 highestPrice_,
        uint64 effectiveTime_,
        uint64 maturity_,
        uint8 collateralType_
    ) 
        public  
        view 
        override
        returns (uint256) 
    {

        return convertiblePool.getSlot(
            issuer_, fundCurrency_, lowestPrice_, highestPrice_, 
            effectiveTime_, maturity_, collateralType_
        );
    }

    function getSlotDetail(uint256 slot_) public view override returns (IConvertiblePool.SlotDetail memory) {

        return convertiblePool.getSlotDetail(slot_);
    }

    function getIssuerSlots(address issuer_) external view override returns (uint256[] memory slots) {

        return convertiblePool.getIssuerSlots(issuer_);
    }
    
    function contractURI() external view override returns (string memory) {

        return voucherDescriptor.contractURI();
    }

    function slotURI(uint256 slot_) external view override returns (string memory) {

        return voucherDescriptor.slotURI(slot_);
    }

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {

        require(_exists(tokenId_), "token not exists");
        return voucherDescriptor.tokenURI(tokenId_);
    }

    function getSnapshot(uint256 tokenId_)
        public
        override
        view
        returns (ConvertibleVoucherSnapshot memory snapshot)
    {

        snapshot.tokenId = tokenId_;
        snapshot.parValue = unitsInToken(tokenId_);
        snapshot.slotDetail = convertiblePool.getSlotDetail(voucherSlotMapping[tokenId_]);
    }

    function underlying() external view override returns (address) {

        return convertiblePool.underlyingToken();
    }

    function underlyingVestingVoucher() external view override returns (address) {

        return convertiblePool.underlyingVestingVoucher();
    }

    function setVoucherDescriptor(address newDescriptor_) external onlyAdmin {

        require(newDescriptor_ != address(0), "newDescriptor can not be 0 address");
        emit SetDescriptor(address(voucherDescriptor), newDescriptor_);
        voucherDescriptor = IVNFTDescriptor(newDescriptor_);
    }

    function setSolver(ISolver newSolver_) external onlyAdmin {

        require(newSolver_.isSolver(), "invalid solver");
        emit SetSolver(address(solver), address(newSolver_));
        solver = newSolver_;
    }

    function voucherType() external pure override returns (Constants.VoucherType) {

        return Constants.VoucherType.BOUNDING;
    }

    function version() external pure returns (string memory) {

        return "1.0.1";
    }
}// MIT

pragma solidity 0.7.6;


contract BondVoucherDescriptor is IVNFTDescriptor, AdminControl {


    event SetVoucherSVG(
        address indexed voucher,
        address oldVoucherSVG,
        address newVoucherSVG
    );

    event SetBondWarrant(
        address indexed voucher,
        uint256 indexed slot,
        string bondWarrant
    );

    using StringConvertor for address;
    using StringConvertor for uint256;
    using StringConvertor for bytes;

    mapping(address => address) public voucherSVGs;

    mapping(address => mapping(uint256 => string)) public bondWarrants;


    function initialize(address defaultVoucherSVG_) external initializer {

        AdminControl.__AdminControl_init(_msgSender());
        setVoucherSVG(address(0), defaultVoucherSVG_);
    }

    function setVoucherSVG(address voucher_, address voucherSVG_) public onlyAdmin {

        emit SetVoucherSVG(voucher_, voucherSVGs[voucher_], voucherSVG_);
        voucherSVGs[voucher_] = voucherSVG_;
    }

    function setBondWarrant(address voucher_, uint256 slot_, string calldata bondWarrant) external onlyAdmin {

        emit SetBondWarrant(voucher_, slot_, bondWarrant);
        bondWarrants[voucher_][slot_] = bondWarrant;
    }

    function contractURI() external view override returns (string memory) { 

        ConvertibleVoucher voucher = ConvertibleVoucher(_msgSender());
        return string(
            abi.encodePacked(
                'data:application/json;{"name":"', voucher.name(),
                '","description":"', _contractDescription(voucher),
                '","unitDecimals":"', uint256(voucher.unitDecimals()).toString(),
                '","properties":{}}'
            )
        );
    }

    function slotURI(uint256 slot_) external view override returns (string memory) {
        ConvertibleVoucher voucher = ConvertibleVoucher(_msgSender());
        ConvertiblePool pool = voucher.convertiblePool();
        ConvertiblePool.SlotDetail memory slotDetail = pool.getSlotDetail(slot_);

        return string(
            abi.encodePacked(
                'data:application/json;{"unitsInSlot":"', voucher.unitsInSlot(slot_).toString(),
                '","tokensInSlot":"', voucher.tokensInSlot(slot_).toString(),
                '","properties":', _properties(pool, slot_, slotDetail),
                '}'
            )
        );
    }

    function tokenURI(uint256 tokenId_)
        external
        view
        virtual
        override
        returns (string memory)
    {
        ConvertibleVoucher voucher = ConvertibleVoucher(_msgSender());
        ConvertiblePool pool = voucher.convertiblePool();

        uint256 slot = voucher.slotOf(tokenId_);
        ConvertiblePool.SlotDetail memory slotDetail = pool.getSlotDetail(slot);
        
        bytes memory name = abi.encodePacked(voucher.name(), ' #', tokenId_.toString());

        address voucherSVG = voucherSVGs[_msgSender()];
        if (voucherSVG == address(0)) {
            voucherSVG = voucherSVGs[address(0)];
        }
        string memory image = IVoucherSVG(voucherSVG).generateSVG(_msgSender(), tokenId_);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"', name, 
                            '","description":"', _tokenDescription(voucher, tokenId_, slotDetail),
                            '","image":"data:image/svg+xml;base64,', Base64.encode(bytes(image)),
                            '","units":"', voucher.unitsInToken(tokenId_).toString(),
                            '","slot":"', slot.toString(),
                            '","properties":', _properties(pool, slot, slotDetail),
                            '}'
                        )
                    )
                )
            );
    }

    function _contractDescription(ConvertibleVoucher voucher) 
        private 
        view
        returns (bytes memory)
    {
        string memory underlyingSymbol = ERC20Upgradeable(voucher.underlying()).symbol();

        return abi.encodePacked(
            unicode'⚠️ ', _descAlert(), '\\n\\n',
            'Convertible Voucher of ', underlyingSymbol, '. ',
            _descVoucher(), '\\n\\n', 
            _descProtocol()
        );
    }

    function _tokenDescription(
        ConvertibleVoucher voucher, 
        uint256 tokenId, 
        ConvertiblePool.SlotDetail memory slotDetail
    )
        private
        view
        returns (bytes memory)
    {
        string memory underlyingSymbol = ERC20Upgradeable(voucher.underlying()).symbol();

        return abi.encodePacked(
            unicode'⚠️ ', _descAlert(), '\\n\\n',
            'Convertible Voucher #', tokenId.toString(), ' of ', underlyingSymbol, '. ',
            _descVoucher(), '\\n\\n', 
            abi.encodePacked(
                '- Voucher Address: ', address(voucher).addressToString(), '\\n',
                '- Pool Address: ', address(voucher.convertiblePool()).addressToString(), '\\n',
                '- Underlying Address: ', voucher.underlying().addressToString(), '\\n',
                '- Fund Currency Address: ', slotDetail.fundCurrency.addressToString()
            )
        );
    }

    function _descAlert() private pure returns (string memory) {
        return "**Alert**: The price of the NFTs you're seeing on this page may be incorrect due to the failure of several third-party marketplaces to keep the numbers up to date. Please check the Voucher's correct pricing on the Solv dApp before buying or making an offer.";
    }

    function _descVoucher() private pure returns (string memory) {
        return 
            string(
                abi.encodePacked(
                    'Convertible Voucher is a structured product that can be converted into a predetermined number of tokens or stablecoins under certain conditions.',
                    '\\n\\n', 
                    'At maturity, the holders are paid the face value in stablecoins if the settlement price falls into the bond range. Otherwise, the Voucher will convert to an amount of tokens redeemable by the holder.'
                )
            );
    }

    function _descProtocol() private pure returns (string memory) {
        return 'Solv Protocol is the decentralized platform for creating, managing and trading Financial NFTs.';
    }

    function _properties(
        ConvertiblePool pool,
        uint256 slot,
        ConvertiblePool.SlotDetail memory slotDetail
    ) 
        private
        view
        returns (bytes memory data) 
    {
        string memory bondWarrant = bondWarrants[_msgSender()][slot];
        if (bytes(bondWarrant).length == 0) {
            bondWarrant = bondWarrants[_msgSender()][0];
        }

        return 
            abi.encodePacked(
                abi.encodePacked(
                    '{"underlyingToken":"', pool.underlyingToken().addressToString(),
                    '","fundCurrency":"', slotDetail.fundCurrency.addressToString(), 
                    '","issuer":"', slotDetail.issuer.addressToString(),
                    '","totalValue":"', _formatValue(slotDetail.totalValue, pool.valueDecimals()),
                    '","bondWarrant":"', bondWarrant
                ),
                abi.encodePacked(
                    '","highestPrice":"', _formatValue(slotDetail.highestPrice, pool.priceDecimals()),
                    '","lowestPrice":"', _formatValue(slotDetail.lowestPrice, pool.priceDecimals()),
                    '","settlePrice":"', _formatValue(slotDetail.settlePrice, pool.priceDecimals()),
                    '","effectiveTime":"', uint256(slotDetail.effectiveTime).datetimeToString(),
                    '","maturity":"', uint256(slotDetail.maturity).datetimeToString(),
                    '"}'
                )
            );
    }

    function _formatValue(uint256 value, uint8 decimals) private pure returns (bytes memory) {
        return value.uint2decimal(decimals).trim(decimals - 2).addThousandsSeparator();
    }

}