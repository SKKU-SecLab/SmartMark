pragma solidity ^0.6.6;


library SafeMath {

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
}
pragma solidity ^0.6.6;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.6.6;


abstract contract ERC20 is IERC20 {
    using SafeMath for uint256;
    
    uint256 private _totalSupply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    function name() public view virtual returns(string memory);
    function symbol() public view virtual returns(string memory);
    function decimals() public view virtual returns(uint8);

    function totalSupply() public view override returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns(uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns(uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public override returns(bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns(bool) {
        _approveAction(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        _transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns(bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public returns(bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(amount));
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public returns(bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        _transferAction(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        _approveAction(owner, spender, amount);
    }
    
    function _burnFrom(address account, uint256 amount) internal {
        _approveAction(account, msg.sender, _allowances[account][msg.sender].sub(amount));
        _burnAction(account, amount);
    }

    function _transferAction(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20::_transferAction: Invalid sender");
        require(recipient != address(0), "ERC20::_transferAction: Invalid recipient");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(sender, recipient, amount);
    }
    
    function _approveAction(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20::_approveAction: Invalid owner");
        require(spender != address(0), "ERC20::_approveAction: Invalid spender");

        _allowances[owner][spender] = amount;
        
        emit Approval(owner, spender, amount);
    }
    
    function _mintAction(address account, uint256 amount) internal {
        require(account != address(0), "ERC20::_mintAction: Invalid account");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        
        emit Transfer(address(0), account, amount);
    }

    function _burnAction(address account, uint256 amount) internal {
        require(account != address(0), "ERC20::_burnAction: Invalid account");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        
        emit Transfer(account, address(0), amount);
    }
}    
pragma solidity ^0.6.6;


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
pragma solidity ^0.6.6;


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
}
pragma solidity ^0.6.6;


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
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}
pragma solidity ^0.6.6;


library ACONameFormatter {

    
    function formatNumber(uint256 value, uint8 decimals) internal pure returns(string memory) {

        uint256 digits;
        uint256 count;
        bool foundRepresentativeDigit = false;
        uint256 addPointAt = 0;
        uint256 temp = value;
        uint256 number = value;
        while (temp != 0) {
            if (!foundRepresentativeDigit && (temp % 10 != 0 || count == uint256(decimals))) {
                foundRepresentativeDigit = true;
                number = temp;
            }
            if (foundRepresentativeDigit) {
                if (count == uint256(decimals)) {
                    addPointAt = digits;
                }
                digits++;
            }
            temp /= 10;
            count++;
        }
        if (count <= uint256(decimals)) {
            digits = digits + 2 + uint256(decimals) - count;
            addPointAt = digits - 2;
        } else if (addPointAt > 0) {
            digits++;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = number;
        for (uint256 i = 0; i < digits; ++i) {
            if (i > 0 && i == addPointAt) {
                buffer[index--] = byte(".");
            } else if (number == 0) {
                buffer[index--] = byte("0");
            } else {
                buffer[index--] = byte(uint8(48 + number % 10));
                number /= 10;
            }
        }
        return string(buffer);
    }
    
    function formatTime(uint256 unixTime) internal pure returns(string memory) {

        (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute,) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(unixTime); 
        return string(abi.encodePacked(
            _getDateNumberWithTwoCharacters(day),
            _getMonthFormatted(month),
            _getYearFormatted(year),
            "-",
            _getDateNumberWithTwoCharacters(hour),
            _getDateNumberWithTwoCharacters(minute),
            "UTC"
            )); 
    }
    
    function formatType(bool isCall) internal pure returns(string memory) {

        if (isCall) {
            return "C";
        } else {
            return "P";
        }
    }
    
    function _getYearFormatted(uint256 year) private pure returns(string memory) {

        bytes memory yearBytes = bytes(Strings.toString(year));
        bytes memory result = new bytes(2);
        uint256 startIndex = yearBytes.length - 2;
        for (uint256 i = startIndex; i < yearBytes.length; i++) {
            result[i - startIndex] = yearBytes[i];
        }
        return string(result);
    }
    
    function _getMonthFormatted(uint256 month) private pure returns(string memory) {

        if (month == 1) {
            return "JAN";
        } else if (month == 2) {
            return "FEB";
        } else if (month == 3) {
            return "MAR";
        } else if (month == 4) {
            return "APR";
        } else if (month == 5) {
            return "MAY";
        } else if (month == 6) {
            return "JUN";
        } else if (month == 7) {
            return "JUL";
        } else if (month == 8) {
            return "AUG";
        } else if (month == 9) {
            return "SEP";
        } else if (month == 10) {
            return "OCT";
        } else if (month == 11) {
            return "NOV";
        } else if (month == 12) {
            return "DEC";
        } else {
            return "INVALID";
        }
    }
    
    function _getDateNumberWithTwoCharacters(uint256 number) private pure returns(string memory) {

        string memory _string = Strings.toString(number);
        if (number < 10) {
            return string(abi.encodePacked("0", _string));
        } else {
            return _string;
        }
    }
}pragma solidity ^0.6.6;


contract ACOToken is ERC20 {

    using Address for address;
    
    struct TokenCollateralized {
        uint256 amount;
        
        uint256 index;
    }
    
    event CollateralDeposit(address indexed account, uint256 amount);
    
    event CollateralWithdraw(address indexed account, address indexed recipient, uint256 amount, uint256 fee);
    
    event Assigned(address indexed from, address indexed to, uint256 paidAmount, uint256 tokenAmount);

    event TransferCollateralOwnership(address indexed from, address indexed to, uint256 tokenCollateralizedAmount);

    address public underlying;
    
    address public strikeAsset;
    
    address payable public feeDestination;
    
    bool public isCall;
    
    uint256 public strikePrice;
    
    uint256 public expiryTime;
    
    uint256 public totalCollateral;
    
    uint256 public acoFee;
    
    string public underlyingSymbol;
    
    string public strikeAssetSymbol;
    
    uint8 public underlyingDecimals;
    
    uint8 public strikeAssetDecimals;
    
    uint256 public maxExercisedAccounts;
    
    uint256 internal underlyingPrecision;
    
    mapping(address => TokenCollateralized) internal tokenData;
    
    address[] internal _collateralOwners;
    
    bool internal _notEntered;
    
    bytes4 internal _transferSelector;
    
    bytes4 internal _transferFromSelector;
    
    modifier notExpired() {

        require(_notExpired(), "ACOToken::Expired");
        _;
    }
    
    modifier nonReentrant() {

        require(_notEntered, "ACOToken::Reentry");
        _notEntered = false;
        _;
        _notEntered = true;
    }
    
    function init(
        address _underlying,
        address _strikeAsset,
        bool _isCall,
        uint256 _strikePrice,
        uint256 _expiryTime,
        uint256 _acoFee,
        address payable _feeDestination,
        uint256 _maxExercisedAccounts
    ) public {

        require(underlying == address(0) && strikeAsset == address(0) && strikePrice == 0, "ACOToken::init: Already initialized");
        
        require(_expiryTime > now, "ACOToken::init: Invalid expiry");
        require(_strikePrice > 0, "ACOToken::init: Invalid strike price");
        require(_underlying != _strikeAsset, "ACOToken::init: Same assets");
        require(_acoFee <= 500, "ACOToken::init: Invalid ACO fee"); // Maximum is 0.5%
        require(_isEther(_underlying) || _underlying.isContract(), "ACOToken::init: Invalid underlying");
        require(_isEther(_strikeAsset) || _strikeAsset.isContract(), "ACOToken::init: Invalid strike asset");
        require(_maxExercisedAccounts >= 25 && _maxExercisedAccounts <= 150, "ACOToken::init: Invalid number to max exercised accounts");
        
        underlying = _underlying;
        strikeAsset = _strikeAsset;
        isCall = _isCall;
        strikePrice = _strikePrice;
        expiryTime = _expiryTime;
        acoFee = _acoFee;
        feeDestination = _feeDestination;
        maxExercisedAccounts = _maxExercisedAccounts;
        underlyingDecimals = _getAssetDecimals(_underlying);
        require(underlyingDecimals < 78, "ACOToken::init: Invalid underlying decimals");
        strikeAssetDecimals = _getAssetDecimals(_strikeAsset);
        underlyingSymbol = _getAssetSymbol(_underlying);
        strikeAssetSymbol = _getAssetSymbol(_strikeAsset);
        underlyingPrecision = 10 ** uint256(underlyingDecimals);

        _transferSelector = bytes4(keccak256(bytes("transfer(address,uint256)")));
        _transferFromSelector = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
        _notEntered = true;
    }
    
    receive() external payable {
        revert();
    }
    
    function name() public view override returns(string memory) {

        return _name();
    }
    
    function symbol() public view override returns(string memory) {

        return _name();
    }
    
    function decimals() public view override returns(uint8) {

        return underlyingDecimals;
    }
    
    function currentCollateral(address account) public view returns(uint256) {

        return getCollateralAmount(currentCollateralizedTokens(account));
    }
    
    function unassignableCollateral(address account) public view returns(uint256) {

        return getCollateralAmount(unassignableTokens(account));
    }
    
    function assignableCollateral(address account) public view returns(uint256) {

        return getCollateralAmount(assignableTokens(account));
    }
    
    function currentCollateralizedTokens(address account) public view returns(uint256) {

        return tokenData[account].amount;
    }
    
    function unassignableTokens(address account) public view returns(uint256) {

        if (balanceOf(account) > tokenData[account].amount || !_notExpired()) {
            return tokenData[account].amount;
        } else {
            return balanceOf(account);
        }
    }
    
    function assignableTokens(address account) public view returns(uint256) {

        if (_notExpired()) {
            return _getAssignableAmount(account);
        } else {
            return 0;
        }
    }
    
    function getCollateralAmount(uint256 tokenAmount) public view returns(uint256) {

        if (isCall) {
            return tokenAmount;
        } else if (tokenAmount > 0) {
            return _getTokenStrikePriceRelation(tokenAmount);
        } else {
            return 0;
        }
    }
    
    function getTokenAmount(uint256 collateralAmount) public view returns(uint256) {

        if (isCall) {
            return collateralAmount;
        } else if (collateralAmount > 0) {
            return collateralAmount.mul(underlyingPrecision).div(strikePrice);
        } else {
            return 0;
        }
    }

    function numberOfAccountsWithCollateral() public view returns(uint256) {

        return _collateralOwners.length;
    }
    
    function getBaseExerciseData(uint256 tokenAmount) public view returns(address, uint256) {

        if (isCall) {
            return (strikeAsset, _getTokenStrikePriceRelation(tokenAmount)); 
        } else {
            return (underlying, tokenAmount);
        }
    }
    
    function getCollateralOnExercise(uint256 tokenAmount) public view returns(uint256, uint256) {

        uint256 collateralAmount = getCollateralAmount(tokenAmount);
        uint256 fee = collateralAmount.mul(acoFee).div(100000);
        collateralAmount = collateralAmount.sub(fee);
        return (collateralAmount, fee);
    }
    
    function collateral() public view returns(address) {

        if (isCall) {
            return underlying;
        } else {
            return strikeAsset;
        }
    }
    
    function mintPayable() external payable returns(uint256) {

        require(_isEther(collateral()), "ACOToken::mintPayable: Invalid call");
        return _mintToken(msg.sender, msg.value);
    }
    
    function mintToPayable(address account) external payable returns(uint256) {

        require(_isEther(collateral()), "ACOToken::mintToPayable: Invalid call");
       return _mintToken(account, msg.value);
    }
    
    function mint(uint256 collateralAmount) external returns(uint256) {

        address _collateral = collateral();
        require(!_isEther(_collateral), "ACOToken::mint: Invalid call");
        
        _transferFromERC20(_collateral, msg.sender, address(this), collateralAmount);
        return _mintToken(msg.sender, collateralAmount);
    }
    
    function mintTo(address account, uint256 collateralAmount) external returns(uint256) {

        address _collateral = collateral();
        require(!_isEther(_collateral), "ACOToken::mintTo: Invalid call");
        
        _transferFromERC20(_collateral, msg.sender, address(this), collateralAmount);
        return _mintToken(account, collateralAmount);
    }
    
    function burn(uint256 tokenAmount) external returns(uint256) {

        return _burn(msg.sender, tokenAmount);
    }
    
    function burnFrom(address account, uint256 tokenAmount) external returns(uint256) {

        return _burn(account, tokenAmount);
    }
    
    function redeem() external returns(uint256) {

        return _redeem(msg.sender);
    }
    
    function redeemFrom(address account) external returns(uint256) {

        require(tokenData[account].amount <= allowance(account, msg.sender), "ACOToken::redeemFrom: Allowance too low");
        return _redeem(account);
    }
    
    function exercise(uint256 tokenAmount, uint256 salt) external payable returns(uint256) {

        return _exercise(msg.sender, tokenAmount, salt);
    }
    
    function exerciseFrom(address account, uint256 tokenAmount, uint256 salt) external payable returns(uint256) {

        return _exercise(account, tokenAmount, salt);
    }
    
    function exerciseAccounts(uint256 tokenAmount, address[] calldata accounts) external payable returns(uint256) {

        return _exerciseFromAccounts(msg.sender, tokenAmount, accounts);
    }

    function transferCollateralOwnership(address recipient, uint256 tokenCollateralizedAmount) external {

        require(recipient != address(0), "ACOToken::transferCollateralOwnership: Invalid recipient");
        require(tokenCollateralizedAmount > 0, "ACOToken::transferCollateralOwnership: Invalid amount");

        TokenCollateralized storage senderData = tokenData[msg.sender];
        senderData.amount = senderData.amount.sub(tokenCollateralizedAmount);

        _removeCollateralDataIfNecessary(msg.sender);

        TokenCollateralized storage recipientData = tokenData[recipient];
        if (_hasCollateral(recipientData)) {
            recipientData.amount = recipientData.amount.add(tokenCollateralizedAmount);
        } else {
            tokenData[recipient] = TokenCollateralized(tokenCollateralizedAmount, _collateralOwners.length);
            _collateralOwners.push(recipient);
        }

        emit TransferCollateralOwnership(msg.sender, recipient, tokenCollateralizedAmount);
    }
    
    function exerciseAccountsFrom(address account, uint256 tokenAmount, address[] calldata accounts) external payable returns(uint256) {

        return _exerciseFromAccounts(account, tokenAmount, accounts);
    }
    
    function _redeemCollateral(address account, uint256 tokenAmount) internal returns(uint256) {

        require(_accountHasCollateral(account), "ACOToken::_redeemCollateral: No collateral available");
        require(tokenAmount > 0, "ACOToken::_redeemCollateral: Invalid token amount");
        
        TokenCollateralized storage data = tokenData[account];
        data.amount = data.amount.sub(tokenAmount);
        
        _removeCollateralDataIfNecessary(account);
        
        return _transferCollateral(account, getCollateralAmount(tokenAmount), 0);
    }
    
    function _mintToken(address account, uint256 collateralAmount) nonReentrant notExpired internal returns(uint256) {

        require(collateralAmount > 0, "ACOToken::_mintToken: Invalid collateral amount");
        
        if (!_accountHasCollateral(account)) {
            tokenData[account].index = _collateralOwners.length;
            _collateralOwners.push(account);
        }
        
        uint256 tokenAmount = getTokenAmount(collateralAmount);
        require(tokenAmount != 0, "ACOToken::_mintToken: Invalid token amount");
        tokenData[account].amount = tokenData[account].amount.add(tokenAmount);
        
        totalCollateral = totalCollateral.add(collateralAmount);
        
        emit CollateralDeposit(account, collateralAmount);
        
        super._mintAction(msg.sender, tokenAmount);
        return tokenAmount;
    }
    
    function _transferCollateral(address account, uint256 collateralAmount, uint256 fee) internal returns(uint256) {

        
        totalCollateral = totalCollateral.sub(collateralAmount.add(fee));
        
        address _collateral = collateral();
        if (_isEther(_collateral)) {
            payable(msg.sender).transfer(collateralAmount);
            if (fee > 0) {
                feeDestination.transfer(fee);   
            }
        } else {
            _transferERC20(_collateral, msg.sender, collateralAmount);
            if (fee > 0) {
                _transferERC20(_collateral, feeDestination, fee);
            }
        }
        
        emit CollateralWithdraw(account, msg.sender, collateralAmount, fee);
        return collateralAmount;
    }
    
    function _exercise(address account, uint256 tokenAmount, uint256 salt) nonReentrant internal returns(uint256) {

        _validateAndBurn(account, tokenAmount, maxExercisedAccounts);
         _exerciseOwners(account, tokenAmount, salt);
        (uint256 collateralAmount, uint256 fee) = getCollateralOnExercise(tokenAmount);
        return _transferCollateral(account, collateralAmount, fee);
    }
    
    function _exerciseFromAccounts(address account, uint256 tokenAmount, address[] memory accounts) nonReentrant internal returns(uint256) {

        _validateAndBurn(account, tokenAmount, accounts.length);
        _exerciseAccounts(account, tokenAmount, accounts);
        (uint256 collateralAmount, uint256 fee) = getCollateralOnExercise(tokenAmount);
        return _transferCollateral(account, collateralAmount, fee);
    }
    
    function _exerciseOwners(address exerciseAccount, uint256 tokenAmount, uint256 salt) internal {

        uint256 accountsExercised = 0;
        uint256 start = salt.mod(_collateralOwners.length);
        uint256 index = start;
        uint256 count = 0;
        while (tokenAmount > 0 && count < _collateralOwners.length) {
            
            uint256 remainingAmount = _exerciseAccount(_collateralOwners[index], tokenAmount, exerciseAccount);
            if (remainingAmount < tokenAmount) {
                accountsExercised++;
                require(accountsExercised < maxExercisedAccounts || remainingAmount == 0, "ACOToken::_exerciseOwners: Too many accounts to exercise");
            }
            tokenAmount = remainingAmount;
            
            ++index;
            if (index == _collateralOwners.length) {
                index = 0;
            }
            ++count;
        }
        require(tokenAmount == 0, "ACOToken::_exerciseOwners: Invalid remaining amount");
        
        uint256 indexOnModifyIteration;
        bool shouldModifyIteration = false;
        if (index == 0) {
            index = _collateralOwners.length;
        } else if (index <= start) {
            indexOnModifyIteration = index - 1;
            shouldModifyIteration = true;
            index = _collateralOwners.length;
        }
            
        for (uint256 i = 0; i < count; ++i) {
            --index;
            if (shouldModifyIteration && index < start) {
                index = indexOnModifyIteration;
                shouldModifyIteration = false;
            }
            _removeCollateralDataIfNecessary(_collateralOwners[index]);
        }
    }
    
    function _exerciseAccounts(address exerciseAccount, uint256 tokenAmount, address[] memory accounts) internal {

        for (uint256 i = 0; i < accounts.length; ++i) {
            if (tokenAmount == 0) {
                break;
            }
            tokenAmount = _exerciseAccount(accounts[i], tokenAmount, exerciseAccount);
            _removeCollateralDataIfNecessary(accounts[i]);
        }
        require(tokenAmount == 0, "ACOToken::_exerciseAccounts: Invalid remaining amount");
    }
    
    function _exerciseAccount(address account, uint256 tokenAmount, address exerciseAccount) internal returns(uint256) {

        uint256 available = _getAssignableAmount(account);
        if (available > 0) {
            
            TokenCollateralized storage data = tokenData[account];
            uint256 valueToTransfer;
            if (available < tokenAmount) {
                valueToTransfer = available;
                tokenAmount = tokenAmount.sub(available);
            } else {
                valueToTransfer = tokenAmount;
                tokenAmount = 0;
            }
            
            (address exerciseAsset, uint256 amount) = getBaseExerciseData(valueToTransfer);
            amount = amount.add(1);
            
            data.amount = data.amount.sub(valueToTransfer); 
            
            if (_isEther(exerciseAsset)) {
                payable(account).transfer(amount);
            } else {
                _transferERC20(exerciseAsset, account, amount);
            }
            emit Assigned(account, exerciseAccount, amount, valueToTransfer);
        }
        return tokenAmount;
    }
    
    function _validateAndBurn(address account, uint256 tokenAmount, uint256 maximumNumberOfAccounts) notExpired internal {

        require(tokenAmount > 0, "ACOToken::_validateAndBurn: Invalid token amount");
        
        if (_accountHasCollateral(account)) {
            require(tokenAmount <= balanceOf(account).sub(tokenData[account].amount), "ACOToken::_validateAndBurn: Token amount not available"); 
        }
        
        _callBurn(account, tokenAmount);
        
        (address exerciseAsset, uint256 expectedAmount) = getBaseExerciseData(tokenAmount);
        expectedAmount = expectedAmount.add(maximumNumberOfAccounts);

        if (_isEther(exerciseAsset)) {
            require(msg.value == expectedAmount, "ACOToken::_validateAndBurn: Invalid ether amount");
        } else {
            require(msg.value == 0, "ACOToken::_validateAndBurn: No ether expected");
            _transferFromERC20(exerciseAsset, msg.sender, address(this), expectedAmount);
        }
    }
    
    function _getTokenStrikePriceRelation(uint256 tokenAmount) internal view returns(uint256) {

        return tokenAmount.mul(strikePrice).div(underlyingPrecision);
    }
    
    function _redeem(address account) nonReentrant internal returns(uint256) {

        require(!_notExpired(), "ACOToken::_redeem: Token not expired yet");
        
        uint256 collateralAmount = _redeemCollateral(account, tokenData[account].amount);
        super._burnAction(account, balanceOf(account));
        return collateralAmount;
    }
    
    function _burn(address account, uint256 tokenAmount) nonReentrant notExpired internal returns(uint256) {

        uint256 collateralAmount = _redeemCollateral(account, tokenAmount);
        _callBurn(account, tokenAmount);
        return collateralAmount;
    }
    
    function _callBurn(address account, uint256 tokenAmount) internal {

        if (account == msg.sender) {
            super._burnAction(account, tokenAmount);
        } else {
            super._burnFrom(account, tokenAmount);
        }
    }
    
    function _getAssignableAmount(address account) internal view returns(uint256) {

        if (tokenData[account].amount > balanceOf(account)) {
            return tokenData[account].amount.sub(balanceOf(account));
        } else {
            return 0;
        }
    }
    
    function _removeCollateralDataIfNecessary(address account) internal {

        TokenCollateralized storage data = tokenData[account];
        if (!_hasCollateral(data)) {
            uint256 lastIndex = _collateralOwners.length - 1;
            if (lastIndex != data.index) {
                address last = _collateralOwners[lastIndex];
                tokenData[last].index = data.index;
                _collateralOwners[data.index] = last;
            }
            _collateralOwners.pop();
            delete tokenData[account];
        }
    }
    
    function _notExpired() internal view returns(bool) {

        return now < expiryTime;
    }
    
    function _accountHasCollateral(address account) internal view returns(bool) {

        return _hasCollateral(tokenData[account]);
    }
    
    function _hasCollateral(TokenCollateralized storage data) internal view returns(bool) {

        return data.amount > 0;
    }
    
    function _isEther(address _address) internal pure returns(bool) {

        return _address == address(0);
    } 
    
    function _name() internal view returns(string memory) {

        return string(abi.encodePacked(
            "ACO ",
            underlyingSymbol,
            "-",
            ACONameFormatter.formatNumber(strikePrice, strikeAssetDecimals),
            strikeAssetSymbol,
            "-",
            ACONameFormatter.formatType(isCall),
            "-",
            ACONameFormatter.formatTime(expiryTime)
        ));
    }
    
    function _getAssetDecimals(address asset) internal view returns(uint8) {

        if (_isEther(asset)) {
            return uint8(18);
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSignature("decimals()"));
            require(success, "ACOToken::_getAssetDecimals: Invalid asset decimals");
            return abi.decode(returndata, (uint8));
        }
    }
    
    function _getAssetSymbol(address asset) internal view returns(string memory) {

        if (_isEther(asset)) {
            return "ETH";
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSignature("symbol()"));
            require(success, "ACOToken::_getAssetSymbol: Invalid asset symbol");
            return abi.decode(returndata, (string));
        }
    }
    
     function _transferERC20(address token, address recipient, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(_transferSelector, recipient, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "ACOToken::_transferERC20");
    }
    
     function _transferFromERC20(address token, address sender, address recipient, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(_transferFromSelector, sender, recipient, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "ACOToken::_transferFromERC20");
    }
}
