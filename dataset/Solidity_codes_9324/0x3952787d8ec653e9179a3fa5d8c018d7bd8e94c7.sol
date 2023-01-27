
pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}// MIT

pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


contract ProxyAdmin is Ownable {

    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(
        TransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) public payable virtual onlyOwner {

        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}// MIT
pragma solidity >=0.5.0;

interface IUniswapOracle
{

    function PERIOD() external returns (uint);

    function factory() external returns (address);

    function update(
      address _tokenIn,
      address _tokenOut
    ) external;

    function consult(
      address _tokenIn,
      uint _amountIn,
      address _tokenOut
    ) external view
      returns (uint _amountOut);

    function updateAndConsult(
      address _tokenIn,
      uint _amountIn,
      address _tokenOut
    ) external
      returns (uint _amountOut);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


abstract contract UnlockInitializable {
    bool private initialized;

    bool private initializing;

    modifier initializer() {
        require(initializing ? _isConstructor() : !initialized, "ALREADY_INITIALIZED");

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

    modifier onlyInitializing() {
        require(initializing, "NOT_INITIALIZING");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract UnlockContextUpgradeable is UnlockInitializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private ______gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract UnlockOwnable is UnlockInitializable, UnlockContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __initializeOwnable(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "ONLY_OWNER");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0), "INVALID_OWNER");
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[50] private ______gap;
}// MIT
pragma solidity >=0.5.17 <0.9.0;
pragma experimental ABIEncoderV2;



interface IPublicLock
{



  function initialize(
    address _lockCreator,
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName
  ) external;



  function DEFAULT_ADMIN_ROLE() external pure returns (bytes32);

  function KEY_GRANTER_ROLE() external pure returns (bytes32);

  function LOCK_MANAGER_ROLE() external pure returns (bytes32);


  function publicLockVersion() external pure returns (uint16);


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


  function setExpirationDuration(uint _newExpirationDuration) external;


  function updateBeneficiary( address _beneficiary ) external;


  function getHasValidKey(
    address _user
  ) external view returns (bool);


  function keyExpirationTimestampFor(
    uint _tokenId
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
    address _onKeyCancelHook,
    address _onValidKeyHook,
    address _onTokenURIHook
  ) external;


  function grantKeys(
    address[] calldata _recipients,
    uint[] calldata _expirationTimestamps,
    address[] calldata _keyManagers
  ) external;


  function purchase(
    uint256[] calldata _values,
    address[] calldata _recipients,
    address[] calldata _referrers,
    address[] calldata _keyManagers,
    bytes[] calldata _data
  ) external payable;

  
  function extend(
    uint _value,
    uint _tokenId,
    address _referrer,
    bytes calldata _data
  ) external payable;


  function mergeKeys(uint _tokenIdFrom, uint _tokenIdTo, uint _amount) external;


  function burn(uint _tokenId) external;


  function setGasRefundValue(uint256 _gasRefundValue) external;

  
  function gasRefundValue() external view returns (uint256 _gasRefundValue);


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
    uint _tokenId,
    uint _time
  ) external view returns (uint);


  function expireAndRefundFor(
    uint _tokenId,
    uint _amount
  ) external;


  function cancelAndRefund(uint _tokenId) external;


  function updateRefundPenalty(
    uint _freeTrialLength,
    uint _refundPenaltyBasisPoints
  ) external;


  function getCancelAndRefundValue(
    address _keyOwner
  ) external view returns (uint refund);


  function addKeyGranter(address account) external;


  function addLockManager(address account) external;


  function isKeyGranter(address account) external view returns (bool);


  function isLockManager(address account) external view returns (bool);


  function onKeyPurchaseHook() external view returns(address);


  function onKeyCancelHook() external view returns(address);

  
  function onValidKeyHook() external view returns(bool);


  function onTokenURIHook() external view returns(string memory);


  function revokeKeyGranter(address _granter) external;


  function renounceLockManager() external;


  function setMaxNumberOfKeys (uint _maxNumberOfKeys) external;

  function setMaxKeysPerAddress (uint _maxKeysPerAddress) external;

  function maxKeysPerAddress() external view returns (uint);




  function beneficiary() external view returns (address );


  function expirationDuration() external view returns (uint256 );


  function freeTrialLength() external view returns (uint256 );


  function keyPrice() external view returns (uint256 );


  function maxNumberOfKeys() external view returns (uint256 );


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

  
  function isValidKey(
    uint _tokenId
  )
    external
    view
    returns (bool);

  
  function name() external view returns (string memory _name);


  function supportsInterface(bytes4 interfaceId) external view returns (bool);


  function balanceOf(address _owner) external view returns (uint256 balance);


  function ownerOf(uint256 tokenId) external view returns (address _owner);


  function safeTransferFrom(address from, address to, uint256 tokenId) external;

  
  function transferFrom(address from, address to, uint256 tokenId) external;

  function approve(address to, uint256 tokenId) external;


  function getApproved(uint256 _tokenId) external view returns (address operator);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator) external view returns (bool);


  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;


  function totalSupply() external view returns (uint256);

  function tokenOfOwnerByIndex(address _owner, uint256 index) external view returns (uint256 tokenId);


  function tokenByIndex(uint256 index) external view returns (uint256);


  function getRoleAdmin(bytes32 role) external view returns (bytes32);

  function grantRole(bytes32 role, address account) external;

  function revokeRole(bytes32 role, address account) external;

  function renounceRole(bytes32 role, address account) external;

  function hasRole(bytes32 role, address account) external view returns (bool);


  function transfer(
    address _to,
    uint _value
  ) external
    returns (bool success);


  function owner() external view returns (address);

  function setOwner(address account) external;

  function isOwner(address account) external returns (bool);


  function migrate(bytes calldata _calldata) external;


  function schemaVersion() external view returns (uint);


  function updateSchemaVersion() external;


  function renewMembershipFor(
    uint _tokenId,
    address _referrer
  ) external;

}// MIT
pragma solidity >=0.5.17 <0.9.0;

interface IMintableERC20
{

  function mint(address account, uint256 amount) external returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function totalSupply() external returns (uint);

  function balanceOf(address account) external returns (uint256);

}// MIT
pragma solidity ^0.8.7;



contract Unlock is
  UnlockInitializable,
  UnlockOwnable
{


  struct LockBalances
  {
    bool deployed;
    uint totalSales; // This is in wei
    uint yieldedDiscountTokens;
  }

  modifier onlyFromDeployedLock() {

    require(locks[msg.sender].deployed, 'ONLY_LOCKS');
    _;
  }

  uint public grossNetworkProduct;

  uint public totalDiscountGranted;

  mapping (address => LockBalances) public locks;

  string public globalBaseTokenURI;

  string public globalTokenSymbol;

  address public publicLockAddress;

  mapping (address => IUniswapOracle) public uniswapOracles;

  address public weth;

  address public udt;

  uint public estimatedGasForPurchase;

  uint public chainId;

  address public proxyAdminAddress;
  ProxyAdmin private proxyAdmin;

  mapping(address => uint16) private _publicLockVersions;
  mapping(uint16 => address) private _publicLockImpls;
  uint16 public publicLockLatestVersion;

  event NewLock(
    address indexed lockOwner,
    address indexed newLockAddress
  );

  event LockUpgraded(
    address lockAddress,
    uint16 version
  );

  event ConfigUnlock(
    address udt,
    address weth,
    uint estimatedGasForPurchase,
    string globalTokenSymbol,
    string globalTokenURI,
    uint chainId
  );

  event SetLockTemplate(
    address publicLockAddress
  );

  event GNPChanged(
    uint grossNetworkProduct,
    uint _valueInETH,
    address tokenAddress,
    uint value,
    address lockAddress
  );
  
  event ResetTrackedValue(
    uint grossNetworkProduct,
    uint totalDiscountGranted
  );

  event UnlockTemplateAdded(
    address indexed impl,
    uint16 indexed version
  );

  function initialize(
    address _unlockOwner
  )
    public
    initializer()
  {

    UnlockOwnable.__initializeOwnable(_unlockOwner);
    _deployProxyAdmin();
  }

  function initializeProxyAdmin() public onlyOwner {

    require(proxyAdminAddress == address(0), "ALREADY_DEPLOYED");
    _deployProxyAdmin();
  }

  function _deployProxyAdmin() private returns(address) {

    proxyAdmin = new ProxyAdmin();
    proxyAdminAddress = address(proxyAdmin);
    return address(proxyAdmin);
  }

  function publicLockVersions(address _impl) external view returns(uint16) {

    return _publicLockVersions[_impl];
  }

  function publicLockImpls(uint16 _version) external view returns(address) {

    return _publicLockImpls[_version];
  }

  function addLockTemplate(address impl, uint16 version) public onlyOwner {

    _publicLockVersions[impl] = version;
    _publicLockImpls[version] = impl;
    if (publicLockLatestVersion < version) publicLockLatestVersion = version;

    emit UnlockTemplateAdded(impl, version);
  }

  function createLock(
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName,
    bytes12 // _salt
  ) public returns(address) {


    bytes memory data = abi.encodeWithSignature(
      'initialize(address,uint256,address,uint256,uint256,string)',
      msg.sender,
      _expirationDuration,
      _tokenAddress,
      _keyPrice,
      _maxNumberOfKeys,
      _lockName
    );

    return createUpgradeableLock(data);
  }

  function createUpgradeableLock(
    bytes memory data
  ) public returns(address)
  {

    address newLock = createUpgradeableLockAtVersion(data, publicLockLatestVersion);
    return newLock;
  }

  function createUpgradeableLockAtVersion(
    bytes memory data,
    uint16 _lockVersion
  ) public returns (address) {

    require(proxyAdminAddress != address(0), "MISSING_PROXY_ADMIN");

    address publicLockImpl = _publicLockImpls[_lockVersion];
    require(publicLockImpl != address(0), 'MISSING_LOCK_TEMPLATE');

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(publicLockImpl, proxyAdminAddress, data);
    address payable newLock = payable(address(proxy));

    locks[newLock] = LockBalances({
      deployed: true, totalSales: 0, yieldedDiscountTokens: 0
    });

    emit NewLock(msg.sender, newLock);
    return newLock;
  }

  function upgradeLock(address payable lockAddress, uint16 version) external returns(address) {

    require(proxyAdminAddress != address(0), "MISSING_PROXY_ADMIN");

    require(_isLockManager(lockAddress, msg.sender) == true, "MANAGER_ONLY");

    IPublicLock lock = IPublicLock(lockAddress);
    uint16 currentVersion = lock.publicLockVersion();
    require( version == currentVersion + 1, 'VERSION_TOO_HIGH');

    address impl = _publicLockImpls[version];
    require(impl != address(0), "MISSING_TEMPLATE");

    TransparentUpgradeableProxy proxy = TransparentUpgradeableProxy(lockAddress);
    proxyAdmin.upgrade(proxy, impl);

    lock.migrate('0x');

    emit LockUpgraded(lockAddress, version);
    return lockAddress;
  }

  function _isLockManager(address lockAddress, address _sender) private view returns(bool isManager) {

    IPublicLock lock = IPublicLock(lockAddress);
    return lock.isLockManager(_sender);
  }

  function computeAvailableDiscountFor(
    address /* _purchaser */,
    uint /* _keyPrice */
  )
    public
    pure
    returns (uint discount, uint tokens)
  {

    return (0, 0);
  }

  function networkBaseFee() external view returns (uint) {

    return block.basefee;
  }

  function recordKeyPurchase(
    uint _value,
    address _referrer
  )
    public
    onlyFromDeployedLock()
  {

    if(_value > 0) {
      uint valueInETH;
      address tokenAddress = IPublicLock(msg.sender).tokenAddress();
      if(tokenAddress != address(0) && tokenAddress != weth) {
        IUniswapOracle oracle = uniswapOracles[tokenAddress];
        if(address(oracle) != address(0)) {
          valueInETH = oracle.updateAndConsult(tokenAddress, _value, weth);
        }
      }
      else {
        valueInETH = _value;
      }

      updateGrossNetworkProduct(
        valueInETH,
        tokenAddress,
        _value,
        msg.sender // lockAddress
      );

      locks[msg.sender].totalSales += valueInETH;

      if(_referrer != address(0))
      {
        IUniswapOracle udtOracle = uniswapOracles[udt];
        if(address(udtOracle) != address(0))
        {
          uint udtPrice = udtOracle.updateAndConsult(udt, 10 ** 18, weth);

          uint baseFee;
          try this.networkBaseFee() returns (uint _basefee) {
            if(_basefee == 0) {
              baseFee = 100;
            } else {
              baseFee = _basefee;
            }
          } catch {
            baseFee = 100;
          }

          uint tokensToDistribute = (estimatedGasForPurchase * baseFee) * (125 * 10 ** 18) / 100 / udtPrice;

          uint maxTokens = 0;
          if (chainId > 1)
          {
            maxTokens = IMintableERC20(udt).balanceOf(address(this)) * valueInETH / (2 + 2 * valueInETH / grossNetworkProduct) / grossNetworkProduct;
          } else {
            maxTokens = IMintableERC20(udt).totalSupply() * valueInETH / 2 / grossNetworkProduct;
          }

          if(tokensToDistribute > maxTokens)
          {
            tokensToDistribute = maxTokens;
          }

          if(tokensToDistribute > 0)
          {
            uint devReward = tokensToDistribute * 20 / 100;
            if (chainId > 1)
            {
              uint balance = IMintableERC20(udt).balanceOf(address(this));
              if (balance > tokensToDistribute) {
                IMintableERC20(udt).transfer(_referrer, tokensToDistribute - devReward);
                IMintableERC20(udt).transfer(owner(), devReward);
              }
            } else {
              IMintableERC20(udt).mint(_referrer, tokensToDistribute - devReward);
              IMintableERC20(udt).mint(owner(), devReward);
            }
          }
        }
      }
    }
  }

  function updateGrossNetworkProduct(
    uint _valueInETH,
    address _tokenAddress,
    uint _value,
    address _lock
  ) internal {

    grossNetworkProduct = grossNetworkProduct + _valueInETH;

    emit GNPChanged(
      grossNetworkProduct,
      _valueInETH,
      _tokenAddress,
      _value,
      _lock
    );
  }

  function recordConsumedDiscount(
    uint /* _discount */,
    uint /* _tokens */
  )
    public
    view
    onlyFromDeployedLock()
  {

    return;
  }

  function unlockVersion(
  ) external pure
    returns (uint16)
  {

    return 11;
  }

  function configUnlock(
    address _udt,
    address _weth,
    uint _estimatedGasForPurchase,
    string calldata _symbol,
    string calldata _URI,
    uint _chainId
  ) external
    onlyOwner
  {

    udt = _udt;
    weth = _weth;
    estimatedGasForPurchase = _estimatedGasForPurchase;

    globalTokenSymbol = _symbol;
    globalBaseTokenURI = _URI;

    chainId = _chainId;

    emit ConfigUnlock(_udt, _weth, _estimatedGasForPurchase, _symbol, _URI, _chainId);
  }

  function setLockTemplate(
    address _publicLockAddress
  ) external
    onlyOwner
  {

    IPublicLock(_publicLockAddress).initialize(
      address(this), 0, address(0), 0, 0, ''
    );
    IPublicLock(_publicLockAddress).renounceLockManager();

    publicLockAddress = _publicLockAddress;

    emit SetLockTemplate(_publicLockAddress);
  }

  function setOracle(
    address _tokenAddress,
    address _oracleAddress
  ) external
    onlyOwner
  {

    uniswapOracles[_tokenAddress] = IUniswapOracle(_oracleAddress);
    if(_oracleAddress != address(0)) {
      IUniswapOracle(_oracleAddress).update(_tokenAddress, weth);
    }
  }

  function resetTrackedValue(
    uint _grossNetworkProduct,
    uint _totalDiscountGranted
  ) external
    onlyOwner
  {

    grossNetworkProduct = _grossNetworkProduct;
    totalDiscountGranted = _totalDiscountGranted;

    emit ResetTrackedValue(_grossNetworkProduct, _totalDiscountGranted);
  }

  function getGlobalBaseTokenURI()
    external
    view
    returns (string memory)
  {

    return globalBaseTokenURI;
  }

  function getGlobalTokenSymbol()
    external
    view
    returns (string memory)
  {

    return globalTokenSymbol;
  }
}