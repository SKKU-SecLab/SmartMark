



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


interface IERC2981 is IERC165 {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}




pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}



pragma solidity ^0.8.13;



interface IERC721Mintable is IERC721, IERC2981 {

    function mintingCharge() external view returns (uint256);


    function royalities(uint256 _tokenId) external view returns (uint256);


    function creators(uint256 _tokenId) external view returns (address payable);


    function broker() external view returns (address payable);


    function ecosystemContract(address) external view returns (bool);


    struct _brokerage {
        uint256 seller;
        uint256 buyer;
    }

    function brokerage() external view returns (_brokerage calldata);

}




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}




pragma solidity ^0.8.0;

interface IERC1822ProxiableUpgradeable {

    function proxiableUUID() external view returns (bytes32);

}




pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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




pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}




pragma solidity ^0.8.0;


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




pragma solidity ^0.8.0;




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
}




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
}




pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;



contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    uint256[50] private __gap;
}



pragma solidity ^0.8.13;








contract UPYOERC721MarketPlace is
    Initializable,
    UUPSUpgradeable,
    ERC721HolderUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{



    struct auction {
        address payable seller;
        uint256 currentBid;
        address payable highestBidder;
        uint256 auctionType;
        uint256 startingPrice;
        uint256 startingTime;
        uint256 closingTime;
        address erc20Token;
    }

    struct _brokerage {
        uint256 seller;
        uint256 buyer;
    }

    mapping(address => mapping(uint256 => auction)) _auctions;

    mapping(address => bool) public tokenAllowed;

    mapping(address => _brokerage) public brokerage;

    address payable public broker;

    uint256 public constant decimalPrecision = 100;

    event Bid(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed seller,
        address bidder,
        uint256 amouont,
        uint256 time,
        address ERC20Address
    );
    event Sold(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed seller,
        address buyer,
        uint256 amount,
        address collector,
        uint256 auctionType,
        uint256 time,
        address ERC20Address
    );
    event OnSale(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 auctionType,
        uint256 amount,
        uint256 time,
        address ERC20Address
    );
    event PriceUpdated(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 auctionType,
        uint256 oldAmount,
        uint256 amount,
        uint256 time,
        address ERC20Address
    );
    event OffSale(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 time,
        address ERC20Address
    );

    modifier erc20Allowed(address _erc20Token) {

        require(tokenAllowed[_erc20Token], "ERC20 not allowed");
        _;
    }

    modifier onSaleOnly(uint256 _tokenId, address _erc721) {

        require(
            auctions(_erc721, _tokenId).seller != address(0),
            "Token Not For Sale"
        );
        _;
    }

    modifier activeAuction(uint256 _tokenId, address _erc721) {

        require(
            block.timestamp < auctions(_erc721, _tokenId).closingTime,
            "Auction Time Over!"
        );
        _;
    }

    modifier auctionOnly(uint256 _tokenId, address _erc721) {

        require(
            auctions(_erc721, _tokenId).auctionType == 2,
            "Auction Not For Bid"
        );
        _;
    }

    modifier flatSaleOnly(uint256 _tokenId, address _erc721) {

        require(
            auctions(_erc721, _tokenId).auctionType == 1,
            "Auction for Bid only!"
        );
        _;
    }

    modifier tokenOwnerOnly(uint256 _tokenId, address _erc721) {

        require(
            IERC721Mintable(_erc721).ownerOf(_tokenId) == msg.sender,
            "You must be owner and Token should not have any bid"
        );
        _;
    }

    function auctions(address _erc721, uint256 _tokenId)
        public
        view
        returns (auction memory)
    {

        address _owner = IERC721Mintable(_erc721).ownerOf(_tokenId);
        if (
            _owner == _auctions[_erc721][_tokenId].seller ||
            _owner == address(this)
        ) {
            return _auctions[_erc721][_tokenId];
        }
    }

    function addERC20TokenPayment(
        address _erc20Token,
        _brokerage calldata brokerage_
    ) external onlyOwner {

        tokenAllowed[_erc20Token] = true;
        brokerage[_erc20Token] = brokerage_;
    }

    function updateBroker(address payable _broker) external onlyOwner {

        broker = _broker;
    }

    function removeERC20TokenPayment(address _erc20Token)
        external
        erc20Allowed(_erc20Token)
        onlyOwner
    {

        tokenAllowed[_erc20Token] = false;
        delete brokerage[_erc20Token];
    }

    function bid(
        uint256 _tokenId,
        address _erc721,
        uint256 amount
    )
        external
        payable
        onSaleOnly(_tokenId, _erc721)
        activeAuction(_tokenId, _erc721)
        nonReentrant
    {

        IERC721Mintable Token = IERC721Mintable(_erc721);

        auction memory _auction = _auctions[_erc721][_tokenId];

        if (_auction.erc20Token == address(0)) {
            require(
                msg.value > _auction.currentBid,
                "Insufficient bidding amount."
            );

            if (_auction.highestBidder != address(0)) {
                _auction.highestBidder.transfer(_auction.currentBid);
            }
        } else {
            IERC20Upgradeable erc20Token = IERC20Upgradeable(
                _auction.erc20Token
            );
            require(
                erc20Token.allowance(msg.sender, address(this)) >= amount,
                "Allowance is less than amount sent for bidding."
            );
            require(
                amount > _auction.currentBid,
                "Insufficient bidding amount."
            );
            erc20Token.transferFrom(msg.sender, address(this), amount);

            if (_auction.highestBidder != address(0)) {
                erc20Token.transfer(
                    _auction.highestBidder,
                    _auction.currentBid
                );
            }
        }

        _auction.currentBid = _auction.erc20Token == address(0)
            ? msg.value
            : amount;

        Token.safeTransferFrom(
            Token.ownerOf(_tokenId),
            address(this),
            _tokenId
        );
        _auction.highestBidder = payable(msg.sender);

        _auctions[_erc721][_tokenId] = _auction;

        emit Bid(
            _erc721,
            _tokenId,
            _auction.seller,
            _auction.highestBidder,
            _auction.currentBid,
            block.timestamp,
            _auction.erc20Token
        );
    }

    function _getCreatorAndRoyalty(
        address _erc721,
        uint256 _tokenId,
        uint256 amount
    ) private view returns (address payable, uint256) {

        address creator;
        uint256 royalty;

        IERC721Mintable collection = IERC721Mintable(_erc721);

        try collection.royaltyInfo(_tokenId, amount) returns (
            address receiver,
            uint256 royaltyAmount
        ) {
            creator = receiver;
            royalty = royaltyAmount;
        } catch {
            try collection.royalities(_tokenId) returns (uint256 royalities) {
                try collection.creators(_tokenId) returns (
                    address payable receiver
                ) {
                    creator = receiver;
                    royalty = (royalities * amount) / (100 * 100);
                } catch {}
            } catch {}
        }
        return (payable(creator), royalty);
    }

    function collect(uint256 _tokenId, address _erc721)
        external
        onSaleOnly(_tokenId, _erc721)
        auctionOnly(_tokenId, _erc721)
        nonReentrant
    {
        IERC721Mintable Token = IERC721Mintable(_erc721);
        auction memory _auction = _auctions[_erc721][_tokenId];

        if (msg.sender != _auction.seller) {
            require(
                block.timestamp > _auction.closingTime,
                "Auction Not Over!"
            );
        }

        if (_auction.highestBidder != address(0)) {
            (address payable creator, uint256 royalty) = _getCreatorAndRoyalty(
                _erc721,
                _tokenId,
                _auction.currentBid
            );

            _brokerage memory brokerage_;

            brokerage_.seller = (brokerage[_auction.erc20Token].seller *
                _auction.currentBid) / (100 * decimalPrecision);

            brokerage_.buyer = (brokerage[_auction.erc20Token].buyer *
                _auction.currentBid) / (100 * decimalPrecision);

            uint256 sellerFund = _auction.currentBid -
                royalty -
                brokerage_.seller -
                brokerage_.buyer;

            if (_auction.erc20Token == address(0)) {
                creator.transfer(royalty);
                _auction.seller.transfer(sellerFund);
                broker.transfer(brokerage_.seller + brokerage_.buyer);
            }
            else {
                IERC20Upgradeable erc20Token = IERC20Upgradeable(
                    _auction.erc20Token
                );
                erc20Token.transfer(creator, royalty);
                erc20Token.transfer(_auction.seller, sellerFund);
                erc20Token.transfer(broker, brokerage_.seller + brokerage_.buyer);
            }
            Token.safeTransferFrom(
                Token.ownerOf(_tokenId),
                _auction.highestBidder,
                _tokenId
            );

            emit Sold(
                _erc721,
                _tokenId,
                _auction.seller,
                _auction.highestBidder,
                _auction.currentBid - brokerage_.buyer,
                msg.sender,
                _auction.auctionType,
                block.timestamp,
                _auction.erc20Token
            );
        }
        delete _auctions[_erc721][_tokenId];
    }

    function buy(uint256 _tokenId, address _erc721)
        external
        payable
        onSaleOnly(_tokenId, _erc721)
        flatSaleOnly(_tokenId, _erc721)
        nonReentrant
    {
        IERC721Mintable Token = IERC721Mintable(_erc721);
        auction memory _auction = _auctions[_erc721][_tokenId];

        (address payable creator, uint256 royalty) = _getCreatorAndRoyalty(
            _erc721,
            _tokenId,
            _auction.startingPrice
        );

        _brokerage memory brokerage_;

        brokerage_.seller = (brokerage[_auction.erc20Token].seller *
            _auction.startingPrice) / (100 * decimalPrecision);

        brokerage_.buyer = (brokerage[_auction.erc20Token].buyer *
            _auction.startingPrice) / (100 * decimalPrecision);

        uint256 sellerFund = _auction.startingPrice -
            royalty -
            brokerage_.seller;

        if (_auction.erc20Token == address(0)) {
            require(
                msg.value >= _auction.startingPrice + brokerage_.buyer,
                "Insufficient Payment"
            );
            creator.transfer(royalty);
            _auction.seller.transfer(sellerFund);
            broker.transfer(msg.value - royalty - sellerFund);
        }
        else {
            IERC20Upgradeable erc20Token = IERC20Upgradeable(
                _auction.erc20Token
            );
            require(
                erc20Token.allowance(msg.sender, address(this)) >=
                    _auction.startingPrice + brokerage_.buyer,
                "Insufficient spent allowance "
            );
            erc20Token.transferFrom(msg.sender, creator, royalty);
            erc20Token.transferFrom(
                msg.sender,
                broker,
                brokerage_.seller + brokerage_.buyer
            );
            erc20Token.transferFrom(msg.sender, _auction.seller, sellerFund);
        }

        Token.safeTransferFrom(Token.ownerOf(_tokenId), msg.sender, _tokenId);

        emit Sold(
            _erc721,
            _tokenId,
            _auction.seller,
            msg.sender,
            _auction.startingPrice,
            msg.sender,
            _auction.auctionType,
            block.timestamp,
            _auction.erc20Token
        );

        delete _auctions[_erc721][_tokenId];
    }

    function withdraw(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function withdrawERC20(address _erc20Token, uint256 amount)
        external
        onlyOwner
    {
        IERC20Upgradeable erc20Token = IERC20Upgradeable(_erc20Token);
        erc20Token.transfer(msg.sender, amount);
    }

    function putOnSale(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _auctionType,
        uint256 _startingTime,
        uint256 _endindTime,
        address _erc721,
        address _erc20Token
    ) external erc20Allowed(_erc20Token) tokenOwnerOnly(_tokenId, _erc721) {
        {
            IERC721Mintable Token = IERC721Mintable(_erc721);

            require(
                Token.getApproved(_tokenId) == address(this) ||
                    Token.isApprovedForAll(msg.sender, address(this)),
                "Broker Not approved"
            );
            require(
                _startingTime < _endindTime,
                "Ending time must be grater than Starting time"
            );
        }
        auction memory _auction = _auctions[_erc721][_tokenId];

        if (_auction.seller != address(0) && _auction.auctionType == 2) {
            require(
                _auction.highestBidder == address(0) &&
                    block.timestamp > _auction.closingTime,
                "This NFT is already on sale."
            );
        }

        auction memory newAuction = auction(
            payable(msg.sender),
            _startingPrice + (brokerage[_erc20Token].buyer * _startingPrice) /
                (100 * decimalPrecision),
            payable(address(0)),
            _auctionType,
            _startingPrice,
            _startingTime,
            _endindTime,
            _erc20Token
        );

        _auctions[_erc721][_tokenId] = newAuction;

        emit OnSale(
            _erc721,
            _tokenId,
            msg.sender,
            _auctionType,
            _startingPrice,
            block.timestamp,
            _erc20Token
        );
    }

    function updatePrice(
        uint256 _tokenId,
        address _erc721,
        uint256 _newPrice,
        address _erc20Token
    )
        external
        onSaleOnly(_tokenId, _erc721)
        erc20Allowed(_erc20Token)
        tokenOwnerOnly(_tokenId, _erc721)
    {
        auction memory _auction = _auctions[_erc721][_tokenId];

        if (_auction.auctionType == 2) {
            require(
                block.timestamp < _auction.closingTime,
                "Auction Time Over!"
            );
        }
        emit PriceUpdated(
            _erc721,
            _tokenId,
            _auction.seller,
            _auction.auctionType,
            _auction.startingPrice,
            _newPrice,
            block.timestamp,
            _auction.erc20Token
        );
        _auction.startingPrice = _newPrice;
        if (_auction.auctionType == 2) {
            _auction.currentBid = _newPrice + (brokerage[_erc20Token].buyer * _newPrice) /
                (100 * decimalPrecision);
        }
        _auction.erc20Token = _erc20Token;
        _auctions[_erc721][_tokenId] = _auction;
    }

    function putSaleOff(uint256 _tokenId, address _erc721)
        external
        tokenOwnerOnly(_tokenId, _erc721)
    {
        auction memory _auction = _auctions[_erc721][_tokenId];

        emit OffSale(
            _erc721,
            _tokenId,
            msg.sender,
            block.timestamp,
            _auction.erc20Token
        );
        delete _auctions[_erc721][_tokenId];
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    constructor() initializer {}

    function _authorizeUpgrade(address) internal override onlyOwner {}
}