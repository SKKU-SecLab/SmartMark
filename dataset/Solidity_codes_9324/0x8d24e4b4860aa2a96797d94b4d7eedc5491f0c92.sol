
pragma solidity ^0.4.21;


contract GuidedByRoles {

    IRightAndRoles public rightAndRoles;
    function GuidedByRoles(IRightAndRoles _rightAndRoles) public {

        rightAndRoles = _rightAndRoles;
    }
}

contract IToken{

    function setUnpausedWallet(address _wallet, bool mode) public;

    function mint(address _to, uint256 _amount) public returns (bool);

    function totalSupply() public view returns (uint256);

    function setPause(bool mode) public;

    function setMigrationAgent(address _migrationAgent) public;

    function migrateAll(address[] _holders) public;

    function markTokens(address _beneficiary, uint256 _value) public;

    function freezedTokenOf(address _beneficiary) public view returns (uint256 amount);

    function defrostDate(address _beneficiary) public view returns (uint256 Date);

    function freezeTokens(address _beneficiary, uint256 _amount, uint256 _when) public;

}

contract IRightAndRoles {

    address[][] public wallets;
    mapping(address => uint16) public roles;

    event WalletChanged(address indexed newWallet, address indexed oldWallet, uint8 indexed role);
    event CloneChanged(address indexed wallet, uint8 indexed role, bool indexed mod);

    function changeWallet(address _wallet, uint8 _role) external;

    function setManagerPowerful(bool _mode) external;

    function onlyRoles(address _sender, uint16 _roleMask) view external returns(bool);

}

contract ERC20Provider is GuidedByRoles {

    function transferTokens(ERC20Basic _token, address _to, uint256 _value) public returns (bool){

        require(rightAndRoles.onlyRoles(msg.sender,2));
        return _token.transfer(_to,_value);
    }
}

contract Crowdsale is GuidedByRoles, ERC20Provider{


    uint256 constant USER_UNPAUSE_TOKEN_TIMEOUT =  30 days;
    uint256 constant FORCED_REFUND_TIMEOUT1     = 400 days;
    uint256 constant FORCED_REFUND_TIMEOUT2     = 600 days;
    uint256 constant ROUND_PROLONGATE           =  60 days;

    using SafeMath for uint256;

    enum TokenSaleType {round1, round2}
    TokenSaleType public TokenSale = TokenSaleType.round1;


    ICreator public creator;
    bool isBegin=false;

    IToken public token;
    IAllocation public allocation;
    IFinancialStrategy public financialStrategy;

    bool public isFinalized;
    bool public isInitialized;
    bool public isPausedCrowdsale;
    bool public chargeBonuses;
    bool public canFirstMint=true;

    struct Bonus {
        uint256 value;
        uint256 procent;
        uint256 freezeTime;
    }

    struct Profit {
        uint256 percent;
        uint256 duration;
    }

    struct Freezed {
        uint256 value;
        uint256 dateTo;
    }

    mapping (address => bool) public promo;

    Bonus[] public bonuses;
    Profit[] public profits;


    uint256 public startTime;  
    uint256 public endTime; 
    uint256 public renewal;

    uint256 public rate; 

    uint256 public exchange;

    uint256 public softCap;

    uint256 public hardCap;

    uint256 public overLimit;

    uint256 public minPay;

    uint256 public maxAllProfit; // max time bonus=20%, max value bonus=10%, maxAll=10%+20%

    uint256 public ethWeiRaised;
    uint256 public nonEthWeiRaised;
    uint256 public weiRound1;
    uint256 public tokenReserved;

    uint256 public totalSaledToken;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event Finalized();
    event Initialized();

    event PaymentedInOtherCurrency(uint256 token, uint256 value);
    event ExchangeChanged(uint256 indexed oldExchange, uint256 indexed newExchange);

    function Crowdsale(ICreator _creator,IToken _token) GuidedByRoles(_creator.getRightAndRoles()) public
    {

        creator=_creator;
        token = _token;
    }

    function updateInfo(uint256 _ETHUSD,uint256 _token, uint256 _value) public {

        if(_token > 0 && _value > 0){
            paymentsInOtherCurrency(_token,_value);
        }
    }


    function setPromo(address[] _investors, uint8[] _mod) public {

        require(rightAndRoles.onlyRoles(msg.sender,18));
        for(uint256 i = 0; i < _investors.length; i++){
            promo[_investors[i]] = _mod[i] > 0;
        }
    }

    function begin() public
    {


        require(rightAndRoles.onlyRoles(msg.sender,22));
        if (isBegin) return;
        isBegin=true;

        startTime   = 1535799600;   // 1.09.18
        endTime     = 1538391599;   // 1.10.18
        rate        = 2000 ether;   // 1 ETH -> 2000 tokens (ETH/USD $300)
        exchange    = 300 ether;    // ETH/USD
        softCap     = 0 ether;     
        hardCap     = 58333 ether;  // $20 000 000 (ETH/USD $300)
        overLimit   = 20 ether;  
        minPay      = 1000 finney;  // 1 ETH =~ $300 (ETH/USD $300)
        maxAllProfit= 55;           // 55%

        financialStrategy = creator.createFinancialStrategy();

        token.setUnpausedWallet(rightAndRoles.wallets(1,0), true);
        token.setUnpausedWallet(rightAndRoles.wallets(3,0), true);
        token.setUnpausedWallet(rightAndRoles.wallets(4,0), true);
        token.setUnpausedWallet(rightAndRoles.wallets(5,0), true);
        token.setUnpausedWallet(rightAndRoles.wallets(6,0), true);

        bonuses.push(Bonus(33 ether, 10,0));   // value >$10000 is +10% bonus   (ETH/USD $300)
        bonuses.push(Bonus(333 ether, 20,0));  // value >$100000 is +20% bonus

        profits.push(Profit(25,100 days));
    }



    function firstMintRound0(uint256 _amount /* QUINTILLIONS! */) public {

        require(rightAndRoles.onlyRoles(msg.sender,6));
        require(canFirstMint);
        begin();
        token.mint(rightAndRoles.wallets(3,0),_amount);
        totalSaledToken = totalSaledToken.add(_amount);
    }

    function firstMintRound0For(address[] _to, uint256[] _amount, uint8[] _setAsUnpaused) public {

        require(rightAndRoles.onlyRoles(msg.sender,6));
        require(canFirstMint);
        begin();
        require(_to.length == _amount.length && _to.length == _setAsUnpaused.length);
        for(uint256 i = 0; i < _to.length; i++){
            token.mint(_to[i],_amount[i]);
            totalSaledToken = totalSaledToken.add(_amount[i]);
            if(_setAsUnpaused[i]>0){
                token.setUnpausedWallet(_to[i], true);
            }
        }
    }

    function totalSupply() external view returns (uint256){

        return token.totalSupply();
    }

    function isPromo(address _address) public view returns (bool){

       return promo[_address];
    }

    function forwardFunds(address _beneficiary) internal {

        financialStrategy.deposit.value(msg.value)(_beneficiary);
    }

    function validPurchase() internal view returns (bool) {


        bool withinPeriod = (now > startTime && now < endTime.add(renewal));

        bool nonZeroPurchase = msg.value >= minPay;

        bool withinCap = msg.value <= hardCap.sub(weiRaised()).add(overLimit);

        return withinPeriod && nonZeroPurchase && withinCap && isInitialized && !isFinalized && !isPausedCrowdsale;
    }

    function hasEnded() public view returns (bool) {

        bool isAdmin = rightAndRoles.onlyRoles(msg.sender,6);

        bool timeReached = now > endTime.add(renewal);

        bool capReached = weiRaised() >= hardCap;

        return (timeReached || capReached || (isAdmin && goalReached())) && isInitialized && !isFinalized;
    }

    function finalize() public {

        require(hasEnded());

        isFinalized = true;
        finalization();
        emit Finalized();
    }

    function finalization() internal {

        bytes32[] memory params = new bytes32[](0);
        if (goalReached()) {

            financialStrategy.setup(1,params);

            if (tokenReserved > 0) {

                token.mint(rightAndRoles.wallets(3,0),tokenReserved);
                totalSaledToken = totalSaledToken.add(tokenReserved);

                tokenReserved = 0;
            }

            if (TokenSale == TokenSaleType.round1) {

                isInitialized = false;
                isFinalized = false;
                if(financialStrategy.freeCash() == 0){
                    rightAndRoles.setManagerPowerful(true);
                }

                TokenSale = TokenSaleType.round2;

                weiRound1 = weiRaised();
                ethWeiRaised = 0;
                nonEthWeiRaised = 0;



            }
            else // If the second round is finalized
            {

                chargeBonuses = true;


            }

        }
        else // If they failed round
        {
            financialStrategy.setup(3,params);
        }
    }

    function finalize2() public {

        require(rightAndRoles.onlyRoles(msg.sender,6));
        require(chargeBonuses);
        chargeBonuses = false;

        allocation = creator.createAllocation(token, now + 1 years /* stage N1 */,0/* not need*/);
        token.setUnpausedWallet(allocation, true);
        allocation.addShare(rightAndRoles.wallets(7,0),100,100); // all 100% - first year

        token.mint(rightAndRoles.wallets(5,0), totalSaledToken.mul(8).div(80));


        token.mint(allocation, totalSaledToken.mul(12).div(80));
    }



    function initialize() public {

        require(rightAndRoles.onlyRoles(msg.sender,6));
        require(!isInitialized);
        begin();


        require(now <= startTime);

        initialization();

        emit Initialized();

        renewal = 0;

        isInitialized = true;

        if(TokenSale == TokenSaleType.round2) canFirstMint = false;
    }

    function initialization() internal {

        bytes32[] memory params = new bytes32[](0);
        rightAndRoles.setManagerPowerful(false);
        if (financialStrategy.state() != IFinancialStrategy.State.Active){
            financialStrategy.setup(2,params);
        }
    }

    function getPartnerCash(uint8 _user, bool _calc) external {

        if(_calc)
            calcFin();
        financialStrategy.getPartnerCash(_user, msg.sender);
    }

    function getBeneficiaryCash(bool _calc) public {

        require(rightAndRoles.onlyRoles(msg.sender,22));
        if(_calc)
            calcFin();
        financialStrategy.getBeneficiaryCash();
        if(!isInitialized && financialStrategy.freeCash() == 0)
            rightAndRoles.setManagerPowerful(true);
    }

    function claimRefund() external{

        financialStrategy.refund(msg.sender);
    }

    function calcFin() public {

        bytes32[] memory params = new bytes32[](2);
        params[0] = bytes32(weiTotalRaised());
        params[1] = bytes32(msg.sender);
        financialStrategy.setup(4,params);
    }

    function calcAndGet() public {

        require(rightAndRoles.onlyRoles(msg.sender,22));
        getBeneficiaryCash(true);
        for (uint8 i=0; i<0; i++) { // <-- TODO check financialStrategy.wallets.length
            financialStrategy.getPartnerCash(i, msg.sender);
        }
    }

    function goalReached() public view returns (bool) {

        return weiRaised() >= softCap;
    }


    function setup(uint256 _startTime, uint256 _endTime, uint256 _softCap, uint256 _hardCap,
        uint256 _rate, uint256 _exchange,
        uint256 _maxAllProfit, uint256 _overLimit, uint256 _minPay,
        uint256[] _durationTB , uint256[] _percentTB, uint256[] _valueVB, uint256[] _percentVB, uint256[] _freezeTimeVB) public
    {


        require(rightAndRoles.onlyRoles(msg.sender,6));
        require(!isInitialized);

        begin();

        require(now <= _startTime);
        require(_startTime < _endTime);

        startTime = _startTime;
        endTime = _endTime;

        require(_softCap <= _hardCap);

        softCap = _softCap;
        hardCap = _hardCap;

        require(_rate > 0);

        rate = _rate;

        overLimit = _overLimit;
        minPay = _minPay;
        exchange = _exchange;

        maxAllProfit = _maxAllProfit;

        require(_valueVB.length == _percentVB.length && _valueVB.length == _freezeTimeVB.length);
        bonuses.length = _valueVB.length;
        for(uint256 i = 0; i < _valueVB.length; i++){
            bonuses[i] = Bonus(_valueVB[i],_percentVB[i],_freezeTimeVB[i]);
        }

        require(_percentTB.length == _durationTB.length);
        profits.length = _percentTB.length;
        for( i = 0; i < _percentTB.length; i++){
            profits[i] = Profit(_percentTB[i],_durationTB[i]);
        }

    }

    function weiRaised() public constant returns(uint256){

        return ethWeiRaised.add(nonEthWeiRaised);
    }

    function weiTotalRaised() public constant returns(uint256){

        return weiRound1.add(weiRaised());
    }

    function getProfitPercent() public constant returns (uint256){

        return getProfitPercentForData(now);
    }

    function getProfitPercentForData(uint256 _timeNow) public constant returns (uint256){

        uint256 allDuration;
        for(uint8 i = 0; i < profits.length; i++){
            allDuration = allDuration.add(profits[i].duration);
            if(_timeNow < startTime.add(allDuration)){
                return profits[i].percent;
            }
        }
        return 0;
    }

    function getBonuses(uint256 _value) public constant returns (uint256,uint256,uint256){

        if(bonuses.length == 0 || bonuses[0].value > _value){
            return (0,0,0);
        }
        uint16 i = 1;
        for(i; i < bonuses.length; i++){
            if(bonuses[i].value > _value){
                break;
            }
        }
        return (bonuses[i-1].value,bonuses[i-1].procent,bonuses[i-1].freezeTime);
    }


    function tokenUnpause() external {


        require(rightAndRoles.onlyRoles(msg.sender,2)
        || (now > endTime.add(renewal).add(USER_UNPAUSE_TOKEN_TIMEOUT) && TokenSale == TokenSaleType.round2 && isFinalized && goalReached()));
        token.setPause(false);
    }

    function tokenPause() public {

        require(rightAndRoles.onlyRoles(msg.sender,6));
        require(!isFinalized);
        token.setPause(true);
    }

    function setCrowdsalePause(bool mode) public {

        require(rightAndRoles.onlyRoles(msg.sender,6));
        isPausedCrowdsale = mode;
    }





    function prolong(uint256 _duration) external {

        require(rightAndRoles.onlyRoles(msg.sender,6));
        require(now > startTime && now < endTime.add(renewal) && isInitialized && !isFinalized);
        renewal = renewal.add(_duration);
        require(renewal <= ROUND_PROLONGATE);

    }




    function distructVault() public {

        bytes32[] memory params = new bytes32[](1);
        params[0] = bytes32(msg.sender);
        if (rightAndRoles.onlyRoles(msg.sender,4) && (now > startTime.add(FORCED_REFUND_TIMEOUT1))) {
            financialStrategy.setup(0,params);
        }
        if (rightAndRoles.onlyRoles(msg.sender,2) && (now > startTime.add(FORCED_REFUND_TIMEOUT2))) {
            financialStrategy.setup(0,params);
        }
    }











    function paymentsInOtherCurrency(uint256 _token, uint256 _value) internal {


        require(rightAndRoles.onlyRoles(msg.sender,18));
        bool withinPeriod = (now >= startTime && now <= endTime.add(renewal));
        bool withinCap = _value.add(ethWeiRaised) <= hardCap.add(overLimit);
        require(withinPeriod && withinCap && isInitialized && !isFinalized);
        emit PaymentedInOtherCurrency(_token,_value);
        nonEthWeiRaised = _value;
        tokenReserved = _token;

    }

    function lokedMint(address _beneficiary, uint256 _value, uint256 _freezeTime) internal {

        if(_freezeTime > 0){

            uint256 totalBloked = token.freezedTokenOf(_beneficiary).add(_value);
            uint256 pastDateUnfreeze = token.defrostDate(_beneficiary);
            uint256 newDateUnfreeze = _freezeTime.add(now);
            newDateUnfreeze = (pastDateUnfreeze > newDateUnfreeze ) ? pastDateUnfreeze : newDateUnfreeze;

            token.freezeTokens(_beneficiary,totalBloked,newDateUnfreeze);
        }
        token.mint(_beneficiary,_value);
        totalSaledToken = totalSaledToken.add(_value);
    }


    function buyTokens(address _beneficiary) public payable {

        require(_beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        uint256 ProfitProcent = getProfitPercent();

        uint256 value;
        uint256 percent;
        uint256 freezeTime;

        (value,
        percent,
        freezeTime) = getBonuses(weiAmount);

        Bonus memory curBonus = Bonus(value,percent,freezeTime);

        uint256 bonus = curBonus.procent;


        uint256 totalProfit = bonus.add(ProfitProcent);
        if(isPromo(_beneficiary)){
            totalProfit = totalProfit.add(10);
        }
        totalProfit = (totalProfit > maxAllProfit) ? maxAllProfit : totalProfit;

        uint256 tokens = weiAmount.mul(rate).mul(totalProfit.add(100)).div(100 ether);

        ethWeiRaised = ethWeiRaised.add(weiAmount);

        lokedMint(_beneficiary, tokens, curBonus.freezeTime);

        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        forwardFunds(_beneficiary);//forwardFunds(msg.sender);
    }

    function () public payable {
        buyTokens(msg.sender);
    }
}

contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    function minus(uint256 a, uint256 b) internal pure returns (uint256) {

        if (b>=a) return 0;
        return a - b;
    }
}

contract IFinancialStrategy{


    enum State { Active, Refunding, Closed }
    State public state = State.Active;

    event Deposited(address indexed beneficiary, uint256 weiAmount);
    event Receive(address indexed beneficiary, uint256 weiAmount);
    event Refunded(address indexed beneficiary, uint256 weiAmount);
    event Started();
    event Closed();
    event RefundsEnabled();
    function freeCash() view public returns(uint256);

    function deposit(address _beneficiary) external payable;

    function refund(address _investor) external;

    function setup(uint8 _state, bytes32[] _params) external;

    function getBeneficiaryCash() external;

    function getPartnerCash(uint8 _user, address _msgsender) external;

}

contract IAllocation {

    function addShare(address _beneficiary, uint256 _proportion, uint256 _percenForFirstPart) external;

}

contract ICreator{

    IRightAndRoles public rightAndRoles;
    function createAllocation(IToken _token, uint256 _unlockPart1, uint256 _unlockPart2) external returns (IAllocation);

    function createFinancialStrategy() external returns(IFinancialStrategy);

    function getRightAndRoles() external returns(IRightAndRoles);

}