pragma solidity 0.8.0;


interface InscribeInterface {

    event Approval(address indexed owner, address indexed inscriber, address indexed nftAddress, uint256 tokenId);
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event InscriptionAdded(uint256 indexed inscriptionId, 
                            address indexed nftAddress,
                            uint256 tokenId, 
                            address indexed inscriber, 
                            bytes32 contentHash);

    event InscriptionRemoved(uint256 indexed inscriptionId, 
                            address indexed nftAddress, 
                            uint256 tokenId, 
                            address indexed inscriber);

    function getInscriber(uint256 inscriptionId) external view returns (address);


    function verifyInscription(uint256 inscriptionId, address nftAddress, uint256 tokenId) external view returns (bool);


    function getNonce(address inscriber, address nftAddress, uint256 tokenId) external view returns (uint256);


    function getInscriptionURI(uint256 inscriptionId) external view returns (string memory inscriptionURI);


    function approve(address to, address nftAddress, uint256 tokenId) external;


    function getApproved(address nftAddress, uint256 tokenId) external view returns (address);

    
    function setApprovalForAll(address operator, bool approved) external;

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function addInscriptionWithNoSig(
        address nftAddress,
        uint256 tokenId,
        bytes32 contentHash,
        uint256 baseUriId
    ) external;

    
    function addInscriptionWithBaseUriId(
        address nftAddress,
        uint256 tokenId,
        address inscriber,
        bytes32 contentHash,
        uint256 baseUriId,
        uint256 nonce,
        bytes calldata sig
    ) external;


    
    function addInscriptionWithInscriptionUri(
        address nftAddress,
        uint256 tokenId,
        address inscriber,
        bytes32 contentHash,
        string calldata inscriptionURI,
        uint256 nonce,
        bytes calldata sig
    ) external;


    function removeInscription(uint256 inscriptionId, address nftAddress, uint256 tokenId) external;



    function migrateURI(uint256 inscriptionId, uint256 baseUriId, address nftAddress, uint256 tokenId) external;


    function migrateURI(uint256 inscriptionId, string calldata inscriptionURI, address nftAddress, uint256 tokenId) external;


}pragma solidity 0.8.0;


interface InscribeMetaDataInterface {


    event BaseURIAdded(uint256 indexed baseUriId, string indexed baseUri);
    
    event BaseURIModified(uint256 indexed baseURIId, string indexed baseURI);
    
    function addBaseURI(string memory baseURI) external;

    
    function migrateBaseURI(uint256 baseUriId, string memory baseURI) external;

    
    function getBaseURI(uint256 baseUriId) external view returns (string memory baseURI);

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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
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
}pragma solidity 0.8.0;




contract InscribeMetadata is InscribeMetaDataInterface {

    
    struct BaseURI {
        string baseUri;
        address owner;
    }
    
    mapping (uint256 => BaseURI) internal _baseUriMapping;
        
    uint256 internal latestBaseUriId;

    function addBaseURI(string memory baseUri) public override {

        emit BaseURIAdded(latestBaseUriId, baseUri);
        _baseUriMapping[latestBaseUriId] = BaseURI(baseUri, msg.sender);
        latestBaseUriId++;
    }
    
    function migrateBaseURI(uint256 baseUriId, string memory baseUri) external override {

        BaseURI memory uri = _baseUriMapping[baseUriId];

        require(_baseURIExists(uri), "Base URI does not exist");
        require(uri.owner == msg.sender, "Only owner of the URI may migrate the URI");
        
        emit BaseURIModified(baseUriId, baseUri);
        _baseUriMapping[baseUriId] = BaseURI(baseUri, msg.sender);
    }

    function getBaseURI(uint256 baseUriId) public view override returns (string memory baseURI) {

        BaseURI memory uri = _baseUriMapping[baseUriId];
        require(_baseURIExists(uri), "Base URI does not exist");
        return uri.baseUri;
    }
    
    function _baseURIExists(BaseURI memory uri) internal pure returns (bool) {

        return uri.owner != address(0);
    }
}


contract Inscribe is InscribeInterface, InscribeMetadata {

    using Strings for uint256;
    using ECDSA for bytes32;
        


    mapping (uint256 => address) private _inscribers;

    mapping (uint256 => bytes32) private _locationHashes;

    mapping (uint256 => uint256) private _baseURIIds;

    mapping (uint256 => string) private _inscriptionURIs;

    mapping (address => mapping (bytes32 => uint256)) private _nonces;


    mapping (address => mapping (uint256 => address)) private _inscriptionApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes32 public immutable domainSeparator;

    uint256 latestInscriptionId;

    bytes32 public constant ADD_INSCRIPTION_TYPEHASH = 0x6b7aae47ef1cd82bf33fbe47ef7d5d948c32a966662d56eb728bd4a5ed1082ea;

    constructor () {
        latestBaseUriId = 1;
        latestInscriptionId = 1;

        uint256 chainID;

        assembly {
            chainID := chainid()
        }

        domainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Inscribe")),
                keccak256(bytes("1")),
                chainID,
                address(this)
            )
        );
    }

    function getInscriber(uint256 inscriptionId) external view override returns (address) {

        address inscriber = _inscribers[inscriptionId];
        require(inscriber != address(0), "Inscription does not exist");
        return inscriber;
    }

    function verifyInscription(uint256 inscriptionId, address nftAddress, uint256 tokenId) public view override returns (bool) {

        bytes32 locationHash = _locationHashes[inscriptionId];
        return locationHash == keccak256(abi.encodePacked(nftAddress, tokenId));
    }

    function getNonce(address inscriber, address nftAddress, uint256 tokenId) external view override returns (uint256) {

        bytes32 locationHash = keccak256(abi.encodePacked(nftAddress, tokenId));
        return _nonces[inscriber][locationHash];
    }

    function getInscriptionURI(uint256 inscriptionId) external view override returns (string memory inscriptionURI) {

        require(_inscriptionExists(inscriptionId), "Inscription does not exist");
                
        uint256 baseUriId = _baseURIIds[inscriptionId];

        if (baseUriId == 0) {
            return _inscriptionURIs[inscriptionId];
        } else {
            BaseURI memory uri = _baseUriMapping[baseUriId];
            require(_baseURIExists(uri), "Base URI does not exist");
            return string(abi.encodePacked(uri.baseUri, inscriptionId.toString()));
        }
    }

    function approve(address to, address nftAddress, uint256 tokenId) public override {

        address owner = _ownerOf(nftAddress, tokenId);
        require(owner != address(0), "Nonexistent token ID");

        require(to != owner, "Cannot approve the 'to' address as it belongs to the nft owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Approve caller is not owner nor approved for all");

        _approve(to, nftAddress, tokenId);
    }

    function getApproved(address nftAddress, uint256 tokenId) public view override returns (address) {

        return _inscriptionApprovals[nftAddress][tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external override {

        require(operator != msg.sender, "Operator cannot be the same as the caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);    
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function addInscriptionWithNoSig(
        address nftAddress,
        uint256 tokenId,
        bytes32 contentHash,
        uint256 baseUriId
    ) external override {

        require(nftAddress != address(0));
        require(baseUriId != 0);

        require(_isApprovedOrOwner(msg.sender, nftAddress, tokenId));
        
        BaseURI memory uri = _baseUriMapping[baseUriId];
        require(_baseURIExists(uri), "Base URI does not exist");
        _baseURIIds[latestInscriptionId] = baseUriId;

        bytes32 locationHash = keccak256(abi.encodePacked(nftAddress, tokenId));

        _addInscription(nftAddress, tokenId, msg.sender, contentHash, latestInscriptionId, locationHash);

        latestInscriptionId++;
    }
    
    function addInscriptionWithBaseUriId(
        address nftAddress,
        uint256 tokenId,
        address inscriber,
        bytes32 contentHash,
        uint256 baseUriId,
        uint256 nonce,
        bytes calldata sig
    ) external override {

        require(inscriber != address(0));
        require(nftAddress != address(0));

        bytes32 locationHash = keccak256(abi.encodePacked(nftAddress, tokenId));
        require(_nonces[inscriber][locationHash] == nonce, "Nonce mismatch, sign again with the nonce from `getNonce`");

        bytes32 digest = _generateAddInscriptionHash(nftAddress, tokenId, contentHash, nonce);

        require(_recoverSigner(digest, sig) == inscriber, "Recovered address does not match inscriber");

        require(_isApprovedOrOwner(msg.sender, nftAddress, tokenId), "NFT does not belong to msg sender");

        uint256 inscriptionId = latestInscriptionId;

        BaseURI memory uri = _baseUriMapping[baseUriId];
        require(_baseURIExists(uri), "Base URI does not exist");
        _baseURIIds[inscriptionId] = baseUriId;

        _nonces[inscriber][locationHash]++;

        _addInscription(nftAddress, tokenId, inscriber, contentHash, inscriptionId, locationHash); 

        latestInscriptionId++;
    }

    function addInscriptionWithInscriptionUri(
        address nftAddress,
        uint256 tokenId,
        address inscriber,
        bytes32 contentHash,
        string calldata inscriptionURI,
        uint256 nonce,
        bytes calldata sig
    ) external override {

        require(inscriber != address(0));
        require(nftAddress != address(0));

        bytes32 locationHash = keccak256(abi.encodePacked(nftAddress, tokenId));
        require(_nonces[inscriber][locationHash] == nonce, "Nonce mismatch, sign again with the nonce from `getNonce`");

        bytes32 digest = _generateAddInscriptionHash(nftAddress, tokenId, contentHash, nonce);

        require(_recoverSigner(digest, sig) == inscriber, "Recovered address does not match inscriber");

        require(_isApprovedOrOwner(msg.sender, nftAddress, tokenId), "NFT does not belong to msg sender");

        uint256 inscriptionId = latestInscriptionId;

        _baseURIIds[inscriptionId] = 0;
        _inscriptionURIs[inscriptionId] = inscriptionURI;

        _nonces[inscriber][locationHash]++;

        _addInscription(nftAddress, tokenId, inscriber, contentHash, inscriptionId, locationHash); 
        
        latestInscriptionId++;
    }

    function removeInscription(uint256 inscriptionId, address nftAddress, uint256 tokenId) external override {

        require(_inscriptionExists(inscriptionId), "Inscription does not exist at this ID");

        require(verifyInscription(inscriptionId, nftAddress, tokenId), "Verifies nftAddress and tokenId are legitimate");

        require(_isApprovedOrOwner(msg.sender, nftAddress, tokenId), "Caller does not own inscription or is not approved");

        _removeInscription(inscriptionId, nftAddress, tokenId);
    }


    function migrateURI(
        uint256 inscriptionId, 
        uint256 baseUriId, 
        address nftAddress, 
        uint256 tokenId
    ) external override {

        require(_inscriptionExists(inscriptionId), "Inscription does not exist at this ID");

        require(verifyInscription(inscriptionId, nftAddress, tokenId), "Verifies nftAddress and tokenId are legitimate");

        require(_isApprovedOrOwner(msg.sender, nftAddress, tokenId), "Caller does not own inscription or is not approved");

        _baseURIIds[inscriptionId] = baseUriId;
        delete _inscriptionURIs[inscriptionId];
    }

    function migrateURI(
        uint256 inscriptionId, 
        string calldata inscriptionURI, 
        address nftAddress, 
        uint256 tokenId
    ) external override{

        require(_inscriptionExists(inscriptionId), "Inscription does not exist at this ID");

        require(verifyInscription(inscriptionId, nftAddress, tokenId), "Verifies nftAddress and tokenId are legitimate");

        require(_isApprovedOrOwner(msg.sender, nftAddress, tokenId), "Caller does not own inscription or is not approved");

        _baseURIIds[inscriptionId] = 0;
        _inscriptionURIs[inscriptionId] = inscriptionURI;
    }

    function _isApprovedOrOwner(address inscriber, address nftAddress, uint256 tokenId) private view returns (bool) {

        address owner = _ownerOf(nftAddress, tokenId);
        require(owner != address(0), "Nonexistent token ID");
        return (inscriber == owner || getApproved(nftAddress, tokenId) == inscriber || isApprovedForAll(owner, inscriber));
    }
    
    function _approve(address to, address nftAddress, uint256 tokenId) internal {

        _inscriptionApprovals[nftAddress][tokenId] = to;
        emit Approval(_ownerOf(nftAddress, tokenId), to, nftAddress, tokenId);
    }
    
    function _ownerOf(address nftAddress, uint256 tokenId) internal view returns (address){

        IERC721 nftContractInterface = IERC721(nftAddress);
        return nftContractInterface.ownerOf(tokenId);
    }
    
    function _removeInscription(uint256 inscriptionId, address nftAddress, uint256 tokenId) private {

        _approve(address(0), nftAddress, tokenId);
        
        address inscriber = _inscribers[inscriptionId];

        delete _inscribers[inscriptionId];
        delete _locationHashes[inscriptionId];
        delete _inscriptionURIs[inscriptionId];

        emit InscriptionRemoved(
            inscriptionId, 
            nftAddress,
            tokenId,
            inscriber);
    }
    
    function _addInscription(
        address nftAddress,
        uint256 tokenId,
        address inscriber,
        bytes32 contentHash,
        uint256 inscriptionId,
        bytes32 locationHash
    ) private {


        _inscribers[inscriptionId] = inscriber;
        _locationHashes[inscriptionId] = locationHash;

        emit InscriptionAdded(
            inscriptionId, 
            nftAddress, 
            tokenId, 
            inscriber, 
            contentHash
        );
    }
    
    function _inscriptionExists(uint256 inscriptionId) private view returns (bool) {

        return _inscribers[inscriptionId] != address(0);
    }

    function _generateAddInscriptionHash(
        address nftAddress,
        uint256 tokenId,
        bytes32 contentHash,
        uint256 nonce
    ) private view returns (bytes32) {


        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        ADD_INSCRIPTION_TYPEHASH,
                        nftAddress,
                        tokenId,
                        contentHash,
                        nonce
                    )
                )
            )
        );
    }
    
    function _recoverSigner(bytes32 _hash, bytes memory _sig) private pure returns (address) {

        address signer = ECDSA.recover(_hash, _sig);
        require(signer != address(0));
        return signer;
    }
}