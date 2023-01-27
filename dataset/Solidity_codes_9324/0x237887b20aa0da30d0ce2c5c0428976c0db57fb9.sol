

contract NiftyEntity {

   
   address internal immutable niftyRegistryContract;
   
    modifier onlyValidSender() {

        NiftyRegistry niftyRegistry = NiftyRegistry(niftyRegistryContract);
        bool isValid = niftyRegistry.isValidNiftySender(msg.sender);
        require(isValid, "NiftyEntity: Invalid msg.sender");
        _;
    }
    
    constructor(address _niftyRegistryContract) {
        niftyRegistryContract = _niftyRegistryContract;
    }
}

interface NiftyRegistry {

   function isValidNiftySender(address sending_key) external view returns (bool);

}


interface IERC165 {


  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);

}


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

}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}


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

}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


contract ERC721 is NiftyEntity, Context, ERC165, IERC721, IERC721Metadata {


    uint immutable public _id;

    uint immutable public _typeCount;

    address immutable public _defaultOwner;

    uint immutable internal topLevelMultiplier;
    uint immutable internal midLevelMultiplier;

    string private _name;

    string private _symbol;

    string private _baseURI;

    mapping(uint256 => string) private _niftyTypeName;

    mapping(uint256 => string) private _niftyTypeIPFSHashes;

    mapping (uint256 => address) internal _owners;

    mapping (address => uint256) internal _balances;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor(string memory name_, 
                string memory symbol_,
                uint256 id_,
                string memory baseURI_,
                uint256 typeCount_,
                address defaultOwner_, 
                address niftyRegistryContract) NiftyEntity(niftyRegistryContract) {
        _name = name_;
        _symbol = symbol_;
        _id = id_;
        _baseURI = baseURI_;
        _typeCount = typeCount_;
        _defaultOwner = defaultOwner_;

        midLevelMultiplier = 10000;
        topLevelMultiplier = id_ * 100000000;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory tokenIdStr = Strings.toString(tokenId);
        return string(abi.encodePacked(_baseURI, tokenIdStr));
    }

    function tokenIPFSHash(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: IPFS hash query for nonexistent token");
        uint256 niftyType = _getNiftyTypeId(tokenId);
        return _niftyTypeIPFSHashes[niftyType];
    }
    
    function _getNiftyTypeId(uint256 tokenId) private view returns (uint256) {

        return (tokenId - topLevelMultiplier) / midLevelMultiplier;
    }

    function tokenName(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: Name query for nonexistent token");
        uint256 niftyType = _getNiftyTypeId(tokenId);
        return _niftyTypeName[niftyType];
    }
   
    function _setTokenIPFSHashNiftyType(uint256 niftyType, string memory ipfs_hash) internal {

        require(bytes(_niftyTypeIPFSHashes[niftyType]).length == 0, "ERC721Metadata: IPFS hash already set");
        _niftyTypeIPFSHashes[niftyType] = ipfs_hash;
    }

    function _setNiftyTypeName(uint256 niftyType, string memory nifty_type_name) internal {

        _niftyTypeName[niftyType] = nifty_type_name;
    }

    function _setBaseURI(string memory baseURI_) internal {

        _baseURI = baseURI_;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (isContract(to)) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}


contract NiftyBuilderInstance is ERC721, ERC721Burnable {


    string private _creator;

    mapping (uint256 => uint256) public _mintCount;

    mapping (uint256 => bytes32) private _finalized;

    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed fromAddress, address indexed toAddress);

    constructor(
        string memory name,
        string memory symbol,
        uint256 id,
        uint256 typeCount,
        string memory baseURI,
        string memory creator_,
        address niftyRegistryContract,
        address defaultOwner) ERC721(name, symbol, id, baseURI, typeCount, defaultOwner, niftyRegistryContract) {

        _creator = creator_;
    }

    function _encodeTokenId(uint256 niftyType, uint256 tokenNumber) private view returns (uint256) {

        return (topLevelMultiplier + (niftyType * midLevelMultiplier) + tokenNumber);
    }

    function _getFinalized(uint256 niftyType) public view returns (bool) {

        bytes32 chunk = _finalized[niftyType / 256];
        return (chunk & bytes32(1 << (niftyType % 256))) != 0x0;
    }

    function setFinalized(uint256 niftyType) public onlyValidSender {

        uint256 quotient = niftyType / 256;
        bytes32 chunk = _finalized[quotient];
        _finalized[quotient] = chunk | bytes32(1 << (niftyType % 256));
    }

    function creator() public view virtual returns (string memory) {

        return _creator;
    }

    function setBaseURI(string memory baseURI) public onlyValidSender {

        _setBaseURI(baseURI);
    }

    function setNiftyName(uint256 niftyType, string memory niftyName) public onlyValidSender {

        _setNiftyTypeName(niftyType, niftyName);
    }

    function setNiftyIPFSHash(uint256 niftyType, string memory hashIPFS) public onlyValidSender {

        _setTokenIPFSHashNiftyType(niftyType, hashIPFS);
    }

    function mintNifty(uint256 niftyType, uint256 count) public onlyValidSender {

        require(!_getFinalized(niftyType), "NiftyBuilderInstance: minting concluded for nifty type");
            
        uint256 tokenNumber = _mintCount[niftyType] + 1;
        uint256 tokenId00 = _encodeTokenId(niftyType, tokenNumber);
        uint256 tokenId01 = tokenId00 + count - 1;
        
        for (uint256 tokenId = tokenId00; tokenId <= tokenId01; tokenId++) {
            _owners[tokenId] = _defaultOwner;
        }
        _mintCount[niftyType] += count;
        _balances[_defaultOwner] += count;

        emit ConsecutiveTransfer(tokenId00, tokenId01, address(0), _defaultOwner);
    }

}


pragma solidity ^0.8.6;



contract BuilderShop is NiftyEntity {


    uint public _id;

    address public _defaultOwner;

    mapping (address => bool) public validBuilderInstance;

    event BuilderInstanceCreated(address instanceAddress, uint id);

    constructor(address niftyRegistryContract,
                address defaultOwner_) NiftyEntity(niftyRegistryContract) {
        _defaultOwner = defaultOwner_;
    }

    function setDefaultOwner(address defaultOwner) onlyValidSender external {

        _defaultOwner = defaultOwner;
    }

    function isValidBuilderInstance(address instanceAddress) external view returns (bool) {

        return (validBuilderInstance[instanceAddress]);
    }

    function createNewBuilderInstance(
        string memory name,
        string memory symbol,
        uint256 typeCount,
        string memory baseURI,
        string memory creator) external onlyValidSender { 

        
        _id += 1;

        NiftyBuilderInstance instance = new NiftyBuilderInstance(
            name,
            symbol,
            _id,
            typeCount,
            baseURI,
            creator,
            niftyRegistryContract,
            _defaultOwner
        );
        address instanceAddress = address(instance);
        validBuilderInstance[instanceAddress] = true;

        emit BuilderInstanceCreated(instanceAddress, _id);
    }
   
}