

pragma solidity 0.4.25;

interface IModelDataSource {

    function getInterval(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);


    function getIntervalCoefs(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256);


    function getRequiredMintAmount(uint256 _rowNum) external view returns (uint256);

}


pragma solidity 0.4.25;

interface IMintingPointTimersManager {

    function start(uint256 _id) external;


    function reset(uint256 _id) external;


    function running(uint256 _id) external view returns (bool);


    function expired(uint256 _id) external view returns (bool);

}


pragma solidity 0.4.25;

interface ISGAAuthorizationManager {

    function isAuthorizedToBuy(address _sender) external view returns (bool);


    function isAuthorizedToSell(address _sender) external view returns (bool);


    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool);


    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool);


    function isAuthorizedForPublicOperation(address _sender) external view returns (bool);

}


pragma solidity 0.4.25;

interface IMintListener {

    function mintSgaForSgnHolders(uint256 _value) external;

}


pragma solidity 0.4.25;

interface IMintHandler {

    function mintSgnVestedInDelay(uint256 _index) external;

}


pragma solidity 0.4.25;

interface IMintManager {

    function getIndex() external view returns (uint256);

}


pragma solidity 0.4.25;

interface IContractAddressLocator {

    function getContractAddress(bytes32 _identifier) external view returns (address);


    function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);

}


pragma solidity 0.4.25;


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


pragma solidity 0.4.25;









contract MintManager is IMintManager, ContractAddressLocatorHolder {

    string public constant VERSION = "1.0.0";

    uint256 public index;

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    function getModelDataSource() public view returns (IModelDataSource) {

        return IModelDataSource(getContractAddress(_IModelDataSource_));
    }

    function getMintingPointTimersManager() public view returns (IMintingPointTimersManager) {

        return IMintingPointTimersManager(getContractAddress(_IMintingPointTimersManager_));
    }

    function getSGAAuthorizationManager() public view returns (ISGAAuthorizationManager) {

        return ISGAAuthorizationManager(getContractAddress(_ISGAAuthorizationManager_));
    }

    function getMintHandler() public view returns (IMintHandler) {

        return IMintHandler(getContractAddress(_IMintHandler_));
    }

    function getMintListener() public view returns (IMintListener) {

        return IMintListener(getContractAddress(_IMintListener_));
    }

    function isMintingStateOutdated() public view returns (bool) {

        return getMintingPointTimersManager().expired(index + 1);
    }

    function updateMintingState() external {

        require(getSGAAuthorizationManager().isAuthorizedForPublicOperation(msg.sender), "update minting state is not authorized");
        if (isMintingStateOutdated()) {
            uint256 amount = getModelDataSource().getRequiredMintAmount(index);
            getMintListener().mintSgaForSgnHolders(amount);
            getMintHandler().mintSgnVestedInDelay(index + 1);
            index += 1;
        }
    }

    function getIndex() external view returns (uint256) {

        return index;
    }
}