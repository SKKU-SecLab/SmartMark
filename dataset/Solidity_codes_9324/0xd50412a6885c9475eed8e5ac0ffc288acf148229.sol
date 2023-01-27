
pragma solidity ^0.8.4;

interface IERC721A {

    error ApprovalCallerNotOwnerNorApproved();

    error ApprovalQueryForNonexistentToken();

    error ApproveToCaller();

    error BalanceQueryForZeroAddress();

    error MintToZeroAddress();

    error MintZeroQuantity();

    error OwnerQueryForNonexistentToken();

    error TransferCallerNotOwnerNorApproved();

    error TransferFromIncorrectOwner();

    error TransferToNonERC721ReceiverImplementer();

    error TransferToZeroAddress();

    error URIQueryForNonexistentToken();

    error MintERC2309QuantityExceedsLimit();

    error OwnershipNotInitializedForExtraData();

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
        uint24 extraData;
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



    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}// MIT

pragma solidity ^0.8.4;


interface ERC721A__IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

contract ERC721A is IERC721A {

    uint256 private constant BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

    uint256 private constant BITPOS_NUMBER_MINTED = 64;

    uint256 private constant BITPOS_NUMBER_BURNED = 128;

    uint256 private constant BITPOS_AUX = 192;

    uint256 private constant BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;

    uint256 private constant BITPOS_START_TIMESTAMP = 160;

    uint256 private constant BITMASK_BURNED = 1 << 224;

    uint256 private constant BITPOS_NEXT_INITIALIZED = 225;

    uint256 private constant BITMASK_NEXT_INITIALIZED = 1 << 225;

    uint256 private constant BITPOS_EXTRA_DATA = 232;

    uint256 private constant BITMASK_EXTRA_DATA_COMPLEMENT = (1 << 232) - 1;

    uint256 private constant BITMASK_ADDRESS = (1 << 160) - 1;

    uint256 private constant MAX_MINT_ERC2309_QUANTITY_LIMIT = 5000;

    uint256 private _currentIndex;

    uint256 private _burnCounter;

    string private _name;

    string private _symbol;

    mapping(uint256 => uint256) private _packedOwnerships;

    mapping(address => uint256) private _packedAddressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    function _startTokenId() internal view virtual returns (uint256) {

        return 0;
    }

    function _nextTokenId() internal view returns (uint256) {

        return _currentIndex;
    }

    function totalSupply() public view override returns (uint256) {

        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    function _totalMinted() internal view returns (uint256) {

        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    function _totalBurned() internal view returns (uint256) {

        return _burnCounter;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return _packedAddressData[owner] & BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        return (_packedAddressData[owner] >> BITPOS_NUMBER_MINTED) & BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        return (_packedAddressData[owner] >> BITPOS_NUMBER_BURNED) & BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _getAux(address owner) internal view returns (uint64) {

        return uint64(_packedAddressData[owner] >> BITPOS_AUX);
    }

    function _setAux(address owner, uint64 aux) internal {

        uint256 packed = _packedAddressData[owner];
        uint256 auxCasted;
        assembly {
            auxCasted := aux
        }
        packed = (packed & BITMASK_AUX_COMPLEMENT) | (auxCasted << BITPOS_AUX);
        _packedAddressData[owner] = packed;
    }

    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256) {

        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr)
                if (curr < _currentIndex) {
                    uint256 packed = _packedOwnerships[curr];
                    if (packed & BITMASK_BURNED == 0) {
                        while (packed == 0) {
                            packed = _packedOwnerships[--curr];
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
        ownership.extraData = uint24(packed >> BITPOS_EXTRA_DATA);
    }

    function _ownershipAt(uint256 index) internal view returns (TokenOwnership memory) {

        return _unpackedOwnership(_packedOwnerships[index]);
    }

    function _initializeOwnershipAt(uint256 index) internal {

        if (_packedOwnerships[index] == 0) {
            _packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

    function _packOwnershipData(address owner, uint256 flags) private view returns (uint256 result) {

        assembly {
            owner := and(owner, BITMASK_ADDRESS)
            result := or(owner, or(shl(BITPOS_START_TIMESTAMP, timestamp()), flags))
        }
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function _nextInitializedFlag(uint256 quantity) private pure returns (uint256 result) {

        assembly {
            result := shl(BITPOS_NEXT_INITIALIZED, eq(quantity, 1))
        }
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ownerOf(tokenId);

        if (_msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                revert ApprovalCallerNotOwnerNorApproved();
            }

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        if (operator == _msgSenderERC721A()) revert ApproveToCaller();

        _operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
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

        transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
            }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex && // If within bounds,
            _packedOwnerships[tokenId] & BITMASK_BURNED == 0; // and not burned.
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        _mint(to, quantity);

        unchecked {
            if (to.code.length != 0) {
                uint256 end = _currentIndex;
                uint256 index = end - quantity;
                do {
                    if (!_checkContractOnERC721Received(address(0), to, index++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (index < end);
                if (_currentIndex != end) revert();
            }
        }
    }

    function _mint(address to, uint256 quantity) internal {

        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);

            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            uint256 tokenId = startTokenId;
            uint256 end = startTokenId + quantity;
            do {
                emit Transfer(address(0), to, tokenId++);
            } while (tokenId < end);

            _currentIndex = end;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _mintERC2309(address to, uint256 quantity) internal {

        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();
        if (quantity > MAX_MINT_ERC2309_QUANTITY_LIMIT) revert MintERC2309QuantityExceedsLimit();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);

            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            emit ConsecutiveTransfer(startTokenId, startTokenId + quantity - 1, address(0), to);

            _currentIndex = startTokenId + quantity;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _getApprovedAddress(uint256 tokenId)
        private
        view
        returns (uint256 approvedAddressSlot, address approvedAddress)
    {

        mapping(uint256 => address) storage tokenApprovalsPtr = _tokenApprovals;
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, tokenApprovalsPtr.slot)
            approvedAddressSlot := keccak256(0x00, 0x40)
            approvedAddress := sload(approvedAddressSlot)
        }
    }

    function _isOwnerOrApproved(
        address approvedAddress,
        address from,
        address msgSender
    ) private pure returns (bool result) {

        assembly {
            from := and(from, BITMASK_ADDRESS)
            msgSender := and(msgSender, BITMASK_ADDRESS)
            result := or(eq(msgSender, from), eq(msgSender, approvedAddress))
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedAddress(tokenId);

        if (!_isOwnerOrApproved(approvedAddress, from, _msgSenderERC721A()))
            if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();

        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        assembly {
            if approvedAddress {
                sstore(approvedAddressSlot, 0)
            }
        }

        unchecked {
            --_packedAddressData[from]; // Updates: `balance -= 1`.
            ++_packedAddressData[to]; // Updates: `balance += 1`.

            _packedOwnerships[tokenId] = _packOwnershipData(
                to,
                BITMASK_NEXT_INITIALIZED | _nextExtraData(from, to, prevOwnershipPacked)
            );

            if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                if (_packedOwnerships[nextTokenId] == 0) {
                    if (nextTokenId != _currentIndex) {
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
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

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedAddress(tokenId);

        if (approvalCheck) {
            if (!_isOwnerOrApproved(approvedAddress, from, _msgSenderERC721A()))
                if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        assembly {
            if approvedAddress {
                sstore(approvedAddressSlot, 0)
            }
        }

        unchecked {
            _packedAddressData[from] += (1 << BITPOS_NUMBER_BURNED) - 1;

            _packedOwnerships[tokenId] = _packOwnershipData(
                from,
                (BITMASK_BURNED | BITMASK_NEXT_INITIALIZED) | _nextExtraData(from, address(0), prevOwnershipPacked)
            );

            if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                if (_packedOwnerships[nextTokenId] == 0) {
                    if (nextTokenId != _currentIndex) {
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        unchecked {
            _burnCounter++;
        }
    }

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        try ERC721A__IERC721Receiver(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data) returns (
            bytes4 retval
        ) {
            return retval == ERC721A__IERC721Receiver(to).onERC721Received.selector;
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

    function _setExtraDataAt(uint256 index, uint24 extraData) internal {

        uint256 packed = _packedOwnerships[index];
        if (packed == 0) revert OwnershipNotInitializedForExtraData();
        uint256 extraDataCasted;
        assembly {
            extraDataCasted := extraData
        }
        packed = (packed & BITMASK_EXTRA_DATA_COMPLEMENT) | (extraDataCasted << BITPOS_EXTRA_DATA);
        _packedOwnerships[index] = packed;
    }

    function _nextExtraData(
        address from,
        address to,
        uint256 prevOwnershipPacked
    ) private view returns (uint256) {

        uint24 extraData = uint24(prevOwnershipPacked >> BITPOS_EXTRA_DATA);
        return uint256(_extraData(from, to, extraData)) << BITPOS_EXTRA_DATA;
    }

    function _extraData(
        address from,
        address to,
        uint24 previousExtraData
    ) internal view virtual returns (uint24) {}


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

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT
pragma solidity ^0.8.0;

interface IERC2981Royalties {

    function royaltyInfo(uint256 _tokenId, uint256 _value)
    external
    view
    returns (address _receiver, uint256 _royaltyAmount);

}// MIT
pragma solidity ^0.8.0;



abstract contract ERC2981Base is ERC165, IERC2981Royalties {
    struct RoyaltyInfo {
        address recipient;
        uint24 amount;
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
    {
        return
        interfaceId == type(IERC2981Royalties).interfaceId ||
        super.supportsInterface(interfaceId);
    }
}// MIT
pragma solidity ^0.8.0;



abstract contract ERC2981ContractWideRoyalties is ERC2981Base {
    RoyaltyInfo private _royalties;

    function _setRoyalties(address recipient, uint256 value) internal {
        require(value <= 10000, 'ERC2981Royalties: Too high');
        _royalties = RoyaltyInfo(recipient, uint24(value));
    }

    function royaltyInfo(uint256, uint256 value)
    external
    view
    override
    returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory royalties = _royalties;
        receiver = royalties.recipient;
        royaltyAmount = (value * royalties.amount) / 10000;
    }
}// MIT
pragma solidity ^0.8.0;

interface IShopXReserveNFT {

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event BeneficiaryAddressUpdate(address indexed _beneficiaryAddress);
    event ETHReceive(address indexed _from, uint256 _amount);
    event MerkleRootChange(bytes32 indexed merkleRoot);
    event NFTClaim(address indexed _claimant, uint256 indexed _tokenId, uint256 mintPrice);
    event Paused(address account);
    event PriceChange(uint256 indexed _price, uint256 indexed _tokenId);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event ShopxAddressUpdate(address indexed _shopxAddress);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Unpaused(address account);

    function BRAND_ADMIN() external view returns (bytes32);

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function SALE_ADMIN() external view returns (bytes32);

    function SHOPX_ADMIN() external view returns (bytes32);

    function addAdmin(bytes32 _role, address _address) external;

    function approve(address to, uint256 tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;

    function exists(uint256 tokenId) external view returns (bool);

    function factory() external view returns (address);

    function getApproved(uint256 tokenId) external view returns (address);

    function getBalance() external view returns (uint256);

    function getBaseURI() external view returns (string memory);

    function getBrand() external view returns (string memory);

    function getClaimed(address _address) external view returns (uint256);

    function getInfo() external view returns (uint256 _balance, uint256 _maxSupply, uint256 _totalSupply, uint256 _mintPrice, bool _paused, address _royaltyRecipient, address _shopxAddress, address _beneficiaryAddress, uint256 _shopxFee);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getShopXFee() external view returns (uint256);

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function initialize(string memory _baseURI, uint256[4] memory _uintArgs, address[2] memory _addressArgs, address[] memory _brandAdmins, address[] memory _saleAdmins, uint256 _shopxFee, address _shopxAddress, address[] memory _shopxAdmins) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function merkleRoot() external view returns (bytes32);

    function mint(bytes32[] memory merkleProof) external payable;

    function mintTo(address to) external;

    function name() external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address);

    function pause() external;

    function paused() external view returns (bool);

    function removeAdmin(bytes32 _role, address _address) external;

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function royaltyInfo(uint256, uint256 value) external view returns (address receiver, uint256 royaltyAmount);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external;

    function setApprovalForAll(address operator, bool approved) external;

    function setBaseURI(string memory _baseURI) external;

    function setMaxSupply(uint256 _maxSupply) external;

    function setMerkleRoot(bytes32 _merkleRoot) external;

    function setMintPrice(uint256 _mintPrice) external;

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(address from, address to, uint256 tokenId) external;

    function unpause() external;

    function updateBeneficiaryAddress(address _beneficiaryAddress) external;

    function updateRoyaltyAddress(address recipient) external;

    function updateShopxAddress(address _shopxAddress) external;

    receive() external payable;
}// MIT

pragma solidity 0.8.13;

contract ShopXReserveNFT is ERC721A, ERC2981ContractWideRoyalties, AccessControl, Pausable {


  bytes32 public merkleRoot;
  address public factory;
  mapping(address => uint256) private claimed;
  string private brand; // Brand Name

  string private baseURI;// Include '/' at the end. ex) www.shopx.co/nft/
  uint256 public maxSupply;     // Maximum supply of NFT
  uint256 public mintPrice;     // Price in ETH required to mint NFTs (in wei)
  uint256 public mintLimitPerWallet;

  uint256 public royaltyValue;
  address public royaltyRecipient;

  address public shopxAddress;
  uint256 public shopxFee;

  address public beneficiaryAddress;

  bytes32 public constant SHOPX_ADMIN = keccak256("SHOPX");
  bytes32 public constant BRAND_ADMIN = keccak256("BRAND");
  bytes32 public constant SALE_ADMIN = keccak256("SALE");

  event NFTClaim(address indexed _claimant, uint256 indexed _tokenId, uint256 _mintPrice);
  event PriceChange(uint _mintPrice);
  event MerkleRootChange(bytes32 indexed merkleRoot);
  event ShopxAddressUpdate(address indexed _shopxAddress);
  event BeneficiaryAddressUpdate(address indexed _beneficiaryAddress);


  constructor (
    string memory _name,
    string memory _symbol,
    string memory _brand
  ) ERC721A(_name, _symbol) {
    brand = _brand;
    factory = msg.sender;
  }

  function initialize(
    string memory _baseURI,
    uint256[4] memory _uintArgs,
    address[2] memory _addressArgs,
    address[] memory _brandAdmins,
    address[] memory _saleAdmins,
    uint256 _shopxFee,
    address _shopxAddress,
    address[] memory _shopxAdmins
  ) external {

    require(msg.sender == factory, "ReserveNFT: FORBIDDEN"); // sufficient check

    _setBaseURI(_baseURI);
    maxSupply = _uintArgs[0];
    mintPrice = _uintArgs[1]; //in wei
    mintLimitPerWallet = _uintArgs[2];

    _setRoyalties(_addressArgs[0], _uintArgs[3]);
    royaltyValue = _uintArgs[3];
    royaltyRecipient = _addressArgs[0];

    beneficiaryAddress = _addressArgs[1];

    shopxFee = _shopxFee;
    shopxAddress = _shopxAddress;

    _setRoleAdmin(SHOPX_ADMIN, SHOPX_ADMIN);
    _setRoleAdmin(BRAND_ADMIN, BRAND_ADMIN);
    _setRoleAdmin(SALE_ADMIN, SALE_ADMIN);

    for (uint i = 0; i < _shopxAdmins.length; i++) {
      _setupRole(SHOPX_ADMIN, _shopxAdmins[i]);
    }

    for (uint i = 0; i < _brandAdmins.length; i++) {
      _setupRole(BRAND_ADMIN, _brandAdmins[i]);
    }

    for (uint i = 0; i < _saleAdmins.length; i++) {
      _setupRole(SALE_ADMIN, _saleAdmins[i]);
    }

    _pause(); // initializes in paused state. setMerkleRoot() or unpause() will unpause the contract.
  }

  receive() external payable {
    revert("Bad Call: ETH should be sent to mint() function.");
  }


  function updateShopxAddress (address _shopxAddress) onlyRole(SHOPX_ADMIN) external {
    require(_shopxAddress != address(0), "ReserveX: address zero is not a valid shopxAddress");
    shopxAddress = _shopxAddress;
    emit ShopxAddressUpdate(shopxAddress);
  }

  function updateBeneficiaryAddress (address _beneficiaryAddress) onlyRole(BRAND_ADMIN) external {
    require(_beneficiaryAddress != address(0), "ReserveX: address zero is not a valid beneficiaryAddress");
    beneficiaryAddress = _beneficiaryAddress;
    emit BeneficiaryAddressUpdate(beneficiaryAddress);
  }

  function setMerkleRoot(bytes32 _merkleRoot) external onlyRole(SALE_ADMIN) {

    merkleRoot = _merkleRoot;
    emit MerkleRootChange(_merkleRoot);
    _unpause();
  }

  function setMintPrice(uint256 _mintPrice) onlyRole(SALE_ADMIN) external {

    mintPrice = _mintPrice;
    emit PriceChange(_mintPrice);
  }

  function addAdmin(bytes32 _role, address _address) onlyRole(_role) external {

    grantRole(_role, _address);
  }

  function removeAdmin(bytes32 _role, address _address) onlyRole(_role) external {

    revokeRole(_role, _address);
  }

  function setBaseURI(string memory _baseURI) onlyRole(SALE_ADMIN) external {

    _setBaseURI(_baseURI);
  }

  function pause() onlyRole(SALE_ADMIN) external {

    _pause();
  }

  function unpause() onlyRole(SALE_ADMIN) external {

    _unpause();
  }



  function getClaimed(address _address) public view returns (uint256) {

    return claimed[_address];
  }


  function getBalance() public view returns(uint) {

    return address(this).balance;
  }

  function exists(uint256 tokenId) public view returns (bool) {

    return _exists(tokenId);
  }


  function getBrand() public view returns(string memory) {

    return brand;
  }

  function getBaseURI() public view returns (string memory) {

      return _baseURI();
  } 

  function totalMintedSupply() public view returns (uint256) {

    return _totalMinted();
  }

  function getShopXFee() public view returns (uint256) {

    return shopxFee;
  }

  function getInfo() public view returns (
    uint256 _balance,
    uint256 _maxSupply,
    uint256 _totalSupply,
    uint256 _totalMintedSupply,
    uint256 _mintPrice,
    uint256 _mintLimitPerWallet,
    bool _paused,
    address _royaltyRecipient,
    address _shopxAddress,
    address _beneficiaryAddress,
    uint256 _royaltyValue,
    uint256 _shopxFee ) {

    return (
      getBalance(),
      maxSupply,
      totalSupply(),
      totalMintedSupply(),
      mintPrice,
      mintLimitPerWallet,
      paused(),
      royaltyRecipient,
      shopxAddress,
      beneficiaryAddress,
      royaltyValue,
      shopxFee
    );
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981Base, AccessControl) returns (bool) {

    return
      ERC721A.supportsInterface(interfaceId) ||
      ERC2981Base.supportsInterface(interfaceId) ||
      AccessControl.supportsInterface(interfaceId);

  }

  function updateRoyaltyAddress(address recipient) onlyRole(BRAND_ADMIN) external {

    require(recipient != address(0), "ReserveX: address zero is not a valid royalty recipient");
    _setRoyalties(recipient, royaltyValue);
  }


  function mint(bytes32[] calldata merkleProof, uint256 quantity) payable external whenNotPaused {

    require(totalSupply() + quantity <= maxSupply, "NotEnoughNFT: NFT supply not available");
    require(claimed[msg.sender] + quantity <= mintLimitPerWallet, "ReserveNFT: NFTs already claimed.");
    require(msg.value == mintPrice * quantity, "WrongETHAmount: More or less than the required amount of ETH sent.");
    require (merkleRoot == bytes32(0) || MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "ReserveNFT: Invalid Proof. Valid proof required.");

    claimed[msg.sender] += quantity;

    _safeMint(msg.sender, quantity);
    for (uint i = 0; i < quantity; i++) {
      emit NFTClaim(msg.sender, _nextTokenId()-quantity+i, mintPrice);
    }

    payable(shopxAddress).transfer(this.getBalance()*shopxFee/10000);

    payable(beneficiaryAddress).transfer(this.getBalance());
  }

  function mintTo(address to, uint256 quantity) external whenNotPaused onlyRole(SALE_ADMIN)  {

    require(totalSupply() + quantity <= maxSupply, "NotEnoughNFT: NFT supply not available");

    _safeMint(to, quantity);
  }

  function burn(uint256 tokenId) external {

    _burn(tokenId, true);
  }


  function _startTokenId() internal view virtual override returns (uint256) {

    return 1;
  }

  function _setBaseURI(string memory baseURI_) internal {

    baseURI = baseURI_;
  }

  function _baseURI() internal view override returns (string memory) {

    return baseURI;
  }

}// MIT
pragma solidity 0.8.13;


contract ShopXReserveFactory {


  address[] public allReserveX;

  uint256 public shopxFee;
  address public shopxAddress;
  address[] public shopxAdmins;

  mapping(address => bool) public isShopxAdmin;
  mapping(address => bool) public isReserveX;

  event FactoryCreated(address indexed ShopXReserveFactory);
  event ContractCreated(string name, string symbol, string brand, address indexed ReserveX, uint index);
  event ShopxAddressUpdate(address indexed _shopxAddress);

  constructor (
    uint256 _shopxFee,
    address _shopxAddress,
    address[] memory _shopxAdmins
  ) public {
    require(_shopxAddress != address(0), "ReserveX: address zero is not a valid shopxAddress");
    require(_shopxAdmins.length > 0, "ShopxAdmins: ShopxAdmins cannot be empty");
    shopxFee = _shopxFee;
    shopxAddress = _shopxAddress;

    for (uint i = 0; i < _shopxAdmins.length; i++) {
      require(_shopxAdmins[i] != address(0), "ReserveX: address zero is not a valid shopxAdmin");
      shopxAdmins.push(_shopxAdmins[i]);
      isShopxAdmin[_shopxAdmins[i]] = true;
    }

    emit FactoryCreated(address(this));
  }

  function createReserveNFT(
    string memory _name,
    string memory _symbol,
    string memory _brand,
    string memory _baseURI,
    uint256[4] memory _uintArgs,
    address[2] memory _addressArgs,
    address[] memory _brandAdmins,
    address[] memory _saleAdmins
  ) external returns (address){

    require(isReserveX[computeAddress(_name,_symbol,_brand)] == false, 'ReserveX: Already Exists');

    bytes memory bytecode = abi.encodePacked(type(ShopXReserveNFT).creationCode, abi.encode(
        _name,
        _symbol,
        _brand
    ));

    require(bytecode.length != 0, "Create2: bytecode length is zero");

    address payable reserveX;
    uint256 codeSize;

    assembly {
      reserveX := create2(0, add(bytecode, 0x20), mload(bytecode), 0)
      codeSize := extcodesize(reserveX)
    }
    require(codeSize > 0, "Create2: Contract creation failed (codeSize is 0)");
    require(reserveX != address(0), "Create2: Failed on deploy (address is 0 )");
    IShopXReserveNFT(reserveX).initialize(
      _baseURI,
      _uintArgs,
      _addressArgs,
      _brandAdmins,
      _saleAdmins,
      shopxFee,
      shopxAddress,
      shopxAdmins
    );
    allReserveX.push(reserveX);
    isReserveX[reserveX] = true;
    emit ContractCreated(_name, _symbol, _brand, address(reserveX), allReserveX.length);

    return reserveX;
    }

  function computeAddress(string memory _name, string memory _symbol, string memory _brand) public view returns (address) {

    bytes memory bytecode = abi.encodePacked(type(ShopXReserveNFT).creationCode, abi.encode(
        _name,
        _symbol,
        _brand
    ));
    bytes32 bytecodeHash = keccak256(abi.encodePacked(bytecode));
    bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), address(this), bytes32(0), bytecodeHash));
    return address(uint160(uint256(_data)));
  }

  modifier onlyShopxAdmin() {

    require(isShopxAdmin[msg.sender], "ShopxAdmins: Caller is not a shopxAdmin");
    _;
  }

  function setShopxFee (uint256 _shopxFee) onlyShopxAdmin external {
    shopxFee = _shopxFee;
  }

  function setShopxAddress (address _shopxAddress) onlyShopxAdmin external{
    require(_shopxAddress != address(0), "ReserveX: address zero is not a valid shopxAddress");
    shopxAddress = _shopxAddress;
    emit ShopxAddressUpdate(_shopxAddress);
  }

  function addShopxAdmin (address _shopxAdmin) onlyShopxAdmin external{
    require(_shopxAdmin != address(0), "ReserveX: address zero is not a valid shopxAdmin");
    require( !isShopxAdmin[_shopxAdmin], "ShopxAdmins: Address is already a shopxAdmin");
    shopxAdmins.push(_shopxAdmin);
    isShopxAdmin[_shopxAdmin]=true;
  }

  function removeShopxAdmin(address _shopxAdmin) onlyShopxAdmin external {

    require( shopxAdmins.length > 1, "ShopxAdmins: ShopxAdmins cannot be empty");
    require( isShopxAdmin[_shopxAdmin], "ShopxAdmins: Address is not a shopxAdmin");

    for (uint i=0; i<shopxAdmins.length; i++) {
      if (shopxAdmins[i] == _shopxAdmin) {
        shopxAdmins[i] = shopxAdmins[shopxAdmins.length - 1];
        shopxAdmins.pop();
        isShopxAdmin[_shopxAdmin]=false;
        break;
      }
    }
  }

}