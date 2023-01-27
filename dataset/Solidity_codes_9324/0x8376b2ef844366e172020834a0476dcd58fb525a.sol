
pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

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

pragma solidity ^0.8.2;


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
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
    function __UUPSUpgradeable_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
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
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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
}interface IAuctionMarketPlace {

    

    event AuctionCreated(uint256 tokenId, uint256 minBidPrice);
    event AuctionBidSubmitted(uint256 tokenId, uint256 amount, address bidder, bool isFirstBid, uint256 endAt);
    event AuctionFinished(uint256 tokenId, address winner, uint256 amount, address caller);
    event AuctionCanceled(uint256 tokenId);
    event AuctionMinBidPriceChanged(uint256 tokenId, uint256 newMinBidPrice);

    function createAuction(uint256 _tokenId,  uint256 _minBidPrice) external;
    function placeBid(uint256 _tokenId) payable external;
    function cancelAuction(uint256 _tokenId) external;
    function changeMinBidPrice(uint256 _tokenId,uint256 _minBidPrice) external;
    function settle(uint256 _tokenId) external;

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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721PausableUpgradeable is Initializable, ERC721Upgradeable, PausableUpgradeable {
    function __ERC721Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __Pausable_init_unchained();
        __ERC721Pausable_init_unchained();
    }

    function __ERC721Pausable_init_unchained() internal onlyInitializing {
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721URIStorage_init_unchained();
    }

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {
    }
    using StringsUpgradeable for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Burnable_init_unchained();
    }

    function __ERC721Burnable_init_unchained() internal onlyInitializing {
    }
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    uint256[50] private __gap;
}// MIT

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

pragma solidity ^0.8.9;


interface IERC2981 {


    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library Counters {
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
}pragma solidity ^0.8.9;



contract FixedPriceMarketPlaceStorage {

    

    Counters.Counter internal _itemIds;
    Counters.Counter internal _itemsSold;
    
    NFTation internal NFTationContract;
    uint8 internal marketPlaceShare;

    mapping(uint256 => MarketItem) internal idToMarketItem;
    

    struct MarketItem {
        uint itemId;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        bool isActive;
    }

    uint256[45] private __gap;
}// MIT
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;






contract FixedPriceMarketPlace is Initializable,
                                  OwnableUpgradeable,
                                  UUPSUpgradeable,PausableUpgradeable,ReentrancyGuardUpgradeable,FixedPriceMarketPlaceStorage {

    using Counters for Counters.Counter;

    event MarketItemDeleted(uint indexed itemId, uint256 tokenId);
    event MoneyTransferred(address from, address to, uint256 amount);
    event NFTTransferred(address from, address to, uint256 tokenId);
    event MarketItemCreated(
        uint indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        uint256 timestamp
        );
    event MarketItemSold(
        uint indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address buyer
        );
    event MarketItemPriceChanged(uint256 itemId, uint256 newPrice);


    constructor() {}

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }
    

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function initToken(address _NFTationContract,uint8 marketPlaceSharePercentage) public onlyOwner {
        NFTationContract = NFTation(_NFTationContract);
        marketPlaceShare = marketPlaceSharePercentage;
    }

    function changeMarketPlaceShare(uint8 _marketPlaceShare) external onlyOwner{
        marketPlaceShare = _marketPlaceShare;
    }

    function getMarketShareAndRoyalty(uint256 tokenId,uint256 price) private view 
    returns(uint256 marketShareAmount,uint256 royaltyAmount ,address  creator){
        bool isFirstSale = NFTationContract.checkFirstSale(tokenId);
        if(isFirstSale){
            marketShareAmount = (price *(marketPlaceShare+ (NFTationContract.getRoyaltyPercentage(tokenId))))/100;
            return (marketShareAmount, 0,address (0));
        }
        else{
             marketShareAmount = ((marketPlaceShare *price) /100);
            (creator, royaltyAmount) = NFTationContract.royaltyInfo(tokenId ,price);
            return (marketShareAmount, royaltyAmount,creator);
        }
    }

    function getMarketItemPrice(uint256 _marketItemId) public view returns(uint256) {
        return idToMarketItem[_marketItemId].price;
    }

    function createMarketItem(uint256 tokenId, uint256 price) external  whenNotPaused nonReentrant returns (uint256)   {
        require(price > 0, "price must be greater than 0");
        _itemIds.increment();
        uint itemId = _itemIds.current();
        idToMarketItem[itemId] = MarketItem(
            itemId,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false,
            true);

        NFTationContract.transferFrom(msg.sender, address(this), tokenId);
        emit MarketItemCreated(itemId, tokenId, msg.sender, address(this), price, block.timestamp);
        return itemId;
    }

    function changeMarketItemPrice(uint256 _itemId, uint256 _newPrice) external whenNotPaused nonReentrant  {
        MarketItem storage _marketItem = idToMarketItem[_itemId];
        require(_marketItem.isActive, "Invalid market item");
        require(msg.sender == _marketItem.seller, "Only seller can change price");
        require(_newPrice > 0, "price must be greater than 0");
        _marketItem.price = _newPrice;
        emit MarketItemPriceChanged(_itemId, _newPrice);
    }

    function deleteMarketItem(uint256 _itemId) external whenNotPaused nonReentrant {
        MarketItem storage _marketItem = idToMarketItem[_itemId];
        require(_marketItem.sold == false, "Can't delete soled market item");
        require(msg.sender == _marketItem.seller, "Only owner can remove market item");
        uint256 tokenId = idToMarketItem[_itemId].tokenId;
        address seller = _marketItem.seller;
        delete idToMarketItem[_itemId];
        
        NFTationContract.transferFrom(address(this),seller, tokenId);

        
        emit MarketItemDeleted(_itemId, idToMarketItem[_itemId].tokenId);
    }

    function createMarketSale(uint256 itemId) external payable whenNotPaused nonReentrant {
        MarketItem storage marketItem = idToMarketItem[itemId];
        uint price = marketItem.price;
        uint _tokenId = marketItem.tokenId;
        require(msg.value == price, "You should include the price of the item");
        require(msg.sender != marketItem.seller, 'seller can not buy its owned token');
        (uint256 marketPlaceShareAmount, uint256 royaltyAmount,address  tokenCreator) = getMarketShareAndRoyalty(_tokenId, price);
        marketItem.owner = payable(msg.sender);
        marketItem.sold = true;
        marketItem.isActive = false;
        _itemsSold.increment();

         bool sent;
        (sent, ) = payable(owner()).call{value: marketPlaceShareAmount}("");
        require(sent);
        
        if(royaltyAmount > 0){
            (sent, ) = payable(tokenCreator).call{value: royaltyAmount}("") ;
            require(sent);
        }
        if(NFTationContract.checkFirstSale(_tokenId)){
            NFTationContract.disableFirstSale(_tokenId);
        }
        uint256 remaining = (price-(marketPlaceShareAmount))-(royaltyAmount);
        (sent, ) = payable(marketItem.seller).call{value: remaining}("") ;
        require(sent);
        NFTationContract.transferFrom(address(this), msg.sender, _tokenId);
        emit MoneyTransferred(msg.sender, marketItem.seller, remaining);
        emit NFTTransferred(address(this), msg.sender, _tokenId);
        emit MarketItemSold(itemId, _tokenId, marketItem.seller, msg.sender);
    }
}pragma solidity ^0.8.9;

contract NFTationStorage {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter internal _tokenIdCounter;
    FixedPriceMarketPlace internal fixedPriceMarketPlaceContract;
    AuctionMarketPlace internal auctionMarketPlaceContract;
    mapping(uint256 => bool) internal tokenFirstSaleMapping;
    mapping(uint256 => Royalty) internal royalties;

    struct Royalty {
        address receiver;
        uint256 percentage;
    }
    
    uint256[44] private __gap;
}// MIT
pragma solidity ^0.8.9;


contract NFTation is Initializable, 
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    ERC721BurnableUpgradeable,
    UUPSUpgradeable,
    ERC721PausableUpgradeable,
    IERC2981,
    NFTationStorage {

    using CountersUpgradeable for CountersUpgradeable.Counter;

    event TokenBurnt(address owner, uint256 tokenId);
    event TokenCreated(
        address owner,
        uint256 tokenId,
        string tokenURI,
        uint256 royalty
    );

    constructor() {}

    function initialize() initializer public {
        __ERC721_init("NFTation", "NFTAT");
        __ERC721URIStorage_init();
        __Ownable_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();
        __ERC721Pausable_init();
    }

    function initMarketPlaces(
        address _fixedPriceMarketPlaceContract,
        address _auctionMarketPlaceContract
    )
        public onlyOwner 
    {
        auctionMarketPlaceContract = AuctionMarketPlace(_auctionMarketPlaceContract);
        fixedPriceMarketPlaceContract = FixedPriceMarketPlace(_fixedPriceMarketPlaceContract);
    }

    function isMArketPlacesActiveForAccount() public view returns (bool) {
        return (isApprovedForAll(msg.sender, address(fixedPriceMarketPlaceContract)) &&
                isApprovedForAll(msg.sender, address(auctionMarketPlaceContract)));
    }

    function aprovalMarketPlacesForAccount() external {
        setApprovalForAll(address(fixedPriceMarketPlaceContract), true);
        setApprovalForAll(address(auctionMarketPlaceContract), true);
    }

    function mint(string memory uri, uint256 royaltyPercentage) public {
        require(royaltyPercentage <= 50 , 'NFTation: invalid royalty');

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        tokenFirstSaleMapping[tokenId] = true;
        _setRoyalty(tokenId, _msgSender(), royaltyPercentage);

        _safeMint(_msgSender(), tokenId);
        super._setTokenURI(tokenId, uri);
        
        emit TokenCreated(_msgSender(), tokenId, uri, royaltyPercentage);
    }

    function burn(uint256 _tokenId) public override {
        super.burn(_tokenId);

        emit TokenBurnt(_msgSender(), _tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
         override(ERC721Upgradeable, ERC721PausableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        _deleteRoyalty(tokenId);
        super._burn(tokenId);
    }

    function _baseURI() internal view override(ERC721Upgradeable) returns (string memory) {
        return "ipfs://";
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _setRoyalty(uint256 _tokenId, address _receiver, uint256 _percentage) internal {
        royalties[_tokenId] = Royalty(_receiver, _percentage);
    }

    function _deleteRoyalty(uint256 _tokenId) internal {
        delete(royalties[_tokenId]);
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    )
        public
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = royalties[_tokenId].receiver;

        royaltyAmount = _salePrice * royalties[_tokenId].percentage / 100;
    }

    function getRoyaltyPercentage(uint256 _tokenId) public view returns (uint256) {
        return  royalties[_tokenId].percentage;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable)
        returns (bool)
    {
        if(interfaceId == type(IERC2981).interfaceId) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }

    function checkFirstSale(uint256 _tokenId) external view returns (bool){
        return tokenFirstSaleMapping[_tokenId];
    }

    function disableFirstSale(uint256 _tokenId) external {
        require(_isApprovedOrOwner(msg.sender,_tokenId), 'NFTation: token must be approved');
        delete (tokenFirstSaleMapping[_tokenId]);
    }

    function pause() public virtual  onlyOwner {
        _pause();
    }

    function unpause() public virtual onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}pragma solidity ^ 0.8.9;



contract AuctionMarketPlaceStorage {

    struct Auction {
        uint256 startedAt;
        uint256 minBidPrice;
        address seller;
        uint256 lastBidAmount;
        address lastBidBidder;
        uint256 lastBidAt;
        bool hasBid; // whene first bid placed on auction this item change to true.
        bool initiated; // whene an auction created, this item change to true and never change again until delete whole auction.
    }

    NFTation                    internal NFTationContract;
    uint256                     internal marketPlaceShare;
    mapping(uint256 => Auction) internal auctionMapping;

    uint256 internal auctionDuration ;
    uint256 internal auctionExtendDuration ;

    mapping(uint256 =>  mapping (address => uint256)) internal pendingWidthrawMapping;

    uint256[44] private __gap;

}// MIT
pragma solidity ^0.8.9;




contract AuctionMarketPlace is IAuctionMarketPlace, Initializable,UUPSUpgradeable, OwnableUpgradeable, PausableUpgradeable,
                               ReentrancyGuardUpgradeable,AuctionMarketPlaceStorage {

    constructor() {}

    function initialize() initializer public {
        __UUPSUpgradeable_init();
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();


        auctionDuration  = 1 days;
        auctionExtendDuration = 15 minutes;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function initToken(address _NFTationContract,uint8 marketPlaceSharePercentage) public onlyOwner {
        NFTationContract = NFTation(_NFTationContract);
        marketPlaceShare = marketPlaceSharePercentage;
    }

    function changeMarketPlaceShare(uint8 _marketPlaceShare) external onlyOwner {
        marketPlaceShare = _marketPlaceShare;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setAuctionTiming(uint256 _auctionDuration,uint256 _auctionExtendDuration) external onlyOwner {
        require (_auctionDuration >= _auctionExtendDuration,"AuctionMarkerPlace: Auction Extend Duration must be less than Auction Duration");
        auctionDuration = _auctionDuration;
        auctionExtendDuration = _auctionExtendDuration;
    }

    function createAuction(uint256 _tokenId,  uint256 _minBidPrice) external nonReentrant whenNotPaused {
        Auction storage auction = auctionMapping[_tokenId];
        auction.minBidPrice = _minBidPrice;
        auction.seller = msg.sender;
        auction.initiated = true;
        NFTationContract.transferFrom(msg.sender, address(this), _tokenId);

        emit AuctionCreated(_tokenId, _minBidPrice);
    }

    function placeBid(uint256 _tokenId) payable external nonReentrant whenNotPaused {
        Auction storage auction = auctionMapping[_tokenId];
        require(auction.initiated, "AuctionMarkerPlace: Auction not initiated.");
        require(auction.startedAt == 0 || block.timestamp <= auction.startedAt + auctionDuration || block.timestamp < auction.lastBidAt + auctionExtendDuration, "AuctionMarketPlace: Auction times up.");
        require(msg.value >= auction.minBidPrice, "AuctionMarketPlace: Bid Should be more than minimum bid price.");
        require(msg.value >= auction.lastBidAmount * 11 / 10, "AuctionMarketPlace: Bid should be 10% more than last bid.");
        require(msg.sender != auction.seller, "AuctionMarketPlace: Seller can not bid on its owned auction.");
        bool isFirstBid = false;
        address lastBidBidder = auction.lastBidBidder;
        uint256 lastBidAmount = auction.lastBidAmount;
        auction.lastBidAmount = msg.value;
        auction.lastBidBidder = msg.sender;
        auction.lastBidAt = block.timestamp;
        if (!auction.hasBid) {
            auction.startedAt = block.timestamp;
            auction.hasBid = true;
            isFirstBid = true;
        } else {
            (bool sent, ) = payable(lastBidBidder).call{value: lastBidAmount}("") ;
            if(!sent){
                pendingWidthrawMapping[_tokenId][lastBidBidder] =lastBidAmount;
            }
        }
        uint256 endAt = (auction.startedAt + auctionDuration) > (auction.lastBidAt + auctionExtendDuration) ? auction.startedAt + auctionDuration : auction.lastBidAt + auctionExtendDuration;
        emit AuctionBidSubmitted(_tokenId, msg.value, msg.sender, isFirstBid, endAt);
    }

    function settle(uint256 _tokenId) external whenNotPaused nonReentrant { 

        Auction memory auction = auctionMapping[_tokenId];
        require(auction.initiated, "AuctionMarkerPlace: Auction not initiated.");
        require(auction.hasBid, "AuctionMarkerPlace: Auction not started yet.");
        require(block.timestamp > auction.startedAt + auctionDuration && block.timestamp > auction.lastBidAt + auctionExtendDuration, "AuctionMarketPlace: auction not finished yet.");
        (uint256 marketPlaceShareAmount, uint256 royaltyAmount, address tokenCreator) = getMarketShareAndRoyalty(_tokenId, auction.lastBidAmount);
        uint256 remaining = auction.lastBidAmount - (marketPlaceShareAmount + royaltyAmount);
        delete auctionMapping[_tokenId];

        bool sent;
        (sent, ) = payable(owner()).call{value: marketPlaceShareAmount}("") ;
        require(sent);
        if(royaltyAmount > 0){
            (sent, ) = payable(tokenCreator).call{value: royaltyAmount}("") ;
            require(sent);
        }
        if(NFTationContract.checkFirstSale(_tokenId))
            NFTationContract.disableFirstSale(_tokenId);

        NFTationContract.transferFrom(address(this) ,auction.lastBidBidder, _tokenId);
        (sent, ) = payable(auction.seller).call{value: remaining}("") ;
        require(sent);
        emit AuctionFinished(_tokenId, auction.lastBidBidder, auction.lastBidAmount ,msg.sender);
    }

    function cancelAuction(uint256 _tokenId) external whenNotPaused nonReentrant {
        Auction memory auction = auctionMapping[_tokenId];
        require(auction.initiated, "AuctionMarkerPlace: Auction not initiated.");
        require(!auction.hasBid, "AuctionMarkerPlace: Auction started.");
        require(auction.seller == msg.sender, "AuctionMarkerPlace: Only seller can cancel auction.");
        delete auctionMapping[_tokenId];

        NFTationContract.transferFrom(address(this) ,msg.sender,  _tokenId);
        emit AuctionCanceled(_tokenId);
    }

    function changeMinBidPrice(uint256 _tokenId, uint256 _newMinBidPrice) external whenNotPaused {
        Auction storage auction = auctionMapping[_tokenId];

        require(auction.initiated, "AuctionMarkerPlace: Auction not initiated.");
        require(!auction.hasBid, "AuctionMarkerPlace: Auction started.");
        require(auction.seller == msg.sender, "AuctionMarkerPlace: Only seller can change minimum bid price of auction.");
        auction.minBidPrice = _newMinBidPrice;
        emit AuctionMinBidPriceChanged(_tokenId, _newMinBidPrice);
    }

    function getMarketShareAndRoyalty(uint256 tokenId, uint256 price) private view returns(uint256 marketShareAmount, uint256 royaltyAmount, address creator) {
        bool isFirstSale = NFTationContract.checkFirstSale(tokenId);
        if(isFirstSale) {
            marketShareAmount = price * (marketPlaceShare + NFTationContract.getRoyaltyPercentage(tokenId)) / 100;
            return(marketShareAmount, 0, address(0));
        } else {
             marketShareAmount = ((marketPlaceShare *price) /100);
            (creator, royaltyAmount) = NFTationContract.royaltyInfo(tokenId , (price));
            return(marketShareAmount, royaltyAmount,creator);
        }
    }

    function withdraw(uint256 _tokenId) external nonReentrant  {
        uint balance = pendingWidthrawMapping[_tokenId][msg.sender];
        pendingWidthrawMapping[_tokenId][msg.sender] = 0;
        (bool sent, ) = payable(msg.sender).call{value: balance}("") ;
        require(sent);
    }

    function getAuctionMapping (uint256 _tokenId) view external returns(Auction memory ){
        return auctionMapping[_tokenId];
    }

    function getPendingWidthrawMapping (uint256 _tokenId,address _address) view external returns(uint256 ){
        return pendingWidthrawMapping[_tokenId][_address];
    }
}