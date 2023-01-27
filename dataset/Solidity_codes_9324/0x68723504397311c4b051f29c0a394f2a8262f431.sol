

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
}

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
        return !Address.isContract(address(this));
    }
}

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
}

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;


library SafeMath {

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
}

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

}

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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

}

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
}

pragma solidity ^0.8.0;


library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;


    struct Map {
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    function _set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._keys.contains(key);
    }

    function _length(Map storage map) private view returns (uint256) {
        return map._keys.length();
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    function _get(
        Map storage map,
        bytes32 key,
        string memory errorMessage
    ) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

pragma solidity ^0.8.0;

library ThemisStrings {
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
    
    function concat(string memory a, string memory b)
        internal pure returns(string memory) {
            
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bc = new bytes(ba.length + bb.length);
        
        uint256 bal = ba.length;
        uint256 bbl = bb.length;
        uint256 k = 0;
        
        for (uint256 i = 0; i != bal; ++i) {
            bc[k++] = ba[i];
        }
        for (uint256 i = 0; i != bbl; ++i) {
            bc[k++] = bb[i];
        }
        
        return string(bc);
    }
}

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
}

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
}
pragma solidity ^0.8.0;

contract Governance {

    address public _governance;

    constructor() {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance) public onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }

}
pragma solidity ^0.8.0;


contract RoleControl is Governance,Pausable,ReentrancyGuard{

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    mapping(bytes32 => mapping(address => bool)) private _roles; // rule name => address => flag

    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender) ,"account is missing role.");
        _;
    }
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    function grantRole(bytes32 role, address account) external onlyGovernance {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyGovernance {
        _revokeRole(role, account);
    }



    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyGovernance {
        _unpause();
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role][account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role][account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }


}
pragma solidity ^0.8.0;
interface IUniswapV3Oracle{
    function getNFTAmounts(uint256 _tokenId) external view returns(address _token0,address _token1,uint24 _fee,uint256 _amount0,uint256 _amount1);
    function getTWAPQuoteNft(uint256 _tokenId,address _quoteToken) external view returns(uint256 _quoteAmount,uint256 _gasEstimate);
    
}
pragma solidity ^0.8.0;


    

interface IThemisBorrowCompoundStorage{
    struct BorrowUserInfo {
        uint256 currTotalBorrow;
    }
    
    struct UserApplyRate{
        address apply721Address;
        uint256 specialMaxRate;
        uint256 tokenId;
    }
    
    struct BorrowInfo {
        address user;
        uint256 pid;
        uint256 tokenId;
        uint256 borrowValue;
        uint256 auctionValue;
        uint256 amount;
        uint256 repaidAmount;
        uint256 startBowShare;
        uint256 startBlock;
        uint256 returnBlock;
        uint256 interests;
        uint256 state;      //0.init 1.borrowing 2.return 8.settlement 9.overdue
    }
    
    struct CompoundBorrowPool {
        address token;
        address ctoken;
        uint256 curBorrow;
        uint256 curBowRate;
        uint256 lastShareBlock;
        uint256 globalBowShare;
        uint256 globalLendInterestShare;
        uint256 totalMineInterests;
        uint256 overdueRate;
    }
    
    struct Special721Info{
        string name;
        uint256 rate;
    }
    
}
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;



interface IThemisBorrowCompound is IThemisBorrowCompoundStorage{

    function borrowPoolInfo(uint256 pid) external view returns(CompoundBorrowPool memory borrowPool);
    function borrowInfo(uint256 bid) external view returns(BorrowInfo memory borrow);
    function settlementBorrow(uint256 bid) external;
    function doAfterLpTransfer(address ctoken,address sender,address recipient, uint256 amount) external;
    function updateBorrowPool(uint256 pid) external;
    function addBorrowPool(address borrowToken,address ctoken) external;
    function getGlobalLendInterestShare(uint256 pid) external view returns(uint256 globalLendInterestShare);
    function transferInterestToLend(uint256 pid,address toUser,uint256 interests) external;
    function getBorrowingRate(uint256 pid) external view returns(uint256);
    function getLendingRate(uint256 pid) external view returns(uint256);
    function borrowUserInfos(address user,uint256 pid) external view returns(BorrowUserInfo memory borrowUserInfo);
}
pragma solidity ^0.8.0;

interface IThemisLiquidation{
    function disposalNFT(uint256 bid,address erc721,uint256 tokenId,address targetToken) external;
}
pragma solidity ^0.8.0;









contract ThemisAuction is RoleControl,IThemisBorrowCompoundStorage,Initializable{
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Strings for string;
    using EnumerableSet for EnumerableSet.UintSet;
    
    struct AuctionInfo{
        address erc721Addr;
        uint256 tokenId;
        uint256 bid;
        uint256 auctionStartTime;
        address auctionToken;
        address auctionUser;
        uint256 startAuctionValue;
        uint256 startAuctionInterests;
        uint256 saledAmount;
        uint256 latestBidPrice;
        uint state;  // 0 read auction, 1 auctioning,2 auctioned
        uint256 totalBidAmount;
    }
    
    struct AuctionRecord{
        address auctionUser;
        uint256 auctionAmount;
        uint blockTime;
        bool returnPay;
        uint256 mulReduce;
    }

    struct BidAuctionInfo{
        uint256 auctionId;
        address harvestAddress;
        bool harvestFlag;
    }
    
    event ToAuctionEvent(uint256 indexed bid, uint256 indexed tokenId,address erc721Addr,address auctionToken,uint256 startAuctionAmount,uint256 startAuctioInterests);
    event DoAuctionEvent(uint256 indexed bid, uint256 indexed tokenId,uint256 indexed auctionId,uint256 auctionAmount,address userAddr);
    event DoHarvestAuctionEvent(uint256 indexed bid, uint256 indexed tokenId,uint256 indexed auctionId,address userAddr,uint256 bidArid,uint256 bidAmount,uint256 totalBidAmount);
    event AbortiveAuctionEvent(uint256 indexed auctionId,address toAddress);
    event SetActionConfigEvent(address sender,uint256 reductionRatio,uint256 reductionTime,uint256 riskFactor,uint256 onePriceRatio);
    event SetThemisLiquidationEvent(address sender,address themisLiquidation);
    event SetFunderEvent(address indexed sender,address beforeVal,address afterVal);
    event FunderClaimEvent(address indexed sender,address token,uint256 amount);
    event SetStreamingProcessorEvent(address indexed sender,address beforeVal,address afterVal);
    event ChangeUniswapV3OracleEvent(address indexed sender,address beforeVal,address afterVal);
    
    mapping(uint256 => AuctionInfo) public auctionInfos;
    uint256 public reductionTime = 14_400;
    uint256 public reductionRatio = 950;
    uint256 public riskFactor = 975;
    uint256 public onePriceRatio = 950;
    
    
    uint256[] private auctionIds;

    EnumerableSet.UintSet private _holderAuctioningIds;
    EnumerableSet.UintSet private _holderAuctionIds;
    EnumerableSet.UintSet private _holderBidAuctionIds;
    EnumerableSet.UintSet private _holderAuctionSaledIds;
    
    mapping(uint256 => AuctionRecord[]) public auctionRecords;
    
    address public funder;
    IThemisBorrowCompound public borrowCompound;
    IThemisLiquidation public themisLiquidation;
    IUniswapV3Oracle public uniswapV3Oracle;

    mapping(address => uint256) public funderPoolInterest;  //token => amount

    address public streamingProcessor;
    
    modifier onlyBorrowVistor {
        require(address(borrowCompound) == msg.sender, "not borrow vistor allow.");
        _;
    }

    modifier onlyFunderVistor {
        require(funder == msg.sender, "not funder vistor allow.");
        _;
    }
    
    
    function doInitialize(IThemisBorrowCompound _borrowCompound,IUniswapV3Oracle _uniswapV3Oracle,uint256 _reductionTime,uint256 _reductionRatio,uint256 _onePriceRatio,uint256 _riskFactor,address _streamingProcessor) external initializer{
        _governance = msg.sender;
        _grantRole(PAUSER_ROLE, msg.sender);
        borrowCompound = _borrowCompound;
        reductionTime = _reductionTime;
        riskFactor = _riskFactor;
        reductionRatio = _reductionRatio;
        uniswapV3Oracle = _uniswapV3Oracle;
        onePriceRatio = _onePriceRatio;
        streamingProcessor = _streamingProcessor;
    }

    function changeUniswapV3Oracle(address _uniswapV3Oracle) external onlyGovernance{
        address _beforeVal = address(uniswapV3Oracle);
        uniswapV3Oracle  = IUniswapV3Oracle(_uniswapV3Oracle);
        emit ChangeUniswapV3OracleEvent(msg.sender,_beforeVal,_uniswapV3Oracle);
    }
    
    function setActionConfig(uint256 _reductionRatio,uint256 _reductionTime,uint256 _riskFactor,uint256 _onePriceRatio) onlyGovernance external{
        require(_reductionRatio <1_000, "max reductionRatio.");
        require(_onePriceRatio <1_000, "max onePriceRatio.");
        require(_riskFactor <1_000, "max riskFactor.");
        reductionRatio = _reductionRatio;
        riskFactor = _riskFactor;
        onePriceRatio = _onePriceRatio;

        if(_reductionTime > 0 ){
            reductionTime = _reductionTime;
        }
          
        emit SetActionConfigEvent(msg.sender,_reductionRatio,_reductionTime,_riskFactor,_onePriceRatio);
    }

    function setThemisLiquidation(address _themisLiquidation) onlyGovernance external{
        themisLiquidation = IThemisLiquidation(_themisLiquidation);
        emit SetThemisLiquidationEvent(msg.sender,_themisLiquidation);
    }

    function setStreamingProcessor(address _streamingProcessor) external onlyGovernance{
        address _beforeVal = streamingProcessor;
        streamingProcessor = _streamingProcessor;
        emit SetStreamingProcessorEvent(msg.sender,_beforeVal,_streamingProcessor);
    }

    function setFunder(address _funder) external onlyGovernance{
        address _beforeVal = funder;
        funder = _funder;
        emit SetFunderEvent(msg.sender,_beforeVal,_funder);
    }

    
    function funderClaim(address _token,uint256 _amount) external onlyFunderVistor{

        uint256 _totalAmount = funderPoolInterest[_token];
        require(_totalAmount >= _amount,"Wrong amount.");
        funderPoolInterest[_token] = funderPoolInterest[_token].sub(_amount);

        IERC20(_token).safeTransfer(funder,_amount);
        emit FunderClaimEvent(msg.sender,_token,_amount);
    }
    
    function toAuction(address erc721Addr,uint256 tokenId,uint256 bid,address auctionToken,uint256 startAuctionValue,uint256 startAuctionInterests) onlyBorrowVistor external {
        
        uint256 auctionId = auctionIds.length;
        auctionIds.push(auctionId);
        auctionInfos[auctionId] = AuctionInfo({
            erc721Addr:erc721Addr,
            tokenId:tokenId,
            bid:bid,
            auctionStartTime:block.timestamp,
            auctionToken:auctionToken,
            auctionUser:address(0),
            startAuctionValue:startAuctionValue,
            startAuctionInterests:startAuctionInterests,
            saledAmount:0,
            latestBidPrice:0,
            state: 0,
            totalBidAmount: 0
        });
        _holderAuctioningIds.add(auctionId);
        _holderAuctionIds.add(auctionId);
        
        emit ToAuctionEvent(bid,tokenId,erc721Addr,auctionToken,startAuctionValue,startAuctionInterests);
    }
    
    function doAuction(uint256 auctionId,uint256 amount) external nonReentrant whenNotPaused{
        require(_holderAuctioningIds.contains(auctionId),"This auction not exist.");
        (uint256 _auctionAmount,uint256 _onePrice,uint256 _remainTime,uint256 mulReduce,,,) = _getCurrSaleInfo(auctionId);
        require(_remainTime >0,"Over time.");
        
        AuctionInfo storage _auctionInfo = auctionInfos[auctionId];
        require(_auctionInfo.state == 0 || _auctionInfo.state == 1,"This auction state error.");

        require(amount > _auctionInfo.latestBidPrice,"Must be greater than the existing maximum bid.");
        require(amount > _auctionAmount,"Must be greater than the starting price.");
        

        IERC20 _payToken = IERC20(_auctionInfo.auctionToken);
        
        AuctionRecord[] storage _auctionRecords = auctionRecords[auctionId];
        _auctionRecords.push(AuctionRecord({
            auctionUser: msg.sender,
            auctionAmount: amount,
            blockTime: block.timestamp,
            returnPay: false,
            mulReduce: mulReduce
        }));
        
        _auctionInfo.latestBidPrice = amount;
        _auctionInfo.state = 1;
        _auctionInfo.totalBidAmount =  _auctionInfo.totalBidAmount.add(amount);
        
        if(!_holderBidAuctionIds.contains(auctionId)){
            _holderBidAuctionIds.add(auctionId);
        }
        
        
        _payToken.safeTransferFrom(msg.sender,address(this),amount);
        
        if(_auctionRecords.length > 1){
            AuctionRecord storage _returnRecord = _auctionRecords[_auctionRecords.length-2];
            if(!_returnRecord.returnPay ){
                _returnRecord.returnPay = true;
                _payToken.safeTransfer(_returnRecord.auctionUser,_returnRecord.auctionAmount);
            }
        }
        
        if(amount >= _onePrice){
            _doHarvestAuction(auctionId,true);
        }
        
        emit DoAuctionEvent(_auctionInfo.bid,_auctionInfo.tokenId,auctionId,amount,msg.sender);
    }
    function doHarvestAuction(uint256 auctionId) external nonReentrant whenNotPaused{
        _doHarvestAuction(auctionId,false);
    }
    
    function _doHarvestAuction(uint256 auctionId,bool onePriceFlag) private{
        require(_holderAuctioningIds.contains(auctionId),"This auction not exist.");
        AuctionInfo storage _auctionInfo = auctionInfos[auctionId];
        require(_auctionInfo.state == 1,"Error auction state.");
        
        AuctionRecord[] memory _auctionRecords = auctionRecords[auctionId]; 
        
        (uint256 _maxBidArid,uint256 _maxBidAmount,uint256 _totalBidAmount,bool _harvestFlag,) = _getHarvestAuction(auctionId);
        require(_harvestFlag || onePriceFlag,"Not harverst in time.");
        
     
            
        AuctionRecord memory _auctionRecord = _auctionRecords[_maxBidArid];
        if(_auctionRecords.length > 0){
            
            require(_auctionRecord.auctionUser == msg.sender,"This auction does not belong to you.");
            require(_auctionRecord.returnPay == false,"This auction has been refunded.");
            
            IERC20 _payToken = IERC20(_auctionInfo.auctionToken);
            _auctionInfo.auctionUser = msg.sender;
            _auctionInfo.saledAmount = _auctionRecord.auctionAmount;
            _auctionInfo.state = 2;
            
            _holderAuctioningIds.remove(auctionId);
            _holderBidAuctionIds.remove(auctionId);
            _holderAuctionSaledIds.add(auctionId);
            
            
            BorrowInfo memory borrow = borrowCompound.borrowInfo(_auctionInfo.bid);    
            uint256 _returnAmount = borrow.amount.add(borrow.interests);
            
            if(_auctionRecord.auctionAmount > _returnAmount){
                uint256 _funderAmount = _auctionRecord.auctionAmount.sub(_returnAmount);
                funderPoolInterest[_auctionInfo.auctionToken] = funderPoolInterest[_auctionInfo.auctionToken].add(_funderAmount);
            }
            _payToken.safeApprove(address(borrowCompound),0);
            _payToken.safeApprove(address(borrowCompound),_returnAmount);
            borrowCompound.settlementBorrow(_auctionInfo.bid);
            
            IERC721(_auctionInfo.erc721Addr).transferFrom(address(this), msg.sender, _auctionInfo.tokenId);

        }
        
        emit DoHarvestAuctionEvent(_auctionInfo.bid,_auctionInfo.tokenId,auctionId,msg.sender,_maxBidArid,_maxBidAmount,_totalBidAmount);
    }
    
    

    function abortiveAuction(uint256 auctionId) external nonReentrant whenNotPaused{
        require(_holderAuctioningIds.contains(auctionId),"This auction not exist.");
        (uint256 _auctionAmount,,,, bool _bidFlag,,) = _getCurrSaleInfo(auctionId);
        require(_auctionAmount == 0,"In time.");
        require(!_bidFlag,"already bid.");
        
        
        AuctionInfo storage _auctionInfo = auctionInfos[auctionId];
        _auctionInfo.state = 9;
        
        _holderAuctioningIds.remove(auctionId);
        _holderBidAuctionIds.remove(auctionId);
        address _processor;
        if(address(themisLiquidation) == address(0)){
            require(streamingProcessor != address(0),"streamingProcessor address not config.");
            _processor = streamingProcessor;
            IERC721(_auctionInfo.erc721Addr).transferFrom(address(this), streamingProcessor, _auctionInfo.tokenId);
        }else{
            _processor = address(themisLiquidation);
            IERC721(_auctionInfo.erc721Addr).approve(_processor,_auctionInfo.tokenId);
            themisLiquidation.disposalNFT(_auctionInfo.bid,_auctionInfo.erc721Addr, _auctionInfo.tokenId,_auctionInfo.auctionToken);
        }
        
        
        emit AbortiveAuctionEvent(auctionId,_processor);
    }
    
    
    function getHolderAuctionIds() external view returns (uint256[] memory) {
        uint256[] memory actionIds = new uint256[](_holderAuctionIds.length());
        for (uint256 i = 0; i < _holderAuctionIds.length(); i++) {
            actionIds[i] = _holderAuctionIds.at(i);
        }
        return actionIds;
    }
    
    function getAuctioningIds() external view returns (uint256[] memory) {
        uint256[] memory actionIds = new uint256[](_holderAuctioningIds.length());
        for (uint256 i = 0; i < _holderAuctioningIds.length(); i++) {
            actionIds[i] = _holderAuctioningIds.at(i);
        }
        return actionIds;
    }
    
    function getBidAuctioningIds() external view returns (uint256[] memory) {
        uint256[] memory actionIds = new uint256[](_holderBidAuctionIds.length());
        for (uint256 i = 0; i < _holderBidAuctionIds.length(); i++) {
            actionIds[i] = _holderBidAuctionIds.at(i);
        }
        return actionIds;
    }
    
    function getUserBidAuctioningIds(address user) public view returns (uint256[] memory) {
        uint256[] memory _actionIdsTmp = new uint256[](_holderBidAuctionIds.length());
        uint _length = 0;
        uint256 _maximum = ~ uint256(0);
        for (uint256 i = 0; i < _holderBidAuctionIds.length(); i++) {
            uint256 _bidAuctionId = _holderBidAuctionIds.at(i);
            AuctionRecord[] memory _auctionRecords = auctionRecords[_bidAuctionId]; 
            bool _flag = false;
            for(uint256 _arId = 0; _arId < _auctionRecords.length; ++_arId){
                if(_auctionRecords[_arId].auctionUser == user){
                    _actionIdsTmp[i] = _bidAuctionId;
                    _length = _length+1;
                    _flag = true;
                    break;
                }
            }
            
            if(!_flag){
                _actionIdsTmp[i] =_maximum;
            }
        }
        
         uint256[] memory _actionIds = new uint256[](_length);
         uint _k = 0;
         for(uint256 j=0;j<_actionIdsTmp.length;j++){
             if(_actionIdsTmp[j]!=_maximum){
                 _actionIds[_k]=_actionIdsTmp[j];
                 _k = _k+1;
             }
         }
         
        return _actionIds;
    }
    
    
    function getUserBidAuctioningInfos(address user) external view returns (BidAuctionInfo[] memory ) {
        
        uint256[] memory _actionIds = getUserBidAuctioningIds(user);
        BidAuctionInfo[] memory _bidAuctionInfo = new BidAuctionInfo[](_actionIds.length);
        for (uint256 i = 0; i < _actionIds.length; i++) {
            uint256 _bidAuctionId = _actionIds[i];
            (,,,bool _harvestFlag,address _harvestAddress) = _getHarvestAuction(_bidAuctionId);
            _bidAuctionInfo[i].auctionId = _bidAuctionId;
            _bidAuctionInfo[i].harvestAddress = _harvestAddress;
            _bidAuctionInfo[i].harvestFlag = _harvestFlag;

        }
        return _bidAuctionInfo;
    }
    
    
    function getCurrSaleInfo (uint256 auctionId) external view returns(uint256 amount,uint256 onePrice,uint256 remainTime,uint256 mulReduce,bool bidFlag){
        (amount,onePrice,remainTime,mulReduce,bidFlag,,) = _getCurrSaleInfo(auctionId);
    }
    
    function getCurrSaleInfoV2 (uint256 auctionId) external view returns(uint256 amount,uint256 onePrice,uint256 remainTime,uint256 mulReduce,bool bidFlag,bool harvestFlag,address harvestAddress){
        (amount,onePrice,remainTime,mulReduce,bidFlag,harvestFlag,harvestAddress) = _getCurrSaleInfo(auctionId);
    }
    
    function getHarvestAuction(uint256 auctionId) external view returns(uint256 maxBidArid,uint256 maxBidAmount,uint256 totalBidAmount){
        (maxBidArid,maxBidAmount,totalBidAmount,,) = _getHarvestAuction(auctionId);
    }
    
    function getHarvestAuctionV2(uint256 auctionId) external view returns(uint256 maxBidArid,uint256 maxBidAmount,uint256 totalBidAmount,bool harvestFlag,address harvestAddress){
        (maxBidArid,maxBidAmount,totalBidAmount,harvestFlag,harvestAddress) = _getHarvestAuction(auctionId);
    }
    
    function getAuctionRecordLength(uint256 auctionId) external view returns(uint256 length){
        AuctionRecord[] memory _auctionRecords = auctionRecords[auctionId]; 
        length = _auctionRecords.length;
    }
    

    function _getCurrSaleInfo(uint256 auctionId) internal view returns(uint256 amount,uint256 onePrice,uint256 remainTime,uint256 mulReduce,bool bidFlag,bool harvestFlag,address harvestAddress){
        require(_holderAuctioningIds.contains(auctionId),"This auction not exist.");
        
        AuctionInfo memory _auctionInfo = auctionInfos[auctionId];
        bidFlag = (_auctionInfo.state == 1);

        uint256 _startValue = _auctionInfo.startAuctionValue.add(_auctionInfo.startAuctionInterests);


        uint256 _diffTime = uint256(block.timestamp).sub(_auctionInfo.auctionStartTime);
        if(!bidFlag){
            mulReduce = _diffTime.div(reductionTime);
            amount = _calAuctionPriceByRiskFactor(_auctionInfo,_startValue,mulReduce);
            if(amount > 0){
                remainTime = reductionTime.sub(_diffTime.sub(reductionTime.mul(mulReduce)));
                onePrice = _calOnePrice(amount);
            }

        }else{
            AuctionRecord memory _lastAuctionRecord = _getLastAuctionRecord(auctionId);
            require(_lastAuctionRecord.auctionUser != address(0),"Auction record error.");
            amount = _lastAuctionRecord.auctionAmount;
            mulReduce = _lastAuctionRecord.mulReduce;

            uint256 _auctionNextTime = _auctionInfo.auctionStartTime + (mulReduce+1)*reductionTime;
            if(_auctionNextTime > block.timestamp ){
                remainTime = _auctionNextTime - _lastAuctionRecord.blockTime;
                onePrice = _calOnePrice(_calAuctionPrice(_startValue,mulReduce));
            }else{
                harvestFlag == true;
                harvestAddress = _lastAuctionRecord.auctionUser;
            }
        }
    }

    function _calOnePrice(uint256 auctionPrice) internal view returns(uint256 onePrice){
        onePrice = auctionPrice.mul(1_000).div(onePriceRatio);
    }

    function _calAuctionPriceByRiskFactor(AuctionInfo memory auctionInfo,uint256 startValue,uint256 mulReduce) internal view returns(uint256 auctionPrice){
        auctionPrice = _calAuctionPrice(startValue,mulReduce);
        if(auctionPrice > 0){
            if(!_checkCanAuction(auctionInfo,auctionPrice)){
                auctionPrice = 0;
            }
        }
    }

    function _calAuctionPrice(uint256 startValue,uint256 mulReduce) internal view returns(uint256 auctionPrice){
        auctionPrice = startValue*1_000*reductionRatio**mulReduce/(1_000**mulReduce)/1_000;
    } 

    function _checkCanAuction(AuctionInfo memory auctionInfo,uint256 auctionPrice) internal view returns(bool _canSell){
        
        (uint256 _nftCurrValue,) = uniswapV3Oracle.getTWAPQuoteNft(auctionInfo.tokenId, auctionInfo.auctionToken);
        BorrowInfo memory _borrow = borrowCompound.borrowInfo(auctionInfo.bid);

        uint256 _needRepay = _borrow.amount.add(_borrow.interests).mul(1_000);

        if(_needRepay.div(auctionPrice) < riskFactor && _needRepay.div(_nftCurrValue) < riskFactor ){
            _canSell = true;
        }

    }

    function _getLastAuctionRecord(uint256 auctionId) internal view returns(AuctionRecord memory lastAuctionRecord){
        AuctionRecord[] memory _auctionRecords = auctionRecords[auctionId]; 
        if(_auctionRecords.length > 0){
            lastAuctionRecord = _auctionRecords[_auctionRecords.length-1];
        }
    }
    
    function _getHarvestAuction(uint256 auctionId) internal view returns(uint256 maxBidArid,uint256 maxBidAmount,uint256 totalBidAmount,bool harvestFlag,address harvestAddress){
        AuctionInfo memory _auctionInfo = auctionInfos[auctionId];
        totalBidAmount = _auctionInfo.totalBidAmount;
        if(_auctionInfo.state == 1){
            AuctionRecord[] memory _auctionRecords = auctionRecords[auctionId]; 
            if(_auctionRecords.length > 0){
                maxBidArid = _auctionRecords.length-1;
                AuctionRecord memory _lastAuctionRecord = _auctionRecords[maxBidArid];
                maxBidAmount = _lastAuctionRecord.auctionAmount;
                uint256 _auctionNextTime = _auctionInfo.auctionStartTime + (_lastAuctionRecord.mulReduce+1)*reductionTime;
                if(_auctionNextTime < block.timestamp ){
                    harvestFlag = true;
                    harvestAddress = _lastAuctionRecord.auctionUser;
                }
            }
            
        }
    }
    
    
}