
pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// GPL-3.0-or-later

pragma solidity ^0.8.4;


error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintedQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerIndexOutOfBounds();
error OwnerQueryForNonexistentToken();
error TokenIndexOutOfBounds();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error UnableDetermineTokenOwner();
error UnableGetTokenOwnerByIndex();
error URIQueryForNonexistentToken();


abstract contract ERC721B {

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    string public name;

    string public symbol;

    function tokenURI(uint256 tokenId) public view virtual returns (string memory);


    address[] internal _owners;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x780e9d63 || // ERC165 Interface ID for ERC721Enumerable
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }


    function totalSupply() public view returns (uint256) {
        return _owners.length;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256 tokenId) {
        if (index >= balanceOf(owner)) revert OwnerIndexOutOfBounds();

        uint256 count;
        uint256 qty = _owners.length;
        unchecked {
            for (tokenId; tokenId < qty; tokenId++) {
                if (owner == ownerOf(tokenId)) {
                    if (count == index) return tokenId;
                    else count++;
                }
            }
        }

        revert UnableGetTokenOwnerByIndex();
    }

    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        if (index >= totalSupply()) revert TokenIndexOutOfBounds();
        return index;
    }


    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();

        uint256 count;
        uint256 qty = _owners.length;
        unchecked {
            for (uint256 i; i < qty; i++) {
                if (owner == ownerOf(i)) {
                    count++;
                }
            }
        }
        return count;
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        if (!_exists(tokenId)) revert OwnerQueryForNonexistentToken();

        unchecked {
            for (tokenId; ; tokenId++) {
                if (_owners[tokenId] != address(0)) {
                    return _owners[tokenId];
                }
            }
        }

        revert UnableDetermineTokenOwner();
    }

    function approve(address to, uint256 tokenId) public virtual {
        address owner = ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert ApprovalCallerNotOwnerNorApproved();

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        if (operator == msg.sender) revert ApproveToCaller();

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        if (!_exists(tokenId)) revert OwnerQueryForNonexistentToken();
        if (ownerOf(tokenId) != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert TransferToZeroAddress();

        bool isApprovedOrOwner = (msg.sender == from ||
            msg.sender == getApproved(tokenId) ||
            isApprovedForAll(from, msg.sender));
        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        delete _tokenApprovals[tokenId];
        _owners[tokenId] = to;

        if (tokenId > 0 && _owners[tokenId - 1] == address(0)) {
            _owners[tokenId - 1] = from;
        }

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        safeTransferFrom(from, to, id, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        if (!_checkOnERC721Received(from, to, id, data)) revert TransferToNonERC721ReceiverImplementer();
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId < _owners.length;
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length == 0) return true;

        try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) revert TransferToNonERC721ReceiverImplementer();

            assembly {
                revert(add(32, reason), mload(reason))
            }
        }
    }


    function _safeMint(address to, uint256 qty) internal virtual {
        _safeMint(to, qty, '');
    }

    function _safeMint(
        address to,
        uint256 qty,
        bytes memory data
    ) internal virtual {
        _mint(to, qty);

        if (!_checkOnERC721Received(address(0), to, _owners.length - 1, data))
            revert TransferToNonERC721ReceiverImplementer();
    }

    function _mint(address to, uint256 qty) internal virtual {
        if (to == address(0)) revert MintToZeroAddress();
        if (qty == 0) revert MintZeroQuantity();

        uint256 _currentIndex = _owners.length;

        unchecked {
            for (uint256 i; i < qty - 1; i++) {
                _owners.push();
                emit Transfer(address(0), to, _currentIndex + i);
            }
        }

        _owners.push(to);
        emit Transfer(address(0), to, _currentIndex + (qty - 1));
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
}// GPL-3.0-or-later

pragma solidity ^0.8.4;


error InvalidProof();
error OverMaxSupply();
error WrongEtherValue();
error OverMintLimit();
error DoubleClaim();
error SaleNotActive();

contract Unmasked is ERC721B, Ownable {

    using Strings for uint256;

    address constant proxyRegistryAddress = address(0xa5409ec958C83C3f309868babACA7c86DCB077c1);
    mapping(address => bool) public addressToRegistryDisabled;

    mapping(address => bool) public claimed;
    bytes32 public CLAIM_ROOT;
    bytes32 public WHITELIST_ROOT;

    string private baseURI;
    string public provenance;
    bool public publicSaleActive;

    uint256 public supply = 3333;
    uint256 public price = 0.06 ether;
    uint256 public price2 = 0.04 ether;
    uint256 constant maxBatchSize = 20;

    constructor() ERC721B('TheUnmasked', 'UNMASKED') {}


    function withdraw() external onlyOwner {

        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setClaim(bytes32 _root) external onlyOwner {

        CLAIM_ROOT = _root;
    }

    function setWhitelist(bytes32 _root) external onlyOwner {

        WHITELIST_ROOT = _root;
    }

    function setProvenanceHash(string calldata provenanceHash) external onlyOwner {

        provenance = provenanceHash;
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {

        baseURI = _baseURI;
    }

    function togglePublicSale() external onlyOwner {

        publicSaleActive = !publicSaleActive;
    }

    function setPrice(uint256 _price, uint256 _price2) external onlyOwner {

        price = _price;
        price2 = _price2;
    }

    function setSupply(uint256 _supply) external onlyOwner {

        supply = _supply;
    }

    function reserveUnmasked(uint256 qty) external onlyOwner {

        if ((_owners.length + qty) > supply) revert OverMaxSupply();

        _mint(msg.sender, qty);
    }

    function claim(
        address account,
        uint256 qty,
        bytes32[] calldata proof
    ) external {

        if (!_verify(_leaf(account, qty), proof)) revert InvalidProof();
        if ((_owners.length + qty) > supply) revert OverMaxSupply();
        if (claimed[account]) revert DoubleClaim();

        claimed[account] = true;

        _mint(account, qty);
    }

    function whitelistMint(uint256 qty, bytes32[] calldata proof) external payable {

        if (!_verify2(_leaf2(msg.sender), proof)) revert InvalidProof();
        if (qty > maxBatchSize) revert OverMintLimit();
        if ((_owners.length + qty) > supply) revert OverMaxSupply();
        if (msg.value < price2 * qty) revert WrongEtherValue();

        _mint(msg.sender, qty);
    }

    function publicMint(uint256 qty) external payable {

        if (!publicSaleActive) revert SaleNotActive();
        if (qty > maxBatchSize) revert OverMintLimit();
        if ((_owners.length + qty) > supply) revert OverMaxSupply();
        if (msg.value < price * qty) revert WrongEtherValue();

        _safeMint(msg.sender, qty);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator && !addressToRegistryDisabled[owner]) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function toggleRegistryAccess() public virtual {

        addressToRegistryDisabled[msg.sender] = !addressToRegistryDisabled[msg.sender];
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {

        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId)));
    }

    function _leaf(address account, uint256 qty) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(account, qty));
    }

    function _leaf2(address account) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(account));
    }

    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {

        return MerkleProof.verify(proof, CLAIM_ROOT, leaf);
    }

    function _verify2(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {

        return MerkleProof.verify(proof, WHITELIST_ROOT, leaf);
    }
}

contract OwnableDelegateProxy {


}

contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}