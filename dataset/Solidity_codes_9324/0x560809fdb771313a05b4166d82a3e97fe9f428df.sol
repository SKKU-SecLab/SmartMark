
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






contract PauserRole {

    using Roles for Roles.Role;

    event PauserAdded(address indexed token, address indexed account);
    event PauserRemoved(address indexed token, address indexed account);

    mapping(address => Roles.Role) private _pausers;

    constructor () internal {}

    modifier onlyPauser(address token) {

        require(isPauser(token, msg.sender));
        _;
    }

    function isPauser(address token, address account) public view returns (bool) {

        return _pausers[token].has(account);
    }

    function addPauser(address token, address account) public onlyPauser(token) {

        _addPauser(token, account);
    }

    function removePauser(address token, address account) public onlyPauser(token) {

        _removePauser(token, account);
    }

    function renouncePauser(address token) public {

        _removePauser(token, msg.sender);
    }

    function _addPauser(address token, address account) internal {

        _pausers[token].add(account);
        emit PauserAdded(token, account);
    }

    function _removePauser(address token, address account) internal {

        _pausers[token].remove(account);
        emit PauserRemoved(token, account);
    }
}

contract Pausable is PauserRole {

    event Paused(address indexed token, address account);
    event Unpaused(address indexed token, address account);

    mapping(address => bool) private _paused;

    function paused(address token) public view returns (bool) {

        return _paused[token];
    }

    modifier whenNotPaused(address token) {

        require(!_paused[token]);
        _;
    }

    modifier whenPaused(address token) {

        require(_paused[token]);
        _;
    }

    function pause(address token) public onlyPauser(token) whenNotPaused(token) {

        _paused[token] = true;
        emit Paused(token, msg.sender);
    }

    function unpause(address token) public onlyPauser(token) whenPaused(token) {

        _paused[token] = false;
        emit Unpaused(token, msg.sender);
    }
}






contract CertificateSignerRole {

    using Roles for Roles.Role;

    event CertificateSignerAdded(address indexed token, address indexed account);
    event CertificateSignerRemoved(address indexed token, address indexed account);

    mapping(address => Roles.Role) private _certificateSigners;

    constructor () internal {}

    modifier onlyCertificateSigner(address token) {

        require(isCertificateSigner(token, msg.sender));
        _;
    }

    function isCertificateSigner(address token, address account) public view returns (bool) {

        return _certificateSigners[token].has(account);
    }

    function addCertificateSigner(address token, address account) public onlyCertificateSigner(token) {

        _addCertificateSigner(token, account);
    }

    function removeCertificateSigner(address token, address account) public onlyCertificateSigner(token) {

        _removeCertificateSigner(token, account);
    }

    function renounceCertificateSigner(address token) public {

        _removeCertificateSigner(token, msg.sender);
    }

    function _addCertificateSigner(address token, address account) internal {

        _certificateSigners[token].add(account);
        emit CertificateSignerAdded(token, account);
    }

    function _removeCertificateSigner(address token, address account) internal {

        _certificateSigners[token].remove(account);
        emit CertificateSignerRemoved(token, account);
    }
}






contract AllowlistAdminRole {

    using Roles for Roles.Role;

    event AllowlistAdminAdded(address indexed token, address indexed account);
    event AllowlistAdminRemoved(address indexed token, address indexed account);

    mapping(address => Roles.Role) private _allowlistAdmins;

    constructor () internal {}

    modifier onlyAllowlistAdmin(address token) {

        require(isAllowlistAdmin(token, msg.sender));
        _;
    }

    function isAllowlistAdmin(address token, address account) public view returns (bool) {

        return _allowlistAdmins[token].has(account);
    }

    function addAllowlistAdmin(address token, address account) public onlyAllowlistAdmin(token) {

        _addAllowlistAdmin(token, account);
    }

    function removeAllowlistAdmin(address token, address account) public onlyAllowlistAdmin(token) {

        _removeAllowlistAdmin(token, account);
    }

    function renounceAllowlistAdmin(address token) public {

        _removeAllowlistAdmin(token, msg.sender);
    }

    function _addAllowlistAdmin(address token, address account) internal {

        _allowlistAdmins[token].add(account);
        emit AllowlistAdminAdded(token, account);
    }

    function _removeAllowlistAdmin(address token, address account) internal {

        _allowlistAdmins[token].remove(account);
        emit AllowlistAdminRemoved(token, account);
    }
}







contract AllowlistedRole is AllowlistAdminRole {

    using Roles for Roles.Role;

    event AllowlistedAdded(address indexed token, address indexed account);
    event AllowlistedRemoved(address indexed token, address indexed account);

    mapping(address => Roles.Role) private _allowlisteds;

    modifier onlyNotAllowlisted(address token) {

        require(!isAllowlisted(token, msg.sender));
        _;
    }

    function isAllowlisted(address token, address account) public view returns (bool) {

        return _allowlisteds[token].has(account);
    }

    function addAllowlisted(address token, address account) public onlyAllowlistAdmin(token) {

        _addAllowlisted(token, account);
    }

    function removeAllowlisted(address token, address account) public onlyAllowlistAdmin(token) {

        _removeAllowlisted(token, account);
    }

    function _addAllowlisted(address token, address account) internal {

        _allowlisteds[token].add(account);
        emit AllowlistedAdded(token, account);
    }

    function _removeAllowlisted(address token, address account) internal {

        _allowlisteds[token].remove(account);
        emit AllowlistedRemoved(token, account);
    }
}






contract BlocklistAdminRole {

    using Roles for Roles.Role;

    event BlocklistAdminAdded(address indexed token, address indexed account);
    event BlocklistAdminRemoved(address indexed token, address indexed account);

    mapping(address => Roles.Role) private _blocklistAdmins;

    constructor () internal {}

    modifier onlyBlocklistAdmin(address token) {

        require(isBlocklistAdmin(token, msg.sender));
        _;
    }

    function isBlocklistAdmin(address token, address account) public view returns (bool) {

        return _blocklistAdmins[token].has(account);
    }

    function addBlocklistAdmin(address token, address account) public onlyBlocklistAdmin(token) {

        _addBlocklistAdmin(token, account);
    }

    function removeBlocklistAdmin(address token, address account) public onlyBlocklistAdmin(token) {

        _removeBlocklistAdmin(token, account);
    }

    function renounceBlocklistAdmin(address token) public {

        _removeBlocklistAdmin(token, msg.sender);
    }

    function _addBlocklistAdmin(address token, address account) internal {

        _blocklistAdmins[token].add(account);
        emit BlocklistAdminAdded(token, account);
    }

    function _removeBlocklistAdmin(address token, address account) internal {

        _blocklistAdmins[token].remove(account);
        emit BlocklistAdminRemoved(token, account);
    }
}







contract BlocklistedRole is BlocklistAdminRole {

    using Roles for Roles.Role;

    event BlocklistedAdded(address indexed token, address indexed account);
    event BlocklistedRemoved(address indexed token, address indexed account);

    mapping(address => Roles.Role) private _blocklisteds;

    modifier onlyNotBlocklisted(address token) {

        require(!isBlocklisted(token, msg.sender));
        _;
    }

    function isBlocklisted(address token, address account) public view returns (bool) {

        return _blocklisteds[token].has(account);
    }

    function addBlocklisted(address token, address account) public onlyBlocklistAdmin(token) {

        _addBlocklisted(token, account);
    }

    function removeBlocklisted(address token, address account) public onlyBlocklistAdmin(token) {

        _removeBlocklisted(token, account);
    }

    function _addBlocklisted(address token, address account) internal {

        _blocklisteds[token].add(account);
        emit BlocklistedAdded(token, account);
    }

    function _removeBlocklisted(address token, address account) internal {

        _blocklisteds[token].remove(account);
        emit BlocklistedRemoved(token, account);
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
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) external view returns(bool);


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


}



















interface IMinterRole {

  function isMinter(address account) external view returns (bool);

}


contract ERC1400TokensValidator is IERC1400TokensValidator, Pausable, CertificateSignerRole, AllowlistedRole, BlocklistedRole, ERC1820Client, ERC1820Implementer {

  using SafeMath for uint256;

  string constant internal ERC1400_TOKENS_VALIDATOR = "ERC1400TokensValidator";

  bytes4 constant internal ERC20_TRANSFER_ID = bytes4(keccak256("transfer(address,uint256)"));
  bytes4 constant internal ERC20_TRANSFERFROM_ID = bytes4(keccak256("transferFrom(address,address,uint256)"));

  mapping(address => address[]) internal _tokenControllers;

  mapping(address => mapping(address => bool)) internal _isTokenController;

  mapping(address => bool) internal _allowlistActivated;

  mapping(address => bool) internal _blocklistActivated;

  mapping(address => CertificateValidation) internal _certificateActivated;

  enum CertificateValidation {
    None,
    NonceBased,
    SaltBased
  }

  mapping(address => mapping(address => uint256)) internal _usedCertificateNonce;

  mapping(address => mapping(bytes32 => bool)) internal _usedCertificateSalt;

  mapping(address => bool) internal _granularityByPartitionActivated;

  mapping(address => bool) internal _holdsActivated;

  enum HoldStatusCode {
    Nonexistent,
    Ordered,
    Executed,
    ExecutedAndKeptOpen,
    ReleasedByNotary,
    ReleasedByPayee,
    ReleasedOnExpiration
  }

  struct Hold {
    bytes32 partition;
    address sender;
    address recipient;
    address notary;
    uint256 value;
    uint256 expiration;
    bytes32 secretHash;
    bytes32 secret;
    HoldStatusCode status;
  }

  mapping(address => mapping(bytes32 => uint256)) internal _granularityByPartition;
  
  mapping(address => mapping(bytes32 => Hold)) internal _holds;

  mapping(address => mapping(address => uint256)) internal _heldBalance;

  mapping(address => mapping(address => mapping(bytes32 => uint256))) internal _heldBalanceByPartition;

  mapping(address => mapping(bytes32 => uint256)) internal _totalHeldBalanceByPartition;

  mapping(address => uint256) internal _totalHeldBalance;

  mapping(bytes32 => uint256) internal _hashNonce;

  mapping(bytes32 => mapping(uint256 => bytes32)) internal _holdIds;

  event HoldCreated(
    address indexed token,
    bytes32 indexed holdId,
    bytes32 partition,
    address sender,
    address recipient,
    address indexed notary,
    uint256 value,
    uint256 expiration,
    bytes32 secretHash
  );
  event HoldReleased(address indexed token, bytes32 holdId, address indexed notary, HoldStatusCode status);
  event HoldRenewed(address indexed token, bytes32 holdId, address indexed notary, uint256 oldExpiration, uint256 newExpiration);
  event HoldExecuted(address indexed token, bytes32 holdId, address indexed notary, uint256 heldValue, uint256 transferredValue, bytes32 secret);
  event HoldExecutedAndKeptOpen(address indexed token, bytes32 holdId, address indexed notary, uint256 heldValue, uint256 transferredValue, bytes32 secret);
  
  modifier onlyTokenController(address token) {

    require(
      msg.sender == token ||
      msg.sender == Ownable(token).owner() ||
      _isTokenController[token][msg.sender],
      "Sender is not a token controller."
    );
    _;
  }

  modifier onlyPauser(address token) {

    require(
      msg.sender == token ||
      msg.sender == Ownable(token).owner() ||
      _isTokenController[token][msg.sender] ||
      isPauser(token, msg.sender),
      "Sender is not a pauser"
    );
    _;
  }

  modifier onlyCertificateSigner(address token) {

    require(
      msg.sender == token ||
      msg.sender == Ownable(token).owner() ||
      _isTokenController[token][msg.sender] ||
      isCertificateSigner(token, msg.sender),
      "Sender is not a certificate signer"
    );
    _;
  }

  modifier onlyAllowlistAdmin(address token) {

    require(
      msg.sender == token ||
      msg.sender == Ownable(token).owner() ||
      _isTokenController[token][msg.sender] ||
      isAllowlistAdmin(token, msg.sender),
      "Sender is not an allowlist admin"
    );
    _;
  }

  modifier onlyBlocklistAdmin(address token) {

    require(
      msg.sender == token ||
      msg.sender == Ownable(token).owner() ||
      _isTokenController[token][msg.sender] ||
      isBlocklistAdmin(token, msg.sender),
      "Sender is not a blocklist admin"
    );
    _;
  }

  constructor() public {
    ERC1820Implementer._setInterface(ERC1400_TOKENS_VALIDATOR);
  }

  function retrieveTokenSetup(address token) external view returns (CertificateValidation, bool, bool, bool, bool, address[] memory) {

    return (
      _certificateActivated[token],
      _allowlistActivated[token],
      _blocklistActivated[token],
      _granularityByPartitionActivated[token],
      _holdsActivated[token],
      _tokenControllers[token]
    );
  }

  function registerTokenSetup(
    address token,
    CertificateValidation certificateActivated,
    bool allowlistActivated,
    bool blocklistActivated,
    bool granularityByPartitionActivated,
    bool holdsActivated,
    address[] calldata operators
  ) external onlyTokenController(token) {

    _certificateActivated[token] = certificateActivated;
    _allowlistActivated[token] = allowlistActivated;
    _blocklistActivated[token] = blocklistActivated;
    _granularityByPartitionActivated[token] = granularityByPartitionActivated;
    _holdsActivated[token] = holdsActivated;
    _setTokenControllers(token, operators);
  }

  function _setTokenControllers(address token, address[] memory operators) internal {

    for (uint i = 0; i<_tokenControllers[token].length; i++){
      _isTokenController[token][_tokenControllers[token][i]] = false;
    }
    for (uint j = 0; j<operators.length; j++){
      _isTokenController[token][operators[j]] = true;
    }
    _tokenControllers[token] = operators;
  }

  function canValidate(
    address token,
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) // Comments to avoid compilation warnings for unused variables.
    external
    view 
    returns(bool)
  {

    (bool canValidateToken,,) = _canValidateCertificateToken(token, payload, operator, operatorData.length != 0 ? operatorData : data);

    canValidateToken = canValidateToken && _canValidateAllowlistAndBlocklistToken(token, payload, from, to);
    
    canValidateToken = canValidateToken && !paused(token);

    canValidateToken = canValidateToken && _canValidateGranularToken(token, partition, value);

    canValidateToken = canValidateToken && _canValidateHoldableToken(token, partition, operator, from, to, value);

    return canValidateToken;
  }

  function tokensToValidate(
    bytes calldata payload,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value,
    bytes calldata data,
    bytes calldata operatorData
  ) // Comments to avoid compilation warnings for unused variables.
    external
  {

    (bool canValidateCertificateToken, CertificateValidation certificateControl, bytes32 salt) = _canValidateCertificateToken(msg.sender, payload, operator, operatorData.length != 0 ? operatorData : data);
    require(canValidateCertificateToken, "54"); // 0x54	transfers halted (contract paused)

    _useCertificateIfActivated(msg.sender, certificateControl, operator, salt);

    require(_canValidateAllowlistAndBlocklistToken(msg.sender, payload, from, to), "54"); // 0x54	transfers halted (contract paused)

    require(!paused(msg.sender), "54"); // 0x54	transfers halted (contract paused)

    require(_canValidateGranularToken(msg.sender, partition, value), "50"); // 0x50	transfer failure

    require(_canValidateHoldableToken(msg.sender, partition, operator, from, to, value), "55"); // 0x55	funds locked (lockup period)

    (,, bytes32 holdId) = _retrieveHoldHashNonceId(msg.sender, partition, operator, from, to, value);
    if (_holdsActivated[msg.sender] && holdId != "") {
      Hold storage executableHold = _holds[msg.sender][holdId];
      _setHoldToExecuted(
        msg.sender,
        executableHold,
        holdId,
        value,
        executableHold.value,
        ""
      );
    }
  }

  function _canValidateCertificateToken(
    address token,
    bytes memory payload,
    address operator,
    bytes memory certificate
  )
    internal
    view
    returns(bool, CertificateValidation, bytes32)
  {

    if(
      _certificateActivated[token] > CertificateValidation.None &&
      _functionSupportsCertificateValidation(payload) &&
      !isCertificateSigner(token, operator) &&
      address(this) != operator
    ) {
      if(_certificateActivated[token] == CertificateValidation.SaltBased) {
        (bool valid, bytes32 salt) = _checkSaltBasedCertificate(
          token,
          operator,
          payload,
          certificate
        );
        if(valid) {
          return (true, CertificateValidation.SaltBased, salt);
        } else {
          return (false, CertificateValidation.SaltBased, "");
        }
        
      } else { // case when _certificateActivated[token] == CertificateValidation.NonceBased
        if(
          _checkNonceBasedCertificate(
            token,
            operator,
            payload,
            certificate
          )
        ) {
          return (true, CertificateValidation.NonceBased, "");
        } else {
          return (false, CertificateValidation.SaltBased, "");
        }
      }
    }

    return (true, CertificateValidation.None, "");
  }

  function _canValidateAllowlistAndBlocklistToken(
    address token,
    bytes memory payload,
    address from,
    address to
  ) // Comments to avoid compilation warnings for unused variables.
    internal
    view
    returns(bool)
  {

    if(
      !_functionSupportsCertificateValidation(payload) ||
      _certificateActivated[token] == CertificateValidation.None
    ) {
      if(_allowlistActivated[token]) {
        if(from != address(0) && !isAllowlisted(token, from)) {
          return false;
        }
        if(to != address(0) && !isAllowlisted(token, to)) {
          return false;
        }
      }
      if(_blocklistActivated[token]) {
        if(from != address(0) && isBlocklisted(token, from)) {
          return false;
        }
        if(to != address(0) && isBlocklisted(token, to)) {
          return false;
        }
      }
    }
    
    return true;
  }

  function _canValidateGranularToken(
    address token,
    bytes32 partition,
    uint value
  )
    internal
    view
    returns(bool)
  {

    if(_granularityByPartitionActivated[token]) {
      if(
        _granularityByPartition[token][partition] > 0 &&
        !_isMultiple(_granularityByPartition[token][partition], value)
      ) {
        return false;
      } 
    }

    return true;
  }

  function _canValidateHoldableToken(
    address token,
    bytes32 partition,
    address operator,
    address from,
    address to,
    uint value
  )
    internal
    view
    returns(bool)
  {

    if (_holdsActivated[token] && from != address(0)) {
      if(operator != from) {
        (,, bytes32 holdId) = _retrieveHoldHashNonceId(token, partition, operator, from, to, value);
        Hold storage hold = _holds[token][holdId];
        
        if (_holdCanBeExecutedAsNotary(hold, operator, value) && value <= IERC1400(token).balanceOfByPartition(partition, from)) {
          return true;
        }
      }
      
      if(value > _spendableBalanceOfByPartition(token, partition, from)) {
        return false;
      }
    }

    return true;
  }

  function granularityByPartition(address token, bytes32 partition) external view returns (uint256) {

    return _granularityByPartition[token][partition];
  }
  
  function setGranularityByPartition(
    address token,
    bytes32 partition,
    uint256 granularity
  )
    external
    onlyTokenController(token)
  {

    _granularityByPartition[token][partition] = granularity;
  }

  function preHoldFor(
    address token,
    bytes32 holdId,
    address recipient,
    address notary,
    bytes32 partition,
    uint256 value,
    uint256 timeToExpiration,
    bytes32 secretHash,
    bytes calldata certificate
  )
    external
    returns (bool)
  {

    return _createHold(
      token,
      holdId,
      address(0),
      recipient,
      notary,
      partition,
      value,
      _computeExpiration(timeToExpiration),
      secretHash,
      certificate
    );
  }

  function preHoldForWithExpirationDate(
    address token,
    bytes32 holdId,
    address recipient,
    address notary,
    bytes32 partition,
    uint256 value,
    uint256 expiration,
    bytes32 secretHash,
    bytes calldata certificate
  )
    external
    returns (bool)
  {

    _checkExpiration(expiration);

    return _createHold(
      token,
      holdId,
      address(0),
      recipient,
      notary,
      partition,
      value,
      expiration,
      secretHash,
      certificate
    );
  }

  function hold(
    address token,
    bytes32 holdId,
    address recipient,
    address notary,
    bytes32 partition,
    uint256 value,
    uint256 timeToExpiration,
    bytes32 secretHash,
    bytes calldata certificate
  ) 
    external
    returns (bool)
  {

    return _createHold(
      token,
      holdId,
      msg.sender,
      recipient,
      notary,
      partition,
      value,
      _computeExpiration(timeToExpiration),
      secretHash,
      certificate
    );
  }

  function holdWithExpirationDate(
    address token,
    bytes32 holdId,
    address recipient,
    address notary,
    bytes32 partition,
    uint256 value,
    uint256 expiration,
    bytes32 secretHash,
    bytes calldata certificate
  )
    external
    returns (bool)
  {

    _checkExpiration(expiration);

    return _createHold(
      token,
      holdId,
      msg.sender,
      recipient,
      notary,
      partition,
      value,
      expiration,
      secretHash,
      certificate
    );
  }

  function holdFrom(
    address token,
    bytes32 holdId,
    address sender,
    address recipient,
    address notary,
    bytes32 partition,
    uint256 value,
    uint256 timeToExpiration,
    bytes32 secretHash,
    bytes calldata certificate
  )
    external
    returns (bool)
  {

    require(sender != address(0), "Payer address must not be zero address");
    return _createHold(
      token,
      holdId,
      sender,
      recipient,
      notary,
      partition,
      value,
      _computeExpiration(timeToExpiration),
      secretHash,
      certificate
    );
  }

  function holdFromWithExpirationDate(
    address token,
    bytes32 holdId,
    address sender,
    address recipient,
    address notary,
    bytes32 partition,
    uint256 value,
    uint256 expiration,
    bytes32 secretHash,
    bytes calldata certificate
  )
    external
    returns (bool)
  {

    _checkExpiration(expiration);
    require(sender != address(0), "Payer address must not be zero address");

    return _createHold(
      token,
      holdId,
      sender,
      recipient,
      notary,
      partition,
      value,
      expiration,
      secretHash,
      certificate
    );
  }

  function _createHold(
    address token,
    bytes32 holdId,
    address sender,
    address recipient,
    address notary,
    bytes32 partition,
    uint256 value,
    uint256 expiration,
    bytes32 secretHash,
    bytes memory certificate
  ) internal returns (bool)
  {

    Hold storage newHold = _holds[token][holdId];

    require(recipient != address(0), "Payee address must not be zero address");
    require(value != 0, "Value must be greater than zero");
    require(newHold.value == 0, "This holdId already exists");
    require(notary != address(0), "Notary address must not be zero address");
    require(
      _canHoldOrCanPreHold(token, msg.sender, sender, certificate),
      "A hold can only be created with adapted authorizations"
    );
    if (sender != address(0)) { // hold (tokens already exist)
      require(value <= _spendableBalanceOfByPartition(token, partition, sender), "Amount of the hold can't be greater than the spendable balance of the sender");
    }
    
    newHold.partition = partition;
    newHold.sender = sender;
    newHold.recipient = recipient;
    newHold.notary = notary;
    newHold.value = value;
    newHold.expiration = expiration;
    newHold.secretHash = secretHash;
    newHold.status = HoldStatusCode.Ordered;

    if(sender != address(0)) {
      _increaseHeldBalance(token, newHold, holdId);
    }

    emit HoldCreated(
      token,
      holdId,
      partition,
      sender,
      recipient,
      notary,
      value,
      expiration,
      secretHash
    );

    return true;
  }

  function releaseHold(address token, bytes32 holdId) external returns (bool) {

    return _releaseHold(token, holdId);
  }

  function _releaseHold(address token, bytes32 holdId) internal returns (bool) {

    Hold storage releasableHold = _holds[token][holdId];

    require(
        releasableHold.status == HoldStatusCode.Ordered || releasableHold.status == HoldStatusCode.ExecutedAndKeptOpen,
        "A hold can only be released in status Ordered or ExecutedAndKeptOpen"
    );
    require(
        _isExpired(releasableHold.expiration) ||
        (msg.sender == releasableHold.notary) ||
        (msg.sender == releasableHold.recipient),
        "A not expired hold can only be released by the notary or the payee"
    );

    if (_isExpired(releasableHold.expiration)) {
        releasableHold.status = HoldStatusCode.ReleasedOnExpiration;
    } else {
        if (releasableHold.notary == msg.sender) {
            releasableHold.status = HoldStatusCode.ReleasedByNotary;
        } else {
            releasableHold.status = HoldStatusCode.ReleasedByPayee;
        }
    }

    if(releasableHold.sender != address(0)) { // In case tokens already exist, decrease held balance
      _decreaseHeldBalance(token, releasableHold, releasableHold.value);
    }

    emit HoldReleased(token, holdId, releasableHold.notary, releasableHold.status);

    return true;
  }

  function renewHold(address token, bytes32 holdId, uint256 timeToExpiration, bytes calldata certificate) external returns (bool) {

    return _renewHold(token, holdId, _computeExpiration(timeToExpiration), certificate);
  }

  function renewHoldWithExpirationDate(address token, bytes32 holdId, uint256 expiration, bytes calldata certificate) external returns (bool) {

    _checkExpiration(expiration);

    return _renewHold(token, holdId, expiration, certificate);
  }

  function _renewHold(address token, bytes32 holdId, uint256 expiration, bytes memory certificate) internal returns (bool) {

    Hold storage renewableHold = _holds[token][holdId];

    require(
      renewableHold.status == HoldStatusCode.Ordered
      || renewableHold.status == HoldStatusCode.ExecutedAndKeptOpen,
      "A hold can only be renewed in status Ordered or ExecutedAndKeptOpen"
    );
    require(!_isExpired(renewableHold.expiration), "An expired hold can not be renewed");

    require(
      _canHoldOrCanPreHold(token, msg.sender, renewableHold.sender, certificate),
      "A hold can only be renewed with adapted authorizations"
    );
    
    uint256 oldExpiration = renewableHold.expiration;
    renewableHold.expiration = expiration;

    emit HoldRenewed(
      token,
      holdId,
      renewableHold.notary,
      oldExpiration,
      expiration
    );

    return true;
  }

  function executeHold(address token, bytes32 holdId, uint256 value, bytes32 secret) external returns (bool) {

    return _executeHold(
      token,
      holdId,
      msg.sender,
      value,
      secret,
      false
    );
  }

  function executeHoldAndKeepOpen(address token, bytes32 holdId, uint256 value, bytes32 secret) external returns (bool) {

    return _executeHold(
      token,
      holdId,
      msg.sender,
      value,
      secret,
      true
    );
  }
  
  function _executeHold(
    address token,
    bytes32 holdId,
    address operator,
    uint256 value,
    bytes32 secret,
    bool keepOpenIfHoldHasBalance
  ) internal returns (bool)
  {

    Hold storage executableHold = _holds[token][holdId];

    bool canExecuteHold;
    if(secret != "" && _holdCanBeExecutedAsSecretHolder(executableHold, value, secret)) {
      executableHold.secret = secret;
      canExecuteHold = true;
    } else if(_holdCanBeExecutedAsNotary(executableHold, operator, value)) {
      canExecuteHold = true;
    }

    if(canExecuteHold) {
      if (keepOpenIfHoldHasBalance && ((executableHold.value - value) > 0)) {
        _setHoldToExecutedAndKeptOpen(
          token,
          executableHold,
          holdId,
          value,
          value,
          secret
        );
      } else {
        _setHoldToExecuted(
          token,
          executableHold,
          holdId,
          value,
          executableHold.value,
          secret
        );
      }

      if (executableHold.sender == address(0)) { // pre-hold (tokens do not already exist)
        IERC1400(token).issueByPartition(executableHold.partition, executableHold.recipient, value, "");
      } else { // post-hold (tokens already exist)
        IERC1400(token).operatorTransferByPartition(executableHold.partition, executableHold.sender, executableHold.recipient, value, "", "");
      }
      
    } else {
      revert("hold can not be executed");
    }

  }

  function _setHoldToExecuted(
    address token,
    Hold storage executableHold,
    bytes32 holdId,
    uint256 value,
    uint256 heldBalanceDecrease,
    bytes32 secret
  ) internal
  {

    if(executableHold.sender != address(0)) { // In case tokens already exist, decrease held balance
      _decreaseHeldBalance(token, executableHold, heldBalanceDecrease);
    }

    executableHold.status = HoldStatusCode.Executed;

    emit HoldExecuted(
      token,
      holdId,
      executableHold.notary,
      executableHold.value,
      value,
      secret
    );
  }

  function _setHoldToExecutedAndKeptOpen(
    address token,
    Hold storage executableHold,
    bytes32 holdId,
    uint256 value,
    uint256 heldBalanceDecrease,
    bytes32 secret
  ) internal
  {

    if(executableHold.sender != address(0)) { // In case tokens already exist, decrease held balance
      _decreaseHeldBalance(token, executableHold, heldBalanceDecrease);
    } 

    executableHold.status = HoldStatusCode.ExecutedAndKeptOpen;
    executableHold.value = executableHold.value.sub(value);

    emit HoldExecutedAndKeptOpen(
      token,
      holdId,
      executableHold.notary,
      executableHold.value,
      value,
      secret
    );
  }

  function _increaseHeldBalance(address token, Hold storage executableHold, bytes32 holdId) private {

    _heldBalance[token][executableHold.sender] = _heldBalance[token][executableHold.sender].add(executableHold.value);
    _totalHeldBalance[token] = _totalHeldBalance[token].add(executableHold.value);

    _heldBalanceByPartition[token][executableHold.sender][executableHold.partition] = _heldBalanceByPartition[token][executableHold.sender][executableHold.partition].add(executableHold.value);
    _totalHeldBalanceByPartition[token][executableHold.partition] = _totalHeldBalanceByPartition[token][executableHold.partition].add(executableHold.value);

    _increaseNonce(token, executableHold, holdId);
  }

  function _decreaseHeldBalance(address token, Hold storage executableHold, uint256 value) private {

    _heldBalance[token][executableHold.sender] = _heldBalance[token][executableHold.sender].sub(value);
    _totalHeldBalance[token] = _totalHeldBalance[token].sub(value);

    _heldBalanceByPartition[token][executableHold.sender][executableHold.partition] = _heldBalanceByPartition[token][executableHold.sender][executableHold.partition].sub(value);
    _totalHeldBalanceByPartition[token][executableHold.partition] = _totalHeldBalanceByPartition[token][executableHold.partition].sub(value);

    if(executableHold.status == HoldStatusCode.Ordered) {
      _decreaseNonce(token, executableHold);
    }
  }

  function _increaseNonce(address token, Hold storage executableHold, bytes32 holdId) private {

    (bytes32 holdHash, uint256 nonce,) = _retrieveHoldHashNonceId(
      token, executableHold.partition,
      executableHold.notary,
      executableHold.sender,
      executableHold.recipient,
      executableHold.value
    );
    _hashNonce[holdHash] = nonce.add(1);
    _holdIds[holdHash][nonce.add(1)] = holdId;
  }

  function _decreaseNonce(address token, Hold storage executableHold) private {

    (bytes32 holdHash, uint256 nonce,) = _retrieveHoldHashNonceId(
      token,
      executableHold.partition,
      executableHold.notary,
      executableHold.sender,
      executableHold.recipient,
      executableHold.value
    );
    _holdIds[holdHash][nonce] = "";
    _hashNonce[holdHash] = _hashNonce[holdHash].sub(1);
  }

  function _checkSecret(Hold storage executableHold, bytes32 secret) internal view returns (bool) {

    if(executableHold.secretHash == sha256(abi.encodePacked(secret))) {
      return true;
    } else {
      return false;
    }
  }

  function _computeExpiration(uint256 timeToExpiration) internal view returns (uint256) {

    uint256 expiration = 0;

    if (timeToExpiration != 0) {
        expiration = now.add(timeToExpiration);
    }

    return expiration;
  }

  function _checkExpiration(uint256 expiration) private view {

    require(expiration > now || expiration == 0, "Expiration date must be greater than block timestamp or zero");
  }

  function _isExpired(uint256 expiration) internal view returns (bool) {

    return expiration != 0 && (now >= expiration);
  }

  function _retrieveHoldHashNonceId(address token, bytes32 partition, address notary, address sender, address recipient, uint value) internal view returns (bytes32, uint256, bytes32) {

    bytes32 holdHash = keccak256(abi.encodePacked(
      token,
      partition,
      sender,
      recipient,
      notary,
      value
    ));
    uint256 nonce = _hashNonce[holdHash];
    bytes32 holdId = _holdIds[holdHash][nonce];

    return (holdHash, nonce, holdId);
  }  

  function _holdCanBeExecuted(Hold storage executableHold, uint value) internal view returns (bool) {

    if(!(executableHold.status == HoldStatusCode.Ordered || executableHold.status == HoldStatusCode.ExecutedAndKeptOpen)) {
      return false; // A hold can only be executed in status Ordered or ExecutedAndKeptOpen
    } else if(value == 0) {
      return false; // Value must be greater than zero
    } else if(_isExpired(executableHold.expiration)) {
      return false; // The hold has already expired
    } else if(value > executableHold.value) {
      return false; // The value should be equal or less than the held amount
    } else {
      return true;
    }
  }

  function _holdCanBeExecutedAsSecretHolder(Hold storage executableHold, uint value, bytes32 secret) internal view returns (bool) {

    if(
      _checkSecret(executableHold, secret)
      && _holdCanBeExecuted(executableHold, value)) {
      return true;
    } else {
      return false;
    }
  }

  function _holdCanBeExecutedAsNotary(Hold storage executableHold, address operator, uint value) internal view returns (bool) {

    if(
      executableHold.notary == operator
      && _holdCanBeExecuted(executableHold, value)) {
      return true;
    } else {
      return false;
    }
  }  

  function retrieveHoldData(address token, bytes32 holdId) external view returns (
    bytes32 partition,
    address sender,
    address recipient,
    address notary,
    uint256 value,
    uint256 expiration,
    bytes32 secretHash,
    bytes32 secret,
    HoldStatusCode status)
  {

    Hold storage retrievedHold = _holds[token][holdId];
    return (
      retrievedHold.partition,
      retrievedHold.sender,
      retrievedHold.recipient,
      retrievedHold.notary,
      retrievedHold.value,
      retrievedHold.expiration,
      retrievedHold.secretHash,
      retrievedHold.secret,
      retrievedHold.status
    );
  }

  function totalSupplyOnHold(address token) external view returns (uint256) {

    return _totalHeldBalance[token];
  }

  function totalSupplyOnHoldByPartition(address token, bytes32 partition) external view returns (uint256) {

    return _totalHeldBalanceByPartition[token][partition];
  }

  function balanceOnHold(address token, address account) external view returns (uint256) {

    return _heldBalance[token][account];
  }

  function balanceOnHoldByPartition(address token, bytes32 partition, address account) external view returns (uint256) {

    return _heldBalanceByPartition[token][account][partition];
  }

  function spendableBalanceOf(address token, address account) external view returns (uint256) {

    return _spendableBalanceOf(token, account);
  }

  function spendableBalanceOfByPartition(address token, bytes32 partition, address account) external view returns (uint256) {

    return _spendableBalanceOfByPartition(token, partition, account);
  }

  function _spendableBalanceOf(address token, address account) internal view returns (uint256) {

    return IERC20(token).balanceOf(account) - _heldBalance[token][account];
  }

  function _spendableBalanceOfByPartition(address token, bytes32 partition, address account) internal view returns (uint256) {

    return IERC1400(token).balanceOfByPartition(partition, account) - _heldBalanceByPartition[token][account][partition];
  }

  function _canHoldOrCanPreHold(address token, address operator, address sender, bytes memory certificate) internal returns(bool) { 

    (bool canValidateCertificate, CertificateValidation certificateControl, bytes32 salt) = _canValidateCertificateToken(token, msg.data, operator, certificate);
    _useCertificateIfActivated(token, certificateControl, operator, salt);

    if (sender != address(0)) { // hold
      return canValidateCertificate && (_isTokenController[token][operator] || operator == sender);
    } else { // pre-hold
      return canValidateCertificate && IMinterRole(token).isMinter(operator); 
    }
  }

  function _functionSupportsCertificateValidation(bytes memory payload) internal pure returns(bool) {

    bytes4 functionSig = _getFunctionSig(payload);
    if(_areEqual(functionSig, ERC20_TRANSFER_ID) || _areEqual(functionSig, ERC20_TRANSFERFROM_ID)) {
      return false;
    } else {
      return true;
    }
  }

  function _useCertificateIfActivated(address token, CertificateValidation certificateControl, address msgSender, bytes32 salt) internal {

    if (certificateControl == CertificateValidation.NonceBased) {
      _usedCertificateNonce[token][msgSender] += 1;
    } else if (certificateControl == CertificateValidation.SaltBased) {
      _usedCertificateSalt[token][salt] = true;
    }
  }

  function _getFunctionSig(bytes memory payload) internal pure returns(bytes4) {

    return (bytes4(payload[0]) | bytes4(payload[1]) >> 8 | bytes4(payload[2]) >> 16 | bytes4(payload[3]) >> 24);
  }

  function _areEqual(bytes4 a, bytes4 b) internal pure returns(bool) {

    for (uint256 i = 0; i < a.length; i++) {
      if(a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  function _isMultiple(uint256 granularity, uint256 value) internal pure returns(bool) {

    return(value.div(granularity).mul(granularity) == value);
  }

  function usedCertificateNonce(address token, address sender) external view returns (uint256) {

    return _usedCertificateNonce[token][sender];
  }

  function _checkNonceBasedCertificate(
    address token,
    address msgSender,
    bytes memory payloadWithCertificate,
    bytes memory certificate
  )
    internal
    view
    returns(bool)
  {

    if (certificate.length != 97) {
      return false;
    }

    uint256 e;
    uint8 v;

    assembly {
      e := mload(add(certificate, 0x20))
      v := byte(0, mload(add(certificate, 0x80)))
    }

    if (e < now) {
      return false;
    }

    if (v < 27) {
      v += 27;
    }

    if (v == 27 || v == 28) {
      bytes memory payloadWithoutCertificate = new bytes(payloadWithCertificate.length.sub(160));
      for (uint i = 0; i < payloadWithCertificate.length.sub(160); i++) { // replace 4 bytes corresponding to function selector
        payloadWithoutCertificate[i] = payloadWithCertificate[i];
      }

      bytes memory pack = abi.encodePacked(
        msgSender,
        token,
        payloadWithoutCertificate,
        e,
        _usedCertificateNonce[token][msgSender]
      );
      bytes32 hash = keccak256(pack);

      bytes32 r;
      bytes32 s;
      assembly {
        r := mload(add(certificate, 0x40))
        s := mload(add(certificate, 0x60))
      }

      if (isCertificateSigner(token, ecrecover(hash, v, r, s))) {
        return true;
      }
    }
    return false;
  }

  function usedCertificateSalt(address token, bytes32 salt) external view returns (bool) {

    return _usedCertificateSalt[token][salt];
  }

  function _checkSaltBasedCertificate(
    address token,
    address msgSender,
    bytes memory payloadWithCertificate,
    bytes memory certificate
  )
    internal
    view
    returns(bool, bytes32)
  {

    if (certificate.length != 129) {
      return (false, "");
    }

    bytes32 salt;
    uint256 e;
    uint8 v;

    assembly {
      salt := mload(add(certificate, 0x20))
      e := mload(add(certificate, 0x40))
      v := byte(0, mload(add(certificate, 0xa0)))
    }

    if (e < now) {
      return (false, "");
    }

    if (v < 27) {
      v += 27;
    }

    if (v == 27 || v == 28) {
      bytes memory payloadWithoutCertificate = new bytes(payloadWithCertificate.length.sub(192));
      for (uint i = 0; i < payloadWithCertificate.length.sub(192); i++) { // replace 4 bytes corresponding to function selector
        payloadWithoutCertificate[i] = payloadWithCertificate[i];
      }

      bytes memory pack = abi.encodePacked(
        msgSender,
        token,
        payloadWithoutCertificate,
        e,
        salt
      );
      bytes32 hash = keccak256(pack);

      bytes32 r;
      bytes32 s;
      assembly {
        r := mload(add(certificate, 0x60))
        s := mload(add(certificate, 0x80))
      }

      if (isCertificateSigner(token, ecrecover(hash, v, r, s)) && !_usedCertificateSalt[token][salt]) {
        return (true, salt);
      }
    }
    return (false, "");
  }

}