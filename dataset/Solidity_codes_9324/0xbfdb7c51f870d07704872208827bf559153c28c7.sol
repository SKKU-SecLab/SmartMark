


pragma solidity ^0.8.9;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.9;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) override external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}




pragma solidity ^0.8.9;


abstract contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public virtual view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public virtual view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual;
    function transferFrom(address from, address to, uint256 tokenId) public virtual;
    function approve(address to, uint256 tokenId) public virtual;
    function getApproved(uint256 tokenId) public virtual view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public virtual;
    function isApprovedForAll(address owner, address operator) public virtual view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual;
}




pragma solidity ^0.8.9;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}




pragma solidity ^0.8.9;



library Counters {


    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value - 1;
    }
}




pragma solidity ^0.8.9;

abstract contract IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public virtual returns (bytes4);
}




pragma solidity ^0.8.9;



contract ERC721 is ERC165, IERC721 {

    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;
    
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC721);
    }


    function balanceOf(address owner) public override view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public override view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public override virtual {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public override view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public override {

        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public override view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}


pragma solidity ^0.8.9;

abstract contract IERC721Enumerable is IERC721 {
    function totalSupply() public virtual view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public virtual view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public virtual view returns (uint256);
}


pragma solidity ^0.8.9;

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;


    constructor () {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public override view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }


    function totalSupply() public override view returns (uint256) {

        return _allTokens.length;
    }


    function tokenByIndex(uint256 index) public override view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) override internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) override internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) override internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }


    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }
 
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].pop();

    }


    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.pop();
        _allTokensIndex[tokenId] = 0;
    }
}




pragma solidity ^0.8.9;

contract CustomERC721Metadata is ERC721Enumerable {


    string private _name;

    string private _symbol;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory nm, string memory sym) {
        _name = nm;
        _symbol = sym;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

}

library Strings {


    function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, "", "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}

pragma solidity ^0.8.9;

interface NtentData {

   function data(uint256 _tokenId) external view returns(string memory);

}
interface NtentTokenUri {

   function tokenUri(uint256 _tokenId) external view returns(string memory);

}

contract NtentArt is CustomERC721Metadata {


    event Mint(
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 indexed _projectId
    );

    struct Project {
        string name;
        string artist;
        string description;
        string website;
        string license;
        address purchaseContract;
        address dataContract;
        address tokenUriContract;
        bool acceptsMintPass;
        uint256 mintPassProjectId;
        bool dynamic;
        string projectBaseURI;
        string projectBaseIpfsURI;
        uint256 invocations;
        uint256 maxInvocations;
        string scriptJSON;
        mapping(uint256 => string) scripts;
        uint scriptCount;
        uint256 tokensBurned; 
        string ipfsHash;
        bool useHashString;
        bool useIpfs;
        bool active;
        bool locked;
        bool paused;

    }

    uint256 constant ONE_MILLION = 1_000_000;
    mapping(uint256 => Project) projects;

    mapping(uint256 => address) public projectIdToArtistAddress;
    mapping(uint256 => uint256) public projectIdToPricePerTokenInWei;

    address public ntentAddress;
    uint256 public ntentPercentage = 10;

    mapping(uint256 => string) public staticIpfsImageLink;
    mapping(uint256 => uint256) public tokenIdToProjectId;
    mapping(uint256 => uint256[]) internal projectIdToTokenIds;
    mapping(uint256 => bytes32) public tokenIdToHash;
    mapping(bytes32 => uint256) public hashToTokenId;

    address public admin;
    mapping(address => bool) public isRainbowlisted;
    mapping(address => bool) public isMintRainbowlisted;

    uint256 public nextProjectId = 1;

    modifier onlyValidTokenId(uint256 _tokenId) {

        require(_exists(_tokenId), "Token ID not exists");
        _;
    }

    modifier onlyUnlocked(uint256 _projectId) {

        require(!projects[_projectId].locked, "Only if unlocked");
        _;
    }

    modifier onlyArtist(uint256 _projectId) {

        require(msg.sender == projectIdToArtistAddress[_projectId], "Only artist");
        _;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyRainbowlisted() {

        require(isRainbowlisted[msg.sender], "Only Rainbowlisted");
        _;
    }

    modifier onlyArtistOrRainbowlisted(uint256 _projectId) {

        require(isRainbowlisted[msg.sender] || msg.sender == projectIdToArtistAddress[_projectId], "Only artist or Rainbowlisted");
        _;
    }

    constructor(string memory _tokenName, string memory _tokenSymbol) CustomERC721Metadata(_tokenName, _tokenSymbol) {
        admin = msg.sender;
        isRainbowlisted[msg.sender] = true;
        ntentAddress = msg.sender;
    }

    function mint(address _to, uint256 _projectId, address _by) external returns (uint256 _tokenId) {

        require(isMintRainbowlisted[msg.sender], "Must mint from Rainbowlisted minter");
        require(projects[_projectId].invocations + 1 <= projects[_projectId].maxInvocations, "Exceeds max invocations");
        require(projects[_projectId].active || _by == projectIdToArtistAddress[_projectId], "Proj must exist and be active");
        require(!projects[_projectId].paused || _by == projectIdToArtistAddress[_projectId], "Purchases are paused");

        uint256 tokenId = _mintToken(_to, _projectId);

        return tokenId;
    }

    function _mintToken(address _to, uint256 _projectId) internal returns (uint256 _tokenId) {


        uint256 tokenIdToBe = (_projectId * ONE_MILLION) + projects[_projectId].invocations;

        projects[_projectId].invocations = projects[_projectId].invocations + 1;

        bytes32 hash = keccak256(abi.encodePacked(projects[_projectId].invocations, block.number, blockhash(block.number - 1), msg.sender, _tokenId));
        tokenIdToHash[tokenIdToBe]=hash;
        hashToTokenId[hash] = tokenIdToBe;

        _mint(_to, tokenIdToBe);

        tokenIdToProjectId[tokenIdToBe] = _projectId;
        projectIdToTokenIds[_projectId].push(tokenIdToBe);

        emit Mint(_to, tokenIdToBe, _projectId);

        return tokenIdToBe;
    }
    
    function burn(address ownerAddress, uint256 tokenId) external returns(uint256 _tokenId) {

        require(isMintRainbowlisted[msg.sender], "Must burn from Rainbowlisted minter");
        _burn(ownerAddress, tokenId);
        projects[tokenIdToProjectId[tokenId]].tokensBurned = projects[tokenIdToProjectId[tokenId]].tokensBurned + 1;
        return tokenId;
    }
    
    function updateNtentAddress(address _ntentAddress) public onlyAdmin {

        ntentAddress = _ntentAddress;
    }

    function updateNtentPercentage(uint256 _ntentPercentage) public onlyAdmin {

        require(_ntentPercentage <= 50, "Max of 50%");
        ntentPercentage = _ntentPercentage;
    }

    function addRainbowlisted(address _address) public onlyAdmin {

        isRainbowlisted[_address] = true;
    }

    function removeRainbowlisted(address _address) public onlyAdmin {

        isRainbowlisted[_address] = false;
    }

    function addMintRainbowlisted(address _address) public onlyAdmin {

        isMintRainbowlisted[_address] = true;
    }

    function removeMintRainbowlisted(address _address) public onlyAdmin {

        isMintRainbowlisted[_address] = false;
    }
    
    function getPricePerTokenInWei(uint256 _projectId) public view returns (uint256 price) {

        return projectIdToPricePerTokenInWei[_projectId];
    }

    function toggleProjectIsLocked(uint256 _projectId) public onlyRainbowlisted onlyUnlocked(_projectId) {

        projects[_projectId].locked = true;
    }

    function toggleProjectIsActive(uint256 _projectId) public onlyRainbowlisted {

        projects[_projectId].active = !projects[_projectId].active;
    }

    function updateProjectArtistAddress(uint256 _projectId, address _artistAddress) public onlyArtistOrRainbowlisted(_projectId) {

        projectIdToArtistAddress[_projectId] = _artistAddress;
    }

    function toggleProjectIsPaused(uint256 _projectId) public onlyArtistOrRainbowlisted(_projectId) {

        projects[_projectId].paused = !projects[_projectId].paused;
    }

    function addProject(string memory _projectName, address _artistAddress, uint256 _pricePerTokenInWei, address _purchaseContract, bool _acceptsMintPass, uint256 _mintPassProjectId, bool _dynamic) public onlyRainbowlisted {


        uint256 projectId = nextProjectId;
        projectIdToArtistAddress[projectId] = _artistAddress;
        projects[projectId].name = _projectName;
        projects[projectId].purchaseContract = _purchaseContract;
        projects[projectId].acceptsMintPass = _acceptsMintPass;
        projects[projectId].mintPassProjectId = _mintPassProjectId;
        projectIdToPricePerTokenInWei[projectId] = _pricePerTokenInWei;
        projects[projectId].paused=true;
        projects[projectId].tokensBurned=0;
        projects[projectId].dynamic=_dynamic;
        projects[projectId].maxInvocations = ONE_MILLION;
        if (!_dynamic) {
            projects[projectId].useHashString = false;
        } else {
            projects[projectId].useHashString = true;
        }
        nextProjectId = nextProjectId + 1;
    }

    function updateProjectPricePerTokenInWei(uint256 _projectId, uint256 _pricePerTokenInWei) onlyArtist(_projectId) public {

        projectIdToPricePerTokenInWei[_projectId] = _pricePerTokenInWei;
    }

    function updateProjectName(uint256 _projectId, string memory _projectName) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

        projects[_projectId].name = _projectName;
    }

    function updateProjectArtistName(uint256 _projectId, string memory _projectArtistName) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

        projects[_projectId].artist = _projectArtistName;
    }
    
    function updateProjectPurchaseContractInfo(uint256 _projectId, address _projectPurchaseContract, bool _acceptsMintPass, uint256 _mintPassProjectId) onlyUnlocked(_projectId) onlyRainbowlisted public {

        projects[_projectId].purchaseContract = _projectPurchaseContract;
        projects[_projectId].acceptsMintPass = _acceptsMintPass;
        projects[_projectId].mintPassProjectId = _mintPassProjectId;
    }
    
    function updateProjectDataContractInfo(uint256 _projectId, address _projectDataContract) onlyUnlocked(_projectId) onlyRainbowlisted public {

        projects[_projectId].dataContract = _projectDataContract;
    }
    
    function updateProjectTokenUriContractInfo(uint256 _projectId, address _projectTokenUriContract) onlyUnlocked(_projectId) onlyRainbowlisted public {

        projects[_projectId].tokenUriContract = _projectTokenUriContract;
    }

    function updateProjectDescription(uint256 _projectId, string memory _projectDescription) onlyArtist(_projectId) public {

        projects[_projectId].description = _projectDescription;
    }

    function updateProjectWebsite(uint256 _projectId, string memory _projectWebsite) onlyArtist(_projectId) public {

        projects[_projectId].website = _projectWebsite;
    }

    function updateProjectLicense(uint256 _projectId, string memory _projectLicense) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

        projects[_projectId].license = _projectLicense;
    }

    function updateProjectMaxInvocations(uint256 _projectId, uint256 _maxInvocations) onlyArtist(_projectId) public {

        require((!projects[_projectId].locked || _maxInvocations<projects[_projectId].maxInvocations), "Only if unlocked");
        require(_maxInvocations > projects[_projectId].invocations, "Max invocations exceeds current");
        require(_maxInvocations <= ONE_MILLION, "Cannot exceed 1000000");
        projects[_projectId].maxInvocations = _maxInvocations;
    }

    function toggleProjectUseHashString(uint256 _projectId) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

      require(projects[_projectId].invocations == 0, "Cannot modify after token is minted.");
      projects[_projectId].useHashString = !projects[_projectId].useHashString;
    }

    function addProjectScript(uint256 _projectId, string memory _script) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

        projects[_projectId].scripts[projects[_projectId].scriptCount] = _script;
        projects[_projectId].scriptCount = projects[_projectId].scriptCount + 1;
    }

    function updateProjectScript(uint256 _projectId, uint256 _scriptId, string memory _script) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

        require(_scriptId < projects[_projectId].scriptCount, "scriptId out of range");
        projects[_projectId].scripts[_scriptId] = _script;
    }

    function removeProjectLastScript(uint256 _projectId) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

        require(projects[_projectId].scriptCount > 0, "there are no scripts to remove");
        delete projects[_projectId].scripts[projects[_projectId].scriptCount - 1];
        projects[_projectId].scriptCount = projects[_projectId].scriptCount + 1;
    }

    function updateProjectScriptJSON(uint256 _projectId, string memory _projectScriptJSON) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

        projects[_projectId].scriptJSON = _projectScriptJSON;
    }

    function updateProjectIpfsHash(uint256 _projectId, string memory _ipfsHash) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

        projects[_projectId].ipfsHash = _ipfsHash;
    }

    function updateProjectBaseURI(uint256 _projectId, string memory _newBaseURI) onlyArtist(_projectId) public {

        projects[_projectId].projectBaseURI = _newBaseURI;
    }

    function updateProjectBaseIpfsURI(uint256 _projectId, string memory _projectBaseIpfsURI) onlyArtist(_projectId) public {

        projects[_projectId].projectBaseIpfsURI = _projectBaseIpfsURI;
    }

    function toggleProjectUseIpfsForStatic(uint256 _projectId) onlyArtistOrRainbowlisted(_projectId) public {

        require(!projects[_projectId].dynamic, "can only set static IPFS hash for static projects");
        projects[_projectId].useIpfs = !projects[_projectId].useIpfs;
    }

    function toggleProjectIsDynamic(uint256 _projectId) onlyUnlocked(_projectId) onlyArtistOrRainbowlisted(_projectId) public {

      require(projects[_projectId].invocations == 0, "Can not switch after a token is minted.");
        if (projects[_projectId].dynamic) {
            projects[_projectId].useHashString = false;
        } else {
            projects[_projectId].useHashString = true;
        }
        projects[_projectId].dynamic = !projects[_projectId].dynamic;
    }

    function overrideTokenDynamicImageWithIpfsLink(uint256 _tokenId, string memory _ipfsHash) onlyArtistOrRainbowlisted(tokenIdToProjectId[_tokenId]) public {

        staticIpfsImageLink[_tokenId] = _ipfsHash;
    }

    function clearTokenIpfsImageUri(uint256 _tokenId) onlyArtistOrRainbowlisted(tokenIdToProjectId[_tokenId]) public {

        delete staticIpfsImageLink[tokenIdToProjectId[_tokenId]];
    }

    function projectDetails(uint256 _projectId) view public returns (string memory projectName, string memory artist, string memory description, string memory website, string memory license, bool dynamic) {

        projectName = projects[_projectId].name;
        artist = projects[_projectId].artist;
        description = projects[_projectId].description;
        website = projects[_projectId].website;
        license = projects[_projectId].license;
        dynamic = projects[_projectId].dynamic;
    }

    function projectTokenInfo(uint256 _projectId) view public returns (address artistAddress, uint256 pricePerTokenInWei, uint256 invocations, uint256 maxInvocations, bool active, address purchaseContract,  address dataContract, address tokenUriContract, bool acceptsMintPass, uint256 mintPassProjectId) {

        artistAddress = projectIdToArtistAddress[_projectId];
        pricePerTokenInWei = projectIdToPricePerTokenInWei[_projectId];
        invocations = projects[_projectId].invocations;
        maxInvocations = projects[_projectId].maxInvocations;
        active = projects[_projectId].active;
        purchaseContract = projects[_projectId].purchaseContract;
        dataContract = projects[_projectId].dataContract;
        tokenUriContract = projects[_projectId].tokenUriContract;
        acceptsMintPass = projects[_projectId].acceptsMintPass;
        mintPassProjectId = projects[_projectId].mintPassProjectId;
    }

    function projectScriptInfo(uint256 _projectId) view public returns (string memory scriptJSON, uint256 scriptCount, bool useHashString, string memory ipfsHash, bool locked, bool paused) {

        scriptJSON = projects[_projectId].scriptJSON;
        scriptCount = projects[_projectId].scriptCount;
        useHashString = projects[_projectId].useHashString;
        ipfsHash = projects[_projectId].ipfsHash;
        locked = projects[_projectId].locked;
        paused = projects[_projectId].paused;
    }

    function projectScriptByIndex(uint256 _projectId, uint256 _index) view public returns (string memory){

        return projects[_projectId].scripts[_index];
    }

    function projectURIInfo(uint256 _projectId) view public returns (string memory projectBaseURI, string memory projectBaseIpfsURI, bool useIpfs) {

        projectBaseURI = projects[_projectId].projectBaseURI;
        projectBaseIpfsURI = projects[_projectId].projectBaseIpfsURI;
        useIpfs = projects[_projectId].useIpfs;
    }

    function projectShowAllTokens(uint _projectId) public view returns (uint256[] memory){

        return projectIdToTokenIds[_projectId];
    }

    function tokensOfOwner(address owner) external view returns (uint256[] memory) {

        return _tokensOfOwner(owner);
    }

    function tokenURI(uint256 _tokenId) external view onlyValidTokenId(_tokenId) returns (string memory) {

        
        if(projects[tokenIdToProjectId[_tokenId]].tokenUriContract != address(0)){
            NtentTokenUri ntentTokenUri = NtentTokenUri(projects[tokenIdToProjectId[_tokenId]].tokenUriContract);
            return ntentTokenUri.tokenUri(_tokenId);
        }
        
        if (bytes(staticIpfsImageLink[_tokenId]).length > 0) {
            return Strings.strConcat(projects[tokenIdToProjectId[_tokenId]].projectBaseIpfsURI, staticIpfsImageLink[_tokenId]);
        }

        if (!projects[tokenIdToProjectId[_tokenId]].dynamic && projects[tokenIdToProjectId[_tokenId]].useIpfs) {
            return Strings.strConcat(projects[tokenIdToProjectId[_tokenId]].projectBaseIpfsURI, projects[tokenIdToProjectId[_tokenId]].ipfsHash);
        }
        
        return Strings.strConcat(projects[tokenIdToProjectId[_tokenId]].projectBaseURI, Strings.uint2str(_tokenId));
    }
}