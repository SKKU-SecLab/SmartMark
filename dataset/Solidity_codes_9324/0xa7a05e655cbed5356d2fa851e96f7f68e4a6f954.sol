



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
}



pragma solidity 0.6.8;

interface IERC721 {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}



pragma solidity 0.6.8;

interface IERC721Metadata {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}



pragma solidity 0.6.8;

interface IERC721BatchTransfer {

    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata tokenIds
    ) external;

}



pragma solidity 0.6.8;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity 0.6.8;

interface IERC1155 {

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;


    function balanceOf(address owner, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}



pragma solidity 0.6.8;

interface IERC1155MetadataURI {

    function uri(uint256 id) external view returns (string memory);

}



pragma solidity 0.6.8;

interface IERC1155Inventory {

    event CollectionCreated(uint256 indexed collectionId, bool indexed fungible);

    function ownerOf(uint256 nftId) external view returns (address);


    function isFungible(uint256 id) external pure returns (bool);


    function collectionOf(uint256 nftId) external pure returns (uint256);


    function totalSupply(uint256 id) external view returns (uint256);





}



pragma solidity 0.6.8;

interface IERC1155TokenReceiver {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}



pragma solidity 0.6.8;






library ERC1155InventoryIdentifiersLib {

    uint256 internal constant _NF_BIT = 1 << 255;

    uint256 internal constant _NF_COLLECTION_MASK = uint256(type(uint32).max) << 224;
    uint256 internal constant _NF_TOKEN_MASK = ~_NF_COLLECTION_MASK;

    function isFungibleToken(uint256 id) internal pure returns (bool) {

        return id & _NF_BIT == 0;
    }

    function isNonFungibleToken(uint256 id) internal pure returns (bool) {

        return id & _NF_BIT != 0 && id & _NF_TOKEN_MASK != 0;
    }

    function getNonFungibleCollection(uint256 nftId) internal pure returns (uint256) {

        return nftId & _NF_COLLECTION_MASK;
    }
}

abstract contract ERC1155InventoryBase is IERC1155, IERC1155MetadataURI, IERC1155Inventory, IERC165, Context {
    using ERC1155InventoryIdentifiersLib for uint256;

    bytes4 private constant _ERC165_INTERFACE_ID = type(IERC165).interfaceId;
    bytes4 private constant _ERC1155_INTERFACE_ID = type(IERC1155).interfaceId;
    bytes4 private constant _ERC1155_METADATA_URI_INTERFACE_ID = type(IERC1155MetadataURI).interfaceId;
    bytes4 private constant _ERC1155_INVENTORY_INTERFACE_ID = type(IERC1155Inventory).interfaceId;

    bytes4 internal constant _ERC1155_RECEIVED = 0xf23a6e61;

    bytes4 internal constant _ERC1155_BATCH_RECEIVED = 0xbc197c81;

    uint256 internal constant _BURNT_NFT_OWNER = 0xdead000000000000000000000000000000000000000000000000000000000000;

    mapping(address => mapping(address => bool)) internal _operators;

    mapping(uint256 => mapping(address => uint256)) internal _balances;

    mapping(uint256 => uint256) internal _supplies;

    mapping(uint256 => uint256) internal _owners;

    mapping(uint256 => address) internal _creators;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == _ERC165_INTERFACE_ID ||
            interfaceId == _ERC1155_INTERFACE_ID ||
            interfaceId == _ERC1155_METADATA_URI_INTERFACE_ID ||
            interfaceId == _ERC1155_INVENTORY_INTERFACE_ID;
    }


    function balanceOf(address owner, uint256 id) public view virtual override returns (uint256) {
        require(owner != address(0), "Inventory: zero address");

        if (id.isNonFungibleToken()) {
            return address(_owners[id]) == owner ? 1 : 0;
        }

        return _balances[id][owner];
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids) external view virtual override returns (uint256[] memory) {
        require(owners.length == ids.length, "Inventory: inconsistent arrays");

        uint256[] memory balances = new uint256[](owners.length);

        for (uint256 i = 0; i != owners.length; ++i) {
            balances[i] = balanceOf(owners[i], ids[i]);
        }

        return balances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        address sender = _msgSender();
        require(operator != sender, "Inventory: self-approval");
        _operators[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    function isApprovedForAll(address tokenOwner, address operator) public view virtual override returns (bool) {
        return _operators[tokenOwner][operator];
    }


    function isFungible(uint256 id) external pure virtual override returns (bool) {
        return id.isFungibleToken();
    }

    function collectionOf(uint256 nftId) external pure virtual override returns (uint256) {
        require(nftId.isNonFungibleToken(), "Inventory: not an NFT");
        return nftId.getNonFungibleCollection();
    }

    function ownerOf(uint256 nftId) public view virtual override returns (address) {
        address owner = address(_owners[nftId]);
        require(owner != address(0), "Inventory: non-existing NFT");
        return owner;
    }

    function totalSupply(uint256 id) external view virtual override returns (uint256) {
        if (id.isNonFungibleToken()) {
            return address(_owners[id]) == address(0) ? 0 : 1;
        } else {
            return _supplies[id];
        }
    }


    function _createCollection(uint256 collectionId) internal virtual {
        require(!collectionId.isNonFungibleToken(), "Inventory: not a collection");
        require(_creators[collectionId] == address(0), "Inventory: existing collection");
        _creators[collectionId] = _msgSender();
        emit CollectionCreated(collectionId, collectionId.isFungibleToken());
    }

    function _creator(uint256 collectionId) internal view virtual returns (address) {
        require(!collectionId.isNonFungibleToken(), "Inventory: not a collection");
        return _creators[collectionId];
    }


    function _isOperatable(address from, address sender) internal view virtual returns (bool) {
        return (from == sender) || _operators[from][sender];
    }

    function _callOnERC1155Received(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) internal {
        require(IERC1155TokenReceiver(to).onERC1155Received(_msgSender(), from, id, value, data) == _ERC1155_RECEIVED, "Inventory: transfer refused");
    }

    function _callOnERC1155BatchReceived(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal {
        require(
            IERC1155TokenReceiver(to).onERC1155BatchReceived(_msgSender(), from, ids, values, data) == _ERC1155_BATCH_RECEIVED,
            "Inventory: transfer refused"
        );
    }
}



pragma solidity 0.6.8;






abstract contract ERC1155721Inventory is IERC721, IERC721Metadata, IERC721BatchTransfer, ERC1155InventoryBase {
    using Address for address;

    bytes4 private constant _ERC165_INTERFACE_ID = type(IERC165).interfaceId;
    bytes4 private constant _ERC1155_TOKEN_RECEIVER_INTERFACE_ID = type(IERC1155TokenReceiver).interfaceId;
    bytes4 private constant _ERC721_INTERFACE_ID = type(IERC721).interfaceId;
    bytes4 private constant _ERC721_METADATA_INTERFACE_ID = type(IERC721Metadata).interfaceId;

    bytes4 internal constant _ERC721_RECEIVED = type(IERC721Receiver).interfaceId;

    uint256 internal constant _APPROVAL_BIT_TOKEN_OWNER_ = 1 << 160;

    mapping(address => uint256) internal _nftBalances;

    mapping(uint256 => address) internal _nftApprovals;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || interfaceId == _ERC721_INTERFACE_ID || interfaceId == _ERC721_METADATA_INTERFACE_ID;
    }


    function balanceOf(address tokenOwner) external view virtual override returns (uint256) {
        require(tokenOwner != address(0), "Inventory: zero address");
        return _nftBalances[tokenOwner];
    }

    function ownerOf(uint256 nftId) public view virtual override(IERC721, ERC1155InventoryBase) returns (address) {
        return ERC1155InventoryBase.ownerOf(nftId);
    }

    function approve(address to, uint256 nftId) external virtual override {
        address tokenOwner = ownerOf(nftId);
        require(to != tokenOwner, "Inventory: self-approval");
        require(_isOperatable(tokenOwner, _msgSender()), "Inventory: non-approved sender");
        _owners[nftId] = uint256(tokenOwner) | _APPROVAL_BIT_TOKEN_OWNER_;
        _nftApprovals[nftId] = to;
        emit Approval(tokenOwner, to, nftId);
    }

    function getApproved(uint256 nftId) external view virtual override returns (address) {
        uint256 tokenOwner = _owners[nftId];
        require(address(tokenOwner) != address(0), "Inventory: non-existing NFT");
        if (tokenOwner & _APPROVAL_BIT_TOKEN_OWNER_ != 0) {
            return _nftApprovals[nftId];
        } else {
            return address(0);
        }
    }

    function isApprovedForAll(address tokenOwner, address operator) public view virtual override(IERC721, ERC1155InventoryBase) returns (bool) {
        return ERC1155InventoryBase.isApprovedForAll(tokenOwner, operator);
    }

    function setApprovalForAll(address operator, bool approved) public virtual override(IERC721, ERC1155InventoryBase) {
        return ERC1155InventoryBase.setApprovalForAll(operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 nftId
    ) public virtual override {
        _transferFrom(
            from,
            to,
            nftId,
            "",
            false
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 nftId
    ) public virtual override {
        _transferFrom(
            from,
            to,
            nftId,
            "",
            true
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 nftId,
        bytes memory data
    ) public virtual override {
        _transferFrom(
            from,
            to,
            nftId,
            data,
            true
        );
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory nftIds
    ) public virtual override {
        require(to != address(0), "Inventory: transfer to zero");
        address sender = _msgSender();
        bool operatable = _isOperatable(from, sender);

        uint256 length = nftIds.length;
        uint256[] memory values = new uint256[](length);

        uint256 nfCollectionId;
        uint256 nfCollectionCount;
        for (uint256 i; i != length; ++i) {
            uint256 nftId = nftIds[i];
            values[i] = 1;
            _transferNFT(from, to, nftId, 1, operatable, true);
            emit Transfer(from, to, nftId);
            uint256 nextCollectionId = nftId.getNonFungibleCollection();
            if (nfCollectionId == 0) {
                nfCollectionId = nextCollectionId;
                nfCollectionCount = 1;
            } else {
                if (nextCollectionId != nfCollectionId) {
                    _transferNFTUpdateCollection(from, to, nfCollectionId, nfCollectionCount);
                    nfCollectionId = nextCollectionId;
                    nfCollectionCount = 1;
                } else {
                    ++nfCollectionCount;
                }
            }
        }

        if (nfCollectionId != 0) {
            _transferNFTUpdateCollection(from, to, nfCollectionId, nfCollectionCount);
            _transferNFTUpdateBalances(from, to, length);
        }

        emit TransferBatch(_msgSender(), from, to, nftIds, values);
        if (to.isContract() && _isERC1155TokenReceiver(to)) {
            _callOnERC1155BatchReceived(from, to, nftIds, values, "");
        }
    }

    function tokenURI(uint256 nftId) external view virtual override returns (string memory) {
        require(address(_owners[nftId]) != address(0), "Inventory: non-existing NFT");
        return uri(nftId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override {
        address sender = _msgSender();
        require(to != address(0), "Inventory: transfer to zero");
        bool operatable = _isOperatable(from, sender);

        if (id.isFungibleToken()) {
            _transferFungible(from, to, id, value, operatable);
        } else if (id.isNonFungibleToken()) {
            _transferNFT(from, to, id, value, operatable, false);
            emit Transfer(from, to, id);
        } else {
            revert("Inventory: not a token id");
        }

        emit TransferSingle(sender, from, to, id, value);
        if (to.isContract()) {
            _callOnERC1155Received(from, to, id, value, data);
        }
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override {
        _safeBatchTransferFrom(from, to, ids, values, data);
    }


    function uri(uint256) public view virtual override returns (string memory);


    function _transferFrom(
        address from,
        address to,
        uint256 nftId,
        bytes memory data,
        bool safe
    ) internal {
        require(to != address(0), "Inventory: transfer to zero");
        address sender = _msgSender();
        bool operatable = _isOperatable(from, sender);

        _transferNFT(from, to, nftId, 1, operatable, false);

        emit Transfer(from, to, nftId);
        emit TransferSingle(sender, from, to, nftId, 1);
        if (to.isContract()) {
            if (_isERC1155TokenReceiver(to)) {
                _callOnERC1155Received(from, to, nftId, 1, data);
            } else if (safe) {
                _callOnERC721Received(from, to, nftId, data);
            }
        }
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal {
        require(to != address(0), "Inventory: transfer to zero");
        uint256 length = ids.length;
        require(length == values.length, "Inventory: inconsistent arrays");
        address sender = _msgSender();
        bool operatable = _isOperatable(from, sender);

        uint256 nfCollectionId;
        uint256 nfCollectionCount;
        uint256 nftsCount;
        for (uint256 i; i != length; ++i) {
            uint256 id = ids[i];
            if (id.isFungibleToken()) {
                _transferFungible(from, to, id, values[i], operatable);
            } else if (id.isNonFungibleToken()) {
                _transferNFT(from, to, id, values[i], operatable, true);
                emit Transfer(from, to, id);
                uint256 nextCollectionId = id.getNonFungibleCollection();
                if (nfCollectionId == 0) {
                    nfCollectionId = nextCollectionId;
                    nfCollectionCount = 1;
                } else {
                    if (nextCollectionId != nfCollectionId) {
                        _transferNFTUpdateCollection(from, to, nfCollectionId, nfCollectionCount);
                        nfCollectionId = nextCollectionId;
                        nftsCount += nfCollectionCount;
                        nfCollectionCount = 1;
                    } else {
                        ++nfCollectionCount;
                    }
                }
            } else {
                revert("Inventory: not a token id");
            }
        }

        if (nfCollectionId != 0) {
            _transferNFTUpdateCollection(from, to, nfCollectionId, nfCollectionCount);
            nftsCount += nfCollectionCount;
            _transferNFTUpdateBalances(from, to, nftsCount);
        }

        emit TransferBatch(_msgSender(), from, to, ids, values);
        if (to.isContract()) {
            _callOnERC1155BatchReceived(from, to, ids, values, data);
        }
    }

    function _mint(
        address to,
        uint256 nftId,
        bytes memory data,
        bool safe
    ) internal {
        require(to != address(0), "Inventory: transfer to zero");
        require(nftId.isNonFungibleToken(), "Inventory: not an NFT");

        _mintNFT(to, nftId, 1, false);

        emit Transfer(address(0), to, nftId);
        emit TransferSingle(_msgSender(), address(0), to, nftId, 1);
        if (to.isContract()) {
            if (_isERC1155TokenReceiver(to)) {
                _callOnERC1155Received(address(0), to, nftId, 1, data);
            } else if (safe) {
                _callOnERC721Received(address(0), to, nftId, data);
            }
        }
    }

    function _batchMint(address to, uint256[] memory nftIds) internal {
        require(to != address(0), "Inventory: transfer to zero");

        uint256 length = nftIds.length;
        uint256[] memory values = new uint256[](length);

        uint256 nfCollectionId;
        uint256 nfCollectionCount;
        for (uint256 i; i != length; ++i) {
            uint256 nftId = nftIds[i];
            require(nftId.isNonFungibleToken(), "Inventory: not an NFT");
            values[i] = 1;
            _mintNFT(to, nftId, 1, true);
            emit Transfer(address(0), to, nftId);
            uint256 nextCollectionId = nftId.getNonFungibleCollection();
            if (nfCollectionId == 0) {
                nfCollectionId = nextCollectionId;
                nfCollectionCount = 1;
            } else {
                if (nextCollectionId != nfCollectionId) {
                    _balances[nfCollectionId][to] += nfCollectionCount;
                    _supplies[nfCollectionId] += nfCollectionCount;
                    nfCollectionId = nextCollectionId;
                    nfCollectionCount = 1;
                } else {
                    ++nfCollectionCount;
                }
            }
        }

        _balances[nfCollectionId][to] += nfCollectionCount;
        _supplies[nfCollectionId] += nfCollectionCount;
        _nftBalances[to] += length;

        emit TransferBatch(_msgSender(), address(0), to, nftIds, values);
        if (to.isContract() && _isERC1155TokenReceiver(to)) {
            _callOnERC1155BatchReceived(address(0), to, nftIds, values, "");
        }
    }

    function _safeMint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "Inventory: transfer to zero");
        address sender = _msgSender();
        if (id.isFungibleToken()) {
            _mintFungible(to, id, value);
        } else if (id.isNonFungibleToken()) {
            _mintNFT(to, id, value, false);
            emit Transfer(address(0), to, id);
        } else {
            revert("Inventory: not a token id");
        }

        emit TransferSingle(sender, address(0), to, id, value);
        if (to.isContract()) {
            _callOnERC1155Received(address(0), to, id, value, data);
        }
    }

    function _safeBatchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "Inventory: transfer to zero");
        uint256 length = ids.length;
        require(length == values.length, "Inventory: inconsistent arrays");

        uint256 nfCollectionId;
        uint256 nfCollectionCount;
        uint256 nftsCount;
        for (uint256 i; i != length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];
            if (id.isFungibleToken()) {
                _mintFungible(to, id, value);
            } else if (id.isNonFungibleToken()) {
                _mintNFT(to, id, value, true);
                emit Transfer(address(0), to, id);
                uint256 nextCollectionId = id.getNonFungibleCollection();
                if (nfCollectionId == 0) {
                    nfCollectionId = nextCollectionId;
                    nfCollectionCount = 1;
                } else {
                    if (nextCollectionId != nfCollectionId) {
                        _balances[nfCollectionId][to] += nfCollectionCount;
                        _supplies[nfCollectionId] += nfCollectionCount;
                        nfCollectionId = nextCollectionId;
                        nftsCount += nfCollectionCount;
                        nfCollectionCount = 1;
                    } else {
                        ++nfCollectionCount;
                    }
                }
            } else {
                revert("Inventory: not a token id");
            }
        }

        if (nfCollectionId != 0) {
            _balances[nfCollectionId][to] += nfCollectionCount;
            _supplies[nfCollectionId] += nfCollectionCount;
            nftsCount += nfCollectionCount;
            _nftBalances[to] += nftsCount;
        }

        emit TransferBatch(_msgSender(), address(0), to, ids, values);
        if (to.isContract()) {
            _callOnERC1155BatchReceived(address(0), to, ids, values, data);
        }
    }


    function _mintFungible(
        address to,
        uint256 id,
        uint256 value
    ) internal {
        require(value != 0, "Inventory: zero value");
        uint256 supply = _supplies[id];
        uint256 newSupply = supply + value;
        require(newSupply > supply, "Inventory: supply overflow");
        _supplies[id] = newSupply;
        _balances[id][to] += value;
    }

    function _mintNFT(
        address to,
        uint256 id,
        uint256 value,
        bool isBatch
    ) internal {
        require(value == 1, "Inventory: wrong NFT value");
        require(_owners[id] == 0, "Inventory: existing/burnt NFT");

        _owners[id] = uint256(to);

        if (!isBatch) {
            uint256 collectionId = id.getNonFungibleCollection();
            ++_supplies[collectionId];
            ++_balances[collectionId][to];
            ++_nftBalances[to];
        }
    }

    function _transferFungible(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bool operatable
    ) internal {
        require(operatable, "Inventory: non-approved sender");
        require(value != 0, "Inventory: zero value");
        uint256 balance = _balances[id][from];
        require(balance >= value, "Inventory: not enough balance");
        if (from != to) {
            _balances[id][from] = balance - value;
            _balances[id][to] += value;
        }
    }

    function _transferNFT(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bool operatable,
        bool isBatch
    ) internal virtual {
        require(value == 1, "Inventory: wrong NFT value");
        uint256 owner = _owners[id];
        require(from == address(owner), "Inventory: non-owned NFT");
        if (!operatable) {
            require((owner & _APPROVAL_BIT_TOKEN_OWNER_ != 0) && _msgSender() == _nftApprovals[id], "Inventory: non-approved sender");
        }
        _owners[id] = uint256(to);
        if (!isBatch) {
            _transferNFTUpdateBalances(from, to, 1);
            _transferNFTUpdateCollection(from, to, id.getNonFungibleCollection(), 1);
        }
    }

    function _transferNFTUpdateBalances(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (from != to) {
            _nftBalances[from] -= amount;
            _nftBalances[to] += amount;
        }
    }

    function _transferNFTUpdateCollection(
        address from,
        address to,
        uint256 collectionId,
        uint256 amount
    ) internal virtual {
        if (from != to) {
            _balances[collectionId][from] -= amount;
            _balances[collectionId][to] += amount;
        }
    }


    function _isERC1155TokenReceiver(address _contract) internal view returns (bool) {
        bool success;
        bool result;
        bytes memory staticCallData = abi.encodeWithSelector(_ERC165_INTERFACE_ID, _ERC1155_TOKEN_RECEIVER_INTERFACE_ID);
        assembly {
            let call_ptr := add(0x20, staticCallData)
            let call_size := mload(staticCallData)
            let output := mload(0x40) // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)
            success := staticcall(10000, _contract, call_ptr, call_size, output, 0x20) // 32 bytes
            result := mload(output)
        }
        assert(gasleft() > 158);
        return success && result;
    }

    function _callOnERC721Received(
        address from,
        address to,
        uint256 nftId,
        bytes memory data
    ) internal {
        require(IERC721Receiver(to).onERC721Received(_msgSender(), from, nftId, data) == _ERC721_RECEIVED, "Inventory: transfer refused");
    }
}



pragma solidity 0.6.8;

interface IERC1155721InventoryBurnable {

    function burnFrom(
        address from,
        uint256 id,
        uint256 value
    ) external;


    function batchBurnFrom(
        address from,
        uint256[] calldata ids,
        uint256[] calldata values
    ) external;


    function batchBurnFrom(address from, uint256[] calldata nftIds) external;

}



pragma solidity 0.6.8;


abstract contract ERC1155721InventoryBurnable is IERC1155721InventoryBurnable, ERC1155721Inventory {

    function burnFrom(
        address from,
        uint256 id,
        uint256 value
    ) public virtual override {
        address sender = _msgSender();
        bool operatable = _isOperatable(from, sender);

        if (id.isFungibleToken()) {
            _burnFungible(from, id, value, operatable);
        } else if (id.isNonFungibleToken()) {
            _burnNFT(from, id, value, operatable, false);
            emit Transfer(from, address(0), id);
        } else {
            revert("Inventory: not a token id");
        }

        emit TransferSingle(sender, from, address(0), id, value);
    }

    function batchBurnFrom(
        address from,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual override {
        uint256 length = ids.length;
        require(length == values.length, "Inventory: inconsistent arrays");

        address sender = _msgSender();
        bool operatable = _isOperatable(from, sender);

        uint256 nfCollectionId;
        uint256 nfCollectionCount;
        uint256 nftsCount;
        for (uint256 i; i != length; ++i) {
            uint256 id = ids[i];
            if (id.isFungibleToken()) {
                _burnFungible(from, id, values[i], operatable);
            } else if (id.isNonFungibleToken()) {
                _burnNFT(from, id, values[i], operatable, true);
                emit Transfer(from, address(0), id);
                uint256 nextCollectionId = id.getNonFungibleCollection();
                if (nfCollectionId == 0) {
                    nfCollectionId = nextCollectionId;
                    nfCollectionCount = 1;
                } else {
                    if (nextCollectionId != nfCollectionId) {
                        _burnNFTUpdateCollection(from, nfCollectionId, nfCollectionCount);
                        nfCollectionId = nextCollectionId;
                        nftsCount += nfCollectionCount;
                        nfCollectionCount = 1;
                    } else {
                        ++nfCollectionCount;
                    }
                }
            } else {
                revert("Inventory: not a token id");
            }
        }

        if (nfCollectionId != 0) {
            _burnNFTUpdateCollection(from, nfCollectionId, nfCollectionCount);
            nftsCount += nfCollectionCount;
            _nftBalances[from] -= nftsCount;
        }

        emit TransferBatch(sender, from, address(0), ids, values);
    }

    function batchBurnFrom(address from, uint256[] memory nftIds) public virtual override {
        address sender = _msgSender();
        bool operatable = _isOperatable(from, sender);

        uint256 length = nftIds.length;
        uint256[] memory values = new uint256[](length);

        uint256 nfCollectionId;
        uint256 nfCollectionCount;
        for (uint256 i; i != length; ++i) {
            uint256 nftId = nftIds[i];
            values[i] = 1;
            _burnNFT(from, nftId, values[i], operatable, true);
            emit Transfer(from, address(0), nftId);
            uint256 nextCollectionId = nftId.getNonFungibleCollection();
            if (nfCollectionId == 0) {
                nfCollectionId = nextCollectionId;
                nfCollectionCount = 1;
            } else {
                if (nextCollectionId != nfCollectionId) {
                    _burnNFTUpdateCollection(from, nfCollectionId, nfCollectionCount);
                    nfCollectionId = nextCollectionId;
                    nfCollectionCount = 1;
                } else {
                    ++nfCollectionCount;
                }
            }
        }

        if (nfCollectionId != 0) {
            _burnNFTUpdateCollection(from, nfCollectionId, nfCollectionCount);
            _nftBalances[from] -= length;
        }

        emit TransferBatch(sender, from, address(0), nftIds, values);
    }


    function _burnFungible(
        address from,
        uint256 id,
        uint256 value,
        bool operatable
    ) internal {
        require(value != 0, "Inventory: zero value");
        require(operatable, "Inventory: non-approved sender");
        uint256 balance = _balances[id][from];
        require(balance >= value, "Inventory: not enough balance");
        _balances[id][from] = balance - value;
        _supplies[id] -= value;
    }

    function _burnNFT(
        address from,
        uint256 id,
        uint256 value,
        bool operatable,
        bool isBatch
    ) internal virtual {
        require(value == 1, "Inventory: wrong NFT value");
        uint256 owner = _owners[id];
        require(from == address(owner), "Inventory: non-owned NFT");
        if (!operatable) {
            require((owner & _APPROVAL_BIT_TOKEN_OWNER_ != 0) && _msgSender() == _nftApprovals[id], "Inventory: non-approved sender");
        }
        _owners[id] = _BURNT_NFT_OWNER;

        if (!isBatch) {
            _burnNFTUpdateCollection(from, id.getNonFungibleCollection(), 1);

            --_nftBalances[from];
        }
    }

    function _burnNFTUpdateCollection(
        address from,
        uint256 collectionId,
        uint256 amount
    ) internal virtual {
        _balances[collectionId][from] -= amount;
        _supplies[collectionId] -= amount;
    }
}



pragma solidity 0.6.8;

interface IERC1155721InventoryMintable {

    function safeMint(
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;


    function safeBatchMint(
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;


    function mint(address to, uint256 nftId) external;


    function batchMint(address to, uint256[] calldata nftIds) external;


    function safeMint(
        address to,
        uint256 nftId,
        bytes calldata data
    ) external;

}



pragma solidity 0.6.8;

interface IERC1155InventoryCreator {

    function creator(uint256 collectionId) external view returns (address);

}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}



pragma solidity 0.6.8;

library UInt256ToDecimalString {

    function toDecimalString(uint256 value) internal pure returns (string memory) {

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
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }
}



pragma solidity 0.6.8;


contract BaseMetadataURI is Ownable {

    using UInt256ToDecimalString for uint256;

    event BaseMetadataURISet(string baseMetadataURI);

    string public baseMetadataURI;

    function setBaseMetadataURI(string calldata baseMetadataURI_) external onlyOwner {

        baseMetadataURI = baseMetadataURI_;
        emit BaseMetadataURISet(baseMetadataURI_);
    }

    function _uri(uint256 id) internal view virtual returns (string memory) {

        return string(abi.encodePacked(baseMetadataURI, id.toDecimalString()));
    }
}



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

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}



pragma solidity >=0.6.0 <0.8.0;



abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



pragma solidity 0.6.8;

contract MinterRole is AccessControl {

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: not a Minter");
        _;
    }

    constructor() internal {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        emit MinterAdded(_msgSender());
    }

    function isMinter(address account) public view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addMinter(address account) public onlyMinter {

        require(!isMinter(account), "MinterRole: already Minter");
        grantRole(DEFAULT_ADMIN_ROLE, account);
        emit MinterAdded(account);
    }

    function renounceMinter() public onlyMinter {

        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
        emit MinterRemoved(_msgSender());
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
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
}



pragma solidity ^0.6.8;







contract REVVInventory is
    Ownable,
    Pausable,
    ERC1155721InventoryBurnable,
    IERC1155721InventoryMintable,
    IERC1155InventoryCreator,
    BaseMetadataURI,
    MinterRole
{

    string public constant override name = "REVV Inventory";
    string public constant override symbol = "REVV-I";


    function uri(uint256 id) public view virtual override returns (string memory) {

        return _uri(id);
    }


    function creator(uint256 collectionId) external view override returns (address) {

        return _creator(collectionId);
    }



    function pause() external virtual {

        require(owner() == _msgSender(), "Inventory: not the owner");
        _pause();
    }

    function unpause() external virtual {

        require(owner() == _msgSender(), "Inventory: not the owner");
        _unpause();
    }


    function createCollection(uint256 collectionId) external onlyOwner {

        _createCollection(collectionId);
    }


    function mint(address to, uint256 nftId) public virtual override {

        require(isMinter(_msgSender()), "Inventory: not a minter");
        _mint(to, nftId, "", false);
    }

    function batchMint(address to, uint256[] memory nftIds) public virtual override {

        require(isMinter(_msgSender()), "Inventory: not a minter");
        _batchMint(to, nftIds);
    }

    function safeMint(
        address to,
        uint256 nftId,
        bytes memory data
    ) public virtual override {

        require(isMinter(_msgSender()), "Inventory: not a minter");
        _mint(to, nftId, data, true);
    }

    function safeMint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override {

        require(isMinter(_msgSender()), "Inventory: not a minter");
        _safeMint(to, id, value, data);
    }

    function safeBatchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override {

        require(isMinter(_msgSender()), "Inventory: not a minter");
        _safeBatchMint(to, ids, values, data);
    }


    function transferFrom(
        address from,
        address to,
        uint256 nftId
    ) public virtual override {

        require(!paused(), "Inventory: paused");
        super.transferFrom(from, to, nftId);
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory nftIds
    ) public virtual override {

        require(!paused(), "Inventory: paused");
        super.batchTransferFrom(from, to, nftIds);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 nftId
    ) public virtual override {

        require(!paused(), "Inventory: paused");
        super.safeTransferFrom(from, to, nftId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 nftId,
        bytes memory data
    ) public virtual override {

        require(!paused(), "Inventory: paused");
        super.safeTransferFrom(from, to, nftId, data);
    }

    function batchBurnFrom(address from, uint256[] memory nftIds) public virtual override {

        require(!paused(), "Inventory: paused");
        super.batchBurnFrom(from, nftIds);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override {

        require(!paused(), "Inventory: paused");
        super.safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override {

        require(!paused(), "Inventory: paused");
        super.safeBatchTransferFrom(from, to, ids, values, data);
    }

    function burnFrom(
        address from,
        uint256 id,
        uint256 value
    ) public virtual override {

        require(!paused(), "Inventory: paused");
        super.burnFrom(from, id, value);
    }

    function batchBurnFrom(
        address from,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual override {

        require(!paused(), "Inventory: paused");
        super.batchBurnFrom(from, ids, values);
    }
}