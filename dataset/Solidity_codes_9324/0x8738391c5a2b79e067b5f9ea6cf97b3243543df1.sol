

pragma solidity 0.4.25;


interface IRateApprover {

    function approveHighRate(uint256 _highRateN, uint256 _highRateD) external view  returns (bool);


    function approveLowRate(uint256 _lowRateN, uint256 _lowRateD) external view  returns (bool);

}


interface IContractAddressLocator {

    function getContractAddress(bytes32 _identifier) external view returns (address);


    function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);

}


contract ContractAddressLocatorHolder {

    bytes32 internal constant _IAuthorizationDataSource_ = "IAuthorizationDataSource";
    bytes32 internal constant _ISGNConversionManager_    = "ISGNConversionManager"      ;
    bytes32 internal constant _IModelDataSource_         = "IModelDataSource"        ;
    bytes32 internal constant _IPaymentHandler_          = "IPaymentHandler"            ;
    bytes32 internal constant _IPaymentManager_          = "IPaymentManager"            ;
    bytes32 internal constant _IPaymentQueue_            = "IPaymentQueue"              ;
    bytes32 internal constant _IReconciliationAdjuster_  = "IReconciliationAdjuster"      ;
    bytes32 internal constant _IIntervalIterator_        = "IIntervalIterator"       ;
    bytes32 internal constant _IMintHandler_             = "IMintHandler"            ;
    bytes32 internal constant _IMintListener_            = "IMintListener"           ;
    bytes32 internal constant _IMintManager_             = "IMintManager"            ;
    bytes32 internal constant _IPriceBandCalculator_     = "IPriceBandCalculator"       ;
    bytes32 internal constant _IModelCalculator_         = "IModelCalculator"        ;
    bytes32 internal constant _IRedButton_               = "IRedButton"              ;
    bytes32 internal constant _IReserveManager_          = "IReserveManager"         ;
    bytes32 internal constant _ISagaExchanger_           = "ISagaExchanger"          ;
    bytes32 internal constant _IMonetaryModel_               = "IMonetaryModel"              ;
    bytes32 internal constant _IMonetaryModelState_          = "IMonetaryModelState"         ;
    bytes32 internal constant _ISGAAuthorizationManager_ = "ISGAAuthorizationManager";
    bytes32 internal constant _ISGAToken_                = "ISGAToken"               ;
    bytes32 internal constant _ISGATokenManager_         = "ISGATokenManager"        ;
    bytes32 internal constant _ISGNAuthorizationManager_ = "ISGNAuthorizationManager";
    bytes32 internal constant _ISGNToken_                = "ISGNToken"               ;
    bytes32 internal constant _ISGNTokenManager_         = "ISGNTokenManager"        ;
    bytes32 internal constant _IMintingPointTimersManager_             = "IMintingPointTimersManager"            ;
    bytes32 internal constant _ITradingClasses_          = "ITradingClasses"         ;
    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = "IWalletsTLValueConverter"       ;
    bytes32 internal constant _BuyWalletsTradingDataSource_       = "BuyWalletsTradingDataSource"      ;
    bytes32 internal constant _SellWalletsTradingDataSource_       = "SellWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _BuyWalletsTradingLimiter_SGATokenManager_          = "BuyWalletsTLSGATokenManager"         ;
    bytes32 internal constant _SellWalletsTradingLimiter_SGATokenManager_          = "SellWalletsTLSGATokenManager"         ;
    bytes32 internal constant _IETHConverter_             = "IETHConverter"   ;
    bytes32 internal constant _ITransactionLimiter_      = "ITransactionLimiter"     ;
    bytes32 internal constant _ITransactionManager_      = "ITransactionManager"     ;
    bytes32 internal constant _IRateApprover_      = "IRateApprover"     ;

    IContractAddressLocator private contractAddressLocator;

    constructor(IContractAddressLocator _contractAddressLocator) internal {
        require(_contractAddressLocator != address(0), "locator is illegal");
        contractAddressLocator = _contractAddressLocator;
    }

    function getContractAddressLocator() external view returns (IContractAddressLocator) {

        return contractAddressLocator;
    }

    function getContractAddress(bytes32 _identifier) internal view returns (address) {

        return contractAddressLocator.getContractAddress(_identifier);
    }



    function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {

        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);
    }

    modifier only(bytes32 _identifier) {

        require(msg.sender == getContractAddress(_identifier), "caller is illegal");
        _;
    }

}


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

    require(b > 0); // Solidity only automatically asserts when dividing by 0
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


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract Claimable is Ownable {

  address public pendingOwner;

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    pendingOwner = newOwner;
  }

  function claimOwnership() public onlyPendingOwner {

    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}


interface AggregatorInterface {

  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy);
}



contract OracleRateApprover is IRateApprover, ContractAddressLocatorHolder, Claimable {

    string public constant VERSION = "1.0.0";

    using SafeMath for uint256;

    uint256 public constant MILLION = 1000000;
    uint256 public constant ORACLE_RATE_PRECISION = 100000000;

    uint256 public rateDeviationThreshold = 0;
    bool public isApproveAllRates = false;
    AggregatorInterface public oracleRateAggregator;

    uint256 public oracleRateAggregatorSequenceNum = 0;
    uint256 public rateDeviationThresholdSequenceNum = 0;
    uint256 public isApproveAllRatesSequenceNum = 0;


    event OracleRateAggregatorSaved(address _oracleRateAggregatorAddress);
    event OracleRateAggregatorNotSaved(address _oracleRateAggregatorAddress);
    event RateDeviationThresholdSaved(uint256 _rateDeviationThreshold);
    event RateDeviationThresholdNotSaved(uint256 _rateDeviationThreshold);
    event ApproveAllRatesSaved(bool _isApproveAllRates);
    event ApproveAllRatesNotSaved(bool _isApproveAllRates);

    constructor(IContractAddressLocator _contractAddressLocator, address _oracleRateAggregatorAddress, uint256 _rateDeviationThreshold) ContractAddressLocatorHolder(_contractAddressLocator) public {
        setOracleRateAggregator(1, _oracleRateAggregatorAddress);
        setRateDeviationThreshold(1, _rateDeviationThreshold);
    }

    function setOracleRateAggregator(uint256 _oracleRateAggregatorSequenceNum, address _oracleRateAggregatorAddress) public onlyOwner() {

        require(_oracleRateAggregatorAddress != address(0), "invalid _oracleRateAggregatorAddress");
        if (oracleRateAggregatorSequenceNum < _oracleRateAggregatorSequenceNum) {
            oracleRateAggregatorSequenceNum = _oracleRateAggregatorSequenceNum;
            oracleRateAggregator = AggregatorInterface(_oracleRateAggregatorAddress);
            emit OracleRateAggregatorSaved(_oracleRateAggregatorAddress);
        }
        else {
            emit OracleRateAggregatorNotSaved(_oracleRateAggregatorAddress);
        }
    }


    function setRateDeviationThreshold(uint256 _rateDeviationThresholdSequenceNum, uint256 _rateDeviationThreshold) public onlyOwner {

        require(_rateDeviationThreshold < MILLION, "_rateDeviationThreshold  is out of range");
        if (rateDeviationThresholdSequenceNum < _rateDeviationThresholdSequenceNum) {
            rateDeviationThresholdSequenceNum = _rateDeviationThresholdSequenceNum;
            rateDeviationThreshold = _rateDeviationThreshold;
            emit RateDeviationThresholdSaved(_rateDeviationThreshold);
        }
        else {
            emit RateDeviationThresholdNotSaved(_rateDeviationThreshold);
        }
    }


    function setIsApproveAllRates(uint256 _isApproveAllRatesSequenceNum, bool _isApproveAllRates) public onlyOwner {

        if (isApproveAllRatesSequenceNum < _isApproveAllRatesSequenceNum) {
            isApproveAllRatesSequenceNum = _isApproveAllRatesSequenceNum;
            isApproveAllRates = _isApproveAllRates;
            emit ApproveAllRatesSaved(_isApproveAllRates);
        }
        else {
            emit ApproveAllRatesNotSaved(_isApproveAllRates);
        }
    }


    function approveHighRate(uint256 _highRateN, uint256 _highRateD) external view only(_IETHConverter_) returns (bool){

        return approveRate(_highRateN, _highRateD);
    }

    function approveLowRate(uint256 _lowRateN, uint256 _lowRateD) external view only(_IETHConverter_) returns (bool){

        return approveRate(_lowRateN, _lowRateD);
    }

    function approveRate(uint256 _rateN, uint256 _rateD) internal view returns (bool) {

        assert(_rateN > 0);
        assert(_rateD > 0);
        bool success = true;

        if (!isApproveAllRates) {
            uint256 A = (getOracleLatestRate()).mul(_rateD);
            uint256 B = A.mul(MILLION);
            uint256 C = A.mul(rateDeviationThreshold);
            uint256 rate = (_rateN.mul(ORACLE_RATE_PRECISION)).mul(MILLION);

            if (rate > B.add(C)) {
                success = false;
            }
            else if (rate < B.sub(C)) {
                success = false;
            }
        }

        return success;
    }

    function getOracleLatestRate() internal view returns (uint256) {

        int256 latestAnswer = oracleRateAggregator.latestAnswer();
        assert(latestAnswer > 0);
        return uint256(latestAnswer);
    }
}