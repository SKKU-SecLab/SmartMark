
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

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
}// MIT License
pragma solidity 0.8.12;



contract UnitedMarket is ReentrancyGuard, Pausable, Ownable {

    mapping(address => bool) addressToSupportedContracts;
    mapping(uint256 => Collection) idToCollection;
    uint256 nbCollections;

    struct Collection {
        uint256 id;
        string name;
        bool activated;
        string openseaCollectionName;
        address contractAddress;
        address contractOwner;
        uint16 royalties; // 4.50% -> 450 -> OS allows 2 digits after comma
        string imageUrl;
        string twitterId;
    }

    struct Offer {
        bool isForSale;
        uint256 collectionId;
        uint256 tokenId;
        address seller;
        uint256 minValue;
        address onlySellTo;
    }

    struct Bid {
        bool hasBid;
        uint256 collectionId;
        uint256 tokenId;
        address bidder;
        uint256 value;
    }

    mapping(string => Offer) public tokenOfferedForSale;
    mapping(string => Bid) public tokenBids;
    mapping(address => uint256) public pendingWithdrawals;

    event TokenOffered(
        uint256 indexed collectionId,
        uint256 indexed tokenId,
        uint256 minValue,
        address indexed toAddress
    );
    event TokenBidEntered(
        uint256 indexed collectionId,
        uint256 indexed tokenId,
        uint256 value,
        address indexed fromAddress
    );
    event TokenBidWithdrawn(
        uint256 indexed collectionId,
        uint256 indexed tokenId,
        uint256 value,
        address indexed fromAddress
    );
    event TokenBought(
        uint256 indexed collectionId,
        uint256 indexed tokenId,
        uint256 value,
        address indexed fromAddress,
        address toAddress
    );
    event TokenNoLongerForSale(
        uint256 indexed collectionId,
        uint256 indexed tokenId
    );

    constructor() {
        nbCollections = 0;
    }

    function pause() public whenNotPaused onlyOwner {

        _pause();
    }

    function unpause() public whenPaused onlyOwner {

        _unpause();
    }

    function getCollections() public view returns (Collection[] memory) {

        Collection[] memory arr = new Collection[](nbCollections);
        for (uint256 i = 1; i <= nbCollections; i++) {
            Collection storage c = idToCollection[i];
            arr[i - 1] = c;
        }
        return arr;
    }

    function updateColection(
        uint256 collectionId,
        string memory name,
        string memory openseaCollectionName,
        address newTokensAddress,
        uint16 royalties,
        string memory imageUrl,
        string memory twitterId
    ) public onlyOwner {

        address contractOwner = Ownable(newTokensAddress).owner();
        idToCollection[collectionId] = Collection(
            collectionId,
            name,
            true,
            openseaCollectionName,
            newTokensAddress,
            contractOwner,
            royalties,
            imageUrl,
            twitterId
        );
    }

    function toggleAtivatedCollection(uint256 collectionId) public onlyOwner {

        idToCollection[collectionId].activated = !idToCollection[collectionId]
            .activated;
    }

    function addCollection(
        string memory name,
        string memory openseaCollectionName,
        address newTokensAddress,
        uint16 royalties,
        string memory imageUrl,
        string memory twitterId
    ) public onlyOwner {

        require(
            !addressToSupportedContracts[newTokensAddress],
            "Contract is already in the list."
        );
        nbCollections++;
        address contractOwner = Ownable(newTokensAddress).owner();
        idToCollection[nbCollections] = Collection(
            nbCollections,
            name,
            true,
            openseaCollectionName,
            newTokensAddress,
            contractOwner,
            royalties,
            imageUrl,
            twitterId
        );
        addressToSupportedContracts[newTokensAddress] = true;
    }

    function offerTokenForSale(
        uint256 collectionId,
        uint256 tokenId,
        uint256 minSalePriceInWei
    ) public whenNotPaused nonReentrant {

        require(
            idToCollection[collectionId].activated,
            "This collection is not supported."
        );
        require(minSalePriceInWei > 0, "Cannot sell with negative price");
        require(
            tokenId <
                IERC721Enumerable(idToCollection[collectionId].contractAddress)
                    .totalSupply(),
            "token index not valid"
        );
        require(
            IERC721(idToCollection[collectionId].contractAddress).ownerOf(
                tokenId
            ) == msg.sender,
            "you are not the owner of this token"
        );
        tokenOfferedForSale[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ] = Offer(
            true,
            collectionId,
            tokenId,
            msg.sender,
            minSalePriceInWei,
            address(0x0)
        );
        emit TokenOffered(
            collectionId,
            tokenId,
            minSalePriceInWei,
            address(0x0)
        );
    }

    function tokenNoLongerForSale(uint256 collectionId, uint256 tokenId)
        public
        nonReentrant
    {

        require(
            tokenId <=
                IERC721Enumerable(idToCollection[collectionId].contractAddress)
                    .totalSupply(),
            "token index not valid"
        );
        require(
            IERC721(idToCollection[collectionId].contractAddress).ownerOf(
                tokenId
            ) == msg.sender,
            "you are not the owner of this token"
        );
        tokenOfferedForSale[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ] = Offer(false, collectionId, tokenId, msg.sender, 0, address(0x0));
        emit TokenNoLongerForSale(collectionId, tokenId);
    }

    function offerTokenForSaleToAddress(
        uint256 collectionId,
        uint256 tokenId,
        uint256 minSalePriceInWei,
        address toAddress
    ) public whenNotPaused nonReentrant {

        require(
            tokenId <=
                IERC721Enumerable(idToCollection[collectionId].contractAddress)
                    .totalSupply(),
            "token index not valid"
        );
        require(
            IERC721(idToCollection[collectionId].contractAddress).ownerOf(
                tokenId
            ) == msg.sender,
            "you are not the owner of this token"
        );
        tokenOfferedForSale[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ] = Offer(
            true,
            collectionId,
            tokenId,
            msg.sender,
            minSalePriceInWei,
            toAddress
        );
        emit TokenOffered(collectionId, tokenId, minSalePriceInWei, toAddress);
    }

    function buyToken(uint256 collectionId, uint256 tokenId)
        public
        payable
        whenNotPaused
        nonReentrant
    {

        require(
            tokenId <=
                IERC721Enumerable(idToCollection[collectionId].contractAddress)
                    .totalSupply(),
            "token index not valid"
        );
        Offer memory offer = tokenOfferedForSale[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ];
        require(offer.isForSale, "token is not for sale"); // token not actually for sale
        require(
            offer.onlySellTo == address(0x0) || offer.onlySellTo == msg.sender,
            "Not for sale for you... sorry"
        );

        uint256 royaltiesPrice = 0;
        if (idToCollection[collectionId].royalties > 0) {
            royaltiesPrice =
                (offer.minValue * idToCollection[collectionId].royalties) /
                10000;
        }

        require(
            msg.value == offer.minValue + royaltiesPrice,
            "not enough ether"
        ); // Didn't send enough ETH
        address seller = offer.seller;
        require(seller != msg.sender, "seller == msg.sender");
        require(
            seller ==
                IERC721(idToCollection[collectionId].contractAddress).ownerOf(
                    tokenId
                ),
            "seller no longer owner of token"
        ); // Seller no longer owner of token

        tokenOfferedForSale[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ] = Offer(false, collectionId, tokenId, msg.sender, 0, address(0x0));

        IERC721(idToCollection[collectionId].contractAddress).safeTransferFrom(
            seller,
            msg.sender,
            tokenId
        );
        pendingWithdrawals[seller] += offer.minValue;
        address owner = Ownable(idToCollection[collectionId].contractAddress)
            .owner();
        pendingWithdrawals[owner] += royaltiesPrice;
        emit TokenBought(collectionId, tokenId, msg.value, seller, msg.sender);

        Bid memory bid = tokenBids[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ];
        if (bid.bidder == msg.sender) {
            pendingWithdrawals[msg.sender] += bid.value;
            tokenBids[
                append(uint2str(collectionId), "_", uint2str(tokenId))
            ] = Bid(false, collectionId, tokenId, address(0x0), 0);
        }
    }

    function withdraw() public nonReentrant {

        require(pendingWithdrawals[msg.sender] > 0, "No amount to be withdrawn ...");
        uint256 amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdrawTo(address from, address to)
        public
        nonReentrant
        onlyOwner
    {

        require(pendingWithdrawals[from] > 0, "No amount to be withdrawn ...");
        uint256 amount = pendingWithdrawals[from];
        pendingWithdrawals[from] = 0;
        payable(to).transfer(amount);
    }

    function enterBidForToken(uint256 collectionId, uint256 tokenId)
        public
        payable
        whenNotPaused
        nonReentrant
    {

        if (
            tokenId >=
            IERC721Enumerable(idToCollection[collectionId].contractAddress)
                .totalSupply()
        ) revert("token index not valid");
        if (
            IERC721(idToCollection[collectionId].contractAddress).ownerOf(
                tokenId
            ) == msg.sender
        ) revert("you already own this token");
        if (msg.value == 0) revert("cannot enter bid of zero");
        Bid memory existing = tokenBids[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ];
        if (msg.value <= existing.value) revert("your bid is too low");
        if (existing.value > 0) {
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        tokenBids[append(uint2str(collectionId), "_", uint2str(tokenId))] = Bid(
            true,
            collectionId,
            tokenId,
            msg.sender,
            msg.value
        );
        emit TokenBidEntered(collectionId, tokenId, msg.value, msg.sender);
    }

    function acceptBidForToken(
        uint256 collectionId,
        uint256 tokenId,
        uint256 minPrice
    ) public whenNotPaused nonReentrant {

        if (
            tokenId >=
            IERC721Enumerable(idToCollection[collectionId].contractAddress)
                .totalSupply()
        ) revert("token index not valid");
        if (
            IERC721(idToCollection[collectionId].contractAddress).ownerOf(
                tokenId
            ) != msg.sender
        ) revert("you do not own this token");
        address seller = msg.sender;
        Bid memory bid = tokenBids[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ];
        if (bid.value == 0) revert("cannot enter bid of zero");
        if (bid.value < minPrice) revert("your bid is too low");

        address bidder = bid.bidder;
        if (seller == bidder) revert("you already own this token");
        tokenOfferedForSale[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ] = Offer(false, collectionId, tokenId, bidder, 0, address(0x0));
        uint256 amount = bid.value;
        tokenBids[append(uint2str(collectionId), "_", uint2str(tokenId))] = Bid(
            false,
            collectionId,
            tokenId,
            address(0x0),
            0
        );
        IERC721(idToCollection[collectionId].contractAddress).safeTransferFrom(
            msg.sender,
            bidder,
            tokenId
        );
        pendingWithdrawals[seller] += amount;
        emit TokenBought(collectionId, tokenId, bid.value, seller, bidder);
    }

    function withdrawBidForToken(uint256 collectionId, uint256 tokenId)
        public
        nonReentrant
    {

        if (
            tokenId >=
            IERC721Enumerable(idToCollection[collectionId].contractAddress)
                .totalSupply()
        ) revert("token index not valid");
        Bid memory bid = tokenBids[
            append(uint2str(collectionId), "_", uint2str(tokenId))
        ];
        if (bid.bidder != msg.sender)
            revert("the bidder is not message sender");
        emit TokenBidWithdrawn(collectionId, tokenId, bid.value, msg.sender);
        uint256 amount = bid.value;
        tokenBids[append(uint2str(collectionId), "_", uint2str(tokenId))] = Bid(
            false,
            collectionId,
            tokenId,
            address(0x0),
            0
        );
        payable(msg.sender).transfer(amount);
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function append(
        string memory a,
        string memory b,
        string memory c
    ) internal pure returns (string memory) {

        return string(abi.encodePacked(a, b, c));
    }
}