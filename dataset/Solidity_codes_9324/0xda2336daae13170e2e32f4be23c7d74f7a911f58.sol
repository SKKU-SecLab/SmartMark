
pragma solidity ^0.8.0;

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

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

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}// MIT

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
}// MIT

pragma solidity ^0.8.2;


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
}// MIT

pragma solidity ^0.8.0;


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
}pragma solidity ^0.8.7;



contract PussyKingClubV1 is Initializable, ContextUpgradeable, UUPSUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _pussyIdTracker;
    
     event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    struct Pussy {
        string Name;
        uint256 PussyId;
        address King;
    }

    struct Auction {
        bool IsStillInProgress;
        uint256 MinPrice;
        uint256 PussyId;
        uint256 AuctionEndTime;
    }

    struct Offer {
        uint256 PussyId;
        uint256 Value;
        address Bidder;
    }
    
    struct Author {
        address Wallet;
        uint8 Part;
    }
    
    bool private _presaleTransferBlock;

    string private _baseTokenURI;
    string private _name;
    string private _symbol;
    address payable private _admin;

    uint256 private _earnedEth;
    uint256 public minBidStep;

    mapping(address => uint256) private _balances;

    mapping(uint256 => Pussy) private _pussies;
    mapping(uint256 => Auction) private _auctions;
    mapping(uint256 => Offer) private _offers;

    function initialize() public initializer {

        __Context_init();
        __UUPSUpgradeable_init();
        _presaleTransferBlock = true;
        minBidStep = 1 * (10 ** 17);

        _name = "PussyKing";
        _symbol = "PUSS";
        _baseTokenURI = "https://pussykingclub.com/";
        _admin = payable(0xDc8b4685332E44F8c3761765c6634B24c036A549);
    }

    function ownerOf(uint256 pussyId) external view returns (address) {

        return _ownerOf(pussyId);
    }

    function _ownerOf(uint256 pussyId) internal view returns (address) {

        address king = _pussies[pussyId].King;
        require(king != address(0), "King query for nonexistent pussy");
        return king;
    }

    function totalSupply() external view returns (uint256) {

        return _pussyIdTracker.current();
    }

    function balanceOf(address king) external view returns (uint256) {

        require(king != address(0), "Balance query for the zero king");
        return _balances[king];
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 pussyId) external view returns (string memory) {

        require(_pussies[pussyId].PussyId != 0, "Invalid pussyId");

        return bytes(_baseTokenURI).length > 0 ? string(abi.encodePacked(_baseTokenURI, pussyId.toString())) : "";
    }
    
    function transferFrom(
        address from,
        address to,
        uint256 pussyId
    ) external payable {

        require(_presaleTransferBlock == false, "Presale is underway");
        require(_msgSender() == from);
        require(_ownerOf(pussyId) == from, "Transfer of pussy that is not own");
        require(to != address(0), "Transfer to the zero king");
        require(_auctions[pussyId].IsStillInProgress == false, "Auction is still in progress");

        _balances[from] -= 1;
        _balances[to] += 1;
        _pussies[pussyId].King = to;

        emit Transfer(from, to, pussyId);
    }

    function uploadPussies(string[] memory pussies) external {

        require(_msgSender() == _admin, "Method is available only to author");
        for(uint8 i = 0; i < pussies.length; i++){
            require(_pussyIdTracker.current() < 100, "Max pussies");
            _pussyIdTracker.increment();
            uint256 pussyId = _pussyIdTracker.current();
            _pussies[pussyId] = Pussy(pussies[i], pussyId, payable(address(0)));
        }
    }

    function uploadPussy(string memory pussyName) external {

        require(_msgSender() == _admin, "Method is available only to author");
        require(_pussyIdTracker.current() < 100, "Max pussies");
        _pussyIdTracker.increment();
        uint256 pussyId = _pussyIdTracker.current();
        _pussies[pussyId] = Pussy(pussyName, pussyId, payable(address(0)));
    }
    
     function authorAuctions(uint256[] memory pussyIds, uint256 startPrice, uint256 auctionTimeInDate) external {

        require(_msgSender() == _admin, "Method is available only to author");
        for(uint8 i = 0; i < pussyIds.length; i++){
            uint256 pussyId = pussyIds[i];
            require(_pussies[pussyId].PussyId != 0, "Invalid pussyId");
            Pussy memory pussy = _pussies[pussyId];
            require(pussy.King == address(0), "Sender not author");

            startAuction(pussyId, startPrice, auctionTimeInDate);
        }
    }
    
    function authorAuction(uint256 pussyId, uint256 startPrice, uint256 auctionTimeInDate) external {

        require(_pussies[pussyId].PussyId != 0, "Invalid pussyId");
        Pussy memory pussy = _pussies[pussyId];
        require(pussy.King == address(0) && _msgSender() == _admin, "Sender not author");

        startAuction(pussyId, startPrice, auctionTimeInDate);
    }

    function auctionPussy(uint256 pussyId, uint256 startPrice, uint256 auctionTimeInDate) external {

        require(_pussies[pussyId].PussyId != 0, "Invalid pussyId");
        Pussy memory pussy = _pussies[pussyId];
        require(pussy.King == _msgSender(), "Sender not King of pussy");

        startAuction(pussyId, startPrice, auctionTimeInDate);
    }

    function startAuction(uint256 pussyId, uint256 startPrice, uint256 auctionTimeInDate) private {

        require(startPrice >= 1 * (10 ** 18), "Min price 1 eth"); // more then 1 eth
        require(_auctions[pussyId].IsStillInProgress == false, "Auction is still in progress");
        require(60 >= auctionTimeInDate && auctionTimeInDate >= 1, "60 >= auctionTimeInDate >= 1");

        uint256 auctionEndTime = block.timestamp + auctionTimeInDate * 24 * 60;
        _auctions[pussyId] = Auction(true, startPrice, pussyId, auctionEndTime);
    }

    function pussyOf(uint256 pussyId) public view returns (string memory, uint256, address) {

        require(_pussies[pussyId].PussyId != 0, "Invalid pussyId"); 
        Pussy memory pussy = _pussies[pussyId];
        return (pussy.Name, pussy.PussyId, pussy.King);
    }
    
    function auctionOf(uint256 pussyId) public view returns (bool, uint256, uint256, uint256) {

        require(_pussies[pussyId].PussyId != 0, "Invalid pussyId");
        Auction memory auction = _auctions[pussyId];
        return (auction.IsStillInProgress, auction.MinPrice, auction.PussyId, auction.AuctionEndTime);
    }
    
    function offerOf(uint256 pussyId) public view returns (uint256,  uint256, address) {

        require(_pussies[pussyId].PussyId != 0, "Invalid pussyId");
        Offer memory offer = _offers[pussyId];
        return (offer.PussyId, offer.Value, offer.Bidder);
    }

    function placeBid(uint256 pussyId) external payable {

        require(_pussies[pussyId].PussyId != 0, "Invalid pussyId");

        Auction memory auction = _auctions[pussyId];
        require(msg.value >= auction.MinPrice, "Auction min price > value");
        require(auction.AuctionEndTime > block.timestamp, "Auction is over");
        
        Offer storage offer = _offers[pussyId];
        require(msg.value >= offer.Value + minBidStep, "Insufficient price");

        if (offer.Bidder != address(0)) {
            AddressUpgradeable.sendValue(payable(offer.Bidder), offer.Value);
        }

        _offers[pussyId] = Offer(pussyId, msg.value, _msgSender());
    }

    function becomePussyKing(uint256 pussyId) external {

        require(_pussies[pussyId].PussyId != 0, "Invalid pussyId");

        Auction memory auction = _auctions[pussyId];
        require(auction.IsStillInProgress, "Auction is not still in progress");
        require(auction.AuctionEndTime < block.timestamp, "The end time of the auction has not yet come");

        Offer memory offer = _offers[pussyId];
        require(offer.Bidder != address(0), "Bidder is zero");


        Pussy memory pussy = _pussies[pussyId];
        uint256 authorReward = 0;
        address from = pussy.King;
        address to = offer.Bidder;
        if(from == address(0)){
            authorReward = offer.Value;
        } else {
            uint256 authorCommision = offer.Value / 5;
            AddressUpgradeable.sendValue(payable(from), offer.Value - authorCommision);
            authorReward = authorCommision;
            _balances[from] -= 1;
        }

        _earnedEth += authorReward;
        _balances[to] += 1;
        _pussies[pussyId] = Pussy(pussy.Name, pussyId, to);
        _offers[pussyId] = Offer(pussyId, 0, address(0));
        _auctions[pussyId] = Auction(false, 0, pussyId, 0);

        emit Transfer(from, to, pussyId);
    }

    function abortAuction(uint256 pussyId) external {

        require(_offers[pussyId].Bidder == address(0), "Has bid");
        address king = _pussies[pussyId].King;
        require(_msgSender() == king || (king == address(0) && _msgSender() == _admin));
        _auctions[pussyId] = Auction(false, 0, pussyId, 0);
    }

    function releaseEarn() external {

        require(_msgSender() == _admin, "Method is available only to admin");

        Author[] memory authors = new Author[](4);
        authors[0] = Author(0x3acaC2b1010553b7F075F7f38eB864a2397472F2, 40);
        authors[1] = Author(0x87cE18C38ff1B42FF491077825ED47F163E01235, 40);
        authors[2] = Author(0x3ab9C686BF000593622327B0Cbcb7B341c370097, 10);
        authors[3] = Author(0x130c69A4683EDEd5C5De668b89c6bfc788e84DE1, 10);

        uint256 currentRelease = _earnedEth;
        for(uint8 i = 0; i < authors.length; i++) {
            Author memory author = authors[i];
            uint256 authorShare = currentRelease / 100 * author.Part;
            AddressUpgradeable.sendValue(payable(author.Wallet), authorShare);
            _earnedEth -= authorShare;
        }
    }
    
    function finishPresale() external {

        require(_msgSender() == _admin, "Method is available only to admin");
        _presaleTransferBlock = false;
    }

    function changeContractAdmin(address newAdmin) external {

        require(_msgSender() == _admin, "Method is available only to admin");
        _admin = payable(newAdmin);
    }

    function owner() public view returns (address) {

        return _admin;
    }

    function _authorizeUpgrade(address) internal override {

        require(_msgSender() == _admin, "Method is available only to admin");
    }
}