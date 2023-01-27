

pragma solidity 0.5.17;



contract IPublicLock
{




  function initialize(
    address _lockCreator,
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName
  ) external;


  function() external payable;

  function initialize() external;


  function publicLockVersion() public pure returns (uint);


  function getBalance(
    address _tokenAddress,
    address _account
  ) external view
    returns (uint);


  function disableLock() external;


  function withdraw(
    address _tokenAddress,
    uint _amount
  ) external;


  function approveBeneficiary(
    address _spender,
    uint _amount
  ) external
    returns (bool);


  function updateKeyPricing( uint _keyPrice, address _tokenAddress ) external;


  function updateBeneficiary( address _beneficiary ) external;


  function getHasValidKey(
    address _user
  ) external view returns (bool);


  function getTokenIdFor(
    address _account
  ) external view returns (uint);


  function getOwnersByPage(
    uint _page,
    uint _pageSize
  ) external view returns (address[] memory);


  function isKeyOwner(
    uint _tokenId,
    address _keyOwner
  ) external view returns (bool);


  function keyExpirationTimestampFor(
    address _keyOwner
  ) external view returns (uint timestamp);


  function numberOfOwners() external view returns (uint);


  function updateLockName(
    string calldata _lockName
  ) external;


  function updateLockSymbol(
    string calldata _lockSymbol
  ) external;


  function symbol()
    external view
    returns(string memory);


  function setBaseTokenURI(
    string calldata _baseTokenURI
  ) external;


  function tokenURI(
    uint256 _tokenId
  ) external view returns(string memory);


  function setEventHooks(
    address _onKeyPurchaseHook,
    address _onKeyCancelHook
  ) external;


  function grantKeys(
    address[] calldata _recipients,
    uint[] calldata _expirationTimestamps,
    address[] calldata _keyManagers
  ) external;


  function purchase(
    uint256 _value,
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external payable;


  function purchasePriceFor(
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external view
    returns (uint);


  function updateTransferFee(
    uint _transferFeeBasisPoints
  ) external;


  function getTransferFee(
    address _keyOwner,
    uint _time
  ) external view returns (uint);


  function expireAndRefundFor(
    address _keyOwner,
    uint amount
  ) external;


  function cancelAndRefund(uint _tokenId) external;


  function cancelAndRefundFor(
    address _keyManager,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    uint _tokenId
  ) external;


  function invalidateOffchainApproval(
    uint _nextAvailableNonce
  ) external;


  function updateRefundPenalty(
    uint _freeTrialLength,
    uint _refundPenaltyBasisPoints
  ) external;


  function getCancelAndRefundValueFor(
    address _keyOwner
  ) external view returns (uint refund);


  function keyManagerToNonce(address ) external view returns (uint256 );


  function getCancelAndRefundApprovalHash(
    address _keyManager,
    address _txSender
  ) external view returns (bytes32 approvalHash);


  function addKeyGranter(address account) external;


  function addLockManager(address account) external;


  function isKeyGranter(address account) external view returns (bool);


  function isLockManager(address account) external view returns (bool);


  function onKeyPurchaseHook() external view returns(address);


  function onKeyCancelHook() external view returns(address);


  function revokeKeyGranter(address _granter) external;


  function renounceLockManager() external;



  function beneficiary() external view returns (address );


  function expirationDuration() external view returns (uint256 );


  function freeTrialLength() external view returns (uint256 );


  function isAlive() external view returns (bool );


  function keyPrice() external view returns (uint256 );


  function maxNumberOfKeys() external view returns (uint256 );


  function owners(uint256 ) external view returns (address );


  function refundPenaltyBasisPoints() external view returns (uint256 );


  function tokenAddress() external view returns (address );


  function transferFeeBasisPoints() external view returns (uint256 );


  function unlockProtocol() external view returns (address );


  function keyManagerOf(uint) external view returns (address );



  function shareKey(
    address _to,
    uint _tokenId,
    uint _timeShared
  ) external;


  function setKeyManagerOf(
    uint _tokenId,
    address _keyManager
  ) external;


  function name() external view returns (string memory _name);


  function supportsInterface(bytes4 interfaceId) external view returns (bool );


    function balanceOf(address _owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address _owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;


    function getApproved(uint256 _tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address _owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;


    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);




    function transfer(
      address _to,
      uint _value
    ) external
      returns (bool success);

}


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.0;



contract ERC165 is Initializable, IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function initialize() public initializer {

        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.5.17;





contract MixinFunds
{

  using Address for address payable;
  using SafeERC20 for IERC20;

  address public tokenAddress;

  function _initializeMixinFunds(
    address _tokenAddress
  ) internal
  {

    tokenAddress = _tokenAddress;
    require(
      _tokenAddress == address(0) || IERC20(_tokenAddress).totalSupply() > 0,
      'INVALID_TOKEN'
    );
  }

  function getBalance(
    address _tokenAddress,
    address _account
  ) public view
    returns (uint)
  {

    if(_tokenAddress == address(0)) {
      return _account.balance;
    } else {
      return IERC20(_tokenAddress).balanceOf(_account);
    }
  }

  function _transfer(
    address _tokenAddress,
    address _to,
    uint _amount
  ) internal
  {

    if(_amount > 0) {
      if(_tokenAddress == address(0)) {
        address(uint160(_to)).sendValue(_amount);
      } else {
        IERC20 token = IERC20(_tokenAddress);
        token.safeTransfer(_to, _amount);
      }
    }
  }
}


pragma solidity ^0.5.0;

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
}


pragma solidity 0.5.17;




contract MixinLockManagerRole {

  using Roles for Roles.Role;

  event LockManagerAdded(address indexed account);
  event LockManagerRemoved(address indexed account);

  Roles.Role private lockManagers;

  function _initializeMixinLockManagerRole(address sender) internal {

    if (!isLockManager(sender)) {
      lockManagers.add(sender);
    }
  }

  modifier onlyLockManager() {

    require(isLockManager(msg.sender), 'MixinLockManager: caller does not have the LockManager role');
    _;
  }

  function isLockManager(address account) public view returns (bool) {

    return lockManagers.has(account);
  }

  function addLockManager(address account) public onlyLockManager {

    lockManagers.add(account);
    emit LockManagerAdded(account);
  }

  function renounceLockManager() public {

    lockManagers.remove(msg.sender);
    emit LockManagerRemoved(msg.sender);
  }
}


pragma solidity 0.5.17;



contract MixinDisable is
  MixinLockManagerRole,
  MixinFunds
{

  bool public isAlive;

  event Disable();

  function _initializeMixinDisable(
  ) internal
  {

    isAlive = true;
  }

  modifier onlyIfAlive() {

    require(isAlive, 'LOCK_DEPRECATED');
    _;
  }

  function disableLock()
    external
    onlyLockManager
    onlyIfAlive
  {

    emit Disable();
    isAlive = false;
  }
}


pragma solidity ^0.5.0;



contract IERC721 is Initializable, IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.0;



contract IERC721Enumerable is Initializable, IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


pragma solidity 0.5.17;



interface IUnlock
{

  function initialize(address _unlockOwner) external;


  function createLock(
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName,
    bytes12 _salt
  ) external;


  function recordKeyPurchase(
    uint _value,
    address _referrer // solhint-disable-line no-unused-vars
  )
    external;


  function recordConsumedDiscount(
    uint _discount,
    uint _tokens // solhint-disable-line no-unused-vars
  )
    external;


  function computeAvailableDiscountFor(
    address _purchaser, // solhint-disable-line no-unused-vars
    uint _keyPrice // solhint-disable-line no-unused-vars
  )
    external
    view
    returns(uint discount, uint tokens);


  function globalBaseTokenURI()
    external
    view
    returns(string memory);


  function getGlobalBaseTokenURI()
    external
    view
    returns (string memory);


  function globalTokenSymbol()
    external
    view
    returns(string memory);


  function getGlobalTokenSymbol()
    external
    view
    returns (string memory);


  function configUnlock(
    address _udt,
    address _weth,
    uint _estimatedGasForPurchase,
    string calldata _symbol,
    string calldata _URI
  )
    external;


  function setLockTemplate(
    address payable _publicLockAddress
  ) external;


  function resetTrackedValue(
    uint _grossNetworkProduct,
    uint _totalDiscountGranted
  ) external;


  function grossNetworkProduct() external view returns(uint);


  function totalDiscountGranted() external view returns(uint);


  function locks(address) external view returns(bool deployed, uint totalSales, uint yieldedDiscountTokens);


  function publicLockAddress() external view returns(address);


  function uniswapOracles(address) external view returns(address);


  function weth() external view returns(address);


  function udt() external view returns(address);


  function estimatedGasForPurchase() external view returns(uint);


  function unlockVersion() external pure returns(uint16);


  function setOracle(
    address _tokenAddress,
    address _oracleAddress
  ) external;


  function isOwner() external view returns(bool);


  function owner() external view returns(address);


  function renounceOwnership() external;


  function transferOwnership(address newOwner) external;

}


pragma solidity 0.5.17;


interface ILockKeyCancelHook
{

  function onKeyCancel(
    address operator,
    address to,
    uint256 refund
  ) external;

}


pragma solidity 0.5.17;


interface ILockKeyPurchaseHook
{

  function keyPurchasePrice(
    address from,
    address recipient,
    address referrer,
    bytes calldata data
  ) external view
    returns (uint minKeyPrice);


  function onKeyPurchase(
    address from,
    address recipient,
    address referrer,
    bytes calldata data,
    uint minKeyPrice,
    uint pricePaid
  ) external;

}


pragma solidity 0.5.17;










contract MixinLockCore is
  IERC721Enumerable,
  MixinLockManagerRole,
  MixinFunds,
  MixinDisable
{

  using Address for address;

  event Withdrawal(
    address indexed sender,
    address indexed tokenAddress,
    address indexed beneficiary,
    uint amount
  );

  event PricingChanged(
    uint oldKeyPrice,
    uint keyPrice,
    address oldTokenAddress,
    address tokenAddress
  );

  IUnlock public unlockProtocol;

  uint public expirationDuration;

  uint public keyPrice;

  uint public maxNumberOfKeys;

  uint internal _totalSupply;

  address public beneficiary;

  uint internal constant BASIS_POINTS_DEN = 10000;

  ILockKeyPurchaseHook public onKeyPurchaseHook;
  ILockKeyCancelHook public onKeyCancelHook;

  modifier notSoldOut() {

    require(maxNumberOfKeys > _totalSupply, 'LOCK_SOLD_OUT');
    _;
  }

  modifier onlyLockManagerOrBeneficiary()
  {

    require(
      isLockManager(msg.sender) || msg.sender == beneficiary,
      'ONLY_LOCK_MANAGER_OR_BENEFICIARY'
    );
    _;
  }

  function _initializeMixinLockCore(
    address _beneficiary,
    uint _expirationDuration,
    uint _keyPrice,
    uint _maxNumberOfKeys
  ) internal
  {

    require(_expirationDuration <= 100 * 365 * 24 * 60 * 60, 'MAX_EXPIRATION_100_YEARS');
    unlockProtocol = IUnlock(msg.sender); // Make sure we link back to Unlock's smart contract.
    beneficiary = _beneficiary;
    expirationDuration = _expirationDuration;
    keyPrice = _keyPrice;
    maxNumberOfKeys = _maxNumberOfKeys;
  }

  function publicLockVersion(
  ) public pure
    returns (uint)
  {

    return 8;
  }

  function withdraw(
    address _tokenAddress,
    uint _amount
  ) external
    onlyLockManagerOrBeneficiary
  {

    uint balance = getBalance(_tokenAddress, address(this));
    uint amount;
    if(_amount == 0 || _amount > balance)
    {
      require(balance > 0, 'NOT_ENOUGH_FUNDS');
      amount = balance;
    }
    else
    {
      amount = _amount;
    }

    emit Withdrawal(msg.sender, _tokenAddress, beneficiary, amount);
    _transfer(_tokenAddress, beneficiary, amount);
  }

  function updateKeyPricing(
    uint _keyPrice,
    address _tokenAddress
  )
    external
    onlyLockManager
    onlyIfAlive
  {

    uint oldKeyPrice = keyPrice;
    address oldTokenAddress = tokenAddress;
    require(
      _tokenAddress == address(0) || IERC20(_tokenAddress).totalSupply() > 0,
      'INVALID_TOKEN'
    );
    keyPrice = _keyPrice;
    tokenAddress = _tokenAddress;
    emit PricingChanged(oldKeyPrice, keyPrice, oldTokenAddress, tokenAddress);
  }

  function updateBeneficiary(
    address _beneficiary
  ) external
  {

    require(msg.sender == beneficiary || isLockManager(msg.sender), 'ONLY_BENEFICIARY_OR_LOCKMANAGER');
    require(_beneficiary != address(0), 'INVALID_ADDRESS');
    beneficiary = _beneficiary;
  }

  function setEventHooks(
    address _onKeyPurchaseHook,
    address _onKeyCancelHook
  ) external
    onlyLockManager()
  {

    require(_onKeyPurchaseHook == address(0) || _onKeyPurchaseHook.isContract(), 'INVALID_ON_KEY_SOLD_HOOK');
    require(_onKeyCancelHook == address(0) || _onKeyCancelHook.isContract(), 'INVALID_ON_KEY_CANCEL_HOOK');
    onKeyPurchaseHook = ILockKeyPurchaseHook(_onKeyPurchaseHook);
    onKeyCancelHook = ILockKeyCancelHook(_onKeyCancelHook);
  }

  function totalSupply()
    public
    view returns(uint256)
  {

    return _totalSupply;
  }

  function approveBeneficiary(
    address _spender,
    uint _amount
  ) public
    onlyLockManagerOrBeneficiary
    returns (bool)
  {

    return IERC20(tokenAddress).approve(_spender, _amount);
  }
}


pragma solidity 0.5.17;




contract MixinKeys is
  MixinLockCore
{

  using SafeMath for uint;

  struct Key {
    uint tokenId;
    uint expirationTimestamp;
  }

  event ExpireKey(uint indexed tokenId);

  event ExpirationChanged(
    uint indexed _tokenId,
    uint _amount,
    bool _timeAdded
  );

  event KeyManagerChanged(uint indexed _tokenId, address indexed _newManager);


  mapping (address => Key) internal keyByOwner;

  mapping (uint => address) internal _ownerOf;

  address[] public owners;

  mapping (uint => address) public keyManagerOf;

  mapping (uint => address) private approved;

  mapping (address => mapping (address => bool)) private managerToOperatorApproved;

  modifier onlyKeyManagerOrApproved(
    uint _tokenId
  )
  {

    require(
      _isKeyManager(_tokenId, msg.sender) ||
      _isApproved(_tokenId, msg.sender) ||
      isApprovedForAll(_ownerOf[_tokenId], msg.sender),
      'ONLY_KEY_MANAGER_OR_APPROVED'
    );
    _;
  }

  modifier ownsOrHasOwnedKey(
    address _keyOwner
  ) {

    require(
      keyByOwner[_keyOwner].expirationTimestamp > 0, 'HAS_NEVER_OWNED_KEY'
    );
    _;
  }

  modifier hasValidKey(
    address _user
  ) {

    require(
      getHasValidKey(_user), 'KEY_NOT_VALID'
    );
    _;
  }

  modifier isKey(
    uint _tokenId
  ) {

    require(
      _ownerOf[_tokenId] != address(0), 'NO_SUCH_KEY'
    );
    _;
  }

  modifier onlyKeyOwner(
    uint _tokenId
  ) {

    require(
      isKeyOwner(_tokenId, msg.sender), 'ONLY_KEY_OWNER'
    );
    _;
  }

  function balanceOf(
    address _keyOwner
  )
    public
    view
    returns (uint)
  {

    require(_keyOwner != address(0), 'INVALID_ADDRESS');
    return getHasValidKey(_keyOwner) ? 1 : 0;
  }

  function getHasValidKey(
    address _keyOwner
  )
    public
    view
    returns (bool)
  {

    return keyByOwner[_keyOwner].expirationTimestamp > block.timestamp;
  }

  function getTokenIdFor(
    address _account
  ) public view
    returns (uint)
  {

    return keyByOwner[_account].tokenId;
  }

  function getOwnersByPage(uint _page, uint _pageSize)
    public
    view
    returns (address[] memory)
  {

    uint pageSize = _pageSize;
    uint _startIndex = _page * pageSize;
    uint endOfPageIndex;

    if (_startIndex + pageSize > owners.length) {
      endOfPageIndex = owners.length;
      pageSize = owners.length - _startIndex;
    } else {
      endOfPageIndex = (_startIndex + pageSize);
    }

    address[] memory ownersByPage = new address[](pageSize);
    uint pageIndex = 0;

    for (uint i = _startIndex; i < endOfPageIndex; i++) {
      ownersByPage[pageIndex] = owners[i];
      pageIndex++;
    }

    return ownersByPage;
  }

  function isKeyOwner(
    uint _tokenId,
    address _keyOwner
  ) public view
    returns (bool)
  {

    return _ownerOf[_tokenId] == _keyOwner;
  }

  function keyExpirationTimestampFor(
    address _keyOwner
  ) public view
    returns (uint)
  {

    return keyByOwner[_keyOwner].expirationTimestamp;
  }

  function numberOfOwners()
    public
    view
    returns (uint)
  {

    return owners.length;
  }
  function ownerOf(
    uint _tokenId
  ) public view
    returns(address)
  {

    return _ownerOf[_tokenId];
  }

  function setKeyManagerOf(
    uint _tokenId,
    address _keyManager
  ) public
    isKey(_tokenId)
  {

    require(
      _isKeyManager(_tokenId, msg.sender) ||
      isLockManager(msg.sender),
      'UNAUTHORIZED_KEY_MANAGER_UPDATE'
    );
    _setKeyManagerOf(_tokenId, _keyManager);
  }

  function _setKeyManagerOf(
    uint _tokenId,
    address _keyManager
  ) internal
  {

    if(keyManagerOf[_tokenId] != _keyManager) {
      keyManagerOf[_tokenId] = _keyManager;
      _clearApproval(_tokenId);
      emit KeyManagerChanged(_tokenId, address(0));
    }
  }

  function approve(
    address _approved,
    uint _tokenId
  )
    public
    onlyIfAlive
    onlyKeyManagerOrApproved(_tokenId)
  {

    require(msg.sender != _approved, 'APPROVE_SELF');

    approved[_tokenId] = _approved;
    emit Approval(_ownerOf[_tokenId], _approved, _tokenId);
  }

  function getApproved(
    uint _tokenId
  ) public view
    isKey(_tokenId)
    returns (address)
  {

    address approvedRecipient = approved[_tokenId];
    return approvedRecipient;
  }

  function isApprovedForAll(
    address _owner,
    address _operator
  ) public view
    returns (bool)
  {

    uint tokenId = keyByOwner[_owner].tokenId;
    address keyManager = keyManagerOf[tokenId];
    if(keyManager == address(0)) {
      return managerToOperatorApproved[_owner][_operator];
    } else {
      return managerToOperatorApproved[keyManager][_operator];
    }
  }

  function _isKeyManager(
    uint _tokenId,
    address _keyManager
  ) internal view
    returns (bool)
  {

    if(keyManagerOf[_tokenId] == _keyManager ||
      (keyManagerOf[_tokenId] == address(0) && isKeyOwner(_tokenId, _keyManager))) {
      return true;
    } else {
      return false;
    }
  }

  function _assignNewTokenId(
    Key storage _key
  ) internal
  {

    if (_key.tokenId == 0) {
      _totalSupply++;
      _key.tokenId = _totalSupply;
    }
  }

  function _recordOwner(
    address _keyOwner,
    uint _tokenId
  ) internal
  {

    if (_ownerOf[_tokenId] != _keyOwner) {
      owners.push(_keyOwner);
      _ownerOf[_tokenId] = _keyOwner;
    }
  }

  function _timeMachine(
    uint _tokenId,
    uint256 _deltaT,
    bool _addTime
  ) internal
  {

    address tokenOwner = _ownerOf[_tokenId];
    require(tokenOwner != address(0), 'NON_EXISTENT_KEY');
    Key storage key = keyByOwner[tokenOwner];
    uint formerTimestamp = key.expirationTimestamp;
    bool validKey = getHasValidKey(tokenOwner);
    if(_addTime) {
      if(validKey) {
        key.expirationTimestamp = formerTimestamp.add(_deltaT);
      } else {
        key.expirationTimestamp = block.timestamp.add(_deltaT);
      }
    } else {
      key.expirationTimestamp = formerTimestamp.sub(_deltaT);
    }
    emit ExpirationChanged(_tokenId, _deltaT, _addTime);
  }

  function setApprovalForAll(
    address _to,
    bool _approved
  ) public
    onlyIfAlive
  {

    require(_to != msg.sender, 'APPROVE_SELF');
    managerToOperatorApproved[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  function _isApproved(
    uint _tokenId,
    address _user
  ) internal view
    returns (bool)
  {

    return approved[_tokenId] == _user;
  }

  function _clearApproval(
    uint256 _tokenId
  ) internal
  {

    if (approved[_tokenId] != address(0)) {
      approved[_tokenId] = address(0);
    }
  }
}


pragma solidity 0.5.17;






contract MixinERC721Enumerable is
  IERC721Enumerable,
  ERC165,
  MixinLockCore, // Implements totalSupply
  MixinKeys
{

  function _initializeMixinERC721Enumerable() internal
  {

    _registerInterface(0x780e9d63);
  }

  function tokenByIndex(
    uint256 _index
  ) public view
    returns (uint256)
  {

    require(_index < _totalSupply, 'OUT_OF_RANGE');
    return _index;
  }

  function tokenOfOwnerByIndex(
    address _keyOwner,
    uint256 _index
  ) public view
    returns (uint256)
  {

    require(_index == 0, 'ONLY_ONE_KEY_PER_OWNER');
    return getTokenIdFor(_keyOwner);
  }
}


pragma solidity 0.5.17;





contract MixinKeyGranterRole is MixinLockManagerRole {

  using Roles for Roles.Role;

  event KeyGranterAdded(address indexed account);
  event KeyGranterRemoved(address indexed account);

  Roles.Role private keyGranters;

  function _initializeMixinKeyGranterRole(address sender) internal {

    if (!isKeyGranter(sender)) {
      keyGranters.add(sender);
    }
  }

  modifier onlyKeyGranterOrManager() {

    require(isKeyGranter(msg.sender) || isLockManager(msg.sender), 'MixinKeyGranter: caller does not have the KeyGranter or LockManager role');
    _;
  }

  function isKeyGranter(address account) public view returns (bool) {

    return keyGranters.has(account);
  }

  function addKeyGranter(address account) public onlyLockManager {

    keyGranters.add(account);
    emit KeyGranterAdded(account);
  }

  function revokeKeyGranter(address _granter) public onlyLockManager {

    keyGranters.remove(_granter);
    emit KeyGranterRemoved(_granter);
  }
}


pragma solidity 0.5.17;




contract MixinGrantKeys is
  MixinKeyGranterRole,
  MixinKeys
{

  function grantKeys(
    address[] calldata _recipients,
    uint[] calldata _expirationTimestamps,
    address[] calldata _keyManagers
  ) external
    onlyKeyGranterOrManager
  {

    for(uint i = 0; i < _recipients.length; i++) {
      address recipient = _recipients[i];
      uint expirationTimestamp = _expirationTimestamps[i];
      address keyManager = _keyManagers[i];

      require(recipient != address(0), 'INVALID_ADDRESS');

      Key storage toKey = keyByOwner[recipient];
      require(expirationTimestamp > toKey.expirationTimestamp, 'ALREADY_OWNS_KEY');

      uint idTo = toKey.tokenId;

      if(idTo == 0) {
        _assignNewTokenId(toKey);
        idTo = toKey.tokenId;
        _recordOwner(recipient, idTo);
      }
      _setKeyManagerOf(idTo, keyManager);
      emit KeyManagerChanged(idTo, keyManager);

      toKey.expirationTimestamp = expirationTimestamp;
      emit Transfer(
        address(0), // This is a creation.
        recipient,
        idTo
      );
    }
  }
}


pragma solidity 0.5.17;


library UnlockUtils {


  function strConcat(
    string memory _a,
    string memory _b,
    string memory _c,
    string memory _d
  ) internal pure
    returns (string memory _concatenatedString)
  {

    return string(abi.encodePacked(_a, _b, _c, _d));
  }

  function uint2Str(
    uint _i
  ) internal pure
    returns (string memory _uintAsString)
  {

    uint c = _i;
    if (_i == 0) {
      return '0';
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (c != 0) {
      bstr[k--] = byte(uint8(48 + c % 10));
      c /= 10;
    }
    return string(bstr);
  }

  function address2Str(
    address _addr
  ) internal pure
    returns(string memory)
  {

    bytes32 value = bytes32(uint256(_addr));
    bytes memory alphabet = '0123456789abcdef';
    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint i = 0; i < 20; i++) {
      str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
      str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
    return string(str);
  }
}


pragma solidity 0.5.17;







contract MixinLockMetadata is
  IERC721Enumerable,
  ERC165,
  MixinLockManagerRole,
  MixinLockCore,
  MixinKeys
{

  using UnlockUtils for uint;
  using UnlockUtils for address;
  using UnlockUtils for string;

  string public name;

  string private lockSymbol;

  string private baseTokenURI;

  event NewLockSymbol(
    string symbol
  );

  function _initializeMixinLockMetadata(
    string memory _lockName
  ) internal
  {

    ERC165.initialize();
    name = _lockName;
    _registerInterface(0x5b5e139f);
  }

  function updateLockName(
    string calldata _lockName
  ) external
    onlyLockManager
  {

    name = _lockName;
  }

  function updateLockSymbol(
    string calldata _lockSymbol
  ) external
    onlyLockManager
  {

    lockSymbol = _lockSymbol;
    emit NewLockSymbol(_lockSymbol);
  }

  function symbol()
    external view
    returns(string memory)
  {

    if(bytes(lockSymbol).length == 0) {
      return unlockProtocol.globalTokenSymbol();
    } else {
      return lockSymbol;
    }
  }

  function setBaseTokenURI(
    string calldata _baseTokenURI
  ) external
    onlyLockManager
  {

    baseTokenURI = _baseTokenURI;
  }

  function tokenURI(
    uint256 _tokenId
  ) external
    view
    returns(string memory)
  {

    string memory URI;
    string memory tokenId;
    string memory lockAddress = address(this).address2Str();
    string memory seperator;

    if(_tokenId != 0) {
      tokenId = _tokenId.uint2Str();
    } else {
      tokenId = '';
    }

    if(bytes(baseTokenURI).length == 0) {
      URI = unlockProtocol.globalBaseTokenURI();
      seperator = '/';
    } else {
      URI = baseTokenURI;
      seperator = '';
      lockAddress = '';
    }

    return URI.strConcat(
        lockAddress,
        seperator,
        tokenId
      );
  }
}


pragma solidity 0.5.17;







contract MixinPurchase is
  MixinFunds,
  MixinDisable,
  MixinLockCore,
  MixinKeys
{

  using SafeMath for uint;

  event RenewKeyPurchase(address indexed owner, uint newExpiration);

  function purchase(
    uint256 _value,
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external payable
    onlyIfAlive
    notSoldOut
  {

    require(_recipient != address(0), 'INVALID_ADDRESS');

    Key storage toKey = keyByOwner[_recipient];
    uint idTo = toKey.tokenId;
    uint newTimeStamp;

    if (idTo == 0) {
      _assignNewTokenId(toKey);
      idTo = toKey.tokenId;
      _recordOwner(_recipient, idTo);
      newTimeStamp = block.timestamp + expirationDuration;
      toKey.expirationTimestamp = newTimeStamp;

      emit Transfer(
        address(0), // This is a creation.
        _recipient,
        idTo
      );
    } else if (toKey.expirationTimestamp > block.timestamp) {
      newTimeStamp = toKey.expirationTimestamp.add(expirationDuration);
      toKey.expirationTimestamp = newTimeStamp;
      emit RenewKeyPurchase(_recipient, newTimeStamp);
    } else {
      newTimeStamp = block.timestamp + expirationDuration;
      toKey.expirationTimestamp = newTimeStamp;

      _setKeyManagerOf(idTo, address(0));

      emit RenewKeyPurchase(_recipient, newTimeStamp);
    }

    (uint inMemoryKeyPrice, uint discount, uint tokens) = _purchasePriceFor(_recipient, _referrer, _data);
    if (discount > 0)
    {
      unlockProtocol.recordConsumedDiscount(discount, tokens);
    }

    unlockProtocol.recordKeyPurchase(inMemoryKeyPrice, getHasValidKey(_referrer) && _referrer != _recipient ? _referrer : address(0));

    uint pricePaid;
    if(tokenAddress != address(0))
    {
      pricePaid = _value;
      IERC20 token = IERC20(tokenAddress);
      token.safeTransferFrom(msg.sender, address(this), _value);
    }
    else
    {
      pricePaid = msg.value;
    }
    require(pricePaid >= inMemoryKeyPrice, 'INSUFFICIENT_VALUE');

    if(address(onKeyPurchaseHook) != address(0))
    {
      onKeyPurchaseHook.onKeyPurchase(msg.sender, _recipient, _referrer, _data, inMemoryKeyPrice, pricePaid);
    }
  }

  function purchasePriceFor(
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external view
    returns (uint minKeyPrice)
  {

    (minKeyPrice, , ) = _purchasePriceFor(_recipient, _referrer, _data);
  }

  function _purchasePriceFor(
    address _recipient,
    address _referrer,
    bytes memory _data
  ) internal view
    returns (uint minKeyPrice, uint unlockDiscount, uint unlockTokens)
  {

    if(address(onKeyPurchaseHook) != address(0))
    {
      minKeyPrice = onKeyPurchaseHook.keyPurchasePrice(msg.sender, _recipient, _referrer, _data);
    }
    else
    {
      minKeyPrice = keyPrice;
    }

    if(minKeyPrice > 0)
    {
      (unlockDiscount, unlockTokens) = unlockProtocol.computeAvailableDiscountFor(_recipient, minKeyPrice);
      require(unlockDiscount <= minKeyPrice, 'INVALID_DISCOUNT_FROM_UNLOCK');
      minKeyPrice -= unlockDiscount;
    }
  }
}


pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity 0.5.17;



contract MixinSignatures
{

  event NonceChanged(
    address indexed keyManager,
    uint nextAvailableNonce
  );

  mapping(address => uint) public keyManagerToNonce;

  modifier consumeOffchainApproval(
    bytes32 _hash,
    address _keyManager,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  )
  {

    require(
      ecrecover(
        ECDSA.toEthSignedMessageHash(_hash),
        _v,
        _r,
        _s
      ) == _keyManager, 'INVALID_SIGNATURE'
    );
    keyManagerToNonce[_keyManager]++;
    emit NonceChanged(_keyManager, keyManagerToNonce[_keyManager]);
    _;
  }

  function invalidateOffchainApproval(
    uint _nextAvailableNonce
  ) external
  {

    require(_nextAvailableNonce > keyManagerToNonce[msg.sender], 'NONCE_ALREADY_USED');
    keyManagerToNonce[msg.sender] = _nextAvailableNonce;
    emit NonceChanged(msg.sender, _nextAvailableNonce);
  }
}


pragma solidity 0.5.17;








contract MixinRefunds is
  MixinLockManagerRole,
  MixinSignatures,
  MixinFunds,
  MixinLockCore,
  MixinKeys
{

  using SafeMath for uint;

  uint public refundPenaltyBasisPoints;

  uint public freeTrialLength;

  bytes32 private constant CANCEL_TYPEHASH = keccak256('cancelAndRefundFor(address _keyOwner)');

  event CancelKey(
    uint indexed tokenId,
    address indexed owner,
    address indexed sendTo,
    uint refund
  );

  event RefundPenaltyChanged(
    uint freeTrialLength,
    uint refundPenaltyBasisPoints
  );

  function _initializeMixinRefunds() internal
  {

    refundPenaltyBasisPoints = 1000;
  }

  function expireAndRefundFor(
    address _keyOwner,
    uint amount
  ) external
    onlyLockManager
    hasValidKey(_keyOwner)
  {

    _cancelAndRefund(_keyOwner, amount);
  }

  function cancelAndRefund(uint _tokenId)
    external
    onlyKeyManagerOrApproved(_tokenId)
  {

    address keyOwner = ownerOf(_tokenId);
    uint refund = _getCancelAndRefundValue(keyOwner);

    _cancelAndRefund(keyOwner, refund);
  }

  function cancelAndRefundFor(
    address _keyManager,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    uint _tokenId
  ) external
    consumeOffchainApproval(
      getCancelAndRefundApprovalHash(_keyManager, msg.sender),
      _keyManager,
      _v,
      _r,
      _s
    )
  {

    address keyOwner = ownerOf(_tokenId);
    uint refund = _getCancelAndRefundValue(keyOwner);
    _cancelAndRefund(keyOwner, refund);
  }

  function updateRefundPenalty(
    uint _freeTrialLength,
    uint _refundPenaltyBasisPoints
  ) external
    onlyLockManager
  {

    emit RefundPenaltyChanged(
      _freeTrialLength,
      _refundPenaltyBasisPoints
    );

    freeTrialLength = _freeTrialLength;
    refundPenaltyBasisPoints = _refundPenaltyBasisPoints;
  }

  function getCancelAndRefundValueFor(
    address _keyOwner
  )
    external view
    returns (uint refund)
  {

    return _getCancelAndRefundValue(_keyOwner);
  }

  function getCancelAndRefundApprovalHash(
    address _keyManager,
    address _txSender
  ) public view
    returns (bytes32 approvalHash)
  {

    return keccak256(
      abi.encodePacked(
        address(this),
        CANCEL_TYPEHASH,
        keyManagerToNonce[_keyManager],
        _txSender
      )
    );
  }

  function _cancelAndRefund(
    address _keyOwner,
    uint refund
  ) internal
  {

    Key storage key = keyByOwner[_keyOwner];

    emit CancelKey(key.tokenId, _keyOwner, msg.sender, refund);
    key.expirationTimestamp = block.timestamp;

    if (refund > 0) {
      _transfer(tokenAddress, _keyOwner, refund);
    }

    if(address(onKeyCancelHook) != address(0))
    {
      onKeyCancelHook.onKeyCancel(msg.sender, _keyOwner, refund);
    }
  }

  function _getCancelAndRefundValue(
    address _keyOwner
  )
    private view
    hasValidKey(_keyOwner)
    returns (uint refund)
  {

    Key storage key = keyByOwner[_keyOwner];
    uint timeRemaining = key.expirationTimestamp - block.timestamp;
    if(timeRemaining + freeTrialLength >= expirationDuration) {
      refund = keyPrice;
    } else {
      refund = keyPrice.mul(timeRemaining) / expirationDuration;
    }

    if(freeTrialLength == 0 || timeRemaining + freeTrialLength < expirationDuration)
    {
      uint penalty = keyPrice.mul(refundPenaltyBasisPoints) / BASIS_POINTS_DEN;
      if (refund > penalty) {
        refund -= penalty;
      } else {
        refund = 0;
      }
    }
  }
}


pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity 0.5.17;










contract MixinTransfer is
  MixinLockManagerRole,
  MixinFunds,
  MixinLockCore,
  MixinKeys
{

  using SafeMath for uint;
  using Address for address;

  event TransferFeeChanged(
    uint transferFeeBasisPoints
  );

  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

  uint public transferFeeBasisPoints;

  function shareKey(
    address _to,
    uint _tokenId,
    uint _timeShared
  ) public
    onlyIfAlive
    onlyKeyManagerOrApproved(_tokenId)
  {

    require(transferFeeBasisPoints < BASIS_POINTS_DEN, 'KEY_TRANSFERS_DISABLED');
    require(_to != address(0), 'INVALID_ADDRESS');
    address keyOwner = _ownerOf[_tokenId];
    require(getHasValidKey(keyOwner), 'KEY_NOT_VALID');
    Key storage fromKey = keyByOwner[keyOwner];
    Key storage toKey = keyByOwner[_to];
    uint idTo = toKey.tokenId;
    uint time;
    uint timeRemaining = fromKey.expirationTimestamp - block.timestamp;
    uint fee = getTransferFee(keyOwner, _timeShared);
    uint timePlusFee = _timeShared.add(fee);

    if(timePlusFee < timeRemaining) {
      time = _timeShared;
      _timeMachine(_tokenId, timePlusFee, false);
    } else {
      fee = getTransferFee(keyOwner, timeRemaining);
      time = timeRemaining - fee;
      fromKey.expirationTimestamp = block.timestamp; // Effectively expiring the key
      emit ExpireKey(_tokenId);
    }

    if (idTo == 0) {
      _assignNewTokenId(toKey);
      idTo = toKey.tokenId;
      _recordOwner(_to, idTo);
      emit Transfer(
        address(0), // This is a creation or time-sharing
        _to,
        idTo
      );
    } else if (toKey.expirationTimestamp <= block.timestamp) {
      _setKeyManagerOf(idTo, address(0));
    }

    _timeMachine(idTo, time, true);
    emit Transfer(
      keyOwner,
      _to,
      idTo
    );

    require(_checkOnERC721Received(keyOwner, _to, _tokenId, ''), 'NON_COMPLIANT_ERC721_RECEIVER');
  }

  function transferFrom(
    address _from,
    address _recipient,
    uint _tokenId
  )
    public
    onlyIfAlive
    hasValidKey(_from)
    onlyKeyManagerOrApproved(_tokenId)
  {

    require(isKeyOwner(_tokenId, _from), 'TRANSFER_FROM: NOT_KEY_OWNER');
    require(transferFeeBasisPoints < BASIS_POINTS_DEN, 'KEY_TRANSFERS_DISABLED');
    require(_recipient != address(0), 'INVALID_ADDRESS');
    uint fee = getTransferFee(_from, 0);

    Key storage fromKey = keyByOwner[_from];
    Key storage toKey = keyByOwner[_recipient];

    uint previousExpiration = toKey.expirationTimestamp;
    _timeMachine(_tokenId, fee, false);

    if (toKey.tokenId == 0) {
      toKey.tokenId = _tokenId;
      _recordOwner(_recipient, _tokenId);
      _clearApproval(_tokenId);
    }

    if (previousExpiration <= block.timestamp) {
      toKey.expirationTimestamp = fromKey.expirationTimestamp;
      toKey.tokenId = _tokenId;

      _setKeyManagerOf(_tokenId, address(0));

      _recordOwner(_recipient, _tokenId);
    } else {
      toKey.expirationTimestamp = fromKey
        .expirationTimestamp.add(previousExpiration - block.timestamp);
    }

    fromKey.expirationTimestamp = block.timestamp;

    fromKey.tokenId = 0;

    emit Transfer(
      _from,
      _recipient,
      _tokenId
    );
  }

  function transfer(
    address _to,
    uint _value
  ) public
    returns (bool success)
  {

    uint maxTimeToSend = _value * expirationDuration;
    Key storage fromKey = keyByOwner[msg.sender];
    uint timeRemaining = fromKey.expirationTimestamp.sub(block.timestamp);
    if(maxTimeToSend < timeRemaining)
    {
      shareKey(_to, fromKey.tokenId, maxTimeToSend);
    }
    else
    {
      transferFrom(msg.sender, _to, fromKey.tokenId);
    }

    return true;
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint _tokenId
  )
    public
  {

    safeTransferFrom(_from, _to, _tokenId, '');
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint _tokenId,
    bytes memory _data
  )
    public
  {

    transferFrom(_from, _to, _tokenId);
    require(_checkOnERC721Received(_from, _to, _tokenId, _data), 'NON_COMPLIANT_ERC721_RECEIVER');

  }

  function updateTransferFee(
    uint _transferFeeBasisPoints
  )
    external
    onlyLockManager
  {

    emit TransferFeeChanged(
      _transferFeeBasisPoints
    );
    transferFeeBasisPoints = _transferFeeBasisPoints;
  }

  function getTransferFee(
    address _keyOwner,
    uint _time
  )
    public view
    returns (uint)
  {

    if(! getHasValidKey(_keyOwner)) {
      return 0;
    } else {
      Key storage key = keyByOwner[_keyOwner];
      uint timeToTransfer;
      uint fee;
      if(_time == 0) {
        timeToTransfer = key.expirationTimestamp - block.timestamp;
      } else {
        timeToTransfer = _time;
      }
      fee = timeToTransfer.mul(transferFeeBasisPoints) / BASIS_POINTS_DEN;
      return fee;
    }
  }

  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  )
    internal
    returns (bool)
  {

    if (!to.isContract()) {
      return true;
    }
    bytes4 retval = IERC721Receiver(to).onERC721Received(
      msg.sender, from, tokenId, _data);
    return (retval == _ERC721_RECEIVED);
  }

}


pragma solidity 0.5.17;


















contract PublicLock is
  IPublicLock,
  Initializable,
  ERC165,
  MixinLockManagerRole,
  MixinKeyGranterRole,
  MixinSignatures,
  MixinFunds,
  MixinDisable,
  MixinLockCore,
  MixinKeys,
  MixinLockMetadata,
  MixinERC721Enumerable,
  MixinGrantKeys,
  MixinPurchase,
  MixinTransfer,
  MixinRefunds
{

  function initialize(
    address _lockCreator,
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string memory _lockName
  ) public
    initializer()
  {

    MixinFunds._initializeMixinFunds(_tokenAddress);
    MixinDisable._initializeMixinDisable();
    MixinLockCore._initializeMixinLockCore(_lockCreator, _expirationDuration, _keyPrice, _maxNumberOfKeys);
    MixinLockMetadata._initializeMixinLockMetadata(_lockName);
    MixinERC721Enumerable._initializeMixinERC721Enumerable();
    MixinRefunds._initializeMixinRefunds();
    MixinLockManagerRole._initializeMixinLockManagerRole(_lockCreator);
    MixinKeyGranterRole._initializeMixinKeyGranterRole(_lockCreator);
    _registerInterface(0x80ac58cd);
  }

  function() external payable {}
}