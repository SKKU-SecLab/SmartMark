
pragma solidity 0.4.25;


interface IRateApprover {

    function approveRate(uint256 _highRateN, uint256 _highRateD, uint256 _lowRateN, uint256 _lowRateD) external view  returns (bool, string);

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
    bytes32 internal constant _IWalletsTradingDataSource_       = "IWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _WalletsTradingLimiter_SGATokenManager_          = "WalletsTLSGATokenManager"         ;
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



contract RateApprover is IRateApprover, ContractAddressLocatorHolder, Claimable {

    string public constant VERSION = "1.0.0";

    using SafeMath for uint256;

    uint256 public constant MAX_RESOLUTION = 0x10000000000000000;

    uint256 public sequenceNum = 0;
    uint256 public maxHighRateN = 0;
    uint256 public maxHighRateD = 0;
    uint256 public minLowRateN = 0;
    uint256 public minLowRateD = 0;

    event RateBoundsSaved(uint256 _maxHighRateN, uint256 _maxHighRateD, uint256 _minLowRateN, uint256 _minLowRateD);
    event RateBoundsNotSaved(uint256 _maxHighRateN, uint256 _maxHighRateD, uint256 _minLowRateN, uint256 _minLowRateD);

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}


    modifier onlyIfRateBoundsSet() {

        assert(maxHighRateN > 0 && maxHighRateD > 0 && minLowRateN > 0 && minLowRateD > 0);
        _;
    }


    function setRateBounds(uint256 _sequenceNum, uint256 _maxHighRateN, uint256 _maxHighRateD, uint256 _minLowRateN, uint256 _minLowRateD) external onlyOwner {

        require(1 <= _maxHighRateN && _maxHighRateN <= MAX_RESOLUTION, "max high rate numerator is out of range");
        require(1 <= _maxHighRateD && _maxHighRateD <= MAX_RESOLUTION, "max high rate denominator is out of range");
        require(1 <= _minLowRateN && _minLowRateN <= MAX_RESOLUTION, "min low rate numerator is out of range");
        require(1 <= _minLowRateD && _minLowRateD <= MAX_RESOLUTION, "min low rate denominator is out of range");
        require(_maxHighRateN * _minLowRateD > _maxHighRateD * _minLowRateN, "max high rate is smaller than min low rate");

        if (sequenceNum < _sequenceNum) {
            sequenceNum = _sequenceNum;
            maxHighRateN = _maxHighRateN;
            maxHighRateD = _maxHighRateD;
            minLowRateN = _minLowRateN;
            minLowRateD = _minLowRateD;

            emit RateBoundsSaved(_maxHighRateN, _maxHighRateD, _minLowRateN, _minLowRateD);
        }
        else {
            emit RateBoundsNotSaved(_maxHighRateN, _maxHighRateD, _minLowRateN, _minLowRateD);
        }
    }


    function approveRate(uint256 _highRateN, uint256 _highRateD, uint256 _lowRateN, uint256 _lowRateD) external view only(_IETHConverter_) onlyIfRateBoundsSet returns (bool, string){

        bool success = false;
        string memory reason;
        if (_highRateN.mul(_lowRateD) < _highRateD.mul(_lowRateN))
            reason = "high rate is smaller than low rate";
        else if (maxHighRateN.mul(_highRateD) < maxHighRateD.mul(_highRateN))
            reason = "high rate is higher than max high rate";
        else if (_lowRateN.mul(minLowRateD) < _lowRateD.mul(minLowRateN))
            reason = "low rate is lower than min low rate";
        else
            success = true;
        return (success, reason);
    }


}