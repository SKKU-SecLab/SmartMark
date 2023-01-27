
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
}// MIT

pragma solidity >=0.6.6 <0.9.0;

library Base64 {

    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}// MIT
pragma solidity ^0.8.0;


library BokkyPooBahsDateTimeLibrary {

    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {

        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days = _day -
            32075 +
            (1461 * (_year + 4800 + (_month - 14) / 12)) /
            4 +
            (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
            12 -
            (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
            4 -
            OFFSET19700101;

        _days = uint256(__days);
    }

    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {

        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function timestampFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (uint256 timestamp) {

        timestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            hour *
            SECONDS_PER_HOUR +
            minute *
            SECONDS_PER_MINUTE +
            second;
    }

    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (bool valid) {

        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }

    function isValidDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (bool valid) {

        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }

    function isLeapYear(uint256 timestamp) internal pure returns (bool leapYear) {

        (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }

    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {

        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {

        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {

        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint256 timestamp) internal pure returns (uint256 daysInMonth) {

        (uint256 year, uint256 month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month) internal pure returns (uint256 daysInMonth) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    function getDayOfWeek(uint256 timestamp) internal pure returns (uint256 dayOfWeek) {

        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {

        (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {

        (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) internal pure returns (uint256 day) {

        (, , day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {

        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp) internal pure returns (uint256 minute) {

        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp) internal pure returns (uint256 second) {

        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp) {

        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp) {

        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp) {

        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp) {

        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp) {

        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp) {

        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years) internal pure returns (uint256 newTimestamp) {

        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months) internal pure returns (uint256 newTimestamp) {

        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days) internal pure returns (uint256 newTimestamp) {

        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours) internal pure returns (uint256 newTimestamp) {

        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes) internal pure returns (uint256 newTimestamp) {

        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds) internal pure returns (uint256 newTimestamp) {

        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _years) {

        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _months) {

        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth, ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth, ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _days) {

        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _hours) {

        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _minutes) {

        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _seconds) {

        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}// MIT

pragma solidity >=0.8.0;

library DynamicBuffer {

    function allocate(uint256 capacity) internal pure returns (bytes memory buffer) {

        assembly {
            let container := mload(0x40)

            {
                let size := add(capacity, 0x60)
                let newNextFree := add(container, size)
                mstore(0x40, newNextFree)
            }

            {
                let length := add(capacity, 0x40)
                mstore(container, length)
            }

            buffer := add(container, 0x20)

            mstore(buffer, 0)
        }

        return buffer;
    }

    function appendUnchecked(bytes memory buffer, bytes memory data) internal pure {

        assembly {
            let length := mload(data)
            for {
                data := add(data, 0x20)
                let dataEnd := add(data, length)
                let copyTo := add(buffer, add(mload(buffer), 0x20))
            } lt(data, dataEnd) {
                data := add(data, 0x20)
                copyTo := add(copyTo, 0x20)
            } {
                mstore(copyTo, mload(data))
            }

            mstore(buffer, add(mload(buffer), length))
        }
    }

    function appendSafe(bytes memory buffer, bytes memory data) internal pure {

        uint256 capacity;
        uint256 length;
        assembly {
            capacity := sub(mload(sub(buffer, 0x20)), 0x40)
            length := mload(buffer)
        }

        require(length + data.length <= capacity, "DynamicBuffer: Appending out of bounds.");
        appendUnchecked(buffer, data);
    }
}// MIT

pragma solidity ^0.8.0;

library EssentialStrings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function toHtmlHexString(uint256 value) internal pure returns (string memory) {

        bytes memory buffer = new bytes(7);
        buffer[0] = "#";
        for (uint256 i = 6; i > 0; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }

        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function toPaddedNumberString(uint256 value) internal pure returns (string memory) {

        bytes memory buffer = new bytes(3);

        if (value < 10) {
            buffer[0] = "0";
            buffer[1] = "0";
            buffer[2] = _HEX_SYMBOLS[value & 0xf];
            return string(buffer);
        }

        uint256 temp = value;
        uint256 digits = 1;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        buffer[0] = "0";
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}// MIT
pragma solidity ^0.8.9;




interface ICorruptionsFont {

    function font() external view returns (string memory);

}

contract BlockClockRenderer is Ownable {

    using DynamicBuffer for bytes;
    using EssentialStrings for uint256;
    using EssentialStrings for uint24;
    using EssentialStrings for uint8;

    ICorruptionsFont private font;

    constructor() {}

    function setFont(address fontAddress) external onlyOwner {

        font = ICorruptionsFont(fontAddress);
    }


    function svgBase64Data(
        int8 hourOffset,
        uint24 hexCode,
        uint256 timestamp
    ) public view returns (string memory) {

        return
            string(
                abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(svgRaw(hourOffset, hexCode, timestamp)))
            );
    }

    function svgRaw(
        int8 hourOffset,
        uint24 hexCode,
        uint256 timestamp
    ) public view returns (bytes memory) {

        uint256 _timestamp = timestamp == 0
            ? uint256(int256(block.timestamp) + int256(hourOffset) * 1 hours)
            : timestamp;

        bytes memory svg = DynamicBuffer.allocate(2**16); // 64KB - reduce?

        (, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second) = BokkyPooBahsDateTimeLibrary
            .timestampToDateTime(_timestamp);

        bytes memory elementClasses = abi.encodePacked(
            dotwClass(_timestamp),
            monthClass(month),
            dayClass(day),
            hourClass(hour),
            minuteClass(minute),
            secondClass(second)
        );

        svg.appendSafe(
            abi.encodePacked(
                "<svg viewBox='0 0 1024 1024' width='1024' height='1024' xmlns='http://www.w3.org/2000/svg'>",
                '<style> @font-face { font-family: CorruptionsFont; src: url("',
                font.font(),
                '") format("opentype"); } ',
                ".wk { letter-spacing: 24px; } .base{fill:#504f54;font-family:CorruptionsFont;font-size: 36px;} ",
                elementClasses,
                "{fill: ",
                hexCode.toHtmlHexString(),
                ";} </style> ",
                '<rect width="100%" height="100%" fill="#181A18" /> '
            )
        );

        for (uint256 i = 1; i < 27; i++) {
            svg.appendSafe(renderRow(i));
        }

        svg.appendSafe(" </svg>");

        return svg;
    }

    function renderRow(uint256 rowNum) internal view returns (bytes memory) {

        bytes memory row = DynamicBuffer.allocate(2**16); // 64KB
        row.appendSafe(abi.encodePacked('<text x="0" y="', ((rowNum + 1) * 36).toString(), '" class="base"> '));
        string[7] memory rowLabels = rowElements(rowNum - 1);

        for (uint256 i = 0; i < 7; i++) {
            row.appendSafe(
                abi.encodePacked(
                    '<tspan class="',
                    abi.encodePacked("wk el", rowNum.toString(), i.toString()),
                    '"  x="',
                    (46 + (138 * i)).toString(),
                    '">',
                    rowLabels[i],
                    "</tspan> "
                )
            );
        }

        row.appendSafe("</text> ");

        return row;
    }

    function rowElements(uint256 rowIndex) internal view returns (string[7] memory row) {

        if (rowIndex > 2) {
            return paddedNumberRow(rowIndex);
        }

        if (rowIndex == 0) return ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        if (rowIndex == 1) return ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL"];
        if (rowIndex == 2) return ["AUG", "SEP", "OCT", "NOV", "DEC", "001", "002"];
    }

    function paddedNumberRow(uint256 rowIndex) internal view returns (string[7] memory row) {

        int256 maxUnit = 59;

        for (int256 index = 0; index < 7; index++) {
            int256 start = int256(rowIndex < 9 ? (rowIndex * 7) - 18 : (rowIndex - 8) * 7 - 6);

            if (rowIndex == 7) {
                maxUnit = 31;

                if (index == 1) {
                    row[uint256(index)] = "012";
                    continue;
                }

                if (index > 1) {
                    start = -1;
                }
            }

            if (rowIndex == 8) {
                maxUnit = 11;
                start = 6;
            }

            int256 unit = start + index;

            if (unit > maxUnit) {
                unit = unit - maxUnit - 1;
            }

            row[uint256(index)] = uint256(unit).toPaddedNumberString();
        }
    }

    function dotwClass(uint256 timestamp) internal view returns (bytes memory) {

        uint256 dow = BokkyPooBahsDateTimeLibrary.getDayOfWeek(timestamp);
        if (dow == 7) return bytes(".el10,");

        return abi.encodePacked(".el1", dow.toString(), ",");
    }

    function monthClass(uint256 month) internal view returns (bytes memory) {

        if (month > 7) {
            return abi.encodePacked(".el3", (month - 8).toString());
        }

        return abi.encodePacked(".el2", (month - 1).toString());
    }

    function dayClass(uint256 day) internal view returns (bytes memory) {

        if (day < 3) {
            return abi.encodePacked(",.el3", (day + 4).toString());
        }

        uint256 dayIdx = (day - 3) % 7;
        uint256 dayRow = (day - 3) / 7 + 4;

        return abi.encodePacked(",.el", dayRow.toString(), dayIdx.toString());
    }

    function hourClass(uint256 hour) internal view returns (bytes memory) {

        if (hour < 6) {
            return abi.encodePacked(",.el8", (hour + 1).toString());
        }

        uint256 meridianHour = hour % 12;

        if (meridianHour < 6) {
            return abi.encodePacked(",.el8", (meridianHour + 1).toString());
        }

        return abi.encodePacked(",.el9", (meridianHour - 6).toString());
    }

    function minuteClass(uint256 minute) internal view returns (bytes memory) {

        if (minute == 0) {
            return bytes(",.el96");
        }

        uint256 minuteIdx = (minute - 1) % 7;
        uint256 minuteRow = (minute - 1) / 7 + 10;

        return abi.encodePacked(",.el", minuteRow.toString(), minuteIdx.toString());
    }

    function secondClass(uint256 second) internal view returns (bytes memory) {

        if (second < 4) {
            return abi.encodePacked(",.el18", (second + 3).toString());
        }

        uint256 secondIdx = (second - 4) % 7;
        uint256 secondRow = (second - 4) / 7 + 19;

        return abi.encodePacked(",.el", secondRow.toString(), secondIdx.toString());
    }
}