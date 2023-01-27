
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

pragma solidity 0.8.12;


contract InitializedProxy is TransparentUpgradeableProxy {

    address public factory;

    constructor(
        address _implementationAddress, 
        address _factoryAddress,
        bytes memory _initializationCallData
    ) TransparentUpgradeableProxy(
        _implementationAddress,
        _factoryAddress,
        _initializationCallData
    ) {
        factory = _factoryAddress;
    }
    receive() external payable override {}

    modifier isFactory() {

        require (msg.sender == factory, "InitializedProxy::isFactory(): Must be calling as factory");
        _;
    }
    
    function getProxyImplementation() external view returns(address){

        return _implementation();
    }
}// MIT

pragma solidity 0.8.12;

contract Merkle {

  function verifyProof(
    bytes32 root,
    bytes32 leaf,
    bytes32[] memory proof
  ) public pure returns (bool) {

    bytes32 currentHash = leaf;

    for(uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      currentHash = currentHash <= proofElement ? 
        keccak256(abi.encodePacked(currentHash, proofElement)) 
        : keccak256(abi.encodePacked(proofElement, currentHash));      
    }

    return currentHash == root;
  }
}// MIT


pragma solidity 0.8.12;

contract ProxyFactoryUpgrade {

    function upgradeKoop(address _newLogic, bytes calldata _data) external {

        TransparentUpgradeableProxy proxyToUpgrade = TransparentUpgradeableProxy(payable(msg.sender));
        if(_data.length > 0) {
            proxyToUpgrade.upgradeToAndCall(_newLogic, _data);
        } else {
            proxyToUpgrade.upgradeTo(_newLogic);
        }
    }
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

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal onlyInitializing {
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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


interface IERC2981Upgradeable is IERC165Upgradeable {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC2981Upgradeable is Initializable, IERC2981Upgradeable, ERC165Upgradeable {
    function __ERC2981_init() internal onlyInitializing {
    }

    function __ERC2981_init_unchained() internal onlyInitializing {
    }
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC2981Upgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        virtual
        override
        returns (address, uint256)
    {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }

    uint256[48] private __gap;
}// MIT


pragma solidity 0.8.12;


contract KoopCore is Merkle, ERC721URIStorageUpgradeable, ERC2981Upgradeable, ReentrancyGuard {

    using Strings for uint256;

    event AllowlistMerkleRootSet(uint256 tierId, bytes32 merkleRoot);
    event MintLimitSet(uint256 tierId, uint256 mintLimit);
    event CrowdfundLaunch(uint256 tierCount, bool transfersBlocked);
    event MemberBadgeTierAdd(uint256 tierId, uint256 mintPrice, uint256 supply, uint256 mintLimit);
    event MemberBadgeTransfersBlock(bool transfersBlocked);
    event MemberBadgeMint(address recipient, uint256 amount, uint256 tierIndex, uint256[] tokenIds);
    event TransferETH(address recipient, uint256 amount);

    address public factory;

    address public immutable proxyAdmin;

    struct MemberBadgeTier {
        uint256 id;                     // unique identifier for this tier (also maps directly to the index of this tier in the memberBadgeTiers array)
        uint256 price;                  // mint price
        uint256 startingId;             // initial tokenId
        uint256 endingId;               // final allocated tokenId
        uint256 currentId;              // the next tokenId to be minted for this tier
        bytes32 allowlistMerkleRoot;
        uint256 mintLimit;
    }

    MemberBadgeTier[] public memberBadgeTiers;

    mapping (bytes32 => uint256) public addressAndTierIndexToMinted;
    
    bool public transfersBlocked = false;

    string public baseURI;

    constructor(address _proxyAdmin) {
        proxyAdmin = _proxyAdmin;
    }

    function __KoopCore_init(
        string calldata _name,
        string calldata _symbol,
        address _factoryAddress,
        uint96 _royaltyFee
    ) public initializer {

        __ERC721URIStorage_init();
        __ERC721_init(_name, _symbol);
        __ERC2981_init();
        factory = _factoryAddress;
        _setDefaultRoyalty(address(this), _royaltyFee);
    }

    function _setAllowlistMerkleRoot(
        uint256 _tierId,
        bytes32 _allowlistMerkleRoot
    ) 
        internal 
    {

        require(_tierId < memberBadgeTiers.length, "KoopCore::_setAllowlistMerkleRoot(): Cannot set allowlist root for a tier that does not exist");
        memberBadgeTiers[_tierId].allowlistMerkleRoot = _allowlistMerkleRoot;
        emit AllowlistMerkleRootSet(_tierId, _allowlistMerkleRoot);
    }

    function _setMintLimit(
        uint256 _tierId,
        uint256 _mintLimit
    ) 
        internal
    {

        require(_tierId < memberBadgeTiers.length, "KoopCore::_setMintLimit(): Cannot set mint limit for a tier that does not exist");
        require(_mintLimit > 0, "KoopCore::_setMintLimit(): Mint limit must be greater than 0");
        memberBadgeTiers[_tierId].mintLimit = _mintLimit;
        emit MintLimitSet(_tierId, _mintLimit);
    }

    function _launchMemberBadgeCrowdfund(
        uint256[] calldata _tierPrices, 
        uint256[] calldata _tierLimits,
        bytes32[] calldata _allowlistMerkleRoots,
        uint256[] calldata _mintLimits,
        string calldata _baseURI,
        bool _blockTransfers
    ) 
        internal 
    {

        require(
            memberBadgeTiers.length == 0, 
            "Koop::_launchMemberBadgeCrowdfund(): crowdfund has already been launched for this Koop"
        );

        uint256 length = _tierPrices.length;
        require(_tierLimits.length == length, "Koop::_launchMemberBadgeCrowdfund(): all input arrays must be same length");
        require(_allowlistMerkleRoots.length == length, "Koop::_launchMemberBadgeCrowdfund(): all input arrays must be same length");
        require(_mintLimits.length == length, "Koop::_launchMemberBadgeCrowdfund(): all input arrays must be same length");


        for(uint256 i = 0; i < length; i++) {
            _createMemberBadgeTier(_tierPrices[i], _tierLimits[i], _allowlistMerkleRoots[i], _mintLimits[i]);
        }
        transfersBlocked = _blockTransfers;

        baseURI = _baseURI;
        emit CrowdfundLaunch(length, _blockTransfers);
    }

    function _addMemberBadgeTiers(
        uint256[] calldata _tierPrices,
        uint256[] calldata _tierLimits,
        bytes32[] calldata _allowlistMerkleRoots,
        uint256[] calldata _mintLimits,
        string calldata _baseURI
    )
        internal
    {

        uint256 length = _tierPrices.length;
        require(_tierLimits.length == length, "Koop::_launchMemberBadgeCrowdfund(): all input arrays must be same length");
        require(_allowlistMerkleRoots.length == length, "Koop::_launchMemberBadgeCrowdfund(): all input arrays must be same length");
        require(_mintLimits.length == length, "Koop::_launchMemberBadgeCrowdfund(): all input arrays must be same length");

        for(uint256 i = 0; i < length; i++) {
            _createMemberBadgeTier(_tierPrices[i], _tierLimits[i], _allowlistMerkleRoots[i], _mintLimits[i]);
        }

        baseURI = _baseURI;
    }

    function _createMemberBadgeTier(
        uint256 _tierPrice,
        uint256 _tierLimit,
        bytes32 _allowlistMerkleRoot,
        uint256 _mintLimit
    ) internal {

        uint256 startingId = memberBadgeTiers.length == 0 ? 0 : memberBadgeTiers[memberBadgeTiers.length - 1].endingId + 1;
        uint256 endingId = startingId + _tierLimit - 1;

        require(_tierLimit > 0, "KoopCore::_createMemberBadgeTier(): _tierLimit must be greater than 0");

        require(startingId + _tierLimit <= type(uint256).max, "KoopCore::_createMemberBadgeTier(): _tierLimit too high, allocated ids would exceed MAX_INT");

        require(_mintLimit > 0, "KoopCore::_createMemberBadgeTier(): _mintLimit must be greater than 0");

        uint256 currentTierId = memberBadgeTiers.length;

        memberBadgeTiers.push(MemberBadgeTier(currentTierId, _tierPrice, startingId, endingId, startingId, _allowlistMerkleRoot, _mintLimit));

        emit MemberBadgeTierAdd(currentTierId, _tierPrice, _tierLimit, _mintLimit);

        currentTierId++;
    }

    function _updateRoyaltyFee(uint96 _royaltyFee) internal {

        _setDefaultRoyalty(address(this), _royaltyFee);
    }

    function _blockMemberBadgeTransfers(bool _blockTransfers)
        internal
    {

        transfersBlocked = _blockTransfers;
        emit MemberBadgeTransfersBlock(transfersBlocked);
    }

    function mintMemberBadge(uint256 _tierId, uint256 _mintCount, bytes32[] calldata _merkleProof) external payable nonReentrant {

        require(memberBadgeTiers.length > 0, "Koop::mintMemberBadge(): a crowdfund has not begun yet");
        require(_tierId < memberBadgeTiers.length, "Koop::mintMemberBadge(): requested tier ID does not exist");
        require(_mintCount > 0, "Koop::mintMemberBadge(): must mint at least 1 token");

        MemberBadgeTier memory tier = memberBadgeTiers[_tierId];
        bytes32 addressAndTierIndexHash = keccak256(abi.encodePacked(msg.sender,_tierId));

        require(tier.currentId <= tier.endingId, "Koop::mintMemberBadge(): no more member badges available at this tier");
        require(tier.price * _mintCount == msg.value, "Koop::mintMemberBadge(): incorrect amount sent to contract for requested member badge tier");
        require(
            addressAndTierIndexToMinted[addressAndTierIndexHash] + _mintCount <= tier.mintLimit, 
            "Koop::mintMemberBadge(): User cannot mint the requested number of this member tier"
        );

        if(tier.allowlistMerkleRoot != bytes32(0x00)) {
            require(
                verifyProof(tier.allowlistMerkleRoot, keccak256(abi.encodePacked(msg.sender)), _merkleProof), 
                "Koop::mintMemberBadge(): address is not on allowlist"
            );
        }
        uint256 mintId = tier.currentId;
        memberBadgeTiers[_tierId].currentId += _mintCount;
        addressAndTierIndexToMinted[addressAndTierIndexHash] += _mintCount;        
        uint256[] memory mintedIds = new uint256[](_mintCount);

        for(uint256 i = 0; i < _mintCount; i++) {
            mintedIds[i] = mintId;
            _safeMint(msg.sender, mintId);
            mintId++;
        }
        
        emit MemberBadgeMint(msg.sender, msg.value, _tierId, mintedIds);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {

        require(_exists(_tokenId), "Koop::tokenURI(): this tokenId has not been minted yet");

        return string(abi.encodePacked(baseURI, _tokenId.toString()));
    }

    function _transferETH(
        address _destination,
        uint256 _amount
    ) internal {

        (bool success, ) = _destination.call{value: _amount}("");
        require(success, "Koop::_transferETH(): could not transfer ETH from contract");
        emit TransferETH(_destination, _amount);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {

        super._beforeTokenTransfer(_from, _to, _amount);

        require(_from == address(0) || _to == address(0) || !transfersBlocked, "Koop::_beforeTokenTransfer(): transfers are blocked for this token");
    }

    function _upgradeKoop(
        address _newLogic, 
        bytes calldata _data
    ) internal {

        ProxyFactoryUpgrade factoryContract = ProxyFactoryUpgrade(factory);
        factoryContract.upgradeKoop(_newLogic, _data);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, ERC2981Upgradeable) returns (bool) {

        return super.supportsInterface(interfaceId);
    }
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


pragma solidity 0.8.12;


contract KoopMembership is KoopCore, OwnableUpgradeable {

    using Strings for uint256;

    constructor(address _proxyAdmin) KoopCore(_proxyAdmin) {}

    function __KoopMembership_init(
        string calldata _name,
        string calldata _symbol,
        address _initialOwner,
        address _factoryAddress,
        uint96 _royaltyFee
    ) external initializer {

        __Ownable_init();
        transferOwnership(_initialOwner);
        __KoopCore_init(_name, _symbol, _factoryAddress, _royaltyFee);
    }

    function setAllowlistMerkleRoot(
        uint256 _tierId,
        bytes32 _allowlistMerkleRoot
    ) onlyOwner external nonReentrant {

        _setAllowlistMerkleRoot(_tierId, _allowlistMerkleRoot);
    }

    function setMintLimit(
        uint256 _tierId,
        uint256 _mintLimit
    ) onlyOwner external nonReentrant {

        _setMintLimit(_tierId, _mintLimit);
    }

    function launchMemberBadgeCrowdfund(
        uint256[] calldata _tierPrices,
        uint256[] calldata _tierLimits,
        bytes32[] calldata _allowlistMerkleRoots,
        uint256[] calldata _mintLimits,
        string calldata _baseURI,
        bool _blockTransfers

    ) onlyOwner external nonReentrant {

        _launchMemberBadgeCrowdfund(
            _tierPrices, 
            _tierLimits, 
            _allowlistMerkleRoots, 
            _mintLimits, 
            _baseURI, 
            _blockTransfers
        );
    }

    function addMemberBadgeTiers(
        uint256[] calldata _tierPrices,
        uint256[] calldata _tierLimits,
        bytes32[] calldata _allowlistMerkleRoots,
        uint256[] calldata _mintLimits,
        string calldata _baseURI
    ) onlyOwner external nonReentrant {

        _addMemberBadgeTiers(_tierPrices, _tierLimits, _allowlistMerkleRoots, _mintLimits, _baseURI);
    }

    function updateRoyaltyFee(
        uint96 _royaltyFee
    ) onlyOwner external nonReentrant {

        _updateRoyaltyFee(_royaltyFee);
    }

    function blockMemberBadgeTransfers(bool _blockTransfers) onlyOwner external nonReentrant {

        _blockMemberBadgeTransfers(_blockTransfers);
    }

    function transferETH(
        address _destination,
        uint256 _amount
    ) onlyOwner external nonReentrant {

        _transferETH(_destination, _amount);
    }

    function upgradeKoop(
        address _newLogic,
        bytes calldata _data
    ) onlyOwner external nonReentrant {

        _upgradeKoop(_newLogic, _data);
    }
}// MIT


pragma solidity 0.8.12;


contract KoopMembershipProxyFactory is ProxyFactoryUpgrade, Ownable {

    event KoopMembershipCreated(address host, address deployedAddress, string externalId);
    event ImplementationCreated(address deployedAddress);

    address public immutable implementation;

    constructor() {
        KoopMembership _implementation = new KoopMembership(owner());
        implementation = address(_implementation);
    }

    function createKoopMembership(
        string calldata _name,
        string calldata _symbol,
        string calldata _externalId,
        uint96 _royaltyFee
    ) external returns (address) {

        bytes memory _koopInitializationCalldata = 
            abi.encodeWithSignature(
                "__KoopMembership_init(string,string,address,address,uint96)",
                _name,
                _symbol,
                msg.sender,
                address(this),
                _royaltyFee
            );

        address koopProxyAddress = address(
            new InitializedProxy(                
                implementation,
                address(this),
                _koopInitializationCalldata
            )
        );
        
        emit KoopMembershipCreated(msg.sender, koopProxyAddress, _externalId);
        return koopProxyAddress;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC1822Proxiable {

    function proxiableUUID() external view returns (bytes32);

}