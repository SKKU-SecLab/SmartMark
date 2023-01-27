
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

pragma solidity ^0.8.1;

library Address {

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

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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
}pragma solidity 0.8.10;

contract EIP712Base {

    bytes32 internal DOMAIN_SEPARATOR;

    function setUpDomain(string memory name) internal {

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    function toTypedMessageHash(bytes32 messageHash)
        internal
        view
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, messageHash)
            );
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.4;


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

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
    }

    struct AddressData {
        uint64 balance;
        uint64 numberMinted;
        uint64 numberBurned;
        uint64 aux;
    }

    uint256 internal _currentIndex;

    uint256 internal _burnCounter;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) internal _ownerships;

    mapping(address => AddressData) private _addressData;

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

    function totalSupply() public view returns (uint256) {

        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    function _totalMinted() internal view returns (uint256) {

        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberMinted);
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberBurned);
    }

    function _getAux(address owner) internal view returns (uint64) {

        return _addressData[owner].aux;
    }

    function _setAux(address owner, uint64 aux) internal {

        _addressData[owner].aux = aux;
    }

    function _ownershipOf(uint256 tokenId)
        internal
        view
        returns (TokenOwnership memory)
    {

        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr && curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId)
        public
        view
        override
        returns (address)
    {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {

        if (operator == _msgSender()) revert ApproveToCaller();

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

        _transfer(from, to, tokenId);
        if (
            to.isContract() &&
            !_checkContractOnERC721Received(from, to, tokenId, _data)
        ) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex &&
            !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, "");
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        _mint(to, quantity, _data, true);
    }

    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {

        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (safe && to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (
                        !_checkContractOnERC721Received(
                            address(0),
                            to,
                            updatedIndex++,
                            _data
                        )
                    ) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex != end);
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex != end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, from);

        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
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

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        _approve(address(0), tokenId, from);

        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        unchecked {
            _burnCounter++;
        }
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) internal {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        try
            IERC721Receiver(to).onERC721Received(
                _msgSender(),
                from,
                tokenId,
                _data
            )
        returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
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

}// MIT

pragma solidity ^0.8.4;


abstract contract ERC721ABurnable is ERC721A {
    function burn(uint256 tokenId) public virtual {
        _burn(tokenId, true);
    }
}// MIT
pragma solidity 0.8.10;


contract CloneFactory {
    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }
}

error CallerIsNotMinter();
error MaxSupplyExceeded();
error NonceTooLow();
error RecoveredUnauthorizedAddress();
error DeadlineExpired();
error TransfersDisabled();

contract DVin is ERC721ABurnable, Ownable, EIP712Base, Initializable {
    using Strings for uint256; /*String library allows for token URI concatenation*/
    using ECDSA for bytes32; /*ECDSA library allows for signature recovery*/

    bool public tradingEnabled; /*Trading can be disabled by owner*/

    string public contractURI; /*contractURI contract metadata json*/
    string public baseURI; /*baseURI_ String to prepend to token IDs*/
    string private _name; /*Token name override*/
    string private _symbol; /*Token symbol override*/

    uint256 public maxSupply;

    address public minter; /*Contract that can mint tokens, changeable by owner*/

    mapping(address => uint256) public nonces; /*maps record of states for signing & validating signatures
        Nonces increment each time a permit is used.
        Users can invalidate a previously signed permit by changing their account nonce
    */

    bytes32 constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );

    bytes32 constant UNIVERSAL_PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 nonce,uint256 deadline)"
        );

    constructor() ERC721A("TEMPLATE", "DEAD") initializer {
        _transferOwnership(address(0xdead)); /*Disable template*/
    }

    function setUp(
        string memory name_,
        string memory symbol_,
        string memory _contractURI,
        string memory baseURI_,
        address _minter,
        address _owner,
        uint256 _maxSupply
    ) public initializer {
        _name = name_;
        _symbol = symbol_;
        _setBaseURI(baseURI_); /*Base URI for token ID resolution*/
        contractURI = _contractURI; /*Contract URI for marketplace metadata*/
        minter = _minter; /*Address authorized to mint */
        _currentIndex = _startTokenId();
        maxSupply = _maxSupply;
        _transferOwnership(_owner);
        setUpDomain(name_);
    }

    function _startTokenId() internal view override(ERC721A) returns (uint256) {
        return 1;
    }

    function mint(address _dst, uint256 _qty) external returns (bool) {
        if (msg.sender != minter) revert CallerIsNotMinter(); /*Minting can only be done by minter address*/
        if ((totalSupply() + _qty) > maxSupply) revert MaxSupplyExceeded(); /*Cannot exceed max supply*/
        _safeMint(_dst, _qty); /*Send token to new recipient*/
        return true; /*Return success to external caller*/
    }

    function setNonce(uint256 _nonce) external {
        if (_nonce <= nonces[msg.sender]) revert NonceTooLow(); /*New nonce must be higher to prevent replay*/
        nonces[msg.sender] = _nonce; /*Set new nonce for sender*/
    }

    function transferWithUniversalPermit(
        address _owner,
        uint256 _tokenId,
        address _dst,
        uint256 _deadline,
        bytes calldata _signature
    ) external {
        bytes32 structHash = keccak256(
            abi.encode(
                UNIVERSAL_PERMIT_TYPEHASH,
                _owner,
                msg.sender,
                nonces[_owner]++, /*Increment nonce to prevent replay*/
                _deadline
            )
        ); /*calculate EIP-712 struct hash*/
        bytes32 digest = toTypedMessageHash(structHash); /*Calculate EIP712 digest*/
        address recoveredAddress = digest.recover(_signature); /*Attempt to recover signer*/
        if (recoveredAddress != _owner) revert RecoveredUnauthorizedAddress(); /*check signer is `owner`*/

        if (block.timestamp > _deadline) revert DeadlineExpired(); /*check signature is not expired*/

        _approve(msg.sender, _tokenId, _owner);
        safeTransferFrom(_owner, _dst, _tokenId); /*Move token to new wallet*/
    }

    function transferWithPermit(
        address _owner,
        uint256 _tokenId,
        address _dst,
        uint256 _deadline,
        bytes calldata _signature
    ) external {
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                _owner,
                msg.sender,
                _tokenId,
                nonces[_owner]++, /*Increment nonce to prevent replay*/
                _deadline
            )
        ); /*calculate EIP-712 struct hash*/
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        ); /*calculate EIP-712 digest for signature*/
        address recoveredAddress = digest.recover(_signature); /*Attempt to recover signer*/
        if (recoveredAddress != _owner) revert RecoveredUnauthorizedAddress(); /*check signer is `owner`*/

        if (block.timestamp > _deadline) revert DeadlineExpired(); /*check signature is not expired*/

        _approve(msg.sender, _tokenId, _owner);
        safeTransferFrom(_owner, _dst, _tokenId); /*Move token to new wallet*/
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _setBaseURI(baseURI_);
    }

    function setTradingState(bool _enabled) external onlyOwner {
        tradingEnabled = _enabled;
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    function _setBaseURI(string memory baseURI_) internal {
        baseURI = baseURI_;
    }

    function setContractURI(string memory _contractURI) external onlyOwner {
        contractURI = _contractURI;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721A)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal override(ERC721A) {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
        if (from != address(0) && to != address(0) && !tradingEnabled)
            revert TransfersDisabled();
    }
}

contract DVinSummoner is CloneFactory, Ownable {
    address public template; /*Template contract to clone*/

    constructor(address _template) public {
        template = _template;
    }

    event SummonComplete(
        address indexed newContract,
        string name,
        string symbol,
        address summoner
    );

    function summonDvin(
        string memory name_,
        string memory symbol_,
        string memory _contractURI,
        string memory baseURI_,
        address _minter,
        uint256 _maxSupply,
        address _owner
    ) external onlyOwner returns (address) {
        DVin dvin = DVin(createClone(template)); /*Create a new clone of the template*/

        dvin.setUp(
            name_,
            symbol_,
            _contractURI,
            baseURI_,
            _minter,
            _owner,
            _maxSupply
        );

        emit SummonComplete(address(dvin), name_, symbol_, msg.sender);

        return address(dvin);
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {
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


abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
}//Unlicense
pragma solidity ^0.8.0;


contract EIP712Whitelisting is AccessControl, EIP712Base {
    using ECDSA for bytes32;
    bytes32 public constant WHITELISTING_ROLE = keccak256("WHITELISTING_ROLE");

    mapping(bytes32 => bool) public signatureUsed;

    bytes32 public constant MINTER_TYPEHASH =
        keccak256("Minter(address wallet,uint256 nonce)");

    constructor(string memory name) {
        setUpDomain(name);
        _setupRole(WHITELISTING_ROLE, msg.sender);
    }

    modifier requiresWhitelist(
        bytes calldata signature,
        uint256 nonce
    ) {
        bytes32 structHash = keccak256(
            abi.encode(MINTER_TYPEHASH, msg.sender, nonce)
        );
        bytes32 digest = toTypedMessageHash(structHash); /*Calculate EIP712 digest*/
        require(!signatureUsed[digest], "signature used");
        signatureUsed[digest] = true;
        address recoveredAddress = digest.recover(signature);
        require(
            hasRole(WHITELISTING_ROLE, recoveredAddress),
            "Invalid Signature"
        );
        _;
    }
}// MIT
pragma solidity 0.8.10;


error RoundDisabled(uint256 round);
error InvalidTier(uint256 tier);
error FailedToMint();
error LengthMismatch();
error PurchaseLimitExceeded();
error InsufficientValue();
error RoundLimitExceeded();
error FailedToSendETH();

contract DVinMint is EIP712Whitelisting {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); /*Role used to permission admin minting*/
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE"); /*Role used to permission contract configuration changes*/

    address payable public ethSink; /*recipient for ETH*/

    mapping(uint256 => address) public tierContracts; /*Contracts for different tier options*/

    uint256 public limitPerPurchase; /*Max amount of tokens someone can buy in one transaction*/

    enum ContractState {
        Presale,
        Public
    }
    mapping(ContractState => bool) public contractState; /*Track which state is enabled*/

    struct SaleConfig {
        uint256 price;
        uint256 limit;
    }
    mapping(uint256 => SaleConfig) public presaleConfig; /*Configuration for presale*/
    mapping(uint256 => SaleConfig) public publicConfig; /*Configuration for public sale*/

    constructor(
        uint256[] memory _tiers,
        address[] memory _addresses,
        address payable _sink
    ) EIP712Whitelisting("DVin") {
        _setupRole(MINTER_ROLE, msg.sender); /*Grant role to deployer for admin minting*/
        _setupRole(OWNER_ROLE, msg.sender); /*Grant role to deployer for config changes*/
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); /*Grant role to deployer for access control changes*/
        ethSink = _sink; /*Set address to send ETH to*/

        setTierContracts(_tiers, _addresses); /*Set contracts to use for types*/
    }

    function mintTierAdmin(
        uint256 _tier,
        address _dst,
        uint256 _qty
    ) public onlyRole(MINTER_ROLE) {
        if (tierContracts[_tier] == address(0)) revert InvalidTier(_tier); /*Ensure tier contract is populated*/
        if (!DVin(tierContracts[_tier]).mint(_dst, _qty)) revert FailedToMint(); /*Mint token by admin to specified address*/
    }

    function mintTierAdminBatch(
        uint256[] calldata _tiers,
        address[] calldata _dsts,
        uint256[] calldata _qtys
    ) public onlyRole(MINTER_ROLE) {
        if (_tiers.length != _dsts.length || _dsts.length != _qtys.length)
            revert LengthMismatch();

        for (uint256 index = 0; index < _tiers.length; index++) {
            mintTierAdmin(_tiers[index], _dsts[index], _qtys[index]);
        }
    }

    function purchaseTokenPresale(
        uint256 _tier,
        uint256 _qty,
        uint256 _nonce,
        bytes calldata _signature
    ) external payable requiresWhitelist(_signature, _nonce) {
        if (!contractState[ContractState.Presale])
            revert RoundDisabled(uint256(ContractState.Presale)); /*Presale must be enabled*/
        if (presaleConfig[_tier].price == 0) revert InvalidTier(_tier); /*Do not allow 0 value purchase. If desired use separate function for free claim*/
        SaleConfig memory _config = presaleConfig[_tier]; /*Fetch sale config*/
        _purchase(_tier, _qty, _config.price, _config.limit); /*Purchase token if all values & limits are valid*/
    }

    function purchaseTokenOpensale(uint256 _tier, uint256 _qty)
        external
        payable
    {
        if (!contractState[ContractState.Public])
            revert RoundDisabled(uint256(ContractState.Public)); /*Public must be enabled*/
        if (publicConfig[_tier].price == 0) revert InvalidTier(_tier); /*Do not allow 0 value purchase. If desired use separate function for free claim*/
        _purchase(
            _tier,
            _qty,
            publicConfig[_tier].price,
            publicConfig[_tier].limit
        ); /*Purchase token if all values & limits are valid*/
    }

    function _purchase(
        uint256 _tier,
        uint256 _qty,
        uint256 _price,
        uint256 _limit
    ) internal {
        if (_qty > limitPerPurchase) revert PurchaseLimitExceeded();
        if (msg.value < (_price * _qty)) revert InsufficientValue();

        if ((DVin(tierContracts[_tier]).totalSupply() + _qty) > _limit)
            revert RoundLimitExceeded();

        (bool _success, ) = ethSink.call{value: msg.value}(""); /*Send ETH to sink first*/
        if (!_success) revert FailedToSendETH();

        if (!DVin(tierContracts[_tier]).mint(msg.sender, _qty))
            revert FailedToMint(); /*Mint token by admin to specified address*/
    }


    function setContractState(ContractState _state, bool _enabled)
        external
        onlyRole(OWNER_ROLE)
    {
        contractState[_state] = _enabled;
    }

    function setSink(address payable _sink) external onlyRole(OWNER_ROLE) {
        ethSink = _sink;
    }

    function setTierContracts(
        uint256[] memory _tiers,
        address[] memory _addresses
    ) public onlyRole(OWNER_ROLE) {
        if (_tiers.length != _addresses.length) revert LengthMismatch();
        for (uint256 index = 0; index < _tiers.length; index++) {
            tierContracts[_tiers[index]] = _addresses[index];
        }
    }

    function setLimit(
        uint256 _tier,
        uint256 _presaleLimit,
        uint256 _publicLimit
    ) external onlyRole(OWNER_ROLE) {
        presaleConfig[_tier].limit = _presaleLimit;
        publicConfig[_tier].limit = _publicLimit;
    }

    function setPrice(
        uint256 _tier,
        uint256 _presalePrice,
        uint256 _opensalePrice
    ) external onlyRole(OWNER_ROLE) {
        presaleConfig[_tier].price = _presalePrice;
        publicConfig[_tier].price = _opensalePrice;
    }

    function setLimitPerPurchase(uint256 _limit) external onlyRole(OWNER_ROLE) {
        limitPerPurchase = _limit;
    }
}