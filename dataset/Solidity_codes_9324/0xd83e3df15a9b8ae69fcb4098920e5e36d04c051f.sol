
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

library AddressUpgradeable {

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

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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

        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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

    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;





abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    using AddressUpgradeable for address;

    function __ERC721Enumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal initializer {
    }
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(!_msgSender().isContract(), "Contracts are not allowed big man");
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(!_msgSender().isContract(), "Contracts are not allowed big man");
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
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
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
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
    uint256[46] private __gap;
}// MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {


  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );


  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );


  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );


  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );


  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;


  function name()
    external
    view
    returns (
      string memory tokenName
    );


  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );


  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );


  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );


  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


}// MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.8.0;



abstract contract VRFConsumerBaseUpgradeable is VRFRequestIDBase, Initializable {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 private USER_SEED_PLACEHOLDER;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal LINK;
  address private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  function __VRFConsumerBase_init(address _vrfCoordinator, address _link) internal initializer {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
    USER_SEED_PLACEHOLDER = 0;
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

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

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

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



abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}// MIT

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}// MIT LICENSE

pragma solidity ^0.8.7;




interface ISalmon {
  function burn(address from, uint256 amount) external;
}

interface ITraits {
  function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IRoar {
  struct ManBear {bool isFisherman; uint8[14] traitarray; uint8 alphaIndex;}
  function getPaidTokens() external view returns (uint256);
  function getTokenTraits(uint256 tokenId) external view returns (ManBear memory);
}

interface IRiver {
  function addManyToRiverSideAndFishing(address account, uint16[] calldata tokenIds) external;
  function randomBearOwner(uint256 seed) external view returns (address);
}

contract RoarGenX is IRoar, ERC721Enumerable, Ownable, Pausable, VRFConsumerBase {
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet; 


  uint256 public immutable MAX_TOKENS;                                   // max number of tokens that can be minted - 50000 in production
  uint256 public PAID_TOKENS;                                            // number of tokens that can be claimed for free - 20% of MAX_TOKENS
  uint16 public minted;                                                  // number of tokens have been minted so far
  uint256 public constant MINT_PRICE = .069420 ether;                    // mint price
      

  
  string public baseURI;

  mapping(address => uint256) public whitelists;
  mapping(uint256 => ManBear) public tokenTraits;                       // mapping from tokenId to a struct containing the token's traits
  mapping(uint256 => uint256) public existingCombinations;              // mapping from hashed(tokenTrait) to the tokenId it's associated with, Why? used to ensure there are no duplicates
  mapping(address => uint256[]) public _mints;



  uint8[][18] public rarities;
  uint8[][18] public aliases;


  IRiver public river;                                                       // STAKING - reference to the Barn for choosing random Bear thieves
  ISalmon public salmon;                                                       // TOKEN - reference to $WOOL for burning on mint
  ITraits public traits;                                                    // TRAITS - reference to Traits


  address private project_wallet = 0x06e8198A5a4AB3E5F4B13DdC9e5c2FCDDD4f8838; 
	address private Bear1 = 0x9E4FaAA4EFd0fb8CbC653Ee68C01c066d078098D; 
	address private Bear2 = 0xe18195D4995D994fAa3663db0b6E2FFF4042D0a1; 
	address private Bear3 = 0x9c39cD2f557B5E851f44ab18714BbBB15FA7417E; 
  address private Bear4 = 0x24af21668F33C8C279025b0E53fCC3bFf48426A0; 
  

  bytes32 internal keyHash;
  uint256 public fee;
  uint256 internal randomResult;
  uint256 internal randomNumber;
  address public linkToken;
  uint256 public vrfcooldown = 10000;
  Counters.Counter public vrfReqd;




  constructor(address _salmon, uint256 _maxTokens, address _vrfCoordinator, address _link) 
      ERC721("BearGame", 'BEARGAME') 
      VRFConsumerBase(_vrfCoordinator, _link)  

  { 


    keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
    fee = 2 * 10 ** 18; // 0.1 LINK (Varies by network)
    linkToken = _link;
    
  


    salmon = ISalmon(_salmon);

    
    MAX_TOKENS = _maxTokens;
    PAID_TOKENS = _maxTokens / 5;


    rarities[0] = [31,49,51,69,113,187,204,207,225]; 
    rarities[1] = [35,48,67,115,189,208,221];
    rarities[2] = [59,97,136,159,197];
    rarities[3] = [85,113,131,143,169];
    rarities[4] = [255,255,255,255];
    rarities[5] = [34,59,118,164,197,222];
    rarities[6] = [59,111,145,197];
    rarities[7] = [57,93,163,199];
    rarities[8] = [255];

    aliases[0] = [8,7,6,5,4,3,2,1,0];
    aliases[1] = [6,5,4,3,2,1,0];
    aliases[2] = [4,3,2,1,0];
    aliases[3] = [4,3,2,1,0];
    aliases[4] = [3,2,1,0];
    aliases[5] = [5,4,3,2,1,0];
    aliases[6] = [3,2,1,0];
    aliases[7] = [3,2,1,0];
    aliases[8] = [0];

    rarities[9] = [255,255,255,255,255];
    rarities[10] = [39,51,59,67,125,131,189,197,204,217];
    rarities[11] = [51,54,57,64,72,90,194,199,202,207,212];
    rarities[12] = [48,60,96,160,196,208];
    rarities[13] = [51,102,153,204];

    aliases[9] = [0,1,2,3,4];
    aliases[10] = [9,8,7,6,5,4,3,2,1,0];
    aliases[11] = [10,9,8,7,6,5,4,3,2,1,0];
    aliases[12] = [5,4,3,2,1,0];
    aliases[13] = [3,2,1,0];
    

  }


      
    
  function mintCost(uint256 tokenId) public view returns (uint256) {
    if (tokenId <= PAID_TOKENS) return 0;                           // the first 20% are paid in ETH, Hence 0 $SALMON
    if (tokenId <= MAX_TOKENS * 2 / 5) return 20000 ether;          // the next 20% are 20000 $SALMON
    if (tokenId <= MAX_TOKENS * 4 / 5) return 40000 ether;          // the next 40% are 40000 $SALMON
    return 80000 ether;                                             // the final 20% are 80000 $SALMON
  }

  function mint(uint256 amount, bool stake) external payable whenNotPaused {

    address msgSender = _msgSender();

    require(tx.origin == msgSender, "Only EOA");
    require(minted + amount <= MAX_TOKENS, "All tokens minted");
    require(amount > 0 && amount <= 10, "Invalid mint amount");
    
    if (minted < PAID_TOKENS) {


      uint256 mintCostEther = MINT_PRICE * amount;
      if (whitelists[msgSender] == 1) {
          mintCostEther = ( amount - 1) * MINT_PRICE;
          whitelists[msgSender] = 0;
      }
    
      require(minted + amount <= PAID_TOKENS, "All tokens on-sale already sold");
      require(mintCostEther == msg.value, "Invalid payment amount");


    } else {

      require(msg.value == 0);

    }

    uint256 totalSalmonCost = 0;                                                          // $SALMON Cost to mint. 0 is Gen0
    uint16[] memory tokenIds = stake ? new uint16[](amount) : new uint16[](0);          
    uint256 seed;

    for (uint i = 0; i < amount; i++) {
      minted++;
      seed = random(minted);                                                             // NOTES: SUS
      generate(minted, seed);                                                            // Generates Token Traits and adds it to the array
      address recipient = selectRecipient(seed);                                         // Selects who the NFT is going to. Gen0 always will be minter. 
      if (!stake || recipient != msgSender) {                                            // recipient != _msgSender() -- IF I BAN CONTRACT, SHIT MIGHT BE GOOOOOFY
        _safeMint(recipient, minted);
      } else {
        _safeMint(address(river), minted);
        tokenIds[i] = minted;
      }
      totalSalmonCost += mintCost(minted);
    }
    
    if (totalSalmonCost > 0) salmon.burn(msgSender, totalSalmonCost);
    if (stake) river.addManyToRiverSideAndFishing(msgSender, tokenIds);
  }





  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    if (_msgSender() != address(river))
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    _transfer(from, to, tokenId);
  }




  function generate(uint256 tokenId, uint256 seed) internal returns (ManBear memory t) {
    getRandomChainlink();
    t = selectTraits(seed);
    if (existingCombinations[structToHash(t.isFisherman, t.traitarray, t.alphaIndex)] == 0) {
      tokenTraits[tokenId] = t;
      existingCombinations[structToHash(t.isFisherman, t.traitarray, t.alphaIndex)] = tokenId;
      return t;
    }
    return generate(tokenId, random(seed));
  }

  function selectTrait(uint16 seed, uint8 traitType) internal view returns (uint8) {

    uint8 trait = uint8(seed) % uint8(rarities[traitType].length);           
    if (seed >> 8 < rarities[traitType][trait]) return trait;                 
    return aliases[traitType][trait];

  }


  function selectTraits(uint256 seed) internal view returns (ManBear memory t) {    
    t.isFisherman = (seed & 0xFFFF) % 10 != 0;
    uint8 shift = t.isFisherman ? 0 : 9;                                          // 0 if its a Fisherman, 9 if its Bear

    seed >>= 16;
    if (t.isFisherman) {



      t.traitarray[0] = selectTrait(uint16(seed & 0xFFFF), 0 + shift);
      seed >>= 16;
      t.traitarray[1] = selectTrait(uint16(seed & 0xFFFF), 1 + shift);
      seed >>= 16;
      t.traitarray[2] = selectTrait(uint16(seed & 0xFFFF), 2 + shift);
      seed >>= 16;
      t.traitarray[3] = selectTrait(uint16(seed & 0xFFFF), 3 + shift);
      seed >>= 16;
      t.traitarray[4] = selectTrait(uint16(seed & 0xFFFF), 4 + shift);
      seed >>= 16;
      t.traitarray[5] = selectTrait(uint16(seed & 0xFFFF), 5 + shift);
      seed >>= 16;
      t.traitarray[6] = selectTrait(uint16(seed & 0xFFFF), 6 + shift);
      seed >>= 16;
      t.traitarray[7] = selectTrait(uint16(seed & 0xFFFF), 7 + shift);
      seed >>= 16;
      t.traitarray[8] = selectTrait(uint16(seed & 0xFFFF), 8 + shift);

      t.alphaIndex = 0;




    } else {

      t.traitarray[9] = selectTrait(uint16(seed & 0xFFFF), 0 + shift);
      seed >>= 16;
      t.traitarray[10] = selectTrait(uint16(seed & 0xFFFF), 1 + shift);
      seed >>= 16;
      t.traitarray[11] = selectTrait(uint16(seed & 0xFFFF), 2 + shift);
      seed >>= 16;
      t.traitarray[12] = selectTrait(uint16(seed & 0xFFFF), 3 + shift);
      seed >>= 16;
      t.traitarray[13] = selectTrait(uint16(seed & 0xFFFF), 4 + shift);

      t.alphaIndex = t.traitarray[13];
      
      
    }

  }


function structToHash(bool isFisherman, uint8[14] memory traitarray, uint8 alphaIndex) internal pure returns (uint256) {
    if(isFisherman){
      return uint256(bytes32(abi.encodePacked(true,
        traitarray[0],
        traitarray[1],
        traitarray[2],
        traitarray[3],
        traitarray[4],
        traitarray[5],
        traitarray[6],
        traitarray[7],
        traitarray[8],
        "0",
        "0",
        "0",
        "0",
        "0",
        alphaIndex)));
    }
    else{
      return uint256(bytes32(abi.encodePacked(false,
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        traitarray[9],
        traitarray[10],
        traitarray[11],
        traitarray[12],
        traitarray[13],
        alphaIndex)));
    }
    
  }
  function selectRecipient(uint256 seed) internal view returns (address) {
    if (minted <= PAID_TOKENS || ((seed >> 245) % 10) != 0) return _msgSender();                 // top 10 bits haven't been used
    address thief = river.randomBearOwner(seed >> 144);                                          // 144 bits reserved for trait selection
    if (thief == address(0x0)) return _msgSender();
    return thief;
  }



  function getTokenTraits(uint256 tokenId) external view override returns (ManBear memory) {
    return tokenTraits[tokenId];
  }

  function getPaidTokens() external view override returns (uint256) {
    return PAID_TOKENS;
  }


  function setRiver(address _river) external onlyOwner {
    river = IRiver(_river);
    getRandomChainlink();
  }

  function setInit(address _river, address erc20Address, address _traits ) public onlyOwner {
    river = IRiver(_river);
    salmon = ISalmon(erc20Address);
    traits = ITraits(_traits);
    getRandomChainlink();
  }
  
  function setURI(string memory _newBaseURI) external onlyOwner {
		  baseURI = _newBaseURI;
  }

  function withdraw() public payable onlyOwner {

    uint256 _project = (address(this).balance * 10) / 100;        
    uint256 _bear1 = (address(this).balance * 225) / 1000;  
    uint256 _bear2 = (address(this).balance * 225) / 1000;  
    uint256 _bear3 = (address(this).balance * 225) / 1000;  
    uint256 _bear4 = (address(this).balance * 225) / 1000;  

		payable(project_wallet).transfer(_project);
    payable(Bear1).transfer(_bear1);
		payable(Bear2).transfer(_bear2);
    payable(Bear3).transfer(_bear3);
		payable(Bear4).transfer(_bear4);

  }



  function setPaidTokens(uint256 _paidTokens) external onlyOwner {
    PAID_TOKENS = _paidTokens;
  }


  function setPaused(bool _paused) external onlyOwner {
    if (_paused) _pause();
    else _unpause();
  }


  function addWhitelist(address[] calldata addressArrays) external onlyOwner {

    uint256 addylength = addressArrays.length;

    for (uint256 i; i < addylength; i++ ){

          whitelists[addressArrays[i]] = 1;
    }
  }





  function setBaseURI(string memory newUri) public onlyOwner {
      baseURI = newUri;
  }


  function _baseURI() internal view virtual override returns (string memory) {
      return baseURI;
  }


  function getTokenIds(address _owner) public view returns (uint256[] memory _tokensOfOwner) {
        _tokensOfOwner = new uint256[](balanceOf(_owner));
        for (uint256 i;i<balanceOf(_owner);i++){
            _tokensOfOwner[i] = tokenOfOwnerByIndex(_owner, i);
        }
  }


      

  function random(uint256 seed) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(
      tx.origin,
      blockhash(block.number - 1),
      block.timestamp,
      seed,
      randomNumber
    )));
  }

  function changeLinkFee(uint256 _fee) external onlyOwner {
    fee = _fee;
  }

  function initChainLink() external onlyOwner {
      getRandomChainlink();
  }

  function getRandomChainlink() internal returns (bytes32 requestId) {

    if (vrfReqd.current() <= vrfcooldown) {
      vrfReqd.increment();
      return 0x000;
    }

    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    vrfReqd.reset();
    return requestRandomness(keyHash, fee);
  }

  function changeVrfCooldown(uint256 _cooldown) external onlyOwner{
      vrfcooldown = _cooldown;
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
      bytes32 reqId = requestId;
      randomNumber = randomness;
  }

  function withdrawLINK() external onlyOwner {
    uint256 tokenSupply = IERC20(linkToken).balanceOf(address(this));
    IERC20(linkToken).transfer(msg.sender, tokenSupply);
  }


}// MIT LICENSE

pragma solidity ^0.8.0;





interface ITSalmon {
  function mint(address to, uint256 amount) external;
}

contract RiverGenX is Ownable, IERC721Receiver, Pausable, VRFConsumerBase,ReentrancyGuard {
  using Address for address;
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet; 

                             
  struct Stake {
    uint16 tokenId;
    uint80 value;
    address owner;
  }


  RoarGenX roar;                                                                 // reference to the RoarGenX NFT contract
  ITSalmon salmon;                                                           // reference to the $SALMON contract for minting $SALMON earnings



  event TokenStaked(address owner, uint256 tokenId, uint256 value);
  event FishermanClaimed(uint256 tokenId, uint256 earned, bool unstaked);
  event BearClaimed(uint256 tokenId, uint256 earned, bool unstaked);


  mapping(uint256 => Stake) public riverside;                                 // maps tokenId to stake
  mapping(uint256 => Stake[]) public Bears;                                   // maps alpha to all Bear stakes with that alpha
  mapping(address => EnumerableSet.UintSet) private _deposits;
  mapping(uint256 => uint256) public packIndices;                             // tracks location of each Bear in Pack
  
  
  uint256 public totalAlphaStaked = 0;                                    // total alpha scores staked
  uint256 public unaccountedRewards = 0;                                  // any rewards distributed when no bears are staked
  uint256 public SalmonPerAlpha = 0;                                      // amount of $SALMON due for each alpha point staked


  uint256 public  DAILY_SALMON_RATE = 10000 ether;                        // Fisherman earn 10000 $SALMON per day
  uint256 public  MINIMUM_TO_EXIT = 2 days;                               // Fisherman must have 2 days worth of $SALMON to unstake or else it's too cold
  
  uint256 public  constant SALMON_CLAIM_TAX_PERCENTAGE = 20;              // Bears take a 20% tax on all $SALMON claimed
  uint256 public  constant MAXIMUM_GLOBAL_WOOL = 2400000000 ether;        // there will only ever be (roughly) 2.4 billion $SALMON earned through staking
  uint8   public  constant MAX_ALPHA = 8; 


  uint256 public totalSalmonEarned;                                       // amount of $SALMON earned so far
  uint256 public totalFishermanStaked;                                    // number of Fisherman staked in the Riverside
  uint256 public lastClaimTimestamp;                                      // the last time $SALMON was claimed

  bool public rescueEnabled = false;                                    // emergency rescue to allow unstaking without any checks but without $SALMON


  bytes32 internal keyHash;
  uint256 public fee;
  uint256 internal randomResult;
  uint256 internal randomNumber;
  address public linkToken;
  uint256 public vrfcooldown = 10000;
  Counters.Counter public vrfReqd;


  constructor(address _roar, address _salmon, address _vrfCoordinator, address _link) 
      VRFConsumerBase(_vrfCoordinator, _link)
  { 
    roar = RoarGenX(_roar);                                                    // reference to the RoarGenX NFT contract
    salmon = ITSalmon(_salmon);                                                //reference to the $SALMON token

    keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
    fee = 2 * 10 ** 18; // 0.1 LINK (Varies by network)
    linkToken = _link;





  }

  function depositsOf(address account) external view returns (uint256[] memory) {
    EnumerableSet.UintSet storage depositSet = _deposits[account];
    uint256[] memory tokenIds = new uint256[] (depositSet.length());

    for (uint256 i; i < depositSet.length(); i++) {
      tokenIds[i] = depositSet.at(i);
    }

    return tokenIds;
  }


  function addManyToRiverSideAndFishing(address account, uint16[] calldata tokenIds) external {    // called in mint

    require(account == _msgSender() || _msgSender() == address(roar), "DONT GIVE YOUR TOKENS AWAY");    /// SEE IF I CAN ADD THE MF CONTRACT BAN

    for (uint i = 0; i < tokenIds.length; i++) {
      if (_msgSender() != address(roar)) { // dont do this step if its a mint + stake


        require(roar.ownerOf(tokenIds[i]) == _msgSender(), "AINT YO TOKEN");
        roar.transferFrom(_msgSender(), address(this), tokenIds[i]);
        

      } else if (tokenIds[i] == 0) {

        continue; // there may be gaps in the array for stolen tokens
      }

      if (isFisherman(tokenIds[i])) 
        _addFishermanToRiverside(account, tokenIds[i]);
        
      else 
        _sendBearsFishing(account, tokenIds[i]);
    }
  }



  function _addFishermanToRiverside(address account, uint256 tokenId) internal whenNotPaused _updateEarnings {
    riverside[tokenId] = Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(block.timestamp)
    });
    totalFishermanStaked += 1;
   
    emit TokenStaked(account, tokenId, block.timestamp);
    _deposits[account].add(tokenId);
  }

  function _sendBearsFishing(address account, uint256 tokenId) internal {
    uint256 alpha = _alphaForBear(tokenId);
    totalAlphaStaked += alpha;                                                // Portion of earnings ranges from 8 to 5
    packIndices[tokenId] = Bears[alpha].length;                                // Store the location of the Bear in the Pack
    Bears[alpha].push(Stake({                                                  // Add the Bear to the Pack
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(SalmonPerAlpha)
    })); 
    emit TokenStaked(account, tokenId, SalmonPerAlpha);
    _deposits[account].add(tokenId);
  }


  function claimManyFromRiverAndFishing(uint16[] calldata tokenIds, bool unstake) external whenNotPaused _updateEarnings nonReentrant() {

    require(!_msgSender().isContract(), "Contracts are not allowed big man");
    
    uint256  owed = 0;
    
    for (uint i = 0; i < tokenIds.length; i++) {
      if (isFisherman(tokenIds[i]))
        owed += _claimFisherFromRiver(tokenIds[i], unstake);
      else
        owed += _claimBearFromFishing(tokenIds[i], unstake);
    }
    if (owed == 0) return;
    salmon.mint(_msgSender(), owed);


  }


  function calculateReward(uint16[] calldata tokenIds) public view returns (uint256 owed) {

    for (uint i = 0; i < tokenIds.length; i++) {
      if (isFisherman(tokenIds[i]))
        owed += calcRewardFisherman(tokenIds[i]);
      else
        owed +=  calcRewardBear(tokenIds[i]);
    }
  
  }


  function calcRewardFisherman(uint256 tokenId) public view returns (uint256 owed) {

    Stake memory stake = riverside[tokenId];

    if (totalSalmonEarned < MAXIMUM_GLOBAL_WOOL) {
        owed = (block.timestamp - stake.value) * DAILY_SALMON_RATE / 1 days;

    } else if (stake.value > lastClaimTimestamp) {
        owed = 0; // $WOOL production stopped already

    } else {
        owed = (lastClaimTimestamp - stake.value) * DAILY_SALMON_RATE / 1 days; // stop earning additional $WOOL if it's all been earned
    }


  }


  function calcRewardBear(uint256 tokenId) public view returns (uint256 owed) {

    uint256 alpha = _alphaForBear(tokenId);  
    Stake memory stake = Bears[alpha][packIndices[tokenId]];
    owed = (alpha) * (SalmonPerAlpha - stake.value); 

  }

  function _claimFisherFromRiver(uint256 tokenId, bool unstake) internal returns (uint256 owed) {

    Stake memory stake = riverside[tokenId];

    require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
    require(!(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT), "GONNA BE COLD WITHOUT TWO DAY'S WOOL");

    owed = calcRewardFisherman(tokenId);

    if (unstake) {
      getRandomChainlink();
      
      if (random(tokenId) & 1 == 1) {                                           // 50% chance of all $SALMON stolen
        _payBearTax(owed);
        owed = 0;  
      }
      
      delete riverside[tokenId];
      totalFishermanStaked -= 1;
      _deposits[_msgSender()].remove(tokenId);
      roar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman        


    } else {

      _payBearTax(owed * SALMON_CLAIM_TAX_PERCENTAGE / 100);                    // percentage tax to staked Bears    
      riverside[tokenId] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(block.timestamp)
      }); // reset stake
      owed = owed * (100 - SALMON_CLAIM_TAX_PERCENTAGE) / 100;                  // remainder goes to Fisherman owner
    }
    emit FishermanClaimed(tokenId, owed, unstake);
  }


  function _claimBearFromFishing(uint256 tokenId, bool unstake) internal returns (uint256 owed) {

    uint256 alpha = _alphaForBear(tokenId);  
    Stake memory stake = Bears[alpha][packIndices[tokenId]];

    require(roar.ownerOf(tokenId) == address(this), "AINT A PART OF THE PACK");                
    require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");

    owed = calcRewardBear(tokenId);                                         // Calculate portion of tokens based on Alpha

    if (unstake) {
      totalAlphaStaked -= alpha;                                            // Remove Alpha from total staked
      Stake memory lastStake = Bears[alpha][Bears[alpha].length - 1];         // Shuffle last Bear to current position PT 1 
      Bears[alpha][packIndices[tokenId]] = lastStake;                        // Shuffle last Bear to current position PT 2
      packIndices[lastStake.tokenId] = packIndices[tokenId];                // Shuffle last Bear to current position PT 3
      Bears[alpha].pop();                                                    // Remove duplicate

      delete packIndices[tokenId];                                          // Delete old mapping
      _deposits[_msgSender()].remove(tokenId);
      roar.safeTransferFrom(address(this), _msgSender(), tokenId, "");     // Send back Bear        


    } else {

      Bears[alpha][packIndices[tokenId]] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(SalmonPerAlpha)
      }); // reset stake

    }
    emit BearClaimed(tokenId, owed, unstake);
  }



  function rescue(uint256[] calldata tokenIds) external nonReentrant() {
    require(!_msgSender().isContract(), "Contracts are not allowed big man");
    require(rescueEnabled, "RESCUE DISABLED");

    uint256 tokenId;
    Stake memory stake;
    Stake memory lastStake;
    uint256 alpha;

    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      if (isFisherman(tokenId)) {
        stake = riverside[tokenId];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        delete riverside[tokenId];
        totalFishermanStaked -= 1;
        roar.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back Fisherman
        emit FishermanClaimed(tokenId, 0, true);
      } else {
        alpha = _alphaForBear(tokenId);
        stake = Bears[alpha][packIndices[tokenId]];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        totalAlphaStaked -= alpha; // Remove Alpha from total staked
        lastStake = Bears[alpha][Bears[alpha].length - 1];
        Bears[alpha][packIndices[tokenId]] = lastStake; // Shuffle last bear to current position
        packIndices[lastStake.tokenId] = packIndices[tokenId];
        Bears[alpha].pop(); // Remove duplicate
        delete packIndices[tokenId]; // Delete old mapping
        roar.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // Send back Fisherman
        emit BearClaimed(tokenId, 0, true);
      }
    }
  }


  function _payBearTax(uint256 amount) internal {

    if (totalAlphaStaked == 0) {                                              // if there's no staked Bear > keep track of $SALMON due to Bear
      unaccountedRewards += amount; 
      return;
    }

    SalmonPerAlpha += (amount + unaccountedRewards) / totalAlphaStaked;         // makes sure to include any unaccounted $SALMON
    unaccountedRewards = 0;
  }

  modifier _updateEarnings() {

    if (totalSalmonEarned < MAXIMUM_GLOBAL_WOOL) {
      totalSalmonEarned += 
        (block.timestamp - lastClaimTimestamp)
        * totalFishermanStaked
        * DAILY_SALMON_RATE / 1 days; 
      lastClaimTimestamp = block.timestamp;
    }
    _;
  }


  function isFisherman(uint256 tokenId) public view returns (bool fisherman) {
    (fisherman,  ) = roar.tokenTraits(tokenId);


  }

  function _alphaForBear(uint256 tokenId) public view returns (uint8) {
    ( ,uint8 alphaIndex) = roar.tokenTraits(tokenId);

    return MAX_ALPHA - alphaIndex; // alpha index is 0-3
  }


  function randomBearOwner(uint256 seed) external view returns (address) {
    if (totalAlphaStaked == 0) return address(0x0);

    uint256 bucket = (seed & 0xFFFFFFFF) % totalAlphaStaked;                  // choose a value from 0 to total alpha staked
    uint256 cumulative;
    seed >>= 32;

    for (uint i = MAX_ALPHA - 3; i <= MAX_ALPHA; i++) {                     // loop through each bucket of Bears with the same alpha score
      cumulative += Bears[i].length * i;
      if (bucket >= cumulative) continue;                                   // if the value is not inside of that bucket, keep going

      return Bears[i][seed % Bears[i].length].owner;                          // get the address of a random Bear with that alpha score
    }

    return address(0x0);
  }



  function setInit(address _roar, address _salmon) external onlyOwner{
    roar = RoarGenX(_roar);                                              // reference to the RoarGenX NFT contract
    salmon = ITSalmon(_salmon);                                                //reference to the $SALMON token

  }

  function changeDailyRate(uint256 _newRate) external onlyOwner{
      DAILY_SALMON_RATE = _newRate;
  }

  function changeMinExit(uint256 _newExit) external onlyOwner{
      _newExit = _newExit ;
  }

  function setRescueEnabled(bool _enabled) external onlyOwner {
    rescueEnabled = _enabled;
  }

  function setPaused(bool _paused) external onlyOwner {
    if (_paused) _pause();
    else _unpause();
  }
  
        

  function changeLinkFee(uint256 _fee) external onlyOwner {
    fee = _fee;
  }

  function random(uint256 seed) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(
      tx.origin,
      blockhash(block.number - 1),
      block.timestamp,
      seed,
      randomNumber
    )));
  }

  function initChainLink() external onlyOwner {
      getRandomChainlink();
  }

  function getRandomChainlink() internal returns (bytes32 requestId) {

    if (vrfReqd.current() <= vrfcooldown) {
      vrfReqd.increment();
      return 0x000;
    }

    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    vrfReqd.reset();
    return requestRandomness(keyHash, fee);
  }

  function changeVrfCooldown(uint256 _cooldown) external onlyOwner{
      vrfcooldown = _cooldown;
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
      bytes32 reqId = requestId;
      randomNumber = randomness;
  }

  function withdrawLINK() external onlyOwner {
    uint256 tokenSupply = IERC20(linkToken).balanceOf(address(this));
    IERC20(linkToken).transfer(msg.sender, tokenSupply);
  }
   
   


  function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {

    require(from == address(0x0), "Cannot send tokens to Barn directly");
    return IERC721Receiver.onERC721Received.selector;

  }




  
}// MIT LICENSE

pragma solidity ^0.8.0;















interface Roar {
  struct ManBear {bool isFisherman; uint8[14] traitarray; uint8 alphaIndex;}
  function getPaidTokens() external view returns (uint256);
  function getTokenTraits(uint256 tokenId) external view returns (ManBear memory);
  function ownerOf(uint256 tokenId) external view returns (address);
  function safeTransferFrom(address from,address to,uint256 tokenId) external; 
  function transferFrom(address from, address to, uint256 tokenId) external;
  function safeTransferFrom(address from,address to,uint256 tokenId,  bytes memory _data) external; 
  function transferFrom(address from, address to, uint256 tokenId,  bytes memory _data) external;
}


interface GenXInterface {
  struct ManBear {bool isFisherman; uint8[14] traitarray; uint8 alphaIndex;}
  function getPaidTokens() external view returns (uint256);
  function getTokenTraits(uint256 tokenId) external view returns (ManBear memory);
  function ownerOf(uint256 tokenId) external view returns (address);
  function safeTransferFrom(address from,address to,uint256 tokenId) external; 
  function transferFrom(address from, address to, uint256 tokenId) external;
  function safeTransferFrom(address from,address to,uint256 tokenId,  bytes memory _data) external; 
  function transferFrom(address from, address to, uint256 tokenId,  bytes memory _data) external;
}




contract RiverSide is OwnableUpgradeable, IERC721ReceiverUpgradeable, PausableUpgradeable, VRFConsumerBaseUpgradeable, ReentrancyGuardUpgradeable {
  using AddressUpgradeable for address;
  using CountersUpgradeable for CountersUpgradeable.Counter;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet; 

                             
  struct Stake {
    uint16 tokenId;
    uint80 value;
    address owner;
  }


  Roar roar;                                                                 // reference to the Roar NFT contract
  ITSalmon salmon;                                                           // reference to the $SALMON contract for minting $SALMON earnings



  event TokenStaked(address owner, uint256 tokenId, uint256 value);
  event FishermanClaimed(uint256 tokenId, uint256 earned, bool unstaked);
  event BearClaimed(uint256 tokenId, uint256 earned, bool unstaked);

  mapping (address => bool) whitelistedContracts;      
  mapping(uint256 => Stake) public riverside;                                 // maps tokenId to stake
  mapping(uint256 => Stake[]) public Bears;                                   // maps alpha to all Bear stakes with that alpha
  mapping(address => EnumerableSetUpgradeable.UintSet) private _deposits;
  mapping(uint256 => uint256) public packIndices;                             // tracks location of each Bear in Pack
  
  
  uint256 public totalAlphaStaked;                                  // total alpha scores staked
  uint256 public unaccountedRewards;                                  // any rewards distributed when no bears are staked
  uint256 public SalmonPerAlpha;                                      // amount of $SALMON due for each alpha point staked


  uint256 public  DAILY_SALMON_RATE ;                       // Fisherman earn 10000 $SALMON per day
  uint256 public  MINIMUM_TO_EXIT;                         // Fisherman must have 2 days worth of $SALMON to unstake or else it's too cold
  
  uint256 public  SALMON_CLAIM_TAX_PERCENTAGE;              // Bears take a 20% tax on all $SALMON claimed
  uint256 public  MAXIMUM_GLOBAL_SALMON;        // there will only ever be (roughly) 2.4 billion $SALMON earned through staking
  uint8   public  MAX_ALPHA; 
  struct ManBear {bool isFisherman; uint8[14] traitarray; uint8 alphaIndex;}

  uint256 public totalSalmonEarned;                                       // amount of $SALMON earned so far
  uint256 public totalFishermanStaked;                                    // number of Fisherman staked in the Riverside
  uint256 public lastClaimTimestamp;                                      // the last time $SALMON was claimed

  bool public rescueEnabled;                                    // emergency rescue to allow unstaking without any checks but without $SALMON


  bytes32 internal keyHash;
  uint256 public fee;
  uint256 internal randomResult;
  uint256 internal randomNumber;
  address public linkToken;
  uint256 public vrfcooldown;
  CountersUpgradeable.Counter public vrfReqd;



  function initialize(address _roar, address _salmon, address _vrfCoordinator, address _link) initializer public {

    __Ownable_init();
    __ReentrancyGuard_init();
    __Pausable_init();
    __VRFConsumerBase_init(_vrfCoordinator,_link);

    roar = Roar(_roar);                                                    // reference to the Roar NFT contract
    salmon = ITSalmon(_salmon);                                                //reference to the $SALMON token

    keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    linkToken = _link;
    vrfcooldown = 1000;


    totalAlphaStaked = 0;                                    
    unaccountedRewards = 0;                                  
    SalmonPerAlpha = 0;  


    MAXIMUM_GLOBAL_SALMON = 2400000000 ether; 
    MAX_ALPHA = 8; 



    DAILY_SALMON_RATE = 6000 ether;                        // Fisherman earn 10000 $SALMON per day
    MINIMUM_TO_EXIT = 2 days;                               // Fisherman must have 2 days worth of $SALMON to unstake or else it's too cold
    SALMON_CLAIM_TAX_PERCENTAGE = 20; 
    

    rescueEnabled = false; 



  }



  function depositsOf(address account) external view returns (uint256[] memory) {
    if (tx.origin != msg.sender) {
          require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }

    EnumerableSetUpgradeable.UintSet storage depositSet = _deposits[account];
    uint256[] memory tokenIds = new uint256[] (depositSet.length());

    for (uint256 i; i < depositSet.length(); i++) {
      tokenIds[i] = depositSet.at(i);
    }

    return tokenIds;
  }

  function addManyToRiverSideAndFishing(address account, uint16[] calldata tokenIds) external {    // called in mint

    require(account == _msgSender() || _msgSender() == address(roar), "DONT GIVE YOUR TOKENS AWAY");    

    for (uint i = 0; i < tokenIds.length; i++) {
      uint16 tokenID = tokenIds[i];

      if (_msgSender() != address(roar)) {

        if (tokenID > 10498) {

          require(roar.ownerOf(tokenID) == _msgSender(), "AINT YO TOKEN");
          roar.transferFrom(_msgSender(), address(this), tokenID);

        } else {

          require(genXRoar.ownerOf(tokenID) == _msgSender(), "AINT YO TOKEN");
          genXRoar.transferFrom(_msgSender(), address(this), tokenID);    // Needs Approval

        }
      
      } else if (tokenID == 0) {

        continue; 
      }

      if (isFisherman(tokenID)) 
        _addFishermanToRiverside(account, tokenID);
        
      else 
        _sendBearsFishing(account, tokenID);
    }
  }


  function _addFishermanToRiverside(address account, uint256 tokenId) internal whenNotPaused _updateEarnings {
    riverside[tokenId] = Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(block.timestamp)
    });
    totalFishermanStaked += 1;
   
    emit TokenStaked(account, tokenId, block.timestamp);
    _deposits[account].add(tokenId);
  }

  function _sendBearsFishing(address account, uint256 tokenId) internal {
    uint256 alpha = _alphaForBear(tokenId);
    totalAlphaStaked += alpha;                                                // Portion of earnings ranges from 8 to 5
    packIndices[tokenId] = Bears[alpha].length;                                // Store the location of the Bear in the Pack
    Bears[alpha].push(Stake({                                                  // Add the Bear to the Pack
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(SalmonPerAlpha)
    })); 
    emit TokenStaked(account, tokenId, SalmonPerAlpha);
    _deposits[account].add(tokenId);
  }



  function claimManyFromRiverAndFishing(uint16[] calldata tokenIds, bool unstake) external whenNotPaused _updateEarnings nonReentrant() {
    require(backupclaimethod,"Method Not enabled");
    require(!_msgSender().isContract(), "Contracts are not allowed big man");
    require(tx.origin == _msgSender(), "Only EOA");

    if (tx.origin != msg.sender) {
        require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }
    
    uint256  owed = 0;
    
    for (uint i = 0; i < tokenIds.length; i++) {
      uint16 tokenID = tokenIds[i];
      
      if (tokenID > 10498) 
        require(roar.ownerOf(tokenID) == address(this), "Not Staked here yet."); 
      else 
        require(genXRoar.ownerOf(tokenID) == address(this), "AINT A PART OF THIS"); 
      

      if (isFisherman(tokenID))
        owed += _claimFisherFromRiver(tokenID, unstake);
      else
        owed += _claimBearFromFishing(tokenID, unstake);

    }

    if (owed == 0) return;
    salmon.mint(_msgSender(), owed);


  }


  function claimManyFromRiverAndFishingV2(uint16[] calldata tokenIds, bool unstake) external whenNotPaused _updateEarnings nonReentrant() {

    require(!_msgSender().isContract(), "Contracts are not allowed big man");
    require(tx.origin == _msgSender(), "Only EOA");

    if (tx.origin != msg.sender) {
        require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }
    
    uint256  owed = 0;
    
    for (uint i = 0; i < tokenIds.length; i++) {
      uint16 tokenID = tokenIds[i];
      
      if (tokenID > 10498) {
        require(roar.ownerOf(tokenID) == address(this), "Not Staked here yet."); 
        owed +=  _regularclaim(tokenID,unstake);

      } else {
        if (genXRoar.ownerOf(tokenID) == address(genXStaking)) {
          owed +=  _claimGenXReward(_msgSender(),tokenID);

        } else {
          require(genXRoar.ownerOf(tokenID) == address(this), "AINT A PART OF THIS"); 
          owed +=  _regularclaim(tokenID,unstake);
        
        }
      }
    }

    if (owed == 0) return;
    salmon.mint(_msgSender(), owed);


  }

  function _regularclaim(uint256 tokenID, bool unstake) private returns (uint256 owed) {

    if (isFisherman(tokenID))
      owed = _claimFisherFromRiver(tokenID, unstake);
    else
      owed = _claimBearFromFishing(tokenID, unstake);

  } 

  function calculateReward(uint16[] calldata tokenIds) public view returns (uint256 owed) {

    if (tx.origin != msg.sender) {
        require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }

    for (uint i = 0; i < tokenIds.length; i++) {
      if (isFisherman(tokenIds[i]))
        owed += calcRewardFisherman(tokenIds[i]);
      else
        owed +=  calcRewardBear(tokenIds[i]);
    }
  
  }

  function calcRewardFisherman(uint256 tokenId) public view returns (uint256 owed) {

    if (tx.origin != msg.sender) {
      require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }

    Stake memory stake = riverside[tokenId];
    uint256 rate;
    if (tokenId > 10498) {
       rate = DAILY_SALMON_RATE;
    } else {
      rate = DAILY_SALMON_RATEGenX;
    }

    if (totalSalmonEarned < MAXIMUM_GLOBAL_SALMON) {
        owed = (block.timestamp - MathUpgradeable.max(resetTime,stake.value) ) * rate / 1 days;

        

    } else if (stake.value > lastClaimTimestamp) {
        owed = 0;

    } else {
        owed = (lastClaimTimestamp - MathUpgradeable.max(resetTime,stake.value)) * rate / 1 days; // stop earning additional $WOOL if it's all been earned
    }

  }

  function calcRewardBear(uint256 tokenId) public view returns (uint256 owed) {

    if (tx.origin != msg.sender) {
        require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }
    uint256 alpha = _alphaForBear(tokenId); 
    Stake memory stake  = Bears[alpha][packIndices[tokenId]];
    owed = (alpha) * ((SalmonPerAlpha - stake.value)-(salmonAlphaReset-stake.value)); 


  }


  function _claimFisherFromRiver(uint256 tokenId, bool unstake) private returns (uint256 owed) {

    Stake memory stake = riverside[tokenId];

    require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
    require(!_msgSender().isContract(), "Contracts are not allowed big man");
    require(!(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT), "GONNA BE COLD WITHOUT TWO DAY'S WOOL");

    owed = calcRewardFisherman(tokenId);

    if (unstake) {

      if (random(tokenId) & 1 == 1) {                                           // 50% chance of all $SALMON stolen
        _payBearTax(owed);
        owed = 0;  
      }
      
      delete riverside[tokenId];
      totalFishermanStaked -= 1;
      _deposits[_msgSender()].remove(tokenId);


      if (tokenId > 10498) {
        roar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman 
      } else {
        genXRoar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman 
      }
             
    } else {

      _payBearTax(owed * SALMON_CLAIM_TAX_PERCENTAGE / 100);                    // percentage tax to staked Bears    
      riverside[tokenId] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(block.timestamp)
      }); // reset stake
      owed = owed * (100 - SALMON_CLAIM_TAX_PERCENTAGE) / 100;                  // remainder goes to Fisherman owner
    }
    emit FishermanClaimed(tokenId, owed, unstake);
  }


  function _claimBearFromFishing(uint256 tokenId, bool unstake) private returns (uint256 owed) {

    uint256 alpha = _alphaForBear(tokenId);  
    Stake memory stake = Bears[alpha][packIndices[tokenId]];         
    require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");

    owed = calcRewardBear(tokenId);                                         // Calculate portion of tokens based on Alpha

    if (unstake) {
      totalAlphaStaked -= alpha;                                            // Remove Alpha from total staked
      Stake memory lastStake = Bears[alpha][Bears[alpha].length - 1];         // Shuffle last Bear to current position PT 1 
      Bears[alpha][packIndices[tokenId]] = lastStake;                        // Shuffle last Bear to current position PT 2
      packIndices[lastStake.tokenId] = packIndices[tokenId];                // Shuffle last Bear to current position PT 3
      Bears[alpha].pop();                                                    // Remove duplicate

      delete packIndices[tokenId];                                          // Delete old mapping
      _deposits[_msgSender()].remove(tokenId);

      if (tokenId > 10498) {
        roar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman 
      } else {
        genXRoar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman 
      }   


    } else {

      Bears[alpha][packIndices[tokenId]] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(SalmonPerAlpha)
      }); // reset stake

    }
    emit BearClaimed(tokenId, owed, unstake);
  }

  function rescue(uint256[] calldata tokenIds) external nonReentrant() {
    require(!_msgSender().isContract(), "Contracts are not allowed big man");
    require(tx.origin == _msgSender(), "Only EOA");
    require(rescueEnabled, "RESCUE DISABLED");
    
    

    uint256 tokenId;
    Stake memory stake;
    Stake memory lastStake;
    uint256 alpha;

    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      if (tokenId > 10498) 
        require(roar.ownerOf(tokenId) == address(this), "Not Staked here yet."); 
      else 
        require(genXRoar.ownerOf(tokenId) == address(this), "AINT A PART OF THIS"); 
      
      if (isFisherman(tokenId)) {
        stake = riverside[tokenId];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        delete riverside[tokenId];
        totalFishermanStaked -= 1;

        if (tokenId > 10498) {
          roar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman 
        } else {
          genXRoar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman 
        }

        emit FishermanClaimed(tokenId, 0, true);

      } else {
        alpha = _alphaForBear(tokenId);
        stake = Bears[alpha][packIndices[tokenId]];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        totalAlphaStaked -= alpha; // Remove Alpha from total staked
        lastStake = Bears[alpha][Bears[alpha].length - 1];
        Bears[alpha][packIndices[tokenId]] = lastStake; // Shuffle last bear to current position
        packIndices[lastStake.tokenId] = packIndices[tokenId];
        Bears[alpha].pop(); // Remove duplicate
        delete packIndices[tokenId]; // Delete old mapping

        if (tokenId > 10498) {
          roar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman 
        } else {
          genXRoar.safeTransferFrom(address(this), _msgSender(), tokenId, "");         // send back Fisherman 
        }  

        emit BearClaimed(tokenId, 0, true);
      }
    }
  }


  function _payBearTax(uint256 amount) private {

    if (totalAlphaStaked == 0) {                                              // if there's no staked Bear > keep track of $SALMON due to Bear
      unaccountedRewards += amount; 
      return;
    }

    SalmonPerAlpha += (amount + unaccountedRewards) / totalAlphaStaked;         // makes sure to include any unaccounted $SALMON
    unaccountedRewards = 0;
  }

  modifier _updateEarnings() {

    if (totalSalmonEarned < MAXIMUM_GLOBAL_SALMON) {
      totalSalmonEarned += 
        (block.timestamp - lastClaimTimestamp)
        * totalFishermanStaked
        * DAILY_SALMON_RATE / 1 days; 
      lastClaimTimestamp = block.timestamp;
    }
    _;
  }

  function setWhitelistContract(address contract_address, bool status) public onlyOwner{
    whitelistedContracts[contract_address] = status;
  }

  function isFisherman(uint256 tokenId) public view returns (bool fisherman) {

    if (tx.origin != msg.sender) {
        require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }

    if (tokenId > 10498) {
      Roar.ManBear memory yo = roar.getTokenTraits(tokenId);
      return yo.isFisherman;
    } else {

      (fisherman,  ) = genXRoar.tokenTraits(tokenId);
      return fisherman;
    }

  }
  function _alphaForBear(uint256 tokenId) private view returns (uint8) {

    if (tokenId > 10498) {
      Roar.ManBear memory yo = roar.getTokenTraits(tokenId);
      return MAX_ALPHA - yo.alphaIndex; 
    } else {

      GenXInterface.ManBear memory yo = genXRoarInterface.getTokenTraits(tokenId);
      return MAX_ALPHA - yo.alphaIndex; 
    }
  }

  function randomBearOwner(uint256 seed) external view returns (address) {

    if (tx.origin != msg.sender) {
      require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }

    if (totalAlphaStaked == 0) return address(0x0);

    uint256 bucket = (seed & 0xFFFFFFFF) % totalAlphaStaked;                  // choose a value from 0 to total alpha staked
    uint256 cumulative;
    seed >>= 32;

    for (uint i = MAX_ALPHA - 3; i <= MAX_ALPHA; i++) {                     // loop through each bucket of Bears with the same alpha score
      cumulative += Bears[i].length * i;
      if (bucket >= cumulative) continue;                                   // if the value is not inside of that bucket, keep going

      return Bears[i][seed % Bears[i].length].owner;                          // get the address of a random Bear with that alpha score
    }

    return address(0x0);
  }



  function setInit(address _roar, address _salmon) external onlyOwner{
    roar = Roar(_roar);                                              
    salmon = ITSalmon(_salmon);                                               

  }

  function changeDailyRateGenY(uint256 _newRate) external onlyOwner{
      DAILY_SALMON_RATE = _newRate;
  }
  
  function changeDailyRateGenX(uint256 _newRate) external onlyOwner{
      DAILY_SALMON_RATEGenX = _newRate;
  }

  function changeMinExit(uint256 _newExit) external onlyOwner{
      MINIMUM_TO_EXIT = _newExit ;
  }

  function changeSalmonTax(uint256 _newTax) external onlyOwner {
      SALMON_CLAIM_TAX_PERCENTAGE = _newTax;
  }


  function changeMaxSalmon(uint256 _newMax) external onlyOwner {
      MAXIMUM_GLOBAL_SALMON = _newMax;
  }

  function setRescueEnabled(bool _enabled) external onlyOwner {
    rescueEnabled = _enabled;
  }

  function setPaused(bool _paused) external onlyOwner {
    if (_paused) _pause();
    else _unpause();
  }
  
        

  function changeLinkFee(uint256 _fee) external onlyOwner {
    fee = _fee;
  }

  function random(uint256 seed) private view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(
      tx.origin,
      blockhash(block.number - 1),
      block.timestamp,
      seed,
      randomNumber
    )));
  }

  function initChainLink() external onlyOwner {
      vrfReqd.increment();
      getRandomChainlink();
  }

  function getRandomChainlink() private returns (bytes32 requestId) {

    if (tx.origin != msg.sender) {
        require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }

    if (vrfReqd.current() <= vrfcooldown) {
      vrfReqd.increment();
      return 0x000;
    }

    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    vrfReqd.reset();
    return requestRandomness(keyHash, fee);
  }

  function changeVrfCooldown(uint256 _cooldown) external onlyOwner{
      vrfcooldown = _cooldown;
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
      bytes32 reqId = requestId;
      randomNumber = randomness;
  }

  function withdrawLINK() external onlyOwner {
    uint256 tokenSupply = IERC20Upgradeable(linkToken).balanceOf(address(this));
    IERC20Upgradeable(linkToken).transfer(msg.sender, tokenSupply);
  }

  function changeLinkAddress(address _newaddress) external onlyOwner{
      linkToken = _newaddress;
  }
   
 
  function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {
    require(from == address(0x0), "Cannot send tokens to Barn directly");
    return IERC721ReceiverUpgradeable.onERC721Received.selector;
  }

                                                                                        
  uint256 public  DAILY_SALMON_RATEGenX;

  mapping(uint256 => bool) public migrated;    
  uint256 public resetTime;

  
  

  RoarGenX genXRoar; 
  RiverGenX genXStaking;
  GenXInterface genXRoarInterface;

  function setGenXContract(address _staking,address  _mint) external onlyOwner {
    genXStaking = RiverGenX(_staking);
    genXRoar = RoarGenX(_mint);
    genXRoarInterface = GenXInterface(_mint);
    DAILY_SALMON_RATEGenX = 10000 ether; 
    backupclaimethod = false;
  }

  function claimGenXRewards (address account, uint16[] calldata tokenIds) external whenNotPaused _updateEarnings nonReentrant() {
    require(backupclaimethod,"Method Not enabled");
    _claimGenXRewards(account,tokenIds);  
  }
   
  function _claimGenXRewards(address account, uint16[] calldata tokenIds) private  {
    require(backupclaimethod,"Method Not enabled");
    require(account == _msgSender() && !_msgSender().isContract(), "Contracts are not allowed big man");

    if (tx.origin != msg.sender) {
      require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }
    
    bool unstake = false;
    uint256  owed = 0;
        
    for (uint i = 0; i < tokenIds.length; i++) {
      
      uint16 tokenID = tokenIds[i];

      require(tokenID <= 10498, "Not a Gen X Token");
      require(genXRoar.ownerOf(tokenID) == address(genXStaking), "AINT A PART OF THE OLD CONTRACT"); 

      bool fisherman = isFisherman(tokenID);
      
      if (!migrated[tokenID]) {
          if (fisherman) {

            uint16 tokenId;
            uint80 valueOLD;
            address owner;
              
            (tokenId,valueOLD,owner) = genXStaking.riverside(tokenID);
            require(owner == _msgSender(), "Not your token bro");

            uint80 value = uint80(MathUpgradeable.min(block.timestamp,resetTime));
            owed = calcFishermanSalmonGenX(value);
            _payBearTax(owed * SALMON_CLAIM_TAX_PERCENTAGE / 100);                    
            owed = owed * (100 - SALMON_CLAIM_TAX_PERCENTAGE) / 100;     

            riverside[tokenID] = Stake({owner: _msgSender(), tokenId: uint16(tokenID), value: uint80(block.timestamp)}); 
            migrated[tokenID] = true;

            emit FishermanClaimed(tokenID, owed, unstake);
            emit TokenStaked(account, tokenID, block.timestamp);


          
          } else {

            uint256 alpha = _alphaForBear(tokenID);  
            uint16 tokenId;
            uint80 value;
            address owner;
            uint256 indic = genXStaking.packIndices(tokenID);
            (tokenId,value,owner) = genXStaking.Bears(alpha,indic);        
            require(owner == _msgSender(), "SWIPER, NO SWIPING");


            owed = (alpha) * (SalmonPerAlpha - 0)
            
            ; 

            totalAlphaStaked += alpha; 
            packIndices[tokenID] = Bears[alpha].length;
            Bears[alpha].push(Stake({owner: account,tokenId: uint16(tokenID),value: uint80(0)})); 

            migrated[tokenID] = true;


              
            emit TokenStaked(account, tokenID, SalmonPerAlpha);

          }

      } else {

          if (fisherman) {

              Stake memory stake = riverside[tokenID];
              owed = calcFishermanSalmonGenX(stake.value);
              _payBearTax(owed * SALMON_CLAIM_TAX_PERCENTAGE / 100);        
              riverside[tokenID] = Stake({owner: _msgSender(), tokenId: uint16(tokenID), value: uint80(block.timestamp)}); 
              owed = owed * (100 - SALMON_CLAIM_TAX_PERCENTAGE) / 100;     
              emit FishermanClaimed(tokenID, owed, unstake);

          } else {
              
              owed = calcRewardBear(tokenID); 
              uint256 alpha = _alphaForBear(tokenID);  
              Bears[alpha][packIndices[tokenID]] = Stake({owner: _msgSender(),tokenId: uint16(tokenID),value: uint80(SalmonPerAlpha)}); // reset stake

          }

      }
      
  
      if (owed == 0) return;
      salmon.mint(_msgSender(), owed);
    }

  }

  function _claimGenXReward(address account, uint16 tokenID) private returns (uint256 owed) {
    
    require(tokenID <= 10498, "Not a Gen X Token");
    require(account == _msgSender() && !_msgSender().isContract(), "Contracts are not allowed big man");
    require(genXRoar.ownerOf(tokenID) == address(genXStaking), "AINT A PART OF THE OLD CONTRACT"); 

    if (tx.origin != msg.sender) {
      require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
    }
    
    bool unstake = false;
    owed = 0;
    bool fisherman = isFisherman(tokenID);
    
    if (!migrated[tokenID]) {
        if (fisherman) {

          uint16 tokenId;
          uint80 valueOLD;
          address owner;
            
          (tokenId,valueOLD,owner) = genXStaking.riverside(tokenID);
          require(owner == _msgSender(), "Not your token bro");

          uint80 value = uint80(MathUpgradeable.min(block.timestamp,resetTime));
          owed = calcFishermanSalmonGenX(value);
          _payBearTax(owed * SALMON_CLAIM_TAX_PERCENTAGE / 100);                    
          owed = owed * (100 - SALMON_CLAIM_TAX_PERCENTAGE) / 100;     

          riverside[tokenID] = Stake({owner: _msgSender(), tokenId: uint16(tokenID), value: uint80(block.timestamp)}); 
          migrated[tokenID] = true;

          emit FishermanClaimed(tokenID, owed, unstake);
          emit TokenStaked(account, tokenID, block.timestamp);


        
        } else {

          uint256 alpha = _alphaForBear(tokenID);  
          uint16 tokenId;
          uint80 value;
          address owner;
          uint256 indic = genXStaking.packIndices(tokenID);
          (tokenId,value,owner) = genXStaking.Bears(alpha,indic);        
          require(owner == _msgSender(), "SWIPER, NO SWIPING");


          owed = (alpha) * (SalmonPerAlpha - salmonAlphaReset); 

          totalAlphaStaked += alpha; 
          packIndices[tokenID] = Bears[alpha].length;
          Bears[alpha].push(Stake({owner: account,tokenId: uint16(tokenID),value: uint80(0)})); 

          migrated[tokenID] = true;


            
          emit TokenStaked(account, tokenID, SalmonPerAlpha);

        }

    } else {

        if (fisherman) {

            Stake memory stake = riverside[tokenID];
            owed = calcFishermanSalmonGenX(stake.value);
            _payBearTax(owed * SALMON_CLAIM_TAX_PERCENTAGE / 100);        
            riverside[tokenID] = Stake({owner: _msgSender(), tokenId: uint16(tokenID), value: uint80(block.timestamp)}); 
            owed = owed * (100 - SALMON_CLAIM_TAX_PERCENTAGE) / 100;     
            emit FishermanClaimed(tokenID, owed, unstake);

        } else {
            
            owed = calcRewardBear(tokenID); 
            uint256 alpha = _alphaForBear(tokenID);  
            Bears[alpha][packIndices[tokenID]] = Stake({owner: _msgSender(),tokenId: uint16(tokenID),value: uint80(SalmonPerAlpha)}); // reset stake

        }

    }
    


    return owed;
  

  }

  function calcFishermanSalmonGenX(uint80 value) internal view returns (uint256 owed) {

      if (tx.origin != msg.sender) {
        require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
      }

      if (totalSalmonEarned < MAXIMUM_GLOBAL_SALMON) {
          owed = (block.timestamp - value) * DAILY_SALMON_RATEGenX / 1 days;

      } else if (value > lastClaimTimestamp) {
          owed = 0; 

      } else {
          owed = (lastClaimTimestamp - value) * DAILY_SALMON_RATEGenX / 1 days; 
      }

  }

  function setResetTime(uint256 _time) external onlyOwner {
    resetTime = _time;
  }

  function enableBackupClaim (bool _status) external onlyOwner {
    backupclaimethod = _status;
    
  }

  bool public backupclaimethod;

  uint256 public salmonAlphaReset;


  function setAlphaReset(uint256 _new) external onlyOwner{

    salmonAlphaReset = _new;


  }

  
}