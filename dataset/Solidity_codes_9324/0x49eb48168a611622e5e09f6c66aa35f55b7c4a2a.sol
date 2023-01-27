pragma solidity ^0.5.10;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity ^0.5.10;


contract Agent is Ownable {

    mapping(address => bool) public Agents;

    event UpdatedAgent(address _agent, bool _status);

    modifier onlyAgent() {

        assert(Agents[msg.sender]);
        _;
    }

    function updateAgent(address _agent, bool _status) public onlyOwner {

        assert(_agent != address(0));
        Agents[_agent] = _status;

        emit UpdatedAgent(_agent, _status);
    }
}
pragma solidity ^0.5.10;

library SafeMath {


    function perc(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        c = c / 10000; // percent to hundredths

        return c;
    }

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
pragma solidity ^0.5.10;

interface CashBackMoneyI {

    function Subscribe(uint256 refererID) external payable;

}
pragma solidity ^0.5.10;


contract CashBackMoney is CashBackMoneyI, Agent {

    using SafeMath for uint256;

    uint256 public constant amount1 = 0.05 ether;
    uint256 public constant amount2 = 0.10 ether;
    uint256 public constant amount3 = 0.50 ether;
    uint256 public constant amount4 = 1.00 ether;
    uint256 public constant amount5 = 5.00 ether;
    uint256 public constant amount6 = 10.00 ether;

    uint256 public constant subs_amount1 = 1.00 ether;
    uint256 public constant subs_amount2 = 5.00 ether;
    uint256 public constant subs_amount3 = 10.00 ether;

    uint256 public constant subs_amount_with_fee1 = 1.18 ether;
    uint256 public constant subs_amount_with_fee2 = 5.90 ether;
    uint256 public constant subs_amount_with_fee3 = 11.80 ether;

    uint256 days1 = 1 days;
    uint256 hours24 = 24 hours;
    uint256 hours3 = 3 hours;

    bool public production = false;
    uint256 public deploy_block;

    address payable public reward_account;
    uint256 public reward;
    uint256 public start_point;

    uint256 public NumberOfParticipants = 0;
    uint256 public NumberOfClicks = 0;
    uint256 public NumberOfSubscriptions = 0;
    uint256 public ProfitPayoutAmount = 0;
    uint256 public FundBalance = 0;

    uint256 public LastRefererID = 0;

    mapping(address => uint256) public RefererID;

    mapping(uint256 => address) public RefererAddr;

    mapping(address => uint256) public Referer;

    mapping(address => bool) public Participants;

    mapping(address => mapping(uint256 => bool)) public OwnerAmountStatus;

    mapping(address => mapping(uint256 => uint256)) public RefClickCount;

    mapping(address => uint256) public OwnerTotalProfit;

    mapping(address => uint256) public RefTotalClicks;

    mapping(address => uint256) public RefTotalIncome;

    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public Balances;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public WithdrawDate;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public OwnerAutoClickCount;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public RefAutoClickCount;

    mapping(address => mapping(uint256 => bool)) public AutoBalances;

    mapping(address => mapping(uint256 => uint256)) public WithdrawAutoDate;

    mapping(address => mapping(uint256 => uint256)) public Subscriptions;

    mapping(address => mapping(uint256 => uint256)) public Intermediate;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public RefSubscCount;

    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public RefSubscStatus;

    event ChangeContractBalance(string text);

    event ChangeClickRefefalNumbers(
        address indexed referer,
        uint256 amount,
        uint256 number
    );

    event AmountInvestedByPay(address indexed owner, uint256 amount);
    event AmountInvestedByAutoPay(address indexed owner, uint256 amount);
    event AmountInvestedBySubscription(address indexed owner, uint256 amount);

    event AmountWithdrawnFromPay(address indexed owner, uint256 amount);
    event AmountWithdrawnFromAutoPay(address indexed owner, uint256 amount);
    event AmountWithdrawnFromSubscription(
        address indexed owner,
        uint256 amount
    );

    constructor(
        address payable _reward_account,
        uint256 _reward,
        uint256 _start_point,
        bool _mode
    ) public {
        reward_account = _reward_account;
        reward = _reward;
        start_point = _start_point;

        production = _mode;
        deploy_block = block.number;
    }

    modifier onlyFixedAmount(uint256 _amount) {

        require(
            _amount == amount1 ||
                _amount == amount2 ||
                _amount == amount3 ||
                _amount == amount4 ||
                _amount == amount5 ||
                _amount == amount6,
            "CashBackMoney: wrong msg.value"
        );
        _;
    }

    modifier onlyFixedAmountSubs(uint256 _amount) {

        require(
            _amount == subs_amount_with_fee1 ||
                _amount == subs_amount_with_fee2 ||
                _amount == subs_amount_with_fee3,
            "CashBackMoney: wrong msg.value for subscription"
        );
        _;
    }

    modifier onlyFixedAmountWithdrawSubs(uint256 _amount) {

        require(
            _amount == subs_amount1 ||
                _amount == subs_amount2 ||
                _amount == subs_amount3,
            "CashBackMoney: wrong msg.value for subscription"
        );
        _;
    }

    modifier onlyInStagingMode() {

        require(
            !production,
            "CashBackMoney: this function can only be used in the stage mode"
        );
        _;
    }

    function() external payable {
        if (
            (msg.value == subs_amount_with_fee1) ||
            (msg.value == subs_amount_with_fee2) ||
            (msg.value == subs_amount_with_fee3)
        ) {
            Subscribe(0);
        } else if (msg.value > 0) {
            PayAll(msg.value);
        } else {
            WithdrawPayAll();
            WithdrawSubscribeAll();
        }
    }

    function TopUpContract() external payable {

        require(msg.value > 0, "TopUpContract: msg.value must be great than 0");
        emit ChangeContractBalance("Thank you very much");
    }

    function GetPeriod(uint256 _timestamp)
        internal
        view
        returns (uint256 _period)
    {

        return (_timestamp.sub(start_point)).div(days1);
    }

    function Pay(uint256 _level, uint256 _refererID)
        external
        payable
        onlyFixedAmount(msg.value)
    {

        if (RefererID[msg.sender] == 0) {
            CreateRefererID(msg.sender);
        }

        require(
            RefererID[msg.sender] != _refererID,
            "Pay: you cannot be a referral to yourself"
        );
        require(_level > 0 && _level < 4, "Pay: level can only be 1,2 or 3");
        require(
            !Balances[msg.sender][_level][msg.value],
            "Pay: amount already paid"
        );

        if (!OwnerAmountStatus[msg.sender][msg.value]) {
            OwnerAmountStatus[msg.sender][msg.value] = true;
        }

        if ((Referer[msg.sender] == 0) && (_refererID != 0)) {
            Referer[msg.sender] = _refererID;
        }

        if (
            (Referer[msg.sender] != 0) &&
            (OwnerAmountStatus[RefererAddr[Referer[msg.sender]]][msg.value])
        ) {
            RefTotalClicks[RefererAddr[Referer[msg.sender]]] += 1;
            RefTotalIncome[RefererAddr[Referer[msg.sender]]] += msg.value;

            RefClickCount[RefererAddr[Referer[msg.sender]]][msg.value] += 1;
            emit ChangeClickRefefalNumbers(
                RefererAddr[Referer[msg.sender]],
                msg.value,
                RefClickCount[RefererAddr[Referer[msg.sender]]][msg.value]
            );

            uint256 Current = GetPeriod(now);
            uint256 Start = Current - 30;

            OwnerAutoClickCount[msg.sender][msg.value][Current] += 1;

            uint256 CountOp = 0;

            for (uint256 k = Start; k < Current; k++) {
                CountOp += OwnerAutoClickCount[msg.sender][msg.value][k];
            }

            if (CountOp >= 30) {
                RefAutoClickCount[RefererAddr[Referer[msg.sender]]][msg
                    .value][Current] += 1;
            }
        }

        uint256 refs;
        uint256 wd_time;

        if (_level == 1) {
            if (RefClickCount[msg.sender][msg.value] > 21) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][msg.value];
            }
        }

        if (_level == 2) {
            require(
                RefClickCount[msg.sender][msg.value] >= 21,
                "Pay: not enough referrals"
            );
            if (RefClickCount[msg.sender][msg.value] > 42) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][msg.value].sub(21);
            }
        }

        if (_level == 3) {
            require(
                RefClickCount[msg.sender][msg.value] >= 42,
                "Pay: not enough referrals"
            );
            if (RefClickCount[msg.sender][msg.value] > 63) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][msg.value].sub(42);
            }
        }

        wd_time = now.add(hours24);
        wd_time = wd_time.sub((refs.div(3)).mul(hours3));

        RefClickCount[msg.sender][msg.value] = RefClickCount[msg.sender][msg
            .value]
            .sub(refs.div(3).mul(3));
        emit ChangeClickRefefalNumbers(
            msg.sender,
            msg.value,
            RefClickCount[msg.sender][msg.value]
        );

        Balances[msg.sender][_level][msg.value] = true;
        WithdrawDate[msg.sender][_level][msg.value] = wd_time;

        reward_account.transfer(msg.value.perc(reward));

        if (!Participants[msg.sender]) {
            Participants[msg.sender] = true;
            NumberOfParticipants += 1;
        }

        FundBalance += msg.value.perc(reward);
        NumberOfClicks += 1;
        emit AmountInvestedByPay(msg.sender, msg.value);
    }

    function WithdrawPay(uint256 _level, uint256 _amount)
        external
        onlyFixedAmount(_amount)
    {

        require(
            Balances[msg.sender][_level][_amount],
            "WithdrawPay: amount has not yet been paid"
        );
        require(
            now >= WithdrawDate[msg.sender][_level][_amount],
            "WithdrawPay: time has not come yet"
        );

        Balances[msg.sender][_level][_amount] = false;
        WithdrawDate[msg.sender][_level][_amount] = 0;

        uint256 Amount = _amount.add(_amount.perc(100));
        msg.sender.transfer(Amount);

        OwnerTotalProfit[msg.sender] += _amount.perc(100);
        ProfitPayoutAmount += Amount;
        emit AmountWithdrawnFromPay(msg.sender, Amount);
    }

    function PayAll(uint256 _amount) internal onlyFixedAmount(_amount) {

        uint256 refs;
        uint256 wd_time;
        uint256 level = 0;

        if (RefererID[msg.sender] == 0) {
            CreateRefererID(msg.sender);
        }

        if (!Balances[msg.sender][1][_amount]) {
            level = 1;
            if (RefClickCount[msg.sender][_amount] > 21) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][_amount];
            }
        }

        if (
            (level == 0) &&
            (!Balances[msg.sender][2][_amount]) &&
            (RefClickCount[msg.sender][_amount] >= 21)
        ) {
            level = 2;
            if (RefClickCount[msg.sender][_amount] > 42) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][_amount].sub(21);
            }
        }

        if (
            (level == 0) &&
            (!Balances[msg.sender][3][_amount]) &&
            (RefClickCount[msg.sender][_amount] >= 42)
        ) {
            level = 3;
            if (RefClickCount[msg.sender][_amount] > 63) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][_amount].sub(42);
            }
        }

        require(
            level > 0,
            "PayAll: amount already paid or not enough referals"
        );

        wd_time = now.add(hours24);
        wd_time = wd_time.sub((refs.div(3)).mul(hours3));

        RefClickCount[msg.sender][msg.value] = RefClickCount[msg.sender][msg
            .value]
            .sub(refs.div(3).mul(3));
        emit ChangeClickRefefalNumbers(
            msg.sender,
            msg.value,
            RefClickCount[msg.sender][msg.value]
        );

        Balances[msg.sender][level][_amount] = true;
        WithdrawDate[msg.sender][level][_amount] = wd_time;

        reward_account.transfer(_amount.perc(reward));

        if (!Participants[msg.sender]) {
            Participants[msg.sender] = true;
            NumberOfParticipants += 1;
        }

        FundBalance += _amount.perc(reward);
        NumberOfClicks += 1;
        emit AmountInvestedByPay(msg.sender, _amount);
    }

    function WithdrawPayAll() public {

        uint256 Amount = 0;

        for (uint256 i = 1; i <= 3; i++) {
            if (
                (Balances[msg.sender][i][amount1]) &&
                (now >= WithdrawDate[msg.sender][i][amount1])
            ) {
                Balances[msg.sender][i][amount1] = false;
                WithdrawDate[msg.sender][i][amount1] = 0;
                Amount += amount1.add(amount1.perc(100));
                OwnerTotalProfit[msg.sender] += amount1.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount2]) &&
                (now >= WithdrawDate[msg.sender][i][amount2])
            ) {
                Balances[msg.sender][i][amount2] = false;
                WithdrawDate[msg.sender][i][amount2] = 0;
                Amount += amount2.add(amount2.perc(100));
                OwnerTotalProfit[msg.sender] += amount2.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount3]) &&
                (now >= WithdrawDate[msg.sender][i][amount3])
            ) {
                Balances[msg.sender][i][amount3] = false;
                WithdrawDate[msg.sender][i][amount3] = 0;
                Amount += amount3.add(amount3.perc(100));
                OwnerTotalProfit[msg.sender] += amount3.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount4]) &&
                (now >= WithdrawDate[msg.sender][i][amount4])
            ) {
                Balances[msg.sender][i][amount4] = false;
                WithdrawDate[msg.sender][i][amount4] = 0;
                Amount += amount4.add(amount4.perc(100));
                OwnerTotalProfit[msg.sender] += amount4.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount5]) &&
                (now >= WithdrawDate[msg.sender][i][amount5])
            ) {
                Balances[msg.sender][i][amount5] = false;
                WithdrawDate[msg.sender][i][amount5] = 0;
                Amount += amount5.add(amount5.perc(100));
                OwnerTotalProfit[msg.sender] += amount5.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount6]) &&
                (now >= WithdrawDate[msg.sender][i][amount6])
            ) {
                Balances[msg.sender][i][amount6] = false;
                WithdrawDate[msg.sender][i][amount6] = 0;
                Amount += amount6.add(amount6.perc(100));
                OwnerTotalProfit[msg.sender] += amount6.perc(100);
            }
        }

        if (Amount > 0) {
            msg.sender.transfer(Amount);

            ProfitPayoutAmount += Amount;
            emit AmountWithdrawnFromPay(msg.sender, Amount);
        }
    }

    function AutoPay(uint256 _refererID)
        external
        payable
        onlyFixedAmount(msg.value)
    {

        if (RefererID[msg.sender] == 0) {
            CreateRefererID(msg.sender);
        }

        require(
            RefererID[msg.sender] != _refererID,
            "AutoPay: you cannot be a referral to yourself"
        );
        require(
            !AutoBalances[msg.sender][msg.value],
            "AutoPay: amount already paid"
        );

        if ((Referer[msg.sender] == 0) && (_refererID != 0)) {
            Referer[msg.sender] = _refererID;
        }

        if (
            (Referer[msg.sender] != 0) &&
            (OwnerAmountStatus[RefererAddr[Referer[msg.sender]]][msg.value])
        ) {
            RefTotalClicks[RefererAddr[Referer[msg.sender]]] += 1;
            RefTotalIncome[RefererAddr[Referer[msg.sender]]] += msg.value;

            RefClickCount[RefererAddr[Referer[msg.sender]]][msg.value] += 1;
            emit ChangeClickRefefalNumbers(
                RefererAddr[Referer[msg.sender]],
                msg.value,
                RefClickCount[RefererAddr[Referer[msg.sender]]][msg.value]
            );

            uint256 Current = GetPeriod(now);
            uint256 Start = Current - 30;

            OwnerAutoClickCount[msg.sender][msg.value][Current] += 1;

            uint256 CountOp = 0;

            for (uint256 k = Start; k < Current; k++) {
                CountOp += OwnerAutoClickCount[msg.sender][msg.value][k];
            }

            if (CountOp >= 30) {
                RefAutoClickCount[RefererAddr[Referer[msg.sender]]][msg
                    .value][Current] += 1;
            }
        }

        uint256 Current = GetPeriod(now);
        uint256 Start = Current - 30;

        uint256 Count1 = 0;
        uint256 Count2 = 0;
        uint256 Count3 = 0;
        uint256 Count4 = 0;
        uint256 Count5 = 0;
        uint256 Count6 = 0;

        for (uint256 k = Start; k < Current; k++) {
            Count1 += RefAutoClickCount[msg.sender][amount1][k];
            Count2 += RefAutoClickCount[msg.sender][amount2][k];
            Count3 += RefAutoClickCount[msg.sender][amount3][k];
            Count4 += RefAutoClickCount[msg.sender][amount4][k];
            Count5 += RefAutoClickCount[msg.sender][amount5][k];
            Count6 += RefAutoClickCount[msg.sender][amount6][k];
        }

        require(Count1 > 62, "AutoPay: not enough autoclick1 referrals");
        require(Count2 > 62, "AutoPay: not enough autoclick2 referrals");
        require(Count3 > 62, "AutoPay: not enough autoclick3 referrals");
        require(Count4 > 62, "AutoPay: not enough autoclick4 referrals");
        require(Count5 > 62, "AutoPay: not enough autoclick5 referrals");
        require(Count6 > 62, "AutoPay: not enough autoclick6 referrals");

        AutoBalances[msg.sender][msg.value] = true;
        WithdrawAutoDate[msg.sender][msg.value] = now.add(hours24);

        reward_account.transfer(msg.value.perc(reward));

        if (!Participants[msg.sender]) {
            Participants[msg.sender] = true;
            NumberOfParticipants += 1;
        }

        FundBalance += msg.value.perc(reward);
        NumberOfClicks += 1;
        emit AmountInvestedByAutoPay(msg.sender, msg.value);
    }

    function WithdrawAutoPay(uint256 _amount)
        external
        onlyFixedAmount(_amount)
    {

        require(
            AutoBalances[msg.sender][_amount],
            "WithdrawAutoPay: autoclick amount has not yet been paid"
        );
        require(
            now >= WithdrawAutoDate[msg.sender][_amount],
            "WithdrawAutoPay: autoclick time has not come yet"
        );

        AutoBalances[msg.sender][_amount] = false;
        WithdrawAutoDate[msg.sender][_amount] = 0;

        uint256 Amount = _amount.add(_amount.perc(800));
        msg.sender.transfer(Amount);

        OwnerTotalProfit[msg.sender] += _amount.perc(800);
        ProfitPayoutAmount += Amount;
        emit AmountWithdrawnFromAutoPay(msg.sender, Amount);
    }

    function Subscribe(uint256 _refererID)
        public
        payable
        onlyFixedAmountSubs(msg.value)
    {

        if (RefererID[msg.sender] == 0) {
            CreateRefererID(msg.sender);
        }

        require(
            RefererID[msg.sender] != _refererID,
            "Subscribe: you cannot be a referral to yourself"
        );

        uint256 reward_amount = msg.value.perc(reward);

        uint256 Amount;

        if (msg.value == subs_amount_with_fee1) {
            Amount = subs_amount1;
        } else if (msg.value == subs_amount_with_fee2) {
            Amount = subs_amount2;
        } else if (msg.value == subs_amount_with_fee3) {
            Amount = subs_amount3;
        } else {
            require(
                true,
                "Subscribe: something went wrong, should not get here"
            );
        }

        require(
            Subscriptions[msg.sender][Amount] == 0,
            "Subscribe: subscription already paid"
        );

        if ((Referer[msg.sender] == 0) && (_refererID != 0)) {
            Referer[msg.sender] = _refererID;
        }

        if (Referer[msg.sender] != 0) {
            RefTotalIncome[RefererAddr[Referer[msg.sender]]] += msg.value;
        }

        uint256 Period = GetPeriod(now);

        if (
            (Referer[msg.sender] != 0) &&
            (!RefSubscStatus[msg.sender][Amount][Period])
        ) {
            RefSubscCount[RefererAddr[Referer[msg
                .sender]]][Amount][Period] += 1;
            RefSubscStatus[msg.sender][Amount][Period] = true;
        }

        Subscriptions[msg.sender][Amount] = now;

        reward_account.transfer(reward_amount);

        if (!Participants[msg.sender]) {
            Participants[msg.sender] = true;
            NumberOfParticipants += 1;
        }

        FundBalance += reward_amount;
        NumberOfSubscriptions += 1;
        emit AmountInvestedBySubscription(msg.sender, Amount);
    }

    function WithdrawSubscribe(uint256 _amount)
        external
        onlyFixedAmountWithdrawSubs(_amount)
    {

        require(
            Subscriptions[msg.sender][_amount] > 0,
            "WithdrawSubscribe: subscription has not yet been paid"
        );

        uint256 Start;
        uint256 Finish;
        uint256 Current = GetPeriod(now);

        Start = GetPeriod(Subscriptions[msg.sender][_amount]);
        Finish = Start + 30;

        require(
            Current > Start,
            "WithdrawSubscribe: the withdrawal time has not yet arrived"
        );

        uint256 Amount = WithdrawAmountCalculate(msg.sender, _amount);

        msg.sender.transfer(Amount);

        ProfitPayoutAmount += Amount;
        emit AmountWithdrawnFromSubscription(msg.sender, Amount);
    }

    function WithdrawSubscribeAll() internal {

        uint256 Amount = WithdrawAmountCalculate(msg.sender, subs_amount1);
        Amount += WithdrawAmountCalculate(msg.sender, subs_amount2);
        Amount += WithdrawAmountCalculate(msg.sender, subs_amount3);

        if (Amount > 0) {
            msg.sender.transfer(Amount);

            ProfitPayoutAmount += Amount;
            emit AmountWithdrawnFromSubscription(msg.sender, Amount);
        }
    }

    function WithdrawAmountCalculate(address _sender, uint256 _amount)
        internal
        returns (uint256)
    {

        if (Subscriptions[_sender][_amount] == 0) {
            return 0;
        }

        uint256 Start;
        uint256 Finish;
        uint256 Current = GetPeriod(now);

        Start = GetPeriod(Subscriptions[_sender][_amount]);
        Finish = Start + 30;

        if (Current <= Start) {
            return 0;
        }

        if (Intermediate[_sender][_amount] == 0) {
            Intermediate[_sender][_amount] = now;
        } else {
            Start = GetPeriod(Intermediate[_sender][_amount]);
            Intermediate[_sender][_amount] = now;
        }

        uint256[30] memory Count;
        uint256 Amount = 0;
        uint256 Profit = 0;

        if (Current >= Finish) {
            Current = Finish;
            Subscriptions[_sender][_amount] = 0;
            Intermediate[_sender][_amount] = 0;
            Amount += _amount;
        }

        uint256 i = Start - 30;
        uint256 j = 0;
        uint256 k = 0;

        while (i < Current) {
            if (i <= Start) {
                j = 0;
            } else {
                j = i - Start;
            }

            while ((j <= k) && (Start + j < Current)) {
                Count[j] += RefSubscCount[_sender][_amount][i];
                j++;
            }
            i++;
            k++;
        }

        for (i = 0; i < (Current - Start); i++) {
            if (Count[i] > 15) {
                Count[i] = 15;
            }
            Profit += _amount.perc(200 + Count[i].mul(15));
        }

        OwnerTotalProfit[msg.sender] += Profit;
        Amount = Amount.add(Profit);
        return Amount;
    }

    function SetRefClickCount(address _address, uint256 _sum, uint256 _count)
        external
        onlyInStagingMode
    {

        RefClickCount[_address][_sum] = _count;
    }

    function SetOwnerAutoClickCountAll(
        uint256 _count1,
        uint256 _count2,
        uint256 _count3,
        uint256 _count4,
        uint256 _count5,
        uint256 _count6
    ) external onlyInStagingMode {

        OwnerAutoClickCount[msg.sender][amount1][GetPeriod(now)] = _count1;
        OwnerAutoClickCount[msg.sender][amount2][GetPeriod(now)] = _count2;
        OwnerAutoClickCount[msg.sender][amount3][GetPeriod(now)] = _count3;
        OwnerAutoClickCount[msg.sender][amount4][GetPeriod(now)] = _count4;
        OwnerAutoClickCount[msg.sender][amount5][GetPeriod(now)] = _count5;
        OwnerAutoClickCount[msg.sender][amount6][GetPeriod(now)] = _count6;
    }

    function SetRefAutoClickCount(
        address _address,
        uint256 _sum,
        uint256 _period,
        uint256 _count
    ) external onlyInStagingMode {

        RefAutoClickCount[_address][_sum][_period] = _count;
    }

    function SetRefAutoClickCountAll(
        uint256 _count1,
        uint256 _count2,
        uint256 _count3,
        uint256 _count4,
        uint256 _count5,
        uint256 _count6
    ) external onlyInStagingMode {

        RefAutoClickCount[msg.sender][amount1][GetPeriod(now)] = _count1;
        RefAutoClickCount[msg.sender][amount2][GetPeriod(now)] = _count2;
        RefAutoClickCount[msg.sender][amount3][GetPeriod(now)] = _count3;
        RefAutoClickCount[msg.sender][amount4][GetPeriod(now)] = _count4;
        RefAutoClickCount[msg.sender][amount5][GetPeriod(now)] = _count5;
        RefAutoClickCount[msg.sender][amount6][GetPeriod(now)] = _count6;
    }

    function SetRefSubscCount(
        address _address,
        uint256 _sum,
        uint256 _period,
        uint256 _count
    ) external onlyInStagingMode {

        RefSubscCount[_address][_sum][_period] = _count;
    }

    function SetValues(
        uint256 _NumberOfParticipants,
        uint256 _NumberOfClicks,
        uint256 _NumberOfSubscriptions,
        uint256 _ProfitPayoutAmount,
        uint256 _FundBalance
    ) external onlyInStagingMode {

        NumberOfParticipants = _NumberOfParticipants;
        NumberOfClicks = _NumberOfClicks;
        NumberOfSubscriptions = _NumberOfSubscriptions;
        ProfitPayoutAmount = _ProfitPayoutAmount;
        FundBalance = _FundBalance;
    }

    function GetCurrentPeriod() external view returns (uint256 _period) {

        return GetPeriod(now);
    }

    function GetFixedPeriod(uint256 _timestamp)
        external
        view
        returns (uint256 _period)
    {

        return GetPeriod(_timestamp);
    }

    function GetAutoClickRefsNumber()
        external
        view
        returns (uint256 number_of_referrals)
    {

        uint256 Current = GetPeriod(now);
        uint256 Start = Current - 30;

        uint256 Count1 = 0;
        uint256 Count2 = 0;
        uint256 Count3 = 0;
        uint256 Count4 = 0;
        uint256 Count5 = 0;
        uint256 Count6 = 0;

        for (uint256 k = Start; k < Current; k++) {
            Count1 += RefAutoClickCount[msg.sender][amount1][k];
            Count2 += RefAutoClickCount[msg.sender][amount2][k];
            Count3 += RefAutoClickCount[msg.sender][amount3][k];
            Count4 += RefAutoClickCount[msg.sender][amount4][k];
            Count5 += RefAutoClickCount[msg.sender][amount5][k];
            Count6 += RefAutoClickCount[msg.sender][amount6][k];
        }

        if (Count1 > 63) {
            Count1 = 63;
        }
        if (Count2 > 63) {
            Count2 = 63;
        }
        if (Count3 > 63) {
            Count3 = 63;
        }
        if (Count4 > 63) {
            Count4 = 63;
        }
        if (Count5 > 63) {
            Count5 = 63;
        }
        if (Count6 > 63) {
            Count6 = 63;
        }

        return Count1 + Count2 + Count3 + Count4 + Count5 + Count6;
    }

    function GetSubscribeRefsNumber(uint256 _amount)
        external
        view
        onlyFixedAmount(_amount)
        returns (uint256 number_of_referrals)
    {

        uint256 Current = GetPeriod(now);
        uint256 Start = Current - 30;

        uint256 Count = 0;
        for (uint256 k = Start; k < Current; k++) {
            Count += RefSubscCount[msg.sender][_amount][k];
        }

        if (Count > 15) {
            Count = 15;
        }

        return Count;
    }

    function GetSubscribeIncome(uint256 _amount)
        external
        view
        onlyFixedAmount(_amount)
        returns (uint256 income)
    {

        uint256 Start = GetPeriod(now);
        uint256 Finish = Start + 30;

        uint256[30] memory Count;
        uint256 Amount = 0;

        uint256 i = Start - 30;
        uint256 j = 0;
        uint256 k = 0;

        while (i < Finish) {
            if (i <= Start) {
                j = 0;
            } else {
                j = i - Start;
            }

            while ((j <= k) && (Start + j < Finish)) {
                Count[j] += RefSubscCount[msg.sender][_amount][i];
                j++;
            }
            i++;
            k++;
        }

        for (i = 0; i < (Finish - Start); i++) {
            if (Count[i] > 15) {
                Count[i] = 15;
            }
            Amount += _amount.perc(200 + Count[i].mul(15));
        }

        return Amount;
    }

    function GetSubscribeFinish(uint256 _amount)
        external
        view
        onlyFixedAmount(_amount)
        returns (uint256 finish)
    {

        if (Subscriptions[msg.sender][_amount] == 0) {
            return 0;
        }

        uint256 Start = GetPeriod(Subscriptions[msg.sender][_amount]);
        uint256 Finish = Start + 30;

        return Finish.mul(days1).add(start_point);
    }

    function GetSubscribeNearPossiblePeriod(uint256 _amount)
        external
        view
        onlyFixedAmount(_amount)
        returns (uint256 timestamp)
    {

        if (Subscriptions[msg.sender][_amount] == 0) {
            return 0;
        }

        uint256 Current = GetPeriod(now);
        uint256 Start = GetPeriod(Subscriptions[msg.sender][_amount]);

        if (Intermediate[msg.sender][_amount] != 0) {
            Start = GetPeriod(Intermediate[msg.sender][_amount]);
        }

        if (Current > Start) {
            return now;
        } else {
            return Start.add(1).mul(days1).add(start_point);
        }
    }

    function CreateRefererID(address _referer) internal {

        require(
            RefererID[_referer] == 0,
            "CreateRefererID: referal id already assigned"
        );

        bytes32 hash = keccak256(abi.encodePacked(now, _referer));

        RefererID[_referer] = LastRefererID.add((uint256(hash) % 13) + 1);
        LastRefererID = RefererID[_referer];
        RefererAddr[LastRefererID] = _referer;
    }
}
pragma solidity ^0.5.10;

interface ERC20I {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.10;


contract ERC20 is ERC20I {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}