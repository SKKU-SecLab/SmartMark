
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



interface ICreatorExtensionTokenURI is IERC165 {


    function tokenURI(address creator, uint256 tokenId) external view returns (string memory);

}// MIT
pragma solidity ^0.8.3;

struct NFTDataAttributes {
    string hashString;
    uint256 sold;
    address[] owners;
    uint256[] tokens;
}
struct Collection {
    string title;
    uint price;
    uint16 editions;
}

struct ContractData {
    string APIEndpoint;
    bool isActive;
    address payable beneficiary;
}// MIT

pragma solidity ^0.8.3;



contract DieGoldeneInge is AdminControl {

    address private _creator;
    address[] private nftImageHolders;


    bool isActive;
    Collection private collectionData;
    NFTDataAttributes[] private nftData;
    ContractData private contractData;

    mapping(uint256 => string) public _tokens;

    NFTDataAttributes[] private tokensData;

    constructor(
        address creator,
        string memory _title,
        uint256 _price,
        uint16 _editions,
        address payable _beneficiary,
        string[] memory hashes
    ) {
        _creator = creator;
        contractData.beneficiary = _beneficiary;
        contractData.isActive = true;
        contractData.APIEndpoint = "https://arweave.net/";
        setCollectionData(
            Collection({title: _title, price: _price, editions: _editions})
        );
        setNftData(hashes, true);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AdminControl)
        returns (bool)
    {

        return
            interfaceId == type(ICreatorExtensionTokenURI).interfaceId ||
            AdminControl.supportsInterface(interfaceId) ||
            super.supportsInterface(interfaceId);
    }

    modifier collectableIsActive() {

        require(contractData.isActive == true);
        _;
    }

    function containsOwner(address to, string memory hashString)
        public
        view
        returns (bool isInArray)
    {

        for (uint256 i = 0; i < tokensData.length; i++) {
            if (
                keccak256(bytes(hashString)) ==
                keccak256(bytes(tokensData[i].hashString))
            ) {
                for (uint256 j = 0; j < tokensData[i].owners.length; j++) {
                    if (tokensData[i].owners[j] == to) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    function getImageMetaByHash(string memory hashString)
        public
        view
        returns (NFTDataAttributes memory data, uint256 index)
    {

        bytes memory tempEmptyStringTest = bytes(hashString); 
        require(tempEmptyStringTest.length > 5);
        for (uint256 i = 0; i < tokensData.length; i++) {
            if (
                keccak256(bytes(hashString)) ==
                keccak256(bytes(tokensData[i].hashString))
            ) {
                return (tokensData[i], i);
            }
        }
    }

    function mint(string memory imageId)
        public
        payable
        collectableIsActive
        returns (uint256 tokenId)
    {

        bytes memory testIfEmpty = bytes(imageId); 
        require(testIfEmpty.length > 5,"invalid hash");

        (
            NFTDataAttributes memory tokenData,
            uint256 index
        ) = getImageMetaByHash(imageId);

        uint256 price = collectionData.price;
        uint256 sold = tokenData.sold;
        testIfEmpty = bytes(tokenData.hashString); 
    
        require(testIfEmpty.length > 5, "Hash not valid");
        require(msg.value >= price, "Not enough ether to purchase NFTs.");
        require(sold < collectionData.editions, "Edition sold out");
        require(
            !containsOwner(msg.sender, imageId),
            "You already own this image"
        );

        uint256 newItemId = IERC721CreatorCore(_creator).mintExtension(
            msg.sender
        );
        IERC721CreatorCore(_creator).setTokenURIExtension(
            newItemId,
            string(abi.encodePacked(contractData.APIEndpoint , tokensData[index].hashString))
        );
        tokensData[index].tokens.push(newItemId);
        tokensData[index].owners.push(msg.sender);
        tokensData[index].sold = tokensData[index].sold + 1;
        _tokens[newItemId] = imageId;
        return newItemId;
    }

    function setApiEndpoint(string memory _apiEndpoint) public adminRequired {

        contractData.APIEndpoint  = _apiEndpoint;
    }

    function setCollectionData(Collection memory _data) public adminRequired {

        collectionData = _data;
    }

    function setNftData(string[] memory _tokensData, bool reset) public adminRequired {

        uint256[] memory placeholder;
        if(reset) {
               delete tokensData;
        }
        for (uint256 i = 0; i < _tokensData.length; i += 1) {
            tokensData.push(
                NFTDataAttributes({
                    hashString: _tokensData[i],
                    sold: 0,
                    owners: new address[](0),
                    tokens: placeholder
                })
            );
        }
    }

    function setBeneficiaryAddress(address payable _beneficiary)
        public
        adminRequired
    {

        contractData.beneficiary = _beneficiary;
    }

    function setIsActive(bool _isActive) public adminRequired {

        contractData.isActive = _isActive;
    }

    function withdraw() public adminRequired {

        contractData.beneficiary.transfer(address(this).balance);
    }
}