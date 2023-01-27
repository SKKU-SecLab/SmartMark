
pragma solidity 0.5.10;

interface IMarketFactory {

    function deployMarket(
        uint256[] calldata _fundingGoals,
        uint256[] calldata _phaseDurations,
        address _creator,
        uint256 _curveType,
        uint256 _feeRate
    )
        external;


    function updateMoleculeVault(address _newMoleculeVault) external;


    function moleculeVault() external view returns(address);


    function marketRegistry() external view returns(address);


    function curveRegistry() external view returns(address);


    function collateralToken() external view returns(address);

}


interface IMarketRegistry {

    event MarketCreated(
		uint256 index,
		address indexed marketAddress,
		address indexed vault,
		address indexed creator
    );
    event DeployerAdded(address deployer, string version);
	event DeployerRemoved(address deployer, string reason);

    function addMarketDeployer(
      address _newDeployer,
      string calldata _version
    ) external;


    function removeMarketDeployer(
      address _deployerToRemove,
      string calldata _reason
    ) external;


    function registerMarket(
        address _marketAddress,
        address _vault,
        address _creator
    )
        external
        returns(uint256);


    function getMarket(uint256 _index)
        external
        view
        returns(
            address,
            address,
            address
        );


    function getIndex() external view returns(uint256);


    function isMarketDeployer(address _deployer) external view returns(bool);


    function publishedBlocknumber() external view returns(uint256);

}


interface ICurveRegistry {

    event CurveRegisterd(
        uint256 index,
        address indexed libraryAddress,
        string curveFunction
    );
    event CurveActivated(uint256 index, address indexed libraryAddress);
    event CurveDeactivated(uint256 index, address indexed libraryAddress);

    function registerCurve(
        address _libraryAddress,
        string calldata _curveFunction)
        external
        returns(uint256);


    function deactivateCurve(uint256 _index) external;


    function reactivateCurve(uint256 _index) external;


    function getCurveAddress(uint256 _index)
        external
        view
        returns(address);


    function getCurveData(uint256 _index)
        external
        view
        returns(
            address,
            string memory,
            bool
        );


    function getIndex()
        external
        view
        returns(uint256);


    function publishedBlocknumber() external view returns(uint256);

}

interface IMoleculeVault {


    function addAdmin(address _moleculeAdmin) external;

    
    function transfer(address _to, uint256 _amount) external;


    function approve(address _spender, uint256 _amount) external;


    function updateFeeRate(uint256 _newFeeRate) external returns(bool);


    function collateralToken() external view returns(address);


    function feeRate() external view returns(uint256);

}

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


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface IMarket {

    event Approval(
      address indexed owner,
      address indexed spender,
      uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint value);
    event Mint(
      address indexed to,			// The address reciving the tokens
      uint256 amountMinted,			// The amount of tokens minted
      uint256 collateralAmount,		// The amount of DAI spent
      uint256 researchContribution	// The tax donatedd (in DAI)
    );
    event Burn(
      address indexed from,			// The address burning the tokens
      uint256 amountBurnt,			// The amount of tokens burnt
      uint256 collateralReturned	//  DAI being recived (in DAI)
    );
    event MarketTerminated();

    function approve(address _spender, uint256 _value) external returns (bool);


    function burn(uint256 _numTokens) external returns(bool);


    function mint(address _to, uint256 _numTokens) external returns(bool);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
		address _from,
		address _to,
		uint256 _value
	)
		external
		returns(bool);


    function finaliseMarket() external returns(bool);


    function withdraw(uint256 _amount) external returns(bool);


    function priceToMint(uint256 _numTokens) external view returns(uint256);


    function rewardForBurn(uint256 _numTokens) external view returns(uint256);


    function collateralToTokenBuying(
		uint256 _collateralTokenOffered
	)
		external
		view
		returns(uint256);


    function collateralToTokenSelling(
		uint256 _collateralTokenNeeded
	)
		external
		view
		returns(uint256);


    function allowance(
		address _owner,
		address _spender
	)
		external
		view
		returns(uint256);


    function balanceOf(address _owner) external view returns (uint256);


    function poolBalance() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function feeRate() external view returns(uint256);


    function decimals() external view returns(uint256);


    function active() external view returns(bool);

}


interface IVault {

	enum FundingState { NOT_STARTED, STARTED, ENDED, PAID }
	event FundingWithdrawn(uint256 phase, uint256 amount);
	event PhaseFinalised(uint256 phase, uint256 amount);

    function initialize(address _market) external returns(bool);


    function withdraw() external returns(bool);


    function validateFunding(uint256 _receivedFunding) external returns(bool);


    function terminateMarket() external;


    function fundingPhase(
      uint256 _phase
    )
		external
		view
		returns(
			uint256,
			uint256,
			uint256,
			uint256,
			FundingState
		);


    function outstandingWithdraw() external view returns(uint256);


    function currentPhase() external view returns(uint256);


    function getTotalRounds() external view returns(uint256);


    function market() external view returns(address);


    function creator() external view returns(address);

}

interface ICurveFunctions {

    function curveIntegral(uint256 _x) external pure returns(uint256);


    function inverseCurveIntegral(uint256 _x) external pure returns(uint256);

}



library BokkyPooBahsDateTimeLibrary {


    uint256  constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256  constant SECONDS_PER_HOUR = 60 * 60;
    uint256  constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256  constant DOW_MON = 1;
    uint256  constant DOW_TUE = 2;
    uint256  constant DOW_WED = 3;
    uint256  constant DOW_THU = 4;
    uint256  constant DOW_FRI = 5;
    uint256  constant DOW_SAT = 6;
    uint256  constant DOW_SUN = 7;

    function _daysFromDate(uint256  year, uint256  month, uint256  day) internal pure returns (uint256  _days) {

        require(year >= 1970, "Epoch error");
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint256 (__days);
    }

    function _daysToDate(uint256  _days) internal pure returns (uint256  year, uint256  month, uint256  day) {

        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int256 _month = 80 * L / 2447;
        int256 _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256 (_year);
        month = uint256 (_month);
        day = uint256 (_day);
    }

    function timestampFromDate(uint256  year, uint256  month, uint256  day) internal pure returns (uint256  timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint256  year, uint256  month, uint256  day, uint256  hour, uint256  minute, uint256  second) internal pure returns (uint256  timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint256  timestamp) internal pure returns (uint256  year, uint256  month, uint256  day) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint256  timestamp) internal pure returns (uint256  year, uint256  month, uint256  day, uint256  hour, uint256  minute, uint256  second) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256  secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint256  year, uint256  month, uint256  day) internal pure returns (bool valid) {

        if (year >= 1970 && month > 0 && month <= 12) {
            uint256  daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint256  year, uint256  month, uint256  day, uint256  hour, uint256  minute, uint256  second) internal pure returns (bool valid) {

        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint256  timestamp) internal pure returns (bool leapYear) {

        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint256  year) internal pure returns (bool leapYear) {

        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint256  timestamp) internal pure returns (bool weekDay) {

        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint256  timestamp) internal pure returns (bool weekEnd) {

        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint256  timestamp) internal pure returns (uint256  daysInMonth) {

        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint256  year, uint256  month) internal pure returns (uint256  daysInMonth) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function getDayOfWeek(uint256  timestamp) internal pure returns (uint256  dayOfWeek) {

        uint256  _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint256  timestamp) internal pure returns (uint256  year) {

        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint256  timestamp) internal pure returns (uint256  month) {

        uint256  year;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint256  timestamp) internal pure returns (uint256  day) {

        uint256  year;
        uint256  month;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint256  timestamp) internal pure returns (uint256  hour) {

        uint256  secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint256  timestamp) internal pure returns (uint256  minute) {

        uint256  secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint256  timestamp) internal pure returns (uint256  second) {

        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256  timestamp, uint256  _years) internal pure returns (uint256  newTimestamp) {

        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256  daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        assert(newTimestamp >= timestamp);
    }
    function addMonths(uint256  timestamp, uint256  _months) internal pure returns (uint256  newTimestamp) {

        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint256  daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        assert(newTimestamp >= timestamp);
    }
    function addDays(uint256  timestamp, uint256  _days) internal pure returns (uint256  newTimestamp) {

        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        assert(newTimestamp >= timestamp);
    }
    function addHours(uint256  timestamp, uint256  _hours) internal pure returns (uint256  newTimestamp) {

        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        assert(newTimestamp >= timestamp);
    }
    function addMinutes(uint256  timestamp, uint256  _minutes) internal pure returns (uint256  newTimestamp) {

        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint256  timestamp, uint256  _seconds) internal pure returns (uint256  newTimestamp) {

        newTimestamp = timestamp + _seconds;
        assert(newTimestamp >= timestamp);
    }

    function subYears(uint256  timestamp, uint256  _years) internal pure returns (uint256  newTimestamp) {

        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256  daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        assert(newTimestamp <= timestamp);
    }
    function subMonths(uint256  timestamp, uint256  _months) internal pure returns (uint256  newTimestamp) {

        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256  yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint256  daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        assert(newTimestamp <= timestamp);
    }
    function subDays(uint256  timestamp, uint256  _days) internal pure returns (uint256  newTimestamp) {

        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        assert(newTimestamp <= timestamp);
    }
    function subHours(uint256  timestamp, uint256  _hours) internal pure returns (uint256  newTimestamp) {

        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        assert(newTimestamp <= timestamp);
    }
    function subMinutes(uint256  timestamp, uint256  _minutes) internal pure returns (uint256  newTimestamp) {

        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        assert(newTimestamp <= timestamp);
    }
    function subSeconds(uint256  timestamp, uint256  _seconds) internal pure returns (uint256  newTimestamp) {

        newTimestamp = timestamp - _seconds;
        assert(newTimestamp <= timestamp);
    }

    function diffYears(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _years) {

        require(fromTimestamp <= toTimestamp);
        uint256  fromYear;
        uint256  fromMonth;
        uint256  fromDay;
        uint256  toYear;
        uint256  toMonth;
        uint256  toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _months) {

        require(fromTimestamp <= toTimestamp);
        uint256  fromYear;
        uint256  fromMonth;
        uint256  fromDay;
        uint256  toYear;
        uint256  toMonth;
        uint256  toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _days) {

        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _hours) {

        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _minutes) {

        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _seconds) {

        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}






contract Market is IMarket, IERC20 {

    using SafeMath for uint256;

    bool internal active_ = true;
    IVault internal creatorVault_;
    uint256 internal feeRate_;
    ICurveFunctions internal curveLibrary_;
    IERC20 internal collateralToken_;
    uint256 internal totalSupply_;
    uint256 internal decimals_ = 18;

    mapping(address => mapping (address => uint256)) internal allowed;
    mapping(address => uint256) internal balances;

    constructor(
        uint256 _feeRate,
        address _creatorVault,
        address _curveLibrary,
        address _collateralToken
    )
        public
    {
        feeRate_ = _feeRate;
        creatorVault_ = IVault(_creatorVault);
        curveLibrary_ = ICurveFunctions(_curveLibrary);
        collateralToken_ = IERC20(_collateralToken);
    }

    modifier onlyActive(){

        require(active_, "Market inactive");
        _;
    }

    modifier onlyVault(){

        require(msg.sender == address(creatorVault_), "Invalid requestor");
        _;
    }

    function burn(uint256 _numTokens) external onlyActive() returns(bool) {

        require(
            balances[msg.sender] >= _numTokens,
            "Not enough tokens available"
        );

        uint256 reward = rewardForBurn(_numTokens);

        totalSupply_ = totalSupply_.sub(_numTokens);
        balances[msg.sender] = balances[msg.sender].sub(_numTokens);

        require(
            collateralToken_.transfer(
                msg.sender,
                reward
            ),
            "Tokens not sent"
        );

        emit Transfer(msg.sender, address(0), _numTokens);
        emit Burn(msg.sender, _numTokens, reward);
        return true;
    }

    function mint(
        address _to,
        uint256 _numTokens
    )
        external
        onlyActive()
        returns(bool)
    {

        uint256 priceForTokens = priceToMint(_numTokens);
        
        require(priceForTokens > 0, "Tokens requested too low");

        uint256 fee = priceForTokens.mul(feeRate_).div(100);
        require(
            collateralToken_.transferFrom(
                msg.sender,
                address(this),
                priceForTokens
            ),
            "Collateral transfer failed"
        );
        require(
            collateralToken_.transfer(
                address(creatorVault_),
                fee
            ),
            "Vault fee not transferred"
        );

        totalSupply_ = totalSupply_.add(_numTokens);
        balances[msg.sender] = balances[msg.sender].add(_numTokens);
        require(
            creatorVault_.validateFunding(fee),
            "Funding validation failed"
        );
        uint256 priceWithoutFee = priceForTokens.sub(fee);

        emit Transfer(address(0), _to, _numTokens);
        emit Mint(_to, _numTokens, priceWithoutFee, fee);
        return true;
    }

    function collateralToTokenBuying(
        uint256 _collateralTokenOffered
    )
        external
        view
        returns(uint256)
    {

        uint256 fee = _collateralTokenOffered.mul(feeRate_).div(100);
        uint256 amountLessFee = _collateralTokenOffered.sub(fee);
        return _inverseCurveIntegral(
                _curveIntegral(totalSupply_).add(amountLessFee)
            ).sub(totalSupply_);
    }

    function collateralToTokenSelling(
        uint256 _collateralTokenNeeded
    )
        external
        view
        returns(uint256)
    {

        return uint256(
            totalSupply_.sub(
                _inverseCurveIntegral(
                    _curveIntegral(totalSupply_).sub(_collateralTokenNeeded)
                )
            )
        );
    }

    function poolBalance() external view returns (uint256){

        return collateralToken_.balanceOf(address(this));
    }

    function feeRate() external view returns(uint256) {

        return feeRate_;
    }

    function decimals() external view returns(uint256) {

        return decimals_;
    }

    function active() external view returns(bool){

        return active_;
    }

    function finaliseMarket() public onlyVault() returns(bool) {

        require(active_, "Market deactivated");
        active_ = false;
        emit MarketTerminated();
        return true;
    }

    function withdraw(uint256 _amount) public returns(bool) {

        require(!active_, "Market not finalised");
        require(_amount <= balances[msg.sender], "Insufficient funds");
        require(_amount > 0, "Cannot withdraw 0");

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        uint256 balance = collateralToken_.balanceOf(address(this));

        uint256 collateralToTransfer = balance.mul(_amount).div(totalSupply_);
        totalSupply_ = totalSupply_.sub(_amount);

        require(
            collateralToken_.transfer(msg.sender, collateralToTransfer),
            "Dai transfer failed"
        );

        emit Transfer(msg.sender, address(0), _amount);
        emit Burn(msg.sender, _amount, collateralToTransfer);

        return true;
    }

    function priceToMint(uint256 _numTokens) public view returns(uint256) {

        uint256 balance = collateralToken_.balanceOf(address(this));
        uint256 collateral = _curveIntegral(
                totalSupply_.add(_numTokens)
            ).sub(balance);
        uint256 baseUnit = 100;
        uint256 result = collateral.mul(100).div(baseUnit.sub(feeRate_));
        return result;
    }

    function rewardForBurn(uint256 _numTokens) public view returns(uint256) {

        uint256 poolBalanceFetched = collateralToken_.balanceOf(address(this));
        return poolBalanceFetched.sub(
            _curveIntegral(totalSupply_.sub(_numTokens))
        );
    }

    function _curveIntegral(uint256 _x) internal view returns (uint256) {

        return curveLibrary_.curveIntegral(_x);
    }

    function _inverseCurveIntegral(uint256 _x) internal view returns(uint256) {

        return curveLibrary_.inverseCurveIntegral(_x);
    }


    function totalSupply() external view returns (uint256) {

        return totalSupply_;
    }

    function balanceOf(address _owner) external view returns (uint256) {

        return balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256)
    {

        return allowed[_owner][_spender];
    }

    function approve(
        address _spender,
        uint256 _value
    )
        external
        returns (bool)
    {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(
        address _spender,
        uint256 _addedValue
    )
        public
        returns(bool) 
    {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender]
            .add(_addedValue);
        emit Approval(msg.sender, _spender, _addedValue);
        return true;
    }

    function decreaseAllowance(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns(bool)
    {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender]
            .sub(_subtractedValue);
        emit Approval(msg.sender, _spender, _subtractedValue);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {

        require(_value <= balances[_from], "Requested amount exceeds balance");
        require(_value <= allowed[_from][msg.sender], "Allowance exceeded");
        require(_to != address(0), "Target account invalid");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_value <= balances[msg.sender], "Insufficient funds");
        require(_to != address(0), "Target account invalid");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}


contract ModifiedWhitelistAdminRole {

    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;
    uint8 internal noOfAdmins_;
    address internal initialAdmin_;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
        initialAdmin_ = msg.sender;
    }

    modifier onlyWhitelistAdmin() {

        require(
            isWhitelistAdmin(msg.sender), 
            "ModifiedWhitelistAdminRole: caller does not have the WhitelistAdmin role"
        );
        _;
    }

    modifier onlyInitialAdmin() {

        require(
            msg.sender == initialAdmin_,
            "Only initial admin may remove another admin"
        );
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin() {

        _addWhitelistAdmin(account);
    }

    function addNewInitialAdmin(address account) public onlyInitialAdmin() {

        if(!isWhitelistAdmin(account)) {
            _addWhitelistAdmin(account);
        }
        initialAdmin_ = account;
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(msg.sender);
    }

    function removeWhitelistAdmin(address account) public onlyInitialAdmin() {

        _removeWhitelistAdmin(account);
    }

    function _addWhitelistAdmin(address account) internal {

        if(!isWhitelistAdmin(account)) {
            noOfAdmins_ += 1;
        }
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {

        noOfAdmins_ -= 1;
        require(noOfAdmins_ >= 1, "Cannot remove all admins");
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    function getAdminCount() public view returns(uint8) {

        return noOfAdmins_;
    }
}








contract Vault is IVault, ModifiedWhitelistAdminRole {

    using SafeMath for uint256;
    using BokkyPooBahsDateTimeLibrary for uint256;

    address internal creator_;
    IMarket internal market_;
    IERC20 internal collateralToken_;
    IMoleculeVault internal moleculeVault_;
    uint256 internal moleculeFeeRate_;
    uint256 internal currentPhase_;
    uint256 internal outstandingWithdraw_;
    uint256 internal totalRounds_;
    uint256 internal cumulativeReceivedFee_;
    bool internal _active;
    
    mapping(uint256 => FundPhase) internal fundingPhases_;

    struct FundPhase{
        uint256 fundingThreshold;   // Collateral limit to trigger funding
        uint256 cumulativeFundingThreshold; // The cumulative funding goals
        uint256 fundingRaised;      // The amount of funding raised
        uint256 phaseDuration;      // Period of time for round (start to end)
        uint256 startDate;
        FundingState state;         // State enum
    }

    constructor(
        uint256[] memory _fundingGoals,
        uint256[] memory _phaseDurations,
        address _creator,
        address _collateralToken,
        address _moleculeVault
    )
        public
        ModifiedWhitelistAdminRole()
    {
        require(_fundingGoals.length > 0, "No funding goals specified");
        require(_fundingGoals.length < 10, "Too many phases defined");
        require(
            _fundingGoals.length == _phaseDurations.length,
            "Invalid phase configuration"
        );

        super.addNewInitialAdmin(_creator);
        outstandingWithdraw_ = 0;
        creator_ = _creator;
        collateralToken_ = IERC20(_collateralToken);
        moleculeVault_ = IMoleculeVault(_moleculeVault);
        moleculeFeeRate_ = moleculeVault_.feeRate();

        uint256 loopLength = _fundingGoals.length;
        for(uint8 i = 0; i < loopLength; i++) {
            if(moleculeFeeRate_ == 0) {
                fundingPhases_[i].fundingThreshold = _fundingGoals[i];
            } else {
                uint256 withFee = _fundingGoals[i].add(
                    _fundingGoals[i].mul(moleculeFeeRate_).div(100)
                );
                fundingPhases_[i].fundingThreshold = withFee;
            }
            fundingPhases_[i].fundingRaised = 0;
            fundingPhases_[i].phaseDuration = _phaseDurations[i];
            totalRounds_ = totalRounds_.add(1);
        }

        fundingPhases_[0].startDate = block.timestamp;
        fundingPhases_[0].state = FundingState.STARTED;
        currentPhase_ = 0;
    }

    modifier onlyMarket() {

        require(msg.sender == address(market_), "Invalid requesting account");
        _;
    }

    modifier isActive() {

        require(_active, "Vault has not been initialized.");
        _;
    }

    function initialize(
        address _market
    )
        external
        onlyWhitelistAdmin()
        returns(bool)
    {

        require(_market != address(0), "Contracts initialized");
        market_ = IMarket(_market); 
        super.renounceWhitelistAdmin();

        for(uint8 i = 0; i < totalRounds_; i++) {
            if(i == 0) {
                fundingPhases_[i].cumulativeFundingThreshold.add(
                    fundingPhases_[i].fundingThreshold
                );
            }
            fundingPhases_[i].cumulativeFundingThreshold.add(
                fundingPhases_[i-1].cumulativeFundingThreshold
            );
        }
        _active = true;

        return true;
    }

    function withdraw()
        external
        isActive()
        onlyWhitelistAdmin()
        returns(bool)
    {

        require(outstandingWithdraw_ > 0, "No funds to withdraw");

        for(uint8 i; i <= totalRounds_; i++) {
            if(fundingPhases_[i].state == FundingState.PAID) {
                continue;
            } else if(fundingPhases_[i].state == FundingState.ENDED) {
                outstandingWithdraw_ = outstandingWithdraw_.sub(
                    fundingPhases_[i].fundingThreshold
                );
                fundingPhases_[i].state = FundingState.PAID;

                uint256 molFee = fundingPhases_[i].fundingThreshold
                    .mul(moleculeFeeRate_)
                    .div(moleculeFeeRate_.add(100));
                require(
                    collateralToken_.transfer(address(moleculeVault_), molFee),
                    "Tokens not transfer"
                );

                uint256 creatorAmount = fundingPhases_[i].fundingThreshold
                    .sub(molFee);

                require(
                    collateralToken_.transfer(msg.sender, creatorAmount),
                    "Tokens not transfer"
                );
                
                emit FundingWithdrawn(i, creatorAmount);
            } else {
                break;
            }
        }

        if(
            fundingPhases_[currentPhase_].state == FundingState.NOT_STARTED
        ) {
            if(market_.active() && outstandingWithdraw_ == 0) {
                terminateMarket();
            }
        }
        return true;
    }

    function validateFunding(
        uint256 _receivedFunding
    )
        external
        isActive()
        onlyMarket()
        returns(bool)
    {

        require(
            fundingPhases_[currentPhase_].state == FundingState.STARTED,
            "Funding inactive"
        );

        uint256 endOfPhase = fundingPhases_[currentPhase_].startDate
            .addMonths(fundingPhases_[currentPhase_].phaseDuration);
        if(endOfPhase <= block.timestamp) {
            terminateMarket();
            return false;
        }

        uint256 balance = collateralToken_.balanceOf(address(this));
        fundingPhases_[currentPhase_]
            .fundingRaised = fundingPhases_[currentPhase_]
            .fundingRaised.add(_receivedFunding);
        cumulativeReceivedFee_.add(_receivedFunding);

        if(
            fundingPhases_[currentPhase_].cumulativeFundingThreshold <=
                cumulativeReceivedFee_ &&
            balance.sub(outstandingWithdraw_) >=
                fundingPhases_[currentPhase_].fundingThreshold
        ) {
            assert(
                fundingPhases_[currentPhase_].fundingRaised >=
                fundingPhases_[currentPhase_].fundingThreshold
            );
            _endCurrentRound();
            if(
                fundingPhases_[currentPhase_].fundingRaised >
                fundingPhases_[currentPhase_].fundingThreshold
            ) {
                _endCurrentRound();
                do {
                    if(
                        fundingPhases_[currentPhase_]
                            .cumulativeFundingThreshold <=
                            cumulativeReceivedFee_ &&
                        balance.sub(outstandingWithdraw_) >=
                        fundingPhases_[currentPhase_].fundingThreshold
                    ) {
                        _endCurrentRound();
                    } else {
                        break;
                    }
                } while(currentPhase_ < totalRounds_);
            }
        }
        return true;
    }

    function terminateMarket()
        public
        isActive()
        onlyWhitelistAdmin()
    {

        uint256 remainingBalance = collateralToken_.balanceOf(address(this));
        if(outstandingWithdraw_ > 0) {
            remainingBalance = remainingBalance.sub(outstandingWithdraw_);
        }
        require(
            collateralToken_.transfer(address(market_), remainingBalance),
            "Transfering of funds failed"
        );
        require(market_.finaliseMarket(), "Market termination error");
    }

    function fundingPhase(
        uint256 _phase
    )
        public
        view
        returns(
            uint256,
            uint256,
            uint256,
            uint256,
            FundingState
        ) {

        return (
            fundingPhases_[_phase].fundingThreshold,
            fundingPhases_[_phase].fundingRaised,
            fundingPhases_[_phase].phaseDuration,
            fundingPhases_[_phase].startDate,
            fundingPhases_[_phase].state
        );
    }

    function outstandingWithdraw() public view returns(uint256) {

        uint256 minusMolFee = outstandingWithdraw_
            .sub(outstandingWithdraw_
                .mul(moleculeFeeRate_)
                .div(moleculeFeeRate_.add(100))
            );
        return minusMolFee;
    }

    function currentPhase() public view returns(uint256) {

        return currentPhase_;
    }

    function getTotalRounds() public view returns(uint256) {

        return totalRounds_;
    }

    function market() public view returns(address) {

        return address(market_);
    }

    function creator() external view returns(address) {

        return creator_;
    }

    function _endCurrentRound() internal {

        fundingPhases_[currentPhase_].state = FundingState.ENDED;
        uint256 excess = fundingPhases_[currentPhase_]
            .fundingRaised.sub(fundingPhases_[currentPhase_].fundingThreshold);
        if (excess > 0) {
            fundingPhases_[currentPhase_.add(1)]
                .fundingRaised = fundingPhases_[currentPhase_.add(1)]
                .fundingRaised.add(excess);
            fundingPhases_[currentPhase_]
                .fundingRaised = fundingPhases_[currentPhase_].fundingThreshold;
        }
        outstandingWithdraw_ = outstandingWithdraw_
            .add(fundingPhases_[currentPhase_].fundingThreshold);
        currentPhase_ = currentPhase_ + 1;
        if(fundingPhases_[currentPhase_].fundingThreshold > 0) {
            fundingPhases_[currentPhase_].state = FundingState.STARTED;
            uint256 endTime = fundingPhases_[currentPhase_
                .sub(1)].startDate
                .addMonths(fundingPhases_[currentPhase_].phaseDuration);
            uint256 remaining = endTime.sub(block.timestamp);
            fundingPhases_[currentPhase_].startDate = block.timestamp
                .add(remaining);
        }

        emit PhaseFinalised(
            currentPhase_.sub(1),
            fundingPhases_[currentPhase_.sub(1)].fundingThreshold
        );
    }
}









contract MarketFactory is IMarketFactory, ModifiedWhitelistAdminRole {

    IMoleculeVault internal moleculeVault_;
    IMarketRegistry internal marketRegistry_;
    ICurveRegistry internal curveRegistry_;
    IERC20 internal collateralToken_;
    address internal marketCreator_;
    bool internal isInitialized_  = false;

    event NewApiAddressAdded(address indexed oldAddress, address indexed newAddress);

    modifier onlyAnAdmin() {

        require(isInitialized_, "Market factory has not been activated");
        require(
            isWhitelistAdmin(msg.sender) || msg.sender == marketCreator_,
            "Functionality restricted to whitelisted admin"
        );
        _;
    }

    constructor(
        address _collateralToken,
        address _moleculeVault,
        address _marketRegistry,
        address _curveRegistry
    )
        ModifiedWhitelistAdminRole()
        public
    {
        collateralToken_ = IERC20(_collateralToken);
        moleculeVault_ = IMoleculeVault(_moleculeVault);
        marketRegistry_ = IMarketRegistry(_marketRegistry);
        curveRegistry_ = ICurveRegistry(_curveRegistry);
    }

    function init(
        address _admin,
        address _api
    )
        onlyWhitelistAdmin()
        public
    {

        super.addNewInitialAdmin(_admin);
        marketCreator_ = _api;
        super.renounceWhitelistAdmin();
        isInitialized_ = true;
    }

    function updateApiAddress(
        address _newApiPublicKey
    ) 
        onlyWhitelistAdmin() 
        public 
        returns(address)
    {

        address oldMarketCreator = marketCreator_;
        marketCreator_ = _newApiPublicKey;

        emit NewApiAddressAdded(oldMarketCreator, marketCreator_);
        return _newApiPublicKey;
    }

    function deployMarket(
        uint256[] calldata _fundingGoals,
        uint256[] calldata _phaseDurations,
        address _creator,
        uint256 _curveType,
        uint256 _feeRate
    )
        external
        onlyAnAdmin()
    {

        (address curveLibrary,, bool curveState) = curveRegistry_.getCurveData(
            _curveType
        );

        require(_feeRate > 0, "Fee rate too low");
        require(_feeRate < 100, "Fee rate too high");
        require(_creator != address(0), "Creator address invalid");
        require(curveState, "Curve inactive");
        require(curveLibrary != address(0), "Curve library invalid");
        
        address newVault = address(new Vault(
            _fundingGoals,
            _phaseDurations,
            _creator,
            address(collateralToken_),
            address(moleculeVault_)
        ));

        address newMarket = address(new Market(
            _feeRate,
            newVault,
            curveLibrary,
            address(collateralToken_)
        ));

        require(Vault(newVault).initialize(newMarket), "Vault not initialized");
        marketRegistry_.registerMarket(newMarket, newVault, _creator);
    }

    function updateMoleculeVault(
        address _newMoleculeVault
    )
        public
        onlyWhitelistAdmin()
    {

        moleculeVault_ = IMoleculeVault(_newMoleculeVault);
    }

    function moleculeVault() public view returns(address) {

        return address(moleculeVault_);
    }

    function marketRegistry() public view returns(address) {

        return address(marketRegistry_);
    }

    function curveRegistry() public view returns(address) {

        return address(curveRegistry_);
    }

    function collateralToken() public view returns(address) {

        return address(collateralToken_);
    }
}