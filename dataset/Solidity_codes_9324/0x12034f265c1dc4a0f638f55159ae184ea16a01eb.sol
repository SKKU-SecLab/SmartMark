
pragma solidity 0.4.25;


interface IPaymentQueue {

    function getNumOfPayments() external view returns (uint256);


    function getPaymentsSum() external view returns (uint256);


    function getPayment(uint256 _index) external view returns (address, uint256);


    function addPayment(address _wallet, uint256 _amount) external;


    function updatePayment(uint256 _amount) external;


    function removePayment() external;

}


interface ISGAAuthorizationManager {

    function isAuthorizedToBuy(address _sender) external view returns (bool);


    function isAuthorizedToSell(address _sender) external view returns (bool);


    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool);


    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool);


    function isAuthorizedForPublicOperation(address _sender) external view returns (bool);

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


library Math {

  function max(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;
  }

  function average(uint256 a, uint256 b) internal pure returns (uint256) {

    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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



contract PaymentQueue is IPaymentQueue, ContractAddressLocatorHolder {

    string public constant VERSION = "1.0.0";

    using SafeMath for uint256;

    struct Payment {
        address wallet;
        uint256 amount;
    }

    Payment[] public payments;
    uint256 public first;
    uint256 public last;

    uint256 public sum = 0;

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    function getSGAAuthorizationManager() public view returns (ISGAAuthorizationManager) {

        return ISGAAuthorizationManager(getContractAddress(_ISGAAuthorizationManager_));
    }

    modifier assertNonEmpty() {

        assert(last > 0);
        _;
    }

    function getNumOfPayments() external view returns (uint256) {

        return last.sub(first);
    }

    function getPaymentsSum() external view returns (uint256) {

        return sum;
    }

    function getPayment(uint256 _index) external view assertNonEmpty returns (address, uint256)  {

        require(last.sub(first) > _index, "index out of range");
        Payment memory payment = payments[first.add(_index)];
        return (payment.wallet, payment.amount);
    }

    function addPayment(address _wallet, uint256 _amount) external only(_IPaymentManager_) {

        assert(_wallet != address(0) && _amount > 0);
        Payment memory newPayment = Payment({wallet : _wallet, amount : _amount});
        if (payments.length > last)
            payments[last] = newPayment;
        else
            payments.push(newPayment);
        sum = sum.add(_amount);
        last = last.add(1);
    }

    function updatePayment(uint256 _amount) external only(_IPaymentManager_) assertNonEmpty {

        assert(_amount > 0);
        sum = (sum.add(_amount)).sub(payments[first].amount);
        payments[first].amount = _amount;

    }

    function removePayment() external only(_IPaymentManager_) assertNonEmpty {

        sum = sum.sub(payments[first].amount);
        payments[first] = Payment({wallet : address(0), amount : 0});
        uint256 newFirstPosition = first.add(1);
        if (newFirstPosition == last)
            first = last = 0;
        else
            first = newFirstPosition;
    }

    function clean(uint256 _maxCleanLength) external {

        require(getSGAAuthorizationManager().isAuthorizedForPublicOperation(msg.sender), "clean queue is not authorized");
        uint256 paymentsQueueLength = payments.length;
        if (paymentsQueueLength > last) {
            uint256 totalPaymentsToClean = paymentsQueueLength.sub(last);
            payments.length = (totalPaymentsToClean < _maxCleanLength) ? last : paymentsQueueLength.sub(_maxCleanLength);
        }
        
    }
}