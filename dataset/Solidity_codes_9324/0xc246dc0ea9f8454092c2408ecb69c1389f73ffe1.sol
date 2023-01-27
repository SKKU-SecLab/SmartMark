


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}







interface IERC1822ProxiableUpgradeable {

    function proxiableUUID() external view returns (bytes32);

}







interface IBeaconUpgradeable {

    function implementation() external view returns (address);

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





pragma solidity 0.8.4;

interface IKODAV3Minter {


    function mintBatchEdition(uint16 _editionSize, address _to, string calldata _uri) external returns (uint256 _editionId);


    function mintBatchEditionAndComposeERC20s(uint16 _editionSize, address _to, string calldata _uri, address[] calldata _erc20s, uint256[] calldata _amounts) external returns (uint256 _editionId);


    function mintConsecutiveBatchEdition(uint16 _editionSize, address _to, string calldata _uri) external returns (uint256 _editionId);

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

interface ICollabRoyaltiesRegistry {


    function createRoyaltiesRecipient(
        address _handler,
        address[] calldata _recipients,
        uint256[] calldata _splits
    ) external returns (address deployedHandler);


    function useRoyaltiesRecipient(uint256 _editionId, address _deployedHandler) external;


    function usePredeterminedRoyaltiesRecipient(
        uint256 _editionId,
        address _handler,
        address[] calldata _recipients,
        uint256[] calldata _splits
    ) external;


    function createAndUseRoyaltiesRecipient(
        uint256 _editionId,
        address _handler,
        address[] calldata _recipients,
        uint256[] calldata _splits
    )
    external returns (address deployedHandler);


    function predictedRoyaltiesHandler(
        address _handler,
        address[] calldata _recipients,
        uint256[] calldata _splits
    ) external view returns (address predictedHandler);


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





pragma solidity 0.8.4;





contract MintingFactoryV2 is Context, UUPSUpgradeable {


    event EditionMinted(uint256 indexed _editionId);
    event EditionMintedAndListed(uint256 indexed _editionId, SaleType _saleType);

    event MintingFactoryCreated();
    event AdminMintingPeriodChanged(uint256 _mintingPeriod);
    event AdminMaxMintsInPeriodChanged(uint256 _maxMintsInPeriod);
    event AdminFrequencyOverrideChanged(address _account, bool _override);
    event AdminRoyaltiesRegistryChanged(address _royaltiesRegistry);

    modifier onlyAdmin() {

        require(accessControls.hasAdminRole(_msgSender()), "Caller must have admin role");
        _;
    }

    modifier canMintAgain(address _sender) {

        require(_canCreateNewEdition(_sender), "Caller unable to create yet");
        _;
    }

    struct MintingPeriod {
        uint128 mints;
        uint128 firstMintInPeriod;
    }

    enum SaleType {
        BUY_NOW, OFFERS, STEPPED, RESERVE
    }

    uint256 public mintingPeriod;

    uint256 public maxMintsInPeriod;

    mapping(address => bool) public frequencyOverride;

    mapping(address => MintingPeriod) mintingPeriodConfig;

    IKOAccessControlsLookup public accessControls;
    IKODAV3Minter public koda;
    IKODAV3PrimarySaleMarketplace public marketplace;
    IKODAV3GatedMarketplace public gatedMarketplace;
    ICollabRoyaltiesRegistry public royaltiesRegistry;

    constructor() initializer {}

    function initialize(
        IKOAccessControlsLookup _accessControls,
        IKODAV3Minter _koda,
        IKODAV3PrimarySaleMarketplace _marketplace,
        IKODAV3GatedMarketplace _gatedMarketplace,
        ICollabRoyaltiesRegistry _royaltiesRegistry
    ) public initializer {


        accessControls = _accessControls;
        koda = _koda;
        marketplace = _marketplace;
        gatedMarketplace = _gatedMarketplace;
        royaltiesRegistry = _royaltiesRegistry;

        mintingPeriod = 30 days;
        maxMintsInPeriod = 15;

        emit MintingFactoryCreated();
    }

    function _authorizeUpgrade(address newImplementation) internal view override {

        require(accessControls.hasAdminRole(msg.sender), "Only admin can upgrade");
    }


    function mintBatchEdition(
        SaleType _saleType,
        uint16 _editionSize,
        uint128 _startDate,
        uint128 _basePrice,
        uint128 _stepPrice,
        string calldata _uri,
        uint256 _merkleIndex,
        bytes32[] calldata _merkleProof,
        address _deployedRoyaltiesHandler
    ) canMintAgain(_msgSender()) external {

        require(accessControls.isVerifiedArtist(_merkleIndex, _msgSender(), _merkleProof), "Caller must have minter role");

        uint256 editionId = koda.mintBatchEdition(_editionSize, _msgSender(), _uri);

        _setupSalesMechanic(editionId, _saleType, _startDate, _basePrice, _stepPrice);
        _recordSuccessfulMint(_msgSender());
        _setupRoyalties(editionId, _deployedRoyaltiesHandler);
    }

    function mintBatchEditionAsProxy(
        address _creator,
        SaleType _saleType,
        uint16 _editionSize,
        uint128 _startDate,
        uint128 _basePrice,
        uint128 _stepPrice,
        string calldata _uri,
        address _deployedRoyaltiesHandler
    ) canMintAgain(_creator) external {

        require(accessControls.isVerifiedArtistProxy(_creator, _msgSender()), "Caller is not artist proxy");

        uint256 editionId = koda.mintBatchEdition(_editionSize, _creator, _uri);

        _setupSalesMechanic(editionId, _saleType, _startDate, _basePrice, _stepPrice);
        _recordSuccessfulMint(_creator);
        _setupRoyalties(editionId, _deployedRoyaltiesHandler);
    }


    function mintBatchEditionGatedOnly(
        uint16 _editionSize,
        uint256 _merkleIndex,
        bytes32[] calldata _merkleProof,
        address _deployedRoyaltiesHandler,
        string calldata _uri
    ) canMintAgain(_msgSender()) external {

        require(accessControls.isVerifiedArtist(_merkleIndex, _msgSender(), _merkleProof), "Caller must have minter role");

        uint256 editionId = koda.mintBatchEdition(_editionSize, _msgSender(), _uri);

        gatedMarketplace.createSale(editionId);

        _recordSuccessfulMint(_msgSender());
        _setupRoyalties(editionId, _deployedRoyaltiesHandler);
    }

    function mintBatchEditionGatedOnlyAsProxy(
        address _creator,
        uint16 _editionSize,
        address _deployedRoyaltiesHandler,
        string calldata _uri
    ) canMintAgain(_creator) external {

        require(accessControls.isVerifiedArtistProxy(_creator, _msgSender()), "Caller is not artist proxy");

        uint256 editionId = koda.mintBatchEdition(_editionSize, _creator, _uri);

        gatedMarketplace.createSale(editionId);

        _recordSuccessfulMint(_creator);
        _setupRoyalties(editionId, _deployedRoyaltiesHandler);
    }


    function mintBatchEditionGatedAndPublic(
        uint16 _editionSize,
        uint128 _publicStartDate,
        uint128 _publicBuyNowPrice,
        uint256 _merkleIndex,
        bytes32[] calldata _merkleProof,
        address _deployedRoyaltiesHandler,
        string calldata _uri
    ) canMintAgain(_msgSender()) external {

        require(accessControls.isVerifiedArtist(_merkleIndex, _msgSender(), _merkleProof), "Caller must have minter role");

        uint256 editionId = koda.mintBatchEdition(_editionSize, _msgSender(), _uri);

        _setupSalesMechanic(editionId, SaleType.BUY_NOW, _publicStartDate, _publicBuyNowPrice, 0);

        gatedMarketplace.createSale(editionId);

        _recordSuccessfulMint(_msgSender());
        _setupRoyalties(editionId, _deployedRoyaltiesHandler);
    }

    function mintBatchEditionGatedAndPublicAsProxy(
        address _creator,
        uint16 _editionSize,
        uint128 _publicStartDate,
        uint128 _publicBuyNowPrice,
        address _deployedRoyaltiesHandler,
        string calldata _uri
    ) canMintAgain(_creator) external {

        require(accessControls.isVerifiedArtistProxy(_creator, _msgSender()), "Caller is not artist proxy");

        uint256 editionId = koda.mintBatchEdition(_editionSize, _creator, _uri);

        _setupSalesMechanic(editionId, SaleType.BUY_NOW, _publicStartDate, _publicBuyNowPrice, 0);

        gatedMarketplace.createSale(editionId);

        _recordSuccessfulMint(_creator);
        _setupRoyalties(editionId, _deployedRoyaltiesHandler);
    }


    function mintBatchEditionOnly(
        uint16 _editionSize,
        uint256 _merkleIndex,
        bytes32[] calldata _merkleProof,
        address _deployedRoyaltiesHandler,
        string calldata _uri
    ) canMintAgain(_msgSender()) external {

        require(accessControls.isVerifiedArtist(_merkleIndex, _msgSender(), _merkleProof), "Caller must have minter role");

        uint256 editionId = koda.mintBatchEdition(_editionSize, _msgSender(), _uri);

        _recordSuccessfulMint(_msgSender());
        _setupRoyalties(editionId, _deployedRoyaltiesHandler);

        emit EditionMinted(editionId);
    }

    function mintBatchEditionOnlyAsProxy(
        address _creator,
        uint16 _editionSize,
        address _deployedRoyaltiesHandler,
        string calldata _uri
    ) canMintAgain(_creator) external {

        require(accessControls.isVerifiedArtistProxy(_creator, _msgSender()), "Caller is not artist proxy");

        uint256 editionId = koda.mintBatchEdition(_editionSize, _creator, _uri);

        _recordSuccessfulMint(_creator);
        _setupRoyalties(editionId, _deployedRoyaltiesHandler);

        emit EditionMinted(editionId);
    }


    function _setupSalesMechanic(uint256 _editionId, SaleType _saleType, uint128 _startDate, uint128 _basePrice, uint128 _stepPrice) internal {

        if (SaleType.BUY_NOW == _saleType) {
            marketplace.listForBuyNow(_msgSender(), _editionId, _basePrice, _startDate);
        }
        else if (SaleType.STEPPED == _saleType) {
            marketplace.listSteppedEditionAuction(_msgSender(), _editionId, _basePrice, _stepPrice, _startDate);
        }
        else if (SaleType.OFFERS == _saleType) {
            marketplace.enableEditionOffers(_editionId, _startDate);
        }
        else if (SaleType.RESERVE == _saleType) {
            marketplace.listForReserveAuction(_msgSender(), _editionId, _basePrice, _startDate);
        }

        emit EditionMintedAndListed(_editionId, _saleType);
    }

    function _setupRoyalties(uint256 _editionId, address _deployedHandler) internal {

        if (_deployedHandler != address(0) && address(royaltiesRegistry) != address(0)) {
            royaltiesRegistry.useRoyaltiesRecipient(_editionId, _deployedHandler);
        }
    }

    function _canCreateNewEdition(address _account) internal view returns (bool) {

        if (frequencyOverride[_account]) {
            return true;
        }

        if (_getNow() <= mintingPeriodConfig[_account].firstMintInPeriod + mintingPeriod) {
            return mintingPeriodConfig[_account].mints < maxMintsInPeriod;
        }

        return true;
    }

    function _recordSuccessfulMint(address _account) internal {

        MintingPeriod storage period = mintingPeriodConfig[_account];

        uint256 endOfCurrentMintingPeriodLimit = period.firstMintInPeriod + mintingPeriod;

        if (period.firstMintInPeriod == 0) {
            period.firstMintInPeriod = _getNow();
            period.mints = period.mints + 1;
        }
        else if (_getNow() <= endOfCurrentMintingPeriodLimit) {
            period.mints = period.mints + 1;
        }
        else if (endOfCurrentMintingPeriodLimit < _getNow()) {
            period.mints = 1;
            period.firstMintInPeriod = _getNow();
        }
    }

    function _getNow() internal virtual view returns (uint128) {

        return uint128(block.timestamp);
    }


    function canCreateNewEdition(address _account) public view returns (bool) {

        return _canCreateNewEdition(_account);
    }

    function currentMintConfig(address _account) public view returns (uint128 mints, uint128 firstMintInPeriod) {

        MintingPeriod memory config = mintingPeriodConfig[_account];
        return (
        config.mints,
        config.firstMintInPeriod
        );
    }

    function setFrequencyOverride(address _account, bool _override) onlyAdmin public {

        frequencyOverride[_account] = _override;
        emit AdminFrequencyOverrideChanged(_account, _override);
    }

    function setMintingPeriod(uint256 _mintingPeriod) onlyAdmin public {

        mintingPeriod = _mintingPeriod;
        emit AdminMintingPeriodChanged(_mintingPeriod);
    }

    function setRoyaltiesRegistry(ICollabRoyaltiesRegistry _royaltiesRegistry) onlyAdmin public {

        royaltiesRegistry = _royaltiesRegistry;
        emit AdminRoyaltiesRegistryChanged(address(_royaltiesRegistry));
    }

    function setMaxMintsInPeriod(uint256 _maxMintsInPeriod) onlyAdmin public {

        maxMintsInPeriod = _maxMintsInPeriod;
        emit AdminMaxMintsInPeriodChanged(_maxMintsInPeriod);
    }

}