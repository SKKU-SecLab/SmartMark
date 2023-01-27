pragma solidity 0.7.5;

interface IAMB {

    event UserRequestForAffirmation(bytes32 indexed messageId, bytes encodedData);
    event UserRequestForSignature(bytes32 indexed messageId, bytes encodedData);
    event CollectedSignatures(
        address authorityResponsibleForRelay,
        bytes32 messageHash,
        uint256 numberOfCollectedSignatures
    );
    event AffirmationCompleted(
        address indexed sender,
        address indexed executor,
        bytes32 indexed messageId,
        bool status
    );
    event RelayedMessage(address indexed sender, address indexed executor, bytes32 indexed messageId, bool status);

    function messageSender() external view returns (address);


    function maxGasPerTx() external view returns (uint256);


    function transactionHash() external view returns (bytes32);


    function messageId() external view returns (bytes32);


    function messageSourceChainId() external view returns (bytes32);


    function messageCallStatus(bytes32 _messageId) external view returns (bool);


    function failedMessageDataHash(bytes32 _messageId) external view returns (bytes32);


    function failedMessageReceiver(bytes32 _messageId) external view returns (address);


    function failedMessageSender(bytes32 _messageId) external view returns (address);


    function requireToPassMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);


    function requireToConfirmMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);


    function sourceChainId() external view returns (uint256);


    function destinationChainId() external view returns (uint256);

}// MIT

pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.7.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}pragma solidity 0.7.5;


interface IBurnableMintableERC1155Token is IERC1155 {

    function mint(
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values
    ) external;


    function burn(uint256[] calldata _tokenId, uint256[] calldata _values) external;

}// MIT

pragma solidity ^0.7.0;


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

}pragma solidity 0.7.5;


interface IBurnableMintableERC721Token is IERC721 {

    function mint(address _to, uint256 _tokeId) external;


    function burn(uint256 _tokenId) external;


    function setTokenURI(uint256 _tokenId, string calldata _tokenURI) external;

}pragma solidity 0.7.5;

interface IERC1155TokenReceiver {

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4);

}pragma solidity 0.7.5;

interface IOwnable {

    function owner() external view returns (address);

}pragma solidity 0.7.5;

interface IUpgradeabilityOwnerStorage {

    function upgradeabilityOwner() external view returns (address);

}pragma solidity 0.7.5;

library Bytes {

    function bytesToAddress(bytes memory _bytes) internal pure returns (address addr) {

        assembly {
            addr := mload(add(_bytes, 20))
        }
    }
}// MIT

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

pragma solidity ^0.7.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.7.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.7.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.7.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

    constructor (string memory name_, string memory symbol_) {
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

}pragma solidity 0.7.5;


contract ERC721BridgeToken is ERC721, IBurnableMintableERC721Token {
    address public bridgeContract;

    constructor(
        string memory _name,
        string memory _symbol,
        address _bridgeContract
    ) ERC721(_name, _symbol) {
        bridgeContract = _bridgeContract;
    }

    modifier onlyBridge() {
        require(msg.sender == bridgeContract);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == bridgeContract || msg.sender == IOwnable(bridgeContract).owner());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        bytes4 INTERFACE_ID_ERC165 = 0x01ffc9a7;
        bytes4 INTERFACE_ID_ERC721 = 0x80ac58cd;
        bytes4 INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
        bytes4 INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
        return
            interfaceId == INTERFACE_ID_ERC165 ||
            interfaceId == INTERFACE_ID_ERC721 ||
            interfaceId == INTERFACE_ID_ERC721_METADATA ||
            interfaceId == INTERFACE_ID_ERC721_ENUMERABLE;
    }

    function _registerInterface(bytes4) internal override {}

    function mint(address _to, uint256 _tokenId) external override onlyBridge {
        _safeMint(_to, _tokenId);
    }

    function burn(uint256 _tokenId) external override onlyBridge {
        _burn(_tokenId);
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {
        _setBaseURI(_baseURI);
    }

    function setBridgeContract(address _bridgeContract) external onlyOwner {
        require(_bridgeContract != address(0));
        bridgeContract = _bridgeContract;
    }

    function setTokenURI(uint256 _tokenId, string calldata _tokenURI) external override onlyOwner {
        _setTokenURI(_tokenId, _tokenURI);
    }

    function getTokenInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {
        return (1, 0, 1);
    }
}pragma solidity 0.7.5;

contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
}pragma solidity 0.7.5;

abstract contract Proxy {
    function implementation() public view virtual returns (address);

    fallback() external payable {
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            mstore(0x40, add(ptr, returndatasize()))
            returndatacopy(ptr, 0, returndatasize())

            switch result
                case 0 {
                    revert(ptr, returndatasize())
                }
                default {
                    return(ptr, returndatasize())
                }
        }
    }
}pragma solidity 0.7.5;


contract Ownable is EternalStorage {
    bytes4 internal constant UPGRADEABILITY_OWNER = 0x6fde8202; // upgradeabilityOwner()

    event OwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    modifier onlyRelevantSender() {
        (bool isProxy, bytes memory returnData) =
            address(this).staticcall(abi.encodeWithSelector(UPGRADEABILITY_OWNER));
        require(
            !isProxy || // covers usage without calling through storage proxy
                (returnData.length == 32 && msg.sender == abi.decode(returnData, (address))) || // covers usage through regular proxy calls
                msg.sender == address(this) // covers calls through upgradeAndCall proxy method
        );
        _;
    }

    bytes32 internal constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; // keccak256(abi.encodePacked("owner"))

    function owner() public view returns (address) {
        return addressStorage[OWNER];
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
    }
}pragma solidity 0.7.5;


abstract contract BasicAMBMediator is Ownable {
    bytes32 internal constant BRIDGE_CONTRACT = 0x811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f; // keccak256(abi.encodePacked("bridgeContract"))
    bytes32 internal constant MEDIATOR_CONTRACT = 0x98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab9880; // keccak256(abi.encodePacked("mediatorContract"))

    modifier onlyMediator {
        _onlyMediator();
        _;
    }

    function _onlyMediator() internal view {
        IAMB bridge = bridgeContract();
        require(msg.sender == address(bridge));
        require(bridge.messageSender() == mediatorContractOnOtherSide());
    }

    function setBridgeContract(address _bridgeContract) external onlyOwner {
        _setBridgeContract(_bridgeContract);
    }

    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {
        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    function bridgeContract() public view returns (IAMB) {
        return IAMB(addressStorage[BRIDGE_CONTRACT]);
    }

    function mediatorContractOnOtherSide() public view virtual returns (address) {
        return addressStorage[MEDIATOR_CONTRACT];
    }

    function _setBridgeContract(address _bridgeContract) internal {
        require(Address.isContract(_bridgeContract));
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {
        addressStorage[MEDIATOR_CONTRACT] = _mediatorContract;
    }

    function messageId() internal view returns (bytes32) {
        return bridgeContract().messageId();
    }

    function maxGasPerTx() internal view returns (uint256) {
        return bridgeContract().maxGasPerTx();
    }

    function _passMessage(bytes memory _data, bool _useOracleLane) internal virtual returns (bytes32);
}pragma solidity 0.7.5;


contract Initializable is EternalStorage {
    bytes32 internal constant INITIALIZED = 0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba; // keccak256(abi.encodePacked("isInitialized"))

    function setInitialize() internal {
        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {
        return boolStorage[INITIALIZED];
    }
}pragma solidity 0.7.5;

contract ReentrancyGuard {
    function lock() internal view returns (bool res) {
        assembly {
            res := sload(0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92) // keccak256(abi.encodePacked("lock"))
        }
    }

    function setLock(bool _lock) internal {
        assembly {
            sstore(0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92, _lock) // keccak256(abi.encodePacked("lock"))
        }
    }
}pragma solidity 0.7.5;


contract Upgradeable {
    modifier onlyIfUpgradeabilityOwner() {
        require(msg.sender == IUpgradeabilityOwnerStorage(address(this)).upgradeabilityOwner());
        _;
    }
}pragma solidity 0.7.5;

interface VersionableBridge {
    function getBridgeInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        );

    function getBridgeMode() external pure returns (bytes4);
}pragma solidity 0.7.5;


abstract contract BridgeOperationsStorage is EternalStorage {
    function setMessageChecksum(bytes32 _messageId, bytes32 _checksum) internal {
        uintStorage[keccak256(abi.encodePacked("messageChecksum", _messageId))] = uint256(_checksum);
    }

    function getMessageChecksum(bytes32 _messageId) internal view returns (bytes32) {
        return bytes32(uintStorage[keccak256(abi.encodePacked("messageChecksum", _messageId))]);
    }

    function _messageChecksum(
        address _token,
        address _sender,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(_token, _sender, _tokenIds, _values));
    }
}pragma solidity 0.7.5;


abstract contract FailedMessagesProcessor is BasicAMBMediator, BridgeOperationsStorage {
    event FailedMessageFixed(bytes32 indexed messageId, address token);

    function requestFailedMessageFix(
        bytes32 _messageId,
        address _token,
        address _sender,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values
    ) external {
        require(_tokenIds.length > 0);
        require(_values.length == 0 || _tokenIds.length == _values.length);

        IAMB bridge = bridgeContract();
        require(!bridge.messageCallStatus(_messageId));
        require(bridge.failedMessageReceiver(_messageId) == address(this));
        require(bridge.failedMessageSender(_messageId) == mediatorContractOnOtherSide());

        bytes memory data =
            abi.encodeWithSelector(this.fixFailedMessage.selector, _messageId, _token, _sender, _tokenIds, _values);
        _passMessage(data, false);
    }

    function fixFailedMessage(
        bytes32 _messageId,
        address _token,
        address _sender,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) public onlyMediator {
        require(!messageFixed(_messageId));
        require(getMessageChecksum(_messageId) == _messageChecksum(_token, _sender, _tokenIds, _values));

        setMessageFixed(_messageId);
        executeActionOnFixedTokens(_token, _sender, _tokenIds, _values);
        emit FailedMessageFixed(_messageId, _token);
    }

    function messageFixed(bytes32 _messageId) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))];
    }

    function setMessageFixed(bytes32 _messageId) internal {
        boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))] = true;
    }

    function executeActionOnFixedTokens(
        address _token,
        address _recipient,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) internal virtual;
}pragma solidity 0.7.5;


abstract contract NFTBridgeLimits is Ownable {
    event TokenBridgingDisabled(address indexed token, bool disabled);
    event TokenExecutionDisabled(address indexed token, bool disabled);

    function isTokenRegistered(address _token) public view virtual returns (bool);

    function disableTokenBridging(address _token, bool _disable) external onlyOwner {
        require(_token == address(0) || isTokenRegistered(_token));
        boolStorage[keccak256(abi.encodePacked("bridgingDisabled", _token))] = _disable;
        emit TokenBridgingDisabled(_token, _disable);
    }

    function disableTokenExecution(address _token, bool _disable) external onlyOwner {
        require(_token == address(0) || isTokenRegistered(_token));
        boolStorage[keccak256(abi.encodePacked("executionDisabled", _token))] = _disable;
        emit TokenExecutionDisabled(_token, _disable);
    }

    function isTokenBridgingAllowed(address _token) public view returns (bool) {
        bool isDisabled = boolStorage[keccak256(abi.encodePacked("bridgingDisabled", _token))];
        if (isDisabled || _token == address(0)) {
            return !isDisabled;
        }
        return isTokenBridgingAllowed(address(0));
    }

    function isTokenExecutionAllowed(address _token) public view returns (bool) {
        bool isDisabled = boolStorage[keccak256(abi.encodePacked("executionDisabled", _token))];
        if (isDisabled || _token == address(0)) {
            return !isDisabled;
        }
        return isTokenExecutionAllowed(address(0));
    }
}pragma solidity 0.7.5;


abstract contract BaseRelayer {
    function _chooseReceiver(address _from, bytes memory _data) internal pure returns (address recipient) {
        recipient = _from;
        if (_data.length > 0) {
            require(_data.length == 20);
            recipient = Bytes.bytesToAddress(_data);
        }
    }

    function _singletonArray(uint256 _value) internal pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = _value;
        return array;
    }

    function bridgeSpecificActionsOnTokenTransfer(
        address _token,
        address _from,
        address _receiver,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) internal virtual;
}pragma solidity 0.7.5;


abstract contract ERC721Relayer is BaseRelayer, ReentrancyGuard {
    function onERC721Received(
        address,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        if (!lock()) {
            bridgeSpecificActionsOnTokenTransfer(
                msg.sender,
                _from,
                _chooseReceiver(_from, _data),
                _singletonArray(_tokenId),
                new uint256[](0)
            );
        }
        return msg.sig;
    }

    function relayToken(
        IERC721 token,
        address _receiver,
        uint256 _tokenId
    ) external {
        _relayToken(token, _receiver, _tokenId);
    }

    function relayToken(IERC721 token, uint256 _tokenId) external {
        _relayToken(token, msg.sender, _tokenId);
    }

    function _relayToken(
        IERC721 _token,
        address _receiver,
        uint256 _tokenId
    ) internal {
        require(!lock());

        setLock(true);
        _token.transferFrom(msg.sender, address(this), _tokenId);
        setLock(false);
        bridgeSpecificActionsOnTokenTransfer(
            address(_token),
            msg.sender,
            _receiver,
            _singletonArray(_tokenId),
            new uint256[](0)
        );
    }
}pragma solidity 0.7.5;


abstract contract ERC1155Relayer is IERC1155TokenReceiver, BaseRelayer {
    uint256 internal constant MAX_BATCH_BRIDGE_AND_DEPLOY_LIMIT = 14;
    uint256 internal constant MAX_BATCH_BRIDGE_LIMIT = 19;

    function onERC1155Received(
        address,
        address _from,
        uint256 _tokenId,
        uint256 _value,
        bytes calldata _data
    ) external override returns (bytes4) {
        bridgeSpecificActionsOnTokenTransfer(
            msg.sender,
            _from,
            _chooseReceiver(_from, _data),
            _singletonArray(_tokenId),
            _singletonArray(_value)
        );
        return msg.sig;
    }

    function onERC1155BatchReceived(
        address,
        address _from,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values,
        bytes calldata _data
    ) external override returns (bytes4) {
        require(_tokenIds.length == _values.length);
        require(_tokenIds.length > 0);
        bridgeSpecificActionsOnTokenTransfer(msg.sender, _from, _chooseReceiver(_from, _data), _tokenIds, _values);
        return msg.sig;
    }
}pragma solidity 0.7.5;


contract NFTOmnibridgeInfo is VersionableBridge {
    event TokensBridgingInitiated(
        address indexed token,
        address indexed sender,
        uint256[] tokenIds,
        uint256[] values,
        bytes32 indexed messageId
    );
    event TokensBridged(
        address indexed token,
        address indexed recipient,
        uint256[] tokenIds,
        uint256[] values,
        bytes32 indexed messageId
    );

    function getBridgeInterfacesVersion()
        external
        pure
        override
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {
        return (3, 0, 0);
    }

    function getBridgeMode() external pure override returns (bytes4 _data) {
        return 0xca7fc3dc; // bytes4(keccak256(abi.encodePacked("multi-nft-to-nft-amb")))
    }
}pragma solidity 0.7.5;


contract NativeTokensRegistry is EternalStorage {
    uint256 internal constant REGISTERED = 1;
    uint256 internal constant REGISTERED_AND_DEPLOYED = 2;

    function isBridgedTokenDeployAcknowledged(address _token) public view returns (bool) {
        return uintStorage[keccak256(abi.encodePacked("tokenRegistered", _token))] == REGISTERED_AND_DEPLOYED;
    }

    function isRegisteredAsNativeToken(address _token) public view returns (bool) {
        return uintStorage[keccak256(abi.encodePacked("tokenRegistered", _token))] > 0;
    }

    function _setNativeTokenIsRegistered(address _token, uint256 _state) internal {
        if (uintStorage[keccak256(abi.encodePacked("tokenRegistered", _token))] != _state) {
            uintStorage[keccak256(abi.encodePacked("tokenRegistered", _token))] = _state;
        }
    }
}// MIT

pragma solidity ^0.7.0;


interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}pragma solidity 0.7.5;


contract MetadataReader is Ownable {
    function setCustomMetadata(
        address _token,
        string calldata _name,
        string calldata _symbol
    ) external onlyOwner {
        stringStorage[keccak256(abi.encodePacked("customName", _token))] = _name;
        stringStorage[keccak256(abi.encodePacked("customSymbol", _token))] = _symbol;
    }

    function _readName(address _token) internal view returns (string memory) {
        (bool status, bytes memory data) = _token.staticcall(abi.encodeWithSelector(IERC721Metadata.name.selector));
        return status ? abi.decode(data, (string)) : stringStorage[keccak256(abi.encodePacked("customName", _token))];
    }

    function _readSymbol(address _token) internal view returns (string memory) {
        (bool status, bytes memory data) = _token.staticcall(abi.encodeWithSelector(IERC721Metadata.symbol.selector));
        return status ? abi.decode(data, (string)) : stringStorage[keccak256(abi.encodePacked("customSymbol", _token))];
    }

    function _readERC721TokenURI(address _token, uint256 _tokenId) internal view returns (string memory) {
        (bool status, bytes memory data) =
            _token.staticcall(abi.encodeWithSelector(IERC721Metadata.tokenURI.selector, _tokenId));
        return status ? abi.decode(data, (string)) : "";
    }

    function _readERC1155TokenURI(address _token, uint256 _tokenId) internal view returns (string memory) {
        (bool status, bytes memory data) =
            _token.staticcall(abi.encodeWithSelector(IERC1155MetadataURI.uri.selector, _tokenId));
        return status ? abi.decode(data, (string)) : "";
    }
}pragma solidity 0.7.5;


contract BridgedTokensRegistry is EternalStorage {
    event NewTokenRegistered(address indexed nativeToken, address indexed bridgedToken);

    function bridgedTokenAddress(address _nativeToken) public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("homeTokenAddress", _nativeToken))];
    }

    function nativeTokenAddress(address _bridgedToken) public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("foreignTokenAddress", _bridgedToken))];
    }

    function _setTokenAddressPair(address _nativeToken, address _bridgedToken) internal {
        addressStorage[keccak256(abi.encodePacked("homeTokenAddress", _nativeToken))] = _bridgedToken;
        addressStorage[keccak256(abi.encodePacked("foreignTokenAddress", _bridgedToken))] = _nativeToken;

        emit NewTokenRegistered(_nativeToken, _bridgedToken);
    }
}pragma solidity 0.7.5;


contract TokenImageStorage is Ownable {
    bytes32 internal constant ERC721_TOKEN_IMAGE_CONTRACT =
        0x20b8ca26cc94f39fab299954184cf3a9bd04f69543e4f454fab299f015b8130f; // keccak256(abi.encodePacked("tokenImageContract"))
    bytes32 internal constant ERC1155_TOKEN_IMAGE_CONTRACT =
        0x02e1d283efd236e8b97cefe072f0c863fa2db9f9ba42b0eca53ab31c49067a67; // keccak256(abi.encodePacked("erc1155tokenImageContract"))

    function setTokenImageERC721(address _image) external onlyOwner {
        _setTokenImageERC721(_image);
    }

    function setTokenImageERC1155(address _image) external onlyOwner {
        _setTokenImageERC1155(_image);
    }

    function tokenImageERC721() public view returns (address) {
        return addressStorage[ERC721_TOKEN_IMAGE_CONTRACT];
    }

    function tokenImageERC1155() public view returns (address) {
        return addressStorage[ERC1155_TOKEN_IMAGE_CONTRACT];
    }

    function _setTokenImageERC721(address _image) internal {
        require(Address.isContract(_image));
        addressStorage[ERC721_TOKEN_IMAGE_CONTRACT] = _image;
    }

    function _setTokenImageERC1155(address _image) internal {
        require(Address.isContract(_image));
        addressStorage[ERC1155_TOKEN_IMAGE_CONTRACT] = _image;
    }
}pragma solidity 0.7.5;


contract ERC721TokenProxy is Proxy {
    mapping(bytes4 => bool) private _supportedInterfaces;
    mapping(address => uint256) private _holderTokens;

    uint256[] private _tokenOwnersEntries;
    mapping(bytes32 => uint256) private _tokenOwnersIndexes;

    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    string private name;
    string private symbol;
    mapping(uint256 => string) private _tokenURIs;
    string private _baseURI;
    address private bridgeContract;

    constructor(
        address _tokenImage,
        string memory _name,
        string memory _symbol,
        address _owner
    ) {
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _tokenImage)
        }
        name = _name;
        symbol = _symbol;
        bridgeContract = _owner; // _owner == HomeOmnibridgeNFT/ForeignOmnibridgeNFT mediator
    }

    function implementation() public view override returns (address impl) {
        assembly {
            impl := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
    }

    function setImplementation(address _implementation) external {
        require(msg.sender == bridgeContract || msg.sender == IOwnable(bridgeContract).owner());
        require(_implementation != address(0));
        require(Address.isContract(_implementation));
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _implementation)
        }
    }

    function getTokenProxyInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {
        return (1, 0, 0);
    }
}pragma solidity 0.7.5;


contract ERC1155TokenProxy is Proxy {
    mapping(bytes4 => bool) private _supportedInterfaces;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    string private name;
    string private symbol;
    mapping(uint256 => string) private _tokenURIs;
    string private _baseURI;
    address private bridgeContract;

    constructor(
        address _tokenImage,
        string memory _name,
        string memory _symbol,
        address _owner
    ) {
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _tokenImage)
        }
        name = _name;
        symbol = _symbol;
        bridgeContract = _owner; // _owner == HomeOmnibridgeNFT/ForeignOmnibridgeNFT mediator
    }

    function implementation() public view override returns (address impl) {
        assembly {
            impl := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
    }

    function setImplementation(address _implementation) external {
        require(msg.sender == bridgeContract || msg.sender == IOwnable(bridgeContract).owner());
        require(_implementation != address(0));
        require(Address.isContract(_implementation));
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _implementation)
        }
    }

    function getTokenProxyInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {
        return (1, 0, 0);
    }
}pragma solidity 0.7.5;


contract NFTMediatorBalanceStorage is EternalStorage {
    function mediatorOwns(address _token, uint256 _tokenId) public view returns (uint256 amount) {
        bytes32 key = _getStorageKey(_token, _tokenId);
        assembly {
            amount := sload(key)
        }
    }

    function _setMediatorOwns(
        address _token,
        uint256 _tokenId,
        uint256 _value
    ) internal {
        bytes32 key = _getStorageKey(_token, _tokenId);
        assembly {
            sstore(key, _value)
        }
    }

    function _getStorageKey(address _token, uint256 _tokenId) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked("mediatorOwns", _token, _tokenId)), uint256(4)));
    }
}pragma solidity 0.7.5;
pragma abicoder v2;


abstract contract BasicNFTOmnibridge is
    Initializable,
    Upgradeable,
    BridgeOperationsStorage,
    BridgedTokensRegistry,
    NativeTokensRegistry,
    NFTOmnibridgeInfo,
    NFTBridgeLimits,
    MetadataReader,
    TokenImageStorage,
    ERC721Relayer,
    ERC1155Relayer,
    NFTMediatorBalanceStorage,
    FailedMessagesProcessor
{
    using SafeMath for uint256;

    uint256 private immutable SUFFIX_SIZE;
    bytes32 private immutable SUFFIX;

    constructor(string memory _suffix) {
        require(bytes(_suffix).length <= 32);
        bytes32 suffix;
        assembly {
            suffix := mload(add(_suffix, 32))
        }
        SUFFIX = suffix;
        SUFFIX_SIZE = bytes(_suffix).length;
    }

    function isTokenRegistered(address _token) public view override returns (bool) {
        return isRegisteredAsNativeToken(_token) || nativeTokenAddress(_token) != address(0);
    }

    function deployAndHandleBridgedNFT(
        address _token,
        string memory _name,
        string memory _symbol,
        address _recipient,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values,
        string[] calldata _tokenURIs
    ) external onlyMediator {
        address bridgedToken = bridgedTokenAddress(_token);
        if (bridgedToken == address(0)) {
            if (bytes(_name).length == 0) {
                require(bytes(_symbol).length > 0);
                _name = _symbol;
            } else if (bytes(_symbol).length == 0) {
                _symbol = _name;
            }
            bridgedToken = _values.length > 0
                ? address(new ERC1155TokenProxy(tokenImageERC1155(), _transformName(_name), _symbol, address(this)))
                : address(new ERC721TokenProxy(tokenImageERC721(), _transformName(_name), _symbol, address(this)));
            _setTokenAddressPair(_token, bridgedToken);
        }

        _handleTokens(bridgedToken, false, _recipient, _tokenIds, _values);
        _setTokensURI(bridgedToken, _tokenIds, _tokenURIs);
    }

    function handleBridgedNFT(
        address _token,
        address _recipient,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values,
        string[] calldata _tokenURIs
    ) external onlyMediator {
        address token = bridgedTokenAddress(_token);

        _handleTokens(token, false, _recipient, _tokenIds, _values);
        _setTokensURI(token, _tokenIds, _tokenURIs);
    }

    function handleNativeNFT(
        address _token,
        address _recipient,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values
    ) external onlyMediator {
        require(isRegisteredAsNativeToken(_token));

        _setNativeTokenIsRegistered(_token, REGISTERED_AND_DEPLOYED);

        _handleTokens(_token, true, _recipient, _tokenIds, _values);
    }

    function setCustomTokenAddressPair(address _nativeToken, address _bridgedToken) external onlyOwner {
        require(Address.isContract(_bridgedToken));
        require(!isTokenRegistered(_bridgedToken));
        require(bridgedTokenAddress(_nativeToken) == address(0));

        _setTokenAddressPair(_nativeToken, _bridgedToken);
    }

    function fixMediatorBalanceERC721(
        address _token,
        address _receiver,
        uint256[] calldata _tokenIds
    ) external onlyIfUpgradeabilityOwner {
        require(isRegisteredAsNativeToken(_token));
        require(_tokenIds.length > 0);

        uint256[] memory values = new uint256[](0);

        bytes memory data = _prepareMessage(_token, _receiver, _tokenIds, values);
        bytes32 _messageId = _passMessage(data, true);
        _recordBridgeOperation(_messageId, _token, _receiver, _tokenIds, values);
    }

    function fixMediatorBalanceERC1155(
        address _token,
        address _receiver,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values
    ) external onlyIfUpgradeabilityOwner {
        require(isRegisteredAsNativeToken(_token));
        require(_tokenIds.length == _values.length);
        require(_tokenIds.length > 0);

        bytes memory data = _prepareMessage(_token, _receiver, _tokenIds, _values);
        bytes32 _messageId = _passMessage(data, true);
        _recordBridgeOperation(_messageId, _token, _receiver, _tokenIds, _values);
    }

    function bridgeSpecificActionsOnTokenTransfer(
        address _token,
        address _from,
        address _receiver,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) internal override {
        if (!isTokenRegistered(_token)) {
            _setNativeTokenIsRegistered(_token, REGISTERED);
        }

        bytes memory data = _prepareMessage(_token, _receiver, _tokenIds, _values);

        bytes32 _messageId = _passMessage(data, _isOracleDrivenLaneAllowed(_token, _from, _receiver));

        _recordBridgeOperation(_messageId, _token, _from, _tokenIds, _values);
    }

    function _prepareMessage(
        address _token,
        address _receiver,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) internal returns (bytes memory) {
        require(_receiver != address(0) && _receiver != mediatorContractOnOtherSide());

        address nativeToken = nativeTokenAddress(_token);

        if (nativeToken == address(0)) {
            string[] memory tokenURIs = new string[](_tokenIds.length);

            if (_values.length > 0) {
                for (uint256 i = 0; i < _tokenIds.length; i++) {
                    uint256 oldBalance = mediatorOwns(_token, _tokenIds[i]);
                    uint256 newBalance = oldBalance.add(_values[i]);
                    require(IERC1155(_token).balanceOf(address(this), _tokenIds[i]) >= newBalance);
                    _setMediatorOwns(_token, _tokenIds[i], newBalance);
                    tokenURIs[i] = _readERC1155TokenURI(_token, _tokenIds[i]);
                }
            } else {
                for (uint256 i = 0; i < _tokenIds.length; i++) {
                    require(mediatorOwns(_token, _tokenIds[i]) == 0);
                    require(IERC721(_token).ownerOf(_tokenIds[i]) == address(this));
                    _setMediatorOwns(_token, _tokenIds[i], 1);
                    tokenURIs[i] = _readERC721TokenURI(_token, _tokenIds[i]);
                }
            }

            if (isBridgedTokenDeployAcknowledged(_token)) {
                require(_tokenIds.length <= MAX_BATCH_BRIDGE_LIMIT);
                return
                    abi.encodeWithSelector(
                        this.handleBridgedNFT.selector,
                        _token,
                        _receiver,
                        _tokenIds,
                        _values,
                        tokenURIs
                    );
            }

            require(_tokenIds.length <= MAX_BATCH_BRIDGE_AND_DEPLOY_LIMIT);

            string memory name = _readName(_token);
            string memory symbol = _readSymbol(_token);

            require(bytes(name).length > 0 || bytes(symbol).length > 0);

            return
                abi.encodeWithSelector(
                    this.deployAndHandleBridgedNFT.selector,
                    _token,
                    name,
                    symbol,
                    _receiver,
                    _tokenIds,
                    _values,
                    tokenURIs
                );
        }

        if (_values.length > 0) {
            IBurnableMintableERC1155Token(_token).burn(_tokenIds, _values);
        } else {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                IBurnableMintableERC721Token(_token).burn(_tokenIds[i]);
            }
        }
        return abi.encodeWithSelector(this.handleNativeNFT.selector, nativeToken, _receiver, _tokenIds, _values);
    }

    function executeActionOnFixedTokens(
        address _token,
        address _recipient,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) internal override {
        _releaseTokens(_token, nativeTokenAddress(_token) == address(0), _recipient, _tokenIds, _values);
    }

    function _handleTokens(
        address _token,
        bool _isNative,
        address _recipient,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values
    ) internal {
        require(isTokenExecutionAllowed(_token));

        _releaseTokens(_token, _isNative, _recipient, _tokenIds, _values);

        emit TokensBridged(_token, _recipient, _tokenIds, _values, messageId());
    }

    function _setTokensURI(
        address _token,
        uint256[] calldata _tokenIds,
        string[] calldata _tokenURIs
    ) internal {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (bytes(_tokenURIs[i]).length > 0) {
                IBurnableMintableERC721Token(_token).setTokenURI(_tokenIds[i], _tokenURIs[i]);
            }
        }
    }

    function _releaseTokens(
        address _token,
        bool _isNative,
        address _recipient,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) internal {
        if (_values.length > 0) {
            if (_isNative) {
                for (uint256 i = 0; i < _tokenIds.length; i++) {
                    _setMediatorOwns(_token, _tokenIds[i], mediatorOwns(_token, _tokenIds[i]).sub(_values[i]));
                }
                IERC1155(_token).safeBatchTransferFrom(address(this), _recipient, _tokenIds, _values, new bytes(0));
            } else {
                IBurnableMintableERC1155Token(_token).mint(_recipient, _tokenIds, _values);
            }
        } else {
            if (_isNative) {
                for (uint256 i = 0; i < _tokenIds.length; i++) {
                    _setMediatorOwns(_token, _tokenIds[i], 0);
                    IERC721(_token).transferFrom(address(this), _recipient, _tokenIds[i]);
                }
            } else {
                for (uint256 i = 0; i < _tokenIds.length; i++) {
                    IBurnableMintableERC721Token(_token).mint(_recipient, _tokenIds[i]);
                }
            }
        }
    }

    function _recordBridgeOperation(
        bytes32 _messageId,
        address _token,
        address _sender,
        uint256[] memory _tokenIds,
        uint256[] memory _values
    ) internal {
        require(isTokenBridgingAllowed(_token));

        setMessageChecksum(_messageId, _messageChecksum(_token, _sender, _tokenIds, _values));

        emit TokensBridgingInitiated(_token, _sender, _tokenIds, _values, _messageId);
    }

    function _isOracleDrivenLaneAllowed(
        address _token,
        address _sender,
        address _receiver
    ) internal view virtual returns (bool) {
        (_token, _sender, _receiver);
        return true;
    }

    function _transformName(string memory _name) internal view returns (string memory) {
        string memory result = string(abi.encodePacked(_name, SUFFIX));
        uint256 size = SUFFIX_SIZE;
        assembly {
            mstore(result, add(mload(_name), size))
        }
        return result;
    }
}pragma solidity 0.7.5;


abstract contract GasLimitManager is BasicAMBMediator {
    bytes32 internal constant REQUEST_GAS_LIMIT = 0x2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be; // keccak256(abi.encodePacked("requestGasLimit"))

    function setRequestGasLimit(uint256 _gasLimit) external onlyOwner {
        _setRequestGasLimit(_gasLimit);
    }

    function requestGasLimit() public view returns (uint256) {
        return uintStorage[REQUEST_GAS_LIMIT];
    }

    function _setRequestGasLimit(uint256 _gasLimit) internal {
        require(_gasLimit <= maxGasPerTx());
        uintStorage[REQUEST_GAS_LIMIT] = _gasLimit;
    }
}pragma solidity 0.7.5;


contract ForeignNFTOmnibridge is BasicNFTOmnibridge, GasLimitManager {
    constructor(string memory _suffix) BasicNFTOmnibridge(_suffix) {}

    function initialize(
        address _bridgeContract,
        address _mediatorContract,
        uint256 _requestGasLimit,
        address _owner,
        address _imageERC721,
        address _imageERC1155
    ) external onlyRelevantSender returns (bool) {
        require(!isInitialized());

        _setBridgeContract(_bridgeContract);
        _setMediatorContractOnOtherSide(_mediatorContract);
        _setRequestGasLimit(_requestGasLimit);
        _setOwner(_owner);
        _setTokenImageERC721(_imageERC721);
        _setTokenImageERC1155(_imageERC1155);

        setInitialize();

        return isInitialized();
    }

    function _passMessage(bytes memory _data, bool _useOracleLane) internal override returns (bytes32) {
        (_useOracleLane);

        return bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), _data, requestGasLimit());
    }
    
    function migrationTo3_0_0() external {
        bytes32 migratedTo3_0_0Storage = 0xd8ad6d205355cc8dd4d88d650469f4d3230596fa9345b86d1d97034a771009ba; // keccak256(abi.encodePacked("migrationTo3_0_020210530"))
        require(!boolStorage[migratedTo3_0_0Storage]);
        
        _setTokenImageERC721(0x8b9E7c13F98291fe90b38E020BcB046f4A4Dd21d);
        _setTokenImageERC1155(0xF714C3aA632ecE07Eeba241803b26f806EA17908);
        
        boolStorage[migratedTo3_0_0Storage] = true;
    }

    
}