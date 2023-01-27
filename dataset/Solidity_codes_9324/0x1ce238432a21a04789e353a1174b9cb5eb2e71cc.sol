
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

}// CONSTANTLY WANTS TO MAKE THE WORLD BEAUTIFUL

                                                                                                                                         


pragma solidity ^0.8.0;

interface IHandleExternal {

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function contractURI() external view returns (string memory);

}



contract MetaCollection is Ownable {


    using Strings for uint256;

    address public HundredElevenContract;

    struct Collection {
        string name;
        bool isExternal;
        address externalContract;
        string uri;
    }

    Collection[] public collections;
    mapping (uint => uint) public idToCollection;

    event tokenMetadataChanged(uint tokenId, uint collection);
    event collectionEdit(uint _index, string _name, bool _isExternal, address _address, string _uri);

    function setHundredElevenAddress(address _address) public onlyOwner {

        HundredElevenContract = _address;
    }

    function addCollection(string memory _name, bool _isExternal, address _address, string memory _uri) public onlyOwner {

        collections.push( Collection(_name,_isExternal,_address,_uri) );
        emit collectionEdit(collections.length - 1,_name,_isExternal,_address,_uri);
    }
    function editCollection(uint _index, string memory _name, bool _isExternal, address _address, string memory _uri) public onlyOwner {

        collections[_index] = Collection(_name,_isExternal,_address,_uri);
        emit collectionEdit(_index,_name,_isExternal,_address,_uri);
    }

    function collectionTotal() public view returns (uint) {

        return collections.length;
    }

    function getCollectionInfo(uint _collection) public view returns (string memory) {

        require(_collection < collections.length, "choose a valid collection!");
        Collection memory collection = collections[_collection];

        return
            collection.isExternal
                ? IHandleExternal(collection.externalContract).contractURI()
                : string(abi.encodePacked(collection.uri, "info"));
    }
    
    function getCollectionInfoAll() public view returns (string[] memory) {

        string[] memory _metadataGroup = new string[](collections.length);

        for (uint i = 0; i < collections.length; i++) {
            Collection memory _collection = collections[i];
            _collection.isExternal
                ? _metadataGroup[i] = IHandleExternal(_collection.externalContract).contractURI()
                : _metadataGroup[i] = string(abi.encodePacked(_collection.uri, "info"));
        }

        return _metadataGroup;
    }


    function getCollections() public view returns (Collection[] memory) {

        return collections;
    }

    function getIdToCollectionMulti(uint256[] memory _ids) public view returns(uint256[] memory) {

        uint256[] memory indexes = new uint256[](_ids.length);
        for (uint256 i = 0; i < indexes.length; i++) {
            indexes[i] = idToCollection[_ids[i]];
        }
        return indexes;
    }

    function getMetadata(uint256 tokenId)
        external
        view
        returns (string memory)
    {

        Collection memory _collection = collections[idToCollection[tokenId]];

        return
            _collection.isExternal
                ? IHandleExternal(_collection.externalContract).tokenURI(tokenId)
                : string(abi.encodePacked(_collection.uri, tokenId.toString()));
        
    }

    function getMetadataOfIdForCollection(uint256 tokenId, uint256 collection)
        external
        view
        returns (string memory)
    {

        require(collection < collections.length, "choose a valid collection!");
        Collection memory _collection = collections[collection];

        return
            _collection.isExternal
                ? IHandleExternal(_collection.externalContract).tokenURI(tokenId)
                : string(abi.encodePacked(_collection.uri, tokenId.toString()));
    
        
    }

    function getMetadataOfIdForAllCollections(uint256 tokenId)
        external
        view
        returns (string[] memory)
    {

        string[] memory _metadataGroup = new string[](collections.length);

        for (uint i = 0; i < collections.length; i++) {
            Collection memory _collection = collections[i];
            _collection.isExternal
                ? _metadataGroup[i] = IHandleExternal(_collection.externalContract).tokenURI(tokenId)
                : _metadataGroup[i] = string(abi.encodePacked(_collection.uri, tokenId.toString()));
        }

        return _metadataGroup;
        
    }

    function changeMetadataForToken(uint[] memory tokenIds, uint[] memory _collections) public {

        for (uint i = 0 ; i < tokenIds.length; i++) {
            uint collection = _collections[i];
            require(collection < collections.length, "choose a valid collection!");
            uint tokenId = tokenIds[i];
            require(IERC721(HundredElevenContract).ownerOf(tokenId) == msg.sender, "Caller is not the owner");
            idToCollection[tokenId] = collection;
            emit tokenMetadataChanged(tokenId, collection);
        }
        
    }

  

    constructor(address _MetaChess) {
        addCollection("NUMZ",false,address(0),"https://berk.mypinata.cloud/ipfs/QmWWsyCUwQ6jKieUQk8gEgafCRxQsR4A8MFaTiHvs7KsyG/");
        addCollection("FreqBae",false,address(0),"https://berk.mypinata.cloud/ipfs/QmQK5WD6hcmZ5CD7oXNzN7gQ5X7YMBeCejmYbxTCi8eKLz/");
        addCollection("ri-se[t]",false,address(0),"https://berk.mypinata.cloud/ipfs/QmQkMgcqUyaNJVK551mFmDtfGhXGaoeF111s13gig7X9i5/");
        addCollection("ATAKOI",false,address(0),"https://berk.mypinata.cloud/ipfs/QmPY9pTNru8SvcgrQJVgrwnhGBZaPNa26HwepG4jHnTQPA/");
        addCollection("MELLOLOVE",false,address(0),"https://berk.mypinata.cloud/ipfs/QmYgSwobV6qSRVw6dwCcv7iXq4QXe7oTde5YdMpLwzP8cQ/");
        addCollection("MetaChess",true,_MetaChess,"");

        for (uint i=1; i <= 111; i++) {
            idToCollection[i] = i % 6;
        }

    }



}