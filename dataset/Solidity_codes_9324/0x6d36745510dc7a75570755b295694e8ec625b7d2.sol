pragma solidity >=0.8.0;

abstract contract Owned {

    event OwnerUpdated(address indexed user, address indexed newOwner);


    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }


    constructor(address _owner) {
        owner = _owner;

        emit OwnerUpdated(address(0), _owner);
    }


    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ERC1155 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);


    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;


    function uri(uint256 id) public view virtual returns (string memory);


    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        require(ids.length == amounts.length, "LENGTH_MISMATCH");

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        uint256 id;
        uint256 amount;

        for (uint256 i = 0; i < ids.length; ) {
            id = ids[i];
            amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        require(owners.length == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }


    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }


    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

}// CC0-1.0
pragma solidity ^0.8.14;

interface IICE64Renderer {

    function drawSVGToString(bytes memory data) external view returns (string memory);


    function drawSVGToBytes(bytes memory data) external view returns (bytes memory);


    function tokenURI(uint256 id) external view returns (string memory);

}// CC0-1.0
pragma solidity ^0.8.14;

interface IICE64 {

    function getOriginalTokenId(uint256 editionId) external pure returns (uint256);


    function getEditionTokenId(uint256 id) external pure returns (uint256);


    function getMaxEditions() external view returns (uint256);


    function isEdition(uint256 id) external pure returns (bool);

}// MIT
pragma solidity ^0.8.14;




contract ICE64 is ERC1155, Owned, IICE64 {


    IICE64Renderer public metadata;

    IERC721 public roots;

    uint256 private _rootsClaims;

    uint256 private constant _maxTokenId = 16;
    uint256 private constant _editionStartId = 100;
    uint256 private constant _maxEditions = 64;

    uint256 public constant priceOriginal = 0.32 ether;
    uint256 public constant priceEdition = 0.04 ether;

    mapping(uint256 => uint256) private _salesCount;

    struct RoyaltyInfo {
        address receiver;
        uint24 amount;
    }

    RoyaltyInfo private _royaltyInfo;


    event ICE64Emerges();
    event SetMetadataAddress(address indexed metadata);
    event RootsClaim(uint256 indexed rootsId, uint256 indexed originalId, uint256 editionId);


    error IncorrectEthAmount();
    error InvalidToken();
    error AlreadyOwnerOfEdition();
    error SoldOut();
    error EditionForOriginalStillReserved();
    error NotOwnerOfRootsPhoto();
    error RootsPhotoAlreadyUsedClaim();
    error NotOwner();
    error NoMetadataYet();
    error PaymentFailed();


    modifier onlyValidToken(uint256 id) {

        if (id == 0 || id > _maxTokenId) revert InvalidToken();
        _;
    }

    modifier onlyCorrectPayment(uint256 cost) {

        if (msg.value != cost) revert IncorrectEthAmount();
        _;
    }

    modifier onlyWithMetadata() {

        if (address(metadata) == address(0)) revert NoMetadataYet();
        _;
    }


    constructor(
        address owner,
        address royalties,
        IERC721 roots_
    ) ERC1155() Owned(owner) {
        emit ICE64Emerges();
        roots = roots_;
        _rootsClaims = _setBool(_rootsClaims, 0, true);
        _royaltyInfo = RoyaltyInfo(royalties, 640);
    }

    function setMetadata(IICE64Renderer metadataAddr) external onlyOwner {

        metadata = metadataAddr;
        emit SetMetadataAddress(address(metadataAddr));
    }


    function purchaseOriginal(uint256 id)
        external
        payable
        onlyValidToken(id)
        onlyCorrectPayment(priceOriginal)
    {

        (uint256 originalsSold, , ) = _decodeSalesCount(_salesCount[id]);
        if (originalsSold > 0) revert SoldOut();

        uint256 editionId = getEditionTokenId(id);
        if (balanceOf[msg.sender][editionId] > 0) {
            _mint(msg.sender, id, 1, "");
            _addSalesCount(id, 1, 0, true);
        } else {
            _mint(msg.sender, id, 1, "");
            _mint(msg.sender, editionId, 1, "");
            _addSalesCount(id, 1, 1, true);
        }
    }

    function purchaseEdition(uint256 id)
        external
        payable
        onlyValidToken(id)
        onlyCorrectPayment(priceEdition)
    {

        _mintEdition(id);
    }

    function claimEditionAsRootsHolder(uint256 id, uint256 rootsId) external onlyValidToken(id) {

        if (roots.ownerOf(rootsId) != msg.sender) revert NotOwnerOfRootsPhoto();
        if (_getBool(_rootsClaims, rootsId)) revert RootsPhotoAlreadyUsedClaim();
        _mintEdition(id);
        _rootsClaims = _setBool(_rootsClaims, rootsId, true);
        emit RootsClaim(rootsId, id, getEditionTokenId(id));
    }

    function _mintEdition(uint256 id) internal {

        uint256 editionId = getEditionTokenId(id);
        (, uint256 editionsSold, bool reservedEditionClaimed) = _decodeSalesCount(_salesCount[id]);
        uint256 editionsAvailable = reservedEditionClaimed ? _maxEditions : _maxEditions - 1;
        if (editionsSold == editionsAvailable) {
            if (reservedEditionClaimed) {
                revert SoldOut();
            } else {
                revert EditionForOriginalStillReserved();
            }
        }
        if (balanceOf[msg.sender][editionId] > 0) revert AlreadyOwnerOfEdition();
        _mint(msg.sender, editionId, 1, "");
        _addSalesCount(id, 0, 1, reservedEditionClaimed);
    }

    function _addSalesCount(
        uint256 id,
        uint256 originalsSold_,
        uint256 editionsSold_,
        bool reservedEditionClaimed_
    ) internal {

        (uint256 originalsSold, uint256 editionsSold, ) = _decodeSalesCount(_salesCount[id]);
        _salesCount[id] = _encodeSalesCount(
            originalsSold + originalsSold_,
            editionsSold + editionsSold_,
            reservedEditionClaimed_
        );
    }

    function _encodeSalesCount(
        uint256 originalsSoldCount,
        uint256 editionsSoldCount,
        bool reservedEditionClaimed
    ) internal pure returns (uint256 salesCount) {

        salesCount = salesCount | (originalsSoldCount << 0);
        salesCount = salesCount | (editionsSoldCount << 8);
        salesCount = reservedEditionClaimed ? salesCount | (1 << 16) : salesCount | (0 << 16);
    }

    function _decodeSalesCount(uint256 salesCount)
        internal
        pure
        returns (
            uint256 originalsSoldCount,
            uint256 editionsSoldCount,
            bool reservedEditionClaimed
        )
    {

        originalsSoldCount = uint8(salesCount >> 0);
        editionsSoldCount = uint8(salesCount >> 8);
        reservedEditionClaimed = uint8(salesCount >> 16) > 0;
    }


    function getOriginalTokenId(uint256 editionId) public pure returns (uint256) {

        return editionId - _editionStartId;
    }

    function getOriginalSold(uint256 id) external view returns (bool) {

        (uint256 originalsSold, , ) = _decodeSalesCount(_salesCount[id]);
        return originalsSold > 0;
    }


    function getEditionTokenId(uint256 id) public pure returns (uint256) {

        return id + _editionStartId;
    }

    function getEditionsSold(uint256 id) external view returns (uint256) {

        (, uint256 editionsSold, ) = _decodeSalesCount(_salesCount[id]);
        return editionsSold;
    }

    function getMaxEditions() external pure returns (uint256) {

        return _maxEditions;
    }

    function isEdition(uint256 id) public pure returns (bool) {

        return id > _editionStartId;
    }

    function hasEditionBeenClaimedForRootsPhoto(uint256 rootsId) external view returns (bool) {

        return _getBool(_rootsClaims, rootsId);
    }


    function burn(uint256 id) external {

        if (balanceOf[msg.sender][id] == 0) revert NotOwner();
        _burn(msg.sender, id, 1);
    }

    function uri(uint256 id) public view virtual override onlyWithMetadata returns (string memory) {

        return metadata.tokenURI(id);
    }


    function withdrawBalance() external {

        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        if (!success) revert PaymentFailed();
    }

    function withdrawToken(IERC20 tokenAddress) external {

        tokenAddress.transfer(owner, tokenAddress.balanceOf(address(this)));
    }


    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {

        receiver = _royaltyInfo.receiver;
        royaltyAmount = (salePrice * _royaltyInfo.amount) / 10_000;
    }

    function setRoyaltyInfo(address receiver, uint256 amount) external onlyOwner {

        _royaltyInfo = RoyaltyInfo(receiver, uint24(amount));
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == 0x2a55205a || super.supportsInterface(interfaceId);
    }


    function _setBool(
        uint256 packed,
        uint256 idx,
        bool value
    ) internal pure returns (uint256) {

        if (value) return packed | (uint256(1) << idx);
        return packed & ~(uint256(1) << idx);
    }

    function _getBool(uint256 packed, uint256 idx) internal pure returns (bool) {

        uint256 flag = (packed >> idx) & uint256(1);
        return flag == 1;
    }
}