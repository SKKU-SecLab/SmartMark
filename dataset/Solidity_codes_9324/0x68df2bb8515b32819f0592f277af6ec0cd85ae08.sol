
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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}// MIT

pragma solidity 0.8.9;

interface IGovernable {
    function governor() external view returns (address _governor);

    function transferGovernorship(address _proposedGovernor) external;
}// MIT

pragma solidity 0.8.9;


interface ICapsuleFactory is IGovernable {
    function capsuleMinter() external view returns (address);

    function createCapsuleCollection(
        string memory _name,
        string memory _symbol,
        address _tokenURIOwner,
        bool _isCollectionPrivate
    ) external payable returns (address);

    function getAllCapsuleCollections() external view returns (address[] memory);

    function getCapsuleCollectionsOf(address _owner) external view returns (address[] memory);

    function getBlacklist() external view returns (address[] memory);

    function getWhitelist() external view returns (address[] memory);

    function isCapsule(address _capsule) external view returns (bool);

    function isBlacklisted(address _user) external view returns (bool);

    function isWhitelisted(address _user) external view returns (bool);

    function taxCollector() external view returns (address);

    function VERSION() external view returns (string memory);

    function addToWhitelist(address _user) external;

    function removeFromWhitelist(address _user) external;

    function addToBlacklist(address _user) external;

    function removeFromBlacklist(address _user) external;

    function flushTaxAmount() external;

    function setCapsuleMinter(address _newCapsuleMinter) external;

    function updateCapsuleCollectionOwner(address _previousOwner, address _newOwner) external;

    function updateCapsuleCollectionTax(uint256 _newTax) external;

    function updateTaxCollector(address _newTaxCollector) external;
}// BUSL-1.1

pragma solidity 0.8.9;


contract Capsule is ERC721URIStorage, ERC721Enumerable, Ownable {
    string public VERSION;
    string public constant LICENSE = "www.capsulenft.com/license";
    ICapsuleFactory public immutable factory;
    address public tokenURIOwner;
    uint256 public counter;
    uint256 public maxId = type(uint256).max;
    bool public immutable isCollectionPrivate;

    event TokenURIOwnerUpdated(address indexed oldOwner, address indexed newOwner);
    event TokenURIUpdated(uint256 indexed tokenId, string oldTokenURI, string newTokenURI);

    constructor(
        string memory _name,
        string memory _symbol,
        address _tokenURIOwner,
        bool _isCollectionPrivate
    ) ERC721(_name, _symbol) {
        isCollectionPrivate = _isCollectionPrivate;
        factory = ICapsuleFactory(_msgSender());
        tokenURIOwner = _tokenURIOwner;
        VERSION = ICapsuleFactory(_msgSender()).VERSION();
    }

    modifier onlyMinter() {
        require(factory.capsuleMinter() == _msgSender(), "!minter");
        _;
    }

    modifier onlyTokenURIOwner() {
        require(tokenURIOwner == _msgSender(), "caller is not tokenURI owner");
        _;
    }


    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    function isCollectionLocked() public view returns (bool) {
        return counter > maxId;
    }

    function isCollectionMinter(address _account) external view returns (bool) {
        if (isCollectionPrivate) {
            return owner() == _account;
        }
        return true;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return ERC721Enumerable.supportsInterface(interfaceId);
    }


    function burn(address _account, uint256 _tokenId) external onlyMinter {
        require(ERC721.ownerOf(_tokenId) == _account, "not NFT owner");
        _burn(_tokenId);
    }

    function lockCollectionCount(uint256 _nftCount) external virtual onlyOwner {
        require(maxId == type(uint256).max, "collection is already locked");
        require(_nftCount > 0, "_nftCount is zero");
        require(_nftCount >= counter, "_nftCount is less than counter");

        maxId = _nftCount - 1;
    }

    function mint(address _account, string memory _uri) external onlyMinter {
        require(!isCollectionLocked(), "collection is locked");
        _safeMint(_account, counter);
        _setTokenURI(counter, _uri);
        counter++;
    }

    function setTokenURI(uint256 _tokenId, string memory _newTokenURI) external onlyTokenURIOwner {
        emit TokenURIUpdated(_tokenId, tokenURI(_tokenId), _newTokenURI);
        _setTokenURI(_tokenId, _newTokenURI);
    }

    function updateTokenURIOwner(address _newTokenURIOwner) external onlyTokenURIOwner {
        emit TokenURIOwnerUpdated(tokenURIOwner, _newTokenURIOwner);
        tokenURIOwner = _newTokenURIOwner;
    }

    function renounceOwnership() public override onlyOwner {
        factory.updateCapsuleCollectionOwner(_msgSender(), address(0));
        super.renounceOwnership();
    }

    function transferOwnership(address _newOwner) public override onlyOwner {
        if (_msgSender() != address(factory)) {
            factory.updateCapsuleCollectionOwner(_msgSender(), _newOwner);
        }
        super.transferOwnership(_newOwner);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        ERC721URIStorage._burn(tokenId);
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
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

pragma solidity 0.8.9;


abstract contract Governable is IGovernable, Context, Initializable {
    address public governor;
    address private proposedGovernor;

    event UpdatedGovernor(address indexed previousGovernor, address indexed proposedGovernor);

    constructor() {
        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    function __Governable_init() internal onlyInitializing {
        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    modifier onlyGovernor() {
        require(governor == _msgSender(), "not governor");
        _;
    }

    function transferGovernorship(address _proposedGovernor) external onlyGovernor {
        require(_proposedGovernor != address(0), "invalid proposed governor");
        proposedGovernor = _proposedGovernor;
    }

    function acceptGovernorship() external {
        require(proposedGovernor == _msgSender(), "not the proposed governor");
        emit UpdatedGovernor(governor, proposedGovernor);
        governor = proposedGovernor;
        proposedGovernor = address(0);
    }

    uint256[49] private __gap;
}// BUSL-1.1

pragma solidity 0.8.9;


abstract contract CapsuleFactoryStorage is ICapsuleFactory {
    uint256 public capsuleCollectionTax;
    address public taxCollector;
    address public capsuleMinter;
    address[] public capsules;

    mapping(address => bool) public isCapsule;

    mapping(address => EnumerableSet.AddressSet) internal capsulesOf;

    EnumerableSet.AddressSet internal whitelist;

    EnumerableSet.AddressSet internal blacklist;
}// BUSL-1.1
pragma solidity 0.8.9;

library Errors {
    string public constant INVALID_TOKEN_AMOUNT = "1"; // Input token amount must be greater than 0
    string public constant INVALID_TOKEN_ADDRESS = "2"; // Input token address is zero
    string public constant INVALID_TOKEN_ARRAY_LENGTH = "3"; // Invalid tokenAddresses array length. 0 < length <= 100. Max 100 elements
    string public constant INVALID_AMOUNT_ARRAY_LENGTH = "4"; // Invalid tokenAmounts array length. 0 < length <= 100. Max 100 elements
    string public constant INVALID_IDS_ARRAY_LENGTH = "5"; // Invalid tokenIds array length. 0 < length <= 100. Max 100 elements
    string public constant LENGTH_MISMATCH = "6"; // Array length must be same
    string public constant NOT_NFT_OWNER = "7"; // Caller/Minter is not NFT owner
    string public constant NOT_CAPSULE = "8"; // Provided address or caller is not a valid Capsule address
    string public constant NOT_MINTER = "9"; // Provided address or caller is not Capsule minter
    string public constant NOT_COLLECTION_MINTER = "10"; // Provided address or caller is not collection minter
    string public constant ZERO_ADDRESS = "11"; // Input/provided address is zero.
    string public constant NON_ZERO_ADDRESS = "12"; // Address under check must be 0
    string public constant SAME_AS_EXISTING = "13"; // Provided address/value is same as stored in state
    string public constant NOT_SIMPLE_CAPSULE = "14"; // Provided Capsule id is not simple Capsule
    string public constant NOT_ERC20_CAPSULE_ID = "15"; // Provided token id is not the id of single/multi ERC20 Capsule
    string public constant NOT_ERC721_CAPSULE_ID = "16"; // Provided token id is not the id of single/multi ERC721 Capsule
    string public constant ADDRESS_DOES_NOT_EXIST = "17"; // Provided address does not exist in valid address list
    string public constant ADDRESS_ALREADY_EXIST = "18"; // Provided address does exist in valid address lists
    string public constant INCORRECT_TAX_AMOUNT = "19"; // Tax amount is incorrect
    string public constant UNAUTHORIZED = "20"; // Caller is not authorized to perform this task
    string public constant BLACKLISTED = "21"; // Caller is blacklisted and can not interact with Capsule protocol
    string public constant WHITELISTED = "22"; // Caller is whitelisted
    string public constant NOT_TOKEN_URI_OWNER = "23"; // Provided address or caller is not tokenUri owner
}// BUSL-1.1

pragma solidity 0.8.9;


contract CapsuleFactory is Initializable, Governable, CapsuleFactoryStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    string public constant VERSION = "1.0.0";
    uint256 internal constant MAX_CAPSULE_CREATION_TAX = 0.1 ether;

    event AddedToWhitelist(address indexed user);
    event RemovedFromWhitelist(address indexed user);
    event AddedToBlacklist(address indexed user);
    event RemovedFromBlacklist(address indexed user);
    event FlushedTaxAmount(uint256 taxAmount);
    event CapsuleCollectionTaxUpdated(uint256 oldTax, uint256 newTax);
    event CapsuleCollectionCreated(address indexed caller, address indexed capsule);
    event CapsuleOwnerUpdated(address indexed capsule, address indexed previousOwner, address indexed newOwner);
    event TaxCollectorUpdated(address indexed oldTaxCollector, address indexed newTaxCollector);

    function initialize() external initializer {
        __Governable_init();
        capsuleCollectionTax = 0.025 ether;
        taxCollector = _msgSender();
    }


    function getAllCapsuleCollections() external view returns (address[] memory) {
        return capsules;
    }

    function getCapsuleCollectionsOf(address _owner) external view returns (address[] memory) {
        return capsulesOf[_owner].values();
    }

    function getWhitelist() external view returns (address[] memory) {
        return whitelist.values();
    }

    function getBlacklist() external view returns (address[] memory) {
        return blacklist.values();
    }

    function isBlacklisted(address _user) public view returns (bool) {
        return blacklist.contains(_user);
    }

    function isWhitelisted(address _user) public view returns (bool) {
        return whitelist.contains(_user);
    }

    function createCapsuleCollection(
        string calldata _name,
        string calldata _symbol,
        address _tokenURIOwner,
        bool _isCollectionPrivate
    ) external payable returns (address) {
        address _owner = _msgSender();
        if (!whitelist.contains(_owner)) {
            require(msg.value == capsuleCollectionTax, Errors.INCORRECT_TAX_AMOUNT);
        }
        Capsule _capsuleCollection = new Capsule(_name, _symbol, _tokenURIOwner, _isCollectionPrivate);

        address _capsuleAddress = address(_capsuleCollection);

        isCapsule[_capsuleAddress] = true;
        capsules.push(_capsuleAddress);
        capsulesOf[_owner].add(_capsuleAddress);

        emit CapsuleCollectionCreated(_owner, _capsuleAddress);
        _capsuleCollection.transferOwnership(_owner);
        return _capsuleAddress;
    }


    function flushTaxAmount() external {
        require(_msgSender() == governor || _msgSender() == taxCollector, Errors.UNAUTHORIZED);
        uint256 _taxAmount = address(this).balance;
        emit FlushedTaxAmount(_taxAmount);
        Address.sendValue(payable(taxCollector), _taxAmount);
    }

    function addToWhitelist(address _user) external onlyGovernor {
        require(_user != address(0), Errors.ZERO_ADDRESS);
        require(!isBlacklisted(_user), Errors.BLACKLISTED);
        require(whitelist.add(_user), Errors.ADDRESS_ALREADY_EXIST);
        emit AddedToWhitelist(_user);
    }

    function removeFromWhitelist(address _user) external onlyGovernor {
        require(_user != address(0), Errors.ZERO_ADDRESS);
        require(whitelist.remove(_user), Errors.ADDRESS_DOES_NOT_EXIST);
        emit RemovedFromWhitelist(_user);
    }

    function addToBlacklist(address _user) external onlyGovernor {
        require(_user != address(0), Errors.ZERO_ADDRESS);
        require(!isWhitelisted(_user), Errors.WHITELISTED);
        require(blacklist.add(_user), Errors.ADDRESS_ALREADY_EXIST);
        emit AddedToBlacklist(_user);
    }

    function removeFromBlacklist(address _user) external onlyGovernor {
        require(_user != address(0), Errors.ZERO_ADDRESS);
        require(blacklist.remove(_user), Errors.ADDRESS_DOES_NOT_EXIST);
        emit RemovedFromBlacklist(_user);
    }

    function setCapsuleMinter(address _newCapsuleMinter) external onlyGovernor {
        require(_newCapsuleMinter != address(0), Errors.ZERO_ADDRESS);
        require(capsuleMinter == address(0), Errors.NON_ZERO_ADDRESS);
        capsuleMinter = _newCapsuleMinter;
    }

    function updateCapsuleCollectionTax(uint256 _newTax) external onlyGovernor {
        require(_newTax <= MAX_CAPSULE_CREATION_TAX, Errors.INCORRECT_TAX_AMOUNT);
        require(_newTax != capsuleCollectionTax, Errors.SAME_AS_EXISTING);
        emit CapsuleCollectionTaxUpdated(capsuleCollectionTax, _newTax);
        capsuleCollectionTax = _newTax;
    }

    function updateTaxCollector(address _newTaxCollector) external onlyGovernor {
        require(_newTaxCollector != address(0), Errors.ZERO_ADDRESS);
        require(_newTaxCollector != address(taxCollector), Errors.SAME_AS_EXISTING);
        emit TaxCollectorUpdated(taxCollector, _newTaxCollector);
        taxCollector = _newTaxCollector;
    }

    function updateCapsuleCollectionOwner(address _previousOwner, address _newOwner) external {
        address _capsule = _msgSender();
        require(isCapsule[_capsule], Errors.NOT_CAPSULE);
        require(capsulesOf[_previousOwner].remove(_capsule), Errors.ADDRESS_DOES_NOT_EXIST);
        require(capsulesOf[_newOwner].add(_capsule), Errors.ADDRESS_ALREADY_EXIST);
        emit CapsuleOwnerUpdated(_capsule, _previousOwner, _newOwner);
    }
}