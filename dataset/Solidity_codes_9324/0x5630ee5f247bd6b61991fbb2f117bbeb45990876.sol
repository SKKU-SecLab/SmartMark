pragma solidity ^0.5.2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}
pragma solidity ^0.5.2;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.2;


contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}
pragma solidity ^0.5.2;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}
pragma solidity ^0.5.2;


contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}
pragma solidity ^0.5.2;


contract ERC20Mintable is ERC20, MinterRole {

    function mint(address to, uint256 value) public onlyMinter returns (bool) {

        _mint(to, value);
        return true;
    }
}
pragma solidity ^0.5.2;


contract ERC20Capped is ERC20Mintable {

    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0);
        _cap = cap;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

    function _mint(address account, uint256 value) internal {

        require(totalSupply().add(value) <= _cap);
        super._mint(account, value);
    }
}
pragma solidity ^0.5.2;


contract ERC20Burnable is ERC20 {

    function burn(uint256 value) public {

        _burn(msg.sender, value);
    }

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);
    }
}
pragma solidity ^0.5.2;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}
pragma solidity ^0.5.2;


contract PauserRole {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {

        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}
pragma solidity ^0.5.2;


contract Pausable is PauserRole {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused);
        _;
    }

    modifier whenPaused() {

        require(_paused);
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}
pragma solidity ^0.5.2;


contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(spender, subtractedValue);
    }
}
pragma solidity ^0.5.2;



contract Eraswap is ERC20Detailed,ERC20Burnable,ERC20Capped,ERC20Pausable {



    event NRTManagerAdded(address NRTManager);

    constructor()
        public
         ERC20Detailed ("Era Swap", "ES", 18) ERC20Capped(9100000000000000000000000000) {
             mint(msg.sender, 910000000000000000000000000);
        }

    int256 public timeMachineDepth;


    function mou() public view returns(uint256) {

        if(timeMachineDepth < 0) {
            return now - uint256(timeMachineDepth);
        } else {
            return now + uint256(timeMachineDepth);
        }
    }

    function setTimeMachineDepth(int256 _timeMachineDepth) public {

        timeMachineDepth = _timeMachineDepth;
    }

    function goToFuture(uint256 _seconds) public {

        timeMachineDepth += int256(_seconds);
    }

    function goToPast(uint256 _seconds) public {

        timeMachineDepth -= int256(_seconds);
    }


    function AddNRTManager(address NRTManager) public onlyMinter returns (bool) {

        addMinter(NRTManager);
        addPauser(NRTManager);
        renounceMinter();
        renouncePauser();
        emit NRTManagerAdded(NRTManager);
        return true;
      }

}
pragma solidity ^0.5.2;



contract NRTManager {


    using SafeMath for uint256;

    uint256 public lastNRTRelease;              // variable to store last release date
    uint256 public monthlyNRTAmount;            // variable to store Monthly NRT amount to be released
    uint256 public annualNRTAmount;             // variable to store Annual NRT amount to be released
    uint256 public monthCount;                  // variable to store the count of months from the intial date
    uint256 public luckPoolBal;                 // Luckpool Balance
    uint256 public burnTokenBal;                // tokens to be burned
    Eraswap token;
    address Owner;

    address public newTalentsAndPartnerships = 0xb4024468D052B36b6904a47541dDE69E44594607;
    address public platformMaintenance = 0x922a2d6B0B2A24779B0623452AdB28233B456D9c;
    address public marketingAndRNR = 0xDFBC0aE48f3DAb5b0A1B154849Ee963430AA0c3E;
    address public kmPards = 0x4881964ac9AD9480585425716A8708f0EE66DA88;
    address public contingencyFunds = 0xF4E731a107D7FFb2785f696543dE8BF6EB558167;
    address public researchAndDevelopment = 0xb209B4cec04cE9C0E1Fa741dE0a8566bf70aDbe9;
    address public powerToken = 0xbc24BfAC401860ce536aeF9dE10EF0104b09f657;
    address public timeSwappers = 0x4b65109E11CF0Ff8fA58A7122a5E84e397C6Ceb8;                 // which include powerToken , curators ,timeTraders , daySwappers
    address public timeAlly;                     //address of timeAlly Contract


    uint256 public newTalentsAndPartnershipsBal; // variable to store last NRT released to the address;
    uint256 public platformMaintenanceBal;       // variable to store last NRT released to the address;
    uint256 public marketingAndRNRBal;           // variable to store last NRT released to the address;
    uint256 public kmPardsBal;                   // variable to store last NRT released to the address;
    uint256 public contingencyFundsBal;          // variable to store last NRT released to the address;
    uint256 public researchAndDevelopmentBal;    // variable to store last NRT released to the address;
    uint256 public powerTokenNRT;                  // variable to store last NRT released to the address;
    uint256 public timeAllyNRT;                   // variable to store last NRT released to the address;
    uint256 public timeSwappersNRT;              // variable to store last NRT released to the address;


      event NRTDistributed(uint256 NRTReleased);

      event NRTTransfer(string pool, address sendAddress, uint256 value);


      event TokensBurned(uint256 amount);

      event PoolAddressAdded(string pool, address sendAddress);

      event LuckPoolUpdated(uint256 luckPoolBal);

      event BurnTokenBalUpdated(uint256 burnTokenBal);




      modifier OnlyAllowed() {

        require(msg.sender == timeAlly || msg.sender == timeSwappers,"Only TimeAlly and Timeswapper is authorised");
        _;
      }

      modifier OnlyOwner() {

        require(msg.sender == Owner,"Only Owner is authorised");
        _;
      }




      function burnTokens() internal returns (bool){

        if(burnTokenBal == 0){
          return true;
        }
        else{
          uint MaxAmount = ((token.totalSupply()).mul(2)).div(100);   // max amount permitted to burn in a month
          if(MaxAmount >= burnTokenBal ){
            token.burn(burnTokenBal);
            burnTokenBal = 0;
          }
          else{
            burnTokenBal = burnTokenBal.sub(MaxAmount);
            token.burn(MaxAmount);
          }
          return true;
        }
      }



      function UpdateAddresses (address[9] calldata pool) external OnlyOwner  returns(bool){

        if((pool[0] != address(0)) && (newTalentsAndPartnerships == address(0))){
          newTalentsAndPartnerships = pool[0];
          emit PoolAddressAdded( "NewTalentsAndPartnerships", newTalentsAndPartnerships);
        }
        if((pool[1] != address(0)) && (platformMaintenance == address(0))){
          platformMaintenance = pool[1];
          emit PoolAddressAdded( "PlatformMaintenance", platformMaintenance);
        }
        if((pool[2] != address(0)) && (marketingAndRNR == address(0))){
          marketingAndRNR = pool[2];
          emit PoolAddressAdded( "MarketingAndRNR", marketingAndRNR);
        }
        if((pool[3] != address(0)) && (kmPards == address(0))){
          kmPards = pool[3];
          emit PoolAddressAdded( "KmPards", kmPards);
        }
        if((pool[4] != address(0)) && (contingencyFunds == address(0))){
          contingencyFunds = pool[4];
          emit PoolAddressAdded( "ContingencyFunds", contingencyFunds);
        }
        if((pool[5] != address(0)) && (researchAndDevelopment == address(0))){
          researchAndDevelopment = pool[5];
          emit PoolAddressAdded( "ResearchAndDevelopment", researchAndDevelopment);
        }
        if((pool[6] != address(0)) && (powerToken == address(0))){
          powerToken = pool[6];
          emit PoolAddressAdded( "PowerToken", powerToken);
        }
        if((pool[7] != address(0)) && (timeSwappers == address(0))){
          timeSwappers = pool[7];
          emit PoolAddressAdded( "TimeSwapper", timeSwappers);
        }
        if((pool[8] != address(0)) && (timeAlly == address(0))){
          timeAlly = pool[8];
          emit PoolAddressAdded( "TimeAlly", timeAlly);
        }

        return true;
      }


      function UpdateLuckpool(uint256 amount) external OnlyAllowed returns(bool){

              luckPoolBal = luckPoolBal.add(amount);
        emit LuckPoolUpdated(luckPoolBal);
        return true;
      }

      function UpdateBurnBal(uint256 amount) external OnlyAllowed returns(bool){

             burnTokenBal = burnTokenBal.add(amount);
        emit BurnTokenBalUpdated(burnTokenBal);
        return true;
      }


      function MonthlyNRTRelease() external returns (bool) {

        require(now.sub(lastNRTRelease)> 2629744,"NRT release happens once every month");
        uint256 NRTBal = monthlyNRTAmount.add(luckPoolBal);        // Total NRT available.

        newTalentsAndPartnershipsBal = (NRTBal.mul(5)).div(100);
        platformMaintenanceBal = (NRTBal.mul(10)).div(100);
        marketingAndRNRBal = (NRTBal.mul(10)).div(100);
        kmPardsBal = (NRTBal.mul(10)).div(100);
        contingencyFundsBal = (NRTBal.mul(10)).div(100);
        researchAndDevelopmentBal = (NRTBal.mul(5)).div(100);

        powerTokenNRT = (NRTBal.mul(10)).div(100);
        timeAllyNRT = (NRTBal.mul(15)).div(100);
        timeSwappersNRT = (NRTBal.mul(25)).div(100);

        token.mint(newTalentsAndPartnerships,newTalentsAndPartnershipsBal);
        emit NRTTransfer("newTalentsAndPartnerships", newTalentsAndPartnerships, newTalentsAndPartnershipsBal);

        token.mint(platformMaintenance,platformMaintenanceBal);
        emit NRTTransfer("platformMaintenance", platformMaintenance, platformMaintenanceBal);

        token.mint(marketingAndRNR,marketingAndRNRBal);
        emit NRTTransfer("marketingAndRNR", marketingAndRNR, marketingAndRNRBal);

        token.mint(kmPards,kmPardsBal);
        emit NRTTransfer("kmPards", kmPards, kmPardsBal);

        token.mint(contingencyFunds,contingencyFundsBal);
        emit NRTTransfer("contingencyFunds", contingencyFunds, contingencyFundsBal);

        token.mint(researchAndDevelopment,researchAndDevelopmentBal);
        emit NRTTransfer("researchAndDevelopment", researchAndDevelopment, researchAndDevelopmentBal);

        token.mint(powerToken,powerTokenNRT);
        emit NRTTransfer("powerToken", powerToken, powerTokenNRT);

        token.mint(timeAlly,timeAllyNRT);
        TimeAlly timeAllyContract = TimeAlly(timeAlly);
        timeAllyContract.increaseMonth(timeAllyNRT);
        emit NRTTransfer("stakingContract", timeAlly, timeAllyNRT);

        token.mint(timeSwappers,timeSwappersNRT);
        emit NRTTransfer("timeSwappers", timeSwappers, timeSwappersNRT);

        emit NRTDistributed(NRTBal);
        luckPoolBal = 0;
        lastNRTRelease = lastNRTRelease.add(2629744); // @dev adding seconds according to 1 Year = 365.242 days
        burnTokens();                                 // burning burnTokenBal
        emit TokensBurned(burnTokenBal);


        if(monthCount == 11){
          monthCount = 0;
          annualNRTAmount = (annualNRTAmount.mul(90)).div(100);
          monthlyNRTAmount = annualNRTAmount.div(12);
        }
        else{
          monthCount = monthCount.add(1);
        }
        return true;
      }



    constructor(address eraswaptoken) public{
      token = Eraswap(eraswaptoken);
      lastNRTRelease = now;
      annualNRTAmount = 819000000000000000000000000;
      monthlyNRTAmount = annualNRTAmount.div(uint256(12));
      monthCount = 0;
      Owner = msg.sender;
    }

}
pragma solidity 0.5.10;



contract TimeAlly {

    using SafeMath for uint256;

    struct Staking {
        uint256 exaEsAmount;
        uint256 timestamp;
        uint256 stakingMonth;
        uint256 stakingPlanId;
        uint256 status; /// @dev 1 => active; 2 => loaned; 3 => withdrawed; 4 => cancelled; 5 => nomination mode
        uint256 loanId;
        uint256 totalNominationShares;
        mapping (uint256 => bool) isMonthClaimed;
        mapping (address => uint256) nomination;
    }

    struct StakingPlan {
        uint256 months;
        uint256 fractionFrom15; /// @dev fraction of NRT released. Alotted to TimeAlly is 15% of NRT
        bool isUrgentLoanAllowed; /// @dev if urgent loan is not allowed then staker can take loan only after 75% (hard coded) of staking months
    }

    struct Loan {
        uint256 exaEsAmount;
        uint256 timestamp;
        uint256 loanPlanId;
        uint256 status; // @dev 1 => not repayed yet; 2 => repayed
        uint256[] stakingIds;
    }

    struct LoanPlan {
        uint256 loanMonths;
        uint256 loanRate; // @dev amount of charge to pay, this will be sent to luck pool
        uint256 maxLoanAmountPercent; /// @dev max loan user can take depends on this percent of the plan and the stakings user wishes to put for the loan
    }

    uint256 public deployedTimestamp;
    address public owner;
    Eraswap public token;
    NRTManager public nrtManager;

    uint256 public earthSecondsInMonth = 2629744;

    StakingPlan[] public stakingPlans;
    LoanPlan[] public loanPlans;

    mapping(address => Staking[]) public stakings;
    mapping(address => Loan[]) public loans;
    mapping(address => uint256) public launchReward;

    mapping (uint256 => uint256) public totalActiveStakings;

    uint256[] public timeAllyMonthlyNRT;

    event NewStaking (
        address indexed _userAddress,
        uint256 indexed _stakePlanId,
        uint256 _exaEsAmount,
        uint256 _stakingId
    );

    event PrincipalWithdrawl (
        address indexed _userAddress,
        uint256 _stakingId
    );

    event NomineeNew (
        address indexed _userAddress,
        uint256 indexed _stakingId,
        address indexed _nomineeAddress
    );

    event NomineeWithdraw (
        address indexed _userAddress,
        uint256 indexed _stakingId,
        address indexed _nomineeAddress,
        uint256 _liquid,
        uint256 _accrued
    );

    event BenefitWithdrawl (
        address indexed _userAddress,
        uint256 _stakingId,
        uint256[] _months,
        uint256 _halfBenefit
    );

    event NewLoan (
        address indexed _userAddress,
        uint256 indexed _loanPlanId,
        uint256 _exaEsAmount,
        uint256 _loanInterest,
        uint256 _loanId
    );

    event RepayLoan (
        address indexed _userAddress,
        uint256 _loanId
    );


    modifier onlyNRTManager() {

        require(
          msg.sender == address(nrtManager)
        );
        _;
    }

    modifier onlyOwner() {

        require(
          msg.sender == owner
        );
        _;
    }

    constructor(address _tokenAddress, address _nrtAddress) public {
        owner = msg.sender;
        token = Eraswap(_tokenAddress);
        nrtManager = NRTManager(_nrtAddress);
        deployedTimestamp = now;
        timeAllyMonthlyNRT.push(0); /// @dev first month there is no NRT released
    }

    function increaseMonth(uint256 _timeAllyNRT) public onlyNRTManager {

        timeAllyMonthlyNRT.push(_timeAllyNRT);
    }

    function getCurrentMonth() public view returns (uint256) {

        return timeAllyMonthlyNRT.length - 1;
    }

    function createStakingPlan(uint256 _months, uint256 _fractionFrom15, bool _isUrgentLoanAllowed) public onlyOwner {

        stakingPlans.push(StakingPlan({
            months: _months,
            fractionFrom15: _fractionFrom15,
            isUrgentLoanAllowed: _isUrgentLoanAllowed
        }));
    }

    function createLoanPlan(uint256 _loanMonths, uint256 _loanRate, uint256 _maxLoanAmountPercent) public onlyOwner {

        require(_maxLoanAmountPercent <= 100
        );
        loanPlans.push(LoanPlan({
            loanMonths: _loanMonths,
            loanRate: _loanRate,
            maxLoanAmountPercent: _maxLoanAmountPercent
        }));
    }



    function newStaking(uint256 _exaEsAmount, uint256 _stakingPlanId) public {


        require(_exaEsAmount > 0
        );

        require(token.transferFrom(msg.sender, address(this), _exaEsAmount)
        );
        uint256 stakeEndMonth = getCurrentMonth() + stakingPlans[_stakingPlanId].months;

        for(
          uint256 month = getCurrentMonth() + 1;
          month <= stakeEndMonth;
          month++
        ) {
            totalActiveStakings[month] = totalActiveStakings[month].add(_exaEsAmount);
        }

        stakings[msg.sender].push(Staking({
            exaEsAmount: _exaEsAmount,
            timestamp: now,
            stakingMonth: getCurrentMonth(),
            stakingPlanId: _stakingPlanId,
            status: 1,
            loanId: 0,
            totalNominationShares: 0
        }));

        emit NewStaking(msg.sender, _stakingPlanId, _exaEsAmount, stakings[msg.sender].length - 1);
    }

    function getNumberOfStakingsByUser(address _userAddress) public view returns (uint256) {

        return stakings[_userAddress].length;
    }

    function topupRewardBucket(uint256 _exaEsAmount) public {

        require(token.transferFrom(msg.sender, address(this), _exaEsAmount));
        launchReward[msg.sender] = launchReward[msg.sender].add(_exaEsAmount);
    }

    function giveLaunchReward(address[] memory _addresses, uint256[] memory _exaEsAmountArray) public onlyOwner {

        for(uint256 i = 0; i < _addresses.length; i++) {
            launchReward[msg.sender] = launchReward[msg.sender].sub(_exaEsAmountArray[i]);
            launchReward[_addresses[i]] = launchReward[_addresses[i]].add(_exaEsAmountArray[i]);
        }
    }

    function claimLaunchReward(uint256 _stakingPlanId) public {


        require(launchReward[msg.sender] > 0
        );
        uint256 reward = launchReward[msg.sender];
        launchReward[msg.sender] = 0;

        uint256 stakeEndMonth = getCurrentMonth() + stakingPlans[_stakingPlanId].months;

        for(
          uint256 month = getCurrentMonth() + 1;
          month <= stakeEndMonth;
          month++
        ) {
            totalActiveStakings[month] = totalActiveStakings[month].add(reward); /// @dev reward means locked ES which only staking option
        }

        stakings[msg.sender].push(Staking({
            exaEsAmount: reward,
            timestamp: now,
            stakingMonth: getCurrentMonth(),
            stakingPlanId: _stakingPlanId,
            status: 1,
            loanId: 0,
            totalNominationShares: 0
        }));

        emit NewStaking(msg.sender, _stakingPlanId, reward, stakings[msg.sender].length - 1);
    }


    function isStakingActive(
        address _userAddress,
        uint256 _stakingId,
        uint256 _atMonth
    ) public view returns (bool) {


        return (
            stakings[_userAddress][_stakingId].stakingMonth + 1 <= _atMonth

            && stakings[_userAddress][_stakingId].stakingMonth + stakingPlans[ stakings[_userAddress][_stakingId].stakingPlanId ].months >= _atMonth

            && stakings[_userAddress][_stakingId].status == 1

            && (
              getCurrentMonth() != _atMonth
              || now >= stakings[_userAddress][_stakingId].timestamp
                          .add(
                            getCurrentMonth()
                              .sub(stakings[_userAddress][_stakingId].stakingMonth)
                              .mul(earthSecondsInMonth)
                          )
              )
            );
    }


    function seeBenefitOfAStakingByMonths(
        address _userAddress,
        uint256 _stakingId,
        uint256[] memory _months
    ) public view returns (uint256) {

        uint256 benefitOfAllMonths;
        for(uint256 i = 0; i < _months.length; i++) {
            if(isStakingActive(_userAddress, _stakingId, _months[i])
            && !stakings[_userAddress][_stakingId].isMonthClaimed[_months[i]]) {
                uint256 benefit = stakings[_userAddress][_stakingId].exaEsAmount
                                  .mul(timeAllyMonthlyNRT[ _months[i] ])
                                  .div(totalActiveStakings[ _months[i] ]);
                benefitOfAllMonths = benefitOfAllMonths.add(benefit);
            }
        }
        return benefitOfAllMonths.mul(
          stakingPlans[stakings[_userAddress][_stakingId].stakingPlanId].fractionFrom15
        ).div(15);
    }

    function withdrawBenefitOfAStakingByMonths(
        uint256 _stakingId,
        uint256[] memory _months
    ) public {

        uint256 _benefitOfAllMonths;
        for(uint256 i = 0; i < _months.length; i++) {
            if(isStakingActive(msg.sender, _stakingId, _months[i])
            && !stakings[msg.sender][_stakingId].isMonthClaimed[_months[i]]) {
                uint256 _benefit = stakings[msg.sender][_stakingId].exaEsAmount
                                  .mul(timeAllyMonthlyNRT[ _months[i] ])
                                  .div(totalActiveStakings[ _months[i] ]);

                _benefitOfAllMonths = _benefitOfAllMonths.add(_benefit);
                stakings[msg.sender][_stakingId].isMonthClaimed[_months[i]] = true;
            }
        }

        uint256 _luckPool = _benefitOfAllMonths
                        .mul( uint256(15).sub(stakingPlans[stakings[msg.sender][_stakingId].stakingPlanId].fractionFrom15) )
                        .div( 15 );

        require( token.transfer(address(nrtManager), _luckPool) );
        require( nrtManager.UpdateLuckpool(_luckPool) );

        _benefitOfAllMonths = _benefitOfAllMonths.sub(_luckPool);

        uint256 _halfBenefit = _benefitOfAllMonths.div(2);
        require( token.transfer(msg.sender, _halfBenefit) );

        launchReward[msg.sender] = launchReward[msg.sender].add(_halfBenefit);

        emit BenefitWithdrawl(msg.sender, _stakingId, _months, _halfBenefit);
    }


    function withdrawExpiredStakings(uint256[] memory _stakingIds) public {

        for(uint256 i = 0; i < _stakingIds.length; i++) {
            require(now >= stakings[msg.sender][_stakingIds[i]].timestamp
                    .add(stakingPlans[ stakings[msg.sender][_stakingIds[i]].stakingPlanId ].months.mul(earthSecondsInMonth))
            );
            stakings[msg.sender][_stakingIds[i]].status = 3;

            token.transfer(msg.sender, stakings[msg.sender][_stakingIds[i]].exaEsAmount);

            emit PrincipalWithdrawl(msg.sender, _stakingIds[i]);
        }
    }

    function seeMaxLoaningAmountOnUserStakings(address _userAddress, uint256[] memory _stakingIds, uint256 _loanPlanId) public view returns (uint256) {

        uint256 _currentMonth = getCurrentMonth();

        uint256 userStakingsExaEsAmount;

        for(uint256 i = 0; i < _stakingIds.length; i++) {

            if(isStakingActive(_userAddress, _stakingIds[i], _currentMonth)
                && (
                  stakingPlans[ stakings[_userAddress][_stakingIds[i]].stakingPlanId ].isUrgentLoanAllowed
                  || now > stakings[_userAddress][_stakingIds[i]].timestamp + stakingPlans[ stakings[_userAddress][_stakingIds[i]].stakingPlanId ].months.mul(earthSecondsInMonth).mul(75).div(100)
                )
            ) {
                userStakingsExaEsAmount = userStakingsExaEsAmount
                    .add(stakings[_userAddress][_stakingIds[i]].exaEsAmount
                      .mul(loanPlans[_loanPlanId].maxLoanAmountPercent)
                      .div(100)
                    );
            }
        }

        return userStakingsExaEsAmount;
    }

    function takeLoanOnSelfStaking(uint256 _loanPlanId, uint256 _exaEsAmount, uint256[] memory _stakingIds) public {

        uint256 _currentMonth = getCurrentMonth();
        uint256 _userStakingsExaEsAmount;

        for(uint256 i = 0; i < _stakingIds.length; i++) {

            if( isStakingActive(msg.sender, _stakingIds[i], _currentMonth)
                && (
                  stakingPlans[ stakings[msg.sender][_stakingIds[i]].stakingPlanId ].isUrgentLoanAllowed
                  || now > stakings[msg.sender][_stakingIds[i]].timestamp + stakingPlans[ stakings[msg.sender][_stakingIds[i]].stakingPlanId ].months.mul(earthSecondsInMonth).mul(75).div(100)
                )
            ) {

                _userStakingsExaEsAmount = _userStakingsExaEsAmount
                    .add(
                        stakings[msg.sender][ _stakingIds[i] ].exaEsAmount
                          .mul(loanPlans[_loanPlanId].maxLoanAmountPercent)
                          .div(100)
                );

                uint256 stakingStartMonth = stakings[msg.sender][_stakingIds[i]].stakingMonth;

                uint256 stakeEndMonth = stakingStartMonth + stakingPlans[stakings[msg.sender][_stakingIds[i]].stakingPlanId].months;

                for(uint256 j = _currentMonth + 1; j <= stakeEndMonth; j++) {
                    totalActiveStakings[j] = totalActiveStakings[j].sub(_userStakingsExaEsAmount);
                }

                for(uint256 j = 1; j <= loanPlans[_loanPlanId].loanMonths; j++) {
                    stakings[msg.sender][ _stakingIds[i] ].isMonthClaimed[ _currentMonth + j ] = true;
                    stakings[msg.sender][ _stakingIds[i] ].status = 2; // means in loan
                }
            }
        }

        uint256 _maxLoaningAmount = _userStakingsExaEsAmount;

        if(_exaEsAmount > _maxLoaningAmount) {
            require(false
            );
        }


        uint256 _loanInterest = _exaEsAmount.mul(loanPlans[_loanPlanId].loanRate).div(100);
        uint256 _loanAmountToTransfer = _exaEsAmount.sub(_loanInterest);

        require( token.transfer(address(nrtManager), _loanInterest) );
        require( nrtManager.UpdateLuckpool(_loanInterest) );

        loans[msg.sender].push(Loan({
            exaEsAmount: _exaEsAmount,
            timestamp: now,
            loanPlanId: _loanPlanId,
            status: 1,
            stakingIds: _stakingIds
        }));

        require( token.transfer(msg.sender, _loanAmountToTransfer) );

        emit NewLoan(msg.sender, _loanPlanId, _exaEsAmount, _loanInterest, loans[msg.sender].length - 1);
    }

    function repayLoanSelf(uint256 _loanId) public {

        require(loans[msg.sender][_loanId].status == 1
        );

        require(loans[msg.sender][_loanId].timestamp + loanPlans[ loans[msg.sender][_loanId].loanPlanId ].loanMonths.mul(earthSecondsInMonth) > now
        );

        require(token.transferFrom(msg.sender, address(this), loans[msg.sender][_loanId].exaEsAmount)
        );

        loans[msg.sender][_loanId].status = 2;

        for(uint256 i = 0; i < loans[msg.sender][_loanId].stakingIds.length; i++) {
            uint256 _stakingId = loans[msg.sender][_loanId].stakingIds[i];

            stakings[msg.sender][_stakingId].status = 1;

            uint256 stakingStartMonth = stakings[msg.sender][_stakingId].timestamp.sub(deployedTimestamp).div(earthSecondsInMonth);

            uint256 stakeEndMonth = stakingStartMonth + stakingPlans[stakings[msg.sender][_stakingId].stakingPlanId].months;

            for(uint256 j = getCurrentMonth() + 1; j <= stakeEndMonth; j++) {
                stakings[msg.sender][_stakingId].isMonthClaimed[i] = false;

                totalActiveStakings[j] = totalActiveStakings[j].add(stakings[msg.sender][_stakingId].exaEsAmount);
            }
        }
        emit RepayLoan(msg.sender, _loanId);
    }

    function burnDefaultedLoans(address[] memory _addressArray, uint256[] memory _loanIdArray) public {

        uint256 _amountToBurn;
        for(uint256 i = 0; i < _addressArray.length; i++) {
            require(
                loans[ _addressArray[i] ][ _loanIdArray[i] ].status == 1
            );
            require(
                now >
                loans[ _addressArray[i] ][ _loanIdArray[i] ].timestamp
                + loanPlans[ loans[ _addressArray[i] ][ _loanIdArray[i] ].loanPlanId ].loanMonths.mul(earthSecondsInMonth)
            );
            uint256[] storage _stakingIdsOfLoan = loans[ _addressArray[i] ][ _loanIdArray[i] ].stakingIds;

            for(uint256 j = 0; j < _stakingIdsOfLoan.length; j++) {
                _amountToBurn = _amountToBurn.add(
                    stakings[ _addressArray[i] ][ _stakingIdsOfLoan[j] ].exaEsAmount
                );
            }
            _amountToBurn = _amountToBurn.sub(
                loans[ _addressArray[i] ][ _loanIdArray[i] ].exaEsAmount
            );
        }
        require(token.transfer(address(nrtManager), _amountToBurn));
        require(nrtManager.UpdateBurnBal(_amountToBurn));

    }

    function addNominee(uint256 _stakingId, address _nomineeAddress, uint256 _shares) public {

        require(stakings[msg.sender][_stakingId].status == 1
        );
        require(stakings[msg.sender][_stakingId].nomination[_nomineeAddress] == 0
        );
        stakings[msg.sender][_stakingId].totalNominationShares = stakings[msg.sender][_stakingId].totalNominationShares.add(_shares);
        stakings[msg.sender][_stakingId].nomination[_nomineeAddress] = _shares;
        emit NomineeNew(msg.sender, _stakingId, _nomineeAddress);
    }

    function viewNomination(address _userAddress, uint256 _stakingId, address _nomineeAddress) public view returns (uint256) {

        return stakings[_userAddress][_stakingId].nomination[_nomineeAddress];
    }


    function removeNominee(uint256 _stakingId, address _nomineeAddress) public {

        require(stakings[msg.sender][_stakingId].status == 1, 'staking should active');
        uint256 _oldShares = stakings[msg.sender][_stakingId].nomination[msg.sender];
        stakings[msg.sender][_stakingId].nomination[_nomineeAddress] = 0;
        stakings[msg.sender][_stakingId].totalNominationShares = stakings[msg.sender][_stakingId].totalNominationShares.sub(_oldShares);
    }

    function nomineeWithdraw(address _userAddress, uint256 _stakingId) public {

        uint256 currentTime = now;
        require( currentTime > (stakings[_userAddress][_stakingId].timestamp
                    + stakingPlans[stakings[_userAddress][_stakingId].stakingPlanId].months * earthSecondsInMonth
                    + 12 * earthSecondsInMonth )
            );

        uint256 _nomineeShares = stakings[_userAddress][_stakingId].nomination[msg.sender];
        require(_nomineeShares > 0
        );


        if(stakings[_userAddress][_stakingId].status != 5) {
            stakings[_userAddress][_stakingId].status = 5;
        }

        uint256 _pendingLiquidAmountInStaking = stakings[_userAddress][_stakingId].exaEsAmount;
        uint256 _pendingAccruedAmountInStaking;

        uint256 _stakeEndMonth = stakings[_userAddress][_stakingId].stakingMonth + stakingPlans[stakings[_userAddress][_stakingId].stakingPlanId].months;

        for(
          uint256 i = stakings[_userAddress][_stakingId].stakingMonth; //_stakingStartMonth;
          i < _stakeEndMonth;
          i++
        ) {
            if( stakings[_userAddress][_stakingId].isMonthClaimed[i] ) {
                uint256 _effectiveAmount = stakings[_userAddress][_stakingId].exaEsAmount
                  .mul(stakingPlans[stakings[_userAddress][_stakingId].stakingPlanId].fractionFrom15)
                  .div(15);
                uint256 _monthlyBenefit = _effectiveAmount
                                          .mul(timeAllyMonthlyNRT[i])
                                          .div(totalActiveStakings[i]);
                _pendingLiquidAmountInStaking = _pendingLiquidAmountInStaking.add(_monthlyBenefit.div(2));
                _pendingAccruedAmountInStaking = _pendingAccruedAmountInStaking.add(_monthlyBenefit.div(2));
            }
        }


        stakings[_userAddress][_stakingId].nomination[msg.sender] = 0;

        uint256 _nomineeLiquidShare = _pendingLiquidAmountInStaking
                                        .mul(_nomineeShares)
                                        .div(stakings[_userAddress][_stakingId].totalNominationShares);
        token.transfer(msg.sender, _nomineeLiquidShare);

        uint256 _nomineeAccruedShare = _pendingAccruedAmountInStaking
                                          .mul(_nomineeShares)
                                          .div(stakings[_userAddress][_stakingId].totalNominationShares);
        launchReward[msg.sender] = launchReward[msg.sender].add(_nomineeAccruedShare);

        emit NomineeWithdraw(_userAddress, _stakingId, msg.sender, _nomineeLiquidShare, _nomineeAccruedShare);
    }
}
