


pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}







interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





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
}








library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}







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
}







abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}







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
}








abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}







interface IERC1822ProxiableUpgradeable {

    function proxiableUUID() external view returns (bytes32);

}







interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}







library StorageSlotUpgradeable {

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
}





pragma solidity ^0.8.2;





abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
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
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    uint256[50] private __gap;
}









abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;

    uint256[50] private __gap;
}







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
}





pragma solidity 0.8.4;

interface IKOAccessControlsLookup {

    function hasAdminRole(address _address) external view returns (bool);


    function isVerifiedArtist(uint256 _index, address _account, bytes32[] calldata _merkleProof) external view returns (bool);


    function isVerifiedArtistProxy(address _artist, address _proxy) external view returns (bool);


    function hasLegacyMinterRole(address _address) external view returns (bool);


    function hasContractRole(address _address) external view returns (bool);


    function hasContractOrAdminRole(address _address) external view returns (bool);

}







interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}







interface IERC721 is IERC165 {

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

}





pragma solidity 0.8.4;

interface IERC2309 {

    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed fromAddress, address indexed toAddress);
}





pragma solidity 0.8.4;

interface IERC2981EditionExtension {


    function hasRoyalties(uint256 _editionId) external view returns (bool);


    function getRoyaltiesReceiver(uint256 _editionId) external view returns (address);

}

interface IERC2981 is IERC165, IERC2981EditionExtension {


    function royaltyInfo(
        uint256 _tokenId,
        uint256 _value
    ) external view returns (
        address _receiver,
        uint256 _royaltyAmount
    );


}





pragma solidity 0.8.4;

interface IHasSecondarySaleFees is IERC165 {


    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint[] bps);

    function getFeeRecipients(uint256 id) external returns (address payable[] memory);


    function getFeeBps(uint256 id) external returns (uint[] memory);

}





pragma solidity 0.8.4;





interface IKODAV3 is
IERC165, // Contract introspection
IERC721, // Core NFTs
IERC2309, // Consecutive batch mint
IERC2981, // Royalties
IHasSecondarySaleFees // Rariable / Foundation royalties
{


    function getCreatorOfEdition(uint256 _editionId) external view returns (address _originalCreator);


    function getCreatorOfToken(uint256 _tokenId) external view returns (address _originalCreator);


    function getSizeOfEdition(uint256 _editionId) external view returns (uint256 _size);


    function getEditionSizeOfToken(uint256 _tokenId) external view returns (uint256 _size);


    function editionExists(uint256 _editionId) external view returns (bool);


    function isEditionSalesDisabled(uint256 _editionId) external view returns (bool);


    function isSalesDisabledOrSoldOut(uint256 _editionId) external view returns (bool);


    function maxTokenIdOfEdition(uint256 _editionId) external view returns (uint256 _tokenId);


    function getNextAvailablePrimarySaleToken(uint256 _editionId) external returns (uint256 _tokenId);


    function getReverseAvailablePrimarySaleToken(uint256 _editionId) external view returns (uint256 _tokenId);


    function facilitateNextPrimarySale(uint256 _editionId) external returns (address _receiver, address _creator, uint256 _tokenId);


    function facilitateReversePrimarySale(uint256 _editionId) external returns (address _receiver, address _creator, uint256 _tokenId);


    function royaltyAndCreatorInfo(uint256 _editionId, uint256 _value) external returns (address _receiver, address _creator, uint256 _amount);


    function updateURIIfNoSaleMade(uint256 _editionId, string calldata _newURI) external;


    function hasMadePrimarySale(uint256 _editionId) external view returns (bool);


    function isEditionSoldOut(uint256 _editionId) external view returns (bool);


    function toggleEditionSalesDisabled(uint256 _editionId) external;



    function exists(uint256 _tokenId) external view returns (bool);


    function getEditionIdOfToken(uint256 _tokenId) external pure returns (uint256 _editionId);


    function getEditionDetails(uint256 _tokenId) external view returns (address _originalCreator, address _owner, uint16 _size, uint256 _editionId, string memory _uri);


    function hadPrimarySaleOfToken(uint256 _tokenId) external view returns (bool);


}





pragma solidity 0.8.4;







abstract contract BaseUpgradableMarketplace is ReentrancyGuardUpgradeable, PausableUpgradeable, UUPSUpgradeable {

    event AdminUpdateModulo(uint256 _modulo);
    event AdminUpdatePlatformPrimaryCommission(uint256 newAmount);
    event AdminUpdateMinBidAmount(uint256 _minBidAmount);
    event AdminUpdateAccessControls(IKOAccessControlsLookup indexed _oldAddress, IKOAccessControlsLookup indexed _newAddress);
    event AdminUpdateBidLockupPeriod(uint256 _bidLockupPeriod);
    event AdminUpdatePlatformAccount(address indexed _oldAddress, address indexed _newAddress);
    event AdminRecoverERC20(address indexed _token, address indexed _recipient, uint256 _amount);
    event AdminRecoverETH(address payable indexed _recipient, uint256 _amount);

    event BidderRefunded(uint256 indexed _id, address _bidder, uint256 _bid, address _newBidder, uint256 _newOffer);
    event BidderRefundedFailed(uint256 indexed _id, address _bidder, uint256 _bid, address _newBidder, uint256 _newOffer);

    struct KOCommissionOverride {
        bool active;
        uint256 koCommission;
    }

    modifier onlyAdmin() {
        require(accessControls.hasAdminRole(_msgSender()), "Caller not admin");
        _;
    }

    modifier onlyCreatorContractOrAdmin(uint256 _editionId) {
        require(
            koda.getCreatorOfEdition(_editionId) == _msgSender() || accessControls.hasContractOrAdminRole(_msgSender()),
            "Caller not creator or admin"
        );
        _;
    }

    IKOAccessControlsLookup public accessControls;

    IKODAV3 public koda;

    address public platformAccount;

    uint256 public modulo;

    uint256 public minBidAmount;

    uint256 public bidLockupPeriod;

    uint256 public platformPrimaryCommission;

    constructor() initializer {}

    function initialize(IKOAccessControlsLookup _accessControls, IKODAV3 _koda, address _platformAccount) public initializer {
        __ReentrancyGuard_init();
        __Pausable_init();

        require(address(_accessControls) != address(0), "Unable to set invalid accessControls address");
        require(address(_koda) != address(0), "Unable to set invalid koda address");
        require(_platformAccount != address(0), "Unable to set invalid _platformAccount address");

        accessControls = _accessControls;
        koda = _koda;
        platformAccount = _platformAccount;

        modulo = 100_00000;
        platformPrimaryCommission = 15_00000;
        minBidAmount = 0.01 ether;
        bidLockupPeriod = 6 hours;
    }

    function _authorizeUpgrade(address newImplementation) internal view override {
        require(accessControls.hasAdminRole(msg.sender), "Only admin can upgrade");
    }

    function recoverERC20(address _token, address _recipient, uint256 _amount) public onlyAdmin {
        require(_recipient != address(0), "Unable to send funds to invalid _recipient address");
        SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(_token), _recipient, _amount);
        emit AdminRecoverERC20(_token, _recipient, _amount);
    }

    function recoverStuckETH(address payable _recipient, uint256 _amount) public onlyAdmin {
        require(_recipient != address(0), "Unable to send funds to invalid _recipient address");
        (bool success,) = _recipient.call{value : _amount}("");
        require(success, "Unable to send recipient ETH");
        emit AdminRecoverETH(_recipient, _amount);
    }

    function updatePlatformPrimaryCommission(uint256 _newAmount) external onlyAdmin {
        require(_newAmount <= 10**40, "Platform commission too high - danger of over overflow");
        platformPrimaryCommission = _newAmount;
        emit AdminUpdatePlatformPrimaryCommission(_newAmount);
    }

    function updateAccessControls(IKOAccessControlsLookup _accessControls) public onlyAdmin {
        require(_accessControls.hasAdminRole(_msgSender()), "Sender must have admin role in new contract");
        emit AdminUpdateAccessControls(accessControls, _accessControls);
        accessControls = _accessControls;
    }

    function updateModulo(uint256 _modulo) public onlyAdmin {
        require(_modulo > 0, "Modulo point cannot be zero");
        modulo = _modulo;
        emit AdminUpdateModulo(_modulo);
    }

    function updateMinBidAmount(uint256 _minBidAmount) public onlyAdmin {
        minBidAmount = _minBidAmount;
        emit AdminUpdateMinBidAmount(_minBidAmount);
    }

    function updateBidLockupPeriod(uint256 _bidLockupPeriod) public onlyAdmin {
        bidLockupPeriod = _bidLockupPeriod;
        emit AdminUpdateBidLockupPeriod(_bidLockupPeriod);
    }

    function updatePlatformAccount(address _newPlatformAccount) public onlyAdmin {
        require(_newPlatformAccount != address(0), "Unable to set invalid _newPlatformAccount address");
        emit AdminUpdatePlatformAccount(platformAccount, _newPlatformAccount);
        platformAccount = _newPlatformAccount;
    }

    function pause() public onlyAdmin {
        super._pause();
    }

    function unpause() public onlyAdmin {
        super._unpause();
    }

    function _getLockupTime() internal view returns (uint256 lockupUntil) {
        lockupUntil = block.timestamp + bidLockupPeriod;
    }

    function _handleSaleFunds(address _fundsReceiver, uint256 _platformCommission) internal {
        uint256 koCommission = msg.value * _platformCommission / modulo;
        if (koCommission > 0) {
            (bool koCommissionSuccess,) = platformAccount.call{value : koCommission}("");
            require(koCommissionSuccess, "commission payment failed");
        }
        (bool success,) = _fundsReceiver.call{value : msg.value - koCommission}("");
        require(success, "payment failed");
    }

    function _refundBidder(uint256 _id, address _receiver, uint256 _paymentAmount, address _newBidder, uint256 _newOffer) internal {
        (bool success,) = _receiver.call{value : _paymentAmount}("");
        if (!success) {
            emit BidderRefundedFailed(_id, _receiver, _paymentAmount, _newBidder, _newOffer);
        } else {
            emit BidderRefunded(_id, _receiver, _paymentAmount, _newBidder, _newOffer);
        }
    }

}




pragma solidity 0.8.4;

interface IBuyNowMarketplace {

    event ListedForBuyNow(uint256 indexed _id, uint256 _price, address _currentOwner, uint256 _startDate);
    event BuyNowPriceChanged(uint256 indexed _id, uint256 _price);
    event BuyNowDeListed(uint256 indexed _id);
    event BuyNowPurchased(uint256 indexed _tokenId, address _buyer, address _currentOwner, uint256 _price);

    function listForBuyNow(address _creator, uint256 _id, uint128 _listingPrice, uint128 _startDate) external;


    function buyEditionToken(uint256 _id) external payable;

    function buyEditionTokenFor(uint256 _id, address _recipient) external payable;


    function setBuyNowPriceListing(uint256 _editionId, uint128 _listingPrice) external;

}

interface IEditionOffersMarketplace {

    event EditionAcceptingOffer(uint256 indexed _editionId, uint128 _startDate);
    event EditionBidPlaced(uint256 indexed _editionId, address _bidder, uint256 _amount);
    event EditionBidWithdrawn(uint256 indexed _editionId, address _bidder);
    event EditionBidAccepted(uint256 indexed _editionId, uint256 indexed _tokenId, address _bidder, uint256 _amount);
    event EditionBidRejected(uint256 indexed _editionId, address _bidder, uint256 _amount);
    event EditionConvertedFromOffersToBuyItNow(uint256 _editionId, uint128 _price, uint128 _startDate);

    function enableEditionOffers(uint256 _editionId, uint128 _startDate) external;


    function placeEditionBid(uint256 _editionId) external payable;

    function placeEditionBidFor(uint256 _editionId, address _bidder) external payable;


    function withdrawEditionBid(uint256 _editionId) external;


    function rejectEditionBid(uint256 _editionId) external;


    function acceptEditionBid(uint256 _editionId, uint256 _offerPrice) external;


    function convertOffersToBuyItNow(uint256 _editionId, uint128 _listingPrice, uint128 _startDate) external;

}

interface IEditionSteppedMarketplace {

    event EditionSteppedSaleListed(uint256 indexed _editionId, uint128 _basePrice, uint128 _stepPrice, uint128 _startDate);
    event EditionSteppedSaleBuy(uint256 indexed _editionId, uint256 indexed _tokenId, address _buyer, uint256 _price, uint16 _currentStep);
    event EditionSteppedAuctionUpdated(uint256 indexed _editionId, uint128 _basePrice, uint128 _stepPrice);

    function listSteppedEditionAuction(address _creator, uint256 _editionId, uint128 _basePrice, uint128 _stepPrice, uint128 _startDate) external;


    function buyNextStep(uint256 _editionId) external payable;

    function buyNextStepFor(uint256 _editionId, address _buyer) external payable;


    function convertSteppedAuctionToListing(uint256 _editionId, uint128 _listingPrice, uint128 _startDate) external;


    function convertSteppedAuctionToOffers(uint256 _editionId, uint128 _startDate) external;


    function updateSteppedAuction(uint256 _editionId, uint128 _basePrice, uint128 _stepPrice) external;

}

interface IReserveAuctionMarketplace {

    event ListedForReserveAuction(uint256 indexed _id, uint256 _reservePrice, uint128 _startDate);
    event BidPlacedOnReserveAuction(uint256 indexed _id, address _currentOwner, address _bidder, uint256 _amount, uint256 _originalBiddingEnd, uint256 _currentBiddingEnd);
    event ReserveAuctionResulted(uint256 indexed _id, uint256 _finalPrice, address _currentOwner, address _winner, address _resulter);
    event BidWithdrawnFromReserveAuction(uint256 _id, address _bidder, uint128 _bid);
    event ReservePriceUpdated(uint256 indexed _id, uint256 _reservePrice);
    event ReserveAuctionConvertedToBuyItNow(uint256 indexed _id, uint128 _listingPrice, uint128 _startDate);
    event EmergencyBidWithdrawFromReserveAuction(uint256 indexed _id, address _bidder, uint128 _bid);

    function placeBidOnReserveAuction(uint256 _id) external payable;

    function placeBidOnReserveAuctionFor(uint256 _id, address _bidder) external payable;


    function listForReserveAuction(address _creator, uint256 _id, uint128 _reservePrice, uint128 _startDate) external;


    function resultReserveAuction(uint256 _id) external;


    function withdrawBidFromReserveAuction(uint256 _id) external;


    function updateReservePriceForReserveAuction(uint256 _id, uint128 _reservePrice) external;


    function emergencyExitBidFromReserveAuction(uint256 _id) external;

}

interface IKODAV3PrimarySaleMarketplace is IEditionSteppedMarketplace, IEditionOffersMarketplace, IBuyNowMarketplace, IReserveAuctionMarketplace {

    function convertReserveAuctionToBuyItNow(uint256 _editionId, uint128 _listingPrice, uint128 _startDate) external;


    function convertReserveAuctionToOffers(uint256 _editionId, uint128 _startDate) external;

}

interface ITokenBuyNowMarketplace {

    event TokenDeListed(uint256 indexed _tokenId);

    function delistToken(uint256 _tokenId) external;

}

interface ITokenOffersMarketplace {

    event TokenBidPlaced(uint256 indexed _tokenId, address _currentOwner, address _bidder, uint256 _amount);
    event TokenBidAccepted(uint256 indexed _tokenId, address _currentOwner, address _bidder, uint256 _amount);
    event TokenBidRejected(uint256 indexed _tokenId, address _currentOwner, address _bidder, uint256 _amount);
    event TokenBidWithdrawn(uint256 indexed _tokenId, address _bidder);

    function acceptTokenBid(uint256 _tokenId, uint256 _offerPrice) external;


    function rejectTokenBid(uint256 _tokenId) external;


    function withdrawTokenBid(uint256 _tokenId) external;


    function placeTokenBid(uint256 _tokenId) external payable;

    function placeTokenBidFor(uint256 _tokenId, address _bidder) external payable;

}

interface IBuyNowSecondaryMarketplace {

    function listTokenForBuyNow(uint256 _tokenId, uint128 _listingPrice, uint128 _startDate) external;

}

interface IEditionOffersSecondaryMarketplace {

    event EditionBidPlaced(uint256 indexed _editionId, address indexed _bidder, uint256 _bid);
    event EditionBidWithdrawn(uint256 indexed _editionId, address _bidder);
    event EditionBidAccepted(uint256 indexed _tokenId, address _currentOwner, address _bidder, uint256 _amount);

    function placeEditionBid(uint256 _editionId) external payable;

    function placeEditionBidFor(uint256 _editionId, address _bidder) external payable;


    function withdrawEditionBid(uint256 _editionId) external;


    function acceptEditionBid(uint256 _tokenId, uint256 _offerPrice) external;

}

interface IKODAV3SecondarySaleMarketplace is ITokenBuyNowMarketplace, ITokenOffersMarketplace, IEditionOffersSecondaryMarketplace, IBuyNowSecondaryMarketplace {

    function convertReserveAuctionToBuyItNow(uint256 _tokenId, uint128 _listingPrice, uint128 _startDate) external;


    function convertReserveAuctionToOffers(uint256 _tokenId) external;

}

interface IKODAV3GatedMarketplace {


    function createSale(uint256 _editionId) external;


    function createPhase(
        uint256 _editionId,
        uint128 _startTime,
        uint128 _endTime,
        uint128 _priceInWei,
        uint16 _mintCap,
        uint16 _walletMintLimit,
        bytes32 _merkleRoot,
        string calldata _merkleIPFSHash
    ) external;


    function createSaleWithPhases(
        uint256 _editionId,
        uint128[] memory _startTimes,
        uint128[] memory _endTimes,
        uint128[] memory _pricesInWei,
        uint16[] memory _mintCaps,
        uint16[] memory _walletMintLimits,
        bytes32[] memory _merkleRoots,
        string[] memory _merkleIPFSHashes
    ) external;


    function createPhases(
        uint256 _editionId,
        uint128[] memory _startTimes,
        uint128[] memory _endTimes,
        uint128[] memory _pricesInWei,
        uint16[] memory _mintCaps,
        uint16[] memory _walletMintLimits,
        bytes32[] memory _merkleRoots,
        string[] memory _merkleIPFSHashes
    ) external;


    function removePhase(uint256 _editionId, uint256 _phaseId) external;

}




pragma solidity 0.8.4;




contract KODAV3UpgradableGatedMarketplace is IKODAV3GatedMarketplace, BaseUpgradableMarketplace {


    event AdminUpdateFundReceiver(uint256 indexed _saleId, address _newFundsReceiver);

    event AdminUpdateMaxEditionId(uint256 indexed _saleId, uint256 _newMaxEditionId);

    event AdminUpdateCreator(uint256 indexed _saleId, address _newCreator);

    event AdminSetKoCommissionOverrideForSale(uint256 indexed _saleId, uint256 _platformPrimarySaleCommission);

    event SalePaused(uint256 indexed _saleId);

    event SaleResumed(uint256 indexed _saleId);

    event SaleWithPhaseCreated(uint256 indexed _saleId);

    event SaleCreated(uint256 indexed _saleId);

    event PhaseCreated(uint256 indexed _saleId, uint256 indexed _phaseId);

    event PhaseRemoved(uint256 indexed _saleId, uint256 indexed _phaseId);

    event MintFromSale(uint256 indexed _saleId, uint256 indexed _phaseId, uint256 indexed _tokenId, address _recipient);

    struct Phase {
        uint128 startTime;      // The start time of the sale as a whole
        uint128 endTime;        // The end time of the sale phase, also the beginning of the next phase if applicable
        uint128 priceInWei;     // Price in wei for one mint
        uint16 mintCounter;     // The current amount of items minted
        uint16 mintCap;         // The maximum amount of mints for the phase
        uint16 walletMintLimit; // The mint limit per wallet for the phase
        bytes32 merkleRoot;     // The merkle tree root for the phase
        string merkleIPFSHash;  // The IPFS hash referencing the merkle tree
    }

    struct Sale {
        uint256 id;             // The ID of the sale
        uint256 editionId;      // The ID of the edition the sale will mint
        address creator;        // Set on creation to save gas - the original edition creator
        address fundsReceiver;  // Where are the funds set
        uint256 maxEditionId;   // Stores the max edition ID for the edition - used when assigning tokens
        uint16 mintCounter;     // Keeps a pointer to the overall mint count for the full sale
        uint8 paused;           // Whether the sale is currently paused > 0 is paused
    }

    mapping(uint256 => KOCommissionOverride) public koCommissionOverrideForSale;

    uint256 public saleIdCounter;

    mapping(bytes32 => uint256) public totalMints;

    mapping(uint256 => uint256) public editionToSale;

    mapping(uint256 => Sale) public sales;

    mapping(uint256 => Phase[]) public phases;

    function createSaleWithPhases(
        uint256 _editionId,
        uint128[] memory _startTimes,
        uint128[] memory _endTimes,
        uint128[] memory _pricesInWei,
        uint16[] memory _mintCaps,
        uint16[] memory _walletMintLimits,
        bytes32[] memory _merkleRoots,
        string[] memory _merkleIPFSHashes
    ) external override whenNotPaused {

        address creator = koda.getCreatorOfEdition(_editionId);
        require(
            creator == _msgSender() || accessControls.hasContractOrAdminRole(_msgSender()),
            "Caller not creator or admin"
        );

        require(editionToSale[_editionId] == 0, "Sale exists for this edition");

        uint256 saleId = _createSale(_editionId, creator);

        _addMultiplePhasesToSale(
            saleId,
            _startTimes,
            _endTimes,
            _pricesInWei,
            _mintCaps,
            _walletMintLimits,
            _merkleRoots,
            _merkleIPFSHashes
        );

        emit SaleWithPhaseCreated(saleId);
    }

    function createSale(uint256 _editionId) external override whenNotPaused {

        address creator = koda.getCreatorOfEdition(_editionId);
        require(
            creator == _msgSender() || accessControls.hasContractOrAdminRole(_msgSender()),
            "Caller not creator or admin"
        );

        require(editionToSale[_editionId] == 0, "Sale exists for this edition");

        uint256 saleId = _createSale(_editionId, creator);

        emit SaleCreated(saleId);
    }

    function _createSale(uint256 _editionId, address _creator) internal returns (uint256) {

        uint256 saleId = ++saleIdCounter;

        sales[saleId] = Sale({
        id : saleId,
        creator : _creator,
        fundsReceiver : koda.getRoyaltiesReceiver(_editionId),
        editionId : _editionId,
        maxEditionId : koda.maxTokenIdOfEdition(_editionId) - 1,
        paused : 0,
        mintCounter : 0
        });

        editionToSale[_editionId] = saleId;

        return saleId;
    }

    function mint(
        uint256 _saleId,
        uint256 _phaseId,
        uint16 _mintCount,
        uint256 _index,
        bytes32[] calldata _merkleProof
    ) payable external nonReentrant whenNotPaused {

        Sale storage sale = sales[_saleId];
        require(sale.paused == 0, 'Sale is paused');

        Phase storage phase = phases[_saleId][_phaseId];

        require(block.timestamp >= phase.startTime && block.timestamp < phase.endTime, 'Sale phase not in progress');
        require(phase.mintCounter + _mintCount <= phase.mintCap, 'Phase mint cap reached');

        bytes32 totalMintsKey = keccak256(abi.encode(_saleId, _phaseId, _msgSender()));

        require(totalMints[totalMintsKey] + _mintCount <= phase.walletMintLimit, 'Cannot exceed total mints for sale phase');
        require(msg.value >= phase.priceInWei * _mintCount, 'Not enough wei sent to complete mint');
        require(onPhaseMintList(_saleId, _phaseId, _index, _msgSender(), _merkleProof), 'Address not able to mint from sale');

        handleMint(_saleId, _phaseId, sale.editionId, _mintCount, _msgSender());

        totalMints[totalMintsKey] += _mintCount;
        phase.mintCounter += _mintCount;
        sale.mintCounter += _mintCount;
    }

    function createPhase(
        uint256 _editionId,
        uint128 _startTime,
        uint128 _endTime,
        uint128 _priceInWei,
        uint16 _mintCap,
        uint16 _walletMintLimit,
        bytes32 _merkleRoot,
        string calldata _merkleIPFSHash
    )
    external override whenNotPaused onlyCreatorContractOrAdmin(_editionId) {

        uint256 saleId = editionToSale[_editionId];
        require(saleId > 0, 'No sale associated with edition id');

        _addPhaseToSale(
            saleId,
            _startTime,
            _endTime,
            _priceInWei,
            _mintCap,
            _walletMintLimit,
            _merkleRoot,
            _merkleIPFSHash
        );
    }

    function createPhases(
        uint256 _editionId,
        uint128[] memory _startTimes,
        uint128[] memory _endTimes,
        uint128[] memory _pricesInWei,
        uint16[] memory _mintCaps,
        uint16[] memory _walletMintLimits,
        bytes32[] memory _merkleRoots,
        string[] memory _merkleIPFSHashes
    )
    external override onlyCreatorContractOrAdmin(_editionId) whenNotPaused {


        uint256 saleId = editionToSale[_editionId];
        require(saleId > 0, 'No sale associated with edition id');

        _addMultiplePhasesToSale(
            saleId,
            _startTimes,
            _endTimes,
            _pricesInWei,
            _mintCaps,
            _walletMintLimits,
            _merkleRoots,
            _merkleIPFSHashes
        );
    }

    function removePhase(uint256 _editionId, uint256 _phaseId)
    external override onlyCreatorContractOrAdmin(_editionId) {

        require(koda.editionExists(_editionId), 'Edition does not exist');

        uint256 saleId = editionToSale[_editionId];
        require(saleId > 0, 'No sale associated with edition id');

        delete phases[saleId][_phaseId];

        emit PhaseRemoved(saleId, _phaseId);
    }

    function onPhaseMintList(uint256 _saleId, uint256 _phaseId, uint256 _index, address _account, bytes32[] calldata _merkleProof)
    public view returns (bool) {

        Phase storage phase = phases[_saleId][_phaseId];
        bytes32 node = keccak256(abi.encodePacked(_index, _account, uint256(1)));
        return MerkleProof.verify(_merkleProof, phase.merkleRoot, node);
    }

    function toggleSalePause(uint256 _saleId, uint256 _editionId) external onlyCreatorContractOrAdmin(_editionId) {

        if (sales[_saleId].paused != 0) {
            sales[_saleId].paused = 0;
            emit SaleResumed(_saleId);
        } else {
            sales[_saleId].paused = 1;
            emit SalePaused(_saleId);
        }
    }

    function remainingPhaseMintAllowance(uint256 _saleId, uint256 _phaseId, uint256 _index, address _account, bytes32[] calldata _merkleProof)
    external view returns (uint256) {

        require(onPhaseMintList(_saleId, _phaseId, _index, _account, _merkleProof), 'Address not able to mint from sale');

        return phases[_saleId][_phaseId].walletMintLimit - totalMints[keccak256(abi.encode(_saleId, _phaseId, _account))];
    }

    function handleMint(
        uint256 _saleId,
        uint256 _phaseId,
        uint256 _editionId,
        uint16 _mintCount,
        address _recipient
    ) internal {

        require(_mintCount > 0, "Nothing being minted");

        address creator = sales[_saleId].creator;
        uint256 startId = sales[_saleId].maxEditionId - sales[_saleId].mintCounter;

        for (uint256 i; i < _mintCount; ++i) {
            uint256 tokenId = getNextAvailablePrimarySaleToken(startId, _editionId, creator);

            koda.safeTransferFrom(creator, _recipient, tokenId);

            emit MintFromSale(_saleId, _phaseId, tokenId, _recipient);

            unchecked {startId = tokenId--;}
        }
        _handleSaleFunds(sales[_saleId].fundsReceiver, getPlatformSaleCommissionForSale(_saleId));
    }

    function getPlatformSaleCommissionForSale(uint256 _saleId) internal view returns (uint256) {

        if (koCommissionOverrideForSale[_saleId].active) {
            return koCommissionOverrideForSale[_saleId].koCommission;
        }
        return platformPrimaryCommission;
    }

    function getNextAvailablePrimarySaleToken(uint256 _startId, uint256 _editionId, address creator) internal view returns (uint256 _tokenId) {

        for (uint256 tokenId = _startId; tokenId >= _editionId; --tokenId) {
            if (koda.ownerOf(tokenId) == creator) {
                return tokenId;
            }
        }
        revert("Primary market exhausted");
    }

    function _addMultiplePhasesToSale(
        uint256 _saleId,
        uint128[] memory _startTimes,
        uint128[] memory _endTimes,
        uint128[] memory _pricesInWei,
        uint16[] memory _mintCaps,
        uint16[] memory _walletMintLimits,
        bytes32[] memory _merkleRoots,
        string[] memory _merkleIPFSHashes
    ) internal {

        uint256 numOfPhases = _startTimes.length;
        for (uint256 i; i < numOfPhases; ++i) {
            _addPhaseToSale(
                _saleId,
                _startTimes[i],
                _endTimes[i],
                _pricesInWei[i],
                _mintCaps[i],
                _walletMintLimits[i],
                _merkleRoots[i],
                _merkleIPFSHashes[i]
            );
        }
    }

    function _addPhaseToSale(
        uint256 _saleId,
        uint128 _startTime,
        uint128 _endTime,
        uint128 _priceInWei,
        uint16 _mintCap,
        uint16 _walletMintLimit,
        bytes32 _merkleRoot,
        string memory _merkleIPFSHash
    ) internal {

        require(_endTime > _startTime, 'Phase end time must be after start time');
        require(_walletMintLimit > 0, 'Zero mint limit');
        require(_mintCap > 0, "Zero mint cap");
        require(_merkleRoot != bytes32(0), "Zero merkle root");
        require(bytes(_merkleIPFSHash).length == 46, "Invalid IPFS hash");

        phases[_saleId].push(Phase({
            startTime : _startTime,
            endTime : _endTime,
            priceInWei : _priceInWei,
            mintCounter : 0,
            mintCap : _mintCap,
            walletMintLimit : _walletMintLimit,
            merkleRoot : _merkleRoot,
            merkleIPFSHash : _merkleIPFSHash
        }));

        emit PhaseCreated(_saleId, phases[_saleId].length - 1);
    }

    function updateFundsReceiver(uint256 _saleId, address _newFundsReceiver) public onlyAdmin {

        require(_newFundsReceiver != address(0), "Unable to send funds to invalid address");
        sales[_saleId].fundsReceiver = _newFundsReceiver;
        emit AdminUpdateFundReceiver(_saleId, _newFundsReceiver);
    }

    function updateMaxEditionId(uint256 _saleId, uint256 _newMaxEditionId) public onlyAdmin {

        require(_newMaxEditionId >= 1, "Unable to set max edition");
        sales[_saleId].maxEditionId = _newMaxEditionId;
        emit AdminUpdateMaxEditionId(_saleId, _newMaxEditionId);
    }

    function updateCreator(uint256 _saleId, address _newCreator) public onlyAdmin {

        require(_newCreator != address(0), "Unable to make invalid address creator");
        sales[_saleId].creator = _newCreator;
        emit AdminUpdateCreator(_saleId, _newCreator);
    }

    function setKoCommissionOverrideForSale(uint256 _saleId, bool _active, uint256 _koCommission) public onlyAdmin {

        require(_koCommission <= (10**40), "KO Commission too high - danger of over overflow");
        KOCommissionOverride storage koCommissionOverride = koCommissionOverrideForSale[_saleId];
        koCommissionOverride.active = _active;
        koCommissionOverride.koCommission = _koCommission;
        emit AdminSetKoCommissionOverrideForSale(_saleId, _koCommission);
    }
}