
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

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping(address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor(string memory name_, string memory symbol_) public {
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

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {

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

        require(
            _msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
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

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

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

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            ERC721.isApprovedForAll(owner, spender));
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

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata =
            to.functionCall(
                abi.encodeWithSelector(
                    IERC721Receiver(to).onERC721Received.selector,
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                ),
                "ERC721: transfer to non ERC721Receiver implementer"
            );
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// AGPL-3.0-or-later

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

interface ILife {
    struct Listing {
        bool isForSale;
        uint256 bioId;
        address seller;
        uint256 minValue;
        address onlySellTo;
        uint256 timestamp;
    }

    struct Bid {
        bool hasBid;
        uint256 bioId;
        address bidder;
        uint256 value;
        uint256 timestamp;
    }

    event BioMinted(uint256 indexed bioId, address indexed owner, uint8[] bioDNA, bytes32 bioHash);
    event BioListed(
        uint256 indexed bioId,
        uint256 minValue,
        address indexed fromAddress,
        address indexed toAddress
    );
    event BioDelisted(uint256 indexed bioId, address indexed fromAddress);
    event BioBidEntered(uint256 indexed bioId, uint256 value, address indexed fromAddress);
    event BioBidWithdrawn(uint256 indexed bioId, uint256 value, address indexed fromAddress);
    event BioBidRemoved(uint256 indexed bioId, address indexed fromAddress);
    event BioBought(
        uint256 indexed bioId,
        uint256 value,
        address indexed fromAddress,
        address indexed toAddress
    );
    event BioBidAccepted(
        uint256 indexed bioId,
        uint256 value,
        address indexed fromAddress,
        address indexed toAddress
    );

    function getBioDNA(uint256 bioId) external view returns (uint8[] memory);

    function getBioDNAs(uint256 from, uint256 size) external view returns (uint8[][] memory);

    function getBioPrice() external view returns (uint256);

    function isBioExist(uint8[] memory bioDNA) external view returns (bool);

    function mintBio(uint8[] memory bioDNA) external payable;

    function getBioListing(uint256 bioId) external view returns (Listing memory);

    function getBioListings(uint256 from, uint256 size) external view returns (Listing[] memory);

    function getBioBid(uint256 bioId) external view returns (Bid memory);

    function getBioBids(uint256 from, uint256 size) external view returns (Bid[] memory);

    function listBioForSale(uint256 bioId, uint256 minValue) external;

    function listBioForSaleToAddress(
        uint256 bioId,
        uint256 minValue,
        address toAddress
    ) external;

    function delistBio(uint256 bioId) external;

    function buyBio(uint256 bioId) external payable;

    function enterBidForBio(uint256 bioId) external payable;

    function acceptBidForBio(uint256 bioId) external;

    function withdrawBidForBio(uint256 bioId) external;

    function serviceFee() external view returns (uint8, uint8);

    function pendingWithdrawals(address toAddress) external view returns (uint256);

    function withdraw() external;
}// AGPL-3.0-or-later

pragma solidity =0.6.12;


contract Life is ILife, ERC721, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    constructor(string memory name_, string memory symbol_) public ERC721(name_, symbol_) {}

    uint256 public constant SALE_START_TIMESTAMP = 1616247000;

    uint256 public constant MAX_NFT_SUPPLY = 10000;

    mapping(address => uint256) private _pendingWithdrawals;
    mapping(uint256 => uint8[]) private _bioDNAById;
    mapping(bytes32 => bool) private _bioExistanceByHash;

    uint8 private _feeFraction = 1;
    uint8 private _feeBase = 100;
    mapping(uint256 => Listing) private _bioListedForSale;
    mapping(uint256 => Bid) private _bioWithBids;

    function getBioDNA(uint256 bioId) external view override returns (uint8[] memory) {
        return _bioDNAById[bioId];
    }

    function getBioDNAs(uint256 from, uint256 size)
        external
        view
        override
        returns (uint8[][] memory)
    {
        uint256 endBioIndex = from + size;
        require(endBioIndex <= totalSupply(), "Requesting too many Bios");

        uint8[][] memory bios = new uint8[][](size);
        for (uint256 i; i < size; i++) {
            bios[i] = _bioDNAById[i + from];
        }
        return bios;
    }

    function getBioPrice() public view override returns (uint256) {
        require(block.timestamp >= SALE_START_TIMESTAMP, "Sale has not started");
        require(totalSupply() < MAX_NFT_SUPPLY, "Sale has already ended");

        uint256 currentSupply = totalSupply();

        if (currentSupply > 9900) {
            return 100000000000000000000; // 9901 - 10000 100 BNB
        } else if (currentSupply > 9500) {
            return 20000000000000000000; // 9501 - 9900 20 BNB
        } else if (currentSupply > 8500) {
            return 10000000000000000000; // 8501  - 9500 10 BNB
        } else if (currentSupply > 4500) {
            return 8000000000000000000; // 4501 - 8500 8 BNB
        } else if (currentSupply > 2500) {
            return 6000000000000000000; // 2501 - 4500 6 BNB
        } else if (currentSupply > 1000) {
            return 4000000000000000000; // 1001 - 2500 4 BNB
        } else if (currentSupply > 100) {
            return 2000000000000000000; // 101 - 1000 2 BNB
        } else {
            return 1000000000000000000; // 0 - 100 1 BNB
        }
    }

    function isBioExist(uint8[] memory bioDNA) external view override returns (bool) {
        bytes32 bioHashOriginal = keccak256(abi.encodePacked(bioDNA));

        return _bioExistanceByHash[bioHashOriginal];
    }

    function mintBio(uint8[] memory bioDNA) external payable override {
        require(totalSupply() < MAX_NFT_SUPPLY, "Sale has already ended");
        require(totalSupply().add(1) <= MAX_NFT_SUPPLY, "Exceeds MAX_NFT_SUPPLY");
        require(getBioPrice() == msg.value, "Ether value sent is not correct");

        bytes32 bioHash = keccak256(abi.encodePacked(bioDNA));
        require(!_bioExistanceByHash[bioHash], "Bio already existed");

        uint256 activeCellCount = 0;
        uint256 totalCellCount = 0;
        for (uint8 i = 0; i < bioDNA.length; i++) {
            totalCellCount = totalCellCount.add(bioDNA[i]);
            if (i % 2 == 1) {
                activeCellCount = activeCellCount.add(bioDNA[i]);
            }
        }

        require(totalCellCount <= 289, "Total cell count should be smaller than 289");
        require(
            activeCellCount >= 5 && activeCellCount <= 48,
            "Active cell count of Bio is not allowed"
        );

        uint256 mintIndex = totalSupply();

        _bioExistanceByHash[bioHash] = true;
        _bioDNAById[mintIndex] = bioDNA;
        _safeMint(msg.sender, mintIndex);
        _pendingWithdrawals[owner()] = _pendingWithdrawals[owner()].add(msg.value);

        emit BioMinted(mintIndex, msg.sender, bioDNA, bioHash);
    }

    modifier saleEnded() {
        require(totalSupply() >= MAX_NFT_SUPPLY, "Bio sale still going");
        _;
    }

    modifier bioExist(uint256 bioId) {
        require(bioId < totalSupply(), "Bio doesn't exist");
        _;
    }

    modifier isBioOwner(uint256 bioId) {
        require(ownerOf(bioId) == msg.sender, "Not the owner of this Bio");
        _;
    }

    function getBioListing(uint256 bioId) external view override returns (Listing memory) {
        return _bioListedForSale[bioId];
    }

    function getBioListings(uint256 from, uint256 size)
        external
        view
        override
        returns (Listing[] memory)
    {
        uint256 endBioIndex = from + size;
        require(endBioIndex <= totalSupply(), "Requesting too many listings");

        Listing[] memory listings = new Listing[](size);
        for (uint256 i; i < size; i++) {
            listings[i] = _bioListedForSale[i + from];
        }
        return listings;
    }

    function getBioBid(uint256 bioId) external view override returns (Bid memory) {
        return _bioWithBids[bioId];
    }

    function getBioBids(uint256 from, uint256 size) external view override returns (Bid[] memory) {
        uint256 endBioIndex = from + size;
        require(endBioIndex <= totalSupply(), "Requesting too many bids");

        Bid[] memory bids = new Bid[](size);
        for (uint256 i; i < totalSupply(); i++) {
            bids[i] = _bioWithBids[i + from];
        }
        return bids;
    }

    function listBioForSale(uint256 bioId, uint256 minValue)
        external
        override
        saleEnded
        bioExist(bioId)
        isBioOwner(bioId)
    {
        _bioListedForSale[bioId] = Listing(
            true,
            bioId,
            msg.sender,
            minValue,
            address(0),
            block.timestamp
        );
        emit BioListed(bioId, minValue, msg.sender, address(0));
    }

    function listBioForSaleToAddress(
        uint256 bioId,
        uint256 minValue,
        address toAddress
    ) external override saleEnded bioExist(bioId) isBioOwner(bioId) {
        _bioListedForSale[bioId] = Listing(
            true,
            bioId,
            msg.sender,
            minValue,
            toAddress,
            block.timestamp
        );
        emit BioListed(bioId, minValue, msg.sender, toAddress);
    }

    function _delistBio(uint256 bioId) private saleEnded bioExist(bioId) {
        emit BioDelisted(bioId, _bioListedForSale[bioId].seller);
        delete _bioListedForSale[bioId];
    }

    function _removeBid(uint256 bioId) private saleEnded bioExist(bioId) {
        emit BioBidRemoved(bioId, _bioWithBids[bioId].bidder);
        delete _bioWithBids[bioId];
    }

    function delistBio(uint256 bioId) external override isBioOwner(bioId) {
        require(_bioListedForSale[bioId].isForSale, "Bio is not for sale");
        _delistBio(bioId);
    }

    function _sendValue(address receiver, uint256 value) private {
        if (receiver.isContract() && receiver != msg.sender) {
            _pendingWithdrawals[receiver] = value;
        } else {
            Address.sendValue(payable(receiver), value);
        }
    }

    function buyBio(uint256 bioId)
        external
        payable
        override
        saleEnded
        bioExist(bioId)
        nonReentrant
    {
        Listing memory listing = _bioListedForSale[bioId];

        require(listing.isForSale, "Bio is not for sale");
        require(
            listing.onlySellTo == address(0) || listing.onlySellTo == msg.sender,
            "Bio is not selling to this address"
        );
        require(ownerOf(bioId) == listing.seller, "This seller is not the owner");
        require(msg.sender != ownerOf(bioId), "This Bio belongs to this address");

        uint256 fees = listing.minValue.mul(_feeFraction).div(_feeBase);
        require(
            msg.value >= listing.minValue + fees,
            "The value send is below sale price plus fees"
        );

        uint256 valueWithoutFees = msg.value.sub(fees);

        _sendValue(ownerOf(bioId), valueWithoutFees);
        _pendingWithdrawals[owner()] = _pendingWithdrawals[owner()].add(fees);
        emit BioBought(bioId, valueWithoutFees, listing.seller, msg.sender);

        _safeTransfer(ownerOf(bioId), msg.sender, bioId, "");

        _delistBio(bioId);

        Bid memory existingBid = _bioWithBids[bioId];
        if (existingBid.bidder == msg.sender) {
            _sendValue(msg.sender, existingBid.value);
            _removeBid(bioId);
        }
    }

    function enterBidForBio(uint256 bioId)
        external
        payable
        override
        saleEnded
        bioExist(bioId)
        nonReentrant
    {
        require(ownerOf(bioId) != address(0), "This Bio has been burnt");
        require(ownerOf(bioId) != msg.sender, "Owner of Bio doesn't need to bid");
        require(msg.value != 0, "The bid price is too low");

        Bid memory existingBid = _bioWithBids[bioId];
        require(msg.value > existingBid.value, "The bid price is no higher than existing one");

        if (existingBid.value > 0) {
            _sendValue(existingBid.bidder, existingBid.value);
        }
        _bioWithBids[bioId] = Bid(true, bioId, msg.sender, msg.value, block.timestamp);
        emit BioBidEntered(bioId, msg.value, msg.sender);
    }

    function acceptBidForBio(uint256 bioId)
        external
        override
        saleEnded
        bioExist(bioId)
        isBioOwner(bioId)
        nonReentrant
    {
        Bid memory existingBid = _bioWithBids[bioId];
        require(existingBid.hasBid && existingBid.value > 0, "This Bio doesn't have a valid bid");

        uint256 fees = existingBid.value.mul(_feeFraction).div(_feeBase + _feeFraction);
        uint256 bioValue = existingBid.value.sub(fees);
        _sendValue(msg.sender, bioValue);
        _pendingWithdrawals[owner()] = _pendingWithdrawals[owner()].add(fees);

        _safeTransfer(msg.sender, existingBid.bidder, bioId, "");
        emit BioBidAccepted(bioId, bioValue, msg.sender, existingBid.bidder);

        _removeBid(bioId);

        if (_bioListedForSale[bioId].isForSale) {
            _delistBio(bioId);
        }
    }

    function withdrawBidForBio(uint256 bioId)
        external
        override
        saleEnded
        bioExist(bioId)
        nonReentrant
    {
        Bid memory existingBid = _bioWithBids[bioId];
        require(existingBid.bidder == msg.sender, "This address doesn't have active bid");

        _sendValue(msg.sender, existingBid.value);

        emit BioBidWithdrawn(bioId, existingBid.value, existingBid.bidder);
        _removeBid(bioId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 bioId
    ) public override nonReentrant {
        require(
            _isApprovedOrOwner(_msgSender(), bioId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, bioId);

        if (_bioListedForSale[bioId].seller == from) {
            _delistBio(bioId);
        }
        if (_bioWithBids[bioId].bidder == to) {
            _sendValue(_bioWithBids[bioId].bidder, _bioWithBids[bioId].value);
            _removeBid(bioId);
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 bioId
    ) public override {
        safeTransferFrom(from, to, bioId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 bioId,
        bytes memory _data
    ) public override nonReentrant {
        require(
            _isApprovedOrOwner(_msgSender(), bioId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, bioId, _data);

        if (_bioListedForSale[bioId].seller == from) {
            _delistBio(bioId);
        }
        if (_bioWithBids[bioId].bidder == to) {
            _sendValue(_bioWithBids[bioId].bidder, _bioWithBids[bioId].value);
            _removeBid(bioId);
        }
    }

    function serviceFee() external view override returns (uint8, uint8) {
        return (_feeFraction, _feeBase);
    }

    function pendingWithdrawals(address toAddress) external view override returns (uint256) {
        return _pendingWithdrawals[toAddress];
    }

    function withdraw() external override nonReentrant {
        require(_pendingWithdrawals[msg.sender] > 0, "There is nothing to withdraw");
        _sendValue(msg.sender, _pendingWithdrawals[msg.sender]);
        _pendingWithdrawals[msg.sender] = 0;
    }

    function changeSeriveFee(uint8 feeFraction_, uint8 feeBase_) external onlyOwner {
        require(feeFraction_ <= feeBase_, "Fee fraction exceeded base.");
        uint256 percentage = (feeFraction_ * 1000) / feeBase_;
        require(percentage <= 25, "Attempt to set percentage higher than 2.5%.");

        _feeFraction = feeFraction_;
        _feeBase = feeBase_;
    }
}