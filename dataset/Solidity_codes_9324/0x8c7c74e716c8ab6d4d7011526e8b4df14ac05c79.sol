
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;


    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}// MIT
pragma solidity ^0.8.0;



contract ERC1820Client {

    IERC1820Registry constant ERC1820REGISTRY = IERC1820Registry(0x5b7aF3FB3f7Fc4a238AFa39d5130B30ed30e0e0C);

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
}// MIT
pragma solidity ^0.8.0;


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

}// MIT
pragma solidity ^0.8.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}// MIT
pragma solidity ^0.8.0;


abstract contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor() {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() virtual {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function removeMinter(address account) public onlyMinter {
        _removeMinter(account);
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
}// MIT
pragma solidity ^0.8.0;


interface IERC1643 {


    function getDocument(bytes32 _name) external view returns (string memory, bytes32, uint256);

    function setDocument(bytes32 _name, string memory _uri, bytes32 _documentHash) external;

    function removeDocument(bytes32 _name) external;

    function getAllDocuments() external view returns (bytes32[] memory);


    event DocumentRemoved(bytes32 indexed name, string uri, bytes32 documentHash);
    event DocumentUpdated(bytes32 indexed name, string uri, bytes32 documentHash);

}// MIT
pragma solidity ^0.8.0;


interface IERC1400 is IERC20, IERC1643 {


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

  
  struct ValidateData {
    address token;
    bytes payload;
    bytes32 partition;
    address operator;
    address from;
    address to;
    uint value;
    bytes data;
    bytes operatorData;
  }

  function canValidate(ValidateData calldata data) external view returns(bool);


  function tokensToValidate(
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;

  
  function canBurn(
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;

  
  function canMint(
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;


}pragma solidity ^0.8.0;

interface IERC1400TokensSender {


  function canTransfer(
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);


  function tokensToTransfer(
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;


}pragma solidity ^0.8.0;

interface IERC1400TokensRecipient {


  function canReceive(
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);


  function tokensReceived(
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external;


}// MIT
pragma solidity ^0.8.0;

abstract contract DomainAware {

    mapping(uint256 => bytes32) private domainSeparators;

    constructor() {
        _updateDomainSeparator();
    }

    function domainName() public virtual view returns (string memory);

    function domainVersion() public virtual view returns (string memory);

    function generateDomainSeparator() public view returns (bytes32) {
        uint256 chainID = _chainID();

        bytes32 domainSeparatorHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(domainName())), // ERC-20 Name
                keccak256(bytes(domainVersion())), // Version
                chainID,
                address(this)
            )
        );

        return domainSeparatorHash;
    }

    function domainSeparator() public returns (bytes32) {
        return _domainSeparator();
    }

    function _updateDomainSeparator() private returns (bytes32) {
        uint256 chainID = _chainID();

        bytes32 newDomainSeparator = generateDomainSeparator();

        domainSeparators[chainID] = newDomainSeparator;

        return newDomainSeparator;
    }

    function _domainSeparator() private returns (bytes32) {
        bytes32 currentDomainSeparator = domainSeparators[_chainID()];

        if (currentDomainSeparator != 0x00) {
            return currentDomainSeparator;
        }

        return _updateDomainSeparator();
    }

    function _chainID() internal view returns (uint256) {
        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        return chainID;
    }
}pragma solidity ^0.8.0;







contract TitanBankToken is IERC20, IERC1400, Ownable, ERC1820Client, ERC1820Implementer, MinterRole, DomainAware {

  using SafeMath for uint256;

  string constant internal ERC1400_INTERFACE_NAME = "TitanBankToken";
  string constant internal ERC20_INTERFACE_NAME = "ERC20Token";

  string constant internal ERC1400_TOKENS_VALIDATOR = "TitanBankValidator";

  string constant internal ERC1400_TOKENS_SENDER = "TitanBankTokensSender";
  string constant internal ERC1400_TOKENS_RECIPIENT = "TitanBankTokensRecipient";

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
    uint256 timestamp;
  }
  mapping(bytes32 => Doc) internal _documents;
  mapping(bytes32 => uint256) internal _indexOfDocHashes;
  bytes32[] internal _docHashes;


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
  modifier onlyMinter() override {

      require(isMinter(msg.sender) || owner() == _msgSender(), "56");
      _;
  }


  event ApprovalByPartition(bytes32 indexed partition, address indexed owner, address indexed spender, uint256 value);


  constructor(
    uint256 granularity,
    address[] memory controllers,
    bytes32[] memory defaultPartitions
  )
    public
  {
    _name = 'TITAN ESTATE BANK TOKEN';
    _symbol = 'TTST';
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




  function totalSupply() external override view returns (uint256) {

    return _totalSupply;
  }
  function balanceOf(address tokenHolder) external override view returns (uint256) {

    return _balances[tokenHolder];
  }
  function transfer(address to, uint256 value) external override returns (bool) {

    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, "");
    return true;
  }
  function allowance(address owner, address spender) external override view returns (uint256) {

    return _allowed[owner][spender];
  }
  function approve(address spender, uint256 value) external override returns (bool) {

    require(spender != address(0), "56"); // 0x56	invalid sender
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
  function transferFrom(address from, address to, uint256 value) external override returns (bool) {

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




  function getDocument(bytes32 name) external override view returns (string memory, bytes32, uint256) {

    require(bytes(_documents[name].docURI).length != 0); // Action Blocked - Empty document
    return (
      _documents[name].docURI,
      _documents[name].docHash,
      _documents[name].timestamp
    );
  }
  function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external override {

    require(_isController[msg.sender]);
    _documents[name] = Doc({
      docURI: uri,
      docHash: documentHash,
      timestamp: block.timestamp
    });

    if (_indexOfDocHashes[documentHash] == 0) {
      _docHashes.push(documentHash);
      _indexOfDocHashes[documentHash] = _docHashes.length;
    }

    emit DocumentUpdated(name, uri, documentHash);
  }

  function removeDocument(bytes32 _name) external override {

    require(_isController[msg.sender], "Unauthorized");
    require(bytes(_documents[_name].docURI).length != 0, "Document doesnt exist"); // Action Blocked - Empty document

    Doc memory data = _documents[_name];

    uint256 index1 = _indexOfDocHashes[data.docHash];
    require(index1 > 0, "Invalid index"); //Indexing starts at 1, 0 is not allowed

    bytes32 lastValue = _docHashes[_docHashes.length - 1];
    _docHashes[index1 - 1] = lastValue; // adjust for 1-based indexing
    _indexOfDocHashes[lastValue] = index1;

    _docHashes.pop();
    _indexOfDocHashes[data.docHash] = 0;

    delete _documents[_name];

    emit DocumentRemoved(_name, data.docURI, data.docHash);
  }

  function getAllDocuments() external override view returns (bytes32[] memory) {

    return _docHashes;
  }


  function balanceOfByPartition(bytes32 partition, address tokenHolder) external override view returns (uint256) {

    return _balanceOfByPartition[tokenHolder][partition];
  }
  function partitionsOf(address tokenHolder) external override view returns (bytes32[] memory) {

    return _partitionsOf[tokenHolder];
  }


  function transferWithData(address to, uint256 value, bytes calldata data) external override {

    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, data);
  }
  function transferFromWithData(address from, address to, uint256 value, bytes calldata data) external override virtual {

    require( _isOperator(msg.sender, from)
      || (value <= _allowed[from][msg.sender]), "53"); // 0x53	insufficient allowance

    if(_allowed[from][msg.sender] >= value) {
      _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    } else {
      _allowed[from][msg.sender] = 0;
    }

    _transferByDefaultPartitions(msg.sender, from, to, value, data);
  }


  function transferByPartition(
    bytes32 partition,
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    override
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
    override
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


  function isControllable() external override view returns (bool) {

    return _isControllable;
  }


  function authorizeOperator(address operator) external override {

    require(operator != msg.sender);
    _authorizedOperator[operator][msg.sender] = true;
    emit AuthorizedOperator(operator, msg.sender);
  }
  function revokeOperator(address operator) external override {

    require(operator != msg.sender);
    _authorizedOperator[operator][msg.sender] = false;
    emit RevokedOperator(operator, msg.sender);
  }
  function authorizeOperatorByPartition(bytes32 partition, address operator) external override {

    _authorizedOperatorByPartition[msg.sender][partition][operator] = true;
    emit AuthorizedOperatorByPartition(partition, operator, msg.sender);
  }
  function revokeOperatorByPartition(bytes32 partition, address operator) external override {

    _authorizedOperatorByPartition[msg.sender][partition][operator] = false;
    emit RevokedOperatorByPartition(partition, operator, msg.sender);
  }


  function isOperator(address operator, address tokenHolder) external override view returns (bool) {

    return _isOperator(operator, tokenHolder);
  }
  function isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) external override view returns (bool) {

    return _isOperatorForPartition(partition, operator, tokenHolder);
  }


  function isIssuable() external override view returns (bool) {

    return _isIssuable;
  }
  function issue(address tokenHolder, uint256 value, bytes calldata data)
    external
    override
    onlyMinter
    isIssuableToken
  {

    require(_defaultPartitions.length != 0, "55"); // 0x55	funds locked (lockup period)

    _issueByPartition(_defaultPartitions[0], msg.sender, tokenHolder, value, data);
  }
  function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data)
    external
    override
    onlyMinter
    isIssuableToken
  {

    _issueByPartition(partition, msg.sender, tokenHolder, value, data);
  }
  

  function redeem(uint256 value, bytes calldata data)
    external
    override
  {

    _redeemByDefaultPartitions(msg.sender, msg.sender, value, data);
  }
  function redeemFrom(address from, uint256 value, bytes calldata data)
    external
    override
    virtual
  {

    require(_isOperator(msg.sender, from)
      || (value <= _allowed[from][msg.sender]), "53"); // 0x53	insufficient allowance

    if(_allowed[from][msg.sender] >= value) {
      _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    } else {
      _allowed[from][msg.sender] = 0;
    }

    _redeemByDefaultPartitions(msg.sender, from, value, data);
  }
  function redeemByPartition(bytes32 partition, uint256 value, bytes calldata data)
    external
    override
  {

    _redeemByPartition(partition, msg.sender, msg.sender, value, data, "");
  }
  function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata operatorData)
    external
    override
  {

    require(_isOperatorForPartition(partition, msg.sender, tokenHolder) || value <= _allowedByPartition[partition][tokenHolder][msg.sender], "58"); // 0x58	invalid operator (transfer agent)

    if(_allowedByPartition[partition][tokenHolder][msg.sender] >= value) {
      _allowedByPartition[partition][tokenHolder][msg.sender] = _allowedByPartition[partition][tokenHolder][msg.sender].sub(value);
    } else {
      _allowedByPartition[partition][tokenHolder][msg.sender] = 0;
    }

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

  
  function setTokenExtension(address extension, string calldata interfaceLabel, bool removeOldExtensionRoles, bool addMinterRoleForExtension, bool addControllerRoleForExtension) external onlyOwner {

    _setTokenExtension(extension, interfaceLabel, removeOldExtensionRoles, addMinterRoleForExtension, addControllerRoleForExtension);
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

    _callSenderExtension(fromPartition, operator, from, to, value, data, operatorData);
    _callTokenExtension(fromPartition, operator, from, to, value, data, operatorData);

    _removeTokenFromPartition(from, fromPartition, value);
    _transferWithData(from, to, value);
    _addTokenToPartition(to, toPartition, value);

    _callRecipientExtension(toPartition, operator, from, to, value, data, operatorData);

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

      _totalPartitions.pop();
      _indexOfTotalPartitions[partition] = 0;
    }

    if(_balanceOfByPartition[from][partition] == 0) {
      uint256 index2 = _indexOfPartitionsOf[from][partition];
      require(index2 > 0, "50"); // 0x50	transfer failure

      bytes32 lastValue = _partitionsOf[from][_partitionsOf[from].length - 1];
      _partitionsOf[from][index2 - 1] = lastValue;  // adjust for 1-based indexing
      _indexOfPartitionsOf[from][lastValue] = index2;

      _partitionsOf[from].pop();
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


  function _callSenderExtension(
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
      IERC1400TokensSender(senderImplementation).tokensToTransfer(msg.data, partition, operator, from, to, value, data, operatorData);
    }
  }
  
  function _callTokenExtension(
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

    address validatorImplementation;
    validatorImplementation = interfaceAddr(address(this), ERC1400_TOKENS_VALIDATOR);
    if (validatorImplementation != address(0)) {
      IERC1400TokensValidator(validatorImplementation).tokensToValidate(msg.data, partition, operator, from, to, value, data, operatorData);
    }
  }
  function _callRecipientExtension(
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes memory data,
    bytes memory operatorData
  )
    internal
    virtual
  {

    address recipientImplementation;
    recipientImplementation = interfaceAddr(to, ERC1400_TOKENS_RECIPIENT);

    if (recipientImplementation != address(0)) {
      IERC1400TokensRecipient(recipientImplementation).tokensReceived(msg.data, partition, operator, from, to, value, data, operatorData);
    }
  }
  
  function _callRedeemExtension(
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

    address validatorImplementation;
    validatorImplementation = interfaceAddr(address(this), ERC1400_TOKENS_VALIDATOR);
    if (validatorImplementation != address(0)) {
      IERC1400TokensValidator(validatorImplementation).canBurn(msg.data, partition, operator, from, to, value, data, operatorData);
    }
  }
  
  function _callMintExtension(
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

    address validatorImplementation;
    validatorImplementation = interfaceAddr(address(this), ERC1400_TOKENS_VALIDATOR);
    if (validatorImplementation != address(0)) {
      IERC1400TokensValidator(validatorImplementation).canMint(msg.data, partition, operator, from, to, value, data, operatorData);
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

    _callMintExtension(toPartition, operator, address(0), to, value, data, "");

    _issue(operator, to, value, data);
    _addTokenToPartition(to, toPartition, value);

    _callRecipientExtension(toPartition, operator, address(0), to, value, data, "");

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

    _callSenderExtension(fromPartition, operator, from, address(0), value, data, operatorData);
    _callRedeemExtension(fromPartition, operator, from, address(0), value, data, operatorData);

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


  function canTransfer(bytes memory payload, bytes32 partition, address operator, address from, address to, uint256 value, bytes memory data, bytes memory operatorData)
    external
    returns (bytes1, bytes32, bytes32)
  {

    if(_balanceOfByPartition[from][partition] < value) {
        return(hex"52", "", partition); // 0x52	insufficient balance
    }
    
    address validatorImplementation = interfaceAddr(address(this), ERC1400_TOKENS_VALIDATOR);
    if (validatorImplementation != address(0)) {
      IERC1400TokensValidator(validatorImplementation).tokensToValidate(msg.data, partition, operator, from, to, value, data, operatorData);
    }
    
    return(hex"00", "", partition);
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


  function _setTokenExtension(address extension, string memory interfaceLabel, bool removeOldExtensionRoles, bool addMinterRoleForExtension, bool addControllerRoleForExtension) internal {

    address oldExtension = interfaceAddr(address(this), interfaceLabel);

    if (oldExtension != address(0) && removeOldExtensionRoles) {
      if(isMinter(oldExtension)) {
        _removeMinter(oldExtension);
      }
      _isController[oldExtension] = false;
    }

    ERC1820Client.setInterfaceImplementation(interfaceLabel, extension);
    if(addMinterRoleForExtension && !isMinter(extension)) {
      _addMinter(extension);
    }
    if (addControllerRoleForExtension) {
      _isController[extension] = true;
    }
  }


  function _migrate(address newContractAddress, bool definitive) internal {

    ERC1820Client.setInterfaceImplementation(ERC20_INTERFACE_NAME, newContractAddress);
    ERC1820Client.setInterfaceImplementation(ERC1400_INTERFACE_NAME, newContractAddress);
    if(definitive) {
      _migrated = true;
    }
  }

  function domainName() public override view returns (string memory) {

    return _name;
  }

  function domainVersion() public override view returns (string memory) {

    return "1";
  }
}