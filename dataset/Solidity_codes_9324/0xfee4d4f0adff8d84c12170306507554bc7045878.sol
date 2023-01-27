
pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


library SafeMathUpgradeable {

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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


interface ICNSRegistry is IERC721MetadataUpgradeable {

    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);


    function resolverOf(uint256 tokenId) external view returns (address);


    function childIdOf(uint256 tokenId, string calldata label) external view returns (uint256);

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

interface IDataReader {

    function getData(string[] calldata keys, uint256 tokenId)
        external
        view
        returns (
            address resolver,
            address owner,
            string[] memory values
        );


    function getDataForMany(string[] calldata keys, uint256[] calldata tokenIds)
        external
        view
        returns (
            address[] memory resolvers,
            address[] memory owners,
            string[][] memory values
        );


    function getDataByHash(uint256[] calldata keyHashes, uint256 tokenId)
        external
        view
        returns (
            address resolver,
            address owner,
            string[] memory keys,
            string[] memory values
        );


    function getDataByHashForMany(uint256[] calldata keyHashes, uint256[] calldata tokenIds)
        external
        view
        returns (
            address[] memory resolvers,
            address[] memory owners,
            string[][] memory keys,
            string[][] memory values
        );


    function ownerOfForMany(uint256[] calldata tokenIds) external view returns (address[] memory owners);

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

interface IRegistryReader {

    function tokenURI(uint256 tokenId) external view returns (string memory);


    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);


    function resolverOf(uint256 tokenId) external view returns (address);


    function childIdOf(uint256 tokenId, string calldata label) external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function ownerOf(uint256 tokenId) external view returns (address);


    function getApproved(uint256 tokenId) external view returns (address);


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function exists(uint256 tokenId) external view returns (bool);

}// @author Unstoppable Domains, Inc.

pragma solidity ^0.8.0;



contract ProxyReader is ERC165Upgradeable, IRegistryReader, IRecordReader, IDataReader {

    using SafeMathUpgradeable for uint256;

    string public constant NAME = 'UNS: Proxy Reader';
    string public constant VERSION = '0.1.0';

    IUNSRegistry private immutable _unsRegistry;
    ICNSRegistry private immutable _cnsRegistry;

    constructor(IUNSRegistry unsRegistry, ICNSRegistry cnsRegistry) {
        _unsRegistry = unsRegistry;
        _cnsRegistry = cnsRegistry;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return
            interfaceId == type(IRegistryReader).interfaceId ||
            interfaceId == type(IRecordReader).interfaceId ||
            interfaceId == type(IDataReader).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {

        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.tokenURI(tokenId);
        } else {
            return _cnsRegistry.tokenURI(tokenId);
        }
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) external view override returns (bool) {

        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.isApprovedOrOwner(spender, tokenId);
        } else {
            return _cnsRegistry.isApprovedOrOwner(spender, tokenId);
        }
    }

    function resolverOf(uint256 tokenId) external view override returns (address) {

        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.resolverOf(tokenId);
        } else {
            return _cnsRegistry.resolverOf(tokenId);
        }
    }

    function childIdOf(uint256 tokenId, string calldata label) external view override returns (uint256) {

        return _unsRegistry.childIdOf(tokenId, label);
    }

    function balanceOf(address owner) external view override returns (uint256) {

        return _unsRegistry.balanceOf(owner).add(_cnsRegistry.balanceOf(owner));
    }

    function ownerOf(uint256 tokenId) external view override returns (address) {

        return _ownerOf(tokenId);
    }

    function getApproved(uint256 tokenId) external view override returns (address) {

        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.getApproved(tokenId);
        } else {
            return _cnsRegistry.getApproved(tokenId);
        }
    }

    function isApprovedForAll(address, address) external pure override returns (bool) {

        revert('ProxyReader: UNSUPPORTED_METHOD');
    }

    function exists(uint256 tokenId) external view override returns (bool) {

        return _unsRegistry.exists(tokenId) || _cnsOwnerOf(tokenId) != address(0x0);
    }

    function get(string calldata key, uint256 tokenId) external view override returns (string memory value) {

        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.get(key, tokenId);
        } else {
            address resolver = _cnsResolverOf(tokenId);
            if (resolver != address(0x0)) {
                value = IResolver(resolver).get(key, tokenId);
            }
        }
    }

    function getMany(string[] calldata keys, uint256 tokenId) external view override returns (string[] memory values) {

        values = new string[](keys.length);
        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.getMany(keys, tokenId);
        } else {
            address resolver = _cnsResolverOf(tokenId);
            if (resolver != address(0x0) && keys.length > 0) {
                values = IResolver(resolver).getMany(keys, tokenId);
            }
        }
    }

    function getByHash(uint256 keyHash, uint256 tokenId)
        external
        view
        override
        returns (string memory key, string memory value)
    {

        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.getByHash(keyHash, tokenId);
        } else {
            address resolver = _cnsResolverOf(tokenId);
            if (resolver != address(0x0)) {
                (key, value) = IResolver(resolver).getByHash(keyHash, tokenId);
            }
        }
    }

    function getManyByHash(uint256[] calldata keyHashes, uint256 tokenId)
        external
        view
        override
        returns (string[] memory keys, string[] memory values)
    {

        keys = new string[](keyHashes.length);
        values = new string[](keyHashes.length);
        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.getManyByHash(keyHashes, tokenId);
        } else {
            address resolver = _cnsResolverOf(tokenId);
            if (resolver != address(0x0) && keyHashes.length > 0) {
                (keys, values) = IResolver(resolver).getManyByHash(keyHashes, tokenId);
            }
        }
    }

    function getData(string[] calldata keys, uint256 tokenId)
        external
        view
        override
        returns (
            address resolver,
            address owner,
            string[] memory values
        )
    {

        return _getData(keys, tokenId);
    }

    function getDataForMany(string[] calldata keys, uint256[] calldata tokenIds)
        external
        view
        override
        returns (
            address[] memory resolvers,
            address[] memory owners,
            string[][] memory values
        )
    {

        resolvers = new address[](tokenIds.length);
        owners = new address[](tokenIds.length);
        values = new string[][](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            (resolvers[i], owners[i], values[i]) = _getData(keys, tokenIds[i]);
        }
    }

    function getDataByHash(uint256[] calldata keyHashes, uint256 tokenId)
        external
        view
        override
        returns (
            address resolver,
            address owner,
            string[] memory keys,
            string[] memory values
        )
    {

        return _getDataByHash(keyHashes, tokenId);
    }

    function getDataByHashForMany(uint256[] calldata keyHashes, uint256[] calldata tokenIds)
        external
        view
        override
        returns (
            address[] memory resolvers,
            address[] memory owners,
            string[][] memory keys,
            string[][] memory values
        )
    {

        resolvers = new address[](tokenIds.length);
        owners = new address[](tokenIds.length);
        keys = new string[][](tokenIds.length);
        values = new string[][](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            (resolvers[i], owners[i], keys[i], values[i]) = _getDataByHash(keyHashes, tokenIds[i]);
        }
    }

    function ownerOfForMany(uint256[] calldata tokenIds) external view override returns (address[] memory owners) {

        owners = new address[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            owners[i] = _ownerOf(tokenIds[i]);
        }
    }

    function registryOf(uint256 tokenId) external view returns (address) {

        if (_unsRegistry.exists(tokenId)) {
            return address(_unsRegistry);
        } else if (_cnsOwnerOf(tokenId) != address(0x0)) {
            return address(_cnsRegistry);
        }
        return address(0x0);
    }

    function _getData(string[] calldata keys, uint256 tokenId)
        private
        view
        returns (
            address resolver,
            address owner,
            string[] memory values
        )
    {

        values = new string[](keys.length);
        if (_unsRegistry.exists(tokenId)) {
            resolver = _unsRegistry.resolverOf(tokenId);
            owner = _unsRegistry.ownerOf(tokenId);
            values = _unsRegistry.getMany(keys, tokenId);
        } else {
            resolver = _cnsResolverOf(tokenId);
            owner = _cnsOwnerOf(tokenId);
            if (resolver != address(0x0) && keys.length > 0) {
                values = IResolver(resolver).getMany(keys, tokenId);
            }
        }
    }

    function _getDataByHash(uint256[] calldata keyHashes, uint256 tokenId)
        private
        view
        returns (
            address resolver,
            address owner,
            string[] memory keys,
            string[] memory values
        )
    {

        keys = new string[](keyHashes.length);
        values = new string[](keyHashes.length);
        if (_unsRegistry.exists(tokenId)) {
            resolver = _unsRegistry.resolverOf(tokenId);
            owner = _unsRegistry.ownerOf(tokenId);
            (keys, values) = _unsRegistry.getManyByHash(keyHashes, tokenId);
        } else {
            resolver = _cnsResolverOf(tokenId);
            owner = _cnsOwnerOf(tokenId);
            if (resolver != address(0x0) && keys.length > 0) {
                (keys, values) = IResolver(resolver).getManyByHash(keyHashes, tokenId);
            }
        }
    }

    function _ownerOf(uint256 tokenId) private view returns (address) {

        if (_unsRegistry.exists(tokenId)) {
            return _unsRegistry.ownerOf(tokenId);
        } else {
            return _cnsOwnerOf(tokenId);
        }
    }

    function _cnsOwnerOf(uint256 tokenId) private view returns (address) {

        try _cnsRegistry.ownerOf(tokenId) returns (address _owner) {
            return _owner;
        } catch {
            return address(0x0);
        }
    }

    function _cnsResolverOf(uint256 tokenId) private view returns (address) {

        try _cnsRegistry.resolverOf(tokenId) returns (address _resolver) {
            return _resolver;
        } catch {
            return address(0x0);
        }
    }
}