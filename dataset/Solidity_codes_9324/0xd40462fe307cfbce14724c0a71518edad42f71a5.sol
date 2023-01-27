


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.5.0;



contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}



pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}



pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity ^0.5.0;





library Counters {

    using SafeMath for uint256;

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

        counter._value = counter._value.sub(1);
    }
}


pragma solidity ^0.5.0;



contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}




pragma solidity ^0.5.0;


pragma solidity ^0.5.0;


contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;
    
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }


    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

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

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

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
}// File contracts/libs/IERC721Enumerable.sol


pragma solidity ^0.5.0;



contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}



pragma solidity ^0.5.0;



contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

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


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}


pragma solidity ^0.5.0;



contract CustomERC721Metadata is ERC165, ERC721, ERC721Enumerable {


    string private _name;

    string private _symbol;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

}


pragma solidity ^0.5.0;

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
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
pragma solidity ^0.5.0;



interface Randomizer {

   function returnValue() external view returns(bytes32);

}

contract Baeowp is CustomERC721Metadata {

    using SafeMath for uint256;
    event Mint(
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 indexed _projectId
    );

    Randomizer public randomizerContract;
    
    struct Project {
        string projectJson;
        string projectAdditionalJson;
        string projectResourceJson;
        string scriptJSON;
        mapping(uint256 => string) scripts;
        uint scriptCount;
        string projectBaseURI;
        string resourceBaseIpfsURI;
        uint256 publications;
        uint256 maxPublications;
        string resourceIpfsHash;
        bool active;
        bool locked;
        address payable artistAddress;
        address payable additionalPayee;   
        uint256 thirdAddressPercentage;
        uint256 secondMarketRoyalty;     
        uint256 pricePerTokenInWei;
    }
    
    address public admin;
    address payable public baeowpAddress;
    uint256 public baeowpPercentage = 10;

    uint256 constant TEN_THOUSAND = 10_000;
    uint256 public nextProjectId;
    mapping(uint256 => Project) projects;
    mapping(uint256 => uint256) public tokenIdToProjectId;
    mapping(uint256 => uint256[]) internal projectIdToTokenIds;
    mapping(uint256 => bytes32) public tokenIdToHash;
    mapping(bytes32 => uint256) public hashToTokenId;

    function _onlyValidTokenId(uint256 _tokenId) private view {

        require(_exists(_tokenId), "Token ID does not exist");
    }
    function _onlyUnlocked(uint256 _projectId) private view {

        require(!projects[_projectId].locked, "Only if unlocked");
    }
    function _onlyArtist(uint256 _projectId) private view {

        require(msg.sender == projects[_projectId].artistAddress, "Only artist");
    }
    function _onlyAdmin() private view {

        require(msg.sender == admin, "Only admin");
    }
    modifier onlyValidTokenId(uint256 _tokenId) {

        _onlyValidTokenId(_tokenId);
        _;
    }
    modifier onlyUnlocked(uint256 _projectId) {

        _onlyUnlocked(_projectId);
        _;
    }
    modifier onlyArtist(uint256 _projectId) {

        _onlyArtist(_projectId);
        _;
    }
    modifier onlyAdmin() {

        _onlyAdmin();
        _;
    }

    constructor(string memory _tokenName, string memory _tokenSymbol, address _randomizerContract) CustomERC721Metadata(_tokenName, _tokenSymbol) public {
        admin = msg.sender;
        baeowpAddress = msg.sender;
        randomizerContract = Randomizer(_randomizerContract);

    }

    function purchase(uint256 _projectId) public payable returns (uint256 _tokenId) {

        return purchaseTo(msg.sender, _projectId);
    }

    function purchaseTo(address _to, uint256 _projectId) public payable returns (uint256 _tokenId) {

        require(msg.value >= projects[_projectId].pricePerTokenInWei, "Must send at least pricePerTokenInWei");
        require(projects[_projectId].publications.add(1) <= projects[_projectId].maxPublications, "Must not exceed max publications");
        require(projects[_projectId].active || msg.sender == projects[_projectId].artistAddress, "Project must exist and be active");

        uint256 tokenId = _mintToken(_to, _projectId);

        _shareMint(_projectId);

        return tokenId;
    }

    function _mintToken(address _to, uint256 _projectId) internal returns (uint256 _tokenId) {


        uint256 tokenIdToBe = (_projectId * TEN_THOUSAND) + projects[_projectId].publications;

        projects[_projectId].publications = projects[_projectId].publications.add(1);

        bytes32 hash = keccak256(abi.encodePacked(projects[_projectId].publications, block.number, blockhash(block.number - 1), msg.sender, randomizerContract));
        tokenIdToHash[tokenIdToBe]=hash;
        hashToTokenId[hash] = tokenIdToBe;

        _mint(_to, tokenIdToBe);

        tokenIdToProjectId[tokenIdToBe] = _projectId;
        projectIdToTokenIds[_projectId].push(tokenIdToBe);

        emit Mint(_to, tokenIdToBe, _projectId);

        return tokenIdToBe;
    }

    function _shareMint(uint256 _projectId) internal {

        if (msg.value > 0) {

            uint256 pricePerTokenInWei = projects[_projectId].pricePerTokenInWei;
            uint256 refund = msg.value.sub(projects[_projectId].pricePerTokenInWei);

            if (refund > 0) {
                msg.sender.transfer(refund);
            }

            uint256 foundationAmount = pricePerTokenInWei.div(100).mul(baeowpPercentage);
            if (foundationAmount > 0) {
                baeowpAddress.transfer(foundationAmount);
            }

            uint256 projectFunds = pricePerTokenInWei.sub(foundationAmount);

            uint256 additionalPayeeAmount;
            if (projects[_projectId].thirdAddressPercentage > 0) {
                additionalPayeeAmount = projectFunds.div(100).mul(projects[_projectId].thirdAddressPercentage);
                if (additionalPayeeAmount > 0) {
                    projects[_projectId].additionalPayee.transfer(additionalPayeeAmount);
                }
            }

            uint256 creatorFunds = projectFunds.sub(additionalPayeeAmount);
            if (creatorFunds > 0) {
                projects[_projectId].artistAddress.transfer(creatorFunds);
            }
        }
    }

    function updateBaeowpAddress(address payable _baeowpAddress) public onlyAdmin {

        baeowpAddress = _baeowpAddress;
    }

    function updateBaeowpPercentage(uint256 _baeowpPercentage) public onlyAdmin {

        require(_baeowpPercentage <= 25, "max 25");
        baeowpPercentage = _baeowpPercentage;
    }

    function doLockProject(uint256 _projectId) public onlyArtist(_projectId)  onlyUnlocked(_projectId) {

        projects[_projectId].locked = true;
    }

    function updateRandomizerAddress(uint256 _projectId, address _randomizerAddress) public onlyArtist(_projectId) {

        randomizerContract = Randomizer(_randomizerAddress);
    }

    function toggleProjectIsActive(uint256 _projectId) public onlyArtist(_projectId)  {

        projects[_projectId].active = !projects[_projectId].active;
    }

    function updateProjectArtistAddress(uint256 _projectId, address payable _artistAddress) public onlyArtist(_projectId) {

        projects[_projectId].artistAddress = _artistAddress;
    }

    function addProject(address payable _artistAddress, uint256 _pricePerTokenInWei) public onlyAdmin {


        uint256 projectId = nextProjectId;
        projects[projectId].artistAddress = _artistAddress;
        projects[projectId].pricePerTokenInWei = _pricePerTokenInWei;
        projects[projectId].maxPublications = TEN_THOUSAND;
        nextProjectId = nextProjectId.add(1);
    }
   
    function updateProjectPricePerTokenInWei(uint256 _projectId, uint256 _pricePerTokenInWei) onlyArtist(_projectId) public {

        projects[_projectId].pricePerTokenInWei = _pricePerTokenInWei;
    }

    
    function updateProjectAdditionalPayeeInfo(uint256 _projectId, address payable _additionalPayee, uint256 _thirdAddressPercentage) onlyArtist(_projectId) public {

        require(_thirdAddressPercentage <= 100, "max 100");
        projects[_projectId].additionalPayee = _additionalPayee;
        projects[_projectId].thirdAddressPercentage = _thirdAddressPercentage;
    }

    function updateProjectSecondaryMarketRoyaltyPercentage(uint256 _projectId, uint256 _secondMarketRoyalty) onlyArtist(_projectId) public {

        require(_secondMarketRoyalty <= 100, "max 100");
        projects[_projectId].secondMarketRoyalty = _secondMarketRoyalty;
    }

    function updateProjectJson(uint256 _projectId, string memory _projectJSON) onlyUnlocked(_projectId) onlyArtist(_projectId) public {

        projects[_projectId].projectJson = _projectJSON;
    }
    function updateProjectAdditionalJson(uint256 _projectId, string memory _projectAdditionalJson) onlyArtist(_projectId) public {

        projects[_projectId].projectAdditionalJson = _projectAdditionalJson;
    }

    function updateProjectMaxPublications(uint256 _projectId, uint256 _maxPublications) onlyUnlocked(_projectId) onlyArtist(_projectId) public {

        require(_maxPublications > projects[_projectId].publications, "You must set max publications greater than current publications");
        require(_maxPublications <= TEN_THOUSAND,  "Cannot exceed 10,000");
        projects[_projectId].maxPublications = _maxPublications;
    }

    function addProjectScript(uint256 _projectId, string memory _script) onlyUnlocked(_projectId) onlyArtist(_projectId) public {

        projects[_projectId].scripts[projects[_projectId].scriptCount] = _script;
        projects[_projectId].scriptCount = projects[_projectId].scriptCount.add(1);
    }

    function updateProjectScript(uint256 _projectId, uint256 _scriptId, string memory _script) onlyUnlocked(_projectId) onlyArtist(_projectId) public {

        require(_scriptId < projects[_projectId].scriptCount, "scriptId out of range");
        projects[_projectId].scripts[_scriptId] = _script;
    }

    function removeProjectLastScript(uint256 _projectId) onlyUnlocked(_projectId) onlyArtist(_projectId) public {

        require(projects[_projectId].scriptCount > 0, "there are no scripts to remove");
        delete projects[_projectId].scripts[projects[_projectId].scriptCount - 1];
        projects[_projectId].scriptCount = projects[_projectId].scriptCount.sub(1);
    }

    function updateProjectScriptJSON(uint256 _projectId, string memory _projectScriptJSON) onlyUnlocked(_projectId) onlyArtist(_projectId) public {

        projects[_projectId].scriptJSON = _projectScriptJSON;
    }

    function updateProjectResourceJSON(uint256 _projectId, string memory _projectResourceJson) onlyUnlocked(_projectId) onlyArtist(_projectId) public {

        projects[_projectId].projectResourceJson = _projectResourceJson;
    }

    function updateProjectResourceIpfsHash(uint256 _projectId, string memory _resourceIpfsHash) onlyUnlocked(_projectId) onlyArtist(_projectId) public {

        projects[_projectId].resourceIpfsHash = _resourceIpfsHash;
    }

    function updateProjectBaseURI(uint256 _projectId, string memory _newBaseURI) onlyArtist(_projectId) public {

        projects[_projectId].projectBaseURI = _newBaseURI;
    }

    function updateResourceBaseIpfsURI(uint256 _projectId, string memory _resourceBaseIpfsURI) onlyArtist(_projectId) public {

        projects[_projectId].resourceBaseIpfsURI = _resourceBaseIpfsURI;
    }

    function projectDetails(uint256 _projectId) view public returns (string memory projectJson, string memory projectAdditionalJson, string memory projectResourceJson) {

        projectJson = projects[_projectId].projectJson;
        projectAdditionalJson = projects[_projectId].projectAdditionalJson;
        projectResourceJson = projects[_projectId].projectResourceJson;
    }


    function projectTokenInfo(uint256 _projectId) view public returns (address artistAddress, uint256 pricePerTokenInWei, uint256 publications, uint256 maxPublications, bool active, address additionalPayee, uint256 thirdAddressPercentage) {

        artistAddress = projects[_projectId].artistAddress;
        pricePerTokenInWei = projects[_projectId].pricePerTokenInWei;
        publications = projects[_projectId].publications;
        maxPublications = projects[_projectId].maxPublications;
        active = projects[_projectId].active;
        additionalPayee = projects[_projectId].additionalPayee;
        thirdAddressPercentage = projects[_projectId].thirdAddressPercentage;
    }

    function projectScriptInfo(uint256 _projectId) view public returns (string memory scriptJSON, uint256 scriptCount, string memory resourceIpfsHash, bool locked) {

        scriptJSON = projects[_projectId].scriptJSON;
        scriptCount = projects[_projectId].scriptCount;
        resourceIpfsHash = projects[_projectId].resourceIpfsHash;
        locked = projects[_projectId].locked;
    }

    function projectScriptByIndex(uint256 _projectId, uint256 _index) view public returns (string memory){

        return projects[_projectId].scripts[_index];
    }

    function projectURIInfo(uint256 _projectId) view public returns (string memory projectBaseURI, string memory resourceBaseIpfsURI) {

        projectBaseURI = projects[_projectId].projectBaseURI;
        resourceBaseIpfsURI = projects[_projectId].resourceBaseIpfsURI;
    }

    function projectShowAllTokens(uint _projectId) public view returns (uint256[] memory){

        return projectIdToTokenIds[_projectId];
    }

    function tokensOfOwner(address owner) external view returns (uint256[] memory) {

        return _tokensOfOwner(owner);
    }

    function getRoyaltyData(uint256 _tokenId) public view returns (address artistAddress, address additionalPayee, uint256 thirdAddressPercentage, uint256 royaltyFeeByID) {

        artistAddress = projects[tokenIdToProjectId[_tokenId]].artistAddress;
        additionalPayee = projects[tokenIdToProjectId[_tokenId]].additionalPayee;
        thirdAddressPercentage = projects[tokenIdToProjectId[_tokenId]].thirdAddressPercentage;
        royaltyFeeByID = projects[tokenIdToProjectId[_tokenId]].secondMarketRoyalty;
    }

    function tokenURI(uint256 _tokenId) external view onlyValidTokenId(_tokenId) returns (string memory) {

        return Strings.strConcat(projects[tokenIdToProjectId[_tokenId]].projectBaseURI, Strings.uint2str(_tokenId));
    }
}
