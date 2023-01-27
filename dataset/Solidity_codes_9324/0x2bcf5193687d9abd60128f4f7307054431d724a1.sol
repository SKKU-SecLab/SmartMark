
pragma solidity ^0.4.24;


contract PeriodUtil {

    function getPeriodIdx(uint256 timestamp) public pure returns (uint256);

    
    function getPeriodStartTimestamp(uint256 periodIdx) public pure returns (uint256);


    function getPeriodCycle(uint256 timestamp) public pure returns (uint256);


    function getRatePerTimeUnits(uint256 tokens, uint256 periodIdx) public view returns (uint256);


    function getUnitsPerPeriod() public pure returns (uint256);

}


contract PeriodUtilWeek is PeriodUtil {

  
    uint256 public constant HOURS_IN_WEEK = 168;
    uint256 constant YEAR_IN_SECONDS = 31536000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint16 constant ORIGIN_YEAR = 1970;


    function getPeriodIdx(uint256 timestamp) public pure returns (uint256) {

        return timestamp / 1 weeks;
    }

    function getPeriodStartTimestamp(uint256 periodIdx) public pure returns (uint256) {

        assert(periodIdx < 50000);
        return 1 weeks * periodIdx;
    }

    function getPeriodCycle(uint256 timestamp) public pure returns (uint256) {

        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;
        
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
        
        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);
        
        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function leapYearsBefore(uint256 _year) public pure returns (uint256) {

        uint256 year = _year - 1;
        return year / 4 - year / 100 + year / 400;
    }

    function isLeapYear(uint16 year) public pure returns (bool) {

        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function getRatePerTimeUnits(uint256 tokens, uint256 periodIdx) public view returns (uint256) {

        if (tokens <= 0)
          return 0;
        uint256 hoursSinceTime = hoursSinceTimestamp(getPeriodStartTimestamp(periodIdx));
        return tokens / hoursSinceTime;
    }

    function hoursSinceTimestamp(uint256 timestamp) public view returns (uint256) {

        assert(now > timestamp);
        return (now - timestamp) / 1 hours;
    }

    function getUnitsPerPeriod() public pure returns (uint256) {

        return HOURS_IN_WEEK;
    }
}