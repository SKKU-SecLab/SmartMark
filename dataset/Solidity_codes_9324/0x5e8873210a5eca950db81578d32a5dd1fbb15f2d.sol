
pragma solidity 0.4.25;


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


library AuthorizationActionRoles {

    string public constant VERSION = "1.0.0";

    enum Flag {
        BuySga         ,
        SellSga        ,
        SellSgn        ,
        ReceiveSga     ,
        ReceiveSgn     ,
        TransferSga    ,
        TransferSgn    ,
        TransferFromSga,
        TransferFromSgn
    }

    function isAuthorizedToBuySga         (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.BuySga         );}
    function isAuthorizedToSellSga        (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.SellSga        );}
    function isAuthorizedToSellSgn        (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.SellSgn        );}
    function isAuthorizedToReceiveSga     (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.ReceiveSga     );}
    function isAuthorizedToReceiveSgn     (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.ReceiveSgn     );}
    function isAuthorizedToTransferSga    (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferSga    );}
    function isAuthorizedToTransferSgn    (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferSgn    );}
    function isAuthorizedToTransferFromSga(uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferFromSga);}

    function isAuthorizedToTransferFromSgn(uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferFromSgn);}

    function isAuthorized(uint256 _flags, Flag _flag) private pure returns (bool) {return ((_flags >> uint256(_flag)) & 1) == 1;}

}


interface IAuthorizationDataSource {

    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);


    function getTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);

}



contract SGAAuthorizationManager is ISGAAuthorizationManager, ContractAddressLocatorHolder {

    string public constant VERSION = "1.0.0";

    using AuthorizationActionRoles for uint256;

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    function getAuthorizationDataSource() public view returns (IAuthorizationDataSource) {

        return IAuthorizationDataSource(getContractAddress(_IAuthorizationDataSource_));
    }

    function isAuthorizedToBuy(address _sender) external view returns (bool) {

        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();
        (bool senderIsWhitelisted, uint256 senderActionRole) = authorizationDataSource.getAuthorizedActionRole(_sender);
        return senderIsWhitelisted && senderActionRole.isAuthorizedToBuySga();
    }

    function isAuthorizedToSell(address _sender) external view returns (bool) {

        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();
        (bool senderIsWhitelisted, uint256 senderActionRole) = authorizationDataSource.getAuthorizedActionRole(_sender);
        return senderIsWhitelisted && senderActionRole.isAuthorizedToSellSga();
    }

    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool) {

        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();
        (bool senderIsWhitelisted, uint256 senderActionRole) = authorizationDataSource.getAuthorizedActionRole(_sender);
        (bool targetIsWhitelisted, uint256 targetActionRole) = authorizationDataSource.getAuthorizedActionRole(_target);
        return senderIsWhitelisted && senderActionRole.isAuthorizedToTransferSga()
            && targetIsWhitelisted && targetActionRole.isAuthorizedToReceiveSga();
    }

    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool) {

        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();
        (bool senderIsWhitelisted, uint256 senderActionRole) = authorizationDataSource.getAuthorizedActionRole(_sender);
        (bool sourceIsWhitelisted, uint256 sourceActionRole) = authorizationDataSource.getAuthorizedActionRole(_source);
        (bool targetIsWhitelisted, uint256 targetActionRole) = authorizationDataSource.getAuthorizedActionRole(_target);
        return senderIsWhitelisted && senderActionRole.isAuthorizedToTransferFromSga()
            && sourceIsWhitelisted && sourceActionRole.isAuthorizedToTransferSga()
            && targetIsWhitelisted && targetActionRole.isAuthorizedToReceiveSga();
    }

    function isAuthorizedForPublicOperation(address _sender) external view returns (bool) {

        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();
        (bool senderIsWhitelisted,) = authorizationDataSource.getAuthorizedActionRole(_sender);
        return senderIsWhitelisted;
    }
}