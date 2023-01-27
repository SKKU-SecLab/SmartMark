
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


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

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

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

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function baseURI() public view virtual returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
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

        return _tokenOwners.contains(tokenId);
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

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

pragma solidity >=0.6.0 <0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity >=0.6.0 <0.8.0;


contract Waifu is ERC721, Ownable {
    uint256 constant public MAX_SUPPLY = 2048;

    uint256 constant public SET_STATUS_PRICE = 1000000000000000; // 0.001 ETH
    uint256 constant public LIKE_PRICE = 1000000000000000; // 0.001 ETH

    uint256 constant private _BASE_SET_NAME_PRICE = 1000000000000000000; // 1 ETH
    uint256 constant private _SET_NAME_PRICE_DISCOUNT_PER_LIKE = 10000000000000000; // 0.01 ETH
    uint256 constant private _SET_NAME_PRICE_DISCOUNT_MAX_LIKES = 100;

    uint256 constant private _BASE_LEVEL = 1;
    uint256 constant private _MAX_LEVEL = 6;
    mapping(uint256 => uint256) private _LEVEL_DURATION;

    string private _baseURI = "https://waifu.art/";

    mapping(uint256 => string) private _statuses;
    mapping(uint256 => string) private _names;
    mapping(string => uint256) private _nameIndex;

    mapping(uint256 => uint256) private _likes;
    mapping(uint256 => mapping(address => bool)) _likesIndex;

    mapping(uint256 => uint256) private _levels;
    mapping(uint256 => uint256) private _steps;
    mapping(uint256 => uint256) private _lastStepTime;
    mapping(uint256 => mapping(address => bool)) private _way;

    mapping(address => bool) private _promo;

    event Like(uint256 indexed tokenId, address from, uint256 likes);
    event LevelUp(uint256 indexed tokenId, uint256 level);
    event SetName(uint256 indexed tokenId, string name);
    event SetStatus(uint256 indexed tokenId, string status);

    constructor() ERC721("Waifu", "WFU") Ownable() public {
        _LEVEL_DURATION[1] = 86400 * 2;
        _LEVEL_DURATION[2] = 86400 * 4;
        _LEVEL_DURATION[3] = 86400 * 8;
        _LEVEL_DURATION[4] = 86400 * 16;
        _LEVEL_DURATION[5] = 86400 * 32;
    }

    function getMintPrice() public view returns (uint256) {
        uint256 currentSupply = totalSupply();
        require(currentSupply < MAX_SUPPLY, "Waifu: there are no more waifus here");

        if (currentSupply >= 2040) {
            return 4000000000000000000;
        } else if (currentSupply >= 2024) {
            return 2000000000000000000;
        } else if (currentSupply >= 1992) {
            return 1000000000000000000;
        } else if (currentSupply >= 1928) {
            return 800000000000000000;
        } else if (currentSupply >= 1800) {
            return 400000000000000000;
        } else if (currentSupply >= 1544) {
            return 200000000000000000;
        } else if (currentSupply >= 1032) {
            return 100000000000000000;
        } else if (currentSupply >= 8) {
            return 50000000000000000;
        } else {
            return 0;
        }
    }

    function isPromoAvailable(address from) public view returns (bool) {
        uint256 mintPrice = getMintPrice();
        return mintPrice == 0 && !_promo[from];
    }

    function getSetNamePrice(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        uint256 level = getLevel(tokenId);
        require(level == _MAX_LEVEL, "Waifu: your waifu needs to reach max level to be named");

        return _BASE_SET_NAME_PRICE - (Math.min(getLikes(tokenId), _SET_NAME_PRICE_DISCOUNT_MAX_LIKES) * _SET_NAME_PRICE_DISCOUNT_PER_LIKE);
    }

    function withdraw() onlyOwner public {
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    function setBaseURI(string memory baseURI) onlyOwner public {
        _baseURI = baseURI;
    }

    function _mint(address to, uint256 tokenId) internal override {
        super._mint(to, tokenId);
        if (_levels[tokenId] == 0) {
            _levels[tokenId] = _BASE_LEVEL;
        }
        _steps[tokenId] = _steps[tokenId] + 1;
        _lastStepTime[tokenId] = block.timestamp;
        _way[tokenId][to] = true;
    }

    function _transfer(address from, address to, uint256 tokenId) internal override {
        super._transfer(from, to, tokenId);
        if (!_way[tokenId][to]) {
            _steps[tokenId] = _steps[tokenId] + 1;
            _lastStepTime[tokenId] = block.timestamp;
            _way[tokenId][to] = true;
        }
    }

    function getLevel(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        return _levels[tokenId];
    }

    function getAvailableLevel(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        uint256 level = Math.min(_MAX_LEVEL, _steps[tokenId]);
        if (level < _MAX_LEVEL) {
            uint256 timeFrom = _lastStepTime[tokenId];
            uint256 additionalLevels = 0;
            for (uint256 currentLevel = level; currentLevel < _MAX_LEVEL; currentLevel++) {
                if (timeFrom + _LEVEL_DURATION[currentLevel] < block.timestamp) {
                    additionalLevels++;
                    timeFrom = timeFrom + _LEVEL_DURATION[currentLevel];
                }
            }
            level = Math.min(_MAX_LEVEL, level + additionalLevels);
        }
        return level;
    }

    function getNextAvailableLevelTimestamp(uint256 tokenId) public view returns (uint256) {
        uint256 availableLevel = getAvailableLevel(tokenId);
        require(availableLevel < _MAX_LEVEL, "Waifu: maximum available level reached");
        uint256 timeFrom = _lastStepTime[tokenId];
        for (uint256 currentLevel = availableLevel; currentLevel < _MAX_LEVEL; currentLevel++) {
            if (timeFrom + _LEVEL_DURATION[currentLevel] < block.timestamp) {
                timeFrom = timeFrom + _LEVEL_DURATION[currentLevel];
            } else {
                return timeFrom + _LEVEL_DURATION[currentLevel];
            }
        }
    }

    function levelUp(uint256 tokenId, uint256 level) public {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        require(ownerOf(tokenId) == msg.sender, "Waifu: you can upgrade only waifu you own");
        uint256 currentLevel = getLevel(tokenId);
        require(level <= _MAX_LEVEL, "Waifu: wrong level");
        require(level >= _BASE_LEVEL, "Waifu: wrong level");
        require(level > currentLevel, "Waifu: you can not decrease level of your waifu");
        uint256 availableLevel = getAvailableLevel(tokenId);
        require(level <= availableLevel, "Waifu: this level is not available for your waifu");
        _levels[tokenId] = level;
        emit LevelUp(tokenId, level);
    }

    function getTop() public view returns (uint256[] memory) {
        uint256 currentSupply = totalSupply();
        uint256[] memory likes = new uint256[](currentSupply + 1);
        for (uint256 tokenId = 1; tokenId <= currentSupply; tokenId++) {
            likes[tokenId] = _likes[tokenId];
        }
        return likes;
    }

    function getLikes(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        return _likes[tokenId];
    }

    function isLikeAvailable(uint256 tokenId, address from) public view returns (bool) {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        return ownerOf(tokenId) != from && !_likesIndex[tokenId][from];
    }

    function like(uint256 tokenId) public payable {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        require(ownerOf(tokenId) != msg.sender, "Waifu: you can not like your own waifu");
        require(isLikeAvailable(tokenId, msg.sender), "Waifu: you have already liked this waifu");
        require(msg.value >= LIKE_PRICE, "Waifu: not enough ether to like");

        _likesIndex[tokenId][msg.sender] = true;
        _likes[tokenId] = _likes[tokenId] + 1;
        emit Like(tokenId, msg.sender, _likes[tokenId]);
    }

    function setStatus(uint256 tokenId, string memory status) public payable {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        require(ownerOf(tokenId) == msg.sender, "Waifu: you can set status only for waifu you own");
        require(msg.value >= SET_STATUS_PRICE, "Waifu: not enough ether to set status");

        _statuses[tokenId] = status;
        emit SetStatus(tokenId, status);
    }

    function getStatus(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        return _statuses[tokenId];
    }

    function getName(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        return _names[tokenId];
    }

    function isNameAvailable(string memory name) public view returns (bool) {
        return validateName(name) && _nameIndex[toLower(name)] == 0;
    }

    function toLower(string memory str) public pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function validateName(string memory name) public pure returns (bool) {
        bytes memory b = bytes(name);
        if (b.length < 1) return false;
        if (b.length > 25) return false;
        if (b[0] == 0x20) return false;
        if (b[b.length - 1] == 0x20) return false;

        bytes1 lastChar = b[0];
        bool onlyNumbers = true;

        for (uint i; i < b.length; i++) {
            bytes1 char = b[i];

            if (char == 0x20 && lastChar == 0x20) return false;

            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
            !(char >= 0x41 && char <= 0x5A) && //A-Z
            !(char >= 0x61 && char <= 0x7A) && //a-z
            !(char == 0x20) //space
            ) {
                return false;
            }

            if (!(char >= 0x30 && char <= 0x39)) {
                onlyNumbers = false;
            }

            lastChar = char;
        }

        if (onlyNumbers) {
            return false;
        }

        return true;
    }

    function setName(uint256 tokenId, string memory name) public payable {
        require(_exists(tokenId), "Waifu: this waifu does not exists");
        require(ownerOf(tokenId) == msg.sender, "Waifu: you can name only waifu you own");
        require(sha256(bytes(_names[tokenId])) == sha256(bytes("")), "Waifu: your waifu already has a name");
        require(validateName(name), "Waifu: invalid name");
        require(isNameAvailable(name), "Waifu: this name is already taken");
        require(msg.value >= getSetNamePrice(tokenId), "Waifu: not enough ether to name your waifu");

        _names[tokenId] = name;
        _nameIndex[toLower(name)] = tokenId;
        emit SetName(tokenId, name);
    }

    function getTokenIdByName(string memory name) public view returns (uint256) {
        uint256 tokenId = _nameIndex[toLower(name)];
        require(tokenId != 0, "Waifu: there is no waifu with such name");
        return tokenId;
    }

    function bytes32ToString(bytes32 x) private pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory resultBytes = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            resultBytes[j] = bytesString[j];
        }

        return string(resultBytes);
    }

    function uintToBytes(uint v) private pure returns (bytes32 ret) {
        if (v == 0) {
            ret = "0";
        }
        else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    function uintToString(uint v) private pure returns (string memory) {
        return bytes32ToString(uintToBytes(v));
    }

    function bytes32ToHex(bytes32 input) internal pure returns (string memory) {
        uint256 number = uint256(input);
        bytes memory numberAsString = new bytes(66); // "0x" and then 2 chars per byte
        numberAsString[0] = byte(uint8(48));  // '0'
        numberAsString[1] = byte(uint8(120)); // 'x'

        for (uint256 n = 0; n < 32; n++) {
            uint256 nthByte = number / uint256(uint256(2) ** uint256(248 - 8 * n));

            uint8 hex1 = uint8(nthByte) / uint8(16);
            uint8 hex2 = uint8(nthByte) % uint8(16);

            hex1 += (hex1 > 9) ? 87 : 48; // shift into proper ascii value
            hex2 += (hex2 > 9) ? 87 : 48; // shift into proper ascii value
            numberAsString[2 * n + 2] = byte(hex1);
            numberAsString[2 * n + 3] = byte(hex2);
        }
        return string(numberAsString);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        uint256 level = getLevel(tokenId);
        string memory hash = bytes32ToHex(sha256(abi.encodePacked(uintToString(tokenId), "_", uintToString(level))));
        return string(abi.encodePacked(_baseURI, hash, ".json"));
    }

    function mint() public payable {
        uint256 currentSupply = totalSupply();
        uint256 mintPrice = getMintPrice();
        require(msg.value >= mintPrice, "Waifu: current waifu price is already higher");
        require(mintPrice > 0 || !_promo[msg.sender], "Waifu: only one free waifu per address");
        uint256 waifuId = currentSupply + 1;
        _mint(msg.sender, waifuId);
        if (mintPrice == 0) {
            _promo[msg.sender] = true;
        }
    }

    receive() external payable {
        mint();
    }
}