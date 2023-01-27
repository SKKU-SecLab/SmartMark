pragma solidity ^0.8.0;

interface CollectionManager {

    function tokenURI(uint256) external view returns (string memory);

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

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping (uint256 => address) private _owners;

    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
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

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}pragma solidity ^0.8.0;


uint256 constant TOKEN_ID_LIMIT = 100000000;

contract NFT is Ownable, ERC721, ERC721Enumerable {
    uint256 public constant collectionIdMultiplier =
        TOKEN_ID_LIMIT * TOKEN_ID_LIMIT;
    uint256 public constant seriesIdMultiplier = TOKEN_ID_LIMIT;
    mapping(CollectionManager => bool) public collectionManagerRegistry;
    mapping(uint256 => CollectionManager) public collectionManagerLookup;
    string public contractURI;

    constructor(string memory name, string memory symbol)
        Ownable()
        ERC721(name, symbol)
    {}


    function setContractURI(string memory contractURI_) public onlyOwner {
        contractURI = contractURI_;
    }

    function addCollectionManager(CollectionManager collectionManager)
        public
        onlyOwner
    {
        collectionManagerRegistry[collectionManager] = true;
    }

    function createCollection(uint256 collectionId) public {
        CollectionManager collectionManager = CollectionManager(msg.sender);
        require(
            collectionManagerRegistry[collectionManager],
            "NOT_COLLECTION_MANAGER"
        );
        require(
            collectionManagerLookup[collectionId] ==
                CollectionManager(address(0x0)),
            "COLLECTION_ALREADY_EXISTS"
        );
        require(collectionId < TOKEN_ID_LIMIT, "COLLECTION_ID_TOO_BIG");

        collectionManagerLookup[collectionId] = collectionManager;
    }

    function mint(
        address recipient,
        uint256 collectionId,
        uint256 seriesId,
        uint256 edition
    ) public {
        require(
            msg.sender == address(collectionManagerLookup[collectionId]),
            "NOT_COLLECTION_MANAGER"
        );
        require(edition < seriesIdMultiplier, "TOKEN_POSITION_TOO_LARGE");
        require(seriesId < collectionIdMultiplier, "SERIES_POSITION_TOO_LARGE");

        uint256 fullId = encodeTokenId(collectionId, seriesId, edition);
        return _safeMint(recipient, fullId);
    }


    function nextAvailableCollectionId() external view returns (uint256) {
        uint256 i = 0;
        while (true) {
            if (collectionManagerLookup[i] == CollectionManager(address(0x0))) {
                return i;
            }
            i++;
        }
        return 0;
    }

    function encodeTokenId(
        uint256 collectionId,
        uint256 seriesId,
        uint256 tokenPosition
    ) public pure returns (uint256) {
        return
            (collectionId + 1) *
            collectionIdMultiplier +
            (seriesId + 1) *
            seriesIdMultiplier +
            tokenPosition +
            1;
    }

    function extractEdition(uint256 tokenId) public pure returns (uint256) {
        return ((tokenId % seriesIdMultiplier)) - 1;
    }

    function extractSeriesId(uint256 tokenId) public pure returns (uint256) {
        return ((tokenId % collectionIdMultiplier) / seriesIdMultiplier) - 1;
    }

    function extractCollectionId(uint256 tokenId)
        public
        pure
        returns (uint256)
    {
        return (tokenId / collectionIdMultiplier) - 1;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        uint256 collectionId = extractCollectionId(tokenId);
        CollectionManager collectionManager =
            collectionManagerLookup[collectionId];
        return collectionManager.tokenURI(tokenId);
    }

    function tokensOfOwner(address owner)
        external
        view
        returns (uint256[] memory, string[] memory)
    {
        uint256 length = ERC721.balanceOf(owner);

        uint256[] memory tokenIds = new uint256[](length);
        string[] memory tokenURIs = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(owner, i);
            tokenIds[i] = tokenId;
            tokenURIs[i] = tokenURI(tokenId);
        }

        return (tokenIds, tokenURIs);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        return ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return ERC721Enumerable.supportsInterface(interfaceId);
    }
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
}pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


address constant ETHEREUM = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
uint256 constant PRICE_CHANGE_DENOMINATOR = 10000;

struct Series {
    uint256 id;
    uint256 limit;
    uint256 minted;
    uint256 initialPrice;
    int256 priceChange;
    uint256 currentPrice;
    uint256 nextPrice;
}

struct Collection {
    uint256 id;
    string title;
    string uriBase;
    uint256 priceChangeTime;
    uint256 initialTimestamp;
    uint256 seriesCount;
    address paymentToken;
    mapping(uint256 => Series) series;
}

struct CollectionFlat {
    uint256 id;
    string title;
    string uriBase;
    uint256 priceChangeTime;
    uint256 initialTimestamp;
    address paymentToken;
    Series[] series;
}

contract Redeem is Ownable, CollectionManager, ReentrancyGuard {
    using Strings for uint256;

    mapping(uint256 => Collection) collections;
    uint256[] public collectionIds;

    NFT public nft;

    constructor(NFT nft_) {
        nft = nft_;
    }

    function startCollectionSale(uint256 collectionId) public onlyOwner {
        require(
            collections[collectionId].initialTimestamp == 0,
            "SALE_ALREADY_STARTED"
        );
        collections[collectionId].initialTimestamp = block.timestamp;
    }

    function updateCollectionUriBase(
        uint256 collectionId,
        string memory uriBase
    ) public onlyOwner {
        collections[collectionId].uriBase = uriBase;
    }

    function updateCollectionTitle(uint256 collectionId, string memory title)
        public
        onlyOwner
    {
        collections[collectionId].title = title;
    }

    function createCollection(
        string memory name,
        string memory uriBase,
        address paymentToken,
        uint256 priceChangeTime,
        uint256[] memory initialPrices,
        uint256[] memory limits,
        int256[] memory priceChanges
    ) public onlyOwner {
        uint256 collectionId = nft.nextAvailableCollectionId();
        nft.createCollection(collectionId);
        collectionIds.push(collectionId);

        collections[collectionId].id = collectionId;
        collections[collectionId].seriesCount = limits.length;
        collections[collectionId].title = name;
        collections[collectionId].uriBase = uriBase;
        collections[collectionId].priceChangeTime = priceChangeTime;
        collections[collectionId].paymentToken = paymentToken;

        require(limits.length == initialPrices.length, "INVALID_PARAMS_LENGTH");
        require(
            priceChanges.length == initialPrices.length,
            "INVALID_PARAMS_LENGTH"
        );

        for (uint256 i = 0; i < limits.length; i++) {
            Series memory series =
                Series({
                    id: i,
                    limit: limits[i],
                    initialPrice: initialPrices[i],
                    priceChange: priceChanges[i],
                    minted: 0,
                    currentPrice: 0,
                    nextPrice: 0
                });
            collections[collectionId].series[i] = series;
        }
    }

    function getCollections() external view returns (CollectionFlat[] memory) {
        uint256 collectionCount = collectionIds.length;
        CollectionFlat[] memory collectionsFlat =
            new CollectionFlat[](collectionCount);

        for (uint256 i = 0; i < collectionCount; i++) {
            uint256 collectionId = collectionIds[i];
            Collection storage collection = collections[collectionId];
            Series[] memory series = new Series[](collection.seriesCount);
            for (uint256 j = 0; j < collection.seriesCount; j++) {
                series[j] = collection.series[j];
                series[j].currentPrice = currentPrice(collectionId, j);
                series[j].nextPrice = calculateFuturePrice(collectionId, j, 1);
            }
            collectionsFlat[i] = CollectionFlat({
                id: collection.id,
                series: series,
                title: collection.title,
                uriBase: collection.uriBase,
                priceChangeTime: collection.priceChangeTime,
                initialTimestamp: collection.initialTimestamp,
                paymentToken: collection.paymentToken
            });
        }

        return collectionsFlat;
    }

    function currentPrice(uint256 collectionId, uint256 seriesId)
        public
        view
        returns (uint256)
    {
        return calculateFuturePrice(collectionId, seriesId, 0);
    }

    function calculateFuturePrice(
        uint256 collectionId,
        uint256 seriesId,
        uint256 periods
    ) public view returns (uint256) {
        uint256 price = collections[collectionId].series[seriesId].initialPrice;
        uint256 priceChangeTime = collections[collectionId].priceChangeTime;
        int256 priceChange =
            collections[collectionId].series[seriesId].priceChange;
        uint256 initialTimestamp = collections[collectionId].initialTimestamp;
        if (initialTimestamp == 0) {
            initialTimestamp = block.timestamp;
        }

        uint256 timePassed =
            ((block.timestamp - initialTimestamp) / priceChangeTime) + periods;

        for (uint256 i = 0; i < timePassed; i++) {
            if (priceChange >= 0) {
                price +=
                    (price * uint256(priceChange)) /
                    PRICE_CHANGE_DENOMINATOR;
            } else {
                price -=
                    (price * uint256(-priceChange)) /
                    PRICE_CHANGE_DENOMINATOR;
            }
        }

        return price;
    }

    function redeem(
        uint256 collectionId,
        uint256 seriesId,
        uint256 amount
    ) public payable nonReentrant {
        require(
            collections[collectionId].initialTimestamp > 0,
            "SALE_NOT_STARTED"
        );
        require(seriesId < collections[collectionId].seriesCount, "INVALID_ID");
        uint256 limit = collections[collectionId].series[seriesId].limit;
        uint256 edition = collections[collectionId].series[seriesId].minted;
        if (limit != 0) {
            require(edition + amount <= limit, "LIMIT_REACHED");
        }
        collections[collectionId].series[seriesId].minted = edition + amount;

        uint256 price = currentPrice(collectionId, seriesId);
        uint256 cost = price * amount;

        takePayment(collections[collectionId].paymentToken, cost);

        for (uint256 i = 0; i < amount; i++) {
            nft.mint(msg.sender, collectionId, seriesId, edition + i);
        }
    }

    function takePayment(address paymentToken, uint256 amount) internal {
        if (paymentToken == ETHEREUM) {
            require(msg.value >= amount, "INSUFFICIENT_ETH_AMOUNT");
            payable(msg.sender).transfer(msg.value - amount);
        } else {
            IERC20(paymentToken).transferFrom(
                msg.sender,
                address(this),
                amount
            );
        }
    }

    function withdraw(address token) public onlyOwner {
        if (token == ETHEREUM) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            IERC20(token).transfer(
                msg.sender,
                IERC20(token).balanceOf(address(this))
            );
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        uint256 collectionId = nft.extractCollectionId(tokenId);
        uint256 seriesId = nft.extractSeriesId(tokenId);
        uint256 edition = nft.extractEdition(tokenId);

        string memory uriBase = collections[collectionId].uriBase;

        return
            string(
                abi.encodePacked(
                    uriBase,
                    "/",
                    (seriesId + 1).toString(),
                    "/",
                    (edition + 1).toString(),
                    ".json"
                )
            );
    }
}