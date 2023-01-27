


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

    function isLeapYear(uint256 timestamp)
        internal
        pure
        returns (bool leapYear)
    {

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

    function getDaysInMonth(uint256 timestamp)
        internal
        pure
        returns (uint256 daysInMonth)
    {

        (uint256 year, uint256 month, ) = _daysToDate(
            timestamp / SECONDS_PER_DAY
        );
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month)
        internal
        pure
        returns (uint256 daysInMonth)
    {

        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    function getDayOfWeek(uint256 timestamp)
        internal
        pure
        returns (uint256 dayOfWeek)
    {

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

    function getMinute(uint256 timestamp)
        internal
        pure
        returns (uint256 minute)
    {

        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp)
        internal
        pure
        returns (uint256 second)
    {

        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        (uint256 year, uint256 month, uint256 day) = _daysToDate(
            timestamp / SECONDS_PER_DAY
        );
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        (uint256 year, uint256 month, uint256 day) = _daysToDate(
            timestamp / SECONDS_PER_DAY
        );
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        (uint256 year, uint256 month, uint256 day) = _daysToDate(
            timestamp / SECONDS_PER_DAY
        );
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        (uint256 year, uint256 month, uint256 day) = _daysToDate(
            timestamp / SECONDS_PER_DAY
        );
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {

        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _years)
    {

        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _months)
    {

        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth, ) = _daysToDate(
            fromTimestamp / SECONDS_PER_DAY
        );
        (uint256 toYear, uint256 toMonth, ) = _daysToDate(
            toTimestamp / SECONDS_PER_DAY
        );
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _days)
    {

        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _hours)
    {

        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _minutes)
    {

        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _seconds)
    {

        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}



pragma solidity ^0.8.0;

library ABDKMath64x64 {

    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function fromInt(int256 x) internal pure returns (int128) {

        unchecked {
            require(x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
            return int128(x << 64);
        }
    }

    function toInt(int128 x) internal pure returns (int64) {

        unchecked {
            return int64(x >> 64);
        }
    }

    function fromUInt(uint256 x) internal pure returns (int128) {

        unchecked {
            require(x <= 0x7FFFFFFFFFFFFFFF);
            return int128(int256(x << 64));
        }
    }

    function toUInt(int128 x) internal pure returns (uint64) {

        unchecked {
            require(x >= 0);
            return uint64(uint128(x >> 64));
        }
    }

    function from128x128(int256 x) internal pure returns (int128) {

        unchecked {
            int256 result = x >> 64;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    function to128x128(int128 x) internal pure returns (int256) {

        unchecked {
            return int256(x) << 64;
        }
    }

    function add(int128 x, int128 y) internal pure returns (int128) {

        unchecked {
            int256 result = int256(x) + y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    function sub(int128 x, int128 y) internal pure returns (int128) {

        unchecked {
            int256 result = int256(x) - y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    function mul(int128 x, int128 y) internal pure returns (int128) {

        unchecked {
            int256 result = (int256(x) * y) >> 64;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    function muli(int128 x, int256 y) internal pure returns (int256) {

        unchecked {
            if (x == MIN_64x64) {
                require(
                    y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
                        y <= 0x1000000000000000000000000000000000000000000000000
                );
                return -y << 63;
            } else {
                bool negativeResult = false;
                if (x < 0) {
                    x = -x;
                    negativeResult = true;
                }
                if (y < 0) {
                    y = -y; // We rely on overflow behavior here
                    negativeResult = !negativeResult;
                }
                uint256 absoluteResult = mulu(x, uint256(y));
                if (negativeResult) {
                    require(
                        absoluteResult <=
                            0x8000000000000000000000000000000000000000000000000000000000000000
                    );
                    return -int256(absoluteResult); // We rely on overflow behavior here
                } else {
                    require(
                        absoluteResult <=
                            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    );
                    return int256(absoluteResult);
                }
            }
        }
    }

    function mulu(int128 x, uint256 y) internal pure returns (uint256) {

        unchecked {
            if (y == 0) return 0;

            require(x >= 0);

            uint256 lo = (uint256(int256(x)) *
                (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
            uint256 hi = uint256(int256(x)) * (y >> 128);

            require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            hi <<= 64;

            require(
                hi <=
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -
                        lo
            );
            return hi + lo;
        }
    }

    function div(int128 x, int128 y) internal pure returns (int128) {

        unchecked {
            require(y != 0);
            int256 result = (int256(x) << 64) / y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    function divi(int256 x, int256 y) internal pure returns (int128) {

        unchecked {
            require(y != 0);

            bool negativeResult = false;
            if (x < 0) {
                x = -x; // We rely on overflow behavior here
                negativeResult = true;
            }
            if (y < 0) {
                y = -y; // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint128 absoluteResult = divuu(uint256(x), uint256(y));
            if (negativeResult) {
                require(absoluteResult <= 0x80000000000000000000000000000000);
                return -int128(absoluteResult); // We rely on overflow behavior here
            } else {
                require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int128(absoluteResult); // We rely on overflow behavior here
            }
        }
    }

    function divu(uint256 x, uint256 y) internal pure returns (int128) {

        unchecked {
            require(y != 0);
            uint128 result = divuu(x, y);
            require(result <= uint128(MAX_64x64));
            return int128(result);
        }
    }

    function neg(int128 x) internal pure returns (int128) {

        unchecked {
            require(x != MIN_64x64);
            return -x;
        }
    }

    function abs(int128 x) internal pure returns (int128) {

        unchecked {
            require(x != MIN_64x64);
            return x < 0 ? -x : x;
        }
    }

    function inv(int128 x) internal pure returns (int128) {

        unchecked {
            require(x != 0);
            int256 result = int256(0x100000000000000000000000000000000) / x;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    function avg(int128 x, int128 y) internal pure returns (int128) {

        unchecked {
            return int128((int256(x) + int256(y)) >> 1);
        }
    }

    function gavg(int128 x, int128 y) internal pure returns (int128) {

        unchecked {
            int256 m = int256(x) * int256(y);
            require(m >= 0);
            require(
                m <
                    0x4000000000000000000000000000000000000000000000000000000000000000
            );
            return int128(sqrtu(uint256(m)));
        }
    }

    function pow(int128 x, uint256 y) internal pure returns (int128) {

        unchecked {
            bool negative = x < 0 && y & 1 == 1;

            uint256 absX = uint128(x < 0 ? -x : x);
            uint256 absResult;
            absResult = 0x100000000000000000000000000000000;

            if (absX <= 0x10000000000000000) {
                absX <<= 63;
                while (y != 0) {
                    if (y & 0x1 != 0) {
                        absResult = (absResult * absX) >> 127;
                    }
                    absX = (absX * absX) >> 127;

                    if (y & 0x2 != 0) {
                        absResult = (absResult * absX) >> 127;
                    }
                    absX = (absX * absX) >> 127;

                    if (y & 0x4 != 0) {
                        absResult = (absResult * absX) >> 127;
                    }
                    absX = (absX * absX) >> 127;

                    if (y & 0x8 != 0) {
                        absResult = (absResult * absX) >> 127;
                    }
                    absX = (absX * absX) >> 127;

                    y >>= 4;
                }

                absResult >>= 64;
            } else {
                uint256 absXShift = 63;
                if (absX < 0x1000000000000000000000000) {
                    absX <<= 32;
                    absXShift -= 32;
                }
                if (absX < 0x10000000000000000000000000000) {
                    absX <<= 16;
                    absXShift -= 16;
                }
                if (absX < 0x1000000000000000000000000000000) {
                    absX <<= 8;
                    absXShift -= 8;
                }
                if (absX < 0x10000000000000000000000000000000) {
                    absX <<= 4;
                    absXShift -= 4;
                }
                if (absX < 0x40000000000000000000000000000000) {
                    absX <<= 2;
                    absXShift -= 2;
                }
                if (absX < 0x80000000000000000000000000000000) {
                    absX <<= 1;
                    absXShift -= 1;
                }

                uint256 resultShift = 0;
                while (y != 0) {
                    require(absXShift < 64);

                    if (y & 0x1 != 0) {
                        absResult = (absResult * absX) >> 127;
                        resultShift += absXShift;
                        if (absResult > 0x100000000000000000000000000000000) {
                            absResult >>= 1;
                            resultShift += 1;
                        }
                    }
                    absX = (absX * absX) >> 127;
                    absXShift <<= 1;
                    if (absX >= 0x100000000000000000000000000000000) {
                        absX >>= 1;
                        absXShift += 1;
                    }

                    y >>= 1;
                }

                require(resultShift < 64);
                absResult >>= 64 - resultShift;
            }
            int256 result = negative ? -int256(absResult) : int256(absResult);
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    function sqrt(int128 x) internal pure returns (int128) {

        unchecked {
            require(x >= 0);
            return int128(sqrtu(uint256(int256(x)) << 64));
        }
    }

    function log_2(int128 x) internal pure returns (int128) {

        unchecked {
            require(x > 0);

            int256 msb = 0;
            int256 xc = x;
            if (xc >= 0x10000000000000000) {
                xc >>= 64;
                msb += 64;
            }
            if (xc >= 0x100000000) {
                xc >>= 32;
                msb += 32;
            }
            if (xc >= 0x10000) {
                xc >>= 16;
                msb += 16;
            }
            if (xc >= 0x100) {
                xc >>= 8;
                msb += 8;
            }
            if (xc >= 0x10) {
                xc >>= 4;
                msb += 4;
            }
            if (xc >= 0x4) {
                xc >>= 2;
                msb += 2;
            }
            if (xc >= 0x2) msb += 1; // No need to shift xc anymore

            int256 result = (msb - 64) << 64;
            uint256 ux = uint256(int256(x)) << uint256(127 - msb);
            for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
                ux *= ux;
                uint256 b = ux >> 255;
                ux >>= 127 + b;
                result += bit * int256(b);
            }

            return int128(result);
        }
    }

    function ln(int128 x) internal pure returns (int128) {

        unchecked {
            require(x > 0);

            return
                int128(
                    int256(
                        (uint256(int256(log_2(x))) *
                            0xB17217F7D1CF79ABC9E3B39803F2F6AF) >> 128
                    )
                );
        }
    }

    function exp_2(int128 x) internal pure returns (int128) {

        unchecked {
            require(x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            uint256 result = 0x80000000000000000000000000000000;

            if (x & 0x8000000000000000 > 0)
                result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
            if (x & 0x4000000000000000 > 0)
                result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
            if (x & 0x2000000000000000 > 0)
                result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
            if (x & 0x1000000000000000 > 0)
                result = (result * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
            if (x & 0x800000000000000 > 0)
                result = (result * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
            if (x & 0x400000000000000 > 0)
                result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
            if (x & 0x200000000000000 > 0)
                result = (result * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
            if (x & 0x100000000000000 > 0)
                result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
            if (x & 0x80000000000000 > 0)
                result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
            if (x & 0x40000000000000 > 0)
                result = (result * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
            if (x & 0x20000000000000 > 0)
                result = (result * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
            if (x & 0x10000000000000 > 0)
                result = (result * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
            if (x & 0x8000000000000 > 0)
                result = (result * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
            if (x & 0x4000000000000 > 0)
                result = (result * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
            if (x & 0x2000000000000 > 0)
                result = (result * 0x1000162E525EE054754457D5995292026) >> 128;
            if (x & 0x1000000000000 > 0)
                result = (result * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
            if (x & 0x800000000000 > 0)
                result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
            if (x & 0x400000000000 > 0)
                result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
            if (x & 0x200000000000 > 0)
                result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
            if (x & 0x100000000000 > 0)
                result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
            if (x & 0x80000000000 > 0)
                result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
            if (x & 0x40000000000 > 0)
                result = (result * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
            if (x & 0x20000000000 > 0)
                result = (result * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
            if (x & 0x10000000000 > 0)
                result = (result * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
            if (x & 0x8000000000 > 0)
                result = (result * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
            if (x & 0x4000000000 > 0)
                result = (result * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
            if (x & 0x2000000000 > 0)
                result = (result * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
            if (x & 0x1000000000 > 0)
                result = (result * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
            if (x & 0x800000000 > 0)
                result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
            if (x & 0x400000000 > 0)
                result = (result * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
            if (x & 0x200000000 > 0)
                result = (result * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
            if (x & 0x100000000 > 0)
                result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
            if (x & 0x80000000 > 0)
                result = (result * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
            if (x & 0x40000000 > 0)
                result = (result * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
            if (x & 0x20000000 > 0)
                result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
            if (x & 0x10000000 > 0)
                result = (result * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
            if (x & 0x8000000 > 0)
                result = (result * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
            if (x & 0x4000000 > 0)
                result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
            if (x & 0x2000000 > 0)
                result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
            if (x & 0x1000000 > 0)
                result = (result * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
            if (x & 0x800000 > 0)
                result = (result * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
            if (x & 0x400000 > 0)
                result = (result * 0x100000000002C5C85FDF477B662B26945) >> 128;
            if (x & 0x200000 > 0)
                result = (result * 0x10000000000162E42FEFA3AE53369388C) >> 128;
            if (x & 0x100000 > 0)
                result = (result * 0x100000000000B17217F7D1D351A389D40) >> 128;
            if (x & 0x80000 > 0)
                result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
            if (x & 0x40000 > 0)
                result = (result * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
            if (x & 0x20000 > 0)
                result = (result * 0x100000000000162E42FEFA39FE95583C2) >> 128;
            if (x & 0x10000 > 0)
                result = (result * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
            if (x & 0x8000 > 0)
                result = (result * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
            if (x & 0x4000 > 0)
                result = (result * 0x10000000000002C5C85FDF473E242EA38) >> 128;
            if (x & 0x2000 > 0)
                result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
            if (x & 0x1000 > 0)
                result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
            if (x & 0x800 > 0)
                result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
            if (x & 0x400 > 0)
                result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
            if (x & 0x200 > 0)
                result = (result * 0x10000000000000162E42FEFA39EF44D91) >> 128;
            if (x & 0x100 > 0)
                result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
            if (x & 0x80 > 0)
                result = (result * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
            if (x & 0x40 > 0)
                result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
            if (x & 0x20 > 0)
                result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
            if (x & 0x10 > 0)
                result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
            if (x & 0x8 > 0)
                result = (result * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
            if (x & 0x4 > 0)
                result = (result * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
            if (x & 0x2 > 0)
                result = (result * 0x1000000000000000162E42FEFA39EF358) >> 128;
            if (x & 0x1 > 0)
                result = (result * 0x10000000000000000B17217F7D1CF79AB) >> 128;

            result >>= uint256(int256(63 - (x >> 64)));
            require(result <= uint256(int256(MAX_64x64)));

            return int128(int256(result));
        }
    }

    function exp(int128 x) internal pure returns (int128) {

        unchecked {
            require(x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            return
                exp_2(
                    int128(
                        (int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12) >> 128
                    )
                );
        }
    }

    function divuu(uint256 x, uint256 y) private pure returns (uint128) {

        unchecked {
            require(y != 0);

            uint256 result;

            if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                result = (x << 64) / y;
            else {
                uint256 msb = 192;
                uint256 xc = x >> 192;
                if (xc >= 0x100000000) {
                    xc >>= 32;
                    msb += 32;
                }
                if (xc >= 0x10000) {
                    xc >>= 16;
                    msb += 16;
                }
                if (xc >= 0x100) {
                    xc >>= 8;
                    msb += 8;
                }
                if (xc >= 0x10) {
                    xc >>= 4;
                    msb += 4;
                }
                if (xc >= 0x4) {
                    xc >>= 2;
                    msb += 2;
                }
                if (xc >= 0x2) msb += 1; // No need to shift xc anymore

                result = (x << (255 - msb)) / (((y - 1) >> (msb - 191)) + 1);
                require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 hi = result * (y >> 128);
                uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 xh = x >> 192;
                uint256 xl = x << 64;

                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here
                lo = hi << 128;
                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here

                assert(xh == hi >> 128);

                result += xl / y;
            }

            require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return uint128(result);
        }
    }

    function sqrtu(uint256 x) private pure returns (uint128) {

        unchecked {
            if (x == 0) return 0;
            else {
                uint256 xx = x;
                uint256 r = 1;
                if (xx >= 0x100000000000000000000000000000000) {
                    xx >>= 128;
                    r <<= 64;
                }
                if (xx >= 0x10000000000000000) {
                    xx >>= 64;
                    r <<= 32;
                }
                if (xx >= 0x100000000) {
                    xx >>= 32;
                    r <<= 16;
                }
                if (xx >= 0x10000) {
                    xx >>= 16;
                    r <<= 8;
                }
                if (xx >= 0x100) {
                    xx >>= 8;
                    r <<= 4;
                }
                if (xx >= 0x10) {
                    xx >>= 4;
                    r <<= 2;
                }
                if (xx >= 0x8) {
                    r <<= 1;
                }
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1; // Seven iterations should be enough
                uint256 r1 = x / r;
                return uint128(r < r1 ? r : r1);
            }
        }
    }
}




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
}




pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

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
}



pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;





contract evaiStableCoinFund is ReentrancyGuard {

    
    using SafeMath for uint256;
    
    struct stakeType {
        bool active;
        uint8 Type;
        uint80 percentageReturn;
        uint80 bonusTerm;
        uint80 bonusMultiplier;
        uint128 minAmount;
        uint128 maxAmount;
    }

    struct stake {
        bool active;
        bool partialWithdrawn;
        bool settled;
        uint8 Type;
        address ownerAddress;
        uint32 startOfTerm;
        uint32 endOfTerm;
        uint32 id;
        uint32 linkedStakeID;
        uint64 evaiAmount;
        uint64 settlementAmount;
        uint64 stakeReturns;
    }

    IERC20 evaiToken;
    uint8 currentStakeType;
    address owner;
    uint32 currentStakeID;
    uint64 currentStakedEvaiAmount;
    uint64 totalProfitsDistrubuted;
    uint64 totalStakedEvaiAmount;
    bool acceptingStakes;
    uint32 acceptingStakesEndTime;

    event AddStake(
        uint8 _Type,
        address _stakeOwner,
        uint32 _startofTerm,
        uint32 _stakeID,
        uint64 _evaiAmount
    );

    event ReStake(
        uint8 _Type,
        address _stakeOwner,
        uint32 _startOfTerm,
        uint32 _stakeID,
        uint64 _evaiAmount,
        uint32 _linkedStakeID
    );

    event WithdrawStake(
        bool _active,
        bool _partialWithdrawn,
        bool _settled,
        uint32 _stakeID,
        uint32 _endOfTerm,
        uint64 _settlementAmount
    );

    mapping(uint32 => stake) stakeByID;
    mapping(address => uint32[]) stakeByOwnerAddress;
    mapping(uint32 => stakeType) stakeTypes;
    mapping(uint32 => bool) stakeTypeAlreadyExists;

    constructor(address _token) {
        evaiToken = IERC20(_token);
        owner = msg.sender;
        acceptingStakes = false;
        acceptingStakesEndTime = uint32(block.timestamp);
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        owner = _newOwner;
    }

    function evaiTransfer(uint32 _stakeID) private {

        evaiToken.transfer(msg.sender, stakeByID[_stakeID].settlementAmount);
    }

    function setInitialState(
        uint32 _currentStakeID,
        uint64 _currentStakedEvaiAmount,
        uint64 _totalProfitsDistrubuted,
        uint64 _totalStakedEvaiAmount)
        external
        onlyOwner
    {

        currentStakeID = _currentStakeID;
        currentStakedEvaiAmount = _currentStakedEvaiAmount;
        totalProfitsDistrubuted = _totalProfitsDistrubuted;
        totalStakedEvaiAmount = _totalStakedEvaiAmount;
    }

    function addManualStake(
        stake calldata _stake
    )
        external
        onlyOwner
    {

        stakeByID[_stake.id] = _stake;
        stakeByOwnerAddress[_stake.ownerAddress].push(_stake.id);
    }

    function removeManualStake(uint32 _stakeID)
        external
        onlyOwner
    {


        require(stakeByID[_stakeID].active, "Stake does not exist");

        uint32[] memory userStakes = stakeByOwnerAddress[stakeByID[_stakeID].ownerAddress];
        uint32[] memory newStakes = new uint32[](userStakes.length - 1);
        uint newStakeId = 0;
        for (uint i = 0; i < userStakes.length; ++i) {
            if (userStakes[i] != _stakeID) {
                newStakes[newStakeId++] = _stakeID;
            }
        }
        stakeByOwnerAddress[stakeByID[_stakeID].ownerAddress] = newStakes;

        delete stakeByID[_stakeID];

    }

    function getCurrentCountOfStakeTypes()
        external
        view
        onlyOwner
        returns (uint32 currentStakeTypes)
    {

        return currentStakeType;
    }

    function getCurrentStakeID()
        external
        view
        onlyOwner
        returns (uint32 currentStakeId)
    {

        return currentStakeID;
    }

    function getStakeType(uint32 _stakeType)
        external
        view
        onlyOwner
        returns (stakeType memory)
    {

        return stakeTypes[_stakeType];
    }

    function getBalance() external view onlyOwner returns (uint256) {

        return evaiToken.balanceOf(address(this));
    }

    function getStakesByAddress(address _user)
        external
        view
        onlyOwner
        returns (uint32[] memory)
    {

        require(
            _user != address(0),
            "EVAIFUND:Address can't be a zero address"
        );
        return stakeByOwnerAddress[_user];
    }

    function getTotalStaked()
        external
        view
        returns (uint64 totalEvaiAmountStaked)
    {

        return totalStakedEvaiAmount;
    }

    function getTotalProfitsDistributed()
        external
        view
        returns (uint64 totalProfits)
    {

        return totalProfitsDistrubuted;
    }

    function getCurrentStakedAmount()
        external
        view
        returns (uint64 currentStakedEvai)
    {

        return currentStakedEvaiAmount;
    }

    function getMyStakes() external view returns (uint32[] memory) {

        return stakeByOwnerAddress[msg.sender];
    }

    function getStakeDetailsByStakeID(uint32 _stakeID)
        external
        view
        returns (stake memory)
    {

        require(
            msg.sender == owner ||
                msg.sender == stakeByID[_stakeID].ownerAddress,
            "Unauthorized User."
        );
        return stakeByID[_stakeID];
    }

    function addStakeType(
        bool _active,
        uint80 _percentageReturn,
        uint80 _bonusTerm,
        uint80 _bonusMultiplier,
        uint128 _minAmount,
        uint128 _maxAmount
    ) external onlyOwner {

        currentStakeType += 1;
        stakeTypes[currentStakeType].Type = currentStakeType;
        stakeTypes[currentStakeType].active = _active;
        stakeTypes[currentStakeType].percentageReturn = _percentageReturn;
        stakeTypes[currentStakeType].bonusTerm = _bonusTerm;
        stakeTypes[currentStakeType].bonusMultiplier = _bonusMultiplier;
        stakeTypes[currentStakeType].minAmount = _minAmount;
        stakeTypes[currentStakeType].maxAmount = _maxAmount;
        stakeTypeAlreadyExists[currentStakeType] = true;
    }

    function updateStakeType(
        uint8 _stakeType,
        bool _active,
        uint80 _percentageReturn,
        uint80 _bonusTerm,
        uint80 _bonusMultiplier,
        uint128 _minAmount,
        uint128 _maxAmount
    ) external onlyOwner {

        require(
            stakeTypeAlreadyExists[_stakeType] == true,
            "This stakeType doesn't exists"
        );
        stakeTypes[currentStakeType].active = _active;
        stakeTypes[_stakeType].percentageReturn = _percentageReturn;
        stakeTypes[_stakeType].bonusTerm = _bonusTerm;
        stakeTypes[currentStakeType].bonusMultiplier = _bonusMultiplier;
        stakeTypes[_stakeType].minAmount = _minAmount;
        stakeTypes[_stakeType].maxAmount = _maxAmount;
    }

    function updateAcceptingStakes(bool _acceptingStakes) external onlyOwner {

        acceptingStakes = _acceptingStakes;
        if (_acceptingStakes == false) {
            acceptingStakesEndTime = uint32(block.timestamp);
        } else {
            acceptingStakesEndTime = 0;
        }
    }

    function claimToInvest() external onlyOwner {

        evaiToken.approve(address(this), evaiToken.balanceOf(address(this)));
        evaiToken.transfer(owner, evaiToken.balanceOf(address(this)));
    }

    function evaisetStakeAttributesAndUpdateGlobalVariables(
        uint64 _amount,
        uint8 _type,
        uint32 _ID
    ) private {

        stakeByID[_ID].active = true;
        stakeByID[_ID].Type = _type;
        stakeByID[_ID].ownerAddress = msg.sender;
        stakeByID[_ID].startOfTerm = uint32(block.timestamp);
        stakeByID[_ID].id = currentStakeID;
        stakeByID[_ID].evaiAmount = _amount;
        stakeByOwnerAddress[msg.sender].push(_ID);
        totalStakedEvaiAmount += _amount;
        currentStakedEvaiAmount += _amount;
    }

    function emitWithdrawStake(uint32 _stakeID) private {

        stakeByID[_stakeID].endOfTerm = uint32(block.timestamp);
        emit WithdrawStake(
            stakeByID[_stakeID].active,
            stakeByID[_stakeID].partialWithdrawn,
            stakeByID[_stakeID].settled,
            _stakeID,
            stakeByID[_stakeID].endOfTerm,
            stakeByID[_stakeID].settlementAmount
        );
    }

    function addStake(uint64 _amount, uint8 _type) external nonReentrant {

        require(acceptingStakes, "Can't add a stake at this time, contract disabled for maintenance");
        require(
            stakeTypes[_type].active,
            "Can't add a stake with the provided stakeType"
        );
        require(stakeTypeAlreadyExists[_type], "The Stake type doesn't exist");

        require(
            _amount >= stakeTypes[_type].minAmount &&
                _amount <= stakeTypes[_type].maxAmount,
            "Staked amount is more than maximum amount specified for the stake"
        );

        require(
            evaiToken.balanceOf(msg.sender) >= _amount,
            "Insufficient Evai Balance. Please buy more EVAI Tokens."
        );
        currentStakeID += 1;
        evaisetStakeAttributesAndUpdateGlobalVariables(
            _amount,
            _type,
            currentStakeID
        );
        evaiToken.transferFrom(msg.sender, address(this), _amount);

        emit AddStake(
            _type,
            stakeByID[currentStakeID].ownerAddress,
            stakeByID[currentStakeID].startOfTerm,
            stakeByID[currentStakeID].id,
            stakeByID[currentStakeID].evaiAmount
        );
    }

    function reStake(
        uint64 _amount,
        uint8 _type,
        uint32 _linkedStakeID
    ) internal {

        require(stakeTypeAlreadyExists[_type], "The Stake type doesn't exist");
        currentStakeID += 1;
        evaisetStakeAttributesAndUpdateGlobalVariables(
            _amount,
            _type,
            currentStakeID
        );
        stakeByID[currentStakeID].linkedStakeID = _linkedStakeID;

        emit ReStake(
            _type,
            stakeByID[currentStakeID].ownerAddress,
            stakeByID[currentStakeID].startOfTerm,
            stakeByID[currentStakeID].id,
            stakeByID[currentStakeID].evaiAmount,
            stakeByID[currentStakeID].linkedStakeID
        );
    }

    function withdraw(
        uint32 _stakeID,
        bool _full,
        uint64 _withdrawAmount
    ) external nonReentrant {

        require(
            stakeByID[_stakeID].ownerAddress == msg.sender,
            "Unauthorized Stake owner"
        );
        require(stakeByID[_stakeID].active == true, "Stake was settled");
        uint256 elapsedTime = BokkyPooBahsDateTimeLibrary.diffDays(
            uint256(stakeByID[_stakeID].startOfTerm),
            uint256(block.timestamp)
        );
        uint256 totalReturns;
        uint256 stakeReturns;
        uint256 rewardEndTime;
        if (elapsedTime < stakeTypes[stakeByID[_stakeID].Type].bonusTerm) {
            totalReturns = compound(
                (stakeByID[_stakeID].evaiAmount),
                (stakeTypes[stakeByID[_stakeID].Type].percentageReturn),
                elapsedTime
            );
            stakeReturns = totalReturns - stakeByID[_stakeID].evaiAmount;
        } else if (
            elapsedTime == stakeTypes[stakeByID[_stakeID].Type].bonusTerm
        ) {
            totalReturns = (stakeByID[_stakeID].evaiAmount *
                (stakeTypes[stakeByID[_stakeID].Type].bonusMultiplier));
            stakeReturns = totalReturns - (stakeByID[_stakeID].evaiAmount);
        } else if (
            elapsedTime > stakeTypes[stakeByID[_stakeID].Type].bonusTerm
        ) {
            uint256 daysForYearInProgress = elapsedTime.mod(
                uint256(stakeTypes[stakeByID[_stakeID].Type].bonusTerm)
            );
            uint256 completedYears = (elapsedTime.sub(daysForYearInProgress))
                .div(uint256(stakeTypes[stakeByID[_stakeID].Type].bonusTerm));

            rewardEndTime = BokkyPooBahsDateTimeLibrary.addDays(
                uint256(stakeByID[_stakeID].startOfTerm),
                uint256(
                    (completedYears + 1) *
                        uint256(stakeTypes[stakeByID[_stakeID].Type].bonusTerm)
                )
            );

            if (rewardEndTime < uint256(block.timestamp)) {
                elapsedTime = BokkyPooBahsDateTimeLibrary.diffDays(
                    uint256(stakeByID[_stakeID].startOfTerm),
                    rewardEndTime
                );

                daysForYearInProgress = elapsedTime.mod(
                    uint256(stakeTypes[stakeByID[_stakeID].Type].bonusTerm)
                );
                completedYears = (elapsedTime.sub(daysForYearInProgress)).div(
                    uint256(stakeTypes[stakeByID[_stakeID].Type].bonusTerm)
                );
            }

            uint256 bMul = uint256(
                stakeTypes[stakeByID[_stakeID].Type].bonusMultiplier
            );

            uint256 postBonusBalance = calculatePostBonusBalance(
                uint256(stakeByID[_stakeID].evaiAmount),
                completedYears,
                bMul
            );

            uint256 pReturns = stakeTypes[stakeByID[_stakeID].Type]
                .percentageReturn;

            totalReturns = compound(
                postBonusBalance,
                pReturns,
                daysForYearInProgress
            );
            stakeReturns = totalReturns - (stakeByID[_stakeID].evaiAmount);
        }

        if (_full == true) {
            stakeByID[_stakeID].partialWithdrawn = false;
            stakeByID[_stakeID].settlementAmount = uint64(totalReturns);
            stakeByID[_stakeID].stakeReturns = uint64(stakeReturns);
        } else {
            require(
                _withdrawAmount <= uint64(totalReturns),
                "Amount to claim is higher than returns"
            );
            stakeByID[_stakeID].settlementAmount = _withdrawAmount;
        }

        if (
            _full == true &&
            stakeByID[_stakeID].settlementAmount <=
            evaiToken.balanceOf(address(this))
        ) {
            currentStakedEvaiAmount -= stakeByID[_stakeID].evaiAmount;
            totalProfitsDistrubuted += stakeByID[_stakeID].stakeReturns;
            stakeByID[_stakeID].active = false;
            stakeByID[_stakeID].settled = true;
            evaiTransfer(_stakeID);
            emitWithdrawStake(_stakeID);
        } else if (
            _full == true &&
            stakeByID[_stakeID].settlementAmount >=
            evaiToken.balanceOf(address(this))
        ) {
            stakeByID[_stakeID].active = false;
            emitWithdrawStake(_stakeID);
        } else if (
            _full == false &&
            stakeByID[_stakeID].settlementAmount <=
            evaiToken.balanceOf(address(this))
        ) {
            currentStakedEvaiAmount -= stakeByID[_stakeID].evaiAmount;
            stakeByID[_stakeID].active = false;
            stakeByID[_stakeID].partialWithdrawn = true;
            stakeByID[_stakeID].settled = true;
            evaiTransfer(_stakeID);
            emitWithdrawStake(_stakeID);
            uint8 Type = stakeByID[_stakeID].Type;
            uint256 reStakeAmount = totalReturns -
                (stakeByID[_stakeID].settlementAmount);
            reStake(uint64(reStakeAmount), Type, _stakeID);
        } else if (
            _full == false &&
            stakeByID[_stakeID].settlementAmount >=
            evaiToken.balanceOf(address(this))
        ) {
            stakeByID[_stakeID].active = false;
            stakeByID[_stakeID].partialWithdrawn = true;
            emitWithdrawStake(_stakeID);
        }
    }

    function compound(
        uint256 principal,
        uint256 ratio,
        uint256 n
    ) public pure returns (uint256) {

        return
            ABDKMath64x64.mulu(
                ABDKMath64x64.pow(
                    ABDKMath64x64.add(
                        ABDKMath64x64.fromUInt(1),
                        ABDKMath64x64.divu(ratio, 100 * 10**6)
                    ),
                    n
                ),
                principal
            );
    }

    function calculatePostBonusBalance(
        uint256 amount,
        uint256 completedYears,
        uint256 bonusMultiplier
    ) public pure returns (uint256) {

        return
            compound(amount, ((bonusMultiplier - 10**6) * 100), completedYears);
    }

    function settleStakes(uint32[] memory _stakeIDs) external onlyOwner {

        for (uint256 i = 0; i < _stakeIDs.length; i++) {
            if (
                stakeByID[_stakeIDs[i]].active == true &&
                stakeByID[_stakeIDs[i]].partialWithdrawn == false
            ) {
                currentStakedEvaiAmount -= stakeByID[_stakeIDs[i]]
                    .settlementAmount;
                stakeByID[_stakeIDs[i]].active = false;
                stakeByID[_stakeIDs[i]].settled = true;

                evaiToken.approve(
                    stakeByID[_stakeIDs[i]].ownerAddress,
                    stakeByID[_stakeIDs[i]].settlementAmount
                );

                evaiToken.transfer(
                    stakeByID[_stakeIDs[i]].ownerAddress,
                    stakeByID[_stakeIDs[i]].settlementAmount
                );
            }
        }
    }
}