
pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


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

library NumbersList {

    using SafeMath for uint256;

    uint256 private constant PERCENTAGE_TO_DECIMAL = 10000;

    struct Values {
        uint256 count; // The total number of numbers added
        uint256 max; // The maximum number that was added
        uint256 min; // The minimum number that was added
        uint256 sum; // The total sum of the numbers that were added
    }

    function addValue(Values storage self, uint256 newValue) internal {

        if (self.max < newValue) {
            self.max = newValue;
        }
        if (self.min > newValue || self.count == 0) {
            self.min = newValue;
        }
        self.sum = self.sum.add(newValue);
        self.count = self.count.add(1);
    }

    function valuesCount(Values storage self) internal view returns (uint256) {

        return self.count;
    }

    function isEmpty(Values storage self) internal view returns (bool) {

        return valuesCount(self) == 0;
    }

    function isFinalized(Values storage self, uint256 totalRequiredValues)
        internal
        view
        returns (bool)
    {

        return valuesCount(self) >= totalRequiredValues;
    }

    function getAverage(Values storage self) internal view returns (uint256) {

        return isEmpty(self) ? 0 : self.sum.div(valuesCount(self));
    }

    function isWithinTolerance(Values storage self, uint256 tolerancePercentage)
        internal
        view
        returns (bool)
    {

        if (isEmpty(self)) {
            return false;
        }
        uint256 average = getAverage(self);
        uint256 toleranceAmount = average.mul(tolerancePercentage).div(
            PERCENTAGE_TO_DECIMAL
        );

        uint256 minTolerance = average.sub(toleranceAmount);
        if (self.min < minTolerance) {
            return false;
        }

        uint256 maxTolerance = average.add(toleranceAmount);
        if (self.max > maxTolerance) {
            return false;
        }
        return true;
    }
}

library TellerCommon {

    enum LoanStatus {NonExistent, TermsSet, Active, Closed}

    struct AccruedInterest {
        uint256 totalAccruedInterest;
        uint256 totalNotWithdrawn;
        uint256 timeLastAccrued;
    }

    struct Signature {
        uint256 signerNonce;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct InterestRequest {
        address lender;
        address consensusAddress;
        uint256 requestNonce;
        uint256 startTime;
        uint256 endTime;
        uint256 requestTime;
    }

    struct InterestResponse {
        address signer;
        address consensusAddress;
        uint256 responseTime;
        uint256 interest;
        Signature signature;
    }

    struct LoanRequest {
        address payable borrower;
        address recipient;
        address consensusAddress;
        uint256 requestNonce;
        uint256 amount;
        uint256 duration;
        uint256 requestTime;
    }

    struct LoanResponse {
        address signer;
        address consensusAddress;
        uint256 responseTime;
        uint256 interestRate;
        uint256 collateralRatio;
        uint256 maxLoanAmount;
        Signature signature;
    }

    struct AccruedLoanTerms {
        NumbersList.Values interestRate;
        NumbersList.Values collateralRatio;
        NumbersList.Values maxLoanAmount;
    }

    struct LoanTerms {
        address payable borrower;
        address recipient;
        uint256 interestRate;
        uint256 collateralRatio;
        uint256 maxLoanAmount;
        uint256 duration;
    }

    struct Loan {
        uint256 id;
        LoanTerms loanTerms;
        uint256 termsExpiry;
        uint256 loanStartTime;
        uint256 collateral;
        uint256 lastCollateralIn;
        uint256 principalOwed;
        uint256 interestOwed;
        uint256 borrowedAmount;
        LoanStatus status;
        bool liquidated;
    }
}

contract SettingsConsts {


    bytes32 public constant REQUIRED_SUBMISSIONS_SETTING = "RequiredSubmissions";
    bytes32 public constant MAXIMUM_TOLERANCE_SETTING = "MaximumTolerance";
    bytes32 public constant RESPONSE_EXPIRY_LENGTH_SETTING = "ResponseExpiryLength";
    bytes32 public constant SAFETY_INTERVAL_SETTING = "SafetyInterval";
    bytes32 public constant TERMS_EXPIRY_TIME_SETTING = "TermsExpiryTime";
    bytes32 public constant LIQUIDATE_ETH_PRICE_SETTING = "LiquidateEthPrice";
    bytes32 public constant MAXIMUM_LOAN_DURATION_SETTING = "MaximumLoanDuration";
    bytes32 public constant REQUEST_LOAN_TERMS_RATE_LIMIT_SETTING = "RequestLoanTermsRateLimit";
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

contract ERC20 is IERC20 {

    function name() public view returns (string memory);


    function symbol() public view returns (string memory);


    function decimals() public view returns (uint8);

}

library ERC20Lib {

    using SafeMath for uint256;

    uint256 internal constant TEN = 10;

    function getAWholeToken(ERC20 self) internal view returns (uint256) {

        uint8 decimals = self.decimals();
        return TEN**decimals;
    }

    function tokenTransfer(ERC20 self, address recipient, uint256 amount) internal {

        uint256 initialBalance = self.balanceOf(address(this));
        require(initialBalance >= amount, "NOT_ENOUGH_TOKENS_BALANCE");

        bool transferResult = self.transfer(recipient, amount);
        require(transferResult, "TOKENS_TRANSFER_FAILED");

        uint256 finalBalance = self.balanceOf(address(this));

        require(initialBalance.sub(finalBalance) == amount, "INV_BALANCE_AFTER_TRANSFER");
    }

    function tokenTransferFrom(ERC20 self, address from, uint256 amount) internal {

        uint256 currentAllowance = self.allowance(from, address(this));
        require(currentAllowance >= amount, "NOT_ENOUGH_TOKENS_ALLOWANCE");

        uint256 initialBalance = self.balanceOf(address(this));
        bool transferFromResult = self.transferFrom(from, address(this), amount);
        require(transferFromResult, "TOKENS_TRANSFER_FROM_FAILED");

        uint256 finalBalance = self.balanceOf(address(this));
        require(
            finalBalance.sub(initialBalance) == amount,
            "INV_BALANCE_AFTER_TRANSFER_FROM"
        );
    }
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

contract ReentrancyGuard is Initializable {

    uint256 private _guardCounter;

    function initialize() public initializer {

        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library AddressLib {

    address public constant ADDRESS_EMPTY = address(0x0);

    function isEmpty(address self) internal pure returns (bool) {

        return self == ADDRESS_EMPTY;
    }

    function isEqualTo(address self, address other) internal pure returns (bool) {

        return self == other;
    }

    function isNotEqualTo(address self, address other) internal pure returns (bool) {

        return self != other;
    }

    function isNotEmpty(address self) internal pure returns (bool) {

        return self != ADDRESS_EMPTY;
    }

    function requireNotEmpty(address self, string memory message) internal pure {

        require(isNotEmpty(self), message);
    }

    function requireEmpty(address self, string memory message) internal pure {

        require(isEmpty(self), message);
    }

    function requireEqualTo(address self, address other, string memory message)
        internal
        pure
    {

        require(isEqualTo(self, other), message);
    }

    function requireNotEqualTo(address self, address other, string memory message)
        internal
        pure
    {

        require(isNotEqualTo(self, other), message);
    }
}

contract TInitializable {


    bool private _isInitialized;


    modifier isNotInitialized() {

        require(!_isInitialized, "CONTRACT_ALREADY_INITIALIZED");
        _;
    }

    modifier isInitialized() {

        require(_isInitialized, "CONTRACT_NOT_INITIALIZED");
        _;
    }



    function initialized() external view returns (bool) {

        return _isInitialized;
    }


    function _initialize() internal {

        _isInitialized = true;
    }

}

library AssetSettingsLib {

    using SafeMath for uint256;
    using AddressLib for address;
    using Address for address;

    struct AssetSettings {
        address cTokenAddress;
        uint256 maxLoanAmount;
    }

    function initialize(
        AssetSettings storage self,
        address cTokenAddress,
        uint256 maxLoanAmount
    ) internal {

        require(maxLoanAmount > 0, "INIT_MAX_AMOUNT_REQUIRED");
        require(
            cTokenAddress.isEmpty() || cTokenAddress.isContract(),
            "CTOKEN_MUST_BE_CONTRACT_OR_EMPTY"
        );
        self.cTokenAddress = cTokenAddress;
        self.maxLoanAmount = maxLoanAmount;
    }

    function requireNotExists(AssetSettings storage self) internal view {

        require(exists(self) == false, "ASSET_SETTINGS_ALREADY_EXISTS");
    }

    function requireExists(AssetSettings storage self) internal view {

        require(exists(self) == true, "ASSET_SETTINGS_NOT_EXISTS");
    }

    function exists(AssetSettings storage self) internal view returns (bool) {

        return self.maxLoanAmount > 0;
    }

    function exceedsMaxLoanAmount(AssetSettings storage self, uint256 amount)
        internal
        view
        returns (bool)
    {

        return amount > self.maxLoanAmount;
    }

    function updateCTokenAddress(AssetSettings storage self, address newCTokenAddress)
        internal
    {

        requireExists(self);
        require(self.cTokenAddress != newCTokenAddress, "NEW_CTOKEN_ADDRESS_REQUIRED");
        self.cTokenAddress = newCTokenAddress;
    }

    function updateMaxLoanAmount(AssetSettings storage self, uint256 newMaxLoanAmount)
        internal
    {

        requireExists(self);
        require(self.maxLoanAmount != newMaxLoanAmount, "NEW_MAX_LOAN_AMOUNT_REQUIRED");
        require(newMaxLoanAmount > 0, "MAX_LOAN_AMOUNT_NOT_ZERO");
        self.maxLoanAmount = newMaxLoanAmount;
    }
}

library PlatformSettingsLib {

    struct PlatformSetting {
        uint256 value;
        uint256 min;
        uint256 max;
        bool exists;
    }

    function initialize(
        PlatformSetting storage self,
        uint256 value,
        uint256 min,
        uint256 max
    ) internal {

        requireNotExists(self);
        require(value >= min, "VALUE_MUST_BE_GT_MIN_VALUE");
        require(value <= max, "VALUE_MUST_BE_LT_MAX_VALUE");
        self.value = value;
        self.min = min;
        self.max = max;
        self.exists = true;
    }

    function requireNotExists(PlatformSetting storage self) internal view {

        require(self.exists == false, "PLATFORM_SETTING_ALREADY_EXISTS");
    }

    function requireExists(PlatformSetting storage self) internal view {

        require(self.exists == true, "PLATFORM_SETTING_NOT_EXISTS");
    }

    function update(PlatformSetting storage self, uint256 newValue)
        internal
        returns (uint256 oldValue)
    {

        requireExists(self);
        require(self.value != newValue, "NEW_VALUE_REQUIRED");
        require(newValue >= self.min, "NEW_VALUE_MUST_BE_GT_MIN_VALUE");
        require(newValue <= self.max, "NEW_VALUE_MUST_BE_LT_MAX_VALUE");
        oldValue = self.value;
        self.value = newValue;
    }

    function remove(PlatformSetting storage self) internal {

        requireExists(self);
        self.value = 0;
        self.min = 0;
        self.max = 0;
        self.exists = false;
    }
}

interface SettingsInterface {

    event PlatformSettingCreated(
        bytes32 indexed settingName,
        address indexed sender,
        uint256 value,
        uint256 minValue,
        uint256 maxValue
    );

    event PlatformSettingRemoved(
        bytes32 indexed settingName,
        uint256 lastValue,
        address indexed sender
    );

    event PlatformSettingUpdated(
        bytes32 indexed settingName,
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );

    event LendingPoolPaused(address indexed account, address indexed lendingPoolAddress);

    event LendingPoolUnpaused(
        address indexed account,
        address indexed lendingPoolAddress
    );

    event AssetSettingsCreated(
        address indexed sender,
        address indexed assetAddress,
        address cTokenAddress,
        uint256 maxLoanAmount
    );

    event AssetSettingsRemoved(address indexed sender, address indexed assetAddress);

    event AssetSettingsAddressUpdated(
        bytes32 indexed assetSettingName,
        address indexed sender,
        address indexed assetAddress,
        address oldValue,
        address newValue
    );

    event AssetSettingsUintUpdated(
        bytes32 indexed assetSettingName,
        address indexed sender,
        address indexed assetAddress,
        uint256 oldValue,
        uint256 newValue
    );

    function createPlatformSetting(
        bytes32 settingName,
        uint256 value,
        uint256 minValue,
        uint256 maxValue
    ) external;


    function updatePlatformSetting(bytes32 settingName, uint256 newValue) external;


    function removePlatformSetting(bytes32 settingName) external;


    function getPlatformSetting(bytes32 settingName)
        external
        view
        returns (PlatformSettingsLib.PlatformSetting memory);


    function getPlatformSettingValue(bytes32 settingName) external view returns (uint256);


    function hasPlatformSetting(bytes32 settingName) external view returns (bool);


    function isPaused() external view returns (bool);


    function lendingPoolPaused(address lendingPoolAddress) external view returns (bool);


    function pauseLendingPool(address lendingPoolAddress) external;


    function unpauseLendingPool(address lendingPoolAddress) external;


    function createAssetSettings(
        address assetAddress,
        address cTokenAddress,
        uint256 maxLoanAmount
    ) external;


    function removeAssetSettings(address assetAddress) external;


    function updateMaxLoanAmount(address assetAddress, uint256 newMaxLoanAmount) external;


    function updateCTokenAddress(address assetAddress, address newCTokenAddress) external;


    function getAssets() external view returns (address[] memory);


    function getAssetSettings(address assetAddress)
        external
        view
        returns (AssetSettingsLib.AssetSettings memory);


    function exceedsMaxLoanAmount(address assetAddress, uint256 amount)
        external
        view
        returns (bool);


    function hasPauserRole(address account) external view returns (bool);

}

library MarketStateLib {

    using SafeMath for uint256;

    uint256 private constant TO_PERCENTAGE = 10000;

    struct MarketState {
        uint256 totalSupplied;
        uint256 totalRepaid;
        uint256 totalBorrowed;
    }

    function increaseRepayment(MarketState storage self, uint256 amount) internal {

        self.totalRepaid = self.totalRepaid.add(amount);
    }

    function increaseSupply(MarketState storage self, uint256 amount) internal {

        self.totalSupplied = self.totalSupplied.add(amount);
    }

    function decreaseSupply(MarketState storage self, uint256 amount) internal {

        self.totalSupplied = self.totalSupplied.sub(amount);
    }

    function increaseBorrow(MarketState storage self, uint256 amount) internal {

        self.totalBorrowed = self.totalBorrowed.add(amount);
    }

    function getSupplyToDebt(MarketState storage self) internal view returns (uint256) {

        if (self.totalSupplied == 0) {
            return 0;
        }
        return
            self.totalBorrowed.sub(self.totalRepaid).mul(TO_PERCENTAGE).div(
                self.totalSupplied
            );
    }

    function getSupplyToDebtFor(MarketState storage self, uint256 loanAmount)
        internal
        view
        returns (uint256)
    {

        if (self.totalSupplied == 0) {
            return 0;
        }
        return
            self
                .totalBorrowed
                .sub(self.totalRepaid)
                .add(loanAmount)
                .mul(TO_PERCENTAGE)
                .div(self.totalSupplied);
    }
}

interface MarketsStateInterface {

    function increaseRepayment(
        address borrowedAsset,
        address collateralAsset,
        uint256 amount
    ) external;


    function increaseSupply(
        address borrowedAsset,
        address collateralAsset,
        uint256 amount
    ) external;


    function decreaseSupply(
        address borrowedAsset,
        address collateralAsset,
        uint256 amount
    ) external;


    function increaseBorrow(
        address borrowedAsset,
        address collateralAsset,
        uint256 amount
    ) external;


    function getSupplyToDebt(address borrowedAsset, address collateralAsset)
        external
        view
        returns (uint256);


    function getSupplyToDebtFor(
        address borrowedAsset,
        address collateralAsset,
        uint256 loanAmount
    ) external view returns (uint256);


    function getMarket(address borrowedAsset, address collateralAsset)
        external
        view
        returns (MarketStateLib.MarketState memory);

}

contract Base is TInitializable, ReentrancyGuard {

    using AddressLib for address;
    using Address for address;


    SettingsInterface public settings;
    MarketsStateInterface public markets;


    modifier whenNotPaused() {

        require(!_isPaused(), "PLATFORM_IS_PAUSED");
        _;
    }

    modifier whenLendingPoolNotPaused(address lendingPoolAddress) {

        require(!_isPoolPaused(lendingPoolAddress), "LENDING_POOL_IS_PAUSED");
        _;
    }

    modifier whenPaused() {

        require(_isPaused(), "PLATFORM_IS_NOT_PAUSED");
        _;
    }

    modifier whenLendingPoolPaused(address lendingPoolAddress) {

        require(_isPoolPaused(lendingPoolAddress), "LENDING_POOL_IS_NOT_PAUSED");
        _;
    }

    modifier whenAllowed(address anAddress) {

        require(settings.hasPauserRole(anAddress), "ADDRESS_ISNT_ALLOWED");
        _;
    }




    function _initialize(address settingsAddress, address marketsAddress)
        internal
        isNotInitialized()
    {

        settingsAddress.requireNotEmpty("SETTINGS_MUST_BE_PROVIDED");
        require(settingsAddress.isContract(), "SETTINGS_MUST_BE_A_CONTRACT");
        marketsAddress.requireNotEmpty("MARKETS_MUST_BE_PROVIDED");
        require(marketsAddress.isContract(), "MARKETS_MUST_BE_A_CONTRACT");

        _initialize();

        settings = SettingsInterface(settingsAddress);
        markets = MarketsStateInterface(marketsAddress);
    }

    function _isPoolPaused(address poolAddress) internal view returns (bool) {

        return settings.lendingPoolPaused(poolAddress);
    }

    function _isPaused() internal view returns (bool) {

        return settings.isPaused();
    }

}

interface PairAggregatorInterface {

    function getLatestAnswer() external view returns (int256);


    function getLatestTimestamp() external view returns (uint256);


    function getPreviousAnswer(uint256 roundsBack) external view returns (int256);


    function getPreviousTimestamp(uint256 roundsBack) external view returns (uint256);


    function getLatestRound() external view returns (uint256);

}

interface LendingPoolInterface {

    function deposit(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function repay(uint256 amount, address borrower) external;


    function liquidationPayment(uint256 amount, address liquidator) external;


    function createLoan(uint256 amount, address borrower) external;


    function withdrawInterest(uint256 amount) external;


    function lendingToken() external view returns (address);


    function interestValidator() external view returns (address);


    function setInterestValidator(address newInterestValidator) external;


    event TokenDeposited(address indexed sender, uint256 amount);

    event TokenWithdrawn(address indexed sender, uint256 amount);

    event TokenRepaid(address indexed borrower, uint256 amount);

    event InterestWithdrawn(address indexed lender, uint256 amount);

    event PaymentLiquidated(address indexed liquidator, uint256 amount);

    event InterestValidatorUpdated(
        address indexed sender,
        address indexed oldInterestValidator,
        address indexed newInterestValidator
    );
}

interface LoanTermsConsensusInterface {

    event TermsSubmitted(
        address indexed signer,
        address indexed borrower,
        uint256 indexed requestNonce,
        uint256 interestRate,
        uint256 collateralRatio,
        uint256 maxLoanAmount
    );

    event TermsAccepted(
        address indexed borrower,
        uint256 indexed requestNonce,
        uint256 interestRate,
        uint256 collateralRatio,
        uint256 maxLoanAmount
    );

    function processRequest(
        TellerCommon.LoanRequest calldata request,
        TellerCommon.LoanResponse[] calldata responses
    ) external returns (uint256, uint256, uint256);

}

interface LoansInterface {

    event CollateralDeposited(
        uint256 indexed loanID,
        address indexed borrower,
        uint256 depositAmount
    );

    event CollateralWithdrawn(
        uint256 indexed loanID,
        address indexed borrower,
        uint256 withdrawalAmount
    );

    event LoanTermsSet(
        uint256 indexed loanID,
        address indexed borrower,
        address indexed recipient,
        uint256 interestRate,
        uint256 collateralRatio,
        uint256 maxLoanAmount,
        uint256 duration,
        uint256 termsExpiry
    );

    event LoanTakenOut(
        uint256 indexed loanID,
        address indexed borrower,
        uint256 amountBorrowed
    );

    event LoanRepaid(
        uint256 indexed loanID,
        address indexed borrower,
        uint256 amountPaid,
        address payer,
        uint256 totalOwed
    );

    event LoanLiquidated(
        uint256 indexed loanID,
        address indexed borrower,
        address liquidator,
        uint256 collateralOut,
        uint256 tokensIn
    );

    event PriceOracleUpdated(
        address indexed sender,
        address indexed oldPriceOracle,
        address indexed newPriceOracle
    );

    function getBorrowerLoans(address borrower) external view returns (uint256[] memory);


    function loans(uint256 loanID) external view returns (TellerCommon.Loan memory);


    function depositCollateral(address borrower, uint256 loanID, uint256 amount)
        external
        payable;


    function withdrawCollateral(uint256 amount, uint256 loanID) external;


    function createLoanWithTerms(
        TellerCommon.LoanRequest calldata request,
        TellerCommon.LoanResponse[] calldata responses,
        uint256 collateralAmount
    ) external payable;


    function takeOutLoan(uint256 loanID, uint256 amountBorrow) external;


    function repay(uint256 amount, uint256 loanID) external;


    function liquidateLoan(uint256 loanID) external;


    function priceOracle() external view returns (address);


    function lendingPool() external view returns (address);


    function lendingToken() external view returns (address);


    function totalCollateral() external view returns (uint256);


    function loanIDCounter() external view returns (uint256);


    function collateralToken() external view returns (address);


    function getCollateralInfo(uint256 loanID)
        external
        view
        returns (
            uint256 collateral,
            uint256 collateralNeededLendingTokens,
            uint256 collateralNeededCollateralTokens,
            bool requireCollateral
        );


    function setPriceOracle(address newPriceOracle) external;

}

interface IATMSettings {


    event ATMPaused(address indexed atm, address indexed account);

    event ATMUnpaused(address indexed account, address indexed atm);

    event MarketToAtmSet(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed atm,
        address account
    );

    event MarketToAtmUpdated(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed oldAtm,
        address newAtm,
        address account
    );

    event MarketToAtmRemoved(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed oldAtm,
        address account
    );





    function pauseATM(address atmAddress) external;


    function unpauseATM(address atmAddress) external;


    function isATMPaused(address atmAddress) external view returns (bool);


    function setATMToMarket(
        address borrowedToken,
        address collateralToken,
        address atmAddress
    ) external;


    function updateATMToMarket(
        address borrowedToken,
        address collateralToken,
        address newAtmAddress
    ) external;


    function removeATMToMarket(address borrowedToken, address collateralToken) external;


    function getATMForMarket(address borrowedToken, address collateralToken)
        external
        view
        returns (address);


    function isATMForMarket(
        address borrowedToken,
        address collateralToken,
        address atmAddress
    ) external view returns (bool);

}

interface IATMGovernance {


    event GeneralSettingAdded(
        address indexed sender,
        bytes32 indexed settingName,
        uint256 settingValue
    );

    event GeneralSettingUpdated(
        address indexed sender,
        bytes32 indexed settingName,
        uint256 oldValue,
        uint256 newValue
    );

    event GeneralSettingRemoved(
        address indexed sender,
        bytes32 indexed settingName,
        uint256 settingValue
    );

    event AssetMarketSettingAdded(
        address indexed sender,
        address indexed asset,
        bytes32 indexed settingName,
        uint256 settingValue
    );

    event AssetMarketSettingUpdated(
        address indexed sender,
        address indexed asset,
        bytes32 indexed settingName,
        uint256 oldValue,
        uint256 newValue
    );

    event AssetMarketSettingRemoved(
        address indexed sender,
        address indexed asset,
        bytes32 indexed settingName,
        uint256 oldValue
    );

    event DataProviderAdded(
        address indexed sender,
        uint8 indexed dataTypeIndex,
        uint256 amountDataProviders,
        address dataProvider
    );

    event DataProviderUpdated(
        address indexed sender,
        uint8 indexed dataTypeIndex,
        uint256 indexed dataProviderIndex,
        address oldDataProvider,
        address newDataProvider
    );

    event DataProviderRemoved(
        address indexed sender,
        uint8 indexed dataTypeIndex,
        uint256 indexed dataProviderIndex,
        address dataProvider
    );

    event CRASet(address indexed sender, string craCommitHash);


    function addGeneralSetting(bytes32 settingName, uint256 settingValue) external;


    function updateGeneralSetting(bytes32 settingName, uint256 newValue) external;


    function removeGeneralSetting(bytes32 settingName) external;


    function addAssetMarketSetting(
        address asset,
        bytes32 settingName,
        uint256 settingValue
    ) external;


    function updateAssetMarketSetting(
        address asset,
        bytes32 settingName,
        uint256 newValue
    ) external;


    function removeAssetMarketSetting(address asset, bytes32 settingName) external;


    function addDataProvider(uint8 dataTypeIndex, address dataProvider) external;


    function updateDataProvider(
        uint8 dataTypeIndex,
        uint256 providerIndex,
        address newProvider
    ) external;


    function removeDataProvider(uint8 dataTypeIndex, uint256 dataProvider) external;


    function setCRA(string calldata cra) external;



    function getGeneralSetting(bytes32 settingName) external view returns (uint256);


    function getAssetMarketSetting(address asset, bytes32 settingName)
        external
        view
        returns (uint256);


    function getDataProvider(uint8 dataTypeIndex, uint256 dataProviderIndex)
        external
        view
        returns (address);


    function getCRA() external view returns (string memory);

}

contract LoansBase is LoansInterface, Base, SettingsConsts {

    using SafeMath for uint256;
    using ERC20Lib for ERC20;


    uint256 internal constant DAYS_PER_YEAR_4DP = 3650000;

    uint256 internal constant TEN_THOUSAND = 10000;

    bytes32 internal constant SUPPLY_TO_DEBT_ATM_SETTING = "SupplyToDebt";

    uint256 public totalCollateral;

    address public collateralToken;

    uint256 public loanIDCounter;

    address public priceOracle;

    LendingPoolInterface public lendingPool;

    LoanTermsConsensusInterface public loanTermsConsensus;

    IATMSettings public atmSettings;

    mapping(address => uint256[]) public borrowerLoans;

    mapping(uint256 => TellerCommon.Loan) public loans;


    modifier isBorrower(address borrower) {

        require(msg.sender == borrower, "BORROWER_MUST_BE_SENDER");
        _;
    }

    modifier loanActive(uint256 loanID) {

        require(
            loans[loanID].status == TellerCommon.LoanStatus.Active,
            "LOAN_NOT_ACTIVE"
        );
        _;
    }

    modifier loanTermsSet(uint256 loanID) {

        require(loans[loanID].status == TellerCommon.LoanStatus.TermsSet, "LOAN_NOT_SET");
        _;
    }

    modifier loanActiveOrSet(uint256 loanID) {

        require(
            loans[loanID].status == TellerCommon.LoanStatus.TermsSet ||
                loans[loanID].status == TellerCommon.LoanStatus.Active,
            "LOAN_NOT_ACTIVE_OR_SET"
        );
        _;
    }

    modifier withValidLoanRequest(TellerCommon.LoanRequest memory loanRequest) {

        require(
            settings.getPlatformSettingValue(MAXIMUM_LOAN_DURATION_SETTING) >=
                loanRequest.duration,
            "DURATION_EXCEEDS_MAX_DURATION"
        );
        require(
            !settings.exceedsMaxLoanAmount(
                lendingPool.lendingToken(),
                loanRequest.amount
            ),
            "AMOUNT_EXCEEDS_MAX_AMOUNT"
        );
        require(
            _isSupplyToDebtRatioValid(loanRequest.amount),
            "SUPPLY_TO_DEBT_EXCEEDS_MAX"
        );
        _;
    }

    function getBorrowerLoans(address borrower) external view returns (uint256[] memory) {

        return borrowerLoans[borrower];
    }

    function lendingToken() external view returns (address) {

        return lendingPool.lendingToken();
    }

    function withdrawCollateral(uint256 amount, uint256 loanID)
        external
        loanActiveOrSet(loanID)
        isInitialized()
        whenNotPaused()
        whenLendingPoolNotPaused(address(lendingPool))
        nonReentrant()
    {

        require(msg.sender == loans[loanID].loanTerms.borrower, "CALLER_DOESNT_OWN_LOAN");
        require(amount > 0, "CANNOT_WITHDRAW_ZERO");

        uint256 collateralNeededToken = _getCollateralNeededInTokens(
            _getTotalOwed(loanID),
            loans[loanID].loanTerms.collateralRatio
        );
        uint256 collateralNeededWei = _convertTokenToWei(collateralNeededToken);

        uint256 withdrawalAmount = loans[loanID].collateral.sub(collateralNeededWei);
        if (withdrawalAmount > amount) {
            withdrawalAmount = amount;
        }

        if (withdrawalAmount > 0) {
            _payOutCollateral(loanID, withdrawalAmount, msg.sender);
        }

        emit CollateralWithdrawn(loanID, msg.sender, withdrawalAmount);
    }

    function takeOutLoan(uint256 loanID, uint256 amountBorrow)
        external
        loanTermsSet(loanID)
        isInitialized()
        whenNotPaused()
        whenLendingPoolNotPaused(address(lendingPool))
        nonReentrant()
        isBorrower(loans[loanID].loanTerms.borrower)
    {

        require(
            loans[loanID].loanTerms.maxLoanAmount >= amountBorrow,
            "MAX_LOAN_EXCEEDED"
        );

        require(loans[loanID].termsExpiry >= now, "LOAN_TERMS_EXPIRED");

        require(
            loans[loanID].lastCollateralIn <=
                now.sub(settings.getPlatformSettingValue(SAFETY_INTERVAL_SETTING)),
            "COLLATERAL_DEPOSITED_RECENTLY"
        );

        loans[loanID].borrowedAmount = amountBorrow;
        loans[loanID].principalOwed = amountBorrow;
        loans[loanID].interestOwed = amountBorrow
            .mul(loans[loanID].loanTerms.interestRate)
            .mul(loans[loanID].loanTerms.duration)
            .div(TEN_THOUSAND)
            .div(DAYS_PER_YEAR_4DP);

        (, , , bool moreCollateralRequired) = _getCollateralInfo(loanID);

        require(!moreCollateralRequired, "MORE_COLLATERAL_REQUIRED");

        loans[loanID].loanStartTime = now;

        loans[loanID].status = TellerCommon.LoanStatus.Active;

        if (loans[loanID].loanTerms.recipient != address(0)) {
            lendingPool.createLoan(amountBorrow, loans[loanID].loanTerms.recipient);
        } else {
            lendingPool.createLoan(amountBorrow, loans[loanID].loanTerms.borrower);
        }

        markets.increaseBorrow(
            lendingPool.lendingToken(),
            this.collateralToken(),
            amountBorrow
        );

        emit LoanTakenOut(loanID, loans[loanID].loanTerms.borrower, amountBorrow);
    }

    function repay(uint256 amount, uint256 loanID)
        external
        loanActive(loanID)
        isInitialized()
        whenNotPaused()
        whenLendingPoolNotPaused(address(lendingPool))
        nonReentrant()
    {

        require(amount > 0, "AMOUNT_VALUE_REQUIRED");
        uint256 toPay = amount;
        uint256 totalOwed = _getTotalOwed(loanID);
        if (totalOwed < toPay) {
            toPay = totalOwed;
        }

        totalOwed = totalOwed.sub(toPay);
        _payLoan(loanID, toPay);

        if (totalOwed == 0) {
            loans[loanID].status = TellerCommon.LoanStatus.Closed;

            uint256 collateralAmount = loans[loanID].collateral;
            _payOutCollateral(loanID, collateralAmount, loans[loanID].loanTerms.borrower);

            emit CollateralWithdrawn(
                loanID,
                loans[loanID].loanTerms.borrower,
                collateralAmount
            );
        }

        lendingPool.repay(toPay, msg.sender);

        markets.increaseRepayment(
            lendingPool.lendingToken(),
            this.collateralToken(),
            toPay
        );

        emit LoanRepaid(
            loanID,
            loans[loanID].loanTerms.borrower,
            toPay,
            msg.sender,
            totalOwed
        );
    }

    function liquidateLoan(uint256 loanID)
        external
        loanActive(loanID)
        isInitialized()
        whenNotPaused()
        whenLendingPoolNotPaused(address(lendingPool))
        nonReentrant()
    {

        (uint256 loanCollateral, , , bool moreCollateralRequired) = _getCollateralInfo(
            loanID
        );

        uint256 loanEndTime = loans[loanID].loanStartTime.add(
            loans[loanID].loanTerms.duration
        );

        require(moreCollateralRequired || loanEndTime < now, "DOESNT_NEED_LIQUIDATION");

        loans[loanID].status = TellerCommon.LoanStatus.Closed;
        loans[loanID].liquidated = true;

        uint256 collateralInTokens = _convertWeiToToken(loanCollateral);

        _payOutCollateral(loanID, loanCollateral, msg.sender);

        uint256 tokenPayment = collateralInTokens
            .mul(settings.getPlatformSettingValue(LIQUIDATE_ETH_PRICE_SETTING))
            .div(TEN_THOUSAND);
        lendingPool.liquidationPayment(tokenPayment, msg.sender);

        emit LoanLiquidated(
            loanID,
            loans[loanID].loanTerms.borrower,
            msg.sender,
            loanCollateral,
            tokenPayment
        );
    }

    function getCollateralInfo(uint256 loanID)
        external
        view
        returns (
            uint256 collateral,
            uint256 collateralNeededLendingTokens,
            uint256 collateralNeededCollateralTokens,
            bool moreCollateralRequired
        )
    {

        return _getCollateralInfo(loanID);
    }

    function setPriceOracle(address newPriceOracle)
        external
        isInitialized()
        whenAllowed(msg.sender)
    {

        require(newPriceOracle.isContract(), "ORACLE_MUST_CONTRACT_NOT_EMPTY");
        address oldPriceOracle = address(priceOracle);
        oldPriceOracle.requireNotEqualTo(newPriceOracle, "NEW_ORACLE_MUST_BE_PROVIDED");

        priceOracle = newPriceOracle;

        emit PriceOracleUpdated(msg.sender, oldPriceOracle, newPriceOracle);
    }

    function _payOutCollateral(uint256 loanID, uint256 amount, address payable recipient)
        internal;


    function _getCollateralInfo(uint256 loanID)
        internal
        view
        returns (
            uint256 collateral,
            uint256 collateralNeededLendingTokens,
            uint256 collateralNeededCollateralTokens,
            bool moreCollateralRequired
        )
    {

        collateral = loans[loanID].collateral;
        (
            collateralNeededLendingTokens,
            collateralNeededCollateralTokens
        ) = _getCollateralNeededInfo(
            _getTotalOwed(loanID),
            loans[loanID].loanTerms.collateralRatio
        );
        moreCollateralRequired = collateralNeededCollateralTokens > collateral;
    }

    function _getCollateralNeededInfo(uint256 totalOwed, uint256 collateralRatio)
        internal
        view
        returns (
            uint256 collateralNeededLendingTokens,
            uint256 collateralNeededCollateralTokens
        )
    {

        uint256 collateralNeededToken = _getCollateralNeededInTokens(
            totalOwed,
            collateralRatio
        );
        return (collateralNeededToken, _convertTokenToWei(collateralNeededToken));
    }

    function _initialize(
        address priceOracleAddress,
        address lendingPoolAddress,
        address loanTermsConsensusAddress,
        address settingsAddress,
        address marketsAddress,
        address atmSettingsAddress
    ) internal isNotInitialized() {

        priceOracleAddress.requireNotEmpty("PROVIDE_ORACLE_ADDRESS");
        lendingPoolAddress.requireNotEmpty("PROVIDE_LENDINGPOOL_ADDRESS");
        loanTermsConsensusAddress.requireNotEmpty("PROVIDED_LOAN_TERMS_ADDRESS");
        atmSettingsAddress.requireNotEmpty("PROVIDED_ATM_SETTINGS_ADDRESS");

        _initialize(settingsAddress, marketsAddress);

        priceOracle = priceOracleAddress;
        lendingPool = LendingPoolInterface(lendingPoolAddress);
        loanTermsConsensus = LoanTermsConsensusInterface(loanTermsConsensusAddress);
        atmSettings = IATMSettings(atmSettingsAddress);
    }

    function _payInCollateral(uint256 loanID, uint256 amount) internal {

        totalCollateral = totalCollateral.add(amount);
        loans[loanID].collateral = loans[loanID].collateral.add(amount);
        loans[loanID].lastCollateralIn = now;
    }

    function _payLoan(uint256 loanID, uint256 toPay) internal {

        if (toPay > loans[loanID].principalOwed) {
            uint256 leftToPay = toPay;
            leftToPay = leftToPay.sub(loans[loanID].principalOwed);
            loans[loanID].principalOwed = 0;
            loans[loanID].interestOwed = loans[loanID].interestOwed.sub(leftToPay);
        } else {
            loans[loanID].principalOwed = loans[loanID].principalOwed.sub(toPay);
        }
    }

    function _getTotalOwed(uint256 loanID) internal view returns (uint256) {

        return loans[loanID].interestOwed.add(loans[loanID].principalOwed);
    }

    function _getCollateralNeededInTokens(uint256 loanAmount, uint256 collateralRatio)
        internal
        pure
        returns (uint256)
    {

        return loanAmount.mul(collateralRatio).div(TEN_THOUSAND);
    }

    function _convertWeiToToken(uint256 weiAmount) internal view returns (uint256) {

        uint256 aWholeLendingToken = ERC20(lendingPool.lendingToken()).getAWholeToken();
        uint256 oneLendingTokenPriceWei = uint256(
            PairAggregatorInterface(priceOracle).getLatestAnswer()
        );
        uint256 tokenValue = weiAmount.mul(aWholeLendingToken).div(
            oneLendingTokenPriceWei
        );
        return tokenValue;
    }

    function _convertTokenToWei(uint256 tokenAmount) internal view returns (uint256) {

        uint256 aWholeLendingToken = ERC20(lendingPool.lendingToken()).getAWholeToken();
        uint256 oneLendingTokenPriceWei = uint256(
            PairAggregatorInterface(priceOracle).getLatestAnswer()
        );
        uint256 weiValue = tokenAmount.mul(oneLendingTokenPriceWei).div(
            aWholeLendingToken
        );
        return weiValue;
    }

    function getAndIncrementLoanID() internal returns (uint256 newLoanID) {

        newLoanID = loanIDCounter;
        loanIDCounter += 1;
    }

    function createLoan(
        uint256 loanID,
        TellerCommon.LoanRequest memory request,
        uint256 interestRate,
        uint256 collateralRatio,
        uint256 maxLoanAmount
    ) internal view returns (TellerCommon.Loan memory) {

        uint256 termsExpiry = now.add(
            settings.getPlatformSettingValue(TERMS_EXPIRY_TIME_SETTING)
        );
        return
            TellerCommon.Loan({
                id: loanID,
                loanTerms: TellerCommon.LoanTerms({
                    borrower: request.borrower,
                    recipient: request.recipient,
                    interestRate: interestRate,
                    collateralRatio: collateralRatio,
                    maxLoanAmount: maxLoanAmount,
                    duration: request.duration
                }),
                termsExpiry: termsExpiry,
                loanStartTime: 0,
                collateral: 0,
                lastCollateralIn: 0,
                principalOwed: 0,
                interestOwed: 0,
                borrowedAmount: 0,
                status: TellerCommon.LoanStatus.TermsSet,
                liquidated: false
            });
    }

    function _emitLoanTermsSetAndCollateralDepositedEventsIfApplicable(
        uint256 loanID,
        TellerCommon.LoanRequest memory request,
        uint256 interestRate,
        uint256 collateralRatio,
        uint256 maxLoanAmount,
        uint256 depositedAmount
    ) internal {

        emit LoanTermsSet(
            loanID,
            request.borrower,
            request.recipient,
            interestRate,
            collateralRatio,
            maxLoanAmount,
            request.duration,
            loans[loanID].termsExpiry
        );
        if (depositedAmount > 0) {
            emit CollateralDeposited(loanID, request.borrower, depositedAmount);
        }
    }

    function _isSupplyToDebtRatioValid(uint256 newLoanAmount)
        internal
        view
        returns (bool)
    {

        address atmAddressForMarket = atmSettings.getATMForMarket(
            lendingPool.lendingToken(),
            collateralToken
        );
        require(atmAddressForMarket != address(0x0), "ATM_NOT_FOUND_FOR_MARKET");
        uint256 supplyToDebtMarketLimit = IATMGovernance(atmAddressForMarket)
            .getGeneralSetting(SUPPLY_TO_DEBT_ATM_SETTING);
        uint256 currentSupplyToDebtMarket = markets.getSupplyToDebtFor(
            lendingPool.lendingToken(),
            collateralToken,
            newLoanAmount
        );
        return currentSupplyToDebtMarket <= supplyToDebtMarketLimit;
    }
}

contract TokenCollateralLoans is LoansBase {




    modifier noMsgValue() {

        require(msg.value == 0, "TOKEN_LOANS_VALUE_MUST_BE_ZERO");
        _;
    }


    function depositCollateral(address borrower, uint256 loanID, uint256 amount)
        external
        payable
        noMsgValue()
        loanActiveOrSet(loanID)
        isInitialized()
        whenNotPaused()
        whenLendingPoolNotPaused(address(lendingPool))
    {

        borrower.requireEqualTo(
            loans[loanID].loanTerms.borrower,
            "BORROWER_LOAN_ID_MISMATCH"
        );
        require(amount > 0, "CANNOT_DEPOSIT_ZERO");

        _payInCollateral(loanID, amount);

        emit CollateralDeposited(loanID, borrower, amount);
    }

    function createLoanWithTerms(
        TellerCommon.LoanRequest calldata request,
        TellerCommon.LoanResponse[] calldata responses,
        uint256 collateralAmount
    )
        external
        payable
        noMsgValue()
        isInitialized()
        whenNotPaused()
        isBorrower(request.borrower)
        withValidLoanRequest(request)
    {

        uint256 loanID = getAndIncrementLoanID();

        (
            uint256 interestRate,
            uint256 collateralRatio,
            uint256 maxLoanAmount
        ) = loanTermsConsensus.processRequest(request, responses);

        loans[loanID] = createLoan(
            loanID,
            request,
            interestRate,
            collateralRatio,
            maxLoanAmount
        );

        if (collateralAmount > 0) {
            _payInCollateral(loanID, collateralAmount);
        }

        borrowerLoans[request.borrower].push(loanID);

        _emitLoanTermsSetAndCollateralDepositedEventsIfApplicable(
            loanID,
            request,
            interestRate,
            collateralRatio,
            maxLoanAmount,
            collateralAmount
        );
    }

    function initialize(
        address priceOracleAddress,
        address lendingPoolAddress,
        address loanTermsConsensusAddress,
        address settingsAddress,
        address collateralTokenAddress,
        address marketsAddress,
        address atmSettingsAddress
    ) external isNotInitialized() {

        collateralTokenAddress.requireNotEmpty("PROVIDE_COLL_TOKEN_ADDRESS");

        _initialize(
            priceOracleAddress,
            lendingPoolAddress,
            loanTermsConsensusAddress,
            settingsAddress,
            marketsAddress,
            atmSettingsAddress
        );

        collateralToken = collateralTokenAddress;
    }

    function _payOutCollateral(uint256 loanID, uint256 amount, address payable recipient)
        internal
    {

        totalCollateral = totalCollateral.sub(amount);
        loans[loanID].collateral = loans[loanID].collateral.sub(amount);

        _collateralTokenTransfer(recipient, amount);
    }

    function _payInCollateral(uint256 loanID, uint256 amount) internal {

        super._payInCollateral(loanID, amount);
        _collateralTokenTransferFrom(msg.sender, amount);
    }

    function _collateralTokenTransfer(address recipient, uint256 amount) internal {

        ERC20(collateralToken).tokenTransfer(recipient, amount);
    }

    function _collateralTokenTransferFrom(address from, uint256 amount) internal {

        ERC20(collateralToken).tokenTransferFrom(from, amount);
    }
}