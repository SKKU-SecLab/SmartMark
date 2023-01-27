
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.0;


interface IERC1155Mintable is IERC1155Upgradeable {

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        string calldata uri,
        bytes memory data
    ) external;

}// MIT
pragma solidity ^0.8.0;


interface IERC721Mintable is IERC721Upgradeable {

    function mint(
        address to,
        uint256 tokenId,
        string calldata uri
    ) external;

}// MIT
pragma solidity ^0.8.0;

interface ISporesMinterBatch {


    event SporesNFTMint(
        address indexed _to,
        address indexed _nft,
        uint256 _id,
        uint256 _amount
    );

    event SporesNFTMintBatch(
        address indexed _to,
        address indexed _nft,
        uint256[] _ids,
        uint256[] _amounts
    );

    function mintSporesERC721(
        uint256 _tokenId,
        string calldata _uri,
        bytes calldata _signature
    ) external;


    function mintBatchSporesERC721(
        uint256[] calldata _tokenIds,
        string[] calldata _uris,
        bytes calldata _signature
    ) external;


    function mintSporesERC1155(
        uint256 _tokenId,
        uint256 _amount,
        string calldata _uri,
        bytes calldata _signature
    ) external;


    function mintBatchSporesERC1155(
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        string[] calldata _uris,
        bytes calldata _signature
    ) external;

}// MIT
pragma solidity ^0.8.0;

contract SporesRegistry is Initializable, OwnableUpgradeable {

    address public treasury;
    address public verifier;
    address public erc721;
    address public erc1155;
    address public minter;
    address public market;

    bytes32 public constant VERSION = keccak256("REGISTRY_v1");

    uint256 private constant NFT721_OPCODE = 721;
    uint256 private constant NFT1155_OPCODE = 1155;

    mapping(address => bool) public supportedTokens;

    mapping(address => bool) public supportedNFT721;
    mapping(address => bool) public supportedNFT1155;
    mapping(address => bool) public collections;

    mapping(bytes32 => bool) public prevSigns;

    event TokenRegister(
        address indexed _token,
        bool _isRegistered // true = Registered, false = Removed
    );

    event NFTContractRegister(
        address indexed _contractNFT,
        uint256 _opcode, // _opcode = 721 => NFT721, _opcode = 1155 => NFT1155
        bool _isRegistered // true = Registered, false = Removed
    );

    event CollectionRegister(
        address indexed _collection,
        bool _isRegistered // true = Registered, false = Removed
    );

    event Treasury(address indexed _oldTreasury, address indexed _newTreasury);
    event Verifier(address indexed _oldVerifier, address indexed _newVerifier);
    event Minter(address indexed _oldMinter, address indexed _newMinter);
    event Market(address indexed _oldMarket, address indexed _newMarket);

    modifier onlyAuthorizer() {

        require(
            _msgSender() == minter ||
            _msgSender() == market ||
            collections[_msgSender()],
            "SporesRegistry: Unauthorized"
        );
        _;
    }

    function init(
        address _treasury,
        address _verifier,
        address _nft721,
        address _nft1155,
        address[] memory _tokens
    ) external initializer {

        __Ownable_init();

        treasury = _treasury;
        verifier = _verifier;
        erc721 = _nft721;
        erc1155 = _nft1155;
        supportedNFT721[_nft721] = true;
        supportedNFT1155[_nft1155] = true;
        for (uint256 i = 0; i < _tokens.length; i++) {
            supportedTokens[_tokens[i]] = true;
        }
    }

    function updateVerifier(address _newVerifier) external onlyOwner {

        require(_newVerifier != address(0), "SporesRegistry: Set zero address");
        emit Verifier(verifier, _newVerifier);
        verifier = _newVerifier;
    }

    function updateTreasury(address _newTreasury) external onlyOwner {

        require(_newTreasury != address(0), "SporesRegistry: Set zero address");
        emit Treasury(treasury, _newTreasury);
        treasury = _newTreasury;
    }

    function updateMinter(address _newMinter) external onlyOwner {

        require(_newMinter != address(0), "SporesRegistry: Set zero address");
        emit Minter(minter, _newMinter);
        minter = _newMinter;
    }

    function updateMarket(address _newMarket) external onlyOwner {

        require(_newMarket != address(0), "SporesRegistry: Set zero address");
        emit Market(market, _newMarket);
        market = _newMarket;
    }

    function registerToken(address _token) external onlyOwner {

        require(!supportedTokens[_token], "SporesRegistry: Token registered");
        require(_token != address(0), "SporesRegistry: Set zero address");
        supportedTokens[_token] = true;
        emit TokenRegister(_token, true);
    }

    function unregisterToken(address _token) external onlyOwner {

        require(
            supportedTokens[_token],
            "SporesRegistry: Token not registered"
        );
        delete supportedTokens[_token];
        emit TokenRegister(_token, false);
    }

    function addCollectionByConstructor(
        address _collection,
        address _admin,
        uint256 _collectionId,
        uint256 _maxEdition,
        uint256 _requestId,
        bytes calldata _signature
    ) external {

        bytes32 _data = 
            keccak256(
                abi.encodePacked(
                    _collectionId, _maxEdition, _requestId, _admin, address(this)
                )
            );
        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(_data);  
        address _verifier = ECDSA.recover(_msgHash, _signature);
        _checkAuthorization(_verifier, keccak256(_signature));
        collections[_collection] = true;
    }

    function addCollection(address _collection) external onlyOwner {

        require(_collection != address(0), "SporesRegistry: Set zero address");
        require(!collections[_collection], "SporesRegistry: Collection exist");
        collections[_collection] = true;
        emit CollectionRegister(_collection, true);
    }

    function removeCollection(address _collection) external onlyOwner {

        require(
            collections[_collection],
            "SporesRegistry: Collection not exist"
        );
        delete collections[_collection];
        emit CollectionRegister(_collection, false);
    }

    function registerNFTContract(address _contractNFT, uint256 _opcode, bool _skip)
        external
        onlyOwner
    {

        require(_contractNFT != address(0), "SporesRegistry: Set zero address");
        require(
            _opcode == NFT721_OPCODE || _opcode == NFT1155_OPCODE,
            "SporesRegistry: Invalid opcode"
        );

        if (_opcode == NFT721_OPCODE) {
            require(
                !supportedNFT721[_contractNFT],
                "SporesRegistry: NFT721 Contract registered"
            );
            require(
                _skip || IERC721(_contractNFT).supportsInterface(
                    type(IERC721).interfaceId
                ),
                "SporesRegistry: Invalid interface"
            );
            supportedNFT721[_contractNFT] = true;
        } else {
            require(
                !supportedNFT1155[_contractNFT],
                "SporesRegistry: NFT1155 Contract registered"
            );
            require(
                _skip || IERC1155(_contractNFT).supportsInterface(
                    type(IERC1155).interfaceId
                ),
                "SporesRegistry: Invalid interface"
            );
            supportedNFT1155[_contractNFT] = true;
        }
        emit NFTContractRegister(_contractNFT, _opcode, true);
    }

    function unregisterNFTContract(address _contractNFT, uint256 _opcode)
        external
        onlyOwner
    {

        require(
            _opcode == NFT721_OPCODE || _opcode == NFT1155_OPCODE,
            "SporesRegistry: Invalid opcode"
        );
        if (_opcode == NFT721_OPCODE) {
            require(
                supportedNFT721[_contractNFT],
                "SporesRegistry: NFT721 Contract not registered"
            );
            delete supportedNFT721[_contractNFT];
        } else {
            require(
                supportedNFT1155[_contractNFT],
                "SporesRegistry: NFT1155 Contract not registered"
            );
            delete supportedNFT1155[_contractNFT];
        }
        emit NFTContractRegister(_contractNFT, _opcode, false);
    }

    function checkAuthorization(address _verifier, bytes32 _sigHash)
        external
        onlyAuthorizer
    {

        _checkAuthorization(_verifier, _sigHash);
    }

    function _checkAuthorization(address _verifier, bytes32 _sigHash) private {

        require(_verifier == verifier, "SporesRegistry: Invalid verifier");
        require(!prevSigns[_sigHash], "SporesRegistry: Signature was used");
        prevSigns[_sigHash] = true;
    }
}// MIT
pragma solidity ^0.8.0;


library Signature {

    enum MintType { 
        ERC721_MINTING,
        ERC1155_MINTING 
    }

    enum TradeType {
        NATIVE_COIN_NFT_721,
        NATIVE_COIN_NFT_1155,
        ERC_20_NFT_721,
        ERC_20_NFT_1155
    }

    struct TradeInfo {
        address _seller;
        address _paymentReceiver;
        address _contractNFT;
        address _paymentToken;
        uint256 _tokenId;
        uint256 _feeRate;
        uint256 _price;
        uint256 _amount;
        uint256 _sellId;
    }

    function getTradingSignature(
        TradeType _type,
        TradeInfo calldata _info,
        bytes calldata _signature
    ) internal pure returns (address verifier) {

        bytes32 _data =
            keccak256(
                abi.encodePacked(
                    _info._seller, _info._paymentReceiver, _info._contractNFT, _info._tokenId,
                    _info._paymentToken, _info._feeRate, _info._price, _info._amount, _info._sellId, uint256(_type)
                )
            );
        verifier = getSigner(_data, _signature);  
    }

    function getAddSubCollectionSignature(
        uint256 _collectionId,
        uint256 _subcollectionId,
        uint256 _maxEdition,
        uint256 _requestId,
        bytes calldata _signature
    ) internal pure returns (address verifier) {

        bytes32 _data =
            keccak256(
                abi.encodePacked(
                    _collectionId, _subcollectionId, _maxEdition, _requestId
                )
            );
        verifier = getSigner(_data, _signature);  
    }

    function getSingleMintingSignature(
        MintType _type,
        address _to,
        uint256 _tokenId,
        string calldata _uri,
        bytes calldata _signature
    ) internal pure returns (address verifier) {

        bytes32 _data =
            keccak256(
                abi.encodePacked(
                    _to, _tokenId, _uri, uint256(_type)
                )
            );
        verifier = getSigner(_data, _signature);  
    }

    function getBatchMintingSignature(
        MintType _type,
        address _to,
        uint256[] calldata _tokenIds,
        string[] calldata _uris,
        bytes calldata _signature
    ) internal pure returns (address verifier) {

        bytes memory _encodeURIs;
        for (uint256 i; i < _uris.length; i++) {
            _encodeURIs = abi.encodePacked(_encodeURIs, _uris[i]);
        }
        bytes32 _data =
            keccak256(
                abi.encodePacked(
                    _to, _tokenIds, _encodeURIs, uint256(_type)
                )
            );
        verifier = getSigner(_data, _signature);    
    }

    function getSigner(bytes32 _data, bytes calldata _signature) private pure returns (address) {

        bytes32 _msgHash = ECDSA.toEthSignedMessageHash(_data);
        return ECDSA.recover(_msgHash, _signature);
    }
}// MIT
pragma solidity ^0.8.0;


contract SporesNFTMinterBatch is ISporesMinterBatch, Ownable {

    using Signature for Signature.MintType;

    bytes32 public constant VERSION = keccak256("MINTER_BATCH_v1");

    uint256 private constant SINGLE_UNIT = 1;

    SporesRegistry public registry;

    constructor(address _registry) Ownable() {
        registry = SporesRegistry(_registry);
    }

    function updateRegistry(address _newRegistry) external onlyOwner {

        require(
            _newRegistry != address(0),
            "SporesNFTMinterBatch: Set zero address"
        );
        registry = SporesRegistry(_newRegistry);
    }

    function mintSporesERC721(
        uint256 _tokenId,
        string calldata _uri,
        bytes calldata _signature
    ) external override {

        registry.checkAuthorization(
            Signature.MintType.ERC721_MINTING.getSingleMintingSignature(
                _msgSender(),
                _tokenId,
                _uri,
                _signature
            ),
            keccak256(_signature)
        );

        IERC721Mintable(registry.erc721()).mint(_msgSender(), _tokenId, _uri);

        emit SporesNFTMint(
            _msgSender(),
            registry.erc721(),
            _tokenId,
            SINGLE_UNIT
        );
    }

    function mintBatchSporesERC721(
        uint256[] calldata _tokenIds,
        string[] calldata _uris,
        bytes calldata _signature
    ) external override {

        uint256 _size = _tokenIds.length;
        require(
            _size == _uris.length,
            "SporesNFTMinterBatch: Size not matched"
        );

        registry.checkAuthorization(
            Signature.MintType.ERC721_MINTING.getBatchMintingSignature(
                _msgSender(),
                _tokenIds,
                _uris,
                _signature
            ),
            keccak256(_signature)
        );

        IERC721Mintable _erc721 = IERC721Mintable(registry.erc721());
        uint256[] memory _amounts = new uint256[](_size);
        for (uint256 i; i < _size; i++) {
            _erc721.mint(_msgSender(), _tokenIds[i], _uris[i]);
            _amounts[i] = 1;
        }

        emit SporesNFTMintBatch(
            _msgSender(),
            registry.erc721(),
            _tokenIds,
            _amounts
        );
    }

    function mintSporesERC1155(
        uint256 _tokenId,
        uint256 _amount,
        string calldata _uri,
        bytes calldata _signature
    ) external override {

        registry.checkAuthorization(
            Signature.MintType.ERC1155_MINTING.getSingleMintingSignature(
                _msgSender(),
                _tokenId,
                _uri,
                _signature
            ),
            keccak256(_signature)
        );

        IERC1155Mintable(registry.erc1155()).mint(
            _msgSender(),
            _tokenId,
            _amount,
            _uri,
            ""
        );

        emit SporesNFTMint(_msgSender(), registry.erc1155(), _tokenId, 1);
    }

    function mintBatchSporesERC1155(
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        string[] calldata _uris,
        bytes calldata _signature
    ) external override {

        require(
            _tokenIds.length == _amounts.length &&
                _tokenIds.length == _uris.length,
            "SporesNFTMinterBatch: Size not matched"
        );

        registry.checkAuthorization(
            Signature.MintType.ERC1155_MINTING.getBatchMintingSignature(
                _msgSender(),
                _tokenIds,
                _uris,
                _signature
            ),
            keccak256(_signature)
        );

        IERC1155Mintable _erc1155 = IERC1155Mintable(registry.erc1155());
        for (uint256 i; i < _tokenIds.length; i++) {
            _erc1155.mint(
                _msgSender(),
                _tokenIds[i],
                _amounts[i],
                _uris[i],
                ""
            );
        }

        emit SporesNFTMintBatch(
            _msgSender(),
            registry.erc1155(),
            _tokenIds,
            _amounts
        );
    }

    function _checkAuthorization(
        Signature.MintType _type,
        uint256 _tokenId,
        string calldata _uri,
        bytes calldata _signature
    ) private {

        registry.checkAuthorization(
            _type.getSingleMintingSignature(
                _msgSender(),
                _tokenId,
                _uri,
                _signature
            ),
            keccak256(_signature)
        );
    }

    function _checkAuthorizationBatch(
        Signature.MintType _type,
        uint256[] calldata _tokenIds,
        string[] calldata _uris,
        bytes calldata _signature
    ) private {

        registry.checkAuthorization(
            _type.getBatchMintingSignature(
                _msgSender(),
                _tokenIds,
                _uris,
                _signature
            ),
            keccak256(_signature)
        );
    }
}