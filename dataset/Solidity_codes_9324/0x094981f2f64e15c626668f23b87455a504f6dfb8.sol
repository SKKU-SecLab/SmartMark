
pragma solidity 0.4.25;


interface ISGATokenManager {

    function exchangeEthForSga(address _sender, uint256 _ethAmount) external returns (uint256);


    function exchangeSgaForEth(address _sender, uint256 _sgaAmount) external returns (uint256);


    function uponTransfer(address _sender, address _to, uint256 _value) external;


    function uponTransferFrom(address _sender, address _from, address _to, uint256 _value) external;


    function uponDeposit(address _sender, uint256 _balance, uint256 _amount) external returns (address, uint256);


    function uponWithdraw(address _sender, uint256 _balance) external returns (address, uint256);


    function uponMintSgaForSgnHolders(uint256 _value) external;


    function uponTransferSgaToSgnHolder(address _to, uint256 _value) external;


    function postTransferEthToSgaHolder(address _to, uint256 _value, bool _status) external;


    function getDepositParams() external view returns (address, uint256);


    function getWithdrawParams() external view returns (address, uint256);

}


interface IReserveManager {

    function getDepositParams(uint256 _balance) external view returns (address, uint256);


    function getWithdrawParams(uint256 _balance) external view returns (address, uint256);

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



contract TransferOnlySGATokenManager is ISGATokenManager, ContractAddressLocatorHolder {

    string public constant VERSION = "1.0.1";
    using SafeMath for uint256;

    event WithdrawCompleted(address indexed _sender, uint256 _balance, uint256 _amount);

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    
    function getReserveManager() public view returns (IReserveManager) {

        return IReserveManager(getContractAddress(_IReserveManager_));
    }

    function getSGRTokenContractAddress() public view returns (address) {

        return getContractAddress(_ISGRToken_);
    }


    modifier blockSGRTokenContractAddress(address _destination) {

        address sgrTokenContractAddress = getSGRTokenContractAddress();
        require(_destination != sgrTokenContractAddress , "SGA cannot be sent directly to the SGRToken smart contract");
        _;
    }

    function exchangeEthForSga(address _sender, uint256 _ethAmount) external returns (uint256) {

        require(false, "SGA token has been deprecated. Use SGR token instead");
        _sender;
        _ethAmount;
        return 0;
    }

    function exchangeSgaForEth(address _sender, uint256 _sgaAmount) external returns (uint256) {

        require(false, "SGA token has been deprecated. Use SGR token instead");
        _sender;
        _sgaAmount;
        return 0;
    }

    function uponTransfer(address _sender, address _to, uint256 _value) external blockSGRTokenContractAddress(_to) {

        _sender;
        _to;
        _value;
    }

    function uponTransferFrom(address _sender, address _from, address _to, uint256 _value) external blockSGRTokenContractAddress(_to) {

        _sender;
        _from;
        _to;
        _value;
    }

    function uponDeposit(address _sender, uint256 _balance, uint256 _amount) external returns (address, uint256) {

        require(false, "SGA token has been deprecated. Use SGR token instead");
        _sender;
        _balance;
        _amount;
        return (address(0), 0);

    }

    function uponWithdraw(address _sender, uint256 _balance) external returns (address, uint256) {

        (address wallet, uint256 amount) = getReserveManager().getWithdrawParams(_balance);
        require(wallet != address(0), "caller is illegal");
        emit WithdrawCompleted(_sender, _balance, amount);
        return (wallet, _balance);
    }

    function uponMintSgaForSgnHolders(uint256 _value) external {

        require(false, "SGA token has been deprecated. Use SGR token instead");
        _value;
    }

    function uponTransferSgaToSgnHolder(address _to, uint256 _value) external {

        require(false, "SGA token has been deprecated. Use SGR token instead");
        _to;
        _value;
    }

    function postTransferEthToSgaHolder(address _to, uint256 _value, bool _status) external {

        require(false, "SGA token has been deprecated. Use SGR token instead");
        _to;
        _value;
        _status;
    }

    function getDepositParams() external view returns (address, uint256) {

        require(false, "SGA token has been deprecated. Use SGR token instead");
        return (address(0), 0);
    }

    function getWithdrawParams() external view returns (address, uint256) {

        require(false, "SGA token has been deprecated. Use SGR token instead");
        return (address(0), 0);
    }
}