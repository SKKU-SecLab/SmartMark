
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

interface IAccessModule {

    enum Operation {
        Deposit,
        Withdraw,
        CreateDebtProposal,
        AddPledge,
        WithdrawPledge,
        CancelDebtProposal,
        ExecuteDebtProposal,
        Repay,
        ExecuteDebtDefault,
        WithdrawUnlockedPledge
    }
    
    function isOperationAllowed(Operation operation, address sender) external view returns(bool);

}

interface ICurveModule {

    function calculateEnter(uint256 liquidAssets, uint256 debtCommitments, uint256 lAmount) external view returns (uint256);


    function calculateExit(uint256 liquidAssets, uint256 lAmount) external view returns (uint256);


    function calculateExitWithFee(uint256 liquidAssets, uint256 lAmount) external view returns(uint256);


    function calculateExitInverseWithFee(uint256 liquidAssets, uint256 pAmount) external view returns (uint256 withdraw, uint256 withdrawU, uint256 withdrawP);


    function calculateExitFee(uint256 lAmount) external view returns(uint256);

}

interface IFundsModule {

    event Status(uint256 lBalance, uint256 lDebts, uint256 lProposals, uint256 pEnterPrice, uint256 pExitPrice);

    function depositLTokens(address from, uint256 amount) external;

    function withdrawLTokens(address to, uint256 amount) external;


    function withdrawLTokens(address to, uint256 amount, uint256 poolFee) external;


    function depositPTokens(address from, uint256 amount) external;


    function withdrawPTokens(address to, uint256 amount) external;


    function mintPTokens(address to, uint256 amount) external;


    function distributePTokens(uint256 amount) external;


    function burnPTokens(address from, uint256 amount) external;


    function lockPTokens(address[] calldata from, uint256[] calldata amount) external;


    function mintAndLockPTokens(uint256 amount) external;


    function unlockAndWithdrawPTokens(address to, uint256 amount) external;


    function burnLockedPTokens(uint256 amount) external;


    function calculatePoolEnter(uint256 lAmount) external view returns(uint256);


    function calculatePoolEnter(uint256 lAmount, uint256 liquidityCorrection) external view returns(uint256);

    
    function calculatePoolExit(uint256 lAmount) external view returns(uint256);


    function calculatePoolExitInverse(uint256 pAmount) external view returns(uint256, uint256, uint256);


    function calculatePoolExitWithFee(uint256 lAmount) external view returns(uint256);


    function calculatePoolExitWithFee(uint256 lAmount, uint256 liquidityCorrection) external view returns(uint256);


    function lBalance() external view returns(uint256);


    function pBalanceOf(address account) external view returns(uint256);


}

interface ILiquidityModule {


    event Deposit(address indexed sender, uint256 lAmount, uint256 pAmount);
    event Withdraw(address indexed sender, uint256 lAmountTotal, uint256 lAmountUser, uint256 pAmount);

    function deposit(uint256 lAmount, uint256 pAmountMin) external;


    function withdraw(uint256 pAmount, uint256 lAmountMin) external;


    function withdrawForRepay(address borrower, uint256 pAmount) external;

}

interface ILoanModule {

    event Repay(address indexed sender, uint256 debt, uint256 lDebtLeft, uint256 lFullPaymentAmount, uint256 lInterestPaid, uint256 pInterestPaid, uint256 newlastPayment);
    event UnlockedPledgeWithdraw(address indexed sender, address indexed borrower, uint256 proposal, uint256 debt, uint256 pAmount);
    event DebtDefaultExecuted(address indexed borrower, uint256 debt, uint256 pBurned);

    function createDebt(address borrower, uint256 proposal, uint256 lAmount) external returns(uint256);


    function repay(uint256 debt, uint256 lAmount) external;


    function repayPTK(uint256 debt, uint256 pAmount, uint256 lAmountMin) external;


    function repayAllInterest(address borrower) external;


    function executeDebtDefault(address borrower, uint256 debt) external;


    function withdrawUnlockedPledge(address borrower, uint256 debt) external;


    function isDebtDefaultTimeReached(address borrower, uint256 debt) external view returns(bool);


    function hasActiveDebts(address borrower) external view returns(bool);


    function totalLDebts() external view returns(uint256);


}

interface ILoanProposalsModule {

    event DebtProposalCreated(address indexed sender, uint256 proposal, uint256 lAmount, uint256 interest, bytes32 descriptionHash);
    event PledgeAdded(address indexed sender, address indexed borrower, uint256 proposal, uint256 lAmount, uint256 pAmount);
    event PledgeWithdrawn(address indexed sender, address indexed borrower, uint256 proposal, uint256 lAmount, uint256 pAmount);
    event DebtProposalCanceled(address indexed sender, uint256 proposal);
    event DebtProposalExecuted(address indexed sender, uint256 proposal, uint256 debt, uint256 lAmount);

    function createDebtProposal(uint256 debtLAmount, uint256 interest, uint256 pAmountMax, bytes32 descriptionHash) external returns(uint256);


    function addPledge(address borrower, uint256 proposal, uint256 pAmount, uint256 lAmountMin) external;


    function withdrawPledge(address borrower, uint256 proposal, uint256 pAmount) external;


    function executeDebtProposal(uint256 proposal) external returns(uint256);



    function totalLProposals() external view returns(uint256);


    function getProposalAndPledgeInfo(address borrower, uint256 proposal, address supporter) external view
    returns(uint256 lAmount, uint256 lCovered, uint256 pCollected, uint256 interest, uint256 lPledge, uint256 pPledge);


    function getProposalInterestRate(address borrower, uint256 proposal) external view returns(uint256);

}

interface ILoanLimitsModule {

    enum LoanLimitType {
        L_DEBT_AMOUNT_MIN,
        DEBT_INTEREST_MIN,
        PLEDGE_PERCENT_MIN,
        L_MIN_PLEDGE_MAX,    
        DEBT_LOAD_MAX,       
        MAX_OPEN_PROPOSALS_PER_USER,
        MIN_CANCEL_PROPOSAL_TIMEOUT
    }

    function set(LoanLimitType limit, uint256 value) external;

    function get(LoanLimitType limit) external view returns(uint256);


    function lDebtAmountMin() external view returns(uint256);

    function debtInterestMin() external view returns(uint256);

    function pledgePercentMin() external view returns(uint256);

    function lMinPledgeMax() external view returns(uint256);

    function debtLoadMax() external view returns(uint256);

    function maxOpenProposalsPerUser() external view returns(uint256);

    function minCancelProposalTimeout() external view returns(uint256);

}

interface IPToken {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;


    function distribute(uint256 amount) external;

    function claimDistributions(address account) external returns(uint256);

    function claimDistributions(address account, uint256 lastDistribution) external returns(uint256);

    function claimDistributions(address[] calldata accounts) external;

    function claimDistributions(address[] calldata accounts, uint256 toDistribution) external;

    function fullBalanceOf(address account) external view returns(uint256);

    function calculateDistributedAmount(uint256 startDistribution, uint256 nextDistribution, uint256 initialBalance) external view returns(uint256);

    function nextDistribution() external view returns(uint256);


}

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

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

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

contract Base is Initializable, Context, Ownable {

    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {

        Ownable.initialize(_msgSender());
    }

}

contract ModuleNames {

    string public constant MODULE_ACCESS            = "access";
    string public constant MODULE_PTOKEN            = "ptoken";
    string public constant MODULE_CURVE             = "curve";
    string public constant MODULE_FUNDS             = "funds";
    string public constant MODULE_LIQUIDITY         = "liquidity";
    string public constant MODULE_LOAN              = "loan";
    string public constant MODULE_LOAN_LIMTS        = "loan_limits";
    string public constant MODULE_LOAN_PROPOSALS    = "loan_proposals";

    string public constant MODULE_LTOKEN            = "ltoken";
}

contract Module is Base, ModuleNames {

    event PoolAddressChanged(address newPool);
    address public pool;

    function initialize(address _pool) public initializer {

        Base.initialize();
        setPool(_pool);
    }

    function setPool(address _pool) public onlyOwner {

        require(_pool != ZERO_ADDRESS, "Module: pool address can't be zero");
        pool = _pool;
        emit PoolAddressChanged(_pool);        
    }

    function getModuleAddress(string memory module) public view returns(address){

        require(pool != ZERO_ADDRESS, "Module: no pool");
        (bool success, bytes memory result) = pool.staticcall(abi.encodeWithSignature("get(string)", module));
        
        if (!success) assembly {
            revert(add(result, 32), result)
        }

        address moduleAddress = abi.decode(result, (address));
        require(moduleAddress != ZERO_ADDRESS, "Module: requested module not found");
        return moduleAddress;
    }

}

contract LoanProposalsModule is Module, ILoanProposalsModule {

    using SafeMath for uint256;

    uint256 public constant COLLATERAL_TO_DEBT_RATIO_MULTIPLIER = 10**3;
    uint256 public constant COLLATERAL_TO_DEBT_RATIO = COLLATERAL_TO_DEBT_RATIO_MULTIPLIER * 3 / 2; // Regulates how many collateral is required 
    uint256 public constant PLEDGE_PERCENT_MULTIPLIER = 10**3;

    uint256 public constant BORROWER_COLLATERAL_TO_FULL_COLLATERAL_MULTIPLIER = 10**3;
    uint256 public constant BORROWER_COLLATERAL_TO_FULL_COLLATERAL_RATIO = BORROWER_COLLATERAL_TO_FULL_COLLATERAL_MULTIPLIER/3;

    struct DebtPledge {
        uint256 senderIndex;  //Index of pledge sender in the array
        uint256 lAmount;      //Amount of liquid tokens, covered by this pledge
        uint256 pAmount;      //Amount of pTokens locked for this pledge
    }

    struct DebtProposal {
        uint256 lAmount;             //Amount of proposed credit (in liquid token)
        uint256 interest;            //Annual interest rate multiplied by INTEREST_MULTIPLIER
        bytes32 descriptionHash;     //Hash of description, description itself is stored on Swarm   
        mapping(address => DebtPledge) pledges;    //Map of all user pledges (this value will not change after proposal )
        address[] supporters;       //Array of all supporters, first supporter (with zero index) is borrower himself
        uint256 lCovered;           //Amount of liquid tokens, covered by pledges
        uint256 pCollected;         //How many pTokens were locked for this proposal
        uint256 created;            //Timestamp when proposal was created 
        bool executed;              //If Debt is created for this proposal
    }

    mapping(address=>DebtProposal[]) public debtProposals;

    uint256 private lProposals;

    mapping(address=>uint256) public openProposals;         // Counts how many open proposals the address has 

    modifier operationAllowed(IAccessModule.Operation operation) {

        IAccessModule am = IAccessModule(getModuleAddress(MODULE_ACCESS));
        require(am.isOperationAllowed(operation, _msgSender()), "LoanProposalsModule: operation not allowed");
        _;
    }

    function initialize(address _pool) public initializer {

        Module.initialize(_pool);
    }

    function createDebtProposal(uint256 debtLAmount, uint256 interest, uint256 pAmountMax, bytes32 descriptionHash) 
    public operationAllowed(IAccessModule.Operation.CreateDebtProposal) returns(uint256) {

        require(debtLAmount >= limits().lDebtAmountMin(), "LoanProposalsModule: debtLAmount should be >= lDebtAmountMin");
        require(interest >= limits().debtInterestMin(), "LoanProposalsModule: interest should be >= debtInterestMin");
        require(openProposals[_msgSender()] < limits().maxOpenProposalsPerUser(), "LoanProposalsModule: borrower has too many open proposals");
        uint256 fullCollateralLAmount = debtLAmount.mul(COLLATERAL_TO_DEBT_RATIO).div(COLLATERAL_TO_DEBT_RATIO_MULTIPLIER);
        uint256 clAmount = fullCollateralLAmount.mul(BORROWER_COLLATERAL_TO_FULL_COLLATERAL_RATIO).div(BORROWER_COLLATERAL_TO_FULL_COLLATERAL_MULTIPLIER);
        uint256 cpAmount = calculatePoolExit(clAmount);
        require(cpAmount <= pAmountMax, "LoanProposalsModule: pAmountMax is too low");

        debtProposals[_msgSender()].push(DebtProposal({
            lAmount: debtLAmount,
            interest: interest,
            descriptionHash: descriptionHash,
            supporters: new address[](0),
            lCovered: 0,
            pCollected: 0,
            created: now,
            executed: false
        }));
        uint256 proposalIndex = debtProposals[_msgSender()].length-1;
        increaseOpenProposals(_msgSender());
        emit DebtProposalCreated(_msgSender(), proposalIndex, debtLAmount, interest, descriptionHash);

        DebtProposal storage prop = debtProposals[_msgSender()][proposalIndex];
        prop.supporters.push(_msgSender());
        prop.pledges[_msgSender()] = DebtPledge({
            senderIndex: 0,
            lAmount: clAmount,
            pAmount: cpAmount
        });
        prop.lCovered = prop.lCovered.add(clAmount);
        prop.pCollected = prop.pCollected.add(cpAmount);
        lProposals = lProposals.add(clAmount); //This is ok only while COLLATERAL_TO_DEBT_RATIO == 1

        fundsModule().depositPTokens(_msgSender(), cpAmount);
        emit PledgeAdded(_msgSender(), _msgSender(), proposalIndex, clAmount, cpAmount);
        return proposalIndex;
    }

    function addPledge(address borrower, uint256 proposal, uint256 pAmount, uint256 lAmountMin) public operationAllowed(IAccessModule.Operation.AddPledge) {

        require(_msgSender() != borrower, "LoanProposalsModule: Borrower can not add pledge");
        DebtProposal storage p = debtProposals[borrower][proposal];
        require(p.lAmount > 0, "LoanProposalsModule: DebtProposal not found");
        require(!p.executed, "LoanProposalsModule: DebtProposal is already executed");
        (uint256 lAmount, , ) = calculatePoolExitInverse(pAmount); 
        require(lAmount >= lAmountMin, "LoanProposalsModule: Minimal amount is too high");
        (uint256 minLPledgeAmount, uint256 maxLPledgeAmount)= getPledgeRequirements(borrower, proposal);
        require(maxLPledgeAmount > 0, "LoanProposalsModule: DebtProposal is already funded");
        require(lAmount >= minLPledgeAmount, "LoanProposalsModule: pledge is too low");
        if (lAmount > maxLPledgeAmount) {
            uint256 pAmountOld = pAmount;
            lAmount = maxLPledgeAmount;
            pAmount = calculatePoolExit(lAmount);
            assert(pAmount <= pAmountOld); // "<=" is used to handle tiny difference between lAmount and maxLPledgeAmount
        } 
        if (p.pledges[_msgSender()].senderIndex == 0) {
            p.supporters.push(_msgSender());
            p.pledges[_msgSender()] = DebtPledge({
                senderIndex: p.supporters.length-1,
                lAmount: lAmount,
                pAmount: pAmount
            });
        } else {
            p.pledges[_msgSender()].lAmount = p.pledges[_msgSender()].lAmount.add(lAmount);
            p.pledges[_msgSender()].pAmount = p.pledges[_msgSender()].pAmount.add(pAmount);
        }
        p.lCovered = p.lCovered.add(lAmount);
        p.pCollected = p.pCollected.add(pAmount);
        lProposals = lProposals.add(lAmount); //This is ok only while COLLATERAL_TO_DEBT_RATIO == 1
        fundsModule().depositPTokens(_msgSender(), pAmount);
        emit PledgeAdded(_msgSender(), borrower, proposal, lAmount, pAmount);
    }

    function withdrawPledge(address borrower, uint256 proposal, uint256 pAmount) public operationAllowed(IAccessModule.Operation.WithdrawPledge) {

        require(_msgSender() != borrower, "LoanProposalsModule: Borrower can not withdraw pledge");
        DebtProposal storage p = debtProposals[borrower][proposal];
        require(p.lAmount > 0, "LoanProposalsModule: DebtProposal not found");
        require(!p.executed, "LoanProposalsModule: DebtProposal is already executed");
        DebtPledge storage pledge = p.pledges[_msgSender()];
        require(pAmount <= pledge.pAmount, "LoanProposalsModule: Can not withdraw more than locked");
        uint256 lAmount; 
        if (pAmount == pledge.pAmount) {
            lAmount = pledge.lAmount;
        } else {
            lAmount = pledge.lAmount.mul(pAmount).div(pledge.pAmount);
            assert(lAmount < pledge.lAmount);
        }
        pledge.pAmount = pledge.pAmount.sub(pAmount);
        pledge.lAmount = pledge.lAmount.sub(lAmount);
        p.pCollected = p.pCollected.sub(pAmount);
        p.lCovered = p.lCovered.sub(lAmount);
        lProposals = lProposals.sub(lAmount); //This is ok only while COLLATERAL_TO_DEBT_RATIO == 1

        (uint256 minLPledgeAmount,)= getPledgeRequirements(borrower, proposal); 
        require(pledge.lAmount >= minLPledgeAmount || pledge.pAmount == 0, "LoanProposalsModule: pledge left is too small");

        fundsModule().withdrawPTokens(_msgSender(), pAmount);
        emit PledgeWithdrawn(_msgSender(), borrower, proposal, lAmount, pAmount);
    }

    function cancelDebtProposal(uint256 proposal) public operationAllowed(IAccessModule.Operation.CancelDebtProposal) {

        DebtProposal storage p = debtProposals[_msgSender()][proposal];
        require(p.lAmount > 0, "LoanProposalsModule: DebtProposal not found");
        require(now.sub(p.created) > limits().minCancelProposalTimeout(), "LoanProposalsModule: proposal can not be canceled now");
        require(!p.executed, "LoanProposalsModule: DebtProposal is already executed");
        for (uint256 i=0; i < p.supporters.length; i++){
            address supporter = p.supporters[i];                //first supporter is borrower himself
            DebtPledge storage pledge = p.pledges[supporter];
            lProposals = lProposals.sub(pledge.lAmount);
            fundsModule().withdrawPTokens(supporter, pledge.pAmount);
            emit PledgeWithdrawn(supporter, _msgSender(), proposal, pledge.lAmount, pledge.pAmount);
            delete p.pledges[supporter];
        }
        delete p.supporters;
        p.lAmount = 0;      //Mark proposal as deleted
        p.interest = 0;
        p.descriptionHash = 0;
        p.pCollected = 0;   
        p.lCovered = 0;
        decreaseOpenProposals(_msgSender());
        emit DebtProposalCanceled(_msgSender(), proposal);
    }

    function executeDebtProposal(uint256 proposal) public operationAllowed(IAccessModule.Operation.ExecuteDebtProposal) returns(uint256) {

        address borrower = _msgSender();
        DebtProposal storage p = debtProposals[borrower][proposal];
        require(p.lAmount > 0, "LoanProposalsModule: DebtProposal not found");
        require(getRequiredPledge(borrower, proposal) == 0, "LoanProposalsModule: DebtProposal is not fully funded");
        require(!p.executed, "LoanProposalsModule: DebtProposal is already executed");

        p.executed = true;

        lProposals = lProposals.sub(p.lCovered);

        uint256[] memory amounts = new uint256[](p.supporters.length);
        for (uint256 i=0; i < p.supporters.length; i++) {
            address supporter = p.supporters[i];
            amounts[i] = p.pledges[supporter].pAmount;
        }

        fundsModule().lockPTokens(p.supporters, amounts);

        uint256 debtIdx = loanModule().createDebt(borrower, proposal, p.lAmount);
        decreaseOpenProposals(borrower);
        emit DebtProposalExecuted(borrower, proposal, debtIdx, p.lAmount);
        return debtIdx;
    }

    function getProposalAndPledgeInfo(address borrower, uint256 proposal, address supporter) public view returns(
        uint256 lAmount, 
        uint256 lCovered, 
        uint256 pCollected, 
        uint256 interest,
        uint256 lPledge,
        uint256 pPledge
        ){

        DebtProposal storage p = debtProposals[borrower][proposal];
        require(p.lAmount > 0, "LoanProposalModule: DebtProposal not found");
        lAmount = p.lAmount;
        lCovered = p.lCovered;
        pCollected = p.pCollected;
        interest = p.interest;
        lPledge = p.pledges[supporter].lAmount;
        pPledge = p.pledges[supporter].pAmount;
    }

    function getProposalInterestRate(address borrower, uint256 proposal) public view returns(uint256){

        DebtProposal storage p = debtProposals[borrower][proposal];
        require(p.lAmount > 0, "LoanProposalModule: DebtProposal not found");
        return p.interest;
    }

    function getRequiredPledge(address borrower, uint256 proposal) public view returns(uint256){

        DebtProposal storage p = debtProposals[borrower][proposal];
        if (p.executed) return 0;
        uint256 fullCollateralLAmount = p.lAmount.mul(COLLATERAL_TO_DEBT_RATIO).div(COLLATERAL_TO_DEBT_RATIO_MULTIPLIER);
        return  fullCollateralLAmount.sub(p.lCovered);
    }

    function getPledgeRequirements(address borrower, uint256 proposal) public view returns(uint256 minLPledge, uint256 maxLPledge){


        DebtProposal storage p = debtProposals[borrower][proposal];
        if (p.executed) return (0, 0);
        uint256 fullCollateralLAmount = p.lAmount.mul(COLLATERAL_TO_DEBT_RATIO).div(COLLATERAL_TO_DEBT_RATIO_MULTIPLIER);
        maxLPledge = fullCollateralLAmount.sub(p.lCovered);

        minLPledge = limits().pledgePercentMin().mul(fullCollateralLAmount).div(PLEDGE_PERCENT_MULTIPLIER);
        uint256 lMinPledgeMax = limits().lMinPledgeMax();
        if (minLPledge > lMinPledgeMax) minLPledge = lMinPledgeMax;
        if (minLPledge > maxLPledge) minLPledge = maxLPledge;
    }

    function totalLProposals() public view returns(uint256){

        return lProposals;
    }

    function calculatePoolEnter(uint256 lAmount) internal view returns(uint256) {

        return fundsModule().calculatePoolEnter(lAmount);
    }

    function calculatePoolEnter(uint256 lAmount, uint256 liquidityCorrection) internal view returns(uint256) {

        return fundsModule().calculatePoolEnter(lAmount, liquidityCorrection);
    }

    function calculatePoolExit(uint256 lAmount) internal view returns(uint256) {

        return fundsModule().calculatePoolExit(lAmount);
    }
    
    function calculatePoolExitWithFee(uint256 lAmount) internal view returns(uint256) {

        return fundsModule().calculatePoolExitWithFee(lAmount);
    }

    function calculatePoolExitWithFee(uint256 lAmount, uint256 liquidityCorrection) internal view returns(uint256) {

        return fundsModule().calculatePoolExitWithFee(lAmount, liquidityCorrection);
    }

    function calculatePoolExitInverse(uint256 pAmount) internal view returns(uint256, uint256, uint256) {

        return fundsModule().calculatePoolExitInverse(pAmount);
    }

    function calculateExitFee(uint256 lAmount) internal view returns(uint256){

        return ICurveModule(getModuleAddress(MODULE_CURVE)).calculateExitFee(lAmount);
    }

    function fundsModule() internal view returns(IFundsModule) {

        return IFundsModule(getModuleAddress(MODULE_FUNDS));
    }

    function liquidityModule() internal view returns(ILiquidityModule) {

        return ILiquidityModule(getModuleAddress(MODULE_LIQUIDITY));
    }

    function pToken() internal view returns(IPToken){

        return IPToken(getModuleAddress(MODULE_PTOKEN));
    }

    function loanModule() internal view returns(ILoanModule) {

        return ILoanModule(getModuleAddress(MODULE_LOAN));
    }
    
    function limits() internal view returns(ILoanLimitsModule) {

        return ILoanLimitsModule(getModuleAddress(MODULE_LOAN_LIMTS));
    }

    function increaseOpenProposals(address borrower) private {

        openProposals[borrower] = openProposals[borrower].add(1);
    }

    function decreaseOpenProposals(address borrower) private {

        openProposals[borrower] = openProposals[borrower].sub(1);
    }

}