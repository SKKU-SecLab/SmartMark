



interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}






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

}





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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}





interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}





interface IHandler {

    function supportToken(address token) external;


    function stopSupportingToken(address token) external;


    function isSupported(address token) external view returns (bool);


    function deposit(address from, address token, uint256 tokenId) external;


    function withdraw(address recipient, address token, uint256 tokenId) external;


    function changeOwnership(address recipient, address token, uint256 tokenId) external;


    function ownerOf(address token, uint256 tokenId) external view returns (address);


    function depositTimestamp(address tokenContract, uint256 tokenId) external view returns (uint256);

}






abstract contract ERC721HandlerStorage {
    bool internal _initialized;
    bool internal _initializing;

    address internal _owner;

    mapping(address => bool) internal _supportedTokens;
    mapping(address => mapping(uint256 => address)) internal _tokenOwners;
    mapping(address => mapping(address => EnumerableSet.UintSet)) internal _ownedTokens;
    mapping(address => mapping(uint256 => uint256)) internal _depositTimestamp;
}






contract Initializable is ERC721HandlerStorage {



    modifier initializer() {

        require(_initializing || isConstructor() || !_initialized, "Contract instance has already been initialized");

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

    function isConstructor() private view returns (bool) {

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}






contract Ownable is ERC721HandlerStorage, Initializable {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init_unchained(address owner) internal initializer {

        _owner = owner;
        emit OwnershipTransferred(address(0), owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity 0.7.3;


contract ERC721Handler is IHandler, IERC721Receiver, ERC721HandlerStorage, Initializable, Ownable {

    using EnumerableSet for EnumerableSet.UintSet;





    constructor(address owner) {
        initialize(owner);
    }

    function initialize(address owner) public initializer {

        __Ownable_init_unchained(owner);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {

        revert("ERC721Handler: tokens cannot be transferred directly, use Pawnshop.depositItem function instead");
    }

    function supportToken(address tokenContract) external override onlyOwner {

        _supportedTokens[tokenContract] = true;
    }

    function stopSupportingToken(address tokenContract) external override onlyOwner {

        _supportedTokens[tokenContract] = false;
    }

    function deposit(address from, address tokenContract, uint256 tokenId) external override onlyOwner {

        require(isSupported(tokenContract), "ERC721Handler: token is not supported");
        IERC721(tokenContract).transferFrom(from, address(this), tokenId);
        _tokenOwners[tokenContract][tokenId] = from;
        _ownedTokens[tokenContract][from].add(tokenId);
        _depositTimestamp[tokenContract][tokenId] = block.timestamp;
    }

    function withdraw(address recipient, address tokenContract, uint256 tokenId) external override onlyOwner {

        require(ownerOf(tokenContract, tokenId) == recipient, "ERC721Handler: recipient address is not the owner of the token");
        IERC721(tokenContract).transferFrom(address(this), recipient, tokenId); // WARNING: Withdrawing to a contract which is not an ERC721 receiver can block an access to the item.
        delete _tokenOwners[tokenContract][tokenId];
        _ownedTokens[tokenContract][recipient].remove(tokenId);
        delete _depositTimestamp[tokenContract][tokenId];
    }

    function changeOwnership(address recipient, address tokenContract, uint256 tokenId) external override onlyOwner {

        require(IERC721(tokenContract).ownerOf(tokenId) == address(this), "ERC721Handler: to change the ownership of the item, it must be deposited to the handler first");
        address owner = ownerOf(tokenContract, tokenId);
        _tokenOwners[tokenContract][tokenId] = recipient;
        _ownedTokens[tokenContract][owner].remove(tokenId);
        _ownedTokens[tokenContract][recipient].add(tokenId);
    }

    function isSupported(address tokenContract) public override view returns (bool) {

        return _supportedTokens[tokenContract];
    }

    function ownerOf(address tokenContract, uint256 tokenId) public override view returns (address) {

        return _tokenOwners[tokenContract][tokenId];
    }

    function ownedTokens(address tokenContract, address owner) public view returns (uint256[] memory) {

        EnumerableSet.UintSet storage tokens = _ownedTokens[tokenContract][owner];
        uint256 ownedTokensLength = tokens.length();
        uint256[] memory tokenIds = new uint256[](ownedTokensLength);
        for (uint i = 0; i < ownedTokensLength; i++) {
            tokenIds[i] = tokens.at(i);
        }

        return tokenIds;
    }

    function depositTimestamp(address tokenContract, uint256 tokenId) public override view returns (uint256) {

        return _depositTimestamp[tokenContract][tokenId];
    }
}