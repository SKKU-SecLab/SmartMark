
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.8.0 <0.9.0;

interface ERC721 {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);


    function ownerOf(uint256 _tokenId) external view returns (address);


    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable;


    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;


    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;


    function approve(address _approved, uint256 _tokenId) external payable;


    function setApprovalForAll(address _operator, bool _approved) external;


    function getApproved(uint256 _tokenId) external view returns (address);


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}// MIT
pragma solidity >=0.8.0 <0.9.0;

contract SignedMessage {

    function getMessageHash(address _tokenContract, uint256 _tokenId) public view returns (bytes32) {

        return keccak256(abi.encodePacked(_tokenContract, _tokenId, address(this)));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function getSigner(
        address _tokenContract,
        uint256 _tokenId,
        bytes memory signature
    ) public view returns (address) {

        bytes32 messageHash = getMessageHash(_tokenContract, _tokenId);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature);
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}// MIT
pragma solidity >=0.8.0 <0.9.0;

contract Helpers {

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {

        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}// MIT
pragma solidity >=0.8.0 <0.9.0;


contract JPGRegistry is OwnableUpgradeable, SignedMessage, Helpers {

    using SafeCast for uint256;

    event CuratorAdded(address indexed curator);
    event CreateSubRegistry(address indexed curator, bytes32 name, string description);
    event UpdateSubRegistry(address indexed curator, bytes32 name, string description);
    event RemoveSubRegistry(address indexed curator, bytes32 name);
    event ReinstateSubRegistry(address indexed curator, bytes32 name);

    event TokensListed(OwnerBundle[] bundles);

    event AddNFTToSubRegistry(address indexed curator, bytes32 name, CuratedNFT token);
    event RemoveNFTFromSubRegistry(address indexed curator, bytes32 name, NFT token);

    event TokenListedForSale(NFT token, uint256 price, address curator, address owner);
    event TokenSold(NFT token, uint256 price, address buyer, address seller, address curator);

    uint16 internal constant MAX_FEE_PERC = 10000;
    uint16 internal constant CURATOR_TAKE_PER_10000 = 500;

    bool private _initialized;
    bool private _initializing;

    struct NFT {
        address tokenContract;
        uint256 tokenId;
    }

    struct CuratedNFT {
        address tokenContract;
        uint256 tokenId;
        string note;
        uint224 ordering;
    }

    struct Listing {
        bytes signedMessage;
        NFT nft;
    }

    struct OwnerBundle {
        address owner;
        Listing[] listings;
    }

    struct ListingPrice {
        uint256 artistTake;
        uint256 curatorTake;
        uint256 sellerTake;
        uint256 sellPrice;
    }

    struct SubRegistry {
        bool created;
        bool removed;
        string description;
        mapping(address => mapping(uint256 => NFTData)) nfts;
    }

    struct NFTData {
        bool active;
        uint224 ordering;
        string note;
    }

    struct SubRegistries {
        uint16 feePercentage;
        bytes32[] registryNames;
        mapping(bytes32 => SubRegistry) subRegistry;
        mapping(address => mapping(uint256 => NFTData)) nfts;
    }

    struct InternalPrice {
        address curator;
        uint96 sellerTake;
    }

    mapping(address => bool) public curators;
    mapping(address => mapping(uint256 => bool)) public mainRegistry;
    mapping(address => SubRegistries) internal subRegistries;
    mapping(address => mapping(address => mapping(uint256 => InternalPrice))) internal priceList;
    mapping(address => uint256) public balances;

    function initialize() public {

        {
            bool either = _initializing || !_initialized;
            require(either, "contract initialized");
        }

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        curators[msg.sender] = true;
        subRegistries[msg.sender].feePercentage = CURATOR_TAKE_PER_10000;
        OwnableUpgradeable.__Ownable_init();

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function bulkAddToMainRegistry(NFT[] calldata tokens) public {

        NFT[] memory listedTokens = new NFT[](tokens.length);
        Listing[] memory bundleListings = new Listing[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            mainRegistry[tokens[i].tokenContract][tokens[i].tokenId] = true;
            listedTokens[i] = tokens[i];
            bundleListings[i] = Listing({signedMessage: bytes("0"), nft: tokens[i]});
        }

        OwnerBundle[] memory bundle = new OwnerBundle[](1);
        bundle[0] = OwnerBundle({listings: bundleListings, owner: address(msg.sender)});
        emit TokensListed(bundle);
    }

    function listForSale(
        NFT calldata token,
        uint96 price,
        address curator
    ) public {

        require(price > 0, "JPGR:lFS:Price cannot be 0");
        require(mainRegistry[token.tokenContract][token.tokenId], "JPGR:lFS:Token not registered");

        require(ERC721(token.tokenContract).ownerOf(token.tokenId) == msg.sender, "JPGR:lFS:Not token owner");

        priceList[msg.sender][token.tokenContract][token.tokenId] = InternalPrice({
            sellerTake: price,
            curator: curator
        });

        emit TokenListedForSale(token, price, curator, msg.sender);
    }

    function bulkListForSale(
        NFT[] calldata tokens,
        uint96[] calldata prices,
        address curator
    ) public {

        require(tokens.length == prices.length, "JPGR:bLFS:Invalid prices array length");

        for (uint256 i = 0; i < tokens.length; i++) {
            require(prices[i] > 0, "JPGR:bLFS:Price cannot be 0");
            require(mainRegistry[tokens[i].tokenContract][tokens[i].tokenId], "JPGR:bLFS:Token not registered");
            require(
                ERC721(tokens[i].tokenContract).ownerOf(tokens[i].tokenId) == msg.sender,
                "JPGR:bLFS:Not token owner"
            );

            priceList[msg.sender][tokens[i].tokenContract][tokens[i].tokenId] = InternalPrice({
                sellerTake: prices[i],
                curator: curator
            });

            emit TokenListedForSale(tokens[i], prices[i], curator, msg.sender);
        }
    }

    function getPrice(
        bytes32 subRegistryName,
        NFT calldata token,
        address curator,
        address owner
    ) public view returns (ListingPrice memory) {

        require(mainRegistry[token.tokenContract][token.tokenId], "JPGR:gp:Token not registered");
        require(inSubRegistry(subRegistryName, token, curator), "JPGR:gp:Token not curated by curator");

        InternalPrice memory priceInternal = priceList[owner][token.tokenContract][token.tokenId];
        require(
            priceInternal.curator != address(0) && priceInternal.curator == curator,
            "JPGR:gp:Curator not approved seller"
        );

        uint256 sellerTake = priceInternal.sellerTake;

        require(sellerTake > 0, "JPGR:bfp:Owner price 0");

        uint256 curatorTake = calculateCuratorTake(sellerTake, curator);
        uint256 artistTake = sellerTake / 10;
        uint256 totalPrice = sellerTake + curatorTake + artistTake;

        return
            ListingPrice({
                curatorTake: curatorTake,
                sellerTake: sellerTake,
                artistTake: artistTake,
                sellPrice: totalPrice
            });
    }

    function buyFixedPrice(
        bytes32 subRegistryName,
        NFT calldata token,
        address curator,
        address owner
    ) public payable {

        ListingPrice memory price = getPrice(subRegistryName, token, curator, owner);
        require(msg.value == price.sellPrice, "JPGR:bfp:Price too low");

        address jpgOwner = this.owner();

        balances[owner] += price.sellerTake;
        balances[curator] += price.curatorTake;
        balances[jpgOwner] += price.artistTake;
        delete priceList[owner][token.tokenContract][token.tokenId];

        ERC721(token.tokenContract).transferFrom(owner, msg.sender, token.tokenId);

        emit TokenSold(token, price.sellPrice, msg.sender, owner, curator);
    }

    function withdrawBalance() public {

        uint256 balance = balances[msg.sender];
        if (balance > 0) {
            balances[msg.sender] = 0;
            (bool success, ) = msg.sender.call{value: balance}("");
            require(success, "JPGR:wb:Transfer failed");
        }
    }

    function calculateCuratorTake(uint256 price, address curator) internal view returns (uint256) {

        return (price * subRegistries[curator].feePercentage) / MAX_FEE_PERC;
    }

    function removeFromMainRegistry(Listing calldata listing) public {

        try ERC721(listing.nft.tokenContract).ownerOf(listing.nft.tokenId) returns (address owner) {
            if (owner == msg.sender) {
                _removeFromMainRegistry(NFT({tokenContract: listing.nft.tokenContract, tokenId: listing.nft.tokenId}));
            }
        } catch {} // solhint-disable-line no-empty-blocks
    }

    function createSubregistry(
        bytes32 subRegistryName,
        string calldata subRegistryDescription,
        NFT[] calldata tokens,
        string[] calldata notes,
        uint224[] calldata ordering
    ) public {
        require(curators[msg.sender], "JPGR:ats:Only allowed curators");
        require(!subRegistries[msg.sender].subRegistry[subRegistryName].created, "JPGR:ats:Subregistry exists");
        require(tokens.length == notes.length && notes.length == ordering.length, "JPGR:ats:Len parity");

        subRegistries[msg.sender].subRegistry[subRegistryName].created = true;
        subRegistries[msg.sender].registryNames.push(subRegistryName);
        subRegistries[msg.sender].subRegistry[subRegistryName].description = subRegistryDescription;
        emit CreateSubRegistry(msg.sender, subRegistryName, subRegistryDescription);

        for (uint256 i = 0; i < tokens.length; i++) {
            mainRegistry[tokens[i].tokenContract][tokens[i].tokenId] = true;

            NFTData memory nftData = NFTData({active: true, ordering: ordering[i], note: notes[i]});
            subRegistries[msg.sender].subRegistry[subRegistryName].nfts[tokens[i].tokenContract][
                tokens[i].tokenId
            ] = nftData;

            emit AddNFTToSubRegistry(
                msg.sender,
                subRegistryName,
                CuratedNFT({
                    tokenContract: tokens[i].tokenContract,
                    tokenId: tokens[i].tokenId,
                    note: notes[i],
                    ordering: ordering[i]
                })
            );
        }
    }

    function updateSubregistry(
        bytes32 subRegistryName,
        string calldata subRegistryDescription,
        NFT[] calldata tokensToUpsert,
        NFT[] calldata tokensToRemove,
        string[] calldata notes,
        uint224[] calldata ordering
    ) public {
        require(subRegistries[msg.sender].subRegistry[subRegistryName].created, "JPGR:ats:Permission denied");
        require(
            tokensToUpsert.length == notes.length && notes.length == ordering.length,
            "JPGR:ats:Mismatched array length"
        );

        subRegistries[msg.sender].subRegistry[subRegistryName].description = subRegistryDescription;

        if (tokensToRemove.length > 0) {
            for (uint256 i = 0; i < tokensToRemove.length; i++) {
                delete subRegistries[msg.sender].subRegistry[subRegistryName].nfts[tokensToRemove[i].tokenContract][
                    tokensToRemove[i].tokenId
                ];
                emit RemoveNFTFromSubRegistry(msg.sender, subRegistryName, tokensToRemove[i]);
            }
        }

        if (tokensToUpsert.length > 0) {
            for (uint256 i = 0; i < tokensToUpsert.length; i++) {
                mainRegistry[tokensToUpsert[i].tokenContract][tokensToUpsert[i].tokenId] = true;

                NFTData memory nftData = NFTData({active: true, ordering: ordering[i], note: notes[i]});
                subRegistries[msg.sender].subRegistry[subRegistryName].nfts[tokensToUpsert[i].tokenContract][
                    tokensToUpsert[i].tokenId
                ] = nftData;

                emit AddNFTToSubRegistry(
                    msg.sender,
                    subRegistryName,
                    CuratedNFT({
                        tokenContract: tokensToUpsert[i].tokenContract,
                        tokenId: tokensToUpsert[i].tokenId,
                        note: notes[i],
                        ordering: ordering[i]
                    })
                );
            }
        }
        emit UpdateSubRegistry(msg.sender, subRegistryName, subRegistryDescription);
    }

    function addToSubregistry(
        bytes32 subRegistryName,
        NFT[] calldata tokens,
        string[] calldata notes,
        uint224[] calldata ordering
    ) public {
        require(subRegistries[msg.sender].subRegistry[subRegistryName].created, "JPGR:ats:Permission denied");
        require(tokens.length == notes.length && notes.length == ordering.length, "JPGR:ats:Mismatched array length");

        for (uint256 i = 0; i < tokens.length; i++) {
            mainRegistry[tokens[i].tokenContract][tokens[i].tokenId] = true;
            NFTData memory nftData = NFTData({active: true, ordering: ordering[i], note: notes[i]});
            subRegistries[msg.sender].subRegistry[subRegistryName].nfts[tokens[i].tokenContract][
                tokens[i].tokenId
            ] = nftData;

            emit AddNFTToSubRegistry(
                msg.sender,
                subRegistryName,
                CuratedNFT({
                    tokenContract: tokens[i].tokenContract,
                    tokenId: tokens[i].tokenId,
                    note: notes[i],
                    ordering: ordering[i]
                })
            );
        }
    }

    function removeSubRegistry(bytes32 subRegistryName) public {
        require(curators[msg.sender], "JPGR:ats:Only allowed curators");
        subRegistries[msg.sender].subRegistry[subRegistryName].removed = true;
        emit RemoveSubRegistry(msg.sender, subRegistryName);
    }

    function reinstateSubRegistry(bytes32 subRegistryName) public {
        require(curators[msg.sender], "JPGR:ats:Only allowed curators");
        subRegistries[msg.sender].subRegistry[subRegistryName].removed = false;
        emit ReinstateSubRegistry(msg.sender, subRegistryName);
    }

    function getSubRegistries(address curator) public view returns (string[] memory) {
        bytes32[] memory registryNames = subRegistries[curator].registryNames;
        uint256 ctr;
        for (uint256 i = 0; i < registryNames.length; i++) {
            if (subRegistries[curator].subRegistry[registryNames[i]].removed) {
                continue;
            }
            ctr += 1;
        }
        string[] memory registryStrings = new string[](ctr);
        ctr = 0;
        for (uint256 i = 0; i < registryNames.length; i++) {
            if (subRegistries[curator].subRegistry[registryNames[i]].removed) {
                continue;
            }
            registryStrings[ctr] = Helpers.bytes32ToString(registryNames[i]);
            ctr += 1;
        }
        return registryStrings;
    }

    function removeFromSubregistry(bytes32 subRegistryName, NFT calldata token) public {
        require(curators[msg.sender], "JPGR:rfs:Only allowed curators");
        subRegistries[msg.sender].subRegistry[subRegistryName].nfts[token.tokenContract][token.tokenId].active = false;
        emit RemoveNFTFromSubRegistry(msg.sender, subRegistryName, token);
    }

    function inSubRegistry(
        bytes32 subRegistryName,
        NFT calldata nft,
        address curator
    ) public view returns (bool) {
        return
            mainRegistry[nft.tokenContract][nft.tokenId] &&
            !subRegistries[curator].subRegistry[subRegistryName].removed &&
            subRegistries[curator].subRegistry[subRegistryName].nfts[nft.tokenContract][nft.tokenId].active;
    }

    function allowCurator(address curator) public onlyOwner {
        curators[curator] = true;
        subRegistries[curator].feePercentage = CURATOR_TAKE_PER_10000;
        emit CuratorAdded(curator);
    }

    function setCuratorFee(uint16 feePercentage) public {
        require(curators[msg.sender], "JPGR:scf:Curator only");
        require(feePercentage <= MAX_FEE_PERC, "JPGR:scf:Fee exceeds MAX_FEE");
        subRegistries[msg.sender].feePercentage = feePercentage;
    }

    function adminBulkAddToMainRegistry(OwnerBundle[] memory ownerBundles) public onlyOwner {
        for (uint256 j = 0; j < ownerBundles.length; j++) {
            Listing[] memory listings = ownerBundles[j].listings;

            for (uint256 i = 0; i < listings.length; i++) {
                mainRegistry[listings[i].nft.tokenContract][listings[i].nft.tokenId] = true;
            }
        }

        emit TokensListed(ownerBundles);
    }

    function bulkRemoveFromMainRegistry(NFT[] calldata tokens) public onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            _removeFromMainRegistry(tokens[i]);
        }
    }

    function _removeFromMainRegistry(NFT memory token) internal {
        mainRegistry[token.tokenContract][token.tokenId] = false;
    }
}