
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool[] memory) {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165(account).supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}// MIT

pragma solidity ^0.8.0;



interface ICreatorCore is IERC165 {

    event ExtensionRegistered(
        address indexed extension,
        address indexed sender
    );
    event ExtensionUnregistered(
        address indexed extension,
        address indexed sender
    );
    event ExtensionBlacklisted(
        address indexed extension,
        address indexed sender
    );
    event MintPermissionsUpdated(
        address indexed extension,
        address indexed permissions,
        address indexed sender
    );
    event RoyaltiesUpdated(
        uint256 indexed tokenId,
        address payable[] receivers,
        uint256[] basisPoints
    );
    event DefaultRoyaltiesUpdated(
        address payable[] receivers,
        uint256[] basisPoints
    );
    event ExtensionRoyaltiesUpdated(
        address indexed extension,
        address payable[] receivers,
        uint256[] basisPoints
    );
    event ExtensionApproveTransferUpdated(
        address indexed extension,
        bool enabled
    );

    function getExtensions() external view returns (address[] memory);


    function registerExtension(address extension, string calldata baseURI)
        external;


    function registerExtension(
        address extension,
        string calldata baseURI,
        bool baseURIIdentical
    ) external;


    function unregisterExtension(address extension) external;


    function blacklistExtension(address extension) external;


    function setBaseTokenURIExtension(string calldata uri) external;


    function setBaseTokenURIExtension(string calldata uri, bool identical)
        external;


    function setTokenURIPrefixExtension(string calldata prefix) external;


    function setTokenURIExtension(uint256 tokenId, string calldata uri)
        external;


    function setTokenURIExtension(
        uint256[] memory tokenId,
        string[] calldata uri
    ) external;


    function setBaseTokenURI(string calldata uri) external;


    function setTokenURIPrefix(string calldata prefix) external;


    function setTokenURI(uint256 tokenId, string calldata uri) external;


    function setTokenURI(uint256[] memory tokenIds, string[] calldata uris)
        external;


    function setMintPermissions(address extension, address permissions)
        external;


    function setApproveTransferExtension(bool enabled) external;


    function tokenExtension(uint256 tokenId) external view returns (address);


    function setRoyalties(
        address payable[] calldata receivers,
        uint256[] calldata basisPoints
    ) external;


    function setRoyalties(
        uint256 tokenId,
        address payable[] calldata receivers,
        uint256[] calldata basisPoints
    ) external;


    function setRoyaltiesExtension(
        address extension,
        address payable[] calldata receivers,
        uint256[] calldata basisPoints
    ) external;


    function getRoyalties(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);


    function getFeeRecipients(uint256 tokenId)
        external
        view
        returns (address payable[] memory);


    function getFeeBps(uint256 tokenId)
        external
        view
        returns (uint256[] memory);


    function getFees(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);


    function royaltyInfo(uint256 tokenId, uint256 value)
        external
        view
        returns (address, uint256);

}// MIT

pragma solidity ^0.8.0;



interface IERC721CreatorCore is ICreatorCore {

    function mintBase(address to) external returns (uint256);


    function mintBase(address to, string calldata uri)
        external
        returns (uint256);


    function mintBaseBatch(address to, uint16 count)
        external
        returns (uint256[] memory);


    function mintBaseBatch(address to, string[] calldata uris)
        external
        returns (uint256[] memory);


    function mintExtension(address to) external returns (uint256);


    function mintExtension(address to, string calldata uri)
        external
        returns (uint256);


    function mintExtensionBatch(address to, uint16 count)
        external
        returns (uint256[] memory);


    function mintExtensionBatch(address to, string[] calldata uris)
        external
        returns (uint256[] memory);


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
    bytes4 internal constant LEGACY_EXTENSION_INTERFACE = 0x7005caad;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165)
        returns (bool)
    {
        return
            interfaceId == LEGACY_EXTENSION_INTERFACE ||
            super.supportsInterface(interfaceId);
    }
}// BSD-4-Clause

pragma solidity ^0.8.0;


library LegacyInterfaces {

    bytes4 internal constant IERC721CreatorCore_v1 = 0x478c8530;
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;



interface IAdminControl is IERC165 {

    event AdminApproved(address indexed account, address indexed sender);
    event AdminRevoked(address indexed account, address indexed sender);

    function getAdmins() external view returns (address[] memory);


    function approveAdmin(address admin) external;


    function revokeAdmin(address admin) external;


    function isAdmin(address admin) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;



abstract contract AdminControl is Ownable, IAdminControl, ERC165 {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _admins;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IAdminControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    modifier adminRequired() {
        require(
            owner() == msg.sender || _admins.contains(msg.sender),
            "AdminControl: Must be owner or admin"
        );
        _;
    }

    function getAdmins()
        external
        view
        override
        returns (address[] memory admins)
    {
        admins = new address[](_admins.length());
        for (uint256 i = 0; i < _admins.length(); i++) {
            admins[i] = _admins.at(i);
        }
        return admins;
    }

    function approveAdmin(address admin) external override onlyOwner {
        if (!_admins.contains(admin)) {
            emit AdminApproved(admin, msg.sender);
            _admins.add(admin);
        }
    }

    function revokeAdmin(address admin) external override onlyOwner {
        if (_admins.contains(admin)) {
            emit AdminRevoked(admin, msg.sender);
            _admins.remove(admin);
        }
    }

    function isAdmin(address admin) public view override returns (bool) {
        return (owner() == admin || _admins.contains(admin));
    }
}// MIT

pragma solidity ^0.8.0;



interface IRedeemBase is IAdminControl {

    event UpdateApprovedContracts(address[] contracts, bool[] approved);
    event UpdateApprovedTokens(
        address contract_,
        uint256[] tokenIds,
        bool[] approved
    );
    event UpdateApprovedTokenRanges(
        address contract_,
        uint256[] minTokenIds,
        uint256[] maxTokenIds
    );

    function updateApprovedContracts(
        address[] calldata contracts,
        bool[] calldata approved
    ) external;


    function updateApprovedTokens(
        address contract_,
        uint256[] calldata tokenIds,
        bool[] calldata approved
    ) external;


    function updateApprovedTokenRanges(
        address contract_,
        uint256[] calldata minTokenIds,
        uint256[] calldata maxTokenIds
    ) external;


    function redeemable(address contract_, uint256 tokenId)
        external
        view
        returns (bool);

}// MIT

pragma solidity ^0.8.0;





struct range {
    uint256 min;
    uint256 max;
}

abstract contract RedeemBase is AdminControl, IRedeemBase {
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(address => bool) private _approvedContracts;

    mapping(address => EnumerableSet.UintSet) private _approvedTokens;
    mapping(address => range[]) private _approvedTokenRange;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AdminControl, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IRedeemBase).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function updateApprovedContracts(
        address[] memory contracts,
        bool[] memory approved
    ) public virtual override adminRequired {
        require(
            contracts.length == approved.length,
            "Redeem: Invalid input parameters"
        );
        for (uint256 i = 0; i < contracts.length; i++) {
            _approvedContracts[contracts[i]] = approved[i];
        }
        emit UpdateApprovedContracts(contracts, approved);
    }

    function updateApprovedTokens(
        address contract_,
        uint256[] memory tokenIds,
        bool[] memory approved
    ) public virtual override adminRequired {
        require(
            tokenIds.length == approved.length,
            "Redeem: Invalid input parameters"
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (
                approved[i] && !_approvedTokens[contract_].contains(tokenIds[i])
            ) {
                _approvedTokens[contract_].add(tokenIds[i]);
            } else if (
                !approved[i] && _approvedTokens[contract_].contains(tokenIds[i])
            ) {
                _approvedTokens[contract_].remove(tokenIds[i]);
            }
        }
        emit UpdateApprovedTokens(contract_, tokenIds, approved);
    }

    function updateApprovedTokenRanges(
        address contract_,
        uint256[] memory minTokenIds,
        uint256[] memory maxTokenIds
    ) public virtual override adminRequired {
        require(
            minTokenIds.length == maxTokenIds.length,
            "Redeem: Invalid input parameters"
        );

        uint256 existingRangesLength = _approvedTokenRange[contract_].length;
        for (uint256 i = 0; i < existingRangesLength; i++) {
            _approvedTokenRange[contract_][i].min = 0;
            _approvedTokenRange[contract_][i].max = 0;
        }

        for (uint256 i = 0; i < minTokenIds.length; i++) {
            require(
                minTokenIds[i] < maxTokenIds[i],
                "Redeem: min must be less than max"
            );
            if (i < existingRangesLength) {
                _approvedTokenRange[contract_][i].min = minTokenIds[i];
                _approvedTokenRange[contract_][i].max = maxTokenIds[i];
            } else {
                _approvedTokenRange[contract_].push(
                    range(minTokenIds[i], maxTokenIds[i])
                );
            }
        }
        emit UpdateApprovedTokenRanges(contract_, minTokenIds, maxTokenIds);
    }

    function redeemable(address contract_, uint256 tokenId)
        public
        view
        virtual
        override
        returns (bool)
    {
        if (_approvedContracts[contract_]) {
            return true;
        }
        if (_approvedTokens[contract_].contains(tokenId)) {
            return true;
        }
        if (_approvedTokenRange[contract_].length > 0) {
            for (
                uint256 i = 0;
                i < _approvedTokenRange[contract_].length;
                i++
            ) {
                if (
                    _approvedTokenRange[contract_][i].max != 0 &&
                    tokenId >= _approvedTokenRange[contract_][i].min &&
                    tokenId <= _approvedTokenRange[contract_][i].max
                ) {
                    return true;
                }
            }
        }
        return false;
    }
}// MIT

pragma solidity ^0.8.0;



interface IERC721RedeemBase is IRedeemBase {

    function redemptionMax() external view returns (uint16);


    function redemptionRate() external view returns (uint16);


    function redemptionRemaining() external view returns (uint16);


    function mintNumber(uint256 tokenId) external view returns (uint256);


    function mintedTokens() external view returns (uint256[] memory);

}// MIT

pragma solidity ^0.8.0;





abstract contract ERC721RedeemBase is
    RedeemBase,
    CreatorExtension,
    IERC721RedeemBase
{
    address private _creator;

    uint16 internal immutable _redemptionRate;
    uint16 private _redemptionMax;
    uint16 private _redemptionCount;
    uint256[] private _mintedTokens;
    mapping(uint256 => uint256) internal _mintNumbers;

    constructor(
        address creator,
        uint16 redemptionRate_,
        uint16 redemptionMax_
    ) {
        require(
            ERC165Checker.supportsInterface(
                creator,
                type(IERC721CreatorCore).interfaceId
            ) ||
                ERC165Checker.supportsInterface(
                    creator,
                    LegacyInterfaces.IERC721CreatorCore_v1
                ),
            "Redeem: Minting reward contract must implement IERC721CreatorCore"
        );
        _redemptionRate = redemptionRate_;
        _redemptionMax = redemptionMax_;
        _creator = creator;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(RedeemBase, CreatorExtension, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721RedeemBase).interfaceId ||
            RedeemBase.supportsInterface(interfaceId) ||
            CreatorExtension.supportsInterface(interfaceId);
    }

    function redemptionMax() external view virtual override returns (uint16) {
        return _redemptionMax;
    }

    function redemptionRate() external view virtual override returns (uint16) {
        return _redemptionRate;
    }

    function redemptionRemaining()
        external
        view
        virtual
        override
        returns (uint16)
    {
        return _redemptionMax - _redemptionCount;
    }

    function mintNumber(uint256 tokenId)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _mintNumbers[tokenId];
    }

    function mintedTokens() external view override returns (uint256[] memory) {
        return _mintedTokens;
    }

    function _mintRedemption(address to) internal {
        require(
            _redemptionCount < _redemptionMax,
            "Redeem: No redemptions remaining"
        );
        _redemptionCount++;

        uint256 tokenId = _mint(to, _redemptionCount);

        _mintedTokens.push(tokenId);
        _mintNumbers[tokenId] = _redemptionCount;
    }

    function _mint(address to, uint16) internal returns (uint256) {
        return IERC721CreatorCore(_creator).mintExtension(to);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;




interface IERC721BurnRedeem is IERC721RedeemBase, IERC721Receiver {

    function setERC721Recoverable(
        address contract_,
        uint256 tokenId,
        address recoverer
    ) external;


    function recoverERC721(address contract_, uint256 tokenId) external;


}// MIT

pragma solidity ^0.8.0;





contract ERC721BurnRedeem is
    ReentrancyGuard,
    ERC721RedeemBase,
    IERC721BurnRedeem
{



    constructor(
        address creator,
        uint16 redemptionRate,
        uint16 redemptionMax
    ) ERC721RedeemBase(creator, redemptionRate, redemptionMax) {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721RedeemBase, IERC165)
        returns (bool)
    {

        return
            interfaceId == type(IERC721BurnRedeem).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function setERC721Recoverable(
        address contract_,
        uint256 tokenId,
        address recoverer
    ) external virtual override adminRequired {}


    function recoverERC721(address contract_, uint256 tokenId)
        external
        virtual
        override
    {}


    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override nonReentrant returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// MIT

pragma solidity ^0.8.0;



abstract contract ERC721CreatorExtension is CreatorExtension {

    bytes4 internal constant LEGACY_ERC721_EXTENSION_BURNABLE_INTERFACE =
        0xf3f4e68b;
}// MIT

pragma solidity ^0.8.0;



interface IERC721CreatorExtensionApproveTransfer is IERC165 {

    function setApproveTransfer(address creator, bool enabled) external;


    function approveTransfer(
        address from,
        address to,
        uint256 tokenId
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;




abstract contract ERC721CreatorExtensionApproveTransfer is
    AdminControl,
    ERC721CreatorExtension,
    IERC721CreatorExtensionApproveTransfer
{
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AdminControl, CreatorExtension, IERC165)
        returns (bool)
    {
        return
            interfaceId ==
            type(IERC721CreatorExtensionApproveTransfer).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function setApproveTransfer(address creator, bool enabled)
        external
        override
        adminRequired
    {
        require(
            ERC165Checker.supportsInterface(
                creator,
                type(IERC721CreatorCore).interfaceId
            ),
            "creator must implement IERC721CreatorCore"
        );
        IERC721CreatorCore(creator).setApproveTransferExtension(enabled);
    }
}// MIT

pragma solidity ^0.8.0;




abstract contract SingleCreatorBase {
    address internal _creator;
}

abstract contract ERC721SingleCreatorExtension is SingleCreatorBase {
    constructor(address creator) {
        require(
            ERC165Checker.supportsInterface(
                creator,
                type(IERC721CreatorCore).interfaceId
            ) ||
                ERC165Checker.supportsInterface(
                    creator,
                    LegacyInterfaces.IERC721CreatorCore_v1
                ),
            "Redeem: Minting reward contract must implement IERC721CreatorCore"
        );
        _creator = creator;
    }
}// MIT

pragma solidity ^0.8.0;






abstract contract ERC721OwnerEnumerableSingleCreatorBase is
    SingleCreatorBase,
    ERC721CreatorExtensionApproveTransfer
{
    mapping(address => uint256) private _ownerBalance;
    mapping(address => mapping(uint256 => uint256)) private _tokensByOwner;
    mapping(uint256 => uint256) private _tokensIndex;

    function _activate() internal {
        IERC721CreatorCore(_creator).setApproveTransferExtension(true);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        returns (uint256)
    {
        require(
            index < _ownerBalance[owner],
            "ERC721Enumerable: owner index out of bounds"
        );
        return _tokensByOwner[owner][index];
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        return _ownerBalance[owner];
    }

    function approveTransfer(
        address from,
        address to,
        uint256 tokenId
    ) external override returns (bool) {
        require(msg.sender == _creator, "Invalid caller");
        if (from != address(0) && from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to != address(0) && to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
        return true;
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = _ownerBalance[to];
        _tokensByOwner[to][length] = tokenId;
        _tokensIndex[tokenId] = length;
        _ownerBalance[to] += 1;
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {

        uint256 lastTokenIndex = _ownerBalance[from] - 1;
        uint256 tokenIndex = _tokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _tokensByOwner[from][lastTokenIndex];

            _tokensByOwner[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _tokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _tokensIndex[tokenId];
        delete _tokensByOwner[from][lastTokenIndex];
        _ownerBalance[from] -= 1;
    }
}

abstract contract ERC721OwnerEnumerableSingleCreatorExtension is
    ERC721OwnerEnumerableSingleCreatorBase,
    ERC721SingleCreatorExtension
{
    constructor(address creator) ERC721SingleCreatorExtension(creator) {}
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Strings {

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



interface ICreatorExtensionTokenURI is IERC165 {

    function tokenURI(address creator, uint256 tokenId)
        external
        view
        returns (string memory);

}// MIT

pragma solidity ^0.8.0;




interface ExtensionInterface {

    function mintNumber(uint256 tokenId) external view returns (uint256);

}

contract Level1FinaleForge is
    ERC721BurnRedeem,
    ERC721OwnerEnumerableSingleCreatorExtension,
    ICreatorExtensionTokenURI
{

    using Strings for uint256;

    address private creator;
    mapping(uint256 => bool) private claimed;
    event forgeWith(
        uint16 _checkToken, // Hop SKip Flop  375
        uint16 _checkToken2, // Xtradit    879
        uint16 _checkToken3, // GameOver   867
        uint16 _checkToken4, // FreshMeat   873
        uint16 _checkToken5, // Vigilant Eye 834
        uint16 _checkToken6, // Bridge Over   801
        uint16 _burnToken  // Distored Reality  123
    );
    event airDropTo(address _receiver);

    string private _endpoint =
        "https://client-metadata.ether.cards/api/aoki/Level1Finale/";

    uint256 public forge_start = 1639674000; // 1639674000 GMT: Thursday, December 16, 2021 5:00:00 PM

    modifier forgeActive() {

        require(block.timestamp >= forge_start, "not started.");
        _;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(
            ERC721BurnRedeem,
            IERC165,
            ERC721CreatorExtensionApproveTransfer
        )
        returns (bool)
    {

        return
            interfaceId == type(ICreatorExtensionTokenURI).interfaceId ||
            super.supportsInterface(interfaceId) ||
            ERC721CreatorExtensionApproveTransfer.supportsInterface(
                interfaceId
            );
    }

    constructor(
        address _creator, //  0x01Ba93514e5Eb642Ec63E95EF7787b0eDd403ADd
        uint16 redemptionRate, // 1
        uint16 redemptionMax // 10
    )
        ERC721OwnerEnumerableSingleCreatorExtension(_creator)
        ERC721BurnRedeem(_creator, redemptionRate, redemptionMax)
    {
        creator = _creator;
    }

    function checkClaim(uint256 _tokenID) public view returns (bool) {

        return (!claimed[_tokenID]); // check status. false by default. then become true after claim.
    }

    function setup() external onlyOwner {

        super._activate();
    }

    function EmergencyAirdrop(address _to) external onlyOwner {

        _mintRedemption(_to);
        emit airDropTo(_to);
    }

    
address public Xtradit = 0x2b09d7DBab4D4a3a7ca4AafB691bB8289b8c132A;
address public GameOver = 0x0d0dCD1af3D7d4De666F252c9eBEFdBF913fa3eb;
address public FreshMeat = 0xf9a38984244A37d7040d9bbE35aa7dd58C00ed9A;
address public VigilantEye = 0x3383a9C5dB21FE5e00491532CC5f38A1Bd747dcd;
address public BridgeOver = 0x2e631e51F83f5aD99dd69B812D755963633c8b62;
    function forge(
        uint16 _checkToken, // Hop SKip Flop
        uint16 _checkToken2, // Xtradit
        uint16 _checkToken3, // GameOver
        uint16 _checkToken4, // FreshMeat
        uint16 _checkToken5, // Vigilant Eye
        uint16 _checkToken6, // Bridge Over
        uint16 _burnToken //  DistortedReality
    ) external forgeActive() {


        require(374 <= _checkToken && _checkToken <= 383, "!H");

        require(ExtensionInterface(Xtradit).mintNumber(_checkToken2) > 0 && ( ExtensionInterface(GameOver).mintNumber(_checkToken3) > 0 ), "!2 & !3");
        require(ExtensionInterface(FreshMeat).mintNumber(_checkToken4) > 0 && ( ExtensionInterface(VigilantEye).mintNumber(_checkToken5) > 0 ), "!4 & !5");
        require(redeemable(creator, _burnToken) && ExtensionInterface(BridgeOver).mintNumber(_checkToken6) > 0 , "IT , !6");

        require(checkClaim(_checkToken) == true && ( IERC721(creator).ownerOf(_checkToken) == msg.sender), "F1");
        require(checkClaim(_checkToken2) == true && ( IERC721(creator).ownerOf(_checkToken2) == msg.sender), "F2");
        require(checkClaim(_checkToken3) == true && (IERC721(creator).ownerOf(_checkToken3) == msg.sender), "F3");
        require(checkClaim(_checkToken4) == true && (IERC721(creator).ownerOf(_checkToken4) == msg.sender) , "F4");
        require(checkClaim(_checkToken5) == true && (IERC721(creator).ownerOf(_checkToken5) == msg.sender), "F5");
        require(checkClaim(_checkToken6) == true &&( IERC721(creator).ownerOf(_checkToken6) == msg.sender), "F6");

        claimed[_checkToken] = true;
        claimed[_checkToken2] = true;
        claimed[_checkToken3] = true;
        claimed[_checkToken4] = true;
        claimed[_checkToken5] = true;
        claimed[_checkToken6] = true;

        try
            IERC721(creator).transferFrom(
                msg.sender,
                address(0xdEaD),
                _burnToken
            )
        {} catch (bytes memory) {
            revert("Bf");
        }

        _mintRedemption(msg.sender);
        emit forgeWith(
            _checkToken, // Hop SKip Flop
            _checkToken2, // Xtradit
            _checkToken3, // GameOver
            _checkToken4, // FreshMeat
            _checkToken5, // Vigilant Eye
            _checkToken6, // Bridge Over
            _burnToken
        );
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_mintNumbers[tokenId] != 0, "It");
        return
            string(
                abi.encodePacked(
                    _endpoint,
                    uint256(int256(_mintNumbers[tokenId])).toString()
                )
            );
    }

    function tokenURI(address _creator, uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return tokenURI(tokenId);
    }


    function drain(IERC20 _token) external onlyOwner {
        if (address(_token) == 0x0000000000000000000000000000000000000000) {
            payable(owner()).transfer(address(this).balance);
        } else {
            _token.transfer(owner(), _token.balanceOf(address(this)));
        }
    }

    function retrieve721(address _tracker, uint256 _id) external onlyOwner {
        IERC721(_tracker).transferFrom(address(this), msg.sender, _id);
    }

        function setTime(uint256 _time) external onlyOwner {
        forge_start = _time;
    }

    function how_long_more()
        public
        view
        returns (
            uint256 Days,
            uint256 Hours,
            uint256 Minutes,
            uint256 Seconds
        )
    {
        require(block.timestamp < forge_start, "Started");
        uint256 gap = forge_start - block.timestamp;
        Days = gap / (24 * 60 * 60);
        gap = gap % (24 * 60 * 60);
        Hours = gap / (60 * 60);
        gap = gap % (60 * 60);
        Minutes = gap / 60;
        Seconds = gap % 60;
        return (Days, Hours, Minutes, Seconds);
    }
}