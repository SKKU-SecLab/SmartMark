pragma solidity ^0.8.10;

library Variables {

    string public constant _name = "Safe Coliseum";
    string public constant _symbol = "SCOLT";
    uint8 public constant _decimals = 8;
    uint256 public constant _initial_total_supply = 105000000 * 10**_decimals;

    uint256 public constant _pioneer_invester_supply = (12 * _initial_total_supply) / 100;
    uint256 public constant _ifo_supply = (21 * _initial_total_supply) / 100;
    uint256 public constant _pool_airdrop_supply = (3 * _initial_total_supply) / 100;
    uint256 public constant _director_supply_each = (5 * _initial_total_supply) / 100;
    uint256 public constant _marketing_expansion_supply = (19 * _initial_total_supply) / 100;
    uint256 public constant _development_expansion_supply = (6 * _initial_total_supply) / 100;
    uint256 public constant _liquidity_supply = (5 * _initial_total_supply) / 100;
    uint256 public constant _future_team_supply = (10 * _initial_total_supply) / 100;
    uint256 public constant _governance_supply = (4 * _initial_total_supply) / 100;
    uint256 public constant _investment_parter_supply = (10 * _initial_total_supply) / 100;

    uint256 public constant _contribution_distribute_after = 700 * 10**_decimals;
    uint256 public constant _contribution_distribution_eligibility = 700 * 10**_decimals;
    
    uint256 public constant _profit_distribution_eligibility = 1000 * 10**_decimals;

    uint256 public constant _burning_till = _initial_total_supply / 2;

    uint256 public constant _whale_per = (_initial_total_supply / 100); // 1% of total tokans consider tobe whale

    uint256 public constant _normal_contribution_per = 2;
    uint256 public constant _whale_contribution_per = 5;

    uint256 public constant _normal_marketing_share = 27;
    uint256 public constant _normal_development_share = 7;
    uint256 public constant _normal_holder_share = 43;
    uint256 public constant _normal_burning_share = 23;

    uint256 public constant _whale_marketing_share = 32;
    uint256 public constant _whale_development_share = 10;
    uint256 public constant _whale_holder_share = 40;
    uint256 public constant _whale_burning_share = 18;

    uint256 public constant _max_sell_amount_whale = 5000 * 10**_decimals; // max for whale
    uint256 public constant _max_sell_amount_normal = 2000 * 10**_decimals; // max for non-whale
    uint256 public constant _max_concurrent_sale_day = 6;
    uint256 public constant _cooling_days = 3;
    uint256 public constant _max_sell_per_director_per_day = 10000 * 10**_decimals;
    uint256 public constant _investor_swap_lock_days = 180; // after 180 days will behave as normal purchase user.

    enum type_of_wallet {
        UndefinedWallet,
        GenesisWallet,
        DirectorWallet,
        MarketingWallet,
        DevelopmentWallet,
        LiquidityWallet,
        GovernanceWallet,
        GeneralWallet,
        FutureTeamWallet,
        PoolOrAirdropWallet,
        IfoWallet,
        UnsoldTokenWallet,
        DexPairWallet
    }

    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    struct wallet_details {
        type_of_wallet wallet_type;
        uint256 balance;
        uint256 lastday_total_sell;
        uint256 concurrent_sale_day_count;
        _DateTime last_sale_date;
        _DateTime joining_date;
        bool contribution_apply;
        bool antiwhale_apply;
        bool anti_dump;
        bool is_investor;
    }

    struct ctc_approval_details {
        bool has_value;
        string uctcid;
        uint256 allowed_till;
        bool used;
        bool burn_or_mint; // false = burn, true = mint
        uint256 amount;
    }

    struct distribution_variables {
        uint256 total_contributions;
        uint256 marketing_contributions;
        uint256 development_contributions;
        uint256 holder_contributions;
        uint256 burn_amount;
    }

    struct function_addresses {
        address owner;
        address sender;
        address this_address;
    }

    struct function_amounts {
        uint256 amount;
        uint256 pending_contribution_to_distribute;
        uint256 initial_total_supply;
        uint256 total_supply;
        uint256 burning_till_now;
    }

    struct function_bools {
        bool _sellers_check_recipient;
        bool _sellers_check_sender;
    }

    struct checkrules_additional_var {
        address sender;
        address recipient;
        uint256 amount;
        bool _sellers_check_recipient;
        bool _sellers_check_sender;
    }

    uint256 public constant _ctc_aproval_validation_timespan = 300; // In Seconds

    address public constant _director_wallet_1 = 0x42B8Ba6D6bD7cD19e132aE5701F970Df0A6b96B1;
    address public constant _director_wallet_2 = 0x9CF71f45c110A4BD01a0Fc0ca2A2f4E9A5e48DF0;
    address public constant _marketing_wallet = 0x548F4817aDC48Df4Abe079c61E731c3ACC216331;
    address public constant _governance_wallet = 0x342B9C569cBaE2AF834dd13539633291A5a8d23B;
    address public constant _liquidity_wallet = 0x27AB3d2F9eB7274092Bf67c54cff1574eA3AFfF4;
    address public constant _pool_airdrop_wallet = 0x7aA854Bc1042df6b10F2a30981FC5DE0fDCF04D2;
    address public constant _future_team_wallet = 0x0Cd8Bd5a0B4DF8a861704c7da1f7D0eB63b2dDa6;
    address public constant _ifo_wallet = 0xffaFCD12D27DCF48a076C914b335B5c152d12609;
    address public constant _development_wallet = 0x8f0070EbC10E4586fC23fc37C6F1975F07f19867;
    address public constant _unsold_token_wallet = 0xC7008531330Ea8BBe55c6fc9b4bED018C1E0AF0e;

}
pragma solidity ^0.8.10;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "SCOLT : insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "SCOLT : unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "SCOLT : low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "SCOLT : low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "SCOLT : insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "SCOLT : call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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
}
pragma solidity ^0.8.10;

library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SCOLT : (SafeMatch) addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SCOLT : (SafeMatch) subtraction overflow");
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
        require(c / a == b, "SCOLT : (SafeMatch) multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SCOLT : (SafeMatch) division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SCOLT : (SafeMatch) modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// UNLICENSED
pragma solidity ^0.8.10;


library SCOLTLibrary {


    using SafeMath for uint256;
    using Address for address;

    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 constant YEAR_IN_SECONDS = 31536000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint256 constant HOUR_IN_SECONDS = 3600;
    uint256 constant MINUTE_IN_SECONDS = 60;

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

    function leapYearsBefore(uint256 year) public pure returns (uint256) {

        uint256 localyear = year;
        localyear -= 1;
        return localyear / 4 - localyear / 100 + localyear / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year)
        public
        pure
        returns (uint8)
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
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }

    function parseTimestamp(uint256 timestamp)
        public
        pure
        returns (Variables._DateTime memory dt)
    {

        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 i;

        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        uint256 secondsInMonth;
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

    function getYear(uint256 timestamp) public pure returns (uint16) {

        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;

        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor +=
            YEAR_IN_SECONDS *
            (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint256 timestamp) public pure returns (uint8) {

        return parseTimestamp(timestamp).month;
    }

    function getDay(uint256 timestamp) public pure returns (uint8) {

        return parseTimestamp(timestamp).day;
    }

    function getHour(uint256 timestamp) public pure returns (uint8) {

        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint256 timestamp) public pure returns (uint8) {

        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint256 timestamp) public pure returns (uint8) {

        return uint8(timestamp % 60);
    }

    function getWeekday(uint256 timestamp) public pure returns (uint8) {

        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day
    ) public pure returns (uint256 timestamp) {

        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour
    ) public pure returns (uint256 timestamp) {

        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute
    ) public pure returns (uint256 timestamp) {

        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute,
        uint8 second
    ) public pure returns (uint256 timestamp) {

        uint16 i;

        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            } else {
                timestamp += YEAR_IN_SECONDS;
            }
        }

        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        } else {
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

    function toTimestampFromDateTime(Variables._DateTime memory date)
        public
        pure
        returns (uint256 timestamp)
    {

        uint16 year = date.year;
        uint8 month = date.month;
        uint8 day = date.day;
        uint8 hour = date.hour;
        uint8 minute = date.minute;
        uint8 second = date.second;
        uint16 i;

        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            } else {
                timestamp += YEAR_IN_SECONDS;
            }
        }

        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        } else {
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

    function _check_time_condition(
        uint256 current_timestamp,
        uint256 last_timestamp,
        uint256 diff
    ) public pure returns (bool) {

        if ((current_timestamp - last_timestamp) >= ((diff * 24) * 3600)) {
            return true;
        } else {
            return false;
        }
    }

    function _checkrules(
        Variables.wallet_details memory sender_wallet,
        Variables.wallet_details memory recipient_wallet,
        Variables.ctc_approval_details memory transferer_ctc_details,
        Variables.checkrules_additional_var memory variables
    ) public view {

        if (transferer_ctc_details.has_value) {
            if (transferer_ctc_details.allowed_till >= block.timestamp) {
                if (!transferer_ctc_details.used) {
                    revert(
                        "SCOLT : You can not make transfer while applied for C2C transfer."
                    );
                }
            }
        }

        if (variables._sellers_check_recipient) {
            if (variables._sellers_check_sender) {
                revert("SCOLT : Inter seller exchange is not allowed.");
            }
        }

        if (
            variables.recipient.isContract()
        ) {
            if (variables._sellers_check_recipient) {
                if (
                    sender_wallet.wallet_type == Variables.type_of_wallet.UndefinedWallet ||
                    sender_wallet.wallet_type == Variables.type_of_wallet.DexPairWallet ||
                    sender_wallet.wallet_type == Variables.type_of_wallet.FutureTeamWallet
                ) {
                    revert(
                        "SCOLT : You are not allowed to send tokens to DexPairWallet"
                    );
                }
            } else {
                if (
                    sender_wallet.wallet_type != Variables.type_of_wallet.LiquidityWallet
                ) {
                    revert(
                        "SCOLT : You are trying to reach unregistered DexPairWallet."
                    );
                }
            }
        }

        if (
            variables.sender.isContract()
        ) {
            if (!variables._sellers_check_sender) {
                if (
                    recipient_wallet.wallet_type != Variables.type_of_wallet.LiquidityWallet
                ) {
                    revert(
                        "SCOLT : Unregistered DexPairWallet are not allowed to send tokens."
                    );
                }
            }
        }

        if (
            sender_wallet.wallet_type != Variables.type_of_wallet.GenesisWallet &&
            sender_wallet.wallet_type != Variables.type_of_wallet.DirectorWallet &&
            sender_wallet.wallet_type != Variables.type_of_wallet.UnsoldTokenWallet &&
            sender_wallet.wallet_type != Variables.type_of_wallet.GeneralWallet &&
            sender_wallet.wallet_type != Variables.type_of_wallet.DexPairWallet &&
            sender_wallet.wallet_type != Variables.type_of_wallet.FutureTeamWallet
        ) {
            if ( sender_wallet.wallet_type != Variables.type_of_wallet.LiquidityWallet ) {
                require(variables._sellers_check_recipient && variables.recipient.isContract(), "SCOLT : This type of wallet is not allowed to do this transaction.");
            } else {
                require(variables.recipient.isContract(), "SCOLT : This type of wallet is not allowed to do this transaction.");
            }
        }

        if (
            sender_wallet.wallet_type == Variables.type_of_wallet.MarketingWallet ||
            sender_wallet.wallet_type == Variables.type_of_wallet.PoolOrAirdropWallet
        ) {
            require(
                recipient_wallet.wallet_type == Variables.type_of_wallet.GeneralWallet || variables.recipient.isContract(),
                "SCOLT : This type of wallet is not allowed to do this transaction."
            );
        }

        if ( sender_wallet.wallet_type == Variables.type_of_wallet.FutureTeamWallet ) {
            require(
                recipient_wallet.wallet_type == Variables.type_of_wallet.GeneralWallet,
                "SCOLT : You are not allowed to send any tokens other than General Type of Wallet."
            );
        }
        if ( recipient_wallet.wallet_type == Variables.type_of_wallet.FutureTeamWallet ) {
            require(
                sender_wallet.wallet_type == Variables.type_of_wallet.GenesisWallet,
                "SCOLT : You are not allowed to send any tokens to Future Team Wallet."
            );
        }

        if (sender_wallet.is_investor) {
            require(
                _check_time_condition(
                    block.timestamp,
                    toTimestampFromDateTime(sender_wallet.joining_date),
                    Variables._investor_swap_lock_days
                ),
                "SCOLT : Investor account can perform any transfer after 180 days only"
            );
        }

        if (variables._sellers_check_recipient && sender_wallet.anti_dump) {

            if (sender_wallet.wallet_type == Variables.type_of_wallet.DirectorWallet) {
                if (
                    _check_time_condition(
                        block.timestamp,
                        toTimestampFromDateTime(sender_wallet.last_sale_date),
                        1
                    )
                ) {
                    if (variables.amount > Variables._max_sell_per_director_per_day) {
                        revert(
                            "SCOLT : Director can only send 10000 SCOLT every 24 hours"
                        );
                    }
                } else {
                    if (
                        sender_wallet.lastday_total_sell + variables.amount >
                        Variables._max_sell_per_director_per_day
                    ) {
                        revert(
                            "SCOLT : Director can only send 10000 SCOLT every 24 hours"
                        );
                    }
                }
            }

            if (sender_wallet.wallet_type == Variables.type_of_wallet.GeneralWallet) {
                if (
                    sender_wallet.concurrent_sale_day_count >=
                    Variables._max_concurrent_sale_day
                ) {
                    if (
                        !_check_time_condition(
                            block.timestamp,
                            toTimestampFromDateTime(
                                sender_wallet.last_sale_date
                            ),
                            1
                        )
                    ) {
                        if (
                            sender_wallet.balance >= Variables._whale_per &&
                            sender_wallet.antiwhale_apply == true
                        ) {
                            if (
                                sender_wallet.lastday_total_sell + variables.amount >
                                Variables._max_sell_amount_whale
                            ) {
                                revert(
                                    "SCOLT : You can not sell more than 5000 SCOLT in past 24 hours."
                                );
                            }
                        } else {
                            if (
                                sender_wallet.lastday_total_sell + variables.amount >
                                Variables._max_sell_amount_normal
                            ) {
                                revert(
                                    "SCOLT : You can not sell more than 2000 SCOLT in past 24 hours."
                                );
                            }
                        }
                    } else {
                        if (
                            !_check_time_condition(
                                block.timestamp,
                                toTimestampFromDateTime(
                                    sender_wallet.last_sale_date
                                ),
                                Variables._cooling_days + 1
                            )
                        ) {
                            revert(
                                "SCOLT : Concurrent sell for more than 6 days not allowed. You can not sell for next 72 Hours"
                            );
                        } else {
                            if (
                                sender_wallet.balance >= Variables._whale_per &&
                                sender_wallet.antiwhale_apply == true
                            ) {
                                if (variables.amount > Variables._max_sell_amount_whale) {
                                    revert(
                                        "SCOLT : You can not sell more than 5000 SCOLT in past 24 hours."
                                    );
                                }
                            } else {
                                if (variables.amount > Variables._max_sell_amount_normal) {
                                    revert(
                                        "SCOLT : You can not sell more than 2000 SCOLT in past 24 hours."
                                    );
                                }
                            }
                        }
                    }
                } else {
                    if (
                        !_check_time_condition(
                            block.timestamp,
                            toTimestampFromDateTime(
                                sender_wallet.last_sale_date
                            ),
                            1
                        )
                    ) {
                        if (
                            sender_wallet.balance >= Variables._whale_per &&
                            sender_wallet.antiwhale_apply == true
                        ) {
                            if (
                                sender_wallet.lastday_total_sell + variables.amount >
                                Variables._max_sell_amount_whale
                            ) {
                                revert(
                                    "SCOLT : You can not sell more than 5000 SCOLT in past 24 hours."
                                );
                            }
                        } else {
                            if (
                                sender_wallet.lastday_total_sell + variables.amount >
                                Variables._max_sell_amount_normal
                            ) {
                                revert(
                                    "SCOLT : You can not sell more than 2000 SCOLT in past 24 hours."
                                );
                            }
                        }
                    } else {
                        if (
                            sender_wallet.balance >= Variables._whale_per &&
                            sender_wallet.antiwhale_apply == true
                        ) {
                            if (variables.amount > Variables._max_sell_amount_whale) {
                                revert(
                                    "SCOLT : You can not sell more than 5000 SCOLT in past 24 hours."
                                );
                            }
                        } else {
                            if (variables.amount > Variables._max_sell_amount_normal) {
                                revert(
                                    "SCOLT : You can not sell more than 2000 SCOLT in past 24 hours."
                                );
                            }
                        }
                    }
                }
            }
        }
    }

    function _after_transfer_updates(
        uint256 amount,
        Variables.wallet_details memory sender_wallet,
        bool _sellers_check_recipient
    ) public view returns (
        Variables.wallet_details memory
    ){

        Variables._DateTime memory tdt = parseTimestamp(block.timestamp);
        Variables._DateTime memory lsd;

        lsd = Variables._DateTime(tdt.year, tdt.month, tdt.day, 0, 0, 0, tdt.weekday);

        if (_sellers_check_recipient) {
            if (sender_wallet.wallet_type == Variables.type_of_wallet.GeneralWallet) {
                if (
                    _check_time_condition(
                        block.timestamp,
                        toTimestampFromDateTime(sender_wallet.last_sale_date),
                        1
                    )
                ) {
                    sender_wallet.lastday_total_sell = 0; // reseting sale at 24 hours
                    if (
                        _check_time_condition(
                            block.timestamp,
                            toTimestampFromDateTime(
                                sender_wallet.last_sale_date
                            ),
                            2
                        )
                    ) {
                        sender_wallet.concurrent_sale_day_count = 1;
                    } else {
                        sender_wallet.concurrent_sale_day_count = sender_wallet
                            .concurrent_sale_day_count
                            .add(1);
                    }
                    sender_wallet.last_sale_date = lsd;
                    sender_wallet.lastday_total_sell = sender_wallet
                        .lastday_total_sell
                        .add(amount);
                } else {
                    sender_wallet.lastday_total_sell = sender_wallet
                        .lastday_total_sell
                        .add(amount);
                    if (sender_wallet.concurrent_sale_day_count == 0) {
                        sender_wallet.concurrent_sale_day_count = 1;
                        sender_wallet.last_sale_date = lsd;
                    }
                }
            }
            if (sender_wallet.wallet_type == Variables.type_of_wallet.DirectorWallet) {
                if (
                    _check_time_condition(
                        block.timestamp,
                        toTimestampFromDateTime(sender_wallet.last_sale_date),
                        1
                    )
                ) {
                    sender_wallet.lastday_total_sell = 0; // reseting director sale at 24 hours
                    sender_wallet.last_sale_date = lsd;
                    sender_wallet.lastday_total_sell = sender_wallet
                        .lastday_total_sell
                        .add(amount);
                } else {
                    sender_wallet.lastday_total_sell = sender_wallet
                        .lastday_total_sell
                        .add(amount);
                    if (sender_wallet.concurrent_sale_day_count == 0) {
                        sender_wallet.concurrent_sale_day_count = 1;
                        sender_wallet.last_sale_date = lsd;
                    }
                }
            }
        }
        return sender_wallet;
    }

    function contributionsCalc(
        Variables.wallet_details memory sender_wallet,
        Variables.wallet_details memory recipient_wallet,
        Variables.wallet_details memory marketing_wallet,
        Variables.wallet_details memory development_wallet,
        Variables.function_addresses memory addresses,
        Variables.function_amounts memory amounts
    ) public pure returns (
        Variables.distribution_variables memory,
        bool, // Sender Contribution Deduct ?
        Variables.wallet_details memory, // marketing wallet update
        Variables.wallet_details memory, // development wallet update
        uint256, // pending contribution update
        uint256, // total supply update
        uint256 // burning till now update
    ) {

        Variables.distribution_variables memory dv;

        if (addresses.sender == addresses.owner || addresses.sender == addresses.this_address) {
            return (
                dv,
                true,
                marketing_wallet,
                development_wallet,
                amounts.pending_contribution_to_distribute,
                amounts.total_supply,
                amounts.burning_till_now
            );
        }

        if (sender_wallet.contribution_apply == false) {
            return (
                dv,
                true,
                marketing_wallet,
                development_wallet,
                amounts.pending_contribution_to_distribute,
                amounts.total_supply,
                amounts.burning_till_now
            );
        }

        if (
            sender_wallet.balance >=  Variables._whale_per &&
            sender_wallet.antiwhale_apply == true
        ) {
            dv.total_contributions = ((amounts.amount * Variables._whale_contribution_per) / 100);
            dv.marketing_contributions = ((dv.total_contributions * Variables._whale_marketing_share) / 100);
            dv.development_contributions = ((dv.total_contributions * Variables._whale_development_share) / 100);
            dv.holder_contributions = ((dv.total_contributions * Variables._whale_holder_share) / 100);
            dv.burn_amount = ((dv.total_contributions * Variables._whale_burning_share) / 100);
        } else {
            dv.total_contributions = ((amounts.amount * Variables._normal_contribution_per) / 100);
            dv.marketing_contributions = ((dv.total_contributions * Variables._normal_marketing_share) / 100);
            dv.development_contributions = ((dv.total_contributions * Variables._normal_development_share) / 100);
            dv.holder_contributions = ((dv.total_contributions * Variables._normal_holder_share) / 100);
            dv.burn_amount = ((dv.total_contributions * Variables._normal_burning_share) / 100);
        }

        if (amounts.total_supply < (amounts.initial_total_supply / 2)) {
            dv.total_contributions = dv.total_contributions.sub(dv.burn_amount);
            dv.burn_amount = 0;
        }

        bool sender_contribution_deduct = false;

        if (
            (sender_wallet.balance >= amounts.amount + dv.total_contributions) &&
            (recipient_wallet.wallet_type != Variables.type_of_wallet.DexPairWallet)
        ) {
            if (dv.marketing_contributions > 0) {
                marketing_wallet.balance = marketing_wallet.balance.add(dv.marketing_contributions);
            }

            if (dv.development_contributions > 0) {
                development_wallet.balance = development_wallet.balance.add(dv.development_contributions);
            }

            if (dv.holder_contributions > 0) {
                amounts.pending_contribution_to_distribute = amounts.pending_contribution_to_distribute.add(
                    dv.holder_contributions
                );
            }

            if (dv.burn_amount > 0) {
                amounts.total_supply = amounts.total_supply.sub(dv.burn_amount);
                amounts.burning_till_now = amounts.burning_till_now.add(dv.burn_amount);
            }
            sender_contribution_deduct = true;
        } else {
            if (dv.marketing_contributions > 0) {
                marketing_wallet.balance = marketing_wallet.balance.add(dv.marketing_contributions);
            }

            if (dv.development_contributions > 0) {
                development_wallet.balance = development_wallet.balance.add(dv.development_contributions);
            }

            if (dv.holder_contributions > 0) {
                amounts.pending_contribution_to_distribute = amounts.pending_contribution_to_distribute.add(
                    dv.holder_contributions
                );
            }

            if (dv.burn_amount > 0) {
                amounts.total_supply = amounts.total_supply.sub(dv.burn_amount);
                amounts.burning_till_now = amounts.burning_till_now.add(dv.burn_amount);
            }
        }

        return (
            dv,
            sender_contribution_deduct,
            marketing_wallet,
            development_wallet,
            amounts.pending_contribution_to_distribute,
            amounts.total_supply,
            amounts.burning_till_now
        );
    }
}
