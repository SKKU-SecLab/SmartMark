pragma solidity 0.8.4;

interface IBNFTRegistry {

  event Initialized(address genericImpl, string namePrefix, string symbolPrefix);
  event GenericImplementationUpdated(address genericImpl);
  event BNFTCreated(address indexed nftAsset, address bNftImpl, address bNftProxy, uint256 totals);
  event BNFTUpgraded(address indexed nftAsset, address bNftImpl, address bNftProxy, uint256 totals);
  event CustomeSymbolsAdded(address[] nftAssets, string[] symbols);
  event ClaimAdminUpdated(address oldAdmin, address newAdmin);

  function getBNFTAddresses(address nftAsset) external view returns (address bNftProxy, address bNftImpl);


  function getBNFTAddressesByIndex(uint16 index) external view returns (address bNftProxy, address bNftImpl);


  function getBNFTAssetList() external view returns (address[] memory);


  function allBNFTAssetLength() external view returns (uint256);


  function initialize(
    address genericImpl,
    string memory namePrefix_,
    string memory symbolPrefix_
  ) external;


  function setBNFTGenericImpl(address genericImpl) external;


  function createBNFT(address nftAsset) external returns (address bNftProxy);


  function createBNFTWithImpl(address nftAsset, address bNftImpl) external returns (address bNftProxy);


  function upgradeBNFTWithImpl(
    address nftAsset,
    address bNftImpl,
    bytes memory encodedCallData
  ) external;


  function batchUpgradeBNFT(address[] calldata nftAssets) external;


  function batchUpgradeAllBNFT() external;


  function addCustomeSymbols(address[] memory nftAssets_, string[] memory symbols_) external;

}// agpl-3.0
pragma solidity 0.8.4;

interface IBNFT {

  event Initialized(address indexed underlyingAsset_);

  event OwnershipTransferred(address oldOwner, address newOwner);

  event ClaimAdminUpdated(address oldAdmin, address newAdmin);

  event Mint(address indexed user, address indexed nftAsset, uint256 nftTokenId, address indexed owner);

  event Burn(address indexed user, address indexed nftAsset, uint256 nftTokenId, address indexed owner);

  event FlashLoan(address indexed target, address indexed initiator, address indexed nftAsset, uint256 tokenId);

  event ClaimERC20Airdrop(address indexed token, address indexed to, uint256 amount);

  event ClaimERC721Airdrop(address indexed token, address indexed to, uint256[] ids);

  event ClaimERC1155Airdrop(address indexed token, address indexed to, uint256[] ids, uint256[] amounts, bytes data);

  event ExecuteAirdrop(address indexed airdropContract);

  function initialize(
    address underlyingAsset_,
    string calldata bNftName,
    string calldata bNftSymbol,
    address owner_,
    address claimAdmin_
  ) external;


  function mint(address to, uint256 tokenId) external;


  function burn(uint256 tokenId) external;


  function flashLoan(
    address receiverAddress,
    uint256[] calldata nftTokenIds,
    bytes calldata params
  ) external;


  function claimERC20Airdrop(
    address token,
    address to,
    uint256 amount
  ) external;


  function claimERC721Airdrop(
    address token,
    address to,
    uint256[] calldata ids
  ) external;


  function claimERC1155Airdrop(
    address token,
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts,
    bytes calldata data
  ) external;


  function executeAirdrop(address airdropContract, bytes calldata airdropParams) external;


  function minterOf(uint256 tokenId) external view returns (address);


  function underlyingAsset() external view returns (address);


  function contractURI() external view returns (string memory);

}// MIT

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

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
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
}// agpl-3.0
pragma solidity 0.8.4;


contract BNFTUpgradeableProxy is TransparentUpgradeableProxy {

  constructor(
    address _logic,
    address admin_,
    bytes memory _data
  ) payable TransparentUpgradeableProxy(_logic, admin_, _data) {}
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// agpl-3.0
pragma solidity 0.8.4;



contract BNFTRegistry is IBNFTRegistry, Initializable, OwnableUpgradeable {

  mapping(address => address) public bNftProxys;
  mapping(address => address) public bNftImpls;
  address[] public bNftAssetLists;
  string public namePrefix;
  string public symbolPrefix;
  address public bNftGenericImpl;
  mapping(address => string) public customSymbols;
  uint256 private constant _NOT_ENTERED = 0;
  uint256 private constant _ENTERED = 1;
  uint256 private _status;
  address private _claimAdmin;

  modifier nonReentrant() {

    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

    _status = _ENTERED;

    _;

    _status = _NOT_ENTERED;
  }

  modifier onlyClaimAdmin() {

    require(claimAdmin() == _msgSender(), "BNFTR: caller is not the claim admin");
    _;
  }

  function getBNFTAddresses(address nftAsset) external view override returns (address bNftProxy, address bNftImpl) {

    bNftProxy = bNftProxys[nftAsset];
    bNftImpl = bNftImpls[nftAsset];
  }

  function getBNFTAddressesByIndex(uint16 index) external view override returns (address bNftProxy, address bNftImpl) {

    require(index < bNftAssetLists.length, "BNFTR: invalid index");
    bNftProxy = bNftProxys[bNftAssetLists[index]];
    bNftImpl = bNftImpls[bNftAssetLists[index]];
  }

  function getBNFTAssetList() external view override returns (address[] memory) {

    return bNftAssetLists;
  }

  function allBNFTAssetLength() external view override returns (uint256) {

    return bNftAssetLists.length;
  }

  function initialize(
    address genericImpl,
    string memory namePrefix_,
    string memory symbolPrefix_
  ) external override initializer {

    require(genericImpl != address(0), "BNFTR: impl is zero address");

    __Ownable_init();

    bNftGenericImpl = genericImpl;

    namePrefix = namePrefix_;
    symbolPrefix = symbolPrefix_;

    _setClaimAdmin(_msgSender());

    emit Initialized(genericImpl, namePrefix, symbolPrefix);
  }

  function createBNFT(address nftAsset) external override nonReentrant returns (address bNftProxy) {

    _requireAddressIsERC721(nftAsset);
    require(bNftProxys[nftAsset] == address(0), "BNFTR: asset exist");
    require(bNftGenericImpl != address(0), "BNFTR: impl is zero address");

    bNftProxy = _createProxyAndInitWithImpl(nftAsset, bNftGenericImpl);

    emit BNFTCreated(nftAsset, bNftImpls[nftAsset], bNftProxy, bNftAssetLists.length);
  }

  function setBNFTGenericImpl(address genericImpl) external override nonReentrant onlyOwner {

    require(genericImpl != address(0), "BNFTR: impl is zero address");
    bNftGenericImpl = genericImpl;

    emit GenericImplementationUpdated(genericImpl);
  }

  function createBNFTWithImpl(address nftAsset, address bNftImpl)
    external
    override
    nonReentrant
    onlyOwner
    returns (address bNftProxy)
  {

    _requireAddressIsERC721(nftAsset);
    require(bNftImpl != address(0), "BNFTR: implement is zero address");
    require(bNftProxys[nftAsset] == address(0), "BNFTR: asset exist");

    bNftProxy = _createProxyAndInitWithImpl(nftAsset, bNftImpl);

    emit BNFTCreated(nftAsset, bNftImpls[nftAsset], bNftProxy, bNftAssetLists.length);
  }

  function upgradeBNFTWithImpl(
    address nftAsset,
    address bNftImpl,
    bytes memory encodedCallData
  ) external override nonReentrant onlyOwner {

    _upgradeBNFTWithImpl(nftAsset, bNftImpl, encodedCallData);
  }

  function _upgradeBNFTWithImpl(
    address nftAsset,
    address bNftImpl,
    bytes memory encodedCallData
  ) internal {

    address bNftProxy = bNftProxys[nftAsset];
    require(bNftProxy != address(0), "BNFTR: asset nonexist");

    BNFTUpgradeableProxy proxy = BNFTUpgradeableProxy(payable(bNftProxy));

    if (encodedCallData.length > 0) {
      proxy.upgradeToAndCall(bNftImpl, encodedCallData);
    } else {
      proxy.upgradeTo(bNftImpl);
    }

    bNftImpls[nftAsset] = bNftImpl;

    emit BNFTUpgraded(nftAsset, bNftImpl, bNftProxy, bNftAssetLists.length);
  }

  function batchUpgradeBNFT(address[] calldata nftAssets) external override nonReentrant onlyOwner {

    require(nftAssets.length > 0, "BNFTR: empty assets");

    for (uint256 i = 0; i < nftAssets.length; i++) {
      _upgradeBNFTWithImpl(nftAssets[i], bNftGenericImpl, new bytes(0));
    }
  }

  function batchUpgradeAllBNFT() external override nonReentrant onlyOwner {

    for (uint256 i = 0; i < bNftAssetLists.length; i++) {
      _upgradeBNFTWithImpl(bNftAssetLists[i], bNftGenericImpl, new bytes(0));
    }
  }

  function addCustomeSymbols(address[] memory nftAssets_, string[] memory symbols_)
    external
    override
    nonReentrant
    onlyOwner
  {

    require(nftAssets_.length == symbols_.length, "BNFTR: inconsistent parameters");

    for (uint256 i = 0; i < nftAssets_.length; i++) {
      customSymbols[nftAssets_[i]] = symbols_[i];
    }

    emit CustomeSymbolsAdded(nftAssets_, symbols_);
  }

  function claimAdmin() public view virtual returns (address) {

    return _claimAdmin;
  }

  function setClaimAdmin(address newAdmin) public virtual onlyOwner {

    require(newAdmin != address(0), "BNFTR: new admin is the zero address");
    _setClaimAdmin(newAdmin);
  }

  function _setClaimAdmin(address newAdmin) internal virtual {

    address oldAdmin = _claimAdmin;
    _claimAdmin = newAdmin;
    emit ClaimAdminUpdated(oldAdmin, newAdmin);
  }

  function _createProxyAndInitWithImpl(address nftAsset, address bNftImpl) internal returns (address bNftProxy) {

    bytes memory initParams = _buildInitParams(nftAsset);

    BNFTUpgradeableProxy proxy = new BNFTUpgradeableProxy(bNftImpl, address(this), initParams);

    bNftProxy = address(proxy);

    bNftImpls[nftAsset] = bNftImpl;
    bNftProxys[nftAsset] = bNftProxy;
    bNftAssetLists.push(nftAsset);
  }

  function _buildInitParams(address nftAsset) internal view returns (bytes memory initParams) {

    string memory nftSymbol = customSymbols[nftAsset];
    if (bytes(nftSymbol).length == 0) {
      nftSymbol = IERC721MetadataUpgradeable(nftAsset).symbol();
    }
    string memory bNftName = string(abi.encodePacked(namePrefix, " ", nftSymbol));
    string memory bNftSymbol = string(abi.encodePacked(symbolPrefix, nftSymbol));

    initParams = abi.encodeWithSelector(
      IBNFT.initialize.selector,
      nftAsset,
      bNftName,
      bNftSymbol,
      owner(),
      claimAdmin()
    );
  }

  function _requireAddressIsERC721(address nftAsset) internal view {

    require(nftAsset != address(0), "BNFTR: asset is zero address");
    require(AddressUpgradeable.isContract(nftAsset), "BNFTR: asset is not contract");
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC1822Proxiable {

    function proxiableUUID() external view returns (bytes32);

}