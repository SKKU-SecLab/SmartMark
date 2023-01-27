

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity >=0.4.24 <0.6.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
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

        return _msgSender() == _owner;
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

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract PauserRole is Initializable, Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {

        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;




contract Pausable is Initializable, Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function initialize(address sender) public initializer {

        PauserRole.initialize(sender);

        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[50] private ______gap;
}


pragma solidity 0.5.13;


contract EthicHubStorageInterface {


    modifier onlyEthicHubContracts() {_;}


    function setAddress(bytes32 _key, address _value) external;

    function setUint(bytes32 _key, uint _value) external;

    function setString(bytes32 _key, string calldata _value) external;

    function setBytes(bytes32 _key, bytes calldata _value) external;

    function setBool(bytes32 _key, bool _value) external;

    function setInt(bytes32 _key, int _value) external;

    function deleteAddress(bytes32 _key) external;

    function deleteUint(bytes32 _key) external;

    function deleteString(bytes32 _key) external;

    function deleteBytes(bytes32 _key) external;

    function deleteBool(bytes32 _key) external;

    function deleteInt(bytes32 _key) external;


    function getAddress(bytes32 _key) external view returns (address);

    function getUint(bytes32 _key) external view returns (uint);

    function getString(bytes32 _key) external view returns (string memory);

    function getBytes(bytes32 _key) external view returns (bytes memory);

    function getBool(bytes32 _key) external view returns (bool);

    function getInt(bytes32 _key) external view returns (int);

}


pragma solidity 0.5.13;



contract EthicHubBase is Initializable {


    uint8 public version;

    EthicHubStorageInterface public ethicHubStorage;

    function initialize(address _ethicHubStorage, uint8 _version) public initializer {

        require(address(_ethicHubStorage) != address(0), "Storage address cannot be zero address");
        ethicHubStorage = EthicHubStorageInterface(_ethicHubStorage);
        version = _version;
    }
}


pragma solidity 0.5.13;







contract EthicHubLending is Pausable, Ownable {

    using SafeMath for uint256;

    enum LendingState {
        Uninitialized,
        AcceptingContributions,
        ExchangingToFiat,
        AwaitingReturn,
        ProjectNotFunded,
        ContributionReturned,
        Default
    }

    uint8 public version;
    EthicHubStorageInterface public ethicHubStorage;

    IERC20 public stableCoin;

    mapping(address => Investor) public investors;

    uint256 public investorCount;
    uint256 public reclaimedContributions;
    uint256 public fundingStartTime; // Start time of contribution period in UNIX time
    uint256 public fundingEndTime; // End time of contribution period in UNIX time
    uint256 public totalContributed;

    bool public capReached;

    LendingState public state;

    uint256 public annualInterest;
    uint256 public totalLendingAmount;
    uint256 public lendingDays;
    uint256 public borrowerReturnDays;
    uint256 public initialStableCoinPerFiatRate;
    uint256 public totalLendingFiatAmount;

    address public borrower;
    address public localNode;
    address public ethicHubTeam;

    address public depositManager;

    uint256 public borrowerReturnStableCoinPerFiatRate;
    uint256 public ethichubFee;
    uint256 public localNodeFee;

    uint256 public constant interestBaseUint = 100;
    uint256 public constant interestBasePercent = 10000;

    bool public localNodeFeeReclaimed;
    bool public ethicHubTeamFeeReclaimed;

    uint256 public returnedAmount;

    struct Investor {
        uint256 amount;
        bool isCompensated;
    }

    event CapReached(uint endTime);
    event Contribution(uint totalContributed, address indexed investor, uint amount, uint investorsCount);
    event Compensated(address indexed contributor, uint amount);
    event StateChange(uint state);
    event InitalRateSet(uint rate);
    event ReturnRateSet(uint rate);
    event ReturnAmount(address indexed borrower, uint amount);
    event BorrowerChanged(address indexed newBorrower);
    event InvestorChanged(address indexed oldInvestor, address indexed newInvestor);
    event Reclaim(address indexed target, uint256 amount);

    modifier checkIfArbiter() {

        address arbiter = ethicHubStorage.getAddress(keccak256(abi.encodePacked("arbiter", this)));
        require(arbiter == msg.sender, "Sender not authorized");
        _;
    }

    modifier onlyOwnerOrLocalNode() {

        require(localNode == msg.sender || owner() == msg.sender,"Sender not authorized");
        _;
    }

    constructor(
        uint256 _fundingStartTime,
        uint256 _fundingEndTime,
        uint256 _annualInterest,
        uint256 _totalLendingAmount,
        uint256 _lendingDays,
        uint256 _ethichubFee,
        uint256 _localNodeFee,
        address _borrower,
        address _localNode,
        address _ethicHubTeam,
        address _depositManager,
        address _ethicHubStorage,
        address _stableCoin
        ) public {
        require(address(_ethicHubStorage) != address(0), "Storage address cannot be zero address");

        ethicHubStorage = EthicHubStorageInterface(_ethicHubStorage);
        version = 8;

        require(_fundingEndTime > fundingStartTime, "fundingEndTime should be later than fundingStartTime");
        require(_borrower != address(0), "No borrower set");
        require(ethicHubStorage.getBool(keccak256(abi.encodePacked("user", "representative", _borrower))), "Borrower not registered representative");
        require(_localNode != address(0), "No Local Node set");
        require(_ethicHubTeam != address(0), "No EthicHub Team set");
        require(ethicHubStorage.getBool(keccak256(abi.encodePacked("user", "localNode", _localNode))), "Local Node is not registered");
        require(_totalLendingAmount > 0, "_totalLendingAmount must be > 0");
        require(_lendingDays > 0, "_lendingDays must be > 0");
        require(_annualInterest > 0 && _annualInterest < 100, "_annualInterest must be between 0 and 100");

        reclaimedContributions = 0;
        borrowerReturnDays = 0;

        fundingStartTime = _fundingStartTime;
        fundingEndTime = _fundingEndTime;
        annualInterest = _annualInterest;
        totalLendingAmount = _totalLendingAmount;
        lendingDays = _lendingDays;
        ethichubFee = _ethichubFee;
        localNodeFee = _localNodeFee;

        borrower = _borrower;
        localNode = _localNode;
        ethicHubTeam = _ethicHubTeam;

        depositManager = _depositManager;

        stableCoin = IERC20(_stableCoin);

        state = LendingState.Uninitialized;

        Ownable.initialize(msg.sender);
        Pausable.initialize(msg.sender);
    }

    function saveInitialParametersToStorage(
        uint256 _maxDelayDays,
        uint256 _communityMembers,
        address _community
        ) external onlyOwnerOrLocalNode {

        require(_maxDelayDays != 0, "_maxDelayDays must be > 0");
        require(state == LendingState.Uninitialized, "State must be Uninitialized");
        require(_communityMembers > 0, "_communityMembers must be > 0");
        require(ethicHubStorage.getBool(keccak256(abi.encodePacked("user", "community", _community))), "Community is not registered");

        ethicHubStorage.setUint(keccak256(abi.encodePacked("lending.maxDelayDays", this)), _maxDelayDays);
        ethicHubStorage.setAddress(keccak256(abi.encodePacked("lending.community", this)), _community);
        ethicHubStorage.setAddress(keccak256(abi.encodePacked("lending.localNode", this)), localNode);
        ethicHubStorage.setUint(keccak256(abi.encodePacked("lending.communityMembers", this)), _communityMembers);

        changeState(LendingState.AcceptingContributions);
    }

    function setBorrower(address _borrower) external checkIfArbiter {

        require(_borrower != address(0), "No borrower set");
        require(ethicHubStorage.getBool(keccak256(abi.encodePacked("user", "representative", _borrower))), "Borrower not registered representative");

        borrower = _borrower;

        emit BorrowerChanged(borrower);
    }

    function changeInvestorAddress(address oldInvestor, address newInvestor) external checkIfArbiter {

        require(newInvestor != address(0));
        require(ethicHubStorage.getBool(keccak256(abi.encodePacked("user", "investor", newInvestor))));
        require(investors[oldInvestor].amount != 0, "OldInvestor should have invested in this project");
        require(
            investors[newInvestor].amount == 0,
            "newInvestor should not have invested anything"
        );

        investors[newInvestor].amount = investors[oldInvestor].amount;
        investors[newInvestor].isCompensated = investors[oldInvestor].isCompensated;

        delete investors[oldInvestor];

        emit InvestorChanged(oldInvestor, newInvestor);
    }

    function deposit(address contributor, uint256 amount) external {

        require(
            msg.sender == depositManager,
            "Caller is not a deposit manager"
        );
        require(
            state == LendingState.AcceptingContributions ||
            state == LendingState.AwaitingReturn,
            "Can't contribute in this state"
        );

        if(state == LendingState.AcceptingContributions) {
            contributeWithAddress(contributor, amount);
        } else {
            require(contributor == borrower, "In state AwaitingReturn only borrower can contribute");
            returnBorrowed(amount);
        }
    }

    function declareProjectNotFunded() external onlyOwnerOrLocalNode {

        require(totalContributed < totalLendingAmount);
        require(state == LendingState.AcceptingContributions);
        require(now > fundingEndTime);

        changeState(LendingState.ProjectNotFunded);
    }

    function declareProjectDefault() external onlyOwnerOrLocalNode {

        require(state == LendingState.AwaitingReturn);
        uint maxDelayDays = getMaxDelayDays();
        require(getDelayDays(now) >= maxDelayDays);

        ethicHubStorage.setUint(keccak256(abi.encodePacked("lending.delayDays", this)), maxDelayDays);

        changeState(LendingState.Default);
    }

    function setborrowerReturnStableCoinPerFiatRate(uint256 _borrowerReturnStableCoinPerFiatRate) external onlyOwnerOrLocalNode {

        require(state == LendingState.AwaitingReturn, "State is not AwaitingReturn");

        borrowerReturnStableCoinPerFiatRate = _borrowerReturnStableCoinPerFiatRate;

        emit ReturnRateSet(borrowerReturnStableCoinPerFiatRate);
    }

    function finishInitialExchangingPeriod(uint256 _initialStableCoinPerFiatRate) external onlyOwnerOrLocalNode {

        require(capReached == true, "Cap not reached");
        require(state == LendingState.ExchangingToFiat, "State is not ExchangingToFiat");

        initialStableCoinPerFiatRate = _initialStableCoinPerFiatRate;
        totalLendingFiatAmount = totalLendingAmount.mul(initialStableCoinPerFiatRate);

        emit InitalRateSet(initialStableCoinPerFiatRate);

        changeState(LendingState.AwaitingReturn);
    }

    function reclaimContributionDefault(address beneficiary) external {

        require(state == LendingState.Default);
        require(!investors[beneficiary].isCompensated);

        uint256 contribution = checkInvestorReturns(beneficiary);

        require(contribution > 0);

        investors[beneficiary].isCompensated = true;
        reclaimedContributions = reclaimedContributions.add(1);

        doReclaim(beneficiary, contribution);
    }

    function reclaimContribution(address beneficiary) external {

        require(state == LendingState.ProjectNotFunded, "State is not ProjectNotFunded");
        require(!investors[beneficiary].isCompensated, "Contribution already reclaimed");
        uint256 contribution = investors[beneficiary].amount;
        require(contribution > 0, "Contribution is 0");

        investors[beneficiary].isCompensated = true;
        reclaimedContributions = reclaimedContributions.add(1);

        doReclaim(beneficiary, contribution);
    }

    function reclaimContributionWithInterest(address beneficiary) external {

        require(state == LendingState.ContributionReturned, "State is not ContributionReturned");
        require(!investors[beneficiary].isCompensated, "Lender already compensated");
        uint256 contribution = checkInvestorReturns(beneficiary);
        require(contribution > 0, "Contribution is 0");

        investors[beneficiary].isCompensated = true;
        reclaimedContributions = reclaimedContributions.add(1);

        doReclaim(beneficiary, contribution);
    }

    function reclaimLocalNodeFee() external {

        require(state == LendingState.ContributionReturned, "State is not ContributionReturned");
        require(localNodeFeeReclaimed == false, "Local Node's fee already reclaimed");
        uint256 fee = totalLendingFiatAmount.mul(localNodeFee).mul(interestBaseUint).div(interestBasePercent).div(borrowerReturnStableCoinPerFiatRate);
        require(fee > 0, "Local Node's team fee is 0");

        localNodeFeeReclaimed = true;

        doReclaim(localNode, fee);
    }

    function reclaimEthicHubTeamFee() external {

        require(state == LendingState.ContributionReturned, "State is not ContributionReturned");
        require(ethicHubTeamFeeReclaimed == false, "EthicHub team's fee already reclaimed");
        uint256 fee = totalLendingFiatAmount.mul(ethichubFee).mul(interestBaseUint).div(interestBasePercent).div(borrowerReturnStableCoinPerFiatRate);
        require(fee > 0, "EthicHub's team fee is 0");

        ethicHubTeamFeeReclaimed = true;

        doReclaim(ethicHubTeam, fee);
    }

    function reclaimLeftover() external checkIfArbiter {

        require(state == LendingState.ContributionReturned || state == LendingState.Default, "State is not ContributionReturned or Default");
        require(localNodeFeeReclaimed, "Local Node fee is not reclaimed");
        require(ethicHubTeamFeeReclaimed, "Team fee is not reclaimed");
        require(investorCount == reclaimedContributions, "Not all investors have reclaimed their share");

        doReclaim(ethicHubTeam, stableCoin.balanceOf(address(this)));
    }

    function doReclaim(address target, uint256 amount) internal {

        uint256 contractBalance = stableCoin.balanceOf(address(this));
        uint256 reclaimAmount = (contractBalance < amount) ? contractBalance : amount;

        require(stableCoin.transfer(target, reclaimAmount), "transfer stable token method failed");

        emit Reclaim(target, reclaimAmount);
    }

    function returnBorrowed(uint256 amount) internal {

        require(state == LendingState.AwaitingReturn, "State is not AwaitingReturn");
        require(borrowerReturnStableCoinPerFiatRate > 0, "Second exchange rate not set");

        bool projectRepayed = false;
        uint excessRepayment = 0;
        uint newReturnedAmount = 0;

        emit ReturnAmount(borrower, amount);

        (newReturnedAmount, projectRepayed, excessRepayment) = calculatePaymentGoal(borrowerReturnAmount(), returnedAmount, amount);

        returnedAmount = newReturnedAmount;

        if (projectRepayed == true) {
            borrowerReturnDays = getDaysPassedBetweenDates(fundingEndTime, now);
            changeState(LendingState.ContributionReturned);
        }

        if (excessRepayment > 0) {
            require(stableCoin.transfer(borrower, excessRepayment), "transfer stable token method failed");
        }
    }

    function contributeWithAddress(address contributor, uint256 amount) internal whenNotPaused {

        require(state == LendingState.AcceptingContributions, "state is not AcceptingContributions");
        require(isContribPeriodRunning(), "can't contribute outside contribution period");

        uint oldTotalContributed = totalContributed;
        uint newTotalContributed = 0;
        uint excessContribAmount = 0;

        (newTotalContributed, capReached, excessContribAmount) = calculatePaymentGoal(totalLendingAmount, oldTotalContributed, amount);

        totalContributed = newTotalContributed;

        if (capReached) {
            fundingEndTime = now;
            emit CapReached(fundingEndTime);
        }

        if (investors[contributor].amount == 0) {
            investorCount = investorCount.add(1);
        }

        if (excessContribAmount > 0) {
            require(stableCoin.transfer(contributor, excessContribAmount), "transfer stable token method failed");
            investors[contributor].amount = investors[contributor].amount.add(amount).sub(excessContribAmount);
            emit Contribution(newTotalContributed, contributor, amount.sub(excessContribAmount), investorCount);
        } else {
            investors[contributor].amount = investors[contributor].amount.add(amount);
            emit Contribution(newTotalContributed, contributor, amount, investorCount);
        }
    }

    function calculatePaymentGoal(uint goal, uint oldTotal, uint contribValue) internal pure returns(uint, bool, uint) {

        uint newTotal = oldTotal.add(contribValue);
        bool goalReached = false;
        uint excess = 0;
        if (newTotal >= goal && oldTotal < goal) {
            goalReached = true;
            excess = newTotal.sub(goal);
            contribValue = contribValue.sub(excess);
            newTotal = goal;
        }
        return (newTotal, goalReached, excess);
    }

    function sendFundsToBorrower() external onlyOwnerOrLocalNode {

        require(state == LendingState.AcceptingContributions, "State has to be AcceptingContributions");
        require(capReached, "Cap is not reached");

        changeState(LendingState.ExchangingToFiat);

        stableCoin.transfer(borrower, totalContributed);
    }

    function getDelayDays(uint date) public view returns(uint) {

        uint lendingDaysSeconds = lendingDays * 1 days;
        uint defaultTime = fundingEndTime.add(lendingDaysSeconds);

        if (date < defaultTime) {
            return 0;
        } else {
            return getDaysPassedBetweenDates(defaultTime, date);
        }
    }

    function getDaysPassedBetweenDates(uint firstDate, uint lastDate) public pure returns(uint) {

        require(firstDate <= lastDate, "lastDate must be bigger than firstDate");
        return lastDate.sub(firstDate).div(60).div(60).div(24);
    }

    function lendingInterestRatePercentage() public view returns(uint256){

        return annualInterest.mul(interestBaseUint)
            .mul(getDaysPassedBetweenDates(fundingEndTime, now)).div(365)
            .add(localNodeFee.mul(interestBaseUint))
            .add(ethichubFee.mul(interestBaseUint))
            .add(interestBasePercent);
    }

    function investorInterest() public view returns(uint256){

        return annualInterest.mul(interestBaseUint).mul(borrowerReturnDays).div(365).add(interestBasePercent);
    }

    function borrowerReturnFiatAmount() public view returns(uint256) {

        return totalLendingFiatAmount.mul(lendingInterestRatePercentage()).div(interestBasePercent);
    }

    function borrowerReturnAmount() public view returns(uint256) {

        return borrowerReturnFiatAmount().div(borrowerReturnStableCoinPerFiatRate);
    }

    function isContribPeriodRunning() public view returns(bool) {

        return fundingStartTime <= now && fundingEndTime > now && !capReached;
    }

    function checkInvestorContribution(address investor) public view returns(uint256){

        return investors[investor].amount;
    }

    function checkInvestorReturns(address investor) public view returns(uint256) {

        uint256 investorAmount = 0;
        if (state == LendingState.ContributionReturned) {
            investorAmount = investors[investor].amount;
            return investorAmount.mul(initialStableCoinPerFiatRate).mul(investorInterest()).div(borrowerReturnStableCoinPerFiatRate).div(interestBasePercent);
        } else if (state == LendingState.Default){
            investorAmount = investors[investor].amount;
            return investorAmount.mul(returnedAmount).div(totalLendingAmount);
        } else {
            return 0;
        }
    }

    function getMaxDelayDays() public view returns(uint256){

        return ethicHubStorage.getUint(keccak256(abi.encodePacked("lending.maxDelayDays", this)));
    }

    function getUserContributionReclaimStatus(address userAddress) public view returns(bool isCompensated){

        return investors[userAddress].isCompensated;
    }

    function changeState(LendingState newState) internal {

        state = newState;
        emit StateChange(uint(newState));
    }
}