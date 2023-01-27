
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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC1271Upgradeable {

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);

}// MIT

pragma solidity ^0.8.0;

library ClonesUpgradeable {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

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


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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


abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Burnable_init_unchained();
    }

    function __ERC721Burnable_init_unchained() internal initializer {
    }
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721URIStorage_init_unchained();
    }

    function __ERC721URIStorage_init_unchained() internal initializer {
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

library ECDSAUpgradeable {

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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;


library SignatureCheckerUpgradeable {

    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {

        (address recovered, ECDSAUpgradeable.RecoverError error) = ECDSAUpgradeable.tryRecover(hash, signature);
        if (error == ECDSAUpgradeable.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271Upgradeable.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271Upgradeable.isValidSignature.selector);
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
}//MIT
pragma solidity ^0.8.9;


contract ForgeMasterStorage {

    bool internal _locked;

    uint256 internal _fee;

    uint256 internal _freeCreations;

    address internal _erc721Implementation;

    address internal _erc1155Implementation;

    address internal _openseaERC721ProxyRegistry;

    address internal _openseaERC1155ProxyRegistry;

    EnumerableSetUpgradeable.AddressSet internal _registries;

    EnumerableSetUpgradeable.AddressSet internal _modules;

    mapping(bytes32 => address) internal _slugsToRegistry;
    mapping(address => bytes32) internal _registryToSlug;

    mapping(address => uint256) public lastIndexing;


    mapping(address => bool) public flaggedRegistries;

    mapping(address => mapping(uint256 => bool)) internal _flaggedTokens;

    uint256[50] private __gap;
}//MIT
pragma solidity ^0.8.9;

contract BaseOpenSea {

    event NewContractURI(string contractURI);

    string private _contractURI;
    address private _proxyRegistry;

    function contractURI() public view returns (string memory) {

        return _contractURI;
    }

    function proxyRegistry() public view returns (address) {

        return _proxyRegistry;
    }

    function isOwnersOpenSeaProxy(address owner, address operator)
        public
        view
        returns (bool)
    {

        address proxyRegistry_ = _proxyRegistry;

        if (proxyRegistry_ != address(0)) {
            if (block.chainid == 1 || block.chainid == 4) {
                return
                    address(ProxyRegistry(proxyRegistry_).proxies(owner)) ==
                    operator;
            } else if (block.chainid == 137 || block.chainid == 80001) {
                return proxyRegistry_ == operator;
            }
        }

        return false;
    }

    function _setContractURI(string memory contractURI_) internal {

        _contractURI = contractURI_;
        emit NewContractURI(contractURI_);
    }

    function _setOpenSeaRegistry(address proxyRegistryAddress) internal {

        _proxyRegistry = proxyRegistryAddress;
    }
}

contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}//MIT
pragma solidity ^0.8.9;



contract ERC721Ownable is OwnableUpgradeable, ERC721Upgradeable, BaseOpenSea {

    modifier onlyEditor(address sender) virtual {

        require(sender == owner(), '!NOT_EDITOR!');
        _;
    }

    function __ERC721Ownable_init(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        address openseaProxyRegistry_,
        address owner_
    ) internal initializer {

        __Ownable_init();
        __ERC721_init_unchained(name_, symbol_);

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

    function isApprovedForAll(address owner_, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {

        return
            super.isApprovedForAll(owner_, operator) ||
            isOwnersOpenSeaProxy(owner_, operator);
    }

    function setContractURI(string memory contractURI_)
        external
        onlyEditor(msg.sender)
    {

        _setContractURI(contractURI_);
    }

    function setOpenSeaRegistry(address osProxyRegistry)
        external
        onlyEditor(msg.sender)
    {

        _setOpenSeaRegistry(osProxyRegistry);
    }
}//MIT
pragma solidity ^0.8.9;


abstract contract ERC721WithRoles {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    event RoleGranted(bytes32 indexed role, address indexed user);

    event RoleRevoked(bytes32 indexed role, address indexed user);

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet)
        private _roleMembers;

    function hasRole(bytes32 role, address user) public view returns (bool) {
        return _roleMembers[role].contains(user);
    }

    function listRole(bytes32 role)
        external
        view
        returns (address[] memory list)
    {
        uint256 count = _roleMembers[role].length();
        list = new address[](count);
        for (uint256 i; i < count; i++) {
            list[i] = _roleMembers[role].at(i);
        }
    }

    function _grantRole(bytes32 role, address user) internal returns (bool) {
        if (_roleMembers[role].add(user)) {
            emit RoleGranted(role, user);
            return true;
        }

        return false;
    }

    function _revokeRole(bytes32 role, address user) internal returns (bool) {
        if (_roleMembers[role].remove(user)) {
            emit RoleRevoked(role, user);
            return true;
        }
        return false;
    }
}// MIT
pragma solidity ^0.8.9;

interface IERC2981Royalties {

    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);

}// MIT
pragma solidity ^0.8.9;


abstract contract ERC2981Royalties is IERC2981Royalties {
    struct RoyaltyData {
        address recipient;
        uint96 amount;
    }

    bool private _useContractRoyalties;

    RoyaltyData private _contractRoyalties;

    mapping(uint256 => RoyaltyData) private _royalties;

    function hasPerTokenRoyalties() public view returns (bool) {
        return !_useContractRoyalties;
    }

    function royaltyInfo(uint256 tokenId, uint256 value)
        public
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        (receiver, royaltyAmount) = _getTokenRoyalty(tokenId);

        if (royaltyAmount != 0) {
            royaltyAmount = (value * royaltyAmount) / 10000;
        }
    }

    function _removeRoyalty(uint256 id) internal {
        delete _royalties[id];
    }

    function _setTokenRoyalty(
        uint256 id,
        address recipient,
        uint256 value
    ) internal {
        require(
            !_useContractRoyalties,
            '!ERC2981Royalties:ROYALTIES_CONTRACT_WIDE!'
        );
        require(value <= 10000, '!ERC2981Royalties:TOO_HIGH!');

        _royalties[id] = RoyaltyData(recipient, uint96(value));
    }

    function _getTokenRoyalty(uint256 id)
        internal
        view
        virtual
        returns (address, uint256)
    {
        RoyaltyData memory data;
        if (_useContractRoyalties) {
            data = _contractRoyalties;
        } else {
            data = _royalties[id];
        }

        return (data.recipient, uint256(data.amount));
    }

    function _setDefaultRoyalties(address recipient, uint256 value) internal {
        require(
            _useContractRoyalties == false,
            '!ERC2981Royalties:DEFAULT_ALREADY_SET!'
        );
        require(value <= 10000, '!ERC2981Royalties:TOO_HIGH!');
        _useContractRoyalties = true;
        _contractRoyalties = RoyaltyData(recipient, uint96(value));
    }

    function _setDefaultRoyaltiesRecipient(address recipient) internal {
        _contractRoyalties.recipient = recipient;
    }

    function _setTokenRoyaltiesRecipient(uint256 tokenId, address recipient)
        internal
    {
        _royalties[tokenId].recipient = recipient;
    }
}// MIT
pragma solidity ^0.8.9;

interface IRaribleSecondarySales {

    function getFeeRecipients(uint256 tokenId)
        external
        view
        returns (address payable[] memory);


    function getFeeBps(uint256 tokenId)
        external
        view
        returns (uint256[] memory);

}// MIT
pragma solidity ^0.8.9;

interface IFoundationSecondarySales {

    function getFees(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);

}// MIT
pragma solidity ^0.8.9;



contract ERC721WithRoyalties is
    ERC2981Royalties,
    IRaribleSecondarySales,
    IFoundationSecondarySales
{

    function getFeeRecipients(uint256 tokenId)
        public
        view
        override
        returns (address payable[] memory recipients)
    {

        (address recipient, uint256 amount) = _getTokenRoyalty(tokenId);
        if (amount != 0) {
            recipients = new address payable[](1);
            recipients[0] = payable(recipient);
        }
    }

    function getFeeBps(uint256 tokenId)
        public
        view
        override
        returns (uint256[] memory fees)
    {

        (, uint256 amount) = _getTokenRoyalty(tokenId);
        if (amount != 0) {
            fees = new uint256[](1);
            fees[0] = amount;
        }
    }

    function getFees(uint256 tokenId)
        external
        view
        virtual
        override
        returns (address payable[] memory recipients, uint256[] memory fees)
    {

        (address recipient, uint256 amount) = _getTokenRoyalty(tokenId);
        if (amount != 0) {
            recipients = new address payable[](1);
            recipients[0] = payable(recipient);

            fees = new uint256[](1);
            fees[0] = amount;
        }
    }
}//MIT
pragma solidity ^0.8.9;


abstract contract ERC721WithPermit is ERC721Upgradeable {
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            'Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)'
        );

    bytes32 public DOMAIN_SEPARATOR;

    mapping(uint256 => uint256) private _nonces;

    function __ERC721WithPermit_init(string memory name_) internal {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
                ),
                keccak256(bytes(name_)),
                keccak256(bytes('1')),
                block.chainid,
                address(this)
            )
        );
    }

    function nonce(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');
        return _nonces[tokenId];
    }

    function makePermitDigest(
        address spender,
        uint256 tokenId,
        uint256 nonce_,
        uint256 deadline
    ) public view returns (bytes32) {
        return
            ECDSAUpgradeable.toTypedDataHash(
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        spender,
                        tokenId,
                        nonce_,
                        deadline
                    )
                )
            );
    }

    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) public {
        require(deadline >= block.timestamp, '!PERMIT_DEADLINE_EXPIRED!');

        address owner_ = ownerOf(tokenId);

        bytes32 digest = makePermitDigest(
            spender,
            tokenId,
            _nonces[tokenId],
            deadline
        );

        (address recoveredAddress, ) = ECDSAUpgradeable.tryRecover(
            digest,
            signature
        );
        require(
            (
                (recoveredAddress == owner_ ||
                    isApprovedForAll(owner_, recoveredAddress))
            ) ||
                SignatureCheckerUpgradeable.isValidSignatureNow(
                    owner_,
                    digest,
                    signature
                ),
            '!INVALID_PERMIT_SIGNATURE!'
        );

        _approve(spender, tokenId);
    }

    function _incrementNonce(uint256 tokenId) internal {
        _nonces[tokenId]++;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._transfer(from, to, tokenId);
        if (from != address(0)) {
            _incrementNonce(tokenId);
        }
    }
}// MIT
pragma solidity ^0.8.9;

interface IERC721WithMutableURI {

    function mutableURI(uint256 tokenId) external view returns (string memory);

}// MIT
pragma solidity ^0.8.9;



contract ERC721WithMutableURI is IERC721WithMutableURI, ERC721Upgradeable {

    using StringsUpgradeable for uint256;

    string public baseMutableURI;

    mapping(uint256 => string) private _tokensMutableURIs;

    function mutableURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {

        require(_exists(tokenId), '!UNKNOWN_TOKEN!');

        string memory _tokenMutableURI = _tokensMutableURIs[tokenId];
        string memory base = _baseMutableURI();

        if (bytes(base).length > 0 && bytes(_tokenMutableURI).length > 0) {
            return string(abi.encodePacked(base, _tokenMutableURI));
        }

        if (bytes(_tokenMutableURI).length > 0) {
            return _tokenMutableURI;
        }

        return
            bytes(base).length > 0
                ? string(abi.encodePacked(base, tokenId.toString()))
                : '';
    }

    function _baseMutableURI() internal view returns (string memory) {

        return baseMutableURI;
    }

    function _setBaseMutableURI(string memory baseMutableURI_) internal {

        baseMutableURI = baseMutableURI_;
    }

    function _setMutableURI(uint256 tokenId, string memory mutableURI_)
        internal
    {

        if (bytes(mutableURI_).length == 0) {
            if (bytes(_tokensMutableURIs[tokenId]).length > 0) {
                delete _tokensMutableURIs[tokenId];
            }
        } else {
            _tokensMutableURIs[tokenId] = mutableURI_;
        }
    }
}//MIT
pragma solidity ^0.8.9;



abstract contract ERC721Full is
    ERC721Ownable,
    ERC721BurnableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721WithRoles,
    ERC721WithRoyalties,
    ERC721WithPermit,
    ERC721WithMutableURI
{
    bytes32 public constant ROLE_EDITOR = keccak256('EDITOR');
    bytes32 public constant ROLE_MINTER = keccak256('MINTER');

    string public baseURI;

    modifier onlyMinter(address minter) virtual {
        require(canMint(minter), '!NOT_MINTER!');
        _;
    }

    modifier onlyEditor(address sender) virtual override {
        require(canEdit(sender), '!NOT_EDITOR!');
        _;
    }

    function __ERC721Full_init(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        address openseaProxyRegistry_,
        address owner_
    ) internal {
        __ERC721Ownable_init(
            name_,
            symbol_,
            contractURI_,
            openseaProxyRegistry_,
            owner_
        );

        __ERC721WithPermit_init(name_);
    }


    function withdraw(
        address token,
        uint256 amount,
        uint256 tokenId
    ) external onlyOwner {
        if (token == address(0)) {
            require(
                amount == 0 || address(this).balance >= amount,
                '!WRONG_VALUE!'
            );
            (bool success, ) = msg.sender.call{value: amount}('');
            require(success, '!TRANSFER_FAILED!');
        } else {
            if (
                IERC165Upgradeable(token).supportsInterface(
                    type(IERC1155Upgradeable).interfaceId
                )
            ) {
                IERC1155Upgradeable(token).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenId,
                    amount,
                    ''
                );
            } else if (
                IERC165Upgradeable(token).supportsInterface(
                    type(IERC721Upgradeable).interfaceId
                )
            ) {
                IERC721Upgradeable(token).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenId,
                    ''
                );
            } else {
                require(
                    IERC20Upgradeable(token).transfer(msg.sender, amount),
                    '!TRANSFER_FAILED!'
                );
            }
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
            interfaceId == type(IERC721WithMutableURI).interfaceId ||
            interfaceId == type(IERC2981Royalties).interfaceId ||
            interfaceId == type(IRaribleSecondarySales).interfaceId ||
            interfaceId == type(IFoundationSecondarySales).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function isApprovedForAll(address owner_, address operator)
        public
        view
        override(ERC721Upgradeable, ERC721Ownable)
        returns (bool)
    {
        return super.isApprovedForAll(owner_, operator);
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

    function canEdit(address user) public view virtual returns (bool) {
        return isEditor(user) || owner() == user;
    }

    function canMint(address user) public view virtual returns (bool) {
        return isMinter(user) || canEdit(user);
    }

    function isEditor(address user) public view returns (bool) {
        return hasRole(ROLE_EDITOR, user);
    }

    function isMinter(address user) public view returns (bool) {
        return hasRole(ROLE_MINTER, user);
    }

    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external {
        permit(msg.sender, tokenId, deadline, signature);

        safeTransferFrom(from, to, tokenId, _data);
    }

    function setBaseURI(string memory baseURI_)
        external
        onlyEditor(msg.sender)
    {
        baseURI = baseURI_;
    }

    function setBaseMutableURI(string memory baseMutableURI_)
        external
        onlyEditor(msg.sender)
    {
        _setBaseMutableURI(baseMutableURI_);
    }

    function setMutableURI(uint256 tokenId, string memory mutableURI_)
        external
        onlyEditor(msg.sender)
    {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');
        _setMutableURI(tokenId, mutableURI_);
    }

    function addEditors(address[] memory users) public onlyOwner {
        for (uint256 i; i < users.length; i++) {
            _grantRole(ROLE_MINTER, users[i]);
        }
    }

    function removeEditors(address[] memory users) public onlyOwner {
        for (uint256 i; i < users.length; i++) {
            _revokeRole(ROLE_MINTER, users[i]);
        }
    }

    function addMinters(address[] memory users) public onlyEditor(msg.sender) {
        for (uint256 i; i < users.length; i++) {
            _grantRole(ROLE_MINTER, users[i]);
        }
    }

    function removeMinters(address[] memory users)
        public
        onlyEditor(msg.sender)
    {
        for (uint256 i; i < users.length; i++) {
            _revokeRole(ROLE_MINTER, users[i]);
        }
    }

    function setDefaultRoyaltiesRecipient(address recipient)
        external
        onlyEditor(msg.sender)
    {
        require(!hasPerTokenRoyalties(), '!PER_TOKEN_ROYALTIES!');
        _setDefaultRoyaltiesRecipient(recipient);
    }

    function setTokenRoyaltiesRecipient(uint256 tokenId, address recipient)
        external
    {
        require(hasPerTokenRoyalties(), '!CONTRACT_WIDE_ROYALTIES!');

        (address currentRecipient, ) = _getTokenRoyalty(tokenId);
        require(msg.sender == currentRecipient, '!NOT_ALLOWED!');

        _setTokenRoyaltiesRecipient(tokenId, recipient);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Upgradeable, ERC721WithPermit) {
        super._transfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        _removeRoyalty(tokenId);

        _setMutableURI(tokenId, '');

        super._burn(tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}//MIT
pragma solidity ^0.8.9;


interface INFModule is IERC165Upgradeable {

    function onAttach() external returns (bool);


    function onEnable() external returns (bool);


    function onDisable() external;


    function contractURI() external view returns (string memory);

}//MIT
pragma solidity ^0.8.9;


interface INFModuleWithEvents is INFModule {

    enum Events {
        MINT,
        TRANSFER,
        BURN
    }

    function onEvent(
        Events eventType,
        uint256 tokenId,
        address from,
        address to
    ) external;

}//MIT
pragma solidity ^0.8.9;


interface INFModuleTokenURI is INFModule {

    function tokenURI(uint256 tokenId) external view returns (string memory);


    function tokenURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);

}//MIT
pragma solidity ^0.8.9;


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
pragma solidity ^0.8.9;


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
pragma solidity ^0.8.9;


interface INFModuleMutableURI is INFModule {

    function mutableURI(uint256 tokenId) external view returns (string memory);


    function mutableURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);

}//MIT
pragma solidity ^0.8.9;


interface INiftyForgeModules {

    enum ModuleStatus {
        UNKNOWN,
        ENABLED,
        DISABLED
    }

    function listModules()
        external
        view
        returns (address[] memory list, uint256[] memory status);


    function addEventListener(INFModuleWithEvents.Events eventType) external;


    function removeEventListener(INFModuleWithEvents.Events eventType) external;

}//MIT
pragma solidity ^0.8.9;


contract NiftyForgeModules is INiftyForgeModules {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    event ModuleChanged(address module);

    EnumerableSetUpgradeable.AddressSet[3] private _listeners;

    EnumerableSetUpgradeable.AddressSet internal modules;

    mapping(address => ModuleStatus) public modulesStatus;

    modifier onlyEnabledModule() {

        require(
            modulesStatus[msg.sender] == ModuleStatus.ENABLED,
            '!MODULE_NOT_ENABLED!'
        );
        _;
    }

    function listModules()
        external
        view
        override
        returns (address[] memory list, uint256[] memory status)
    {

        uint256 count = modules.length();
        list = new address[](count);
        status = new uint256[](count);
        for (uint256 i; i < count; i++) {
            list[i] = modules.at(i);
            status[i] = uint256(modulesStatus[list[i]]);
        }
    }

    function addEventListener(INFModuleWithEvents.Events eventType)
        external
        override
        onlyEnabledModule
    {

        _listeners[uint256(eventType)].add(msg.sender);
    }

    function removeEventListener(INFModuleWithEvents.Events eventType)
        external
        override
        onlyEnabledModule
    {

        _listeners[uint256(eventType)].remove(msg.sender);
    }

    function _attachModule(address module, bool enabled) internal {

        require(
            modulesStatus[module] == ModuleStatus.UNKNOWN,
            '!ALREADY_ATTACHED!'
        );

        modules.add(module);

        require(INFModule(module).onAttach(), '!ATTACH_FAILED!');

        if (enabled) {
            _enableModule(module);
        } else {
            _disableModule(module, true);
        }
    }

    function _enableModule(address module) internal {

        require(
            modulesStatus[module] != ModuleStatus.ENABLED,
            '!NOT_DISABLED!'
        );
        modulesStatus[module] = ModuleStatus.ENABLED;

        require(INFModule(module).onEnable(), '!ENABLING_FAILED!');
        emit ModuleChanged(module);
    }

    function _disableModule(address module, bool keepListeners)
        internal
        virtual
    {

        require(
            modulesStatus[module] != ModuleStatus.DISABLED,
            '!NOT_ENABLED!'
        );
        modulesStatus[module] = ModuleStatus.DISABLED;

        try INFModule(module).onDisable() {} catch {}

        if (!keepListeners) {
            _listeners[uint256(INFModuleWithEvents.Events.MINT)].remove(module);
            _listeners[uint256(INFModuleWithEvents.Events.TRANSFER)].remove(
                module
            );
            _listeners[uint256(INFModuleWithEvents.Events.BURN)].remove(module);
        }

        emit ModuleChanged(module);
    }

    function _fireEvent(
        INFModuleWithEvents.Events eventType,
        uint256 tokenId,
        address from,
        address to
    ) internal {

        EnumerableSetUpgradeable.AddressSet storage listeners = _listeners[
            uint256(eventType)
        ];
        uint256 length = listeners.length();
        for (uint256 i; i < length; i++) {
            INFModuleWithEvents(listeners.at(i)).onEvent(
                eventType,
                tokenId,
                from,
                to
            );
        }
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
pragma solidity ^0.8.9;




contract NiftyForge721 is INiftyForge721, NiftyForgeModules, ERC721Full {

    uint256 public lastTokenId;

    uint256 public totalSupply;

    bool private _mintingOpenToAll;

    uint256 public maxTokenId;

    mapping(uint256 => address) public tokenIdToModule;

    modifier onlyMinter(address minter) virtual override {

        require(isMintingOpenToAll() || canMint(minter), '!NOT_MINTER!');
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        address openseaProxyRegistry_,
        address owner_,
        ModuleInit[] memory modulesInit_,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue
    ) external initializer {

        __ERC721Full_init(
            name_,
            symbol_,
            contractURI_,
            openseaProxyRegistry_,
            owner_
        );

        for (uint256 i; i < modulesInit_.length; i++) {
            _attachModule(modulesInit_[i].module, modulesInit_[i].enabled);
            if (modulesInit_[i].enabled && modulesInit_[i].minter) {
                _grantRole(ROLE_MINTER, modulesInit_[i].module);
            }
        }

        if (
            contractRoyaltiesRecipient != address(0) ||
            contractRoyaltiesValue != 0
        ) {
            _setDefaultRoyalties(
                contractRoyaltiesRecipient,
                contractRoyaltiesValue
            );
        }
    }

    function isMintingOpenToAll() public view override returns (bool) {

        return _mintingOpenToAll;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory uri)
    {

        require(_exists(tokenId), '!UNKNOWN_TOKEN!');

        (bool support, address module) = _moduleSupports(
            tokenId,
            type(INFModuleTokenURI).interfaceId
        );
        if (support) {
            uri = INFModuleTokenURI(module).tokenURI(tokenId);
        }

        if (bytes(uri).length == 0) {
            uri = super.tokenURI(tokenId);
        }
    }

    function renderTokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory uri)
    {

        require(_exists(tokenId), '!UNKNOWN_TOKEN!');

        (bool support, address module) = _moduleSupports(
            tokenId,
            type(INFModuleRenderTokenURI).interfaceId
        );
        if (support) {
            uri = INFModuleRenderTokenURI(module).renderTokenURI(tokenId);
        }
    }

    function setMintingOpenToAll(bool isOpen)
        external
        override
        onlyEditor(msg.sender)
    {

        _mintingOpenToAll = isOpen;
    }

    function setMaxTokenId(uint256 maxTokenId_)
        external
        onlyEditor(msg.sender)
    {

        require(maxTokenId == 0, '!MAX_TOKEN_ALREADY_SET!');
        maxTokenId = maxTokenId_;
    }

    function mutableURI(uint256 tokenId)
        public
        view
        override
        returns (string memory uri)
    {

        require(_exists(tokenId), '!UNKNOWN_TOKEN!');

        (bool support, address module) = _moduleSupports(
            tokenId,
            type(INFModuleMutableURI).interfaceId
        );
        if (support) {
            uri = INFModuleMutableURI(module).mutableURI(tokenId);
        }

        if (bytes(uri).length == 0) {
            uri = super.mutableURI(tokenId);
        }
    }

    function mint(
        address to,
        string memory uri,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) public override onlyMinter(msg.sender) returns (uint256 tokenId) {

        tokenId = lastTokenId + 1;
        lastTokenId = mint(
            to,
            uri,
            tokenId,
            feeRecipient,
            feeAmount,
            transferTo
        );
    }

    function mintBatch(
        address[] memory to,
        string[] memory uris,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    )
        public
        override
        onlyMinter(msg.sender)
        returns (uint256[] memory tokenIds)
    {

        require(
            to.length == uris.length &&
                to.length == feeRecipients.length &&
                to.length == feeAmounts.length,
            '!LENGTH_MISMATCH!'
        );

        uint256 tokenId = lastTokenId;

        tokenIds = new uint256[](to.length);
        _verifyMaxTokenId(tokenId + to.length);

        bool isModule = modulesStatus[msg.sender] == ModuleStatus.ENABLED;
        for (uint256 i; i < to.length; i++) {
            tokenId++;
            _mint(
                to[i],
                uris[i],
                tokenId,
                feeRecipients[i],
                feeAmounts[i],
                isModule
            );
            tokenIds[i] = tokenId;
        }

        lastTokenId = tokenId;
    }

    function mint(
        address to,
        string memory uri,
        uint256 tokenId_,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) public override onlyMinter(msg.sender) returns (uint256) {


        _verifyMaxTokenId(tokenId_);

        _mint(
            to,
            uri,
            tokenId_,
            feeRecipient,
            feeAmount,
            modulesStatus[msg.sender] == ModuleStatus.ENABLED
        );

        if (transferTo != address(0)) {
            _transfer(to, transferTo, tokenId_);
        }

        return tokenId_;
    }

    function mintBatch(
        address[] memory to,
        string[] memory uris,
        uint256[] memory tokenIds,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    ) public override onlyMinter(msg.sender) returns (uint256[] memory) {


        require(
            to.length == uris.length &&
                to.length == tokenIds.length &&
                to.length == feeRecipients.length &&
                to.length == feeAmounts.length,
            '!LENGTH_MISMATCH!'
        );

        uint256 highestId;
        for (uint256 i; i < tokenIds.length; i++) {
            if (tokenIds[i] > highestId) {
                highestId = tokenIds[i];
            }
        }

        _verifyMaxTokenId(highestId);

        bool isModule = modulesStatus[msg.sender] == ModuleStatus.ENABLED;
        for (uint256 i; i < to.length; i++) {
            if (tokenIds[i] > highestId) {
                highestId = tokenIds[i];
            }

            _mint(
                to[i],
                uris[i],
                tokenIds[i],
                feeRecipients[i],
                feeAmounts[i],
                isModule
            );
        }

        return tokenIds;
    }

    function attachModule(
        address module,
        bool enabled,
        bool moduleCanMint
    ) external override onlyEditor(msg.sender) {

        if (moduleCanMint && enabled) {
            _grantRole(ROLE_MINTER, module);
        }

        _attachModule(module, enabled);
    }

    function enableModule(address module, bool moduleCanMint)
        external
        override
        onlyEditor(msg.sender)
    {

        if (moduleCanMint) {
            _grantRole(ROLE_MINTER, module);
        }

        _enableModule(module);
    }

    function disableModule(address module, bool keepListeners)
        external
        override
        onlyEditor(msg.sender)
    {

        _disableModule(module, keepListeners);
    }

    function _mint(
        address to,
        string memory uri,
        uint256 tokenId,
        address feeRecipient,
        uint256 feeAmount,
        bool isModule
    ) internal {

        _safeMint(to, tokenId, '');

        if (bytes(uri).length > 0) {
            _setTokenURI(tokenId, uri);
        }

        if (feeAmount > 0) {
            _setTokenRoyalty(tokenId, feeRecipient, feeAmount);
        }

        if (isModule) {
            tokenIdToModule[tokenId] = msg.sender;
        }
    }

    function _mint(address to, uint256 tokenId) internal virtual override {

        super._mint(to, tokenId);
        totalSupply++;

        _fireEvent(INFModuleWithEvents.Events.MINT, tokenId, address(0), to);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {

        super._transfer(from, to, tokenId);

        if (to == address(0xdEaD)) {
            _fireEvent(INFModuleWithEvents.Events.BURN, tokenId, from, to);
        } else {
            _fireEvent(INFModuleWithEvents.Events.TRANSFER, tokenId, from, to);
        }
    }

    function _burn(uint256 tokenId) internal virtual override {

        address owner_ = ownerOf(tokenId);
        super._burn(tokenId);
        totalSupply--;
        _fireEvent(
            INFModuleWithEvents.Events.BURN,
            tokenId,
            owner_,
            address(0)
        );
    }

    function _disableModule(address module, bool keepListeners)
        internal
        override
    {

        _revokeRole(ROLE_MINTER, module);

        super._disableModule(module, keepListeners);
    }

    function _verifyMaxTokenId(uint256 tokenId) internal view {

        uint256 maxTokenId_ = maxTokenId;
        require(maxTokenId_ == 0 || tokenId <= maxTokenId_, '!MAX_TOKEN_ID!');
    }

    function _getTokenRoyalty(uint256 tokenId)
        internal
        view
        override
        returns (address royaltyRecipient, uint256 royaltyAmount)
    {

        (royaltyRecipient, royaltyAmount) = super._getTokenRoyalty(tokenId);

        if (royaltyAmount == 0) {
            (bool support, address module) = _moduleSupports(
                tokenId,
                type(INFModuleWithRoyalties).interfaceId
            );
            if (support) {
                (royaltyRecipient, royaltyAmount) = INFModuleWithRoyalties(
                    module
                ).royaltyInfo(tokenId);
            }
        }
    }

    function _moduleSupports(uint256 tokenId, bytes4 interfaceId)
        internal
        view
        returns (bool support, address module)
    {

        module = tokenIdToModule[tokenId];
        support =
            module != address(0) &&
            IERC165Upgradeable(module).supportsInterface(interfaceId);
    }
}//MIT
pragma solidity ^0.8.9;




contract ForgeMaster is OwnableUpgradeable, ForgeMasterStorage {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    event RegistryCreated(address indexed registry, string context);

    event RegistrySlug(address indexed registry, string slug);

    event ModuleAdded(address indexed module);

    event ModuleRemoved(address indexed module);

    event ForceIndexing(address registry, uint256[] tokenIds);

    event FlagRegistry(address registry, address operator, string reason);

    event FlagToken(
        address registry,
        uint256 tokenId,
        address operator,
        string reason
    );

    function initialize(
        bool locked,
        uint256 fee_,
        uint256 freeCreations_,
        address erc721Implementation,
        address erc1155Implementation,
        address owner_
    ) external initializer {

        __Ownable_init();

        _locked = locked;
        _fee = fee_;
        _freeCreations = freeCreations_;
        _setERC721Implementation(erc721Implementation);
        _setERC1155Implementation(erc1155Implementation);

        if (owner_ != address(0)) {
            transferOwnership(owner_);
        }
    }

    function isLocked() external view returns (bool) {

        return _locked;
    }

    function fee() external view returns (uint256) {

        return _fee;
    }

    function freeCreations() external view returns (uint256) {

        return _freeCreations;
    }

    function getERC721Implementation() public view returns (address) {

        return _erc721Implementation;
    }

    function getERC1155Implementation() public view returns (address) {

        return _erc1155Implementation;
    }

    function getERC721ProxyRegistry() public view returns (address) {

        return _openseaERC721ProxyRegistry;
    }

    function getERC1155ProxyRegistry() public view returns (address) {

        return _openseaERC1155ProxyRegistry;
    }

    function isSlugFree(string memory slug) external view returns (bool) {

        bytes32 bSlug = keccak256(bytes(slug));
        return _slugsToRegistry[bSlug] != address(0);
    }

    function getRegistryBySlug(string memory slug)
        external
        view
        returns (address)
    {

        bytes32 bSlug = keccak256(bytes(slug));
        require(_slugsToRegistry[bSlug] != address(0), '!UNKNOWN_SLUG!');
        return _slugsToRegistry[bSlug];
    }

    function listRegistries(uint256 startAt, uint256 limit)
        external
        view
        returns (address[] memory list)
    {

        uint256 count = _registries.length();

        require(startAt < count, '!OVERFLOW!');

        if (startAt + limit > count) {
            limit = count - startAt;
        }

        list = new address[](limit);
        for (uint256 i; i < limit; i++) {
            list[i] = _registries.at(startAt + i);
        }
    }

    function listModules() external view returns (address[] memory list) {

        uint256 count = _modules.length();
        list = new address[](count);
        for (uint256 i; i < count; i++) {
            list[i] = _modules.at(i);
        }
    }

    function isTokenFlagged(address registry, uint256 tokenId)
        public
        view
        returns (bool)
    {

        return _flaggedTokens[registry][tokenId];
    }

    function createERC721(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        bool enableOpenSeaProxy,
        address owner_,
        NiftyForge721.ModuleInit[] memory modulesInit,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue,
        string memory slug,
        string memory context
    ) external payable returns (address newContract) {

        require(_erc721Implementation != address(0), '!NO_721_IMPLEMENTATION!');

        require(_locked == false || msg.sender == owner(), '!LOCKED!');

        if (_freeCreations == 0) {
            require(
                msg.value == _fee || msg.sender == owner(),
                '!WRONG_VALUE!'
            );
        } else {
            _freeCreations--;
        }

        newContract = ClonesUpgradeable.clone(_erc721Implementation);

        NiftyForge721(payable(newContract)).initialize(
            name_,
            symbol_,
            contractURI_,
            enableOpenSeaProxy ? _openseaERC721ProxyRegistry : address(0),
            owner_ != address(0) ? owner_ : msg.sender,
            modulesInit,
            contractRoyaltiesRecipient,
            contractRoyaltiesValue
        );

        _addRegistry(newContract, context);

        if (bytes(slug).length > 0) {
            setSlug(slug, newContract);
        }
    }

    function forceReindexing(address registry, uint256[] memory tokenIds)
        external
    {

        require(_registries.contains(registry), '!UNKNOWN_REGISTRY!');
        require(flaggedRegistries[registry] == false, '!FLAGGED_REGISTRY!');

        if (tokenIds.length == 0 || tokenIds.length > 10) {
            uint256 lastKnownIndexing = lastIndexing[registry];
            require(
                block.timestamp - lastKnownIndexing > 1 days,
                '!INDEXING_DELAY!'
            );

            require(
                NiftyForge721(payable(registry)).canEdit(msg.sender),
                '!NOT_EDITOR!'
            );
            lastIndexing[registry] = block.timestamp;
        }

        emit ForceIndexing(registry, tokenIds);
    }

    function flagRegistry(address registry, string memory reason)
        external
        onlyOwner
    {

        require(_registries.contains(registry), '!UNKNOWN_REGISTRY!');
        require(
            flaggedRegistries[registry] == false,
            '!REGISTRY_ALREADY_FLAGGED!'
        );

        flaggedRegistries[registry] = true;

        emit FlagRegistry(registry, msg.sender, reason);
    }

    function flagToken(
        address registry,
        uint256 tokenId,
        string memory reason
    ) external {

        require(_registries.contains(registry), '!UNKNOWN_REGISTRY!');
        require(
            flaggedRegistries[registry] == false,
            '!REGISTRY_ALREADY_FLAGGED!'
        );
        require(
            _flaggedTokens[registry][tokenId] == false,
            '!TOKEN_ALREADY_FLAGGED!'
        );

        require(
            msg.sender == owner() ||
                NiftyForge721(payable(registry)).canEdit(msg.sender),
            '!NOT_EDITOR!'
        );

        _flaggedTokens[registry][tokenId] = true;

        emit FlagToken(registry, tokenId, msg.sender, reason);
    }

    function setLocked(bool locked) external onlyOwner {

        _locked = locked;
    }

    function setFee(uint256 fee_) external onlyOwner {

        _fee = fee_;
    }

    function setFreeCreations(uint256 howMany) external onlyOwner {

        _freeCreations = howMany;
    }

    function setERC721Implementation(address implementation) public onlyOwner {

        _setERC721Implementation(implementation);
    }

    function setERC1155Implementation(address implementation) public onlyOwner {

        _setERC1155Implementation(implementation);
    }

    function setERC721ProxyRegistry(address proxy) public onlyOwner {

        _openseaERC721ProxyRegistry = proxy;
    }

    function setERC1155ProxyRegistry(address proxy) public onlyOwner {

        _openseaERC1155ProxyRegistry = proxy;
    }

    function addModule(address module) external onlyOwner {

        if (_modules.add(module)) {
            emit ModuleAdded(module);
        }
    }

    function removeModule(address module) external onlyOwner {

        if (_modules.remove(module)) {
            emit ModuleRemoved(module);
        }
    }

    function setSlug(string memory slug, address registry) public {

        bytes32 bSlug = keccak256(bytes(slug));

        require(_slugsToRegistry[bSlug] == address(0), '!SLUG_IN_USE!');

        require(
            NiftyForge721(payable(registry)).canEdit(msg.sender),
            '!NOT_EDITOR!'
        );

        bytes32 currentSlug = _registryToSlug[registry];
        if (currentSlug.length > 0) {
            delete _slugsToRegistry[currentSlug];
        }

        if (bytes(slug).length > 0) {
            _slugsToRegistry[bSlug] = registry;
            _registryToSlug[registry] = bSlug;
        } else {
            delete _registryToSlug[registry];
        }

        emit RegistrySlug(registry, slug);
    }

    function _setERC721Implementation(address implementation) internal {

        _erc721Implementation = implementation;
    }

    function _setERC1155Implementation(address implementation) internal {

        _erc1155Implementation = implementation;
    }

    function _addRegistry(address registry, string memory context) internal {

        _registries.add(registry);
        emit RegistryCreated(registry, context);
    }
}