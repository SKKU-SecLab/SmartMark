
pragma solidity ^0.8.11;

abstract contract GuardedAgainstContracts {
    modifier onlyUsers() {
        require(tx.origin == msg.sender, 'Must be user');
        _;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.11;


contract SlimPaymentSplitter is Context {

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);
    event PayeeTransferred(address oldOwner, address newOwner);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;

    address[] private _payees;

    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(
            payees.length == shares_.length,
            "PaymentSplitter: payees and shares length mismatch"
        );
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function totalShares() public view returns (uint256) {

        return _totalShares;
    }

    function totalReleased() public view returns (uint256) {

        return _totalReleased;
    }

    function shares(address account) public view returns (uint256) {

        return _shares[account];
    }

    function released(address account) public view returns (uint256) {

        return _released[account];
    }

    function payee(uint256 index) public view returns (address) {

        return _payees[index];
    }

    function release(address payable account) public virtual {

        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(
            account,
            totalReceived,
            released(account)
        );

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {

        return
            (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    function _addPayee(address account, uint256 shares_) private {

        require(
            account != address(0),
            "PaymentSplitter: account is the zero address"
        );
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(
            _shares[account] == 0,
            "PaymentSplitter: account already has shares"
        );

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }


    function transferPayee(address payable newOwner) public {

        require(newOwner != address(0), "PaymentSplitter: New payee is the zero address.");
        require(_shares[msg.sender] > 0, "PaymentSplitter: You have no shares.");
        require(
            _shares[newOwner] == 0, // why not _shares[newOwner] ??
            "PaymentSplitter: New payee already has shares."
        );

        _transferPayee(newOwner);
        emit PayeeTransferred(msg.sender, newOwner);
    }

    function _transferPayee(address newOwner) private {

        if (_payees.length == 0) return;

        for (uint i = 0; i < _payees.length - 1; i++) {
            if (_payees[i] == msg.sender) {
                _payees[i] = newOwner;
                _shares[newOwner] = _shares[msg.sender];
                _shares[msg.sender] = 0;
            }
        }
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

pragma solidity ^0.8.11;


abstract contract LockedPaymentSplitter is SlimPaymentSplitter, Ownable {
    function release(address payable account) public override onlyOwner {
        super.release(account);
    }

    function releaseToSelf() public {
        super.release(payable(msg.sender));
    }
}// MIT
pragma solidity ^0.8.11;

abstract contract MerkleLeaves {
    function getLeafFor(address wallet) external pure returns (bytes32) {
        return _generateLeaf(wallet);
    }

    function getIndexedLeafFor(address wallet, uint256 index)
        external
        pure
        returns (bytes32)
    {
        return _generateIndexedLeaf(wallet, index);
    }

    function _generateLeaf(address wallet) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(wallet));
    }

    function _generateIndexedLeaf(address wallet, uint256 index)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(wallet, "_", index));
    }
}// MIT
pragma solidity ^0.8.11;

library BooleanPacking {

    function getBoolean(uint256 _packedBools, uint256 _columnNumber)
        internal
        pure
        returns (bool)
    {

        uint256 flag = (_packedBools >> _columnNumber) & uint256(1);
        return (flag == 1 ? true : false);
    }

    function setBoolean(
        uint256 _packedBools,
        uint256 _columnNumber,
        bool _value
    ) internal pure returns (uint256) {

        if (_value) {
            _packedBools = _packedBools | (uint256(1) << _columnNumber);
            return _packedBools;
        } else {
            _packedBools = _packedBools & ~(uint256(1) << _columnNumber);
            return _packedBools;
        }
    }
}// MIT
pragma solidity ^0.8.11;



contract TwoPhaseMint is Ownable {

    using BooleanPacking for uint256;

    uint256 private constant CLAIMING_PHASE = 1;
    uint256 private constant PUBLIC_MINT_PHASE = 2;

    uint256 private mintControlFlags;

    uint256 public claimPricePerNft;
    uint256 public publicMintPricePerNft;

    modifier isClaiming() {

        require(mintControlFlags.getBoolean(CLAIMING_PHASE), 'Claiming stopped');
        _;
    }

    modifier isPublicMinting() {

        require(mintControlFlags.getBoolean(PUBLIC_MINT_PHASE), 'Minting stopped');
        _;
    }

    constructor(
        uint256 __claimPricePerNft,
        uint256 __publicMintPricePerNft
    ) {
        claimPricePerNft = __claimPricePerNft;
        publicMintPricePerNft = __publicMintPricePerNft;
    }

    function setMintingState(
        bool __claimingActive,
        bool __publicMintingActive,
        uint256 __claimPricePerNft,
        uint256 __publicMintPricePerNft
    ) external onlyOwner {

        uint256 tempControlFlags;

        tempControlFlags = tempControlFlags.setBoolean(
            CLAIMING_PHASE,
            __claimingActive
        );
        tempControlFlags = tempControlFlags.setBoolean(
            PUBLIC_MINT_PHASE,
            __publicMintingActive
        );

        mintControlFlags = tempControlFlags;

        if (__claimPricePerNft > 0) {
            claimPricePerNft = __claimPricePerNft;
        }

        if (__publicMintPricePerNft > 0) {
            publicMintPricePerNft = __publicMintPricePerNft;
        }
    }

    function isClaimingActive() external view returns (bool) {

        return mintControlFlags.getBoolean(CLAIMING_PHASE);
    }

    function isPublicMintingActive() external view returns (bool) {

        return mintControlFlags.getBoolean(PUBLIC_MINT_PHASE);
    }

    function supportedPhases() external pure returns (uint256) {

        return PUBLIC_MINT_PHASE;
    }
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}// MIT
pragma solidity ^0.8.11;


library MerkleRoot {

    using MerkleProof for bytes32[];

    function check(
        bytes32 root,
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal pure returns (bool) {

        return proof.verify(root, leaf);
    }
}// MIT
pragma solidity ^0.8.11;


library MerkleClaimList {

    using MerkleRoot for bytes32;

    struct Root {
        bytes32 _root;
    }

    function _checkLeaf(
        Root storage root,
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal view returns (bool) {

        return root._root.check(proof, leaf);
    }

    function _setRoot(Root storage root, bytes32 __root) internal {

        root._root = __root;
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

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

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

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

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        if (operator == _msgSender()) revert ApproveToCaller();

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
        if (to.isContract() && !_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _startTokenId() <= tokenId && tokenId < _currentIndex &&
            !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
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
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
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
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
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
}// MIT
pragma solidity ^0.8.11;

interface ISolidarityMetadata {
    function getAsString(uint256 tokenId, uint256 tokenType) external view returns (string memory);

    function getAsEncodedString(uint256 tokenId, uint256 tokenType)
        external
        view
        returns (string memory);
}// MIT
pragma solidity ^0.8.11;







abstract contract SolidarityBase is
    ERC721A,
    Ownable,
    GuardedAgainstContracts,
    ReentrancyGuard,
    LockedPaymentSplitter,
    TwoPhaseMint,
    MerkleLeaves
{
    using MerkleClaimList for MerkleClaimList.Root;

    uint256 private constant MAX_NFTS_FOR_SALE = 999999;
    uint256 private constant MAX_MINT_BATCH_SIZE = 100;

    uint256 public lastTokenMinted = MAX_NFTS_FOR_SALE;

    uint256 private constant TOKEN_TYPE_ONE = 1;
    uint256 private constant TOKEN_TYPE_TWO = 2;

    MerkleClaimList.Root private _claimRoot;
    address private _externalClaimer;

    ISolidarityMetadata private _solidarityMetadata;

    constructor(
        string memory __name,
        string memory __symbol,
        address __solidarityMetadata,
        address[] memory __addresses,
        uint256[] memory __splits
    )
        ERC721A(__name, __symbol)
        SlimPaymentSplitter(__addresses, __splits)
        TwoPhaseMint(0 ether, 0.08 ether)
    {
        _setNewDependencies(__solidarityMetadata, address(0));
    }

    function maxSupply() external pure returns (uint256) {
        return MAX_NFTS_FOR_SALE;
    }

    function publicMintBatchSize() external pure returns (uint256) {
        return MAX_MINT_BATCH_SIZE;
    }

    function isOpenEdition() external pure returns (bool) {
        return true;
    }

    function setLastTokenMinted() external onlyOwner {
        lastTokenMinted = _totalMinted() - 1;
    }

    function unsetLastTokenMinted() external onlyOwner {
        lastTokenMinted = MAX_NFTS_FOR_SALE;
    }

    function unsetExternalClaimer() external onlyOwner {
        _externalClaimer = address(0);
    }

    function setNewDependencies(address __solidarityMetadata, address __externalClaimer)
        external
        onlyOwner
    {
        _setNewDependencies(__solidarityMetadata, __externalClaimer);
    }

    function setMerkleRoot(bytes32 __claimRoot) external onlyOwner {
        if (__claimRoot != 0) {
            _claimRoot._setRoot(__claimRoot);
        }
    }

    function checkClaim(
        bytes32[] calldata proof,
        address wallet,
        uint256 index
    ) external view returns (bool) {
        return _claimRoot._checkLeaf(proof, _generateIndexedLeaf(wallet, index));
    }

    function getNextClaimIndex(address wallet) external view returns (uint256) {
        return _numberMinted(wallet);
    }

    function getMetadataAddress() external view returns (address) {
        return address(_solidarityMetadata);
    }

    function getClaimerAddress() external view returns (address) {
        return address(_externalClaimer);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), 'No token');

        if (tokenId <= lastTokenMinted) {
            return _solidarityMetadata.getAsEncodedString(tokenId, TOKEN_TYPE_ONE);
        }

        return _solidarityMetadata.getAsEncodedString(tokenId, TOKEN_TYPE_TWO);
    }

    function reserveTokens(address[] memory friends, uint256 count) external onlyOwner {
        require(0 < count && count <= MAX_MINT_BATCH_SIZE, 'Invalid count');

        uint256 idx;
        for (idx = 0; idx < friends.length; idx++) {
            _internalMintTokens(friends[idx], count);
        }
    }

    function externalClaimTokens(address claimer, uint256 count) external nonReentrant {
        require(_externalClaimer != address(0) && msg.sender == _externalClaimer, 'Invalid source');
        require(0 < count && count <= MAX_MINT_BATCH_SIZE, 'Invalid count');

        _internalMintTokens(claimer, count);
    }

    function claimTokens(bytes32[] calldata proof, uint256 count)
        external
        payable
        nonReentrant
        isClaiming
    {
        require(0 < count && count <= MAX_MINT_BATCH_SIZE, 'Invalid count');
        require(msg.value >= claimPricePerNft * count, 'Invalid price');

        _claimTokens(msg.sender, proof, count);
    }

    function mintTokens(uint256 count) external payable nonReentrant onlyUsers isPublicMinting {
        require(0 < count && count <= MAX_MINT_BATCH_SIZE, 'Invalid count');
        require(msg.value >= publicMintPricePerNft * count, 'Invalid price');

        _internalMintTokens(msg.sender, count);
    }

    function _claimTokens(
        address minter,
        bytes32[] calldata proof,
        uint256 count
    ) internal {
        require(
            _claimRoot._checkLeaf(
                proof,
                _generateIndexedLeaf(minter, (_numberMinted(minter) + count) - 1) //Zero-based index.
            ),
            'Proof invalid for claim'
        );

        _internalMintTokens(minter, count);
    }

    function _internalMintTokens(address minter, uint256 count) internal {
        require(totalSupply() + count <= MAX_NFTS_FOR_SALE, 'Limit exceeded');

        _safeMint(minter, count);
    }

    function _setNewDependencies(address __solidarityMetadata, address __externalClaimer) internal {
        if (__solidarityMetadata != address(0)) {
            _solidarityMetadata = ISolidarityMetadata(__solidarityMetadata);
        }

        if (__externalClaimer != address(0)) {
            _externalClaimer = __externalClaimer;
        }
    }
}// MIT
pragma solidity ^0.8.11;

contract SolidaritySplits {
    address[] internal addresses = [
        0xb7c7EDC3811ca33c56207844Be48E7375Fe3DB83 // Project Wallet
    ];

    uint256[] internal splits = [100];
}// MIT
pragma solidity ^0.8.11;


contract SolidarityNFTProjectForUkraine is SolidaritySplits, SolidarityBase {
    constructor()
        SolidarityBase(
            "SolidarityNFTForUkraine",
            "Sol4U",
            0x7397f20B4B2eBcd385860718082f6D3e59c1654d, // SolidarityMetadata Mainnet Address.
            addresses,
            splits
        )
    {
    }
}