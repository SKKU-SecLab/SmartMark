
pragma solidity 0.4.25;


interface IRedButton {

    function isEnabled() external view returns (bool);

}


interface IPaymentManager {

    function getNumOfPayments() external view returns (uint256);


    function getPaymentsSum() external view returns (uint256);


    function computeDifferPayment(uint256 _ethAmount, uint256 _ethBalance) external view returns (uint256);


    function registerDifferPayment(address _wallet, uint256 _ethAmount) external;

}


interface IReserveManager {

    function getDepositParams(uint256 _balance) external view returns (address, uint256);


    function getWithdrawParams(uint256 _balance) external view returns (address, uint256);

}


interface ISGRTokenManager {

    function exchangeEthForSgr(address _sender, uint256 _ethAmount) external returns (uint256);


    function afterExchangeEthForSgr(address _sender, uint256 _ethAmount, uint256 _sgrAmount) external;


    function exchangeSgrForEth(address _sender, uint256 _sgrAmount) external returns (uint256);


    function afterExchangeSgrForEth(address _sender, uint256 _sgrAmount, uint256 _ethAmount) external returns (bool);


    function uponTransfer(address _sender, address _to, uint256 _value) external;



    function afterTransfer(address _sender, address _to, uint256 _value, bool _transferResult) external returns (bool);


    function uponTransferFrom(address _sender, address _from, address _to, uint256 _value) external;


    function afterTransferFrom(address _sender, address _from, address _to, uint256 _value, bool _transferFromResult) external returns (bool);


    function uponDeposit(address _sender, uint256 _balance, uint256 _amount) external returns (address, uint256);


    function uponWithdraw(address _sender, uint256 _balance) external returns (address, uint256);


    function afterWithdraw(address _sender, address _wallet, uint256 _amount, uint256 _priorWithdrawEthBalance, uint256 _afterWithdrawEthBalance) external;


    function uponMintSgrForSgnHolders(uint256 _value) external;


    function afterMintSgrForSgnHolders(uint256 _value) external;


    function uponTransferSgrToSgnHolder(address _to, uint256 _value) external;


    function afterTransferSgrToSgnHolder(address _to, uint256 _value) external;


    function postTransferEthToSgrHolder(address _to, uint256 _value, bool _status) external;


    function getDepositParams() external view returns (address, uint256);


    function getWithdrawParams() external view returns (address, uint256);

}


interface ITransactionManager {

    function buy(uint256 _ethAmount) external returns (uint256);


    function sell(uint256 _sgrAmount) external returns (uint256);

}


interface ISGRAuthorizationManager {

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


interface IWalletsTradingLimiter {

    function updateWallet(address _wallet, uint256 _value) external;

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


contract BurnableWallets is Claimable {

    address[] public burnableWalletArray;

    struct BurnableWalletInfo {
        bool valid;
        uint256 index;
    }

    mapping(address => BurnableWalletInfo) public burnableWalletsTable;

    event BurnableWalletAccepted(address indexed _wallet);
    event BurnableWalletRejected(address indexed _wallet);

    function accept(address _wallet) external onlyOwner {

        require(_wallet != address(0), "wallet is illegal");
        BurnableWalletInfo storage burnableWalletInfo = burnableWalletsTable[_wallet];
        require(!burnableWalletInfo.valid, "wallet is already accepted");
        burnableWalletInfo.valid = true;
        burnableWalletInfo.index = burnableWalletArray.length;
        burnableWalletArray.push(_wallet);
        emit BurnableWalletAccepted(_wallet);
    }

    function reject(address _wallet) external onlyOwner {

        BurnableWalletInfo storage burnableWalletInfo = burnableWalletsTable[_wallet];
        require(burnableWalletArray.length > burnableWalletInfo.index, "wallet is already rejected");
        require(_wallet == burnableWalletArray[burnableWalletInfo.index], "wallet is already rejected");
        address lastWallet = burnableWalletArray[burnableWalletArray.length - 1];
        burnableWalletsTable[lastWallet].index = burnableWalletInfo.index;
        burnableWalletArray[burnableWalletInfo.index] = lastWallet;
        burnableWalletArray.length -= 1;
        delete burnableWalletsTable[_wallet];
        emit BurnableWalletRejected(_wallet);
    }

    function getBurnableWalletArray() external view returns (address[] memory) {

        return burnableWalletArray;
    }

    function getBurnableWalletCount() external view returns (uint256) {

        return burnableWalletArray.length;
    }

    function isBurnableWallet(address _wallet) public view returns (bool){

        return burnableWalletsTable[_wallet].valid;
    }
}



contract SGRTokenManager is ISGRTokenManager, ContractAddressLocatorHolder, BurnableWallets {

    string public constant VERSION = "2.0.0";

    using SafeMath for uint256;

    event ExchangeEthForSgrCompleted(address indexed _user, uint256 _input, uint256 _output);
    event ExchangeSgrForEthCompleted(address indexed _user, uint256 _input, uint256 _output);
    event MintSgrForSgnHoldersCompleted(uint256 _value);
    event TransferSgrToSgnHolderCompleted(address indexed _to, uint256 _value);
    event TransferEthToSgrHolderCompleted(address indexed _to, uint256 _value, bool _status);
    event DepositCompleted(address indexed _sender, uint256 _balance, uint256 _amount);
    event WithdrawCompleted(address indexed _sender, uint256 _balance, uint256 _amount);

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    function getSGRAuthorizationManager() public view returns (ISGRAuthorizationManager) {

        return ISGRAuthorizationManager(getContractAddress(_ISGRAuthorizationManager_));
    }

    function getTransactionManager() public view returns (ITransactionManager) {

        return ITransactionManager(getContractAddress(_ITransactionManager_));
    }

    function getSellWalletsTradingLimiter() public view returns (IWalletsTradingLimiter) {

        return IWalletsTradingLimiter(getContractAddress(_SellWalletsTradingLimiter_SGRTokenManager_));
    }

    function getBuyWalletsTradingLimiter() public view returns (IWalletsTradingLimiter) {

        return IWalletsTradingLimiter(getContractAddress(_BuyWalletsTradingLimiter_SGRTokenManager_));
    }

    function getReserveManager() public view returns (IReserveManager) {

        return IReserveManager(getContractAddress(_IReserveManager_));
    }

    function getPaymentManager() public view returns (IPaymentManager) {

        return IPaymentManager(getContractAddress(_IPaymentManager_));
    }

    function getRedButton() public view returns (IRedButton) {

        return IRedButton(getContractAddress(_IRedButton_));
    }

    modifier onlyIfRedButtonIsNotEnabled() {

        require(!getRedButton().isEnabled(), "red button is enabled");
        _;
    }

    function exchangeEthForSgr(address _sender, uint256 _ethAmount) external only(_ISGRToken_) onlyIfRedButtonIsNotEnabled returns (uint256) {

        require(getSGRAuthorizationManager().isAuthorizedToBuy(_sender), "exchanging ETH for SGR is not authorized");
        uint256 sgrAmount = getTransactionManager().buy(_ethAmount);
        emit ExchangeEthForSgrCompleted(_sender, _ethAmount, sgrAmount);
        getBuyWalletsTradingLimiter().updateWallet(_sender, sgrAmount);
        return sgrAmount;
    }

    function afterExchangeEthForSgr(address _sender, uint256 _ethAmount, uint256 _sgrAmount) external {

        _sender;
        _ethAmount;
        _sgrAmount;
    }


    function exchangeSgrForEth(address _sender, uint256 _sgrAmount) external only(_ISGRToken_) onlyIfRedButtonIsNotEnabled returns (uint256) {

        require(getSGRAuthorizationManager().isAuthorizedToSell(_sender), "exchanging SGR for ETH is not authorized");
        uint256 calculatedETHAmount = 0;
        if (!isBurnableWallet(_sender)) {
            uint256 ethAmount = getTransactionManager().sell(_sgrAmount);
            emit ExchangeSgrForEthCompleted(_sender, _sgrAmount, ethAmount);
            getSellWalletsTradingLimiter().updateWallet(_sender, _sgrAmount);
            IPaymentManager paymentManager = getPaymentManager();
            uint256 paymentETHAmount = paymentManager.computeDifferPayment(ethAmount, msg.sender.balance);
            if (paymentETHAmount > 0)
                paymentManager.registerDifferPayment(_sender, paymentETHAmount);
            assert(ethAmount >= paymentETHAmount);
            calculatedETHAmount = ethAmount - paymentETHAmount;
        }
        return calculatedETHAmount;
    }

    function afterExchangeSgrForEth(address _sender, uint256 _sgrAmount, uint256 _ethAmount) external returns (bool) {

        _sender;
        _sgrAmount;
        _ethAmount;
        return true;
    }


    function uponTransfer(address _sender, address _to, uint256 _value) external only(_ISGRToken_) {

        _sender;
        _to;
        _value;
    }

    function afterTransfer(address _sender, address _to, uint256 _value, bool _transferResult) external returns (bool) {

        _sender;
        _to;
        _value;
        return _transferResult;
    }

    function uponTransferFrom(address _sender, address _from, address _to, uint256 _value) external only(_ISGRToken_) {

        _sender;
        _from;
        _to;
        _value;
    }

    function afterTransferFrom(address _sender, address _from, address _to, uint256 _value, bool _transferFromResult) external returns (bool) {

        _sender;
        _from;
        _to;
        _value;
        return _transferFromResult;
    }

    function uponDeposit(address _sender, uint256 _balance, uint256 _amount) external only(_ISGRToken_) returns (address, uint256) {

        uint256 ethBalancePriorToDeposit = _balance.sub(_amount);
        (address wallet, uint256 recommendationAmount) = getReserveManager().getDepositParams(ethBalancePriorToDeposit);
        emit DepositCompleted(_sender, ethBalancePriorToDeposit, _amount);
        return (wallet, recommendationAmount);
    }

    function uponWithdraw(address _sender, uint256 _balance) external only(_ISGRToken_) returns (address, uint256) {

        require(getSGRAuthorizationManager().isAuthorizedForPublicOperation(_sender), "withdraw is not authorized");
        (address wallet, uint256 amount) = getReserveManager().getWithdrawParams(_balance);
        require(wallet != address(0), "caller is illegal");
        require(amount > 0, "operation is not required");
        emit WithdrawCompleted(_sender, _balance, amount);
        return (wallet, amount);
    }

    function afterWithdraw(address _sender, address _wallet, uint256 _amount, uint256 _priorWithdrawEthBalance, uint256 _afterWithdrawEthBalance) external {

        _sender;
        _wallet;
        _amount;
        _priorWithdrawEthBalance;
        _afterWithdrawEthBalance;
    }
    function uponMintSgrForSgnHolders(uint256 _value) external only(_ISGRToken_) {

        emit MintSgrForSgnHoldersCompleted(_value);
    }

    function afterMintSgrForSgnHolders(uint256 _value) external {

        _value;
    }

    function uponTransferSgrToSgnHolder(address _to, uint256 _value) external only(_ISGRToken_) onlyIfRedButtonIsNotEnabled {

        emit TransferSgrToSgnHolderCompleted(_to, _value);
    }

    function afterTransferSgrToSgnHolder(address _to, uint256 _value) external {

        _to;
        _value;
    }

    function postTransferEthToSgrHolder(address _to, uint256 _value, bool _status) external only(_ISGRToken_) {

        emit TransferEthToSgrHolderCompleted(_to, _value, _status);
    }

    function getDepositParams() external view only(_ISGRToken_) returns (address, uint256) {

        return getReserveManager().getDepositParams(msg.sender.balance);
    }

    function getWithdrawParams() external view only(_ISGRToken_) returns (address, uint256) {

        return getReserveManager().getWithdrawParams(msg.sender.balance);
    }
}