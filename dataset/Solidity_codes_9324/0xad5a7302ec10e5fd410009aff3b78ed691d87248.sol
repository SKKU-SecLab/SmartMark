
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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
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


library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
pragma solidity ^0.8.0;

interface IERC2981Royalties {
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}//MIT
pragma solidity ^0.8.0;

contract BaseOpenSea {
    string private _contractURI;
    ProxyRegistry private _proxyRegistry;

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function isOwnersOpenSeaProxy(address owner, address operator)
        public
        view
        returns (bool)
    {
        ProxyRegistry proxyRegistry = _proxyRegistry;
        return
            address(proxyRegistry) != address(0) &&
            address(proxyRegistry.proxies(owner)) == operator;
    }

    function _setContractURI(string memory contractURI_) internal {
        _contractURI = contractURI_;
    }

    function _setOpenSeaRegistry(address proxyRegistryAddress) internal {
        _proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    }
}

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}//MIT
pragma solidity ^0.8.0;



contract ERC721Ownable is Ownable, ERC721Enumerable, BaseOpenSea {
    constructor(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        address openseaProxyRegistry_,
        address owner_
    ) ERC721(name_, symbol_) {
        if (bytes(contractURI_).length > 0) {
            _setContractURI(contractURI_);
        }

        if (address(0) != openseaProxyRegistry_) {
            _setOpenSeaRegistry(openseaProxyRegistry_);
        }

        if (address(0) != owner_) {
            transferOwnership(owner_);
        }
    }

    function burn(uint256 tokenId) public virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            'ERC721Burnable: caller is not owner nor approved'
        );
        _burn(tokenId);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        if (isOwnersOpenSeaProxy(owner, operator)) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function setContractURI(string memory contractURI_) external onlyOwner {
        _setContractURI(contractURI_);
    }
}//MIT
pragma solidity ^0.8.9;

interface INiftyForge721 {
    struct ModuleInit {
        address module;
        bool enabled;
        bool minter;
    }

    function totalSupply() external view returns (uint256);

    function isMintingOpenToAll() external view returns (bool);

    function setMintingOpenToAll(bool isOpen) external;

    function mint(
        address to,
        string memory uri,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) external returns (uint256 tokenId);

    function mintBatch(
        address[] memory to,
        string[] memory uris,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    ) external returns (uint256[] memory tokenIds);

    function mint(
        address to,
        string memory uri,
        uint256 tokenId_,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) external returns (uint256 tokenId);

    function mintBatch(
        address[] memory to,
        string[] memory uris,
        uint256[] memory tokenIds,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    ) external returns (uint256[] memory);

    function attachModule(
        address module,
        bool enabled,
        bool canModuleMint
    ) external;

    function enableModule(address module, bool canModuleMint) external;

    function disableModule(address module, bool keepListeners) external;

    function renderTokenURI(uint256 tokenId)
        external
        view
        returns (string memory);
}//MIT
pragma solidity ^0.8.0;


interface INFModule is IERC165 {
    function onAttach() external returns (bool);

    function onEnable() external returns (bool);

    function onDisable() external;

    function contractURI() external view returns (string memory);
}//MIT
pragma solidity ^0.8.0;


interface INFModuleRenderTokenURI is INFModule {
    function renderTokenURI(uint256 tokenId)
        external
        view
        returns (string memory);

    function renderTokenURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);
}//MIT
pragma solidity ^0.8.0;


interface INFModuleTokenURI is INFModule {
    function tokenURI(uint256 tokenId) external view returns (string memory);

    function tokenURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);
}//MIT
pragma solidity ^0.8.0;


interface INFModuleWithRoyalties is INFModule {
    function royaltyInfo(uint256 tokenId)
        external
        view
        returns (address recipient, uint256 basisPoint);

    function royaltyInfo(address registry, uint256 tokenId)
        external
        view
        returns (address recipient, uint256 basisPoint);
}//MIT
pragma solidity ^0.8.0;


contract NFBaseModule is INFModule, ERC165 {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal _attached;

    event NewContractURI(string contractURI);

    string private _contractURI;

    modifier onlyAttached(address registry) {
        require(_attached.contains(registry), '!NOT_ATTACHED!');
        _;
    }

    constructor(string memory contractURI_) {
        _setContractURI(contractURI_);
    }

    function contractURI()
        external
        view
        virtual
        override
        returns (string memory)
    {
        return _contractURI;
    }

    function onAttach() external virtual override returns (bool) {
        if (_attached.add(msg.sender)) {
            return true;
        }

        revert('!ALREADY_ATTACHED!');
    }

    function onEnable() external pure virtual override returns (bool) {
        return true;
    }

    function onDisable() external virtual override {}

    function _setContractURI(string memory contractURI_) internal {
        _contractURI = contractURI_;
        emit NewContractURI(contractURI_);
    }
}//MIT
pragma solidity ^0.8.0;

interface IOldMetaHolder {
    function get(uint256 tokenId)
        external
        pure
        returns (
            uint256,
            string memory,
            string memory
        );
}//MIT
pragma solidity ^0.8.0;




contract AstragladeUpgrade is
    IERC2981Royalties,
    ERC721Ownable,
    IERC721Receiver
{
    using ECDSA for bytes32;
    using Strings for uint256;

    event AstragladeUpgraded(address indexed operator, uint256 indexed tokenId);

    event RequestUpdate(address indexed operator, uint256 indexed tokenId);

    struct MintingOrder {
        address to;
        uint256 expiration;
        uint256 seed;
        string signature;
        string imageHash;
    }

    struct AstragladeMeta {
        uint256 seed;
        string signature;
        string imageHash;
    }

    uint256 public lastTokenId = 84;

    address public mintSigner;

    uint256 public expiration;

    address public oldAstragladeContract;

    address public oldMetaHolder;

    address public contractOperator =
        address(0xD1edDfcc4596CC8bD0bd7495beaB9B979fc50336);

    uint256 constant MAX_SUPPLY = 5555;

    uint256 constant PRICE = 0.0888 ether;

    string private _baseRenderURI;

    string internal _description;

    mapping(uint256 => AstragladeMeta) internal _astraglades;

    mapping(bytes32 => uint256) public messageToTokenId;

    mapping(uint256 => bool) public requestUpdates;

    uint256 public remainingGiveaways = 100;

    mapping(address => uint8) public giveaways;

    mapping(uint256 => bool) public petriRedeemed;

    address public artBlocks;

    address[3] public feeRecipients = [
        0xe4657aF058E3f844919c3ee713DF09c3F2949447,
        0xb275E5aa8011eA32506a91449B190213224aEc1e,
        0xdAC81C3642b520584eD0E743729F238D1c350E62
    ];

    modifier onlyOperator() {
        require(isOperator(msg.sender), 'Not operator.');
        _;
    }

    function isOperator(address operator) public view returns (bool) {
        return owner() == operator || contractOperator == operator;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        address openseaProxyRegistry_,
        address mintSigner_,
        address owner_,
        address oldAstragladeContract_,
        address oldMetaHolder_,
        address artBlocks_
    )
        ERC721Ownable(
            name_,
            symbol_,
            contractURI_,
            openseaProxyRegistry_,
            owner_
        )
    {
        mintSigner = mintSigner_;
        oldAstragladeContract = oldAstragladeContract_;
        oldMetaHolder = oldMetaHolder_;
        artBlocks = artBlocks_;
    }

    function mint(
        MintingOrder memory mintingOrder,
        bytes memory mintingSignature,
        uint256 petriId
    ) external payable {
        bytes32 message = hashMintingOrder(mintingOrder)
            .toEthSignedMessageHash();

        address sender = msg.sender;

        require(
            message.recover(mintingSignature) == mintSigner,
            'Wrong minting order signature.'
        );

        require(
            mintingOrder.expiration >= block.timestamp,
            'Minting order expired.'
        );

        require(
            mintingOrder.to == sender,
            'Minting order for another address.'
        );

        require(mintingOrder.seed != 0, 'Seed can not be 0');

        require(messageToTokenId[message] == 0, 'Token already minted.');

        uint256 tokenId = lastTokenId + 1;

        require(tokenId <= MAX_SUPPLY, 'Max supply already reached.');

        uint256 mintingCost = PRICE;

        if (petriId >= 67000000 && petriId < 67000200) {
            require(
                petriRedeemed[petriId] == false &&
                    ERC721(artBlocks).ownerOf(petriId) == sender,
                'Petri already redeemed or not owner'
            );

            petriRedeemed[petriId] = true;
            mintingCost = 0;
        } else if (giveaways[sender] > 0) {
            giveaways[sender]--;
            mintingCost = 0;
        }

        require(
            msg.value == mintingCost || isOperator(sender),
            'Incorrect value.'
        );

        lastTokenId = tokenId;

        messageToTokenId[message] = tokenId;

        _astraglades[tokenId] = AstragladeMeta({
            seed: mintingOrder.seed,
            signature: mintingOrder.signature,
            imageHash: mintingOrder.imageHash
        });

        _safeMint(mintingOrder.to, tokenId, '');
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            ERC721Enumerable.supportsInterface(interfaceId) ||
            interfaceId == type(IERC2981Royalties).interfaceId;
    }

    function getPrice() external pure returns (uint256) {
        return PRICE;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        AstragladeMeta memory astraglade = getAstraglade(tokenId);

        string memory astraType;
        if (tokenId <= 10) {
            astraType = 'Universa';
        } else if (tokenId <= 100) {
            astraType = 'Galactica';
        } else if (tokenId <= 1000) {
            astraType = 'Nebula';
        } else if (tokenId <= 2500) {
            astraType = 'Meteora';
        } else if (tokenId <= 5554) {
            astraType = 'Solaris';
        } else {
            astraType = 'Quanta';
        }

        return
            string(
                abi.encodePacked(
                    'data:application/json;utf8,{"name":"Astraglade - ',
                    tokenId.toString(),
                    ' - ',
                    astraType,
                    '","license":"CC BY-SA 4.0","description":"',
                    getDescription(),
                    '","created_by":"Fabin Rasheed","twitter":"@astraglade","image":"ipfs://ipfs/',
                    astraglade.imageHash,
                    '","seed":"',
                    astraglade.seed.toString(),
                    '","signature":"',
                    astraglade.signature,
                    '","animation_url":"',
                    renderTokenURI(tokenId),
                    '"}'
                )
            );
    }

    function renderTokenURI(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        AstragladeMeta memory astraglade = getAstraglade(tokenId);
        return
            string(
                abi.encodePacked(
                    getBaseRenderURI(),
                    '?seed=',
                    astraglade.seed.toString(),
                    '&signature=',
                    astraglade.signature
                )
            );
    }

    function getAstraglade(uint256 tokenId)
        public
        view
        returns (AstragladeMeta memory astraglade)
    {
        require(_exists(tokenId), 'Astraglade: nonexistent token');

        if (_astraglades[tokenId].seed != 0) {
            astraglade = _astraglades[tokenId];
        } else {
            (
                uint256 seed,
                string memory signature,
                string memory imageHash
            ) = IOldMetaHolder(oldMetaHolder).get(tokenId);
            astraglade.seed = seed;
            astraglade.signature = signature;
            astraglade.imageHash = imageHash;
        }
    }

    function getDescription() public view returns (string memory) {
        if (bytes(_description).length == 0) {
            return
                'Astraglade is an interactive, generative, 3D collectible project. Astraglades are collected through a unique social collection mechanism. Each version of Astraglade can be signed with a signature which will remain in the artwork forever.';
        }

        return _description;
    }

    function setDescription(string memory newDescription)
        external
        onlyOperator
    {
        _description = newDescription;
    }

    function getExpiration() public view returns (uint256) {
        if (expiration == 0) {
            return 15 * 60;
        }

        return expiration;
    }

    function setExpiration(uint256 newExpiration) external onlyOperator {
        expiration = newExpiration;
    }

    function getBaseRenderURI() public view returns (string memory) {
        if (bytes(_baseRenderURI).length == 0) {
            return 'ipfs://ipfs/QmP85DSrtLAxSBnct9iUr7qNca43F3E4vuG6Jv5aoTh9w7';
        }

        return _baseRenderURI;
    }

    function setBaseRenderURI(string memory newRenderURI)
        external
        onlyOperator
    {
        _baseRenderURI = newRenderURI;
    }

    function giveaway(address winner, uint8 count) external onlyOperator {
        require(remainingGiveaways >= count, 'Giveaway limit reached');
        remainingGiveaways -= count;
        giveaways[winner] += count;
    }

    receive() external payable {}

    function withdraw() external onlyOperator {
        address[3] memory feeRecipients_ = feeRecipients;

        uint256 balance_ = address(this).balance;
        payable(address(feeRecipients_[0])).transfer((balance_ * 30) / 100);
        payable(address(feeRecipients_[1])).transfer((balance_ * 35) / 100);
        payable(address(feeRecipients_[2])).transfer(address(this).balance);
    }

    function setFeeRecipient(address newFeeRecipient, uint8 index)
        external
        onlyOperator
    {
        require(index < feeRecipients.length, 'Index too high.');
        require(newFeeRecipient != address(0), 'Invalid address.');

        feeRecipients[index] = newFeeRecipient;
    }

    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = address(this);
        royaltyAmount = (value * 1000) / 10000;
    }

    function hashMintingOrder(MintingOrder memory mintingOrder)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(mintingOrder));
    }

    function setMintingSigner(address mintSigner_) external onlyOperator {
        require(mintSigner_ != address(0), 'Invalid Signer address.');
        mintSigner = mintSigner_;
    }

    function setContractOperator(address newOperator) external onlyOperator {
        contractOperator = newOperator;
    }

    function setOldMetaHolder(address oldMetaHolder_) external onlyOperator {
        require(oldMetaHolder_ != address(0), 'Invalid Contract address.');
        oldMetaHolder = oldMetaHolder_;
    }

    function createMintingOrder(
        address to,
        uint256 seed,
        string memory signature,
        string memory imageHash
    )
        external
        view
        returns (MintingOrder memory mintingOrder, bytes32 message)
    {
        mintingOrder = MintingOrder({
            to: to,
            expiration: block.timestamp + getExpiration(),
            seed: seed,
            signature: signature,
            imageHash: imageHash
        });

        message = hashMintingOrder(mintingOrder);
    }

    function tokenIdFromOrder(MintingOrder memory mintingOrder)
        external
        view
        returns (uint256)
    {
        bytes32 message = hashMintingOrder(mintingOrder)
            .toEthSignedMessageHash();
        return messageToTokenId[message];
    }

    function requestMetaUpdate(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, 'Not token owner.');
        requestUpdates[tokenId] = true;
        emit RequestUpdate(msg.sender, tokenId);
    }

    function updateMeta(
        uint256 tokenId,
        string memory newImageHash,
        string memory newSignature
    ) external onlyOperator {
        require(
            requestUpdates[tokenId] == true,
            'No update request for token.'
        );
        requestUpdates[tokenId] = false;

        AstragladeMeta memory astraglade = getAstraglade(tokenId);
        if (bytes(newImageHash).length > 0) {
            astraglade.imageHash = newImageHash;
        }

        if (bytes(newSignature).length > 0) {
            astraglade.signature = newSignature;
        }

        _astraglades[tokenId] = astraglade;
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        require(msg.sender == oldAstragladeContract, 'Only old Astraglades.');
        _mint(from, tokenId);

        ERC721Burnable(msg.sender).burn(tokenId);

        emit AstragladeUpgraded(from, tokenId);

        return 0x150b7a02;
    }
}//MIT
pragma solidity ^0.8.0;

library Randomize {
    struct Random {
        uint256 seed;
    }

    function randomDec(Random memory random) internal pure returns (uint256) {
        random.seed ^= random.seed << 13;
        random.seed ^= random.seed >> 17;
        random.seed ^= random.seed << 5;
        return ((random.seed < 0 ? ~random.seed + 1 : random.seed) % 1000);
    }

    function randomBetween(
        Random memory random,
        uint256 min,
        uint256 max
    ) internal pure returns (uint256) {
        return min * 1000 + (max - min) * Randomize.randomDec(random);
    }
}pragma solidity ^0.8.0;


library Base64 {
    string internal constant TABLE =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                let input := mload(dataPtr)

                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}//MIT
pragma solidity ^0.8.9;






contract PlanetsModule is
    Ownable,
    NFBaseModule,
    INFModuleTokenURI,
    INFModuleRenderTokenURI,
    INFModuleWithRoyalties
{
    using Strings for uint256;
    using Randomize for Randomize.Random;

    uint256 constant SEED_BOUND = 1000000000;

    event PlanetsClaimed(uint256[] tokenIds);

    address public planetsContract;

    address public astragladeContract;

    address public contractOperator =
        address(0xD1edDfcc4596CC8bD0bd7495beaB9B979fc50336);

    string private _baseRenderURI;

    bool public frozenMeta;

    string private _baseImagesURI;

    string internal _description;

    address[3] public feeRecipients = [
        0xe4657aF058E3f844919c3ee713DF09c3F2949447,
        0xb275E5aa8011eA32506a91449B190213224aEc1e,
        0xdAC81C3642b520584eD0E743729F238D1c350E62
    ];

    mapping(uint256 => bytes32) public planetSeed;

    mapping(uint256 => bool) public seedTaken;

    modifier onlyOperator() {
        require(isOperator(msg.sender), 'Not operator.');
        _;
    }

    function isOperator(address operator) public view returns (bool) {
        return owner() == operator || contractOperator == operator;
    }

    receive() external payable {}

    constructor(
        string memory contractURI_,
        address owner_,
        address planetsContract_,
        address astragladeContract_
    ) NFBaseModule(contractURI_) {
        planetsContract = planetsContract_;
        astragladeContract = astragladeContract_;

        if (address(0) != owner_) {
            transferOwnership(owner_);
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(INFModuleTokenURI).interfaceId ||
            interfaceId == type(INFModuleRenderTokenURI).interfaceId ||
            interfaceId == type(INFModuleWithRoyalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 tokenId)
        public
        view
        override
        returns (address, uint256)
    {
        return royaltyInfo(msg.sender, tokenId);
    }

    function royaltyInfo(address, uint256)
        public
        view
        override
        returns (address receiver, uint256 basisPoint)
    {
        receiver = address(this);
        basisPoint = 1000;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return tokenURI(msg.sender, tokenId);
    }

    function tokenURI(address, uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        (
            uint256 seed,
            uint256 astragladeSeed,
            uint256[] memory attributes
        ) = getPlanetData(tokenId);

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"Planet - ',
                            tokenId.toString(),
                            '","license":"CC BY-SA 4.0","description":"',
                            getDescription(),
                            '","created_by":"Fabin Rasheed","twitter":"@astraglade","image":"',
                            abi.encodePacked(
                                getBaseImageURI(),
                                tokenId.toString()
                            ),
                            '","seed":"',
                            seed.toString(),
                            abi.encodePacked(
                                '","astragladeSeed":"',
                                astragladeSeed.toString(),
                                '","attributes":[',
                                _generateJSONAttributes(attributes),
                                '],"animation_url":"',
                                _renderTokenURI(
                                    seed,
                                    astragladeSeed,
                                    attributes
                                ),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function renderTokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return renderTokenURI(msg.sender, tokenId);
    }

    function renderTokenURI(address, uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        (
            uint256 seed,
            uint256 astragladeSeed,
            uint256[] memory attributes
        ) = getPlanetData(tokenId);

        return _renderTokenURI(seed, astragladeSeed, attributes);
    }

    function getPlanetData(uint256 tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256[] memory
        )
    {
        require(planetSeed[tokenId] != 0, '!UNKNOWN_TOKEN!');

        uint256 seed = uint256(planetSeed[tokenId]) % SEED_BOUND;
        uint256[] memory attributes = _getAttributes(seed);

        AstragladeUpgrade.AstragladeMeta memory astraglade = AstragladeUpgrade(
            payable(astragladeContract)
        ).getAstraglade(tokenId);

        return (seed, astraglade.seed, attributes);
    }

    function getAstraglade(uint256 tokenId)
        public
        view
        returns (AstragladeUpgrade.AstragladeMeta memory astraglade)
    {
        return
            AstragladeUpgrade(payable(astragladeContract)).getAstraglade(
                tokenId
            );
    }

    function getDescription() public view returns (string memory) {
        if (bytes(_description).length == 0) {
            return
                "Astraglade Planets is an extension of project Astraglade (https://nurecas.com/astraglade). Planets are an interactive and generative 3D art that can be minted for free by anyone who owns an astraglade at [https://astraglade.beyondnft.io/planets/](https://astraglade.beyondnft.io/planets/). When a Planet is minted, the owner's astraglade will orbit forever around the planet that they mint.";
        }

        return _description;
    }

    function getBaseRenderURI() public view returns (string memory) {
        if (bytes(_baseRenderURI).length == 0) {
            return 'ar://JYtFvtxlpyur2Cdpaodmo46XzuTpmp0OwJl13rFUrrg/';
        }

        return _baseRenderURI;
    }

    function getBaseImageURI() public view returns (string memory) {
        if (bytes(_baseImagesURI).length == 0) {
            return 'https://astraglade-api.beyondnft.io/planets/images/';
        }

        return _baseImagesURI;
    }

    function onAttach()
        external
        virtual
        override(INFModule, NFBaseModule)
        returns (bool)
    {
        if (planetsContract == address(0)) {
            planetsContract = msg.sender;
            return true;
        }

        return false;
    }

    function claim(uint256[] calldata tokenIds) external {
        address operator = msg.sender;

        address astragladeContract_ = astragladeContract;
        address planetsContract_ = planetsContract;

        for (uint256 i; i < tokenIds.length; i++) {
            _claim(
                operator,
                tokenIds[i],
                astragladeContract_,
                planetsContract_
            );
        }
    }

    function freezeMeta() external onlyOperator {
        frozenMeta = true;
    }

    function setContractURI(string memory newURI) external onlyOperator {
        _setContractURI(newURI);
    }

    function setPlanetsContract(address planetsContract_)
        external
        onlyOperator
    {
        planetsContract = planetsContract_;
    }

    function setDescription(string memory newDescription)
        external
        onlyOperator
    {
        require(frozenMeta == false, '!META_FROZEN!');
        _description = newDescription;
    }

    function setBaseRenderURI(string memory newRenderURI)
        external
        onlyOperator
    {
        require(frozenMeta == false, '!META_FROZEN!');
        _baseRenderURI = newRenderURI;
    }

    function setBaseImagesURI(string memory newBaseImagesURI)
        external
        onlyOperator
    {
        require(frozenMeta == false, '!META_FROZEN!');
        _baseImagesURI = newBaseImagesURI;
    }

    function withdraw() external onlyOperator {
        address[3] memory feeRecipients_ = feeRecipients;

        uint256 balance_ = address(this).balance;
        payable(address(feeRecipients_[0])).transfer((balance_ * 30) / 100);
        payable(address(feeRecipients_[1])).transfer((balance_ * 35) / 100);
        payable(address(feeRecipients_[2])).transfer(address(this).balance);
    }

    function setFeeRecipient(address newFeeRecipient, uint8 index)
        external
        onlyOperator
    {
        require(index < feeRecipients.length, '!INDEX_OVERFLOW!');
        require(newFeeRecipient != address(0), '!INVALID_ADDRESS!');

        feeRecipients[index] = newFeeRecipient;
    }

    function setContractOperator(address newOperator) external onlyOperator {
        contractOperator = newOperator;
    }

    function _claim(
        address operator,
        uint256 tokenId,
        address astragladeContract_,
        address planetsContract_
    ) internal {
        AstragladeUpgrade astraglade = AstragladeUpgrade(
            payable(astragladeContract_)
        );
        address owner_ = astraglade.ownerOf(tokenId);

        require(
            owner_ == operator ||
                astraglade.isApprovedForAll(owner_, operator) ||
                astraglade.getApproved(tokenId) == operator,
            '!NOT_AUTHORIZED!'
        );

        INiftyForge721 planets = INiftyForge721(planetsContract_);

        planets.mint(owner_, '', tokenId, address(0), 0, address(0));

        bytes32 seed;
        do {
            seed = _generateSeed(
                tokenId,
                block.timestamp,
                owner_,
                blockhash(block.number - 1)
            );
        } while (seedTaken[uint256(seed) % SEED_BOUND]);

        planetSeed[tokenId] = seed;
        seedTaken[uint256(seed) % SEED_BOUND] = true;
    }

    function _generateSeed(
        uint256 tokenId,
        uint256 timestamp,
        address operator,
        bytes32 blockHash
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    tokenId,
                    timestamp,
                    operator,
                    blockHash,
                    block.coinbase,
                    block.difficulty,
                    tx.gasprice
                )
            );
    }

    function _getAttributes(uint256 seed)
        internal
        pure
        returns (uint256[] memory attributes)
    {
        Randomize.Random memory random = Randomize.Random({seed: seed});

        attributes = new uint256[](6);

        attributes[0] = random.randomBetween(10, 200);

        attributes[1] = random.randomBetween(5, 15);

        attributes[2] = random.randomBetween(0, 5000);
        if (attributes[2] < 20000) {
            attributes[1] = 10000;
        }

        attributes[3] = random.randomBetween(0, 2) < 1000 ? 0 : 1;

        if (attributes[2] < 20000) {
            attributes[4] = random.randomBetween(2, 4) / 1000;
        } else {
            attributes[4] = random.randomBetween(0, 10) / 1000;
            if (attributes[4] > 3) {
                attributes[4] = 0;
            }
        }

        attributes[5] = random.randomBetween(0, 4) / 1000;
    }

    function _generateJSONAttributes(uint256[] memory attributes)
        internal
        pure
        returns (string memory)
    {
        bytes memory coma = bytes(',');

        bytes memory jsonAttributes = abi.encodePacked(
            _makeAttributes(
                'Terrain',
                attributes[0] < 50000 ? 'Dense' : 'Sparse'
            ),
            coma
        );

        if (attributes[1] < 8000) {
            jsonAttributes = abi.encodePacked(
                jsonAttributes,
                _makeAttributes('Size', 'Tiny'),
                coma
            );
        } else if (attributes[1] < 12000) {
            jsonAttributes = abi.encodePacked(
                jsonAttributes,
                _makeAttributes('Size', 'Medium'),
                coma
            );
        } else {
            jsonAttributes = abi.encodePacked(
                jsonAttributes,
                _makeAttributes('Size', 'Giant'),
                coma
            );
        }

        jsonAttributes = abi.encodePacked(
            jsonAttributes,
            _makeAttributes(
                'Form',
                attributes[2] < 20000 ? 'Tesseract' : 'Geo'
            ),
            coma,
            _makeAttributes('Shade', attributes[3] == 0 ? 'Vibrant' : 'Simple'),
            coma,
            _makeAttributes('Rings', attributes[4].toString()),
            coma,
            _makeAttributes('Moons', attributes[5].toString())
        );

        return string(jsonAttributes);
    }

    function _makeAttributes(string memory name_, string memory value)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodePacked(
                '{"trait_type":"',
                name_,
                '","value":"',
                value,
                '"}'
            );
    }

    function _renderTokenURI(
        uint256 seed,
        uint256 astragladeSeed,
        uint256[] memory attributes
    ) internal view returns (string memory) {
        bytes memory coma = bytes(',');

        bytes memory attrs = abi.encodePacked(
            attributes[0].toString(),
            coma,
            attributes[1].toString(),
            coma,
            attributes[2].toString(),
            coma
        );

        return
            string(
                abi.encodePacked(
                    getBaseRenderURI(),
                    '?seed=',
                    seed.toString(),
                    '&astragladeSeed=',
                    astragladeSeed.toString(),
                    '&attributes=',
                    abi.encodePacked(
                        attrs,
                        attributes[3].toString(),
                        coma,
                        attributes[4].toString(),
                        coma,
                        attributes[5].toString()
                    )
                )
            );
    }
}