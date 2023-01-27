
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

contract LoanModule is Module, ILoanModule {

    using SafeMath for uint256;

    uint256 public constant INTEREST_MULTIPLIER = 10**3;    // Multiplier to store interest rate (decimal) in int
    uint256 public constant ANNUAL_SECONDS = 365*24*60*60+(24*60*60/4);  // Seconds in a year + 1/4 day to compensate leap years

    uint256 public constant DEBT_REPAY_DEADLINE_PERIOD = 90*24*60*60;   //Period before debt without payments may be defaulted

    uint256 public constant DEBT_LOAD_MULTIPLIER = 10**3;

    struct Debt {
        uint256 proposal;           // Index of DebtProposal in adress's proposal list
        uint256 lAmount;            // Current amount of debt (in liquid token). If 0 - debt is fully paid
        uint256 lastPayment;        // Timestamp of last interest payment (can be timestamp of last payment or a virtual date untill which interest is paid)
        uint256 pInterest;          // Amount of pTokens minted as interest for this debt
        mapping(address => uint256) claimedPledges;  //Amount of pTokens already claimed by supporter
        bool defaultExecuted;       // If debt default is already executed by executeDebtDefault()
    }

    mapping(address=>Debt[]) public debts;                 

    uint256 private lDebts;

    mapping(address=>uint256) public activeDebts;           // Counts how many active debts the address has 

    modifier operationAllowed(IAccessModule.Operation operation) {

        IAccessModule am = IAccessModule(getModuleAddress(MODULE_ACCESS));
        require(am.isOperationAllowed(operation, _msgSender()), "LoanModule: operation not allowed");
        _;
    }

    function initialize(address _pool) public initializer {

        Module.initialize(_pool);
    }

    function createDebt(address borrower, uint256 proposal, uint256 lAmount) public returns(uint256) {

        require(_msgSender() == getModuleAddress(MODULE_LOAN_PROPOSALS), "LoanModule: requests only accepted from LoanProposalsModule");
        debts[borrower].push(Debt({
            proposal: proposal,
            lAmount: lAmount,
            lastPayment: now,
            pInterest: 0,
            defaultExecuted: false
        }));
        uint256 debtIdx = debts[borrower].length-1; //It's important to save index before calling external contract

        uint256 maxDebts = limits().debtLoadMax().mul(fundsModule().lBalance().add(lDebts)).div(DEBT_LOAD_MULTIPLIER);

        lDebts = lDebts.add(lAmount);
        require(lDebts <= maxDebts, "LoanModule: Debt can not be created now because of debt loan limit");


        increaseActiveDebts(borrower);
        fundsModule().withdrawLTokens(borrower, lAmount);
        return debtIdx;
    }

    function repay(uint256 debt, uint256 lAmount) public operationAllowed(IAccessModule.Operation.Repay) {

        address borrower = _msgSender();
        Debt storage d = debts[borrower][debt];
        require(d.lAmount > 0, "LoanModule: Debt is already fully repaid"); //Or wrong debt index
        require(!_isDebtDefaultTimeReached(d), "LoanModule: debt is already defaulted");

        (, uint256 lCovered, , uint256 interest, uint256 pledgeLAmount, )
        = loanProposals().getProposalAndPledgeInfo(borrower, d.proposal, borrower);

        uint256 lInterest = calculateInterestPayment(d.lAmount, interest, d.lastPayment, now);

        uint256 actualInterest;
        if (lAmount < lInterest) {
            uint256 paidTime = now.sub(d.lastPayment).mul(lAmount).div(lInterest);
            assert(d.lastPayment + paidTime <= now);
            d.lastPayment = d.lastPayment.add(paidTime);
            actualInterest = lAmount;
        } else {
            uint256 fullRepayLAmount = d.lAmount.add(lInterest);
            if (lAmount > fullRepayLAmount) lAmount = fullRepayLAmount;

            d.lastPayment = now;
            uint256 debtReturned = lAmount.sub(lInterest);
            d.lAmount = d.lAmount.sub(debtReturned);
            lDebts = lDebts.sub(debtReturned);
            actualInterest = lInterest;
        }

        uint256 pInterest = calculatePoolEnter(actualInterest);
        d.pInterest = d.pInterest.add(pInterest);
        uint256 poolInterest = pInterest.mul(pledgeLAmount).div(lCovered);

        fundsModule().depositLTokens(borrower, lAmount); 
        fundsModule().distributePTokens(poolInterest);
        fundsModule().mintAndLockPTokens(pInterest.sub(poolInterest));

        emit Repay(_msgSender(), debt, d.lAmount, lAmount, actualInterest, pInterest, d.lastPayment);

        if (d.lAmount == 0) {
            decreaseActiveDebts(borrower);
            withdrawUnlockedPledge(borrower, debt);
        }
    }

    function repayPTK(uint256 debt, uint256 pAmount, uint256 lAmountMin) public operationAllowed(IAccessModule.Operation.Repay) {

        address borrower = _msgSender();
        Debt storage d = debts[borrower][debt];
        require(d.lAmount > 0, "LoanModule: Debt is already fully repaid"); //Or wrong debt index
        require(!_isDebtDefaultTimeReached(d), "LoanModule: debt is already defaulted");

        (, uint256 lAmount,) = fundsModule().calculatePoolExitInverse(pAmount);
        require(lAmount >= lAmountMin, "LoanModule: Minimal amount is too high");

        (uint256 actualPAmount, uint256 actualInterest, uint256 pInterest, uint256 poolInterest) 
            = repayPTK_calculateInterestAndUpdateDebt(borrower, d, lAmount);
        if (actualPAmount == 0) actualPAmount = pAmount; // Fix of stack too deep if send original pAmount to repayPTK_calculateInterestAndUpdateDebt

        liquidityModule().withdrawForRepay(borrower, actualPAmount);
        fundsModule().distributePTokens(poolInterest);
        fundsModule().mintAndLockPTokens(pInterest.sub(poolInterest));

        emit Repay(_msgSender(), debt, d.lAmount, lAmount, actualInterest, pInterest, d.lastPayment);

        if (d.lAmount == 0) {
            decreaseActiveDebts(borrower);
            withdrawUnlockedPledge(borrower, debt);
        }
    }

    function repayPTK_calculateInterestAndUpdateDebt(address borrower, Debt storage d, uint256 lAmount) private 
    returns(uint256 pAmount, uint256 actualInterest, uint256 pInterest, uint256 poolInterest){

        (, uint256 lCovered, , uint256 interest, uint256 lPledge, )
        = loanProposals().getProposalAndPledgeInfo(borrower, d.proposal, borrower);

        uint256 lInterest = calculateInterestPayment(d.lAmount, interest, d.lastPayment, now);
        if (lAmount < lInterest) {
            uint256 paidTime = now.sub(d.lastPayment).mul(lAmount).div(lInterest);
            assert(d.lastPayment + paidTime <= now);
            d.lastPayment = d.lastPayment.add(paidTime);
            actualInterest = lAmount;
        } else {
            uint256 fullRepayLAmount = d.lAmount.add(lInterest);
            if (lAmount > fullRepayLAmount) {
                lAmount = fullRepayLAmount;
                pAmount = calculatePoolExitWithFee(lAmount);
            }

            d.lastPayment = now;
            uint256 debtReturned = lAmount.sub(lInterest);
            d.lAmount = d.lAmount.sub(debtReturned);
            lDebts = lDebts.sub(debtReturned);
            actualInterest = lInterest;
        }

        pInterest = calculatePoolEnter(actualInterest, lAmount); 
        d.pInterest = d.pInterest.add(pInterest);
        poolInterest = pInterest.mul(lPledge).div(lCovered);
    }

    function repayAllInterest(address borrower) public {

        require(_msgSender() == getModuleAddress(MODULE_LIQUIDITY), "LoanModule: call only allowed from LiquidityModule");
        Debt[] storage userDebts = debts[borrower];
        if (userDebts.length == 0) return;
        uint256 totalLFee;
        uint256 totalPWithdraw;
        uint256 totalPInterestToDistribute;
        uint256 totalPInterestToMint;
        uint256 activeDebtCount = 0;
        for (int256 i=int256(userDebts.length)-1; i >= 0; i--){
            Debt storage d = userDebts[uint256(i)];
            if ((d.lAmount != 0) && !_isDebtDefaultTimeReached(d)){ //removed isUnpaid and isDefaulted variables to preent "Stack too deep" error
                (uint256 pWithdrawn, uint256 lFee, uint256 poolInterest, uint256 pInterestToMint) 
                    = repayInterestForDebt(borrower, uint256(i), d, totalLFee);
                totalPWithdraw = totalPWithdraw.add(pWithdrawn);
                totalLFee = totalLFee.add(lFee);
                totalPInterestToDistribute = totalPInterestToDistribute.add(poolInterest);
                totalPInterestToMint = totalPInterestToMint.add(pInterestToMint);

                activeDebtCount++;
                if (activeDebtCount >= activeDebts[borrower]) break;
            }
        }
        if (totalPWithdraw > 0) {
            liquidityModule().withdrawForRepay(borrower, totalPWithdraw);
            fundsModule().distributePTokens(totalPInterestToDistribute);
            fundsModule().mintAndLockPTokens(totalPInterestToMint);
        } else {
            assert(totalPInterestToDistribute == 0);
            assert(totalPInterestToMint == 0);
        }
    }

    function repayInterestForDebt(address borrower, uint256 debt, Debt storage d, uint256 totalLFee) private 
    returns(uint256 pWithdrawn, uint256 lFee, uint256 poolInterest, uint256 pInterestToMint) {

        (, uint256 lCovered, , uint256 interest, uint256 lPledge, )
        = loanProposals().getProposalAndPledgeInfo(borrower, d.proposal, borrower);
        uint256 lInterest = calculateInterestPayment(d.lAmount, interest, d.lastPayment, now);
        pWithdrawn = calculatePoolExitWithFee(lInterest, totalLFee);
        lFee = calculateExitFee(lInterest);

        d.lastPayment = now;
        uint256 pInterest = calculatePoolEnter(lInterest, lInterest.add(totalLFee)); 
        d.pInterest = d.pInterest.add(pInterest);
        poolInterest = pInterest.mul(lPledge).div(lCovered);
        pInterestToMint = pInterest.sub(poolInterest); //We substract interest that will be minted during distribution
        emitRepay(borrower, debt, d, lInterest, lInterest, pInterest);
    }

    function emitRepay(address borrower, uint256 debt, Debt storage d, uint256 lFullPaymentAmount, uint256 lInterestPaid, uint256 pInterestPaid) private {

        emit Repay(borrower, debt, d.lAmount, lFullPaymentAmount, lInterestPaid, pInterestPaid, d.lastPayment);
    }

    function executeDebtDefault(address borrower, uint256 debt) public operationAllowed(IAccessModule.Operation.ExecuteDebtDefault) {

        Debt storage dbt = debts[borrower][debt];
        require(dbt.lAmount > 0, "LoanModule: debt is fully repaid");
        require(!dbt.defaultExecuted, "LoanModule: default is already executed");
        require(_isDebtDefaultTimeReached(dbt), "LoanModule: not enough time passed");

        (uint256 proposalLAmount, , uint256 pCollected, , , uint256 pPledge)
        = loanProposals().getProposalAndPledgeInfo(borrower, dbt.proposal, borrower);

        withdrawDebtDefaultPayment(borrower, debt);

        uint256 pLockedBorrower = pPledge.mul(dbt.lAmount).div(proposalLAmount);
        uint256 pUnlockedBorrower = pPledge.sub(pLockedBorrower);
        uint256 pSupportersPledge = pCollected.sub(pPledge);
        uint256 pLockedSupportersPledge = pSupportersPledge.mul(dbt.lAmount).div(proposalLAmount);
        uint256 pLocked = pLockedBorrower.add(pLockedSupportersPledge);
        dbt.defaultExecuted = true;
        lDebts = lDebts.sub(dbt.lAmount);
        uint256 pExtra;
        if (pUnlockedBorrower > pLockedSupportersPledge){
            pExtra = pUnlockedBorrower - pLockedSupportersPledge;
            fundsModule().distributePTokens(pExtra);
        }
        fundsModule().burnLockedPTokens(pLocked.add(pExtra));
        decreaseActiveDebts(borrower);
        emit DebtDefaultExecuted(borrower, debt, pLocked);
    }

    function withdrawUnlockedPledge(address borrower, uint256 debt) public operationAllowed(IAccessModule.Operation.WithdrawUnlockedPledge) {

        (, uint256 pUnlocked, uint256 pInterest, uint256 pWithdrawn) = calculatePledgeInfo(borrower, debt, _msgSender());

        uint256 pUnlockedPlusInterest = pUnlocked.add(pInterest);
        require(pUnlockedPlusInterest > pWithdrawn, "LoanModule: nothing to withdraw");
        uint256 pAmount = pUnlockedPlusInterest.sub(pWithdrawn);

        Debt storage dbt = debts[borrower][debt];
        dbt.claimedPledges[_msgSender()] = dbt.claimedPledges[_msgSender()].add(pAmount);
        
        fundsModule().unlockAndWithdrawPTokens(_msgSender(), pAmount);
        emit UnlockedPledgeWithdraw(_msgSender(), borrower, dbt.proposal, debt, pAmount);
    }

    function isDebtDefaultTimeReached(address borrower, uint256 debt) public view returns(bool) {

        Debt storage dbt = debts[borrower][debt];
        return _isDebtDefaultTimeReached(dbt);
    }

    function calculatePledgeInfo(address borrower, uint256 debt, address supporter) public view
    returns(uint256 pLocked, uint256 pUnlocked, uint256 pInterest, uint256 pWithdrawn){

        Debt storage dbt = debts[borrower][debt];

        (uint256 proposalLAmount, uint256 lCovered, , , uint256 lPledge, uint256 pPledge)
        = loanProposals().getProposalAndPledgeInfo(borrower, dbt.proposal, supporter);

        pWithdrawn = dbt.claimedPledges[supporter];


        if (supporter == borrower) {
            if (dbt.lAmount == 0) {
                pLocked = 0;
                pUnlocked = pPledge;
            } else {
                pLocked = pPledge;
                pUnlocked = 0;
                if (dbt.defaultExecuted || _isDebtDefaultTimeReached(dbt)) {
                    pLocked = 0; 
                }
            }
            pInterest = 0;
        }else{
            pLocked = pPledge.mul(dbt.lAmount).div(proposalLAmount);
            assert(pLocked <= pPledge);
            pUnlocked = pPledge.sub(pLocked);
            pInterest = dbt.pInterest.mul(lPledge).div(lCovered);
            assert(pInterest <= dbt.pInterest);
            if (dbt.defaultExecuted || _isDebtDefaultTimeReached(dbt)) {
                (pLocked, pUnlocked) = calculatePledgeInfoForDefault(borrower, dbt, proposalLAmount, lCovered, lPledge, pLocked, pUnlocked);
            }
        }
    }

    function calculatePledgeInfoForDefault(
        address borrower, Debt storage dbt, uint256 proposalLAmount, uint256 lCovered, uint256 lPledge, 
        uint256 pLocked, uint256 pUnlocked) private view
    returns(uint256, uint256){

        (, , , , uint256 bpledgeLAmount, uint256 bpledgePAmount) = loanProposals().getProposalAndPledgeInfo(borrower, dbt.proposal, borrower);
        uint256 pLockedBorrower = bpledgePAmount.mul(dbt.lAmount).div(proposalLAmount);
        uint256 pUnlockedBorrower = bpledgePAmount.sub(pLockedBorrower);
        uint256 pCompensation = pUnlockedBorrower.mul(lPledge).div(lCovered.sub(bpledgeLAmount));
        if (pCompensation > pLocked) {
            pCompensation = pLocked;
        }
        if (dbt.defaultExecuted) {
            pLocked = 0;
            pUnlocked = pUnlocked.add(pCompensation);
        }else {
            pLocked = pCompensation;
        }
        return (pLocked, pUnlocked);
    }

    function getDebtRequiredPayments(address borrower, uint256 debt) public view returns(uint256, uint256) {

        Debt storage d = debts[borrower][debt];
        if (d.lAmount == 0) {
            return (0, 0);
        }
        uint256 interestRate = loanProposals().getProposalInterestRate(borrower, d.proposal);

        uint256 interest = calculateInterestPayment(d.lAmount, interestRate, d.lastPayment, now);
        return (d.lAmount, interest);
    }

    function hasActiveDebts(address borrower) public view returns(bool) {

        return activeDebts[borrower] > 0;
    }

    function getUnpaidInterest(address borrower) public view returns(uint256 totalLInterest, uint256 totalLInterestPerSecond){

        Debt[] storage userDebts = debts[borrower];
        if (userDebts.length == 0) return (0, 0);
        uint256 activeDebtCount;
        for (int256 i=int256(userDebts.length)-1; i >= 0; i--){
            Debt storage d = userDebts[uint256(i)];
            bool isUnpaid = (d.lAmount != 0);
            bool isDefaulted = _isDebtDefaultTimeReached(d);
            if (isUnpaid && !isDefaulted){
                uint256 interestRate = loanProposals().getProposalInterestRate(borrower, d.proposal);
                uint256 lInterest = calculateInterestPayment(d.lAmount, interestRate, d.lastPayment, now);
                uint256 lInterestPerSecond = lInterest.div(now.sub(d.lastPayment));
                totalLInterest = totalLInterest.add(lInterest);
                totalLInterestPerSecond = totalLInterestPerSecond.add(lInterestPerSecond);

                activeDebtCount++;
                if (activeDebtCount >= activeDebts[borrower]) break;
            }
        }
    }

    function totalLDebts() public view returns(uint256){

        return lDebts;
    }

    function calculateInterestPayment(uint256 debtLAmount, uint256 interest, uint256 prevPayment, uint currentPayment) public pure returns(uint256){

        require(prevPayment <= currentPayment, "LoanModule: prevPayment should be before currentPayment");
        uint256 annualInterest = debtLAmount.mul(interest).div(INTEREST_MULTIPLIER);
        uint256 time = currentPayment.sub(prevPayment);
        return time.mul(annualInterest).div(ANNUAL_SECONDS);
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

    function limits() internal view returns(ILoanLimitsModule) {

        return ILoanLimitsModule(getModuleAddress(MODULE_LOAN_LIMTS));
    }

    function loanProposals() internal view returns(ILoanProposalsModule) {

        return ILoanProposalsModule(getModuleAddress(MODULE_LOAN_PROPOSALS));
    }

    function increaseActiveDebts(address borrower) private {

        activeDebts[borrower] = activeDebts[borrower].add(1);
    }

    function decreaseActiveDebts(address borrower) private {

        activeDebts[borrower] = activeDebts[borrower].sub(1);
    }

    function withdrawDebtDefaultPayment(address borrower, uint256 debt) private {

        Debt storage d = debts[borrower][debt];

        uint256 lInterest = calculateInterestPayment(d.lAmount, loanProposals().getProposalInterestRate(borrower, d.proposal), d.lastPayment, now);

        uint256 lAmount = d.lAmount.add(lInterest);
        uint256 pAmount = calculatePoolExitWithFee(lAmount);
        uint256 pBalance = pToken().balanceOf(borrower);
        if (pBalance == 0) return;

        if (pAmount > pBalance) {
            pAmount = pBalance;
            (, lAmount,) = fundsModule().calculatePoolExitInverse(pAmount);
        }

        (uint256 pInterest, uint256 poolInterest) 
            = withdrawDebtDefaultPayment_calculatePInterest(borrower, d, lAmount, lInterest); 
        d.pInterest = d.pInterest.add(pInterest);
        
        if (lAmount < lInterest) {
            uint256 paidTime = now.sub(d.lastPayment).mul(lAmount).div(lInterest);
            assert(d.lastPayment + paidTime <= now);
            d.lastPayment = d.lastPayment.add(paidTime);
            lInterest = lAmount;
        } else {
            d.lastPayment = now;
            uint256 debtReturned = lAmount.sub(lInterest);
            d.lAmount = d.lAmount.sub(debtReturned);
            lDebts = lDebts.sub(debtReturned);
        }


        liquidityModule().withdrawForRepay(borrower, pAmount);
        fundsModule().distributePTokens(poolInterest);
        fundsModule().mintAndLockPTokens(pInterest.sub(poolInterest));

        emit Repay(borrower, debt, d.lAmount, lAmount, lInterest, pInterest, d.lastPayment);
    }

    function withdrawDebtDefaultPayment_calculatePInterest(address borrower, Debt storage d, uint256 lAmount, uint256 lInterest) private view 
    returns(uint256 pInterest, uint256 poolInterest) {

        pInterest = calculatePoolEnter(lInterest, lAmount); 

        (, uint256 lCovered, , , uint256 lPledge, )
        = loanProposals().getProposalAndPledgeInfo(borrower, d.proposal, borrower);
        poolInterest = pInterest.mul(lPledge).div(lCovered);
    }

    function _isDebtDefaultTimeReached(Debt storage dbt) private view returns(bool) {

        uint256 timeSinceLastPayment = now.sub(dbt.lastPayment);
        return timeSinceLastPayment > DEBT_REPAY_DEADLINE_PERIOD;
    }
}