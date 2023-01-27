
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;



interface ICreatorCore is IERC165 {


    event ExtensionRegistered(address indexed extension, address indexed sender);
    event ExtensionUnregistered(address indexed extension, address indexed sender);
    event ExtensionBlacklisted(address indexed extension, address indexed sender);
    event MintPermissionsUpdated(address indexed extension, address indexed permissions, address indexed sender);
    event RoyaltiesUpdated(uint256 indexed tokenId, address payable[] receivers, uint256[] basisPoints);
    event DefaultRoyaltiesUpdated(address payable[] receivers, uint256[] basisPoints);
    event ExtensionRoyaltiesUpdated(address indexed extension, address payable[] receivers, uint256[] basisPoints);
    event ExtensionApproveTransferUpdated(address indexed extension, bool enabled);

    function getExtensions() external view returns (address[] memory);


    function registerExtension(address extension, string calldata baseURI) external;


    function registerExtension(address extension, string calldata baseURI, bool baseURIIdentical) external;


    function unregisterExtension(address extension) external;


    function blacklistExtension(address extension) external;


    function setBaseTokenURIExtension(string calldata uri) external;


    function setBaseTokenURIExtension(string calldata uri, bool identical) external;


    function setTokenURIPrefixExtension(string calldata prefix) external;


    function setTokenURIExtension(uint256 tokenId, string calldata uri) external;


    function setTokenURIExtension(uint256[] memory tokenId, string[] calldata uri) external;


    function setBaseTokenURI(string calldata uri) external;


    function setTokenURIPrefix(string calldata prefix) external;


    function setTokenURI(uint256 tokenId, string calldata uri) external;


    function setTokenURI(uint256[] memory tokenIds, string[] calldata uris) external;


    function setMintPermissions(address extension, address permissions) external;


    function setApproveTransferExtension(bool enabled) external;


    function tokenExtension(uint256 tokenId) external view returns (address);


    function setRoyalties(address payable[] calldata receivers, uint256[] calldata basisPoints) external;


    function setRoyalties(uint256 tokenId, address payable[] calldata receivers, uint256[] calldata basisPoints) external;


    function setRoyaltiesExtension(address extension, address payable[] calldata receivers, uint256[] calldata basisPoints) external;


    function getRoyalties(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);

    
    function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory);

    function getFeeBps(uint256 tokenId) external view returns (uint[] memory);

    function getFees(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);

    function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address, uint256);


}// MIT

pragma solidity ^0.8.0;



interface IERC721CreatorCore is ICreatorCore {


    function mintBase(address to) external returns (uint256);


    function mintBase(address to, string calldata uri) external returns (uint256);


    function mintBaseBatch(address to, uint16 count) external returns (uint256[] memory);


    function mintBaseBatch(address to, string[] calldata uris) external returns (uint256[] memory);


    function mintExtension(address to) external returns (uint256);


    function mintExtension(address to, string calldata uri) external returns (uint256);


    function mintExtensionBatch(address to, uint16 count) external returns (uint256[] memory);


    function mintExtensionBatch(address to, string[] calldata uris) external returns (uint256[] memory);


    function burn(uint256 tokenId) external;


}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;



abstract contract CreatorExtension is ERC165 {

    bytes4 constant internal LEGACY_EXTENSION_INTERFACE = 0x7005caad;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == LEGACY_EXTENSION_INTERFACE
            || super.supportsInterface(interfaceId);
    }
    
}// MIT

pragma solidity ^0.8.0;



interface ICreatorExtensionTokenURI is IERC165 {


    function tokenURI(address creator, uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

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


abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}// MIT

pragma solidity 0.8.9;


interface ITokengateManifoldExtension is IERC165 {

    event EditionMinted(
        address indexed creator,
        uint256 indexed tokenId,
        uint64 indexed projectId,
        uint32 editionNumber
    );

    event SeriesCreated(uint64 indexed projectId);

    event SeriesParamsSet(uint64 indexed projectId);

    event BaseTokenURISet(string baseTokenURI);

    event DefaultTokenURIPrefixSet(string defaultTokenURIPrefix);

    error ProjectIdMustBePositive(address emitter);

    error EditionSizeMustBeGreaterThanOne(address emitter);

    error EditionNumberMustBePositive(address emitter);

    error EditionNumberExceedsEditionSize(address emitter);

    error SeriesAlreadyCreated(address emitter);

    error ProjectIsMintedAsSingleEdition(address emitter);

    error EditionAlreadyMinted(address emitter);

    error ProjectIsMintedAsSeries(address emitter);

    error SeriesNotFound(address emitter);

    error ZeroAddressNotAllowed(address emitter);

    error ArrayLengthMismatch(address emitter);

    error TokenNotFound(address emitter);

    struct Series {
        bool hasEntry;
        uint32 editionSize;
        uint32 editionCount;
        string tokenURIPrefix;
        string tokenURISuffix;
        bool addEditionToTokenURISuffix;
        string tokenURIExtension;
    }

    function createSeries(
        uint64 projectId,
        uint32 editionSize,
        string calldata tokenURIPrefix,
        string calldata tokenURISuffix,
        bool addEditionToTokenURISuffix,
        string calldata tokenURIExtension
    ) external;


    function setSeriesParams(
        uint64 projectId,
        string calldata tokenURIPrefix,
        string calldata tokenURISuffix,
        bool addEditionToTokenURISuffix,
        string calldata tokenURIExtension
    ) external;


    function getSeries(uint64 projectId) external view returns (Series memory);


    function mintSeries(
        address creator,
        address recipient,
        uint64 projectId,
        uint32 editionNumber,
        bool isFullTokenURI,
        string calldata tokenURIData
    ) external;


    function mintSeriesBatch1(
        address creator,
        address recipient,
        uint64 projectId,
        uint32 startEditionNumber,
        uint32 nbEditions
    ) external;


    function mintSeriesBatch1(
        address creator,
        address recipient,
        uint64 projectId,
        uint32 startEditionNumber,
        uint32 nbEditions,
        bool[] calldata isFullTokenURIs,
        string[] calldata tokenURIData
    ) external;


    function mintSeriesBatchN(
        address creator,
        address[] calldata recipients,
        uint64[] calldata projectIds,
        uint32[] calldata editionNumbers
    ) external;


    function mintSeriesBatchN(
        address creator,
        address[] calldata recipients,
        uint64[] calldata projectIds,
        uint32[] calldata editionNumbers,
        bool[] calldata isFullTokenURIs,
        string[] calldata tokenURIData
    ) external;


    function mintSingle(
        address creator,
        address recipient,
        uint64 projectId,
        bool isFullTokenURI,
        string calldata tokenURIData
    ) external;


    function mintSingleBatch(
        address creator,
        address[] calldata recipients,
        uint64[] calldata projectIds
    ) external;


    function mintSingleBatch(
        address creator,
        address[] calldata recipients,
        uint64[] calldata projectIds,
        bool[] calldata isFullTokenURIs,
        string[] calldata tokenURIData
    ) external;


    function setBaseTokenURI(string calldata baseTokenURI) external;


    function getBaseTokenURI() external view returns (string memory);


    function setDefaultTokenURIPrefix(string calldata defaultTokenURIPrefix)
        external;


    function getDefaultTokenURIPrefix() external view returns (string memory);


    function setTokenURIData(
        address creator,
        uint256 tokenId,
        bool isFullTokenURI,
        string calldata tokenURIData
    ) external;


    function setTokenURIDataBatch(
        address creator,
        uint256[] calldata tokenIds,
        bool[] calldata isFullTokenURIs,
        string[] calldata tokenURIData
    ) external;


    function getTokenURISuffix(address creator, uint256 tokenId)
        external
        view
        returns (string memory);


    function getFullTokenURI(address creator, uint256 tokenId)
        external
        view
        returns (string memory);


    function getTokenInfo(address creator, uint256 tokenId)
        external
        view
        returns (uint64 projectId, uint32 editionNumber);


    function isSeries(uint64 projectId) external view returns (bool);


    function isMinted(uint64 projectId, uint32 editionNumber)
        external
        view
        returns (bool);


    function createEditionId(uint64 projectId, uint32 editionNumber)
        external
        pure
        returns (uint96);


    function splitEditionId(uint96 editionId)
        external
        pure
        returns (uint64 projectId, uint32 editionNumber);


    function getRoleMembers(bytes32 role)
        external
        view
        returns (address[] memory);

}// MIT

pragma solidity 0.8.9;




contract TokengateManifoldExtension is
    ITokengateManifoldExtension,
    CreatorExtension,
    ICreatorExtensionTokenURI,
    AccessControlEnumerable
{

    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private _baseTokenURI;

    string private _defaultTokenURIPrefix;

    mapping(address => mapping(uint256 => string)) private _tokenURISuffixMap;

    mapping(address => mapping(uint256 => string)) private _fullTokenURIMap;

    mapping(uint64 => Series) private _seriesMap;

    mapping(uint96 => bool) private _mintedEditionIdMap;

    mapping(address => mapping(uint256 => uint96)) private _editionIdMap;

    constructor(string memory baseTokenURI, string memory defaultTokenURIPrefix)
        payable
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _baseTokenURI = baseTokenURI;
        _defaultTokenURIPrefix = defaultTokenURIPrefix;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(CreatorExtension, IERC165, AccessControlEnumerable)
        returns (bool)
    {

        return
            interfaceId == type(ICreatorExtensionTokenURI).interfaceId ||
            CreatorExtension.supportsInterface(interfaceId) ||
            interfaceId == type(ITokengateManifoldExtension).interfaceId ||
            AccessControlEnumerable.supportsInterface(interfaceId) ||
            super.supportsInterface(interfaceId);
    }

    function createSeries(
        uint64 projectId,
        uint32 editionSize,
        string calldata tokenURIPrefix,
        string calldata tokenURISuffix,
        bool addEditionToTokenURISuffix,
        string calldata tokenURIExtension
    ) external onlyRole(MINTER_ROLE) {

        if (projectId == 0) {
            revert ProjectIdMustBePositive(address(this));
        }
        if (editionSize <= 1) {
            revert EditionSizeMustBeGreaterThanOne(address(this));
        }
        if (_seriesMap[projectId].hasEntry) {
            revert SeriesAlreadyCreated(address(this));
        }
        if (_mintedEditionIdMap[createEditionId(projectId, 1)]) {
            revert ProjectIsMintedAsSingleEdition(address(this));
        }

        _seriesMap[projectId] = Series(
            true,
            editionSize,
            0,
            tokenURIPrefix,
            tokenURISuffix,
            addEditionToTokenURISuffix,
            tokenURIExtension
        );

        emit SeriesCreated(projectId);
    }

    function setSeriesParams(
        uint64 projectId,
        string calldata tokenURIPrefix,
        string calldata tokenURISuffix,
        bool addEditionToTokenURISuffix,
        string calldata tokenURIExtension
    ) external onlyRole(MINTER_ROLE) {

        if (!_seriesMap[projectId].hasEntry) {
            revert SeriesNotFound(address(this));
        }

        Series storage series = _seriesMap[projectId];
        series.tokenURIPrefix = tokenURIPrefix;
        series.tokenURISuffix = tokenURISuffix;
        series.addEditionToTokenURISuffix = addEditionToTokenURISuffix;
        series.tokenURIExtension = tokenURIExtension;

        emit SeriesParamsSet(projectId);
    }

    function getSeries(uint64 projectId) external view returns (Series memory) {

        return _seriesMap[projectId];
    }

    function mintSeries(
        address creator,
        address recipient,
        uint64 projectId,
        uint32 editionNumber,
        bool isFullTokenURI,
        string memory tokenURIData
    ) external onlyRole(MINTER_ROLE) {

        _mintSeries(
            creator,
            recipient,
            projectId,
            editionNumber,
            isFullTokenURI,
            tokenURIData
        );
    }

    function _mintSeries(
        address creator,
        address recipient,
        uint64 projectId,
        uint32 editionNumber,
        bool isFullTokenURI,
        string memory tokenURIData
    ) internal {

        if (recipient == address(0)) {
            revert ZeroAddressNotAllowed(address(this));
        }
        if (!_seriesMap[projectId].hasEntry) {
            revert SeriesNotFound(address(this));
        }

        if (editionNumber == 0) {
            revert EditionNumberMustBePositive(address(this));
        }

        if (editionNumber > _seriesMap[projectId].editionSize) {
            revert EditionNumberExceedsEditionSize(address(this));
        }

        uint96 editionId = createEditionId(projectId, editionNumber);
        if (_mintedEditionIdMap[editionId]) {
            revert EditionAlreadyMinted(address(this));
        }
        _mintedEditionIdMap[editionId] = true;
        _seriesMap[projectId].editionCount += 1;

        uint256 tokenId = IERC721CreatorCore(creator).mintExtension(recipient);

        if (bytes(tokenURIData).length != 0) {
            if (isFullTokenURI) {
                _fullTokenURIMap[creator][tokenId] = tokenURIData;
            } else {
                _tokenURISuffixMap[creator][tokenId] = tokenURIData;
            }
        }

        _editionIdMap[creator][tokenId] = editionId;

        emit EditionMinted(creator, tokenId, projectId, editionNumber);
    }

    function mintSeriesBatch1(
        address creator,
        address recipient,
        uint64 projectId,
        uint32 startEditionNumber,
        uint32 nbEditions
    ) external onlyRole(MINTER_ROLE) {

        for (uint32 i = 0; i < nbEditions; ) {
            _mintSeries(
                creator,
                recipient,
                projectId,
                startEditionNumber + i,
                false,
                ""
            );

            unchecked {
                ++i;
            }
        }
    }

    function mintSeriesBatch1(
        address creator,
        address recipient,
        uint64 projectId,
        uint32 startEditionNumber,
        uint32 nbEditions,
        bool[] calldata isFullTokenURIs,
        string[] calldata tokenURIData
    ) external onlyRole(MINTER_ROLE) {

        if (
            isFullTokenURIs.length != nbEditions ||
            tokenURIData.length != nbEditions
        ) {
            revert ArrayLengthMismatch(address(this));
        }

        for (uint32 i = 0; i < nbEditions; ) {
            _mintSeries(
                creator,
                recipient,
                projectId,
                startEditionNumber + i,
                isFullTokenURIs[i],
                tokenURIData[i]
            );

            unchecked {
                ++i;
            }
        }
    }

    function mintSeriesBatchN(
        address creator,
        address[] calldata recipients,
        uint64[] calldata projectIds,
        uint32[] calldata editionNumbers
    ) external onlyRole(MINTER_ROLE) {

        uint256 batchSize = recipients.length;
        if (
            projectIds.length != batchSize || editionNumbers.length != batchSize
        ) {
            revert ArrayLengthMismatch(address(this));
        }

        for (uint256 i = 0; i < batchSize; ) {
            _mintSeries(
                creator,
                recipients[i],
                projectIds[i],
                editionNumbers[i],
                false,
                ""
            );

            unchecked {
                ++i;
            }
        }
    }

    function mintSeriesBatchN(
        address creator,
        address[] calldata recipients,
        uint64[] calldata projectIds,
        uint32[] calldata editionNumbers,
        bool[] calldata isFullTokenURIs,
        string[] calldata tokenURIData
    ) external onlyRole(MINTER_ROLE) {

        uint256 batchSize = recipients.length;
        if (
            projectIds.length != batchSize ||
            editionNumbers.length != batchSize ||
            isFullTokenURIs.length != batchSize ||
            tokenURIData.length != batchSize
        ) {
            revert ArrayLengthMismatch(address(this));
        }

        for (uint256 i = 0; i < batchSize; ) {
            _mintSeries(
                creator,
                recipients[i],
                projectIds[i],
                editionNumbers[i],
                isFullTokenURIs[i],
                tokenURIData[i]
            );

            unchecked {
                ++i;
            }
        }
    }

    function mintSingle(
        address creator,
        address recipient,
        uint64 projectId,
        bool isFullTokenURI,
        string memory tokenURIData
    ) public onlyRole(MINTER_ROLE) {

        if (recipient == address(0)) {
            revert ZeroAddressNotAllowed(address(this));
        }
        if (projectId == 0) {
            revert ProjectIdMustBePositive(address(this));
        }

        uint96 editionId = createEditionId(projectId, 1);

        if (_mintedEditionIdMap[editionId]) {
            revert EditionAlreadyMinted(address(this));
        }
        if (_seriesMap[projectId].hasEntry) {
            revert ProjectIsMintedAsSeries(address(this));
        }

        _mintedEditionIdMap[editionId] = true;

        uint256 tokenId = IERC721CreatorCore(creator).mintExtension(recipient);

        if (bytes(tokenURIData).length != 0) {
            if (isFullTokenURI) {
                _fullTokenURIMap[creator][tokenId] = tokenURIData;
            } else {
                _tokenURISuffixMap[creator][tokenId] = tokenURIData;
            }
        }

        _editionIdMap[creator][tokenId] = editionId;

        emit EditionMinted(creator, tokenId, projectId, 1);
    }

    function mintSingleBatch(
        address creator,
        address[] calldata recipients,
        uint64[] calldata projectIds
    ) external onlyRole(MINTER_ROLE) {

        uint256 batchSize = recipients.length;
        if (projectIds.length != batchSize) {
            revert ArrayLengthMismatch(address(this));
        }

        for (uint256 i = 0; i < batchSize; ) {
            mintSingle(creator, recipients[i], projectIds[i], false, "");

            unchecked {
                ++i;
            }
        }
    }

    function mintSingleBatch(
        address creator,
        address[] calldata recipients,
        uint64[] calldata projectIds,
        bool[] calldata isFullTokenURIs,
        string[] calldata tokenURIData
    ) external onlyRole(MINTER_ROLE) {

        uint256 batchSize = recipients.length;
        if (
            projectIds.length != batchSize ||
            isFullTokenURIs.length != batchSize ||
            tokenURIData.length != batchSize
        ) {
            revert ArrayLengthMismatch(address(this));
        }

        for (uint256 i = 0; i < batchSize; ) {
            mintSingle(
                creator,
                recipients[i],
                projectIds[i],
                isFullTokenURIs[i],
                tokenURIData[i]
            );

            unchecked {
                ++i;
            }
        }
    }

    function setBaseTokenURI(string calldata baseTokenURI)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        _baseTokenURI = baseTokenURI;
        emit BaseTokenURISet(_baseTokenURI);
    }

    function getBaseTokenURI() external view returns (string memory) {

        return _baseTokenURI;
    }

    function setDefaultTokenURIPrefix(string calldata defaultTokenURIPrefix_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        _defaultTokenURIPrefix = defaultTokenURIPrefix_;
        emit DefaultTokenURIPrefixSet(_defaultTokenURIPrefix);
    }

    function getDefaultTokenURIPrefix() external view returns (string memory) {

        return _defaultTokenURIPrefix;
    }

    function setTokenURIData(
        address creator,
        uint256 tokenId,
        bool isFullTokenURI,
        string calldata tokenURIData
    ) public onlyRole(MINTER_ROLE) {

        if (_editionIdMap[creator][tokenId] == 0) {
            revert TokenNotFound(address(this));
        }
        if (isFullTokenURI) {
            _fullTokenURIMap[creator][tokenId] = tokenURIData;
        } else {
            _tokenURISuffixMap[creator][tokenId] = tokenURIData;
        }
    }

    function setTokenURIDataBatch(
        address creator,
        uint256[] calldata tokenIds,
        bool[] calldata isFullTokenURIs,
        string[] calldata tokenURIData
    ) external onlyRole(MINTER_ROLE) {

        uint256 batchSize = tokenIds.length;
        if (
            isFullTokenURIs.length != batchSize ||
            tokenURIData.length != batchSize
        ) {
            revert ArrayLengthMismatch(address(this));
        }

        for (uint256 i = 0; i < batchSize; ) {
            setTokenURIData(
                creator,
                tokenIds[i],
                isFullTokenURIs[i],
                tokenURIData[i]
            );

            unchecked {
                ++i;
            }
        }
    }

    function getTokenURISuffix(address creator, uint256 tokenId)
        external
        view
        returns (string memory)
    {

        return _tokenURISuffixMap[creator][tokenId];
    }

    function getFullTokenURI(address creator, uint256 tokenId)
        external
        view
        returns (string memory)
    {

        return _fullTokenURIMap[creator][tokenId];
    }

    function tokenURI(address creator, uint256 tokenId)
        external
        view
        returns (string memory)
    {

        string memory fullTokenURI = _fullTokenURIMap[creator][tokenId];
        if (bytes(fullTokenURI).length != 0) {
            return fullTokenURI;
        }

        (uint64 projectId, uint32 editionNumber) = splitEditionId(
            _editionIdMap[creator][tokenId]
        );

        Series memory series = _seriesMap[projectId];
        if (series.hasEntry) {
            return
                getSeriesTokenURI(creator, tokenId, projectId, editionNumber);
        }

        string memory tokenURISuffix = _tokenURISuffixMap[creator][tokenId];
        if (bytes(tokenURISuffix).length != 0) {
            return
                string(
                    abi.encodePacked(_defaultTokenURIPrefix, tokenURISuffix)
                );
        }

        return
            string(
                abi.encodePacked(
                    _baseTokenURI,
                    toString(creator),
                    "-",
                    tokenId.toString()
                )
            );
    }

    function getSeriesTokenURI(
        address creator,
        uint256 tokenId,
        uint64 projectId,
        uint32 editionNumber
    ) internal view returns (string memory) {

        string memory suffix = _tokenURISuffixMap[creator][tokenId];
        Series memory series = _seriesMap[projectId];

        if (
            bytes(series.tokenURISuffix).length == 0 &&
            bytes(suffix).length == 0
        ) {
            return
                string(
                    abi.encodePacked(
                        _baseTokenURI,
                        toString(creator),
                        "-",
                        tokenId.toString()
                    )
                );
        }

        string memory tokenURIPrefix = getSeriesTokenURIPrefix(projectId);

        if (bytes(suffix).length != 0) {
            return string(abi.encodePacked(tokenURIPrefix, suffix));
        }

        if (series.addEditionToTokenURISuffix) {
            if (bytes(series.tokenURIExtension).length != 0) {
                return
                    string(
                        abi.encodePacked(
                            tokenURIPrefix,
                            series.tokenURISuffix,
                            uint256(editionNumber).toString(),
                            series.tokenURIExtension
                        )
                    );
            }

            return
                string(
                    abi.encodePacked(
                        tokenURIPrefix,
                        series.tokenURISuffix,
                        uint256(editionNumber).toString()
                    )
                );
        }

        return string(abi.encodePacked(tokenURIPrefix, series.tokenURISuffix));
    }

    function getSeriesTokenURIPrefix(uint64 projectId)
        internal
        view
        returns (string memory)
    {

        Series memory series = _seriesMap[projectId];

        if (bytes(series.tokenURIPrefix).length != 0) {
            return series.tokenURIPrefix;
        }

        return _defaultTokenURIPrefix;
    }

    function getTokenInfo(address creator, uint256 tokenId)
        external
        view
        returns (uint64 projectId, uint32 editionNumber)
    {

        uint96 editionId = _editionIdMap[creator][tokenId];
        if (editionId == 0) {
            revert TokenNotFound(address(this));
        }
        (projectId, editionNumber) = splitEditionId(
            _editionIdMap[creator][tokenId]
        );
    }

    function isSeries(uint64 projectId) external view returns (bool) {

        return _seriesMap[projectId].hasEntry;
    }

    function isMinted(uint64 projectId, uint32 editionNumber)
        external
        view
        returns (bool)
    {

        return _mintedEditionIdMap[createEditionId(projectId, editionNumber)];
    }

    function createEditionId(uint64 projectId, uint32 editionNumber)
        public
        pure
        returns (uint96)
    {

        uint96 editionId = projectId;
        editionId = editionId << 32;
        editionId = editionId + editionNumber;
        return editionId;
    }

    function splitEditionId(uint96 editionId)
        public
        pure
        returns (uint64 projectId, uint32 editionNumber)
    {

        projectId = uint64(editionId >> 32);
        editionNumber = uint32(editionId);
    }

    function getRoleMembers(bytes32 role)
        public
        view
        returns (address[] memory)
    {

        uint256 roleCount = getRoleMemberCount(role);
        address[] memory members = new address[](roleCount);
        for (uint256 i = 0; i < roleCount; ) {
            members[i] = getRoleMember(role, i);

            unchecked {
                ++i;
            }
        }
        return members;
    }

    function toString(address addr) public pure returns (string memory) {

        uint256 data = uint256(uint160(addr));
        return data.toHexString();
    }
}