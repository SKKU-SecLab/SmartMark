
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
}pragma solidity ^0.8.0;

interface IMetaBus {

    function mint(address _to) external;

    function numberMinted(address _to) external view returns (uint256);

}pragma solidity ^0.8.0;

interface IProxySale {

    function isStake(uint256 _tokenId) external view returns (bool);

}pragma solidity ^0.8.4;



contract ProxySale is Ownable, ReentrancyGuard, IProxySale {

    using ECDSA for bytes32;
    event Stake(address indexed owner, uint256 indexed tokenId, uint256 indexed timestamp);
    event UnStake(address indexed owner, uint256 indexed tokenId, uint256 indexed timestamp);

    enum Status {
        Pending,
        PreSale,
        PublicSale,
        Finished
    }

    struct StakeInfo {
        uint256 tokenId;
        uint256 stakeType;
        uint stakeTimestamp;
    }

    Status public status;

    address public proxyAddress;
    IMetaBus private metaBus;
    IERC721Enumerable private erc721;

    uint256 public whiteListMintPrice = 0.88 ether;

    uint256 public publicMintPrice = 1 ether;

    mapping(uint256 => StakeInfo) public stakeList;

    mapping(string => address) public verifiedList;

    bytes32 public root;
    mapping(string => address) private signerList;
    address private vault;

    mapping(address => uint256) private publicNumberMinted;

    uint256 public MaxSupply;

    modifier eoaOnly() {

        require(tx.origin == msg.sender, "EOA Only");
        _;
    }

    constructor(address _signerMint, address _signerUnStake, address _vault) public {
        signerList["mint"] = _signerMint;
        signerList["unStake"] = _signerUnStake;
        vault = _vault;
        MaxSupply = 577;
    }

    function isStake(uint256 _tokenId) external view override returns (bool){

        return stakeList[_tokenId].stakeTimestamp > 0;
    }

    function _whitelistVerify(bytes32[] memory _proof)
    internal
    view
    returns (bool)
    {

        return
        MerkleProof.verify(
            _proof,
            root,
            keccak256(abi.encodePacked(msg.sender))
        );
    }

    function _hash(string calldata _salt, address _address) internal view returns (bytes32)
    {

        return keccak256(abi.encode(_salt, address(this), _address));
    }

    function _verify(address _signer, bytes32 _hash, bytes memory _token) internal view returns (bool)
    {

        return _signer == _recover(_hash, _token);
    }

    function _recover(bytes32 _hash, bytes memory _token) internal pure returns (address)
    {

        return _hash.toEthSignedMessageHash().recover(_token);
    }

    function makeChange(uint256 _price) private {

        require(msg.value >= _price, "Insufficient ether amount");
        if (msg.value > _price) {
            payable(msg.sender).transfer(msg.value - _price);
        }
    }

    function _preMint(bytes32[] memory _proof) internal{

        require(status == Status.PreSale, "WhiteList not avalible for now");

        require(_whitelistVerify(_proof), "Invalid merkle proof");

        require(MaxSupply - erc721.totalSupply() >= 1, "Max supply reached");

        require(metaBus.numberMinted(msg.sender) == 0, "Minting more than the max supply for a single address");

        metaBus.mint(msg.sender);

        makeChange(whiteListMintPrice);
    }

    function preMint(bytes32[] memory _proof)
    public
    payable
    nonReentrant
    eoaOnly
    {

        _preMint(_proof);
    }

    function preMintOfStake(bytes32[] memory _proof, uint256 _stakeType)
    external
    payable
    nonReentrant
    eoaOnly
    {

        _preMint(_proof);
        uint256 _num = erc721.balanceOf(msg.sender);
        uint256 _tokenId = erc721.tokenOfOwnerByIndex(msg.sender, _num - 1);
        _stake(_tokenId, _stakeType);
    }

    function _publicMint(string calldata _salt, bytes calldata _signature) internal
    {

        require(status == Status.PublicSale, "PublicSale not avalible for now");

        require(_verify(signerList["mint"], _hash(_salt, msg.sender), _signature), "Invalid signature");

        require(MaxSupply - erc721.totalSupply() >= 1, "Max supply reached");

        require(publicNumberMinted[msg.sender] == 0, "Minting more than the max supply for a single address");

        metaBus.mint(msg.sender);

        makeChange(publicMintPrice);

        verifiedList[_salt] = msg.sender;

        publicNumberMinted[msg.sender] = publicNumberMinted[msg.sender] + 1;
    }

    function publicMint(string calldata _salt, bytes calldata _signature)
    public
    payable
    nonReentrant
    eoaOnly
    {

        _publicMint(_salt, _signature);
    }

    function publicMintOfStake(string calldata _salt, bytes calldata _signature, uint256 _stakeType)
    external
    payable
    nonReentrant
    eoaOnly
    {

        _publicMint(_salt, _signature);
        uint256 _num = erc721.balanceOf(msg.sender);
        uint256 _tokenId = erc721.tokenOfOwnerByIndex(msg.sender, _num - 1);
        _stake(_tokenId, _stakeType);
    }

    function _stake(uint256 _tokenId, uint256 _stakeType) internal {

        require(!(stakeList[_tokenId].stakeTimestamp > 0), "Token already staked");

        require(erc721.ownerOf(_tokenId) == msg.sender, "Only owner can stake");

        require(_stakeType >= 0 && _stakeType < 4, "Stake type is error");

        stakeList[_tokenId] = StakeInfo(_tokenId, _stakeType, block.timestamp);

        emit Stake(msg.sender, _tokenId, stakeList[_tokenId].stakeTimestamp);
    }


    function stake(uint256 _tokenId, uint256 _stakeType) public nonReentrant eoaOnly {

        _stake(_tokenId, _stakeType);
    }

    function unStake(string calldata _salt, bytes calldata _signature,  uint256 _tokenId) public nonReentrant eoaOnly{

        require(stakeList[_tokenId].stakeTimestamp > 0, "Token not staked");

        require(erc721.ownerOf(_tokenId) == msg.sender, "Only owner can unstake");

        require(verifiedList[_salt] != msg.sender, "Already verified");

        require(_verify(signerList["unStake"], _hash(_salt, msg.sender), _signature), "Invalid signature");

        delete stakeList[_tokenId];

        verifiedList[_salt] = msg.sender;

        emit UnStake(msg.sender, _tokenId, block.timestamp);
    }

    function setProxyAddress(address _proxyAddress) public onlyOwner{

        proxyAddress = _proxyAddress;
        metaBus = IMetaBus(proxyAddress);
        erc721 = IERC721Enumerable(proxyAddress);
    }

    function setStatus(Status _status) public onlyOwner {

        status = _status;
    }

    function setRoot(bytes32 _root) public onlyOwner{

        root = _root;
    }

    function setSigner(string memory _key, address _signer) public onlyOwner{

        signerList[_key] = _signer;
    }

    function delSigner(string memory _key) public onlyOwner{

        delete signerList[_key];
    }

    function setVault(address _vault) public onlyOwner{

        vault = _vault;
    }

    function setPublicMintPrice(uint256 _publicMintPrice) public onlyOwner{

        publicMintPrice = _publicMintPrice;
    }

    function withdraw() public onlyOwner {

        uint256 balance = address(this).balance;
        payable(vault).transfer(balance);
    }
}