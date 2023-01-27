
pragma solidity ^0.8.4;

interface IERC721AUpgradeable {

    error ApprovalCallerNotOwnerNorApproved();

    error ApprovalQueryForNonexistentToken();

    error ApproveToCaller();

    error ApprovalToCurrentOwner();

    error BalanceQueryForZeroAddress();

    error MintToZeroAddress();

    error MintZeroQuantity();

    error OwnerQueryForNonexistentToken();

    error TransferCallerNotOwnerNorApproved();

    error TransferFromIncorrectOwner();

    error TransferToNonERC721ReceiverImplementer();

    error TransferToZeroAddress();

    error URIQueryForNonexistentToken();

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
    }

    function totalSupply() external view returns (uint256);



    function supportsInterface(bytes4 interfaceId) external view returns (bool);



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



    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


library ERC721AStorage {

    struct Layout {
        uint256 _currentIndex;
        uint256 _burnCounter;
        string _name;
        string _symbol;
        mapping(uint256 => uint256) _packedOwnerships;
        mapping(address => uint256) _packedAddressData;
        mapping(uint256 => address) _tokenApprovals;
        mapping(address => mapping(address => bool)) _operatorApprovals;
    }

    bytes32 internal constant STORAGE_SLOT = keccak256('ERC721A.contracts.storage.ERC721A');

    function layout() internal pure returns (Layout storage l) {

        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.0;


library ERC721A__InitializableStorage {

    struct Layout {
        bool _initialized;
        bool _initializing;
    }

    bytes32 internal constant STORAGE_SLOT = keccak256('ERC721A.contracts.storage.initializable.facet');

    function layout() internal pure returns (Layout storage l) {

        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}// MIT
pragma solidity ^0.8.0;



abstract contract ERC721A__Initializable {
    using ERC721A__InitializableStorage for ERC721A__InitializableStorage.Layout;

    modifier initializerERC721A() {
        require(
            ERC721A__InitializableStorage.layout()._initializing
                ? _isConstructor()
                : !ERC721A__InitializableStorage.layout()._initialized,
            'ERC721A__Initializable: contract is already initialized'
        );

        bool isTopLevelCall = !ERC721A__InitializableStorage.layout()._initializing;
        if (isTopLevelCall) {
            ERC721A__InitializableStorage.layout()._initializing = true;
            ERC721A__InitializableStorage.layout()._initialized = true;
        }

        _;

        if (isTopLevelCall) {
            ERC721A__InitializableStorage.layout()._initializing = false;
        }
    }

    modifier onlyInitializingERC721A() {
        require(
            ERC721A__InitializableStorage.layout()._initializing,
            'ERC721A__Initializable: contract is not initializing'
        );
        _;
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}// MIT

pragma solidity ^0.8.4;


interface ERC721A__IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

contract ERC721AUpgradeable is ERC721A__Initializable, IERC721AUpgradeable {

    using ERC721AStorage for ERC721AStorage.Layout;
    uint256 private constant BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

    uint256 private constant BITPOS_NUMBER_MINTED = 64;

    uint256 private constant BITPOS_NUMBER_BURNED = 128;

    uint256 private constant BITPOS_AUX = 192;

    uint256 private constant BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;

    uint256 private constant BITPOS_START_TIMESTAMP = 160;

    uint256 private constant BITMASK_BURNED = 1 << 224;

    uint256 private constant BITPOS_NEXT_INITIALIZED = 225;

    uint256 private constant BITMASK_NEXT_INITIALIZED = 1 << 225;

    function __ERC721A_init(string memory name_, string memory symbol_) internal onlyInitializingERC721A {

        __ERC721A_init_unchained(name_, symbol_);
    }

    function __ERC721A_init_unchained(string memory name_, string memory symbol_) internal onlyInitializingERC721A {

        ERC721AStorage.layout()._name = name_;
        ERC721AStorage.layout()._symbol = symbol_;
        ERC721AStorage.layout()._currentIndex = _startTokenId();
    }

    function _startTokenId() internal view virtual returns (uint256) {

        return 0;
    }

    function _nextTokenId() internal view returns (uint256) {

        return ERC721AStorage.layout()._currentIndex;
    }

    function totalSupply() public view override returns (uint256) {

        unchecked {
            return ERC721AStorage.layout()._currentIndex - ERC721AStorage.layout()._burnCounter - _startTokenId();
        }
    }

    function _totalMinted() internal view returns (uint256) {

        unchecked {
            return ERC721AStorage.layout()._currentIndex - _startTokenId();
        }
    }

    function _totalBurned() internal view returns (uint256) {

        return ERC721AStorage.layout()._burnCounter;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (_addressToUint256(owner) == 0) revert BalanceQueryForZeroAddress();
        return ERC721AStorage.layout()._packedAddressData[owner] & BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        return (ERC721AStorage.layout()._packedAddressData[owner] >> BITPOS_NUMBER_MINTED) & BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        return (ERC721AStorage.layout()._packedAddressData[owner] >> BITPOS_NUMBER_BURNED) & BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _getAux(address owner) internal view returns (uint64) {

        return uint64(ERC721AStorage.layout()._packedAddressData[owner] >> BITPOS_AUX);
    }

    function _setAux(address owner, uint64 aux) internal {

        uint256 packed = ERC721AStorage.layout()._packedAddressData[owner];
        uint256 auxCasted;
        assembly {
            auxCasted := aux
        }
        packed = (packed & BITMASK_AUX_COMPLEMENT) | (auxCasted << BITPOS_AUX);
        ERC721AStorage.layout()._packedAddressData[owner] = packed;
    }

    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256) {

        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr)
                if (curr < ERC721AStorage.layout()._currentIndex) {
                    uint256 packed = ERC721AStorage.layout()._packedOwnerships[curr];
                    if (packed & BITMASK_BURNED == 0) {
                        while (packed == 0) {
                            packed = ERC721AStorage.layout()._packedOwnerships[--curr];
                        }
                        return packed;
                    }
                }
        }
        revert OwnerQueryForNonexistentToken();
    }

    function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership) {

        ownership.addr = address(uint160(packed));
        ownership.startTimestamp = uint64(packed >> BITPOS_START_TIMESTAMP);
        ownership.burned = packed & BITMASK_BURNED != 0;
    }

    function _ownershipAt(uint256 index) internal view returns (TokenOwnership memory) {

        return _unpackedOwnership(ERC721AStorage.layout()._packedOwnerships[index]);
    }

    function _initializeOwnershipAt(uint256 index) internal {

        if (ERC721AStorage.layout()._packedOwnerships[index] == 0) {
            ERC721AStorage.layout()._packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    function name() public view virtual override returns (string memory) {

        return ERC721AStorage.layout()._name;
    }

    function symbol() public view virtual override returns (string memory) {

        return ERC721AStorage.layout()._symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function _addressToUint256(address value) private pure returns (uint256 result) {

        assembly {
            result := value
        }
    }

    function _boolToUint256(bool value) private pure returns (uint256 result) {

        assembly {
            result := value
        }
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = address(uint160(_packedOwnershipOf(tokenId)));
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                revert ApprovalCallerNotOwnerNorApproved();
            }

        ERC721AStorage.layout()._tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return ERC721AStorage.layout()._tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        if (operator == _msgSenderERC721A()) revert ApproveToCaller();

        ERC721AStorage.layout()._operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return ERC721AStorage.layout()._operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        _transfer(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
            }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return
            _startTokenId() <= tokenId &&
            tokenId < ERC721AStorage.layout()._currentIndex && // If within bounds,
            ERC721AStorage.layout()._packedOwnerships[tokenId] & BITMASK_BURNED == 0; // and not burned.
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        uint256 startTokenId = ERC721AStorage.layout()._currentIndex;
        if (_addressToUint256(to) == 0) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            ERC721AStorage.layout()._packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);

            ERC721AStorage.layout()._packedOwnerships[startTokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                (_boolToUint256(quantity == 1) << BITPOS_NEXT_INITIALIZED);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (to.code.length != 0) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex < end);
                if (ERC721AStorage.layout()._currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex < end);
            }
            ERC721AStorage.layout()._currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _mint(address to, uint256 quantity) internal {

        uint256 startTokenId = ERC721AStorage.layout()._currentIndex;
        if (_addressToUint256(to) == 0) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            ERC721AStorage.layout()._packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);

            ERC721AStorage.layout()._packedOwnerships[startTokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                (_boolToUint256(quantity == 1) << BITPOS_NEXT_INITIALIZED);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            ERC721AStorage.layout()._currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();

        address approvedAddress = ERC721AStorage.layout()._tokenApprovals[tokenId];

        bool isApprovedOrOwner = (_msgSenderERC721A() == from ||
            isApprovedForAll(from, _msgSenderERC721A()) ||
            approvedAddress == _msgSenderERC721A());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (_addressToUint256(to) == 0) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        if (_addressToUint256(approvedAddress) != 0) {
            delete ERC721AStorage.layout()._tokenApprovals[tokenId];
        }

        unchecked {
            --ERC721AStorage.layout()._packedAddressData[from]; // Updates: `balance -= 1`.
            ++ERC721AStorage.layout()._packedAddressData[to]; // Updates: `balance += 1`.

            ERC721AStorage.layout()._packedOwnerships[tokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                BITMASK_NEXT_INITIALIZED;

            if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                if (ERC721AStorage.layout()._packedOwnerships[nextTokenId] == 0) {
                    if (nextTokenId != ERC721AStorage.layout()._currentIndex) {
                        ERC721AStorage.layout()._packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _burn(uint256 tokenId) internal virtual {

        _burn(tokenId, false);
    }

    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {

        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        address from = address(uint160(prevOwnershipPacked));
        address approvedAddress = ERC721AStorage.layout()._tokenApprovals[tokenId];

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSenderERC721A() == from ||
                isApprovedForAll(from, _msgSenderERC721A()) ||
                approvedAddress == _msgSenderERC721A());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        if (_addressToUint256(approvedAddress) != 0) {
            delete ERC721AStorage.layout()._tokenApprovals[tokenId];
        }

        unchecked {
            ERC721AStorage.layout()._packedAddressData[from] += (1 << BITPOS_NUMBER_BURNED) - 1;

            ERC721AStorage.layout()._packedOwnerships[tokenId] =
                _addressToUint256(from) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                BITMASK_BURNED |
                BITMASK_NEXT_INITIALIZED;

            if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                if (ERC721AStorage.layout()._packedOwnerships[nextTokenId] == 0) {
                    if (nextTokenId != ERC721AStorage.layout()._currentIndex) {
                        ERC721AStorage.layout()._packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        unchecked {
            ERC721AStorage.layout()._burnCounter++;
        }
    }

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        try
            ERC721A__IERC721ReceiverUpgradeable(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data)
        returns (bytes4 retval) {
            return retval == ERC721A__IERC721ReceiverUpgradeable(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    function _msgSenderERC721A() internal view virtual returns (address) {

        return msg.sender;
    }

    function _toString(uint256 value) internal pure returns (string memory ptr) {

        assembly {
            ptr := add(mload(0x40), 128)
            mstore(0x40, ptr)

            let end := ptr

            for {
                let temp := value
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
                temp := div(temp, 10)
            } temp {
                temp := div(temp, 10)
            } {
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
            }

            let length := sub(end, ptr)
            ptr := sub(ptr, 32)
            mstore(ptr, length)
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
                version == 1 && !AddressUpgradeable.isContract(address(this)),
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
pragma solidity ^0.8.4;


struct Config {
    string name;
    string symbol;
    uint256 maxSupply;
    address signer;
    string baseURI;
    uint256 publicMintLimit;
    uint256 publicMintPrice;
    bool publicMintEnabled;
    bool approveListMintingEnabled;
    address squshy_labs_address;
    uint256 commission;
    address implementationAddress;
}

contract SqushyLabsMintUpgradeable is ERC721AUpgradeable, OwnableUpgradeable {

    using ECDSA for bytes32;

    uint256 public maxSupply;
    string public baseURI;

    bool public approveListMintingEnabled;
    bool public publicMintEnabled;

    uint256 public publicMintPrice;
    uint256 public publicMintLimit;

    address private squshy_labs_address;
    uint256 private commission;

    address private signer;

    function _initialize(Config memory _config) initializerERC721A initializer public {

        __ERC721A_init(_config.name, _config.symbol);
        __Ownable_init();
        setURI(_config.baseURI);
        signer = _config.signer;
        maxSupply = _config.maxSupply;
        commission = _config.commission;
        squshy_labs_address = _config.squshy_labs_address;
        setMintConfig(_config.publicMintLimit, _config.publicMintPrice, _config.publicMintEnabled, _config.approveListMintingEnabled);
    }

    function setMintConfig(uint256 _publicMintLimit, uint256 _publicMintPrice, bool _publicMintEnabled, bool _approveListMintingEnabled) public onlyOwner{

        publicMintLimit = _publicMintLimit;
        publicMintPrice = _publicMintPrice;
        publicMintEnabled = _publicMintEnabled;
        approveListMintingEnabled = _approveListMintingEnabled;
    }

	function _baseURI() internal view virtual override returns (string memory) {

	    return baseURI;
	}

    function setURI(string memory _newBaseURI) public onlyOwner {

	    baseURI = _newBaseURI;
	}

    function updateSigner(address _signer) external onlyOwner {

        signer = _signer;
    }

    function _hash(address _address, uint amount, uint allowedAmount, uint cost) internal view returns (bytes32){

        return keccak256(abi.encode(address(this), _address, amount, allowedAmount, cost));
    }

    function _verify(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal view returns (bool){

        return (ecrecover(hash, v, r, s) == signer);
    }

    function mint(uint256 amount, address mintAddress) public payable {

        require(publicMintEnabled, "CONTRACT ERROR: minting has not been enabled");
        require(_numberMinted(mintAddress) + amount <= publicMintLimit, "CONTRACT ERROR: Address has already claimed max amount");
        require(totalSupply() + amount <= maxSupply, "CONTRACT ERROR: not enough remaining in supply to support desired mint amount");
        require(amount * msg.value == amount * publicMintPrice, "CONTRACT ERROR: not enough ether sent");
        _safeMint(mintAddress, amount);
    }

    function allowListMint(uint8 v, bytes32 r, bytes32 s, uint256 amount, uint256 allowedAmount, address mintAddress) public payable {

        require(approveListMintingEnabled, "CONTRACT ERROR: allow list minting has not been enabled");
        require(_numberMinted(mintAddress) + amount <= allowedAmount, "CONTRACT ERROR: Address has already claimed max amount");
        require(totalSupply() + amount <= maxSupply, "CONTRACT ERROR: not enough remaining in supply to support desired mint amount");
        require(_verify(_hash(mintAddress, amount, allowedAmount, msg.value), v, r, s), 'CONTRACT ERROR: Invalid signature');
        _safeMint(mintAddress, amount);
    }

    function withdraw() public payable {

        uint256 balance = address(this).balance;
        require(balance > 0, "CONTRACT ERROR: Zero balance");
        uint256 _commission = ((commission * balance) / 1000);
        AddressUpgradeable.sendValue(payable(squshy_labs_address), _commission);
        AddressUpgradeable.sendValue(payable(owner()), balance - _commission);
    }

}

contract SqushyLabsMint is SqushyLabsMintUpgradeable {

    function initialize(Config memory _config
    ) public initializer {

        _initialize(_config);
    }
}