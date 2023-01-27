pragma solidity ^0.5.0;

contract TimeSim {

  uint256 public Now;
  constructor() public {
    Now = now;
  }
  function Step() public {

    Now += 30 days;
  }
}
pragma solidity ^0.5.0;

contract SmartLoan {



  uint256 public OriginalBalance;
  uint256 public CurrentBalance;
  uint256 public IntPaidIn;
  uint256 public PrinPaidIn;
  uint256 public MonthlyInstallment;
  uint256 public InterestRateBasisPoints;
  uint256 public OriginalTermMonths;
  uint256 public RemainingTermMonths;
  uint256 public NextPaymentDate;
  uint256 public PaymentsMade;
  uint256 public OverdueDays;

  uint256 public Now;
  uint256[120] public PaymentDates;

  bool public ContractCurrent = true;

  address payable public LenderAddress;
  address public TimeAddress;

  TimeSim Time;

  modifier OnlyLender {

    require(msg.sender == LenderAddress, "Error lender address");
    _;
  }

  constructor(
    address payable lenderAddress,
    uint256 balance,
    uint256 interestRateBasisPoints,
    uint256 termMonths,
    address timeAddress
  ) public {
    LenderAddress = lenderAddress;
    TimeAddress = timeAddress;
    OriginalBalance = balance;
    CurrentBalance = balance;
    InterestRateBasisPoints = interestRateBasisPoints;
    OriginalTermMonths = termMonths;
    RemainingTermMonths = termMonths;
    Time = TimeSim(timeAddress);

    uint256 MonthlyInstallment1 = (
        interestRateBasisPoints * (10000 * termMonths + interestRateBasisPoints) ** termMonths
      ) /
      1000000;
    uint256 MonthlyInstallment2 = (
        (10000 * termMonths + interestRateBasisPoints) **
          termMonths *
          10000 *
          termMonths -
          10000 **
          (termMonths + 1) *
          termMonths **
          (termMonths + 1)
      ) /
      1000000;


    if (MonthlyInstallment2 != 0)
      MonthlyInstallment = balance * MonthlyInstallment1 / (MonthlyInstallment2 + 1);

    for (uint256 k = 0; k < termMonths; k++) {
      PaymentDates[k] = now + (k + 1) * 30 days;
    }

    NextPaymentDate = PaymentDates[0];
  }

  function Read() public view returns (uint256[11] memory) {

    return [
      OverdueDays,
      OriginalBalance,
      CurrentBalance,
      NextPaymentDate,
      IntPaidIn,
      PrinPaidIn,
      MonthlyInstallment,
      InterestRateBasisPoints,
      OriginalTermMonths,
      RemainingTermMonths,
      address(this).balance
    ];
  }

  function ReadTime() public view returns (address) {

    return TimeAddress;
  }

  function ContractCurrentUpdate() private returns (uint256) {

    PaymentsMade = OriginalTermMonths - RemainingTermMonths;
    NextPaymentDate = PaymentDates[PaymentsMade];

    if (Time.Now() > NextPaymentDate && RemainingTermMonths != 0) {
      ContractCurrent = false;
      OverdueDays = (Time.Now() - NextPaymentDate) / (60 * 60 * 24);
      return OverdueDays;
    }

    OverdueDays = 0;
    ContractCurrent = true;
    return OverdueDays;
  }

  function Transfer(address payable NewLender) public OnlyLender() {

    LenderAddress = NewLender;
  }

  function PayIn() public payable {

    uint256 Principal;
    uint256 Interest;

    require(msg.value == MonthlyInstallment, "Invalid MonthlyInstallment");
    require(RemainingTermMonths != 0, "RemainingTermMonths == 0");

    RemainingTermMonths--;
    Principal = CalculatePVOfInstallment(OriginalTermMonths - RemainingTermMonths);
    Interest = MonthlyInstallment - Principal;
    CurrentBalance -= Principal;
    IntPaidIn += Interest;
    PrinPaidIn += Principal;

    ContractCurrentUpdate();
  }

  function WithdrawIntPrin() public OnlyLender returns (uint256[10] memory) {

    uint256 intPaidIn = IntPaidIn;
    uint256 prinPaidIn = PrinPaidIn;

    OverdueDays = ContractCurrentUpdate();

    LenderAddress.transfer(IntPaidIn + PrinPaidIn);

    IntPaidIn = 0;
    PrinPaidIn = 0;

    return [
      OverdueDays,
      OriginalBalance,
      CurrentBalance,
      NextPaymentDate,
      intPaidIn,
      prinPaidIn,
      MonthlyInstallment,
      InterestRateBasisPoints,
      OriginalTermMonths,
      RemainingTermMonths
    ];
  }

  function CalculatePVOfInstallment(uint256 periods) public view returns (uint256) {

    uint256 PV = MonthlyInstallment *
      (10000 * OriginalTermMonths) **
      periods /
      (10000 * OriginalTermMonths + InterestRateBasisPoints) **
      periods;

    return PV;
  }

}
pragma solidity ^0.5.0;

contract Bank {

  uint256 public LoansNumber;
  address public BankDirector;
  address public TmpLoanAddress;
  address public TimeAddress;
  address public Securitization;
  mapping(address => address) public AccountsToLoans;
  address[] public Loans;
  TimeSim Time;
  SmartLoan TmpLoan;

  modifier OnlyDirector {

    require(msg.sender == BankDirector, "Invalid BankDirector");
    _;
  }

  function SetSecuritization(address sfc) public {

    Securitization = sfc;
  }

  constructor() public {
    Time = new TimeSim();
    TimeAddress = address(Time);
    BankDirector = msg.sender;
  }

  function GetLoanAddress() public view returns (address) {

    return AccountsToLoans[msg.sender];
  }
  function getLoans() public view returns (address[] memory) {

    return Loans;
  }
  function NewOwner(address payable LedgerAddress) public {

    for (uint256 i = 0; i < LoansNumber; i++) {
      SmartLoan(Loans[i]).Transfer(LedgerAddress);
    }
  }
  function Pay() public payable {

    for (uint256 i = 0; i < LoansNumber; i++) {
      SmartLoan(Loans[i]).PayIn(); //.value(1200000).gas(2500)();
    }
  }

  function NewLoan(
    address _Borrower,
    uint256 _Balance,
    uint256 _InterestRateBPS,
    uint256 _TermMonths
  ) public OnlyDirector returns (address) {

    TmpLoan = new SmartLoan(address(this), _Balance, _InterestRateBPS, _TermMonths, TimeAddress);
    TmpLoanAddress = address(TmpLoan);
    AccountsToLoans[_Borrower] = TmpLoanAddress;
    Loans.push(TmpLoanAddress);
    LoansNumber++;
    return TmpLoanAddress;
  }

  function() external payable {}

}
