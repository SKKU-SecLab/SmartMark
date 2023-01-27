

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



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;



interface IPublicLockV7Sol6
{




  function initialize(
    address _lockCreator,
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName
  ) external;


  receive() external payable;

  function initialize() external;


  function publicLockVersion() external pure returns (uint);


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


    function balanceOf(address _owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address _owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 _tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address _owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;


    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}


pragma solidity 0.6.6;



contract LockRoles
{

  modifier onlyLockManager(
    IPublicLockV7Sol6 _lock
  )
  {

    require(_lock.isLockManager(msg.sender), 'ONLY_LOCK_MANAGER');
    _;
  }

  modifier onlyKeyGranterOrManager(
    IPublicLockV7Sol6 _lock
  )
  {

    require(_lock.isKeyGranter(msg.sender) || _lock.isLockManager(msg.sender), 'ONLY_KEY_GRANTER');
    _;
  }
}


pragma solidity 0.6.6;








contract KeyPurchaser is Initializable, LockRoles
{

  using Address for address payable;
  using SafeERC20 for IERC20;
  using SafeMath for uint;

  event Stopped(address account);


  IPublicLockV7Sol6 public lock;

  uint public maxPurchasePrice;

  uint public renewWindow;

  uint public renewMinFrequency;

  uint public msgSenderReward;


  string public name;

  bool internal hidden;

  bool public stopped;


  mapping(address => uint) public timestampOfLastPurchase;

  function initialize(
    IPublicLockV7Sol6 _lock,
    uint _maxPurchasePrice,
    uint _renewWindow,
    uint _renewMinFrequency,
    uint _msgSenderReward
  ) public
    initializer()
  {

    lock = _lock;
    maxPurchasePrice = _maxPurchasePrice;
    renewWindow = _renewWindow;
    renewMinFrequency = _renewMinFrequency;
    msgSenderReward = _msgSenderReward;
    approveSpending();
  }

  modifier whenNotStopped()
  {

    require(!stopped, 'Stoppable: stopped');
    _;
  }

  function stop() public onlyLockManager(lock) whenNotStopped
  {

    stopped = true;
    emit Stopped(msg.sender);
  }

  function approveSpending() public
  {

    IERC20 token = IERC20(lock.tokenAddress());
    if(address(token) != address(0))
    {
      token.approve(address(lock), uint(-1));
    }
  }

  function config(
    string memory _name,
    bool _hidden
  ) public
    onlyLockManager(lock)
  {

    name = _name;
    hidden = _hidden;
  }

  function shouldBeDisplayed() public view returns(bool)
  {

    return !stopped && !hidden;
  }

  function _readyToPurchaseFor(
    address payable _recipient,
    address _referrer,
    bytes memory _data
  ) private view
    whenNotStopped
    returns(uint purchasePrice)
  {

    uint lastPurchase = timestampOfLastPurchase[_recipient];
    require(now - lastPurchase >= renewMinFrequency, 'BEFORE_MIN_FREQUENCY');

    uint expiration = lock.keyExpirationTimestampFor(_recipient);
    require(expiration <= now || expiration - now <= renewWindow, 'OUTSIDE_RENEW_WINDOW');

    purchasePrice = lock.purchasePriceFor(_recipient, _referrer, _data);
    require(purchasePrice <= maxPurchasePrice, 'PRICE_TOO_HIGH');
  }

  function readyToPurchaseFor(
    address payable _recipient,
    address _referrer,
    bytes memory _data
  ) public view
  {

    uint purchasePrice = _readyToPurchaseFor(_recipient, _referrer, _data);
    purchasePrice = purchasePrice.add(msgSenderReward);

    IERC20 token = IERC20(lock.tokenAddress());
    require(token.balanceOf(_recipient) >= purchasePrice, 'INSUFFICIENT_BALANCE');
    require(token.allowance(_recipient, address(this)) >= purchasePrice, 'INSUFFICIENT_ALLOWANCE');
  }

  function purchaseFor(
    address payable _recipient,
    address _referrer,
    bytes memory _data
  ) public
  {

    IERC20 token = IERC20(lock.tokenAddress());

    uint keyPrice = _readyToPurchaseFor(_recipient, _referrer, _data);
    uint totalCost = keyPrice.add(msgSenderReward);
    if(totalCost > 0)
    {
      token.transferFrom(_recipient, address(this), totalCost);
      if(msgSenderReward > 0)
      {
        token.transfer(msg.sender, msgSenderReward);
      }

    }

    lock.purchase(keyPrice, _recipient, _referrer, _data);
    timestampOfLastPurchase[_recipient] = now;

  }
}


pragma solidity ^0.6.0;


library Clone2Factory
{

  function createClone2(
    address target,
    bytes32 salt
  ) internal
    returns (address proxyAddress)
  {

    assembly
    {
      let pointer := mload(0x40)

      mstore(pointer, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(pointer, 0x14), shl(96, target))
      mstore(add(pointer, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)


      let contractCodeHash := keccak256(pointer, 0x37)

      mstore(add(pointer, 0x100), salt)

      mstore(add(pointer, 0x40), 0xff00000000000000000000000000000000000000000000000000000000000000)
      mstore(add(pointer, 0x41), shl(96, address()))
      mstore(add(pointer, 0x55), mload(add(pointer, 0x100)))
      mstore(add(pointer, 0x75), contractCodeHash)

      proxyAddress := keccak256(add(pointer, 0x40), 0x55)

      switch extcodesize(proxyAddress)
      case 0 {
        proxyAddress := create2(0, pointer, 0x37, mload(add(pointer, 0x100)))
      }
      default {
        proxyAddress := 0
      }
    }

    require(proxyAddress != address(0), 'PROXY_DEPLOY_FAILED');
  }
}


pragma solidity ^0.6.0;


library Clone2Probe
{

  function getClone2Address(
    address target,
    bytes32 salt
  ) internal view
    returns (address cloneAddress)
  {

    assembly
    {
      let pointer := mload(0x40)

      mstore(pointer, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(pointer, 0x14), shl(96, target))
      mstore(add(pointer, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let contractCodeHash := keccak256(pointer, 0x37)

      mstore(pointer, 0xff00000000000000000000000000000000000000000000000000000000000000)
      mstore(add(pointer, 0x1), shl(96, address()))

      mstore(add(pointer, 0x15), salt)

      mstore(add(pointer, 0x35), contractCodeHash)

      cloneAddress := keccak256(pointer, 0x55)
    }
  }
}


pragma solidity 0.6.6;





contract KeyPurchaserFactory
{

  using Clone2Factory for address;
  using Clone2Probe for address;

  event KeyPurchaserCreated(address indexed forLock, address indexed keyPurchaser);

  address public keyPurchaserTemplate;

  mapping(address => address[]) public lockToKeyPurchasers;

  constructor() public
  {
    keyPurchaserTemplate = address(new KeyPurchaser());
  }

  function _getClone2Salt(
    IPublicLockV7Sol6 _lock,
    uint _maxKeyPrice,
    uint _renewWindow,
    uint _renewMinFrequency,
    uint _msgSenderReward,
    uint _nonce
  ) private pure
    returns (bytes32)
  {

    return keccak256(abi.encodePacked(address(_lock), _maxKeyPrice, _renewWindow, _renewMinFrequency, _msgSenderReward, _nonce));
  }

  function getExpectedAddress(
    IPublicLockV7Sol6 _lock,
    uint _maxKeyPrice,
    uint _renewWindow,
    uint _renewMinFrequency,
    uint _msgSenderReward,
    uint _nonce
  ) external view
    returns (address)
  {

    bytes32 salt = _getClone2Salt(_lock, _maxKeyPrice, _renewWindow, _renewMinFrequency, _msgSenderReward, _nonce);
    return keyPurchaserTemplate.getClone2Address(salt);
  }

  function deployKeyPurchaser(
    IPublicLockV7Sol6 _lock,
    uint _maxKeyPrice,
    uint _renewWindow,
    uint _renewMinFrequency,
    uint _msgSenderReward,
    uint _nonce
  ) public
  {

    bytes32 salt = _getClone2Salt(_lock, _maxKeyPrice, _renewWindow, _renewMinFrequency, _msgSenderReward, _nonce);
    address purchaser = keyPurchaserTemplate.createClone2(salt);

    KeyPurchaser(purchaser).initialize(_lock, _maxKeyPrice, _renewWindow, _renewMinFrequency, _msgSenderReward);
    lockToKeyPurchasers[address(_lock)].push(purchaser);
    emit KeyPurchaserCreated(address(_lock), purchaser);
  }

  function getKeyPurchasers(
    address _lock
  ) public view
    returns (address[] memory)
  {

    return lockToKeyPurchasers[_lock];
  }

  function getKeyPurchaserCount(
    address _lock
  ) public view
    returns (uint)
  {

    return lockToKeyPurchasers[_lock].length;
  }
}