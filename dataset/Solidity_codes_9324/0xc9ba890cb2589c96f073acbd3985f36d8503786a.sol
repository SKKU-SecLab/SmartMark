
pragma solidity 0.4.25;


interface IMonetaryModel {

    function buy(uint256 _sdrAmount) external returns (uint256);


    function sell(uint256 _sgrAmount) external returns (uint256);

}


interface IMonetaryModelState {

    function setSdrTotal(uint256 _amount) external;


    function setSgrTotal(uint256 _amount) external;


    function getSdrTotal() external view returns (uint256);


    function getSgrTotal() external view returns (uint256);

}


interface IModelCalculator {

    function isTrivialInterval(uint256 _alpha, uint256 _beta) external pure returns (bool);


    function getValN(uint256 _valR, uint256 _maxN, uint256 _maxR) external pure returns (uint256);


    function getValR(uint256 _valN, uint256 _maxR, uint256 _maxN) external pure returns (uint256);


    function getNewN(uint256 _newR, uint256 _minR, uint256 _minN, uint256 _alpha, uint256 _beta) external pure returns (uint256);


    function getNewR(uint256 _newN, uint256 _minN, uint256 _minR, uint256 _alpha, uint256 _beta) external pure returns (uint256);

}


interface IPriceBandCalculator {

    function buy(uint256 _sdrAmount, uint256 _sgrTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);


    function sell(uint256 _sdrAmount, uint256 _sgrTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);

}


interface IIntervalIterator {

    function grow() external;


    function shrink() external;


    function getCurrentInterval() external view returns (uint256, uint256, uint256, uint256, uint256, uint256);


    function getCurrentIntervalCoefs() external view returns (uint256, uint256);

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
    bytes32 internal constant _ISogurExchanger_           = "ISogurExchanger"          ;
    bytes32 internal constant _SgnToSgrExchangeInitiator_ = "SgnToSgrExchangeInitiator"          ;
    bytes32 internal constant _IMonetaryModel_               = "IMonetaryModel"              ;
    bytes32 internal constant _IMonetaryModelState_          = "IMonetaryModelState"         ;
    bytes32 internal constant _ISGRAuthorizationManager_ = "ISGRAuthorizationManager";
    bytes32 internal constant _ISGRToken_                = "ISGRToken"               ;
    bytes32 internal constant _ISGRTokenManager_         = "ISGRTokenManager"        ;
    bytes32 internal constant _ISGRTokenInfo_         = "ISGRTokenInfo"        ;
    bytes32 internal constant _ISGNAuthorizationManager_ = "ISGNAuthorizationManager";
    bytes32 internal constant _ISGNToken_                = "ISGNToken"               ;
    bytes32 internal constant _ISGNTokenManager_         = "ISGNTokenManager"        ;
    bytes32 internal constant _IMintingPointTimersManager_             = "IMintingPointTimersManager"            ;
    bytes32 internal constant _ITradingClasses_          = "ITradingClasses"         ;
    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = "IWalletsTLValueConverter"       ;
    bytes32 internal constant _BuyWalletsTradingDataSource_       = "BuyWalletsTradingDataSource"      ;
    bytes32 internal constant _SellWalletsTradingDataSource_       = "SellWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _BuyWalletsTradingLimiter_SGRTokenManager_          = "BuyWalletsTLSGRTokenManager"         ;
    bytes32 internal constant _SellWalletsTradingLimiter_SGRTokenManager_          = "SellWalletsTLSGRTokenManager"         ;
    bytes32 internal constant _IETHConverter_             = "IETHConverter"   ;
    bytes32 internal constant _ITransactionLimiter_      = "ITransactionLimiter"     ;
    bytes32 internal constant _ITransactionManager_      = "ITransactionManager"     ;
    bytes32 internal constant _IRateApprover_      = "IRateApprover"     ;
    bytes32 internal constant _SGAToSGRInitializer_      = "SGAToSGRInitializer"     ;

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



contract MonetaryModel is IMonetaryModel, ContractAddressLocatorHolder {

    string public constant VERSION = "1.0.1";

    using SafeMath for uint256;

    uint256 public constant MIN_RR  = 1000000000000000000000000000000000;
    uint256 public constant MAX_RR  = 10000000000000000000000000000000000;

    event MonetaryModelBuyCompleted(uint256 _input, uint256 _output);
    event MonetaryModelSellCompleted(uint256 _input, uint256 _output);

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    function getMonetaryModelState() public view returns (IMonetaryModelState) {

        return IMonetaryModelState(getContractAddress(_IMonetaryModelState_));
    }

    function getModelCalculator() public view returns (IModelCalculator) {

        return IModelCalculator(getContractAddress(_IModelCalculator_));
    }

    function getPriceBandCalculator() public view returns (IPriceBandCalculator) {

        return IPriceBandCalculator(getContractAddress(_IPriceBandCalculator_));
    }

    function getIntervalIterator() public view returns (IIntervalIterator) {

        return IIntervalIterator(getContractAddress(_IIntervalIterator_));
    }

    function buy(uint256 _sdrAmount) external only(_ITransactionManager_) returns (uint256) {

        IMonetaryModelState monetaryModelState = getMonetaryModelState();
        IIntervalIterator intervalIterator = getIntervalIterator();

        uint256 sgrTotal = monetaryModelState.getSgrTotal();
        (uint256 alpha, uint256 beta) = intervalIterator.getCurrentIntervalCoefs();
        uint256 reserveRatio = alpha.sub(beta.mul(sgrTotal));
        assert(MIN_RR <= reserveRatio && reserveRatio <= MAX_RR);
        uint256 sdrAmountAfterFee = getPriceBandCalculator().buy(_sdrAmount, sgrTotal, alpha, beta);
        uint256 sgrAmount = buyFunc(sdrAmountAfterFee, monetaryModelState, intervalIterator);

        emit MonetaryModelBuyCompleted(_sdrAmount, sgrAmount);
        return sgrAmount;
    }

    function sell(uint256 _sgrAmount) external only(_ITransactionManager_) returns (uint256) {

        IMonetaryModelState monetaryModelState = getMonetaryModelState();
        IIntervalIterator intervalIterator = getIntervalIterator();

        uint256 sgrTotal = monetaryModelState.getSgrTotal();
        (uint256 alpha, uint256 beta) = intervalIterator.getCurrentIntervalCoefs();
        uint256 reserveRatio = alpha.sub(beta.mul(sgrTotal));
        assert(MIN_RR <= reserveRatio && reserveRatio <= MAX_RR);
        uint256 sdrAmountBeforeFee = sellFunc(_sgrAmount, monetaryModelState, intervalIterator);
        uint256 sdrAmount = getPriceBandCalculator().sell(sdrAmountBeforeFee, sgrTotal, alpha, beta);

        emit MonetaryModelSellCompleted(_sgrAmount, sdrAmount);
        return sdrAmount;
    }

    function buyFunc(uint256 _sdrAmount, IMonetaryModelState _monetaryModelState, IIntervalIterator _intervalIterator) private returns (uint256) {

        uint256 sgrCount = 0;
        uint256 sdrCount = _sdrAmount;

        uint256 sdrDelta;
        uint256 sgrDelta;

        uint256 sdrTotal = _monetaryModelState.getSdrTotal();
        uint256 sgrTotal = _monetaryModelState.getSgrTotal();

        (uint256 minN, uint256 maxN, uint256 minR, uint256 maxR, uint256 alpha, uint256 beta) = _intervalIterator.getCurrentInterval();
        while (sdrCount >= maxR.sub(sdrTotal)) {
            sdrDelta = maxR.sub(sdrTotal);
            sgrDelta = maxN.sub(sgrTotal);
            _intervalIterator.grow();
            (minN, maxN, minR, maxR, alpha, beta) = _intervalIterator.getCurrentInterval();
            sdrTotal = minR;
            sgrTotal = minN;
            sdrCount = sdrCount.sub(sdrDelta);
            sgrCount = sgrCount.add(sgrDelta);
        }

        if (sdrCount > 0) {
            if (getModelCalculator().isTrivialInterval(alpha, beta))
                sgrDelta = getModelCalculator().getValN(sdrCount, maxN, maxR);
            else
                sgrDelta = getModelCalculator().getNewN(sdrTotal.add(sdrCount), minR, minN, alpha, beta).sub(sgrTotal);
            sdrTotal = sdrTotal.add(sdrCount);
            sgrTotal = sgrTotal.add(sgrDelta);
            sgrCount = sgrCount.add(sgrDelta);
        }

        _monetaryModelState.setSdrTotal(sdrTotal);
        _monetaryModelState.setSgrTotal(sgrTotal);

        return sgrCount;
    }

    function sellFunc(uint256 _sgrAmount, IMonetaryModelState _monetaryModelState, IIntervalIterator _intervalIterator) private returns (uint256) {

        uint256 sdrCount = 0;
        uint256 sgrCount = _sgrAmount;

        uint256 sgrDelta;
        uint256 sdrDelta;

        uint256 sgrTotal = _monetaryModelState.getSgrTotal();
        uint256 sdrTotal = _monetaryModelState.getSdrTotal();

        (uint256 minN, uint256 maxN, uint256 minR, uint256 maxR, uint256 alpha, uint256 beta) = _intervalIterator.getCurrentInterval();
        while (sgrCount > sgrTotal.sub(minN)) {
            sgrDelta = sgrTotal.sub(minN);
            sdrDelta = sdrTotal.sub(minR);
            _intervalIterator.shrink();
            (minN, maxN, minR, maxR, alpha, beta) = _intervalIterator.getCurrentInterval();
            sgrTotal = maxN;
            sdrTotal = maxR;
            sgrCount = sgrCount.sub(sgrDelta);
            sdrCount = sdrCount.add(sdrDelta);
        }

        if (sgrCount > 0) {
            if (getModelCalculator().isTrivialInterval(alpha, beta))
                sdrDelta = getModelCalculator().getValR(sgrCount, maxR, maxN);
            else
                sdrDelta = sdrTotal.sub(getModelCalculator().getNewR(sgrTotal.sub(sgrCount), minN, minR, alpha, beta));
            sgrTotal = sgrTotal.sub(sgrCount);
            sdrTotal = sdrTotal.sub(sdrDelta);
            sdrCount = sdrCount.add(sdrDelta);
        }

        _monetaryModelState.setSgrTotal(sgrTotal);
        _monetaryModelState.setSdrTotal(sdrTotal);

        return sdrCount;
    }
}