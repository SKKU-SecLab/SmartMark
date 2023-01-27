
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library ECDSAUpgradeable {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;

interface IResolver {

    function preconfigure(
        string[] memory keys,
        string[] memory values,
        uint256 tokenId
    ) external;


    function get(string calldata key, uint256 tokenId) external view returns (string memory);


    function getMany(string[] calldata keys, uint256 tokenId) external view returns (string[] memory);


    function getByHash(uint256 keyHash, uint256 tokenId) external view returns (string memory key, string memory value);


    function getManyByHash(uint256[] calldata keyHashes, uint256 tokenId)
        external
        view
        returns (string[] memory keys, string[] memory values);


    function set(
        string calldata key,
        string calldata value,
        uint256 tokenId
    ) external;

}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;

interface IMintingController {

    function mintSLD(address to, string calldata label) external;


    function safeMintSLD(address to, string calldata label) external;


    function safeMintSLD(
        address to,
        string calldata label,
        bytes calldata data
    ) external;


    function mintSLDWithResolver(
        address to,
        string memory label,
        address resolver
    ) external;


    function safeMintSLDWithResolver(
        address to,
        string calldata label,
        address resolver
    ) external;


    function safeMintSLDWithResolver(
        address to,
        string calldata label,
        address resolver,
        bytes calldata data
    ) external;

}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;

interface IURIPrefixController {

    function setTokenURIPrefix(string calldata prefix) external;

}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;

interface IMintingManager {

    function mintSLD(
        address to,
        uint256 tld,
        string calldata label
    ) external;


    function safeMintSLD(
        address to,
        uint256 tld,
        string calldata label
    ) external;


    function safeMintSLD(
        address to,
        uint256 tld,
        string calldata label,
        bytes calldata data
    ) external;


    function mintSLDWithRecords(
        address to,
        uint256 tld,
        string calldata label,
        string[] calldata keys,
        string[] calldata values
    ) external;


    function safeMintSLDWithRecords(
        address to,
        uint256 tld,
        string calldata label,
        string[] calldata keys,
        string[] calldata values
    ) external;


    function safeMintSLDWithRecords(
        address to,
        uint256 tld,
        string calldata label,
        string[] calldata keys,
        string[] calldata values,
        bytes calldata data
    ) external;


    function claim(uint256 tld, string calldata label) external;


    function claimTo(
        address to,
        uint256 tld,
        string calldata label
    ) external;


    function claimToWithRecords(
        address to,
        uint256 tld,
        string calldata label,
        string[] calldata keys,
        string[] calldata values
    ) external;


    function setTokenURIPrefix(string calldata prefix) external;

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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;

interface IRecordReader {

    function get(string calldata key, uint256 tokenId) external view returns (string memory);


    function getMany(string[] calldata keys, uint256 tokenId) external view returns (string[] memory);


    function getByHash(uint256 keyHash, uint256 tokenId) external view returns (string memory key, string memory value);


    function getManyByHash(uint256[] calldata keyHashes, uint256 tokenId)
        external
        view
        returns (string[] memory keys, string[] memory values);

}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;


interface IRecordStorage is IRecordReader {

    event Set(uint256 indexed tokenId, string indexed keyIndex, string indexed valueIndex, string key, string value);

    event NewKey(uint256 indexed tokenId, string indexed keyIndex, string key);

    event ResetRecords(uint256 indexed tokenId);

    function set(
        string calldata key,
        string calldata value,
        uint256 tokenId
    ) external;


    function setMany(
        string[] memory keys,
        string[] memory values,
        uint256 tokenId
    ) external;


    function setByHash(
        uint256 keyHash,
        string calldata value,
        uint256 tokenId
    ) external;


    function setManyByHash(
        uint256[] calldata keyHashes,
        string[] calldata values,
        uint256 tokenId
    ) external;


    function reconfigure(
        string[] memory keys,
        string[] memory values,
        uint256 tokenId
    ) external;


    function reset(uint256 tokenId) external;

}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;



interface IUNSRegistry is IERC721MetadataUpgradeable, IRecordStorage {

    event NewURI(uint256 indexed tokenId, string uri);

    event NewURIPrefix(string prefix);

    function setTokenURIPrefix(string calldata prefix) external;


    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);


    function resolverOf(uint256 tokenId) external view returns (address);


    function childIdOf(uint256 tokenId, string calldata label) external pure returns (uint256);


    function exists(uint256 tokenId) external view returns (bool);


    function setOwner(address to, uint256 tokenId) external;


    function burn(uint256 tokenId) external;


    function mint(
        address to,
        uint256 tokenId,
        string calldata uri
    ) external;


    function safeMint(
        address to,
        uint256 tokenId,
        string calldata uri
    ) external;


    function safeMint(
        address to,
        uint256 tokenId,
        string calldata uri,
        bytes calldata data
    ) external;


    function mintWithRecords(
        address to,
        uint256 tokenId,
        string calldata uri,
        string[] calldata keys,
        string[] calldata values
    ) external;


    function safeMintWithRecords(
        address to,
        uint256 tokenId,
        string calldata uri,
        string[] calldata keys,
        string[] calldata values
    ) external;


    function safeMintWithRecords(
        address to,
        uint256 tokenId,
        string calldata uri,
        string[] calldata keys,
        string[] calldata values,
        bytes calldata data
    ) external;

}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;


abstract contract Relayer is ContextUpgradeable {
    using ECDSAUpgradeable for bytes32;

    event Relayed(address indexed sender, address indexed signer, bytes4 indexed funcSig, bytes32 digest);

    function relay(bytes calldata data, bytes calldata signature) external returns (bytes memory) {
        bytes32 digest = keccak256(data);
        address signer = keccak256(abi.encodePacked(digest, address(this))).toEthSignedMessageHash().recover(signature);

        bytes4 funcSig;
        bytes memory _data = data;
        assembly {
            funcSig := mload(add(_data, add(0x20, 0)))
        }

        _verifyRelaySigner(signer);
        _verifyRelayCall(funcSig, data);

        (bool success, bytes memory result) = address(this).call(data);
        if (success == false) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }

        emit Relayed(_msgSender(), signer, funcSig, digest);
        return result;
    }

    function _verifyRelaySigner(address signer) internal view virtual {
        require(signer != address(0), 'Relayer: SIGNATURE_IS_INVALID');
    }

    function _verifyRelayCall(bytes4 funcSig, bytes calldata data) internal pure virtual {}
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlUpgradeable {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

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
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                StringsUpgradeable.toHexString(uint160(account), 20),
                " is missing role ",
                StringsUpgradeable.toHexString(uint256(role), 32)
            )));
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
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
}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;


abstract contract MinterRole is OwnableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

    modifier onlyMinter() {
        require(isMinter(_msgSender()), 'MinterRole: CALLER_IS_NOT_MINTER');
        _;
    }

    function __MinterRole_init() internal initializer {
        __Ownable_init_unchained();
        __AccessControl_init_unchained();
        __MinterRole_init_unchained();
    }

    function __MinterRole_init_unchained() internal initializer {}

    function isMinter(address account) public view returns (bool) {
        return hasRole(MINTER_ROLE, account);
    }

    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    function addMinters(address[] memory accounts) public onlyOwner {
        for (uint256 index = 0; index < accounts.length; index++) {
            _addMinter(accounts[index]);
        }
    }

    function removeMinter(address account) public onlyOwner {
        _removeMinter(account);
    }

    function removeMinters(address[] memory accounts) public onlyOwner {
        for (uint256 index = 0; index < accounts.length; index++) {
            _removeMinter(accounts[index]);
        }
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function closeMinter(address payable receiver) external payable onlyMinter {
        require(receiver != address(0x0), 'MinterRole: RECEIVER_IS_EMPTY');

        renounceMinter();
        receiver.transfer(msg.value);
    }

    function rotateMinter(address payable receiver) external payable onlyMinter {
        require(receiver != address(0x0), 'MinterRole: RECEIVER_IS_EMPTY');

        _addMinter(receiver);
        renounceMinter();
        receiver.transfer(msg.value);
    }

    function _addMinter(address account) internal {
        _setupRole(MINTER_ROLE, account);
    }

    function _removeMinter(address account) internal {
        renounceRole(MINTER_ROLE, account);
    }
}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;



contract MintingManager is Initializable, ContextUpgradeable, OwnableUpgradeable, MinterRole, Relayer, IMintingManager {

    string public constant NAME = 'UNS: Minting Manager';
    string public constant VERSION = '0.1.0';

    IUNSRegistry public unsRegistry;
    IMintingController public cnsMintingController;
    IURIPrefixController public cnsURIPrefixController;
    IResolver public cnsResolver;

    mapping(uint256 => string) internal _tlds;

    bytes4 private constant _SIG_MINT = 0xae2ad903;

    bytes4 private constant _SIG_SAFE_MINT = 0x4c1819e0;

    bytes4 private constant _SIG_SAFE_MINT_DATA = 0x58839d6b;

    bytes4 private constant _SIG_MINT_WITH_RECORDS = 0x39ccf4d0;

    bytes4 private constant _SIG_SAFE_MINT_WITH_RECORDS = 0x27bbd225;

    bytes4 private constant _SIG_SAFE_MINT_WITH_RECORDS_DATA = 0x6a2d2256;

    modifier onlyRegisteredTld(uint256 tld) {

        require(bytes(_tlds[tld]).length > 0, 'MintingManager: TLD_NOT_REGISTERED');
        _;
    }

    function initialize(
        IUNSRegistry unsRegistry_,
        IMintingController cnsMintingController_,
        IURIPrefixController cnsURIPrefixController_,
        IResolver cnsResolver_
    ) public initializer {

        unsRegistry = unsRegistry_;
        cnsMintingController = cnsMintingController_;
        cnsURIPrefixController = cnsURIPrefixController_;
        cnsResolver = cnsResolver_;

        __Ownable_init_unchained();
        __MinterRole_init_unchained();

        _addMinter(address(this));

        _tlds[0x0f4a10a4f46c288cea365fcf45cccf0e9d901b945b9829ccdb54c10dc3cb7a6f] = 'crypto';

        string[8] memory tlds = ['wallet', 'coin', 'x', 'nft', 'blockchain', 'bitcoin', '888', 'dao'];
        for (uint256 i = 0; i < tlds.length; i++) {
            uint256 namehash = uint256(keccak256(abi.encodePacked(uint256(0x0), keccak256(abi.encodePacked(tlds[i])))));
            _tlds[namehash] = tlds[i];

            if (!unsRegistry.exists(namehash)) {
                unsRegistry.mint(address(0xdead), namehash, tlds[i]);
            }
        }
    }

    function mintSLD(
        address to,
        uint256 tld,
        string calldata label
    ) external override onlyMinter onlyRegisteredTld(tld) {

        _mintSLD(to, tld, label);
    }

    function safeMintSLD(
        address to,
        uint256 tld,
        string calldata label
    ) external override onlyMinter onlyRegisteredTld(tld) {

        _safeMintSLD(to, tld, label, '');
    }

    function safeMintSLD(
        address to,
        uint256 tld,
        string calldata label,
        bytes calldata data
    ) external override onlyMinter onlyRegisteredTld(tld) {

        _safeMintSLD(to, tld, label, data);
    }

    function mintSLDWithRecords(
        address to,
        uint256 tld,
        string calldata label,
        string[] calldata keys,
        string[] calldata values
    ) external override onlyMinter onlyRegisteredTld(tld) {

        _mintSLDWithRecords(to, tld, label, keys, values);
    }

    function safeMintSLDWithRecords(
        address to,
        uint256 tld,
        string calldata label,
        string[] calldata keys,
        string[] calldata values
    ) external override onlyMinter onlyRegisteredTld(tld) {

        _safeMintSLDWithRecords(to, tld, label, keys, values, '');
    }

    function safeMintSLDWithRecords(
        address to,
        uint256 tld,
        string calldata label,
        string[] calldata keys,
        string[] calldata values,
        bytes calldata data
    ) external override onlyMinter onlyRegisteredTld(tld) {

        _safeMintSLDWithRecords(to, tld, label, keys, values, data);
    }

    function claim(uint256 tld, string calldata label) external override onlyRegisteredTld(tld) {

        _mintSLD(_msgSender(), tld, _freeSLDLabel(label));
    }

    function claimTo(
        address to,
        uint256 tld,
        string calldata label
    ) external override onlyRegisteredTld(tld) {

        _mintSLD(to, tld, _freeSLDLabel(label));
    }

    function claimToWithRecords(
        address to,
        uint256 tld,
        string calldata label,
        string[] calldata keys,
        string[] calldata values
    ) external override onlyRegisteredTld(tld) {

        _mintSLDWithRecords(to, tld, _freeSLDLabel(label), keys, values);
    }

    function setResolver(address resolver) external onlyOwner {

        cnsResolver = IResolver(resolver);
    }

    function setTokenURIPrefix(string calldata prefix) external override onlyOwner {

        unsRegistry.setTokenURIPrefix(prefix);
        if (address(cnsURIPrefixController) != address(0x0)) {
            cnsURIPrefixController.setTokenURIPrefix(prefix);
        }
    }

    function _verifyRelaySigner(address signer) internal view override {

        super._verifyRelaySigner(signer);
        require(isMinter(signer), 'MintingManager: SIGNER_IS_NOT_MINTER');
    }

    function _verifyRelayCall(bytes4 funcSig, bytes calldata) internal pure override {

        bool isSupported =
            funcSig == _SIG_MINT ||
                funcSig == _SIG_SAFE_MINT ||
                funcSig == _SIG_SAFE_MINT_DATA ||
                funcSig == _SIG_MINT_WITH_RECORDS ||
                funcSig == _SIG_SAFE_MINT_WITH_RECORDS ||
                funcSig == _SIG_SAFE_MINT_WITH_RECORDS_DATA;

        require(isSupported, 'MintingManager: UNSUPPORTED_RELAY_CALL');
    }

    function _mintSLD(
        address to,
        uint256 tld,
        string memory label
    ) private {

        if (tld == 0x0f4a10a4f46c288cea365fcf45cccf0e9d901b945b9829ccdb54c10dc3cb7a6f) {
            cnsMintingController.mintSLDWithResolver(to, label, address(cnsResolver));
        } else {
            unsRegistry.mint(to, _childId(tld, label), _uri(tld, label));
        }
    }

    function _safeMintSLD(
        address to,
        uint256 tld,
        string calldata label,
        bytes memory data
    ) private {

        if (tld == 0x0f4a10a4f46c288cea365fcf45cccf0e9d901b945b9829ccdb54c10dc3cb7a6f) {
            cnsMintingController.safeMintSLDWithResolver(to, label, address(cnsResolver), data);
        } else {
            unsRegistry.safeMint(to, _childId(tld, label), _uri(tld, label), data);
        }
    }

    function _mintSLDWithRecords(
        address to,
        uint256 tld,
        string memory label,
        string[] calldata keys,
        string[] calldata values
    ) private {

        uint256 tokenId = _childId(tld, label);
        if (tld == 0x0f4a10a4f46c288cea365fcf45cccf0e9d901b945b9829ccdb54c10dc3cb7a6f) {
            cnsMintingController.mintSLDWithResolver(to, label, address(cnsResolver));
            if (keys.length > 0) {
                cnsResolver.preconfigure(keys, values, tokenId);
            }
        } else {
            unsRegistry.mintWithRecords(to, tokenId, _uri(tld, label), keys, values);
        }
    }

    function _safeMintSLDWithRecords(
        address to,
        uint256 tld,
        string memory label,
        string[] calldata keys,
        string[] calldata values,
        bytes memory data
    ) private {

        uint256 tokenId = _childId(tld, label);
        if (tld == 0x0f4a10a4f46c288cea365fcf45cccf0e9d901b945b9829ccdb54c10dc3cb7a6f) {
            cnsMintingController.safeMintSLDWithResolver(to, label, address(cnsResolver), data);
            if (keys.length > 0) {
                cnsResolver.preconfigure(keys, values, tokenId);
            }
        } else {
            unsRegistry.safeMintWithRecords(to, tokenId, _uri(tld, label), keys, values, data);
        }
    }

    function _childId(uint256 tokenId, string memory label) internal pure returns (uint256) {

        require(bytes(label).length != 0, 'MintingManager: LABEL_EMPTY');
        return uint256(keccak256(abi.encodePacked(tokenId, keccak256(abi.encodePacked(label)))));
    }

    function _freeSLDLabel(string calldata label) private pure returns (string memory) {

        return string(abi.encodePacked('udtestdev-', label));
    }

    function _uri(uint256 tld, string memory label) private view returns (string memory) {

        return string(abi.encodePacked(label, '.', _tlds[tld]));
    }

    uint256[50] private __gap;
}