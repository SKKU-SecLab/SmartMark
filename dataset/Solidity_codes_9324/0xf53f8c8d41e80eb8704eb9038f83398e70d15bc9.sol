

pragma solidity 0.8.2;




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
}


interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}


interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}


interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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


library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



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
}


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
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

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
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


abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}


abstract contract ERC165StorageUpgradeable is Initializable, ERC165Upgradeable {
    function __ERC165Storage_init() internal initializer {
        __ERC165_init_unchained();
        __ERC165Storage_init_unchained();
    }

    function __ERC165Storage_init_unchained() internal initializer {
    }
    mapping(bytes4 => bool) private _supportedInterfaces;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}


contract EmogramMarketplaceUpgradeable is 
 Initializable, UUPSUpgradeable, ERC165StorageUpgradeable, ReentrancyGuardUpgradeable, AccessControlUpgradeable {



    bytes32 public constant FOUNDER_ROLE = keccak256("FOUNDER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    bytes4 constant ERC2981ID = 0x2a55205a;

    bool isTestPeriod;

    struct initAuction {
        bool isInitialAuction;
        uint256 cycle;
    }

    bool public isInitialAuction = true;

    struct sellItem {
        uint256 sellId;
        address tokenAddress;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool isSold;
    }

    struct auctionItem {
        uint256 auctionId;
        address tokenAddress;
        uint256 tokenId;
        address payable seller;
        address payable highestBidder;
        uint256 startPrice;
        uint256 highestBid;
        uint256 endDate;
        bool onAuction;
    }

    initAuction public initialAuction;

    sellItem[] public emogramsOnSale;
    auctionItem[] public emogramsOnAuction;

    mapping(uint256 => uint256) private initialEmogramsorder;

    mapping(address => mapping(uint256 => bool)) public activeEmograms;
    mapping(address => mapping(uint256 => bool)) public activeAuctions;

    event EmogramAdded(uint256 indexed id, uint256 indexed tokenId, address indexed tokenAddress, uint256 askingPrice);
    event SellCancelled(address indexed sender, address indexed tokenAddress, uint256 indexed tokenId);
    event EmogramSold (uint256 indexed id, uint256 indexed tokenId, address indexed buyer, uint256 askingPrice, address seller);
    event BidPlaced(uint256 indexed id, uint256 indexed tokenId, address indexed bidder, uint256 bid);
    event AuctionCreated(uint256 indexed id, uint256 indexed tokenId, address indexed seller, address tokenAddress, uint256 startPrice, uint256 duration);
    event AuctionCanceled(uint256 indexed id, uint256 indexed tokenId, address indexed seller, address tokenAddress);
    event AuctionFinished(uint256 indexed id, uint256 indexed tokenId, address indexed highestBidder, address seller, uint256 highestBid);
    event InitialAuctionSale(uint256 indexed id, uint256 indexed tokenid, address highestBidder, uint256 highestBid);
    event InitialAuctionFinished();

    modifier isTheOwner(address _tokenAddress, uint256 _tokenId, address _owner) {

        IERC1155 tokenContract = IERC1155(_tokenAddress);
        require(tokenContract.balanceOf(_owner, _tokenId) != 0, "Not owner");
        _;
    }

    modifier isTheHighestBidder(address _bidder, uint256 _auctionId) {

        require(emogramsOnAuction[_auctionId].highestBidder == _bidder, "Not the highest Bidder");
        _;
    }

    modifier hasTransferApproval (address tokenAddress, uint256 tokenId) {

        IERC1155 tokenContract = IERC1155(tokenAddress);
        require(tokenContract.isApprovedForAll(msg.sender, address(this)) == true, "No Approval");
        _;
    }

    modifier isInitialAuctionPeriod() {

        require(initialAuction.isInitialAuction == true, "The initial auction period has already ended");
        _;
    }

    modifier auctionNotEnded(uint256 _auctionId) {

        require(emogramsOnAuction[_auctionId].endDate > block.timestamp, "Auction has already ended");
        _;
    }

        modifier auctionEnded(uint256 _auctionId) {

        require(emogramsOnAuction[_auctionId].endDate < block.timestamp, "Auction is still ongoing");
        _;
    }

    modifier AuctionActive(uint256 _auctionId) {

        require(activeAuctions[emogramsOnAuction[_auctionId].tokenAddress][emogramsOnAuction[_auctionId].tokenId] == true, "Auction already finished");
        _;
    }

    modifier itemExists(uint256 id){

        require(id <= emogramsOnSale.length && emogramsOnSale[id].sellId == id, "Could not find item");
        _;
    }
    
    modifier itemExistsAuction(uint256 id) {

        require(id <= emogramsOnAuction.length && emogramsOnAuction[id].auctionId == id, "Could not find item");
        _;
    }

    modifier isForSale(uint256 id) {

        require(emogramsOnSale[id].isSold == false, "Item is already sold");
        _;
    }

    function initialize(bool _isTest) initializer public {

        
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __ERC165Storage_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FOUNDER_ROLE, msg.sender);
        _setupRole(UPGRADER_ROLE, msg.sender);

        _registerInterface(ERC2981ID);
        isTestPeriod = _isTest;

        initialAuction.isInitialAuction = true;
        initialAuction.cycle = 0;
    }

    function setInitialorder(uint256[99] memory _ids) 
    public
    onlyRole(FOUNDER_ROLE) {

         require(_ids.length == 99, "id length mismatch");
         for(uint256 i = 0; i < _ids.length; i++) {
             initialEmogramsorder[i] = _ids[i];
         }
    }

    function addFounder(address _newFounder)
    public
    onlyRole(DEFAULT_ADMIN_ROLE) {


            grantRole(FOUNDER_ROLE, _newFounder);
        }

    function emogramsOnSaleLength()
    public
    view
    returns (uint256) {

            return emogramsOnSale.length;
        }

    function emogramsOnAuctionLength()
    public
    view
    returns (uint256) {

            return emogramsOnAuction.length;
        }

    function getSaleArray()
    public
    view
    returns (sellItem[] memory) {

          return emogramsOnSale;
      }

     function getAuctionArray()
    public
    view
    returns (auctionItem[] memory) {

          return emogramsOnAuction;
      }

    function sendRoyalty(uint256 _id) 
    private 
    returns(address, uint256) {


        (bool succes, bytes memory result) = emogramsOnSale[_id].tokenAddress.call(abi.encodeWithSignature("royaltyInfo(uint256,uint256)", emogramsOnSale[_id].tokenId, emogramsOnSale[_id].price));
        (address receiver, uint256 royAmount) = abi.decode(result, (address, uint256));
        uint256 toSend = SafeMath.sub(emogramsOnSale[_id].price,royAmount);

        (bool sent, bytes memory data) = receiver.call{value: royAmount}("");
        require(sent, "Failed to send royalty");

        return (emogramsOnSale[_id].seller, toSend);

    }

    function sendRoyaltyAuction(uint256 _id)
    private
    returns(address, uint256) {


        (bool succes, bytes memory result) = emogramsOnAuction[_id].tokenAddress.call(abi.encodeWithSignature("royaltyInfo(uint256,uint256)", emogramsOnAuction[_id].tokenId, emogramsOnAuction[_id].highestBid));
        (address receiver, uint256 royAmount) = abi.decode(result, (address, uint256));

        uint256 toSend = emogramsOnAuction[_id].highestBid - royAmount;

        (bool sent, bytes memory data) = receiver.call{value: royAmount}("");
        require(sent, "Failed to send royalty");

        return (emogramsOnAuction[_id].highestBidder, toSend);
    }

    function addEmogramToMarket(uint256 tokenId, address tokenAddress, uint256 askingPrice) 
    hasTransferApproval(tokenAddress, tokenId)
    nonReentrant() 
    external 
    returns(uint256) {

        require(activeEmograms[tokenAddress][tokenId] == false, "Item is already up for sale");
        require(activeAuctions[tokenAddress][tokenId] == false, "Item already up for auction");
        uint256 newItemId = emogramsOnSale.length;
        emogramsOnSale.push(sellItem(newItemId, tokenAddress, tokenId, payable(msg.sender), askingPrice, false));
        activeEmograms[tokenAddress][tokenId] = true;

        assert(emogramsOnSale[newItemId].sellId == newItemId);
        emit EmogramAdded(newItemId, tokenId, tokenAddress, askingPrice);
        return newItemId;
    }

    function cancelSell(uint256 _id) 
    itemExists(_id)
    isForSale(_id)
    isTheOwner(emogramsOnSale[_id].tokenAddress, emogramsOnSale[_id].tokenId, msg.sender)
    public {

        
        emit SellCancelled(msg.sender, emogramsOnSale[_id].tokenAddress, emogramsOnSale[_id].tokenId);
        activeEmograms[emogramsOnSale[_id].tokenAddress][emogramsOnSale[_id].tokenId] = false;
        delete emogramsOnSale[_id];
    } 

    function buyEmogram(uint256 id) 
    payable  
    external
    nonReentrant() 
    itemExists(id) 
    isForSale(id) 
    {

        require(msg.value >= emogramsOnSale[id].price, "Not enough funds for purchase");
        require(msg.sender != emogramsOnSale[id].seller, "Cannot buy own item");

        emogramsOnSale[id].isSold = true;
        activeEmograms[emogramsOnSale[id].tokenAddress][emogramsOnSale[id].tokenId] = false;
        IERC1155(emogramsOnSale[id].tokenAddress).safeTransferFrom(emogramsOnSale[id].seller, msg.sender, emogramsOnSale[id].tokenId, 1, "");

        (address receiver, uint256 toSend) = sendRoyalty(id);

        (bool sentSucces, bytes memory dataRec) = emogramsOnSale[id].seller.call{value: toSend}("");
        require(sentSucces, "Failed to buy");

        emit EmogramSold(id, emogramsOnSale[id].tokenId, msg.sender, emogramsOnSale[id].price, emogramsOnSale[id].seller);
    }

    function createAuction(uint256 _tokenId, address _tokenAddress, uint256 _duration, uint256 _startPrice) 
    hasTransferApproval(_tokenAddress, _tokenId)
    isTheOwner(_tokenAddress, _tokenId, msg.sender)
    nonReentrant()
    public
    returns (uint256) 
    {

        require(activeAuctions[_tokenAddress][_tokenId] == false, "Emogram is already up for auction");
        require(activeEmograms[_tokenAddress][_tokenId] == false, "Item is already up for sale");
        uint256 durationToDays;

        if(isTestPeriod == true) {
            durationToDays = block.timestamp + _duration; //TODO: actually in secs
        }
        else {
            durationToDays = block.timestamp + _duration * 1 days;
         }

        emogramsOnAuction.push(auctionItem(emogramsOnAuction.length, _tokenAddress, _tokenId, payable(msg.sender), payable(msg.sender), _startPrice, _startPrice, durationToDays, true));
        activeAuctions[_tokenAddress][_tokenId] = true;

        assert(emogramsOnAuction[emogramsOnAuction.length - 1].auctionId == emogramsOnAuction.length - 1);
        emit AuctionCreated(emogramsOnAuction[emogramsOnAuction.length - 1].auctionId, _tokenId, msg.sender, _tokenAddress, _startPrice, durationToDays);

        return emogramsOnAuction[emogramsOnAuction.length - 1].auctionId;
    }

    function cancelAuction(uint256 _auctionId, uint256 _tokenId, address _tokenAddress)
    hasTransferApproval(_tokenAddress, _tokenId)
    isTheOwner(_tokenAddress, _tokenId, msg.sender)
    auctionNotEnded(_auctionId)
    nonReentrant()
    payable
    external
    returns(uint256) 
    {

        require(activeAuctions[_tokenAddress][_tokenId] == true, "This auction doesn't exits anymore");

        if(emogramsOnAuction[_auctionId].highestBid == emogramsOnAuction[_auctionId].startPrice) {

            activeAuctions[_tokenAddress][_tokenId] = false;
            delete emogramsOnAuction[_auctionId];
            emit AuctionCanceled(_auctionId, _tokenId, msg.sender, _tokenAddress);
        }

        else {

            (bool sent, bytes memory data) = emogramsOnAuction[_auctionId].highestBidder.call{value: emogramsOnAuction[_auctionId].highestBid}("");
            require(sent, "Failed to cancel");
            activeAuctions[_tokenAddress][_tokenId] = false;
            delete emogramsOnAuction[_auctionId];

            emit AuctionCanceled(_auctionId, _tokenId, msg.sender, _tokenAddress);
        }
    }

    function PlaceBid(uint256 _auctionId, uint256 _tokenId, address _tokenAddress)
    auctionNotEnded(_auctionId)
    nonReentrant()
    payable
    external
    returns(uint256)
    {

        require(activeAuctions[_tokenAddress][_tokenId] == true, "Auction has already finished");
        require(emogramsOnAuction[_auctionId].highestBid <= msg.value, "Bid too low");
        require(emogramsOnAuction[_auctionId].seller != msg.sender, "Can't bid on your own auction!");

        if(emogramsOnAuction[_auctionId].highestBid != emogramsOnAuction[_auctionId].startPrice) {    
        (bool sent, bytes memory data) = emogramsOnAuction[_auctionId].highestBidder.call{value: emogramsOnAuction[_auctionId].highestBid}("");
        require(sent, "Failed to place bid");

        emogramsOnAuction[_auctionId].highestBidder = payable(msg.sender);
        emogramsOnAuction[_auctionId].highestBid = msg.value;

        emit BidPlaced(_auctionId, emogramsOnAuction[_auctionId].tokenId, msg.sender, msg.value);
        return _auctionId;
        }

        else {
            require(emogramsOnAuction[_auctionId].highestBid < msg.value, "Bid too low");
            emogramsOnAuction[_auctionId].highestBidder = payable(msg.sender);
            emogramsOnAuction[_auctionId].highestBid = msg.value;

            emit BidPlaced(_auctionId, emogramsOnAuction[_auctionId].tokenId, msg.sender, msg.value);
            return _auctionId;
        }
    }

    function stepAuctions(address _tokenAddress, uint256 _startPrice, uint256 _duration)
    isInitialAuctionPeriod()
    onlyRole(FOUNDER_ROLE)
    payable
    external
     {

        require(initialAuction.cycle <= 34, "Max cycles already reached");

        if(emogramsOnAuction.length == initialAuction.cycle * 3 && initialAuction.cycle != 0) {

            for(uint i = (initialAuction.cycle * 3) - 1; i >= (initialAuction.cycle * 3) - 3; i--) {
                if(emogramsOnAuction[i].highestBidder == msg.sender) {
                    endAuctionWithNoBid(_tokenAddress, emogramsOnAuction[i].tokenId, emogramsOnAuction[i].auctionId);
                }
                else {
                    endAuctionWithBid(_tokenAddress, emogramsOnAuction[i].tokenId, emogramsOnAuction[i].auctionId);
                }
                if(i == 0) { break; }
            }
        }

        if(initialAuction.cycle < 33) {
            for(uint256 i = (initialAuction.cycle * 3); i < (initialAuction.cycle * 3 + 3); i++) {

                createAuction(initialEmogramsorder[i], _tokenAddress, _duration, _startPrice);
            }
        }


        initialAuction.cycle = initialAuction.cycle + 1;

        if(initialAuction.cycle >= 34) {
            initialAuction.isInitialAuction = false;
            emit InitialAuctionFinished();
        }

     }

    function endAuctionWithBid(address _tokenAddress, uint256 _tokenId, uint256 _auctionId) private {


        require(emogramsOnAuction[_auctionId].highestBid != 0, "Highest bid cannot be zero in endAuctionWithBid()");

        (address receiver, uint256 toSend) = sendRoyaltyAuction(_auctionId);

        (bool sentSucces, bytes memory dataReceived) = emogramsOnAuction[_auctionId].seller.call{value: toSend}("");
        require(sentSucces, "Failed to cancel");

        IERC1155(emogramsOnAuction[_auctionId].tokenAddress).safeTransferFrom(emogramsOnAuction[_auctionId].seller, emogramsOnAuction[_auctionId].highestBidder, emogramsOnAuction[_auctionId].tokenId, 1, "");
            
        activeAuctions[_tokenAddress][_tokenId] = false;
        emit AuctionFinished(_auctionId, _tokenId, emogramsOnAuction[_auctionId].highestBidder, emogramsOnAuction[_auctionId].seller, emogramsOnAuction[_auctionId].highestBid);
        delete emogramsOnAuction[_auctionId];
     }

    function endAuctionWithNoBid(address _tokenAddress, uint256 _tokenId, uint256 _auctionId) private {


        require(activeAuctions[_tokenAddress][_tokenId] == true);
        require(emogramsOnAuction[_auctionId].highestBid == emogramsOnAuction[_auctionId].startPrice && emogramsOnAuction[_auctionId].highestBidder == emogramsOnAuction[_auctionId].seller);

        activeAuctions[_tokenAddress][_tokenId] = false;
        emit AuctionFinished(_auctionId, _tokenId, emogramsOnAuction[_auctionId].highestBidder, emogramsOnAuction[_auctionId].seller, emogramsOnAuction[_auctionId].highestBid);     
        delete emogramsOnAuction[_auctionId];    
     }

    function finishAuction(address _tokenAddress, uint256 _tokenId, uint256 _auctionId)
    auctionEnded(_auctionId)
    AuctionActive(_auctionId)
    nonReentrant()
    hasTransferApproval(_tokenAddress, _tokenId)
    itemExistsAuction(_auctionId) 
    public
    returns (bool)
     {

        IERC1155 tokenContract = IERC1155(_tokenAddress);
        require(tokenContract.balanceOf(msg.sender, _tokenId) != 0 || emogramsOnAuction[_auctionId].highestBidder == msg.sender, "Not the owner or highest bidder");

        if(emogramsOnAuction[_auctionId].highestBid != emogramsOnAuction[_auctionId].startPrice) {

            endAuctionWithBid(_tokenAddress, _tokenId, _auctionId);
            return true;
        }

        else if(emogramsOnAuction[_auctionId].highestBid == emogramsOnAuction[_auctionId].startPrice && emogramsOnAuction[_auctionId].highestBidder == emogramsOnAuction[_auctionId].seller) {

            endAuctionWithNoBid(_tokenAddress, _tokenId, _auctionId);
            return true;
        }
     }

    function setPeriod(bool _isTest)
    onlyRole(FOUNDER_ROLE)
    public
    returns (bool) {

        isTestPeriod = _isTest;
        return isTestPeriod;
    }

    function _authorizeUpgrade(address) 
    internal 
    override
    onlyRole(UPGRADER_ROLE) {}


    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(AccessControlUpgradeable, ERC165StorageUpgradeable)
    returns (bool) {

        
        return super.supportsInterface(interfaceId);
    }
    
    receive() external payable {}
}