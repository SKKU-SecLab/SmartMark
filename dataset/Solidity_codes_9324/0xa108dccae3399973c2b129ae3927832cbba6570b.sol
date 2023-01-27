

pragma solidity  ^0.6.0;

contract SafeMath {

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

        return safeSub(a, b, "SafeMath: subtraction overflow");
    }

    function safeSub(uint256 a, uint256 b, string memory error) internal pure returns (uint256) {

        require(b <= a, error);
        uint256 c = a - b;
        return c;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return safeDiv(a, b, "SafeMath: division by zero");
    }

    function safeDiv(uint256 a, uint256 b, string memory error) internal pure returns (uint256) {

        require(b > 0, error);
        uint256 c = a / b;

        return c;
    }

    function safeExponent(uint256 a,uint256 b) internal pure returns (uint256) {

        uint256 result;
        assembly {
            result:=exp(a, b)
        }
        return result;
    }
}


pragma solidity ^0.6;

contract DateTime {

        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

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

        function leapYearsBefore(uint year) public pure returns (uint) {

                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {

                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {

                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                dt.hour = getHour(timestamp);

                dt.minute = getMinute(timestamp);

                dt.second = getSecond(timestamp);

                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) public pure returns (uint16) {

                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

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

        function getMonth(uint timestamp) public pure returns (uint8) {

                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) public pure returns (uint8) {

                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) public pure returns (uint8) {

                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public pure returns (uint8) {

                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint8) {

                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) public pure returns (uint8) {

                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {

                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {

                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {

                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {

                uint16 i;

                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                timestamp += DAY_IN_SECONDS * (day - 1);

                timestamp += HOUR_IN_SECONDS * (hour);

                timestamp += MINUTE_IN_SECONDS * (minute);

                timestamp += second;

                return timestamp;
        }
}


pragma solidity ^0.6.0;



contract STYK_I is SafeMath, DateTime {

    constructor(
        uint256 _lockTime,
        uint256 _auctionExpiryTime,
        uint256 _auctionLimit,
        uint256 _stakeAmount
    ) public {
        STYK_REWARD_TOKENS = safeMul(200000, 1e18);
        MONTHLY_REWARD_TOKENS = safeMul(100000, 1e18);

        tokenBalanceLedger_[address(this)] = safeAdd(
            STYK_REWARD_TOKENS,
            MONTHLY_REWARD_TOKENS
        );
        lockTime = _lockTime;
        auctionExpiryTime = _auctionExpiryTime;
        auctionEthLimit = _auctionLimit;
        stakingRequirement = _stakeAmount;
        inflationPayOutDays = safeAdd(now, 500 days);
    }

    modifier onlybelievers() {

        require(myTokens() > 0);
        _;
    }

    modifier onlyhodler() {

        require(myDividends(true) > 0);
        _;
    }

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

    event Transfer(address indexed from, address indexed to, uint256 tokens);

    string public name = "STYK I";
    string public symbol = "STYK";
    uint256 public constant decimals = 18;
    uint8 internal constant dividendFee_ = 10;
    uint256 internal constant tokenPriceInitial_ = 0.0000001 ether;
    uint256 internal constant tokenPriceIncremental_ = 0.00000001 ether;
    uint256 internal constant magnitude = 2**64;
    uint256 STYK_REWARD_TOKENS;

    uint256 MONTHLY_REWARD_TOKENS;

    uint256 internal inflationTime;

    uint256 internal lockTime;
    uint256 internal inflationPayOutDays;
    uint56 internal userCount = 0;
    uint256 public inflationCounter = 0;

    uint256 internal stakingRequirement;


    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => bool) public rewardQualifier;
    mapping(address => uint256) internal stykRewards;
    mapping(address => address[]) internal referralUsers;
    mapping(address => mapping(address => bool)) internal userExists;
    mapping(address => bool) internal earlyadopters;
    mapping(address => bool) internal userAdded;
    mapping(address => uint256) internal userIndex;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal totalMonthRewards;
    mapping(address => uint256) internal earlyadopterBonus;
    mapping(address => uint256) internal userDeposit;
    mapping(address => bool) internal auctionAddressTracker;
    mapping(address => mapping(uint256 => mapping (uint256 => bool)))public monthlyRewardsClaimed;
    mapping(address =>mapping(uint256 => bool))public stykclaimMap;

    address[] internal userAddress;
    uint256 internal tokenSupply_ = 0;
    uint256 public auctionEthLimit;
    uint256 public auctionExpiryTime;
    uint256 internal profitPerShare_;
    uint256 internal auctionProfitPerShare_;

    function buy(address _referredBy) public payable returns (uint256) {

        purchaseTokens(msg.value, _referredBy);
    }

    fallback() external payable {
        revert("ERR_CANNOT_FORCE_ETHERS");
    }

    receive() external payable {
        revert("ERR_CANNOT_FORCE_ETHERS");
    }

    function reinvest() public onlyhodler() {

        address _customerAddress = msg.sender;
        uint256 _dividends = totalDividends(_customerAddress);
        userDeposit[_customerAddress] = 0;
        payoutsTo_[_customerAddress] += (int256)(
            _dividendsOf(_customerAddress) * magnitude
        );
        referralBalance_[_customerAddress] = 0;

        if (
            earlyadopters[_customerAddress] &&
            (now > safeAdd(auctionExpiryTime, 24 hours))
        ) {
            if (tokenBalanceLedger_[_customerAddress] == 0) {
                earlyadopterBonus[_customerAddress] = 0;
            }
            earlyadopters[_customerAddress] = false;
        }

        if (
            rewardQualifier[_customerAddress] &&
            _calculateInflationMinutes() > 4320
        ) {
            stykRewards[_customerAddress] = 0;
            rewardQualifier[_customerAddress] = false;
        }
        if (totalMonthRewards[_customerAddress] != 0) {
            totalMonthRewards[_customerAddress] = 0;
        }

        uint256 _tokens = purchaseTokens(_dividends, address(0));

        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function exit() public {

        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];

        if (_tokens > 0) sell(_tokens);

        withdraw();
        userAdded[_customerAddress] = false;

        uint256 index = getUserAddressIndex(_customerAddress);
        address _lastAddress = userAddress[userAddress.length - 1];
        uint256 _lastindex = getUserAddressIndex(_lastAddress);
        userAddress[index] = _lastAddress;
        userAddress[userAddress.length - 1] = _customerAddress;

        userIndex[_lastAddress] = index;
        userIndex[_customerAddress] = _lastindex;
        delete userIndex[_customerAddress];
        userAddress.pop();
        userCount--;
    }

    function withdraw() public onlyhodler() {

        address payable _customerAddress = msg.sender;
        uint256 _dividends = totalDividends(_customerAddress);

        userDeposit[_customerAddress] = 0;
        payoutsTo_[_customerAddress] += (int256)(
            _dividendsOf(_customerAddress) * magnitude
        );
        referralBalance_[_customerAddress] = 0;

        if (
            earlyadopters[_customerAddress] &&
            (now > safeAdd(auctionExpiryTime, 24 hours))
        ) {
            if (tokenBalanceLedger_[_customerAddress] == 0) {
                earlyadopterBonus[_customerAddress] = 0;
            }
            earlyadopters[_customerAddress] = false;
        }

        if (
            rewardQualifier[_customerAddress] &&
            _calculateInflationMinutes() > 4320
        ) {
            stykRewards[_customerAddress] = 0;
            rewardQualifier[_customerAddress] = false;
        }
        if (totalMonthRewards[_customerAddress] != 0) {
            totalMonthRewards[_customerAddress] = 0;
        }
        _customerAddress.transfer(_dividends);

        emit onWithdraw(_customerAddress, _dividends);
    }

    function sell(uint256 _amountOfTokens) public onlybelievers() {

        address _customerAddress = msg.sender;

        require(
            now > auctionExpiryTime,
            "ERR_CANNOT_SELL_TOKENS_BEFORE_AUCTION"
        );

        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = safeDiv(_ethereum, dividendFee_);
        uint256 _taxedEthereum = safeSub(_ethereum, _dividends);

        if (tokenBalanceLedger_[_customerAddress] == _amountOfTokens) {
            if (earlyadopters[_customerAddress]) {
                earlyadopterBonus[_customerAddress] = earlyAdopterBonus(
                    _customerAddress
                );
            }
            if (rewardQualifier[_customerAddress]) {
                stykRewards[_customerAddress] = STYKRewards(_customerAddress);
            }
        }

        tokenSupply_ = safeSub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = safeSub(
            tokenBalanceLedger_[_customerAddress],
            _tokens
        );

        if (auctionAddressTracker[_customerAddress]) {
            int256 _updatedPayouts = (int256)(auctionProfitPerShare_ * _tokens);
            payoutsTo_[_customerAddress] -= _updatedPayouts;
        } else {
            int256 _updatedPayouts = (int256)(profitPerShare_ * _tokens);
            payoutsTo_[_customerAddress] -= _updatedPayouts;
        }

        if (tokenSupply_ > 0) {
            auctionProfitPerShare_ = safeAdd(
                auctionProfitPerShare_,
                (_dividends * magnitude) /
                    safeAdd(tokenSupply_, tokenBalanceLedger_[address(this)])
            );

            profitPerShare_ = safeAdd(
                profitPerShare_,
                (_dividends * magnitude) /
                    safeAdd(tokenSupply_, tokenBalanceLedger_[address(this)])
            );
        }

        userDeposit[_customerAddress] = safeAdd(
            userDeposit[_customerAddress],
            _taxedEthereum
        );

        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
        emit Transfer(_customerAddress, address(0), _amountOfTokens);
    }

    function totalEthereumBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function totalSupply() public view returns (uint256) {

        return tokenSupply_;
    }

    function myTokens() public view returns (uint256) {

        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    function myDividends(bool _includeReferralBonus)
        public
        view
        returns (uint256)
    {

        address _customerAddress = msg.sender;
        return
            _includeReferralBonus
                ? _dividendsOf(_customerAddress) +
                    referralBalance_[_customerAddress]
                : _dividendsOf(_customerAddress);
    }

    function balanceOf(address _customerAddress) public view returns (uint256) {

        return tokenBalanceLedger_[_customerAddress];
    }

    function _dividendsOf(address _customerAddress)
        public
        view
        returns (uint256)
    {

        if (auctionAddressTracker[_customerAddress]) {
            return
                safeAdd(
                    (uint256)(
                        (int256)(
                            auctionProfitPerShare_ *
                                (tokenBalanceLedger_[_customerAddress])
                        ) - payoutsTo_[_customerAddress]
                    ) / magnitude,
                    userDeposit[_customerAddress]
                );
        } else {
            return
                safeAdd(
                    (uint256)(
                        (int256)(
                            profitPerShare_ *
                                (tokenBalanceLedger_[_customerAddress])
                        ) - payoutsTo_[_customerAddress]
                    ) / magnitude,
                    userDeposit[_customerAddress]
                );
        }
    }

    function sellPrice() external view returns (uint256) {

        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = safeDiv(_ethereum, dividendFee_);
            uint256 _taxedEthereum = safeSub(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }

    function buyPrice() public view returns (uint256) {

        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = safeDiv(_ethereum, dividendFee_);
            uint256 _taxedEthereum = safeAdd(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }

    function calculateTokensReceived(uint256 _ethereumToSpend)
        external
        view
        returns (uint256)
    {

        uint256 _dividends = safeDiv(_ethereumToSpend, dividendFee_);
        uint256 _taxedEthereum = safeSub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }

    function calculateEthereumReceived(uint256 _tokensToSell)
        external
        view
        returns (uint256)
    {

        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = safeDiv(_ethereum, dividendFee_);
        uint256 _taxedEthereum = safeSub(_ethereum, _dividends);
        return _taxedEthereum;
    }


    function _inflation() internal view returns (uint256) {

        uint256 buyPrice_ = buyPrice();
        uint256 inflation_factor = safeDiv(buyPrice_, 1e12);
        return inflation_factor;
    }

    function checkInflation() external view returns (uint256) {

        return _inflation();
    }

    function setInflationTime() internal {

        if (_inflation() >= 20000 || now > inflationPayOutDays) {
            inflationTime = now;
            inflationPayOutDays = safeAdd(inflationTime, 500 days);
             ++inflationCounter;
        }
    }

    function _calculateInflationMinutes() internal view returns (uint256) {

        if (inflationTime == 0) {
            return 0;
        }
        return safeDiv(safeSub(now, inflationTime), 60);
    }

    function calculateInflationMinutes() external view returns (uint256) {

        return _calculateInflationMinutes();
    }

    function _calculateTokenPercentage(address _customerAddress)
        internal
        view
        returns (uint256)
    {

        if (tokenBalanceLedger_[_customerAddress] > 0) {
            uint256 token_percent =
                safeDiv(
                    safeMul(tokenBalanceLedger_[_customerAddress], 1000000),
                    totalSupply()
                );
            return token_percent;
        }
        return 0;
    }

    function calculateTokenPercentage(address _customerAddress)
        external
        view
        returns (uint256)
    {

        return _calculateTokenPercentage(_customerAddress);
    }

    function _calculateSTYKReward(address _customerAddress)
        internal
        view
        returns (uint256)
    {

        if (now > auctionExpiryTime) {
            uint256 token_percent = _calculateTokenPercentage(_customerAddress);
            if (token_percent > 0) {
                uint256 rewards =
                    safeDiv(
                        safeMul(
                            _dividendsOfPremintedTokens(STYK_REWARD_TOKENS),
                            token_percent
                        ),
                        1000000
                    );
                return rewards;
            }
            return 0;
        }
        return 0;
    }

    function calculateSTYKReward(address _customerAddress)
        external
        view
        returns (uint256)
    {

        return _calculateSTYKReward(_customerAddress);
    }

    function deflationSell() external {

        uint256 inflationMinutes = _calculateInflationMinutes();
        require(
            inflationMinutes <= 4320,
            "ERR_INFLATION_MINUTES_SHOULD_BE_LESS_THAN_4320"
        );

        require(!stykclaimMap[msg.sender][inflationCounter], "ERR_REWARD_ALREADY_CLAIMED");

        if (_calculateSTYKReward(msg.sender) > 0) {
            rewardQualifier[msg.sender] = true;
            stykclaimMap[msg.sender][inflationCounter] = true;
            uint256 rewards = _calculateSTYKReward(msg.sender);

            stykRewards[msg.sender] = safeAdd(stykRewards[msg.sender], rewards);

            uint256 userToken =
                safeDiv(safeMul(tokenBalanceLedger_[msg.sender], 25), 100);

            sell(userToken);
        }
    }

    function _deflationAccumulatedRewards() internal view returns (uint256) {

        uint256 stykRewardPoolBalance = 0;

        for (uint256 i = 0; i < userAddress.length; i++) {
            if (userAddress[i] != address(0)) {
                address _user = userAddress[i];
                if (!rewardQualifier[_user]) {
                    stykRewardPoolBalance = safeAdd(
                        _calculateSTYKReward(_user),
                        stykRewardPoolBalance
                    );
                }
            }
        }
        return stykRewardPoolBalance;
    }

    function STYKRewards(address _to) internal view returns (uint256) {

        if (_calculateTokenPercentage(_to) > 0) {
            uint256 _rewards = stykRewards[_to];
            uint256 accumulatedRewards =
                safeDiv(
                    safeMul(
                        _deflationAccumulatedRewards(),
                        _calculateTokenPercentage(_to)
                    ),
                    1000000
                );
            uint256 finalRewards = safeAdd(_rewards, accumulatedRewards);
            return finalRewards;
        }
        return 0;
    }

    function _teamTokenHolder(address _to) internal view returns (uint256) {

        uint256 useractivecount = 0;
        uint256 usertotaltokens = 0;
        if (profitPerShare_ > 0) {
            for (uint256 i = 0; i < referralUsers[_to].length; i++) {
                address _userAddress = referralUsers[_to][i];
                if (_checkUserActiveStatus(_userAddress)) {
                    ++useractivecount;
                }
            }

            if (useractivecount >= 3) {
                for (uint256 i = 0; i < referralUsers[_to].length; i++) {
                    address _addr = referralUsers[_to][i];
                    usertotaltokens = safeAdd(
                        tokenBalanceLedger_[_addr],
                        usertotaltokens
                    );
                }
                return
                    safeDiv(safeMul(usertotaltokens, 1000000), totalSupply());
            } else {
                return 0;
            }
        } else return 0;
    }

    function teamTokenHolder(address _to) external view returns (uint256) {

        return _teamTokenHolder(_to);
    }

    function _calculateMonthlyRewards(address _to)
        internal
        view
        returns (uint256)
    {

        uint256 token_percent = _teamTokenHolder(_to);
        if (token_percent != 0) {
            uint256 rewards =
                safeDiv(
                    safeMul(
                        _dividendsOfPremintedTokens(MONTHLY_REWARD_TOKENS),
                        token_percent
                    ),
                    1000000
                );

            return rewards;
        }
        return 0;
    }

    function calculateMonthlyRewards(address _to)
        external
        view
        returns (uint256)
    {

        return _calculateMonthlyRewards(_to);
    }

    function _checkUserActiveStatus(address _user)
        internal
        view
        returns (bool)
    {

        if (tokenBalanceLedger_[_user] > safeMul(10, 1e18)) {
            return true;
        } else {
            return false;
        }
    }

    function earlyAdopterBonus(address _user) public view returns (uint256) {

        if (tokenBalanceLedger_[_user] > 0 && earlyadopters[_user]) {
            uint256 token_percent = _calculateTokenPercentage(_user);
            uint256 _earlyadopterDividends =
                (uint256)(
                    (int256)(
                        auctionProfitPerShare_ *
                            tokenBalanceLedger_[address(this)]
                    )
                ) / magnitude;
            uint256 rewards =
                safeDiv(
                    safeMul(_earlyadopterDividends, token_percent),
                    1000000
                );
            return rewards;
        }
        return 0;
    }

    function getUserAffiliateBalance(address _user)
        external
        view
        returns (uint256)
    {

        return referralBalance_[_user];
    }

    function getUserAddressIndex(address _customerAddress)
        internal
        view
        returns (uint256)
    {

        return userIndex[_customerAddress];
    }

    function _dividendsOfPremintedTokens(uint256 _tokens)
        internal
        view
        returns (uint256)
    {

        return (uint256)((int256)(profitPerShare_ * _tokens)) / magnitude;
    }

    function totalDividends(address _customerAddress)
        public
        view
        returns (uint256)
    {

        uint256 _dividends = _dividendsOf(_customerAddress);

        uint256 qualifying_rewards;
        if (
            earlyadopters[_customerAddress] &&
            (now > safeAdd(auctionExpiryTime, 24 hours))
        ) {
            if (tokenBalanceLedger_[_customerAddress] > 0) {
                qualifying_rewards = safeAdd(
                    qualifying_rewards,
                    earlyAdopterBonus(_customerAddress)
                );
            } else {
                qualifying_rewards = safeAdd(
                    qualifying_rewards,
                    earlyadopterBonus[_customerAddress]
                );
            }
        }
        if (
            rewardQualifier[_customerAddress] &&
            _calculateInflationMinutes() > 4320
        ) {
            if (tokenBalanceLedger_[_customerAddress] > 0) {
                qualifying_rewards = safeAdd(
                    qualifying_rewards,
                    STYKRewards(_customerAddress)
                );
            } else {
                qualifying_rewards = safeAdd(
                    qualifying_rewards,
                    stykRewards[_customerAddress]
                );
            }
        }

        if (totalMonthRewards[_customerAddress] != 0) {
            qualifying_rewards = safeAdd(
                qualifying_rewards,
                totalMonthRewards[_customerAddress]
            );
        }

        return (
            safeAdd(
                safeAdd(_dividends, qualifying_rewards),
                referralBalance_[_customerAddress]
            )
        );
    }

    function claimMonthlyRewards() external {

        address _customerAddress = msg.sender;
        
        require(_calculateMonthlyRewards(_customerAddress) > 0 ,"ERR_YOU_DONT_QUALIFY");
        
        uint256 daysPayout = safeSub(getDaysInMonth(getMonth(now), getYear(now)),1);

        require(
            (getDay(now) == daysPayout || getDay(now) == getDaysInMonth(getMonth(now), getYear(now))),
            "ERR_CANNOT_CLAIM_BEFORE_PAYOUT"
        );
        
        require(!monthlyRewardsClaimed[_customerAddress][getYear(now)][getMonth(now)],"ERR_REWARD_ALREADY_CLAIMED");
        
        if (_calculateTokenPercentage(_customerAddress) != 0) {
            totalMonthRewards[_customerAddress] = safeAdd(
                totalMonthRewards[_customerAddress],
                _calculateMonthlyRewards(_customerAddress)
            );
            monthlyRewardsClaimed[_customerAddress][getYear(now)][getMonth(now)] = true;
        
        }
    }

    function release() external {

        require(now > lockTime, "ERR_CANNOT_RELEASE_TOKENS_BEFORE_LOCK_TIME");

        uint256 amount = tokenBalanceLedger_[address(this)];
        tokenSupply_ = safeAdd(tokenSupply_, amount);
    }

    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        internal
        returns (uint256)
    {

        address _customerAddress = msg.sender;
        uint256 _undividedDividends = safeDiv(_incomingEthereum, dividendFee_);
        uint256 _referralBonus = safeDiv(_undividedDividends, 2);
        uint256 _dividends = safeSub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum =
            safeSub(_incomingEthereum, _undividedDividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;

        require(
            _amountOfTokens > 0 &&
                (safeAdd(_amountOfTokens, tokenSupply_) > tokenSupply_)
        );

        if (
            _referredBy != address(0) &&
            _referredBy != _customerAddress &&
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ) {
            referralBalance_[_referredBy] = safeAdd(
                referralBalance_[_referredBy],
                _referralBonus
            );
        } else {
            _dividends = safeAdd(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

        tokenSupply_ = safeAdd(tokenSupply_, _amountOfTokens);

        if (now > auctionExpiryTime) {
            profitPerShare_ += ((_dividends * magnitude) /
                safeAdd(tokenSupply_, tokenBalanceLedger_[address(this)]));
        }
        auctionProfitPerShare_ += ((_dividends * magnitude) /
            safeAdd(tokenSupply_, tokenBalanceLedger_[address(this)]));

        _fee =
            _fee -
            (_fee -
                (_amountOfTokens *
                    ((_dividends * magnitude) /
                        safeAdd(
                            tokenSupply_,
                            tokenBalanceLedger_[address(this)]
                        ))));

        tokenBalanceLedger_[_customerAddress] = safeAdd(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        if (
            !userExists[_referredBy][_customerAddress] &&
            _referredBy != address(0) &&
            _referredBy != _customerAddress
        ) {
            userExists[_referredBy][_customerAddress] = true;
            referralUsers[_referredBy].push(_customerAddress);
        }

        if (now <= auctionExpiryTime) {
            if (
                totalEthereumBalance() <= auctionEthLimit &&
                safeAdd(totalEthereumBalance(), _incomingEthereum) <=
                auctionEthLimit
            ) {
                if (!earlyadopters[_customerAddress]) {
                    earlyadopters[_customerAddress] = true;
                }
                if (!auctionAddressTracker[_customerAddress]) {
                    auctionAddressTracker[_customerAddress] = true;
                }
            }
        }

        if (auctionAddressTracker[_customerAddress]) {
            int256 _updatedPayouts =
                (int256)((auctionProfitPerShare_ * _amountOfTokens) - _fee);
            payoutsTo_[_customerAddress] += _updatedPayouts;
        } else {
            int256 _updatedPayouts =
                (int256)((profitPerShare_ * _amountOfTokens) - _fee);
            payoutsTo_[_customerAddress] += _updatedPayouts;
        }

        if (!userAdded[_customerAddress]) {
            userAddress.push(_customerAddress);
            userAdded[_customerAddress] = true;
            userIndex[_customerAddress] = userCount;
            userCount++;
        }

        emit onTokenPurchase(
            _customerAddress,
            _incomingEthereum,
            _amountOfTokens,
            _referredBy
        );
        if (now > auctionExpiryTime) {
            if (inflationTime == 0 || _calculateInflationMinutes() > 4320)
                setInflationTime();
        }
        emit Transfer(address(this), _customerAddress, _amountOfTokens);

        return _amountOfTokens;
    }

    function ethereumToTokens_(uint256 _ethereum)
        internal
        view
        returns (uint256)
    {

        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived =
            ((
                safeSub(
                    (
                        sqrt(
                            (_tokenPriceInitial**2) +
                                (2 *
                                    (tokenPriceIncremental_ * 1e18) *
                                    (_ethereum * 1e18)) +
                                (((tokenPriceIncremental_)**2) *
                                    (tokenSupply_**2)) +
                                (2 *
                                    (tokenPriceIncremental_) *
                                    _tokenPriceInitial *
                                    tokenSupply_)
                        )
                    ),
                    _tokenPriceInitial
                )
            ) / (tokenPriceIncremental_)) - (tokenSupply_);

        return _tokensReceived;
    }

    function tokensToEthereum_(uint256 _tokens)
        internal
        view
        returns (uint256)
    {

        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
            (// underflow attempts BTFO
            safeSub(
                (((tokenPriceInitial_ +
                    (tokenPriceIncremental_ * (_tokenSupply / 1e18))) -
                    tokenPriceIncremental_) * (tokens_ - 1e18)),
                (tokenPriceIncremental_ * ((tokens_**2 - tokens_) / 1e18)) / 2
            ) / 1e18);
        return _etherReceived;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

