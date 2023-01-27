
pragma solidity 0.8.12;

contract OpenSeaOwnableDelegateProxy {}


contract OpenSeaProxyRegistry {

    mapping(address => OpenSeaOwnableDelegateProxy) public proxies;
}// MIT

pragma solidity 0.8.12;


interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}// MIT

pragma solidity 0.8.12;


enum UriType {
    ARWEAVE, // 0
    IPFS, // 1
    HTTP // 2
}// MIT

pragma solidity 0.8.12;



struct CollectionData {
    bytes32 name;
    bytes32 name2;
    bytes32 symbol;
    address royalties;
    uint96 bps;
}// MIT

pragma solidity 0.8.12;


struct Verification {
    bytes32 r;
    bytes32 s;
    uint8 v;
}// MIT

pragma solidity 0.8.12;



struct TokenData {
    bytes32 payloadHash;
    Verification payloadSignature;
    address creator;
    bytes32 arweave;
    bytes11 arweave2;
    bytes32 ipfs;
    bytes14 ipfs2;
}// MIT

pragma solidity 0.8.12;



interface ICxipERC721 {

    function arweaveURI(uint256 tokenId) external view returns (string memory);


    function contractURI() external view returns (string memory);


    function creator(uint256 tokenId) external view returns (address);


    function httpURI(uint256 tokenId) external view returns (string memory);


    function ipfsURI(uint256 tokenId) external view returns (string memory);


    function name() external view returns (string memory);


    function payloadHash(uint256 tokenId) external view returns (bytes32);


    function payloadSignature(uint256 tokenId) external view returns (Verification memory);


    function payloadSigner(uint256 tokenId) external view returns (address);


    function supportsInterface(bytes4 interfaceId) external view returns (bool);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);


    function tokensOfOwner(address wallet) external view returns (uint256[] memory);


    function verifySHA256(bytes32 hash, bytes calldata payload) external pure returns (bool);


    function approve(address to, uint256 tokenId) external;


    function burn(uint256 tokenId) external;


    function init(address newOwner, CollectionData calldata collectionData) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external payable;


    function setApprovalForAll(address to, bool approved) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external payable;


    function cxipMint(uint256 id, TokenData calldata tokenData) external returns (uint256);


    function setApprovalForAll(
        address from,
        address to,
        bool approved
    ) external;


    function setName(bytes32 newName, bytes32 newName2) external;


    function setSymbol(bytes32 newSymbol) external;


    function transferOwnership(address newOwner) external;


    function balanceOf(address wallet) external view returns (uint256);


    function baseURI() external view returns (string memory);


    function getApproved(uint256 tokenId) external view returns (address);


    function getIdentity() external view returns (address);


    function isApprovedForAll(address wallet, address operator) external view returns (bool);


    function isOwner() external view returns (bool);


    function owner() external view returns (address);


    function ownerOf(uint256 tokenId) external view returns (address);


    function tokenByIndex(uint256 index) external view returns (uint256);


    function tokenOfOwnerByIndex(address wallet, uint256 index) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4);

}// MIT

pragma solidity 0.8.12;


enum InterfaceType {
    NULL, // 0
    ERC20, // 1
    ERC721, // 2
    ERC1155 // 3
}// MIT

pragma solidity 0.8.12;



struct Token {
    address collection;
    uint256 tokenId;
    InterfaceType tokenType;
    address creator;
}// MIT

pragma solidity 0.8.12;



interface ICxipIdentity {

    function addSignedWallet(
        address newWallet,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function addWallet(address newWallet) external;


    function connectWallet() external;


    function createERC721Token(
        address collection,
        uint256 id,
        TokenData calldata tokenData,
        Verification calldata verification
    ) external returns (uint256);


    function createERC721Collection(
        bytes32 saltHash,
        address collectionCreator,
        Verification calldata verification,
        CollectionData calldata collectionData
    ) external returns (address);


    function createCustomERC721Collection(
        bytes32 saltHash,
        address collectionCreator,
        Verification calldata verification,
        CollectionData calldata collectionData,
        bytes32 slot,
        bytes memory bytecode
    ) external returns (address);


    function init(address wallet, address secondaryWallet) external;


    function getAuthorizer(address wallet) external view returns (address);


    function getCollectionById(uint256 index) external view returns (address);


    function getCollectionType(address collection) external view returns (InterfaceType);


    function getWallets() external view returns (address[] memory);


    function isCollectionCertified(address collection) external view returns (bool);


    function isCollectionRegistered(address collection) external view returns (bool);


    function isNew() external view returns (bool);


    function isOwner() external view returns (bool);


    function isTokenCertified(address collection, uint256 tokenId) external view returns (bool);


    function isTokenRegistered(address collection, uint256 tokenId) external view returns (bool);


    function isWalletRegistered(address wallet) external view returns (bool);


    function listCollections(uint256 offset, uint256 length)
        external
        view
        returns (address[] memory);


    function nextNonce(address wallet) external view returns (uint256);


    function totalCollections() external view returns (uint256);


    function isCollectionOpen(address collection) external pure returns (bool);

}// MIT

pragma solidity 0.8.12;


interface ICxipProvenance {

    function createIdentity(
        bytes32 saltHash,
        address wallet,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256, address);


    function createIdentityBatch(
        bytes32 saltHash,
        address[] memory wallets,
        uint8[] memory V,
        bytes32[] memory RS
    ) external returns (uint256, address);


    function getIdentity() external view returns (address);


    function getWalletIdentity(address wallet) external view returns (address);


    function informAboutNewWallet(address newWallet) external;


    function isIdentityValid(address identity) external view returns (bool);


    function nextNonce(address wallet) external view returns (uint256);

}// MIT

pragma solidity 0.8.12;


interface ICxipRegistry {

    function getAsset() external view returns (address);


    function getAssetSigner() external view returns (address);


    function getAssetSource() external view returns (address);


    function getCopyright() external view returns (address);


    function getCopyrightSource() external view returns (address);


    function getCustomSource(bytes32 name) external view returns (address);


    function getCustomSourceFromString(string memory name) external view returns (address);


    function getERC1155CollectionSource() external view returns (address);


    function getERC721CollectionSource() external view returns (address);


    function getIdentitySource() external view returns (address);


    function getPA1D() external view returns (address);


    function getPA1DSource() external view returns (address);


    function getProvenance() external view returns (address);


    function getProvenanceSource() external view returns (address);


    function owner() external view returns (address);


    function setAsset(address proxy) external;


    function setAssetSigner(address source) external;


    function setAssetSource(address source) external;


    function setCopyright(address proxy) external;


    function setCopyrightSource(address source) external;


    function setCustomSource(string memory name, address source) external;


    function setERC1155CollectionSource(address source) external;


    function setERC721CollectionSource(address source) external;


    function setIdentitySource(address source) external;


    function setPA1D(address proxy) external;


    function setPA1DSource(address source) external;


    function setProvenance(address proxy) external;


    function setProvenanceSource(address source) external;

}// MIT

pragma solidity 0.8.12;


library Zora {

    struct Decimal {
        uint256 value;
    }

    struct BidShares {
        Decimal prevOwner;
        Decimal creator;
        Decimal owner;
    }
}// MIT

pragma solidity 0.8.12;



interface IPA1D {

    function init(
        uint256 tokenId,
        address payable receiver,
        uint256 bp
    ) external;


    function configurePayouts(address payable[] memory addresses, uint256[] memory bps) external;


    function getPayoutInfo()
        external
        view
        returns (address payable[] memory addresses, uint256[] memory bps);


    function getEthPayout() external;


    function getTokenPayout(address tokenAddress) external;


    function getTokenPayoutByName(string memory tokenName) external;


    function getTokensPayout(address[] memory tokenAddresses) external;


    function getTokensPayoutByName(string[] memory tokenNames) external;


    function supportsInterface(bytes4 interfaceId) external pure returns (bool);


    function setRoyalties(
        uint256 tokenId,
        address payable receiver,
        uint256 bp
    ) external;


    function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address, uint256);


    function getFeeBps(uint256 tokenId) external view returns (uint256[] memory);


    function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory);


    function getRoyalties(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);


    function getFees(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);


    function tokenCreator(address contractAddress, uint256 tokenId) external view returns (address);


    function calculateRoyaltyFee(
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) external view returns (uint256);


    function marketContract() external view returns (address);


    function tokenCreators(uint256 tokenId) external view returns (address);


    function bidSharesForToken(uint256 tokenId)
        external
        view
        returns (Zora.BidShares memory bidShares);


    function getStorageSlot(string calldata slot) external pure returns (bytes32);


    function getTokenAddress(string memory tokenName) external view returns (address);

}// MIT

pragma solidity 0.8.12;


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 &&
            codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
    }

    function isZero(address account) internal pure returns (bool) {

        return (account == address(0));
    }
}// MIT

pragma solidity 0.8.12;


library Bytes {

    function getBoolean(uint192 _packedBools, uint192 _boolNumber) internal pure returns (bool) {

        uint192 flag = (_packedBools >> _boolNumber) & uint192(1);
        return (flag == 1 ? true : false);
    }

    function setBoolean(
        uint192 _packedBools,
        uint192 _boolNumber,
        bool _value
    ) internal pure returns (uint192) {

        if (_value) {
            return _packedBools | (uint192(1) << _boolNumber);
        } else {
            return _packedBools & ~(uint192(1) << _boolNumber);
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");
        bytes memory tempBytes;
        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)
                let lengthmod := and(_length, 31)
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)
                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }
                mstore(tempBytes, _length)
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(tempBytes, 0)
                mstore(0x40, add(tempBytes, 0x20))
            }
        }
        return tempBytes;
    }

    function trim(bytes32 source) internal pure returns (bytes memory) {

        uint256 temp = uint256(source);
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return slice(abi.encodePacked(source), 32 - length, length);
    }
}// MIT

pragma solidity 0.8.12;


library Strings {

    function toHexString(address account) internal pure returns (string memory) {

        return toHexString(uint256(uint160(account)));
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
            buffer[i] = bytes16("0123456789abcdef")[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity 0.8.12;



contract DanielArshamErodingAndReformingCars {

    CollectionData private _collectionData;

    uint256 private _currentTokenId;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    mapping(uint256 => address) private _tokenOwner;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => uint256) private _ownedTokensCount;

    mapping(address => uint256[]) private _ownedTokens;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => TokenData) private _tokenData;

    address private _admin;

    address private _owner;

    uint256 private _totalTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed wallet, address indexed operator, uint256 indexed tokenId);

    event ApprovalForAll(address indexed wallet, address indexed operator, bool approved);

    constructor() {}

    modifier onlyOwner() {

        require(isOwner(), "CXIP: caller not an owner");
        _;
    }

    receive() external payable {}

    fallback() external {
        _royaltiesFallback();
    }

    function getIntervalConfig() public view returns (uint256[4] memory intervals) {

        uint64 unpacked;
        assembly {
            unpacked := sload(
                0xf8883f7674e7099512a3eb674d514a03c06b3984f509bd9a7b34673ea2a79349
            )
        }
        intervals[0] = uint256(uint16(unpacked >> 48));
        intervals[1] = uint256(uint16(unpacked >> 32));
        intervals[2] = uint256(uint16(unpacked >> 16));
        intervals[3] = uint256(uint16(unpacked));
    }

    function setIntervalConfig(uint256[4] memory intervals) external onlyOwner {

        uint256 packed = uint256((intervals[0] << 48) | (intervals[1] << 32) | (intervals[2] << 16) | intervals[3]);
        assembly {
            sstore(
                0xf8883f7674e7099512a3eb674d514a03c06b3984f509bd9a7b34673ea2a79349,
                packed
            )
        }
    }

    function _calculateRotation(uint256 tokenId) internal view returns (uint256 rotationIndex) {

        uint256 configIndex = (tokenId / getTokenSeparator());
        uint256 interval = getIntervalConfig()[configIndex - 1];
        uint256 remainder = ((block.timestamp - getStartTimestamp()) / interval) % 2;
        rotationIndex = (configIndex * 2) + remainder;
    }

    function arweaveURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = _calculateRotation(tokenId);
        return string(abi.encodePacked("https://arweave.net/", _tokenData[index].arweave, _tokenData[index].arweave2));
    }

    function contractURI() external view returns (string memory) {

        return string(abi.encodePacked("https://nft.cxip.io/", Strings.toHexString(address(this)), "/"));
    }

    function creator(uint256 tokenId) external view returns (address) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = _calculateRotation(tokenId);
        return _tokenData[index].creator;
    }

    function httpURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        return string(abi.encodePacked(baseURI(), "/", Strings.toHexString(tokenId)));
    }

    function ipfsURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = _calculateRotation(tokenId);
        return string(abi.encodePacked("https://ipfs.io/ipfs/", _tokenData[index].ipfs, _tokenData[index].ipfs2));
    }

    function name() external view returns (string memory) {

        return string(abi.encodePacked(Bytes.trim(_collectionData.name), Bytes.trim(_collectionData.name2)));
    }

    function payloadHash(uint256 tokenId) external view returns (bytes32) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = _calculateRotation(tokenId);
        return _tokenData[index].payloadHash;
    }

    function payloadSignature(uint256 tokenId) external view returns (Verification memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = _calculateRotation(tokenId);
        return _tokenData[index].payloadSignature;
    }

    function payloadSigner(uint256 tokenId) external view returns (address) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = _calculateRotation(tokenId);
        return _tokenData[index].creator;
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        if (
            interfaceId == 0x01ffc9a7 || // ERC165
            interfaceId == 0x80ac58cd || // ERC721
            interfaceId == 0x780e9d63 || // ERC721Enumerable
            interfaceId == 0x5b5e139f || // ERC721Metadata
            interfaceId == 0x150b7a02 || // ERC721TokenReceiver
            interfaceId == 0xe8a3d485 || // contractURI()
            IPA1D(getRegistry().getPA1D()).supportsInterface(interfaceId)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function symbol() external view returns (string memory) {

        return string(Bytes.trim(_collectionData.symbol));
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = _calculateRotation(tokenId);
        return string(abi.encodePacked("https://arweave.net/", _tokenData[index].arweave, _tokenData[index].arweave2));
    }

    function tokensOfOwner(address wallet) external view returns (uint256[] memory) {

        return _ownedTokens[wallet];
    }

    function approve(address to, uint256 tokenId) public {

        address tokenOwner = _tokenOwner[tokenId];
        require(to != tokenOwner, "CXIP: can't approve self");
        require(_isApproved(msg.sender, tokenId), "CXIP: not approved sender");
        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function burn(uint256 tokenId) public {

        require(_isApproved(msg.sender, tokenId), "CXIP: not approved sender");
        address wallet = _tokenOwner[tokenId];
        _clearApproval(tokenId);
        _tokenOwner[tokenId] = address(0);
        emit Transfer(wallet, address(0), tokenId);
        _removeTokenFromOwnerEnumeration(wallet, tokenId);
    }

    function init(address newOwner, CollectionData calldata collectionData) public {

        require(Address.isZero(_admin), "CXIP: already initialized");
        _admin = msg.sender;
        _owner = address(this);
        _collectionData = collectionData;
        IPA1D(address(this)).init(0, payable(collectionData.royalties), collectionData.bps);
        _owner = newOwner;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable {

        require(_isApproved(msg.sender, tokenId), "CXIP: not approved sender");
        _transferFrom(from, to, tokenId);
        if (Address.isContract(to)) {
            require(
                IERC165(to).supportsInterface(0x01ffc9a7) &&
                    IERC165(to).supportsInterface(0x150b7a02) &&
                    ICxipERC721(to).onERC721Received(address(this), from, tokenId, data) == 0x150b7a02,
                "CXIP: onERC721Received fail"
            );
        }
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, "CXIP: can't approve self");
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable {

        transferFrom(from, to, tokenId, "");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory /*_data*/
    ) public payable {

        require(_isApproved(msg.sender, tokenId), "CXIP: not approved sender");
        _transferFrom(from, to, tokenId);
    }

    function batchMint(
        address creatorWallet,
        uint256 startId,
        uint256 length,
        address recipient
    ) public onlyOwner {

        require(!getMintingClosed(), "CXIP: minting is now closed");
        require(_allTokens.length + length <= getTokenLimit(), "CXIP: over token limit");
        require(isIdentityWallet(creatorWallet), "CXIP: creator not in identity");
        bool hasRecipient = !Address.isZero(recipient);
        uint256 tokenId;
        for (uint256 i = 0; i < length; i++) {
            tokenId = (startId + i);
            if (hasRecipient) {
                require(!_exists(tokenId), "CXIP: token already exists");
                emit Transfer(address(0), creatorWallet, tokenId);
                emit Transfer(creatorWallet, recipient, tokenId);
                _tokenOwner[tokenId] = recipient;
                _addTokenToOwnerEnumeration(recipient, tokenId);
            } else {
                _mint(creatorWallet, tokenId);
            }
        }
        if (_allTokens.length == getTokenLimit()) {
            setMintingClosed();
        }
    }

    function getStartTimestamp() public view returns (uint256 _timestamp) {

        assembly {
            _timestamp := sload(
                0xf2aaccfcfa4e77d7601ed4ebe139368f313960f63d25a2f26ec905d019eba48b
            )
        }
    }

    function getMintingClosed() public view returns (bool mintingClosed) {

        uint256 data;
        assembly {
            data := sload(
                0xab90edbe8f424080ec4ee1e9062e8b7540cbbfd5f4287285e52611030e58b8d4
            )
        }
        mintingClosed = (data == 1);
    }

    function setMintingClosed() public onlyOwner {

        uint256 data = 1;
        assembly {
            sstore(
                0xab90edbe8f424080ec4ee1e9062e8b7540cbbfd5f4287285e52611030e58b8d4,
                data
            )
        }
    }

    function getTokenLimit() public view returns (uint256 tokenLimit) {

        assembly {
            tokenLimit := sload(
                0xb63653e470fa8e7fcc528e0068173a1969fdee5ae0ee29dd58e7b6111b829c56
            )
        }
    }

    function setTokenLimit(uint256 tokenLimit) public onlyOwner {

        require(getTokenLimit() == 0, "CXIP: token limit already set");
        assembly {
            sstore(
                0xb63653e470fa8e7fcc528e0068173a1969fdee5ae0ee29dd58e7b6111b829c56,
                tokenLimit
            )
        }
    }

    function getTokenSeparator() public view returns (uint256 tokenSeparator) {

        assembly {
            tokenSeparator := sload(
                0x988145eec05de02f4c5d4ecd419a9617237db574d35b27207657cbd8c5b1f045
            )
        }
    }

    function setTokenSeparator(uint256 tokenSeparator) public onlyOwner {

        require(getTokenSeparator() == 0, "CXIP: separator already set");
        assembly {
            sstore(
                0x988145eec05de02f4c5d4ecd419a9617237db574d35b27207657cbd8c5b1f045,
                tokenSeparator
            )
        }
    }

    function prepareMintData(uint256 id, TokenData calldata tokenData) public onlyOwner {

        require(Address.isZero(_tokenData[id].creator), "CXIP: token data already set");
        _tokenData[id] = tokenData;
    }

    function prepareMintDataBatch(uint256[] calldata ids, TokenData[] calldata tokenData) public onlyOwner {

        require(ids.length == tokenData.length, "CXIP: array lengths missmatch");
        for (uint256 i = 0; i < ids.length; i++) {
            require(Address.isZero(_tokenData[ids[i]].creator), "CXIP: token data already set");
            _tokenData[ids[i]] = tokenData[i];
        }
    }

    function setName(bytes32 newName, bytes32 newName2) public onlyOwner {

        _collectionData.name = newName;
        _collectionData.name2 = newName2;
    }

    function setStartTimestamp(uint256 _timestamp) public onlyOwner {

        assembly {
            sstore(
                0xf2aaccfcfa4e77d7601ed4ebe139368f313960f63d25a2f26ec905d019eba48b,
                _timestamp
            )
        }
    }

    function setSymbol(bytes32 newSymbol) public onlyOwner {

        _collectionData.symbol = newSymbol;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(!Address.isZero(newOwner), "CXIP: zero address");
        _owner = newOwner;
    }

    function balanceOf(address wallet) public view returns (uint256) {

        require(!Address.isZero(wallet), "CXIP: zero address");
        return _ownedTokensCount[wallet];
    }

    function baseURI() public view returns (string memory) {

        return string(abi.encodePacked("https://nft.cxip.io/", Strings.toHexString(address(this))));
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        return _tokenApprovals[tokenId];
    }

    function getIdentity() public view returns (address) {

        return ICxipProvenance(getRegistry().getProvenance()).getWalletIdentity(_owner);
    }

    function isApprovedForAll(address wallet, address operator) public view returns (bool) {

        return _operatorApprovals[wallet][operator];
    }

    function isOwner() public view returns (bool) {

        return (msg.sender == _owner || msg.sender == _admin || isIdentityWallet(msg.sender));
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address tokenOwner = _tokenOwner[tokenId];
        require(!Address.isZero(tokenOwner), "ERC721: token does not exist");
        return tokenOwner;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "CXIP: index out of bounds");
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address wallet, uint256 index) public view returns (uint256) {

        require(index < balanceOf(wallet), "CXIP: index out of bounds");
        return _ownedTokens[wallet][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata /*_data*/
    ) public pure returns (bytes4) {

        return 0x150b7a02;
    }

    function _royaltiesFallback() internal {

        address _target = getRegistry().getPA1D();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function isIdentityWallet(address sender) internal view returns (bool) {

        address identity = getIdentity();
        if (Address.isZero(identity)) {
            return false;
        }
        return ICxipIdentity(identity).isWalletRegistered(sender);
    }

    function getRegistry() internal pure returns (ICxipRegistry) {

        return ICxipRegistry(0xC267d41f81308D7773ecB3BDd863a902ACC01Ade);
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokensCount[to];
        _ownedTokensCount[to]++;
        _ownedTokens[to].push(tokenId);
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _clearApproval(uint256 tokenId) private {

        delete _tokenApprovals[tokenId];
    }

    function _mint(address to, uint256 tokenId) private {

        require(!Address.isZero(to), "CXIP: can't mint a burn");
        require(!_exists(tokenId), "CXIP: token already exists");
        _tokenOwner[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId;
        _allTokensIndex[lastTokenId] = tokenIndex;
        delete _allTokensIndex[tokenId];
        delete _allTokens[lastTokenIndex];
        _allTokens.pop();
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        _removeTokenFromAllTokensEnumeration(tokenId);
        _ownedTokensCount[from]--;
        uint256 lastTokenIndex = _ownedTokensCount[from];
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }
        if (lastTokenIndex == 0) {
            delete _ownedTokens[from];
        } else {
            delete _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from].pop();
        }
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) private {

        require(_tokenOwner[tokenId] == from, "CXIP: not from's token");
        require(!Address.isZero(to), "CXIP: use burn instead");
        _clearApproval(tokenId);
        _tokenOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _removeTokenFromOwnerEnumeration(from, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _exists(uint256 tokenId) private view returns (bool) {

        address tokenOwner = _tokenOwner[tokenId];
        return !Address.isZero(tokenOwner);
    }

    function _isApproved(address spender, uint256 tokenId) private view returns (bool) {

        require(_exists(tokenId));
        address tokenOwner = _tokenOwner[tokenId];
        return (spender == tokenOwner || getApproved(tokenId) == spender || isApprovedForAll(tokenOwner, spender));
    }
}