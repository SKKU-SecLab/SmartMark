
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
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


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Upgradeable.ownerOf(tokenId);

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

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
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


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
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


abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal onlyInitializing {
    }

    function __ERC721Burnable_init_unchained() internal onlyInitializing {
    }
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal onlyInitializing {
    }

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {
    }
    using StringsUpgradeable for uint256;

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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

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


interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal onlyInitializing {
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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

    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.7;


contract LenderToken is
    ERC721URIStorageUpgradeable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable,
    AccessControlEnumerableUpgradeable
{

    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 public constant ROLE_MINTER = keccak256("ROLE_MINTER");
    bytes32 public constant ROLE_LTOKEN_MANAGER = keccak256("ROLE_LTOKEN_MANAGER");

    CountersUpgradeable.Counter private _tokenIds;
    string private _baseURIextended;


    event SetBaseURI(string baseURI_);

    event Mint(address indexed player);


    modifier onlyMinter() {

        require(
            hasRole(ROLE_MINTER, _msgSender()),
            "only the kyokoP2P contract has permission to perform this operation."
        );
        _;
    }

    modifier onlyLTokenManager() {

        require(
            hasRole(ROLE_LTOKEN_MANAGER, _msgSender()),
            "only the LToken manager has permission to perform this operation."
        );
        _;
    }    

    function initialize() public initializer {

        __ERC721_init("KyokoLToken", "KL");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Burnable_init();
        __Context_init();
        __AccessControlEnumerable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(ROLE_LTOKEN_MANAGER, _msgSender());
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {

        super._beforeTokenTransfer(from, to, amount);
    }

    function setBaseURI(string memory baseURI_) external onlyLTokenManager {

        _baseURIextended = baseURI_;
        emit SetBaseURI(baseURI_);
    }

    function _baseURI() internal view virtual override returns (string memory) {

        return _baseURIextended;
    }

    function mint(address player) public onlyMinter returns (uint256) {

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        emit Mint(player);
        return newItemId;
    }

    function burn(uint256 tokenId)
        public
        virtual
        override(ERC721BurnableUpgradeable)
    {

        super._burn(tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {

        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlEnumerableUpgradeable)
        returns (bool)
    {

        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {

        return super.tokenURI(tokenId);
    }
}// MIT

pragma solidity 0.8.7;

library DataTypes {

    struct COLLATERAL {
        uint256 apy;
        uint256 price;
        uint256 period;
        uint256 buffering;
        address erc20Token;
        string description;
    }

    struct OFFER {
        uint256 apy;
        uint256 price;
        uint256 period;
        uint256 buffering;
        address erc20Token;
        bool accept;
        bool cancel;
        uint256 offerId; //final sold offerId
        uint256 lTokenId; //lTokenId, the token's id given to the lender
        address user; //the person who given this offer
        uint256 fee;// The fee when the user adds an offer
    }

    struct NFT {
        address holder;
        address lender;
        uint256 nftId; // nft tokenId
        address nftAdr; // nft address
        uint256 depositId; // depositId
        uint256 lTokenId; // ltoken id
        uint256 borrowTimestamp; // borrow timestamp
        uint256 emergencyTimestamp; // emergency timestamp
        uint256 repayAmount; // repayAmount
        uint8 marks;
        COLLATERAL collateral;
    }
}// MIT

pragma solidity 0.8.7;


library Configuration {

    uint8 public constant BORROW_MASK = 0x0E;
    uint8 public constant REPAY_MASK = 0x0D;
    uint8 public constant WITHDRAW_MASK = 0x0B;
    uint8 public constant LIQUIDATE_MASK = 0x07;

    uint8 constant IS_BORROW_START_BIT_POSITION = 0;
    uint8 constant IS_REPAY_START_BIT_POSITION = 1;
    uint8 constant IS_WITHDRAW_START_BIT_POSITION = 2;
    uint8 constant IS_LIQUIDATE_START_BIT_POSITION = 3;

    function setBorrow(DataTypes.NFT storage self, bool active) internal {

        self.marks =
            (self.marks & BORROW_MASK) |
            (uint8(active ? 1 : 0) << IS_BORROW_START_BIT_POSITION);
    }

    function setRepay(DataTypes.NFT storage self, bool active) internal {

        self.marks =
            (self.marks & REPAY_MASK) |
            (uint8(active ? 1 : 0) << IS_REPAY_START_BIT_POSITION);
    }

    function setWithdraw(DataTypes.NFT storage self, bool active) internal {

        self.marks =
            (self.marks & WITHDRAW_MASK) |
            (uint8(active ? 1 : 0) << IS_WITHDRAW_START_BIT_POSITION);
    }

    function setLiquidate(DataTypes.NFT storage self, bool active) internal {

        self.marks =
            (self.marks & LIQUIDATE_MASK) |
            (uint8(active ? 1 : 0) << IS_LIQUIDATE_START_BIT_POSITION);
    }

    function getBorrow(DataTypes.NFT storage self)
        internal
        view
        returns (bool)
    {

        return self.marks & ~BORROW_MASK != 0;
    }

    function getRepay(DataTypes.NFT storage self) internal view returns (bool) {

        return self.marks & ~REPAY_MASK != 0;
    }

    function getWithdraw(DataTypes.NFT storage self)
        internal
        view
        returns (bool)
    {

        return self.marks & ~WITHDRAW_MASK != 0;
    }

    function getLiquidate(DataTypes.NFT storage self)
        internal
        view
        returns (bool)
    {

        return self.marks & ~LIQUIDATE_MASK != 0;
    }

    function getState(DataTypes.NFT storage self)
        internal
        view
        returns (
            bool,
            bool,
            bool,
            bool
        )
    {

        return (
            self.marks & ~BORROW_MASK != 0,
            self.marks & ~REPAY_MASK != 0,
            self.marks & ~WITHDRAW_MASK != 0,
            self.marks & ~LIQUIDATE_MASK != 0
        );
    }
}// MIT

pragma solidity 0.8.7;


contract KyokoStorage {


    uint256 public constant ONE_YEAR = 365 days;

    uint256 public constant FEE_PERCENTAGE_BASE = 10000;

    uint256 public fee;

    LenderToken public lToken;

    CountersUpgradeable.Counter internal depositId;

    CountersUpgradeable.Counter internal offerId;

    mapping(address => bool) internal whiteList;
    EnumerableSetUpgradeable.AddressSet internal whiteSet;

    mapping(uint256 => DataTypes.NFT) public nftMap; //depositId => NFT

    mapping(address => EnumerableSetUpgradeable.UintSet) internal nftHolderMap; //holder address => depositId Set

    mapping(uint256 => EnumerableSetUpgradeable.UintSet)
        internal depositIdOfferMap; //depositId => offerId Set
    mapping(uint256 => DataTypes.OFFER) public offerMap; //offerId => OFFER

    mapping(uint256 => uint256) public lendMap; //lTokenId => depositId

    EnumerableSetUpgradeable.UintSet internal open;
    EnumerableSetUpgradeable.UintSet internal lent;
}// MIT

pragma solidity 0.8.7;


interface IKyoko {

    event NFTReceived(
        address indexed operator,
        address indexed from,
        uint256 indexed tokenId,
        bytes data
    );

    event SetPause(bool pause);

    event UpdateWhiteList(address indexed _address, bool _active);

    event SetFee(uint256 _fee);

    event Deposit(
        uint256 indexed _depositId,
        uint256 indexed _nftId,
        address indexed _nftAdr
    );

    event Modify(uint256 indexed _depositId, address _holder);

    event AddOffer(
        uint256 indexed _depositId,
        address indexed _lender,
        uint256 indexed _offerId
    );

    event CancelOffer(
        uint256 indexed _depositId,
        uint256 indexed _offerId,
        address indexed user
    );

    event AcceptOffer(address indexed offerUser, address indexed nftUser,uint256 indexed _depositId, uint256 _offerId);

    event Borrow(uint256 indexed _depositId);

    event Lend(address indexed lender, address indexed nftUser, uint256 indexed _depositId, uint256 _lTokenId);

    event Repay(uint256 indexed _depositId, uint256 _amount);

    event ClaimCollateral(uint256 indexed _depositId);

    event ClaimERC20(uint256 indexed _depositId);

    event ExecuteEmergency(uint256 indexed _depositId);

    event Liquidate(uint256 indexed _depositId);
}// MIT

pragma solidity 0.8.7;



contract KyokoP2P is
    OwnableUpgradeable,
    ERC721HolderUpgradeable,
    PausableUpgradeable,
    KyokoStorage,
    IKyoko
{

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using Configuration for DataTypes.NFT;

    function initialize(address _lToken) public initializer {

        __Ownable_init();
        __Pausable_init();
        lToken = LenderToken(_lToken);
        fee = 100;
    }

    modifier checkWhiteList(address _address) {

        require(whiteList[_address], "This address is not in the whitelist");
        _;
    }

    modifier checkCollateralStatus(uint256 _depositId) {

        DataTypes.NFT storage _nft = nftMap[_depositId];
        require(!_nft.getRepay() && _nft.getBorrow(), "NFT status wrong");
        _;
    }

    function setPause(bool pause) external onlyOwner {

        if (pause) {
            _pause();
        } else {
            _unpause();
        }
        emit SetPause(pause);
    }

    function updateWhiteList(address _address, bool _active)
        external
        whenNotPaused
        onlyOwner
    {

        whiteList[_address] = _active;
        _active ? whiteSet.add(_address) : whiteSet.remove(_address);
        emit UpdateWhiteList(_address, _active);
    }

    function setFee(uint256 _fee) external whenNotPaused onlyOwner {

        require(_fee * 10 <= FEE_PERCENTAGE_BASE, "fee too high");
        fee = _fee;
        emit SetFee(_fee);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721HolderUpgradeable) returns (bytes4) {

        emit NFTReceived(operator, from, tokenId, data);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function deposit(
        address _nftAdr,
        uint256 _nftId,
        uint256 _apy,
        uint256 _price,
        uint256 _period,
        uint256 _buffering,
        address _erc20Token,
        string memory _description
    ) external whenNotPaused checkWhiteList(_erc20Token) returns (uint256) {

        require(
            IERC721Upgradeable(_nftAdr) != lToken,
            "the lender token Credential not supported."
        );
        require(
            IERC721Upgradeable(_nftAdr).supportsInterface(0x80ac58cd),
            "Parameter _nftAdr is not ERC721 contract address"
        );

        depositId.increment();
        uint256 currentDepositId = depositId.current();

        nftHolderMap[msg.sender].add(currentDepositId);
        DataTypes.COLLATERAL memory _collateral = DataTypes.COLLATERAL({
            apy: _apy,
            price: _price,
            period: _period,
            buffering: _buffering,
            erc20Token: _erc20Token,
            description: _description
        }); // collateral info
        nftMap[currentDepositId] = DataTypes.NFT({
            holder: msg.sender,
            lender: address(0),
            nftId: _nftId,
            nftAdr: _nftAdr,
            depositId: currentDepositId,
            lTokenId: 0,
            borrowTimestamp: 0,
            emergencyTimestamp: 0,
            repayAmount: 0,
            marks: 0,
            collateral: _collateral
        });

        IERC721Upgradeable(_nftAdr).safeTransferFrom(msg.sender, address(this), _nftId);
        open.add(currentDepositId);
        emit Deposit(currentDepositId, _nftId, _nftAdr);
        return currentDepositId;
    }

    function modify(
        uint256 _depositId,
        uint256 _apy,
        uint256 _price,
        uint256 _period,
        uint256 _buffering,
        address _erc20Token,
        string memory _description
    ) external whenNotPaused checkWhiteList(_erc20Token) {

        DataTypes.NFT storage _nft = nftMap[_depositId];
        require(
            nftHolderMap[msg.sender].contains(_depositId) && !_nft.getBorrow() && !_nft.getWithdraw(),
            "this _depositId is not your owner"
        );
        _nft.collateral.apy = _apy;
        _nft.collateral.price = _price;
        _nft.collateral.period = _period;
        _nft.collateral.buffering = _buffering;
        _nft.collateral.erc20Token = _erc20Token;
        _nft.collateral.description = _description;
        emit Modify(_depositId, msg.sender);
    }

    function addOffer(
        uint256 _depositId,
        uint256 _apy,
        uint256 _price,
        uint256 _period,
        uint256 _buffering,
        address _erc20Token
    ) external whenNotPaused checkWhiteList(_erc20Token) {

        DataTypes.NFT storage _nft = nftMap[_depositId];
        require(!_nft.getBorrow(), "This collateral already borrowed");
        require(!_nft.getWithdraw(), "This collateral already withdrawn.");
        require(!_nft.getRepay(), "Bad parameters:repay.");
        require(!_nft.getLiquidate(), "Bad parameters:liquidate.");

        offerId.increment();
        uint256 currentOfferId = offerId.current();

        uint256 _realPrice = _price.mul(FEE_PERCENTAGE_BASE).div(
            FEE_PERCENTAGE_BASE + fee
        );
        IERC20Upgradeable(_erc20Token).safeTransferFrom(
            address(msg.sender),
            address(this),
            _price
        );
        DataTypes.OFFER memory _off = DataTypes.OFFER({
            apy: _apy,
            price: _realPrice,
            period: _period,
            buffering: _buffering,
            erc20Token: _erc20Token,
            accept: false,
            cancel: false,
            offerId: currentOfferId,
            lTokenId: 0,
            user: msg.sender,
            fee: fee
        });
        depositIdOfferMap[_depositId].add(currentOfferId);
        offerMap[currentOfferId] = _off;
        emit AddOffer(_depositId, msg.sender, currentOfferId);
    }

    function cancelOffer(uint256 _depositId, uint256 _offerId)
        external
        whenNotPaused
    {

        require(
            depositIdOfferMap[_depositId].contains(_offerId),
            "this offer not in the deposit NFT transaction"
        );
        DataTypes.OFFER storage _offer = offerMap[_offerId];
        require(_offer.user == msg.sender, "Not this offer owner"); // Verify token owner
        require(!_offer.accept, "This offer already accepted");
        require(!_offer.cancel, "This offer already cancelled");

        depositIdOfferMap[_depositId].remove(_offerId);
        _offer.cancel = true;

        uint256 _totalAmount = _offer.price.mul(FEE_PERCENTAGE_BASE + _offer.fee).div(
            FEE_PERCENTAGE_BASE
        );
        IERC20Upgradeable(_offer.erc20Token).safeTransfer(
            msg.sender,
            _totalAmount
        );

        emit CancelOffer(_depositId, _offerId, msg.sender);
    }

    function acceptOffer(uint256 _depositId, uint256 _offerId)
        external
        whenNotPaused
    {

        require(
            depositIdOfferMap[_depositId].contains(_offerId),
            "this offer not in the deposit NFT transaction"
        );
        require(
            nftHolderMap[msg.sender].contains(_depositId),
            "this depositId is not belong to you."
        );

        DataTypes.OFFER storage _offer = offerMap[_offerId];
        require(!_offer.accept, "This offer already accepted.");
        require(!_offer.cancel, "This offer already cancelled.");

        _offer.accept = true; // change offer status

        DataTypes.NFT storage _nft = nftMap[_depositId];

        _nft.collateral.apy = _offer.apy;
        _nft.collateral.price = _offer.price;
        _nft.collateral.period = _offer.period;
        _nft.collateral.buffering = _offer.buffering;
        _nft.collateral.erc20Token = _offer.erc20Token;

        _lend(_depositId, false, _offer.user);

        emit AcceptOffer(_offer.user, msg.sender, _depositId, _offerId);
    }

    function lend(
        uint256 _depositId,
        uint256 _apy,
        uint256 _price,
        uint256 _period,
        uint256 _buffering,
        address _erc20Token
    ) external whenNotPaused {

        DataTypes.NFT memory _nft = nftMap[_depositId];
        require(
            _nft.collateral.apy == _apy &&
                _nft.collateral.price == _price &&
                _nft.collateral.period == _period &&
                _nft.collateral.buffering == _buffering &&
                _nft.collateral.erc20Token == _erc20Token,
            "Bad parameters."
        );
        _lend(_depositId, true, msg.sender);
    }

    function _lend(
        uint256 _depositId,
        bool lendMode,
        address offerUser
    ) private {

        DataTypes.NFT storage _nft = nftMap[_depositId];

        require(!_nft.getBorrow(), "This collateral already borrowed.");
        require(!_nft.getWithdraw(), "This collateral already withdrawn.");
        require(!_nft.getRepay(), "Bad parameters:repay.");
        require(!_nft.getLiquidate(), "Bad parameters:liquidate.");

        address _erc20Token = _nft.collateral.erc20Token;
        uint256 price = _nft.collateral.price;
        uint256 totalAmount = price.mul(FEE_PERCENTAGE_BASE + fee).div(
            FEE_PERCENTAGE_BASE
        ); // get lend amount

        if (lendMode) {
            IERC20Upgradeable(_erc20Token).safeTransferFrom(
                address(msg.sender),
                address(this),
                totalAmount
            );
        }
        IERC20Upgradeable(_nft.collateral.erc20Token).safeTransfer(
            address(_nft.holder),
            price
        );

        uint256 _lTokenId = lToken.mint(offerUser); // mint lToken
        lendMap[_lTokenId] = _depositId;

        _nft.lender = offerUser;
        _nft.lTokenId = _lTokenId; // set collateral lTokenid
        _nft.borrowTimestamp = block.timestamp;

        _nft.setBorrow(true); // change collateral status
        lent.add(_depositId);
        open.remove(_depositId);

        emit Lend(offerUser, _nft.holder, _depositId, _lTokenId);
    }

    function repay(uint256 _depositId, uint256 _amount) external {

        DataTypes.NFT storage _nft = nftMap[_depositId];

        require(
            nftHolderMap[msg.sender].contains(_depositId),
            "this depositId is not belong to you."
        );
        require(_nft.getBorrow(), "This collateral is not borrowed.");
        require(!_nft.getRepay(), "This debt already Cleared."); // Debt has clear
        require(!_nft.getLiquidate(), "This debt already liquidated."); // has liquidate

        uint256 _repayAmount = calcInterestRate(_depositId, true); // get repay amount
        require(_amount >= _repayAmount, "Wrong payment amount.");

        IERC20Upgradeable(_nft.collateral.erc20Token).safeTransferFrom(
            address(msg.sender),
            address(this),
            _repayAmount
        );
        _nft.setRepay(true); // change collateral status
        _nft.repayAmount = _repayAmount;
        lent.remove(_depositId);
        emit Repay(_depositId, _repayAmount);
    }

    function claimCollateral(uint256 _depositId) external {

        require(
            nftHolderMap[msg.sender].contains(_depositId),
            "this depositId is not belong to you."
        );

        DataTypes.NFT storage _nft = nftMap[_depositId];
        require(!_nft.getBorrow() || (_nft.getBorrow() && _nft.getRepay()), "This debt is not repay.");
        require(!_nft.getWithdraw(), "You have withdrawn this NFT.");
        require(!_nft.getLiquidate(), "This debt already liquidated.");

        IERC721Upgradeable(_nft.nftAdr).safeTransferFrom(
            address(this),
            msg.sender,
            _nft.nftId
        ); // send collateral to msg.sender
        _nft.setWithdraw(true);
        open.remove(_depositId);
        lent.remove(_depositId);
        emit ClaimCollateral(_depositId);
    }

    function claimERC20(uint256 _lTokenId) external {

        uint256 _depositId = lendMap[_lTokenId];
        DataTypes.NFT storage _nft = nftMap[_depositId];
        require(_lTokenId == _nft.lTokenId, "lTokenId data error.");
        require(
            lToken.ownerOf(_nft.lTokenId) == msg.sender,
            "Not lToken owner"
        ); // Verify token owner
        require(_nft.getRepay(), "This debt is not clear");
        lToken.burn(_nft.lTokenId); // burn lToken
        IERC20Upgradeable(_nft.collateral.erc20Token).safeTransfer(
            msg.sender,
            _nft.repayAmount
        );
        emit ClaimERC20(_lTokenId);
    }

    function executeEmergency(uint256 _depositId)
        external
        whenNotPaused
        checkCollateralStatus(_depositId)
    {

        DataTypes.NFT storage _nft = nftMap[_depositId];
        require(
            lToken.ownerOf(_nft.lTokenId) == msg.sender,
            "Not lToken owner"
        ); // Verify token owner
        require(
            (block.timestamp - _nft.borrowTimestamp) > _nft.collateral.period,
            "Can do not execute emergency."
        ); // An emergency can be triggered after collateral period
        _nft.emergencyTimestamp = block.timestamp; // set collateral emergency timestamp
        emit ExecuteEmergency(_depositId);
    }

    function liquidate(uint256 _depositId)
        external
        whenNotPaused
        checkCollateralStatus(_depositId)
    {

        DataTypes.NFT storage _nft = nftMap[_depositId];
        uint256 _emerTime = _nft.emergencyTimestamp;
        require(_emerTime > 0, "The collateral has not been in an emergency");
        require(
            (block.timestamp - _emerTime) > _nft.collateral.buffering,
            "Can do not liquidate."
        );
        require(
            lToken.ownerOf(_nft.lTokenId) == msg.sender,
            "Not lToken owner"
        ); // Verify token owner
        lToken.burn(_nft.lTokenId); // burn lToken
        IERC721Upgradeable(_nft.nftAdr).safeTransferFrom(
            address(this),
            msg.sender,
            _nft.nftId
        ); // send collateral to lender
        _nft.setLiquidate(true);
        lent.remove(_depositId);
        emit Liquidate(_depositId);
    }

    function calcInterestRate(uint256 _depositId, bool _isRepay)
        public
        view
        returns (uint256 repayAmount)
    {

        uint256 base = _isRepay ? 100 : 101;
        DataTypes.NFT storage _nft = nftMap[_depositId];
        require(
            _nft.getBorrow() && !_nft.getRepay() && !_nft.getLiquidate(),
            "No interest."
        );
        if (_nft.borrowTimestamp == 0) {
            return repayAmount;
        }
        uint256 _loanSeconds = block.timestamp - _nft.borrowTimestamp; // loan period
        uint256 _secondsInterest = _nft.collateral.apy.mul(10**16).div(
            ONE_YEAR
        );
        uint256 _totalInterest = (_loanSeconds *
            _secondsInterest *
            _nft.collateral.price) / 10**18; // total interest
        repayAmount = _totalInterest.add(
            _nft.collateral.price.mul(base).div(100)
        );
    }

    function getWhiteSet() public view returns (address[] memory) {

        return whiteSet.values();
    }

    function getNftHolderMap(address holder)
        public
        view
        returns (uint256[] memory)
    {

        return nftHolderMap[holder].values();
    }

    function getDepositIdOfferMap(uint256 depositId)
        public
        view
        returns (uint256[] memory)
    {

        return depositIdOfferMap[depositId].values();
    }

    function getState(uint256 _depositId)
        public
        view
        returns (
            bool,
            bool,
            bool,
            bool
        )
    {

        DataTypes.NFT storage _nft = nftMap[_depositId];
        return _nft.getState();
    }


    function getEffectiveNftHolderDepositId(address holder)
        public
        view
        returns (uint256[] memory)
    {

        uint256[] memory depositIdArray = nftHolderMap[holder].values();
        if (depositIdArray.length == 0) {
            return depositIdArray;
        }
        uint256 arrayLength = depositIdArray.length;
        uint256[] memory resultDepositIdArray = new uint256[](arrayLength);
        for (uint256 i = 0; i < depositIdArray.length; i++) {
            uint256 tempDepositId = depositIdArray[i];
            (
                bool borrowState,
                bool repayState,
                bool withdrawState,
                bool liquidateState
            ) = getState(tempDepositId);

            bool case1 = !borrowState && !withdrawState;
            bool case2 = borrowState &&
                !repayState &&
                !liquidateState &&
                !withdrawState;
            bool case3 = borrowState &&
                repayState &&
                !liquidateState &&
                !withdrawState;
            if (case1 || case2 || case3) {
                resultDepositIdArray[i] = tempDepositId;
            }
        }
        return resultDepositIdArray;
    }

    function getOpen() public view returns (uint256[] memory) {

        return open.values();
    }

    function getLent() public view returns (uint256[] memory) {

        return lent.values();
    }

}