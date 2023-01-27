
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
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

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}// MIT

pragma solidity ^0.8.0;






contract FirstDayOut is AdminControl, ICreatorExtensionTokenURI {

    enum ContractStatus {
        Paused,
        PreMint,
        Public,
        Closed
    }
    
    using Strings for uint256;

    ContractStatus public contractStatus = ContractStatus.Paused;
    address private _creator;
    address public _donationAddress;
    string private _day;
    string private _dayPreview;
    string private _night;
    uint public _price;
    bytes32 public _merkleRoot;    
    uint256 public totalSupply = 0;

    mapping(uint256 => bool) public tokenIdDayOrNight; // 0 = Night; 1 = Day

    constructor(
        address creator,
        string memory day,
        string memory dayPreview,
        string memory night,
        bytes32 merkleRoot,
        address donationAddress,
        uint price
    ) public {
        _creator = creator;
        _day = day;
        _dayPreview = dayPreview;
        _night = night;
        _merkleRoot = merkleRoot;
        _donationAddress = donationAddress;
        _price = price;
    }

    modifier callerIsUser() {

        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AdminControl, IERC165) returns (bool) {

        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId || AdminControl.supportsInterface(interfaceId) || super.supportsInterface(interfaceId);
    }

    function airdrop(address[] memory receivers) public adminRequired {

        for (uint i; i < receivers.length; i++) {
            IERC721CreatorCore(_creator).mintExtension(receivers[i]);
            totalSupply += 1;
        }
    }

    function mintPrivate(uint256 quantity, bytes32[] calldata proof) public payable callerIsUser {      

        require(contractStatus == ContractStatus.PreMint, "Pre mint is yet not available");
        require(msg.value == _price * quantity, "Not enough ETH sent");
        require(canMintPrivate(msg.sender, proof), "Failed wallet verification");      
        IERC721CreatorCore(_creator).mintExtensionBatch(msg.sender, uint16(quantity));
        totalSupply += quantity;
    }

    function mintPublic(uint256 quantity) public payable callerIsUser {

        require(contractStatus == ContractStatus.Public, "Public minting yet not available");
        require(msg.value == _price * quantity, "Not enough ETH sent");
        IERC721CreatorCore(_creator).mintExtensionBatch(msg.sender, uint16(quantity));
        totalSupply += quantity;
    }

    function setImages(string memory day, string memory dayPreview, string memory night) public adminRequired {

        _day = day;
        _dayPreview = dayPreview;
        _night = night;
    }
 
    function setPrice(uint price) public adminRequired {

        _price = price;
    }

    function setDonationAddress(address donationAddress) public adminRequired {

        require(donationAddress != address(0), "Donation address cannot be 0x0");
        _donationAddress = donationAddress;
    }

    function setContractStatus(ContractStatus status) public adminRequired {

        contractStatus = status;
    }

    function overrideTotalSupply(uint256 supply) public adminRequired{ 

        totalSupply = supply;
    }

    function toggleURI(uint256 tokenId) public {

        require(IERC721Upgradeable(_creator).ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        tokenIdDayOrNight[tokenId] = !tokenIdDayOrNight[tokenId];
    }

    function getName(uint256 tokenId) private view returns (string memory) {

        if(contractStatus == ContractStatus.Closed) {
            return string(abi.encodePacked("First Day Out #", tokenId.toString(), "/", totalSupply.toString()));
        } else {
            return string(abi.encodePacked("First Day Out #", tokenId.toString()));
        }
    }

    function getImage(uint256 tokenId) private view returns (string memory) {

        if(tokenIdDayOrNight[tokenId]) {
            return string(abi.encodePacked(
                '"image":"',
                _dayPreview,
                '","image_url":"',
                _dayPreview,
                '","animation_url":"',
                _day,
                '","attributes": [{"trait_type": "Location","value": "Hamilton County, OH"}]'
            ));
        } else {
            return string(abi.encodePacked(
                '"image":"',
                _night,
                '","image_url":"',
                _night,
                '","attributes": [{"trait_type": "Location","value": "New York, NY"}]'
            ));
        }
    }

    function tokenURI(address creator, uint256 tokenId) external view override returns (string memory) {

       require(creator == _creator, "Invalid token");
       return string(abi.encodePacked('data:application/json;utf8,',
        '{"name":"',
            getName(tokenId),
        '",',
        '"created_by":"Isaac Wright",',
        '"description":"First Day Out\\n\\nArtist: Isaac Wright",',
            getImage(tokenId),
        '}'
        ));
    }

    function withdraw(address to) public onlyOwner {

        uint256 sendAmount = address(this).balance;

        address creator = payable(to);
        address donation = payable(_donationAddress); // 15% of the funds go to the donation address

        bool success;

        (success, ) = creator.call{value: (sendAmount * 850/1000)}("");
        require(success, "Transaction Unsuccessful");

        (success, ) = donation.call{value: (sendAmount * 150/1000)}("");
        require(success, "Transaction Unsuccessful");
    }

    function canMintPrivate(address account, bytes32[] calldata proof) public view returns (bool) {

        return MerkleProof.verify(proof, _merkleRoot, generateMerkleLeaf(account));
    }

    function generateMerkleLeaf(address account) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(account));
    }

    function setMerkleRoot(bytes32 merkleRoot) public adminRequired {

        _merkleRoot = merkleRoot;
    }
}