
pragma solidity 0.4.25;


interface IMonetaryModelState {

    function setSdrTotal(uint256 _amount) external;


    function setSgrTotal(uint256 _amount) external;


    function getSdrTotal() external view returns (uint256);


    function getSgrTotal() external view returns (uint256);

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



contract MonetaryModelState is IMonetaryModelState, ContractAddressLocatorHolder {

    string public constant VERSION = "1.1.0";

    bool public initialized;

    uint256 public sdrTotal;
    uint256 public sgrTotal;

    event MonetaryModelStateInitialized(address indexed _initializer, uint256 _sdrTotal, uint256 _sgrTotal);

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    modifier onlyIfNotInitialized() {

        require(!initialized, "contract already initialized");
        _;
    }

    function init(uint256 _sdrTotal, uint256 _sgrTotal) external onlyIfNotInitialized only(_SGAToSGRInitializer_) {

        initialized = true;
        sdrTotal = _sdrTotal;
        sgrTotal = _sgrTotal;
        emit MonetaryModelStateInitialized(msg.sender, _sdrTotal, _sgrTotal);
    }

    function setSdrTotal(uint256 _amount) external only(_IMonetaryModel_) {

        sdrTotal = _amount;
    }

    function setSgrTotal(uint256 _amount) external only(_IMonetaryModel_) {

        sgrTotal = _amount;
    }

    function getSdrTotal() external view returns (uint256) {

        return sdrTotal;
    }

    function getSgrTotal() external view returns (uint256) {

        return sgrTotal;
    }
}


interface IPaymentHandler {

    function getEthBalance() external view returns (uint256);


    function transferEthToSgrHolder(address _to, uint256 _value) external;

}


interface IMintListener {

    function mintSgrForSgnHolders(uint256 _value) external;

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


interface ISogurExchanger {

    function transferSgrToSgnHolder(address _to, uint256 _value) external;

}


interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
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


contract ERC20 is IERC20 {

  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  function totalSupply() public view returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];
  }

  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {

    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool) {

    _transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {

    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {

    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {

    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _transfer(address from, address to, uint256 value) internal {

    require(value <= _balances[from], "sdjfndskjfndskjfb");
    require(to != address(0), "asfdsf");

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  function _mint(address account, uint256 value) internal {

    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  function _burn(address account, uint256 value) internal {

    require(account != 0, "heerrrrrsss");
    require(value <= _balances[account], "heerrrrr");

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  function _burnFrom(address account, uint256 value) internal {

    require(value <= _allowed[account][msg.sender]);

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}


interface ISGRTokenInfo {

    function getName() external pure returns (string);


    function getSymbol() external pure returns (string);


    function getDecimals() external pure returns (uint8);

}



contract SGRToken is ERC20, ContractAddressLocatorHolder, IMintListener, ISogurExchanger, IPaymentHandler {

    string public constant VERSION = "2.0.0";

    bool public initialized;

    event SgrTokenInitialized(address indexed _initializer, address _sgaToSGRTokenExchangeAddress, uint256 _sgaToSGRTokenExchangeSGRSupply);


    address public constant SGR_MINTED_FOR_SGN_HOLDERS = address(keccak256("SGR_MINTED_FOR_SGN_HOLDERS"));

    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    function getSGRTokenManager() public view returns (ISGRTokenManager) {

        return ISGRTokenManager(getContractAddress(_ISGRTokenManager_));
    }

    function getSGRTokenInfo() public view returns (ISGRTokenInfo) {

        return ISGRTokenInfo(getContractAddress(_ISGRTokenInfo_));
    }

    function name() public view returns (string) {

        return getSGRTokenInfo().getName();
    }

    function symbol() public view returns (string){

        return getSGRTokenInfo().getSymbol();
    }

    function decimals() public view returns (uint8){

        return getSGRTokenInfo().getDecimals();
    }

    modifier onlyIfNotInitialized() {

        require(!initialized, "contract already initialized");
        _;
    }

    function() external payable {
        ISGRTokenManager sgrTokenManager = getSGRTokenManager();
        uint256 amount = sgrTokenManager.exchangeEthForSgr(msg.sender, msg.value);
        _mint(msg.sender, amount);
        sgrTokenManager.afterExchangeEthForSgr(msg.sender, msg.value, amount);
    }

    function exchange() external payable {

        ISGRTokenManager sgrTokenManager = getSGRTokenManager();
        uint256 amount = sgrTokenManager.exchangeEthForSgr(msg.sender, msg.value);
        _mint(msg.sender, amount);
        sgrTokenManager.afterExchangeEthForSgr(msg.sender, msg.value, amount);
    }

    function init(address _sgaToSGRTokenExchangeAddress, uint256 _sgaToSGRTokenExchangeSGRSupply) external onlyIfNotInitialized only(_SGAToSGRInitializer_) {

        require(_sgaToSGRTokenExchangeAddress != address(0), "SGA to SGR token exchange address is illegal");
        initialized = true;
        _mint(_sgaToSGRTokenExchangeAddress, _sgaToSGRTokenExchangeSGRSupply);
        emit SgrTokenInitialized(msg.sender, _sgaToSGRTokenExchangeAddress, _sgaToSGRTokenExchangeSGRSupply);
    }


    function transfer(address _to, uint256 _value) public returns (bool) {

        ISGRTokenManager sgrTokenManager = getSGRTokenManager();
        if (_to == address(this)) {
            uint256 amount = sgrTokenManager.exchangeSgrForEth(msg.sender, _value);
            _burn(msg.sender, _value);
            msg.sender.transfer(amount);
            return sgrTokenManager.afterExchangeSgrForEth(msg.sender, _value, amount);
        }
        sgrTokenManager.uponTransfer(msg.sender, _to, _value);
        bool transferResult = super.transfer(_to, _value);
        return sgrTokenManager.afterTransfer(msg.sender, _to, _value, transferResult);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        ISGRTokenManager sgrTokenManager = getSGRTokenManager();
        require(_to != address(this), "custodian-transfer of SGR into this contract is illegal");
        sgrTokenManager.uponTransferFrom(msg.sender, _from, _to, _value);
        bool transferFromResult = super.transferFrom(_from, _to, _value);
        return sgrTokenManager.afterTransferFrom(msg.sender, _from, _to, _value, transferFromResult);
    }

    function deposit() external payable {

        getSGRTokenManager().uponDeposit(msg.sender, address(this).balance, msg.value);
    }

    function withdraw() external {

        ISGRTokenManager sgrTokenManager = getSGRTokenManager();
        uint256 priorWithdrawEthBalance = address(this).balance;
        (address wallet, uint256 amount) = sgrTokenManager.uponWithdraw(msg.sender, priorWithdrawEthBalance);
        wallet.transfer(amount);
        sgrTokenManager.afterWithdraw(msg.sender, wallet, amount, priorWithdrawEthBalance, address(this).balance);
    }

    function mintSgrForSgnHolders(uint256 _value) external only(_IMintManager_) {

        ISGRTokenManager sgrTokenManager = getSGRTokenManager();
        sgrTokenManager.uponMintSgrForSgnHolders(_value);
        _mint(SGR_MINTED_FOR_SGN_HOLDERS, _value);
        sgrTokenManager.afterMintSgrForSgnHolders(_value);
    }

    function transferSgrToSgnHolder(address _to, uint256 _value) external only(_SgnToSgrExchangeInitiator_) {

        ISGRTokenManager sgrTokenManager = getSGRTokenManager();
        sgrTokenManager.uponTransferSgrToSgnHolder(_to, _value);
        _transfer(SGR_MINTED_FOR_SGN_HOLDERS, _to, _value);
        sgrTokenManager.afterTransferSgrToSgnHolder(_to, _value);
    }

    function transferEthToSgrHolder(address _to, uint256 _value) external only(_IPaymentManager_) {

        bool status = _to.send(_value);
        getSGRTokenManager().postTransferEthToSgrHolder(_to, _value, status);
    }

    function getEthBalance() external view returns (uint256) {

        return address(this).balance;
    }

    function getDepositParams() external view returns (address, uint256) {

        return getSGRTokenManager().getDepositParams();
    }

    function getWithdrawParams() external view returns (address, uint256) {

        return getSGRTokenManager().getWithdrawParams();
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


interface IRedButton {

    function isEnabled() external view returns (bool);

}



interface ISGAToSGRInitializerSGAMonetaryModelState {

    function getSgaTotal() external view returns (uint256);


    function getSdrTotal() external view returns (uint256);

}


contract SGAToSGRInitializer is Claimable {

    string public constant VERSION = "1.0.0";

    IRedButton public redButton;
    IERC20 public sgaToken;
    SGRToken public sgrToken;
    ISGAToSGRInitializerSGAMonetaryModelState public sgaMonetaryModelState;
    MonetaryModelState public sgrMonetaryModelState;

    address  public sgaToSGRTokenExchangeAddress;

    constructor(address _redButtonAddress, address _sgaTokenAddress, address _sgrTokenAddress, address _sgaMonetaryModelStateAddress, address _sgrMonetaryModelStateAddress, address _sgaToSGRTokenExchangeAddress) public {
        require(_redButtonAddress != address(0), "red button address is illegal");
        require(_sgaTokenAddress != address(0), "SGA token address is illegal");
        require(_sgrTokenAddress != address(0), "SGR token address is illegal");
        require(_sgaMonetaryModelStateAddress != address(0), "SGA MonetaryModelState address is illegal");
        require(_sgrMonetaryModelStateAddress != address(0), "SGR MonetaryModelState address is illegal");
        require(_sgaToSGRTokenExchangeAddress != address(0), "SGA to SGR token exchange is illegal");

        redButton = IRedButton(_redButtonAddress);
        sgaToken = IERC20(_sgaTokenAddress);
        sgrToken = SGRToken(_sgrTokenAddress);
        sgaMonetaryModelState = ISGAToSGRInitializerSGAMonetaryModelState(_sgaMonetaryModelStateAddress);
        sgrMonetaryModelState = MonetaryModelState(_sgrMonetaryModelStateAddress);
        sgaToSGRTokenExchangeAddress = _sgaToSGRTokenExchangeAddress;
    }

    modifier onlyIfRedButtonIsEnabled() {

        require(redButton.isEnabled(), "red button must be enabled");
        _;
    }

    function executeInitialization() external onlyIfRedButtonIsEnabled onlyOwner {

        uint256 initializationSGRAmount = getInitializationAmount();
        sgrToken.init(sgaToSGRTokenExchangeAddress, initializationSGRAmount);
        sgrMonetaryModelState.init(initializationSGRAmount, initializationSGRAmount);
    }

    function getInitializationAmount() public view returns (uint256) {

        uint256 sga1 = sgaToken.totalSupply();
        uint256 sga2 = sgaMonetaryModelState.getSgaTotal();
        require(sga1 == sga2, "abnormal SGA token state");
        uint256 sdr = sgaMonetaryModelState.getSdrTotal();
        require(sga2 == sdr, "abnormal SGA monetary model state");
        return sga1;
    }
}