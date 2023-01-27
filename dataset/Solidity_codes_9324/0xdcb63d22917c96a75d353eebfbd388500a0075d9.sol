


pragma solidity ^0.4.24;


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


pragma solidity >=0.4.24 <0.6.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.4.24;


contract IPropertyToken is IERC20 {

    function canTransfer(address _to, uint256 _value, bytes) external view returns (byte, bytes32);

    function canTransferFrom(address _from, address _to, uint256 _value, bytes) external view returns (byte, bytes32);


    function dividendToken() public view returns (address);

    function dividendPerToken() public view returns (uint);

    function dividendBalanceOf(address account) public view returns (uint);

    function deposit(uint amount) public;

    function depositPartial(uint amount) public;

    function withdraw() public;

    function changeDividendToken(address newToken) public;

    function recoverDividend(address user) public;


    function getDocument(bytes32 _name) external view returns (string, bytes32, uint256);

    function setDocument(bytes32 _name, string _uri, bytes32 _documentHash) external;

    function removeDocument(bytes32 _name) external;

    function getAllDocuments() external view returns (bytes32[]);


    function getMetadata(bytes32 name) external view returns (string);

    function setMetadata(bytes32 name, string value) external;

    function getAllMetadata() external view returns (bytes32[]);

}


pragma solidity ^0.4.24;

contract ProxyAddress {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

      require(msg.sender == owner, "Must be called by owner or manager");
      _;
    }

    function executeCall(address to, uint256 value, bytes memory data) public onlyOwner returns (bool success) {

        assembly {
            success := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }
}


pragma solidity ^0.4.24;


contract Ownable is Initializable {

  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  function initialize(address sender) public initializer {

    _owner = sender;
  }

  function owner() public view returns(address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.4.24;


contract SlaveProxy {


  bytes32 private constant MANAGER_SLOT = 0x7a55c4d64d3f68c3935ebba18bdf734d8a1d1d068c865f9e08eab9d3a6da73b4;

  constructor(address manager, bytes data) public {
    assert(MANAGER_SLOT == keccak256("minuteman-wallet-manager"));
    setManager(manager);

    if(data.length > 0) {
      require(_implementation().delegatecall(data));
    }
  }

  function _implementation() internal view returns (address) {

    return WalletManager(managerAddress()).getImplementation();
  }

  function setManager(address manager) internal {

    bytes32 slot = MANAGER_SLOT;
    assembly {
      sstore(slot, manager)
    }
  }

  function managerAddress() internal view returns(address manager) {

    bytes32 slot = MANAGER_SLOT;
    assembly {
      manager := sload(slot)
    }
  }

  function () payable external {
    _fallback();
  }

  function _delegate(address implementation) internal {

    assembly {
      calldatacopy(0, 0, calldatasize)

      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      returndatacopy(0, 0, returndatasize)

      switch result
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  function _fallback() internal {

    _delegate(_implementation());
  }
}


pragma solidity ^0.4.24;




contract WalletManager is Initializable, Ownable {


  mapping(address => address) public walletsByUser;
  address private implementation;

  event UserWalletCreated(address user, address walletAddress);
  event ImplementationChanged(address implementation);

  function initialize(address _implementation) initializer public {

    Ownable.initialize(msg.sender);
    implementation = _implementation;
    emit ImplementationChanged(implementation);
  }

  function getImplementation() external view returns (address) {

    return implementation;
  }

  function setImplementation(address newImplementation) external onlyOwner {

    implementation = newImplementation;
    emit ImplementationChanged(implementation);
  }

  function createWallet(address owner) public returns (address) {

    require(owner == address(0x0) || walletsByUser[owner] == address(0x0), "Address already has existing wallet");

    bytes memory data = abi.encodeWithSignature("initialize(address,address)", address(this), owner);
    address proxy = new SlaveProxy(address(this), data);

    if (owner != address(0x0)) {
      walletsByUser[owner] = proxy;
    }
    emit UserWalletCreated(owner, proxy);
    return proxy;
  }

  function changeOwner(address oldOwner, address newOwner) public {

    require(oldOwner == address(0) || msg.sender == walletsByUser[oldOwner]);
    walletsByUser[oldOwner] = address(0);
    walletsByUser[newOwner] = msg.sender;
  }
}


pragma solidity ^0.4.24;







contract UserWallet is Initializable {


  uint256 constant UINT256_MAX = ~uint256(0);

  WalletManager public walletManager;
  address public owner;

  event OwnershipChanged(address newOwner);
  event NewForwardingAddress(address forwardingAddress, address tokenAddress, bytes data);

  function initialize(address _manager, address _owner) initializer public {

    walletManager = WalletManager(_manager);
    owner = _owner;
  }

  modifier onlyOwnerAndManager() {

    require(msg.sender == owner || msg.sender == walletManager.owner(), "Must be called by owner or manager");
    _;
  }

  function setOwner(address newOwner) public onlyOwnerAndManager {

    walletManager.changeOwner(owner, newOwner);
    owner = newOwner;
    emit OwnershipChanged(newOwner);
  }

  function getBalance(address token) public view returns (uint) {

    return IERC20(token).balanceOf(address(this));
  }

  function transfer(address token, address recipient, uint value) public onlyOwnerAndManager returns (bool) {

    return IERC20(token).transfer(recipient, value);
  }

  function approve(address token, address spender, uint256 value) public onlyOwnerAndManager returns (bool) {

    return IERC20(token).approve(spender, value);
  }

  function transferFrom(address token, address from, address to, uint256 value) public onlyOwnerAndManager returns (bool) {

    return IERC20(token).transferFrom(from, to, value);
  }

  function createForwardingAddress(address tokenAddress, bytes data) public onlyOwnerAndManager {

    ProxyAddress newAddress = new ProxyAddress();
    bytes memory setAllowance = abi.encodeWithSignature("approve(address,uint256)", address(this), UINT256_MAX);
    newAddress.executeCall(tokenAddress, 0, setAllowance);
    emit NewForwardingAddress(newAddress, tokenAddress, data);
  }

  function distributeDividends(address forwardingAddress, address dividendToken, address propertyToken, uint8 mode) public onlyOwnerAndManager {

    require(mode < 2);
    uint numTokens = IERC20(dividendToken).balanceOf(forwardingAddress);
    require(numTokens > 0);

    IERC20(dividendToken).transferFrom(forwardingAddress, address(this), numTokens);
    IERC20(dividendToken).approve(propertyToken, numTokens);
    if (mode == 0) {
      IPropertyToken(propertyToken).deposit(numTokens);
    }
    if (mode == 1) {
      IPropertyToken(propertyToken).depositPartial(numTokens);
    }
  }

  function withdrawAndTransfer(address[] contracts, address recipient) external onlyOwnerAndManager {

    address tokenAddress;
    for (uint i = 0; i < contracts.length; i++) {
      if (i == 0) {
        tokenAddress = IPropertyToken(contracts[i]).dividendToken();
      } else {
        require(tokenAddress == IPropertyToken(contracts[i]).dividendToken());
      }
      if (IPropertyToken(contracts[i]).dividendBalanceOf(this) > 0) {
        IPropertyToken(contracts[i]).withdraw();
      }
    }
    IERC20(tokenAddress).transfer(recipient, IERC20(tokenAddress).balanceOf(this));
  }
}