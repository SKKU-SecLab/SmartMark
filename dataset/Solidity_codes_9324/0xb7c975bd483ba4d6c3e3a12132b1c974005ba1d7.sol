

pragma solidity ^0.4.11;

contract LoggingErrors {

  event LogErrorString(string errorString);


  function error(string _errorMessage) internal returns(bool) {

    emit LogErrorString(_errorMessage);
    return false;
  }
}


pragma solidity ^0.4.15;


contract WalletConnector is LoggingErrors {

  address public owner_;
  address public latestLogic_;
  uint256 public latestVersion_;
  mapping(uint256 => address) public logicVersions_;
  uint256 public birthBlock_;

  event LogLogicVersionAdded(uint256 version);
  event LogLogicVersionRemoved(uint256 version);

  function WalletConnector (
    uint256 _latestVersion,
    address _latestLogic
  ) public {
    owner_ = msg.sender;
    latestLogic_ = _latestLogic;
    latestVersion_ = _latestVersion;
    logicVersions_[_latestVersion] = _latestLogic;
    birthBlock_ = block.number;
  }

  function addLogicVersion (
    uint256 _version,
    address _logic
  ) external
    returns(bool)
  {
    if (msg.sender != owner_)
      return error('msg.sender != owner, WalletConnector.addLogicVersion()');

    if (logicVersions_[_version] != 0)
      return error('Version already exists, WalletConnector.addLogicVersion()');

    if (_version > latestVersion_) {
      latestLogic_ = _logic;
      latestVersion_ = _version;
    }

    logicVersions_[_version] = _logic;
    LogLogicVersionAdded(_version);

    return true;
  }

  function removeLogicVersion(uint256 _version) external {

    require(msg.sender == owner_);
    require(_version != latestVersion_);
    delete logicVersions_[_version];
    LogLogicVersionRemoved(_version);
  }


  function getLogic(uint256 _version)
    external
    constant
    returns(address)
  {

    if (_version == 0)
      return latestLogic_;
    else
      return logicVersions_[_version];
  }
}


pragma solidity ^0.4.15;



interface WalletBuilderInterface {


  function buildWallet(address _owner, address _exchange) external returns(address);

}


pragma solidity ^0.4.11;

interface Token {

  function totalSupply() external constant returns (uint256 supply);


  function balanceOf(address _owner) external constant returns (uint256 balance);


  function transfer(address _to, uint256 _value) external returns (bool success);


  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);


  function approve(address _spender, uint256 _value) external returns (bool success);


  function allowance(address _owner, address _spender) external constant returns (uint256 remaining);


  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function decimals() external constant returns(uint);

  function name() external constant returns(string);

}


pragma solidity ^0.4.15;




contract WalletV3 is LoggingErrors {

  address public owner_;
  address public exchange_;
  mapping(address => uint256) public tokenBalances_;

  address public logic_; // storage location 0x3 loaded for delegatecalls so this var must remain at index 3
  uint256 public birthBlock_;

  WalletConnector private connector_;

  event LogDeposit(address token, uint256 amount, uint256 balance);
  event LogWithdrawal(address token, uint256 amount, uint256 balance);

  constructor(address _owner, address _connector, address _exchange) public {
    owner_ = _owner;
    connector_ = WalletConnector(_connector);
    exchange_ = _exchange;
    logic_ = connector_.latestLogic_();
    birthBlock_ = block.number;
  }

  function () external payable {}


  function depositEther()
    external
    payable
  {

    require(
      logic_.delegatecall(abi.encodeWithSignature('deposit(address,uint256)', 0, msg.value)),
      "depositEther() failed"
    );
  }

  function depositERC20Token (
    address _token,
    uint256 _amount
  ) external
    returns(bool)
  {
    if (_token == 0)
      return error('Cannot deposit ether via depositERC20, Wallet.depositERC20Token()');

    require(
      logic_.delegatecall(abi.encodeWithSignature('deposit(address,uint256)', _token, _amount)),
      "depositERC20Token() failed"
    );
    return true;
  }

  function updateBalance (
    address /*_token*/,
    uint256 /*_amount*/,
    bool /*_subtractionFlag*/
  ) external
    returns(bool)
  {
    assembly {
      calldatacopy(0x40, 0, calldatasize)
      delegatecall(gas, sload(0x3), 0x40, calldatasize, 0, 32)
      return(0, 32)
      pop
    }
  }

  function updateExchange(address _exchange)
    external
    returns(bool)
  {

    if (msg.sender != owner_)
      return error('msg.sender != owner_, Wallet.updateExchange()');

    exchange_ = _exchange;

    return true;
  }

  function updateLogic(uint256 _version)
    external
    returns(bool)
  {

    if (msg.sender != owner_)
      return error('msg.sender != owner_, Wallet.updateLogic()');

    address newVersion = connector_.getLogic(_version);

    if (newVersion == 0)
      return error('Invalid version, Wallet.updateLogic()');

    logic_ = newVersion;
    return true;
  }

  function verifyOrder (
    address /*_token*/,
    uint256 /*_amount*/,
    uint256 /*_fee*/,
    address /*_feeToken*/
  ) external
    returns(bool)
  {
    assembly {
      calldatacopy(0x40, 0, calldatasize)
      delegatecall(gas, sload(0x3), 0x40, calldatasize, 0, 32)
      return(0, 32)
      pop
    }
  }

  function withdraw(address /*_token*/, uint256 /*_amount*/)
    external
    returns(bool)
  {

    if(msg.sender != owner_)
      return error('msg.sender != owner, Wallet.withdraw()');

    assembly {
      calldatacopy(0x40, 0, calldatasize)
      delegatecall(gas, sload(0x3), 0x40, calldatasize, 0, 32)
      return(0, 32)
      pop
    }
  }


  function balanceOf(address _token)
    public
    view
    returns(uint)
  {

    if (_token == address(0)) {
      return address(this).balance;
    } else {
      return Token(_token).balanceOf(this);
    }
  }

  function walletVersion() external pure returns(uint){

    return 3;
  }
}


pragma solidity ^0.4.24;

contract Ownable {

  address public owner;

  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "msg.sender != owner");
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0), "newOwner == 0");
    owner = newOwner;
  }

}


pragma solidity ^0.4.11;


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


pragma solidity ^0.4.24;







interface RetrieveWalletInterface {

  function retrieveWallet(address userAccount) external returns(address walletAddress);

}

contract UsersManager is Ownable, RetrieveWalletInterface {

  mapping(address => address) public userAccountToWallet_; // User EOA to wallet addresses
  WalletBuilderInterface public walletBuilder;
  RetrieveWalletInterface public previousMapping;

  event LogUserAdded(address indexed user, address walletAddress);
  event LogWalletUpgraded(address indexed user, address oldWalletAddress, address newWalletAddress);
  event LogWalletBuilderChanged(address newWalletBuilder);

  constructor (
    address _previousMappingAddress,
    address _walletBuilder
  ) public {
    require(_walletBuilder != address (0), "WalletConnector address == 0");
    previousMapping = RetrieveWalletInterface(_previousMappingAddress);
    walletBuilder = WalletBuilderInterface(_walletBuilder);
  }


  function retrieveWallet(address userAccount)
    public
    returns(address walletAddress)
  {

    walletAddress = userAccountToWallet_[userAccount];
    if (walletAddress == address(0) && address(previousMapping) != address(0)) {
      walletAddress = previousMapping.retrieveWallet(userAccount);

      if (walletAddress != address(0)) {
        userAccountToWallet_[userAccount] = walletAddress;
      }
    }
  }

  function __addNewUser(address userExternalOwnedAccount, address exchangeAddress)
    private
    returns (address)
  {

    address userTradingWallet = walletBuilder.buildWallet(userExternalOwnedAccount, exchangeAddress);
    userAccountToWallet_[userExternalOwnedAccount] = userTradingWallet;
    emit LogUserAdded(userExternalOwnedAccount, userTradingWallet);
    return userTradingWallet;
  }

  function addNewUser(address userExternalOwnedAccount)
    public
    returns (bool)
  {

    require (
      retrieveWallet(userExternalOwnedAccount) == address(0),
      "User already exists, Exchange.addNewUser()"
    );

    __addNewUser(userExternalOwnedAccount, msg.sender);
    return true;
  }

  function upgradeWallet() external
  {

    address oldWallet = retrieveWallet(msg.sender);
    require(
      oldWallet != address(0),
      "User does not exists yet, Exchange.upgradeWallet()"
    );
    address exchange = WalletV3(oldWallet).exchange_();
    address userTradingWallet = __addNewUser(msg.sender, exchange);
    emit LogWalletUpgraded(msg.sender, oldWallet, userTradingWallet);
  }

  function adminSetWallet(address userExternalOwnedAccount, address userTradingWallet)
    onlyOwner
    external
  {

    address oldWallet = retrieveWallet(userExternalOwnedAccount);
    userAccountToWallet_[userExternalOwnedAccount] = userTradingWallet;
    emit LogUserAdded(userExternalOwnedAccount, userTradingWallet);
    if (oldWallet != address(0)) {
      emit LogWalletUpgraded(userExternalOwnedAccount, oldWallet, userTradingWallet);
    }
  }

  function setWalletBuilder(address newWalletBuilder)
    public
    onlyOwner
    returns (bool)
  {

    require(newWalletBuilder != address(0), "setWalletBuilder(): newWalletBuilder == 0");
    walletBuilder = WalletBuilderInterface(newWalletBuilder);
    emit LogWalletBuilderChanged(walletBuilder);
    return true;
  }
}