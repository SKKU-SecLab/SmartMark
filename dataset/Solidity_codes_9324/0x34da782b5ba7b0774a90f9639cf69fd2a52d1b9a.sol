
pragma solidity 0.4.25;


interface ISGNAuthorizationManager {

    function isAuthorizedToSell(address _sender) external view returns (bool);


    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool);


    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool);

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


library AuthorizationActionRoles {

    string public constant VERSION = "1.1.0";

    enum Flag {
        BuySga         ,
        SellSga        ,
        SellSgn        ,
        ReceiveSgn     ,
        TransferSgn    ,
        TransferFromSgn
    }

    function isAuthorizedToBuySga         (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.BuySga         );}
    function isAuthorizedToSellSga        (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.SellSga        );}
    function isAuthorizedToSellSgn        (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.SellSgn        );}
    function isAuthorizedToReceiveSgn     (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.ReceiveSgn     );}
    function isAuthorizedToTransferSgn    (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferSgn    );}
    function isAuthorizedToTransferFromSgn(uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferFromSgn);}

    function isAuthorized(uint256 _flags, Flag _flag) private pure returns (bool) {return ((_flags >> uint256(_flag)) & 1) == 1;}

}


interface IAuthorizationDataSource {

    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);


    function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256);


    function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256);



    function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);


    function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);

}


interface ITradingClasses {

    function getInfo(uint256 _id) external view returns (uint256, uint256, uint256);


    function getActionRole(uint256 _id) external view returns (uint256);


    function getSellLimit(uint256 _id) external view returns (uint256);


    function getBuyLimit(uint256 _id) external view returns (uint256);

}



contract SGNAuthorizationManager is ISGNAuthorizationManager, ContractAddressLocatorHolder {

    string public constant VERSION = "1.1.0";

    using AuthorizationActionRoles for uint256;

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    function getAuthorizationDataSource() public view returns (IAuthorizationDataSource) {

        return IAuthorizationDataSource(getContractAddress(_IAuthorizationDataSource_));
    }

    function getTradingClasses() public view returns (ITradingClasses) {

        return ITradingClasses(getContractAddress(_ITradingClasses_));
    }

    function isAuthorizedToSell(address _sender) external view returns (bool) {

        (bool senderIsWhitelisted, uint256 senderActionRole, uint256 senderTradeClassId) = getAuthorizationDataSource().getAuthorizedActionRoleAndClass(_sender);

        return senderIsWhitelisted && getActionRole(senderActionRole, senderTradeClassId).isAuthorizedToSellSgn();
    }

    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool) {

        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();
        (bool senderIsWhitelisted, uint256 senderActionRole, uint256 senderTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_sender);
        (bool targetIsWhitelisted, uint256 targetActionRole, uint256 targetTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_target);

        return senderIsWhitelisted && targetIsWhitelisted &&
        getActionRole(senderActionRole, senderTradeClassId).isAuthorizedToTransferSgn() &&
        getActionRole(targetActionRole, targetTradeClassId).isAuthorizedToReceiveSgn();
    }

    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool) {

        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();
        (bool senderIsWhitelisted, uint256 senderActionRole, uint256 senderTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_sender);
        (bool sourceIsWhitelisted, uint256 sourceActionRole, uint256 sourceTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_source);
        (bool targetIsWhitelisted, uint256 targetActionRole, uint256 targetTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_target);

        return senderIsWhitelisted && sourceIsWhitelisted && targetIsWhitelisted &&
        getActionRole(senderActionRole, senderTradeClassId).isAuthorizedToTransferFromSgn() &&
        getActionRole(sourceActionRole, sourceTradeClassId).isAuthorizedToTransferSgn() &&
        getActionRole(targetActionRole, targetTradeClassId).isAuthorizedToReceiveSgn();
    }

    function getActionRole(uint256 _actionRole, uint256 _tradeClassId) private view returns (uint256) {

        return _actionRole > 0 ? _actionRole : getTradingClasses().getActionRole(_tradeClassId);
    }
}