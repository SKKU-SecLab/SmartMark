
pragma solidity ^0.5.0;

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

        require(b > 0);
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

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
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
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract ERC1820Registry {

    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;

    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address);

    function setManager(address _addr, address _newManager) external;

    function getManager(address _addr) public view returns (address);

}


contract ERC1820Client {

    ERC1820Registry constant ERC1820REGISTRY = ERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    function setInterfaceImplementation(string memory _interfaceLabel, address _implementation) internal {

        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        ERC1820REGISTRY.setInterfaceImplementer(address(this), interfaceHash, _implementation);
    }

    function interfaceAddr(address addr, string memory _interfaceLabel) internal view returns(address) {

        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        return ERC1820REGISTRY.getInterfaceImplementer(addr, interfaceHash);
    }

    function delegateManagement(address _newManager) internal {

        ERC1820REGISTRY.setManager(address(this), _newManager);
    }
}




contract ERC1820Implementer {

  bytes32 constant ERC1820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC1820_ACCEPT_MAGIC"));

  mapping(bytes32 => bool) internal _interfaceHashes;

  function canImplementInterfaceForAddress(bytes32 interfaceHash, address /*addr*/) // Comments to avoid compilation warnings for unused variables.
    external
    view
    returns(bytes32)
  {

    if(_interfaceHashes[interfaceHash]) {
      return ERC1820_ACCEPT_MAGIC;
    } else {
      return "";
    }
  }

  function _setInterface(string memory interfaceLabel) internal {

    _interfaceHashes[keccak256(abi.encodePacked(interfaceLabel))] = true;
  }

}



interface IERC1400 /*is IERC20*/ { // Interfaces can currently not inherit interfaces, but IERC1400 shall include IERC20


  function getDocument(bytes32 name) external view returns (string memory, bytes32);

  function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external;


  function balanceOfByPartition(bytes32 partition, address tokenHolder) external view returns (uint256);

  function partitionsOf(address tokenHolder) external view returns (bytes32[] memory);


  function transferWithData(address to, uint256 value, bytes calldata data) external;

  function transferFromWithData(address from, address to, uint256 value, bytes calldata data) external;


  function transferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data) external returns (bytes32);

  function operatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData) external returns (bytes32);


  function isControllable() external view returns (bool);


  function authorizeOperator(address operator) external;

  function revokeOperator(address operator) external;

  function authorizeOperatorByPartition(bytes32 partition, address operator) external;

  function revokeOperatorByPartition(bytes32 partition, address operator) external;


  function isOperator(address operator, address tokenHolder) external view returns (bool);

  function isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) external view returns (bool);


  function isIssuable() external view returns (bool);

  function issue(address tokenHolder, uint256 value, bytes calldata data) external;

  function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data) external;


  function redeem(uint256 value, bytes calldata data) external;

  function redeemFrom(address tokenHolder, uint256 value, bytes calldata data) external;

  function redeemByPartition(bytes32 partition, uint256 value, bytes calldata data) external;

  function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata operatorData) external;




  event Document(bytes32 indexed name, string uri, bytes32 documentHash);

  event TransferByPartition(
      bytes32 indexed fromPartition,
      address operator,
      address indexed from,
      address indexed to,
      uint256 value,
      bytes data,
      bytes operatorData
  );

  event ChangedPartition(
      bytes32 indexed fromPartition,
      bytes32 indexed toPartition,
      uint256 value
  );

  event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
  event RevokedOperator(address indexed operator, address indexed tokenHolder);
  event AuthorizedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);
  event RevokedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);

  event Issued(address indexed operator, address indexed to, uint256 value, bytes data);
  event Redeemed(address indexed operator, address indexed from, uint256 value, bytes data);
  event IssuedByPartition(bytes32 indexed partition, address indexed operator, address indexed to, uint256 value, bytes data, bytes operatorData);
  event RedeemedByPartition(bytes32 indexed partition, address indexed operator, address indexed from, uint256 value, bytes operatorData);

}




interface IERC1400TokensValidator {


  function canValidate(
    address token,
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);


  function tokensToValidate(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;


}



interface IERC1400TokensChecker {



  function canTransferByPartition(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes calldata data,
    bytes calldata operatorData
    ) external view returns (byte, bytes32, bytes32);


}



interface IERC1400TokensSender {


  function canTransfer(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);


  function tokensToTransfer(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;


}



interface IERC1400TokensRecipient {


  function canReceive(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);


  function tokensReceived(
    bytes4 functionSig,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;


}



















contract ERC1400 is IERC20, IERC1400, Ownable, ERC1820Client, ERC1820Implementer, MinterRole {

  using SafeMath for uint256;

  string constant internal ERC1400_INTERFACE_NAME = "ERC1400Token";
  string constant internal ERC20_INTERFACE_NAME = "ERC20Token";

  string constant internal ERC1400_TOKENS_CHECKER = "ERC1400TokensChecker";
  string constant internal ERC1400_TOKENS_VALIDATOR = "ERC1400TokensValidator";

  string constant internal ERC1400_TOKENS_SENDER = "ERC1400TokensSender";
  string constant internal ERC1400_TOKENS_RECIPIENT = "ERC1400TokensRecipient";

  string internal _name;
  string internal _symbol;
  uint256 internal _granularity;
  uint256 internal _totalSupply;
  bool internal _migrated;


  bool internal _isControllable;

  bool internal _isIssuable;


  mapping(address => uint256) internal _balances;

  mapping (address => mapping (address => uint256)) internal _allowed;


  struct Doc {
    string docURI;
    bytes32 docHash;
  }
  mapping(bytes32 => Doc) internal _documents;


  bytes32[] internal _totalPartitions;

  mapping (bytes32 => uint256) internal _indexOfTotalPartitions;

  mapping (bytes32 => uint256) internal _totalSupplyByPartition;

  mapping (address => bytes32[]) internal _partitionsOf;

  mapping (address => mapping (bytes32 => uint256)) internal _indexOfPartitionsOf;

  mapping (address => mapping (bytes32 => uint256)) internal _balanceOfByPartition;

  bytes32[] internal _defaultPartitions;


  mapping(address => mapping(address => bool)) internal _authorizedOperator;

  address[] internal _controllers;

  mapping(address => bool) internal _isController;


  mapping(bytes32 => mapping (address => mapping (address => uint256))) internal _allowedByPartition;

  mapping (address => mapping (bytes32 => mapping (address => bool))) internal _authorizedOperatorByPartition;

  mapping (bytes32 => address[]) internal _controllersByPartition;

  mapping (bytes32 => mapping (address => bool)) internal _isControllerByPartition;


  modifier isIssuableToken() {

    require(_isIssuable, "55"); // 0x55	funds locked (lockup period)
    _;
  }
  modifier isNotMigratedToken() {

      require(!_migrated, "54"); // 0x54	transfers halted (contract paused)
      _;
  }


  event ApprovalByPartition(bytes32 indexed partition, address indexed owner, address indexed spender, uint256 value);


  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    bytes32[] memory defaultPartitions
  )
    public
  {
    _name = name;
    _symbol = symbol;
    _totalSupply = 0;
    require(granularity >= 1); // Constructor Blocked - Token granularity can not be lower than 1
    _granularity = granularity;

    _setControllers(controllers);

    _defaultPartitions = defaultPartitions;

    _isControllable = true;
    _isIssuable = true;

    ERC1820Client.setInterfaceImplementation(ERC1400_INTERFACE_NAME, address(this));
    ERC1820Client.setInterfaceImplementation(ERC20_INTERFACE_NAME, address(this));

    ERC1820Implementer._setInterface(ERC1400_INTERFACE_NAME); // For migration
    ERC1820Implementer._setInterface(ERC20_INTERFACE_NAME); // For migration
  }




  function totalSupply() external view returns (uint256) {

    return _totalSupply;
  }
  function balanceOf(address tokenHolder) external view returns (uint256) {

    return _balances[tokenHolder];
  }
  function transfer(address to, uint256 value) external returns (bool) {

    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, "");
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {

    return _allowed[owner][spender];
  }
  function approve(address spender, uint256 value) external returns (bool) {

    require(spender != address(0), "56"); // 0x56	invalid sender
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
  function transferFrom(address from, address to, uint256 value) external returns (bool) {

    require( _isOperator(msg.sender, from)
      || (value <= _allowed[from][msg.sender]), "53"); // 0x53	insufficient allowance

    if(_allowed[from][msg.sender] >= value) {
      _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    } else {
      _allowed[from][msg.sender] = 0;
    }

    _transferByDefaultPartitions(msg.sender, from, to, value, "");
    return true;
  }




  function getDocument(bytes32 name) external view returns (string memory, bytes32) {

    require(bytes(_documents[name].docURI).length != 0); // Action Blocked - Empty document
    return (
      _documents[name].docURI,
      _documents[name].docHash
    );
  }
  function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external {

    require(_isController[msg.sender]);
    _documents[name] = Doc({
      docURI: uri,
      docHash: documentHash
    });
    emit Document(name, uri, documentHash);
  }


  function balanceOfByPartition(bytes32 partition, address tokenHolder) external view returns (uint256) {

    return _balanceOfByPartition[tokenHolder][partition];
  }
  function partitionsOf(address tokenHolder) external view returns (bytes32[] memory) {

    return _partitionsOf[tokenHolder];
  }


  function transferWithData(address to, uint256 value, bytes calldata data) external {

    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, data);
  }
  function transferFromWithData(address from, address to, uint256 value, bytes calldata data) external {

    require(_isOperator(msg.sender, from), "58"); // 0x58	invalid operator (transfer agent)

    _transferByDefaultPartitions(msg.sender, from, to, value, data);
  }


  function transferByPartition(
    bytes32 partition,
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (bytes32)
  {

    return _transferByPartition(partition, msg.sender, msg.sender, to, value, data, "");
  }
  function operatorTransferByPartition(
    bytes32 partition,
    address from,
    address to,
    uint256 value,
    bytes calldata data,
    bytes calldata operatorData
  )
    external
    returns (bytes32)
  {

    require(_isOperatorForPartition(partition, msg.sender, from)
      || (value <= _allowedByPartition[partition][from][msg.sender]), "53"); // 0x53	insufficient allowance

    if(_allowedByPartition[partition][from][msg.sender] >= value) {
      _allowedByPartition[partition][from][msg.sender] = _allowedByPartition[partition][from][msg.sender].sub(value);
    } else {
      _allowedByPartition[partition][from][msg.sender] = 0;
    }

    return _transferByPartition(partition, msg.sender, from, to, value, data, operatorData);
  }


  function isControllable() external view returns (bool) {

    return _isControllable;
  }


  function authorizeOperator(address operator) external {

    require(operator != msg.sender);
    _authorizedOperator[operator][msg.sender] = true;
    emit AuthorizedOperator(operator, msg.sender);
  }
  function revokeOperator(address operator) external {

    require(operator != msg.sender);
    _authorizedOperator[operator][msg.sender] = false;
    emit RevokedOperator(operator, msg.sender);
  }
  function authorizeOperatorByPartition(bytes32 partition, address operator) external {

    _authorizedOperatorByPartition[msg.sender][partition][operator] = true;
    emit AuthorizedOperatorByPartition(partition, operator, msg.sender);
  }
  function revokeOperatorByPartition(bytes32 partition, address operator) external {

    _authorizedOperatorByPartition[msg.sender][partition][operator] = false;
    emit RevokedOperatorByPartition(partition, operator, msg.sender);
  }


  function isOperator(address operator, address tokenHolder) external view returns (bool) {

    return _isOperator(operator, tokenHolder);
  }
  function isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) external view returns (bool) {

    return _isOperatorForPartition(partition, operator, tokenHolder);
  }


  function isIssuable() external view returns (bool) {

    return _isIssuable;
  }
  function issue(address tokenHolder, uint256 value, bytes calldata data)
    external
    onlyMinter
    isIssuableToken
  {

    require(_defaultPartitions.length != 0, "55"); // 0x55	funds locked (lockup period)

    _issueByPartition(_defaultPartitions[0], msg.sender, tokenHolder, value, data);
  }
  function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data)
    external
    onlyMinter
    isIssuableToken
  {

    _issueByPartition(partition, msg.sender, tokenHolder, value, data);
  }
  

  function redeem(uint256 value, bytes calldata data)
    external
  {

    _redeemByDefaultPartitions(msg.sender, msg.sender, value, data);
  }
  function redeemFrom(address from, uint256 value, bytes calldata data)
    external
  {

    require(_isOperator(msg.sender, from), "58"); // 0x58	invalid operator (transfer agent)

    _redeemByDefaultPartitions(msg.sender, from, value, data);
  }
  function redeemByPartition(bytes32 partition, uint256 value, bytes calldata data)
    external
  {

    _redeemByPartition(partition, msg.sender, msg.sender, value, data, "");
  }
  function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata operatorData)
    external
  {

    require(_isOperatorForPartition(partition, msg.sender, tokenHolder), "58"); // 0x58	invalid operator (transfer agent)

    _redeemByPartition(partition, msg.sender, tokenHolder, value, "", operatorData);
  }




  function name() external view returns(string memory) {

    return _name;
  }
  function symbol() external view returns(string memory) {

    return _symbol;
  }
  function decimals() external pure returns(uint8) {

    return uint8(18);
  }
  function granularity() external view returns(uint256) {

    return _granularity;
  }
  function totalPartitions() external view returns (bytes32[] memory) {

    return _totalPartitions;
  }
  function totalSupplyByPartition(bytes32 partition) external view returns (uint256) {

    return _totalSupplyByPartition[partition];
  }


  function renounceControl() external onlyOwner {

    _isControllable = false;
  }
  function renounceIssuance() external onlyOwner {

    _isIssuable = false;
  }


  function controllers() external view returns (address[] memory) {

    return _controllers;
  }
  function controllersByPartition(bytes32 partition) external view returns (address[] memory) {

    return _controllersByPartition[partition];
  }
  function setControllers(address[] calldata operators) external onlyOwner {

    _setControllers(operators);
  }
   function setPartitionControllers(bytes32 partition, address[] calldata operators) external onlyOwner {

     _setPartitionControllers(partition, operators);
   }


  function getDefaultPartitions() external view returns (bytes32[] memory) {

    return _defaultPartitions;
  }
  function setDefaultPartitions(bytes32[] calldata partitions) external onlyOwner {

    _defaultPartitions = partitions;
  }


  function allowanceByPartition(bytes32 partition, address owner, address spender) external view returns (uint256) {

    return _allowedByPartition[partition][owner][spender];
  }
  function approveByPartition(bytes32 partition, address spender, uint256 value) external returns (bool) {

    require(spender != address(0), "56"); // 0x56	invalid sender
    _allowedByPartition[partition][msg.sender][spender] = value;
    emit ApprovalByPartition(partition, msg.sender, spender, value);
    return true;
  }

  
  function setHookContract(address validatorAddress, string calldata interfaceLabel) external onlyOwner {

    _setHookContract(validatorAddress, interfaceLabel);
  }

  function migrate(address newContractAddress, bool definitive) external onlyOwner {

    _migrate(newContractAddress, definitive);
  }




  function _transferWithData(
    address from,
    address to,
    uint256 value
  )
    internal
    isNotMigratedToken
  {

    require(_isMultiple(value), "50"); // 0x50	transfer failure
    require(to != address(0), "57"); // 0x57	invalid receiver
    require(_balances[from] >= value, "52"); // 0x52	insufficient balance
  
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);

    emit Transfer(from, to, value); // ERC20 retrocompatibility 
  }
  function _transferByPartition(
    bytes32 fromPartition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
    returns (bytes32)
  {

    require(_balanceOfByPartition[from][fromPartition] >= value, "52"); // 0x52	insufficient balance

    bytes32 toPartition = fromPartition;

    if(operatorData.length != 0 && data.length >= 64) {
      toPartition = _getDestinationPartition(fromPartition, data);
    }

    _callPreTransferHooks(fromPartition, operator, from, to, value, data, operatorData);

    _removeTokenFromPartition(from, fromPartition, value);
    _transferWithData(from, to, value);
    _addTokenToPartition(to, toPartition, value);

    _callPostTransferHooks(toPartition, operator, from, to, value, data, operatorData);

    emit TransferByPartition(fromPartition, operator, from, to, value, data, operatorData);

    if(toPartition != fromPartition) {
      emit ChangedPartition(fromPartition, toPartition, value);
    }

    return toPartition;
  }
  function _transferByDefaultPartitions(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data
  )
    internal
  {

    require(_defaultPartitions.length != 0, "55"); // // 0x55	funds locked (lockup period)

    uint256 _remainingValue = value;
    uint256 _localBalance;

    for (uint i = 0; i < _defaultPartitions.length; i++) {
      _localBalance = _balanceOfByPartition[from][_defaultPartitions[i]];
      if(_remainingValue <= _localBalance) {
        _transferByPartition(_defaultPartitions[i], operator, from, to, _remainingValue, data, "");
        _remainingValue = 0;
        break;
      } else if (_localBalance != 0) {
        _transferByPartition(_defaultPartitions[i], operator, from, to, _localBalance, data, "");
        _remainingValue = _remainingValue - _localBalance;
      }
    }

    require(_remainingValue == 0, "52"); // 0x52	insufficient balance
  }
  function _getDestinationPartition(bytes32 fromPartition, bytes memory data) internal pure returns(bytes32 toPartition) {

    bytes32 changePartitionFlag = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    bytes32 flag;
    assembly {
      flag := mload(add(data, 32))
    }
    if(flag == changePartitionFlag) {
      assembly {
        toPartition := mload(add(data, 64))
      }
    } else {
      toPartition = fromPartition;
    }
  }
  function _removeTokenFromPartition(address from, bytes32 partition, uint256 value) internal {

    _balanceOfByPartition[from][partition] = _balanceOfByPartition[from][partition].sub(value);
    _totalSupplyByPartition[partition] = _totalSupplyByPartition[partition].sub(value);

    if(_totalSupplyByPartition[partition] == 0) {
      uint256 index1 = _indexOfTotalPartitions[partition];
      require(index1 > 0, "50"); // 0x50	transfer failure

      bytes32 lastValue = _totalPartitions[_totalPartitions.length - 1];
      _totalPartitions[index1 - 1] = lastValue; // adjust for 1-based indexing
      _indexOfTotalPartitions[lastValue] = index1;

      _totalPartitions.length -= 1;
      _indexOfTotalPartitions[partition] = 0;
    }

    if(_balanceOfByPartition[from][partition] == 0) {
      uint256 index2 = _indexOfPartitionsOf[from][partition];
      require(index2 > 0, "50"); // 0x50	transfer failure

      bytes32 lastValue = _partitionsOf[from][_partitionsOf[from].length - 1];
      _partitionsOf[from][index2 - 1] = lastValue;  // adjust for 1-based indexing
      _indexOfPartitionsOf[from][lastValue] = index2;

      _partitionsOf[from].length -= 1;
      _indexOfPartitionsOf[from][partition] = 0;
    }
  }
  function _addTokenToPartition(address to, bytes32 partition, uint256 value) internal {

    if(value != 0) {
      if (_indexOfPartitionsOf[to][partition] == 0) {
        _partitionsOf[to].push(partition);
        _indexOfPartitionsOf[to][partition] = _partitionsOf[to].length;
      }
      _balanceOfByPartition[to][partition] = _balanceOfByPartition[to][partition].add(value);

      if (_indexOfTotalPartitions[partition] == 0) {
        _totalPartitions.push(partition);
        _indexOfTotalPartitions[partition] = _totalPartitions.length;
      }
      _totalSupplyByPartition[partition] = _totalSupplyByPartition[partition].add(value);
    }
  }
  function _isMultiple(uint256 value) internal view returns(bool) {

    return(value.div(_granularity).mul(_granularity) == value);
  }


  function _callPreTransferHooks(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
  {

    address senderImplementation;
    senderImplementation = interfaceAddr(from, ERC1400_TOKENS_SENDER);
    if (senderImplementation != address(0)) {
      IERC1400TokensSender(senderImplementation).tokensToTransfer(msg.sig, partition, operator, from, to, value, data, operatorData);
    }

    address validatorImplementation;
    validatorImplementation = interfaceAddr(address(this), ERC1400_TOKENS_VALIDATOR);
    if (validatorImplementation != address(0)) {
      IERC1400TokensValidator(validatorImplementation).tokensToValidate(msg.sig, partition, operator, from, to, value, data, operatorData);
    }
  }
  function _callPostTransferHooks(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
  {

    address recipientImplementation;
    recipientImplementation = interfaceAddr(to, ERC1400_TOKENS_RECIPIENT);

    if (recipientImplementation != address(0)) {
      IERC1400TokensRecipient(recipientImplementation).tokensReceived(msg.sig, partition, operator, from, to, value, data, operatorData);
    }
  }


  function _isOperator(address operator, address tokenHolder) internal view returns (bool) {

    return (operator == tokenHolder
      || _authorizedOperator[operator][tokenHolder]
      || (_isControllable && _isController[operator])
    );
  }
   function _isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) internal view returns (bool) {

     return (_isOperator(operator, tokenHolder)
       || _authorizedOperatorByPartition[tokenHolder][partition][operator]
       || (_isControllable && _isControllerByPartition[partition][operator])
     );
   }


  function _issue(address operator, address to, uint256 value, bytes memory data)
    internal
    isNotMigratedToken  
  {

    require(_isMultiple(value), "50"); // 0x50	transfer failure
    require(to != address(0), "57"); // 0x57	invalid receiver

    _totalSupply = _totalSupply.add(value);
    _balances[to] = _balances[to].add(value);

    emit Issued(operator, to, value, data);
    emit Transfer(address(0), to, value); // ERC20 retrocompatibility
  }
  function _issueByPartition(
    bytes32 toPartition,
    address operator,
    address to,
    uint256 value,
    bytes memory data
  )
    internal
  {

    _issue(operator, to, value, data);
    _addTokenToPartition(to, toPartition, value);

    _callPostTransferHooks(toPartition, operator, address(0), to, value, data, "");

    emit IssuedByPartition(toPartition, operator, to, value, data, "");
  }


  function _redeem(address operator, address from, uint256 value, bytes memory data)
    internal
    isNotMigratedToken
  {

    require(_isMultiple(value), "50"); // 0x50	transfer failure
    require(from != address(0), "56"); // 0x56	invalid sender
    require(_balances[from] >= value, "52"); // 0x52	insufficient balance

    _balances[from] = _balances[from].sub(value);
    _totalSupply = _totalSupply.sub(value);

    emit Redeemed(operator, from, value, data);
    emit Transfer(from, address(0), value);  // ERC20 retrocompatibility
  }
  function _redeemByPartition(
    bytes32 fromPartition,
    address operator,
    address from,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
  {

    require(_balanceOfByPartition[from][fromPartition] >= value, "52"); // 0x52	insufficient balance

    _callPreTransferHooks(fromPartition, operator, from, address(0), value, data, operatorData);

    _removeTokenFromPartition(from, fromPartition, value);
    _redeem(operator, from, value, data);

    emit RedeemedByPartition(fromPartition, operator, from, value, operatorData);
  }
  function _redeemByDefaultPartitions(
    address operator,
    address from,
    uint256 value,
    bytes memory data
  )
    internal
  {

    require(_defaultPartitions.length != 0, "55"); // 0x55	funds locked (lockup period)

    uint256 _remainingValue = value;
    uint256 _localBalance;

    for (uint i = 0; i < _defaultPartitions.length; i++) {
      _localBalance = _balanceOfByPartition[from][_defaultPartitions[i]];
      if(_remainingValue <= _localBalance) {
        _redeemByPartition(_defaultPartitions[i], operator, from, _remainingValue, data, "");
        _remainingValue = 0;
        break;
      } else {
        _redeemByPartition(_defaultPartitions[i], operator, from, _localBalance, data, "");
        _remainingValue = _remainingValue - _localBalance;
      }
    }

    require(_remainingValue == 0, "52"); // 0x52	insufficient balance
  }


  function _canTransfer(bytes4 functionSig, bytes32 partition, address operator, address from, address to, uint256 value, bytes memory data, bytes memory operatorData)
    internal
    view
    returns (byte, bytes32, bytes32)
  {

    address checksImplementation = interfaceAddr(address(this), ERC1400_TOKENS_CHECKER);

    if((checksImplementation != address(0))) {
      return IERC1400TokensChecker(checksImplementation).canTransferByPartition(functionSig, partition, operator, from, to, value, data, operatorData);
    }
    else {
      return(hex"00", "", partition);
    }
  }




  function _setControllers(address[] memory operators) internal {

    for (uint i = 0; i<_controllers.length; i++){
      _isController[_controllers[i]] = false;
    }
    for (uint j = 0; j<operators.length; j++){
      _isController[operators[j]] = true;
    }
    _controllers = operators;
  }
   function _setPartitionControllers(bytes32 partition, address[] memory operators) internal {

     for (uint i = 0; i<_controllersByPartition[partition].length; i++){
       _isControllerByPartition[partition][_controllersByPartition[partition][i]] = false;
     }
     for (uint j = 0; j<operators.length; j++){
       _isControllerByPartition[partition][operators[j]] = true;
     }
     _controllersByPartition[partition] = operators;
   }


  function _setHookContract(address validatorAddress, string memory interfaceLabel) internal {

    address oldValidatorAddress = interfaceAddr(address(this), interfaceLabel);

    if (oldValidatorAddress != address(0)) {
      if(isMinter(oldValidatorAddress)) {
        _removeMinter(oldValidatorAddress);
      }
      _isController[oldValidatorAddress] = false;
    }

    ERC1820Client.setInterfaceImplementation(interfaceLabel, validatorAddress);
    if(!isMinter(validatorAddress)) {
      _addMinter(validatorAddress);
    }
    _isController[validatorAddress] = true;
  }


  function _migrate(address newContractAddress, bool definitive) internal {

    ERC1820Client.setInterfaceImplementation(ERC20_INTERFACE_NAME, newContractAddress);
    ERC1820Client.setInterfaceImplementation(ERC1400_INTERFACE_NAME, newContractAddress);
    if(definitive) {
      _migrated = true;
    }
  }

}




contract CertificateController {


  bool _certificateControllerActivated;

  mapping(address => bool) internal _certificateSigners;


  mapping(bytes32 => bool) internal _usedCertificate;

  event Used(address sender);

  constructor(address _certificateSigner, bool activated) public {
    _setCertificateSigner(_certificateSigner, true);
    _certificateControllerActivated = activated;
  }

  modifier isValidCertificate(bytes memory data) {


    if(_certificateControllerActivated) {
      require(_certificateSigners[msg.sender] || _checkCertificate(data, 0, 0x00000000), "54"); // 0x54	transfers halted (contract paused)

      bytes32 salt;
      assembly {
        salt := mload(add(data, 0x20))
      }

      _usedCertificate[salt] = true; // Use certificate

      emit Used(msg.sender);
    }
    
    _;
  }


  function isUsedCertificate(bytes32 salt) external view returns (bool) {

    return _usedCertificate[salt];
  }

  function _setCertificateSigner(address operator, bool authorized) internal {

    require(operator != address(0)); // Action Blocked - Not a valid address
    _certificateSigners[operator] = authorized;
  }

  function certificateControllerActivated() external view returns (bool) {

    return _certificateControllerActivated;
  }

  function _setCertificateControllerActivated(bool activated) internal {

    _certificateControllerActivated = activated;
  }

  function _checkCertificate(
    bytes memory data,
    uint256 amount,
    bytes4 functionID
  )
    internal
    view
    returns(bool)
  {

    bytes32 salt;
    uint256 e;
    bytes32 r;
    bytes32 s;
    uint8 v;

    if (data.length != 129) {
      return false;
    }

    assembly {
      salt := mload(add(data, 0x20))
      e := mload(add(data, 0x40))
      r := mload(add(data, 0x60))
      s := mload(add(data, 0x80))
      v := byte(0, mload(add(data, 0xa0)))
    }

    if (e < now) {
      return false;
    }

    if (v < 27) {
      v += 27;
    }

    if (v == 27 || v == 28) {
      bytes memory payload;

      assembly {
        let payloadsize := sub(calldatasize, 192)
        payload := mload(0x40) // allocate new memory
        mstore(0x40, add(payload, and(add(add(payloadsize, 0x20), 0x1f), not(0x1f)))) // boolean trick for padding to 0x40
        mstore(payload, payloadsize) // set length
        calldatacopy(add(add(payload, 0x20), 4), 4, sub(payloadsize, 4))
      }

      if(functionID == 0x00000000) {
        assembly {
          calldatacopy(add(payload, 0x20), 0, 4)
        }
      } else {
        for (uint i = 0; i < 4; i++) { // replace 4 bytes corresponding to function selector
          payload[i] = functionID[i];
        }
      }

      bytes memory pack = abi.encodePacked(
        msg.sender,
        this,
        amount,
        payload,
        e,
        salt
      );
      bytes32 hash = keccak256(pack);

      if (_certificateSigners[ecrecover(hash, v, r, s)] && !_usedCertificate[salt]) {
        return true;
      }
    }
    return false;
  }
}






contract ERC1400CertificateSalt is ERC1400, CertificateController {


  constructor(
    string memory name,
    string memory symbol,
    uint256 granularity,
    address[] memory controllers,
    address certificateSigner,
    bool certificateActivated,
    bytes32[] memory defaultPartitions
  )
    public
    ERC1400(name, symbol, granularity, controllers, defaultPartitions)
    CertificateController(certificateSigner, certificateActivated)
  {}


  function setCertificateSigner(address operator, bool authorized) external onlyOwner {

    _setCertificateSigner(operator, authorized);
  }
  function setCertificateControllerActivated(bool activated) external onlyOwner {

   _setCertificateControllerActivated(activated);
  }


  function transferWithData(address to, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {

    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, data);
  }

  function transferFromWithData(address from, address to, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {

    require(_isOperator(msg.sender, from), "58"); // 0x58	invalid operator (transfer agent)

    _transferByDefaultPartitions(msg.sender, from, to, value, data);
  }

  function transferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
    returns (bytes32)
  {

    return _transferByPartition(partition, msg.sender, msg.sender, to, value, data, "");
  }

  function operatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    isValidCertificate(operatorData)
    returns (bytes32)
  {

    require(_isOperatorForPartition(partition, msg.sender, from)
      || (value <= _allowedByPartition[partition][from][msg.sender]), "53"); // 0x53	insufficient allowance

    if(_allowedByPartition[partition][from][msg.sender] >= value) {
      _allowedByPartition[partition][from][msg.sender] = _allowedByPartition[partition][from][msg.sender].sub(value);
    } else {
      _allowedByPartition[partition][from][msg.sender] = 0;
    }

    return _transferByPartition(partition, msg.sender, from, to, value, data, operatorData);
  }

  function issue(address tokenHolder, uint256 value, bytes calldata data)
    external
    onlyMinter
    isIssuableToken
    isValidCertificate(data)
  {

    require(_defaultPartitions.length != 0, "55"); // 0x55	funds locked (lockup period)

    _issueByPartition(_defaultPartitions[0], msg.sender, tokenHolder, value, data);
  }

  function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data)
    external
    onlyMinter
    isIssuableToken
    isValidCertificate(data)
  {

    _issueByPartition(partition, msg.sender, tokenHolder, value, data);
  }

  function redeem(uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {

    _redeemByDefaultPartitions(msg.sender, msg.sender, value, data);
  }

  function redeemFrom(address from, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {

    require(_isOperator(msg.sender, from), "58"); // 0x58	invalid operator (transfer agent)

    _redeemByDefaultPartitions(msg.sender, from, value, data);
  }

  function redeemByPartition(bytes32 partition, uint256 value, bytes calldata data)
    external
    isValidCertificate(data)
  {

    _redeemByPartition(partition, msg.sender, msg.sender, value, data, "");
  }

  function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata operatorData)
    external
    isValidCertificate(operatorData)
  {

    require(_isOperatorForPartition(partition, msg.sender, tokenHolder), "58"); // 0x58	invalid operator (transfer agent)

    _redeemByPartition(partition, msg.sender, tokenHolder, value, "", operatorData);
  }


  function canTransferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data)
    external
    view
    returns (byte, bytes32, bytes32)
  {

    bytes4 functionSig = this.transferByPartition.selector; // 0xf3d490db: 4 first bytes of keccak256(transferByPartition(bytes32,address,uint256,bytes))
    if(!_checkCertificate(data, 0, functionSig)) {
      return(hex"54", "", partition); // 0x54	transfers halted (contract paused)
    } else {
      return ERC1400._canTransfer(functionSig, partition, msg.sender, msg.sender, to, value, data, "");
    }
  }
  function canOperatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData)
    external
    view
    returns (byte, bytes32, bytes32)
  {

    bytes4 functionSig = this.operatorTransferByPartition.selector; // 0x8c0dee9c: 4 first bytes of keccak256(operatorTransferByPartition(bytes32,address,address,uint256,bytes,bytes))
    if(!_checkCertificate(operatorData, 0, functionSig)) {
      return(hex"54", "", partition); // 0x54	transfers halted (contract paused)
    } else {
      return ERC1400._canTransfer(functionSig, partition, msg.sender, from, to, value, data, operatorData);
    }
  }

  function _setHookContract(address validatorAddress, string memory interfaceLabel) internal {

    address oldValidatorAddress = interfaceAddr(address(this), interfaceLabel);
    _setCertificateSigner(oldValidatorAddress, false);
    
    ERC1400._setHookContract(validatorAddress, interfaceLabel);
    _setCertificateSigner(validatorAddress, true);
  }

}