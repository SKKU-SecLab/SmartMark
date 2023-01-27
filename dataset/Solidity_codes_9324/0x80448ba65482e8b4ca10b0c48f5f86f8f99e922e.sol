pragma solidity ^0.8.0;

interface IIBGEvents {


    event Registration(address indexed _user, address indexed referrer, uint registrationTime);
    event PackPurchased(address indexed _user, uint indexed _pack, uint _plan, uint currentPackAmount, uint time);
    event StakedToken(address indexed stakedBy, uint amountStaked, uint plan, uint time, uint stakingPeriod);
    event DirectReferralIncome(address indexed _from, address indexed receiver, uint incomeRecieved, uint indexed level, uint time);
    event LostIncome(address indexed _from, address indexed reciever, uint incomeLost, uint indexed level, uint time);
    event YieldIncome(address indexed user, uint yieldRecieved, uint time);
    event YieldMatchingIncome(address indexed _from, address indexed receiver, uint incomeRecieved, uint indexed level, uint time);
    event YieldMatchingLostIncome(address indexed _from, address indexed reciever, uint matchingLostIncome, uint indexed level, uint time);
}


library InvestmentLibrary {


    struct Investment {
        uint plan;
        uint investment;
        uint investmentTime;
        uint stakingPeriod;
        uint yieldRateValue;
        bool isUnstaked;
        bool withdrawInvestment;
    }
}


library IBGLibrary {


    struct IBGPlan {
        uint IBGTokens;
        uint stakedIBGTokens;
        uint IBGYieldIncome;
        uint IBGYieldMatchingIncome;
        uint IBGYieldMatchingLostIncome;
        uint withdrawnInvestment;
        uint withdrawnYield;
    }
}


library UserLibrary {


    struct User {
        uint referralCount;
        uint directReferrerIncome;
        uint lostIncome;
        uint currentPlan;
        uint investmentCount;
        address referrer;
    }

    function exists(User storage self) internal view returns (bool) {

        return self.investmentCount > 0;
    }
}



library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{ value: value }(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}



contract CustomOwnable {

    event OwnershipTransferred(address previousOwner, address newOwner);

    address private _owner;

    modifier onlyOwner() {

        require(msg.sender == owner(), "CustomOwnable: FORBIDDEN");
        _;
    }

    constructor() {
        _setOwner(msg.sender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function _setOwner(address newOwner) internal {

        _owner = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "CustomOwnable: FORBIDDEN");
        emit OwnershipTransferred(owner(), newOwner);
        _setOwner(newOwner);
    }
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}





abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}








contract IBGV0 is IIBGEvents, CustomOwnable, ReentrancyGuard {

    using SafeMath for uint;
    using UserLibrary for UserLibrary.User;
    using IBGLibrary for IBGLibrary.IBGPlan;
    using InvestmentLibrary for InvestmentLibrary.Investment;

    IERC20 public usdt;
    IERC20 ibg;
    IERC20 bgbf;
    address rootNode;

    mapping(address => UserLibrary.User) public users;
    mapping(address => IBGLibrary.IBGPlan) public IBGPlanDetails;
    mapping(address => mapping(uint => InvestmentLibrary.Investment)) public cycleDetails;

    bool internal _initialized;

    uint public constant SERVICE_START_TIME = 1619521871;

    uint private constant DECIMAL_FACTOR = 10**6;
    uint private constant DECIMAL_FACTOR_IBG = 10**18;
    uint private constant SECONDS_IN_DAY = 86400;
    uint private constant IBG_TO_USDT = 1 * DECIMAL_FACTOR_IBG;

    uint private constant MAX_PACKS = 6;
    uint private constant MAX_PLANS = 3;

    uint private constant IBG_PERCENTAGE = 20;
    uint private constant BGBF_PERCENTAGE = 10;
    uint private constant MAX_CURRENT_PLAN = DECIMAL_FACTOR_IBG ** 2;

    uint private constant MAX_ELIGIBLE_REFERRER_WALKS = 25;


    uint ibgPercentage;
    uint bgbfPercentage;
    uint maxPacks;
    uint maxPlans;
    uint public maxWalks;
    uint public IBGToUsdt;
    uint public increaseIBGAfterLimit;
    uint public increaseRateIBG;
    uint public totalIBGDistributed;
    address treasuryWallet;
    address directCommissionWallet;
    address yieldMatchingWallet;
    address yieldWallet;

    uint lastRate;

    mapping(uint => string) public plans;
    mapping(uint => bool) public planActiveStatus;
    mapping(uint => uint) public packPrice;
    mapping(uint => uint) public stakingTime;
    mapping(uint => uint) public yieldRate;
    mapping(uint => uint) public directReferralRate;
    mapping(uint => uint) public yieldMatchingRate;

    modifier onlyBeforeLaunch() {

        require(block.timestamp < SERVICE_START_TIME, "IBGV0: Service Expired");
        _;
    }

    function initialize(address _governance, address _ibg, address _usdt, address _treasuryWallet) external {

        require(!_initialized, 'IBGV0: INVALID');
        _initialized = true;
        _setOwner(_governance);
        usdt = IERC20(_usdt);
        ibg = IERC20(_ibg);
        rootNode = _treasuryWallet;
        treasuryWallet = _treasuryWallet;
        directCommissionWallet = _treasuryWallet;
        yieldMatchingWallet = _treasuryWallet;
        yieldWallet = _treasuryWallet;


        users[rootNode].investmentCount = 1;

        ibgPercentage = IBG_PERCENTAGE;
        bgbfPercentage = BGBF_PERCENTAGE;

        IBGToUsdt = IBG_TO_USDT;
        increaseRateIBG = 10 * 10**16;
        increaseIBGAfterLimit = 100000 * DECIMAL_FACTOR_IBG;
        maxPacks = MAX_PACKS;
        maxPlans = MAX_PLANS;
        maxWalks = MAX_ELIGIBLE_REFERRER_WALKS;

        directReferralRate[1] = 40;
        directReferralRate[2] = 30;
        directReferralRate[3] = 20;

        plans[1] = "IBG";
        plans[2] = "BGBF";
        plans[3] = "BLENDED";

        planActiveStatus[1] = true;

        packPrice[1] = 100 * DECIMAL_FACTOR;
        packPrice[2] = 1000 * DECIMAL_FACTOR;
        packPrice[3] = 5000 * DECIMAL_FACTOR;
        packPrice[4] = 10000 * DECIMAL_FACTOR;
        packPrice[5] = 50000 * DECIMAL_FACTOR;
        packPrice[6] = 100000 * DECIMAL_FACTOR;

        stakingTime[1] = 30;
        stakingTime[2] = 60;
        stakingTime[3] = 90;

        yieldRate[stakingTime[1]] = 5;
        yieldRate[stakingTime[2]] = 6;
        yieldRate[stakingTime[3]] = 7;

        yieldMatchingRate[1] = 30;
        yieldMatchingRate[2] = 20;
        yieldMatchingRate[3] = 10;
        yieldMatchingRate[4] = 10;
        yieldMatchingRate[5] = 10;

        users[rootNode].currentPlan = MAX_CURRENT_PLAN;
        emit Registration(rootNode, address(0), block.timestamp);
    }

    function setPackagePercentage(uint _value, uint plan) public onlyOwner {

        require(_value > 0 && _value <= 100, "IBGV0: Invalid percentage");
        if (plan == 1) {
            ibgPercentage = _value;
        } else if (plan == 2) {
            bgbfPercentage = _value;
        }
    }

    function setIBGIncreaseBase(uint newBase) external virtual onlyOwner {

        require(newBase > 0, "IBGV1: Non_Zero");
        increaseIBGAfterLimit = newBase;
    }

    function setIBGIncreaseRate(uint newRate) external virtual onlyOwner {

        require(newRate > 0, "IBGV1: Non_Zero");
        increaseRateIBG = newRate;
    }

    function setlastRate(uint newRate) external virtual onlyOwner {

        lastRate = newRate;
    }

    function registerAdmin(address _user, address _referrer, uint _pack, uint _plan, uint stakingPeriod) external virtual onlyOwner onlyBeforeLaunch nonReentrant {

        _register(_user, _referrer, _pack, _plan, stakingPeriod, true);
    }

    function register(address _referrer, uint _pack, uint _plan, uint stakingPeriod) external virtual nonReentrant {

        _register(msg.sender, _referrer, _pack, _plan, stakingPeriod, false);
    }

    function _register(address user, address _referrer, uint _pack, uint _plan, uint stakingPeriod, bool isAdmin) private {

        require(_pack >= 1 && _pack <= maxPacks, 'IBGV0: Invalid Pack');
        require(_plan >= 1 && _plan <= maxPlans, 'IBGV0: Invalid Plan');
        require(planActiveStatus[_plan], 'IBGV0: Plan is not active yet');
        require(stakingPeriod >= 1 && stakingPeriod <= 3, 'IBGV0: Invalid staking period');
        require(!users[user].exists(), 'IBGV0: User_Exists');
        require(users[_referrer].exists(), 'IBGV0: Referrer does not exists');
        uint value = packPrice[_pack];

        if (!isAdmin) {
            TransferHelper.safeTransferFrom(address(usdt), user, address(this), value);
        }

        users[user].referrer = _referrer;
        users[_referrer].referralCount++;

        emit Registration(user, _referrer, block.timestamp);

        _investment(user, _pack, _plan, value, stakingPeriod, isAdmin);
    }

    function investmentAdmin(address _user, uint _pack, uint _plan, uint stakingPeriod) external virtual onlyOwner onlyBeforeLaunch nonReentrant {

        require(_pack >= 1 && _pack <= maxPacks, 'IBGV0: Invalid Pack');
        require(_plan >= 1 && _plan <= maxPlans, 'IBGV0: Invalid Plan');
        require(planActiveStatus[_plan], 'IBGV0: Plan is not active yet');
        require(stakingPeriod >= 1 && stakingPeriod <= 3, 'IBGV0: Invalid staking period');
        require(users[_user].exists(), "IBGV0: User not registered yet");

        _investment(_user, _pack, _plan, packPrice[_pack], stakingPeriod, true);
    }

    function investment(uint _pack, uint _plan, uint stakingPeriod) external virtual nonReentrant {

        require(_pack >= 1 && _pack <= maxPacks, 'IBGV0: Invalid Pack');
        require(_plan >= 1 && _plan <= maxPlans, 'IBGV0: Invalid Plan');
        require(planActiveStatus[_plan], 'IBGV0: Plan is not active yet');
        require(stakingPeriod >= 1 && stakingPeriod <= 3, 'IBGV0: Invalid staking period');
        require(users[msg.sender].exists(), "IBGV0: User not registered yet");

        uint value = packPrice[_pack];
        TransferHelper.safeTransferFrom(address(usdt), msg.sender, address(this), value);
        _investment(msg.sender, _pack, _plan, value, stakingPeriod, false);
    }

    function _investment(address _user, uint _pack, uint _plan, uint currentPackAmount, uint stakingPeriod, bool isAdmin) private {

        users[_user].investmentCount++;
        users[_user].currentPlan = users[_user].currentPlan.add(currentPackAmount);

        InvestmentLibrary.Investment storage cycle = cycleDetails[_user][users[_user].investmentCount];
        cycle.investmentTime = block.timestamp;
        cycle.plan = _plan;
        cycle.stakingPeriod = stakingTime[stakingPeriod];
        cycle.yieldRateValue = yieldRate[stakingTime[stakingPeriod]];
        if(_plan == 1) {
            uint iBGAmount = (currentPackAmount.mul(DECIMAL_FACTOR_IBG)).div(DECIMAL_FACTOR);
            if (!isAdmin) {
                iBGAmount = ((iBGAmount).mul(DECIMAL_FACTOR_IBG)).div(IBGToUsdt);
                TransferHelper.safeTransfer(address(usdt), treasuryWallet, currentPackAmount.mul((uint(100)).sub(ibgPercentage)).div(100));
            }

            cycle.investment = iBGAmount;
            totalIBGDistributed = totalIBGDistributed.add(iBGAmount);
            IBGPlanDetails[_user].IBGTokens = IBGPlanDetails[_user].IBGTokens.add(iBGAmount);
            IBGPlanDetails[_user].stakedIBGTokens = IBGPlanDetails[_user].stakedIBGTokens.add(iBGAmount);
            emit StakedToken(_user, iBGAmount, _plan, block.timestamp, stakingPeriod);

            calculateIBGTokenPrice();

            if (!isAdmin) {
                commisionTransfer(_user, users[_user].referrer, currentPackAmount, (currentPackAmount.mul(ibgPercentage).div(100)), ibgPercentage);
            }
        }

        emit PackPurchased(_user, _pack, _plan, currentPackAmount, block.timestamp);
    }

    function iBGYieldCommission(address user, address reciever, uint currentPlan, uint yieldDistributionAmount) private {

        uint level = 1;
        TransferHelper.safeTransfer(address(ibg), yieldMatchingWallet, (yieldDistributionAmount.mul(20)).div(100));

        while(level <= 5) {
            uint amount = (yieldDistributionAmount.mul(yieldMatchingRate[level]).div(100));
            if(reciever == address(0)) {
                TransferHelper.safeTransfer(address(ibg), rootNode, amount);
                IBGPlanDetails[rootNode].IBGYieldMatchingIncome = IBGPlanDetails[rootNode].IBGYieldMatchingIncome.add(amount);

                emit YieldMatchingIncome(user, rootNode, amount, level, block.timestamp);
            } else {
                if(users[reciever].currentPlan >= currentPlan) {
                    TransferHelper.safeTransfer(address(ibg), reciever, amount);
                    IBGPlanDetails[reciever].IBGYieldMatchingIncome = IBGPlanDetails[reciever].IBGYieldMatchingIncome.add(amount);

                    emit YieldMatchingIncome(user, reciever, amount, level, block.timestamp);
                }
                else {
                    uint newAmount = ((amount).mul(users[reciever].currentPlan).div(currentPlan));
                    TransferHelper.safeTransfer(address(ibg), reciever, newAmount);
                    IBGPlanDetails[reciever].IBGYieldMatchingIncome = IBGPlanDetails[reciever].IBGYieldMatchingIncome.add(newAmount);

                    emit YieldMatchingIncome(user, reciever, newAmount, level, block.timestamp);

                    uint lostIncome = amount.sub(newAmount);
                    IBGPlanDetails[reciever].IBGYieldMatchingLostIncome = IBGPlanDetails[reciever].IBGYieldMatchingLostIncome.add(lostIncome);

                    address eligibleUser = getEligibleReceiver(users[reciever].referrer, users[user].currentPlan);
                    TransferHelper.safeTransfer(address(ibg), eligibleUser, lostIncome);
                    IBGPlanDetails[eligibleUser].IBGYieldMatchingIncome = IBGPlanDetails[eligibleUser].IBGYieldMatchingIncome.add(lostIncome);

                    emit YieldMatchingLostIncome(user, reciever, lostIncome, level, block.timestamp);
                    emit YieldMatchingIncome(user, eligibleUser, lostIncome, level, block.timestamp);
                }
            }

            reciever = users[reciever].referrer;
            level++;
        }
    }

    function commisionTransfer(address _from, address _receiver, uint currentPlan, uint distributeAmount, uint _basePercentage) private {

        TransferHelper.safeTransfer(address(usdt), directCommissionWallet, (distributeAmount.mul(10)).div(100));
        uint level = 1;
        while(level <= 3) {
            uint amount;
            amount = ((distributeAmount).mul(directReferralRate[level])).div(100);
            if(_receiver == address(0)) {
                TransferHelper.safeTransfer(address(usdt), rootNode, amount);
                users[rootNode].directReferrerIncome = users[rootNode].directReferrerIncome.add(amount);
                emit DirectReferralIncome(_from, rootNode, amount, level, block.timestamp);
            } else {
                if(users[_receiver].currentPlan >= users[_from].currentPlan) {
                    TransferHelper.safeTransfer(address(usdt), _receiver, amount);
                    users[_receiver].directReferrerIncome = users[_receiver].directReferrerIncome.add(amount);
                    emit DirectReferralIncome(_from, _receiver, amount, level, block.timestamp);
                } else {
                    uint prevPlan = users[_from].currentPlan.sub(currentPlan);
                    uint newAmount;
                    if (prevPlan < users[_receiver].currentPlan) {
                        newAmount = users[_receiver].currentPlan.sub(prevPlan);
                    }


                    if (newAmount > 0) {
                        newAmount = (((newAmount).mul(_basePercentage)).div(100));
                        newAmount = ((newAmount).mul(directReferralRate[level])).div(100);
                        TransferHelper.safeTransfer(address(usdt), _receiver, newAmount);
                        users[_receiver].directReferrerIncome = users[_receiver].directReferrerIncome.add(newAmount);

                        emit DirectReferralIncome(_from, _receiver, newAmount, level, block.timestamp);
                    }


                    uint lostIncome = amount - newAmount;

                    users[_receiver].lostIncome = users[_receiver].lostIncome.add(lostIncome);
                    address eligibleUser = getEligibleReceiver(users[_receiver].referrer, users[_from].currentPlan);
                    TransferHelper.safeTransfer(address(usdt), eligibleUser, lostIncome);
                    users[eligibleUser].directReferrerIncome = users[eligibleUser].directReferrerIncome.add(lostIncome);
                    emit LostIncome(_from, _receiver, lostIncome, level, block.timestamp);
                    emit DirectReferralIncome(_from, eligibleUser, lostIncome, level, block.timestamp);
                }
            }

            _receiver = users[_receiver].referrer;
            level++;
        }
    }

    function getEligibleReceiver(address _receiver, uint currentPlan) private view returns(address) {

        uint walks;
        while (_receiver != address(0) && walks++ < maxWalks) {
            if (users[_receiver].currentPlan >= currentPlan) {
                return _receiver;
            }
            _receiver = users[_receiver].referrer;
        }

        return rootNode;
    }

    function setMaxWalks(uint walks) external onlyOwner {

        require(walks > 0, 'IBGV0: Invalid walks');
        maxWalks = walks;
    }

    function withdrawYield(bool onlyYield) external virtual nonReentrant {

        require(onlyYield || !onlyYield, "IBGV0: Forbidden");
    }

    function _withdrawYield(address user) private {

        require(users[user].investmentCount > 0, 'IBGV0: Please invest to withdraw');
        _withdrawIBGYield(user, users[user].investmentCount, true);
    }

    function _withdrawIBGYield(address user, uint cycles, bool onlyYield) private {

        require(users[user].investmentCount > 0, 'IBGV0: Please invest to withdraw');
        require(onlyYield, "IBGV0: Only Yield");
        uint totalYield;
        for(uint i = 1; i <= cycles; i++) {
            InvestmentLibrary.Investment storage cycle = cycleDetails[user][i];
            if(!cycle.isUnstaked && cycle.plan == 1) {
                uint daysDiff = (block.timestamp.sub(cycle.investmentTime)).div(SECONDS_IN_DAY);
                uint count;
                if(daysDiff >= (cycle.stakingPeriod)) {
                    count = (cycle.stakingPeriod).div(30);
                    cycleDetails[user][i].isUnstaked = true;
                    totalYield = totalYield.add(((cycle.investment).mul(count.mul(cycle.yieldRateValue))).div(100));
                    IBGPlanDetails[user].withdrawnYield = IBGPlanDetails[user].withdrawnYield.add(totalYield);
                }
            }
        }

        if (totalYield == 0) {
            return;
        }

        totalIBGDistributed = totalIBGDistributed.add(totalYield);
        calculateIBGTokenPrice();

        uint yieldAmount = (totalYield.mul(95)).div(100);
        TransferHelper.safeTransfer(address(ibg), yieldWallet, ((totalYield).mul(5)).div(100));
        IBGPlanDetails[user].IBGYieldIncome = IBGPlanDetails[user].IBGYieldIncome.add(((yieldAmount).mul(90)).div(100));
        TransferHelper.safeTransfer(address(ibg), user, ((yieldAmount).mul(90)).div(100));

        emit YieldIncome(msg.sender, ((yieldAmount).mul(90)).div(100), block.timestamp);

        iBGYieldCommission(user, users[user].referrer, users[user].currentPlan, (yieldAmount.mul(10)).div(100));
    }

    function withdrawInvestment(address user, bool withdraw, uint8 stakingPeriod) private {

        require(users[user].investmentCount > 0, 'IBGV0: Please invest to withdraw');
        if(!withdraw) {
            require(stakingPeriod >= 1 && stakingPeriod <= 3, 'IBGV0: Invalid staking period');
        }
        _withdrawInvestment(user, users[user].investmentCount, withdraw, stakingPeriod);
    }

    function _withdrawInvestment(address user, uint cycles, bool withdraw, uint stakingPeriod) private {

        uint totalInvestment;
        uint reStakedInvestment;
        uint totalIBGAmount;
        if(withdraw) {
            totalIBGAmount = calculateTotalIBGInvest(user);
        }
        for(uint i = 1; i <= cycles; i++) {
            InvestmentLibrary.Investment storage cycle = cycleDetails[user][i];
            if(cycle.plan == 1 && !cycle.withdrawInvestment) {
                uint daysDiff = (block.timestamp.sub(cycle.investmentTime)).div(SECONDS_IN_DAY);
                if(daysDiff >= (cycle.stakingPeriod)) {
                    if(withdraw) {
                        IBGPlanDetails[user].stakedIBGTokens = IBGPlanDetails[user].stakedIBGTokens.sub(cycle.investment);
                        totalInvestment = totalInvestment.add(cycle.investment);
                    } else {
                       reStakedInvestment = reStakedInvestment.add(cycle.investment);
                    }
                    cycle.withdrawInvestment = true;
                }
            }
        }

        if(totalInvestment > 0 && withdraw) {
            TransferHelper.safeTransfer(address(ibg), user, totalInvestment);
            IBGPlanDetails[user].withdrawnInvestment = IBGPlanDetails[user].withdrawnInvestment.add(totalInvestment);
            demotePack(user, totalIBGAmount, totalInvestment);
        }

        if(!withdraw && reStakedInvestment > 0) {
            reStakeInvestment(user, reStakedInvestment, stakingPeriod);
        }
    }

    function reStakeInvestment(address user, uint investmentAmount, uint stakingPeriod) private {

        users[user].investmentCount++;
        InvestmentLibrary.Investment storage cycle = cycleDetails[user][users[user].investmentCount];
        cycle.investmentTime = block.timestamp;
        cycle.plan = 1;
        cycle.stakingPeriod = stakingTime[stakingPeriod];
        cycle.yieldRateValue = yieldRate[stakingTime[stakingPeriod]];
        cycle.investment = investmentAmount;
    }

    function _restakeYieldAndInvestment(address user, uint8 stakingPeriod) private {

        require(users[user].investmentCount > 0, 'IBGV0: Please invest to withdraw');
        require(stakingPeriod >= 1 && stakingPeriod <= 3, 'IBGV0: Invalid staking period');

        uint totalStakeAmount;
        for(uint i = 1; i <= users[user].investmentCount; i++) {
            uint totalYield;
            InvestmentLibrary.Investment storage cycle = cycleDetails[user][i];
            if(!cycle.isUnstaked && cycle.plan == 1) {
                uint daysDiff = (block.timestamp.sub(cycle.investmentTime)).div(SECONDS_IN_DAY);
                uint count;
                if(daysDiff >= (cycle.stakingPeriod)) {
                    count = (cycle.stakingPeriod).div(30);
                    totalYield = totalYield.add(((cycle.investment).mul(count.mul(cycle.yieldRateValue))).div(100));
                    cycle.isUnstaked = true;
                }
            }
            if(totalYield > 0) {
                uint yieldAmount = (totalYield.mul(95)).div(100);
                TransferHelper.safeTransfer(address(ibg), yieldWallet, ((totalYield).mul(5)).div(100));
                totalStakeAmount = totalStakeAmount.add(yieldAmount);
            }
            if(cycle.plan == 1 && !cycle.withdrawInvestment) {
                uint daysDiff = (block.timestamp.sub(cycle.investmentTime)).div(SECONDS_IN_DAY);
                if(daysDiff >= (cycle.stakingPeriod)) {
                    totalStakeAmount = totalStakeAmount.add(cycle.investment);
                    cycle.withdrawInvestment = true;
                }
            }
        }
        if(totalStakeAmount > 0) {
            reStakeInvestment(user, totalStakeAmount, stakingPeriod);
        }
    }

    function yieldAndInvestment(uint8 operation, uint8 stakingPeriod) public {

        require(users[msg.sender].investmentCount > 0, 'IBGV0: Please invest to withdraw');
        require(operation >= 0 && operation <= 3, 'IBGV0: Invalid operation');
        if(operation == 1 && operation == 3) {
            require(stakingPeriod >= 1 && stakingPeriod <= 3, 'IBGV0: Invalid staking period');
        }
        if(operation == 0) {
            _withdrawYield(msg.sender);
        } else if(operation == 1) {
            _withdrawYield(msg.sender);
            withdrawInvestment(msg.sender, true, stakingPeriod);
        } else if(operation == 2) {
            withdrawInvestment(msg.sender, false, stakingPeriod);
        } else if(operation == 3) {
            _restakeYieldAndInvestment(msg.sender, stakingPeriod);
        }
    }

    function calculateTotalIBGInvest(address user) private view returns(uint) {

        uint total;
        for(uint i = 1; i <= users[user].investmentCount; i++) {
            InvestmentLibrary.Investment storage cycle = cycleDetails[user][i];
            if(!cycle.withdrawInvestment) {
                total = total.add(cycle.investment);
            }
        }
        return total;
    }

    function calculateStakedInvestment(address user) public view returns(uint) {

        uint stakedInvestment;
        for(uint i = 1; i <= users[user].investmentCount; i++) {
            InvestmentLibrary.Investment storage cycle = cycleDetails[user][i];
            uint daysDiff = (block.timestamp.sub(cycle.investmentTime)).div(SECONDS_IN_DAY);
            if(daysDiff < (cycle.stakingPeriod)) {
                stakedInvestment = stakedInvestment.add(cycle.investment);
            }
        }
        return stakedInvestment;
    }

    function calculateAccumulatedYield(address user) public view returns(uint) {

        uint accumulatedYield;
        for(uint i = 1; i <= users[user].investmentCount; i++) {
            InvestmentLibrary.Investment storage cycle = cycleDetails[user][i];
            uint count;
            uint daysDiff = (block.timestamp.sub(cycle.investmentTime)).div(SECONDS_IN_DAY);
            if(daysDiff >= (cycle.stakingPeriod)) {
                count = (cycle.stakingPeriod).div(30);
                accumulatedYield = accumulatedYield.add(((cycle.investment).mul(count.mul(cycle.yieldRateValue))).div(100));
            }
        }
        return accumulatedYield;
    }

    function demotePack(address user, uint totalIBGAmount, uint IBGAmount) private {

        uint afterSellIbg = totalIBGAmount.sub(IBGAmount);
        uint newPlanUsdt = ((((afterSellIbg).mul(IBGToUsdt)).div(DECIMAL_FACTOR_IBG)).div(DECIMAL_FACTOR_IBG)).mul(DECIMAL_FACTOR);
        if(newPlanUsdt <= users[user].currentPlan) {
            users[user].currentPlan = newPlanUsdt;
        }
    }

    function calculateYieldAndInvestment(address user) public view returns(uint withdrawableYield, uint withdrawableInvestment) {

        uint totalYield;
        uint totalInvestment;
        for(uint i = 1; i <= users[user].investmentCount; i++) {
            InvestmentLibrary.Investment storage cycle = cycleDetails[user][i];
            if(!cycle.isUnstaked && cycle.plan == 1) {
                uint daysDiff = (block.timestamp.sub(cycle.investmentTime)).div(SECONDS_IN_DAY);
                uint count;
                if(daysDiff >= (cycle.stakingPeriod)) {
                    count = (cycle.stakingPeriod).div(30);
                    totalYield = totalYield.add(((cycle.investment).mul(count.mul(cycle.yieldRateValue))).div(100));
                }
            }
            if(cycle.plan == 1 && !cycle.withdrawInvestment) {
                uint daysDiff = (block.timestamp.sub(cycle.investmentTime)).div(SECONDS_IN_DAY);
                if(daysDiff >= (cycle.stakingPeriod)) {
                    totalInvestment = totalInvestment.add(cycle.investment);
                }
            }
        }
        return (totalYield, totalInvestment);
    }

    function calculateIBGTokenPrice() private {

        uint newValue = totalIBGDistributed.div(increaseIBGAfterLimit);
        if(newValue > lastRate) {
            lastRate = newValue;
            newValue = newValue.mul(increaseRateIBG);
            IBGToUsdt = (1 * DECIMAL_FACTOR_IBG).add(newValue);
        }
    }

    function getInvestmentDetails(address _user, uint _id) external view returns (uint plan, uint investmentAmount, uint investmentTime, uint stakingPeriod, bool isUnstaked) {

        return(
            cycleDetails[_user][_id].plan,
            cycleDetails[_user][_id].investment,
            cycleDetails[_user][_id].investmentTime,
            cycleDetails[_user][_id].stakingPeriod,
            cycleDetails[_user][_id].isUnstaked
        );
    }

    function updateDirectReferralRate(uint index, uint value) external virtual onlyOwner {

        require(index > 0 && index < 4, 'IBGV0: Index length must be between 1 to 3');
        require(value > 0 && value <= 100,'IBGV0: Invalid Value');
        directReferralRate[index] = value;
    }

    function updateYieldMatchingRate(uint index, uint value) external virtual onlyOwner {

        require(index > 0 && index < 6, 'IBGV0: Index length must be between 1 to 5');
        require(value > 0 && value <= 100,'IBGV0: Invalid Value');
        yieldMatchingRate[index] = value;
    }


    function updatePack(uint packNumber, uint price) external virtual onlyOwner returns(uint, uint) {

        require((packNumber > 0 && packNumber <= maxPacks.add(1)), "IBGV0: Invalid PackNumber");
        require(price > 0, "IBGV0: Invalid Packprice");
        packPrice[packNumber] = price;

        if(packNumber > maxPacks) {
            maxPacks = packNumber;
        }

        return(packNumber, packPrice[packNumber]);
    }

    function updatePlan(uint planNumber, string calldata planName) external virtual onlyOwner returns(uint, string memory) {

        require((planNumber > 0 && planNumber <= maxPlans.add(1)), "IBGV0: Invalid PlanNumber");
        require(keccak256(abi.encodePacked(planName)) != keccak256(abi.encodePacked('')), "IBGV0: Invalid Plan name");
        plans[planNumber] = planName;

        if(planNumber > maxPlans) {
            maxPlans = planNumber;
        }

        return(planNumber, plans[planNumber]);
    }

    function updateStakingTime(uint timeIndex, uint timeValue) external virtual onlyOwner returns(uint, uint) {

        require(timeIndex > 0, 'IBGV0: Invalid TimeIndex');
        require(timeValue > 0, 'IBGV0: Invalid TimeValue');
        stakingTime[timeIndex] = timeValue;
        return(timeIndex, stakingTime[timeIndex]);

    }

    function updateYieldRate(uint timeInDays, uint yieldValue) external virtual onlyOwner returns(uint, uint) {

        require(timeInDays > 0, 'IBGV0: Invalid YieldIndex');
        require(yieldValue > 0, 'IBGV0: Invalid YieldValue');
        yieldRate[timeInDays] = yieldValue;
        return(timeInDays, yieldRate[timeInDays]);
    }

    function updateBGBFToken(address _token) external virtual onlyOwner {

        require(_token != address(0), "IBGV0: Invalid Token Address");
        bgbf = IERC20(_token);
    }

    function updatePlanStatus(uint plan, bool status) external virtual onlyOwner {

        require(planActiveStatus[plan] != status, "IBGV0: Plan already has required status");
        require(plan >= 1 && plan <= maxPlans, 'IBGV0: Invalid Plan');
        planActiveStatus[plan] = status;
    }

    function updateTreasuryWallet(address _newWallet) external virtual onlyOwner {

        require(_newWallet != address(0), 'IBGV0: Invalid Address');
        require(_newWallet != treasuryWallet, "IBGV0: Wallet is same as previous");
        treasuryWallet = _newWallet;
    }

    function updateDirectCommissionWallet(address _newWallet) external virtual onlyOwner {

        require(_newWallet != address(0), 'IBGV0: Invalid Address');
        require(_newWallet != directCommissionWallet, "IBGV0: Wallet is same as previous");
        directCommissionWallet = _newWallet;
    }

    function updateYieldMatchingWallet(address _newWallet) external virtual onlyOwner {

        require(_newWallet != address(0), 'IBGV0: Invalid Address');
        require(_newWallet != yieldMatchingWallet, "IBGV0: Wallet is same as previous");
        yieldMatchingWallet = _newWallet;
    }

    function updateYieldWallet(address _newWallet) external virtual onlyOwner {

        require(_newWallet != address(0), 'IBGV0: Invalid Address');
        require(_newWallet != yieldWallet, "IBGV0: Wallet is same as previous");
        yieldWallet = _newWallet;
    }

    function walletBalance() external virtual onlyOwner {

        uint value = ibg.balanceOf(address(this));

        require(value > 0, "IBGV0: Invalid balance");
        TransferHelper.safeTransfer(address(ibg), treasuryWallet, value);
    }
}