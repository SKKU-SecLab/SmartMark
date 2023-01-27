
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IAdminControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    modifier adminRequired() {
        require(owner() == msg.sender || _admins.contains(msg.sender), "AdminControl: Must be owner or admin");
        _;
    }   

    function getAdmins() external view override returns (address[] memory admins) {
        admins = new address[](_admins.length());
        for (uint i = 0; i < _admins.length(); i++) {
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

    function isAdmin(address admin) public override view returns (bool) {
        return (owner() == admin || _admins.contains(admin));
    }

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


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

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

        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
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



interface ICreatorExtensionTokenURI is IERC165 {


    function tokenURI(address creator, uint256 tokenId) external view returns (string memory);

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





abstract contract CreatorCore is ReentrancyGuard, ICreatorCore, ERC165 {
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using AddressUpgradeable for address;

    uint256 _tokenCount = 0;

    EnumerableSet.AddressSet internal _extensions;
    EnumerableSet.AddressSet internal _blacklistedExtensions;
    mapping (address => address) internal _extensionPermissions;
    mapping (address => bool) internal _extensionApproveTransfers;
    
    mapping (uint256 => address) internal _tokensExtension;

    mapping (address => string) private _extensionBaseURI;
    mapping (address => bool) private _extensionBaseURIIdentical;

    mapping (address => string) private _extensionURIPrefix;

    mapping (uint256 => string) internal _tokenURIs;

    
    mapping (address => address payable[]) internal _extensionRoyaltyReceivers;
    mapping (address => uint256[]) internal _extensionRoyaltyBPS;
    mapping (uint256 => address payable[]) internal _tokenRoyaltyReceivers;
    mapping (uint256 => uint256[]) internal _tokenRoyaltyBPS;


    bytes4 private constant _INTERFACE_ID_ROYALTIES_CREATORCORE = 0xbb3bafd6;

    bytes4 private constant _INTERFACE_ID_ROYALTIES_RARIBLE = 0xb7799584;

    bytes4 private constant _INTERFACE_ID_ROYALTIES_FOUNDATION = 0xd5a06d4c;

    bytes4 private constant _INTERFACE_ID_ROYALTIES_EIP2981 = 0x2a55205a;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(ICreatorCore).interfaceId || super.supportsInterface(interfaceId)
            || interfaceId == _INTERFACE_ID_ROYALTIES_CREATORCORE || interfaceId == _INTERFACE_ID_ROYALTIES_RARIBLE
            || interfaceId == _INTERFACE_ID_ROYALTIES_FOUNDATION || interfaceId == _INTERFACE_ID_ROYALTIES_EIP2981;
    }

    modifier extensionRequired() {
        require(_extensions.contains(msg.sender), "Must be registered extension");
        _;
    }

    modifier nonBlacklistRequired(address extension) {
        require(!_blacklistedExtensions.contains(extension), "Extension blacklisted");
        _;
    }   

    function getExtensions() external view override returns (address[] memory extensions) {
        extensions = new address[](_extensions.length());
        for (uint i = 0; i < _extensions.length(); i++) {
            extensions[i] = _extensions.at(i);
        }
        return extensions;
    }

    function _registerExtension(address extension, string calldata baseURI, bool baseURIIdentical) internal {
        require(extension != address(this), "Creator: Invalid");
        require(extension.isContract(), "Creator: Extension must be a contract");
        if (!_extensions.contains(extension)) {
            _extensionBaseURI[extension] = baseURI;
            _extensionBaseURIIdentical[extension] = baseURIIdentical;
            emit ExtensionRegistered(extension, msg.sender);
            _extensions.add(extension);
        }
    }

    function _unregisterExtension(address extension) internal {
       if (_extensions.contains(extension)) {
           emit ExtensionUnregistered(extension, msg.sender);
           _extensions.remove(extension);
       }
    }

    function _blacklistExtension(address extension) internal {
       require(extension != address(this), "Cannot blacklist yourself");
       if (_extensions.contains(extension)) {
           emit ExtensionUnregistered(extension, msg.sender);
           _extensions.remove(extension);
       }
       if (!_blacklistedExtensions.contains(extension)) {
           emit ExtensionBlacklisted(extension, msg.sender);
           _blacklistedExtensions.add(extension);
       }
    }

    function _setBaseTokenURIExtension(string calldata uri, bool identical) internal {
        _extensionBaseURI[msg.sender] = uri;
        _extensionBaseURIIdentical[msg.sender] = identical;
    }

    function _setTokenURIPrefixExtension(string calldata prefix) internal {
        _extensionURIPrefix[msg.sender] = prefix;
    }

    function _setTokenURIExtension(uint256 tokenId, string calldata uri) internal {
        require(_tokensExtension[tokenId] == msg.sender, "Invalid token");
        _tokenURIs[tokenId] = uri;
    }

    function _setBaseTokenURI(string memory uri) internal {
        _extensionBaseURI[address(this)] = uri;
    }

    function _setTokenURIPrefix(string calldata prefix) internal {
        _extensionURIPrefix[address(this)] = prefix;
    }


    function _setTokenURI(uint256 tokenId, string calldata uri) internal {
        require(_tokensExtension[tokenId] == address(this), "Invalid token");
        _tokenURIs[tokenId] = uri;
    }

    function _tokenURI(uint256 tokenId) internal view returns (string memory) {
        address extension = _tokensExtension[tokenId];
        require(!_blacklistedExtensions.contains(extension), "Extension blacklisted");

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            if (bytes(_extensionURIPrefix[extension]).length != 0) {
                return string(abi.encodePacked(_extensionURIPrefix[extension],_tokenURIs[tokenId]));
            }
            return _tokenURIs[tokenId];
        }

        if (ERC165Checker.supportsInterface(extension, type(ICreatorExtensionTokenURI).interfaceId)) {
            return ICreatorExtensionTokenURI(extension).tokenURI(address(this), tokenId);
        }

        if (!_extensionBaseURIIdentical[extension]) {
            return string(abi.encodePacked(_extensionBaseURI[extension], tokenId.toString()));
        } else {
            return _extensionBaseURI[extension];
        }
    }

    function _tokenExtension(uint256 tokenId) internal view returns (address extension) {
        extension = _tokensExtension[tokenId];

        require(extension != address(this), "No extension for token");
        require(!_blacklistedExtensions.contains(extension), "Extension blacklisted");

        return extension;
    }

    function _getRoyalties(uint256 tokenId) view internal returns (address payable[] storage, uint256[] storage) {
        return (_getRoyaltyReceivers(tokenId), _getRoyaltyBPS(tokenId));
    }

    function _getRoyaltyReceivers(uint256 tokenId) view internal returns (address payable[] storage) {
        if (_tokenRoyaltyReceivers[tokenId].length > 0) {
            return _tokenRoyaltyReceivers[tokenId];
        } else if (_extensionRoyaltyReceivers[_tokensExtension[tokenId]].length > 0) {
            return _extensionRoyaltyReceivers[_tokensExtension[tokenId]];
        }
        return _extensionRoyaltyReceivers[address(this)];        
    }

    function _getRoyaltyBPS(uint256 tokenId) view internal returns (uint256[] storage) {
        if (_tokenRoyaltyBPS[tokenId].length > 0) {
            return _tokenRoyaltyBPS[tokenId];
        } else if (_extensionRoyaltyBPS[_tokensExtension[tokenId]].length > 0) {
            return _extensionRoyaltyBPS[_tokensExtension[tokenId]];
        }
        return _extensionRoyaltyBPS[address(this)];        
    }

    function _getRoyaltyInfo(uint256 tokenId, uint256 value) view internal returns (address receiver, uint256 amount){
        address payable[] storage receivers = _getRoyaltyReceivers(tokenId);
        require(receivers.length <= 1, "More than 1 royalty receiver");
        
        if (receivers.length == 0) {
            return (address(this), 0);
        }
        return (receivers[0], _getRoyaltyBPS(tokenId)[0]*value/10000);
    }

    function _setRoyalties(uint256 tokenId, address payable[] calldata receivers, uint256[] calldata basisPoints) internal {
        require(receivers.length == basisPoints.length, "Invalid input");
        uint256 totalBasisPoints;
        for (uint i = 0; i < basisPoints.length; i++) {
            totalBasisPoints += basisPoints[i];
        }
        require(totalBasisPoints < 10000, "Invalid total royalties");
        _tokenRoyaltyReceivers[tokenId] = receivers;
        _tokenRoyaltyBPS[tokenId] = basisPoints;
        emit RoyaltiesUpdated(tokenId, receivers, basisPoints);
    }

    function _setRoyaltiesExtension(address extension, address payable[] calldata receivers, uint256[] calldata basisPoints) internal {
        require(receivers.length == basisPoints.length, "Invalid input");
        uint256 totalBasisPoints;
        for (uint i = 0; i < basisPoints.length; i++) {
            totalBasisPoints += basisPoints[i];
        }
        require(totalBasisPoints < 10000, "Invalid total royalties");
        _extensionRoyaltyReceivers[extension] = receivers;
        _extensionRoyaltyBPS[extension] = basisPoints;
        if (extension == address(this)) {
            emit DefaultRoyaltiesUpdated(receivers, basisPoints);
        } else {
            emit ExtensionRoyaltiesUpdated(extension, receivers, basisPoints);
        }
    }


}// MIT

pragma solidity ^0.8.0;



interface IERC1155CreatorCore is ICreatorCore {


    function mintBaseNew(address[] calldata to, uint256[] calldata amounts, string[] calldata uris) external returns (uint256[] memory);


    function mintBaseExisting(address[] calldata to, uint256[] calldata tokenIds, uint256[] calldata amounts) external;


    function mintExtensionNew(address[] calldata to, uint256[] calldata amounts, string[] calldata uris) external returns (uint256[] memory);


    function mintExtensionExisting(address[] calldata to, uint256[] calldata tokenIds, uint256[] calldata amounts) external;


    function burn(address account, uint256[] calldata tokenIds, uint256[] calldata amounts) external;


    function totalSupply(uint256 tokenId) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


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

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;




contract Burn is AdminControl, ICreatorExtensionTokenURI {


    using Strings for uint256;
    using Strings for uint16;

    address private _creator;
    string private _baseURI;
    string private _previewImage;

    uint _listingId;
    address _marketplace;
    address _entropyContract;

    uint _ashRateLow;
    uint _ashRateHigh;
    IERC20 _ashContract;

    uint _burnableToken;
    uint _redTokenId;
    uint _blueTokenId;

    string _redToken;
    string _blueToken;

    mapping(address => uint) _numBlues;
    mapping(address => uint) _numReds;

    constructor(address creator) {
        _creator = creator;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AdminControl, IERC165) returns (bool) {

        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId || AdminControl.supportsInterface(interfaceId) || super.supportsInterface(interfaceId);
    }

    function setEntropyContract(address entropyContract) public adminRequired {

      _entropyContract = entropyContract;
    }

    function preMint() public adminRequired {

      address[] memory addressToSend = new address[](1);
      addressToSend[0] = msg.sender;
      uint[] memory amount = new uint[](1);
      amount[0] = 1;
      string[] memory uris = new string[](1);
      uris[0] = "";
      IERC1155CreatorCore(_creator).mintExtensionNew(addressToSend, amount, uris);
    }

    function configureTokens(uint burnableToken, uint redToken, uint blueToken) public adminRequired {

      _burnableToken = burnableToken;
      _redTokenId = redToken;
      _blueTokenId = blueToken;
    }

    function setAshContract(address ashContract, uint ashRateLow, uint ashRateHigh) public adminRequired {

      _ashContract = IERC20(ashContract);
      _ashRateLow = ashRateLow;
      _ashRateHigh = ashRateHigh;
    }

    function withdraw(address recipient, address erc20, uint256 amount) external adminRequired {

        IERC20(erc20).transfer(recipient, amount);
    }

    function mint(uint256 desiredToken, uint whichMethod) public {

      require(desiredToken == _redTokenId || desiredToken == _blueTokenId, "Can only mint red or blue");

      if (desiredToken == _redTokenId) {
        require(_numReds[msg.sender] < 2, "Can only mint 2 reds.");
        _numReds[msg.sender]++;
      } else if (desiredToken == _blueTokenId) {
        require(_numBlues[msg.sender] < 2, "Can only mint 2 blues.");
        _numBlues[msg.sender]++;
      }
      if (whichMethod == 0) {
        require(IERC1155(_entropyContract).balanceOf(msg.sender, _burnableToken) > 1, "Must own NFT");
        require(IERC1155(_entropyContract).isApprovedForAll(msg.sender, address(this)), "BurnRedeem: Contract must be given approval to burn NFT");

        uint[] memory tokenIds = new uint[](1);
        tokenIds[0] = _burnableToken;
        uint[] memory burnAmounts = new uint[](1);
        burnAmounts[0] = 2;
        try IERC1155CreatorCore(_entropyContract).burn(msg.sender, tokenIds, burnAmounts) {
        } catch (bytes memory) {
            revert("BurnRedeem: Burn failure");
        }

        address[] memory addressToSend = new address[](1);
        addressToSend[0] = msg.sender;
        uint[] memory numToSend = new uint[](1);
        numToSend[0] = 1;
        uint[] memory tokenToSend = new uint[](1);
        tokenToSend[0] = desiredToken;

        IERC1155CreatorCore(_creator).mintExtensionExisting(addressToSend, tokenToSend, numToSend);
      } else if (whichMethod == 1) {
        require(_ashContract.allowance(msg.sender, address(this)) >= _ashRateLow, "You have not approved ASH.");
        require(_ashContract.balanceOf(msg.sender) >= _ashRateLow, "You do not have enough ASH.");
        require(IERC1155(_entropyContract).balanceOf(msg.sender, _burnableToken) > 0, "Must own NFT");
        require(IERC1155(_entropyContract).isApprovedForAll(msg.sender, address(this)), "BurnRedeem: Contract must be given approval to burn NFT");


        uint[] memory tokenIds = new uint[](1);
        tokenIds[0] = _burnableToken;
        uint[] memory burnAmounts = new uint[](1);
        burnAmounts[0] = 1;

        try IERC1155CreatorCore(_entropyContract).burn(msg.sender, tokenIds, burnAmounts) {
        } catch (bytes memory) {
            revert("BurnRedeem: Burn failure");
        }

        address[] memory addressToSend = new address[](1);
        addressToSend[0] = msg.sender;
        uint[] memory numToSend = new uint[](1);
        numToSend[0] = 1;
        uint[] memory tokenToSend = new uint[](1);
        tokenToSend[0] = desiredToken;
        require(_ashContract.transferFrom(msg.sender, address(this), _ashRateLow));
        IERC1155CreatorCore(_creator).mintExtensionExisting(addressToSend, tokenToSend, numToSend);
      } else if (whichMethod == 2) {
        require(_ashContract.allowance(msg.sender, address(this)) >= _ashRateHigh, "You have not approved ASH.");
        require(_ashContract.balanceOf(msg.sender) >= _ashRateHigh, "You do not have enough ASH.");
        address[] memory addressToSend = new address[](1);
        addressToSend[0] = msg.sender;
        uint[] memory numToSend = new uint[](1);
        numToSend[0] = 1;
        uint[] memory tokenToSend = new uint[](1);
        tokenToSend[0] = desiredToken;

        require(_ashContract.transferFrom(msg.sender, address(this), _ashRateHigh));
        IERC1155CreatorCore(_creator).mintExtensionExisting(addressToSend, tokenToSend, numToSend);      }
    }

    function setURIs(string memory redToken, string memory blueToken) public adminRequired {

      _redToken = redToken;
      _blueToken = blueToken;
    }

    function tokenURI(address creator, uint256 tokenId) external view override returns (string memory) {

        require(creator == _creator, "Invalid token");
        if (tokenId == _redTokenId) {
          return _redToken;
        } else if (tokenId == _blueTokenId) {
          return _blueToken;
        }
        return "";
    }
}